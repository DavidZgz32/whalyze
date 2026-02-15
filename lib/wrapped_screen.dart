import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'whatsapp_processor.dart';
import 'services/wrapped_storage.dart';
import 'models/wrapped_model.dart';
import 'wrapped_slideshow.dart';

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

class _WrappedScreenState extends State<WrappedScreen> {
  WhatsAppData? _data;
  bool _hasBeenSaved = false;

  @override
  void initState() {
    super.initState();
    _data = WhatsAppProcessor.processFile(widget.fileContent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!_hasBeenSaved && _data != null && mounted) {
          _saveWrapped();
        }
      });
    });
  }

  Future<void> _saveWrapped() async {
    if (_hasBeenSaved || _data == null) return;

    try {
      _hasBeenSaved = true;
      final wrapped = WrappedModel(
        id: 'wrapped_${DateTime.now().millisecondsSinceEpoch}',
        title: 'WHALYZE ${DateTime.now().year}',
        createdAt: DateTime.now(),
        data: _data!.toJson(),
        participants: _data!.participants,
        totalLines: widget.fileContent.split('\n').length,
      );
      await WrappedStorage.saveWrapped(wrapped);
    } catch (e, stackTrace) {
      print('Error al guardar wrapped: $e');
      print('Stack trace: $stackTrace');
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
    if (!_hasBeenSaved && _data != null) {
      _saveWrapped();
    }
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
      body: WrappedSlideshow(
        data: _data!,
        onClose: () => Navigator.of(context).popUntil((route) => route.isFirst),
        onAllScreensCompleted: _saveWrapped,
      ),
    );
  }
}
