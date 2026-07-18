import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostImagePreview extends StatefulWidget {
  const PostImagePreview({
    required this.images,
    required this.canAddImages,
    required this.isLoading,
    required this.onAddImages,
    required this.onRemoveImage,
    super.key,
  });

  final List<XFile> images;
  final bool canAddImages;
  final bool isLoading;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveImage;

  @override
  State<PostImagePreview> createState() => _PostImagePreviewState();
}

class _PostImagePreviewState extends State<PostImagePreview> {
  int _currentIndex = 0;

  void _removeCurrentImage() {
    if (widget.isLoading || widget.images.isEmpty) return;

    widget.onRemoveImage(_currentIndex);

    setState(() {
      _currentIndex = math.max(
        0,
        math.min(_currentIndex, widget.images.length - 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _SelectedImage(image: widget.images[index]);
            },
          ),
          Positioned(
            top: 12,
            left: 12,
            child: FilledButton.tonalIcon(
              onPressed: widget.canAddImages && !widget.isLoading
                  ? widget.onAddImages
                  : null,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add'),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton.filled(
              onPressed: widget.isLoading ? null : _removeCurrentImage,
              tooltip: 'Remove image',
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedImage extends StatefulWidget {
  const _SelectedImage({required this.image});

  final XFile image;

  @override
  State<_SelectedImage> createState() => _SelectedImageState();
}

class _SelectedImageState extends State<_SelectedImage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.image.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant _SelectedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image.path != widget.image.path) {
      _bytes = widget.image.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Icon(Icons.broken_image_outlined));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Image.memory(
          snapshot.data!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        );
      },
    );
  }
}
