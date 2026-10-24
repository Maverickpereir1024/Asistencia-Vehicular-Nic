import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/job_image.dart';

class SupabaseService {
  // Nombre exacto de tu bucket creado en Supabase
  static const String _bucketName = 'Imagenes de servicios';

  /// Obtiene la URL pública de una imagen alojada en tu Storage de Supabase
  /// y asegura que los espacios y caracteres especiales se codifiquen correctamente (%20).
  static String getPublicUrl(String fileName) {
    final rawUrl = Supabase.instance.client.storage
        .from(_bucketName)
        .getPublicUrl(fileName);

    return Uri.encodeFull(rawUrl);
  }

  /// Obtiene las imágenes de los trabajos:
  /// 1. Primero lee directamente todos los archivos subidos al bucket de Storage.
  /// 2. Si no hay o falla, intenta leer de la tabla 'job_images' (si existiera).
  /// 3. Como último recurso, usa las fotos de respaldo con nombres exactos.
  static Future<List<JobImage>> fetchJobImages() async {
    // 1. Cargar dinámicamente desde el bucket de Supabase Storage
    try {
      final List<FileObject> files = await Supabase.instance.client.storage
          .from(_bucketName)
          .list();

      final imageFiles = files.where((file) {
        final name = file.name.toLowerCase();
        return (name.endsWith('.jpg') ||
                name.endsWith('.jpeg') ||
                name.endsWith('.png') ||
                name.endsWith('.webp')) &&
            !name.startsWith('.');
      }).toList();

      if (imageFiles.isNotEmpty) {
        return imageFiles.map((file) {
          final url = getPublicUrl(file.name);
          return JobImage(
            id: file.id ?? file.name,
            imageUrl: url,
            title: _generateTitle(file.name),
            description: _generateDescription(file.name),
            createdAt: file.createdAt != null
                ? DateTime.tryParse(file.createdAt!) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      // Ignoramos y pasamos al siguiente método
    }

    // 2. Si Storage no devolvió nada, intentar tabla 'job_images'
    try {
      final response = await Supabase.instance.client
          .from('job_images')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      final list = (response as List)
          .map((item) => JobImage.fromJson(item as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) return list;
    } catch (_) {
      // Si la tabla no existe en la base de datos, ignoramos el error
    }

    // 3. Respaldo con los nombres exactos existentes en tu Storage
    return _fallbackImages();
  }

  static String _generateTitle(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('llanta')) {
      return 'Cambio de Llanta';
    } else if (lower.contains('bateria') && lower.contains('diagnost')) {
      return 'Diagnóstico de Batería';
    } else if (lower.contains('bateria')) {
      return 'Paso de Corriente / Batería';
    } else if (lower.contains('abrir') || lower.contains('carro') || lower.contains('cerraj')) {
      return 'Cerrajería Vehicular';
    } else if (lower.contains('grua') || lower.contains('remolc')) {
      return 'Servicio de Grúa';
    } else if (lower.contains('gasolina') || lower.contains('combust')) {
      return 'Suministro de Gasolina';
    }
    final clean = fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
    return clean.isEmpty ? 'Trabajo Realizado' : clean;
  }

  static String _generateDescription(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.contains('llanta')) {
      return 'Cambio rápido y seguro en carretera';
    } else if (lower.contains('bateria') && lower.contains('diagnost')) {
      return 'Diagnósticos de baterías y detección de fallas';
    } else if (lower.contains('bateria')) {
      return 'Batería descargada, solución inmediata en el lugar';
    } else if (lower.contains('abrir') || lower.contains('carro')) {
      return 'Apertura de vehículo profesional y sin daños';
    }
    return 'Atención profesional y garantizada 24/7';
  }

  /// Lista de respaldo con los nombres EXACTOS de tus archivos en Supabase
  static List<JobImage> _fallbackImages() {
    return [
      JobImage(
        id: '1',
        imageUrl: getPublicUrl('cambio de llanta.jpeg'),
        title: 'Cambio de Llanta',
        description: 'Cambio rápido en carretera',
        createdAt: DateTime.now(),
      ),
      JobImage(
        id: '2',
        imageUrl: getPublicUrl('baterias.jpeg'), // Corregido: 'b' minúscula
        title: 'Paso de Corriente',
        description: 'Batería descargada, solución inmediata',
        createdAt: DateTime.now(),
      ),
      JobImage(
        id: '3',
        imageUrl: getPublicUrl('abrir carro.jpeg'),
        title: 'Cerrajería Vehicular',
        description: 'Apertura de vehículo sin daños',
        createdAt: DateTime.now(),
      ),
      JobImage(
        id: '4',
        imageUrl: getPublicUrl('diagnostico de bateria.jpeg'),
        title: 'Diagnósticos rápidos y efectivos',
        description: 'Diagnósticos de baterías y detección de fallas',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
