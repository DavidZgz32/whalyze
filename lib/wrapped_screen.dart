import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'whatsapp_processor.dart';
import 'services/wrapped_storage.dart';
import 'models/wrapped_model.dart';

class WrappedScreen extends StatefulWidget {
  final String filePath;
  final String fileContent;

  const WrappedScreen({
    super.key,
    required this.filePath,
    required this.fileContent,
  });

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  WhatsAppData? _data;
  int _currentScreen = 0;
  double _progress = 0.0;
  bool _hasBeenSaved = false; // Flag para evitar guardar múltiples veces

  @override
  void initState() {
    super.initState();
    
    print('WrappedScreen initState - procesando archivo...');
    // Procesar el archivo
    _data = WhatsAppProcessor.processFile(widget.fileContent);
    print('Archivo procesado - totalLines: ${_data?.totalLines}, participants: ${_data?.participants.length}');
    
    // Guardar inmediatamente después de procesar (backup)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('PostFrameCallback - guardando wrapped inmediatamente...');
      Future.delayed(const Duration(seconds: 1), () {
        if (!_hasBeenSaved && _data != null) {
          print('Guardando wrapped en postFrameCallback...');
          _saveWrapped();
        }
      });
    });
    
    // Controlador para la barra de progreso
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.linear,
      ),
    );
    
    // Controlador para fade in/out
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
    
    _progressController.addListener(() {
      setState(() {
        _progress = _progressAnimation.value;
      });
    });
    
    print('Iniciando animación...');
    _startAnimation();
  }

  void _startAnimation() {
    print('_startAnimation() llamado');
    _fadeController.forward();
    _progressController.forward().then((_) {
      print('Animación de progreso completada (10 segundos)');
      // Después de 10 segundos, pasar a la siguiente pantalla
      _fadeController.reverse().then((_) {
        print('Fade out completado, cambiando a pantalla 2');
        setState(() {
          _currentScreen = 1;
        });
        _fadeController.forward();
        // Guardar el wrapped cuando se complete
        print('Animación completada, guardando wrapped...');
        _saveWrapped();
      }).catchError((error) {
        print('Error en fade reverse: $error');
      });
    }).catchError((error) {
      print('Error en progress animation: $error');
    });
  }

  Future<void> _saveWrapped() async {
    // Evitar guardar múltiples veces
    if (_hasBeenSaved) {
      print('_saveWrapped() ya fue llamado anteriormente, saltando...');
      return;
    }
    
    print('_saveWrapped() llamado');
    if (_data == null) {
      print('Error: _data is null, cannot save wrapped');
      return;
    }
    
    print('_data no es null, totalLines: ${_data!.totalLines}, participants: ${_data!.participants.length}');
    
    try {
      // Marcar como guardado antes de empezar para evitar duplicados
      _hasBeenSaved = true;
      
      // Generar ID único con formato wrapped_<timestamp>
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final wrappedId = 'wrapped_$timestamp';
      
      // Obtener el JSON completo con todas las métricas
      final jsonData = _data!.toJson();
      
      print('JSON generado con ${jsonData.keys.length} keys');
      print('Primeros keys del JSON: ${jsonData.keys.take(5).toList()}');
      
      final wrapped = WrappedModel(
        id: wrappedId,
        title: 'WHALYZE ${DateTime.now().year}',
        createdAt: DateTime.now(),
        data: jsonData, // JSON completo con todas las métricas
        participants: _data!.participants,
        totalLines: _data!.totalLines,
      );
      
      print('WrappedModel creado: ${wrapped.id}, título: ${wrapped.title}');
      print('Intentando guardar en WrappedStorage...');
      
      await WrappedStorage.saveWrapped(wrapped);
      print('Wrapped guardado exitosamente: ${wrapped.id}');
      
      // Verificar que se guardó inmediatamente
      await Future.delayed(const Duration(milliseconds: 100));
      final allWrappeds = WrappedStorage.getAllWrappeds();
      print('Total wrappeds guardados después de guardar: ${allWrappeds.length}');
      
      if (allWrappeds.isEmpty) {
        print('ERROR CRÍTICO: El wrapped no aparece después de guardar');
      }
      
      // Mostrar mensaje de confirmación solo si el widget está montado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wrapped guardado en favoritos',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF00C980),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error al guardar wrapped: $e');
      print('Stack trace: $stackTrace');
      // Resetear el flag si falló
      _hasBeenSaved = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar wrapped: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Guardar el wrapped antes de cerrar si no se ha guardado aún
    if (_currentScreen >= 1 && _data != null) {
      print('Dispose llamado - guardando wrapped antes de cerrar...');
      _saveWrapped();
    }
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00C980),
              const Color(0xFF00A6B6),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: _currentScreen == 0
                    ? _buildFirstScreen()
                    : _buildSecondScreen(),
              ),
              // Botón X en la esquina superior derecha
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstScreen() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            '${_data!.totalLines}',
            style: GoogleFonts.inter(
              fontSize: 80,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'líneas',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const Spacer(),
          // Barra de progreso
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSecondScreen() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'Participantes',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          ..._data!.participants.map((participant) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                participant,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

