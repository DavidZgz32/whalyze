import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../wrapped_group_roles.dart';
import 'wrapped_group_role_card.dart';

import '../../whatsapp_processor.dart';

/// Pantalla 4 del Wrapped grupal: roles humorísticos (los “nuevos” roles).
class WrappedGroupFourthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupFourthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupFourthScreen> createState() =>
      _WrappedGroupFourthScreenState();
}

class _WrappedGroupFourthScreenState extends State<WrappedGroupFourthScreen>
    with TickerProviderStateMixin {
  static const int _staggerMs = 2000;
  static const int _rowFadeMs = 400;
  // El slideshow grupal añade 1s de hold post-animación.
  // Queremos 3s después del último fade, así que añadimos 2s extra antes
  // de avisar a través de onGroupScreenAnimationsComplete.
  static const int _extraHoldAfterLastAnimationMs = 2000;

  late final List<GroupRoleDisplay> _roles;
  late final List<AnimationController> _rowControllers;
  late final List<Animation<double>> _rowOpacity;

  @override
  void initState() {
    super.initState();
    _roles = buildGroupRoleDisplaysFourth(widget.data);
    _rowControllers = List.generate(
      _roles.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _rowFadeMs),
      ),
    );
    _rowOpacity = _rowControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    for (var i = 0; i < _rowControllers.length; i++) {
      Future<void>.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (mounted) _rowControllers[i].forward();
      });
    }

    final completeDelayMs = _roles.isEmpty
        ? 0
        : _staggerMs * (_roles.length - 1) + _rowFadeMs + _extraHoldAfterLastAnimationMs;
    if (completeDelayMs == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onGroupScreenAnimationsComplete?.call(3);
      });
    } else {
      Future<void>.delayed(Duration(milliseconds: completeDelayMs), () {
        if (mounted) widget.onGroupScreenAnimationsComplete?.call(3);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _rowControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: padTop + 12,
          left: 22,
          right: 22,
          bottom: MediaQuery.of(context).padding.bottom + 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Así se reparten los roles',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < _roles.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _rowOpacity[i],
                        child: WrappedGroupRoleCard(role: _roles[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
