import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/core/constants/storage_constants.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/models/post_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepository {
  final SupabaseClient _supabaseClient;

  const PostRepository(this._supabaseClient);

  Future<List<Post>> fetchPosts() async {
    final response = await _supabaseClient
        .from('posts')
        .select(
          '*, '
          'author:profiles!posts_user_id_profiles_fkey(*), '
          'post_images(*)',
        )
        .order('created_at', ascending: false)
        .order('position', referencedTable: 'post_images', ascending: true);

    return response.map(Post.fromJson).toList();
  }

  Future<Post?> fetchPost(String postId) async {
    final response = await _supabaseClient
        .from('posts')
        .select(
          '*, '
          'author:profiles!posts_user_id_profiles_fkey(*), '
          'post_images(*)',
        )
        .eq('id', postId)
        .order('position', referencedTable: 'post_images', ascending: true)
        .maybeSingle();

    if (response == null) return null;
    return Post.fromJson(response);
  }

  Future<Post> createPost({
    required String title,
    required String content,
  }) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to create a post.');
    }

    final response = await _supabaseClient
        .from('posts')
        .insert({
          'user_id': user.id,
          'title': title.trim(),
          'content': content.trim(),
        })
        .select(
          '*, '
          'author:profiles!posts_user_id_profiles_fkey(*)',
        )
        .single();

    return Post.fromJson(response);
  }

  Future<List<PostImage>> uploadPostImages({
    required String postId,
    required List<XFile> images,
    int startPosition = 0,
  }) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to upload images.');
    }

    if (images.isEmpty) return [];

    final bucket = _supabaseClient.storage.from(
      StorageConstants.postImagesBucket,
    );

    final uploadedPaths = <String>[];
    final imageRows = <Map<String, dynamic>>[];

    try {
      for (var index = 0; index < images.length; index++) {
        final image = images[index];
        final bytes = await image.readAsBytes();

        if (bytes.length > 5 * 1024 * 1024) {
          throw FormatException('${image.name} is larger than 5 MB.');
        }

        final contentType = _contentTypeFor(image);
        final extension = _extensionFor(contentType);
        final uniqueName =
            '${DateTime.now().microsecondsSinceEpoch}_$index.$extension';

        final storagePath = '${user.id}/$postId/$uniqueName';

        await bucket.uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

        uploadedPaths.add(storagePath);

        imageRows.add({
          'post_id': postId,
          'image_url': bucket.getPublicUrl(storagePath),
          'storage_path': storagePath,
          'position': startPosition + index,
        });
      }

      final response = await _supabaseClient
          .from('post_images')
          .insert(imageRows)
          .select();

      return response.map(PostImage.fromJson).toList();
    } catch (_) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await bucket.remove(uploadedPaths);
        } catch (_) {
          // Preserve the original upload or database error.
        }
      }

      rethrow;
    }
  }

  String _contentTypeFor(XFile image) {
    final mimeType = image.mimeType?.toLowerCase();

    if (mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/webp') {
      return mimeType!;
    }

    final fileName = image.name.toLowerCase();

    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (fileName.endsWith('.png')) {
      return 'image/png';
    }

    if (fileName.endsWith('.webp')) {
      return 'image/webp';
    }

    throw FormatException('${image.name} is not a supported image type.');
  }

  String _extensionFor(String contentType) {
    return switch (contentType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => throw const FormatException('Unsupported image type.'),
    };
  }

  Future<void> deletePost(String postId) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to delete a post.');
    }

    final post = await fetchPost(postId);

    if (post == null) {
      return;
    }

    if (post.userId != user.id) {
      throw const AuthException('You cannot delete another user’s post.');
    }

    final storagePaths = post.images.map((image) => image.storagePath).toList();

    if (storagePaths.isNotEmpty) {
      final deletedFiles = await _supabaseClient.storage
          .from(StorageConstants.postImagesBucket)
          .remove(storagePaths);

      debugPrint(
        'Requested ${storagePaths.length} deletions; '
        'deleted ${deletedFiles.length} files.',
      );

      if (deletedFiles.length != storagePaths.length) {
        throw StateError('Some post images could not be deleted from storage.');
      }
    }

    final deletedPost = await _supabaseClient
        .from('posts')
        .delete()
        .eq('id', postId)
        .eq('user_id', user.id)
        .select('id')
        .maybeSingle();

    if (deletedPost == null) {
      throw StateError('The post could not be deleted.');
    }
  }

  Future<Post> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to update a post.');
    }

    final response = await _supabaseClient
        .from('posts')
        .update({
          'title': title.trim(),
          'content': content.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', postId)
        .eq('user_id', user.id)
        .select(
          '*, '
          'author:profiles!posts_user_id_profiles_fkey(*), '
          'post_images(*)',
        )
        .order('position', referencedTable: 'post_images', ascending: true)
        .single();

    return Post.fromJson(response);
  }

  Future<void> deletePostImages({
    required String postId,
    required List<PostImage> images,
  }) async {
    if (images.isEmpty) return;

    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to delete post images.');
    }

    final post = await fetchPost(postId);

    if (post == null || post.userId != user.id) {
      throw const AuthException('You cannot delete images from this post.');
    }

    final storagePaths = images.map((image) => image.storagePath).toList();

    final deletedFiles = await _supabaseClient.storage
        .from(StorageConstants.postImagesBucket)
        .remove(storagePaths);

    if (deletedFiles.length != storagePaths.length) {
      throw StateError('Some images could not be deleted from storage.');
    }

    final imageIds = images.map((image) => image.id).toList();

    final deletedRows = await _supabaseClient
        .from('post_images')
        .delete()
        .eq('post_id', postId)
        .inFilter('id', imageIds)
        .select('id');

    if (deletedRows.length != imageIds.length) {
      throw StateError('Some image records could not be deleted.');
    }
  }
}
