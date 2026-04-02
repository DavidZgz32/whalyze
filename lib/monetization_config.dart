/// IDs de AdMob (Whalyze) y SKU del pack en Google Play.
/// Crea en Play Console un producto **consumible** con el mismo id que [wrappedSixPackProductId].
class MonetizationConfig {
  MonetizationConfig._();

  /// Anuncio bonificado — emplazamiento "Bonificado paywall".
  static const rewardedAdUnitId =
      'ca-app-pub-3143297085616264/5457284961';

  /// Sustituye por el id real del producto en Play Console (Managed product → consumible).
  static const wrappedSixPackProductId = 'whalyze_wrapped_pack_6';
}
