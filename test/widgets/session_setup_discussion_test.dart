import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/pages/session_setup_page.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';

void main() {
  testWidgets('SessionSetupPage group discussion lays out without hanging',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTalkShuffleTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: SessionSetupPage(
          forDiscussion: true,
          fromCardSettings: true,
          discussionDeckType: CardDeckType.groupDiscussion,
          deckLabel: 'Test deck',
          themes: {
            PolyhedronType.cube: List<String>.filled(20, 'placeholder theme'),
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SessionSetupPage), findsOneWidget);
    expect(find.textContaining('セッション設定'), findsWidgets);
  });
}
