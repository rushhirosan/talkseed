import 'package:flutter/material.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/services/checkin_checkout_service.dart';
import 'package:theme_dice/services/self_reflection_service.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/utils/error_dialog_helper.dart';
import 'package:theme_dice/pages/mode_selection_page.dart';
import 'package:theme_dice/pages/topics_page.dart';
import 'package:theme_dice/pages/value_card_page.dart';

/// カード設定画面（デッキ選択方式）
/// サイコロ設定とは別の、価値観カード・チェックインカード風のUI
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

    // チームビルディングは価値観カード フルルール
    if (deck.type == CardDeckType.teamBuilding) {
      final themes = deck.themes(l10n);
      await PreferencesHelper.saveLastCardThemes(themes);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: ValueCardPage(themes: themes),
        ),
      );
      return;
    }

    try {
      if (deck.type == CardDeckType.checkIn) {
        final checkInThemes =
            await CheckInCheckOutService.loadCheckInQuestions();
        final checkOutThemes =
            await CheckInCheckOutService.loadCheckOutQuestions();
        final combined = [...checkInThemes, ...checkOutThemes];
        await PreferencesHelper.saveLastCardThemes(combined);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          RouteTransitions.forwardRoute(
            page: TopicsPage(
              initialThemes: {PolyhedronType.cube: combined},
              sessionConfig: null,
              checkInThemes: checkInThemes,
              checkOutThemes: checkOutThemes,
            ),
          ),
        );
      } else {
        // 自己内省・1on1
        final data = await SelfReflectionService.loadThemesWithSections();
        await PreferencesHelper.saveLastCardThemes(data.themes);
        if (!mounted) return;
        final themeCategoryMap =
            CardDeck.buildReflectionCategoryMap(data.sectionIdByTheme);
        Navigator.of(context).pushReplacement(
          RouteTransitions.forwardRoute(
            page: TopicsPage(
              initialThemes: {PolyhedronType.cube: data.themes},
              sessionConfig: null,
              themeCategoryMap: themeCategoryMap,
            ),
          ),
        );
      }
    } on ThemeDiceException {
      if (!mounted) return;
      await ErrorDialogHelper.showDataLoadError(
        context,
        onRetry: () => _playWithDeck(deck),
      );
    } catch (_) {
      if (!mounted) return;
      await ErrorDialogHelper.showDataLoadError(
        context,
        onRetry: () => _playWithDeck(deck),
      );
    }
  }

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _cardBlue = Color(0xFFE3F2FD);
  static const Color _cardGreen = Color(0xFFE8F5E9);
  static const Color _cardOrange = Color(0xFFFFF3E0);
  static const Color _cardPurple = Color(0xFFF3E5F5);
  static const Color _cardTeal = Color(0xFFE0F2F1);

  Color _getDeckColor(CardDeckType type) {
    switch (type) {
      case CardDeckType.teamBuilding:
        return _cardBlue;
      case CardDeckType.checkIn:
        return _cardGreen;
      case CardDeckType.oneOnOne:
        return _cardOrange;
    }
  }

  IconData _getDeckIcon(CardDeckType type) {
    switch (type) {
      case CardDeckType.teamBuilding:
        return Icons.groups;
      case CardDeckType.checkIn:
        return Icons.wb_sunny;
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
              ...CardDeck.allDecks.map((deck) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DeckCard(
                    deck: deck,
                    deckColor: _getDeckColor(deck.type),
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
