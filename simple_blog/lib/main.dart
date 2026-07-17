import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleBlogApp());
}

class SimpleBlogApp extends StatelessWidget {
  const SimpleBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Blog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('Simple Blog'))),
    );
  }
}
