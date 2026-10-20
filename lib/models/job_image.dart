// ============================================================
// lib/models/job_image.dart
// ============================================================
class JobImage {
  final String id;
  final String imageUrl;
  final String title;
  final String? description;
  final DateTime createdAt;
  const JobImage({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.description,
    required this.createdAt,
  });
  factory JobImage.fromJson(Map<String, dynamic> json) {
    return JobImage(
      id: json['id'].toString(),
      imageUrl: json['image_url'] as String,
      title: json['title'] as String? ?? 'Trabajo realizado',
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}