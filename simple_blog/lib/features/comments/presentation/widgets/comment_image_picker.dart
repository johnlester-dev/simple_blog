import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/comments/presentation/providers/comment_provider.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_image_preview.dart';

class CommentImagePicker extends StatelessWidget {
  const CommentImagePicker({super.key});

  Future<void> _pickImages(BuildContext context) async {
    final provider = context.read<CommentProvider>();
    final succeeded = await provider.pickImages();

    if (!context.mounted || succeeded) return;

    AppNotification.error(
      context,
      message: provider.imageErrorMessage ?? 'Unable to select comment images.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = context.select<CommentProvider, List<XFile>>(
      (provider) => provider.selectedImages,
    );

    final canAddImages = context.select<CommentProvider, bool>(
      (provider) => provider.canAddImages,
    );

    final isSubmitting = context.select<CommentProvider, bool>(
      (provider) => provider.isSubmitting,
    );

    final provider = context.read<CommentProvider>();

    if (images.isNotEmpty) {
      return PostImagePreview(
        images: images,
        canAddImages: canAddImages,
        isLoading: isSubmitting,
        onAddImages: () => _pickImages(context),
        onRemoveImage: provider.removeImageAt,
      );
    }

    return OutlinedButton.icon(
      onPressed: isSubmitting ? null : () => _pickImages(context),
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: const Text('Add images'),
    );
  }
}
