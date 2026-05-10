import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/participant_utils.dart';
import '../../whatsapp_processor.dart';
import 'wrapped_intro_shared.dart';

/// Pausa al final de la pantalla 1 grupal para leer el último bloque (debe coincidir con la estimación).
const int _kWrappedGroupFirstFinalReadPauseMs = 3000;

/// Pantalla 1 del Wrapped grupal: bienvenida, hasta 12 bolitas con iniciales y color por persona.
class WrappedGroupFirstScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  /// Índice en el slideshow (0). Cuando acaban todas las animaciones de esta pantalla.
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  /// Duración estimada de la fase de animaciones (sin el hold de 1 s del slideshow).
  /// Debe coincidir con los delays y duraciones de [WrappedGroupFirstScreenState].
  static int estimateGroupFirstContentMs(int participantCount) {
    final n = participantCount.clamp(1, 12);
    const titleFade = 1200;
    const delayAfterTitleFade = 800;
    const titlePos = 1000;
    const delayAfterTitlePos = 600;
    const groupNameMax = 450;
    const delayAfterGroupName = 150;
    const ballDur = 400;
    const betweenBalls = 80;
    final ballsMs = n * ballDur + (n > 1 ? (n - 1) * betweenBalls : 0);
    const waitBeforeParticipants = 1000;
    const participantsFade = 600;
    const delayBeforeFirstMessage = 350;
    const firstMsg = 1000;
    const delayAfterFirstMessage = 1200;
    const days = 1000;
    const delayAfterDays = 1000;
    const random = 1000;
    const yearCaptionExtra = 350 + 800;
    return titleFade +
        delayAfterTitleFade +
        titlePos +
        delayAfterTitlePos +
        groupNameMax +
        delayAfterGroupName +
        ballsMs +
        waitBeforeParticipants +
        participantsFade +
        delayBeforeFirstMessage +
        firstMsg +
        delayAfterFirstMessage +
        days +
        delayAfterDays +
        random +
        yearCaptionExtra +
        _kWrappedGroupFirstFinalReadPauseMs;
  }

  const WrappedGroupFirstScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupFirstScreen> createState() =>
      WrappedGroupFirstScreenState();
}

