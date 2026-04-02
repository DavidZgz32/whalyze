import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kPrefsDeviceId = 'firebase_user_device_id';
const _kPrefsIndividualCount = 'user_wrapped_individual_cache';
const _kPrefsGroupCount = 'user_wrapped_group_cache';
const _kPrefsRemaining = 'user_wrapped_remaining_cache';
const _kPrefsHasPaid = 'user_has_paid_cache';

const _kFieldIndividual = 'individualWrappedCount';
const _kFieldGroup = 'groupWrappedCount';
const _kFieldRemaining = 'remainingWrappeds';

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

/// Cupo actual para mostrar en UI (p. ej. favoritos). Firestore es la fuente de verdad vía [FirestoreUserService.fetchQuotaSnapshot].
class UserWrappedQuotaSnapshot {
  const UserWrappedQuotaSnapshot({
    required this.individualWrappedCount,
    required this.groupWrappedCount,
    required this.remainingWrappeds,
    required this.hasPaid,
  });

  final int individualWrappedCount;
  final int groupWrappedCount;
  final int remainingWrappeds;
  final bool hasPaid;

  /// Creaciones posibles de un tipo: 1 gratis si aún no usaste ese tipo + [remainingWrappeds] compartido.
  /// `-1` significa ilimitado ([hasPaid] legacy).
  int remainingForKind({required bool isGroup}) {
    if (hasPaid) return -1;
    final freeSlot = isGroup
        ? (groupWrappedCount < 1 ? 1 : 0)
        : (individualWrappedCount < 1 ? 1 : 0);
    return freeSlot + remainingWrappeds;
  }
}

bool _legacyHasPaid(Map<String, dynamic> d) => d['hasPaid'] as bool? ?? false;

/// Lee contadores efectivos; migra campos antiguos (`wrappedCount`, `wrappedQuota`) si faltan los nuevos.
int _individualCount(Map<String, dynamic> d) {
  final v = d[_kFieldIndividual];
  if (v is num) return v.toInt();
  final legacy = d['wrappedCount'];
  if (legacy is num) return legacy.toInt();
  return 0;
}

int _groupCount(Map<String, dynamic> d) {
  final v = d[_kFieldGroup];
  if (v is num) return v.toInt();
  return 0;
}

int _remainingWrappeds(Map<String, dynamic> d) {
  final v = d[_kFieldRemaining];
  if (v is num) return v.toInt();
  final quota = d['wrappedQuota'];
  final count = d['wrappedCount'];
  if (quota is num && count is num) {
    return math.max(0, quota.toInt() - count.toInt());
  }
  return 0;
}

bool _canOpenWrappedKind(Map<String, dynamic> d, {required bool isGroup}) {
  if (_legacyHasPaid(d)) return true;
  if (isGroup) {
    if (_groupCount(d) < 1) return true;
    return _remainingWrappeds(d) > 0;
  }
  if (_individualCount(d) < 1) return true;
  return _remainingWrappeds(d) > 0;
}

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
    final ind = _individualCount(data ?? {});
    final grp = _groupCount(data ?? {});
    final rem = _remainingWrappeds(data ?? {});
    final paid = _legacyHasPaid(data ?? {});
    await prefs.setInt(_kPrefsIndividualCount, ind);
    await prefs.setInt(_kPrefsGroupCount, grp);
    await prefs.setInt(_kPrefsRemaining, rem);
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
          _kFieldIndividual: 0,
          _kFieldGroup: 0,
          _kFieldRemaining: 0,
          'hasPaid': false,
          'deviceId': localDeviceId,
        });
        await _cacheFromDocData({
          _kFieldIndividual: 0,
          _kFieldGroup: 0,
          _kFieldRemaining: 0,
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
  Future<PreflightOpenWrapped> preflightOpenWrapped({
    required bool isGroup,
  }) async {
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

      if (!_canOpenWrappedKind(data, isGroup: isGroup)) {
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
      return UserWrappedQuotaSnapshot(
        individualWrappedCount: _individualCount(data),
        groupWrappedCount: _groupCount(data),
        remainingWrappeds: _remainingWrappeds(data),
        hasPaid: _legacyHasPaid(data),
      );
    } catch (e, st) {
      debugPrint('fetchQuotaSnapshot: $e\n$st');
      return null;
    }
  }

  /// Atomically checks paywall rules and increments counters. [isGroup] must match el tipo de export.
  Future<void> consumeWrappedSlot({required bool isGroup}) async {
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
          _kFieldIndividual: isGroup ? 0 : 1,
          _kFieldGroup: isGroup ? 1 : 0,
          _kFieldRemaining: 0,
          'hasPaid': false,
          'deviceId': boundDeviceId,
        });
        return;
      }

      final d = snap.data() ?? {};
      final paid = _legacyHasPaid(d);
      var ind = _individualCount(d);
      var grp = _groupCount(d);
      var rem = _remainingWrappeds(d);

      if (!paid) {
        final allowed = _canOpenWrappedKind(d, isGroup: isGroup);
        if (!allowed) throw PaywallRequiredException();
      }

      if (isGroup) {
        grp += 1;
        if (!paid && _groupCount(d) >= 1) {
          rem -= 1;
        }
      } else {
        ind += 1;
        if (!paid && _individualCount(d) >= 1) {
          rem -= 1;
        }
      }

      if (!paid && rem < 0) {
        throw PaywallRequiredException();
      }

      final update = <String, dynamic>{
        _kFieldIndividual: ind,
        _kFieldGroup: grp,
        _kFieldRemaining: rem,
      };

      tx.update(ref, update);
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }

  /// +1 wrapped compartido (pool) tras anuncio bonificado.
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
      final rem = _remainingWrappeds(d);
      tx.update(ref, {_kFieldRemaining: rem + 1});
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }

  /// Créditos por pack de pago (consumible).
  Future<void> grantPurchasedWrappedSlots(int slots) async {
    if (slots <= 0) return;
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
      final rem = _remainingWrappeds(d);
      tx.update(ref, {_kFieldRemaining: rem + slots});
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }
}
