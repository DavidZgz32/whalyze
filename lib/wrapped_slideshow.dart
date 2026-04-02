import 'dart:developer' show log;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wrapped_screen_durations.dart';
import 'whatsapp_processor.dart';
import 'screens/wrapped/wrapped_first_screen.dart';
import 'screens/wrapped/wrapped_second_screen.dart';
import 'screens/wrapped/wrapped_third_screen.dart';
import 'screens/wrapped/wrapped_placeholder_screen.dart';
import 'screens/wrapped/wrapped_fifth_screen.dart';
import 'screens/wrapped/wrapped_sixth_screen.dart';
import 'screens/wrapped/wrapped_seventh_screen.dart';
import 'screens/wrapped/wrapped_eighth_screen.dart';
import 'screens/wrapped/wrapped_words_screen.dart';
import 'screens/wrapped/wrapped_final_screen.dart';
import 'screens/wrapped/wrapped_group_first_screen.dart';
import 'screens/wrapped/wrapped_group_second_screen.dart';
import 'screens/wrapped/wrapped_group_third_screen.dart';
import 'screens/wrapped/wrapped_group_fourth_screen.dart';
import 'screens/wrapped/wrapped_group_fifth_screen.dart';
import 'screens/wrapped/wrapped_group_sixth_screen.dart';
import 'screens/wrapped/wrapped_group_seventh_screen.dart';
import 'screens/wrapped/wrapped_group_eighth_screen.dart';
import 'screens/wrapped/wrapped_group_ninth_screen.dart';

/// Debug: filtra en consola / DevTools por `WrappedNav`.
void _wrappedNavLog(String message) =>
    log(message, name: 'WrappedNav');

