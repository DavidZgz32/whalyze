import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Mensaje asociado a cada emoji para el resumen final.
String _messageForEmoji(String emoji) {
  const map = {
    // Risa
    '😂': 'se ríe mucho',
    '🤣': 'se ríe mucho',
    '😆': 'se ríe mucho',
    '😅': 'se ríe mucho',
    '😹': 'se ríe mucho',
    '😄': 'se ríe mucho',
    '🥲': 'llora mucho',
    '🙃': 'se ríe del revés',
    // Gatos
    '🐱': 'le encantan los gatos',
    '😺': 'le encantan los gatos',
    '😸': 'le encantan los gatos',
    '🐈': 'le encantan los gatos',
    '😻': 'le encantan los gatos',
    '😽': 'le encantan los gatos',
    // Amor / corazones
    '❤️': 'es muy amoroso/a',
    '🥰': 'es muy amoroso/a',
    '😍': 'es muy amoroso/a',
    '💕': 'es muy amoroso/a',
    '😘': 'es muy amoroso/a',
    '💖': 'es muy amoroso/a',
    '💗': 'es muy amoroso/a',
    '💓': 'es muy amoroso/a',
    '💞': 'es muy amoroso/a',
    '💘': 'es muy amoroso/a',
    '💝': 'es muy amoroso/a',
    '❤': 'es muy amoroso/a',
    '🧡': 'es muy amoroso/a',
    '💛': 'es muy amoroso/a',
    '💚': 'es muy amoroso/a',
    '💙': 'es muy amoroso/a',
    '💜': 'es muy amoroso/a',
    '🖤': 'es muy amoroso/a',
    '🤍': 'es muy amoroso/a',
    '🤎': 'es muy amoroso/a',
    // Tristeza / sentimental
    '😢': 'es bastante sentimental',
    '😭': 'es bastante sentimental',
    '😿': 'es bastante sentimental',
    '💔': 'ha pasado por algo',
    '🥺': 'tiene un corazón sensible',
    '😥': 'se emociona fácil',
    // Fuego / molón
    '🔥': 'le gusta lo que mola',
    '✨': 'brilla con luz propia',
    '⭐': 'brilla con luz propia',
    '🌟': 'brilla con luz propia',
    // Pulgares
    '👍': 'da el visto bueno a todo',
    '👎': 'no se corta al discrepar',
    '👍🏻': 'da el visto bueno a todo',
    '👎🏻': 'no se corta al discrepar',
    // Sorprendido
    '😮': 'se sorprende fácil',
    '😲': 'se sorprende fácil',
    '🤯': 'se sorprende fácil',
    '😱': 'se asusta con todo',
    '🙀': 'se asusta con todo',
    // Pensativo
    '🤔': 'se pasa el día pensando',
    '💭': 'se pasa el día pensando',
    // Besos
    '💋': 'es de los que mandan besos',
    // Ok / mano
    '👌': 'todo le parece bien',
    '👌🏻': 'todo le parece bien',
    // Vergüenza / manos
    '🤭': 'le da vergüenza todo',
    '🙈': 'le da vergüenza todo',
    '🙉': 'no quiere enterarse',
    '🙊': 'prefiere no hablar',
    // Celebración
    '🎉': 'le gusta celebrar',
    '🥳': 'le gusta celebrar',
    '🎊': 'le gusta celebrar',
    '🎈': 'le gusta celebrar',
    // Flores
    '🌸': 'le gustan las flores',
    '🌷': 'le gustan las flores',
    '💐': 'le gustan las flores',
    '🌹': 'le gustan las flores',
    '🌺': 'le gustan las flores',
    '🌻': 'le gustan las flores',
    // Deportes
    '⚽': 'es muy deportista',
    '🏀': 'es muy deportista',
    '🎾': 'es muy deportista',
    '🏐': 'es muy deportista',
    '🎱': 'le gusta el billar',
    '🏈': 'es muy deportista',
    '⚾': 'es muy deportista',
    // Comida y bebida
    '🍕': 'le gusta comer bien',
    '🍔': 'le gusta comer bien',
    '🍟': 'le gusta comer bien',
    '☕': 'necesita café para vivir',
    '🍺': 'le gusta una birra',
    '🍻': 'le gusta brindar',
    '🥤': 'es de los que piden refresco',
    '🍰': 'tiene un dulce',
    '🍫': 'no puede con el chocolate',
    '🍿': 'le gusta el cine',
    '🌮': 'le gusta comer bien',
    '🍣': 'le gusta el sushi',
    '🥗': 'cuida lo que come',
    // Música
    '🎵': 'la música le va',
    '🎶': 'la música le va',
    '🎸': 'la música le va',
    '🎤': 'le gusta cantar',
    '🎧': 'vive con los cascos puestos',
    '🎼': 'la música le va',
    '🎹': 'la música le va',
    '🥁': 'la música le va',
    // Luna / noche
    '🌙': 'es más de noche',
    '🌜': 'es más de noche',
    '🌛': 'es más de noche',
    // Sol / día
    '☀️': 'es de los que madrugan',
    '🌞': 'es de los que madrugan',
    '☀': 'es de los que madrugan',
    // Caras
    '😇': 'se hace el inocente',
    '😈': 'tiene su lado travieso',
    '😴': 'se pasa el día durmiendo',
    '💤': 'se pasa el día durmiendo',
    '🥱': 'está siempre cansado/a',
    '😤': 'se enfada con facilidad',
    '😠': 'se enfada con facilidad',
    '😡': 'se enfada con facilidad',
    '🤷': 'se lo toma con filosofía',
    '🤷‍♂️': 'se lo toma con filosofía',
    '🤷‍♀️': 'se lo toma con filosofía',
    '🤷🏻': 'se lo toma con filosofía',
    '🤷🏻‍♂️': 'se lo toma con filosofía',
    '🤷🏻‍♀️': 'se lo toma con filosofía',
    // Otros comunes
    '👏': 'aprueba con las manos',
    '👏🏻': 'aprueba con las manos',
    '🙌': 'celebra en grande',
    '🙌🏻': 'celebra en grande',
    '🤝': 'es de dar la mano',
    '💪': 'se motiva mucho',
    '💪🏻': 'se motiva mucho',
    '😎': 'va de fresco/a',
    '🥸': 'va de incógnito',
    '🤓': 'es un poco friki',
    '😏': 'tiene una sonrisa pícara',
    '🫠': 'se derrite con el calor',
    '😬': 'se pone en plan incómodo',
    '🤐': 'prefiere no decir nada',
    '😐': 'es de cara seria',
    '😑': 'no dice ni mu',
    '💀': 'se muere de risa',
    '☠️': 'va de dramático/a',
    '👻': 'le gusta el misterio',
    '🤖': 'es muy tecnológico/a',
    '👽': 'es de otro planeta',
    '🦋': 'le gustan las mariposas',
    '🐶': 'le encantan los perros',
    '🐕': 'le encantan los perros',
    '🐻': 'le encantan los osos',
    '🐼': 'le encantan los pandas',
    '🦊': 'le encantan los zorros',
    '🐰': 'le encantan los conejos',
    '🐹': 'le encantan los hamsters',
    '🐸': 'le gustan las ranas',
    '🦉': 'es más de noche',
    '🐵': 'le gustan los monos',
    '🐒': 'le gustan los monos',
    '🦍': 'le gustan los gorilas',
    '🦄': 'cree en la magia',
    '🌍': 'le preocupa el planeta',
    '🌎': 'le preocupa el planeta',
    '🌏': 'le preocupa el planeta',
    '💩': 'tiene sentido del humor',
    '🤡': 'tiene sentido del humor',
    '🫶': 'es muy cariñoso/a',
    '🫶🏻': 'es muy cariñoso/a',
    '🫀': 'da el corazón',
    '👀': 'está siempre atento/a',
    '🫦': 'es de los que muerden',
    '😮‍💨': 'suelta el suspiro',
    '😪': 'está siempre cansado/a',
    '🤤': 'se le hace la boca agua',
    '😋': 'se le hace la boca agua',
    '🥴': 'va un poco mareado/a',
    '😵': 'va un poco mareado/a',
    '🤢': 'se marea fácil',
    '🤮': 'se marea fácil',
    '🤒': 'se pone malo/a a menudo',
    '🤕': 'ha pasado por algo',
  };
  return map[emoji] ?? 'tiene un emoji favorito';
}

