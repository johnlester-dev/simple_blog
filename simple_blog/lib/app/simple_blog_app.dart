import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:simple_blog/app/router/app_router.dart';
import 'package:simple_blog/app/theme/app_theme.dart';
import 'package:simple_blog/app/theme/theme_provider.dart';
import 'package:simple_blog/features/auth/data/auth_repository.dart';
import 'package:simple_blog/features/auth/presentation/providers/auth_provider.dart';
import 'package:simple_blog/features/posts/data/post_repository.dart';
import 'package:simple_blog/features/posts/presentation/providers/post_list_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SimpleBlogApp extends StatelessWidget {
  const SimpleBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //My Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        //Auth Repo and Provider
        Provider(create: (_) => AuthRepository(Supabase.instance.client)),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),

        //Posts Repo and Provider
        Provider(create: (_) => PostRepository(Supabase.instance.client)),
        ChangeNotifierProvider(
          create: (context) => PostListProvider(context.read<PostRepository>()),
        ),
      ],
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
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: 600, name: MOBILE),
          Breakpoint(start: 601, end: 1023, name: TABLET),
          Breakpoint(start: 1024, end: double.infinity, name: DESKTOP),
        ],
      ),
    );
  }
}
