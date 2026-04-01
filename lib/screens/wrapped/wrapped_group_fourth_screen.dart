import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupFourthScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedGroupFourthScreen({super.key, required this.totalScreens});

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 4,
      totalScreens: totalScreens,
    );
  }
}
