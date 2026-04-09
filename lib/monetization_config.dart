/// IDs de AdMob (Whalyze) y SKUs de compras in-app en Google Play.
///
/// En Play Console aparecen como **Productos únicos** (p. ej. `05_wrap`, `10_wrap`).
/// El id debe coincidir **exactamente** con el de la consola.
///
/// **Si el producto existe en la web pero la app no comprueba:** Google Play a veces
/// no devuelve el SKU hasta que la app está **instalada desde la Play Store**
/// (pista interna/cerrada), con la cuenta en **probadores de licencias**, y puede
/// tardar en propagarse. Probar solo con `flutter run` + USB suele dar precios vacíos
/// o "producto no encontrado" aunque el ID sea correcto.
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
