import 'package:flutter/material.dart';
import 'models/wrapped_model.dart';
import 'whatsapp_processor.dart';
import 'wrapped_slideshow.dart';

class WrappedViewScreen extends StatefulWidget {
  final WrappedModel wrapped;

  const WrappedViewScreen({
    super.key,
    required this.wrapped,
  });

  @override
  State<WrappedViewScreen> createState() => _WrappedViewScreenState();
}

class _WrappedViewScreenState extends State<WrappedViewScreen> {
  WhatsAppData? _data;

  @override
  void initState() {
    super.initState();
    _data = WhatsAppData.fromJson(widget.wrapped.data);
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
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
