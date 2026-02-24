import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F2FF),
        elevation: 0,
        title: Text(
          'Privacidad',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tu privacidad es lo primero.',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D3D0D),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Whalyze procesa tus conversaciones directamente en tu dispositivo. El contenido de tus chats no se sube a servidores ni se almacena externamente. No necesitas crear una cuenta ni iniciar sesión para usar la aplicación.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'En caso de compartir un wrapped, se genera un archivo JSON con los datos estadísticos necesarios para construir el resumen visual. Este archivo no incluye el contenido de los mensajes y está pensado para ser anónimo. Únicamente incluye los nombres de pila y la inicial del apellido de los participantes, necesarios para personalizar el wrapped.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ese JSON se almacena de forma temporal y segura, durante un periodo establecido e informado para generar y permitir el acceso al wrapped compartido. Pasado ese periodo, los datos se eliminan automáticamente.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Para cualquier consulta relacionada con privacidad puedes contactarnos en ',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('mailto:info@whalyze.com');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: Text(
                'info@whalyze.com',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D3D0D),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
