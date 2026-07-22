import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:simple_blog/features/posts/data/models/post_image.dart';

class PostImageCarousel extends StatefulWidget {
  const PostImageCarousel({required this.images, this.height = 420, super.key});

  final List<PostImage> images;
  final double height;

  @override
  State<PostImageCarousel> createState() => _PostImageCarouselState();
}

class _PostImageCarouselState extends State<PostImageCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  bool get _hasMultipleImages => widget.images.length > 1;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPage(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: colors.surfaceContainerHighest,
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                scrollbars: false,
                dragDevices: const {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.images[index].imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: colors.onSurfaceVariant,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (_hasMultipleImages) ...[
            if (_currentPage > 0)
              _CarouselArrow(
                alignment: Alignment.centerLeft,
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous image',
                onPressed: () => _showPage(_currentPage - 1),
              ),
            if (_currentPage < widget.images.length - 1)
              _CarouselArrow(
                alignment: Alignment.centerRight,
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next image',
                onPressed: () => _showPage(_currentPage + 1),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.images.length, (index) {
                        final selected = index == _currentPage;
                        return GestureDetector(
                          onTap: () => _showPage(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: selected ? 18 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.48),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_currentPage + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({
    required this.alignment,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          color: Colors.black.withValues(alpha: 0.58),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            color: Colors.white,
            icon: Icon(icon),
          ),
        ),
      ),
    );
  }
}
