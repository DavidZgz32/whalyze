import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

class WrappedSecondScreen extends StatelessWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedSecondScreen({
    super.key,
    required this.data,
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
              'Participantes',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ...data.participants.map((participant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  participant,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              );
            }),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

