import 'package:flutter/material.dart';
import 'package:simple_blog/core/widgets/loading_skeleton.dart';

class CommentListSkeleton extends StatelessWidget {
  const CommentListSkeleton({this.itemCount = 3, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LoadingSkeleton(
      child: Column(
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SkeletonBox(width: 32, height: 32, radius: 999),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: SkeletonBox(width: 120, height: 12),
                        ),
                        const SizedBox(width: 24),
                        SkeletonBox(width: 76, height: 10),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SkeletonBox(height: 13),
                    const SizedBox(height: 8),
                    const SkeletonBox(width: 240, height: 13),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
