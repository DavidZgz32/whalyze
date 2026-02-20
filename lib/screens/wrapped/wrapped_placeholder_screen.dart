import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WrappedPlaceholderScreen extends StatelessWidget {
  final int screenNumber;
  final int totalScreens;
  /// Si se pasa, se muestra este título en lugar de "Pantalla N".
  final String? title;

  const WrappedPlaceholderScreen({
    super.key,
    required this.screenNumber,
    required this.totalScreens,
    this.title,
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
              title ?? 'Pantalla ${screenNumber + 1}',
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
