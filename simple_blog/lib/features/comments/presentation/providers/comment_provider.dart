import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/features/comments/data/comment_repository.dart';
import 'package:simple_blog/features/comments/data/models/comment.dart';
import 'package:simple_blog/features/comments/data/models/comment_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepository _commentRepository;

  CommentProvider(this._commentRepository);

  final List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  bool _isSubmitting = false;
  String? _submitErrorMessage;
  static const int maxImages = 3;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  String? _imageErrorMessage;
  final Set<String> _deletingCommentIds = {};
  String? _deleteErrorMessage;
  final Set<String> _updatingCommentIds = {};
  String? _updateErrorMessage;

  List<Comment> get comments => List.unmodifiable(_comments);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && !hasError && _comments.isEmpty;
  bool get isSubmitting => _isSubmitting;
  String? get submitErrorMessage => _submitErrorMessage;
  List<XFile> get selectedImages => List.unmodifiable(_selectedImages);
  bool get canAddImages => _selectedImages.length < maxImages;
  int get remainingImageSlots => maxImages - _selectedImages.length;
  String? get imageErrorMessage => _imageErrorMessage;
  String? get deleteErrorMessage => _deleteErrorMessage;
  String? get updateErrorMessage => _updateErrorMessage;

  static const int pageSize = 20;

  bool isDeletingComment(String commentId) {
    return _deletingCommentIds.contains(commentId);
  }

  bool isUpdatingComment(String commentId) {
    return _updatingCommentIds.contains(commentId);
  }

  Future<void> loadComments(String postId) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final comments = await _commentRepository.fetchComments(
        postId,
        offset: 0,
        limit: pageSize,
      );

      _comments
        ..clear()
        ..addAll(comments);
      _hasMore = comments.length == pageSize;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load comments. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreComments(String postId) async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = await _commentRepository.fetchComments(
        postId,
        offset: _comments.length,
        limit: pageSize,
      );
      _comments.addAll(nextPage);
      _hasMore = nextPage.length == pageSize;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load more comments.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required String postId,
    required String content,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _submitErrorMessage = null;
    notifyListeners();
    Comment? commentWithoutImages;
    try {
      commentWithoutImages = await _commentRepository.createComment(
        postId: postId,
        content: content,
      );

      final uploadedImages = await _commentRepository.uploadCommentImages(
        commentId: commentWithoutImages.id,
        images: List.of(_selectedImages),
      );

      final completedComment = commentWithoutImages.copyWith(
        images: uploadedImages,
      );

      _comments.add(completedComment);
      _selectedImages.clear();
      _imageErrorMessage = null;
      _isSubmitting = false;
      notifyListeners();

      return true;
    } on AuthException catch (error) {
      _submitErrorMessage = error.message;
    } on PostgrestException catch (error) {
      _submitErrorMessage = error.message;
    } on FormatException catch (error) {
      _submitErrorMessage = error.message.toString();
    } on StorageException catch (error) {
      _submitErrorMessage = error.message;
    } catch (_) {
      _submitErrorMessage = 'Unable to create your comment.';
    }

    final rollbackComment = commentWithoutImages;

    if (rollbackComment != null) {
      try {
        await _commentRepository.deleteComment(rollbackComment.id);
      } catch (error, stackTrace) {
        debugPrint('Comment rollback failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    _isSubmitting = false;
    notifyListeners();

    return false;
  }

  Future<bool> pickImages() async {
    if (_isSubmitting || !canAddImages) return false;

    _imageErrorMessage = null;

    try {
      final images = kIsWeb
          ? await _imagePicker.pickMultiImage(
              limit: remainingImageSlots,
              requestFullMetadata: false,
            )
          : await _imagePicker.pickMultiImage(
              maxWidth: 1920,
              maxHeight: 1920,
              imageQuality: 85,
              limit: remainingImageSlots,
              requestFullMetadata: false,
            );

      if (images.isEmpty) return true;

      _selectedImages.addAll(images.take(remainingImageSlots));

      notifyListeners();
      return true;
    } on PlatformException catch (error) {
      _imageErrorMessage = error.message ?? 'Unable to select images.';
    } catch (error, stackTrace) {
      debugPrint('Comment image picker error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _imageErrorMessage = 'Unable to select images.';
    }

    notifyListeners();
    return false;
  }

  void removeImageAt(int index) {
    if (_isSubmitting) return;
    if (index < 0 || index >= _selectedImages.length) return;

    _selectedImages.removeAt(index);
    notifyListeners();
  }

  Future<bool> deleteComment(Comment comment) async {
    if (_deletingCommentIds.contains(comment.id)) return false;

    _deletingCommentIds.add(comment.id);
    _deleteErrorMessage = null;
    notifyListeners();

    try {
      await _commentRepository.deleteComment(comment.id);

      _comments.removeWhere(
        (existingComment) => existingComment.id == comment.id,
      );

      _deletingCommentIds.remove(comment.id);
      notifyListeners();

      return true;
    } on AuthException catch (error) {
      _deleteErrorMessage = error.message;
    } on PostgrestException catch (error) {
      _deleteErrorMessage = error.message;
    } on StorageException catch (error) {
      _deleteErrorMessage = error.message;
    } catch (_) {
      _deleteErrorMessage = 'Unable to delete this comment.';
    }

    _deletingCommentIds.remove(comment.id);
    notifyListeners();

    return false;
  }

  Future<bool> updateComment({
    required Comment comment,
    required String content,
    List<CommentImage> removedImages = const [],
    List<XFile> newImages = const [],
  }) async {
    if (_updatingCommentIds.contains(comment.id)) return false;

    _updatingCommentIds.add(comment.id);
    _updateErrorMessage = null;
    notifyListeners();

    try {
      await _commentRepository.deleteCommentImages(
        commentId: comment.id,
        images: removedImages,
      );

      final commentAfterDeletion = await _commentRepository.fetchComment(
        comment.id,
      );

      if (commentAfterDeletion == null) {
        throw StateError('The comment no longer exists.');
      }

      if (commentAfterDeletion.images.length + newImages.length > maxImages) {
        throw const FormatException('A comment can contain up to 3 images.');
      }

      var nextPosition = 0;

      for (final image in commentAfterDeletion.images) {
        if (image.position >= nextPosition) {
          nextPosition = image.position + 1;
        }
      }

      await _commentRepository.uploadCommentImages(
        commentId: comment.id,
        images: newImages,
        startPosition: nextPosition,
      );

      final updatedComment = await _commentRepository.updateComment(
        commentId: comment.id,
        content: content,
      );

      final index = _comments.indexWhere(
        (existingComment) => existingComment.id == comment.id,
      );

      if (index != -1) {
        _comments[index] = updatedComment;
      }

      _updatingCommentIds.remove(comment.id);
      notifyListeners();

      return true;
    } on AuthException catch (error) {
      _updateErrorMessage = error.message;
    } on PostgrestException catch (error) {
      _updateErrorMessage = error.message;
    } on FormatException catch (error) {
      _updateErrorMessage = error.message.toString();
    } on StorageException catch (error) {
      _updateErrorMessage = error.message;
    } catch (_) {
      _updateErrorMessage = 'Unable to update this comment.';
    }

    _updatingCommentIds.remove(comment.id);
    notifyListeners();

    return false;
  }
}
