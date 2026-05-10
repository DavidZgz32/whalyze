import 'analysis/chat_question_counter.dart';
import 'analysis/chat_url_counter.dart';
import 'analysis/word_emoji_stats_tracker.dart';
import 'group_name_events.dart';
import 'locale/export_phrase_catalog.dart';
import 'models/emoji_stat.dart';
import 'models/whatsapp_data.dart';
import 'parsing/group_leave_line_parser.dart';
import 'parsing/parsed_header.dart';
import 'time_band.dart';

class _OpenMessage {
  String date;
  String user;
  int hour;
  String timeBandLabel;
  String year;
  String text;

  _OpenMessage({
    required this.date,
    required this.user,
    required this.hour,
    required this.timeBandLabel,
    required this.year,
    required this.text,
  });
}

/// Una pasada sobre el TXT: parsing, normalización implícita y agregación.
class ChatExportSession {
  ChatExportSession(String content) : _content = content;

  final String _content;

  late final List<String> _lines = _content.split('\n');
  late final String? _groupNameFromExport =
      GroupNameEvents.extractLastGroupNameFromExport(_content);
  late final int _groupRenameCount =
      GroupNameEvents.countGroupRenameEventsInExport(_content);

  final _participants = <String>{};
  final _leftParticipants = <String>{};

  _OpenMessage? _openMessage;

  String? _firstMessageUser;
  String? _firstMessageText;

  final _participantMessageCounts = <String, int>{};
  final _timeRangeCounts = <String, int>{
    TimeBand.madrugada: 0,
    TimeBand.manana: 0,
    TimeBand.tarde: 0,
    TimeBand.noche: 0,
  };

  late final List<List<int>> _dayOfWeekTimeBandCounts =
      List.generate(7, (_) => [0, 0, 0, 0]);

  final _hourlyMessageCounts = List.filled(24, 0);

  final _dailyMessageCounts = <String, int>{};
  final _monthlyMessageCounts = <String, int>{};

  String? _currentConsecutiveUser;
  int _currentConsecutiveCount = 0;
  int _mostConsecutiveMessages = 0;
  String? _mostConsecutiveUser;
  String? _mostConsecutiveDate;

  int _totalQuestions = 0;
  final _questionsByParticipant = <String, int>{};

  final _conversationStarters = <String, int>{};
  final _conversationStartersAfter12h = <String, int>{};
  final _lastWordsBeforeNextAfter12h = <String, int>{};
  final _breakIceStartersAfter2d = <String, int>{};
  final _responseTimes = <String, List<double>>{};
  final _quickResponseCounts = <String, int>{};
  int? _lastMessageTime;
  String? _lastMessageUser;
  static const _conversationGapHours = 4;
  static const _longSilenceHours = 12;
  static const _breakIceSilenceHours = 48;

  final _participantWordTotals = <String, int>{};
  final _nightOwlMessageCounts = <String, int>{};
  final _earlyBirdMessageCounts = <String, int>{};

  final _wordStats = <String, Map<String, int>>{};
  final _wordStatsByParticipant = <String, Map<String, Map<String, int>>>{};
  final _uniqueWords = <String>{};

  final _emojiStatsByParticipant = <String, Map<String, int>>{};
  final _emojiTotalByParticipant = <String, int>{};

  final _deletedMessagesByParticipant = <String, int>{};
  final _editedMessagesByParticipant = <String, int>{};
  final _multimediaByParticipant = <String, int>{};
  final _locationsByParticipant = <String, int>{};
  final _contactsByParticipant = <String, int>{};
  final _oneTimePhotosByParticipant = <String, int>{};
  final _sharedUrlsByParticipant = <String, int>{};

  String? _uploaderParticipant;

  late final WordEmojiStatsTracker _wordEmoji = WordEmojiStatsTracker(
    emojiStatsByParticipant: _emojiStatsByParticipant,
    emojiTotalByParticipant: _emojiTotalByParticipant,
    participantWordTotals: _participantWordTotals,
    wordStats: _wordStats,
    wordStatsByParticipant: _wordStatsByParticipant,
    uniqueWords: _uniqueWords,
  );

  WhatsAppData run() {
    _identifyUploader();
    for (final line in _lines) {
      _handleLine(line);
    }
    _flushOpenMessage(isFinal: true);
    return _assembleResult();
  }

