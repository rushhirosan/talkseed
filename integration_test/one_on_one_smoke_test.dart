import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1on1 coach UI screenshots', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OneOnOneSessionPage(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await binding.takeScreenshot('one_on_one_01_format');

    await tester.tap(find.text('この型で始める'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot('one_on_one_02_candidates');

    await tester.tap(find.byIcon(Icons.radio_button_off).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot('one_on_one_03_selected');

    await tester.tap(find.text('次のフェーズへ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot('one_on_one_04_phase2');
  });
}
