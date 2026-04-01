import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupThirdScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedGroupThirdScreen({super.key, required this.totalScreens});

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 3,
      totalScreens: totalScreens,
    );
  }
}
