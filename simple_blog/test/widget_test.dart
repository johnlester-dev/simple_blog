import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_blog/app/simple_blog_app.dart';

void main() {
  testWidgets('displays the public post list', (tester) async {
    await tester.pumpWidget(const SimpleBlogApp());
    await tester.pumpAndSettle();

    expect(find.text('Simple Blog'), findsOneWidget);
    expect(find.text('Posts will appear here'), findsOneWidget);
  });

  testWidgets('switches between dark and light themes', (tester) async {
    await tester.pumpWidget(const SimpleBlogApp());
    await tester.pumpAndSettle();

    var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.themeMode, ThemeMode.dark);

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pumpAndSettle();

    materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.themeMode, ThemeMode.light);
  });
}
