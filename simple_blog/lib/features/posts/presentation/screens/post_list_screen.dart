import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/app/theme/theme_provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_list_provider.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_card.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostListProvider>().loadPosts();
    });
  }

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    final loggedOut = await authProvider.logout();

    if (!mounted) return;

    if (!loggedOut) {
      AppNotification.error(
        context,
        message: authProvider.errorMessage ?? 'Unable to sign out.',
      );
      return;
    }

    AppNotification.success(
      context,
      message: 'You have signed out successfully.',
    );
  }

  Widget _buildBody(PostListProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError && provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage ?? 'Unable to load posts.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.loadPosts,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (provider.isEmpty) {
      return const Center(child: Text('No posts yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.posts.length,
      itemBuilder: ((context, index) {
        final post = provider.posts[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            onTap: () {
              context.goNamed(
                RouteNames.postDetail,
                pathParameters: {'postId': post.id},
              );
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<ThemeProvider, bool>(
      (provider) => provider.isDarkMode,
    );

    final postListProvider = context.watch<PostListProvider>();

    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );

    final isAuthLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );

    return Scaffold(
      floatingActionButton: isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: () {
                context.goNamed(RouteNames.createPost);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create post'),
            )
          : null,
      appBar: AppBar(
        title: const Text('Simple Blog'),
        actions: [
          if (!isAuthenticated)
            IconButton(
              onPressed: () => context.goNamed(RouteNames.register),
              tooltip: 'Create account',
              icon: const Icon(Icons.person_add_outlined),
            ),
          IconButton(
            onPressed: context.read<ThemeProvider>().toggleTheme,
            tooltip: isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          if (isAuthenticated)
            IconButton(
              onPressed: isAuthLoading ? null : _logout,
              tooltip: 'Sign out',
              icon: isAuthLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: _buildBody(postListProvider),
    );
  }
}
