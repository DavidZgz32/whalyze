/// Modelo completo de datos procesados de WhatsApp
class WhatsAppData {
  // Información básica
  final List<String> participants;
  final List<String> leftParticipants;
  final int totalParticipantsWhoLeft;
  
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
  final Map<String, String> averageResponseTimes; // MM:SS o HH:MM:SS
  final Map<String, int> quickResponseCounts;
  
  // Mensajes consecutivos
  final int mostConsecutiveMessages;
  final String? mostConsecutiveUser;
  final String? mostConsecutiveDate;
  
  // Estadísticas de emojis
  final Map<String, List<EmojiStat>> emojiStatsByParticipant;
  
  // Estadísticas de palabras
  final Map<String, Map<String, int>> wordStatsByYear; // "3_letters" -> {word: count}
  final int totalUniqueWords;
  /// Por participante: longitud (4..14) -> palabra más usada de esa longitud.
  final Map<String, Map<int, String>> topWordByLengthByParticipant;
  /// Una sola palabra por longitud (4..14), la más usada en todo el chat.
  final Map<int, String> topWordByLength;

  // Preguntas
  final int totalQuestions;
  
  // Estadísticas de multimedia
  final Map<String, int> deletedMessagesByParticipant;
  final Map<String, int> editedMessagesByParticipant;
  final Map<String, int> multimediaByParticipant;
  final Map<String, int> locationsByParticipant;
  final Map<String, int> contactsByParticipant;
  final Map<String, int> oneTimePhotosByParticipant;

  WhatsAppData({
    required this.participants,
    required this.leftParticipants,
    required this.totalParticipantsWhoLeft,
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
    required this.averageResponseTimes,
    required this.quickResponseCounts,
    required this.mostConsecutiveMessages,
    this.mostConsecutiveUser,
    this.mostConsecutiveDate,
    required this.emojiStatsByParticipant,
    required this.wordStatsByYear,
    required this.totalUniqueWords,
    required this.topWordByLengthByParticipant,
    required this.topWordByLength,
    required this.totalQuestions,
    required this.deletedMessagesByParticipant,
    required this.editedMessagesByParticipant,
    required this.multimediaByParticipant,
    required this.locationsByParticipant,
    required this.contactsByParticipant,
    required this.oneTimePhotosByParticipant,
  });

  /// Convierte los datos a un JSON completo
  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'leftParticipants': leftParticipants,
      'totalParticipantsWhoLeft': totalParticipantsWhoLeft,
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
      'averageResponseTimes': averageResponseTimes,
      'quickResponseCounts': quickResponseCounts,
      'mostConsecutiveMessages': mostConsecutiveMessages,
      'mostConsecutiveUser': mostConsecutiveUser,
      'mostConsecutiveDate': mostConsecutiveDate,
      'emojiStatsByParticipant': emojiStatsByParticipant.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'wordStatsByYear': wordStatsByYear,
      'totalUniqueWords': totalUniqueWords,
      'topWordByLengthByParticipant': topWordByLengthByParticipant.map(
        (p, byLen) => MapEntry(p, byLen.map((k, v) => MapEntry(k.toString(), v))),
      ),
      'topWordByLength': topWordByLength.map((k, v) => MapEntry(k.toString(), v)),
      'totalQuestions': totalQuestions,
      'deletedMessagesByParticipant': deletedMessagesByParticipant,
      'editedMessagesByParticipant': editedMessagesByParticipant,
      'multimediaByParticipant': multimediaByParticipant,
      'locationsByParticipant': locationsByParticipant,
      'contactsByParticipant': contactsByParticipant,
      'oneTimePhotosByParticipant': oneTimePhotosByParticipant,
    };
  }

  /// Reconstruye WhatsAppData desde un JSON guardado
  factory WhatsAppData.fromJson(Map<String, dynamic> json) {
    return WhatsAppData(
      participants: List<String>.from(json['participants'] as List? ?? []),
      leftParticipants: List<String>.from(json['leftParticipants'] as List? ?? []),
      totalParticipantsWhoLeft: json['totalParticipantsWhoLeft'] as int? ?? 0,
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
      averageResponseTimes: Map<String, String>.from(json['averageResponseTimes'] as Map? ?? {}),
      quickResponseCounts: Map<String, int>.from(json['quickResponseCounts'] as Map? ?? {}),
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
      deletedMessagesByParticipant: Map<String, int>.from(json['deletedMessagesByParticipant'] as Map? ?? {}),
      editedMessagesByParticipant: Map<String, int>.from(json['editedMessagesByParticipant'] as Map? ?? {}),
      multimediaByParticipant: Map<String, int>.from(json['multimediaByParticipant'] as Map? ?? {}),
      locationsByParticipant: Map<String, int>.from(json['locationsByParticipant'] as Map? ?? {}),
      contactsByParticipant: Map<String, int>.from(json['contactsByParticipant'] as Map? ?? {}),
      oneTimePhotosByParticipant: Map<String, int>.from(json['oneTimePhotosByParticipant'] as Map? ?? {}),
    );
  }
}

