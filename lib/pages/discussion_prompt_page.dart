import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/game_session.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/timer_feedback.dart';
import 'package:theme_dice/widgets/player_indicator.dart';
import 'package:theme_dice/widgets/timer_display.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';
import 'mode_selection_page.dart';

/// 問題解決・社会課題デッキ用：お題を1枚ずつ表示し、順位づけなく話す
class DiscussionPromptPage extends StatefulWidget {
  final List<String> themes;
  final SessionConfig sessionConfig;
  /// AppBar タイトル（デッキ名）
  final String deckTitle;

  const DiscussionPromptPage({
    super.key,
    required this.themes,
    required this.sessionConfig,
    required this.deckTitle,
  });

  @override
  State<DiscussionPromptPage> createState() => _DiscussionPromptPageState();
}

class _DiscussionPromptPageState extends State<DiscussionPromptPage> {
  final Random _random = Random();
  late List<String> _ordered;
  int _index = 0;
  GameSession? _session;
  TimerService? _timerService;
  bool _didSaveHistory = false;

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  String get _currentPrompt =>
      _ordered.isEmpty ? '' : _ordered[_index.clamp(0, _ordered.length - 1)];

  @override
  void initState() {
    super.initState();
    _ordered = List<String>.from(widget.themes)..shuffle(_random);
    _session = GameSession(
      config: widget.sessionConfig,
      themes: {PolyhedronType.cube: widget.themes},
      isActive: true,
    );
    _session!.startSession();
    if (_ordered.isNotEmpty) {
      _session!.addRoundResult(_ordered[0]);
    }
    if (widget.sessionConfig.enableTimer) {
      _timerService = TimerService(
        initialDuration: widget.sessionConfig.timerDuration,
        onTick: () => setState(() {}),
        onFinished: _onTimerFinished,
      );
      _timerService!.start();
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

  void _resetTimerFromConfig() {
    if (_timerService == null || _session == null) return;
    if (!_session!.config.enableTimer) return;
    _timerService!.reset(_session!.config.timerDuration);
    _timerService!.start();
  }

  void _nextTopic() {
    if (_ordered.isEmpty) return;
    setState(() {
      final nextIndex = (_index + 1) % _ordered.length;
      if (nextIndex == 0) {
        _ordered = List<String>.from(widget.themes)..shuffle(_random);
      }
      _index = nextIndex;
      _session?.addRoundResult(_ordered[_index]);
    });
    _resetTimerFromConfig();
    _triggerVibration();
  }

  void _nextPlayer() {
    if (_session == null) return;
    final wasLast = _session!.isLastPlayer;
    setState(() {
      _session!.nextPlayer();
      if (_timerService != null) {
        _timerService!.stop();
        if (_session?.config.enableTimer == true) {
          _timerService!.reset(_session!.config.timerDuration);
        }
      }
    });
    if (wasLast && _session != null && !_session!.isActive) {
      _saveDiscussionRecord();
      _showSessionEndDialog();
    }
  }

  void _saveDiscussionRecord() {
    if (_didSaveHistory || _session == null) return;
    final topics = _session!.rounds.map((r) => r.theme).toList();
    final record = SessionRecord.create(
      mode: 'discussion',
      topics: topics,
      selectedCardsByPlayer: const {},
      playerCount: _session!.config.playerCount,
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

  void _goBack() {
    if (_session != null && _session!.isActive) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = _ordered.length;
    final ts = context.talkShuffle;

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
              Text(
                l10n.discussionHint,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: _black.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                  onExtendOneMinute: _extendTimerOneMinute,
                ),
                const SizedBox(height: 16),
              ],
              if (total > 0)
                Text(
                  l10n.discussionProgress(_index + 1, total),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _black.withOpacity(0.55),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                child: Center(
                  child: Text(
                    _currentPrompt,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: _black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: total == 0 ? null : _nextTopic,
                icon: const Icon(Icons.navigate_next, color: _black),
                label: Text(
                  l10n.discussionNextTopic,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ts.brandYellow,
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
              const SizedBox(height: 20),
              if (_session != null && _session!.isActive) ...[
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
