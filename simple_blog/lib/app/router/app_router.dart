import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/features/auth/presentation/screens/login_screen.dart';
import 'package:simple_blog/features/auth/presentation/screens/register_screen.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_detail_provider.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_form_provider.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_form_screen.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_list_screen.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.posts,
  routes: [
    GoRoute(
      path: RoutePaths.posts,
      name: RouteNames.posts,
      builder: (context, state) => const PostListScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RoutePaths.createPost,
      name: RouteNames.createPost,
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) => PostFormProvider(context.read<PostRepository>()),
          child: const PostFormScreen(),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.postDetail,
      name: RouteNames.postDetail,
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return ChangeNotifierProvider(
          create: (context) {
            return PostDetailProvider(context.read<PostRepository>())
              ..loadPost(postId);
          },
          child: PostDetailScreen(postId: postId),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.editPost,
      name: RouteNames.editPost,
      builder: (context, state) {
        final post = state.extra;

        if (post is! Post) {
          return const Scaffold(
            body: Center(child: Text('Post data is unavailable.')),
          );
        }

        return ChangeNotifierProvider(
          create: (context) => PostFormProvider(context.read<PostRepository>()),
          child: PostFormScreen(initialPost: post),
        );
      },
    ),
  ],
);
