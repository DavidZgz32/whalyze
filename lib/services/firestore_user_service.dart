import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../monetization_config.dart';

const _kPrefsDeviceId = 'firebase_user_device_id';
/// Caché local del campo Firestore [wrappedCount] (créditos restantes).
const _kPrefsWrappedRemaining = 'user_wrapped_remaining_cache';
const _kPrefsHasPaid = 'user_has_paid_cache';

/// Créditos de wrapped disponibles (inicio 2 gratis; anuncios/IAP suman).
const _kFieldWrappedCount = 'wrappedCount';
/// Esquema v2: [wrappedCount] = créditos restantes (no confundir con legacy).
const _kFieldSchemaVersion = 'schemaVersion';
const _kSchemaVersion = 2;

class PaywallRequiredException implements Exception {
  PaywallRequiredException();
}

class DeviceSecurityException implements Exception {
  DeviceSecurityException();
}

class FirestoreUserNotReadyException implements Exception {
  FirestoreUserNotReadyException();
}

enum PreflightOpenWrapped { ok, paywall, deviceMismatch, notSignedIn, error }

/// Cupo para UI (p. ej. favoritos). Firestore es la fuente de verdad vía [FirestoreUserService.fetchQuotaSnapshot].
class UserWrappedQuotaSnapshot {
  const UserWrappedQuotaSnapshot({
    required this.wrappedRemaining,
    required this.hasPaid,
  });

  /// Créditos restantes (ignorar si [hasPaid]).
  final int wrappedRemaining;
  final bool hasPaid;

  /// Créditos que aún puedes gastar; -1 = ilimitado ([hasPaid]).
  int get displayRemaining => hasPaid ? -1 : wrappedRemaining;
}

bool _legacyHasPaid(Map<String, dynamic> d) => d['hasPaid'] as bool? ?? false;

// --- Lectura legacy (solo migración) ---

int _legacyIndividual(Map<String, dynamic> d) {
  final v = d['individualWrappedCount'];
  if (v is num) return v.toInt();
  if (d['wrappedQuota'] is num && d['wrappedCount'] is num) {
    return 0;
  }
  final legacy = d['wrappedCount'];
  if (legacy is num) return legacy.toInt();
  return 0;
}

int _legacyGroup(Map<String, dynamic> d) {
  final v = d['groupWrappedCount'];
  if (v is num) return v.toInt();
  return 0;
}

int _legacyRemainingPool(Map<String, dynamic> d) {
  final v = d['remainingWrappeds'];
  if (v is num) return v.toInt();
  final quota = d['wrappedQuota'];
  final count = d['wrappedCount'];
  if (quota is num && count is num) {
    return math.max(0, quota.toInt() - count.toInt());
  }
  return 0;
}

/// [wrappedCount] en Firestore = créditos restantes con [schemaVersion] ≥ 2.
/// Si falta [schemaVersion], se calcula desde el esquema antiguo.
int _effectiveWrappedRemaining(Map<String, dynamic> d) {
  if (_legacyHasPaid(d)) return 0;
  final sv = (d[_kFieldSchemaVersion] as num?)?.toInt() ?? 0;
  if (sv >= _kSchemaVersion) {
    final v = d[_kFieldWrappedCount];
    if (v is num) return math.max(0, v.toInt());
    return 2;
  }
  final ind = _legacyIndividual(d);
  final grp = _legacyGroup(d);
  final pool = _legacyRemainingPool(d);
  return math.max(0, 2 + pool - ind - grp);
}

bool _canOpenWrapped(Map<String, dynamic> d) {
  if (_legacyHasPaid(d)) return true;
  return _effectiveWrappedRemaining(d) > 0;
}

Map<String, dynamic> _stripLegacyWrappedFields() => {
      'individualWrappedCount': FieldValue.delete(),
      'groupWrappedCount': FieldValue.delete(),
      'remainingWrappeds': FieldValue.delete(),
      'wrappedQuota': FieldValue.delete(),
    };

