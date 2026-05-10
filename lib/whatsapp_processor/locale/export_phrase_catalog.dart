/// Textos, subcadenas y patrones del export de WhatsApp (ES/EN/CA).
///
/// Para añadir gallego, euskera, etc.: extender listas/sets o añadir variantes
/// en un segundo catálogo y combinarlos en la capa de detección — sin tocar
/// la lógica de agregación en [ChatExportSession].
abstract final class ExportPhraseCatalog {
  static final stripBidiMarks = RegExp(r'[\u200E\u200F\u202A-\u202E]');

  /// ES: `cambió el nombre del grupo de "A" a "B"`
  static final groupRenameEs = RegExp(
    r'cambió el nombre del grupo de "([^"]*)" a "([^"]*)"',
    unicode: true,
  );

  /// EN: `changed the group name from "A" to "B"`
  static final groupRenameEn = RegExp(
    r'changed the group name from "([^"]*)" to "([^"]*)"',
    caseSensitive: false,
  );

  static final List<RegExp> groupRenamePatterns = [groupRenameEs, groupRenameEn];

  static const editTagEs = '<Se editó este mensaje.>';
  static const editTagEn = '<This message was edited>';
  static const editTagCa = "<Aquest missatge s'ha editat>";

  /// Frases de «salida del grupo» (mensaje de sistema o mención en texto).
  static bool lineMentionsGroupLeave(String trimmedLine) {
    return trimmedLine.contains('salió del grupo') ||
        trimmedLine.contains('left the group') ||
        trimmedLine.contains('salió del grupo.') ||
        trimmedLine.contains('left the group.');
  }

  static bool isEndToEndEncryptionNoticeLine(String trimmedLine) {
    final lower = trimmedLine.toLowerCase();
    return lower.contains('los mensajes y las llamadas') ||
        lower.contains('messages and calls are end-to-end encrypted');
  }

  /// Líneas que identifican al subidor (mensaje borrado por uno mismo).
  static bool lineIndicatesSelfDeletedForUploaderId(String line) {
    return line.contains('Eliminaste este mensaje') ||
        line.contains('You deleted this message') ||
        line.contains('Has eliminat aquest missatge');
  }

  static final Set<String> selfDeletedByUploaderExact = {
    'Eliminaste este mensaje',
    'Eliminaste este mensaje.',
    'You deleted this message',
    'You deleted this message.',
    'Has eliminat aquest missatge',
    'Has eliminat aquest missatge.',
  };

  static final Set<String> deletedByOtherExact = {
    'Se eliminó este mensaje',
    'Se eliminó este mensaje.',
    'This message was deleted',
    'This message was deleted.',
    "Aquest missatge s'ha eliminat",
    "Aquest missatge s'ha eliminat.",
  };

  static final Set<String> multimediaOmittedExact = {
    '<Multimedia omitido>',
    '<Media omitted>',
    '<Fitxers multimèdia omesos>',
  };

  static bool isStatSkippedMessageBody(String text) {
    return multimediaOmittedExact.contains(text) ||
        selfDeletedByUploaderExact.contains(text) ||
        deletedByOtherExact.contains(text) ||
        text == '' ||
        text == 'null';
  }

  static bool textContainsEditMarker(String text) {
    return text.contains(editTagEs) ||
        text.contains(editTagEn) ||
        text.contains(editTagCa);
  }

  /// Cada aparición del marcador de edición en el cuerpo (+1 al contador de editados).
  static int countEditMarkersInText(String trimmedText) {
    return editTagEs.allMatches(trimmedText).length +
        editTagEn.allMatches(trimmedText).length +
        editTagCa.allMatches(trimmedText).length;
  }

  static bool isDisappearingPhotoPlaceholder(String trimmed) =>
      trimmed == 'null' || trimmed == '';

  static const tokenStoplistLowercase = {'http', 'https', 'www', 'eliminaste', 'deleted'};

  static bool looksLikeLocationShare(String trimmed) {
    return trimmed.contains('ubicación:') ||
        trimmed.contains('location:') ||
        trimmed.contains('ubicació:');
  }

  static bool hasMapsLink(String trimmed) {
    return trimmed.contains('maps.google.com') ||
        trimmed.contains('goo.gl/maps') ||
        trimmed.contains('maps.app.goo.gl');
  }

  static bool looksLikeContactAttachment(String trimmed) {
    return trimmed.contains('.vcf') &&
        (trimmed.contains('(archivo adjunto)') ||
            trimmed.contains('(file attached)') ||
            trimmed.contains('(fitxer adjunt)'));
  }
}
