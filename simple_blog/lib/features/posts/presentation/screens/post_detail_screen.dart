import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_detail_provider.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_list_provider.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  const PostDetailScreen({required this.postId, super.key});

  Widget _buildBody(BuildContext context, PostDetailProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.errorMessage ?? 'Unable to load this post.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => provider.loadPost(postId),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.wasNotFound) {
      return const Center(child: Text('Post not found.'));
    }

    return _PostContent(post: provider.post!);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PostDetailProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text(
            'This will permanently delete the post and all its images. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final deleted = await provider.deletePost();

    if (!context.mounted) return;

    if (!deleted) {
      AppNotification.error(
        context,
        message: provider.deleteErrorMessage ?? 'Unable to delete this post.',
      );
      return;
    }

    await context.read<PostListProvider>().loadPosts();

    if (!context.mounted) return;

    AppNotification.success(
      context,
      message: 'Your post was deleted successfully.',
    );

    context.goNamed(RouteNames.posts);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostDetailProvider>();
    final currentUserId = context.select<AuthProvider, String?>(
      (provider) => provider.currentUser?.id,
    );

    final post = provider.post;
    final isOwner = post != null && post.userId == currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          if (isOwner) ...[
            IconButton(
              onPressed: provider.isDeleting
                  ? null
                  : () async {
                      final updatedPost = await context.pushNamed<Post>(
                        RouteNames.editPost,
                        pathParameters: {'postId': post.id},
                        extra: post,
                      );

                      if (!context.mounted || updatedPost == null) return;

                      await provider.loadPost(post.id);
                    },
              tooltip: 'Edit post',
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: provider.isDeleting
                  ? null
                  : () => _confirmDelete(context, provider),
              tooltip: 'Delete post',
              icon: provider.isDeleting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ],
      ),
      body: _buildBody(context, provider),
    );
  }
}

class _PostContent extends StatelessWidget {
  final Post post;
  const _PostContent({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(post.createdAt.toLocal());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 760),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.images.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: PageView.builder(
                      itemCount: post.images.length,
                      itemBuilder: (context, index) {
                        final image = post.images[index];

                        return Image.network(
                          image.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(
                              color: Colors.black12,
                              child: Center(
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 17,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (post.images.length > 1) ...[
                            const Spacer(),
                            const Icon(Icons.photo_library_outlined, size: 17),
                            const SizedBox(width: 5),
                            Text('${post.images.length} images'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        post.content,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