/// Pantalla 3 del wrapped (índice 2): Emojis más usados (chat 1 a 1).
class WrappedThirdScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedThirdScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedThirdScreen> createState() => WrappedThirdScreenState();
}

class WrappedThirdScreenState extends State<WrappedThirdScreen>
    with TickerProviderStateMixin {
  int _visibleLines = 0;
  Timer? _timer;
  static const int _delayMs = 1400; // 100ms menos entre cada línea
  static const double _baseFontSize = 36.0;
  static const double _fontSizeStep = 2.0; // cada fila baja 2px
  static const double _namesFontSize = 22.0;
  /// Altura de referencia para calcular escala (pantalla "estándar")
  static const double _referenceContentHeight = 460.0; // 7 filas + nombres

  late AnimationController _titleFadeController;
  late AnimationController _titlePositionController;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titlePositionAnimation;
  List<AnimationController> _lineControllers = [];
  List<Animation<double>> _lineAnimations = [];

  static const int _maxEmojiRows = 7;

  int get _totalLines {
    final leftEmojis =
        widget.data.emojiStatsByParticipant[widget.data.participants[0]] ?? [];
    final rightEmojis = widget.data.participants.length > 1
        ? (widget.data.emojiStatsByParticipant[widget.data.participants[1]] ??
            [])
        : <EmojiStat>[];
    final rawMax = leftEmojis.length > rightEmojis.length
        ? leftEmojis.length
        : rightEmojis.length;
    final maxRows = rawMax > _maxEmojiRows ? _maxEmojiRows : rawMax;
    return 1 + maxRows;
  }

  /// True si el mensaje va con "a" (ej. "le encantan los gatos" → "y a David le encantan...").
  static bool _messageNeedsA(String msg) {
    final lower = msg.trim().toLowerCase();
    return lower.startsWith('le ') ||
        lower.startsWith('la ') ||
        lower.startsWith('lo ') ||
        lower.startsWith('les ');
  }

  /// Construye el mensaje final según el emoji más usado (y el segundo si ambos coinciden).
  String? _buildSummaryMessage(
    List<EmojiStat> leftEmojis,
    List<EmojiStat> rightEmojis,
    String leftName,
    String rightName,
  ) {
    if (leftEmojis.isEmpty) return null;
    final leftMsg = _messageForEmoji(leftEmojis[0].emoji);
    final leftMsg2 =
        leftEmojis.length > 1 ? _messageForEmoji(leftEmojis[1].emoji) : leftMsg;

    if (rightName.isEmpty) {
      return 'Parece que $leftName $leftMsg.';
    }

    if (rightEmojis.isEmpty) {
      return 'Parece que $leftName $leftMsg.';
    }

    final rightMsg = _messageForEmoji(rightEmojis[0].emoji);
    final rightMsg2 = rightEmojis.length > 1
        ? _messageForEmoji(rightEmojis[1].emoji)
        : rightMsg;

    String msgLeft = leftMsg;
    String msgRight = rightMsg;

    if (leftMsg == rightMsg) {
      msgLeft = leftMsg2;
      msgRight = rightMsg;
      if (msgLeft == msgRight) {
        msgRight = rightMsg2;
      }
    }

    final String secondPart = _messageNeedsA(msgRight)
        ? 'y a $rightName $msgRight'
        : 'y $rightName $msgRight';
    return 'Parece que $leftName $msgLeft $secondPart.';
  }

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

    final totalLines = _totalLines;
    for (var i = 0; i < totalLines; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _lineControllers.add(c);
      _lineAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOut),
        ),
      );
    }

    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _titlePositionController.forward().then((_) {
          if (!mounted) return;
          Future.delayed(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            _startLineAnimation();
          });
        });
      });
    });
  }

  void _startLineAnimation() {
    _visibleLines = 0;
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _visibleLines = 1;
        if (_lineControllers.isNotEmpty) _lineControllers[0].forward();
      });
    });
    _startLineTimer();
  }

  void _startLineTimer() {
    final totalLines = _totalLines;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: _delayMs), (_) {
      if (!mounted) return;
      setState(() {
        if (_visibleLines < totalLines) {
          _visibleLines++;
          if (_visibleLines - 1 < _lineControllers.length) {
            _lineControllers[_visibleLines - 1].forward();
          }
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void pauseAnimations() {
    _timer?.cancel();
    _timer = null;
    _titleFadeController.stop(canceled: false);
    _titlePositionController.stop(canceled: false);
    for (final c in _lineControllers) {
      c.stop(canceled: false);
    }
  }

  void resumeAnimations() {
    if (_titleFadeController.value < 1.0) _titleFadeController.forward();
    if (_titlePositionController.value < 1.0) _titlePositionController.forward();
    for (var i = 0; i < _lineControllers.length; i++) {
      final c = _lineControllers[i];
      if (c.value > 0 && c.value < 1) c.forward();
    }
    if (_visibleLines < _totalLines) _startLineTimer();
  }

  void resetAnimations() {
    _timer?.cancel();
    _timer = null;
    _titleFadeController.reset();
    _titlePositionController.reset();
    for (final c in _lineControllers) c.reset();
    if (mounted) setState(() => _visibleLines = 0);
    _titleFadeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _titlePositionController.forward().then((_) {
          if (!mounted) return;
          Future.delayed(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            _startLineAnimation();
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleFadeController.dispose();
    _titlePositionController.dispose();
    for (final c in _lineControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participants = widget.data.participants;
    final leftName = participants.isNotEmpty ? participants[0] : '';
    final rightName = participants.length > 1 ? participants[1] : '';
    final leftEmojis =
        widget.data.emojiStatsByParticipant[leftName] ?? <EmojiStat>[];
    final rightEmojis =
        widget.data.emojiStatsByParticipant[rightName] ?? <EmojiStat>[];
    final leftDisplay = leftEmojis.take(_maxEmojiRows).toList();
    final rightDisplay = rightEmojis.take(_maxEmojiRows).toList();
    final maxRows = leftDisplay.length >= rightDisplay.length
        ? leftDisplay.length
        : rightDisplay.length;

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
    final horizontalPadding = 32.0;

    // Altura disponible para el contenido (debajo del título); algo más arriba para que no se corte
    const contentTopOffset = 78.0;
    final availableHeight =
        screenHeight - topPadding - contentTopOffset - bottomPadding;
    // Factor de escala para que todo quepa: mismo aspecto en todas las pantallas
    final scale = (availableHeight / _referenceContentHeight)
        .clamp(0.65, 1.0);

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
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
                    'Emojis más usados',
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
          Positioned(
            top: topPadding + contentTopOffset,
            bottom: bottomPadding,
            left: horizontalPadding,
            right: horizontalPadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_visibleLines >= 1 && _lineAnimations.isNotEmpty)
                    FadeTransition(
                      opacity: _lineAnimations[0],
                      child: _buildNamesRow(
                          leftName, rightName, _namesFontSize * scale),
                    ),
                  ...List.generate(maxRows, (index) {
                    final lineIndex = 2 + index;
                    if (_visibleLines < lineIndex)
                      return const SizedBox.shrink();
                    final fontSize =
                        (_baseFontSize - (index * _fontSizeStep)) * scale;
                    final leftStat =
                        index < leftDisplay.length ? leftDisplay[index] : null;
                    final rightStat =
                        index < rightDisplay.length ? rightDisplay[index] : null;
                    final animIndex = 1 + index;
                    final opacity = animIndex < _lineAnimations.length
                        ? _lineAnimations[animIndex]
                        : null;
                    final row = Padding(
                      padding: EdgeInsets.only(top: 14 * scale),
                      child: _buildEmojiRow(
                        leftStat,
                        rightStat,
                        fontSize,
                      ),
                    );
                    if (opacity != null) {
                      return FadeTransition(opacity: opacity, child: row);
                    }
                    return row;
                  }),
                  if (_visibleLines >= _totalLines) ...[
                    Builder(
                      builder: (context) {
                        final msg = _buildSummaryMessage(
                          leftDisplay,
                          rightDisplay,
                          leftName,
                          rightName,
                        );
                        if (msg == null || msg.isEmpty)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(top: 28 * scale),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamesRow(String leftName, String rightName, double fontSize) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              leftName,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Center(
            child: Text(
              rightName,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiRow(EmojiStat? left, EmojiStat? right, double fontSize) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              left != null ? '${left.emoji}  ${left.count}' : '',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Center(
            child: Text(
              right != null ? '${right.emoji}  ${right.count}' : '',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
