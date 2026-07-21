import 'package:flutter/material.dart';
import 'package:simple_blog/core/widgets/network_image_gallery.dart';
import 'package:simple_blog/features/comments/data/models/comment.dart';

enum CommentAction { edit, delete }

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isOwner;
  final bool isDeleting;
  final VoidCallback? onDelete;
  final bool isUpdating;
  final VoidCallback? onEdit;

  const CommentCard({
    required this.comment,
    this.isOwner = false,
    this.isDeleting = false,
    this.onDelete,
    this.isUpdating = false,
    this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(comment.createdAt.toLocal());
    final author = comment.author;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
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
                Text(
                  author?.displayName ?? 'User',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 6),
                  if (isDeleting || isUpdating)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    PopupMenuButton<CommentAction>(
                      tooltip: 'Comment actions',
                      onSelected: (action) {
                        switch (action) {
                          case CommentAction.edit:
                            onEdit?.call();
                          case CommentAction.delete:
                            onDelete?.call();
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: CommentAction.edit,
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: CommentAction.delete,
                            child: ListTile(
                              leading: Icon(Icons.delete_outline_rounded),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ];
                      },
                    ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              comment.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            if (comment.images.isNotEmpty) ...[
              const SizedBox(height: 14),
              NetworkImageGallery(
                imageUrls: comment.images
                    .map((image) => image.imageUrl)
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
