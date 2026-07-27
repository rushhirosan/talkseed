import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_preset.dart';

/// プリセット UI 表示用ヘルパー
extension SessionPresetDisplay on SessionPreset {
  String modeLabel(AppLocalizations l10n) {
    switch (mode) {
      case SessionPresetMode.oneOnOne:
        return l10n.presetModeOneOnOne;
      case SessionPresetMode.groupDiscussion:
        return l10n.presetModeGroupDiscussion;
      case SessionPresetMode.valueCards:
        return l10n.presetModeValueCards;
      case SessionPresetMode.dice:
        return l10n.presetModeDice;
    }
  }

  String configSummary(AppLocalizations l10n) {
    switch (mode) {
      case SessionPresetMode.oneOnOne:
        final format = oneOnOneFormat;
        if (format == null) {
          return modeLabel(l10n);
        }
        return '${modeLabel(l10n)} · ${format.title(l10n)}';
      case SessionPresetMode.groupDiscussion:
      case SessionPresetMode.valueCards:
      case SessionPresetMode.dice:
        final config = sessionConfig;
        if (config == null) {
          return modeLabel(l10n);
        }
        return presetSessionConfigSummary(l10n, config, mode);
    }
  }

  Color modeAccentColor() {
    switch (mode) {
      case SessionPresetMode.oneOnOne:
        return const Color(0xFF64B5F6);
      case SessionPresetMode.groupDiscussion:
        return const Color(0xFF81C784);
      case SessionPresetMode.valueCards:
        return const Color(0xFFBA68C8);
      case SessionPresetMode.dice:
        return const Color(0xFFFFB74D);
    }
  }

  IconData modeIcon() {
    switch (mode) {
      case SessionPresetMode.oneOnOne:
        return oneOnOneFormat?.icon ?? Icons.psychology_outlined;
      case SessionPresetMode.groupDiscussion:
        return Icons.forum_outlined;
      case SessionPresetMode.valueCards:
        return Icons.style_outlined;
      case SessionPresetMode.dice:
        return Icons.casino_outlined;
    }
  }
}

String presetSessionConfigSummary(
  AppLocalizations l10n,
  SessionConfig config,
  SessionPresetMode mode,
) {
  final timerLabel = presetTimerLabel(l10n, config.timerDuration);
  final playerPart = l10n.presetSummaryPlayers(config.playerCount);
  if (mode == SessionPresetMode.groupDiscussion) {
    final categoryPart = _discussionCategorySummary(l10n, config);
    if (categoryPart != null) {
      return '$categoryPart · $playerPart · $timerLabel';
    }
  }
  if (mode == SessionPresetMode.dice) {
    return '${l10n.presetSummaryDiceCustom} · $playerPart · $timerLabel';
  }
  return '$playerPart · $timerLabel';
}

String? _discussionCategorySummary(
  AppLocalizations l10n,
  SessionConfig config,
) {
  final ids = config.discussionCategoryIds;
  if (ids == null) {
    return l10n.presetSummaryAllCategories;
  }
  if (ids.isEmpty) {
    return null;
  }
  return l10n.presetSummaryCategories(ids.length);
}

String presetTimerLabel(AppLocalizations l10n, Duration duration) {
  if (duration == const Duration(seconds: 30)) return l10n.timer30Seconds;
  if (duration == const Duration(minutes: 1)) return l10n.timer1Minute;
  if (duration == const Duration(minutes: 2)) return l10n.timer2Minutes;
  if (duration == const Duration(minutes: 3)) return l10n.timer3Minutes;
  if (duration == const Duration(minutes: 5)) return l10n.timer5Minutes;
  if (duration == const Duration(hours: 1)) return l10n.timerUnlimited;
  return l10n.timer3Minutes;
}

/// プリセットライブラリのモード別グループ見出し
String presetModeSectionTitle(
  SessionPresetMode mode,
  AppLocalizations l10n,
) {
  switch (mode) {
    case SessionPresetMode.oneOnOne:
      return l10n.presetModeSectionOneOnOne;
    case SessionPresetMode.groupDiscussion:
      return l10n.presetModeSectionGroupDiscussion;
    case SessionPresetMode.valueCards:
      return l10n.presetModeSectionValueCards;
    case SessionPresetMode.dice:
      return l10n.presetModeSectionDice;
  }
}

/// 保存済みプリセットをモード別にグループ化（定義順）
Map<SessionPresetMode, List<SessionPreset>> groupPresetsByMode(
  List<SessionPreset> presets,
) {
  final grouped = <SessionPresetMode, List<SessionPreset>>{};
  for (final mode in SessionPresetMode.values) {
    final items = presets.where((p) => p.mode == mode).toList();
    if (items.isNotEmpty) {
      grouped[mode] = items;
    }
  }
  return grouped;
}

/// モードバッジ用の背景色
Color presetModeBadgeBackground(SessionPresetMode mode) {
  switch (mode) {
    case SessionPresetMode.oneOnOne:
      return const Color(0xFF64B5F6).withValues(alpha: 0.15);
    case SessionPresetMode.groupDiscussion:
      return const Color(0xFF81C784).withValues(alpha: 0.15);
    case SessionPresetMode.valueCards:
      return const Color(0xFFBA68C8).withValues(alpha: 0.15);
    case SessionPresetMode.dice:
      return const Color(0xFFFFB74D).withValues(alpha: 0.15);
  }
}

Color presetModeBadgeForeground(SessionPresetMode mode) {
  switch (mode) {
    case SessionPresetMode.oneOnOne:
      return const Color(0xFF64B5F6);
    case SessionPresetMode.groupDiscussion:
      return const Color(0xFF81C784);
    case SessionPresetMode.valueCards:
      return const Color(0xFFBA68C8);
    case SessionPresetMode.dice:
      return const Color(0xFFFFB74D);
  }
}
