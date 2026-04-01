import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/participant_utils.dart';
import '../../whatsapp_processor.dart';
import 'wrapped_intro_shared.dart';

/// Pantalla 2 del Wrapped grupal: ranking de mensajes por participante (máx. 10).
class WrappedGroupSecondScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  /// Índice 1: fin de filas escalonadas + pie del carro (si hay).
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupSecondScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  /// Máximo 12 caracteres; si es más largo, se corta a 11 y se añade ".".
  static String shortParticipantName(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    if (t.length <= 12) return t;
    return '${t.substring(0, 11)}.';
  }

  /// Nombre corto para la frase del carro: `Laura S.` a partir de `Laura Sister...`.
  static String shortNameForCarriagePuller(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts[0];
      if (p.length <= 12) return p;
      return '${p.substring(0, 11)}.';
    }
    final first = parts[0];
    final second = parts[1];
    if (second.isEmpty) {
      return first.length <= 12 ? first : '${first.substring(0, 11)}.';
    }
    return '$first ${second[0].toUpperCase()}.';
  }

  @override
  State<WrappedGroupSecondScreen> createState() =>
      _WrappedGroupSecondScreenState();
}

class _WrappedGroupSecondScreenState extends State<WrappedGroupSecondScreen>
    with TickerProviderStateMixin {
  static const int _staggerMs = 1000;
  static const int _rowFadeMs = 400;

  late final List<MapEntry<String, int>> _top;
  late final int _maxVal;
  late final List<AnimationController> _rowControllers;
  late final List<Animation<double>> _rowOpacity;
  AnimationController? _footerController;
  Animation<double>? _footerOpacity;

  @override
  void initState() {
    super.initState();
    final entries = widget.data.participants
        .map((p) => MapEntry(p, widget.data.participantMessageCounts[p] ?? 0))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _top = entries.take(10).toList();
    _maxVal =
        _top.isEmpty ? 1 : _top.map((e) => e.value).reduce(math.max);

    _rowControllers = List.generate(
      _top.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _rowFadeMs),
      ),
    );
    _rowOpacity = _rowControllers
        .map(
          (c) => CurvedAnimation(parent: c, curve: Curves.easeOut),
        )
        .toList();

    for (var i = 0; i < _rowControllers.length; i++) {
      Future<void>.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (mounted) _rowControllers[i].forward();
      });
    }

    if (_top.isNotEmpty) {
      _footerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _rowFadeMs),
      );
      _footerOpacity = CurvedAnimation(
        parent: _footerController!,
        curve: Curves.easeOut,
      );
      Future<void>.delayed(
        Duration(milliseconds: _staggerMs * _top.length),
        () {
          if (mounted) _footerController?.forward();
        },
      );
    }

    final completeDelayMs = _top.isEmpty
        ? 0
        : (_footerController != null
            ? _staggerMs * _top.length + _rowFadeMs
            : _staggerMs * (_top.length - 1) + _rowFadeMs);
    if (completeDelayMs == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onGroupScreenAnimationsComplete?.call(1);
      });
    } else {
      Future<void>.delayed(Duration(milliseconds: completeDelayMs), () {
        if (mounted) widget.onGroupScreenAnimationsComplete?.call(1);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _rowControllers) {
      c.dispose();
    }
    _footerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: padTop + 12,
          left: 22,
          right: 22,
          bottom: MediaQuery.of(context).padding.bottom + 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Quién ha contribuido más?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < _top.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      FadeTransition(
                        opacity: _rowOpacity[i],
                        child: _RankRow(
                          name: _top[i].key,
                          count: _top[i].value,
                          maxCount: _maxVal,
                        ),
                      ),
                    ],
                    if (_footerOpacity != null) ...[
                      const SizedBox(height: 26),
                      FadeTransition(
                        opacity: _footerOpacity!,
                        child: Text(
                          '${WrappedGroupSecondScreen.shortNameForCarriagePuller(_top.first.key)} tirando del carro... 🐐',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
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

class _RankRow extends StatelessWidget {
  final String name;
  final int count;
  final int maxCount;

  const _RankRow({
    required this.name,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final participantColor = getParticipantColor(name);
    final ratio = maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            WrappedGroupSecondScreen.shortParticipantName(name),
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: participantColor,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SizedBox(
            height: 30,
            child: ClipRect(
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                color: participantColor,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          WrappedIntroShared.formatMessageCountForRank(count),
          textAlign: TextAlign.right,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
