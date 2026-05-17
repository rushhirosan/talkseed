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
import 'package:theme_dice/widgets/play/play_session_ui.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/utils/session_end_dialog.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';
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

  GameSession? _session;
  TimerService? _timerService;
  bool _didSaveHistory = false;

  _FlowPhase _flowPhase = _FlowPhase.pickingTopics;

  /// 選定済みのカード ID（`categoryId|index`）。順序＝議論の順番。
  final List<String> _selectedDiscussionIds = [];

  /// 議論フェーズで順に表示するお題（確定順）。`_proceedToDiscussionPhase` で埋める。
  List<String> _discussionPromptsRounds = [];

  /// 現在の議論ラウンド（0 ~ `_discussionPromptsRounds.length - 1`）
  int _currentDiscussionRound = 0;

  int get _totalCards =>
      _groups.fold<int>(0, (a, g) => a + g.prompts.length);

  /// このセッションで話し合うお題の枚数（設定画面の「話すお題の数」。null はプール全枚）
  int get _discussionTargetCount {
    if (_totalCards <= 0) return 0;
    final cap = widget.sessionConfig.discussionTotalPromptsOnTable;
    if (cap == null) return _totalCards;
    return min(cap, _totalCards);
  }

  bool get _selectionReadyForProceed {
    final k = _discussionTargetCount;
    if (k <= 0) return false;
    if (_selectedDiscussionIds.length == k) return true;
    if (k == _totalCards && _selectedDiscussionIds.isEmpty) return true;
    return false;
  }

  /// 卓に並ぶカード ID を表示順に並べる
  List<String> _allCardIdsInDisplayOrder() {
    final out = <String>[];
    for (final g in _groups) {
      for (var i = 0; i < g.prompts.length; i++) {
        out.add('${g.categoryId}|$i');
      }
    }
    return out;
  }

  String? _promptForCardId(String? cardId) {
    if (cardId == null) return null;
    final parts = cardId.split('|');
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

  /// 場に並んだお題（履歴・一覧用）
  List<String> _flatTopicsFromGroups() {
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
    final l10n = AppLocalizations.of(context)!;
    final cap = widget.sessionConfig.discussionPromptCap;
    final dt = widget.discussionDeckType;
    if (dt != null && cardDeckTypeUsesCategorizedDiscussion(dt)) {
      final raw = widget.sessionConfig.discussionCategoryIds;
      final per = widget.sessionConfig.discussionPromptsPerCategory ?? 1;
      final Set<String>? allowed;
      if (raw == null) {
        allowed = null;
      } else if (raw.isEmpty) {
        allowed = {};
      } else {
        allowed = Set<String>.from(raw);
      }
      _groups = CardDeck.buildShuffledDiscussionCategoriesPerCategory(
        deckType: dt,
        l10n: l10n,
        random: _random,
        promptsPerCategory: per,
        allowedCategoryIds: allowed,
      );
      // 卓には候補プールをすべて並べる（discussionTotalPromptsOnTable は目安として SessionConfig に保持）。
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

  void _onPickingCardTap(String cardId) {
    if (_flowPhase != _FlowPhase.pickingTopics) return;
    if (_session == null || !_session!.isActive) return;
    final l10n = AppLocalizations.of(context)!;
    final k = _discussionTargetCount;

    if (_selectedDiscussionIds.contains(cardId)) {
      setState(() => _selectedDiscussionIds.remove(cardId));
      _triggerVibration();
      return;
    }

    if (_selectedDiscussionIds.length < k) {
      setState(() => _selectedDiscussionIds.add(cardId));
      _triggerVibration();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.discussionSnackbarSelectionCap(k))),
    );
  }

  void _proceedToDiscussionPhase() {
    if (_flowPhase != _FlowPhase.pickingTopics) return;
    if (_session == null || !_session!.isActive) return;
    if (_totalCards <= 0) return;
    final l10n = AppLocalizations.of(context)!;
    final k = _discussionTargetCount;

    late final List<String> idsOrdered;
    if (_selectedDiscussionIds.length == k) {
      idsOrdered = List<String>.from(_selectedDiscussionIds);
    } else if (k == _totalCards && _selectedDiscussionIds.isEmpty) {
      idsOrdered = _allCardIdsInDisplayOrder();
    } else {
      final need = k - _selectedDiscussionIds.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            need > 0
                ? l10n.discussionSnackbarNeedMoreSelections(need)
                : l10n.discussionSnackbarSelectionCap(k),
          ),
        ),
      );
      return;
    }

    final prompts = <String>[];
    for (final id in idsOrdered) {
      final p = _promptForCardId(id);
      if (p != null) prompts.add(p);
    }
    if (prompts.length != k) return;

    setState(() {
      _discussionPromptsRounds = prompts;
      _currentDiscussionRound = 0;
      _flowPhase = _FlowPhase.discussion;
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

  void _goToNextDiscussionRound() {
    if (_flowPhase != _FlowPhase.discussion) return;
    if (_currentDiscussionRound >= _discussionPromptsRounds.length - 1) {
      return;
    }
    final wasRunning = _timerService?.isRunning ?? false;
    setState(() {
      _currentDiscussionRound++;
      if (widget.sessionConfig.enableTimer) {
        _timerService?.dispose();
        _timerService = TimerService(
          initialDuration: widget.sessionConfig.timerDuration,
          onTick: () => setState(() {}),
          onFinished: _onTimerFinished,
        );
        if (wasRunning) {
          _timerService!.start();
        }
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
    SessionEndDialog.show(context);
  }

  void _saveDiscussionRecord() {
    if (_didSaveHistory || _session == null) return;
    final s = _session!;
    final l10n = AppLocalizations.of(context)!;
    final topics = _discussionPromptsRounds.isNotEmpty
        ? List<String>.from(_discussionPromptsRounds)
        : _flatTopicsFromGroups();
    final record = SessionRecord.create(
      mode: 'discussion',
      topics: topics,
      selectedCardsByPlayer: const {},
      playerCount: s.config.playerCount,
      playerNames: SessionRecord.labelsForPlayers(
        playerCount: s.config.playerCount,
        configPlayerNames: s.config.playerNames,
        defaultName: l10n.playerName,
      ),
    );
    _didSaveHistory = true;
    SessionRecordService.addRecord(record);
  }

  void _navigateToModeSelection() {
    // モード選択は pushReplacement で消えているため isFirst では SessionSetup に戻る
    Navigator.of(context).pushAndRemoveUntil(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
      (route) => false,
    );
  }

  void _goBack() {
    if (_session != null && _session!.isActive) {
      Navigator.of(context).pop();
      return;
    }
    _navigateToModeSelection();
  }

  Widget _buildPickingKickoffSummary(AppLocalizations l10n) {
    final hasTimer = widget.sessionConfig.enableTimer;
    final btn = l10n.discussionKickoffStartButton;
    final durationLabel = hasTimer
        ? _formatDiscussionDuration(widget.sessionConfig.timerDuration)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.discussionGroupKickoffLead(_discussionTargetCount),
          textAlign: TextAlign.center,
          style: PlayTextStyles.bodyEmphasis(),
        ),
        if (hasTimer) ...[
          const SizedBox(height: 8),
          Text(
            l10n.discussionKickoffTimerNote(btn, durationLabel),
            textAlign: TextAlign.center,
            style: PlayTextStyles.timerNote(),
          ),
        ],
      ],
    );
  }

  Widget _buildDiscussionActiveGroupHint(AppLocalizations l10n) {
    return Text(
      l10n.discussionGroupHint,
      textAlign: TextAlign.center,
      style: PlayTextStyles.bodyEmphasis(),
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
            style: PlayTextStyles.sectionTitle(),
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
                    isSelected: _selectedDiscussionIds.contains(
                      '${group.categoryId}|$index',
                    ),
                    selectionOrder: _selectedDiscussionIds.indexOf(
                          '${group.categoryId}|$index',
                        ) +
                        1,
                    interactive: pickingEnabled,
                    onTap: () => _onPickingCardTap(
                      '${group.categoryId}|$index',
                    ),
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
    if (_flowPhase != _FlowPhase.discussion) return false;
    return _discussionPromptsRounds.isNotEmpty;
  }

  Widget _buildMainPromptCard(AppLocalizations l10n, TalkShuffleTokens ts) {
    if (_flowPhase == _FlowPhase.discussion) {
      if (_discussionPromptsRounds.isEmpty) {
        return const SizedBox.shrink();
      }
      final body = _discussionPromptsRounds[_currentDiscussionRound];
      final roundTotal = _discussionPromptsRounds.length;
      return PlaySurfaceCard(
        minHeight: 88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.discussionRoundProgress(
                _currentDiscussionRound + 1,
                roundTotal,
              ),
              textAlign: TextAlign.center,
              style: PlayTextStyles.caption(),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: PlayTextStyles.prompt(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ts = context.talkShuffle;
    final picking = _flowPhase == _FlowPhase.pickingTopics;
    final pickingEnabled = picking && _session != null && _session!.isActive;

    return PlaySessionScaffold(
      title: widget.deckTitle,
      onBack: _goBack,
      backTooltip: l10n.backToSettings,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          playScreenHorizontalPadding,
          playScreenVerticalPadding,
          playScreenHorizontalPadding,
          24,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_flowPhase == _FlowPhase.discussion &&
                  _session != null &&
                  _session!.isActive) ...[
                _buildDiscussionActiveGroupHint(l10n),
                const SizedBox(height: 12),
                if (_session!.config.enableTimer && _timerService != null) ...[
                  PlayTimerPanel(
                    timerService: _timerService!,
                    onPause: _toggleTimer,
                    onResume: _toggleTimer,
                    onExtendOneMinute: _extendTimerOneMinute,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              if (picking)
                Text(
                  l10n.discussionHint,
                  style: PlayTextStyles.hint(),
                  textAlign: TextAlign.center,
                ),
              if (picking && _discussionTargetCount > 0) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.discussionPickTopicsInstruction(_discussionTargetCount),
                  style: PlayTextStyles.bodyEmphasis(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.discussionSelectionProgress(
                    _selectedDiscussionIds.length,
                    _discussionTargetCount,
                  ),
                  textAlign: TextAlign.center,
                  style: PlayTextStyles.caption(),
                ),
                if (_discussionTargetCount == _totalCards &&
                    _selectedDiscussionIds.isEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.discussionPickTopicsAllOrSelectHint,
                    textAlign: TextAlign.center,
                    style: PlayTextStyles.timerNote(),
                  ),
                ],
              ],
              if (picking) const SizedBox(height: 16),
              if (picking &&
                  _session != null &&
                  _session!.isActive &&
                  _totalCards > 0)
                Text(
                  widget.discussionDeckType != null &&
                          cardDeckTypeUsesCategorizedDiscussion(
                            widget.discussionDeckType!,
                          )
                      ? l10n.discussionTableSummary(
                          widget.sessionConfig.discussionPromptsPerCategory ??
                              1,
                          _totalCards,
                        )
                      : l10n.discussionTotalCardsOnTable(_totalCards),
                  textAlign: TextAlign.center,
                  style: PlayTextStyles.caption(),
                ),
              if (picking) const SizedBox(height: 16),
              if (picking) ...[
                Text(
                  l10n.discussionPickFromCardsHeading,
                  textAlign: TextAlign.center,
                  style: PlayTextStyles.sectionTitle(),
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
                _buildPickingKickoffSummary(l10n),
                const SizedBox(height: 12),
                Opacity(
                  opacity: _selectionReadyForProceed ? 1 : 0.45,
                  child: PlayPrimaryButton(
                    label: l10n.discussionKickoffStartButton,
                    onPressed: _selectionReadyForProceed
                        ? _proceedToDiscussionPhase
                        : null,
                  ),
                ),
              ],
              if (_showMainPromptCard) ...[
                const SizedBox(height: 16),
                _buildMainPromptCard(l10n, ts),
              ],
              if (_session != null &&
                  _session!.isActive &&
                  _flowPhase == _FlowPhase.discussion &&
                  _discussionPromptsRounds.length > 1 &&
                  _currentDiscussionRound <
                      _discussionPromptsRounds.length - 1) ...[
                const SizedBox(height: 14),
                PlayOutlineButton(
                  label: l10n.discussionNextRoundButton,
                  onPressed: _goToNextDiscussionRound,
                ),
              ],
              if (_session != null &&
                  _session!.isActive &&
                  _flowPhase == _FlowPhase.discussion) ...[
                const SizedBox(height: 24),
                PlayPrimaryButton(
                  label: l10n.discussionEndDiscussionButton,
                  icon: Icons.check_circle,
                  onPressed: _endDiscussionSession,
                ),
              ],
            ],
          ),
        ),
    );
  }
}

class _DiscussionPickCard extends StatelessWidget {
  final String prompt;
  final String backLabel;
  final Color accent;
  final bool isSelected;
  /// 選ばれているとき 1 始まりの順番。未選択は 0。
  final int selectionOrder;
  final bool interactive;
  final VoidCallback onTap;

  const _DiscussionPickCard({
    required this.prompt,
    required this.backLabel,
    required this.accent,
    this.isSelected = false,
    this.selectionOrder = 0,
    required this.interactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const w = 112.0;
    const h = 132.0;
    final border = Border.all(color: Colors.black87, width: 1.5);

    final back = Material(
      color: accent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: interactive ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 28,
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
        onTap: interactive ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2E7D32),
              width: 2.6,
            ),
          ),
          child: Stack(
            children: [
              Center(
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
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$selectionOrder',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
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
      child: isSelected
          ? KeyedSubtree(
              key: ValueKey('f-$selectionOrder'),
              child: front,
            )
          : KeyedSubtree(
              key: const ValueKey('b'),
              child: back,
            ),
    );
  }
}
