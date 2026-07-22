import 'package:flutter/material.dart';
import 'package:simple_blog/app/theme/app_theme.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({this.centered = false, super.key});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    final logo = Icon(
      Icons.forum_outlined,
      color: AppTheme.primary,
      size: centered ? 52 : 36,
    );

    if (centered) {
      return Column(
        children: [
          logo,
          const SizedBox(height: 14),
          Text(
            'Simple Blog/Forum',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connecting ideas, one post at a time.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        logo,
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            'Simple Blog/Forum',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }
}
