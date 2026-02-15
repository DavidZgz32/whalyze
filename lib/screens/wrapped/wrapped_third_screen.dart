import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

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

class WrappedThirdScreenState extends State<WrappedThirdScreen> {
  int _visibleLines = 0;
  Timer? _timer;
  static const int _delaySeconds = 2;
  static const double _baseFontSize = 30.0;
  static const double _fontSizeStep = 3.0;

  @override
  void initState() {
    super.initState();
    _startLineAnimation();
  }

  void _startLineAnimation() {
    _visibleLines = 0;
    final leftEmojis =
        widget.data.emojiStatsByParticipant[widget.data.participants[0]] ?? [];
    final rightEmojis = widget.data.participants.length > 1
        ? (widget.data.emojiStatsByParticipant[widget.data.participants[1]] ??
            [])
        : <EmojiStat>[];
    final maxRows = leftEmojis.length > rightEmojis.length
        ? leftEmojis.length
        : rightEmojis.length;
    final totalLines = 1 + maxRows; // 1 fila de nombres + filas de emojis

    _timer?.cancel();
    // Primera línea (nombres) visible al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visibleLines = 1);
    });
    _timer = Timer.periodic(const Duration(seconds: _delaySeconds), (_) {
      if (!mounted) return;
      setState(() {
        if (_visibleLines < totalLines) {
          _visibleLines++;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final maxRows = leftEmojis.length > rightEmojis.length
        ? leftEmojis.length
        : rightEmojis.length;

    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
    final horizontalPadding = 32.0;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: bottomPadding,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Emojis más usados',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Fila de nombres (línea 1)
                    if (_visibleLines >= 1)
                      _buildNamesRow(leftName, rightName, _baseFontSize),
                    ...List.generate(maxRows, (index) {
                      final lineIndex = 2 + index;
                      if (_visibleLines < lineIndex)
                        return const SizedBox.shrink();
                      final fontSize = _baseFontSize - (index * _fontSizeStep);
                      final leftStat =
                          index < leftEmojis.length ? leftEmojis[index] : null;
                      final rightStat = index < rightEmojis.length
                          ? rightEmojis[index]
                          : null;
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildEmojiRow(
                          leftStat,
                          rightStat,
                          fontSize,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamesRow(String leftName, String rightName, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            leftName,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            rightName,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiRow(EmojiStat? left, EmojiStat? right, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            left != null ? '${left.emoji} ${left.count}' : '',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            right != null ? '${right.emoji} ${right.count}' : '',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
