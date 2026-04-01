import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Textos y estilos compartidos entre la pantalla 1 individual y la grupal
/// ("todo empezó…", "Desde entonces…", "En este periodo…").
abstract final class WrappedIntroShared {
  WrappedIntroShared._();

  static String truncateAtWordBoundary(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    int endIndex = maxLen;
    if (endIndex < text.length &&
        text[endIndex] != ' ' &&
        (endIndex > 0 && text[endIndex - 1] != ' ')) {
      final nextSpace = text.indexOf(' ', endIndex);
      endIndex = nextSpace == -1 ? text.length : nextSpace;
    }
    return '${text.substring(0, endIndex)}...';
  }

  static String formatThousands(int number) {
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

  static const List<String> _monthNames = [
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
    'diciembre',
  ];

  /// Frase tipo "el 4 de abril de 2026" a partir de [isoDate] `YYYY-MM-DD`.
  static String firstDayPhrase(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return 'el ${date.day} de ${_monthNames[date.month - 1]} de ${date.year}';
    } catch (_) {
      return '';
    }
  }

  static int daysSinceFirstMessage(String? isoDate) {
    if (isoDate == null) return 0;
    try {
      final firstDate = DateTime.parse(isoDate);
      return DateTime.now().difference(firstDate).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Misma lógica que la pantalla 1 individual (mensaje curioso según días).
  static String? randomPeriodMessage(int daysSinceStart) {
    if (daysSinceStart <= 0) return null;
    final random = DateTime.now().millisecondsSinceEpoch % 3;
    if (random == 0) {
      final heartbeats = formatThousands(100800 * daysSinceStart);
      return 'Tiempo suficiente para que vuestro corazón haya latido más de $heartbeats veces.';
    }
    if (random == 1) {
      final tiktokVideos = formatThousands(34000000 * daysSinceStart);
      return 'Durante este tiempo se han publicado más de $tiktokVideos vídeos en TikTok.';
    }
    final births = formatThousands(385000 * daysSinceStart);
    return 'En este tiempo han nacido $births bebés en el mundo';
  }

  static TextStyle welcomeTitleStyle() => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle firstMessageBlockStyle() => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.9),
        fontStyle: FontStyle.italic,
      );

  static TextStyle daysSinceBlockStyle() => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.9),
      );

  static TextStyle periodFactBlockStyle() => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.85),
      );

  /// Nombre del grupo encima de las bolitas (pantalla 1 grupal).
  static TextStyle groupNameLabelStyle() => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.95),
        height: 1.25,
      );
}
