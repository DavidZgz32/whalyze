import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../whatsapp_processor.dart';
import 'wrapped_intro_shared.dart';

class WrappedGroupSixthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  /// Máx. 6 filas de emoji + pausa + entrada del texto honorífico (alineado con el state).
  static int estimateGroupSixthContentMs() {
    const staggerMs = 1500;
    const rowAnimMs = 450;
    const honorGapMs = 200;
    const honorAnimMs = 750;
    const maxEmojiRows = 6;
    const lastRowDoneMs = (maxEmojiRows - 1) * staggerMs + rowAnimMs;
    return lastRowDoneMs + honorGapMs + honorAnimMs;
  }

  const WrappedGroupSixthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupSixthScreen> createState() => _WrappedGroupSixthScreenState();
}

class _WrappedGroupSixthScreenState extends State<WrappedGroupSixthScreen>
    with TickerProviderStateMixin {
  static const int _staggerMs = 1500;
  static const int _rowAnimMs = 450;
  static const int _honorGapAfterLastEmojiMs = 200;
  static const int _honorAnimMs = 750;

  late final List<MapEntry<String, int>> _topEmojis;
  late final _HonorMention _honorMention;
  late final List<AnimationController> _rowControllers;
  late final List<Animation<double>> _rowOpacity;
  late final List<Animation<Offset>> _rowSlide;

  late final AnimationController _honorMentionController;
  late final Animation<double> _honorMentionOpacity;
  late final Animation<Offset> _honorMentionSlide;

  @override
  void initState() {
    super.initState();
    _topEmojis = _computeTopEmojis();
    _honorMention = _computeHonorMention();

    _honorMentionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _honorAnimMs),
    );
    _honorMentionOpacity = CurvedAnimation(
      parent: _honorMentionController,
      curve: Curves.easeOut,
    );
    _honorMentionSlide = Tween<Offset>(
      begin: const Offset(1.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _honorMentionController,
        curve: Curves.easeOutCubic,
      ),
    );

    _rowControllers = List.generate(
      _topEmojis.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _rowAnimMs),
      ),
    );

    _rowOpacity = _rowControllers
        .map(
          (c) => CurvedAnimation(parent: c, curve: Curves.easeOut),
        )
        .toList();
    _rowSlide = _rowControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0.75, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    for (var i = 0; i < _rowControllers.length; i++) {
      Future<void>.delayed(Duration(milliseconds: i * _staggerMs), () {
        if (!mounted) return;
        _rowControllers[i].forward();
      });
    }

    final int lastEmojiDoneMs = _topEmojis.isEmpty
        ? 0
        : ((_topEmojis.length - 1) * _staggerMs) + _rowAnimMs;
    final int honorStartMs =
        lastEmojiDoneMs + (_topEmojis.isEmpty ? 400 : _honorGapAfterLastEmojiMs);

    Future<void>.delayed(Duration(milliseconds: honorStartMs), () {
      if (!mounted) return;
      _honorMentionController.forward();
    });

    final doneMs = honorStartMs + _honorAnimMs;
    Future<void>.delayed(Duration(milliseconds: doneMs), () {
      if (!mounted) return;
      widget.onGroupScreenAnimationsComplete?.call(5);
    });
  }

  List<MapEntry<String, int>> _computeTopEmojis() {
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
    return sorted.take(6).toList();
  }

  _HonorMention _computeHonorMention() {
    final totals = widget.data.emojiTotalByParticipant;
    if (totals.isEmpty) {
      return const _HonorMention(
        user: 'alguien',
        percentageText: '0',
        favoriteEmoji: '🙂',
        favoriteEmojiCount: 0,
      );
    }

    var topUser = totals.entries.first.key;
    var topTotal = totals.entries.first.value;
    var groupTotal = 0;
    for (final entry in totals.entries) {
      groupTotal += entry.value;
      if (entry.value > topTotal) {
        topUser = entry.key;
        topTotal = entry.value;
      }
    }

    final favList = widget.data.emojiStatsByParticipant[topUser] ?? const <EmojiStat>[];
    String favoriteEmoji = '🙂';
    int favoriteEmojiCount = 0;
    if (favList.isNotEmpty) {
      favoriteEmoji = favList.first.emoji;
      favoriteEmojiCount = favList.first.count;
    }

    final pct = groupTotal > 0 ? (topTotal * 100 / groupTotal) : 0.0;
    final pct1 = pct.toStringAsFixed(1);
    final percentageText = pct1.endsWith('.0') ? pct.toStringAsFixed(0) : pct1;

    return _HonorMention(
      user: topUser,
      percentageText: percentageText,
      favoriteEmoji: favoriteEmoji,
      favoriteEmojiCount: favoriteEmojiCount,
    );
  }

  @override
  void dispose() {
    for (final c in _rowControllers) {
      c.dispose();
    }
    _honorMentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 52;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding + 8,
          left: 22,
          right: 22,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '6 EMOJIS MÁS USADOS',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_topEmojis.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No hay emojis suficientes',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < _topEmojis.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _rowOpacity[i],
                          child: SlideTransition(
                            position: _rowSlide[i],
                            child: _EmojiLine(
                              rank: i + 1,
                              emoji: _topEmojis[i].key,
                              count: _topEmojis[i].value,
                            ),
                          ),
                        ),
                      ],
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _honorMentionOpacity,
                      child: SlideTransition(
                        position: _honorMentionSlide,
                        child: Text(
                          '🎖️ Mención honorífica a ${_honorMention.user}, responsable del ${_honorMention.percentageText}% de los emojis del grupo y de llenar el chat con su emoji favorito ${_honorMention.favoriteEmoji} hasta ${WrappedIntroShared.formatThousands(_honorMention.favoriteEmojiCount)} veces.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.92),
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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

class _HonorMention {
  final String user;
  final String percentageText;
  final String favoriteEmoji;
  final int favoriteEmojiCount;

  const _HonorMention({
    required this.user,
    required this.percentageText,
    required this.favoriteEmoji,
    required this.favoriteEmojiCount,
  });
}

class _EmojiLine extends StatelessWidget {
  final int rank;
  final String emoji;
  final int count;

  const _EmojiLine({
    required this.rank,
    required this.emoji,
    required this.count,
  });

  double _emojiSizeForRank() {
    const baseSize = 28.0;
    switch (rank) {
      case 1:
        return baseSize + 6;
      case 2:
        return baseSize + 4;
      case 3:
        return baseSize + 2;
      case 4:
        return baseSize;
      default:
        return baseSize + (4 - rank);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emojiSize = _emojiSizeForRank();
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: GoogleFonts.poppins(
              fontSize: emojiSize,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            WrappedIntroShared.formatThousands(count),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
