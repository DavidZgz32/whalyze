/// Duración en milisegundos de cada pantalla del wrapped.
/// Modifica estos valores para ajustar cuánto tiempo se muestra cada pantalla.
class WrappedScreenDurations {
  WrappedScreenDurations._();

  /// Pantalla 0: Bienvenida a tu Whatsapp Wrapped
  static const int pantalla0 = 20000;

  /// Pantalla 1: Vamos a analizar vuestros mensajes
  static const int pantalla1 = 25000;

  /// Pantalla 2: Día / mes con más mensajes
  static const int pantalla2 = 25000;

  /// Pantalla 3: ¿Quién mueve el chat?
  static const int pantalla3 = 28000;

  /// Pantallas 4-7
  static const int pantalla4 = 20000;
  static const int pantalla5 = 20000;
  static const int pantalla6 = 60000;
  static const int pantalla7 = 20000;

  static const List<int> _durations = [
    pantalla0,
    pantalla1,
    pantalla2,
    pantalla3,
    pantalla4,
    pantalla5,
    pantalla6,
    pantalla7,
  ];

  /// Obtiene la duración en milisegundos para el índice de pantalla dado.
  static int getDurationMs(int screenIndex) {
    if (screenIndex < 0 || screenIndex >= _durations.length) {
      return 20000; // por defecto
    }
    return _durations[screenIndex];
  }
}
