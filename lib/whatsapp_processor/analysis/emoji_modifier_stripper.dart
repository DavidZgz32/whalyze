/// Quita modificadores de emoji huérfanos (piel, género sin base válida).
abstract final class EmojiModifierStripper {
  static final _skinTones = RegExp(r'[\u{1F3FB}-\u{1F3FF}]', unicode: true);
  static const _genderRe = r'[\u2640\u2642\u26A7]';
  static const _zwj = '\u200D';
  static const _vs16 = '\uFE0F';
  static final _emojiBaseRe = RegExp(
    r'[\u{1F300}-\u{1F6FF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F600}-\u{1F64F}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F910}-\u{1F96B}]|[\u{1F980}-\u{1F9E0}]',
    unicode: true,
  );
  static final _genderChecker = RegExp(_genderRe);

  static String stripOrphanEmojiModifiers(String input) {
    final withoutSkinTones = input.replaceAll(_skinTones, '');

    bool isGender(String ch) => _genderChecker.hasMatch(ch);
    bool isEmojiBase(String ch) {
      if (!_emojiBaseRe.hasMatch(ch)) return false;
      if (isGender(ch)) return false;
      if (ch == _zwj || ch == _vs16) return false;
      return true;
    }

    final chars = withoutSkinTones.split('');
    final out = <String>[];

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];

      if (isGender(ch)) {
        final prev1 = out.isNotEmpty ? out[out.length - 1] : '';
        final prev2 = out.length > 1 ? out[out.length - 2] : '';
        final prev3 = out.length > 2 ? out[out.length - 3] : '';
        final valid = (prev1 == _zwj && isEmojiBase(prev2)) ||
            (prev1 == _zwj && prev2 == _vs16 && isEmojiBase(prev3));
        if (valid) {
          out.add(ch);
        }
        continue;
      }

      out.add(ch);
    }

    return out.join('');
  }
}
