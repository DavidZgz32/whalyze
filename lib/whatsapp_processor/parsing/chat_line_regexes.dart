/// Patrones de línea Android / iOS del export (independientes del idioma del chat).
abstract final class ChatLineRegexes {
  static final androidLineRegex = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{2,4}),\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s[-–]\s([^:]+):\s?([\s\S]*)$',
    unicode: true,
  );

  static final iosLineRegex = RegExp(
    r'^\[(\d{1,2})/(\d{1,2})/(\d{2,4}),\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\]\s([^:]+):\s?([\s\S]*)$',
    unicode: true,
  );
}
