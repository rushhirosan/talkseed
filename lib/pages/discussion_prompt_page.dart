import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/discussion_category_group.dart';
import 'package:theme_dice/models/game_session.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/timer_feedback.dart';
import 'package:theme_dice/widgets/timer_display.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';
import 'session_history_page.dart';
import 'mode_selection_page.dart';

/// 1テーマずつめくる旧フローは廃止。設定で絞ったお題を全員で話し合う1フェーズのみ。
/// グループディスカッションデッキ用：設定画面で選んだ枚数のお題を一覧表示し、全員で話し合う
class DiscussionPromptPage extends StatefulWidget {
  final List<String> themes;
  final SessionConfig sessionConfig;
  /// AppBar タイトル（デッキ名）
  final String deckTitle;
  /// [groupDiscussion] のときカテゴリー別レイアウト。null なら1列のフラットデッキ
  final CardDeckType? discussionDeckType;

  const DiscussionPromptPage({
    super.key,
    required this.themes,
    required this.sessionConfig,
    required this.deckTitle,
    this.discussionDeckType,
  });

  @override
  State<DiscussionPromptPage> createState() => _DiscussionPromptPageState();
}

class _DiscussionPromptPageState extends State<DiscussionPromptPage> {
  final Random _random = Random();

  /// セッションで話し合う確定済みのお題（カテゴリー別の表示順を保つためグループ単位）
  List<DiscussionCategoryGroup> _groups = [];
  bool _groupsReady = false;

  GameSession? _session;
  TimerService? _timerService;
  bool _didSaveHistory = false;

  /// 議論開始の案内を済ませたら true。タイマーはこれが true になってから動かす。
  bool _discussionKickoffAcknowledged = false;

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  /// 確定したお題の総数
  int get _totalCards =>
      _groups.fold<int>(0, (a, g) => a + g.prompts.length);

  /// 表示順のフラットなお題リスト（履歴保存・番号付き表示用）
  List<String> get _flatTopics {
    final out = <String>[];
    for (final g in _groups) {
      out.addAll(g.prompts);
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _session = GameSession(
      config: widget.sessionConfig,
      themes: {PolyhedronType.cube: widget.themes},
      isActive: true,
    );
    _session!.startSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_groupsReady) return;
    _groupsReady = true;
    _rebuildGroups();
  }

  void _rebuildGroups() {
    final l10n = AppLocalizations.of(context)!;
    final cap = widget.sessionConfig.discussionPromptCap;
    final dt = widget.discussionDeckType;
    if (dt != null && cardDeckTypeUsesCategorizedDiscussion(dt)) {
      final allowed = widget.sessionConfig.discussionCategoryIds;
      _groups = CardDeck.buildShuffledDiscussionCategories(
        deckType: dt,
        l10n: l10n,
        random: _random,
        cap: cap,
        allowedCategoryIds:
            allowed == null ? null : Set<String>.from(allowed),
      );
    } else {
      _groups = CardDeck.buildFlatDiscussionCategories(
        themes: widget.themes,
        l10n: l10n,
        random: _random,
        cap: cap,
      );
    }
  }

  @override
  void dispose() {
    _timerService?.dispose();
    super.dispose();
  }

  void _onTimerFinished() {
    TimerFeedback.play();
    setState(() {});
  }

  void _extendTimerOneMinute() {
    if (_timerService == null || _session == null) return;
    if (!_session!.config.enableTimer) return;
    setState(() {
      _timerService!.addTime(const Duration(minutes: 1));
      _timerService!.start();
    });
  }

  void _toggleTimer() {
    if (_timerService == null) return;
    setState(() {
      if (_timerService!.isRunning) {
        _timerService!.pause();
      } else if (_timerService!.isPaused) {
        _timerService!.resume();
      }
    });
  }

