import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Pantalla 6 del wrapped (índice 5): Hitos del chat – 2 columnas (título - dato), fecha abajo.
class WrappedSeventhScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedSeventhScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedSeventhScreen> createState() => WrappedSeventhScreenState();
}

class WrappedSeventhScreenState extends State<WrappedSeventhScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late List<AnimationController> _rowTitleControllers;
  late List<AnimationController> _rowValue1Controllers;
  late List<AnimationController> _rowValue2Controllers;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late List<Animation<double>> _rowTitleAnimations;
  late List<Animation<double>> _rowValue1Animations;
  late List<Animation<double>> _rowValue2Animations;

  static const Color _numberBadgeBg = Color(0xFF00B872);

  bool _paused = false;

  // Datos calculados
  String? _longestStreakStartDate;
  String? _longestStreakEndDate;
  int _longestStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _calculateLongestStreakDates();
    _initAnimations();
  }

  void _calculateLongestStreakDates() {
    final dailyCounts = widget.data.dailyMessageCounts;
    if (dailyCounts.isEmpty) return;

    final datesWithMessages = dailyCounts.keys.toList()..sort();
    if (datesWithMessages.isEmpty) return;

    int longestStreak = 0;
    int currentStreak = 0;
    String? currentStreakStart;

    String? lastDate;
    for (final date in datesWithMessages) {
      if (lastDate == null) {
        currentStreak = 1;
        currentStreakStart = date;
      } else {
        final lastDateObj = DateTime.parse(lastDate);
        final currentDateObj = DateTime.parse(date);
        final diffDays = currentDateObj.difference(lastDateObj).inDays;

        if (diffDays == 1) {
          currentStreak++;
        } else {
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
            _longestStreakStartDate = currentStreakStart;
            _longestStreakEndDate = lastDate;
          }
          currentStreak = 1;
          currentStreakStart = date;
        }
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        _longestStreakStartDate = currentStreakStart;
        _longestStreakEndDate = date;
      }

      lastDate = date;
    }

    _longestStreakDays = longestStreak;
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

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleFadeController, curve: Curves.easeOut),
    );
    _titlePositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _titlePositionController, curve: Curves.easeInOut),
    );

    const rowCount = 4;
    _rowTitleControllers = List.generate(
      rowCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _rowValue1Controllers = List.generate(
      rowCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _rowValue2Controllers = List.generate(
      rowCount,
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

  /// Espera hasta que se llame a resume (o el widget no esté montado).
  Future<void> _waitUntilUnpaused() async {
    while (_paused && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _startAnimations() async {
    _paused = false;
    _titleFadeController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await _waitUntilUnpaused();
    if (!mounted) return;
    _titlePositionController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    await _waitUntilUnpaused();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await _waitUntilUnpaused();
    if (!mounted) return;
    await _animateRowsSequentially();
  }

  Future<void> _animateRowsSequentially() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _waitUntilUnpaused();
    if (!mounted) return;
    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      await _waitUntilUnpaused();
      if (!mounted) return;
      _rowTitleControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;
      await _waitUntilUnpaused();
      if (!mounted) return;
      _rowValue1Controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await _waitUntilUnpaused();
      if (!mounted) return;
      _rowValue2Controllers[i].forward();
      if (i < 3) {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
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
    _paused = false;
    _titleFadeController.reset();
    _titlePositionController.reset();
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _formatDateRange() {
    if (_longestStreakStartDate == null || _longestStreakEndDate == null) {
      return '';
    }
    final start = _formatDate(_longestStreakStartDate!);
    final end = _formatDate(_longestStreakEndDate!);
    return 'del $start al $end';
  }

  String _formatConsecutiveDate() {
    if (widget.data.mostConsecutiveDate == null) {
      return '';
    }
    return _formatDate(widget.data.mostConsecutiveDate!);
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.data.participants;
    final p1 = participants.isNotEmpty ? participants[0] : '—';

    final value2Row1 = _formatDateRange();
    final value2Row2 = widget.data.mostConsecutiveUser != null
        ? '${widget.data.mostConsecutiveUser} - ${_formatConsecutiveDate()}'
        : _formatConsecutiveDate();
    final totalMultimedia = widget.data.multimediaByParticipant.values.fold<int>(
        0, (sum, count) => sum + count);
    final multimediaExampleUser = p1 != '—' ? p1 : 'Usuario';
    final value2Row4 = 'Se mide así:\n23/2/26, 22:10 - $multimediaExampleUser: <Multimedia omitido>';
    final dataRows = <_RowData>[
      _RowData(
        title: 'Racha más larga días hablando',
        value1: '$_longestStreakDays\ndías',
        value2: value2Row1,
        value1TwoLines: true,
      ),
      _RowData(
        title: 'Racha más intensa de mensajes seguidos',
        value1: '${widget.data.mostConsecutiveMessages}\nmensajes',
        value2: value2Row2,
        value1TwoLines: true,
      ),
      _RowData(
        title: 'Total de preguntas realizadas',
        value1: '${widget.data.totalQuestions}',
        value2: '',
      ),
      _RowData(
        title: 'Multimedia, stickers y audios compartidos:',
        value1: '$totalMultimedia',
        value2: value2Row4,
      ),
    ];

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
    const horizontalPadding = 24.0;
    final titleFontSize = (28.0 * (screenHeight < 700 ? 0.9 : 1.0) * (screenWidth < 360 ? 0.92 : 1.0)).clamp(22.0, 28.0);

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
                    'Hitos del chat',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: topPadding + 72,
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: bottomPadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < dataRows.length; i++) ...[
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.2),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _buildTitleValueRow(dataRows[i], i),
                      ],
                    ),
                    if (dataRows[i].value2.isNotEmpty)
                      _buildDateRow(dataRows[i].value2, i),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTitleValueRow(_RowData row, int index) {
    final width = MediaQuery.of(context).size.width;
    final titleFontSize = width < 360 ? 13.0 : (width < 400 ? 14.0 : 16.0);
    final titleStyle = GoogleFonts.poppins(
      fontSize: titleFontSize,
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
          padding: const EdgeInsets.only(right: 12, top: 14, bottom: 8),
          child: FadeTransition(
            opacity: _rowTitleAnimations[index],
            child: Text(
              row.title,
              style: titleStyle,
              maxLines: 4,
              textAlign: TextAlign.start,
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
                child: _buildValueWidget(
                  row.value1,
                  valueStyle,
                  twoLines: row.value1TwoLines,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Fila de fecha a ancho completo (una sola columna de lado a lado).
  Widget _buildDateRow(String dateText, int index) {
    final dateStyle = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.9),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FadeTransition(
        opacity: _rowValue2Animations[index],
        child: SizedBox(
          width: double.infinity,
          child: Text(
            dateText,
            style: dateStyle,
            textAlign: TextAlign.start,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildValueWidget(String value, TextStyle style, {bool twoLines = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _numberBadgeBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: twoLines && value.contains('\n')
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: value.split('\n').map((line) => Text(
                line,
                style: style,
                textAlign: TextAlign.center,
              )).toList(),
            )
          : Text(
              value,
              style: style,
              textAlign: TextAlign.center,
            ),
    );
  }
}

class _RowData {
  final String title;
  final String value1;
  final String value2;
  final bool value1TwoLines;

  _RowData({
    required this.title,
    required this.value1,
    required this.value2,
    this.value1TwoLines = false,
  });
}
