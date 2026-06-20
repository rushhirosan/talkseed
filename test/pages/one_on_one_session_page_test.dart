import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';
import 'package:theme_dice/widgets/play/play_session_ui.dart';
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

Widget _wrapEn(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
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

Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _startLiteSession(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(PlayPrimaryButton, 'この型で始める'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('format setup shows presets before session', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);

    expect(find.text('今日の1on1の型'), findsOneWidget);
    expect(find.text('ライト'), findsOneWidget);
    expect(find.text('成長深掘り'), findsOneWidget);
    expect(find.text('関係性・FB'), findsOneWidget);
    expect(find.text('フル'), findsOneWidget);
    expect(find.widgetWithText(PlayPrimaryButton, 'この型で始める'), findsOneWidget);
  });

  testWidgets('lite session phase 1 shows three selectable candidates',
      (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);
    await _startLiteSession(tester);

    expect(find.text('1on1'), findsOneWidget);
    expect(find.text('フェーズ 1 / 3'), findsOneWidget);
    expect(find.text('このフェーズで話す問いを1つ選んでください'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_off), findsNWidgets(3));
    expect(find.widgetWithText(PlayPrimaryButton, '次のフェーズへ'), findsOneWidget);
    expect(
      tester.widget<PlayPrimaryButton>(
        find.widgetWithText(PlayPrimaryButton, '次のフェーズへ'),
      ).onPressed,
      isNull,
    );
  });

  testWidgets('selecting a prompt enables next phase', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);
    await _startLiteSession(tester);

    await tester.tap(find.byIcon(Icons.radio_button_off).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('この問いで話す'), findsOneWidget);
    expect(find.text('今日のテーマ'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('選び直す'), findsOneWidget);
    expect(
      tester.widget<PlayPrimaryButton>(
        find.widgetWithText(PlayPrimaryButton, '次のフェーズへ'),
      ).onPressed,
      isNotNull,
    );
  });

  testWidgets('next phase advances to phase 2 in lite session', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);
    await _startLiteSession(tester);

    await tester.tap(find.byIcon(Icons.radio_button_off).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(PlayPrimaryButton, '次のフェーズへ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('フェーズ 2 / 3'), findsOneWidget);
    expect(find.text('業務・働き方'), findsWidgets);
    expect(find.text('今日のテーマ'), findsOneWidget);
  });

  testWidgets('full format shows five phases', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);

    await tester.tap(find.text('フル'));
    await tester.pump();
    await tester.tap(find.widgetWithText(PlayPrimaryButton, 'この型で始める'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('フェーズ 1 / 5'), findsOneWidget);
  });

  testWidgets('theme agenda expands to show all phases', (tester) async {
    await tester.pumpWidget(_wrap(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);
    await _startLiteSession(tester);

    await tester.tap(find.byIcon(Icons.radio_button_off).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('今日のテーマ'), findsOneWidget);
    await tester.tap(find.text('今日のテーマ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('チェックイン'), findsWidgets);
    expect(find.text('業務・働き方'), findsWidgets);
    expect(find.text('締め'), findsWidgets);
    expect(find.text('未選択'), findsWidgets);
  });

  testWidgets('English locale shows English prompts', (tester) async {
    await tester.pumpWidget(_wrapEn(const OneOnOneSessionPage()));
    await _pumpUntilLoaded(tester);

    expect(find.text('Today\'s 1-on-1 format'), findsOneWidget);
    expect(find.text('Lite'), findsOneWidget);

    await tester.tap(find.widgetWithText(PlayPrimaryButton, 'Start with this format'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Phase 1 of 3'), findsOneWidget);
    expect(find.text('Choose one prompt for this phase'), findsOneWidget);
    expect(find.text('このフェーズで話す問いを1つ選んでください'), findsNothing);
    expect(find.textContaining('エネルギー'), findsNothing);
    expect(find.textContaining('今週'), findsNothing);
    expect(find.text('Phase 1 of 7'), findsNothing);
    expect(find.text('Work & progress'), findsNothing);
  });
}
