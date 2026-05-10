import 'parsed_header.dart';

/// Extrae el nombre del participante en mensajes de sistema «salió del grupo».
abstract final class GroupLeaveLineParser {
  static final _androidSystemLeave = RegExp(
    r'^\d{1,2}/\d{1,2}/\d{2,4},\s+\d{1,2}:\d{2}(?::\d{2})?\s[-–]\s([^:]+?)\s+(?:salió del grupo|left the group)',
    caseSensitive: false,
  );

  static final _iosSystemLeave = RegExp(
    r'^\[\d{1,2}/\d{1,2}/\d{2,4},\s+\d{1,2}:\d{2}(?::\d{2})?\]\s([^:]+?)\s+(?:salió del grupo|left the group)',
    caseSensitive: false,
  );

  static final _nameCleanup = RegExp(r'[‎~]');

  /// Si [trimmedLine] es mensaje de sistema de salida, devuelve el nombre limpio.
  static String? tryParseLeftParticipantName(String trimmedLine) {
    if (parseMessageHeader(trimmedLine) != null) return null;

    final nameMatch = _androidSystemLeave.firstMatch(trimmedLine) ??
        _iosSystemLeave.firstMatch(trimmedLine);

    if (nameMatch == null) return null;
    return nameMatch.group(1)!.replaceAll(_nameCleanup, '').trim();
  }
}
