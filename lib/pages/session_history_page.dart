import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  String _filter = 'all';

  TextStyle _titleStyle({double fontSize = 15}) => GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: HomePalette.text,
      );

  TextStyle _subtitleStyle() => GoogleFonts.zenKakuGothicNew(
        fontSize: 12,
        color: HomePalette.textMuted,
      );

  String _modeLabel(AppLocalizations l10n, SessionRecord record) {
    switch (record.mode) {
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

  String? _playersSubtitle(AppLocalizations l10n, SessionRecord record) {
    if (record.mode == SessionRecord.modeOneOnOne) {
      final count = record.selectedCardsByPlayer.entries
          .where((entry) => entry.value.isNotEmpty)
          .length;
      if (count > 0) {
        return l10n.historyOneOnOneSubtitle(count);
      }
      return null;
    }
    final names = record.displayPlayerNames;
    if (names.isNotEmpty) {
      return names.join('、');
    }
    if (record.playerCount != null) {
      return l10n.historyPlayerCount(record.playerCount!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMMd(l10n.localeName);

    return HomeScaffold(
      title: l10n.historyTitle,
      leading: HomeBackButton(onPressed: () => Navigator.of(context).pop()),
      actions: [
        HomeHeaderIconButton(
          icon: Icons.delete_sweep,
          tooltip: l10n.historyDeleteAll,
          onPressed: () => _confirmDeleteAll(context, l10n),
        ),
      ],
      body: ValueListenableBuilder(
        valueListenable: SessionRecordService.listenable(),
        builder: (context, box, _) {
          final records = SessionRecordService.getRecords();
          final filtered = _filter == 'all'
              ? records
              : records.where((e) => e.mode == _filter).toList();
          return Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFilterChips(l10n),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: filtered.isEmpty ? 1 : filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (filtered.isEmpty) {
                      final message = records.isEmpty
                          ? l10n.historyEmptyMessage
                          : l10n.historyEmptyFiltered;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            message,
                            style: _subtitleStyle(),
                          ),
                        ),
                      );
                    }
                    final record = filtered[index];
                    final dateLabel = dateFormat.format(record.playedAt);
                    final modeLabel = _modeLabel(l10n, record);
                    final title =
                        l10n.historyListItemTitle(dateLabel, modeLabel);
                    final playersSubtitle = _playersSubtitle(l10n, record);

                    return Material(
                      color: HomePalette.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  SessionHistoryDetailPage(record: record),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: HomePalette.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: _titleStyle()),
                              if (playersSubtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(playersSubtitle, style: _subtitleStyle()),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.zenKakuGothicNew(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? HomePalette.bg : HomePalette.text,
        ),
      ),
      selected: selected,
      showCheckmark: true,
      checkmarkColor: HomePalette.bg,
      selectedColor: HomePalette.accent,
      backgroundColor: HomePalette.surface,
      side: BorderSide(
        color: selected
            ? HomePalette.accent
            : Colors.white.withValues(alpha: 0.12),
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(
          label: l10n.historyFilterAll,
          selected: _filter == 'all',
          onTap: () => setState(() => _filter = 'all'),
        ),
        _buildFilterChip(
          label: l10n.historyFilterDice,
          selected: _filter == SessionRecord.modeDice,
          onTap: () => setState(() => _filter = SessionRecord.modeDice),
        ),
        _buildFilterChip(
          label: l10n.historyFilterValueCards,
          selected: _filter == SessionRecord.modeValueCards,
          onTap: () => setState(() => _filter = SessionRecord.modeValueCards),
        ),
        _buildFilterChip(
          label: l10n.historyFilterDiscussion,
          selected: _filter == SessionRecord.modeDiscussion,
          onTap: () => setState(() => _filter = SessionRecord.modeDiscussion),
        ),
        _buildFilterChip(
          label: l10n.historyFilterOneOnOne,
          selected: _filter == SessionRecord.modeOneOnOne,
          onTap: () => setState(() => _filter = SessionRecord.modeOneOnOne),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAll(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: HomePalette.surface,
            title: Text(
              l10n.historyDeleteAllTitle,
              style: _titleStyle(fontSize: 18),
            ),
            content: Text(
              l10n.historyDeleteAllMessage,
              style: _subtitleStyle(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (shouldDelete) {
      await SessionRecordService.clearAll();
    }
  }
}

class SessionHistoryDetailPage extends StatelessWidget {
  final SessionRecord record;

  const SessionHistoryDetailPage({
    super.key,
    required this.record,
  });

  TextStyle _titleStyle({double fontSize = 16}) => GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: HomePalette.text,
      );

  TextStyle _bodyStyle() => GoogleFonts.zenKakuGothicNew(
        fontSize: 14,
        color: HomePalette.text,
      );

  TextStyle _mutedStyle({double fontSize = 13}) => GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        color: HomePalette.textMuted,
      );

  String _modeLabel(AppLocalizations l10n) {
    switch (record.mode) {
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

  Widget? _buildPlayersSummary(AppLocalizations l10n) {
    final names = record.displayPlayerNames;
    if (names.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.historyPlayersTitle, style: _mutedStyle()),
          const SizedBox(height: 6),
          ...names.map(
            (name) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('・$name', style: _bodyStyle()),
            ),
          ),
        ],
      );
    }
    if (record.playerCount != null) {
      return Text(
        l10n.historyPlayerCount(record.playerCount!),
        style: _mutedStyle(),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMMd(l10n.localeName);
    final dateLabel = dateFormat.format(record.playedAt);
    final modeLabel = _modeLabel(l10n);
    final hideFlatTopics = (record.mode == SessionRecord.modeDiscussion ||
            record.mode == SessionRecord.modeOneOnOne) &&
        record.selectedCardsByPlayer.isNotEmpty;
    final playersSummary = _buildPlayersSummary(l10n);

    return HomeScaffold(
      title: l10n.historyDetailTitle,
      leading: HomeBackButton(onPressed: () => Navigator.of(context).pop()),
      actions: [
        HomeHeaderIconButton(
          icon: Icons.delete_outline,
          tooltip: l10n.historyDeleteOne,
          onPressed: () => _confirmDeleteOne(context, l10n),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionCard(
            title: l10n.historySummaryTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyListItemTitle(dateLabel, modeLabel),
                  style: _titleStyle(),
                ),
                if (playersSummary != null) ...[
                  const SizedBox(height: 10),
                  playersSummary,
                ],
              ],
            ),
          ),
          if (record.topics.isNotEmpty && !hideFlatTopics) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.historyTopicsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: record.topics
                    .map((topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('・$topic', style: _bodyStyle()),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (record.mode == SessionRecord.modeOneOnOne &&
              record.selectedCardsByPlayer.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.historyOneOnOnePromptsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in record.selectedCardsByPlayer.entries) ...[
                    if (entry.value.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              OneOnOnePhase.titleForSessionId(l10n, entry.key),
                              style: _mutedStyle(),
                            ),
                            const SizedBox(height: 6),
                            ...entry.value.map(
                              (prompt) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('・$prompt', style: _bodyStyle()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
          if (record.selectedCardsByPlayer.isNotEmpty &&
              record.mode != SessionRecord.modeOneOnOne) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              title: record.mode == SessionRecord.modeDiscussion
                  ? l10n.historyDiscussionPromptsTitle
                  : l10n.historySelectedCardsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...record.selectedCardsByPlayer.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: _mutedStyle()),
                          const SizedBox(height: 6),
                          ...entry.value.map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('・$card', style: _bodyStyle()),
                              )),
                        ],
                      ),
                    );
                  }),
                  if (record.mode == SessionRecord.modeDiscussion)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.historyDiscussionPromptsFootnote,
                        style: _mutedStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (record.voteResults.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionCard(
              title: l10n.voteResultsTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: record.voteResults.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: _bodyStyle()),
                        Text(
                          l10n.voteCount(entry.value),
                          style: _mutedStyle(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteOne(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: HomePalette.surface,
            title: Text(
              l10n.historyDeleteOneTitle,
              style: GoogleFonts.zenKakuGothicNew(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: HomePalette.text,
              ),
            ),
            content: Text(
              l10n.historyDeleteOneMessage,
              style: GoogleFonts.zenKakuGothicNew(
                fontSize: 14,
                color: HomePalette.textMuted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
    if (shouldDelete) {
      await SessionRecordService.deleteRecord(record.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: HomePalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: HomePalette.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
