import 'whatsapp_processor.dart';

/// Una fila de rol en la pantalla 3 del Wrapped grupal (`wrapped_group_third_screen.dart`).
class GroupRoleDisplay {
  final String emoji;
  final String title;
  final String description;
  final String? winnerName;

  const GroupRoleDisplay({
    required this.emoji,
    required this.title,
    required this.description,
    required this.winnerName,
  });
}

int _sumForParticipants(Map<String, int> m, List<String> participants) {
  var s = 0;
  for (final p in participants) {
    s += m[p] ?? 0;
  }
  return s;
}

/// Reparte [total] en enteros ≥0 según pesos de [weights] (método del mayor resto).
Map<String, int> _allocateProportional(
  List<String> participants,
  int total,
  Map<String, int> weights,
) {
  var sumW = 0;
  for (final p in participants) {
    sumW += weights[p] ?? 0;
  }
  if (sumW == 0 || total <= 0) {
    return {for (final p in participants) p: 0};
  }
  final quotas = participants
      .map((p) => total * (weights[p] ?? 0) / sumW)
      .toList();
  final ints = quotas.map((q) => q.floor()).toList();
  final assigned = ints.fold<int>(0, (a, b) => a + b);
  var rem = total - assigned;
  final fracs =
      List<double>.generate(participants.length, (i) => quotas[i] - ints[i]);
  final order = List<int>.generate(participants.length, (i) => i)
    ..sort((a, b) => fracs[b].compareTo(fracs[a]));
  for (var k = 0; k < rem; k++) {
    ints[order[k]]++;
  }
  return {for (var i = 0; i < participants.length; i++) participants[i]: ints[i]};
}

int _globalNightCount(WhatsAppData data) {
  final h = data.hourlyMessageCounts;
  if (h.length < 24) return 0;
  var n = 0;
  for (var i = 0; i < 24; i++) {
    if (i >= 20 || i < 6) n += h[i];
  }
  return n;
}

int _globalMorningCount(WhatsAppData data) {
  final h = data.hourlyMessageCounts;
  if (h.length < 24) return 0;
  var n = 0;
  for (var i = 6; i < 12; i++) {
    n += h[i];
  }
  return n;
}

Map<String, int> _effectiveNightOwl(WhatsAppData data) {
  if (_sumForParticipants(data.nightOwlMessageCounts, data.participants) > 0) {
    return data.nightOwlMessageCounts;
  }
  final total = _globalNightCount(data);
  return _allocateProportional(
    data.participants,
    total,
    data.participantMessageCounts,
  );
}

Map<String, int> _effectiveEarlyBird(WhatsAppData data) {
  if (_sumForParticipants(data.earlyBirdMessageCounts, data.participants) > 0) {
    return data.earlyBirdMessageCounts;
  }
  final total = _globalMorningCount(data);
  return _allocateProportional(
    data.participants,
    total,
    data.participantMessageCounts,
  );
}

Map<String, int> _effectiveWordTotals(WhatsAppData data) {
  if (_sumForParticipants(data.participantWordTotals, data.participants) > 0) {
    return data.participantWordTotals;
  }
  // Sin totales por persona (p. ej. favorito guardado antes del campo): proxy proporcional a mensajes.
  return Map<String, int>.from(data.participantMessageCounts);
}

Map<String, int> _effectiveLongSilenceStarters(WhatsAppData data) {
  if (_sumForParticipants(
        data.conversationStartersAfter12h,
        data.participants,
      ) >
      0) {
    return data.conversationStartersAfter12h;
  }
  if (_sumForParticipants(data.conversationStarters, data.participants) > 0) {
    return data.conversationStarters;
  }
  return {};
}

/// Calcula los seis roles. Reglas de medición: `WRAPPED_DATOS.md` §8b.
/// La UI solo muestra [GroupRoleDisplay.description] (una frase corta).
List<GroupRoleDisplay> buildGroupRoleDisplays(WhatsAppData data) {
  final order = data.participants;
  final night = _effectiveNightOwl(data);
  final morning = _effectiveEarlyBird(data);
  final words = _effectiveWordTotals(data);
  final longSilence = _effectiveLongSilenceStarters(data);

  final usedRealWordTotals =
      _sumForParticipants(data.participantWordTotals, order) > 0;

  String? maxKey(
    Map<String, int> counts, {
    Set<String> exclude = const {},
  }) {
    var bestVal = -1;
    String? best;
    for (final p in order) {
      if (exclude.contains(p)) continue;
      final v = counts[p] ?? 0;
      if (v > bestVal) {
        bestVal = v;
        best = p;
      }
    }
    if (bestVal <= 0) return null;
    return best;
  }

  String? minAvgWordsParticipant(Map<String, int> wordTotals) {
    String? bestP;
    var bestAvg = double.infinity;
    for (final p in order) {
      final msgs = data.participantMessageCounts[p] ?? 0;
      if (msgs == 0) continue;
      final w = wordTotals[p] ?? 0;
      final avg = w / msgs;
      if (avg < bestAvg - 1e-9) {
        bestAvg = avg;
        bestP = p;
      } else if (bestP != null && (avg - bestAvg).abs() < 1e-9) {
        if (order.indexOf(p) < order.indexOf(bestP)) {
          bestP = p;
        }
      }
    }
    return bestP;
  }

  /// Cuando no hay `participantWordTotals` reales, todos tienen la misma media con el proxy → usamos quien menos mensajes.
  String? minMessageCountParticipantExcluding(Set<String> exclude) {
    String? bestP;
    var bestM = 1 << 30;
    for (final p in order) {
      if (exclude.contains(p)) continue;
      final m = data.participantMessageCounts[p] ?? 0;
      if (m <= 0) continue;
      if (m < bestM) {
        bestM = m;
        bestP = p;
      } else if (m == bestM && bestP != null) {
        if (order.indexOf(p) < order.indexOf(bestP)) {
          bestP = p;
        }
      }
    }
    return bestP;
  }

  final mvp = maxKey(data.participantMessageCounts);
  final mvpExclude = mvp != null ? <String>{mvp} : <String>{};

  final asesino = usedRealWordTotals
      ? minAvgWordsParticipant(words)
      : minMessageCountParticipantExcluding({});

  return [
    GroupRoleDisplay(
      emoji: '⭐',
      title: 'MVP',
      description: 'Quién más mensajes ha enviado.',
      winnerName: mvp,
    ),
    GroupRoleDisplay(
      emoji: '🦉',
      title: 'El búho',
      description: 'Más mensajes por la noche.',
      winnerName: maxKey(night, exclude: mvpExclude),
    ),
    GroupRoleDisplay(
      emoji: '🥷',
      title: 'Asesino silencioso',
      description: 'Menos palabras de media por mensaje.',
      winnerName: asesino,
    ),
    GroupRoleDisplay(
      emoji: '🌅',
      title: 'Madrugador/a del grupo',
      description: 'Más mensajes por la mañana.',
      winnerName: maxKey(morning, exclude: mvpExclude),
    ),
    GroupRoleDisplay(
      emoji: '🎙️',
      title: 'La voz del grupo',
      description: 'Quién más palabras ha escrito.',
      winnerName: maxKey(words),
    ),
    GroupRoleDisplay(
      emoji: '💬',
      title: 'Hola chic@s',
      description: 'Quién más rompe el silencio del grupo.',
      winnerName: maxKey(longSilence),
    ),
  ];
}
