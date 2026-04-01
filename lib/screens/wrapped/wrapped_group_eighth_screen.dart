import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupEighthScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedGroupEighthScreen({super.key, required this.totalScreens});

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 8,
      totalScreens: totalScreens,
    );
  }
}
