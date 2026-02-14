import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
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
          titleTextStyle: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
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
  int _selectedIndex = 0; // Whalyze expandido por defecto
  static const MethodChannel _channel = MethodChannel('com.example.wra5/file');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = ['Whalyze', 'Detectar red flags', 'Roast me'];

  final List<List<Color>> _gradientColors = [
    [const Color(0xFF00C980), const Color(0xFF00A6B6)], // Whalyze
    [const Color(0xFFFF3B30), const Color(0xFFFF6B8A)], // Detectar red flags
    [const Color(0xFFA2713F), const Color(0xFFE3B87A)], // Roast me
  ];

  final List<String> _buttonTexts = [
    'Hacer mi Whalyze',
    'Hacer mi Red Flags',
    'Hacer mi Roast',
  ];

  final List<String> _descriptions = [
    'Genera un resumen divertido con cualquier conversación de whatsapp!',
    'Detecta redflags con IA y crea un resumen divertido',
    'Crea mi roast me al estilo americano',
  ];

  final List<String> _costs = [
    'Gratuito',
    'Coste: 1,99€',
    'Coste: 1,99€',
  ];

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
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Botón WHALYZE
                _buildServiceButton(
                  context: context,
                  title: 'WHALYZE',
                  gradientColors: _gradientColors[0],
                  cost: 'Gratuito',
                  lineCount: lineCount,
                  fileContent: fileContent,
                  filePath: filePath,
                ),
                const SizedBox(height: 16),
                // Botón DETECTAR RED FLAGS
                _buildServiceButton(
                  context: context,
                  title: 'DETECTAR RED FLAGS',
                  gradientColors: _gradientColors[1],
                  cost: '1,99€',
                  lineCount: lineCount,
                  fileContent: fileContent,
                  filePath: filePath,
                ),
                const SizedBox(height: 16),
                // Botón ROAST ME
                _buildServiceButton(
                  context: context,
                  title: 'ROAST ME',
                  gradientColors: _gradientColors[2],
                  cost: '1,99€',
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
                  fontWeight: FontWeight.w500,
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
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
      backgroundColor: const Color(0xFFF0F4F8),
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
                leading: const Icon(Icons.home_outlined),
                title: Text(
                  'Volver a bienvenida',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Cierra el drawer
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F2FF),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
              setState(() {});
            },
            child: HeroIcon(
              HeroIcons.heart,
              style: HeroIconStyle.outline,
              color: Colors.black87,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'WHALYZE',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.black87,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: List.generate(
              _titles.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < _titles.length - 1 ? 12 : 0,
                ),
                child: _ExpansionItem(
                  title: _titles[index],
                  gradientColors: _gradientColors[index],
                  buttonText: _buttonTexts[index],
                  description: _descriptions[index],
                  cost: _costs[index],
                  isExpanded: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = _selectedIndex == index ? -1 : index;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpansionItem extends StatefulWidget {
  final String title;
  final List<Color> gradientColors;
  final String buttonText;
  final String description;
  final String cost;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpansionItem({
    required this.title,
    required this.gradientColors,
    required this.buttonText,
    required this.description,
    required this.cost,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_ExpansionItem> createState() => _ExpansionItemState();
}

class _ExpansionItemState extends State<_ExpansionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_ExpansionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                've a whatsapp -> la conversación que quieras -> exportar -> abrir con Whalyze',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'o también puedes seleccionar el archivo desde aquí:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        final filePath = result.files.single.path!;
                        Navigator.of(context).pop();

                        // Leer el contenido del archivo
                        try {
                          final file = File(filePath);
                          if (await file.exists()) {
                            final content = await file.readAsString();
                            // Navegar a pantallas Wrapped
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WrappedScreen(
                                  filePath: filePath,
                                  fileContent: content,
                                ),
                              ),
                            );
                          } else {
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
                        } catch (e) {
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
                    } catch (e) {
                      // Manejo de errores del plugin
                      Navigator.of(context).pop();
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cerrar',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título clickeable
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: widget.isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    )
                  : BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: widget.isExpanded
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (widget.title == 'Detectar red flags' ||
                          widget.title == 'Roast me')
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'IA',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: widget.isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Contenido expandible
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              color: Colors.white,
              border: Border.all(
                color: widget.gradientColors[0],
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón Ver más
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Ver más',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón Hacer mi X
                  ElevatedButton(
                    onPressed: () {
                      _showExportDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.gradientColors[0],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      widget.buttonText,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Coste
                  Text(
                    widget.cost,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: widget.title == 'Whalyze'
                          ? const Color(0xFF9D4EDD)
                          : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
