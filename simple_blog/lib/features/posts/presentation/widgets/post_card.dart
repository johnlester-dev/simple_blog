import 'package:flutter/material.dart';
import 'package:simple_blog/core/widgets/relative_timestamp.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_image_carousel.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({required this.post, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = post.author;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        foregroundImage: author?.avatarUrl != null
                            ? NetworkImage(author!.avatarUrl!)
                            : null,
                        child: author?.avatarUrl == null
                            ? const Icon(Icons.person_outline, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author?.displayName ?? 'User',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            RelativeTimestamp(
                              dateTime: post.createdAt,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(post.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          if (post.images.isNotEmpty) PostImageCarousel(images: post.images),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    post.commentCount == 0
                        ? 'No comments yet'
                        : '${post.commentCount} ${post.commentCount == 1 ? 'comment' : 'comments'}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
