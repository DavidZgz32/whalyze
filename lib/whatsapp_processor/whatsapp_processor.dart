import 'chat_export_session.dart';
import 'group_name_events.dart';
import 'models/whatsapp_data.dart';
import 'parsing/chat_line_regexes.dart';

/// Procesador principal de archivos de WhatsApp.
class WhatsAppProcessor {
  static final androidLineRegex = ChatLineRegexes.androidLineRegex;
  static final iosLineRegex = ChatLineRegexes.iosLineRegex;

  /// Procesa el contenido de un archivo de WhatsApp y extrae información completa
  static WhatsAppData processFile(String content) => ChatExportSession(content).run();

  /// Recorre el TXT y devuelve el nombre nuevo de la **última** línea de cambio de nombre del grupo.
  static String? extractLastGroupNameFromExport(String content) =>
      GroupNameEvents.extractLastGroupNameFromExport(content);

  /// Cuenta cuántas veces aparece un cambio de nombre en el export (mismos patrones ES/EN).
  static int countGroupRenameEventsInExport(String content) =>
      GroupNameEvents.countGroupRenameEventsInExport(content);
}
