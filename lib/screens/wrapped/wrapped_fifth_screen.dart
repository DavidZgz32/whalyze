import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';
import '../../utils/participant_utils.dart';

/// Pantalla 5 del wrapped: ¿Quién mueve el chat? - tabla de 3 columnas con animaciones.
class WrappedFifthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedFifthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedFifthScreen> createState() => WrappedFifthScreenState();
}

class WrappedFifthScreenState extends State<WrappedFifthScreen>
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
  static const Color _greenBg = Color(0xFF2E7D32);
  static const Color _redBg = Color(0xFFC62828);

  late AnimationController _messageController;
  late Animation<double> _messageAnimation;
  late int _randomMessageIndex; // 0=starters, 1=response_time, 2=quick

  bool _paused = false;

  @override
  void initState() {
    _randomMessageIndex = Random().nextInt(3);
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
      CurvedAnimation(parent: _titlePositionController, curve: Curves.easeInOut),
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

    // 3 filas de datos (excluyendo header)
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
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _rowValue1Animations = _rowValue1Controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _rowValue2Animations = _rowValue2Controllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _messageController, curve: Curves.easeOut),
    );

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
          // 2. Inicial 1, 700ms (200+500 extra), Inicial 2
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
    // +900ms antes del primer título (tras la raya blanca)
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _paused) return;
    _messageController.forward();
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
    _messageController.dispose();
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
    _messageController.reset();
    _randomMessageIndex = Random().nextInt(3);
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
    _messageController.stop(canceled: false);
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
    forwardIfInProgress(_messageController);
  }

  /// Parsea tiempo "M:SS" o "H:MM:SS" a minutos. Menor = más rápido.
  double? _parseResponseTimeMinutes(String s) {
    if (s.isEmpty || s == '—') return null;
    final parts = s.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      final sec = int.tryParse(parts[1]);
      if (m != null && sec != null) return m + sec / 60;
    } else if (parts.length == 3) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final sec = int.tryParse(parts[2]);
      if (h != null && m != null && sec != null) {
        return h * 60 + m + sec / 60;
      }
    }
    return null;
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

    const quickMinutes = 5;
    final dataRows = <_RowData>[
      _RowData(
        title: 'Quién inicia más conversaciones',
        value1: '${widget.data.conversationStarters[p1] ?? 0}',
        value2: '${widget.data.conversationStarters[p2] ?? 0}',
        rowType: _RowType.conversationStarters,
      ),
      _RowData(
        title: 'Tiempo medio de respuesta',
        value1: widget.data.averageResponseTimes[p1] ?? '—',
        value2: widget.data.averageResponseTimes[p2] ?? '—',
        rowType: _RowType.responseTime,
      ),
      _RowData(
        title: 'Respuestas rápidas (menos de $quickMinutes min)',
        value1: '${widget.data.quickResponseCounts[p1] ?? 0}',
        value2: '${widget.data.quickResponseCounts[p2] ?? 0}',
        rowType: _RowType.quickResponses,
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
                    '¿Quién mueve el chat?',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fila header: iniciales (2 columnas centradas)
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
                // Línea separadora (aparece después de las dos iniciales)
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
                              _buildAnimatedTableRow(
                                  dataRows[i], i, p1, p2),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _messageAnimation,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                            child: Center(
                              child: Text(
                                _getClosingMessage(p1, p2),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
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
        ],
      ),
    );
  }

  /// Formato "David M." = nombre + inicial del siguiente si existe.
  String _formatDisplayName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return name;
    if (parts.length == 1) return parts[0];
    if (parts[1].isEmpty) return parts[0];
    return '${parts[0]} ${parts[1][0].toUpperCase()}.';
  }

  String _getClosingMessage(String p1, String p2) {
    switch (_randomMessageIndex) {
      case 0: // conversation starters
        final c1 = widget.data.conversationStarters[p1] ?? 0;
        final c2 = widget.data.conversationStarters[p2] ?? 0;
        final winner = c1 >= c2 ? p1 : p2;
        return '${_formatDisplayName(winner)} inicia más conversaciones… alguien tiene ganas de hablar 😏';
      case 1: // response time
        final t1 = _parseResponseTimeMinutes(
            widget.data.averageResponseTimes[p1] ?? '—');
        final t2 = _parseResponseTimeMinutes(
            widget.data.averageResponseTimes[p2] ?? '—');
        String winner;
        if (t1 == null && t2 == null) {
          winner = p1; // empate, elegir uno
        } else if (t1 == null) {
          winner = p2;
        } else if (t2 == null) {
          winner = p1;
        } else {
          winner = t1 <= t2 ? p1 : p2;
        }
        return '${_formatDisplayName(winner)} suele responder antes... Responder rápido también es una forma de cariño 😉';
      case 2: // quick responses
        final q1 = widget.data.quickResponseCounts[p1] ?? 0;
        final q2 = widget.data.quickResponseCounts[p2] ?? 0;
        final winner = q1 >= q2 ? p1 : p2;
        return '${_formatDisplayName(winner)} tiene más respuestas rápidas… ¿duermes con el móvil en la mano? 😏';
      default:
        return '';
    }
  }

  TableRow _buildAnimatedTableRow(
      _RowData row, int index, String p1, String p2) {
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
    final isNumeric1 = _isNumeric(row.value1);
    final isNumeric2 = _isNumeric(row.value2);

    Color? bg1;
    Color? bg2;
    switch (row.rowType) {
      case _RowType.conversationStarters:
        final v1 = int.tryParse(row.value1) ?? 0;
        final v2 = int.tryParse(row.value2) ?? 0;
        if (v1 > v2) {
          bg1 = _greenBg;
          bg2 = _redBg;
        } else if (v2 > v1) {
          bg1 = _redBg;
          bg2 = _greenBg;
        }
        break;
      case _RowType.responseTime:
        final t1 = _parseResponseTimeMinutes(row.value1);
        final t2 = _parseResponseTimeMinutes(row.value2);
        if (t1 != null && t2 != null) {
          if (t1 < t2) {
            bg1 = _greenBg;
            bg2 = _redBg;
          } else if (t2 < t1) {
            bg1 = _redBg;
            bg2 = _greenBg;
          }
        } else if (t1 != null && t2 == null) {
          bg1 = _greenBg;
          bg2 = _redBg;
        } else if (t1 == null && t2 != null) {
          bg1 = _redBg;
          bg2 = _greenBg;
        }
        break;
      case _RowType.quickResponses:
        final v1 = int.tryParse(row.value1) ?? 0;
        final v2 = int.tryParse(row.value2) ?? 0;
        if (v1 > v2) {
          bg1 = _greenBg;
          bg2 = _redBg;
        } else if (v2 > v1) {
          bg1 = _redBg;
          bg2 = _greenBg;
        }
        break;
    }

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
                child: _buildValueWidget(
                    row.value1, valueStyle, isNumeric1, bg1),
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
                child: _buildValueWidget(
                    row.value2, valueStyle, isNumeric2, bg2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isNumeric(String value) {
    if (value == '—') return false;
    return int.tryParse(value) != null || double.tryParse(value) != null;
  }

  Widget _buildValueWidget(
      String value, TextStyle style, bool isNumeric, Color? bgColor) {
    final effectiveColor =
        bgColor ?? (isNumeric ? _numberBadgeBg : Colors.transparent);
    final needsBackground = bgColor != null || isNumeric;

    if (needsBackground && effectiveColor != Colors.transparent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: style,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Text(
      value,
      style: style,
      textAlign: TextAlign.center,
    );
  }
}

enum _RowType { conversationStarters, responseTime, quickResponses }

class _RowData {
  final String title;
  final String value1;
  final String value2;
  final _RowType rowType;

  _RowData({
    required this.title,
    required this.value1,
    required this.value2,
    required this.rowType,
  });
}
