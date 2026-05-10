import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Superficies de tarjeta reutilizables sobre el degradado del Wrapped.
///
/// **Dos estilos** (convención de la app):
///
/// 1. **Vidrio** — [WrappedGlassCard] + tokens en esta clase (`glass*`).
///    Pantalla de referencia: «Hitos del chat» (wrapped grupal).
///
/// 2. **Rol sólido** — [WrappedContentSurfaces.roleCardDecoration].
///    Pantalla de referencia: «Así se reparten los roles» (`WrappedGroupRoleCard`).
abstract final class WrappedContentSurfaces {
  WrappedContentSurfaces._();

  // --- Vidrio (Hitos del chat, etc.) ---

  static const double glassBorderRadius = 22.0;
  static const double glassBlurSigma = 10.0;

  static List<Color> get glassGradientColors => [
        Colors.white.withValues(alpha: 0.20),
        Colors.white.withValues(alpha: 0.06),
      ];

  static Color get glassBorderColor =>
      Colors.white.withValues(alpha: 0.24);

  static List<BoxShadow> get glassOuterShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
      ];

  // --- Tarjeta de roles (sólida + acento) ---

  static const Color roleCardBaseColor = Color(0xFF334155);
  static const double roleCardBorderRadius = 12.0;
  static const double roleCardAccentHeight = 3.0;

  static List<BoxShadow> get roleCardShadow => const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ];

  /// Decoración de [WrappedGroupRoleCard] y pantallas «Así se reparten los roles».
  static BoxDecoration roleCardDecoration({
    required Color accentTopColor,
    Color baseColor = roleCardBaseColor,
  }) {
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(roleCardBorderRadius),
      border: Border(
        top: BorderSide(
          color: accentTopColor,
          width: roleCardAccentHeight,
        ),
      ),
      boxShadow: roleCardShadow,
    );
  }
}

/// Tarjeta estilo vidrio (blur + borde claro). Usada en hitos del chat grupal.
class WrappedGlassCard extends StatelessWidget {
  const WrappedGlassCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.only(bottom: 14),
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 14),
    this.borderRadius = WrappedContentSurfaces.glassBorderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(borderRadius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: WrappedContentSurfaces.glassOuterShadow,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WrappedContentSurfaces.glassBlurSigma,
            sigmaY: WrappedContentSurfaces.glassBlurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              border: Border.all(
                color: WrappedContentSurfaces.glassBorderColor,
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: WrappedContentSurfaces.glassGradientColors,
                stops: const [0.0, 1.0],
              ),
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