  Future<void> _triggerVibration() async {
    final enabled = await PreferencesHelper.loadVibrationEnabled();
    if (!enabled) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 80);
    }
  }

  void _onDiscussionKickoffStart() {
    if (_session == null || !_session!.isActive) return;
    setState(() {
      _discussionKickoffAcknowledged = true;
      if (widget.sessionConfig.enableTimer) {
        _timerService?.dispose();
        _timerService = TimerService(
          initialDuration: widget.sessionConfig.timerDuration,
          onTick: () => setState(() {}),
          onFinished: _onTimerFinished,
        );
        _timerService!.start();
      }
    });
    _triggerVibration();
  }

  void _reshufflePrompts() {
    if (_discussionKickoffAcknowledged) return;
    setState(_rebuildGroups);
    _triggerVibration();
  }

  String _formatDiscussionDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _endDiscussionSession() {
    if (_session == null || !_session!.isActive) return;
    setState(() {
      _session!.endSession();
      _timerService?.stop();
    });
    _saveDiscussionRecord();
    _showSessionEndDialog();
  }

  void _saveDiscussionRecord() {
    if (_didSaveHistory || _session == null) return;
    final s = _session!;
    final topics = _flatTopics;
    if (topics.isEmpty) {
      _didSaveHistory = true;
      return;
    }
    final record = SessionRecord.create(
      mode: 'discussion',
      topics: topics,
      // グループディスカッションではプレイヤー別のお題は持たないため空のまま
      selectedCardsByPlayer: const {},
      playerCount: s.config.playerCount,
    );
    _didSaveHistory = true;
    SessionRecordService.addRecord(record);
  }

  void _showSessionEndDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.sessionSummary),
        content: Text(l10n.sessionCompleteAcknowledgeMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.sessionCompleteAcknowledgeButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SessionHistoryPage(),
                ),
              );
            },
            child: Text(l10n.historyTitle),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    if (_session != null && _session!.isActive) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  Color _accentForCategory(String categoryId, TalkShuffleTokens ts) {
    switch (categoryId) {
      case 'prob_logical':
        return ts.deckTileProblemSolving.withOpacity(0.85);
      case 'prob_creative':
        return ts.brandYellow.withOpacity(0.9);
      case 'prob_fermi':
        return ts.playerPastel1;
      case 'prob_dilemma':
        return ts.playerPastel2;
      case 'soc_geo':
        return ts.deckTileSocialIssues.withOpacity(0.85);
      case 'soc_ai_gap':
        return ts.playerPastel0;
      case 'soc_climate':
        return const Color(0xFFB2DFDB);
      case 'soc_democracy':
        return ts.shellLavender;
      case 'soc_japan_decline':
        return ts.playerPastel3;
      case 'soc_japan_immigration':
        return const Color(0xFFFFE0B2);
      case 'soc_japan_work':
        return const Color(0xFFC5E1A5);
      case 'soc_japan_local':
        return const Color(0xFFB39DDB);
      default:
        return ts.borderLavender;
    }
  }

  Widget _buildKickoffCard(AppLocalizations l10n, TalkShuffleTokens ts) {
    final hasTimer = widget.sessionConfig.enableTimer;
    final durationLabel = hasTimer
        ? _formatDiscussionDuration(widget.sessionConfig.timerDuration)
        : '';
    final btn = l10n.discussionKickoffStartButton;
    final canStart = _totalCards > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.discussionGroupKickoffTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            canStart
                ? l10n.discussionGroupKickoffLead(_totalCards)
                : l10n.discussionGroupTopicsEmpty,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _black.withOpacity(0.88),
            ),
            textAlign: TextAlign.center,
          ),
          if (canStart && hasTimer) ...[
            const SizedBox(height: 10),
            Text(
              l10n.discussionKickoffTimerNote(btn, durationLabel),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: _black.withOpacity(0.72),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: canStart ? _onDiscussionKickoffStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ts.brandYellow,
              foregroundColor: _black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Text(
              btn,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// 確定済みのお題一覧（番号付き、カテゴリー別に区切り表示）
  Widget _buildTopicsList(AppLocalizations l10n, TalkShuffleTokens ts) {
    if (_totalCards == 0) {
      return const SizedBox.shrink();
    }
    var runningIndex = 0;
    final children = <Widget>[];
    final showCategoryHeader = _groups.length > 1 ||
        (_groups.isNotEmpty && _groups.first.categoryId != 'uncategorized');
    for (final g in _groups) {
      if (showCategoryHeader) {
        children.add(
          Padding(
            padding: EdgeInsets.only(
              top: children.isEmpty ? 0 : 14,
              bottom: 6,
              left: 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _accentForCategory(g.categoryId, ts),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  g.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _black.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      for (final p in g.prompts) {
        runningIndex++;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TopicTile(
              index: runningIndex,
              prompt: p,
              accent: _accentForCategory(g.categoryId, ts),
            ),
          ),
        );
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.discussionGroupTopicsTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
              ),
              Text(
                l10n.discussionGroupTopicsCount(_totalCards),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _black.withOpacity(0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ts = context.talkShuffle;
    final inDiscussion = _discussionKickoffAcknowledged;

    return Scaffold(
      backgroundColor: ts.scaffoldPlayWarm,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: _goBack,
          tooltip: l10n.backToSettings,
        ),
        title: Text(
          widget.deckTitle,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!inDiscussion) ...[
                _buildKickoffCard(l10n, ts),
                const SizedBox(height: 12),
                if (_totalCards > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _reshufflePrompts,
                      icon: const Icon(Icons.shuffle, size: 18, color: _black),
                      label: Text(
                        l10n.discussionGroupReshuffle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _black,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  l10n.discussionGroupHint,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: _black.withOpacity(0.72),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                _buildTopicsList(l10n, ts),
              ] else ...[
                if (_session != null &&
                    _session!.config.enableTimer &&
                    _timerService != null) ...[
                  TimerDisplay(
                    timerService: _timerService!,
                    onPause: _toggleTimer,
                    onResume: _toggleTimer,
                    onExtendOneMinute: _extendTimerOneMinute,
                  ),
                  const SizedBox(height: 16),
                ],
                _buildTopicsList(l10n, ts),
                if (_session != null && _session!.isActive) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _endDiscussionSession,
                    icon: const Icon(Icons.check_circle, color: _black),
                    label: Text(
                      l10n.discussionEndDiscussionButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ts.brandYellow,
                      foregroundColor: _black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 番号付きのお題行（議論画面と確認画面で共通利用）
class _TopicTile extends StatelessWidget {
  final int index;
  final String prompt;
  final Color accent;

  const _TopicTile({
    required this.index,
    required this.prompt,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 1.2),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              prompt,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
