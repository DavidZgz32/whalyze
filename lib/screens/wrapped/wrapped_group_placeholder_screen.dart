import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Marcador de posición para pantallas del Wrapped grupal (índices 2–7 del slideshow).
class WrappedGroupPlaceholderScreen extends StatefulWidget {
  /// Número mostrado al usuario (3…8 según pantalla).
  final int displayNumber;
  final int totalScreens;

  /// Índice del slideshow (2…7), para [onGroupScreenAnimationsComplete].
  final int slideshowIndex;

  /// Tras el primer frame (no hay animaciones que esperar).
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupPlaceholderScreen({
    super.key,
    required this.displayNumber,
    required this.totalScreens,
    required this.slideshowIndex,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupPlaceholderScreen> createState() =>
      _WrappedGroupPlaceholderScreenState();
}

class _WrappedGroupPlaceholderScreenState
    extends State<WrappedGroupPlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onGroupScreenAnimationsComplete
          ?.call(widget.slideshowIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              (widget.totalScreens * 4) +
              ((widget.totalScreens - 1) * 2) +
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
              'Pantalla grupal ${widget.displayNumber}',
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
