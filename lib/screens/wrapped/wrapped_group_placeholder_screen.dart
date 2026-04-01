import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Marcador de posición para pantallas del Wrapped grupal (2–8).
class WrappedGroupPlaceholderScreen extends StatelessWidget {
  /// Número mostrado al usuario (2…8).
  final int displayNumber;
  final int totalScreens;

  const WrappedGroupPlaceholderScreen({
    super.key,
    required this.displayNumber,
    required this.totalScreens,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              (totalScreens * 4) +
              ((totalScreens - 1) * 2) +
              60,
          bottom: MediaQuery.of(context).padding.bottom + 32,
          left: 32,
          right: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Pantalla grupal $displayNumber',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
