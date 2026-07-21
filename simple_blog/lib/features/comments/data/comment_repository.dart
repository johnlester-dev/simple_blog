import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/core/constants/storage_constants.dart';
import 'package:simple_blog/features/comments/data/models/comment.dart';
import 'package:simple_blog/features/comments/data/models/comment_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepository {
  final SupabaseClient _supabaseClient;

  const CommentRepository(this._supabaseClient);

  Future<List<Comment>> fetchComments(String postId) async {
    final response = await _supabaseClient
        .from('comments')
        .select('*, comment_images(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .order('position', referencedTable: 'comment_images', ascending: true);

    return response.map(Comment.fromJson).toList();
  }

  Future<Comment> createComment({
    required String postId,
    required String content,
  }) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to create a comment.');
    }

    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw const FormatException('Comment cannot be empty.');
    }

    if (trimmedContent.length > 1000) {
      throw const FormatException('Comment cannot exceed 1000 characters.');
    }

    final response = await _supabaseClient
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': user.id,
          'content': trimmedContent,
        })
        .select()
        .single();

    return Comment.fromJson(response);
  }

  Future<List<CommentImage>> uploadCommentImages({
    required String commentId,
    required List<XFile> images,
    int startPosition = 0,
  }) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be signed in to upload comment images.',
      );
    }

    if (images.isEmpty) return [];

    if (images.length > 3) {
      throw const FormatException('A comment can contain up to 3 images.');
    }

    final bucket = _supabaseClient.storage.from(
      StorageConstants.commentImagesBucket,
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

        final storagePath = '${user.id}/$commentId/$uniqueName';

        await bucket.uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

        uploadedPaths.add(storagePath);

        imageRows.add({
          'comment_id': commentId,
          'image_url': bucket.getPublicUrl(storagePath),
          'storage_path': storagePath,
          'position': startPosition + index,
        });
      }

      final response = await _supabaseClient
          .from('comment_images')
          .insert(imageRows)
          .select();

      return response.map(CommentImage.fromJson).toList();
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

  //Adding a rollback support

  Future<Comment?> fetchComment(String commentId) async {
    final response = await _supabaseClient
        .from('comments')
        .select('*, comment_images(*)')
        .eq('id', commentId)
        .order('position', referencedTable: 'comment_images', ascending: true)
        .maybeSingle();

    if (response == null) return null;

    return Comment.fromJson(response);
  }

  Future<void> deleteComment(String commentId) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to delete a comment.');
    }

    final comment = await fetchComment(commentId);

    if (comment == null) return;

    if (comment.userId != user.id) {
      throw const AuthException('You cannot delete another user\'s comment.');
    }

    final storagePaths = comment.images
        .map((image) => image.storagePath)
        .toList();

    if (storagePaths.isNotEmpty) {
      final deletedFiles = await _supabaseClient.storage
          .from(StorageConstants.commentImagesBucket)
          .remove(storagePaths);

      if (deletedFiles.length != storagePaths.length) {
        throw StateError('Some comment images could not be deleted.');
      }
    }

    final deletedComment = await _supabaseClient
        .from('comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', user.id)
        .select('id')
        .maybeSingle();

    if (deletedComment == null) {
      throw StateError('The comment could not be deleted.');
    }
  }

  Future<Comment> updateComment({
    required String commentId,
    required String content,
  }) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to update a comment.');
    }

    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      throw const FormatException('Comment cannot be empty.');
    }

    if (trimmedContent.length > 1000) {
      throw const FormatException('Comment cannot exceed 1000 characters.');
    }

    final response = await _supabaseClient
        .from('comments')
        .update({
          'content': trimmedContent,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', commentId)
        .eq('user_id', user.id)
        .select('*, comment_images(*)')
        .order('position', referencedTable: 'comment_images', ascending: true)
        .single();

    return Comment.fromJson(response);
  }

  Future<void> deleteCommentImages({
    required String commentId,
    required List<CommentImage> images,
  }) async {
    if (images.isEmpty) return;

    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be signed in to delete comment images.',
      );
    }

    final comment = await fetchComment(commentId);

    if (comment == null || comment.userId != user.id) {
      throw const AuthException('You cannot delete images from this comment.');
    }

    final invalidImage = images.any((image) => image.commentId != commentId);

    if (invalidImage) {
      throw ArgumentError('Every image must belong to the selected comment.');
    }

    final storagePaths = images.map((image) => image.storagePath).toList();

    final deletedFiles = await _supabaseClient.storage
        .from(StorageConstants.commentImagesBucket)
        .remove(storagePaths);

    if (deletedFiles.length != storagePaths.length) {
      throw StateError(
        'Some comment images could not be deleted from storage.',
      );
    }

    final imageIds = images.map((image) => image.id).toList();

    final deletedRows = await _supabaseClient
        .from('comment_images')
        .delete()
        .eq('comment_id', commentId)
        .inFilter('id', imageIds)
        .select('id');

    if (deletedRows.length != imageIds.length) {
      throw StateError('Some comment image records could not be deleted.');
    }
  }
}
