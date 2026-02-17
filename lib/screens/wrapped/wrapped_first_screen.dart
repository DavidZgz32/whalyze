import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';
import '../../utils/participant_utils.dart';

class WrappedFirstScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedFirstScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedFirstScreen> createState() => WrappedFirstScreenState();
}

class WrappedFirstScreenState extends State<WrappedFirstScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late AnimationController _participantsController;
  late AnimationController _firstMessageController;
  late AnimationController _daysController;
  late AnimationController _randomMessageController;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late Animation<double> _participantsAnimation;
  late Animation<double> _firstMessageAnimation;
  late Animation<double> _daysAnimation;
  late Animation<double> _randomMessageAnimation;

  String? _randomMessage; // Mensaje aleatorio calculado una sola vez
  bool _paused = false;

  @override
  void initState() {
    super.initState();

    // Calcular mensaje aleatorio una sola vez
    _calculateRandomMessage();

    // Inicializar controladores de animación (todo distribuido en ~18-19 segundos)
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _participantsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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

    _participantsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _participantsController,
        curve: Curves.easeOut,
      ),
    );

    _firstMessageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _firstMessageController,
        curve: Curves.easeOut,
      ),
    );

    _daysAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _daysController,
        curve: Curves.easeOut,
      ),
    );

    _randomMessageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _randomMessageController,
        curve: Curves.easeOut,
      ),
    );

    // Iniciar animaciones
    _startAnimations();
  }

  void _calculateRandomMessage() {
    // Calcular días transcurridos
    int daysSinceStart = 0;
    if (widget.data.firstMessageDate != null) {
      try {
        final firstDate = DateTime.parse(widget.data.firstMessageDate!);
        daysSinceStart = DateTime.now().difference(firstDate).inDays;
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    if (daysSinceStart > 0) {
      // Función para formatear números grandes con puntos como separadores de miles
      String formatNumber(int number) {
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

      final random = DateTime.now().millisecondsSinceEpoch % 3;
      if (random == 0) {
        final heartbeats = formatNumber(100800 * daysSinceStart);
        _randomMessage =
            'En este periodo, vuestro corazón ha latido más de $heartbeats veces.';
      } else if (random == 1) {
        final tiktokVideos = formatNumber(34000000 * daysSinceStart);
        _randomMessage =
            'Durante este tiempo se han publicado más de $tiktokVideos vídeos en TikTok.';
      } else {
        final births = formatNumber(385000 * daysSinceStart);
        _randomMessage = 'En este tiempo han nacido $births bebés en el mundo';
      }
    }
  }

  void _startAnimations() {
    _paused = false;
    // 1. Aparecer título en el centro
    _titleFadeController.forward().then((_) {
      if (!mounted || _paused) return;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _paused) return;
        _titlePositionController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted || _paused) return;
            _participantsController.forward().then((_) {
              if (!mounted || _paused) return;
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (!mounted || _paused) return;
                _firstMessageController.forward().then((_) {
                  if (!mounted || _paused) return;
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    if (!mounted || _paused) return;
                    _daysController.forward().then((_) {
                      if (!mounted || _paused) return;
                      Future.delayed(const Duration(milliseconds: 1200), () {
                        if (!mounted || _paused) return;
                        _randomMessageController.forward();
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  }

  Widget _buildParticipantBall(String participant) {
    final color = getParticipantColor(participant);
    final initials = getParticipantInitials(participant);
    return Container(
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
    );
  }

  void resetAnimations() {
    _titleFadeController.reset();
    _titlePositionController.reset();
    _participantsController.reset();
    _firstMessageController.reset();
    _daysController.reset();
    _randomMessageController.reset();
    _startAnimations();
  }

  void pauseAnimations() {
    _paused = true;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    _participantsController.stop(canceled: false);
    _firstMessageController.stop(canceled: false);
    _daysController.stop(canceled: false);
    _randomMessageController.stop(canceled: false);
  }

  void resumeAnimations() {
    _paused = false;
    void forwardIfInProgress(AnimationController c) {
      if (c.value > 0 && c.value < 1) c.forward();
    }

    void runNextStep() {
      if (_titleFadeController.value < 1) {
        _titleFadeController.forward();
        return;
      }
      if (_titlePositionController.value < 1) {
        _titlePositionController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted || _paused) return;
            _participantsController.forward().then((_) {
              if (!mounted || _paused) return;
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (!mounted || _paused) return;
                _firstMessageController.forward().then((_) {
                  if (!mounted || _paused) return;
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    if (!mounted || _paused) return;
                    _daysController.forward().then((_) {
                      if (!mounted || _paused) return;
                      Future.delayed(const Duration(milliseconds: 1200), () {
                        if (!mounted || _paused) return;
                        _randomMessageController.forward();
                      });
                    });
                  });
                });
              });
            });
          });
        });
        return;
      }
      if (_participantsController.value < 1) {
        _participantsController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted || _paused) return;
            _firstMessageController.forward().then((_) {
              if (!mounted || _paused) return;
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (!mounted || _paused) return;
                _daysController.forward().then((_) {
                  if (!mounted || _paused) return;
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    if (!mounted || _paused) return;
                    _randomMessageController.forward();
                  });
                });
              });
            });
          });
        });
        return;
      }
      if (_firstMessageController.value < 1) {
        _firstMessageController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted || _paused) return;
            _daysController.forward().then((_) {
              if (!mounted || _paused) return;
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (!mounted || _paused) return;
                _randomMessageController.forward();
              });
            });
          });
        });
        return;
      }
      if (_daysController.value < 1) {
        _daysController.forward().then((_) {
          if (!mounted || _paused) return;
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (!mounted || _paused) return;
            _randomMessageController.forward();
          });
        });
        return;
      }
      if (_randomMessageController.value < 1) {
        _randomMessageController.forward();
      }
    }

    forwardIfInProgress(_titleFadeController);
    forwardIfInProgress(_titlePositionController);
    forwardIfInProgress(_participantsController);
    forwardIfInProgress(_firstMessageController);
    forwardIfInProgress(_daysController);
    forwardIfInProgress(_randomMessageController);
    runNextStep();
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    _participantsController.dispose();
    _firstMessageController.dispose();
    _daysController.dispose();
    _randomMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el primer mensaje
    final firstMessageText = widget.data.firstMessageText;

    // Calcular días transcurridos
    int daysSinceStart = 0;
    if (widget.data.firstMessageDate != null) {
      try {
        final firstDate = DateTime.parse(widget.data.firstMessageDate!);
        daysSinceStart = DateTime.now().difference(firstDate).inDays;
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    // Obtener fecha del primer mensaje para mostrar "el primer día"
    String firstDayText = '';
    if (widget.data.firstMessageDate != null) {
      try {
        final date = DateTime.parse(widget.data.firstMessageDate!);
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
        firstDayText =
            'el ${date.day} de ${months[date.month - 1]} de ${date.year}';
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    // Texto de participantes
    final participantsText = widget.data.participants.length == 2
        ? '${widget.data.participants[0]} - ${widget.data.participants[1]}'
        : '${widget.data.participants.length} participantes';

    // Limitar el primer mensaje a 150 caracteres
    final limitedFirstMessage =
        firstMessageText != null && firstMessageText.isNotEmpty
            ? (firstMessageText.length > 150
                ? '${firstMessageText.substring(0, 150)}...'
                : firstMessageText)
            : null;

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
              // Calcular posición del título dentro del builder para que se actualice
              // El título empieza en el centro absoluto de la pantalla
              final centerY = screenHeight / 2;
              final titleStartY = centerY -
                  topPadding; // Posición inicial relativa al topPadding
              final titleEndY =
                  0.0; // Posición final arriba (relativa al topPadding)

              // Interpolación: cuando animation.value = 0, currentTitleY = titleStartY (centro)
              // cuando animation.value = 1, currentTitleY = titleEndY (arriba)
              final currentTitleY = titleStartY -
                  (titleStartY - titleEndY) * _titlePositionAnimation.value;

              return Positioned(
                top: topPadding + currentTitleY,
                left: 30,
                right: 30,
                child: Opacity(
                  opacity: _titleFadeAnimation.value,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Bienvenid@ a tu Whatsapp Wrapped!',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        fontSize: 31,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Contenedor con los demás elementos que aparecen debajo
          Padding(
            padding: EdgeInsets.only(
              top: topPadding + 100, // Espacio para el título desplazado
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 30,
              right: 30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Bolitas con iniciales de participantes (como en pantalla 2)
                if (widget.data.participants.length >= 2)
                  FadeTransition(
                    opacity: _participantsAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildParticipantBall(widget.data.participants[0]),
                        const SizedBox(width: 16),
                        _buildParticipantBall(widget.data.participants[1]),
                      ],
                    ),
                  )
                else if (widget.data.participants.length == 1)
                  FadeTransition(
                    opacity: _participantsAnimation,
                    child: _buildParticipantBall(widget.data.participants[0]),
                  ),
                const SizedBox(height: 12),
                // Participantes (nombres)
                FadeTransition(
                  opacity: _participantsAnimation,
                  child: Text(
                    participantsText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // "todo empezó con un..."
                FadeTransition(
                  opacity: _firstMessageAnimation,
                  child: Text(
                    limitedFirstMessage != null && firstDayText.isNotEmpty
                        ? 'todo empezó con un... "$limitedFirstMessage" $firstDayText'
                        : limitedFirstMessage != null
                            ? 'todo empezó con un... "$limitedFirstMessage"'
                            : 'todo empezó con un...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Días transcurridos
                FadeTransition(
                  opacity: _daysAnimation,
                  child: Text(
                    'Desde entonces han pasado $daysSinceStart días',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Mensaje aleatorio
                if (_randomMessage != null && _randomMessage!.isNotEmpty)
                  FadeTransition(
                    opacity: _randomMessageAnimation,
                    child: Text(
                      _randomMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
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
}
