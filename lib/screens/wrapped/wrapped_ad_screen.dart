import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla 4 del wrapped: pide valoración con 5 estrellas (Play Store / App Store).
class WrappedAdScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedAdScreen({
    super.key,
    required this.totalScreens,
  });

  @override
  Widget build(BuildContext context) {
    final storeText = Platform.isIOS
        ? 'Si te está gustando, valóranos con 5 estrellas en la App Store'
        : 'Si te está gustando, valóranos con 5 estrellas en la Play Store';

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              storeText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 48,
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
