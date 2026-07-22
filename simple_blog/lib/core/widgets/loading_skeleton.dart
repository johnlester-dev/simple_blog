import 'package:flutter/material.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({required this.child, super.key});

  final Widget child;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
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
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _opacity,
        child: widget.child,
        builder: (context, child) {
          return Opacity(opacity: _opacity.value, child: child);
        },
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.height,
    this.width,
    this.radius = 8,
    super.key,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
