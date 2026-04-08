import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../monetization_config.dart';
import 'firestore_user_service.dart';

/// Compras in-app de packs de wrappeds (consumibles); escucha el stream global.
class IapWrappedPackService {
  IapWrappedPackService._();
  static final instance = IapWrappedPackService._();

  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool _listening = false;
  final Map<String, ProductDetails> _productDetailsCache = {};

  /// Detalles cacheados tras [fetchWrappedProducts]; también se rellenan al comprar.
  Map<String, ProductDetails> get cachedProductDetails =>
      Map.unmodifiable(_productDetailsCache);

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
      if (MonetizationConfig.wrappedSlotsForProductId(p.productID) == null) {
        continue;
      }

      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          try {
            await FirestoreUserService.instance.applySuccessfulPurchase(p.productID);
          } catch (e, st) {
            debugPrint('applySuccessfulPurchase: $e\n$st');
          }
          if (p.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(p);
          }
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          debugPrint('IAP error: ${p.error}');
          if (p.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(p);
          }
        case PurchaseStatus.canceled:
          if (p.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(p);
          }
      }
    }
  }

  /// Productos activos desde Play Console (precio localizado en [ProductDetails.price]).
  Future<Map<String, ProductDetails>> fetchWrappedProducts() async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return {};
    final response = await iap.queryProductDetails(MonetizationConfig.wrappedProductIds);
    if (response.error != null) {
      debugPrint('queryProductDetails: ${response.error}');
      return Map.from(_productDetailsCache);
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'IAP queryProductDetails: notFoundIDs=${response.notFoundIDs} '
        '(publica la app vía Play pista de prueba y crea los productos activos con el mismo id)',
      );
    }
    // No vaciar la caché: si Play devuelve lista vacía (p. ej. billing aún no listo), conserva precios previos.
    for (final d in response.productDetails) {
      _productDetailsCache[d.id] = d;
    }
    return Map.unmodifiable(_productDetailsCache);
  }

  /// Inicia el flujo de compra de un consumible. Requiere id en [MonetizationConfig].
  Future<bool> buyWrappedPack(String productId) async {
    if (MonetizationConfig.wrappedSlotsForProductId(productId) == null) {
      return false;
    }
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return false;

    ProductDetails? details = _productDetailsCache[productId];
    if (details == null) {
      await fetchWrappedProducts();
      details = _productDetailsCache[productId];
    }
    if (details == null) return false;

    await iap.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    return true;
  }

  /// Android/iOS: reemite en el stream compras no consumidas / pendientes de reconocer.
  Future<void> restorePurchases() async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return;
    await iap.restorePurchases();
  }
}
