class EmojiStat {
  final String emoji;
  final int count;

  EmojiStat({required this.emoji, required this.count});

  Map<String, dynamic> toJson() => {'emoji': emoji, 'count': count};

  factory EmojiStat.fromJson(Map<String, dynamic> json) =>
      EmojiStat(emoji: json['emoji'] as String, count: json['count'] as int);
}
