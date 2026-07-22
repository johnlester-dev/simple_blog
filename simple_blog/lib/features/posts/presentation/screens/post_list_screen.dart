import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/app/theme/theme_provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_form_provider.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_list_provider.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_composer_dialog.dart';
import 'package:simple_blog/features/posts/presentation/widgets/feed_header.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_card.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_feed_skeleton.dart';
import 'package:simple_blog/features/profile/data/profile_repository.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  String? _profileUserId;
  String? _avatarUrl;

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

  Future<void> _openComposer() async {
    if (!context.read<AuthProvider>().isAuthenticated) {
      context.goNamed(RouteNames.register, queryParameters: {'mode': 'login'});
      return;
    }

    final repository = context.read<PostRepository>();
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => PostFormProvider(repository),
        child: const PostComposerDialog(),
      ),
    );

    if (!mounted || created != true) return;
    await context.read<PostListProvider>().loadPosts();
    if (!mounted) return;
    AppNotification.success(context, message: 'Your post was published.');
  }

  void _syncProfile(String? userId) {
    if (_profileUserId == userId) return;
    _profileUserId = userId;
    _avatarUrl = null;

    if (userId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final profile = await context
            .read<ProfileRepository>()
            .fetchCurrentProfile();
        if (!mounted || _profileUserId != userId) return;
        setState(() => _avatarUrl = profile.avatarUrl);
      } catch (_) {
        // The fallback avatar remains visible if the profile cannot be loaded.
      }
    });
  }

  Widget _buildBody(
    PostListProvider provider, {
    required bool isAuthenticated,
  }) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return const PostFeedSkeleton();
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
      return RefreshIndicator(
        onRefresh: provider.loadPosts,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            _FeedIntro(
              isAuthenticated: isAuthenticated,
              avatarUrl: _avatarUrl,
              onCreatePost: _openComposer,
            ),
            const SizedBox(height: 24),
            _EmptyFeed(
              isAuthenticated: isAuthenticated,
              onAction: isAuthenticated
                  ? _openComposer
                  : () => context.goNamed(
                      RouteNames.register,
                      queryParameters: {'mode': 'login'},
                    ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadPosts,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: provider.posts.length + 2,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FeedIntro(
              isAuthenticated: isAuthenticated,
              avatarUrl: _avatarUrl,
              onCreatePost: _openComposer,
            );
          }

          if (index > provider.posts.length) {
            if (provider.isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (provider.hasMore) {
              return Center(
                child: OutlinedButton.icon(
                  onPressed: provider.loadMore,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Load more posts'),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You’re all caught up',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final post = provider.posts[index - 1];

          return PostCard(
            post: post,
            onTap: () {
              context.goNamed(
                RouteNames.postDetail,
                pathParameters: {'postId': post.id},
              );
            },
          );
        },
      ),
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
    final currentUserId = context.select<AuthProvider, String?>(
      (provider) => provider.currentUser?.id,
    );
    _syncProfile(currentUserId);

    final isAuthLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );

    return Scaffold(
      appBar: FeedHeader(
        isAuthenticated: isAuthenticated,
        isDarkMode: isDarkMode,
        isAuthLoading: isAuthLoading,
        onLogin: () => context.goNamed(
          RouteNames.register,
          queryParameters: {'mode': 'login'},
        ),
        onRegister: () => context.goNamed(RouteNames.register),
        onToggleTheme: context.read<ThemeProvider>().toggleTheme,
        onProfile: () async {
          await context.pushNamed(RouteNames.profile);

          if (!context.mounted) return;

          _profileUserId = null;
          _syncProfile(currentUserId);
          await context.read<PostListProvider>().loadPosts();
        },
        onLogout: _logout,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600 ? 12.0 : 24.0;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _buildBody(
                  postListProvider,
                  isAuthenticated: isAuthenticated,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeedIntro extends StatelessWidget {
  final bool isAuthenticated;
  final String? avatarUrl;
  final VoidCallback onCreatePost;

  const _FeedIntro({
    required this.isAuthenticated,
    required this.avatarUrl,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feed', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onCreatePost,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      foregroundImage: isAuthenticated && avatarUrl != null
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: isAuthenticated && avatarUrl != null
                          ? null
                          : Icon(
                              isAuthenticated
                                  ? Icons.person_outline_rounded
                                  : Icons.login_rounded,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isAuthenticated
                            ? 'Create a post'
                            : 'Sign in to create a post',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isAuthenticated
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.primary,
                          fontWeight: isAuthenticated
                              ? FontWeight.normal
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      isAuthenticated
                          ? Icons.image_outlined
                          : Icons.arrow_forward_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.isAuthenticated, required this.onAction});

  final bool isAuthenticated;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 30,
                color: colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start the conversation',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isAuthenticated
                  ? 'Share the first story, question, or idea with the community.'
                  : 'There are no posts yet. Sign in and be the first to share.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(
                isAuthenticated ? Icons.add_rounded : Icons.login_rounded,
              ),
              label: Text(isAuthenticated ? 'Create first post' : 'Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
