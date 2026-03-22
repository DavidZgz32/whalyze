import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

/// Pantalla de demostración con vídeo e Imagen en imagen (Android 8+).
class PipDemoScreen extends StatefulWidget {
  const PipDemoScreen({super.key});

  @override
  State<PipDemoScreen> createState() => _PipDemoScreenState();
}

class _PipDemoScreenState extends State<PipDemoScreen> {
  static const MethodChannel _pipChannel = MethodChannel('com.whalyze.wra5/pip');

  VideoPlayerController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final c = VideoPlayerController.asset('assets/videos/sample.mp4');
      await c.initialize();
      await c.setLooping(true);
      await c.play();
      if (!mounted) return;
      setState(() {
        _controller = c;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _enterPip() async {
    if (!Platform.isAndroid) return;
    try {
      await _pipChannel.invokeMethod<void>('enterPictureInPicture');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo activar Imagen en imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Imagen en imagen',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarContrastEnforced: false,
        ),
        actions: [
          if (Platform.isAndroid)
            IconButton(
              tooltip: 'Imagen en imagen',
              icon: const Icon(Icons.picture_in_picture_alt_outlined),
              onPressed: _enterPip,
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                : _controller != null && _controller!.value.isInitialized
                    ? Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      )
                    : const SizedBox.shrink(),
      ),
    );
  }
}
