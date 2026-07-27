import 'package:intl/intl.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_record.dart';

/// セッション履歴を共有シート用のプレーンテキストに整形する。
String formatSessionRecordShareText(
  SessionRecord record,
  AppLocalizations l10n,
) {
  final buffer = StringBuffer();
  final dateFormat = DateFormat.yMMMMd(l10n.localeName);
  final dateLabel = dateFormat.format(record.playedAt);
  final modeLabel = _modeLabel(l10n, record.mode);

  buffer.writeln(l10n.historyShareHeader);
  buffer.writeln();
  buffer.writeln(l10n.historyListItemTitle(dateLabel, modeLabel));

  final names = record.displayPlayerNames;
  if (names.isNotEmpty) {
    buffer.writeln();
    buffer.writeln(l10n.historyPlayersTitle);
    for (final name in names) {
      buffer.writeln('・$name');
    }
  } else if (record.playerCount != null &&
      record.mode != SessionRecord.modeOneOnOne) {
    buffer.writeln();
    buffer.writeln(l10n.historyPlayerCount(record.playerCount!));
  }

  final hideFlatTopics = (record.mode == SessionRecord.modeDiscussion ||
          record.mode == SessionRecord.modeOneOnOne) &&
      record.selectedCardsByPlayer.isNotEmpty;
  if (record.topics.isNotEmpty && !hideFlatTopics) {
    buffer.writeln();
    buffer.writeln(l10n.historyTopicsTitle);
    for (final topic in record.topics) {
      buffer.writeln('・$topic');
    }
  }

  if (record.mode == SessionRecord.modeOneOnOne &&
      record.selectedCardsByPlayer.isNotEmpty) {
    buffer.writeln();
    buffer.writeln(l10n.historyOneOnOnePromptsTitle);
    for (final entry in record.selectedCardsByPlayer.entries) {
      if (entry.value.isEmpty) {
        continue;
      }
      buffer.writeln();
      buffer.writeln(OneOnOnePhase.titleForSessionId(l10n, entry.key));
      for (final prompt in entry.value) {
        buffer.writeln('・$prompt');
      }
    }
  }

  if (record.selectedCardsByPlayer.isNotEmpty &&
      record.mode != SessionRecord.modeOneOnOne) {
    buffer.writeln();
    buffer.writeln(
      record.mode == SessionRecord.modeDiscussion
          ? l10n.historyDiscussionPromptsTitle
          : l10n.historySelectedCardsTitle,
    );
    for (final entry in record.selectedCardsByPlayer.entries) {
      buffer.writeln();
      buffer.writeln(entry.key);
      for (final card in entry.value) {
        buffer.writeln('・$card');
      }
    }
    if (record.mode == SessionRecord.modeDiscussion) {
      buffer.writeln();
      buffer.writeln(l10n.historyDiscussionPromptsFootnote);
    }
  }

  if (record.voteResults.isNotEmpty) {
    buffer.writeln();
    buffer.writeln(l10n.voteResultsTitle);
    for (final entry in record.voteResults.entries) {
      buffer.writeln('${entry.key} — ${l10n.voteCount(entry.value)}');
    }
  }

  buffer.writeln();
  buffer.writeln('---');
  buffer.writeln(l10n.historyShareFooter);

  return buffer.toString().trimRight();
}

String _modeLabel(AppLocalizations l10n, String mode) {
  switch (mode) {
    case SessionRecord.modeValueCards:
      return l10n.historyModeValueCards;
    case SessionRecord.modeDiscussion:
      return l10n.historyModeDiscussion;
    case SessionRecord.modeOneOnOne:
      return l10n.historyModeOneOnOne;
    case SessionRecord.modeDice:
    default:
      return l10n.historyModeDice;
  }
}
