import 'package:simple_blog/features/posts/data/models/post_image.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PostImage> images;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PostImage>? images,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }

  factory Post.fromJson(Map<String, dynamic> jsonData) {
    final imagesJson = jsonData['post_images'] as List<dynamic>? ?? [];
    final images =
        imagesJson
            .map((image) => PostImage.fromJson((image as Map<String, dynamic>)))
            .toList()
          ..sort((first, second) => first.position.compareTo(second.position));

    return Post(
      id: jsonData['id'] as String,
      userId: jsonData['user_id'] as String,
      title: jsonData['title'] as String,
      content: jsonData['content'] as String,
      createdAt: DateTime.parse(jsonData['created_at'] as String),
      updatedAt: DateTime.parse(jsonData['updated_at'] as String),
      images: images,
    );
  }
}
