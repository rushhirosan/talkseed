import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('ja'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phase 1 shows three selectable candidates', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('1on1'), findsOneWidget);
    expect(find.text('自己内省・1on1'), findsNothing);
    expect(find.text('このフェーズで話す問いを1つ選んでください'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_off), findsNWidgets(3));
    expect(find.widgetWithText(ElevatedButton, '次のフェーズへ'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '次のフェーズへ'),
      ).onPressed,
      isNull,
    );
  });

  testWidgets('selecting a prompt enables next phase', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.byIcon(Icons.radio_button_off).first);
    await tester.pumpAndSettle();

    expect(find.text('この問いで話す'), findsOneWidget);
    expect(find.text('選び直す'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '次のフェーズへ'),
      ).onPressed,
      isNotNull,
    );
  });

  testWidgets('next phase advances to phase 2', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.byIcon(Icons.radio_button_off).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '次のフェーズへ'));
    await tester.pumpAndSettle();

    expect(find.text('フェーズ 2 / 7'), findsOneWidget);
    expect(find.text('今週の仕事・進捗・ボトルネック'), findsOneWidget);
  });
}
