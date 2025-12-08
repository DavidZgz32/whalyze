import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

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
  late AnimationController _dateController;
  late AnimationController _firstMessageController;
  late AnimationController _daysController;

  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  late Animation<double> _participantsAnimation;
  late Animation<double> _dateAnimation;
  late Animation<double> _firstMessageAnimation;
  late Animation<double> _daysAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _titleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titlePositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _participantsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _firstMessageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _daysController = AnimationController(
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
    
    // Listener para debug (puede eliminarse después)
    _titlePositionController.addListener(() {
      print('Title position animation value: ${_titlePositionAnimation.value}');
    });

    _participantsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _participantsController,
        curve: Curves.easeOut,
      ),
    );

    _dateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dateController,
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

    // Iniciar animaciones
    _startAnimations();
  }

  void _startAnimations() {
    // 1. Aparecer título en el centro
    _titleFadeController.forward().then((_) {
      // 2. Desplazar título hacia arriba
      Future.delayed(const Duration(milliseconds: 500), () {
        _titlePositionController.forward().then((_) {
          // 3. Aparecer participantes
          Future.delayed(const Duration(milliseconds: 300), () {
            _participantsController.forward().then((_) {
              // 4. Aparecer fecha
              Future.delayed(const Duration(milliseconds: 300), () {
                _dateController.forward().then((_) {
                  // 5. Aparecer "todo empezó con un..."
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _firstMessageController.forward().then((_) {
                      // 6. Aparecer días
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _daysController.forward();
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

  void resetAnimations() {
    _titleFadeController.reset();
    _titlePositionController.reset();
    _participantsController.reset();
    _dateController.reset();
    _firstMessageController.reset();
    _daysController.reset();
    _startAnimations();
  }

  void pauseAnimations() {
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    _participantsController.stop(canceled: false);
    _dateController.stop(canceled: false);
    _firstMessageController.stop(canceled: false);
    _daysController.stop(canceled: false);
  }

  void resumeAnimations() {
    _titleFadeController.forward();
    _titlePositionController.forward();
    _participantsController.forward();
    _dateController.forward();
    _firstMessageController.forward();
    _daysController.forward();
  }

  @override
  void dispose() {
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    _participantsController.dispose();
    _dateController.dispose();
    _firstMessageController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el primer mensaje
    final firstMessage = widget.data.allMessages.isNotEmpty
        ? widget.data.allMessages.first
        : null;

    // Calcular días transcurridos
    final daysSinceStart = widget.data.firstMessageDate != null
        ? DateTime.now().difference(widget.data.firstMessageDate!).inDays
        : 0;

    // Formatear fecha de inicio
    String formattedStartDate = '';
    if (widget.data.firstMessageDate != null) {
      final date = widget.data.firstMessageDate!;
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
      formattedStartDate =
          '${date.day} de ${months[date.month - 1]} de ${date.year}';
    }

    // Texto de participantes
    final participantsText = widget.data.participants.length == 2
        ? '${widget.data.participants[0]} y ${widget.data.participants[1]}'
        : '${widget.data.participants.length} participantes';

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
            animation:
                Listenable.merge([_titleFadeAnimation, _titlePositionAnimation]),
            builder: (context, child) {
              // Calcular posición del título dentro del builder para que se actualice
              // El título empieza en el centro absoluto de la pantalla
              final centerY = screenHeight / 2;
              final titleStartY = centerY - topPadding; // Posición inicial relativa al topPadding
              final titleEndY = 0.0; // Posición final arriba (relativa al topPadding)
              
              // Interpolación: cuando animation.value = 0, currentTitleY = titleStartY (centro)
              // cuando animation.value = 1, currentTitleY = titleEndY (arriba)
              final currentTitleY = titleStartY - (titleStartY - titleEndY) * _titlePositionAnimation.value;
              
              return Positioned(
                top: topPadding + currentTitleY,
                left: 32,
                right: 32,
                child: Opacity(
                  opacity: _titleFadeAnimation.value,
                  child: Text(
                    'Bienvenid@ a tu Whatsapp Wrapped!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
              left: 32,
              right: 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60), // Espacio para el título
                // Participantes
                FadeTransition(
                  opacity: _participantsAnimation,
                  child: Text(
                    participantsText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Fecha
                if (formattedStartDate.isNotEmpty)
                  FadeTransition(
                    opacity: _dateAnimation,
                    child: Text(
                      formattedStartDate,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                // "todo empezó con un..."
                FadeTransition(
                  opacity: _firstMessageAnimation,
                  child: Column(
                    children: [
                      Text(
                        'todo empezó con un...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (firstMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            firstMessage['message'] as String? ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

