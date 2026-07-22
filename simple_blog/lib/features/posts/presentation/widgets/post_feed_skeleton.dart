import 'package:flutter/material.dart';

class PostFeedSkeleton extends StatefulWidget {
  const PostFeedSkeleton({super.key});

  @override
  State<PostFeedSkeleton> createState() => _PostFeedSkeletonState();
}

class _PostFeedSkeletonState extends State<PostFeedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.42,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return Opacity(opacity: _opacity.value, child: child);
        },
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 150, height: 28, color: skeletonColor),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: 310, height: 14, color: skeletonColor),
                ],
              );
            }

            return _PostCardSkeleton(color: skeletonColor);
          },
        ),
      ),
    );
  }
}

class _PostCardSkeleton extends StatelessWidget {
  final Color color;

  const _PostCardSkeleton({required this.color});

  @override
  Widget build(BuildContext context) {
    final outlineColor = Theme.of(context).colorScheme.outlineVariant;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBox(
                      width: 40,
                      height: 40,
                      radius: 999,
                      color: color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: 120, height: 12, color: color),
                          const SizedBox(height: 6),
                          _SkeletonBox(width: 72, height: 10, color: color),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SkeletonBox(height: 22, color: color),
                const SizedBox(height: 10),
                _SkeletonBox(width: 240, height: 14, color: color),
                const SizedBox(height: 7),
                _SkeletonBox(width: 190, height: 14, color: color),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(color: color),
          ),
          Divider(height: 1, color: outlineColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: _SkeletonBox(width: 130, height: 14, color: color),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBox({
    this.width,
    required this.height,
    this.radius = 8,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
