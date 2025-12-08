class WhatsAppProcessor {
  /// Procesa el contenido de un archivo de WhatsApp y extrae información completa
  static WhatsAppData processFile(String content) {
    final lines = content.split('\n');
    final participants = <String>{};
    final messagesByParticipant = <String, int>{};
    final allMessages = <Map<String, dynamic>>[];
    
    // Patrón para detectar mensajes: "21/10/25, 8:21 - Pepe: Mensaje"
    final messagePattern = RegExp(r'^(\d{1,2}/\d{1,2}/\d{2,4}),?\s+(\d{1,2}:\d{2})\s+-\s+([^:]+):\s*(.*)$');
    
    DateTime? firstMessageDate;
    DateTime? lastMessageDate;
    
    for (final line in lines) {
      final match = messagePattern.firstMatch(line.trim());
      if (match != null) {
        final dateStr = match.group(1)?.trim() ?? '';
        final timeStr = match.group(2)?.trim() ?? '';
        final participant = match.group(3)?.trim() ?? '';
        final message = match.group(4)?.trim() ?? '';
        
        if (participant.isNotEmpty) {
          participants.add(participant);
          messagesByParticipant[participant] = (messagesByParticipant[participant] ?? 0) + 1;
          
          // Guardar mensaje completo
          allMessages.add({
            'date': dateStr,
            'time': timeStr,
            'participant': participant,
            'message': message,
            'messageLength': message.length,
          });
          
          // Intentar parsear fecha para primera y última
          try {
            final dateParts = dateStr.split('/');
            if (dateParts.length == 3) {
              final year = int.parse('20${dateParts[2]}');
              final month = int.parse(dateParts[1]);
              final day = int.parse(dateParts[0]);
              final currentDate = DateTime(year, month, day);
              
              if (firstMessageDate == null || currentDate.isBefore(firstMessageDate)) {
                firstMessageDate = currentDate;
              }
              if (lastMessageDate == null || currentDate.isAfter(lastMessageDate)) {
                lastMessageDate = currentDate;
              }
            }
          } catch (e) {
            // Ignorar errores de parsing de fecha
          }
        }
      }
    }
    
    // Calcular estadísticas adicionales
    final totalMessages = allMessages.length;
    final totalWords = allMessages.fold<int>(0, (sum, msg) => sum + (msg['message'] as String).split(' ').length);
    final totalMessageLength = allMessages.fold<int>(0, (sum, msg) => sum + (msg['messageLength'] as int));
    final averageMessageLength = totalMessages > 0 ? (totalMessageLength / totalMessages).round() : 0;
    
    return WhatsAppData(
      totalLines: lines.length,
      participants: participants.toList()..sort(),
      totalMessages: totalMessages,
      messagesByParticipant: messagesByParticipant,
      firstMessageDate: firstMessageDate,
      lastMessageDate: lastMessageDate,
      totalWords: totalWords,
      averageMessageLength: averageMessageLength.round(),
      allMessages: allMessages,
    );
  }
}

class WhatsAppData {
  final int totalLines;
  final List<String> participants;
  final int totalMessages;
  final Map<String, int> messagesByParticipant;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final int totalWords;
  final int averageMessageLength;
  final List<Map<String, dynamic>> allMessages;

  WhatsAppData({
    required this.totalLines,
    required this.participants,
    required this.totalMessages,
    required this.messagesByParticipant,
    this.firstMessageDate,
    this.lastMessageDate,
    required this.totalWords,
    required this.averageMessageLength,
    required this.allMessages,
  });

  /// Convierte los datos a un JSON completo con todas las métricas
  Map<String, dynamic> toJson() {
    return {
      'totalLines': totalLines,
      'totalMessages': totalMessages,
      'participants': participants,
      'messagesByParticipant': messagesByParticipant,
      'firstMessageDate': firstMessageDate?.toIso8601String(),
      'lastMessageDate': lastMessageDate?.toIso8601String(),
      'totalWords': totalWords,
      'averageMessageLength': averageMessageLength,
      'participantCount': participants.length,
      'messages': allMessages,
      'statistics': {
        'totalLines': totalLines,
        'totalMessages': totalMessages,
        'totalWords': totalWords,
        'averageMessageLength': averageMessageLength,
        'participantCount': participants.length,
        'dateRange': {
          'start': firstMessageDate?.toIso8601String(),
          'end': lastMessageDate?.toIso8601String(),
        },
      },
    };
  }

  /// Reconstruye WhatsAppData desde un JSON guardado
  factory WhatsAppData.fromJson(Map<String, dynamic> json) {
    DateTime? firstMessageDate;
    DateTime? lastMessageDate;
    
    if (json['firstMessageDate'] != null) {
      try {
        firstMessageDate = DateTime.parse(json['firstMessageDate'] as String);
      } catch (e) {
        // Ignorar errores de parsing
      }
    }
    
    if (json['lastMessageDate'] != null) {
      try {
        lastMessageDate = DateTime.parse(json['lastMessageDate'] as String);
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    return WhatsAppData(
      totalLines: json['totalLines'] as int? ?? 0,
      participants: List<String>.from(json['participants'] as List? ?? []),
      totalMessages: json['totalMessages'] as int? ?? 0,
      messagesByParticipant: Map<String, int>.from(json['messagesByParticipant'] as Map? ?? {}),
      firstMessageDate: firstMessageDate,
      lastMessageDate: lastMessageDate,
      totalWords: json['totalWords'] as int? ?? 0,
      averageMessageLength: json['averageMessageLength'] as int? ?? 0,
      allMessages: List<Map<String, dynamic>>.from(json['messages'] as List? ?? []),
    );
  }
}

