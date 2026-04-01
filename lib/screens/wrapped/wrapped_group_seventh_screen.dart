import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupSeventhScreen extends StatelessWidget {
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupSeventhScreen({
    super.key,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 7,
      totalScreens: totalScreens,
      slideshowIndex: 6,
      onGroupScreenAnimationsComplete: onGroupScreenAnimationsComplete,
    );
  }
}
