import 'package:flutter/material.dart';

/// Genera un color consistente para cada participante (misma lógica en todas las pantallas).
Color getParticipantColor(String participant) {
  final hash = participant.hashCode;
  final hue = (hash.abs() % 360).toDouble();
  return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
}

/// Obtiene las iniciales del nombre (1 o 2 letras).
String getParticipantInitials(String name) {
  if (name.isEmpty) return '?';

  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  } else if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
}