class WrappedGroupFirstScreenState extends State<WrappedGroupFirstScreen>
    with TickerProviderStateMixin {
  static const int _maxBalls = 12;
  static const double _ballSize = 40;

  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late List<AnimationController> _ballControllers;
  late AnimationController _firstMessageController;
  late AnimationController _daysController;
  late AnimationController _randomMessageController;
  late AnimationController _participantsLabelController;
  AnimationController? _groupNameController;
  Animation<double>? _groupNameAnimation;
  AnimationController? _yearCaptionController;
  Animation<double>? _yearCaptionAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late List<Animation<double>> _ballAnimations;
  late Animation<double> _firstMessageAnimation;
  late Animation<double> _daysAnimation;
  late Animation<double> _randomMessageAnimation;
  late Animation<double> _participantsLabelAnimation;

  String? _randomMessage;
  String? _yearCultureLine;
  bool _paused = false;
  int _sequenceGen = 0;

  List<String> get _displayParticipants =>
      widget.data.participants.take(_maxBalls).toList();

  @override
  void initState() {
    super.initState();
    final n = _displayParticipants.length;
    final days = WrappedIntroShared.daysSinceFirstMessage(
      widget.data.firstMessageDate,
    );
    _randomMessage = WrappedIntroShared.randomPeriodMessage(days);
    _yearCultureLine = WrappedIntroShared.cultureLineForFirstMessageYear(
      widget.data.firstMessageDate,
    );

    final groupLabel = widget.data.groupNameFromExport?.trim();
    if (groupLabel != null && groupLabel.isNotEmpty) {
      _groupNameController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      _groupNameAnimation = CurvedAnimation(
        parent: _groupNameController!,
        curve: Curves.easeOut,
      );
    }

    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _ballControllers = List.generate(
      n,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _firstMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _daysController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _randomMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _participantsLabelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (_yearCultureLine != null && _yearCultureLine!.isNotEmpty) {
      _yearCaptionController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      _yearCaptionAnimation = CurvedAnimation(
        parent: _yearCaptionController!,
        curve: Curves.easeOut,
      );
    }

    _titleFadeAnimation = CurvedAnimation(
      parent: _titleFadeController,
      curve: Curves.easeOut,
    );
    _titlePositionAnimation = CurvedAnimation(
      parent: _titlePositionController,
      curve: Curves.easeInOut,
    );
    _ballAnimations = _ballControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _firstMessageAnimation = CurvedAnimation(
      parent: _firstMessageController,
      curve: Curves.easeOut,
    );
    _daysAnimation = CurvedAnimation(
      parent: _daysController,
      curve: Curves.easeOut,
    );
    _randomMessageAnimation = CurvedAnimation(
      parent: _randomMessageController,
      curve: Curves.easeOut,
    );
    _participantsLabelAnimation = CurvedAnimation(
      parent: _participantsLabelController,
      curve: Curves.easeOut,
    );

    _runAnimationSequence();
  }

  Future<void> _waitUntilUnpaused() async {
    while (_paused && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _runAnimationSequence() async {
    final gen = _sequenceGen;
    _paused = false;
    bool aborted() => !mounted || gen != _sequenceGen;

    if (_titleFadeController.value < 1) {
      await _titleFadeController.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(const Duration(milliseconds: 800));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    if (_titlePositionController.value < 1) {
      await _titlePositionController.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(const Duration(milliseconds: 600));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    final gnc = _groupNameController;
    if (gnc != null && gnc.value < 1) {
      await gnc.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(const Duration(milliseconds: 150));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    for (var i = 0; i < _ballControllers.length; i++) {
      final c = _ballControllers[i];
      if (c.value < 1) {
        await c.forward();
      }
      if (aborted()) return;
      await _waitUntilUnpaused();
      if (aborted()) return;
      if (i < _ballControllers.length - 1) {
        await Future.delayed(const Duration(milliseconds: 80));
        if (aborted()) return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    if (_participantsLabelController.value < 1) {
      await _participantsLabelController.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(const Duration(milliseconds: 350));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    if (_firstMessageController.value < 1) {
      await _firstMessageController.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(const Duration(milliseconds: 1200));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    if (_daysController.value < 1) {
      await _daysController.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(const Duration(milliseconds: 1000));
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    if (_randomMessage != null &&
        _randomMessage!.isNotEmpty &&
        _randomMessageController.value < 1) {
      await _randomMessageController.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    final ycc = _yearCaptionController;
    if (ycc != null &&
        _yearCultureLine != null &&
        _yearCultureLine!.isNotEmpty &&
        ycc.value < 1) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (aborted()) return;
      await _waitUntilUnpaused();
      if (aborted()) return;
      await ycc.forward();
    }
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    await Future.delayed(
      const Duration(milliseconds: _kWrappedGroupFirstFinalReadPauseMs),
    );
    if (aborted()) return;
    await _waitUntilUnpaused();
    if (aborted()) return;

    if (mounted) {
      widget.onGroupScreenAnimationsComplete?.call(0);
    }
  }

  Widget _buildBall(String participant) {
    final color = getParticipantColor(participant);
    final initials = getParticipantInitials(participant);
    return Container(
      width: _ballSize,
      height: _ballSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void resetAnimations() {
    _sequenceGen++;
    _paused = false;
    _titleFadeController.reset();
    _titlePositionController.reset();
    _groupNameController?.reset();
    for (final c in _ballControllers) {
      c.reset();
    }
    _participantsLabelController.reset();
    _firstMessageController.reset();
    _daysController.reset();
    _randomMessageController.reset();
    _yearCaptionController?.reset();
    _runAnimationSequence();
  }

  void jumpAnimationsToEnd() {
    _sequenceGen++;
    _paused = false;
    _titleFadeController.value = 1;
    _titlePositionController.value = 1;
    if (_groupNameController != null) {
      _groupNameController!.value = 1;
    }
    for (final c in _ballControllers) {
      c.value = 1;
    }
    _participantsLabelController.value = 1;
    _firstMessageController.value = 1;
    _daysController.value = 1;
    _randomMessageController.value = 1;
    if (_yearCaptionController != null) {
      _yearCaptionController!.value = 1;
    }
    if (mounted) setState(() {});
  }

  void pauseAnimations() {
    _paused = true;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    _groupNameController?.stop(canceled: false);
    for (final c in _ballControllers) {
      c.stop(canceled: false);
    }
    _participantsLabelController.stop(canceled: false);
    _firstMessageController.stop(canceled: false);
    _daysController.stop(canceled: false);
    _randomMessageController.stop(canceled: false);
    _yearCaptionController?.stop(canceled: false);
  }

  void resumeAnimations() {
    _paused = false;
    void forwardIfInProgress(AnimationController c) {
      if (c.value > 0 && c.value < 1) {
        c.forward();
      }
    }

    forwardIfInProgress(_titleFadeController);
    forwardIfInProgress(_titlePositionController);
    if (_groupNameController != null) {
      forwardIfInProgress(_groupNameController!);
    }
    for (final c in _ballControllers) {
      forwardIfInProgress(c);
    }
    forwardIfInProgress(_participantsLabelController);
    forwardIfInProgress(_firstMessageController);
    forwardIfInProgress(_daysController);
    forwardIfInProgress(_randomMessageController);
    if (_yearCaptionController != null) {
      forwardIfInProgress(_yearCaptionController!);
    }
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    for (final c in _ballControllers) {
      c.dispose();
    }
    _participantsLabelController.dispose();
    _firstMessageController.dispose();
    _daysController.dispose();
    _randomMessageController.dispose();
    _yearCaptionController?.dispose();
    _groupNameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstMessageText = widget.data.firstMessageText;
    final firstDayText =
        WrappedIntroShared.firstDayPhrase(widget.data.firstMessageDate);
    final daysSince = WrappedIntroShared.daysSinceFirstMessage(
      widget.data.firstMessageDate,
    );

    final limitedFirstMessage =
        firstMessageText != null && firstMessageText.isNotEmpty
            ? WrappedIntroShared.truncateAtWordBoundary(firstMessageText, 72)
            : null;

    final groupName = widget.data.groupNameFromExport?.trim();
    final participantTotal = widget.data.participants.length;
    final participantsLine = participantTotal == 1
        ? '1 participante'
        : '$participantTotal participantes';

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _titleFadeAnimation,
              _titlePositionAnimation,
            ]),
            builder: (context, child) {
              final centerY = screenHeight / 2;
              final titleStartY = centerY - topPadding;
              const titleEndY = 0.0;
              final currentTitleY = titleStartY -
                  (titleStartY - titleEndY) * _titlePositionAnimation.value;

              return Positioned(
                top: topPadding + currentTitleY,
                left: 30,
                right: 30,
                child: Opacity(
                  opacity: _titleFadeAnimation.value,
                  child: Text(
                    'Bienvenid@s a vuestro Wrapped',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: WrappedIntroShared.welcomeTitleStyle(),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 100,
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  if (groupName != null &&
                      groupName.isNotEmpty &&
                      _groupNameAnimation != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FadeTransition(
                        opacity: _groupNameAnimation!,
                        child: Text(
                          groupName,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: WrappedIntroShared.groupNameLabelStyle(),
                        ),
                      ),
                    ),
                  if (_displayParticipants.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_displayParticipants.length, (i) {
                        return FadeTransition(
                          opacity: _ballAnimations[i],
                          child: _buildBall(_displayParticipants[i]),
                        );
                      }),
                    ),
                  AnimatedBuilder(
                    animation: _participantsLabelController,
                    builder: (context, _) {
                      if (_participantsLabelController.value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: FadeTransition(
                          opacity: _participantsLabelAnimation,
                          child: Text(
                            participantsLine,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _firstMessageAnimation,
                    child: Text(
                      limitedFirstMessage != null && firstDayText.isNotEmpty
                          ? 'todo empezó con un... "$limitedFirstMessage" $firstDayText'
                          : limitedFirstMessage != null
                              ? 'todo empezó con un... "$limitedFirstMessage"'
                              : 'todo empezó con un...',
                      textAlign: TextAlign.center,
                      style: WrappedIntroShared.firstMessageBlockStyle(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _daysAnimation,
                    child: Text(
                      'Desde entonces han pasado $daysSince días',
                      textAlign: TextAlign.center,
                      style: WrappedIntroShared.daysSinceBlockStyle(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_randomMessage != null && _randomMessage!.isNotEmpty)
                    FadeTransition(
                      opacity: _randomMessageAnimation,
                      child: Text(
                        _randomMessage!,
                        textAlign: TextAlign.center,
                        style: WrappedIntroShared.periodFactBlockStyle(),
                      ),
                    ),
                  if (_yearCaptionController != null &&
                      _yearCaptionAnimation != null &&
                      _yearCultureLine != null &&
                      _yearCultureLine!.isNotEmpty)
                    AnimatedBuilder(
                      animation: _yearCaptionController!,
                      builder: (context, _) {
                        if (_yearCaptionController!.value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: FadeTransition(
                            opacity: _yearCaptionAnimation!,
                            child: Text(
                              _yearCultureLine!,
                              textAlign: TextAlign.center,
                              style:
                                  WrappedIntroShared.yearCultureCaptionStyle(),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
