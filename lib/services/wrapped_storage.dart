import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/wrapped_model.dart';

class WrappedStorage {
  static const String _boxName = 'wrappeds';
  static Box? _box;

  static Future<void> init() async {
    try {
      print('Inicializando Hive...');
      await Hive.initFlutter();
      print('Hive inicializado, abriendo box: $_boxName');
      _box = await Hive.openBox(_boxName);
      print('Box abierto exitosamente. Keys en box: ${_box?.keys.length ?? 0}');
    } catch (e) {
      print('Error al inicializar Hive: $e');
      rethrow;
    }
  }

  static Future<void> saveWrapped(WrappedModel wrapped) async {
    try {
      if (_box == null) {
        print('Error: Hive box no está inicializado');
        return;
      }
      
      // Usar formato: wrapped_<timestamp> como key
      final key = wrapped.id.startsWith('wrapped_') ? wrapped.id : 'wrapped_${wrapped.id}';
      
      // Guardar el JSON completo directamente
      final jsonString = jsonEncode(wrapped.toJson());
      await _box!.put(key, jsonString);
      
      print('Wrapped guardado en Hive con key: $key');
      print('JSON guardado (primeros 200 chars): ${jsonString.substring(0, jsonString.length > 200 ? 200 : jsonString.length)}...');
      
      // Verificar que se guardó
      final saved = _box!.get(key);
      if (saved != null) {
        print('Verificación: Wrapped guardado correctamente. Total keys en box: ${_box!.keys.length}');
      } else {
        print('ERROR: El wrapped no se encontró después de guardar');
      }
    } catch (e, stackTrace) {
      print('Error al guardar wrapped en Hive: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static List<WrappedModel> getAllWrappeds() {
    if (_box == null) {
      print('Box no inicializado en getAllWrappeds');
      return [];
    }
    
    print('Obteniendo todos los wrappeds. Total keys en box: ${_box!.keys.length}');
    final List<WrappedModel> wrappeds = [];
    
    for (var key in _box!.keys) {
      try {
        final jsonString = _box!.get(key) as String?;
        if (jsonString != null) {
          print('Procesando key: $key');
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          wrappeds.add(WrappedModel.fromJson(json));
          print('Wrapped cargado exitosamente: ${json['id'] ?? key}');
        } else {
          print('Warning: Key $key tiene valor null');
        }
      } catch (e, stackTrace) {
        print('Error parsing wrapped con key $key: $e');
        print('Stack trace: $stackTrace');
      }
    }
    
    // Ordenar por fecha de creación (más reciente primero)
    wrappeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    print('Total wrappeds cargados: ${wrappeds.length}');
    return wrappeds;
  }

  static Future<void> deleteWrapped(String id) async {
    await _box?.delete(id);
  }

  static WrappedModel? getWrapped(String id) {
    final jsonString = _box?.get(id) as String?;
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WrappedModel.fromJson(json);
    } catch (e) {
      print('Error parsing wrapped: $e');
      return null;
    }
  }
}

