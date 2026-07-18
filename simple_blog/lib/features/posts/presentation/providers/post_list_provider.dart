import 'package:flutter/material.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostListProvider extends ChangeNotifier {
  final PostRepository _postRepository;

  PostListProvider(this._postRepository);

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && !hasError && _posts.isEmpty;

  Future<void> loadPosts() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _postRepository.fetchPosts();
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load posts. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
