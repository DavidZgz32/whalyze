import 'locale/export_phrase_catalog.dart';

/// Lectura de eventos de cambio de nombre del grupo en el TXT.
abstract final class GroupNameEvents {
  /// Recorre el TXT y devuelve el nombre nuevo de la **última** línea de cambio de nombre.
  static String? extractLastGroupNameFromExport(String content) {
    String? last;
    for (final raw in content.split('\n')) {
      final line = raw.replaceAll(ExportPhraseCatalog.stripBidiMarks, '');
      for (final pattern in ExportPhraseCatalog.groupRenamePatterns) {
        final m = pattern.firstMatch(line);
        if (m != null) {
          final name = m.group(2)?.trim();
          if (name != null && name.isNotEmpty) {
            last = name;
          }
          break;
        }
      }
    }
    return last;
  }

  static int countGroupRenameEventsInExport(String content) {
    var n = 0;
    for (final raw in content.split('\n')) {
      final line = raw.replaceAll(ExportPhraseCatalog.stripBidiMarks, '');
      for (final pattern in ExportPhraseCatalog.groupRenamePatterns) {
        if (pattern.hasMatch(line)) {
          n++;
          break;
        }
      }
    }
    return n;
  }
}
