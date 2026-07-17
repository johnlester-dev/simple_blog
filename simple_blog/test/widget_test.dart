import 'package:flutter_test/flutter_test.dart';
import 'package:simple_blog/main.dart';

void main() {
  testWidgets('displays the application title', (tester) async {
    await tester.pumpWidget(const SimpleBlogApp());

    expect(find.text('Simple Blog'), findsOneWidget);
  });
}
