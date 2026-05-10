import '../locale/export_phrase_catalog.dart';
import 'emoji_modifier_stripper.dart';

/// Acumula conteos de palabras y emojis por mensaje (mutación de mapas compartidos).
class WordEmojiStatsTracker {
  WordEmojiStatsTracker({
    required this.emojiStatsByParticipant,
    required this.emojiTotalByParticipant,
    required this.participantWordTotals,
    required this.wordStats,
    required this.wordStatsByParticipant,
    required this.uniqueWords,
  });

  final Map<String, Map<String, int>> emojiStatsByParticipant;
  final Map<String, int> emojiTotalByParticipant;
  final Map<String, int> participantWordTotals;
  final Map<String, Map<String, int>> wordStats;
  final Map<String, Map<String, Map<String, int>>> wordStatsByParticipant;
  final Set<String> uniqueWords;

  static final _urlStrip = RegExp(r'(?:https?://|www\.)[^\s]*', caseSensitive: false);
  static final _emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F018}-\u{1F270}]|[\u{238C}-\u{2454}]|[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F100}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]|[\u{1F910}-\u{1F96B}]|[\u{1F980}-\u{1F9E0}]',
    unicode: true,
  );
  static final _emojiNoise = RegExp(r'[\u2640\u2642\u26A7\u200D\uFE0F]', unicode: true);
  static final _nonWordChars = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _whitespace = RegExp(r'\s+');

  void processWords(String text, String participant) {
    final sanitized = EmojiModifierStripper.stripOrphanEmojiModifiers(text);

    final withoutUrls = sanitized.replaceAll(_urlStrip, ' ');

    final emojis = _emojiRegex.allMatches(sanitized).map((m) => m.group(0)!).toList();
    final cleanedEmojis =
        emojis.where((e) => !_emojiNoise.hasMatch(e)).toList();

    emojiStatsByParticipant.putIfAbsent(participant, () => <String, int>{});
    final participantEmojis = emojiStatsByParticipant[participant]!;

    emojiTotalByParticipant[participant] =
        (emojiTotalByParticipant[participant] ?? 0) + cleanedEmojis.length;

    for (final emoji in cleanedEmojis) {
      participantEmojis[emoji] = (participantEmojis[emoji] ?? 0) + 1;
    }

    final words = withoutUrls
        .toLowerCase()
        .replaceAll(_nonWordChars, ' ')
        .split(_whitespace)
        .where((word) => word.isNotEmpty)
        .where((word) => !ExportPhraseCatalog.tokenStoplistLowercase.contains(word))
        .toList();

    participantWordTotals[participant] =
        (participantWordTotals[participant] ?? 0) + words.length;

    for (final word in words) {
      final len = word.length;
      if (len >= 3 && len <= 11) {
        final key = '${len}_letters';
        wordStats.putIfAbsent(key, () => <String, int>{});
        final map = wordStats[key]!;
        map[word] = (map[word] ?? 0) + 1;
        uniqueWords.add(word);
      }
      if (len >= 4 && len <= 14) {
        final key = '${len}_letters';
        wordStatsByParticipant.putIfAbsent(participant, () => <String, Map<String, int>>{});
        final byParticipant = wordStatsByParticipant[participant]!;
        byParticipant.putIfAbsent(key, () => <String, int>{});
        final map = byParticipant[key]!;
        map[word] = (map[word] ?? 0) + 1;
      }
    }
  }
}
