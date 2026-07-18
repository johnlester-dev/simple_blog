import 'package:flutter/material.dart';

class NetworkImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final ValueChanged<int>? onRemove;
  final bool enabled;

  const NetworkImageGallery({
    super.key,
    required this.imageUrls,
    this.onRemove,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    );
                  },
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    tooltip: 'Remove image',
                    onPressed: enabled ? () => onRemove!(index) : null,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
