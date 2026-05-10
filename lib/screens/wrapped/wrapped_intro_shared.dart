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

  /// Contador para rankings: &lt;10k con puntos de miles; desde 10k en formato `10k`, `10.5k`, `125k`.
  static String formatMessageCountForRank(int count) {
    if (count < 10000) {
      return formatThousands(count);
    }
    final whole = count ~/ 1000;
    final rem = count % 1000;
    if (rem == 0) {
      return '${whole}k';
    }
    final k = count / 1000.0;
    final oneDec = (k * 10).round() / 10;
    if ((oneDec * 1000).round() == count) {
      if ((oneDec - oneDec.truncateToDouble()).abs() < 0.001) {
        return '${oneDec.toInt()}k';
      }
      return '${oneDec.toStringAsFixed(1)}k';
    }
    return '${whole}k';
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

  /// Contexto de época según el año del primer mensaje (grupo). Antes de 2010 → texto de 2010; desde 2027 → 2026.
  static String? cultureLineForFirstMessageYear(String? isoDate) {
    if (isoDate == null) return null;
    int year;
    try {
      year = DateTime.parse(isoDate).year;
    } catch (_) {
      return null;
    }
    if (year >= 2027) year = 2026;
    if (year < 2010) year = 2010;

    switch (year) {
      case 2026:
        return 'Cuando mandaste ese primer mensaje, todavía había gente diciendo "búscalo en Google" en vez de preguntarle a una IA.';
      case 2025:
        return 'Este grupo comenzó antes de que la IA estuviera en literalmente todas partes.';
      case 2024:
        return 'Cuando empezó este chat, Twitter todavía se llamaba Twitter hacía muy poco.';
      case 2023:
        return 'Este grupo comenzó antes del boom mundial de la IA generativa.';
      case 2022:
        return 'Cuando empezó este chat, ChatGPT todavía no existía.';
      case 2021:
        return 'Este grupo nació cuando aún llevábamos mascarillas a todas partes.';
      case 2020:
        return 'Este chat empezó en plena pandemia mundial.';
      case 2019:
        return 'Este grupo nació antes de que el mundo se parara por el COVID.';
      case 2018:
        return 'Cuando empezó este grupo, TikTok todavía no dominaba internet.';
      case 2017:
        return 'Este grupo comenzó cuando la gente seguía usando filtros de Snapchat.';
      case 2016:
        return 'Cuando nació este chat, Pokémon GO estaba revolucionando el mundo.';
      case 2015:
        return 'Este grupo nació cuando los selfies con palo inundaban todas las vacaciones.';
      case 2014:
        return 'Este chat nació cuando los audios de WhatsApp daban vergüenza.';
      case 2013:
        return 'Cuando empezó este grupo, Spotify aún no era lo normal en los coches.';
      case 2012:
        return 'Este grupo nació cuando Gangnam Style estaba en todas partes.';
      case 2011:
        return 'Este chat comenzó cuando WhatsApp aún costaba dinero en algunos móviles.';
      case 2010:
        return 'Este grupo empezó cuando Instagram acababa de nacer.';
      default:
        return 'Cuando mandaste ese primer mensaje, todavía había gente diciendo "búscalo en Google" en vez de preguntarle a una IA.';
    }
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

  static TextStyle yearCultureCaptionStyle() => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.82),
        height: 1.35,
      );

  /// Nombre del grupo encima de las bolitas (pantalla 1 grupal).
  static TextStyle groupNameLabelStyle() => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.95),
        height: 1.25,
      );
}
