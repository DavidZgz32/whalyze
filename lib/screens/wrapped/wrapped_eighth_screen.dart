import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';
import '../../utils/participant_utils.dart';

/// Pantalla 7 del wrapped (índice 6): Media – mismo formato que ¿Quién mueve el chat?
/// Círculos de iniciales arriba, raya separadora, tabla 3 columnas (título + valor + valor).
class WrappedEighthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedEighthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedEighthScreen> createState() => WrappedEighthScreenState();
}

class WrappedEighthScreenState extends State<WrappedEighthScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late AnimationController _initial1Controller;
  late AnimationController _initial2Controller;
  late AnimationController _separatorController;
  late List<AnimationController> _rowTitleControllers;
  late List<AnimationController> _rowValue1Controllers;
  late List<AnimationController> _rowValue2Controllers;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late Animation<double> _initial1Animation;
  late Animation<double> _initial2Animation;
  late Animation<double> _separatorAnimation;
  late List<Animation<double>> _rowTitleAnimations;
  late List<Animation<double>> _rowValue1Animations;
  late List<Animation<double>> _rowValue2Animations;

  static const double _participantBallSize = 40.0;
  static const Color _numberBadgeBg = Color(0xFF00B872);

  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initial1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initial2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleFadeController, curve: Curves.easeOut),
    );
    _titlePositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _titlePositionController, curve: Curves.easeInOut),
    );
    _initial1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _initial1Controller, curve: Curves.easeOut),
    );
    _initial2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _initial2Controller, curve: Curves.easeOut),
    );

    _separatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _separatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _separatorController, curve: Curves.easeOut),
    );

    const dataRowCount = 3;
    _rowTitleControllers = List.generate(
      dataRowCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _rowValue1Controllers = List.generate(
      dataRowCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _rowValue2Controllers = List.generate(
      dataRowCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _rowTitleAnimations = _rowTitleControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _rowValue1Animations = _rowValue1Controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _rowValue2Animations = _rowValue2Controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _startAnimations();
  }

  void _startAnimations() {
    _paused = false;
    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _paused) return;
        _titlePositionController.forward().then((_) {
          if (!mounted || _paused) return;
          _initial1Controller.forward();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted || _paused) return;
            _initial2Controller.forward().then((_) {
              if (!mounted || _paused) return;
              _separatorController.forward().then((_) {
                if (!mounted || _paused) return;
                _animateRowsSequentially();
              });
            });
          });
        });
      });
    });
  }

  Future<void> _animateRowsSequentially() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted || _paused) return;
    for (int i = 0; i < 3; i++) {
      if (!mounted || _paused) return;
      _rowTitleControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted || _paused) return;
      _rowValue1Controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted || _paused) return;
      _rowValue2Controllers[i].forward();
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    _initial1Controller.dispose();
    _initial2Controller.dispose();
    _separatorController.dispose();
    for (final c in _rowTitleControllers) {
      c.dispose();
    }
    for (final c in _rowValue1Controllers) {
      c.dispose();
    }
    for (final c in _rowValue2Controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void resetAnimations() {
    _titleFadeController.reset();
    _titlePositionController.reset();
    _initial1Controller.reset();
    _initial2Controller.reset();
    _separatorController.reset();
    for (final c in _rowTitleControllers) {
      c.reset();
    }
    for (final c in _rowValue1Controllers) {
      c.reset();
    }
    for (final c in _rowValue2Controllers) {
      c.reset();
    }
    _startAnimations();
  }

  void pauseAnimations() {
    _paused = true;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    _initial1Controller.stop(canceled: false);
    _initial2Controller.stop(canceled: false);
    _separatorController.stop(canceled: false);
    for (final c in _rowTitleControllers) {
      c.stop(canceled: false);
    }
    for (final c in _rowValue1Controllers) {
      c.stop(canceled: false);
    }
    for (final c in _rowValue2Controllers) {
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
    forwardIfInProgress(_initial1Controller);
    forwardIfInProgress(_initial2Controller);
    forwardIfInProgress(_separatorController);
    for (final c in _rowTitleControllers) {
      forwardIfInProgress(c);
    }
    for (final c in _rowValue1Controllers) {
      forwardIfInProgress(c);
    }
    for (final c in _rowValue2Controllers) {
      forwardIfInProgress(c);
    }
  }

  Widget _buildParticipantBall(String participant) {
    final color = getParticipantColor(participant);
    final initials = getParticipantInitials(participant);
    return Container(
      width: _participantBallSize,
      height: _participantBallSize,
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

  @override
  Widget build(BuildContext context) {
    final participants = widget.data.participants;
    final p1 = participants.isNotEmpty ? participants[0] : '—';
    final p2 = participants.length > 1 ? participants[1] : '—';

    final multi1 = widget.data.multimediaByParticipant[p1] ?? 0;
    final multi2 = widget.data.multimediaByParticipant[p2] ?? 0;
    final oneTime1 = widget.data.oneTimePhotosByParticipant[p1] ?? 0;
    final oneTime2 = widget.data.oneTimePhotosByParticipant[p2] ?? 0;
    final urls1 = widget.data.sharedUrlsByParticipant[p1] ?? 0;
    final urls2 = widget.data.sharedUrlsByParticipant[p2] ?? 0;

    final dataRows = <_MediaRowData>[
      _MediaRowData(
        title: 'Multimedia compartido',
        value1: '$multi1',
        value2: '$multi2',
      ),
      _MediaRowData(
        title: 'Fotos de una sola vez',
        value1: '$oneTime1',
        value2: '$oneTime2',
      ),
      _MediaRowData(
        title: 'URLs compartidas',
        value1: '$urls1',
        value2: '$urls2',
      ),
    ];

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
    const horizontalPadding = 24.0;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
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
                    'Media',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(0.9),
                    2: FlexColumnWidth(0.9),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 12, top: 10, bottom: 10),
                          child: SizedBox.shrink(),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: FadeTransition(
                                opacity: _initial1Animation,
                                child: _buildParticipantBall(p1),
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: FadeTransition(
                                opacity: _initial2Animation,
                                child: _buildParticipantBall(p2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                FadeTransition(
                  opacity: _separatorAnimation,
                  child: Container(
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 0),
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.2),
                            1: FlexColumnWidth(0.9),
                            2: FlexColumnWidth(0.9),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            for (int i = 0; i < dataRows.length; i++)
                              _buildAnimatedTableRow(dataRows[i], i),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildAnimatedTableRow(_MediaRowData row, int index) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      height: 1.3,
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    );

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 14, bottom: 14),
          child: FadeTransition(
            opacity: _rowTitleAnimations[index],
            child: Text(
              row.title,
              style: titleStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: FadeTransition(
                opacity: _rowValue1Animations[index],
                child: _buildValueWidget(row.value1, valueStyle),
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: FadeTransition(
                opacity: _rowValue2Animations[index],
                child: _buildValueWidget(row.value2, valueStyle),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueWidget(String value, TextStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _numberBadgeBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MediaRowData {
  final String title;
  final String value1;
  final String value2;

  _MediaRowData({
    required this.title,
    required this.value1,
    required this.value2,
  });
}
