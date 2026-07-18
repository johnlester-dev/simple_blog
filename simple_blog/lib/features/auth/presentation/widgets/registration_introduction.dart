import 'package:flutter/material.dart';
import 'package:simple_blog/app/theme/app_theme.dart';
import 'package:simple_blog/features/auth/presentation/widgets/auth_brand_mark.dart';

class RegistrationIntroduction extends StatelessWidget {
  const RegistrationIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBrandMark(),
          const SizedBox(height: 40),
          Text(
            'A thoughtful place\nfor good conversations.',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.12,
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Publish ideas, share images, and join discussions with people '
            'who care about the same things.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          const _FeatureLine(
            icon: Icons.public_rounded,
            text: 'Discover public conversations',
          ),
          const SizedBox(height: 16),
          const _FeatureLine(
            icon: Icons.photo_library_outlined,
            text: 'Share stories through multiple images',
          ),
          const SizedBox(height: 16),
          const _FeatureLine(
            icon: Icons.forum_outlined,
            text: 'Build meaningful discussions',
          ),
        ],
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary, size: 21),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
