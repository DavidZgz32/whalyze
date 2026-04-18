import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'wrapped_screen.dart';
import 'services/wrapped_storage.dart';
import 'favorites_screen.dart';
import 'privacy_screen.dart';
import 'onboarding_preferences.dart';
import 'onboarding_screen.dart';
import 'paywall_dialog.dart';
import 'services/firestore_user_service.dart';

Future<void> _initFirebaseAndUser() async {
  try {
    await Firebase.initializeApp();
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    await FirestoreUserService.instance.bootstrap();
    debugPrint(
      'Firebase uid: ${FirebaseAuth.instance.currentUser?.uid ?? "(none)"}',
    );
  } catch (e, stackTrace) {
    debugPrint('Firebase / Firestore bootstrap: $e\n$stackTrace');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseAndUser();
  await MobileAds.instance.initialize();
  // IAP desactivado temporalmente (no se escucha el stream de compras).
  if (Platform.isAndroid) {
    // Edge-to-edge explícito + estilo sin colores de barra (evita setStatusBarColor /
    // setNavigationBarColor deprecados en Android 15+ en el embedding de Flutter).
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
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
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: false,
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _ExportHowToBottomSheet(
            onPickFile: _pickAndOpenFile,
          ),
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
          if (!await guardOpenWrapped(context)) return;
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

  Future<void> _openDemo() async {
    if (!await guardOpenWrapped(context)) return;
    if (!mounted) return;
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

      if (!mounted) return;
      if (!await guardOpenWrapped(context)) return;
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WrappedScreen(
            filePath: pathToRead,
            fileContent: content,
          ),
        ),
      );
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
                  'Mis wrappeds',
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
          tooltip: 'Mis wrappeds',
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
                  // Botón CREAR WRAPPED
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
                                  'CREAR WRAPPED',
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

/// Carrusel de pasos «cómo exportar» dentro del bottom sheet.
class _ExportHowToBottomSheet extends StatefulWidget {
  const _ExportHowToBottomSheet({required this.onPickFile});

  final Future<void> Function() onPickFile;

  @override
  State<_ExportHowToBottomSheet> createState() =>
      _ExportHowToBottomSheetState();
}

class _ExportHowToBottomSheetState extends State<_ExportHowToBottomSheet> {
  static const _stepTexts = <String>[
    'Ve a WhatsApp, abre el chat, pulsa los tres puntos (⋮) y toca “Exportar chat”.',
    'Haz click en "Más"',
    'Selecciona "Sin archivos"',
    'Abre el archivo con Whalyze',
  ];

  static const _tutorialImages = <String>[
    'assets/images/export_tutorial_1.png',
    'assets/images/export_tutorial_2.png',
    'assets/images/export_tutorial_3.png',
    'assets/images/export_tutorial_4.png',
  ];

  late final PageController _imagePageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _stepTexts.length) return;
    setState(() => _pageIndex = index);
    _imagePageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('whatsapp://');
    if (!mounted) return;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo abrir WhatsApp.',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo abrir WhatsApp.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  static const double _stepCircleGap = 6;

  Widget _navArrow({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      color: Colors.black87,
      icon: Icon(icon, size: 28),
      onPressed: onPressed,
    );
  }

  Widget _stepNumberCircle(int step1Based) {
    final i = step1Based - 1;
    final active = i == _pageIndex;
    return GestureDetector(
      onTap: () => _goToPage(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFF00C980) : Colors.white,
          border: Border.all(
            color: active ? const Color(0xFF00C980) : Colors.grey.shade400,
            width: active ? 2 : 1.5,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C980).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          '$step1Based',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.black87,
            height: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.45,
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '¿Cómo exportar un chat?',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepNumberCircle(1),
                const SizedBox(width: _stepCircleGap),
                _stepNumberCircle(2),
                const SizedBox(width: _stepCircleGap),
                _stepNumberCircle(3),
                const SizedBox(width: _stepCircleGap),
                _stepNumberCircle(4),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                _stepTexts[_pageIndex],
                key: ValueKey<int>(_pageIndex),
                textAlign: TextAlign.center,
                style: stepStyle,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _imagePageController,
                    onPageChanged: (i) {
                      if (_pageIndex != i) setState(() => _pageIndex = i);
                    },
                    itemCount: _tutorialImages.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        _tutorialImages[index],
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  if (_pageIndex > 0)
                    _navArrow(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Anterior',
                      onPressed: () => _goToPage(_pageIndex - 1),
                    )
                  else
                    const SizedBox(width: 44),
                  const Spacer(),
                  _navArrow(
                    icon: Icons.arrow_forward_rounded,
                    tooltip: _pageIndex < _stepTexts.length - 1
                        ? 'Siguiente'
                        : 'Abrir WhatsApp',
                    onPressed: () {
                      if (_pageIndex < _stepTexts.length - 1) {
                        _goToPage(_pageIndex + 1);
                      } else {
                        _openWhatsApp();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'También puedes seleccionar el archivo desde aquí:',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.onPickFile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C980),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
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
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 22,
                      color: const Color(0xFF0D2847),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nada se sube ni se comparte: todos los datos se procesan en tu teléfono.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0D2847),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
