import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/card_deck.dart';
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
  /// チェックイン・チェックアウト用。両方指定時は会議前/会議後の切り替えUIを表示
  final List<String>? checkInThemes;
  final List<String>? checkOutThemes;
  /// 自己内省・1on1用：テーマ文字列 → カテゴリ（色・アイコン表示用）
  final Map<String, ReflectionDeckCategory>? themeCategoryMap;

  const TopicsPage({
    super.key,
    required this.initialThemes,
    this.sessionConfig,
    this.checkInThemes,
    this.checkOutThemes,
    this.themeCategoryMap,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

/// 会議前/会議後のフェーズ
enum _CheckInPhase { before, after }

class _TopicsPageState extends State<TopicsPage> {
  GameSession? _session;
  TimerService? _timerService;
  String? _currentTopic;
  final Random _random = Random();
  _CheckInPhase _phase = _CheckInPhase.before;
  /// チェックイン・チェックアウトで「今日の1問」として選んだ問い（会議前/会議後で別）
  String? _selectedCheckInQuestion;
  String? _selectedCheckOutQuestion;
  /// 候補として表示中の2〜3問（再描画で変わらないよう保持）
  List<String>? _candidateQuestions;

  bool get _isCheckInCheckOutMode =>
      (widget.checkInThemes != null &&
          widget.checkInThemes!.isNotEmpty &&
          widget.checkOutThemes != null &&
          widget.checkOutThemes!.isNotEmpty);

  List<String> get _themes {
    if (_isCheckInCheckOutMode) {
      return _phase == _CheckInPhase.before
          ? widget.checkInThemes!
          : widget.checkOutThemes!;
    }
    return widget.initialThemes[PolyhedronType.cube] ?? [];
  }

  /// 現在のフェーズで選ばれた1問（未選択なら null）
  String? _getSelectedQuestionForPhase() =>
      _phase == _CheckInPhase.before ? _selectedCheckInQuestion : _selectedCheckOutQuestion;

  /// 表示中のテーマに対するカテゴリ（自己内省デッキ用・テーマが未選択なら null）
  ReflectionDeckCategory? _getCategoryForCurrentTopic() {
    final map = widget.themeCategoryMap;
    if (map == null || map.isEmpty) return null;
    final topic = _isCheckInCheckOutMode
        ? _getSelectedQuestionForPhase()
        : _currentTopic;
    return topic != null ? map[topic] : null;
  }

  /// 候補として表示する2〜3問（シャッフルから先頭を取る）
  List<String> _getCandidates() {
    final list = List<String>.from(_themes);
    if (list.isEmpty) return [];
    list.shuffle(_random);
    return list.take(3).toList();
  }

  void _selectQuestion(String question) {
    setState(() {
      if (_phase == _CheckInPhase.before) {
        _selectedCheckInQuestion = question;
      } else {
        _selectedCheckOutQuestion = question;
      }
      _currentTopic = question;
      final session = _session;
      if (session != null) {
        session.addRoundResult(question);
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
        _selectedCheckInQuestion = null;
      } else {
        _selectedCheckOutQuestion = null;
      }
      _currentTopic = null;
      _candidateQuestions = _getCandidates();
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

  Widget _buildCandidateCards(AppLocalizations l10n) {
    final computed = _getCandidates();
    final candidates = _candidateQuestions ?? computed;
    if (candidates.isEmpty) return const SizedBox.shrink();
    // 初回表示で候補を状態に保存（再描画で変わらないように）
    if (_candidateQuestions == null && computed.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _getSelectedQuestionForPhase() == null) {
          setState(() => _candidateQuestions = computed);
        }
      });
    }
    return Column(
      children: candidates.map((question) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            elevation: 2,
            child: InkWell(
              onTap: () => _selectQuestion(question),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _black.withOpacity(0.15), width: 1),
                ),
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _black,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
              onTap: () => setState(() {
                _phase = _CheckInPhase.before;
                _candidateQuestions = _getCandidates();
              }),
            ),
          ),
          Expanded(
            child: _PhaseSegmentButton(
              label: l10n.phaseCheckOut,
              isSelected: _phase == _CheckInPhase.after,
              onTap: () => setState(() {
                _phase = _CheckInPhase.after;
                _candidateQuestions = _getCandidates();
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
              // チェックイン・チェックアウト: 候補から1問選ぶ or 選んだ1問を表示
              if (_isCheckInCheckOutMode && _getSelectedQuestionForPhase() == null) ...[
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
                _buildCandidateCards(l10n),
              ] else ...[
                if (_isCheckInCheckOutMode && _getSelectedQuestionForPhase() != null) ...[
                  Text(
                    _phase == _CheckInPhase.before
                        ? l10n.chosenCardLabelBefore
                        : l10n.chosenCardLabelAfter,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                Center(
                  child: CardDrawWidget(
                    theme: _isCheckInCheckOutMode
                        ? _getSelectedQuestionForPhase()
                        : _currentTopic,
                    onDrawRequest: _isCheckInCheckOutMode ? _reselectQuestion : _drawTopic,
                    canDraw: _isCheckInCheckOutMode || _themes.isNotEmpty,
                    category: _getCategoryForCurrentTopic(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isCheckInCheckOutMode
                      ? _reselectQuestion
                      : (_themes.isEmpty ? null : _drawTopic),
                  icon: Icon(
                    _isCheckInCheckOutMode ? Icons.refresh : Icons.style,
                    color: _black,
                  ),
                  label: Text(
                    _isCheckInCheckOutMode ? l10n.reselectQuestion : l10n.drawTopic,
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
                      (_isCheckInCheckOutMode && _getSelectedQuestionForPhase() != null))) ...[
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
