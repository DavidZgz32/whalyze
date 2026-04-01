import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupFifthScreen extends StatelessWidget {
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupFifthScreen({
    super.key,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 5,
      totalScreens: totalScreens,
      slideshowIndex: 4,
      onGroupScreenAnimationsComplete: onGroupScreenAnimationsComplete,
    );
  }
}
