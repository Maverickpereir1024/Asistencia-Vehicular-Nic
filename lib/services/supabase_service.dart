// ============================================================
// lib/services/supabase_service.dart
// ============================================================
// Servicio para obtener imágenes de trabajos desde Supabase.
//
// 📋 TABLA REQUERIDA EN SUPABASE:
// Crea una tabla llamada "job_images" con estas columnas:
//   - id: uuid (primary key, default: gen_random_uuid())
//   - image_url: text (URL pública de la imagen)
//   - title: text
//   - description: text (nullable)
//   - created_at: timestamptz (default: now())
//
// También puedes usar Supabase Storage:
//   1. Crea un bucket llamado "job-images" (público)
//   2. Sube tus fotos ahí
//   3. Guarda las URLs públicas en la tabla job_images.image_url

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/job_image.dart';

class SupabaseService {
  /// Obtiene todas las imágenes de trabajos realizados
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
      // Si falla Supabase o aún no está conectado, retorna imágenes de ejemplo para demo
      return _demoImages();
    }
  }

  /// Imágenes de ejemplo para cuando no hay conexión a Supabase
  static List<JobImage> _demoImages() {
    return [
      JobImage(
        id: '2',
        imageUrl: 'https://imgs.search.brave.com/7A8DoqcNIXLuSltwHoFbeN3dbAWZw911QQ-YyJGIz2s/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly91cy4x/MjNyZi5jb20vNDUw/d20vemh5azE5ODgv/emh5azE5ODgxNjEy/L3poeWsxOTg4MTYx/MjAwMTAxLzY4MjE1/ODA2LWhvbWJyZS1k/ZS1jYW1iaWFyLXVu/YS1ydWVkYS1lbi1s/YS1jYXJyZXRlcmEt/ZGUtbWFuZXJhLWh1/Ym8tcm90dXJhLWRl/LWxhLXJ1ZWRhLXBl/cmZvcmUtbmVjZXNh/cmlvLmpwZz92ZXI9/Ng',
        title: 'Cambio de Llanta',
        description: 'Cambio rápido en carretera',
        createdAt: DateTime.now(),
      ),
      JobImage(
        id: '3',
        imageUrl: 'https://imgs.search.brave.com/NT63NiX48iqif4bzTmvihQ4nDRAyFzttaAojbGbqQK0/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly93d3cu/ZmlyZXN0b25lLmNv/bS5teC9jb250ZW50/L2RhbS9jb25zdW1l/ci9mc3QvbGEvbXgv/dGlwcy9jb21wcmFy/LWxsYW50YXMvcGFz/YXJjb3JyaWVudGUt/YmlnLTEuanBn',
        title: 'Paso de Corriente',
        description: 'Batería descargada, solución inmediata',
        createdAt: DateTime.now(),
      ),
      JobImage(
        id: '4',
        imageUrl: 'https://imgs.search.brave.com/Pog90yLYSWvgh6OOWA95aUHt2SMaolwzU1L4FrpnZgo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMud2l4c3RhdGlj/LmNvbS9tZWRpYS80/ZTYxN2FfMzlkZGEx/ZDk2OWE3NDljZTg3/NjE4N2NkMzczMDY0/NGR-bXYyLmpwZWcv/djEvZmlsbC93XzE3/OCxoXzIzNCxhbF9j/LHFfODAsdXNtXzAu/NjZfMS4wMF8wLjAx/LGVuY19hdmlmLHF1/YWxpdHlfYXV0by80/ZTYxN2FfMzlkZGEx/ZDk2OWE3NDljZTg3/NjE4N2NkMzczMDY0/NGR-bXYyLmpwZWc',
        title: 'Cerrajería Vehicular',
        description: 'Apertura de vehículo sin daños',
        createdAt: DateTime.now(),
      ),
      JobImage(
        id: '5',
        imageUrl: 'https://imgs.search.brave.com/IymvyayNJohIb6UD5nU97XfvJy9VnONpZsTU4EvDmi8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/bXVjaG9uZXVtYXRp/Y28uY29tL2Jsb2cv/d3AtY29udGVudC91/cGxvYWRzLzIwMjMv/MDIvYXV0by1tZWNo/YW5pYy1jaGVja2lu/Zy1jYXItYmF0dGVy/eS12b2x0YWdlLmpw/Zw',
        title: 'Diagnosticos rapidos y efectivos',
        description: 'Diagnósticos de baterías y detección de fallas',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
