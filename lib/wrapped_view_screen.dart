import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/wrapped_model.dart';

class WrappedViewScreen extends StatelessWidget {
  final WrappedModel wrapped;

  const WrappedViewScreen({
    super.key,
    required this.wrapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00C980),
              const Color(0xFF00A6B6),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      '${wrapped.totalLines}',
                      style: GoogleFonts.inter(
                        fontSize: 80,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'líneas',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Participantes',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...wrapped.participants.map((participant) {
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Botón X en la esquina superior derecha
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

