import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/session_record_service.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  String _filter = 'all'; // all | dice | value_cards

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _lightYellow = Color(0xFFFFFDE7);

  String _modeLabel(AppLocalizations l10n, SessionRecord record) {
    switch (record.mode) {
      case 'value_cards':
        return l10n.historyModeValueCards;
      case 'dice':
      default:
        return l10n.historyModeDice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMMd(l10n.localeName);

    return Scaffold(
      backgroundColor: _lightYellow,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        title: Text(
          l10n.historyTitle,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: _black),
            tooltip: l10n.historyDeleteAll,
            onPressed: () => _confirmDeleteAll(context, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
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
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: filtered.isEmpty ? 1 : filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                              style: TextStyle(
                                color: _black.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }
                      final record = filtered[index];
                      final dateLabel = dateFormat.format(record.playedAt);
                      final modeLabel = _modeLabel(l10n, record);
                      final title = l10n.historyListItemTitle(dateLabel, modeLabel);
                      final playerCountText = record.playerCount != null
                          ? l10n.historyPlayerCount(record.playerCount!)
                          : null;

                      return Material(
                        color: _white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
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
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _black.withOpacity(0.2), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: _black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _black,
                                  ),
                                ),
                                if (playerCountText != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    playerCountText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _black.withOpacity(0.6),
                                    ),
                                  ),
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
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(l10n.historyFilterAll),
          selected: _filter == 'all',
          onSelected: (_) => setState(() => _filter = 'all'),
        ),
        ChoiceChip(
          label: Text(l10n.historyFilterDice),
          selected: _filter == 'dice',
          onSelected: (_) => setState(() => _filter = 'dice'),
        ),
        ChoiceChip(
          label: Text(l10n.historyFilterValueCards),
          selected: _filter == 'value_cards',
          onSelected: (_) => setState(() => _filter = 'value_cards'),
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
            title: Text(l10n.historyDeleteAllTitle),
            content: Text(l10n.historyDeleteAllMessage),
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

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _lightYellow = Color(0xFFFFFDE7);

  String _modeLabel(AppLocalizations l10n) {
    switch (record.mode) {
      case 'value_cards':
        return l10n.historyModeValueCards;
      case 'dice':
      default:
        return l10n.historyModeDice;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMMd(l10n.localeName);
    final dateLabel = dateFormat.format(record.playedAt);
    final modeLabel = _modeLabel(l10n);

    return Scaffold(
      backgroundColor: _lightYellow,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        title: Text(
          l10n.historyDetailTitle,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: _black),
            tooltip: l10n.historyDeleteOne,
            onPressed: () => _confirmDeleteOne(context, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildSectionCard(
              title: l10n.historySummaryTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.historyListItemTitle(dateLabel, modeLabel),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _black,
                    ),
                  ),
                  if (record.playerCount != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.historyPlayerCount(record.playerCount!),
                      style: TextStyle(
                        fontSize: 13,
                        color: _black.withOpacity(0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (record.topics.isNotEmpty)
              _buildSectionCard(
                title: l10n.historyTopicsTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: record.topics
                      .map((topic) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '・$topic',
                              style: const TextStyle(
                                fontSize: 14,
                                color: _black,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            if (record.selectedCardsByPlayer.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionCard(
                title: l10n.historySelectedCardsTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: record.selectedCardsByPlayer.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...entry.value.map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '・$card',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _black,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  }).toList(),
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
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _black,
                            ),
                          ),
                          Text(
                            l10n.voteCount(entry.value),
                            style: TextStyle(
                              fontSize: 13,
                              color: _black.withOpacity(0.7),
                            ),
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
            title: Text(l10n.historyDeleteOneTitle),
            content: Text(l10n.historyDeleteOneMessage),
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
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: _black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _black.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
