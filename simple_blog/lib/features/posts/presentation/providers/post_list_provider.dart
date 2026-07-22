import 'package:flutter/material.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostListProvider extends ChangeNotifier {
  final PostRepository _postRepository;

  PostListProvider(this._postRepository);

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && !hasError && _posts.isEmpty;

  static const int pageSize = 20;

  Future<void> loadPosts() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final posts = await _postRepository.fetchPosts(
        offset: 0,
        limit: pageSize,
      );
      _posts = posts;
      _hasMore = posts.length == pageSize;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load posts. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = await _postRepository.fetchPosts(
        offset: _posts.length,
        limit: pageSize,
      );
      _posts = [..._posts, ...nextPage];
      _hasMore = nextPage.length == pageSize;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load more posts.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
