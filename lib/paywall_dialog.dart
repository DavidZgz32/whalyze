import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/firestore_user_service.dart';

Future<void> showPaywallDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Límite alcanzado',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Ya has creado un wrapped gratuito. Desbloquea más wraps con la versión de pago.',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Entendido', style: GoogleFonts.poppins()),
        ),
      ],
    ),
  );
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
  final result =
      await FirestoreUserService.instance.preflightOpenWrapped();
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
