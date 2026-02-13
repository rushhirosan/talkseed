import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/widgets/theme_display.dart';

void main() {
  Widget wrapWithMaterialApp(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''),
        Locale('en', ''),
      ],
      home: child,
    );
  }

  group('ThemeDisplay', () {
    testWidgets('shows prompt when selectedTheme is null (dice mode)', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const ThemeDisplay(selectedTheme: null, useCardPrompt: false)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tap the dice to\nselect a theme!'), findsOneWidget);
    });

    testWidgets('shows card prompt when useCardPrompt is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const ThemeDisplay(selectedTheme: null, useCardPrompt: true)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tap the button below to draw a card'), findsOneWidget);
    });

    testWidgets('does not show dice prompt when selectedTheme is set', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const ThemeDisplay(selectedTheme: 'My chosen theme')),
      );
      await tester.pumpAndSettle();
      // When a theme is selected, the prompt text must not be shown (AnimatedTextKit shows the theme instead)
      expect(find.text('Tap the dice to\nselect a theme!'), findsNothing);
    });
  });
}
