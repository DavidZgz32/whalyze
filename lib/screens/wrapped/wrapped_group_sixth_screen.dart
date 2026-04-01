import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupSixthScreen extends StatelessWidget {
  final int totalScreens;

  const WrappedGroupSixthScreen({super.key, required this.totalScreens});

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 6,
      totalScreens: totalScreens,
    );
  }
}
