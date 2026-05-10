import 'chat_line_regexes.dart';

/// Cabecera parseada de una línea de mensaje (fecha, hora, autor, texto).
class ParsedMessageHeader {
  final String isoDate; // YYYY-MM-DD
  final String year;
  final int hour;
  final int minute;
  final int second;
  final String user;
  final String text;

  ParsedMessageHeader({
    required this.isoDate,
    required this.year,
    required this.hour,
    required this.minute,
    required this.second,
    required this.user,
    required this.text,
  });
}

ParsedMessageHeader? parseMessageHeader(String line) {
  ParsedMessageHeader? tryRegex(RegExp regex) {
    final m = regex.firstMatch(line);
    if (m == null) return null;

    final dayStr = m.group(1)!;
    final monthStr = m.group(2)!;
    final yearStrRaw = m.group(3)!;
    final hourStr = m.group(4)!;
    final minuteStr = m.group(5)!;
    final secondStr = m.group(6) ?? '0';
    final user = (m.group(7) ?? '').trim();
    final text = (m.group(8) ?? '');

    final year = yearStrRaw.length == 2 ? '20$yearStrRaw' : yearStrRaw;
    final month = monthStr.padLeft(2, '0');
    final day = dayStr.padLeft(2, '0');
    final isoDate = '$year-$month-$day';
    final hour = int.parse(hourStr);
    final minute = int.parse(minuteStr);
    final second = int.parse(secondStr);

    return ParsedMessageHeader(
      isoDate: isoDate,
      year: year,
      hour: hour,
      minute: minute,
      second: second,
      user: user,
      text: text,
    );
  }

  return tryRegex(ChatLineRegexes.iosLineRegex) ??
      tryRegex(ChatLineRegexes.androidLineRegex);
}
