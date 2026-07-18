import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_blog/features/posts/data/models/post_image.dart';

enum PostFormStatus { idle, loading, success, failure }

class PostFormProvider extends ChangeNotifier {
  final PostRepository _postRepository;
  PostFormProvider(this._postRepository);

  PostFormStatus _status = PostFormStatus.idle;
  Post? _createdPost;
  String? _errorMessage;

  PostFormStatus get status => _status;
  Post? get createdPost => _createdPost;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PostFormStatus.loading;
  bool get isSuccess => _status == PostFormStatus.success;
  bool get hasError => _status == PostFormStatus.failure;

  static const int maxImages = 5;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  int _existingImageCount = 0;

  List<XFile> get selectedImages {
    return List.unmodifiable(_selectedImages);
  }

  bool get canAddImages {
    return _existingImageCount + _selectedImages.length < maxImages;
  }

  int get remainingImageSlots {
    return maxImages - _existingImageCount - _selectedImages.length;
  }

  void setExistingImageCount(int count) {
    final safeCount = count.clamp(0, maxImages);

    if (_existingImageCount == safeCount) return;

    _existingImageCount = safeCount;
    notifyListeners();
  }

  Future<bool> pickImages() async {
    if (isLoading || !canAddImages) return false;

    _errorMessage = null;

    late final List<XFile> images;

    try {
      if (kIsWeb) {
        images = await _imagePicker.pickMultiImage(
          limit: remainingImageSlots,
          requestFullMetadata: false,
        );
      } else {
        images = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
          limit: remainingImageSlots,
          requestFullMetadata: false,
        );
      }

      if (images.isEmpty) {
        return true;
      }

      _selectedImages.addAll(images.take(remainingImageSlots));

      notifyListeners();
      return true;
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? 'Unable to select images.';
    } catch (error, stackTrace) {
      debugPrint('Image picker error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to select images.';
    }

    notifyListeners();
    return false;
  }

  void removeImageAt(int index) {
    if (isLoading) return;

    if (index < 0 || index >= _selectedImages.length) {
      return;
    }

    _selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearImages() {
    if (isLoading || _selectedImages.isEmpty) return;

    _selectedImages.clear();
    notifyListeners();
  }

  Future<Post?> createPost({
    required String title,
    required String content,
  }) async {
    if (isLoading) return null;

    _status = PostFormStatus.loading;
    _createdPost = null;
    _errorMessage = null;
    notifyListeners();

    Post? postWithoutImages;

    try {
      postWithoutImages = await _postRepository.createPost(
        title: title,
        content: content,
      );

      final uploadedImages = await _postRepository.uploadPostImages(
        postId: postWithoutImages.id,
        images: List.of(_selectedImages),
      );

      final completedPost = postWithoutImages.copyWith(images: uploadedImages);

      _createdPost = completedPost;
      _selectedImages.clear();
      _status = PostFormStatus.success;
      notifyListeners();

      return completedPost;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } on StorageException catch (error) {
      _errorMessage = error.message;
    } on FormatException catch (error) {
      _errorMessage = error.message.toString();
    } catch (_) {
      _errorMessage = 'Unable to create your post. Please try again.';
    }

    if (postWithoutImages != null) {
      try {
        await _postRepository.deletePost(postWithoutImages.id);
      } catch (_) {
        // Preserve the original creation or upload error.
      }
    }

    _status = PostFormStatus.failure;
    notifyListeners();

    return null;
  }

  Future<Post?> updatePost({
    required String postId,
    required String title,
    required String content,
    List<PostImage> removedImages = const [],
  }) async {
    if (isLoading) return null;

    _status = PostFormStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postRepository.deletePostImages(
        postId: postId,
        images: removedImages,
      );

      final postAfterDeletion = await _postRepository.fetchPost(postId);

      var nextPosition = 0;

      for (final image in postAfterDeletion?.images ?? <PostImage>[]) {
        if (image.position >= nextPosition) {
          nextPosition = image.position + 1;
        }
      }

      await _postRepository.uploadPostImages(
        postId: postId,
        images: List.of(_selectedImages),
        startPosition: nextPosition,
      );

      final updatedPost = await _postRepository.updatePost(
        postId: postId,
        title: title,
        content: content,
      );

      _createdPost = updatedPost;
      _selectedImages.clear();
      _existingImageCount = updatedPost.images.length;
      _status = PostFormStatus.success;
      notifyListeners();

      return updatedPost;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } on StorageException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to update your post. Please try again.';
    }

    _status = PostFormStatus.failure;
    notifyListeners();

    return null;
  }

  void reset() {
    _status = PostFormStatus.idle;
    _createdPost = null;
    _errorMessage = null;
    _selectedImages.clear();
    _existingImageCount = 0;
    notifyListeners();
  }
}
