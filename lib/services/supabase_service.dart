import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/job_image.dart';

class SupabaseService {
  // Nombre exacto de tu bucket creado en Supabase
  static const String _bucketName = 'Imagenes de servicios';

  /// Obtiene la URL pública de una imagen alojada en tu Storage de Supabase
  static String getPublicUrl(String fileName) {
    final url = Supabase.instance.client.storage
        .from(_bucketName)
        .getPublicUrl(fileName);

    print('URL generada de Supabase Storage: $url');
    return url;
  }

  /// Obtiene todas las imágenes de la tabla 'job_images' en la base de datos
  static Future<List<JobImage>> fetchJobImages() async {
    try {
      final response = await Supabase.instance.client
          .from('job_images')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((item) => JobImage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si falla la consulta o la tabla 'job_images' aún está vacía,
      // retorna la lista local conectada a tus imágenes reales de Supabase Storage.
      return _demoImages();
    }
  }

  /// Lista con tus fotos reales subidas a Supabase Storage
  static List<JobImage> _demoImages() {
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
        imageUrl: getPublicUrl('Baterias.jpeg'),
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
