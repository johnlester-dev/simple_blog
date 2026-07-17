import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_blog/app/theme/theme_provider.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<ThemeProvider, bool>(
      (provider) => provider.isDarkMode,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Blog'),
        actions: [
          IconButton(
            onPressed: context.read<ThemeProvider>().toggleTheme,
            tooltip: isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: const Center(child: Text('Posts will appear here')),
    );
  }
}
