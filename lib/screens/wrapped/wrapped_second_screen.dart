import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';
import '../../utils/participant_utils.dart';

class WrappedSecondScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedSecondScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedSecondScreen> createState() => WrappedSecondScreenState();
}

class WrappedSecondScreenState extends State<WrappedSecondScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late List<AnimationController> _participantControllers;
  late AnimationController _barController;
  late AnimationController _barMessageController;
  late AnimationController _dayTitleController;
  late AnimationController _dayDateController;
  late AnimationController _monthTitleController;
  late AnimationController _monthDateController;
  late AnimationController _monthPhraseController;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late List<Animation<double>> _participantAnimations;
  late Animation<double> _barAnimation;
  late Animation<double> _barMessageAnimation;
  late Animation<double> _dayTitleAnimation;
  late Animation<double> _dayDateAnimation;
  late Animation<double> _monthTitleAnimation;
  late Animation<double> _monthDateAnimation;
  late Animation<double> _monthPhraseAnimation;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();

    // Calcular número de participantes
    final participantCount = widget.data.participants.length;

    // Inicializar controladores (título más rápido, resto un poco más lento)
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Crear controladores para cada participante (bolita más rápida)
    _participantControllers = List.generate(
      participantCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      ),
    );

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _barMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dayTitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _dayDateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _monthTitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _monthDateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _monthPhraseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Crear animaciones
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleFadeController,
        curve: Curves.easeOut,
      ),
    );

    _titlePositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titlePositionController,
        curve: Curves.easeInOut,
      ),
    );

    _participantAnimations = _participantControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOut,
        ),
      );
    }).toList();

    _barAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _barController,
        curve: Curves.easeOut,
      ),
    );

    _barMessageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _barMessageController,
        curve: Curves.easeOut,
      ),
    );

    _dayTitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dayTitleController,
        curve: Curves.easeOut,
      ),
    );

    _dayDateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dayDateController,
        curve: Curves.easeOut,
      ),
    );

    _monthTitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _monthTitleController,
        curve: Curves.easeOut,
      ),
    );

    _monthDateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _monthDateController,
        curve: Curves.easeOut,
      ),
    );

    _monthPhraseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _monthPhraseController,
        curve: Curves.easeOut,
      ),
    );

    _animationsInitialized = true;
    _startAnimations();
  }

  void _startAnimations() {
    // 1. Aparecer título en el centro (más rápido)
    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        _titlePositionController.forward().then((_) {
          _animateParticipantsSequentially();
        });
      });
    });
  }

  void _animateParticipantsSequentially() {
    Future<void> animateNext(int index) async {
      if (index < _participantControllers.length) {
        await Future.delayed(const Duration(milliseconds: 500));
        _participantControllers[index].forward();
        await animateNext(index + 1);
      } else {
        await Future.delayed(const Duration(milliseconds: 1200));
        _barController.forward();

        await Future.delayed(const Duration(milliseconds: 1500));
        _barMessageController.forward();

        await Future.delayed(const Duration(milliseconds: 1200));
        if (widget.data.dayWithMostMessages != null) {
          _dayTitleController.forward();
          await Future.delayed(const Duration(milliseconds: 1500));
          _dayDateController.forward();
        }

        await Future.delayed(const Duration(milliseconds: 2000));
        if (widget.data.monthWithMostMessages != null) {
          _monthTitleController.forward();
          await Future.delayed(const Duration(milliseconds: 1500));
          _monthDateController.forward();
          final monthNum =
              _getMonthKeyMonthNumber(widget.data.monthWithMostMessages!);
          if (monthNum != null && _getMonthMessage(monthNum).isNotEmpty) {
            await Future.delayed(const Duration(milliseconds: 2000));
            _monthPhraseController.forward();
          }
        }
      }
    }

    animateNext(0);
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    for (final controller in _participantControllers) {
      controller.dispose();
    }
    _barController.dispose();
    _barMessageController.dispose();
    _dayTitleController.dispose();
    _dayDateController.dispose();
    _monthTitleController.dispose();
    _monthDateController.dispose();
    _monthPhraseController.dispose();
    super.dispose();
  }

  void pauseAnimations() {
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    for (final c in _participantControllers) {
      c.stop(canceled: false);
    }
    _barController.stop(canceled: false);
    _barMessageController.stop(canceled: false);
    _dayTitleController.stop(canceled: false);
    _dayDateController.stop(canceled: false);
    _monthTitleController.stop(canceled: false);
    _monthDateController.stop(canceled: false);
    _monthPhraseController.stop(canceled: false);
  }

  void resumeAnimations() {
    // Solo reanudar los controladores que estaban en progreso (evita "todo de golpe")
    void forwardIfInProgress(AnimationController c) {
      if (c.value > 0 && c.value < 1) {
        c.forward();
      }
    }

    forwardIfInProgress(_titleFadeController);
    forwardIfInProgress(_titlePositionController);
    for (final c in _participantControllers) {
      forwardIfInProgress(c);
    }
    forwardIfInProgress(_barController);
    forwardIfInProgress(_barMessageController);
    forwardIfInProgress(_dayTitleController);
    forwardIfInProgress(_dayDateController);
    forwardIfInProgress(_monthTitleController);
    forwardIfInProgress(_monthDateController);
    forwardIfInProgress(_monthPhraseController);
  }

  // Formatear número con puntos de miles
  String _formatNumber(int number) {
    final String numberStr = number.toString();
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < numberStr.length; i++) {
      if (i > 0 && (numberStr.length - i) % 3 == 0) {
        result.write('.');
      }
      result.write(numberStr[i]);
    }
    return result.toString();
  }

  // Formatear mes en español
  String _formatMonth(String monthKey) {
    // monthKey formato: "YYYY-MM"
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;

    final monthNum = int.tryParse(parts[1]);
    if (monthNum == null || monthNum < 1 || monthNum > 12) return monthKey;

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

    return '${months[monthNum - 1]} ${parts[0]}';
  }

  int? _getMonthKeyMonthNumber(String monthKey) {
    final parts = monthKey.split('-');
    if (parts.length != 2) return null;
    return int.tryParse(parts[1]);
  }

  // Mensaje según el mes (para día o mes más movido)
  String _getMonthMessage(int monthNum) {
    const messages = {
      1: 'Nuevo año, nuevo tú... misma cantidad de mensajes.',
      2: 'Mes corto, pero cargadito de drama digital',
      3: 'Algo se despertó en marzo... y no fue la primavera.',
      4: 'No llovieron solo gotas, también mensajes.',
      5: '¿Estudiando o trabajando? Sí, cómo no. WhatsApp a tope.',
      6: 'Junio se llenó de conversaciones que no estaban en el guión.',
      7: 'Tanto mensaje en julio... ¿estábais preparando las vacaciones?',
      8: 'Tantos mensajes en agosto... ¿sabías que existen las llamadas?',
      9: 'No sabemos qué empezó, pero seguro empezó en septiembre.',
      10: 'No hizo falta disfraz, los mensajes ya daban miedo.',
      11: 'Noviembre fue el ensayo general antes del caos navideño.',
      12: 'Entre memes y fiestas navideñas, ¡arrasásteis!',
    };
    return messages[monthNum] ?? '';
  }

  // Formatear fecha en español
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

    return '$day de ${months[monthNum - 1]} de $year';
  }

  @override
  Widget build(BuildContext context) {
    if (!_animationsInitialized) {
      return const SizedBox.shrink();
    }

    // Calcular total de mensajes
    final totalMessages = widget.data.participantMessageCounts.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    // Ordenar participantes por cantidad de mensajes (descendente)
    final sortedParticipants = widget.data.participants.toList()
      ..sort((a, b) {
        final countA = widget.data.participantMessageCounts[a] ?? 0;
        final countB = widget.data.participantMessageCounts[b] ?? 0;
        return countB.compareTo(countA);
      });

    // Calcular porcentajes
    final percentages = <String, double>{};
    for (final participant in sortedParticipants) {
      final count = widget.data.participantMessageCounts[participant] ?? 0;
      percentages[participant] =
          totalMessages > 0 ? (count / totalMessages) * 100 : 0.0;
    }

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
                left: 32,
                right: 32,
                child: Opacity(
                  opacity: _titleFadeAnimation.value,
                  child: Text(
                    'Vamos a analizar vuestros mensajes',
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
          // Contenedor con el contenido
          Positioned(
            top: topPadding + 100,
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 32,
            right: 32,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Participantes en 2 columnas
                  if (sortedParticipants.length == 2)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda
                        Expanded(
                          child: FadeTransition(
                            opacity: _participantAnimations[0],
                            child: _buildParticipantColumn(
                              sortedParticipants[0],
                              percentages[sortedParticipants[0]] ?? 0.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Columna derecha
                        Expanded(
                          child: FadeTransition(
                            opacity: _participantAnimations[1],
                            child: _buildParticipantColumn(
                              sortedParticipants[1],
                              percentages[sortedParticipants[1]] ?? 0.0,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Si no son exactamente 2, mostrar en lista
                    ...sortedParticipants.asMap().entries.map((entry) {
                      final index = entry.key;
                      final participant = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: FadeTransition(
                          opacity: _participantAnimations[index],
                          child: _buildParticipantColumn(
                            participant,
                            percentages[participant] ?? 0.0,
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                  // Barra combinada de porcentajes (solo si hay 2 participantes)
                  if (sortedParticipants.length == 2)
                    _buildCombinedProgressBar(
                      sortedParticipants[0],
                      sortedParticipants[1],
                      percentages[sortedParticipants[0]] ?? 0.0,
                      percentages[sortedParticipants[1]] ?? 0.0,
                    ),
                  const SizedBox(height: 40),
                  // Día con más mensajes (título y fecha uno tras otro)
                  if (widget.data.dayWithMostMessages != null &&
                      widget.data.dayWithMostMessagesCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _dayTitleAnimation,
                            child: Text(
                              'DÍA CON MÁS MENSAJES',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FadeTransition(
                            opacity: _dayDateAnimation,
                            child: Text(
                              '${_formatDate(widget.data.dayWithMostMessages!)} - ${_formatNumber(widget.data.dayWithMostMessagesCount)} mensajes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // El mes más movido (título, fecha y mensaje uno tras otro)
                  if (widget.data.monthWithMostMessages != null &&
                      widget.data.monthWithMostMessagesCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _monthTitleAnimation,
                            child: Text(
                              'EL MES MÁS MOVIDO',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FadeTransition(
                            opacity: _monthDateAnimation,
                            child: Text(
                              '${_formatMonth(widget.data.monthWithMostMessages!)} - ${_formatNumber(widget.data.monthWithMostMessagesCount)} mensajes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (_getMonthKeyMonthNumber(
                                  widget.data.monthWithMostMessages!) !=
                              null) ...[
                            const SizedBox(height: 24),
                            FadeTransition(
                              opacity: _monthPhraseAnimation,
                              child: Text(
                                '"${_getMonthMessage(_getMonthKeyMonthNumber(widget.data.monthWithMostMessages!)!)}"',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantColumn(String participant, double percentage) {
    final color = getParticipantColor(participant);
    final initials = getParticipantInitials(participant);
    final messageCount = widget.data.participantMessageCounts[participant] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Círculo con iniciales
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Total de mensajes
        Text(
          '${_formatNumber(messageCount)} mensajes',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCombinedProgressBar(
    String participant1,
    String participant2,
    double percentage1,
    double percentage2,
  ) {
    final color1 = getParticipantColor(participant1);
    final color2 = getParticipantColor(participant2);

    return Column(
      children: [
        FadeTransition(
          opacity: _barAnimation,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 12,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width1 = constraints.maxWidth * (percentage1 / 100);
                      final width2 = constraints.maxWidth * (percentage2 / 100);

                      return Row(
                        children: [
                          Container(width: width1, color: color1),
                          Container(width: width2, color: color2),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentage1.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '${percentage2.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        FadeTransition(
          opacity: _barMessageAnimation,
          child: Center(
            child: Text(
              _getPercentageMessage(
                  participant1, participant2, percentage1, percentage2),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.85),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  String _getPercentageMessage(
      String p1, String p2, double perc1, double perc2) {
    final diff = (perc1 - perc2).abs();
    if (diff < 0.1) return 'Casi al 50%';
    final more = perc1 >= perc2 ? p1 : p2;
    return '$more tiene ${diff.toStringAsFixed(1)}% más de mensajes';
  }

  void resetAnimations() {
    _titleFadeController.reset();
    _titlePositionController.reset();
    for (final c in _participantControllers) c.reset();
    _barController.reset();
    _barMessageController.reset();
    _dayTitleController.reset();
    _dayDateController.reset();
    _monthTitleController.reset();
    _monthDateController.reset();
    _monthPhraseController.reset();
    _startAnimations();
  }
}
