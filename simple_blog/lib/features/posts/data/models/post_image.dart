class PostImage {
  final String id;
  final String postId;
  final String imageUrl;
  final String storagePath;
  final int position;
  final DateTime createdAt;

  const PostImage({
    required this.id,
    required this.postId,
    required this.imageUrl,
    required this.storagePath,
    required this.position,
    required this.createdAt,
  });

  factory PostImage.fromJson(Map<String, dynamic> jsonData) {
    return PostImage(
      id: jsonData['id'] as String,
      postId: jsonData['post_id'] as String,
      imageUrl: jsonData['image_url'] as String,
      storagePath: jsonData['storage_path'] as String,
      position: jsonData['position'] as int,
      createdAt: DateTime.parse(jsonData['created_at'] as String),
    );
  }
}
