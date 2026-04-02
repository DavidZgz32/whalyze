import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/participant_utils.dart';
import '../../wrapped_group_roles.dart';
import 'wrapped_group_second_screen.dart';

class WrappedGroupRoleCard extends StatelessWidget {
  static const Color _cardBackground = Color(0xFF334155);

  final GroupRoleDisplay role;
  final Color cardColor;

  const WrappedGroupRoleCard({
    required this.role,
    this.cardColor = _cardBackground,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final name = role.winnerName;
    final nameText = name == null || name.isEmpty
        ? '—'
        : WrappedGroupSecondScreen.shortParticipantName(name);

    final accentColor = name == null || name.isEmpty
        ? Colors.white.withOpacity(0.18)
        : getParticipantColor(name);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(
            color: accentColor,
            width: 3,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role.emoji,
              style: const TextStyle(fontSize: 28, height: 1.1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 108),
              child: Text(
                nameText,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

