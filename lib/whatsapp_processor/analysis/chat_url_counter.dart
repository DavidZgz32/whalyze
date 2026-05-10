/// Cuenta URLs en un texto: https?://, www., y dominios tipo marca.com
abstract final class ChatUrlCounter {
  static final _httpRe = RegExp(r'https?://[^\s<>"\x27]+', caseSensitive: false);
  static final _wwwRe = RegExp(r'www\.[^\s<>"\x27]+', caseSensitive: false);
  static final _domainRe = RegExp(
    r'\b[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.(?:[a-zA-Z]{2,})(?:\.[a-zA-Z]{2,})*\b',
  );

  static int countUrlsInText(String text) {
    if (text.isEmpty) return 0;
    var n = _httpRe.allMatches(text).length;
    final withoutHttp = text.replaceAll(_httpRe, ' ');
    n += _wwwRe.allMatches(withoutHttp).length;
    final withoutWww = withoutHttp.replaceAll(_wwwRe, ' ');
    n += _domainRe.allMatches(withoutWww).length;
    return n;
  }
}
