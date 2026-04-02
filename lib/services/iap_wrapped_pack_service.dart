import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../monetization_config.dart';
import 'firestore_user_service.dart';

/// Compra del pack de 6 wrappeds; escucha el stream global de compras.
class IapWrappedPackService {
  IapWrappedPackService._();
  static final instance = IapWrappedPackService._();

  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _listening = false;

  void startListening() {
    if (_listening) return;
    _listening = true;
    _sub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e, StackTrace st) =>
          debugPrint('IAP stream error: $e\n$st'),
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _listening = false;
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != MonetizationConfig.wrappedSixPackProductId) continue;

      if (p.status == PurchaseStatus.purchased) {
        try {
          await FirestoreUserService.instance.grantPurchasedWrappedSlots(6);
        } catch (e, st) {
          debugPrint('grantPurchasedWrappedSlots: $e\n$st');
        }
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
      } else if (p.status == PurchaseStatus.error) {
        debugPrint('IAP error: ${p.error}');
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
      } else if (p.status == PurchaseStatus.canceled) {
        if (p.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(p);
        }
      }
    }
  }

  /// Devuelve false si la tienda no está disponible o el producto no existe aún.
  Future<bool> buySixPack() async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return false;
    final response = await iap.queryProductDetails({
      MonetizationConfig.wrappedSixPackProductId,
    });
    if (response.error != null) {
      debugPrint('queryProductDetails: ${response.error}');
      return false;
    }
    if (response.productDetails.isEmpty) return false;
    final details = response.productDetails.first;
    await iap.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    return true;
  }
}
