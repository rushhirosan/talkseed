import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/bingo_deck.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/models/value_game_state.dart';
import 'package:theme_dice/pages/bingo_page.dart';
import 'package:theme_dice/pages/discussion_prompt_page.dart';
import 'package:theme_dice/pages/dice_page.dart';
import 'package:theme_dice/pages/mashup_page.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';
import 'package:theme_dice/pages/value_card_page.dart';
import 'package:theme_dice/services/bingo_picker.dart';
import 'package:theme_dice/services/bingo_service.dart';
import 'package:theme_dice/services/mashup_service.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/utils/error_dialog_helper.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/pro_access.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/models/mashup_deck.dart';

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
      case SessionPresetMode.mashup:
        final allowed = await ProAccess.ensure(
          context,
          feature: ProFeature.sparkModes,
        );
        if (!allowed || !context.mounted) {
          return;
        }
        await _launchMashup(context, preset);
      case SessionPresetMode.bingo:
        final allowed = await ProAccess.ensure(
          context,
          feature: ProFeature.sparkModes,
        );
        if (!allowed || !context.mounted) {
          return;
        }
        await _launchBingo(context, preset);
    }
  }

  static void _showLaunchError(BuildContext context) {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.presetLaunchError)),
    );
  }

  static Future<void> _launchOneOnOne(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final format = preset.oneOnOneFormat;
    if (format == null) {
      _showLaunchError(context);
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
      _showLaunchError(context);
      return;
    }
    final ids = config.discussionCategoryIds;
    if (ids != null && ids.isEmpty) {
      _showLaunchError(context);
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
      _showLaunchError(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final deck = CardDeck.allDecks.firstWhere(
      (d) => d.type == CardDeckType.teamBuilding,
    );
    final themes = deck.themes(l10n);
    final maxPlayers = ValueGameLogic.maxPlayersForDeck(themes.length);
    final safeConfig = config.playerCount > maxPlayers
        ? config.copyWith(playerCount: maxPlayers)
        : config;

    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: ValueCardPage(
          themes: themes,
          sessionConfig: safeConfig,
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
      _showLaunchError(context);
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

  static Future<void> _launchMashup(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final config = preset.sessionConfig;
    final axisIds = config?.mashupEnabledAxisIds;
    if (config == null || axisIds == null || axisIds.isEmpty) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mashupPresetLaunchError)),
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    late final MashupDeck deck;
    try {
      deck = await MashupService.loadDeck(languageCode: l10n.localeName);
    } catch (_) {
      if (context.mounted) {
        await ErrorDialogHelper.showDataLoadError(context);
      }
      return;
    }
    final axes = deck.axes.where((a) => axisIds.contains(a.id)).toList();
    if (!context.mounted) {
      return;
    }
    if (axes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mashupPresetLaunchError)),
      );
      return;
    }

    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: MashupPage(deck: deck, axes: axes, config: config),
      ),
    );
  }

  static Future<void> _launchBingo(
    BuildContext context,
    SessionPreset preset,
  ) async {
    final config = preset.sessionConfig;
    if (config == null) {
      _showLaunchError(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    late final BingoDeck deck;
    try {
      deck = await BingoService.loadDeck(languageCode: l10n.localeName);
    } catch (_) {
      if (context.mounted) {
        await ErrorDialogHelper.showDataLoadError(context);
      }
      return;
    }
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: BingoPage(
          board: BingoPicker(deck: deck).deal(
            playerCount: config.playerCount.clamp(2, BingoBoard.maxPlayers),
          ),
          config: config.playerCount > BingoBoard.maxPlayers
              ? config.copyWith(playerCount: BingoBoard.maxPlayers)
              : config,
        ),
      ),
    );
  }
}
