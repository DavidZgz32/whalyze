import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'monetization_config.dart';
import 'services/firestore_user_service.dart';
import 'services/iap_wrapped_pack_service.dart';
import 'services/rewarded_ad_helper.dart';

Future<void> showPaywallDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const _PaywallDialogBody(),
  );
}

class _PaywallDialogBody extends StatefulWidget {
  const _PaywallDialogBody();

  @override
  State<_PaywallDialogBody> createState() => _PaywallDialogBodyState();
}

class _PaywallDialogBodyState extends State<_PaywallDialogBody> {
  bool _adBusy = false;
  String? _purchasingProductId;
  Map<String, ProductDetails> _products = {};
  bool _productsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Precio localizado de Play; si el string viene vacío, usa [ProductDetails.rawPrice].
  String _priceLabel(ProductDetails? d, {required bool loading}) {
    if (loading) return '…';
    if (d == null) return '—';
    final p = d.price.trim();
    if (p.isNotEmpty) return p;
    if (d.rawPrice > 0 && d.currencyCode.isNotEmpty) {
      return '${d.rawPrice.toStringAsFixed(2)} ${d.currencyCode}';
    }
    return '—';
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _productsLoading = true);
    try {
      for (var attempt = 0; attempt < 4; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(Duration(milliseconds: 350 * attempt));
        }
        final map = await IapWrappedPackService.instance.fetchWrappedProducts();
        if (!mounted) return;
        setState(() {
          _products = Map<String, ProductDetails>.from(map);
        });
        final allFound = MonetizationConfig.wrappedProductIds.every(
          (id) => map[id] != null,
        );
        if (allFound) break;
      }
    } finally {
      if (mounted) setState(() => _productsLoading = false);
    }
  }

  Future<void> _onWatchAd() async {
    if (_adBusy) return;
    setState(() => _adBusy = true);
    var earned = false;
    await RewardedAdHelper.instance.show(
      onFailed: (msg) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg, style: GoogleFonts.poppins())),
        );
      },
      onUserEarnedReward: () {
        earned = true;
      },
    );

    if (earned) {
      try {
        await FirestoreUserService.instance.grantBonusWrappedSlotFromAd();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Listo! Tienes +2 wrappeds gratis.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo aplicar el premio. Inténtalo de nuevo.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    }

    if (mounted) setState(() => _adBusy = false);
  }

  Future<void> _onBuyPack(String productId, int slots) async {
    if (_purchasingProductId != null) return;
    setState(() => _purchasingProductId = productId);
    try {
      if (_products[productId] == null) {
        await _loadProducts();
        if (!mounted) return;
      }
      final ok = await IapWrappedPackService.instance.buyWrappedPack(productId);
      if (!mounted) return;
      if (!ok) {
        final hint = IapWrappedPackService.instance.purchaseSetupHint();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo iniciar la compra ($productId).\n$hint',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Completa el pago en Google Play. Se añadirán $slots wrappeds al confirmar.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasingProductId = null);
    }
  }

  static const _yellowBadge = Color(0xFFFFE082);

  Widget _packCard({
    required String productId,
    required int slots,
    required bool showCheaperLine,
    required TextStyle cheaperLineStyle,
  }) {
    final details = _products[productId];
    final priceText = _priceLabel(details, loading: _productsLoading);
    final busy = _purchasingProductId == productId;
    final greenWrapStyle = GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.45,
      color: const Color(0xFF2E7D32),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: const Color(0xFFF3F6FF),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _purchasingProductId != null
                ? null
                : () => _onBuyPack(productId, slots),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD0DAF5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceText,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('+$slots wrappeds', style: greenWrapStyle),
                  if (showCheaperLine) ...[
                    const SizedBox(height: 4),
                    Text('25% más barato', style: cheaperLineStyle),
                  ],
                  if (busy) ...[
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _yellowBadge,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6C85C)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
    final bodyStyle = GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: Colors.black87,
    );
    final cheaperLineStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: Colors.black54,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      title: Text(
        '¡Has alcanzado tu límite de wrappeds! Puedes ver un anuncio o comprar más para seguir.',
        style: titleStyle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _packCard(
                      productId: MonetizationConfig.wrappedProductId5,
                      slots: 5,
                      showCheaperLine: false,
                      cheaperLineStyle: cheaperLineStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _packCard(
                      productId: MonetizationConfig.wrappedProductId10,
                      slots: 10,
                      showCheaperLine: true,
                      cheaperLineStyle: cheaperLineStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _adBusy ? null : _onWatchAd,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ver anuncio 30 segundos',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '+2 wrappeds gratis',
                        style: bodyStyle.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_adBusy) ...[
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cerrar', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

Future<void> showDeviceSecurityDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Dispositivo no reconocido',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Tu cuenta está asociada a otro dispositivo. Por seguridad, no se pueden crear más wraps en este equipo. Si cambiaste de móvil, contacta con soporte.',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Cerrar', style: GoogleFonts.poppins()),
        ),
      ],
    ),
  );
}

void showFirestoreErrorSnack(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'No se pudo comprobar tu cuenta. Revisa la conexión e inténtalo de nuevo.',
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: Colors.red,
    ),
  );
}

/// Returns `true` if navigation to [WrappedScreen] is allowed.
Future<bool> guardOpenWrapped(BuildContext context) async {
  final result = await FirestoreUserService.instance.preflightOpenWrapped();
  switch (result) {
    case PreflightOpenWrapped.ok:
      return true;
    case PreflightOpenWrapped.paywall:
      if (context.mounted) await showPaywallDialog(context);
      return false;
    case PreflightOpenWrapped.deviceMismatch:
      if (context.mounted) await showDeviceSecurityDialog(context);
      return false;
    case PreflightOpenWrapped.notSignedIn:
    case PreflightOpenWrapped.error:
      if (context.mounted) showFirestoreErrorSnack(context);
      return false;
  }
}
