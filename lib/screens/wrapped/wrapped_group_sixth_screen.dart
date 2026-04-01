import 'package:flutter/material.dart';

import 'wrapped_group_placeholder_screen.dart';

class WrappedGroupSixthScreen extends StatelessWidget {
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupSixthScreen({
    super.key,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  Widget build(BuildContext context) {
    return WrappedGroupPlaceholderScreen(
      displayNumber: 6,
      totalScreens: totalScreens,
      slideshowIndex: 5,
      onGroupScreenAnimationsComplete: onGroupScreenAnimationsComplete,
    );
  }
}
