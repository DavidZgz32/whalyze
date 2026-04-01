import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../wrapped_group_roles.dart';
import '../../whatsapp_processor.dart';
import 'wrapped_group_second_screen.dart';

/// Pantalla 3 del Wrapped grupal: reparto de roles humorísticos.
class WrappedGroupThirdScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupThirdScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupThirdScreen> createState() =>
      _WrappedGroupThirdScreenState();
}

class _WrappedGroupThirdScreenState extends State<WrappedGroupThirdScreen>
    with TickerProviderStateMixin {
  static const int _staggerMs = 2000;
  static const int _rowFadeMs = 400;
  static const Color _cardBackground = Color(0xFF3a4254);

  late final List<GroupRoleDisplay> _roles;
  late final List<AnimationController> _rowControllers;
  late final List<Animation<double>> _rowOpacity;

  @override
  void initState() {
    super.initState();
    _roles = buildGroupRoleDisplays(widget.data);
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
        : _staggerMs * (_roles.length - 1) + _rowFadeMs;
    if (completeDelayMs == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onGroupScreenAnimationsComplete?.call(2);
      });
    } else {
      Future<void>.delayed(Duration(milliseconds: completeDelayMs), () {
        if (mounted) widget.onGroupScreenAnimationsComplete?.call(2);
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
              'Asi se reparten los roles',
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
                        child: _RoleCard(
                          role: _roles[i],
                          cardColor: _cardBackground,
                        ),
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

class _RoleCard extends StatelessWidget {
  final GroupRoleDisplay role;
  final Color cardColor;

  const _RoleCard({
    required this.role,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final name = role.winnerName;
    final nameText = name == null || name.isEmpty
        ? '—'
        : WrappedGroupSecondScreen.shortParticipantName(name);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role.emoji,
              style: const TextStyle(fontSize: 28, height: 1.1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 108),
              child: Text(
                nameText,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
