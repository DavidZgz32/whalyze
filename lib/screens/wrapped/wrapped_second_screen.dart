import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

class WrappedSecondScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedSecondScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedSecondScreen> createState() => _WrappedSecondScreenState();
}

class _WrappedSecondScreenState extends State<WrappedSecondScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late List<AnimationController> _participantControllers;
  late AnimationController _barController;
  late AnimationController _dayController;
  late AnimationController _monthController;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late List<Animation<double>> _participantAnimations;
  late Animation<double> _barAnimation;
  late Animation<double> _dayAnimation;
  late Animation<double> _monthAnimation;

  @override
  void initState() {
    super.initState();

    // Calcular número de participantes
    final participantCount = widget.data.participants.length;

    // Inicializar controladores de animación
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Crear controladores para cada participante
    _participantControllers = List.generate(
      participantCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _monthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

    _dayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dayController,
        curve: Curves.easeOut,
      ),
    );

    _monthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _monthController,
        curve: Curves.easeOut,
      ),
    );

    // Iniciar animaciones
    _startAnimations();
  }

  void _startAnimations() {
    // 1. Aparecer título en el centro
    _titleFadeController.forward().then((_) {
      // 2. Desplazar título hacia arriba
      Future.delayed(const Duration(milliseconds: 2000), () {
        _titlePositionController.forward().then((_) {
          // 3. Aparecer participantes uno por uno
          _animateParticipantsSequentially();
        });
      });
    });
  }

  void _animateParticipantsSequentially() {
    Future<void> animateNext(int index) async {
      if (index < _participantControllers.length) {
        await Future.delayed(const Duration(milliseconds: 400));
        _participantControllers[index].forward();
        await animateNext(index + 1);
      } else {
        // Después de todos los participantes, mostrar la barra
        await Future.delayed(const Duration(milliseconds: 400));
        _barController.forward();

        // Después de la barra, mostrar día más ocupado
        await Future.delayed(const Duration(milliseconds: 400));
        if (widget.data.dayWithMostMessages != null) {
          _dayController.forward();
        }

        // Finalmente, mostrar mes más ocupado
        await Future.delayed(const Duration(milliseconds: 400));
        if (widget.data.monthWithMostMessages != null) {
          _monthController.forward();
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
    _dayController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  // Generar color consistente para cada participante
  Color _getParticipantColor(String participant) {
    final hash = participant.hashCode;
    final hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  // Obtener iniciales del nombre
  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    // Limpiar espacios extra y dividir por espacios
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      // Solo un nombre: devolver primera letra
      return parts[0][0].toUpperCase();
    } else if (parts.length == 2) {
      // Dos partes: devolver iniciales de ambas
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      // Más de dos partes: devolver solo la primera inicial
      return parts[0][0].toUpperCase();
    }
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
                  const SizedBox(height: 32),
                  // Barra combinada de porcentajes (solo si hay 2 participantes)
                  if (sortedParticipants.length == 2)
                    FadeTransition(
                      opacity: _barAnimation,
                      child: _buildCombinedProgressBar(
                        sortedParticipants[0],
                        sortedParticipants[1],
                        percentages[sortedParticipants[0]] ?? 0.0,
                        percentages[sortedParticipants[1]] ?? 0.0,
                      ),
                    ),
                  const SizedBox(height: 40),
                  // Día más ocupado
                  if (widget.data.dayWithMostMessages != null &&
                      widget.data.dayWithMostMessagesCount > 0)
                    FadeTransition(
                      opacity: _dayAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            Text(
                              'Día más ocupado',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatDate(widget.data.dayWithMostMessages!)} - ${_formatNumber(widget.data.dayWithMostMessagesCount)} mensajes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Mes más ocupado
                  if (widget.data.monthWithMostMessages != null &&
                      widget.data.monthWithMostMessagesCount > 0)
                    FadeTransition(
                      opacity: _monthAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            Text(
                              'Mes más ocupado',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatMonth(widget.data.monthWithMostMessages!)} - ${_formatNumber(widget.data.monthWithMostMessagesCount)} mensajes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
    final color = _getParticipantColor(participant);
    final initials = _getInitials(participant);
    final messageCount = widget.data.participantMessageCounts[participant] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Círculo con iniciales
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                fontSize: 24,
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
    final color1 = _getParticipantColor(participant1);
    final color2 = _getParticipantColor(participant2);

    return Column(
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
                    // Primera parte de la barra
                    Container(
                      width: width1,
                      color: color1,
                    ),
                    // Segunda parte de la barra
                    Container(
                      width: width2,
                      color: color2,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Porcentajes como texto
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
    );
  }
}
