import 'package:go_router/go_router.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/features/auth/presentation/screens/login_screen.dart';
import 'package:simple_blog/features/auth/presentation/screens/register_screen.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_list_screen.dart';

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
  ],
);