/// Slideshow del Wrapped (1 a 1 o grupal si hay más de 2 participantes).
/// Índice de las 9 pantallas: lib/WRAPPED_PANTALLAS.md
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

  int _currentScreen = 0;
  bool _isPaused = false;
  static const int _totalScreens = 9;

  /// Solo se construyen las diapositivas ya visitadas (se conserva el estado).
  final List<bool> _everVisited = List<bool>.filled(9, false);

  /// Último progreso de barra [0,1] al salir de cada índice; 1 = vista completa.
  final List<double?> _savedProgress = List<double?>.filled(9, null);

  final GlobalKey<WrappedFirstScreenState> _firstScreenKey =
      GlobalKey<WrappedFirstScreenState>();
  final GlobalKey<WrappedGroupFirstScreenState> _groupFirstScreenKey =
      GlobalKey<WrappedGroupFirstScreenState>();
  final GlobalKey<WrappedSecondScreenState> _secondScreenKey =
      GlobalKey<WrappedSecondScreenState>();
  final GlobalKey<WrappedThirdScreenState> _thirdScreenKey =
      GlobalKey<WrappedThirdScreenState>();
  final GlobalKey<WrappedFifthScreenState> _fifthScreenKey =
      GlobalKey<WrappedFifthScreenState>();
  final GlobalKey<WrappedSixthScreenState> _sixthScreenKey =
      GlobalKey<WrappedSixthScreenState>();
  final GlobalKey<WrappedSeventhScreenState> _seventhScreenKey =
      GlobalKey<WrappedSeventhScreenState>();
  final GlobalKey<WrappedEighthScreenState> _eighthScreenKey =
      GlobalKey<WrappedEighthScreenState>();
  final GlobalKey<WrappedWordsScreenState> _wordsScreenKey =
      GlobalKey<WrappedWordsScreenState>();

  bool get _isGroupChat => widget.data.participants.length > 2;

  /// Tras las animaciones de cada pantalla grupal (índices 0–7), cuánto dura
  /// la barra de margen antes del auto-avance. Ver `WRAPPED_GRUPO_DURACION.md`.
  static const int _groupPostAnimationHoldMs = 1000;

  /// Slideshow en pausa cuando el grupo ya terminó animaciones y debe arrancar
  /// solo la barra de 1 s al reanudar.
  bool _groupWaitingToStartPostAnimationBar = false;

  /// Grupal 0–7: true mientras las animaciones de la pantalla pueden seguir;
  /// la barra lineal llega como máximo hasta la fracción
  /// `D_estimado/(D_estimado+hold)` y espera si hace falta. Tras
  /// [onGroupScreenAnimationsComplete] → false y la barra termina el tramo hasta 1
  /// en el tiempo de hold (estilo Instagram).
  bool _groupSlideContentPhaseActive = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );

    _everVisited[0] = true;
    _createProgressControllerForCurrentScreen();
    _fadeController.forward();
    if (_isGroupChat && _currentScreen < 8) {
      _groupSlideContentPhaseActive = true;
    }
    // Grupal 0–7: barra lineal continua (estimación contenido + hold).
    // Individual: misma barra según WrappedScreenDurations.
    _startProgressBarForward();
  }

  void _pauseWrappedScreen(int index) {
    switch (index) {
      case 0:
        if (_isGroupChat) {
          _groupFirstScreenKey.currentState?.pauseAnimations();
        } else {
          _firstScreenKey.currentState?.pauseAnimations();
        }
        break;
      case 1:
        _secondScreenKey.currentState?.pauseAnimations();
        break;
      case 2:
        _thirdScreenKey.currentState?.pauseAnimations();
        break;
      case 3:
        _fifthScreenKey.currentState?.pauseAnimations();
        break;
      case 4:
        _sixthScreenKey.currentState?.pauseAnimations();
        break;
      case 5:
        _seventhScreenKey.currentState?.pauseAnimations();
        break;
      case 6:
        _eighthScreenKey.currentState?.pauseAnimations();
        break;
      case 7:
        _wordsScreenKey.currentState?.pauseAnimations();
        break;
      case 8:
        break;
    }
  }

  void _jumpWrappedScreenToEnd(int index) {
    switch (index) {
      case 0:
        if (_isGroupChat) {
          _groupFirstScreenKey.currentState?.jumpAnimationsToEnd();
        } else {
          _firstScreenKey.currentState?.jumpAnimationsToEnd();
        }
        break;
      case 1:
        _secondScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 2:
        _thirdScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 3:
        _fifthScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 4:
        _sixthScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 5:
        _seventhScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 6:
        _eighthScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 7:
        _wordsScreenKey.currentState?.jumpAnimationsToEnd();
        break;
      case 8:
        break;
    }
  }

  void _resumeWrappedScreenPartial(int index) {
    switch (index) {
      case 0:
        if (_isGroupChat) {
          _groupFirstScreenKey.currentState?.resumeAnimations();
        } else {
          _firstScreenKey.currentState?.resumeAnimations();
        }
        break;
      case 1:
        _secondScreenKey.currentState?.resumeAnimations();
        break;
      case 2:
        _thirdScreenKey.currentState?.resumeAnimations();
        break;
      case 3:
        _fifthScreenKey.currentState?.resumeAnimations();
        break;
      case 4:
        _sixthScreenKey.currentState?.resumeAnimations();
        break;
      case 5:
        _seventhScreenKey.currentState?.resumeAnimations();
        break;
      case 6:
        _eighthScreenKey.currentState?.resumeAnimations();
        break;
      case 7:
        _wordsScreenKey.currentState?.resumeAnimations();
        break;
      case 8:
        break;
    }
  }

  /// Arranca la barra de progreso en el siguiente frame (evita interferir con gestos tras avance automático).
  void _startProgressBarForward() {
    if (_isPaused) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isPaused) return;
      _progressController?.forward();
    });
  }

  /// Aplica progreso guardado y animaciones al mostrar la diapositiva [index].
  void _applyRestoredProgressForScreen(int index, bool firstVisit) {
    if (index == 8) {
      _progressController!.value = 0.0;
      _startProgressBarForward();
      return;
    }

    final saved = _savedProgress[index];
    if (saved != null && saved >= 1.0) {
      if (_isGroupChat && index < 8) {
        _groupSlideContentPhaseActive = false;
      }
      // Asignar 1.0 dispara `AnimationStatus.completed` y reprogramaba el auto-avance:
      // un frame en la pantalla anterior y luego salto otra vez a la siguiente ("flash").
      final c = _progressController!;
      c.removeStatusListener(_onProgressStatusChanged);
      c.value = 1.0;
      c.addStatusListener(_onProgressStatusChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || index != _currentScreen) return;
        _jumpWrappedScreenToEnd(index);
      });
      return;
    }

    // Grupal 0–7: barra determinada; durante fase contenido se limita el avance.
    if (_isGroupChat && index < 8) {
      final v = firstVisit ? 0.0 : (saved ?? 0.0);
      _groupSlideContentPhaseActive = firstVisit || v == 0.0;
      _progressController!.value = v;
      if (firstVisit) {
        _startProgressBarForward();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || index != _currentScreen) return;
          _resumeWrappedScreenPartial(index);
          if (!_groupSlideContentPhaseActive && v < 1.0) {
            _startProgressBarForward();
          }
        });
      }
      return;
    }

    final v = firstVisit ? 0.0 : (saved ?? 0.0);
    _progressController!.value = v;

    if (!firstVisit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || index != _currentScreen) return;
        _resumeWrappedScreenPartial(index);
        _startProgressBarForward();
      });
    } else {
      _startProgressBarForward();
    }
  }

  /// Tiempo estimado solo de animaciones de contenido (grupal); el hold se suma aparte.
  int _groupContentEstimateMs(int screenIndex) {
    final n = widget.data.participants.length;
    switch (screenIndex) {
      case 0:
        return 32000;
      case 1:
        final rows = math.min(10, n);
        if (rows <= 0) return 2000;
        return 800 + rows * 1000 + 600;
      case 2:
        // Pantalla grupal 3: 6 roles → último fade a 2000*5 + 400.
        // El widget además avisa 2s extra antes del hold de 1s del slideshow.
        return 2000 * 5 + 400 + 2000;
      case 3:
        // Pantalla grupal 4: 5 roles → último fade a 2000*4 + 400.
        return 2000 * 4 + 400 + 2000;
      case 4:
        // Pantalla grupal 5: día/mes + ladder de emojis (animación propia ~1.2s).
        return 1600;
      case 5:
      case 6:
      case 7:
        return 600;
      default:
        return 5000;
    }
  }

  double _groupClampUpperBoundForScreen(int screenIndex) {
    final dEst = _groupContentEstimateMs(screenIndex).toDouble();
    final dHold = _groupPostAnimationHoldMs.toDouble();
    return dEst / (dEst + dHold);
  }

  void _onGroupProgressClamp() {
    if (!mounted) return;
    if (!_isGroupChat || _currentScreen >= 8) return;
    if (!_groupSlideContentPhaseActive) return;
    final c = _progressController;
    if (c == null || !c.isAnimating) return;
    final f = _groupClampUpperBoundForScreen(_currentScreen);
    if (c.value > f) {
      c.stop(canceled: false);
      c.value = f;
    }
  }

  void _createProgressControllerForCurrentScreen() {
    _wrappedNavLog(
      'createProgressController: drop old, new screen=$_currentScreen '
      '(hash=$hashCode)',
    );
    _progressController?.removeListener(_onGroupProgressClamp);
    _progressController?.removeStatusListener(_onProgressStatusChanged);
    _progressController?.dispose();

    final bool groupTimeline = _isGroupChat && _currentScreen < 8;
    final durationMs = groupTimeline
        ? _groupContentEstimateMs(_currentScreen) + _groupPostAnimationHoldMs
        : WrappedScreenDurations.getDurationMs(_currentScreen);
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    _progressController!.addStatusListener(_onProgressStatusChanged);
    if (groupTimeline) {
      _progressController!.addListener(_onGroupProgressClamp);
    }
  }

  /// Pantalla grupal 0–7: la animación de contenido terminó; arranca (o encola)
  /// la barra de [_groupPostAnimationHoldMs].
  void _onGroupScreenAnimationsComplete(int screenIndex) {
    if (!_isGroupChat ||
        screenIndex != _currentScreen ||
        screenIndex > 7) {
      _wrappedNavLog(
        'group anim done IGNORED announced='
        '$screenIndex current=$_currentScreen group=$_isGroupChat',
      );
      return;
    }
    _wrappedNavLog(
      'group anim done announced=$screenIndex → '
      '${_isPaused ? "QUEUE post-anim bar" : "START post-anim bar"}',
    );
    setState(() {
      _groupSlideContentPhaseActive = false;
    });
    if (_isPaused) {
      _groupWaitingToStartPostAnimationBar = true;
    } else {
      _groupWaitingToStartPostAnimationBar = false;
      if (mounted) {
        _progressController?.forward();
      }
    }
  }

  void _onProgressStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    if (_isPaused) return;
    if (_isGroupChat &&
        _currentScreen < 8 &&
        _groupSlideContentPhaseActive) {
      return;
    }
    if (_currentScreen >= _totalScreens - 1) {
      _wrappedNavLog(
        'progress COMPLETED on last screen=$_currentScreen → onAllScreensCompleted',
      );
      widget.onAllScreensCompleted?.call();
      return;
    }

    // No disponer ni recrear el controlador de progreso dentro de este listener:
    // degenera el reconocimiento de gestos hasta el punto de que deja de funcionar "atrás".
    final completedIndex = _currentScreen;
    final next = completedIndex + 1;
    _wrappedNavLog(
      'progress COMPLETED screen=$completedIndex → schedule advance to $next',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _wrappedNavLog('auto-advance postFrame: skip (unmounted)');
        return;
      }
      if (_isPaused) {
        _wrappedNavLog('auto-advance postFrame: skip (paused)');
        return;
      }
      if (_currentScreen != completedIndex) {
        _wrappedNavLog(
          'auto-advance postFrame: SKIP stale (expected screen=$completedIndex '
          'current=$_currentScreen)',
        );
        return;
      }

      _groupWaitingToStartPostAnimationBar = false;
      _savedProgress[completedIndex] = 1.0;
      _jumpWrappedScreenToEnd(completedIndex);
      _pauseWrappedScreen(completedIndex);

      final firstVisitNext = !_everVisited[next];
      setState(() {
        _currentScreen = next;
        _everVisited[next] = true;
        _isPaused = false;
      });
      _createProgressControllerForCurrentScreen();
      _fadeController.value = 1.0;
      _applyRestoredProgressForScreen(next, firstVisitNext);

      if (_isPaused) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _pauseWrappedScreen(_currentScreen);
        });
      }
      _wrappedNavLog(
        'auto-advance DONE now screen=$_currentScreen '
        'progressCtrl=${_progressController.hashCode} value=${_progressController?.value}',
      );
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
      if (_isGroupChat) {
        _groupFirstScreenKey.currentState?.pauseAnimations();
      } else {
        _firstScreenKey.currentState?.pauseAnimations();
      }
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 2) {
      _thirdScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 3) {
      _fifthScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 4) {
      _sixthScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 5) {
      _seventhScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 6) {
      _eighthScreenKey.currentState?.pauseAnimations();
    } else if (_currentScreen == 7) {
      _wordsScreenKey.currentState?.pauseAnimations();
    }
  }

  void _resumeAnimation() {
    if (!_isPaused) return;
    if (!mounted) return;
    setState(() => _isPaused = false);
    if (_groupWaitingToStartPostAnimationBar &&
        _isGroupChat &&
        _currentScreen < 8) {
      _groupWaitingToStartPostAnimationBar = false;
      _startProgressBarForward();
    } else if (_isGroupChat &&
        _currentScreen < 8 &&
        _groupSlideContentPhaseActive) {
      final c = _progressController;
      if (c != null) {
        final f = _groupClampUpperBoundForScreen(_currentScreen);
        if (c.isAnimating || c.value < f - 1e-5) {
          c.forward();
        }
      }
    } else {
      _progressController?.forward();
    }
    if (_currentScreen == 0) {
      if (_isGroupChat) {
        _groupFirstScreenKey.currentState?.resumeAnimations();
      } else {
        _firstScreenKey.currentState?.resumeAnimations();
      }
    } else if (_currentScreen == 1) {
      _secondScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 2) {
      _thirdScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 3) {
      _fifthScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 4) {
      _sixthScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 5) {
      _seventhScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 6) {
      _eighthScreenKey.currentState?.resumeAnimations();
    } else if (_currentScreen == 7) {
      _wordsScreenKey.currentState?.resumeAnimations();
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
    _wrappedNavLog(
      'goToNext ENTRY screen=$_currentScreen paused=$_isPaused',
    );
    if (_currentScreen >= _totalScreens - 1) {
      _wrappedNavLog('goToNext ABORT (already last)');
      return;
    }
    _groupWaitingToStartPostAnimationBar = false;
    _progressController?.stop();
    if (!mounted) return;
    _savedProgress[_currentScreen] = _progressController?.value ?? 0.0;
    _pauseWrappedScreen(_currentScreen);

    final next = _currentScreen + 1;
    final firstVisitNext = !_everVisited[next];
    setState(() {
      _currentScreen = next;
      _everVisited[next] = true;
      _isPaused = false;
    });
    _createProgressControllerForCurrentScreen();
    _fadeController.value = 1.0;
    _applyRestoredProgressForScreen(next, firstVisitNext);
    _wrappedNavLog('goToNext DONE screen=$_currentScreen');
  }

  void _goToPreviousScreen() {
    _wrappedNavLog(
      'goToPrevious ENTRY screen=$_currentScreen paused=$_isPaused '
      'bar=${_progressController?.value}',
    );
    if (_currentScreen <= 0) {
      _wrappedNavLog('goToPrevious ABORT (already first)');
      return;
    }
    _groupWaitingToStartPostAnimationBar = false;
    _progressController?.stop();
    if (!mounted) return;
    _savedProgress[_currentScreen] = _progressController?.value ?? 0.0;
    _pauseWrappedScreen(_currentScreen);

    final prev = _currentScreen - 1;
    final firstVisitPrev = !_everVisited[prev];
    setState(() {
      _currentScreen = prev;
      _everVisited[prev] = true;
      _isPaused = false;
    });
    _createProgressControllerForCurrentScreen();
    _fadeController.value = 1.0;
    _applyRestoredProgressForScreen(prev, firstVisitPrev);
    _wrappedNavLog('goToPrevious DONE screen=$_currentScreen');
  }

  double _chromeIconRowTop(BuildContext context) {
    final pad = MediaQuery.of(context).padding.top;
    final barH = (_totalScreens * 4) + ((_totalScreens - 1) * 2);
    return pad + barH + 4;
  }

  /// Debajo de la fila de iconos; las franjas laterales empiezan aquí.
  double _navStripTop(BuildContext context) {
    return _chromeIconRowTop(context) + 56;
  }

  double _navStripWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return math.max(72.0, math.min(120.0, w * 0.30));
  }

  void _onNavLeftStripTap() {
    final bar = _progressController?.value ?? 0.0;
    _wrappedNavLog(
      'LEFT onTap screen=$_currentScreen bar=$bar paused=$_isPaused',
    );
    if (_currentScreen > 0) {
      _goToPreviousScreen();
      return;
    }
    // Primera pantalla: la franja izquierda no hace nada (no reinicia barra ni animaciones).
    _wrappedNavLog('LEFT on first screen: no-op bar=$bar');
  }

  void _onNavRightStripTap() {
    _wrappedNavLog('RIGHT onTap screen=$_currentScreen');
    _goToNextScreen();
  }

  void _onLeftStripPointerDown(PointerDownEvent e) {
    _wrappedNavLog(
      'LEFT PointerDown local=${e.localPosition} global=${e.position} '
      'screen=$_currentScreen',
    );
  }

  @override
  void dispose() {
    _progressController?.removeListener(_onGroupProgressClamp);
    _progressController?.removeStatusListener(_onProgressStatusChanged);
    _progressController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _wrappedPage(int index) {
    final data = widget.data;
    if (_isGroupChat) {
      switch (index) {
        case 0:
          return WrappedGroupFirstScreen(
            key: _groupFirstScreenKey,
            data: data,
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 1:
          return WrappedGroupSecondScreen(
            data: data,
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 2:
          return WrappedGroupThirdScreen(
            data: data,
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 3:
          return WrappedGroupFourthScreen(
            data: data,
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 4:
          return WrappedGroupFifthScreen(
            data: data,
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 5:
          return WrappedGroupSixthScreen(
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 6:
          return WrappedGroupSeventhScreen(
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 7:
          return WrappedGroupEighthScreen(
            totalScreens: _totalScreens,
            onGroupScreenAnimationsComplete: _onGroupScreenAnimationsComplete,
          );
        case 8:
          return WrappedGroupNinthScreen(
            totalScreens: _totalScreens,
            onGoHome: widget.onClose,
          );
        default:
          return WrappedPlaceholderScreen(
            screenNumber: index,
            totalScreens: _totalScreens,
            title: null,
          );
      }
    }

    switch (index) {
      case 0:
        return WrappedFirstScreen(
          key: _firstScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 1:
        return WrappedSecondScreen(
          key: _secondScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 2:
        return WrappedThirdScreen(
          key: _thirdScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 3:
        return WrappedFifthScreen(
          key: _fifthScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 4:
        return WrappedSixthScreen(
          key: _sixthScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 5:
        return WrappedSeventhScreen(
          key: _seventhScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 6:
        return WrappedEighthScreen(
          key: _eighthScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 7:
        return WrappedWordsScreen(
          key: _wordsScreenKey,
          data: data,
          totalScreens: _totalScreens,
        );
      case 8:
        return WrappedFinalScreen(
          totalScreens: _totalScreens,
          onGoHome: widget.onClose,
        );
      default:
        return WrappedPlaceholderScreen(
          screenNumber: index,
          totalScreens: _totalScreens,
          title: null,
        );
    }
  }

  Widget _buildScreenStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (int i = 0; i < _totalScreens; i++)
          if (_everVisited[i])
            Offstage(
              offstage: i != _currentScreen,
              child: TickerMode(
                enabled: i == _currentScreen,
                child: _wrappedPage(i),
              ),
            ),
      ],
    );
  }

  /// Solo esta zona escucha el tick del [AnimationController]; evita `setState` global
  /// en cada frame (eso recreaba el `Stack` y rompía los gestos de las franjas laterales).
  Widget _buildProgressBarArea(BuildContext context) {
    final c = _progressController;
    final padTop = MediaQuery.of(context).padding.top;
    final barContainerH =
        padTop + (_totalScreens * 4) + ((_totalScreens - 1) * 2);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: barContainerH,
        padding: EdgeInsets.only(
          top: padTop + 2,
          left: 2,
          right: 2,
        ),
        child: c == null
            ? const SizedBox.shrink()
            : AnimatedBuilder(
                animation: c,
                builder: (context, _) {
                  final p = c.value;
                  return Row(
                    children: List.generate(_totalScreens, (index) {
                      final isCurrent = index == _currentScreen;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < _totalScreens - 1 ? 2 : 0,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: index < _currentScreen
                                    ? 1.0
                                    : isCurrent
                                        ? p
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
                        ),
                      );
                    }),
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stripTop = _navStripTop(context);
    final stripW = _navStripWidth(context);
    final bottomPad = MediaQuery.of(context).padding.bottom + 36;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: (_) => _pauseAnimation(),
      onLongPressEnd: (_) {}, // Mantener pulsado = pausa y queda pausado (como el botón)
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
          fit: StackFit.expand,
          children: [
            _buildProgressBarArea(context),
            _buildScreenStack(),
            Positioned(
              left: 0,
              top: stripTop,
              bottom: bottomPad,
              width: stripW,
              child: Listener(
                behavior: HitTestBehavior.deferToChild,
                onPointerDown: _onLeftStripPointerDown,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onNavLeftStripTap,
                  onLongPressStart: (_) => _pauseAnimation(),
                  child: const ColoredBox(color: Color(0x00000000)),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: stripTop,
              bottom: bottomPad,
              width: stripW,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onNavRightStripTap,
                onLongPressStart: (_) => _pauseAnimation(),
                child: const ColoredBox(color: Color(0x00000000)),
              ),
            ),
            if (_currentScreen != 8)
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
              left: 16,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(
                        'Compartir todavía no está disponible',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cerrar', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  );
                },
                iconSize: 22,
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  (_totalScreens * 4) +
                  ((_totalScreens - 1) * 2) +
                  4,
              right: 16,
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
          ],
        ),
      ),
    );
  }
}
