import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/card_deck.dart';
import '../models/checkin_checkout_item.dart';
import '../models/session_config.dart';
import '../models/game_session.dart';
import '../models/polyhedron_type.dart';
import '../services/timer_service.dart';
import '../utils/route_transitions.dart';
import '../widgets/player_indicator.dart';
import '../widgets/timer_display.dart';
import '../widgets/card_draw_widget.dart';
import 'mode_selection_page.dart';
import 'session_setup_page.dart';

/// トピックカード/リストでテーマを引いて遊ぶ画面（案B: 初期画面「カードで遊ぶ」またはセッション設定で選択）
class TopicsPage extends StatefulWidget {
  final Map<PolyhedronType, List<String>> initialThemes;
  /// null の場合は単体利用（プレイヤー表示・タイマー・次のプレイヤーなし）
  final SessionConfig? sessionConfig;
  /// チェックイン・チェックアウト用。両方指定時は会議前/会議後の切り替えUIを表示（難易度付き）
  final List<CheckInCheckOutItem>? checkInItems;
  final List<CheckInCheckOutItem>? checkOutItems;
  /// 自己内省・1on1用：テーマ文字列 → カテゴリ（色・アイコン表示用）
  final Map<String, ReflectionDeckCategory>? themeCategoryMap;

  const TopicsPage({
    super.key,
    required this.initialThemes,
    this.sessionConfig,
    this.checkInItems,
    this.checkOutItems,
    this.themeCategoryMap,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

/// 会議前/会議後のフェーズ
enum _CheckInPhase { before, after }

/// 会議前で選ぶ枚数（最大3）
const int _maxCheckInCards = 3;

class _TopicsPageState extends State<TopicsPage> {
  GameSession? _session;
  TimerService? _timerService;
  String? _currentTopic;
  final Random _random = Random();
  _CheckInPhase _phase = _CheckInPhase.before;
  /// 会議前：何枚選ぶか（1〜3）
  int _checkInCardCount = 1;
  /// 会議前：選んだカード（1〜3枚）
  List<CheckInCheckOutItem>? _selectedCheckInItems;
  /// 会議後：選んだ1問
  CheckInCheckOutItem? _selectedCheckOutItem;
  /// 会議後：候補として表示中の問い（再描画で変わらないよう保持）
  List<CheckInCheckOutItem>? _candidateCheckOutItems;

  bool get _isCheckInCheckOutMode =>
      (widget.checkInItems != null &&
          widget.checkInItems!.isNotEmpty &&
          widget.checkOutItems != null &&
          widget.checkOutItems!.isNotEmpty);

  List<String> get _themes {
    if (_isCheckInCheckOutMode) {
      return _phase == _CheckInPhase.before
          ? widget.checkInItems!.map((e) => e.text).toList()
          : widget.checkOutItems!.map((e) => e.text).toList();
    }
    return widget.initialThemes[PolyhedronType.cube] ?? [];
  }

  /// 会議前で選択済みか
  bool get _hasCheckInSelection =>
      _selectedCheckInItems != null && _selectedCheckInItems!.isNotEmpty;

  /// 会議後で選択済みか
  bool get _hasCheckOutSelection => _selectedCheckOutItem != null;

  /// 難易度の表示ラベル（l10n）
  String _levelLabel(AppLocalizations l10n, CheckInLevel level) {
    switch (level) {
      case CheckInLevel.beginner:
        return l10n.levelBeginner;
      case CheckInLevel.intermediate:
        return l10n.levelIntermediate;
      case CheckInLevel.advanced:
        return l10n.levelAdvanced;
    }
  }

  /// 表示中のテーマに対するカテゴリ（自己内省デッキ用・テーマが未選択なら null）
  ReflectionDeckCategory? _getCategoryForCurrentTopic() {
    final map = widget.themeCategoryMap;
    if (map == null || map.isEmpty) return null;
    final topic = _isCheckInCheckOutMode
        ? (_phase == _CheckInPhase.after
            ? _selectedCheckOutItem?.text
            : _selectedCheckInItems?.isNotEmpty == true
                ? _selectedCheckInItems!.first.text
                : null)
        : _currentTopic;
    return topic != null ? map[topic] : null;
  }

  /// 会議後用：候補として表示する3問（シャッフルから先頭を取る）
  List<CheckInCheckOutItem> _getCheckOutCandidates() {
    final list = List<CheckInCheckOutItem>.from(widget.checkOutItems ?? []);
    if (list.isEmpty) return [];
    list.shuffle(_random);
    return list.take(3).toList();
  }

  /// 会議前：選択した枚数でランダムに選ぶ
  void _drawCheckInCards() {
    final items = widget.checkInItems!;
    if (items.isEmpty) return;
    final list = List<CheckInCheckOutItem>.from(items);
    list.shuffle(_random);
    final selected = list.take(_checkInCardCount).toList();
    setState(() {
      _selectedCheckInItems = selected;
      final session = _session;
      if (session != null) {
        for (final item in selected) {
          session.addRoundResult(item.text);
        }
        if (session.config.enableTimer && _timerService != null) {
          _timerService!.reset(session.config.timerDuration);
          _timerService!.start();
        }
      }
    });
    _triggerVibration();
  }

  void _selectCheckOutItem(CheckInCheckOutItem item) {
    setState(() {
      _selectedCheckOutItem = item;
      _currentTopic = item.text;
      final session = _session;
      if (session != null) {
        session.addRoundResult(item.text);
        if (session.config.enableTimer && _timerService != null) {
          _timerService!.reset(session.config.timerDuration);
          _timerService!.start();
        }
      }
    });
    _triggerVibration();
  }

  void _reselectQuestion() {
    setState(() {
      if (_phase == _CheckInPhase.before) {
        _selectedCheckInItems = null;
      } else {
        _selectedCheckOutItem = null;
        _candidateCheckOutItems = null;
      }
      _currentTopic = null;
      if (_phase == _CheckInPhase.after) {
        _candidateCheckOutItems = _getCheckOutCandidates();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final config = widget.sessionConfig;
    if (config != null) {
      _session = GameSession(
        config: config,
        themes: widget.initialThemes,
        isActive: true,
      );
      _session!.startSession();
      if (config.enableTimer) {
        _timerService = TimerService(
          initialDuration: config.timerDuration,
          onTick: () => setState(() {}),
          onFinished: _onTimerFinished,
        );
      }
    }
  }

  void _onTimerFinished() {
    _triggerVibration();
  }

  @override
  void dispose() {
    _timerService?.dispose();
    super.dispose();
  }

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _drawTopic() {
    final list = _themes;
    if (list.isEmpty) return;
    final theme = list[_random.nextInt(list.length)];
    setState(() {
      _currentTopic = theme;
      final session = _session;
      if (session != null) {
        session.addRoundResult(theme);
        if (session.config.enableTimer && _timerService != null) {
          _timerService!.reset(session.config.timerDuration);
          _timerService!.start();
        }
      }
    });
    _triggerVibration();
  }

  void _nextPlayer() {
    if (_session == null) return;
    final wasLastPlayer = _session!.isLastPlayer;
    setState(() {
      _session!.nextPlayer();
      _currentTopic = null;
      if (_timerService != null) {
        _timerService!.stop();
        if (_session?.config.enableTimer == true) {
          _timerService!.reset(_session!.config.timerDuration);
        }
      }
    });
    if (wasLastPlayer && _session != null && !_session!.isActive) {
      _showSessionEndDialog();
    }
  }

  void _showSessionEndDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.sessionSummary),
        content: Text(l10n.sessionCompleteMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _session = null);
            },
            child: Text(l10n.newSession),
          ),
        ],
      ),
    );
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

