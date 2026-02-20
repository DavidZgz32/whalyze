import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Pantalla 6 del wrapped (índice 5): Hitos del chat
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
  late List<AnimationController> _statTitleControllers;
  late List<AnimationController> _statValueControllers;
  late List<AnimationController> _statSubtitleControllers;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late List<Animation<double>> _statTitleAnimations;
  late List<Animation<double>> _statValueAnimations;
  late List<Animation<double>> _statSubtitleAnimations;

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
          // Día consecutivo, continuar la racha
          currentStreak++;
        } else {
          // Nueva racha - verificar si la racha anterior es la más larga
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
            _longestStreakStartDate = currentStreakStart;
            _longestStreakEndDate = lastDate;
          }
          // Iniciar nueva racha
          currentStreak = 1;
          currentStreakStart = date;
        }
      }

      // Verificar si la racha actual es la más larga
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

    // 3 estadísticas: título, valor, subtítulo
    const statCount = 3;
    _statTitleControllers = List.generate(
      statCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _statValueControllers = List.generate(
      statCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _statSubtitleControllers = List.generate(
      statCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _statTitleAnimations = _statTitleControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _statValueAnimations = _statValueControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _statSubtitleAnimations = _statSubtitleControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _startAnimations();
  }

  void _startAnimations() {
    _paused = false;
    // 1. Título en el centro, luego se desplaza arriba
    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _paused) return;
        _titlePositionController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted || _paused) return;
            _animateStatsSequentially();
          });
        });
      });
    });
  }

  Future<void> _animateStatsSequentially() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted || _paused) return;
      // Título de la estadística
      _statTitleControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted || _paused) return;
      // Valor de la estadística
      _statValueControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted || _paused) return;
      // Subtítulo (fecha o información adicional)
      _statSubtitleControllers[i].forward();
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    for (final c in _statTitleControllers) {
      c.dispose();
    }
    for (final c in _statValueControllers) {
      c.dispose();
    }
    for (final c in _statSubtitleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void resetAnimations() {
    _titleFadeController.reset();
    _titlePositionController.reset();
    for (final c in _statTitleControllers) {
      c.reset();
    }
    for (final c in _statValueControllers) {
      c.reset();
    }
    for (final c in _statSubtitleControllers) {
      c.reset();
    }
    _startAnimations();
  }

  void pauseAnimations() {
    _paused = true;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    for (final c in _statTitleControllers) {
      c.stop(canceled: false);
    }
    for (final c in _statValueControllers) {
      c.stop(canceled: false);
    }
    for (final c in _statSubtitleControllers) {
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
    for (final c in _statTitleControllers) {
      forwardIfInProgress(c);
    }
    for (final c in _statValueControllers) {
      forwardIfInProgress(c);
    }
    for (final c in _statSubtitleControllers) {
      forwardIfInProgress(c);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
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
        'diciembre'
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
          // Título que aparece en el centro y se desplaza hacia arriba
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
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          // Contenido debajo del título
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 80,
              bottom: bottomPadding,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Estadística 1: Racha más larga (días seguidos)
                  _buildStat(
                    index: 0,
                    title: 'Racha más larga (días seguidos) hablando',
                    value: '$_longestStreakDays días',
                    subtitle: _formatDateRange(),
                  ),
                  const SizedBox(height: 40),
                  // Estadística 2: Racha más intensa de mensajes seguidos
                  _buildStat(
                    index: 1,
                    title: 'Racha más intensa de mensajes seguidos',
                    value: '${widget.data.mostConsecutiveMessages} mensajes',
                    subtitle: widget.data.mostConsecutiveUser != null
                        ? '${widget.data.mostConsecutiveUser} - ${_formatConsecutiveDate()}'
                        : _formatConsecutiveDate(),
                  ),
                  const SizedBox(height: 40),
                  // Estadística 3: Total de preguntas
                  _buildStat(
                    index: 2,
                    title: 'Total de preguntas',
                    value: '${widget.data.totalQuestions}',
                    subtitle: '',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required int index,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.3,
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final subtitleStyle = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.85),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _statTitleAnimations[index],
          child: Text(
            title,
            style: titleStyle,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _statValueAnimations[index],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF00B872).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _statSubtitleAnimations[index],
            child: Text(
              subtitle,
              style: subtitleStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
