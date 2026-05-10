import 'emoji_stat.dart';

/// Modelo completo de datos procesados de WhatsApp
class WhatsAppData {
  /// Convierte un mapa JSON (valores num/int) en `Map<String, int>` de forma tolerante.
  static Map<String, int> mapStringIntFromJson(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final out = <String, int>{};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is int) {
        out[e.key.toString()] = v;
      } else if (v is num) {
        out[e.key.toString()] = v.round();
      }
    }
    return out;
  }

  // Información básica
  final List<String> participants;
  final List<String> leftParticipants;
  final int totalParticipantsWhoLeft;

  /// Último nombre del grupo según la última línea del export del tipo
  /// `… cambió el nombre del grupo de "…" a "…"`.
  final String? groupNameFromExport;

  /// Número de líneas de cambio de nombre en el export (ES/EN).
  final int groupRenameCount;

  // Primer mensaje
  final String? firstMessageDate; // YYYY-MM-DD
  final String? firstMessageUser;
  final String? firstMessageText;

  // Estadísticas de mensajes por participante
  final Map<String, int> participantMessageCounts;
  final Map<String, int> timeRangeCounts; // Madrugada, Mañana, Tarde, Noche
  final List<List<int>> dayOfWeekTimeBandCounts; // 7x4 matrix
  final List<int> hourlyMessageCounts; // 24 horas
  final Map<String, int> dailyMessageCounts; // YYYY-MM-DD -> count
  final Map<String, int> monthlyMessageCounts; // YYYY-MM -> count

  // Día y mes más activos
  final String? dayWithMostMessages;
  final int dayWithMostMessagesCount;
  final String? monthWithMostMessages;
  final int monthWithMostMessagesCount;
  final int longestStreak; // Días consecutivos

  // Estadísticas de conversación
  final Map<String, int> conversationStarters;
  /// Tras ≥12 h sin mensajes, el siguiente autor suma 1 (p. ej. rol «Hola chic@s» grupal).
  final Map<String, int> conversationStartersAfter12h;

  /// «Último en salir»: autor del mensaje anterior a una pausa de ≥12 h.
  /// Regla: si hay al menos 12 h hasta el próximo mensaje, ese autor suma +1.
  final Map<String, int> lastWordsBeforeNextAfter12h;

  /// «Rompehielos»: el autor del mensaje que aparece tras una pausa de ≥2 días (48 h).
  final Map<String, int> breakIceStartersAfter2d;

  final Map<String, String> averageResponseTimes; // MM:SS o HH:MM:SS
  final Map<String, int> quickResponseCounts;

  /// Palabras tokenizadas (misma regla que `processWords`) por participante.
  final Map<String, int> participantWordTotals;
  /// Mensajes entre las 20:00 y las 06:00 (hora local del export), por participante.
  final Map<String, int> nightOwlMessageCounts;
  /// Mensajes entre las 06:00 y las 12:00 (hora local del export), por participante.
  final Map<String, int> earlyBirdMessageCounts;

  // Mensajes consecutivos
  final int mostConsecutiveMessages;
  final String? mostConsecutiveUser;
  final String? mostConsecutiveDate;

  // Estadísticas de emojis
  final Map<String, List<EmojiStat>> emojiStatsByParticipant;

  /// Total de emojis (iconos) por participante (suma de todos los emojis, no solo top 8).
  final Map<String, int> emojiTotalByParticipant;

  // Estadísticas de palabras
  final Map<String, Map<String, int>> wordStatsByYear; // "3_letters" -> {word: count}
  final int totalUniqueWords;
  /// Por participante: longitud (4..14) -> palabra más usada de esa longitud.
  final Map<String, Map<int, String>> topWordByLengthByParticipant;
  /// Una sola palabra por longitud (4..14), la más usada en todo el chat.
  final Map<int, String> topWordByLength;

  // Preguntas
  final int totalQuestions;

  /// Conteo de bloques de interrogantes por participante (según `countQuestions`).
  final Map<String, int> questionsByParticipant;

  // Estadísticas de multimedia
  final Map<String, int> deletedMessagesByParticipant;
  final Map<String, int> editedMessagesByParticipant;
  final Map<String, int> multimediaByParticipant;
  final Map<String, int> locationsByParticipant;
  final Map<String, int> contactsByParticipant;
  final Map<String, int> oneTimePhotosByParticipant;
  final Map<String, int> sharedUrlsByParticipant;

  WhatsAppData({
    required this.participants,
    required this.leftParticipants,
    required this.totalParticipantsWhoLeft,
    this.groupNameFromExport,
    this.groupRenameCount = 0,
    this.firstMessageDate,
    this.firstMessageUser,
    this.firstMessageText,
    required this.participantMessageCounts,
    required this.timeRangeCounts,
    required this.dayOfWeekTimeBandCounts,
    required this.hourlyMessageCounts,
    required this.dailyMessageCounts,
    required this.monthlyMessageCounts,
    this.dayWithMostMessages,
    required this.dayWithMostMessagesCount,
    this.monthWithMostMessages,
    required this.monthWithMostMessagesCount,
    required this.longestStreak,
    required this.conversationStarters,
    required this.conversationStartersAfter12h,
    required this.lastWordsBeforeNextAfter12h,
    required this.breakIceStartersAfter2d,
    required this.averageResponseTimes,
    required this.quickResponseCounts,
    required this.participantWordTotals,
    required this.nightOwlMessageCounts,
    required this.earlyBirdMessageCounts,
    required this.mostConsecutiveMessages,
    this.mostConsecutiveUser,
    this.mostConsecutiveDate,
    required this.emojiStatsByParticipant,
    required this.emojiTotalByParticipant,
    required this.wordStatsByYear,
    required this.totalUniqueWords,
    required this.topWordByLengthByParticipant,
    required this.topWordByLength,
    required this.totalQuestions,
    required this.questionsByParticipant,
    required this.deletedMessagesByParticipant,
    required this.editedMessagesByParticipant,
    required this.multimediaByParticipant,
    required this.locationsByParticipant,
    required this.contactsByParticipant,
    required this.oneTimePhotosByParticipant,
    required this.sharedUrlsByParticipant,
  });

  /// Convierte los datos a un JSON completo
  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'leftParticipants': leftParticipants,
      'totalParticipantsWhoLeft': totalParticipantsWhoLeft,
      'groupNameFromExport': groupNameFromExport,
      'groupRenameCount': groupRenameCount,
      'firstMessageDate': firstMessageDate,
      'firstMessageUser': firstMessageUser,
      'firstMessageText': firstMessageText,
      'participantMessageCounts': participantMessageCounts,
      'timeRangeCounts': timeRangeCounts,
      'dayOfWeekTimeBandCounts': dayOfWeekTimeBandCounts,
      'hourlyMessageCounts': hourlyMessageCounts,
      'dailyMessageCounts': dailyMessageCounts,
      'monthlyMessageCounts': monthlyMessageCounts,
      'dayWithMostMessages': dayWithMostMessages,
      'dayWithMostMessagesCount': dayWithMostMessagesCount,
      'monthWithMostMessages': monthWithMostMessages,
      'monthWithMostMessagesCount': monthWithMostMessagesCount,
      'longestStreak': longestStreak,
      'conversationStarters': conversationStarters,
      'conversationStartersAfter12h': conversationStartersAfter12h,
      'lastWordsBeforeNextAfter12h': lastWordsBeforeNextAfter12h,
      'breakIceStartersAfter2d': breakIceStartersAfter2d,
      'averageResponseTimes': averageResponseTimes,
      'quickResponseCounts': quickResponseCounts,
      'participantWordTotals': participantWordTotals,
      'nightOwlMessageCounts': nightOwlMessageCounts,
      'earlyBirdMessageCounts': earlyBirdMessageCounts,
      'mostConsecutiveMessages': mostConsecutiveMessages,
      'mostConsecutiveUser': mostConsecutiveUser,
      'mostConsecutiveDate': mostConsecutiveDate,
      'emojiStatsByParticipant': emojiStatsByParticipant.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'emojiTotalByParticipant': emojiTotalByParticipant,
      'wordStatsByYear': wordStatsByYear,
      'totalUniqueWords': totalUniqueWords,
      'topWordByLengthByParticipant': topWordByLengthByParticipant.map(
        (p, byLen) => MapEntry(p, byLen.map((k, v) => MapEntry(k.toString(), v))),
      ),
      'topWordByLength': topWordByLength.map((k, v) => MapEntry(k.toString(), v)),
      'totalQuestions': totalQuestions,
      'questionsByParticipant': questionsByParticipant,
      'deletedMessagesByParticipant': deletedMessagesByParticipant,
      'editedMessagesByParticipant': editedMessagesByParticipant,
      'multimediaByParticipant': multimediaByParticipant,
      'locationsByParticipant': locationsByParticipant,
      'contactsByParticipant': contactsByParticipant,
      'oneTimePhotosByParticipant': oneTimePhotosByParticipant,
      'sharedUrlsByParticipant': sharedUrlsByParticipant,
    };
  }

  /// Reconstruye WhatsAppData desde un JSON guardado
  factory WhatsAppData.fromJson(Map<String, dynamic> json) {
    return WhatsAppData(
      participants: List<String>.from(json['participants'] as List? ?? []),
      leftParticipants: List<String>.from(json['leftParticipants'] as List? ?? []),
      totalParticipantsWhoLeft: json['totalParticipantsWhoLeft'] as int? ?? 0,
      groupNameFromExport: json['groupNameFromExport'] as String?,
      groupRenameCount: json['groupRenameCount'] as int? ?? 0,
      firstMessageDate: json['firstMessageDate'] as String?,
      firstMessageUser: json['firstMessageUser'] as String?,
      firstMessageText: json['firstMessageText'] as String?,
      participantMessageCounts: Map<String, int>.from(json['participantMessageCounts'] as Map? ?? {}),
      timeRangeCounts: Map<String, int>.from(json['timeRangeCounts'] as Map? ?? {}),
      dayOfWeekTimeBandCounts: (json['dayOfWeekTimeBandCounts'] as List? ?? [])
          .map((e) => List<int>.from(e as List))
          .toList(),
      hourlyMessageCounts: List<int>.from(json['hourlyMessageCounts'] as List? ?? []),
      dailyMessageCounts: Map<String, int>.from(json['dailyMessageCounts'] as Map? ?? {}),
      monthlyMessageCounts: Map<String, int>.from(json['monthlyMessageCounts'] as Map? ?? {}),
      dayWithMostMessages: json['dayWithMostMessages'] as String?,
      dayWithMostMessagesCount: json['dayWithMostMessagesCount'] as int? ?? 0,
      monthWithMostMessages: json['monthWithMostMessages'] as String?,
      monthWithMostMessagesCount: json['monthWithMostMessagesCount'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      conversationStarters: Map<String, int>.from(json['conversationStarters'] as Map? ?? {}),
      conversationStartersAfter12h:
          WhatsAppData.mapStringIntFromJson(json['conversationStartersAfter12h']),
      lastWordsBeforeNextAfter12h:
          WhatsAppData.mapStringIntFromJson(json['lastWordsBeforeNextAfter12h']),
      breakIceStartersAfter2d:
          WhatsAppData.mapStringIntFromJson(json['breakIceStartersAfter2d']),
      averageResponseTimes: Map<String, String>.from(json['averageResponseTimes'] as Map? ?? {}),
      quickResponseCounts: Map<String, int>.from(json['quickResponseCounts'] as Map? ?? {}),
      participantWordTotals:
          WhatsAppData.mapStringIntFromJson(json['participantWordTotals']),
      nightOwlMessageCounts:
          WhatsAppData.mapStringIntFromJson(json['nightOwlMessageCounts']),
      earlyBirdMessageCounts:
          WhatsAppData.mapStringIntFromJson(json['earlyBirdMessageCounts']),
      mostConsecutiveMessages: json['mostConsecutiveMessages'] as int? ?? 0,
      mostConsecutiveUser: json['mostConsecutiveUser'] as String?,
      mostConsecutiveDate: json['mostConsecutiveDate'] as String?,
      emojiStatsByParticipant: (json['emojiStatsByParticipant'] as Map? ?? {}).map(
        (key, value) => MapEntry(
          key as String,
          (value as List)
              .map((e) => EmojiStat.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
      emojiTotalByParticipant:
          WhatsAppData.mapStringIntFromJson(json['emojiTotalByParticipant']),
      wordStatsByYear: (json['wordStatsByYear'] as Map? ?? {}).map(
        (key, value) => MapEntry(key as String, Map<String, int>.from(value as Map)),
      ),
      totalUniqueWords: json['totalUniqueWords'] as int? ?? 0,
      topWordByLengthByParticipant: (json['topWordByLengthByParticipant'] as Map? ?? {}).map(
        (p, value) => MapEntry(
          p as String,
          (value as Map).map((k, v) => MapEntry(int.parse(k as String), v as String)),
        ),
      ),
      topWordByLength: (json['topWordByLength'] as Map? ?? {}).map(
        (k, v) => MapEntry(int.parse(k as String), v as String),
      ),
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      questionsByParticipant:
          WhatsAppData.mapStringIntFromJson(json['questionsByParticipant']),
      deletedMessagesByParticipant: Map<String, int>.from(json['deletedMessagesByParticipant'] as Map? ?? {}),
      editedMessagesByParticipant: Map<String, int>.from(json['editedMessagesByParticipant'] as Map? ?? {}),
      multimediaByParticipant: Map<String, int>.from(json['multimediaByParticipant'] as Map? ?? {}),
      locationsByParticipant: Map<String, int>.from(json['locationsByParticipant'] as Map? ?? {}),
      contactsByParticipant: Map<String, int>.from(json['contactsByParticipant'] as Map? ?? {}),
      oneTimePhotosByParticipant: Map<String, int>.from(json['oneTimePhotosByParticipant'] as Map? ?? {}),
      sharedUrlsByParticipant: Map<String, int>.from(json['sharedUrlsByParticipant'] as Map? ?? {}),
    );
  }
}
