import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'whatsapp_processor.dart';
import 'services/wrapped_storage.dart';
import 'models/wrapped_model.dart';
import 'screens/wrapped/wrapped_first_screen.dart';
import 'screens/wrapped/wrapped_second_screen.dart';
import 'screens/wrapped/wrapped_placeholder_screen.dart';

class WrappedScreen extends StatefulWidget {
  final String filePath;
  final String fileContent;

  const WrappedScreen({
    super.key,
    required this.filePath,
    required this.fileContent,
  });

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  WhatsAppData? _data;
  int _currentScreen = 0;
  double _progress = 0.0;
  bool _hasBeenSaved = false; // Flag para evitar guardar múltiples veces
  bool _isPaused = false; // Flag para pausar animación
  static const int _totalScreens = 9;

  // Referencia a la primera y segunda pantalla para controlar animaciones
  final GlobalKey<WrappedFirstScreenState> _firstScreenKey =
      GlobalKey<WrappedFirstScreenState>();
  final GlobalKey<WrappedSecondScreenState> _secondScreenKey =
      GlobalKey<WrappedSecondScreenState>();

  @override
  void initState() {
    super.initState();

    print('WrappedScreen initState - procesando archivo...');
    // Procesar el archivo
    _data = WhatsAppProcessor.processFile(widget.fileContent);
    print('Archivo procesado - participants: ${_data?.participants.length}');

    // Guardar inmediatamente después de procesar (backup)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('PostFrameCallback - guardando wrapped inmediatamente...');
      Future.delayed(const Duration(seconds: 1), () {
        if (!_hasBeenSaved && _data != null) {
          print('Guardando wrapped en postFrameCallback...');
          _saveWrapped();
        }
      });
    });

    // Controlador para la barra de progreso (20 segundos por pantalla)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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

    print('Iniciando animación...');
    _startAnimation();
  }

  void _startAnimation() {
    _fadeController.forward();
    _forwardProgressWithCompletion();
  }

  void _forwardProgressWithCompletion() {
    _progressController.forward().then((_) {
      if (!mounted) return;
      if (_currentScreen < _totalScreens - 1) {
        _fadeController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            _currentScreen++;
            _progress = 0.0;
          });
          _progressController.reset();
          _fadeController.forward();
          _forwardProgressWithCompletion();

          if (_currentScreen == 0) {
            _firstScreenKey.currentState?.resetAnimations();
          }
        }).catchError((error) {
          print('Error en fade reverse: $error');
        });
      } else {
        print('Todas las pantallas completadas, guardando wrapped...');
        _saveWrapped();
      }
    }).catchError((error) {
      print('Error en progress animation: $error');
    });
  }

  void _pauseAnimation() {
    if (_isPaused) return;
    setState(() {
      _isPaused = true;
      _progress = _progressAnimation.value;
    });
    _progressController.stop(canceled: false);

    if (_currentScreen == 0) {
      _firstScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.pauseAnimations();
    }
  }

  void _resumeAnimation() {
    if (!_isPaused) return;
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();

    if (_currentScreen == 0) {
      _firstScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.resumeAnimations();
    }
  }

  void _togglePlayPause() {
    if (_isPaused) {
      _resumeAnimation();
    } else {
      _pauseAnimation();
    }
  }

  void _goToNextScreen() {
    if (_currentScreen < _totalScreens - 1) {
      _progressController.stop();
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentScreen++;
          _progress = 0.0;
        });
        _progressController.reset();
        _fadeController.forward();
        _forwardProgressWithCompletion();

        if (_currentScreen == 0) {
          _firstScreenKey.currentState?.resetAnimations();
        }
      });
    }
  }

  void _goToPreviousScreen() {
    if (_currentScreen > 0) {
      _progressController.stop();
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentScreen--;
          _progress = 0.0;
        });
        _progressController.reset();
        _fadeController.forward();
        _forwardProgressWithCompletion();

        if (_currentScreen == 0) {
          _firstScreenKey.currentState?.resetAnimations();
        }
      });
    }
  }

  void _restartCurrentScreen() {
    _progressController.stop();
    _progressController.reset();
    _progress = 0.0;
    _forwardProgressWithCompletion();

    if (_currentScreen == 0) {
      _firstScreenKey.currentState?.resetAnimations();
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.resetAnimations();
    }
  }

  void _handleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX > screenWidth / 2) {
      _goToNextScreen();
    } else {
      // Tap izquierdo: primeros 4 seg → pantalla anterior; pasado 50% → reiniciar
      const secondsPerScreen = 20;
      final progressSeconds = _progress * secondsPerScreen;

      if (progressSeconds < 4 && _currentScreen > 0) {
        _goToPreviousScreen();
      } else if (_progress >= 0.5 || progressSeconds >= 4) {
        _restartCurrentScreen();
      } else {
        _goToPreviousScreen();
      }
    }
  }

  Future<void> _saveWrapped() async {
    // Evitar guardar múltiples veces
    if (_hasBeenSaved) {
      print('_saveWrapped() ya fue llamado anteriormente, saltando...');
      return;
    }

    print('_saveWrapped() llamado');
    if (_data == null) {
      print('Error: _data is null, cannot save wrapped');
      return;
    }

    print('_data no es null, participants: ${_data!.participants.length}');

    try {
      // Marcar como guardado antes de empezar para evitar duplicados
      _hasBeenSaved = true;

      // Generar ID único con formato wrapped_<timestamp>
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wrappedId = 'wrapped_$timestamp';

      // Obtener el JSON completo con todas las métricas
      final jsonData = _data!.toJson();

      print('JSON generado con ${jsonData.keys.length} keys');
      print('Primeros keys del JSON: ${jsonData.keys.take(5).toList()}');

      // Calcular totalLines desde el contenido del archivo
      final totalLines = widget.fileContent.split('\n').length;

      final wrapped = WrappedModel(
        id: wrappedId,
        title: 'WHALYZE ${DateTime.now().year}',
        createdAt: DateTime.now(),
        data: jsonData, // JSON completo con todas las métricas
        participants: _data!.participants,
        totalLines: totalLines,
      );

      print('WrappedModel creado: ${wrapped.id}, título: ${wrapped.title}');
      print('Intentando guardar en WrappedStorage...');

      await WrappedStorage.saveWrapped(wrapped);
      print('Wrapped guardado exitosamente: ${wrapped.id}');

      // Verificar que se guardó inmediatamente
      await Future.delayed(const Duration(milliseconds: 100));
      final allWrappeds = WrappedStorage.getAllWrappeds();
      print(
          'Total wrappeds guardados después de guardar: ${allWrappeds.length}');

      if (allWrappeds.isEmpty) {
        print('ERROR CRÍTICO: El wrapped no aparece después de guardar');
      }

      // Wrapped guardado silenciosamente sin mostrar aviso
    } catch (e, stackTrace) {
      print('Error al guardar wrapped: $e');
      print('Stack trace: $stackTrace');
      // Resetear el flag si falló
      _hasBeenSaved = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar wrapped: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Guardar el wrapped antes de cerrar si no se ha guardado aún
    if (_currentScreen >= 1 && _data != null) {
      print('Dispose llamado - guardando wrapped antes de cerrar...');
      _saveWrapped();
    }
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  height: MediaQuery.of(context).padding.top +
                      (_totalScreens * 4) +
                      ((_totalScreens - 1) * 2),
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
              // "Creado con Whalyze" abajo de todas las pantallas
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Creado con Whalyze',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              // Botones de control en la esquina superior derecha
              Positioned(
                top: MediaQuery.of(context).padding.top +
                    (_totalScreens * 4) +
                    ((_totalScreens - 1) * 2) +
                    4,
                right: 16,
                child: GestureDetector(
                  onTap:
                      () {}, // Absorber taps para evitar que lleguen al GestureDetector principal
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón play/pause
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón X
                      IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
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
    if (_currentScreen == 0) {
      return WrappedFirstScreen(
        key: _firstScreenKey,
        data: _data!,
        totalScreens: _totalScreens,
      );
    } else if (_currentScreen == 1) {
      return WrappedSecondScreen(
        key: _secondScreenKey,
        data: _data!,
        totalScreens: _totalScreens,
      );
    } else {
      // Pantallas adicionales (2-8) - por ahora mostrar placeholder
      return WrappedPlaceholderScreen(
        screenNumber: _currentScreen,
        totalScreens: _totalScreens,
      );
    }
  }
}
