import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupSecondScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedGroupSecondScreen({super.key, required this.totalScreens});

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 2,
      totalScreens: totalScreens,
    );
  }
}