class EmojiStat {
  final String emoji;
  final int count;

  EmojiStat({required this.emoji, required this.count});

  Map<String, dynamic> toJson() => {'emoji': emoji, 'count': count};

  factory EmojiStat.fromJson(Map<String, dynamic> json) =>
      EmojiStat(emoji: json['emoji'] as String, count: json['count'] as int);
}

/// Estructura para parsear mensajes
class _ParsedHeader {
  final String isoDate; // YYYY-MM-DD
  final String year;
  final int hour;
  final int minute;
  final int second;
  final String user;
  final String text;

  _ParsedHeader({
    required this.isoDate,
    required this.year,
    required this.hour,
    required this.minute,
    required this.second,
    required this.user,
    required this.text,
  });
}

/// Estructura para mensajes actuales
class _CurrentMessage {
  String date;
  String user;
  int hour;
  String franja;
  String year;
  String text;

  _CurrentMessage({
    required this.date,
    required this.user,
    required this.hour,
    required this.franja,
    required this.year,
    required this.text,
  });
}

/// Procesador principal de archivos de WhatsApp
class WhatsAppProcessor {
  // Patrones regex para Android e iOS
  static final androidLineRegex = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{2,4}),\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s[-–]\s([^:]+):\s?([\s\S]*)$',
    unicode: true,
  );
  
  static final iosLineRegex = RegExp(
    r'^\[(\d{1,2})/(\d{1,2})/(\d{2,4}),\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\]\s([^:]+):\s?([\s\S]*)$',
    unicode: true,
  );

  /// Procesa el contenido de un archivo de WhatsApp y extrae información completa
  static WhatsAppData processFile(String content) {
    final lines = content.split('\n');
    final participants = <String>{};
    final leftParticipants = <String>{};

    _ParsedHeader? parseMessageHeader(String line) {
      _ParsedHeader? tryRegex(RegExp regex) {
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

        return _ParsedHeader(
          isoDate: isoDate,
          year: year,
          hour: hour,
          minute: minute,
          second: second,
          user: user,
          text: text,
        );
      }

      return tryRegex(iosLineRegex) ?? tryRegex(androidLineRegex);
    }

    _CurrentMessage? currentMessage;

    // Track primer mensaje válido
    String? firstMessageUser;
    String? firstMessageText;

    // Estadísticas globales
    final participantMessageCounts = <String, int>{};
    final timeRangeCounts = <String, int>{
      'Madrugada': 0,
      'Mañana': 0,
      'Tarde': 0,
      'Noche': 0,
    };

    // Matriz 7x4 (días x franjas)
    final dayOfWeekTimeBandCounts = List.generate(7, (_) => [0, 0, 0, 0]);
    final bandIndexByName = <String, int>{
      'Madrugada': 0,
      'Mañana': 1,
      'Tarde': 2,
      'Noche': 3,
    };

    final hourlyMessageCounts = List.filled(24, 0);

    int toDowIndexFromIso(String isoDate) {
      // Convert to 0=Mon..6=Sun
      // DateTime.weekday: 1=Mon..7=Sun
      // We want: 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun
      final date = DateTime.parse(isoDate);
      final weekday = date.weekday; // 1=Mon..7=Sun
      return weekday - 1; // 0=Mon..6=Sun
    }

    final dailyMessageCounts = <String, int>{};
    final monthlyMessageCounts = <String, int>{};

    // Rachas de mensajes consecutivos
    String? currentConsecutiveUser;
    int currentConsecutiveCount = 0;
    int mostConsecutiveMessages = 0;
    String? mostConsecutiveUser;
    String? mostConsecutiveDate;

    // Preguntas
    int totalQuestions = 0;

    // Conversación
    final conversationStarters = <String, int>{};
    final responseTimes = <String, List<double>>{};
    final quickResponseCounts = <String, int>{};
    int? lastMessageTime;
    String? lastMessageUser;
    const conversationGapHours = 4;

    // Estadísticas de palabras
    final wordStats = <String, Map<String, int>>{};
    final wordStatsByParticipant = <String, Map<String, Map<String, int>>>{};
    final uniqueWords = <String>{};

    // Estadísticas de emojis
    final emojiStatsByParticipant = <String, Map<String, int>>{};

    // Estadísticas de multimedia
    final deletedMessagesByParticipant = <String, int>{};
    final editedMessagesByParticipant = <String, int>{};
    final multimediaByParticipant = <String, int>{};
    final locationsByParticipant = <String, int>{};
    final contactsByParticipant = <String, int>{};
    final oneTimePhotosByParticipant = <String, int>{};

    // Identificación del subidor
    String? uploaderParticipant;

    // Funciones auxiliares
    String formatTime(double minutes) {
      final totalSeconds = (minutes * 60).round();
      final hours = totalSeconds ~/ 3600;
      final remainingSeconds = totalSeconds % 3600;
      final mins = remainingSeconds ~/ 60;
      final secs = remainingSeconds % 60;

      if (hours > 0) {
        return '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      } else {
        return '${mins}:${secs.toString().padLeft(2, '0')}';
      }
    }

    int countQuestions(String text) {
      // Contar grupos de signos de interrogación consecutivos
      // Múltiples ? seguidos cuentan como una sola pregunta
      // Ejemplo: "Que tal??????" = 1 pregunta, "Hola ??" = 1 pregunta, "Hola?" = 1 pregunta
      int questionCount = 0;
      
      // Buscar grupos de ? o ¿ consecutivos (pueden tener espacios entre ellos)
      // Usamos regex para encontrar patrones como: ?+, ¿+, o combinaciones
      final questionPattern = RegExp(r'[?¿]+');
      final matches = questionPattern.allMatches(text);
      
      // Cada grupo de ? consecutivos cuenta como una pregunta
      questionCount = matches.length;
      
      return questionCount;
    }

    void identifyUploader(String text) {
      final lines = text.split('\n');

      for (final line in lines) {
        if (line.contains('Eliminaste este mensaje') ||
            line.contains('You deleted this message')) {
          final parsed = parseMessageHeader(line);
          if (parsed != null && parsed.user.isNotEmpty) {
            uploaderParticipant = parsed.user;
            break;
          }
        }
      }
    }

    void processMediaPatterns(String text, String participant) {
      final trimmedText = text.trim();

      // Mensajes eliminados
      if (trimmedText == 'Eliminaste este mensaje' ||
          trimmedText == 'Eliminaste este mensaje.' ||
          trimmedText == 'You deleted this message' ||
          trimmedText == 'You deleted this message.') {
        if (uploaderParticipant != null) {
          deletedMessagesByParticipant[uploaderParticipant!] =
              (deletedMessagesByParticipant[uploaderParticipant!] ?? 0) + 1;
        }
      } else if (trimmedText == 'Se eliminó este mensaje' ||
          trimmedText == 'Se eliminó este mensaje.' ||
          trimmedText == 'This message was deleted' ||
          trimmedText == 'This message was deleted.') {
        deletedMessagesByParticipant[participant] =
            (deletedMessagesByParticipant[participant] ?? 0) + 1;
      }

      // Mensajes editados
      if (trimmedText.contains('<Se editó este mensaje.>') ||
          trimmedText.contains('<This message was edited>')) {
        editedMessagesByParticipant[participant] =
            (editedMessagesByParticipant[participant] ?? 0) + 1;
      }

      // Multimedia omitido
      if (trimmedText == '<Multimedia omitido>' ||
          trimmedText == '<Media omitted>') {
        multimediaByParticipant[participant] =
            (multimediaByParticipant[participant] ?? 0) + 1;
      }

      // Ubicaciones
      if (trimmedText.contains('ubicación:') ||
          trimmedText.contains('location:')) {
        if (trimmedText.contains('maps.google.com') ||
            trimmedText.contains('goo.gl/maps') ||
            trimmedText.contains('maps.app.goo.gl')) {
          locationsByParticipant[participant] =
              (locationsByParticipant[participant] ?? 0) + 1;
        }
      }

      // Contactos
      if (trimmedText.contains('.vcf') &&
          (trimmedText.contains('(archivo adjunto)') ||
              trimmedText.contains('(file attached)'))) {
        contactsByParticipant[participant] =
            (contactsByParticipant[participant] ?? 0) + 1;
      }

      // Fotos temporales
      if (trimmedText == 'null' || trimmedText == '') {
        oneTimePhotosByParticipant[participant] =
            (oneTimePhotosByParticipant[participant] ?? 0) + 1;
      }
    }

    String stripOrphanEmojiModifiers(String input) {
      // Remove Fitzpatrick skin tone modifiers globally
      String withoutSkinTones = input.replaceAll(
        RegExp(r'[\u{1F3FB}-\u{1F3FF}]', unicode: true),
        '',
      );

      const genderRe = r'[\u2640\u2642\u26A7]';
      const zwj = '\u200D';
      const vs16 = '\uFE0F';
      final emojiBaseRe = RegExp(
        r'[\u{1F300}-\u{1F6FF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F600}-\u{1F64F}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F910}-\u{1F96B}]|[\u{1F980}-\u{1F9E0}]',
        unicode: true,
      );

      bool isGender(String ch) => RegExp(genderRe).hasMatch(ch);
      bool isEmojiBase(String ch) {
        if (!emojiBaseRe.hasMatch(ch)) return false;
        if (isGender(ch)) return false;
        if (ch == zwj || ch == vs16) return false;
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
          final valid = (prev1 == zwj && isEmojiBase(prev2)) ||
              (prev1 == zwj && prev2 == vs16 && isEmojiBase(prev3));
          if (valid) {
            out.add(ch);
          }
          continue;
        }

        out.add(ch);
      }

      return out.join('');
    }

    void processWords(String text, String participant) {
      // Remove orphaned emoji modifiers before processing
      final sanitized = stripOrphanEmojiModifiers(text);

      // Quitar URLs para no contar fragmentos (ej. C0b9SjIoAel de un link de Instagram)
      final withoutUrls = sanitized.replaceAll(
        RegExp(r'(?:https?://|www\.)[^\s]*', caseSensitive: false),
        ' ',
      );

      // Process emojis first
      final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[\u{1F018}-\u{1F270}]|[\u{238C}-\u{2454}]|[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F100}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]|[\u{1F910}-\u{1F96B}]|[\u{1F980}-\u{1F9E0}]',
        unicode: true,
      );
      final emojis = emojiRegex.allMatches(sanitized).map((m) => m.group(0)!).toList();
      final cleanedEmojis = emojis.where((e) =>
          !RegExp(r'[\u2640\u2642\u26A7\u200D\uFE0F]', unicode: true).hasMatch(e)).toList();

      // Initialize participant's emoji map if it doesn't exist
      if (!emojiStatsByParticipant.containsKey(participant)) {
        emojiStatsByParticipant[participant] = <String, int>{};
      }
      final participantEmojis = emojiStatsByParticipant[participant]!;

      for (final emoji in cleanedEmojis) {
        participantEmojis[emoji] = (participantEmojis[emoji] ?? 0) + 1;
      }

      // Normalize and split text into words (usar texto sin URLs)
      final words = withoutUrls
          .toLowerCase()
          .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .where((word) =>
              word != 'http' &&
              word != 'https' &&
              word != 'www' &&
              word != 'eliminaste' &&
              word != 'deleted')
          .toList();

      for (final word in words) {
        final len = word.length;
        if (len >= 3 && len <= 11) {
          final key = '${len}_letters';
          if (!wordStats.containsKey(key)) {
            wordStats[key] = <String, int>{};
          }
          final map = wordStats[key]!;
          map[word] = (map[word] ?? 0) + 1;
          uniqueWords.add(word);
        }
        // Por participante, longitudes 4 a 14 para la pantalla de palabras
        if (len >= 4 && len <= 14) {
          final key = '${len}_letters';
          if (!wordStatsByParticipant.containsKey(participant)) {
            wordStatsByParticipant[participant] = <String, Map<String, int>>{};
          }
          final byParticipant = wordStatsByParticipant[participant]!;
          if (!byParticipant.containsKey(key)) {
            byParticipant[key] = <String, int>{};
          }
          final map = byParticipant[key]!;
          map[word] = (map[word] ?? 0) + 1;
        }
      }
    }

    // Primera pasada: identificar el subidor
    identifyUploader(content);

    // Procesar líneas
    for (final line in lines) {
      final trimmedLine = line.trim();

      // Ignorar mensaje de cifrado
      if (trimmedLine.contains('Los mensajes y las llamadas')) {
        continue;
      }

      // Detectar participantes que salieron del grupo
      if (trimmedLine.contains('salió del grupo') ||
          trimmedLine.contains('left the group') ||
          trimmedLine.contains('salió del grupo.') ||
          trimmedLine.contains('left the group.')) {
        // Verificar si es mensaje del sistema (sin ":" después del timestamp)
        // Un mensaje del sistema tiene el formato: "DD/MM/YY, HH:MM - Nombre salió del grupo"
        // Un mensaje de usuario tiene: "DD/MM/YY, HH:MM - Usuario: texto que menciona salió del grupo"
        final parsed = parseMessageHeader(trimmedLine);
        
        // Si NO se puede parsear como mensaje de usuario (no tiene ":" después del timestamp),
        // entonces es un mensaje del sistema
        if (parsed == null) {
          // Intentar extraer nombre del participante del mensaje del sistema
          // Formato Android: "22/9/23, 6:46 - ‎~ J salió del grupo."
          // Formato iOS: "[22/9/23, 6:46:59] ‎~ J salió del grupo."
          RegExpMatch? nameMatch = RegExp(
            r'^\d{1,2}/\d{1,2}/\d{2,4},\s+\d{1,2}:\d{2}(?::\d{2})?\s[-–]\s([^:]+?)\s+(?:salió del grupo|left the group)',
            caseSensitive: false,
          ).firstMatch(trimmedLine);
          
          if (nameMatch == null) {
            nameMatch = RegExp(
              r'^\[\d{1,2}/\d{1,2}/\d{2,4},\s+\d{1,2}:\d{2}(?::\d{2})?\]\s([^:]+?)\s+(?:salió del grupo|left the group)',
              caseSensitive: false,
            ).firstMatch(trimmedLine);
          }

          if (nameMatch != null) {
            final participantName = nameMatch.group(1)!
                .replaceAll(RegExp(r'[‎~]'), '')
                .trim();
            leftParticipants.add(participantName);
          }
          continue;
        }
        // Si parsed != null, es un mensaje de usuario normal que menciona "salió del grupo",
        // continuar con el procesamiento normal
      }

      final parsed = parseMessageHeader(trimmedLine);

      if (parsed != null) {
        // Nuevo mensaje - procesar el mensaje anterior si existe
        if (currentMessage != null) {
          // Procesar patrones multimedia para TODOS los mensajes
          processMediaPatterns(currentMessage.text, currentMessage.user);

          // Saltar mensajes multimedia omitidos, eliminados y vacíos
          final skipMessage = currentMessage.text == '<Multimedia omitido>' ||
              currentMessage.text == '<Media omitted>' ||
              currentMessage.text == 'Eliminaste este mensaje' ||
              currentMessage.text == 'Eliminaste este mensaje.' ||
              currentMessage.text == 'You deleted this message' ||
              currentMessage.text == 'You deleted this message.' ||
              currentMessage.text == 'Se eliminó este mensaje' ||
              currentMessage.text == 'Se eliminó este mensaje.' ||
              currentMessage.text == 'This message was deleted' ||
              currentMessage.text == 'This message was deleted.' ||
              currentMessage.text == '' ||
              currentMessage.text == 'null';

          if (!skipMessage) {
            // Track mensajes consecutivos
            if (currentConsecutiveUser == currentMessage.user) {
              currentConsecutiveCount++;
            } else {
              currentConsecutiveUser = currentMessage.user;
              currentConsecutiveCount = 1;
            }
            if (currentConsecutiveCount > mostConsecutiveMessages) {
              mostConsecutiveMessages = currentConsecutiveCount;
              mostConsecutiveUser = currentMessage.user;
              mostConsecutiveDate = currentMessage.date;
            }

            // Establecer primer mensaje válido
            if (firstMessageUser == null &&
                currentMessage.text != '<Multimedia omitido>' &&
                currentMessage.text != '<Media omitted>' &&
                !currentMessage.text.contains('<Se editó este mensaje.>') &&
                !currentMessage.text.contains('<This message was edited>') &&
                currentMessage.text != '' &&
                currentMessage.text != 'null') {
              firstMessageUser = currentMessage.user;
              firstMessageText = currentMessage.text;
            }

            // Contar mensaje globalmente
            participantMessageCounts[currentMessage.user] =
                (participantMessageCounts[currentMessage.user] ?? 0) + 1;
            timeRangeCounts[currentMessage.franja] =
                (timeRangeCounts[currentMessage.franja] ?? 0) + 1;
            hourlyMessageCounts[currentMessage.hour]++;

            // Incrementar matriz 7x4
            try {
              final dowIdx = toDowIndexFromIso(currentMessage.date);
              final bandIdx = bandIndexByName[currentMessage.franja];
              if (bandIdx != null && dowIdx >= 0 && dowIdx < 7) {
                dayOfWeekTimeBandCounts[dowIdx][bandIdx]++;
              }
            } catch (e) {
              // Ignorar errores
            }

            // Contar por día
            dailyMessageCounts[currentMessage.date] =
                (dailyMessageCounts[currentMessage.date] ?? 0) + 1;

            // Contar por mes
            final monthKey = currentMessage.date.substring(0, 7);
            monthlyMessageCounts[monthKey] =
                (monthlyMessageCounts[monthKey] ?? 0) + 1;

            // Procesar palabras
            processWords(currentMessage.text, currentMessage.user);

            // Contar preguntas
            totalQuestions += countQuestions(currentMessage.text);
          }
        }

        // Iniciar nuevo mensaje
        final year = parsed.year;
        final date = parsed.isoDate;
        final hour = parsed.hour;
        final minute = parsed.minute;
        final second = parsed.second;
        final user = parsed.user;
        final text = parsed.text;

        participants.add(user);

        // Crear timestamp para detección de conversación
        final messageTime = DateTime.parse(
                '$date ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}')
            .millisecondsSinceEpoch;

        // Verificar si inicia nueva conversación (gap de 4+ horas)
        if (lastMessageTime != null) {
          final timeDiffHours =
              (messageTime - lastMessageTime!) / (1000 * 60 * 60);
          if (timeDiffHours >= conversationGapHours) {
            conversationStarters[user] = (conversationStarters[user] ?? 0) + 1;
          } else {
            // Calcular tiempo de respuesta si es diferente usuario
            if (lastMessageUser != null && user != lastMessageUser) {
              final timeDiffMinutes =
                  (messageTime - lastMessageTime!) / (1000 * 60);
              if (!responseTimes.containsKey(user)) {
                responseTimes[user] = <double>[];
              }
              responseTimes[user]!.add(timeDiffMinutes);

              // Track respuestas rápidas (menos de 5 minutos)
              if (timeDiffMinutes < 5) {
                quickResponseCounts[user] =
                    (quickResponseCounts[user] ?? 0) + 1;
              }
            }
          }
        } else {
          // Primer mensaje, contar como iniciador
          conversationStarters[user] = (conversationStarters[user] ?? 0) + 1;
        }

        lastMessageTime = messageTime;
        lastMessageUser = user;

        String franja = '';
        if (hour >= 0 && hour < 6) {
          franja = 'Madrugada';
        } else if (hour >= 6 && hour < 13) {
          franja = 'Mañana';
        } else if (hour >= 13 && hour < 19) {
          franja = 'Tarde';
        } else {
          franja = 'Noche';
        }

        currentMessage = _CurrentMessage(
          date: date,
          user: user,
          hour: hour,
          franja: franja,
          year: year,
          text: text,
        );
      } else if (currentMessage != null) {
        // Mensaje multilínea: agregar al texto actual
        currentMessage!.text += '\n$trimmedLine';
      }
    }

    // No olvidar contar el último mensaje
    if (currentMessage != null) {
      processMediaPatterns(currentMessage!.text, currentMessage!.user);

      final skipMessage = currentMessage!.text == '<Multimedia omitido>' ||
          currentMessage!.text == '<Media omitted>' ||
          currentMessage!.text == 'Eliminaste este mensaje' ||
          currentMessage!.text == 'Eliminaste este mensaje.' ||
          currentMessage!.text == 'You deleted this message' ||
          currentMessage!.text == 'You deleted this message.' ||
          currentMessage!.text == 'Se eliminó este mensaje' ||
          currentMessage!.text == 'Se eliminó este mensaje.' ||
          currentMessage!.text == 'This message was deleted' ||
          currentMessage!.text == 'This message was deleted.' ||
          currentMessage!.text == '' ||
          currentMessage!.text == 'null';

      if (!skipMessage) {
        // Track mensajes consecutivos (mensaje final)
        if (currentConsecutiveUser == currentMessage!.user) {
          currentConsecutiveCount++;
        } else {
          currentConsecutiveUser = currentMessage!.user;
          currentConsecutiveCount = 1;
        }
        if (currentConsecutiveCount > mostConsecutiveMessages) {
          mostConsecutiveMessages = currentConsecutiveCount;
          mostConsecutiveUser = currentMessage!.user;
          mostConsecutiveDate = currentMessage!.date;
        }

        // Establecer primer mensaje válido si no está establecido
        if (firstMessageUser == null &&
            currentMessage!.text != '<Multimedia omitido>' &&
            currentMessage!.text != '<Media omitted>' &&
            !currentMessage!.text.contains('<Se editó este mensaje.>') &&
            !currentMessage!.text.contains('<This message was edited>') &&
            currentMessage!.text != '' &&
            currentMessage!.text != 'null') {
          firstMessageUser = currentMessage!.user;
          firstMessageText = currentMessage!.text;
        }

        // Contar último mensaje globalmente
        participantMessageCounts[currentMessage!.user] =
            (participantMessageCounts[currentMessage!.user] ?? 0) + 1;
        timeRangeCounts[currentMessage!.franja] =
            (timeRangeCounts[currentMessage!.franja] ?? 0) + 1;
        hourlyMessageCounts[currentMessage!.hour]++;

        // Incrementar matriz 7x4 para mensaje final
        try {
          final dowIdx = toDowIndexFromIso(currentMessage!.date);
          final bandIdx = bandIndexByName[currentMessage!.franja];
          if (bandIdx != null && dowIdx >= 0 && dowIdx < 7) {
            dayOfWeekTimeBandCounts[dowIdx][bandIdx]++;
          }
        } catch (e) {
          // Ignorar errores
        }

        // Contar por día
        dailyMessageCounts[currentMessage!.date] =
            (dailyMessageCounts[currentMessage!.date] ?? 0) + 1;

        // Contar por mes
        final monthKey = currentMessage!.date.substring(0, 7);
        monthlyMessageCounts[monthKey] =
            (monthlyMessageCounts[monthKey] ?? 0) + 1;

        // Procesar palabras para último mensaje
        processWords(currentMessage!.text, currentMessage!.user);

        // Contar preguntas en último mensaje
        totalQuestions += countQuestions(currentMessage!.text);
      }
    }

    // Filtrar participantes que salieron del grupo
    final allParticipants = participants.toList();
    final participantsArray = allParticipants
        .where((participant) => !leftParticipants.contains(participant))
        .toList();

    // Encontrar día y mes más activos
    String? dayWithMostMessages;
    int dayWithMostMessagesCount = 0;
    for (final entry in dailyMessageCounts.entries) {
      if (entry.value > dayWithMostMessagesCount) {
        dayWithMostMessages = entry.key;
        dayWithMostMessagesCount = entry.value;
      }
    }

    String? monthWithMostMessages;
    int monthWithMostMessagesCount = 0;
    for (final entry in monthlyMessageCounts.entries) {
      if (entry.value > monthWithMostMessagesCount) {
        monthWithMostMessages = entry.key;
        monthWithMostMessagesCount = entry.value;
      }
    }

    // Calcular racha más larga de días consecutivos
    int longestStreak = 0;
    int currentStreak = 0;
    String? lastDate;

    final datesWithMessages = dailyMessageCounts.keys.toList()..sort();

    for (final date in datesWithMessages) {
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final lastDateObj = DateTime.parse(lastDate);
        final currentDateObj = DateTime.parse(date);
        final diffTime = currentDateObj.difference(lastDateObj).inDays;

        if (diffTime == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      lastDate = date;
    }

    // Convertir wordStats maps a objetos ordenados top 20
    final wordStatsByYearFinal = <String, Map<String, int>>{};
    for (final entry in wordStats.entries) {
      final lenKey = entry.key;
      final map = entry.value;
      final topWords = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value) != 0
            ? b.value.compareTo(a.value)
            : a.key.compareTo(b.key));
      final top20 = topWords.take(20).toList();
      wordStatsByYearFinal[lenKey] =
          Map.fromEntries(top20.map((e) => MapEntry(e.key, e.value)));
    }

    // Top palabra por longitud por participante (4..14) para pantalla palabras más usadas
    final topWordByLengthByParticipant = <String, Map<int, String>>{};
    for (final participant in participantsArray) {
      final byLen = <int, String>{};
      final partStats = wordStatsByParticipant[participant];
      if (partStats != null) {
        for (int len = 14; len >= 4; len--) {
          final key = '${len}_letters';
          final map = partStats[key];
          if (map != null && map.isNotEmpty) {
            final top = map.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value) != 0
                  ? b.value.compareTo(a.value)
                  : a.key.compareTo(b.key));
            byLen[len] = top.first.key;
          }
        }
      }
      topWordByLengthByParticipant[participant] = byLen;
    }

    // Una palabra por longitud (4..14): la más usada en todo el chat
    final topWordByLength = <int, String>{};
    for (int len = 14; len >= 4; len--) {
      final key = '${len}_letters';
      final globalCount = <String, int>{};
      for (final participant in participantsArray) {
        final partStats = wordStatsByParticipant[participant];
        if (partStats == null) continue;
        final map = partStats[key];
        if (map != null) {
          for (final e in map.entries) {
            globalCount[e.key] = (globalCount[e.key] ?? 0) + e.value;
          }
        }
      }
      if (globalCount.isNotEmpty) {
        final top = globalCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value) != 0
              ? b.value.compareTo(a.value)
              : a.key.compareTo(b.key));
        topWordByLength[len] = top.first.key;
      }
    }

    // Convertir emojiStatsByParticipant a arrays ordenados top 8
    final emojiStatsByParticipantFinal = <String, List<EmojiStat>>{};

    for (final entry in emojiStatsByParticipant.entries) {
      final participant = entry.key;
      final emojiMap = entry.value;
      final topEmojis = emojiMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value) != 0
            ? b.value.compareTo(a.value)
            : a.key.compareTo(b.key));
      final top8 = topEmojis.take(8).toList();
      emojiStatsByParticipantFinal[participant] =
          top8.map((e) => EmojiStat(emoji: e.key, count: e.value)).toList();
    }

    // Calcular tiempos promedio de respuesta
    final averageResponseTimes = <String, String>{};

    for (final entry in responseTimes.entries) {
      final participant = entry.key;
      final times = entry.value;
      if (times.isNotEmpty) {
        final averageMinutes =
            times.reduce((sum, time) => sum + time) / times.length;
        averageResponseTimes[participant] = formatTime(averageMinutes);
      } else {
        averageResponseTimes[participant] = '0:00';
      }
    }

    // Obtener primera fecha de mensaje válido
    final firstMessageDate = datesWithMessages.isNotEmpty
        ? datesWithMessages.first
        : null;

    return WhatsAppData(
      participants: participantsArray,
      leftParticipants: leftParticipants.toList(),
      totalParticipantsWhoLeft: leftParticipants.length,
      firstMessageDate: firstMessageDate,
      firstMessageUser: firstMessageUser,
      firstMessageText: firstMessageText,
      participantMessageCounts: participantMessageCounts,
      timeRangeCounts: timeRangeCounts,
      dayOfWeekTimeBandCounts: dayOfWeekTimeBandCounts,
      hourlyMessageCounts: hourlyMessageCounts,
      dailyMessageCounts: dailyMessageCounts,
      monthlyMessageCounts: monthlyMessageCounts,
      dayWithMostMessages: dayWithMostMessages,
      dayWithMostMessagesCount: dayWithMostMessagesCount,
      monthWithMostMessages: monthWithMostMessages,
      monthWithMostMessagesCount: monthWithMostMessagesCount,
      longestStreak: longestStreak,
      conversationStarters: conversationStarters,
      averageResponseTimes: averageResponseTimes,
      quickResponseCounts: quickResponseCounts,
      mostConsecutiveMessages: mostConsecutiveMessages,
      mostConsecutiveUser: mostConsecutiveUser,
      mostConsecutiveDate: mostConsecutiveDate,
      emojiStatsByParticipant: emojiStatsByParticipantFinal,
      wordStatsByYear: wordStatsByYearFinal,
      totalUniqueWords: uniqueWords.length,
      topWordByLengthByParticipant: topWordByLengthByParticipant,
      topWordByLength: topWordByLength,
      totalQuestions: totalQuestions,
      deletedMessagesByParticipant: deletedMessagesByParticipant,
      editedMessagesByParticipant: editedMessagesByParticipant,
      multimediaByParticipant: multimediaByParticipant,
      locationsByParticipant: locationsByParticipant,
      contactsByParticipant: contactsByParticipant,
      oneTimePhotosByParticipant: oneTimePhotosByParticipant,
    );
  }
}
