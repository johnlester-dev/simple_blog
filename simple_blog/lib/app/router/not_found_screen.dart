import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/route_names.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthProvider, bool>(
      (provider) => provider.isAuthenticated,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore_off_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'This page doesn\'t exist',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'The link may be incorrect or the page may have moved.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.goNamed(RouteNames.posts),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Go to feed'),
                  ),
                ),
                if (!isAuthenticated) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.goNamed(
                        RouteNames.register,
                        queryParameters: {'mode': 'login'},
                      ),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Sign in'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
