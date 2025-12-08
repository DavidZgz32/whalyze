import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/wrapped_model.dart';

class WrappedViewScreen extends StatefulWidget {
  final WrappedModel wrapped;

  const WrappedViewScreen({
    super.key,
    required this.wrapped,
  });

  @override
  State<WrappedViewScreen> createState() => _WrappedViewScreenState();
}

class _WrappedViewScreenState extends State<WrappedViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  int _currentScreen = 0;
  double _progress = 0.0;
  bool _isPaused = false; // Flag para pausar animación
  static const int _totalScreens = 9;

  @override
  void initState() {
    super.initState();
    
    // Controlador para la barra de progreso
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.linear,
      ),
    );
    
    // Controlador para fade in/out
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
    
    _progressController.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });
    
    _startAnimation();
  }

  void _startAnimation() {
    _fadeController.forward();
    _progressController.forward().then((_) {
      // Después de 10 segundos, pasar a la siguiente pantalla
      if (_currentScreen < _totalScreens - 1) {
        _fadeController.reverse().then((_) {
          setState(() {
            _currentScreen++;
            _progress = 0.0;
          });
          // Reiniciar el controlador para la siguiente pantalla
          _progressController.reset();
          _fadeController.forward();
          _progressController.forward();
        });
      }
    });
  }

  void _pauseAnimation() {
    if (!_isPaused && _progressController.isAnimating) {
      _isPaused = true;
      _progressController.stop(canceled: false);
    }
  }

  void _resumeAnimation() {
    if (_isPaused) {
      _isPaused = false;
      _progressController.forward();
    }
  }

  void _goToNextScreen() {
    if (_currentScreen < _totalScreens - 1) {
      _progressController.stop();
      _fadeController.reverse().then((_) {
        setState(() {
          _currentScreen++;
          _progress = 0.0;
        });
        _progressController.reset();
        _fadeController.forward();
        _progressController.forward();
      });
    }
  }

  void _goToPreviousScreen() {
    if (_currentScreen > 0) {
      _progressController.stop();
      _fadeController.reverse().then((_) {
        setState(() {
          _currentScreen--;
          _progress = 0.0;
        });
        _progressController.reset();
        _fadeController.forward();
        _progressController.forward();
      });
    }
  }

  void _handleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;
    
    // Si el tap es en la mitad derecha de la pantalla, avanzar
    if (tapX > screenWidth / 2) {
      _goToNextScreen();
    } else {
      // Si el tap es en la mitad izquierda, retroceder
      _goToPreviousScreen();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: _handleTap,
        onLongPressStart: (_) => _pauseAnimation(),
        onLongPressEnd: (_) => _resumeAnimation(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00C980),
                const Color(0xFF00A6B6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 9 barras de progreso arriba del todo (como Instagram)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).padding.top + (_totalScreens * 4) + ((_totalScreens - 1) * 2),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 2,
                    left: 2,
                    right: 2,
                  ),
                  child: Row(
                    children: List.generate(_totalScreens, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < _totalScreens - 1 ? 2 : 0,
                          ),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: index < _currentScreen
                                  ? 1.0 // Pantallas anteriores: completamente cargadas
                                  : index == _currentScreen
                                      ? _progress // Pantalla actual: progreso actual
                                      : 0.0, // Pantallas siguientes: vacías
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildScreen(),
              ),
              // Botón X en la esquina superior derecha
              Positioned(
                top: MediaQuery.of(context).padding.top + (_totalScreens * 4) + ((_totalScreens - 1) * 2) + 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    // Por ahora, mostrar las primeras 2 pantallas como antes
    // Más adelante se pueden agregar las otras 7
    if (_currentScreen == 0) {
      return _buildFirstScreen();
    } else if (_currentScreen == 1) {
      return _buildSecondScreen();
    } else {
      // Pantallas adicionales (2-8) - por ahora mostrar placeholder
      return _buildPlaceholderScreen();
    }
  }

  Widget _buildFirstScreen() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + (_totalScreens * 4) + ((_totalScreens - 1) * 2) + 60,
          bottom: MediaQuery.of(context).padding.bottom + 32,
          left: 32,
          right: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              '${widget.wrapped.totalLines}',
              style: GoogleFonts.inter(
                fontSize: 80,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'líneas',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondScreen() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + (_totalScreens * 4) + ((_totalScreens - 1) * 2) + 60,
          bottom: MediaQuery.of(context).padding.bottom + 32,
          left: 32,
          right: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Participantes',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ...widget.wrapped.participants.map((participant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  participant,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              );
            }),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderScreen() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + (_totalScreens * 4) + ((_totalScreens - 1) * 2) + 60,
          bottom: MediaQuery.of(context).padding.bottom + 32,
          left: 32,
          right: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Pantalla ${_currentScreen + 1}',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

