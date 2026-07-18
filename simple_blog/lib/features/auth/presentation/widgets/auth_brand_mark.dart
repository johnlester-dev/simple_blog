import 'package:flutter/material.dart';
import 'package:simple_blog/app/theme/app_theme.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.forum_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            'Simple Blog',
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