  void _skipTimer() {
    _timerService?.stop();
  }

  /// 会議後用：候補カード（3問・レベル表示付き）
  Widget _buildCheckOutCandidateCards(AppLocalizations l10n) {
    final computed = _getCheckOutCandidates();
    final candidates = _candidateCheckOutItems ?? computed;
    if (candidates.isEmpty) return const SizedBox.shrink();
    if (_candidateCheckOutItems == null && computed.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasCheckOutSelection) {
          setState(() => _candidateCheckOutItems = computed);
        }
      });
    }
    return Column(
      children: candidates.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            child: InkWell(
              onTap: () => _selectCheckOutItem(item),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _black.withOpacity(0.15), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _levelLabel(l10n, item.level),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _black.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _black,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 会議前用：「何枚選ぶ」セグメント（1〜3枚）
  Widget _buildCheckInCountSegment(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PhaseSegmentButton(
              label: l10n.checkInCardsOne,
              isSelected: _checkInCardCount == 1,
              onTap: () => setState(() => _checkInCardCount = 1),
            ),
          ),
          Expanded(
            child: _PhaseSegmentButton(
              label: l10n.checkInCardsTwo,
              isSelected: _checkInCardCount == 2,
              onTap: () => setState(() => _checkInCardCount = 2),
            ),
          ),
          Expanded(
            child: _PhaseSegmentButton(
              label: l10n.checkInCardsThree,
              isSelected: _checkInCardCount == 3,
              onTap: () => setState(() => _checkInCardCount = 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSegment(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PhaseSegmentButton(
              label: l10n.phaseCheckIn,
              isSelected: _phase == _CheckInPhase.before,
              onTap: () => setState(() => _phase = _CheckInPhase.before),
            ),
          ),
          Expanded(
            child: _PhaseSegmentButton(
              label: l10n.phaseCheckOut,
              isSelected: _phase == _CheckInPhase.after,
              onTap: () => setState(() {
                _phase = _CheckInPhase.after;
                _candidateCheckOutItems = _getCheckOutCandidates();
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _goBackToSettings() {
    if (widget.sessionConfig == null) {
      Navigator.of(context).pushReplacement(
        RouteTransitions.backRoute(
          page: const ModeSelectionPage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        RouteTransitions.backRoute(
          page: SessionSetupPage(
            themes: widget.initialThemes,
            fromDicePage: true,
          ),
        ),
      );
    }
  }

  static const Color _mustardYellow = Color(0xFFFFEB3B);
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _lightYellow = Color(0xFFFFFDE7);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _lightYellow,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: _goBackToSettings,
          tooltip: l10n.backToSettings,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_session != null) ...[
                PlayerIndicator(
                  currentPlayerIndex: _session!.currentPlayerIndex,
                  totalPlayers: _session!.config.playerCount,
                  currentPlayerName: _session!.currentPlayerName,
                ),
                const SizedBox(height: 16),
              ],
              if (_session != null &&
                  _session!.config.enableTimer &&
                  _timerService != null) ...[
                TimerDisplay(
                  timerService: _timerService!,
                  onPause: _toggleTimer,
                  onResume: _toggleTimer,
                  onSkip: _skipTimer,
                ),
                const SizedBox(height: 16),
              ],
              if (_isCheckInCheckOutMode) ...[
                _buildPhaseSegment(l10n),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
              // チェックイン・チェックアウト専用UI
              if (_isCheckInCheckOutMode) ...[
                if (_phase == _CheckInPhase.before) ...[
                  if (!_hasCheckInSelection) ...[
                    Text(
                      l10n.checkInHowManyPrompt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _buildCheckInCountSegment(l10n),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _drawCheckInCards,
                        icon: const Icon(Icons.style, color: _black),
                        label: Text(
                          l10n.checkInDrawCountButton,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mustardYellow,
                          foregroundColor: _black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      l10n.chosenCardLabelBefore,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ..._selectedCheckInItems!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: CardDrawWidget(
                              theme: item.text,
                              levelLabel: _levelLabel(l10n, item.level),
                              onDrawRequest: () {},
                              canDraw: false,
                            ),
                          ),
                        )),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reselectQuestion,
                      icon: const Icon(Icons.refresh, color: _black),
                      label: Text(
                        l10n.reselectQuestion,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mustardYellow,
                        foregroundColor: _black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ] else ...[
                  // 会議後
                  if (!_hasCheckOutSelection) ...[
                    Text(
                      l10n.checkInPickOnePrompt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildCheckOutCandidateCards(l10n),
                  ] else ...[
                    Text(
                      l10n.chosenCardLabelAfter,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: CardDrawWidget(
                        theme: _selectedCheckOutItem!.text,
                        levelLabel: _levelLabel(l10n, _selectedCheckOutItem!.level),
                        onDrawRequest: _reselectQuestion,
                        canDraw: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _reselectQuestion,
                      icon: const Icon(Icons.refresh, color: _black),
                      label: Text(
                        l10n.reselectQuestion,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mustardYellow,
                        foregroundColor: _black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ],
              ] else ...[
                // 通常のトピックカード（自己内省・チームビルディング等）
                Center(
                  child: CardDrawWidget(
                    theme: _currentTopic,
                    onDrawRequest: _drawTopic,
                    canDraw: _themes.isNotEmpty,
                    category: _getCategoryForCurrentTopic(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _themes.isEmpty ? null : _drawTopic,
                  icon: const Icon(Icons.style, color: _black),
                  label: Text(
                    l10n.drawTopic,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mustardYellow,
                    foregroundColor: _black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_session != null &&
                  (_currentTopic != null ||
                      (_isCheckInCheckOutMode && (_hasCheckInSelection || _hasCheckOutSelection)))) ...[
                ElevatedButton.icon(
                  onPressed: _nextPlayer,
                  icon: Icon(
                    _session!.isLastPlayer ? Icons.check_circle : Icons.arrow_forward,
                    color: _black,
                  ),
                  label: Text(
                    _session!.isLastPlayer ? l10n.endSession : l10n.nextPlayer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _white,
                    foregroundColor: _black,
                    side: const BorderSide(color: _black, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 1,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseSegmentButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PhaseSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _black = Colors.black87;
  static const Color _mustardYellow = Color(0xFFFFEB3B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _mustardYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: _black, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: _black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