  static String _formatAverageResponse(double minutes) {
    final totalSeconds = (minutes * 60).round();
    final hours = totalSeconds ~/ 3600;
    final remainingSeconds = totalSeconds % 3600;
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;

    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  void _identifyUploader() {
    for (final line in _content.split('\n')) {
      if (ExportPhraseCatalog.lineIndicatesSelfDeletedForUploaderId(line)) {
        final parsed = parseMessageHeader(line);
        if (parsed != null && parsed.user.isNotEmpty) {
          _uploaderParticipant = parsed.user;
          break;
        }
      }
    }
  }

  void _processMediaPatterns(String text, String participant) {
    final trimmedText = text.trim();

    if (ExportPhraseCatalog.selfDeletedByUploaderExact.contains(trimmedText)) {
      final u = _uploaderParticipant;
      if (u != null) {
        _deletedMessagesByParticipant[u] = (_deletedMessagesByParticipant[u] ?? 0) + 1;
      }
    } else if (ExportPhraseCatalog.deletedByOtherExact.contains(trimmedText)) {
      _deletedMessagesByParticipant[participant] =
          (_deletedMessagesByParticipant[participant] ?? 0) + 1;
    }

    final editCount = ExportPhraseCatalog.countEditMarkersInText(trimmedText);
    if (editCount > 0) {
      _editedMessagesByParticipant[participant] =
          (_editedMessagesByParticipant[participant] ?? 0) + editCount;
    }

    if (ExportPhraseCatalog.multimediaOmittedExact.contains(trimmedText)) {
      _multimediaByParticipant[participant] =
          (_multimediaByParticipant[participant] ?? 0) + 1;
    }

    if (ExportPhraseCatalog.looksLikeLocationShare(trimmedText) &&
        ExportPhraseCatalog.hasMapsLink(trimmedText)) {
      _locationsByParticipant[participant] =
          (_locationsByParticipant[participant] ?? 0) + 1;
    }

    if (ExportPhraseCatalog.looksLikeContactAttachment(trimmedText)) {
      _contactsByParticipant[participant] =
          (_contactsByParticipant[participant] ?? 0) + 1;
    }

    if (ExportPhraseCatalog.isDisappearingPhotoPlaceholder(trimmedText)) {
      _oneTimePhotosByParticipant[participant] =
          (_oneTimePhotosByParticipant[participant] ?? 0) + 1;
    }

    final urlCount = ChatUrlCounter.countUrlsInText(trimmedText);
    if (urlCount > 0) {
      _sharedUrlsByParticipant[participant] =
          (_sharedUrlsByParticipant[participant] ?? 0) + urlCount;
    }
  }

  int _dayOfWeekIndexFromIso(String isoDate) {
    final date = DateTime.parse(isoDate);
    return date.weekday - 1;
  }

  void _trySetFirstMessage(String user, String text) {
    if (_firstMessageUser != null) return;
    if (ExportPhraseCatalog.multimediaOmittedExact.contains(text)) return;
    if (ExportPhraseCatalog.textContainsEditMarker(text)) return;
    if (text == '' || text == 'null') return;
    _firstMessageUser = user;
    _firstMessageText = text;
  }

  void _recordConsecutiveAndMaybeFirst(_OpenMessage m) {
    if (_currentConsecutiveUser == m.user) {
      _currentConsecutiveCount++;
    } else {
      _currentConsecutiveUser = m.user;
      _currentConsecutiveCount = 1;
    }
    if (_currentConsecutiveCount > _mostConsecutiveMessages) {
      _mostConsecutiveMessages = _currentConsecutiveCount;
      _mostConsecutiveUser = m.user;
      _mostConsecutiveDate = m.date;
    }
    _trySetFirstMessage(m.user, m.text);
  }

  void _incrementHourlyAndBands(_OpenMessage m) {
    _participantMessageCounts[m.user] = (_participantMessageCounts[m.user] ?? 0) + 1;
    _timeRangeCounts[m.timeBandLabel] = (_timeRangeCounts[m.timeBandLabel] ?? 0) + 1;
    _hourlyMessageCounts[m.hour]++;

    final h = m.hour;
    if (h >= 20 || h < 6) {
      _nightOwlMessageCounts[m.user] = (_nightOwlMessageCounts[m.user] ?? 0) + 1;
    }
    if (h >= 6 && h < 12) {
      _earlyBirdMessageCounts[m.user] = (_earlyBirdMessageCounts[m.user] ?? 0) + 1;
    }

    try {
      final dowIdx = _dayOfWeekIndexFromIso(m.date);
      final bandIdx = TimeBand.indexByName[m.timeBandLabel];
      if (bandIdx != null && dowIdx >= 0 && dowIdx < 7) {
        _dayOfWeekTimeBandCounts[dowIdx][bandIdx]++;
      }
    } catch (_) {}

    _dailyMessageCounts[m.date] = (_dailyMessageCounts[m.date] ?? 0) + 1;
    final monthKey = m.date.substring(0, 7);
    _monthlyMessageCounts[monthKey] = (_monthlyMessageCounts[monthKey] ?? 0) + 1;
  }

  void _accumulateWordsAndQuestions(_OpenMessage m) {
    _wordEmoji.processWords(m.text, m.user);
    final q = ChatQuestionCounter.countQuestions(m.text);
    _totalQuestions += q;
    _questionsByParticipant[m.user] = (_questionsByParticipant[m.user] ?? 0) + q;
  }

  void _applyConversationGaps({
    required int messageTime,
    required String user,
  }) {
    if (_lastMessageTime != null) {
      final timeDiffHours = (messageTime - _lastMessageTime!) / (1000 * 60 * 60);
      if (timeDiffHours >= _conversationGapHours) {
        _conversationStarters[user] = (_conversationStarters[user] ?? 0) + 1;
      } else {
        final lastUser = _lastMessageUser;
        if (lastUser != null && user != lastUser) {
          final timeDiffMinutes = (messageTime - _lastMessageTime!) / (1000 * 60);
          _responseTimes.putIfAbsent(user, () => <double>[]);
          _responseTimes[user]!.add(timeDiffMinutes);
          if (timeDiffMinutes < 5) {
            _quickResponseCounts[user] = (_quickResponseCounts[user] ?? 0) + 1;
          }
        }
      }
      if (timeDiffHours >= _longSilenceHours) {
        _conversationStartersAfter12h[user] =
            (_conversationStartersAfter12h[user] ?? 0) + 1;
        final lastUser = _lastMessageUser;
        if (lastUser != null) {
          _lastWordsBeforeNextAfter12h[lastUser] =
              (_lastWordsBeforeNextAfter12h[lastUser] ?? 0) + 1;
        }
      }
      if (timeDiffHours >= _breakIceSilenceHours) {
        _breakIceStartersAfter2d[user] = (_breakIceStartersAfter2d[user] ?? 0) + 1;
      }
    } else {
      _conversationStarters[user] = (_conversationStarters[user] ?? 0) + 1;
      _conversationStartersAfter12h[user] =
          (_conversationStartersAfter12h[user] ?? 0) + 1;
    }
    _lastMessageTime = messageTime;
    _lastMessageUser = user;
  }

  void _flushOpenMessage({required bool isFinal}) {
    final m = _openMessage;
    if (m == null) return;

    _processMediaPatterns(m.text, m.user);

    if (!ExportPhraseCatalog.isStatSkippedMessageBody(m.text)) {
      _recordConsecutiveAndMaybeFirst(m);
      _incrementHourlyAndBands(m);
      _accumulateWordsAndQuestions(m);
    }

    if (!isFinal) {
      _openMessage = null;
    }
  }

  void _startNewMessage(ParsedMessageHeader parsed) {
    final date = parsed.isoDate;
    final hour = parsed.hour;
    final minute = parsed.minute;
    final second = parsed.second;
    final user = parsed.user;
    final text = parsed.text;

    _participants.add(user);

    final messageTime = DateTime.parse(
      '$date ${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}:'
      '${second.toString().padLeft(2, '0')}',
    ).millisecondsSinceEpoch;

    _applyConversationGaps(messageTime: messageTime, user: user);

    _openMessage = _OpenMessage(
      date: date,
      user: user,
      hour: hour,
      timeBandLabel: TimeBand.forHour(hour),
      year: parsed.year,
      text: text,
    );
  }

  void _handleLine(String line) {
    final trimmedLine = line.trim();

    if (ExportPhraseCatalog.isEndToEndEncryptionNoticeLine(trimmedLine)) {
      return;
    }

    if (ExportPhraseCatalog.lineMentionsGroupLeave(trimmedLine)) {
      final parsed = parseMessageHeader(trimmedLine);
      if (parsed == null) {
        final name = GroupLeaveLineParser.tryParseLeftParticipantName(trimmedLine);
        if (name != null) {
          _leftParticipants.add(name);
        }
        return;
      }
    }

    final parsed = parseMessageHeader(trimmedLine);

    if (parsed != null) {
      _flushOpenMessage(isFinal: false);
      _startNewMessage(parsed);
    } else if (_openMessage != null) {
      _openMessage!.text += '\n$trimmedLine';
    }
  }

  WhatsAppData _assembleResult() {
    final allParticipants = _participants.toList();
    final participantsArray =
        allParticipants.where((p) => !_leftParticipants.contains(p)).toList();

    String? dayWithMostMessages;
    var dayWithMostMessagesCount = 0;
    for (final entry in _dailyMessageCounts.entries) {
      if (entry.value > dayWithMostMessagesCount) {
        dayWithMostMessages = entry.key;
        dayWithMostMessagesCount = entry.value;
      }
    }

    String? monthWithMostMessages;
    var monthWithMostMessagesCount = 0;
    for (final entry in _monthlyMessageCounts.entries) {
      if (entry.value > monthWithMostMessagesCount) {
        monthWithMostMessages = entry.key;
        monthWithMostMessagesCount = entry.value;
      }
    }

    var longestStreak = 0;
    var currentStreak = 0;
    String? lastDate;

    final datesWithMessages = _dailyMessageCounts.keys.toList()..sort();

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

    final wordStatsByYearFinal = <String, Map<String, int>>{};
    for (final entry in _wordStats.entries) {
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

    final topWordByLengthByParticipant = <String, Map<int, String>>{};
    for (final participant in participantsArray) {
      final byLen = <int, String>{};
      final partStats = _wordStatsByParticipant[participant];
      if (partStats != null) {
        for (var len = 14; len >= 4; len--) {
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

    final topWordByLength = <int, String>{};
    for (var len = 14; len >= 4; len--) {
      final key = '${len}_letters';
      final globalCount = <String, int>{};
      for (final participant in participantsArray) {
        final partStats = _wordStatsByParticipant[participant];
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

    final emojiStatsByParticipantFinal = <String, List<EmojiStat>>{};

    for (final entry in _emojiStatsByParticipant.entries) {
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

    final averageResponseTimes = <String, String>{};

    for (final entry in _responseTimes.entries) {
      final participant = entry.key;
      final times = entry.value;
      if (times.isNotEmpty) {
        final averageMinutes =
            times.reduce((sum, time) => sum + time) / times.length;
        averageResponseTimes[participant] = _formatAverageResponse(averageMinutes);
      } else {
        averageResponseTimes[participant] = '0:00';
      }
    }

    final firstMessageDate =
        datesWithMessages.isNotEmpty ? datesWithMessages.first : null;

    return WhatsAppData(
      participants: participantsArray,
      leftParticipants: _leftParticipants.toList(),
      totalParticipantsWhoLeft: _leftParticipants.length,
      groupNameFromExport: _groupNameFromExport,
      groupRenameCount: _groupRenameCount,
      firstMessageDate: firstMessageDate,
      firstMessageUser: _firstMessageUser,
      firstMessageText: _firstMessageText,
      participantMessageCounts: _participantMessageCounts,
      timeRangeCounts: _timeRangeCounts,
      dayOfWeekTimeBandCounts: _dayOfWeekTimeBandCounts,
      hourlyMessageCounts: _hourlyMessageCounts,
      dailyMessageCounts: _dailyMessageCounts,
      monthlyMessageCounts: _monthlyMessageCounts,
      dayWithMostMessages: dayWithMostMessages,
      dayWithMostMessagesCount: dayWithMostMessagesCount,
      monthWithMostMessages: monthWithMostMessages,
      monthWithMostMessagesCount: monthWithMostMessagesCount,
      longestStreak: longestStreak,
      conversationStarters: _conversationStarters,
      conversationStartersAfter12h: _conversationStartersAfter12h,
      lastWordsBeforeNextAfter12h: _lastWordsBeforeNextAfter12h,
      breakIceStartersAfter2d: _breakIceStartersAfter2d,
      averageResponseTimes: averageResponseTimes,
      quickResponseCounts: _quickResponseCounts,
      participantWordTotals: _participantWordTotals,
      nightOwlMessageCounts: _nightOwlMessageCounts,
      earlyBirdMessageCounts: _earlyBirdMessageCounts,
      mostConsecutiveMessages: _mostConsecutiveMessages,
      mostConsecutiveUser: _mostConsecutiveUser,
      mostConsecutiveDate: _mostConsecutiveDate,
      emojiStatsByParticipant: emojiStatsByParticipantFinal,
      emojiTotalByParticipant: _emojiTotalByParticipant,
      wordStatsByYear: wordStatsByYearFinal,
      totalUniqueWords: _uniqueWords.length,
      topWordByLengthByParticipant: topWordByLengthByParticipant,
      topWordByLength: topWordByLength,
      totalQuestions: _totalQuestions,
      questionsByParticipant: _questionsByParticipant,
      deletedMessagesByParticipant: _deletedMessagesByParticipant,
      editedMessagesByParticipant: _editedMessagesByParticipant,
      multimediaByParticipant: _multimediaByParticipant,
      locationsByParticipant: _locationsByParticipant,
      contactsByParticipant: _contactsByParticipant,
      oneTimePhotosByParticipant: _oneTimePhotosByParticipant,
      sharedUrlsByParticipant: _sharedUrlsByParticipant,
    );
  }
}
