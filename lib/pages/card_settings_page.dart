import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/pages/mode_selection_page.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';
import 'package:theme_dice/pages/session_setup_page.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';

/// カード設定画面（デッキ選択方式）
class CardSettingsPage extends StatefulWidget {
  const CardSettingsPage({super.key});

  @override
  State<CardSettingsPage> createState() => _CardSettingsPageState();
}

class _CardSettingsPageState extends State<CardSettingsPage> {
  void _goBackToModeSelection() {
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  void _playWithDeck(CardDeck deck) async {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;

    // チームビルディング → 重要度ランキングゲーム（価値観カード）
    if (deck.type == CardDeckType.teamBuilding) {
      final themes = deck.themes(l10n);
      await PreferencesHelper.saveLastCardThemes(themes);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: SessionSetupPage(
            themes: {PolyhedronType.cube: themes},
            forValueCard: true,
            fromCardSettings: true,
          ),
        ),
      );
      return;
    }

    // グループディスカッション → 議論モード
    if (deck.type == CardDeckType.groupDiscussion) {
      final themes = deck.themes(l10n);
      await PreferencesHelper.saveLastCardThemes(themes);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: SessionSetupPage(
            themes: {PolyhedronType.cube: themes},
            forDiscussion: true,
            fromCardSettings: true,
            deckLabel: deck.name(l10n),
            discussionDeckType: deck.type,
          ),
        ),
      );
      return;
    }

    if (deck.type == CardDeckType.oneOnOne) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: const OneOnOneSessionPage(),
        ),
      );
    }
  }

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  Color _getDeckColor(BuildContext context, CardDeckType type) {
    final t = context.talkShuffle;
    switch (type) {
      case CardDeckType.teamBuilding:
        return t.deckTileTeamBuilding;
      case CardDeckType.groupDiscussion:
        return t.deckTileProblemSolving;
      case CardDeckType.oneOnOne:
        return t.deckTileOneOnOne;
    }
  }

  IconData _getDeckIcon(CardDeckType type) {
    switch (type) {
      case CardDeckType.teamBuilding:
        return Icons.groups;
      case CardDeckType.groupDiscussion:
        return Icons.forum_outlined;
      case CardDeckType.oneOnOne:
        return Icons.psychology_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _white,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: _goBackToModeSelection,
          tooltip: l10n.backToModeSelection,
        ),
        title: Text(
          l10n.cardSettingsTitle,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.selectDeckPrompt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _black.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
              ...CardDeck.visibleDecks.map((deck) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DeckCard(
                    deck: deck,
                    deckColor: _getDeckColor(context, deck.type),
                    icon: _getDeckIcon(deck.type),
                    onTap: () => _playWithDeck(deck),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final CardDeck deck;
  final Color deckColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DeckCard({
    required this.deck,
    required this.deckColor,
    required this.icon,
    required this.onTap,
  });

  static const Color _black = Colors.black87;
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: deckColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _black.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: _black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name(l10n),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deck.description(l10n),
                      style: TextStyle(
                        fontSize: 13,
                        color: _black.withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: _black.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
