import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _purchaseBusy = false;

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
              '¡Listo! Tienes +1 wrapped gratis.',
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

  Future<void> _onBuyPack() async {
    if (_purchaseBusy) return;
    setState(() => _purchaseBusy = true);
    try {
      final ok =
          await IapWrappedPackService.instance.buySixPack();
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo iniciar la compra. Comprueba que el producto existe en Play Console y está activo.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Completa el pago en Google Play. Se añadirán 6 wrappeds al confirmar.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchaseBusy = false);
    }
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      title: Text(
        'Has creado un wrapped gratuito, ahora puedes pagar o ver un anuncio para crear más',
        style: titleStyle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _purchaseBusy ? null : _onBuyPack,
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
                            'Pagar 4,99 €',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3A5F),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'por 6 wrappeds',
                            style: bodyStyle,
                          ),
                          if (_purchaseBusy) ...[
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
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
                            'Ver anuncio',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+1 wrapped gratis',
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
              ),
            ],
          ),
        ],
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
/// [isGroup] debe coincidir con si el chat tiene más de dos participantes (export grupal).
Future<bool> guardOpenWrapped(
  BuildContext context, {
  required bool isGroup,
}) async {
  final result =
      await FirestoreUserService.instance.preflightOpenWrapped(isGroup: isGroup);
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
