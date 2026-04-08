/// IDs de AdMob (Whalyze) y SKUs de compras in-app en Google Play.
///
/// Cada id debe existir en Play Console como producto **gestionado → consumible**
/// (one-time) con el mismo identificador.
class MonetizationConfig {
  MonetizationConfig._();

  /// Anuncio bonificado — emplazamiento "Bonificado paywall".
  static const rewardedAdUnitId =
      'ca-app-pub-3143297085616264/5457284961';

  static const String wrappedProductId5 = '05_wrap';
  static const String wrappedProductId10 = '10_wrap';

  static const Set<String> wrappedProductIds = {
    wrappedProductId5,
    wrappedProductId10,
  };

  /// Créditos de wrapped otorgados tras compra confirmada (o restauración).
  static int? wrappedSlotsForProductId(String productId) {
    switch (productId) {
      case wrappedProductId5:
        return 5;
      case wrappedProductId10:
        return 10;
      default:
        return null;
    }
  }
}
