/// Franjas horarias en español (claves de [timeRangeCounts] en datos).
abstract final class TimeBand {
  static const madrugada = 'Madrugada';
  static const manana = 'Mañana';
  static const tarde = 'Tarde';
  static const noche = 'Noche';

  static const indexByName = {
    madrugada: 0,
    manana: 1,
    tarde: 2,
    noche: 3,
  };

  static String forHour(int hour) {
    if (hour >= 0 && hour < 6) {
      return madrugada;
    }
    if (hour >= 6 && hour < 13) {
      return manana;
    }
    if (hour >= 13 && hour < 19) {
      return tarde;
    }
    return noche;
  }
}
