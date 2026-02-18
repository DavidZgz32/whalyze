import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wrapped_screen_durations.dart';
import 'whatsapp_processor.dart';
import 'screens/wrapped/wrapped_first_screen.dart';
import 'screens/wrapped/wrapped_second_screen.dart';
import 'screens/wrapped/wrapped_third_screen.dart';
import 'screens/wrapped/wrapped_placeholder_screen.dart';
import 'screens/wrapped/wrapped_ad_screen.dart';
import 'screens/wrapped/wrapped_fifth_screen.dart';

/// Slideshow unificado del Wrapped. Usado tanto al subir un chat como al abrirlo desde favoritos.
class WrappedSlideshow extends StatefulWidget {
  final WhatsAppData data;
  final VoidCallback onClose;
  final VoidCallback? onAllScreensCompleted;

  const WrappedSlideshow({
    super.key,
    required this.data,
    required this.onClose,
    this.onAllScreensCompleted,
  });

  @override
  State<WrappedSlideshow> createState() => _WrappedSlideshowState();
}

class _WrappedSlideshowState extends State<WrappedSlideshow>
    with TickerProviderStateMixin {
  AnimationController? _progressController;
  late AnimationController _fadeController;
  Animation<double>? _progressAnimation;
  late Animation<double> _fadeAnimation;

  int _currentScreen = 0;
  double _progress = 0.0;
  bool _isPaused = false;
  static const int _totalScreens = 9;

  final GlobalKey<WrappedFirstScreenState> _firstScreenKey =
      GlobalKey<WrappedFirstScreenState>();
  final GlobalKey<WrappedSecondScreenState> _secondScreenKey =
      GlobalKey<WrappedSecondScreenState>();
  final GlobalKey<WrappedThirdScreenState> _thirdScreenKey =
      GlobalKey<WrappedThirdScreenState>();
  final GlobalKey<WrappedFifthScreenState> _fifthScreenKey =
      GlobalKey<WrappedFifthScreenState>();

  @override
  void initState() {
    super.initState();

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

    _createProgressControllerForCurrentScreen();
    _fadeController.forward();
    _progressController!.forward();
  }

  void _createProgressControllerForCurrentScreen() {
    _progressController?.removeStatusListener(_onProgressStatusChanged);
    _progressController?.dispose();

    final durationMs =
        WrappedScreenDurations.getDurationMs(_currentScreen);
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController!,
        curve: Curves.linear,
      ),
    );

    _progressController!.addListener(() {
      if (mounted && _progressAnimation != null) {
        setState(() => _progress = _progressAnimation!.value);
      }
    });

    _progressController!.addStatusListener(_onProgressStatusChanged);
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    if (_isPaused) return;
    if (_currentScreen >= _totalScreens - 1) {
      widget.onAllScreensCompleted?.call();
      return;
    }

    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentScreen++;
        _progress = 0.0;
      });
      _createProgressControllerForCurrentScreen();
      _fadeController.forward();
      if (!_isPaused) {
        _progressController!.forward();
      }
      if (_currentScreen == 0) {
        _firstScreenKey.currentState?.resetAnimations();
      }
      if (_isPaused) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_currentScreen == 0) {
            _firstScreenKey.currentState?.pauseAnimations();
          } else if (_currentScreen == 1) {
            _secondScreenKey.currentState?.pauseAnimations();
          } else if (_currentScreen == 2) {
            _thirdScreenKey.currentState?.pauseAnimations();
          } else if (_currentScreen == 4) {
            _fifthScreenKey.currentState?.pauseAnimations();
          }
        });
      }
    }).catchError((error) {
      if (mounted) print('Error en fade reverse: $error');
    });
  }

  void _pauseAnimation() {
    if (_isPaused) return;
    if (!mounted) return;
    setState(() => _isPaused = true);
    if (_progressController?.isAnimating ?? false) {
      _progressController!.stop(canceled: false);
    }
    if (_currentScreen == 0) {
      _firstScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 2) {
      _thirdScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 4) {
      _fifthScreenKey.currentState?.pauseAnimations();
    }
  }

  void _resumeAnimation() {
    if (!_isPaused) return;
    if (!mounted) return;
    setState(() => _isPaused = false);
    _progressController?.forward();
    if (_currentScreen == 0) {
      _firstScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 2) {
      _thirdScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 4) {
      _fifthScreenKey.currentState?.resumeAnimations();
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
      _progressController?.stop();
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentScreen++;
          _progress = 0.0;
        });
        _createProgressControllerForCurrentScreen();
        _fadeController.forward();
        _progressController!.forward();
        if (_currentScreen == 0) {
          _firstScreenKey.currentState?.resetAnimations();
        }
      });
    }
  }

  void _goToPreviousScreen() {
    if (_currentScreen > 0) {
      _progressController?.stop();
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentScreen--;
          _progress = 0.0;
        });
        _createProgressControllerForCurrentScreen();
        _fadeController.forward();
        _progressController!.forward();
        if (_currentScreen == 0) {
          _firstScreenKey.currentState?.resetAnimations();
        }
      });
    }
  }

  void _restartCurrentScreen() {
    _progressController?.stop();
    _progressController?.reset();
    setState(() => _progress = 0.0);
    _progressController?.forward();
    if (_currentScreen == 0) {
      _firstScreenKey.currentState?.resetAnimations();
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.resetAnimations();
    } else if (_currentScreen == 2) {
      _thirdScreenKey.currentState?.resetAnimations();
    } else if (_currentScreen == 4) {
      _fifthScreenKey.currentState?.resetAnimations();
    }
  }

  void _handleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX > screenWidth / 2) {
      _goToNextScreen();
    } else {
      final secondsPerScreen =
          WrappedScreenDurations.getDurationMs(_currentScreen) / 1000.0;
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

  @override
  void dispose() {
    _progressController?.removeStatusListener(_onProgressStatusChanged);
    _progressController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildScreen() {
    final data = widget.data;
    if (_currentScreen == 0) {
      return WrappedFirstScreen(
        key: _firstScreenKey,
        data: data,
        totalScreens: _totalScreens,
      );
    }
    if (_currentScreen == 1) {
      return WrappedSecondScreen(
        key: _secondScreenKey,
        data: data,
        totalScreens: _totalScreens,
      );
    }
    if (_currentScreen == 2) {
      return WrappedThirdScreen(
        key: _thirdScreenKey,
        data: data,
        totalScreens: _totalScreens,
      );
    }
    if (_currentScreen == 3) {
      return const WrappedAdScreen(totalScreens: _totalScreens);
    }
    if (_currentScreen == 4) {
      return WrappedFifthScreen(
        key: _fifthScreenKey,
        data: data,
        totalScreens: _totalScreens,
      );
    }
    return WrappedPlaceholderScreen(
      screenNumber: _currentScreen,
      totalScreens: _totalScreens,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      onLongPressStart: (_) => _pauseAnimation(),
      onLongPressEnd: (_) => _resumeAnimation(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00C980),
              Color(0xFF00A6B6),
            ],
          ),
        ),
        child: Stack(
          children: [
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
                                ? 1.0
                                : index == _currentScreen
                                    ? _progress
                                    : 0.0,
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
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  (_totalScreens * 4) +
                  ((_totalScreens - 1) * 2) +
                  4,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onClose,
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
    );
  }
}
