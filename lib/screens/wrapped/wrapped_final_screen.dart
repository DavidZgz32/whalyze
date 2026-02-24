import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Última pantalla del Wrapped (índice 8): cierre con créditos, compartir, valorar y crear otra historia.
class WrappedFinalScreen extends StatelessWidget {
  final int totalScreens;
  final VoidCallback onGoHome;

  const WrappedFinalScreen({
    super.key,
    required this.totalScreens,
    required this.onGoHome,
  });

  void _onShare(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          'Compartir todavía no está disponible',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _onRate(BuildContext context) {
    // Por ahora no hace nada
  }

  static const Color _teal = Color(0xFF00C980);
  static const Color _tealDark = Color(0xFF00A6B6);

  Widget _buildCardButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_teal, _tealDark],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          'Esta historia ha sido creada con Whalyze',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        // Recuadro 1: Compartir
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _tealDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Comparte el enlace con tus amigos para que vean tu Wrapped ❤️',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildCardButton(
                label: 'Compartir',
                onTap: () => _onShare(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Recuadro 2: Valorar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Si te ha gustado, valóranos en Play Store',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.95),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildCardButton(
                label: 'Valorar',
                onTap: () => _onRate(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Botón CREAR OTRA HISTORIA (grande)
        SizedBox(
          width: double.infinity,
          child: Material(
            borderRadius: BorderRadius.circular(28),
            elevation: 3,
            shadowColor: Colors.black26,
            child: InkWell(
              onTap: onGoHome,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_teal, _tealDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '👈 ',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'CREAR OTRA HISTORIA',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top +
        (totalScreens * 4) +
        ((totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 48;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: bottomPadding,
          left: 24,
          right: 24,
        ),
        child: _buildBody(context),
      ),
    );
  }
}
