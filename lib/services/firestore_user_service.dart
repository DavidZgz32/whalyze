import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kPrefsDeviceId = 'firebase_user_device_id';
const _kPrefsWrappedCount = 'user_wrapped_count_cache';
const _kPrefsHasPaid = 'user_has_paid_cache';

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

  Future<void> _writeCache(
    SharedPreferences prefs,
    int wrappedCount,
    bool hasPaid,
  ) async {
    await prefs.setInt(_kPrefsWrappedCount, wrappedCount);
    await prefs.setBool(_kPrefsHasPaid, hasPaid);
  }

  Future<void> _cacheFromDocData(Map<String, dynamic>? data) async {
    final prefs = await SharedPreferences.getInstance();
    final count = (data?['wrappedCount'] as num?)?.toInt() ?? 0;
    final paid = data?['hasPaid'] as bool? ?? false;
    await prefs.setInt(_kPrefsWrappedCount, count);
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
          'wrappedCount': 0,
          'hasPaid': false,
          'deviceId': localDeviceId,
        });
        await _writeCache(prefs, 0, false);
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

      final count = (data['wrappedCount'] as num?)?.toInt() ?? 0;
      final paid = data['hasPaid'] as bool? ?? false;
      if (count >= 1 && !paid) return PreflightOpenWrapped.paywall;
      return PreflightOpenWrapped.ok;
    } catch (e, st) {
      debugPrint('preflightOpenWrapped: $e\n$st');
      return PreflightOpenWrapped.error;
    }
  }

  /// Atomically checks paywall rules and increments [wrappedCount]. Updates local cache after success.
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
          'wrappedCount': 1,
          'hasPaid': false,
          'deviceId': boundDeviceId,
        });
        return;
      }

      final d = snap.data() ?? {};
      final count = (d['wrappedCount'] as num?)?.toInt() ?? 0;
      final paid = d['hasPaid'] as bool? ?? false;
      if (count >= 1 && !paid) {
        throw PaywallRequiredException();
      }
      tx.update(ref, {'wrappedCount': count + 1});
    });

    final fresh = await ref.get();
    await _cacheFromDocData(fresh.data());
  }
}
