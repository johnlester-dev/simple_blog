import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/app/router/not_found_screen.dart';
import 'package:simple_blog/features/auth/presentation/screens/login_screen.dart';
import 'package:simple_blog/features/comments/data/comment_repository.dart';
import 'package:simple_blog/features/comments/presentation/providers/comment_provider.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_detail_provider.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_form_provider.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_form_screen.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_list_screen.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:simple_blog/features/profile/data/profile_repository.dart';
import 'package:simple_blog/features/profile/presentation/providers/profile_provider.dart';
import 'package:simple_blog/features/profile/presentation/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GoRouter appRouter = GoRouter(
  errorBuilder: (context, state) => const NotFoundScreen(),
  redirect: (context, state) {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;
    final path = state.uri.path;
    final requiresAuthentication =
        path == RoutePaths.profile ||
        (path.startsWith('/posts/') && path.endsWith('/edit'));

    if (!isAuthenticated && requiresAuthentication) {
      final returnPath = path.endsWith('/edit')
          ? path.substring(0, path.length - '/edit'.length)
          : state.uri.toString();
      return Uri(
        path: RoutePaths.register,
        queryParameters: {'mode': 'login', 'redirect': returnPath},
      ).toString();
    }

    return null;
  },
  routes: [
    GoRoute(
      path: RoutePaths.posts,
      name: RouteNames.posts,
      builder: (context, state) => const PostListScreen(),
    ),
    GoRoute(
      path: RoutePaths.register,
      name: RouteNames.register,
      builder: (context, state) => LoginScreen(
        initialLogin: state.uri.queryParameters['mode'] == 'login',
      ),
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
    GoRoute(
      path: RoutePaths.postDetail,
      name: RouteNames.postDetail,
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) {
                return PostDetailProvider(context.read<PostRepository>())
                  ..loadPost(postId);
              },
            ),
            ChangeNotifierProvider(
              create: (context) {
                return CommentProvider(context.read<CommentRepository>())
                  ..loadComments(postId);
              },
            ),
          ],
          child: PostDetailScreen(postId: postId),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (context) {
            return ProfileProvider(context.read<ProfileRepository>())
              ..loadProfile();
          },
          child: const ProfileScreen(),
        );
      },
    ),
  ],
);
