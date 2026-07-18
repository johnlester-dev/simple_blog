import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_form_provider.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_image_preview.dart';

class PostImagePicker extends StatelessWidget {
  const PostImagePicker({super.key});

  Future<void> _pickImages(BuildContext context) async {
    final provider = context.read<PostFormProvider>();
    final succeeded = await provider.pickImages();

    if (!context.mounted || succeeded) return;

    AppNotification.error(
      context,
      message: provider.errorMessage ?? 'Unable to select images.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = context.select<PostFormProvider, List<XFile>>(
      (provider) => provider.selectedImages,
    );

    final canAddImages = context.select<PostFormProvider, bool>(
      (provider) => provider.canAddImages,
    );

    final isLoading = context.select<PostFormProvider, bool>(
      (provider) => provider.isLoading,
    );

    final provider = context.read<PostFormProvider>();

    if (images.isEmpty) {
      return _EmptyImagePicker(
        enabled: !isLoading,
        onTap: () => _pickImages(context),
      );
    }

    return PostImagePreview(
      images: provider.selectedImages,
      canAddImages: canAddImages,
      isLoading: isLoading,
      onAddImages: () => _pickImages(context),
      onRemoveImage: provider.removeImageAt,
    );
  }
}

class _EmptyImagePicker extends StatelessWidget {
  const _EmptyImagePicker({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                'Add images',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose up to ${PostFormProvider.maxImages} images',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
