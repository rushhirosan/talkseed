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

/// 選定フェーズ（カードをめくって確認）→ 議論フェーズ（案内後にタイマー開始可）。プレイヤー交代はない。
enum _FlowPhase { pickingTopics, discussion }

/// グループディスカッションデッキ用：テーマ絞り込みと枚数で場に並べた候補を、全員でめくって確認してから議論する
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
  List<DiscussionCategoryGroup> _groups = [];
  bool _groupsReady = false;

  /// めくって確認待ちのカード（`categoryId|index`）
  String? _revealedCardId;

  GameSession? _session;
  TimerService? _timerService;
  bool _didSaveHistory = false;

  _FlowPhase _flowPhase = _FlowPhase.pickingTopics;

  /// 議論開始の案内を済ませたら true。タイマーはこれが true になってから動かす。
  bool _discussionKickoffAcknowledged = false;

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  int get _totalCards =>
      _groups.fold<int>(0, (a, g) => a + g.prompts.length);

  /// 場に並んだお題（履歴・一覧用）
  List<String> _flatTopicsFromGroups() {
    final out = <String>[];
    for (final g in _groups) {
      out.addAll(g.prompts);
    }
    return out;
  }

  String? get _revealedPrompt {
    final id = _revealedCardId;
    if (id == null) return null;
    final parts = id.split('|');
    if (parts.length != 2) return null;
    final catId = parts[0];
    final idx = int.tryParse(parts[1]);
    if (idx == null) return null;
    for (final g in _groups) {
      if (g.categoryId == catId &&
          idx >= 0 &&
          idx < g.prompts.length) {
        return g.prompts[idx];
      }
    }
    return null;
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
    if (_flowPhase != _FlowPhase.discussion) return;
    if (_timerService == null || _session == null) return;
    if (!_session!.config.enableTimer) return;
    setState(() {
      _timerService!.addTime(const Duration(minutes: 1));
      _timerService!.start();
    });
  }

  void _toggleTimer() {
    if (_flowPhase != _FlowPhase.discussion) return;
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

  void _onCardFaceDownTap(String cardId) {
    if (_flowPhase != _FlowPhase.pickingTopics) return;
    if (_session == null || !_session!.isActive) return;
    setState(() {
      _revealedCardId = cardId;
    });
    _triggerVibration();
  }

  void _flipBack() {
    if (_flowPhase != _FlowPhase.pickingTopics) return;
    setState(() => _revealedCardId = null);
    _triggerVibration();
  }

  void _proceedToDiscussionPhase() {
    if (_flowPhase != _FlowPhase.pickingTopics) return;
    if (_session == null || !_session!.isActive) return;
    if (_totalCards <= 0) return;
    setState(() {
      _revealedCardId = null;
      _flowPhase = _FlowPhase.discussion;
      _discussionKickoffAcknowledged = false;
      if (widget.sessionConfig.enableTimer) {
        _timerService?.dispose();
        _timerService = TimerService(
          initialDuration: widget.sessionConfig.timerDuration,
          onTick: () => setState(() {}),
          onFinished: _onTimerFinished,
        );
      }
    });
    _triggerVibration();
  }

  void _onDiscussionKickoffStart() {
    if (_flowPhase != _FlowPhase.discussion) return;
    setState(() {
      _discussionKickoffAcknowledged = true;
      if (widget.sessionConfig.enableTimer && _timerService != null) {
        _timerService!.start();
      }
    });
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
    final topics = _flatTopicsFromGroups();
    final record = SessionRecord.create(
      mode: 'discussion',
      topics: topics,
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

  Widget _buildGroupTopicsRollup(AppLocalizations l10n) {
    if (_totalCards == 0) return const SizedBox.shrink();
    var running = 0;
    final rows = <Widget>[];
    for (final g in _groups) {
      for (final p in g.prompts) {
        running++;
        rows.add(
          Padding(
            padding: EdgeInsets.only(
              bottom: running == _totalCards ? 0 : 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '$running.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _black.withOpacity(0.55),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    p,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: _black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black, width: 1.5),
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
            l10n.discussionGroupTopicsTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _black,
            ),
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDiscussionKickoffCard(AppLocalizations l10n, TalkShuffleTokens ts) {
    final hasTimer = widget.sessionConfig.enableTimer;
    final durationLabel = hasTimer
        ? _formatDiscussionDuration(widget.sessionConfig.timerDuration)
        : '';
    final btn = l10n.discussionKickoffStartButton;

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
            l10n.discussionGroupKickoffLead(_totalCards),
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _black.withOpacity(0.88),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasTimer) ...[
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
            onPressed: _onDiscussionKickoffStart,
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

  Widget _buildDiscussionActiveGroupHint(AppLocalizations l10n) {
    return Text(
      l10n.discussionGroupHint,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        height: 1.35,
        color: _black.withOpacity(0.72),
      ),
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

  String _backShortLabel(String categoryId, int cardIndex) {
    const map = {
      'prob_logical': 'L',
      'prob_creative': 'C',
      'prob_fermi': 'F',
      'prob_dilemma': 'D',
      'soc_geo': 'G',
      'soc_ai_gap': 'AI',
      'soc_climate': 'CL',
      'soc_democracy': 'DM',
      'soc_japan_decline': 'J1',
      'soc_japan_immigration': 'J2',
      'soc_japan_work': 'J3',
      'soc_japan_local': 'J4',
      'uncategorized': '●',
    };
    final prefix = map[categoryId] ?? '?';
    return '$prefix${cardIndex + 1}';
  }

  Widget _buildCategoryRow({
    required DiscussionCategoryGroup group,
    required TalkShuffleTokens ts,
    required bool pickingEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            group.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _black.withOpacity(0.88),
            ),
          ),
        ),
        SizedBox(
          height: 136,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < group.prompts.length; index++) ...[
                  if (index > 0) const SizedBox(width: 10),
                  _DiscussionPickCard(
                    prompt: group.prompts[index],
                    backLabel: _backShortLabel(group.categoryId, index),
                    accent: _accentForCategory(group.categoryId, ts),
                    faceUp: _revealedCardId == '${group.categoryId}|$index',
                    interactive: pickingEnabled,
                    onFaceDownTap: () => _onCardFaceDownTap(
                      '${group.categoryId}|$index',
                    ),
                    onFaceUpTap: pickingEnabled ? _flipBack : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  bool get _showMainPromptCard {
    if (_flowPhase == _FlowPhase.discussion) {
      return _discussionKickoffAcknowledged;
    }
    return _revealedPrompt != null;
  }

  Widget _buildMainPromptCard(AppLocalizations l10n, TalkShuffleTokens ts) {
    if (_flowPhase == _FlowPhase.discussion) {
      final body = widget.sessionConfig.enableTimer
          ? l10n.discussionDiscussionCardWithTimer
          : l10n.discussionDiscussionCardNoTimer;
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        child: Text(
          body,
          style: const TextStyle(
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: _black,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final revealed = _revealedPrompt;
    if (revealed == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
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
      child: Text(
        revealed,
        style: const TextStyle(
          fontSize: 17,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: _black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ts = context.talkShuffle;
    final picking = _flowPhase == _FlowPhase.pickingTopics;
    final pickingEnabled = picking && _session != null && _session!.isActive;

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
              if (_flowPhase == _FlowPhase.discussion &&
                  _session != null &&
                  _session!.isActive) ...[
                if (!_discussionKickoffAcknowledged) ...[
                  _buildDiscussionKickoffCard(l10n, ts),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildDiscussionActiveGroupHint(l10n),
                  const SizedBox(height: 12),
                  if (_session!.config.enableTimer && _timerService != null) ...[
                    TimerDisplay(
                      timerService: _timerService!,
                      onPause: _toggleTimer,
                      onResume: _toggleTimer,
                      onExtendOneMinute: _extendTimerOneMinute,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ],
              if (picking)
                Text(
                  l10n.discussionHint,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: _black.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
              if (picking) const SizedBox(height: 16),
              if (picking &&
                  _session != null &&
                  _session!.isActive)
                Text(
                  '${l10n.discussionDeckScopeTitle}: $_totalCards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _black.withOpacity(0.55),
                  ),
                ),
              if (picking) const SizedBox(height: 16),
              if (picking) ...[
                Text(
                  l10n.discussionPickFromCardsHeading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _black.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 10),
                ..._groups.map(
                  (g) => _buildCategoryRow(
                    group: g,
                    ts: ts,
                    pickingEnabled: pickingEnabled,
                  ),
                ),
              ],
              if (picking &&
                  _session != null &&
                  _session!.isActive &&
                  _totalCards > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _proceedToDiscussionPhase,
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
                      l10n.discussionProceedToDiscussionButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
              if (_showMainPromptCard) ...[
                const SizedBox(height: 16),
                _buildMainPromptCard(l10n, ts),
              ],
              if (_session != null) ...[
                const SizedBox(height: 14),
                _buildGroupTopicsRollup(l10n),
              ],
              if (_session != null &&
                  _session!.isActive &&
                  _flowPhase == _FlowPhase.discussion) ...[
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
          ),
        ),
      ),
    );
  }
}

class _DiscussionPickCard extends StatelessWidget {
  final String prompt;
  final String backLabel;
  final Color accent;
  final bool faceUp;
  final bool interactive;
  final VoidCallback onFaceDownTap;
  final VoidCallback? onFaceUpTap;

  const _DiscussionPickCard({
    required this.prompt,
    required this.backLabel,
    required this.accent,
    required this.faceUp,
    required this.interactive,
    required this.onFaceDownTap,
    this.onFaceUpTap,
  });

  @override
  Widget build(BuildContext context) {
    const w = 112.0;
    const h = 132.0;
    final border = Border.all(color: Colors.black87, width: 1.4);

    final back = Material(
      color: accent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: interactive ? onFaceDownTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.help_outline,
                size: 32,
                color: Colors.black.withOpacity(0.35),
              ),
              const SizedBox(height: 8),
              Text(
                backLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final front = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: (interactive && onFaceUpTap != null) ? onFaceUpTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: Center(
            child: Text(
              prompt,
              maxLines: 7,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(anim),
            child: child,
          ),
        );
      },
      child: faceUp
          ? KeyedSubtree(
              key: const ValueKey('f'),
              child: front,
            )
          : KeyedSubtree(
              key: const ValueKey('b'),
              child: back,
            ),
    );
  }
}
