import 'package:simple_blog/features/comments/data/models/comment_image.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentImage> images;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final imageData = json['comment_images'] as List<dynamic>? ?? const [];

    final images = imageData
        .map((image) => CommentImage.fromJson(image as Map<String, dynamic>))
        .toList();

    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      images: images,
    );
  }

  Comment copyWith({
    String? content,
    List<CommentImage>? images,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id,
      postId: postId,
      userId: userId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }
}
