import 'package:flutter/widgets.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDetailProvider extends ChangeNotifier {
  final PostRepository _postRepository;
  PostDetailProvider(this._postRepository);

  Post? _post;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDeleting = false;
  String? _deleteErrorMessage;

  Post? get post => _post;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isDeleting => _isDeleting;
  String? get deleteErrorMessage => _deleteErrorMessage;
  bool get wasNotFound {
    return !_isLoading && !hasError && _post == null;
  }

  Future<void> loadPost(String postId) async {
    if (_isLoading) return;

    _isLoading = true;
    _post = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _post = await _postRepository.fetchPost(postId);
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load this post. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost() async {
    final currentPost = _post;

    if (_isLoading || _isDeleting || currentPost == null) {
      return false;
    }

    _isDeleting = true;
    _deleteErrorMessage = null;
    notifyListeners();

    try {
      await _postRepository.deletePost(currentPost.id);

      _post = null;
      _isDeleting = false;
      notifyListeners();

      return true;
    } on AuthException catch (error) {
      _deleteErrorMessage = error.message;
    } on PostgrestException catch (error) {
      _deleteErrorMessage = error.message;
    } catch (_) {
      _deleteErrorMessage = 'Unable to delete this post. Please try again.';
    }

    _isDeleting = false;
    notifyListeners();

    return false;
  }
}
