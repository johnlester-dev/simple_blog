import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/comments/data/models/comment.dart';
import 'package:simple_blog/features/comments/presentation/providers/comment_provider.dart';
import 'package:simple_blog/features/comments/presentation/widgets/comment_card.dart';
import 'package:simple_blog/features/comments/presentation/widgets/comment_edit_dialog.dart';

class CommentList extends StatelessWidget {
  final String postId;

  const CommentList({required this.postId, super.key});

  Future<void> _confirmDelete(BuildContext context, Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete comment?'),
          content: const Text(
            'This will permanently delete the comment and its images.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
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

    final provider = context.read<CommentProvider>();
    final deleted = await provider.deleteComment(comment);

    if (!context.mounted) return;

    if (!deleted) {
      AppNotification.error(
        context,
        message:
            provider.deleteErrorMessage ?? 'Unable to delete this comment.',
      );
      return;
    }

    AppNotification.success(context, message: 'Your comment was deleted.');
  }

  Future<void> _editComment(BuildContext context, Comment comment) async {
    final result = await showDialog<CommentEditResult>(
      context: context,
      builder: (dialogContext) {
        return CommentEditDialog(comment: comment);
      },
    );

    if (result == null || !context.mounted) return;

    final hasTextChange = result.content != comment.content;

    final hasImageChanges =
        result.removedImages.isNotEmpty || result.newImages.isNotEmpty;

    if (!hasTextChange && !hasImageChanges) return;

    final provider = context.read<CommentProvider>();

    final updated = await provider.updateComment(
      comment: comment,
      content: result.content,
      removedImages: result.removedImages,
      newImages: result.newImages,
    );

    if (!context.mounted) return;

    if (!updated) {
      AppNotification.error(
        context,
        message:
            provider.updateErrorMessage ?? 'Unable to update this comment.',
      );
      return;
    }

    AppNotification.success(context, message: 'Your comment was updated.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();

    final currentUserId = context.select<AuthProvider, String?>(
      (provider) => provider.currentUser?.id,
    );

    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              provider.errorMessage ?? 'Unable to load comments.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => provider.loadComments(postId),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (provider.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No comments yet. Be the first to comment.')),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < provider.comments.length; index++) ...[
          CommentCard(
            comment: provider.comments[index],
            isOwner: provider.comments[index].userId == currentUserId,
            isDeleting: provider.isDeletingComment(provider.comments[index].id),
            isUpdating: provider.isUpdatingComment(provider.comments[index].id),
            onEdit: () => _editComment(context, provider.comments[index]),
            onDelete: () => _confirmDelete(context, provider.comments[index]),
          ),
          if (index < provider.comments.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
