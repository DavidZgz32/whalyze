import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WrappedPlaceholderScreen extends StatelessWidget {
  final int screenNumber;
  final int totalScreens;

  const WrappedPlaceholderScreen({
    super.key,
    required this.screenNumber,
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
              'Pantalla ${screenNumber + 1}',
              style: GoogleFonts.inter(
                fontSize: 32,
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

