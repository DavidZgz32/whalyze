import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'wrapped_intro_shared.dart';
import '../../whatsapp_processor.dart';

class WrappedGroupFifthScreen extends StatefulWidget {
  final WhatsAppData data;
  final int totalScreens;
  final ValueChanged<int>? onGroupScreenAnimationsComplete;

  const WrappedGroupFifthScreen({
    super.key,
    required this.data,
    required this.totalScreens,
    this.onGroupScreenAnimationsComplete,
  });

  @override
  State<WrappedGroupFifthScreen> createState() =>
      _WrappedGroupFifthScreenState();
}

class _WrappedGroupFifthScreenState extends State<WrappedGroupFifthScreen>
    with TickerProviderStateMixin {
  late final AnimationController _appearCtrl;
  Animation<double> _dayOpacity = const AlwaysStoppedAnimation(0.0);
  Animation<double> _monthOpacity = const AlwaysStoppedAnimation(0.0);
  Animation<Offset> _dayOffset =
      const AlwaysStoppedAnimation(Offset(0, 0.06));
  Animation<Offset> _monthOffset =
      const AlwaysStoppedAnimation(Offset(0, 0.06));

  @override
  void initState() {
    super.initState();

    _appearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dayOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
      ),
    );
    _monthOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
      ),
    );
    _dayOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
      ),
    );
    _monthOffset =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(
      CurvedAnimation(
        parent: _appearCtrl,
        curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
      ),
    );
    _appearCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onGroupScreenAnimationsComplete?.call(4);
      }
    });

    _appearCtrl.forward();
  }

  @override
  void dispose() {
    _appearCtrl.dispose();
    super.dispose();
  }

  static const _monthNames = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String _formatDate(String dateKey) {
    // dateKey formato: "YYYY-MM-DD"
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final day = int.tryParse(parts[2]);
    final monthNum = int.tryParse(parts[1]);
    final year = parts[0];
    if (day == null || monthNum == null || monthNum < 1 || monthNum > 12) {
      return dateKey;
    }
    return '$day de ${_monthNames[monthNum - 1]} de $year';
  }

  String _formatMonth(String monthKey) {
    // monthKey formato: "YYYY-MM"
    final parts = monthKey.split('-');
    if (parts.length != 2) return monthKey;
    final monthNum = int.tryParse(parts[1]);
    final year = parts[0];
    if (monthNum == null || monthNum < 1 || monthNum > 12) return monthKey;
    return '${_monthNames[monthNum - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top +
        (widget.totalScreens * 4) +
        ((widget.totalScreens - 1) * 2) +
        60;
    // "Creado con Whalyze" vive por debajo en el `Stack` del slideshow.
    // Dejamos margen extra para que no se corte en móviles pequeños.
    final bottomPadding = MediaQuery.of(context).padding.bottom + 64;

    final scale = (screenWidth / 360).clamp(0.9, 1.15);

    final dayKey = widget.data.dayWithMostMessages;
    final dayCount = widget.data.dayWithMostMessagesCount;
    final monthKey = widget.data.monthWithMostMessages;
    final monthCount = widget.data.monthWithMostMessagesCount;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding + 4,
          left: 22,
          right: 22,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (dayKey != null && dayCount > 0)
                      FadeTransition(
                        opacity: _dayOpacity,
                        child: SlideTransition(
                          position: _dayOffset,
                          child: _StatCard(
                            title: 'EL DÍA QUE MÁS SE HABLÓ',
                            dateText: _formatDate(dayKey),
                            count: dayCount,
                            scale: scale,
                          ),
                        ),
                      ),
                    if (dayKey != null &&
                        dayCount > 0 &&
                        monthKey != null &&
                        monthCount > 0)
                      const SizedBox(height: 16),
                    if (monthKey != null && monthCount > 0)
                      FadeTransition(
                        opacity: _monthOpacity,
                        child: SlideTransition(
                          position: _monthOffset,
                          child: _StatCard(
                            title: 'EL MES QUE MÁS SE HABLÓ',
                            dateText: _formatMonth(monthKey),
                            count: monthCount,
                            scale: scale,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String dateText;
  final int count;
  final double scale;

  const _StatCard({
    required this.title,
    required this.dateText,
    required this.count,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final countFont = 40.0 * scale;
    final dateFont = 20.0 * scale;
    final titleFont = 18.0 * scale;
    final labelFont = 16.0 * scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: titleFont,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: dateFont,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                WrappedIntroShared.formatThousands(count),
                style: GoogleFonts.poppins(
                  fontSize: countFont,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'mensajes',
                style: GoogleFonts.poppins(
                  fontSize: labelFont,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
