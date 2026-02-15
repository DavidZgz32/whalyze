import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wrapped_screen.dart';
import 'services/wrapped_storage.dart';
import 'favorites_screen.dart';
import 'onboarding_preferences.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WrappedStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whalyze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      home: const AppStart(),
    );
  }
}

/// Decide si mostrar onboarding o pantalla principal al arrancar.
class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    OnboardingPreferences.hasCompletedOnboarding().then((done) {
      if (mounted) setState(() => _onboardingDone = done);
    });
  }

  void _goToHome() {
    if (!mounted) return;
    setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE8F2FF),
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF00C980),
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (_onboardingDone!) {
      return const HomeScreen();
    }
    return OnboardingScreen(onFinish: _goToHome);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _channel = MethodChannel('com.example.wra5/file');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _demoChatContent = '''
01/01/24, 10:00 - Ana: Hola! Qué tal estás?
01/01/24, 10:01 - Luis: Muy bien! Y tú?
01/01/24, 10:02 - Ana: Genial, probando Whalyze 🐋
01/01/24, 10:03 - Luis: Qué divertido! A ver qué sale
01/01/24, 10:05 - Ana: Espero que algo épico
01/01/24, 10:06 - Luis: Sin duda jajaja
01/01/24, 14:00 - Luis: Oye, has visto el resultado?
01/01/24, 14:02 - Ana: Sí! Está genial, lo recomiendo
01/01/24, 14:03 - Luis: 😂😂😂
01/01/24, 14:04 - Ana: 100% de acuerdo
02/01/24, 9:00 - Ana: Buenos días!
02/01/24, 9:15 - Luis: Buenos días! Qué tal dormiste?
02/01/24, 9:20 - Ana: Muy bien, soñé con ballenas
02/01/24, 9:25 - Luis: Jajaja es la app, te ha marcado
''';

  @override
  void initState() {
    super.initState();
    // Esperar a que el widget esté completamente construido antes de verificar el archivo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSharedFile();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkInitialSharedFile() async {
    // Verificar si hay un archivo compartido al iniciar la app
    try {
      // Esperar un poco para que el intent se procese completamente
      await Future.delayed(const Duration(milliseconds: 300));

      final String? filePath = await _channel.invokeMethod('getSharedFile');
      if (filePath != null && filePath.isNotEmpty) {
        // Procesar el archivo (ya viene filtrado por MIME type en AndroidManifest)
        await _processFile(filePath);
      }
    } catch (e) {
      // Si no hay archivo compartido o hay error, continuar normalmente
      print('No hay archivo compartido o error: $e');
    }
  }

  void _showFileOptionsDialog(BuildContext context, int lineCount,
      String fileContent, String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Elige una opción',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                _buildServiceButton(
                  context: context,
                  title: 'WHALYZE',
                  gradientColors: const [Color(0xFF00C980), Color(0xFF00A6B6)],
                  cost: 'Gratuito',
                  lineCount: lineCount,
                  fileContent: fileContent,
                  filePath: filePath,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '¿Cómo exportar un chat?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ve a WhatsApp → la conversación que quieras → Exportar chat → Abrir con Whalyze',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'O selecciona el archivo desde aquí:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _pickAndOpenFile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C980),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Seleccionar archivo',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndOpenFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        try {
          final file = File(filePath);
          if (await file.exists()) {
            final content = await file.readAsString();
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WrappedScreen(
                  filePath: filePath,
                  fileContent: content,
                ),
              ),
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'El archivo no existe',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al leer el archivo: $e',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al seleccionar archivo. Por favor, reinicia la app completamente.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _openDemo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WrappedScreen(
          filePath: 'demo',
          fileContent: _demoChatContent,
        ),
      ),
    );
  }

  Widget _buildBlurb(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2E8B57), size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required BuildContext context,
    required String title,
    required List<Color> gradientColors,
    required String cost,
    required int lineCount,
    required String fileContent,
    required String filePath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        if (title == 'WHALYZE') {
          // Navegar a pantallas Wrapped
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WrappedScreen(
                filePath: filePath,
                fileContent: fileContent,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                '$lineCount líneas abierto con $title',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              backgroundColor: gradientColors[0],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cost,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processFile(String filePath) async {
    try {
      String content;

      // Manejar URIs de content:// (usados por WhatsApp al compartir)
      if (filePath.startsWith('content://')) {
        // Leer desde content URI usando el método channel
        final String? fileContent =
            await _channel.invokeMethod('readContentUri', {'uri': filePath});
        if (fileContent == null) {
          throw Exception('No se pudo leer el archivo desde content URI');
        }
        content = fileContent;
      } else {
        // Leer archivo normal
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('El archivo no existe');
        }
        content = await file.readAsString();
      }

      final lineCount = content.split('\n').length;

      if (mounted) {
        _showFileOptionsDialog(context, lineCount, content, filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFB8E986),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Whalyze',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: Text(
                  'Mis favoritos',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(
                  'Cómo exportar un chat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showExportDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text(
                  'Volver a bienvenida',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OnboardingScreen(
                        onFinish: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.favorite_border),
          color: Colors.white,
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              ),
            );
            setState(() {});
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.white,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo-back.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // Logo: saludo_home (personaje + Whalyze)
                  Image.asset(
                'assets/images/saludo_home.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              // Título
              Text(
                'Convierte tus chats en un Wrapped',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre lo que tus conversaciones\ndicen de ti',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              const Spacer(flex: 1),
              // Botón Subir un chat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showExportDialog(context),
                      borderRadius: BorderRadius.circular(36),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B5E20),
                              blurRadius: 0,
                              spreadRadius: 3,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Subir un chat',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Ver demo
              GestureDetector(
                onTap: _openDemo,
                child: Text(
                  'Ver demo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1B5E20),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF1B5E20),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Blurbs: Sin registro, Privado y seguro, 100% gratis
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildBlurb(Icons.check_circle_outline, 'Sin registro'),
                    const SizedBox(height: 12),
                    _buildBlurb(Icons.lock_outline, 'Privado y seguro'),
                    const SizedBox(height: 12),
                    _buildBlurb(Icons.sentiment_satisfied_alt, '100% gratis'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
