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

  /// Último resultado de consulta a Play (para mensajes de error en UI).
  bool lastBillingUnavailable = false;
  String? lastProductQueryError;
  List<String> lastNotFoundProductIds = [];

  /// Texto breve con la causa más probable cuando [buyWrappedPack] falla.
  String purchaseSetupHint() {
    if (lastBillingUnavailable) {
      return 'Google Play (facturación) no está disponible en este dispositivo. '
          'Comprueba que Play Store esté instalado y actualizado.';
    }
    if (lastProductQueryError != null && lastProductQueryError!.isNotEmpty) {
      return 'Error al pedir productos a Play: $lastProductQueryError';
    }
    if (lastNotFoundProductIds.isNotEmpty) {
      return 'Play no devolvió los IDs: ${lastNotFoundProductIds.join(", ")}. '
          'Aunque existan en la consola, la prueba suele fallar si la app no está '
          'instalada desde Play (pista interna/cerrada). No uses solo `flutter run` '
          'con USB: descarga la app desde la tienda con una cuenta añadida como '
          'probador de licencias; puede tardar horas en propagarse.';
    }
    return 'No hay detalles del producto. Reintenta o instala la build desde Play.';
  }

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
    lastBillingUnavailable = false;
    lastProductQueryError = null;
    lastNotFoundProductIds = [];

    if (!await iap.isAvailable()) {
      lastBillingUnavailable = true;
      debugPrint('IAP: isAvailable() == false');
      return Map.from(_productDetailsCache);
    }
    final response = await iap
        .queryProductDetails(MonetizationConfig.wrappedProductIds)
        .timeout(
          const Duration(seconds: 25),
          onTimeout: () {
            debugPrint(
              'queryProductDetails: timeout (25s); comprueba conexión y Play.',
            );
            return ProductDetailsResponse(
              productDetails: <ProductDetails>[],
              notFoundIDs: MonetizationConfig.wrappedProductIds.toList(),
            );
          },
        );
    if (response.error != null) {
      final e = response.error!;
      lastProductQueryError = '${e.code}: ${e.message}';
      debugPrint('queryProductDetails: $e');
      return Map.from(_productDetailsCache);
    }
    lastNotFoundProductIds = List<String>.from(response.notFoundIDs);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'IAP queryProductDetails: notFoundIDs=${response.notFoundIDs} '
        '(los IDs existen en consola pero Play no los devuelve: instala desde '
        'pista de prueba, cuenta probador, propagación)',
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

    return iap.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  /// Android/iOS: reemite en el stream compras no consumidas / pendientes de reconocer.
  Future<void> restorePurchases() async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return;
    await iap.restorePurchases();
  }
}
