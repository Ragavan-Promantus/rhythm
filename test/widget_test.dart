// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:rhythm/main.dart';

void main() {
  testWidgets('Login screen renders expected content', (WidgetTester tester) async {
    await tester.pumpWidget(const RhythmApp());

    expect(find.text('EchoStream'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });
}
