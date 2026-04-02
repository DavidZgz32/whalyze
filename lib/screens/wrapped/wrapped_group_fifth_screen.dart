import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../whatsapp_processor.dart';
import 'wrapped_intro_shared.dart';

class WrappedGroupFifthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupFifthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupFifthScreen> createState() =>
      _WrappedGroupFifthScreenState();
}

class _WrappedGroupFifthScreenState extends State<WrappedGroupFifthScreen>
    with TickerProviderStateMixin {
  // 0=oro, 1=plata, 2=bronce
  late final List<_EmojiMedal> _topEmojis = _computeTopEmojis();

  late final AnimationController _appearCtrl;
  Animation<double> _dayOpacity = const AlwaysStoppedAnimation(0.0);
  Animation<double> _monthOpacity = const AlwaysStoppedAnimation(0.0);
  Animation<double> _ladderOpacity = const AlwaysStoppedAnimation(0.0);
  Animation<Offset> _dayOffset =
      const AlwaysStoppedAnimation(Offset(0, 0.06));
  Animation<Offset> _monthOffset =
      const AlwaysStoppedAnimation(Offset(0, 0.06));
  Animation<Offset> _ladderOffset =
      const AlwaysStoppedAnimation(Offset(0, 0.06));

  @override
  void initState() {
    super.initState();

    _appearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
      ),
    );
    _monthOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
      ),
    );
    _ladderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.48, 1.00, curve: Curves.easeOut),
      ),
    );

    _dayOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
      ),
    );
    _monthOffset =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
      ),
    );
    _ladderOffset =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.48, 1.00, curve: Curves.easeOut),
      ),
    );

    _appearCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onGroupScreenAnimationsComplete?.call(4);
      }
    });

    _appearCtrl.forward();
  }

  @override
  void dispose() {
    _appearCtrl.dispose();
    super.dispose();
  }

  static const _monthNames = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String _formatDate(String dateKey) {
    // dateKey formato: "YYYY-MM-DD"
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final day = int.tryParse(parts[2]);
    final monthNum = int.tryParse(parts[1]);
    final year = parts[0];
    if (day == null || monthNum == null || monthNum < 1 || monthNum > 12) {
      return dateKey;
    }
    return '$day de ${_monthNames[monthNum - 1]} de $year';
  }

  String _formatMonth(String monthKey) {
    // monthKey formato: "YYYY-MM"
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final monthNum = int.tryParse(parts[1]);
    final year = parts[0];
    if (monthNum == null || monthNum < 1 || monthNum > 12) return monthKey;
    return '${_monthNames[monthNum - 1]} $year';
  }

  List<_EmojiMedal> _computeTopEmojis() {
    final emojiCounts = <String, int>{};
    for (final participant in widget.data.participants) {
      final list = widget.data.emojiStatsByParticipant[participant] ??
          const <EmojiStat>[];
      for (final e in list) {
        emojiCounts[e.emoji] = (emojiCounts[e.emoji] ?? 0) + e.count;
      }
    }

    final sorted = emojiCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).toList().asMap().entries.map((entry) {
      final rank = entry.key; // 0..2
      final emoji = entry.value.key;
      final count = entry.value.value;
      return _EmojiMedal(rank: rank, emoji: emoji, count: count);
    }).toList();
  }

  Color _medalColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFD54F); // oro
      case 1:
        return const Color(0xFFC0C0C0); // plata
      case 2:
        return const Color(0xFFCD7F32); // bronce
      default:
        return Colors.white;
    }
  }

  String _medalEmoji(int rank) {
    switch (rank) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '🏅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    // "Creado con Whalyze" vive por debajo en el `Stack` del slideshow.
    // Dejamos margen extra para que no se corte en móviles pequeños.
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

    final scale = (screenWidth / 360).clamp(0.9, 1.15);

    final dayKey = widget.data.dayWithMostMessages;
    final dayCount = widget.data.dayWithMostMessagesCount;
    final monthKey = widget.data.monthWithMostMessages;
    final monthCount = widget.data.monthWithMostMessagesCount;

    final availableWidth = screenWidth - 44; // 22+22 padding en este widget
    final stepWidth = availableWidth < 320 ? availableWidth : 320.0;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding + 4,
          left: 22,
          right: 22,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (dayKey != null && dayCount > 0)
                      FadeTransition(
                        opacity: _dayOpacity,
                        child: SlideTransition(
                          position: _dayOffset,
                          child: _StatCard(
                            title: 'EL DÍA QUE MÁS SE HABLÓ',
                            dateText: _formatDate(dayKey),
                            count: dayCount,
                            scale: scale,
                          ),
                        ),
                      ),
                    if (dayKey != null &&
                        dayCount > 0 &&
                        monthKey != null &&
                        monthCount > 0)
                      const SizedBox(height: 16),
                    if (monthKey != null && monthCount > 0)
                      FadeTransition(
                        opacity: _monthOpacity,
                        child: SlideTransition(
                          position: _monthOffset,
                          child: _StatCard(
                            title: 'EL MES QUE MÁS SE HABLÓ',
                            dateText: _formatMonth(monthKey),
                            count: monthCount,
                            scale: scale,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    FadeTransition(
                      opacity: _ladderOpacity,
                      child: SlideTransition(
                        position: _ladderOffset,
                        child: _EmojiLadder(
                          medals: _topEmojis,
                          medalColor: _medalColor,
                          medalEmoji: _medalEmoji,
                          stepWidth: stepWidth,
                          scale: scale,
                        ),
                      ),
                    ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String dateText;
  final int count;
  final double scale;

  const _StatCard({
    required this.title,
    required this.dateText,
    required this.count,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final countFont = 40.0 * scale;
    final dateFont = 20.0 * scale;
    final titleFont = 18.0 * scale;
    final labelFont = 16.0 * scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: titleFont,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: dateFont,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WrappedIntroShared.formatThousands(count),
                style: GoogleFonts.poppins(
                  fontSize: countFont,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'mensajes',
                style: GoogleFonts.poppins(
                  fontSize: labelFont,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiLadder extends StatelessWidget {
  final List<_EmojiMedal> medals;
  final Color Function(int rank) medalColor;
  final String Function(int rank) medalEmoji;
  final double stepWidth;
  final double scale;

  const _EmojiLadder({
    required this.medals,
    required this.medalColor,
    required this.medalEmoji,
    required this.stepWidth,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    // El ladder se ajusta para no quedar cortado en móviles pequeños.
    final baseLadderHeight = 260.0 * scale;
    final ladderHeight = math.min(baseLadderHeight, screenH * 0.28);
    final k = baseLadderHeight > 0 ? ladderHeight / baseLadderHeight : 1.0;

    final stepHeights =
        <double>[92, 82, 72].map((v) => v * scale * k).toList();
    final stepBottoms =
        <double>[150, 80, 20].map((v) => v * scale * k).toList();

    final titleFont = 20.0 * scale;
    final subGap = 8.0 * scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '3 EMOJIS MÁS USADOS',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: titleFont,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        SizedBox(height: subGap),
        SizedBox(
          height: ladderHeight,
          width: double.infinity,
          child: Stack(
            children: [
              for (final m in medals)
                Positioned(
                  bottom: stepBottoms[m.rank],
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _MedalStep(
                      medalEmoji: medalEmoji(m.rank),
                      emoji: m.emoji,
                      count: m.count,
                      height: stepHeights[m.rank],
                      width: stepWidth,
                      color: medalColor(m.rank),
                      scale: scale,
                      rank: m.rank,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MedalStep extends StatelessWidget {
  final String medalEmoji;
  final String emoji;
  final int count;
  final double height;
  final double width;
  final Color color;
  final double scale;
  final int rank;

  const _MedalStep({
    required this.medalEmoji,
    required this.emoji,
    required this.count,
    required this.height,
    required this.width,
    required this.color,
    required this.scale,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final stepPadX = 16.0 * scale;
    final rankFont = 26.0 * scale;
    final medalFont = 28.0 * scale;
    final emojiFont = 46.0 * scale;
    final countFont = 22.0 * scale;
    final labelFont = 14.0 * scale;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: stepPadX),
      decoration: BoxDecoration(
        color: color.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                medalEmoji,
                style: GoogleFonts.inter(
                  fontSize: medalFont,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${rank + 1}',
                style: GoogleFonts.poppins(
                  fontSize: rankFont,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            emoji,
            style: GoogleFonts.poppins(
              fontSize: emojiFont,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            WrappedIntroShared.formatThousands(count),
            style: GoogleFonts.poppins(
              fontSize: countFont,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'usos',
            style: GoogleFonts.poppins(
              fontSize: labelFont,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiMedal {
  final int rank; // 0..2
  final String emoji;
  final int count;

  const _EmojiMedal({
    required this.rank,
    required this.emoji,
    required this.count,
  });
}
