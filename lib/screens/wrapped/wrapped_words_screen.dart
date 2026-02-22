import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Pantalla 8 del wrapped (índice 7): Palabras más usadas por número de letras.
/// Una palabra por longitud (14 a 4), la más usada en todo el chat.
/// Cada palabra entra desde la derecha deslizándose al centro; el número va entre paréntesis a la derecha.
class WrappedWordsScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedWordsScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedWordsScreen> createState() => WrappedWordsScreenState();
}

class WrappedWordsScreenState extends State<WrappedWordsScreen>
    with TickerProviderStateMixin {
  static const int _minLength = 4;
  static const int _maxLength = 14;
  static const int _slideDurationMs = 700;
  static const int _delayBetweenWordsMs = 900;

  late List<_WordEntry> _entries;
  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late List<AnimationController> _wordControllers;
  late List<Animation<double>> _wordAnimations;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _buildEntries();
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleFadeController, curve: Curves.easeOut),
    );
    _titlePositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _titlePositionController, curve: Curves.easeInOut),
    );
    _wordControllers = List.generate(
      _entries.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _slideDurationMs),
      ),
    );
    _wordAnimations = _wordControllers
        .map((c) => Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
        .toList();
    _startAnimations();
  }

  void _buildEntries() {
    final list = <_WordEntry>[];
    final topByLength = widget.data.topWordByLength;
    for (int len = _maxLength; len >= _minLength; len--) {
      final word = topByLength[len];
      if (word != null && word.isNotEmpty) {
        list.add(_WordEntry(word: word, length: len));
      }
    }
    _entries = list;
  }

  Future<void> _startAnimations() async {
    _paused = false;
    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _paused) return;
        _titlePositionController.forward().then((_) {
          if (!mounted || _paused) return;
          _animateWords();
        });
      });
    });
  }

  Future<void> _animateWords() async {
    for (int i = 0; i < _wordControllers.length; i++) {
      if (!mounted || _paused) return;
      _wordControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: _delayBetweenWordsMs));
    }
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    for (final c in _wordControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void resetAnimations() {
    _titleFadeController.reset();
    _titlePositionController.reset();
    for (final c in _wordControllers) {
      c.reset();
    }
    _startAnimations();
  }

  void pauseAnimations() {
    _paused = true;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    for (final c in _wordControllers) {
      c.stop(canceled: false);
    }
  }

  void resumeAnimations() {
    _paused = false;
    void forwardIfInProgress(AnimationController c) {
      if (c.value > 0 && c.value < 1) c.forward();
    }
    forwardIfInProgress(_titleFadeController);
    forwardIfInProgress(_titlePositionController);
    for (final c in _wordControllers) {
      forwardIfInProgress(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
    const horizontalPadding = 24.0;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge(
                [_titleFadeAnimation, _titlePositionAnimation]),
            builder: (context, child) {
              final centerY = screenHeight / 2;
              final titleStartY = centerY - topPadding;
              final titleEndY = 0.0;
              final currentTitleY = titleStartY -
                  (titleStartY - titleEndY) * _titlePositionAnimation.value;

              return Positioned(
                top: topPadding + currentTitleY,
                left: horizontalPadding,
                right: horizontalPadding,
                child: Opacity(
                  opacity: _titleFadeAnimation.value,
                  child: Text(
                    'Palabras más usadas por número de letras',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: MediaQuery.of(context).size.width < 380 ? 22 : 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 80,
              bottom: bottomPadding,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final slideDistance = constraints.maxWidth + 80;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRect(
                        clipBehavior: Clip.hardEdge,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_entries.length, (i) {
                              final e = _entries[i];
                              return AnimatedBuilder(
                                animation: _wordAnimations[i],
                                builder: (context, child) {
                                  final t = _wordAnimations[i].value;
                                  final offset = slideDistance * t;
                                  return Transform.translate(
                                    offset: Offset(offset, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              e.word,
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '(${e.length})',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WordEntry {
  final String word;
  final int length;

  _WordEntry({required this.word, required this.length});
}
