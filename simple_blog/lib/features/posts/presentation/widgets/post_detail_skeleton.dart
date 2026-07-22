import 'package:flutter/material.dart';
import 'package:simple_blog/core/widgets/loading_skeleton.dart';
import 'package:simple_blog/features/comments/presentation/widgets/comment_list_skeleton.dart';

class PostDetailSkeleton extends StatelessWidget {
  const PostDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: LoadingSkeleton(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(height: 360, radius: 0),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                SkeletonBox(width: 36, height: 36, radius: 999),
                                SizedBox(width: 10),
                                SkeletonBox(width: 130, height: 13),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const SkeletonBox(width: 320, height: 28),
                            const SizedBox(height: 16),
                            const SkeletonBox(width: 150, height: 12),
                            const SizedBox(height: 24),
                            const SkeletonBox(height: 14),
                            const SizedBox(height: 9),
                            const SkeletonBox(height: 14),
                            const SizedBox(height: 9),
                            const SkeletonBox(width: 420, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const SkeletonBox(width: 120, height: 22),
                const SizedBox(height: 16),
                const CommentListSkeleton(itemCount: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