/// Firestore `users/{uid}` as source of truth; anonymous auth + device binding + wrapped quota.
class FirestoreUserService {
  FirestoreUserService._();
  static final instance = FirestoreUserService._();

  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  bool _deviceIdMismatch = false;
  bool _bootstrapDone = false;

  bool get deviceIdMismatch => _deviceIdMismatch;
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
  bool get bootstrapDone => _bootstrapDone;

  DocumentReference<Map<String, dynamic>>? _userRef(String? uid) {
    if (uid == null || uid.isEmpty) return null;
    return _db.collection('users').doc(uid);
  }

  Future<void> _cacheFromDocData(Map<String, dynamic>? data) async {
    final prefs = await SharedPreferences.getInstance();
    final paid = _legacyHasPaid(data ?? {});
    final rem = paid ? 0 : _effectiveWrappedRemaining(data ?? {});
    await prefs.setInt(_kPrefsWrappedRemaining, rem);
    await prefs.setBool(_kPrefsHasPaid, paid);
  }

  /// Call after [Firebase.initializeApp] and anonymous sign-in.
  Future<void> bootstrap() async {
    _bootstrapDone = false;
    _deviceIdMismatch = false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _bootstrapDone = true;
      return;
    }

    final ref = _userRef(user.uid);
    if (ref == null) {
      _bootstrapDone = true;
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var localDeviceId = prefs.getString(_kPrefsDeviceId);
      final snap = await ref.get();

      if (!snap.exists) {
        localDeviceId ??= _uuid.v4();
        await prefs.setString(_kPrefsDeviceId, localDeviceId);
        await ref.set({
          _kFieldWrappedCount: 2,
          _kFieldSchemaVersion: _kSchemaVersion,
          'hasPaid': false,
          'deviceId': localDeviceId,
        });
        await _cacheFromDocData({
          _kFieldWrappedCount: 2,
          _kFieldSchemaVersion: _kSchemaVersion,
          'hasPaid': false,
        });
        _bootstrapDone = true;
        return;
      }

      final data = snap.data() ?? {};
      final remoteDevice = data['deviceId'] as String?;

      await _cacheFromDocData(data);

      if (localDeviceId == null || localDeviceId.isEmpty) {
        if (remoteDevice != null && remoteDevice.isNotEmpty) {
          await prefs.setString(_kPrefsDeviceId, remoteDevice);
        }
        _bootstrapDone = true;
        return;
      }

      if (remoteDevice != null &&
          remoteDevice.isNotEmpty &&
          localDeviceId != remoteDevice) {
        _deviceIdMismatch = true;
        _bootstrapDone = true;
        return;
      }

      if (remoteDevice == null || remoteDevice.isEmpty) {
        await ref.update({'deviceId': localDeviceId});
      }

      _bootstrapDone = true;
    } catch (e, st) {
      debugPrint('FirestoreUserService.bootstrap: $e\n$st');
      _bootstrapDone = true;
    }
  }

  /// Reads server state before opening the wrapped flow (UX gate).
  Future<PreflightOpenWrapped> preflightOpenWrapped() async {
    if (_deviceIdMismatch) return PreflightOpenWrapped.deviceMismatch;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return PreflightOpenWrapped.notSignedIn;

    final ref = _userRef(user.uid);
    if (ref == null) return PreflightOpenWrapped.error;

    try {
      var snap = await ref.get();
      if (!snap.exists) {
        await bootstrap();
        snap = await ref.get();
        if (!snap.exists) return PreflightOpenWrapped.error;
      }
      final data = snap.data() ?? {};
      await _cacheFromDocData(data);

      if (!_canOpenWrapped(data)) {
        return PreflightOpenWrapped.paywall;
      }
      return PreflightOpenWrapped.ok;
    } catch (e, st) {
      debugPrint('preflightOpenWrapped: $e\n$st');
      return PreflightOpenWrapped.error;
    }
  }

  /// Lee el cupo en Firestore para mostrarlo en UI (p. ej. favoritos). `null` si no hay sesión, error o documento ausente.
  Future<UserWrappedQuotaSnapshot?> fetchQuotaSnapshot() async {
    if (_deviceIdMismatch) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final ref = _userRef(user.uid);
    if (ref == null) return null;

    try {
      var snap = await ref.get();
      if (!snap.exists) {
        await bootstrap();
        snap = await ref.get();
        if (!snap.exists) return null;
      }
      final data = snap.data() ?? {};
      await _cacheFromDocData(data);
      final paid = _legacyHasPaid(data);
      return UserWrappedQuotaSnapshot(
        wrappedRemaining: paid ? 0 : _effectiveWrappedRemaining(data),
        hasPaid: paid,
      );
    } catch (e, st) {
      debugPrint('fetchQuotaSnapshot: $e\n$st');
      return null;
    }
  }

  /// Atomically checks paywall rules and decrements [wrappedCount] (1 por creación; cualquier tipo).
  Future<void> consumeWrappedSlot() async {
    if (_deviceIdMismatch) throw DeviceSecurityException();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw FirestoreUserNotReadyException();

    final ref = _userRef(user.uid);
    if (ref == null) throw FirestoreUserNotReadyException();

    final prefs = await SharedPreferences.getInstance();
    var boundDeviceId = prefs.getString(_kPrefsDeviceId);
    if (boundDeviceId == null || boundDeviceId.isEmpty) {
      boundDeviceId = _uuid.v4();
      await prefs.setString(_kPrefsDeviceId, boundDeviceId);
    }

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          _kFieldWrappedCount: 1,
          _kFieldSchemaVersion: _kSchemaVersion,
          'hasPaid': false,
          'deviceId': boundDeviceId,
        });
        return;
      }

      final d = snap.data() ?? {};
      final paid = _legacyHasPaid(d);
      var rem = _effectiveWrappedRemaining(d);

      if (!paid) {
        if (rem <= 0) throw PaywallRequiredException();
        rem -= 1;
      }

      final update = <String, dynamic>{
        _kFieldWrappedCount: rem,
        _kFieldSchemaVersion: _kSchemaVersion,
        ..._stripLegacyWrappedFields(),
      };

      tx.update(ref, update);
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }

  /// +2 wrappeds tras anuncio bonificado.
  Future<void> grantBonusWrappedSlotFromAd() async {
    if (_deviceIdMismatch) throw DeviceSecurityException();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw FirestoreUserNotReadyException();

    final ref = _userRef(user.uid);
    if (ref == null) throw FirestoreUserNotReadyException();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final d = snap.data() ?? {};
      if (_legacyHasPaid(d)) return;
      final rem = _effectiveWrappedRemaining(d);
      tx.update(ref, {
        _kFieldWrappedCount: rem + 2,
        _kFieldSchemaVersion: _kSchemaVersion,
        ..._stripLegacyWrappedFields(),
      });
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }

  /// Tras compra IAP completada: [hasPaid] = true (ilimitado en esta app).
  Future<void> applySuccessfulPurchase(String productId) async {
    final add = MonetizationConfig.wrappedSlotsForProductId(productId);
    if (add == null || add <= 0) return;

    if (_deviceIdMismatch) throw DeviceSecurityException();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw FirestoreUserNotReadyException();

    final ref = _userRef(user.uid);
    if (ref == null) throw FirestoreUserNotReadyException();

    final prefs = await SharedPreferences.getInstance();
    var boundDeviceId = prefs.getString(_kPrefsDeviceId);
    if (boundDeviceId == null || boundDeviceId.isEmpty) {
      boundDeviceId = _uuid.v4();
      await prefs.setString(_kPrefsDeviceId, boundDeviceId);
    }

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          _kFieldWrappedCount: 0,
          _kFieldSchemaVersion: _kSchemaVersion,
          'hasPaid': true,
          'deviceId': boundDeviceId,
        });
        return;
      }

      tx.update(ref, {
        _kFieldWrappedCount: 0,
        _kFieldSchemaVersion: _kSchemaVersion,
        'hasPaid': true,
        ..._stripLegacyWrappedFields(),
      });
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }
}
