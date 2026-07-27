import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/pages/discussion_prompt_page.dart';
import 'package:theme_dice/pages/dice_page.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';
import 'package:theme_dice/pages/value_card_page.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/route_transitions.dart';

/// 保存済みプリセットからセッションを起動する
class PresetLauncher {
  PresetLauncher._();

  static Future<void> launch(
    BuildContext context,
    SessionPreset preset,
  ) async {
    await PresetService.markPresetUsed(preset.id);
    if (!context.mounted) {
      return;
    }

    switch (preset.mode) {
      case SessionPresetMode.oneOnOne:
        await _launchOneOnOne(context, preset);
      case SessionPresetMode.groupDiscussion:
        await _launchGroupDiscussion(context, preset);
      case SessionPresetMode.valueCards:
        await _launchValueCards(context, preset);
      case SessionPresetMode.dice:
        await _launchDice(context, preset);
    }
  }

  static Future<void> _launchOneOnOne(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final format = preset.oneOnOneFormat;
    if (format == null) {
      return;
    }
    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: OneOnOneSessionPage(
          initialFormat: format,
          autoStartSession: true,
        ),
      ),
    );
  }

  static Future<void> _launchGroupDiscussion(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final config = preset.sessionConfig;
    final deckType = preset.discussionDeckType;
    if (config == null || deckType == null) {
      return;
    }
    final ids = config.discussionCategoryIds;
    if (ids != null && ids.isEmpty) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final deck = CardDeck.allDecks.firstWhere((d) => d.type == deckType);
    final themes = deck.themes(l10n);

    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: DiscussionPromptPage(
          themes: themes,
          sessionConfig: config,
          deckTitle: preset.deckLabel ?? deck.name(l10n),
          discussionDeckType: deckType,
        ),
      ),
    );
  }

  static Future<void> _launchValueCards(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final config = preset.sessionConfig;
    if (config == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final deck = CardDeck.allDecks.firstWhere(
      (d) => d.type == CardDeckType.teamBuilding,
    );
    final themes = deck.themes(l10n);

    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: ValueCardPage(
          themes: themes,
          sessionConfig: config,
        ),
      ),
    );
  }

  static Future<void> _launchDice(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final config = preset.sessionConfig;
    final themes = preset.diceThemes;
    if (config == null || themes == null || themes.length != 6) {
      return;
    }

    await PreferencesHelper.saveLastThemes(themes);
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: DicePage(
          initialType: PolyhedronType.cube,
          initialThemes: {PolyhedronType.cube: themes},
          sessionConfig: config,
        ),
      ),
    );
  }
}
