import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Pantalla 6 del wrapped: mapa de calor por día de la semana y franja horaria.
/// Arriba: L M X J V S D. Izquierda: Madrugada, Mañana, Tarde, Noche.
class WrappedSixthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedSixthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  @override
  State<WrappedSixthScreen> createState() => WrappedSixthScreenState();
}

class WrappedSixthScreenState extends State<WrappedSixthScreen> {
  static const List<String> _dayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const List<String> _timeLabels = [
    'Madrugada',
    'Mañana',
    'Tarde',
    'Noche',
  ];

  /// Colores estilo WhatsApp Wrapped: de claro a más saturado/verde.
  static const Color _colorMin = Color(0xFFE8F5E9);
  static const Color _colorMid = Color(0xFF00C980);
  static const Color _colorMax = Color(0xFF00796B);

  @override
  Widget build(BuildContext context) {
    final matrix = widget.data.dayOfWeekTimeBandCounts;
    final maxCount = _computeMax(matrix);
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        48;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: MediaQuery.of(context).padding.bottom + 32,
          left: 20,
          right: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Cuándo habláis más?',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mapa de calor por día y franja',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const rowLabelWidth = 72.0;
                  const cellSize = 36.0;
                  const headerHeight = 28.0;
                  final gridWidth = 7 * cellSize;
                  final gridHeight = 4 * cellSize;
                  final totalWidth = rowLabelWidth + gridWidth;
                  final totalHeight = headerHeight + gridHeight;

                  return SizedBox(
                    width: totalWidth,
                    height: totalHeight.clamp(0.0, constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila de días: vacío + L M X J V S D
                        SizedBox(
                          height: headerHeight,
                          child: Row(
                            children: [
                              SizedBox(width: rowLabelWidth),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: 7,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, dayIndex) {
                                    return Center(
                                      child: Text(
                                        _dayLetters[dayIndex],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Filas: etiqueta + 7 celdas
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: 4 * 8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final row = index ~/ 8;
                              final col = index % 8;
                              if (col == 0) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Text(
                                      _timeLabels[row],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }
                              final dayIndex = col - 1;
                              final bandIndex = row;
                              // matrix: 7 días x 4 franjas → matrix[dayIndex][bandIndex]
                              final count = (dayIndex >= 0 &&
                                      dayIndex < 7 &&
                                      bandIndex < 4 &&
                                      dayIndex < matrix.length &&
                                      bandIndex < matrix[dayIndex].length)
                                  ? matrix[dayIndex][bandIndex]
                                  : 0;
                              final t = maxCount > 0 ? count / maxCount : 0.0;
                              final color = _lerpColor(t);
                              return Padding(
                                padding: const EdgeInsets.all(2),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: count > 0
                                        ? Text(
                                            '$count',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: t > 0.5
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _computeMax(List<List<int>> matrix) {
    int max = 0;
    for (final row in matrix) {
      for (final v in row) {
        if (v > max) max = v;
      }
    }
    return max > 0 ? max : 1;
  }

  Color _lerpColor(double t) {
    if (t <= 0) return _colorMin;
    if (t >= 1) return _colorMax;
    if (t < 0.5) {
      return Color.lerp(_colorMin, _colorMid, t * 2)!;
    }
    return Color.lerp(_colorMid, _colorMax, (t - 0.5) * 2)!;
  }
}
