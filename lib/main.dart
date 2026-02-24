import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wrapped_screen.dart';
import 'services/wrapped_storage.dart';
import 'favorites_screen.dart';
import 'privacy_screen.dart';
import 'onboarding_preferences.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
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

/// Canal para leer archivo compartido (abrir con Whalyze desde WhatsApp, etc.).
const _fileChannel = MethodChannel('com.whalyze.wra5/file');

/// Decide si mostrar onboarding o pantalla principal al arrancar.
/// Si la app se abre con un zip/archivo desde fuera (p. ej. WhatsApp), se salta el onboarding y se va al wrapped.
class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool? _onboardingDone;
  String? _initialFilePath;

  @override
  void initState() {
    super.initState();
    _resolveStart();
  }

  Future<void> _resolveStart() async {
    final done = await OnboardingPreferences.hasCompletedOnboarding();
    await Future.delayed(const Duration(milliseconds: 300));
    String? sharedPath;
    try {
      final path = await _fileChannel.invokeMethod<String>('getSharedFile');
      if (path != null && path.isNotEmpty) sharedPath = path;
    } catch (_) {}
    if (!mounted) return;
    if (sharedPath != null) {
      await OnboardingPreferences.setOnboardingDone();
      setState(() {
        _onboardingDone = true;
        _initialFilePath = sharedPath;
      });
    } else {
      setState(() => _onboardingDone = done);
    }
  }

  void _goToHome() {
    if (!mounted) return;
    setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F2FF),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00C980),
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (_onboardingDone!) {
      return HomeScreen(initialFilePath: _initialFilePath);
    }
    return OnboardingScreen(onFinish: _goToHome);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialFilePath});

  /// Si la app se abrió con un archivo (p. ej. zip desde WhatsApp), se abre el wrapped directamente.
  final String? initialFilePath;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _channel = MethodChannel('com.whalyze.wra5/file');
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFilePath != null) {
        _processFile(widget.initialFilePath!);
      } else {
        _checkInitialSharedFile();
      }
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

  Future<void> _showEmailPopup(
    BuildContext context, {
    required String titulo,
    required String subject,
  }) async {
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            titulo,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Se abrirá tu cliente de correo para enviar un email a info@whalyze.com.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: GoogleFonts.poppins()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Abrir correo', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      final uri = Uri.parse(
        'mailto:info@whalyze.com?subject=${Uri.encodeComponent(subject)}',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el cliente de correo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                '1. Ve a WhatsApp.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '2. Abre la conversación que quieras.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '3. Menú (⋮) → Exportar chat.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '4. Abre el archivo con Whalyze.',
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tus datos se procesan en el propio teléfono.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
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

  /// Si el archivo es .zip, descomprime con flutter_archive (APIs nativas) y devuelve el .txt interno.
  /// Si no, devuelve el contenido del archivo como texto.
  Future<String> _readChatContentFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('El archivo no existe');
    }
    final bytes = await file.readAsBytes();
    final isZip = filePath.toLowerCase().endsWith('.zip') ||
        (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B);
    if (isZip) {
      final tempDir = await Directory.systemTemp.createTemp('whalyze_zip');
      try {
        await ZipFile.extractToDirectory(
          zipFile: file,
          destinationDir: tempDir,
          onExtracting: (zipEntry, progress) {
            return zipEntry.name.toLowerCase().endsWith('.txt')
                ? ZipFileOperation.includeItem
                : ZipFileOperation.skipItem;
          },
        );
        final txtFile = _findFirstTxtFile(tempDir);
        if (txtFile == null) {
          throw Exception('El ZIP no contiene ningún archivo .txt');
        }
        return await txtFile.readAsString();
      } finally {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }
    }
    return file.readAsString();
  }

  File? _findFirstTxtFile(Directory dir) {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.txt')) {
        return entity;
      }
    }
    return null;
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
          final content = await _readChatContentFromFile(filePath);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WrappedScreen(
                filePath: filePath,
                fileContent: content,
              ),
            ),
          );
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
        builder: (context) => const WrappedScreen(
          filePath: 'demo',
          fileContent: _demoChatContent,
        ),
      ),
    );
  }

  Widget _buildBlurb(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2E8B57), size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processFile(String filePath) async {
    try {
      String pathToRead = filePath;
      // Si nos pasan content:// (p. ej. al abrir con Whalyze), Android copia a temp y nos devuelve la ruta
      if (filePath.startsWith('content://')) {
        final String? tempPath =
            await _channel.invokeMethod('readContentUri', {'uri': filePath});
        if (tempPath == null || tempPath.isEmpty) {
          throw Exception('No se pudo leer el archivo desde content URI');
        }
        pathToRead = tempPath;
      }
      final content = await _readChatContentFromFile(pathToRead);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WrappedScreen(
              filePath: pathToRead,
              fileContent: content,
            ),
          ),
        );
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
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF0D3D0D),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(
                  'Privacidad',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyScreen(),
                    ),
                  );
                },
              ),
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
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      )
                      .then((_) => setState(() {}));
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
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(
                  'Sugerir una mejora',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEmailPopup(
                    context,
                    titulo: 'Sugerir una mejora',
                    subject: 'Sugerencia de mejora',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(
                  'Reportar bug',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEmailPopup(
                    context,
                    titulo: 'Reportar bug',
                    subject: 'Reporte de bug',
                  );
                },
              ),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(
                  'Salir',
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
          color: Colors.black,
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
            icon: const Icon(Icons.menu),
            color: Colors.black,
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
                    'Convierte tus chats\nen un Wrapped',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
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
                  const SizedBox(height: 4),
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF1B5E20),
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
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
                  const SizedBox(height: 18),
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
                  const Spacer(flex: 1),
                  // Blurbs: Sin registro, Privado y seguro, 100% gratis
                  Transform.translate(
                    offset: const Offset(0, -1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBlurb(
                              Icons.check_circle_outline, 'Sin registro'),
                          const SizedBox(height: 12),
                          _buildBlurb(Icons.lock_outline, 'Privado y seguro'),
                          const SizedBox(height: 12),
                          _buildBlurb(
                              Icons.sentiment_satisfied_alt, '100% gratis'),
                        ],
                      ),
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
