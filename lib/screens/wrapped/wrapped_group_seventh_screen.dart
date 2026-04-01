import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupSeventhScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedGroupSeventhScreen({super.key, required this.totalScreens});

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 7,
      totalScreens: totalScreens,
    );
  }
}
