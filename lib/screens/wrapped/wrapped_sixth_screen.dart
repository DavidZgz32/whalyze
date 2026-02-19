import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Pantalla 6 del wrapped: mapa de calor por día de la semana y franja horaria.
/// Arriba: L M X J V S D. Izquierda: Madrugada, Mañana, Tarde, Noche.
class WrappedSixthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedSixthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedSixthScreen> createState() => WrappedSixthScreenState();
}

class WrappedSixthScreenState extends State<WrappedSixthScreen>
    with TickerProviderStateMixin {
  static const List<String> _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const List<String> _timeLabels = [
    'Madrugada',
    'Mañana',
    'Tarde',
    'Noche',
  ];

  /// Colores del heatmap: de menor a mayor mensajes.
  static const List<Color> _heatmapColors = [
    Color(0xFFF3E8FF),
    Color(0xFFE9D5FF),
    Color(0xFFD8B4FE),
    Color(0xFFC084FC),
    Color(0xFFA855F7),
    Color(0xFF7E22CE),
  ];

  static const int _animDurationMs = 400;
  static const int _delayPerCellMs = 100;

  late final AnimationController _titleFadeController;
  late final AnimationController _titlePositionController;
  late final AnimationController _subtitleController;
  late final AnimationController _heatmapVisibleController;
  late final AnimationController _heatmapController;
  late final AnimationController _hourlyTitleController;
  late final AnimationController _hourlyBarsController;

  late final Animation<double> _titleFadeAnimation;
  late final Animation<double> _titlePositionAnimation;
  late final Animation<double> _heatmapVisibleAnimation;

  bool _paused = false;

  static const int _hourlyBarDelayMs = 100;
  static const int _hourlyBarFadeMs = 300;
  static const double _hourlyBarHeight = 32.0;

  @override
  void initState() {
    super.initState();
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _heatmapVisibleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final heatmapTotalMs = 7 * 4 * _delayPerCellMs + _animDurationMs;
    _heatmapController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: heatmapTotalMs),
    );
    _hourlyTitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _hourlyBarsController = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: 24 * _hourlyBarDelayMs + _hourlyBarFadeMs),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleFadeController, curve: Curves.easeOut),
    );
    _titlePositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _titlePositionController, curve: Curves.easeInOut),
    );
    _heatmapVisibleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heatmapVisibleController, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _paused = false;
    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _paused) return;
        _titlePositionController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted || _paused) return;
            _subtitleController.forward().then((_) {
              if (!mounted || _paused) return;
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (!mounted || _paused) return;
                _heatmapVisibleController.forward();
                _heatmapController.forward();
                _heatmapController.addStatusListener(_onHeatmapStatusChanged);
              });
            });
          });
        });
      });
    });
  }

  void pauseAnimations() {
    _paused = true;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    _subtitleController.stop(canceled: false);
    _heatmapVisibleController.stop(canceled: false);
    _heatmapController.stop(canceled: false);
    _hourlyTitleController.stop(canceled: false);
    _hourlyBarsController.stop(canceled: false);
  }

  void resumeAnimations() {
    _paused = false;
    void forwardIfInProgress(AnimationController c) {
      if (c.value > 0 && c.value < 1) c.forward();
    }

    forwardIfInProgress(_titleFadeController);
    forwardIfInProgress(_titlePositionController);
    forwardIfInProgress(_subtitleController);
    forwardIfInProgress(_heatmapVisibleController);
    forwardIfInProgress(_heatmapController);
    forwardIfInProgress(_hourlyTitleController);
    forwardIfInProgress(_hourlyBarsController);
  }

  void resetAnimations() {
    _heatmapController.removeStatusListener(_onHeatmapStatusChanged);
    _titleFadeController.reset();
    _titlePositionController.reset();
    _subtitleController.reset();
    _heatmapVisibleController.reset();
    _heatmapController.reset();
    _hourlyTitleController.reset();
    _hourlyBarsController.reset();
    _startAnimations();
  }

  void _onHeatmapStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _heatmapController.removeStatusListener(_onHeatmapStatusChanged);
    if (!mounted || _paused) return;
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted || _paused) return;
      _hourlyTitleController.forward().then((_) {
        if (!mounted || _paused) return;
        _hourlyBarsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _heatmapController.removeStatusListener(_onHeatmapStatusChanged);
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    _subtitleController.dispose();
    _heatmapVisibleController.dispose();
    _heatmapController.dispose();
    _hourlyTitleController.dispose();
    _hourlyBarsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matrix = widget.data.dayOfWeekTimeBandCounts;
    final maxCount = _computeMax(matrix);
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        48;
    const horizontalPadding = 20.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 56;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Título "Horarios de mensaje" en el centro que se desplaza arriba
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
                    'Horarios de mensajes',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          // Contenido: subtítulo y heatmap (aparecen después)
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 56,
              bottom: bottomPadding,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: _subtitleController, curve: Curves.easeOut),
                  ),
                  child: Text(
                    'Mapa de calor por dia y franja',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FadeTransition(
                    opacity: _heatmapVisibleAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const headerHeight = 14.0;
                        const dayHeaderGap = 8.0;
                        final totalWidth = constraints.maxWidth;
                        final columnWidth = totalWidth / 8;
                        final heatmapTotalMs =
                            7 * 4 * _delayPerCellMs + _animDurationMs;
                        final gridCellHeight = columnWidth / 1.1;
                        final hourlyCounts = widget.data.hourlyMessageCounts;
                        final hourlyMax = _hourlyMax(hourlyCounts);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fila de días: 8 celdas iguales (vacía la primera + L M X J V S D)
                              SizedBox(
                                height: headerHeight,
                                child: Row(
                                  children: [
                                    for (int i = 0; i < 8; i++)
                                      SizedBox(
                                        width: columnWidth,
                                        height: headerHeight,
                                        child: i == 0
                                            ? const SizedBox.shrink()
                                            : Center(
                                                child: Text(
                                                  _dayLetters[i - 1],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: dayHeaderGap),
                              AnimatedBuilder(
                                animation: _heatmapController,
                                builder: (context, _) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(4, (bandIndex) {
                                      return SizedBox(
                                        height: gridCellHeight,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: columnWidth,
                                              height: gridCellHeight,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 6),
                                                  child: Text(
                                                    _timeLabels[bandIndex],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ...List.generate(7, (dayIndex) {
                                              final count = (dayIndex <
                                                          matrix.length &&
                                                      bandIndex <
                                                          matrix[dayIndex]
                                                              .length)
                                                  ? matrix[dayIndex][bandIndex]
                                                  : 0;
                                              final t = maxCount > 0
                                                  ? count / maxCount
                                                  : 0.0;
                                              final color = _lerpColor(t);
                                              final delayMs =
                                                  (dayIndex + bandIndex * 7) *
                                                      _delayPerCellMs;
                                              final startT =
                                                  delayMs / heatmapTotalMs;
                                              final endT =
                                                  (delayMs + _animDurationMs) /
                                                      heatmapTotalMs;
                                              final cellT =
                                                  (_heatmapController.value -
                                                          startT) /
                                                      (endT - startT)
                                                          .clamp(0.001, 1.0);
                                              final opacity =
                                                  cellT.clamp(0.0, 1.0);
                                              return SizedBox(
                                                width: columnWidth,
                                                height: gridCellHeight,
                                                child: Opacity(
                                                  opacity: opacity,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.15),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: count > 0
                                                          ? Text(
                                                              '$count',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: t > 0.5
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black87,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(height: 72),
                              FadeTransition(
                                opacity:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                      parent: _hourlyTitleController,
                                      curve: Curves.easeOut),
                                ),
                                child: Text(
                                  'mapa de calor por horas (0-24h)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: _hourlyBarHeight,
                                child: AnimatedBuilder(
                                  animation: _hourlyBarsController,
                                  builder: (context, _) {
                                    final totalMs = 24 * _hourlyBarDelayMs +
                                        _hourlyBarFadeMs;
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: List.generate(24, (h) {
                                        final count = h < hourlyCounts.length
                                            ? hourlyCounts[h]
                                            : 0;
                                        final t = hourlyMax > 0
                                            ? count / hourlyMax
                                            : 0.0;
                                        final color = _lerpColor(t);
                                        final startMs = h * _hourlyBarDelayMs;
                                        final barT =
                                            ((_hourlyBarsController.value *
                                                        totalMs) -
                                                    startMs) /
                                                _hourlyBarFadeMs;
                                        final opacity = barT.clamp(0.0, 1.0);
                                        return Expanded(
                                          child: Opacity(
                                            opacity: opacity,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
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

  int _hourlyMax(List<int> hourly) {
    if (hourly.isEmpty) return 1;
    int m = 0;
    for (final v in hourly) {
      if (v > m) m = v;
    }
    return m > 0 ? m : 1;
  }

  int _computeMax(List<List<int>> matrix) {
    int max = 0;
    for (final row in matrix) {
      for (final v in row) {
        if (v > max) max = v;
      }
    }
    return max > 0 ? max : 1;
  }

  Color _lerpColor(double t) {
    if (t <= 0) return _heatmapColors.first;
    if (t >= 1) return _heatmapColors.last;
    final n = _heatmapColors.length;
    final segment = (n - 1) * t;
    final i = segment.floor().clamp(0, n - 2);
    final localT = segment - i;
    return Color.lerp(_heatmapColors[i], _heatmapColors[i + 1], localT)!;
  }
}
