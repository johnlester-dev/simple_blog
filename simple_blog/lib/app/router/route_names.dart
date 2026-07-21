abstract final class RouteNames {
  static const posts = 'posts';
  static const login = 'login';
  static const register = 'register';
  static const createPost = 'create-post';
  static const postDetail = 'post-detail';
  static const editPost = 'edit-post';
  static const profile = 'profile';
}

abstract final class RoutePaths {
  static const posts = '/';
  static const login = '/login';
  static const register = '/register';
  static const createPost = '/posts/new';
  static const postDetail = '/posts/:postId';
  static const editPost = '/posts/:postId/edit';
  static const profile = '/profile';
}
