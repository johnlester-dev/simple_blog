import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/app/simple_blog_app.dart';
import 'package:simple_blog/core/config/environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  Environment.validate();

  await Supabase.initialize(
    url: Environment.supabaseUrl,
    publishableKey: Environment.supabasePublishableKey,
  );

  runApp(const SimpleBlogApp());
}
