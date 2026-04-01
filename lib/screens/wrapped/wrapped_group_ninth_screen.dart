import 'package:flutter/material.dart';

import 'wrapped_final_screen.dart';

/// Pantalla 9 del Wrapped grupal: mismo cierre que el flujo individual.
class WrappedGroupNinthScreen extends StatelessWidget {
  final int totalScreens;
  final VoidCallback onGoHome;

  const WrappedGroupNinthScreen({
    super.key,
    required this.totalScreens,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return WrappedFinalScreen(
      totalScreens: totalScreens,
      onGoHome: onGoHome,
    );
  }
}
