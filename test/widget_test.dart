import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/main.dart';

void main() {
  testWidgets('MyApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    // MainPage shows loading or tutorial/mode selection; we only verify the app tree is built.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
