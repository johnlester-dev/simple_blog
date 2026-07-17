import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/router/app_router.dart';
import 'package:simple_blog/app/theme/app_theme.dart';
import 'package:simple_blog/app/theme/theme_provider.dart';

class SimpleBlogApp extends StatelessWidget {
  const SimpleBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (provider) => provider.themeMode,
    );

    return MaterialApp.router(
      title: 'Simple Blog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
