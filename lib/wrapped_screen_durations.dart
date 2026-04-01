/// Duración en milisegundos de cada pantalla del wrapped **individual**
/// y de la **última** pantalla (índice 8) en el flujo grupal.
///
/// En el flujo **grupal**, los índices 0–7 no usan estos valores: el avance
/// depende de las animaciones de cada pantalla + 1 s de margen. Ver
/// `WRAPPED_GRUPO_DURACION.md` y `wrapped_slideshow.dart`.
/// Modifica estos valores para ajustar cuánto tiempo se muestra cada pantalla.
class WrappedScreenDurations {
  WrappedScreenDurations._();

  /// Índice 0 – Pantalla 1: Bienvenida a tu Whatsapp Wrapped
  static const int pantalla0 = 20000;

  /// Índice 1 – Pantalla 2: Vamos a analizar vuestros mensajes
  static const int pantalla1 = 25000;

  /// Índice 2 – Pantalla 3: Emojis más usados
  static const int pantalla2 = 25000;

  /// Índice 3 – Pantalla 4: ¿Quién mueve el chat?
  static const int pantalla3 = 28000;

  /// Índice 4 – Pantalla 5: Horarios de mensajes (mapas de calor)
  static const int pantalla4 = 22000;

  /// Índice 5 – Pantalla 6: Hitos del chat
  static const int pantalla5 = 28000;

  /// Índice 6 – Pantalla 7: Media
  static const int pantalla6 = 30000;

  /// Índice 7 – Pantalla 8: Palabras más usadas
  static const int pantalla7 = 19000;

  /// Índice 8 – Pantalla 9: Botón de volver (última)
  static const int pantalla8 = 25000;

  static const List<int> _durations = [
    pantalla0,
    pantalla1,
    pantalla2,
    pantalla3,
    pantalla4,
    pantalla5,
    pantalla6,
    pantalla7,
    pantalla8,
  ];

  /// Obtiene la duración en milisegundos para el índice de pantalla dado.
  static int getDurationMs(int screenIndex) {
    if (screenIndex < 0 || screenIndex >= _durations.length) {
      return 20000; // por defecto
    }
    return _durations[screenIndex];
  }
}
