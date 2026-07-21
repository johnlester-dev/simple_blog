import 'package:flutter/material.dart';
import 'package:simple_blog/features/posts/data/models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({required this.post, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(post.createdAt.toLocal());
    final author = post.author;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        foregroundImage: author?.avatarUrl != null
                            ? NetworkImage(author!.avatarUrl!)
                            : null,
                        child: author?.avatarUrl == null
                            ? const Icon(Icons.person_outline, size: 18)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          author?.displayName ?? 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
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
                        const Icon(Icons.photo_library_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text('${post.images.length}'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
