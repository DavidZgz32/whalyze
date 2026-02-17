import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../whatsapp_processor.dart';

/// Pantalla 5 del wrapped: tabla de 3 columnas (título, participante 1, participante 2).
class WrappedFifthScreen extends StatelessWidget {
  final WhatsAppData data;
  final int totalScreens;

  const WrappedFifthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
  });

  /// Inicial del nombre (primera letra del primer token).
  static String initial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    final first = t.split(RegExp(r'\s+')).first;
    if (first.isEmpty) return '?';
    return first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final participants = data.participants;
    final p1 = participants.isNotEmpty ? participants[0] : '—';
    final p2 = participants.length > 1 ? participants[1] : '—';
    final i1 = initial(p1);
    final i2 = initial(p2);

    final topPadding = MediaQuery.of(context).padding.top +
        (totalScreens * 4) +
        ((totalScreens - 1) * 2) +
        60;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;
    const horizontalPadding = 24.0;

    // Filas: título | dato P1 | dato P2
    const quickMinutes = 5;
    final rows = <_RowData>[
      _RowData(
        title: '',
        value1: i1,
        value2: i2,
        isHeader: true,
      ),
      _RowData(
        title: 'Quién inicia más conversaciones',
        value1: '${data.conversationStarters[p1] ?? 0}',
        value2: '${data.conversationStarters[p2] ?? 0}',
      ),
      _RowData(
        title: 'Tiempo medio de respuesta',
        value1: data.averageResponseTimes[p1] ?? '—',
        value2: data.averageResponseTimes[p2] ?? '—',
      ),
      _RowData(
        title: 'Respuestas rápidas (menos de $quickMinutes min)',
        value1: '${data.quickResponseCounts[p1] ?? 0}',
        value2: '${data.quickResponseCounts[p2] ?? 0}',
      ),
      _RowData(
        title: 'Mensajes enviados',
        value1: '${data.participantMessageCounts[p1] ?? 0}',
        value2: '${data.participantMessageCounts[p2] ?? 0}',
      ),
    ];

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          bottom: bottomPadding,
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tú vs ellos',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(0.9),
                    2: FlexColumnWidth(0.9),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    for (final row in rows) _buildTableRow(row),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(_RowData row) {
    final titleStyle = GoogleFonts.poppins(
      fontSize: row.isHeader ? 14 : 13,
      fontWeight: row.isHeader ? FontWeight.w700 : FontWeight.w500,
      color: Colors.white,
      height: 1.3,
    );
    final valueStyle = GoogleFonts.poppins(
      fontSize: row.isHeader ? 16 : 14,
      fontWeight: row.isHeader ? FontWeight.w700 : FontWeight.w500,
      color: Colors.white,
    );
    return TableRow(
      decoration: row.isHeader
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            )
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: Text(
            row.title,
            style: titleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              row.value1,
              style: valueStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              row.value2,
              style: valueStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _RowData {
  final String title;
  final String value1;
  final String value2;
  final bool isHeader;

  _RowData({
    required this.title,
    required this.value1,
    required this.value2,
    this.isHeader = false,
  });
}
