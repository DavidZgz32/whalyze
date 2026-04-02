import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'paywall_dialog.dart';
import 'whatsapp_processor.dart';
import 'services/wrapped_storage.dart';
import 'services/firestore_user_service.dart';
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
  bool _consumingSlot = true;
  String? _slotError;

  @override
  void initState() {
    super.initState();
    _data = WhatsAppProcessor.processFile(widget.fileContent);
    _consumeWrappedSlot();
  }

  Future<void> _consumeWrappedSlot() async {
    if (_data == null) {
      if (mounted) setState(() => _consumingSlot = false);
      return;
    }
    try {
      final isGroup = _data!.participants.length > 2;
      await FirestoreUserService.instance.consumeWrappedSlot(isGroup: isGroup);
    } on PaywallRequiredException {
      if (mounted) {
        await showPaywallDialog(context);
        if (mounted) Navigator.of(context).pop();
      }
      return;
    } on DeviceSecurityException {
      if (mounted) {
        await showDeviceSecurityDialog(context);
        if (mounted) Navigator.of(context).pop();
      }
      return;
    } catch (e, st) {
      debugPrint('consumeWrappedSlot: $e\n$st');
      if (mounted) {
        setState(() {
          _slotError = e.toString();
          _consumingSlot = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() => _consumingSlot = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!_hasBeenSaved && _data != null && mounted) {
          _saveWrapped();
        }
      });
    });
  }

  /// Título para favoritos: nombres de participantes hasta 8 letras, ej. "David Per - Miguelit"
  static String _titleFromParticipants(List<String> participants) {
    if (participants.isEmpty) return 'WHALYZE ${DateTime.now().year}';
    const maxLetters = 8;
    final parts = participants
        .map((name) => name.trim().isEmpty
            ? ''
            : name.trim().length <= maxLetters
                ? name.trim()
                : name.trim().substring(0, maxLetters))
        .where((s) => s.isNotEmpty);
    return parts.isEmpty ? 'WHALYZE ${DateTime.now().year}' : parts.join(' - ');
  }

  /// Grupo: nombre del export si hay línea de cambio de nombre; si no, participantes.
  static String favoritesTitle(WhatsAppData data) {
    final isGroup = data.participants.length > 2;
    final group = data.groupNameFromExport?.trim();
    if (isGroup && group != null && group.isNotEmpty) {
      return group;
    }
    return _titleFromParticipants(data.participants);
  }

  Future<void> _saveWrapped() async {
    if (_hasBeenSaved || _data == null) return;

    try {
      _hasBeenSaved = true;
      final wrapped = WrappedModel(
        id: 'wrapped_${DateTime.now().millisecondsSinceEpoch}',
        title: favoritesTitle(_data!),
        createdAt: DateTime.now(),
        data: _data!.toJson(),
        participants: _data!.participants,
        totalLines: widget.fileContent.split('\n').length,
      );
      await WrappedStorage.saveWrapped(wrapped);
    } catch (e, stackTrace) {
      debugPrint('Error al guardar wrapped: $e\n$stackTrace');
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
    if (!_hasBeenSaved && _data != null && !_consumingSlot && _slotError == null) {
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

    if (_consumingSlot) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Preparando tu wrapped…',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_slotError != null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'No se pudo confirmar tu cuenta',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _slotError!,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Volver', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
        ),
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
