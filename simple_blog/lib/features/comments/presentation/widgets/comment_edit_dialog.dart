import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/core/widgets/app_notification.dart';
import 'package:simple_blog/core/widgets/network_image_gallery.dart';
import 'package:simple_blog/features/comments/data/models/comment.dart';
import 'package:simple_blog/features/comments/data/models/comment_image.dart';
import 'package:simple_blog/features/posts/presentation/widgets/post_image_preview.dart';

class CommentEditResult {
  final String content;
  final List<CommentImage> removedImages;
  final List<XFile> newImages;

  const CommentEditResult({
    required this.content,
    required this.removedImages,
    required this.newImages,
  });
}

class CommentEditDialog extends StatefulWidget {
  final Comment comment;

  const CommentEditDialog({required this.comment, super.key});

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  static const maxImages = 3;

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _contentController;
  late final List<CommentImage> _existingImages;

  final List<CommentImage> _removedImages = [];
  final List<XFile> _newImages = [];

  int get _remainingSlots {
    return maxImages - _existingImages.length - _newImages.length;
  }

  bool get _canAddImages => _remainingSlots > 0;

  @override
  void initState() {
    super.initState();

    _contentController = TextEditingController(text: widget.comment.content);

    _existingImages = List.of(widget.comment.images);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (!_canAddImages) return;

    try {
      final images = kIsWeb
          ? await _imagePicker.pickMultiImage(
              limit: _remainingSlots,
              requestFullMetadata: false,
            )
          : await _imagePicker.pickMultiImage(
              maxWidth: 1920,
              maxHeight: 1920,
              imageQuality: 85,
              limit: _remainingSlots,
              requestFullMetadata: false,
            );

      if (!mounted || images.isEmpty) return;

      setState(() {
        _newImages.addAll(images.take(_remainingSlots));
      });
    } on PlatformException catch (error) {
      if (!mounted) return;

      AppNotification.error(
        context,
        message: error.message ?? 'Unable to select images.',
      );
    } catch (_) {
      if (!mounted) return;

      AppNotification.error(context, message: 'Unable to select images.');
    }
  }

  void _removeExistingImage(int index) {
    if (index < 0 || index >= _existingImages.length) return;

    setState(() {
      _removedImages.add(_existingImages.removeAt(index));
    });
  }

  void _removeNewImage(int index) {
    if (index < 0 || index >= _newImages.length) return;

    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      CommentEditResult(
        content: _contentController.text.trim(),
        removedImages: List.of(_removedImages),
        newImages: List.of(_newImages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit comment'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _contentController,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Comment cannot be empty.';
                    }

                    return null;
                  },
                ),
                if (_existingImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Current images'),
                  const SizedBox(height: 8),
                  NetworkImageGallery(
                    imageUrls: _existingImages
                        .map((image) => image.imageUrl)
                        .toList(),
                    onRemove: _removeExistingImage,
                  ),
                ],
                if (_newImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('New images'),
                  const SizedBox(height: 8),
                  PostImagePreview(
                    images: _newImages,
                    canAddImages: _canAddImages,
                    isLoading: false,
                    onAddImages: _pickImages,
                    onRemoveImage: _removeNewImage,
                  ),
                ],
                if (_newImages.isEmpty && _canAddImages) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text('Add images ($_remainingSlots remaining)'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
