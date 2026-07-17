import 'package:go_router/go_router.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/features/posts/presentation/screens/post_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.posts,
  routes: [
    GoRoute(
      path: RoutePaths.posts,
      name: RouteNames.posts,
      builder: (context, state) => const PostListScreen(),
    ),
  ],
);
