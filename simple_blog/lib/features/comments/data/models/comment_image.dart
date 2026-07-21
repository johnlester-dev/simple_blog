class CommentImage {
  final String id;
  final String commentId;
  final String imageUrl;
  final String storagePath;
  final int position;
  final DateTime createdAt;

  const CommentImage({
    required this.id,
    required this.commentId,
    required this.imageUrl,
    required this.storagePath,
    required this.position,
    required this.createdAt,
  });

  factory CommentImage.fromJson(Map<String, dynamic> json) {
    return CommentImage(
      id: json['id'] as String,
      commentId: json['comment_id'] as String,
      imageUrl: json['image_url'] as String,
      storagePath: json['storage_path'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
