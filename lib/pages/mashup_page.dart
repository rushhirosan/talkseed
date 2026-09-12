import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/mashup_deck.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/services/mashup_picker.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/utils/session_end_dialog.dart';
import 'package:theme_dice/utils/timer_feedback.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';
import 'package:theme_dice/widgets/mashup_slot_widget.dart';
import 'package:theme_dice/widgets/play/play_session_ui.dart';
import 'package:theme_dice/widgets/talk_shuffle_dialog.dart';
import 'package:theme_dice/widgets/timer_display.dart';

/// マッシュアップのプレイ画面。軸ごとのスロットを回して 1 行のお題を作る。
class MashupPage extends StatefulWidget {
  final MashupDeck deck;

  /// このセッションで使う軸（設定画面でオンにしたもの）
  final List<MashupAxis> axes;
  final SessionConfig config;

  const MashupPage({
    super.key,
    required this.deck,
    required this.axes,
    required this.config,
  });

  @override
  State<MashupPage> createState() => _MashupPageState();
}

class _MashupPageState extends State<MashupPage> {
  static const Duration _tickInterval = Duration(milliseconds: 70);
  static const Duration _firstStopDelay = Duration(milliseconds: 500);
  static const Duration _stopStagger = Duration(milliseconds: 280);

  late final MashupPicker _picker;

  /// 軸ID -> 現在表示中の語
  final Map<String, String> _picks = {};

  /// プレイヤー index -> 確定したお題
  final Map<int, String> _topicByPlayerIndex = {};

  /// ロック中の軸ID（回しても変わらない）
  final Set<String> _lockedAxisIds = {};

  /// 回転中の軸ID
  final Set<String> _spinningAxisIds = {};

  final List<Timer> _pendingStops = [];
  Timer? _tickTimer;

  /// 今回のスピンで確定済みの軸（ティックで消えない）
  final Map<String, String> _resolvedPicks = {};

  /// 回転中スロットの表示用（ティックごとに更新）
  final Map<String, String> _tickValues = {};

  int _currentPlayerIndex = 0;
  bool _hasSpun = false;

  bool get _isLastPlayer =>
      _currentPlayerIndex >= widget.config.playerCount - 1;

  /// お題が確定し、タイマー待機中または計測中
  bool get _promptReady => _hasSpun && _spinningAxisIds.isEmpty;

  bool get _hasSessionProgress =>
      _topicByPlayerIndex.isNotEmpty || _hasSpun;

  TimerService? _timerService;

  @override
  void initState() {
    super.initState();
    _picker = MashupPicker(deck: widget.deck, axes: widget.axes);
    if (widget.config.enableTimer) {
      _timerService = TimerService(
        initialDuration: widget.config.timerDuration,
        onTick: () => setState(() {}),
        onFinished: () {
          TimerFeedback.play();
          if (mounted) setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    _cancelSpin();
    _timerService?.dispose();
    super.dispose();
  }

  void _cancelSpin() {
    _tickTimer?.cancel();
    _tickTimer = null;
    for (final timer in _pendingStops) {
      timer.cancel();
    }
    _pendingStops.clear();
    _spinningAxisIds.clear();
    _tickValues.clear();
  }

  void _refreshDisplayPicks() {
    _picks
      ..clear()
      ..addAll(_resolvedPicks);
    for (final id in _spinningAxisIds) {
      final tick = _tickValues[id];
      if (tick != null && tick.isNotEmpty) {
        _picks[id] = tick;
      }
    }
  }

  void _lightHaptic() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 40);
      }
    });
  }

  void _startTickTimer(Map<String, String> previousPicks) {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(_tickInterval, (_) {
      if (!mounted || _spinningAxisIds.isEmpty) return;
      for (final id in _spinningAxisIds) {
        final rolled = _picker.spin(
          lockedPicks: _resolvedPicks,
          spinAxisIds: {id},
          previousPicks: previousPicks,
        );
        final value = rolled[id];
        if (value != null && value.isNotEmpty) {
          _tickValues[id] = value;
        }
      }
      setState(_refreshDisplayPicks);
    });
  }

  void _stopAxis(String axisId, Map<String, String> previousPicks) {
    if (!mounted) return;

    _tickTimer?.cancel();
    _tickTimer = null;

    final rolled = _picker.spin(
      lockedPicks: _resolvedPicks,
      spinAxisIds: {axisId},
      previousPicks: previousPicks,
    );
    final value = rolled[axisId];
    if (value != null && value.isNotEmpty) {
      _resolvedPicks[axisId] = value;
    }
    _tickValues.remove(axisId);

    _spinningAxisIds.remove(axisId);
    final allStopped = _spinningAxisIds.isEmpty;

    setState(_refreshDisplayPicks);

    _lightHaptic();

    if (allStopped) {
      _onSpinSettled();
    } else {
      _startTickTimer(previousPicks);
    }
  }

  Map<String, String> _lockedPicks() {
    return Map.fromEntries(
      _picks.entries.where((e) => _lockedAxisIds.contains(e.key)),
    );
  }

  void _spin() {
    if (_spinningAxisIds.isNotEmpty) return;

    final targetIds = <String>[
      for (final axis in widget.axes)
        if (!_lockedAxisIds.contains(axis.id)) axis.id,
    ];
    if (targetIds.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mashupAllAxesLocked)),
      );
      return;
    }

    _cancelSpin();
    final timer = _timerService;
    timer?.stop();
    timer?.reset(widget.config.timerDuration);

    final previousPicks = Map<String, String>.from(_picks);
    _resolvedPicks
      ..clear()
      ..addAll(_lockedPicks());
    for (final id in targetIds) {
      _resolvedPicks.remove(id);
    }
    _tickValues.clear();

    setState(() {
      _hasSpun = true;
      _spinningAxisIds
        ..clear()
        ..addAll(targetIds);
      _refreshDisplayPicks();
    });

    _startTickTimer(previousPicks);

    for (var i = 0; i < targetIds.length; i++) {
      final axisId = targetIds[i];
      final delay = _firstStopDelay + _stopStagger * i;
      _pendingStops.add(
        Timer(delay, () => _stopAxis(axisId, previousPicks)),
      );
    }
  }

  void _onSpinSettled() {
    _tickTimer?.cancel();
    _tickTimer = null;
    _tickValues.clear();
    setState(() {
      _picks
        ..clear()
        ..addAll(_resolvedPicks);
    });
    final topic = widget.deck.compose(_picks);
    if (topic.isNotEmpty) {
      _topicByPlayerIndex[_currentPlayerIndex] = topic;
    }
    final timer = _timerService;
    if (timer != null) {
      timer.reset(widget.config.timerDuration);
      timer.start();
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void _toggleLock(String axisId) {
    if (_spinningAxisIds.isNotEmpty) {
      return;
    }
    setState(() {
      if (_lockedAxisIds.contains(axisId)) {
        _lockedAxisIds.remove(axisId);
      } else {
        _lockedAxisIds.add(axisId);
      }
    });
  }

  Future<void> _nextPlayer() async {
    if (!_promptReady) return;

    if (_isLastPlayer) {
      await _finish();
      return;
    }

    _cancelSpin();
    final timer = _timerService;
    timer?.stop();
    timer?.reset(widget.config.timerDuration);
    setState(() {
      _currentPlayerIndex++;
      _hasSpun = false;
      _picks.clear();
      _resolvedPicks.clear();
      _tickValues.clear();
    });
  }

  Future<bool> _confirmLeaveSession() async {
    if (!_hasSessionProgress) {
      return true;
    }
    final l10n = AppLocalizations.of(context)!;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => TalkShuffleAlertDialog(
        title: Text(l10n.mashupLeaveTitle),
        content: Text(l10n.mashupLeaveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.mashupLeaveConfirm),
          ),
        ],
      ),
    );
    return leave == true;
  }

  Future<void> _handleBack() async {
    if (await _confirmLeaveSession()) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _finish() async {
    if (_topicByPlayerIndex.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => TalkShuffleAlertDialog(
          title: Text(l10n.mashupEmptySessionTitle),
          content: Text(l10n.mashupEmptySessionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.endSession),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) {
        return;
      }
    }

    final l10n = AppLocalizations.of(context)!;
    _cancelSpin();
    _timerService?.stop();

    final playerNames = SessionRecord.labelsForPlayers(
      playerCount: widget.config.playerCount,
      configPlayerNames: widget.config.playerNames,
      defaultName: l10n.playerName,
    );

    final selectedCardsByPlayer = <String, List<String>>{};
    final topics = <String>[];
    for (var i = 0; i < playerNames.length; i++) {
      final topic = _topicByPlayerIndex[i];
      if (topic != null && topic.isNotEmpty) {
        selectedCardsByPlayer[playerNames[i]] = [topic];
        topics.add(topic);
      }
    }

    await SessionRecordService.addRecord(
      SessionRecord.create(
        mode: SessionRecord.modeMashup,
        topics: topics,
        selectedCardsByPlayer: selectedCardsByPlayer,
        playerCount: widget.config.playerCount,
        playerNames: playerNames,
        sessionConfig: widget.config,
      ),
    );
    if (!mounted) return;
    await SessionEndDialog.show(context);
  }

  Widget _buildComposedLine(AppLocalizations l10n) {
    final settled = _promptReady;
    final text = settled ? widget.deck.compose(_picks) : l10n.mashupSpinHint;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePalette.accent.withValues(alpha: settled ? 0.12 : 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HomePalette.accent.withValues(alpha: settled ? 0.5 : 0.15),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.zenKakuGothicNew(
          fontSize: settled ? 18 : 14,
          fontWeight: settled ? FontWeight.w700 : FontWeight.w500,
          color: settled ? HomePalette.text : HomePalette.textMuted,
          height: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spinning = _spinningAxisIds.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: HomeScaffold(
        title: l10n.mashupTitle,
        leading: HomeBackButton(onPressed: _handleBack),
        body: LayoutBuilder(
          builder: (context, viewport) {
            final contentWidth = viewport.maxWidth < 520
                ? viewport.maxWidth
                : 520.0;
            Widget? timer;
            if (_timerService != null && _promptReady) {
              timer = TimerDisplay(
                timerService: _timerService,
                useHomeStyle: true,
                onPause: () => setState(() {
                  _timerService!.pause();
                }),
                onResume: () => setState(() {
                  _timerService!.resume();
                }),
                onExtendOneMinute: () => setState(() {
                  _timerService!
                    ..addTime(const Duration(minutes: 1))
                    ..start();
                }),
              );
            }

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: viewport.maxHeight,
                child: PlayStickyChrome(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  header: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlaySessionMetaBar(
                      currentPlayerIndex: _currentPlayerIndex,
                      totalPlayers: widget.config.playerCount,
                      currentPlayerName:
                          widget.config.getPlayerName(_currentPlayerIndex),
                      trailing: timer,
                    ),
                  ),
                  scrollBody: true,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final axis in widget.axes) ...[
                        MashupSlotWidget(
                          axisLabel: axis.label,
                          value: _picks[axis.id],
                          spinning: _spinningAxisIds.contains(axis.id),
                          locked: _lockedAxisIds.contains(axis.id),
                          lockTooltip: l10n.mashupLockAxis,
                          unlockTooltip: l10n.mashupUnlockAxis,
                          onToggleLock: () => _toggleLock(axis.id),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                      _buildComposedLine(l10n),
                    ],
                  ),
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: spinning ? 0.45 : 1,
                        child: AbsorbPointer(
                          absorbing: spinning,
                          child: HomePrimaryButton(
                            label: _hasSpun
                                ? l10n.mashupSpinAgain
                                : l10n.mashupSpin,
                            icon: Icons.autorenew_rounded,
                            onPressed: _spin,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _promptReady ? _nextPlayer : null,
                              style: TextButton.styleFrom(
                                foregroundColor: HomePalette.text,
                              ),
                              child: Text(
                                _isLastPlayer
                                    ? l10n.endSession
                                    : l10n.nextPlayer,
                              ),
                            ),
                          ),
                          if (!_isLastPlayer)
                            Expanded(
                              child: TextButton(
                                onPressed: _finish,
                                style: TextButton.styleFrom(
                                  foregroundColor: HomePalette.textMuted,
                                ),
                                child: Text(l10n.endSession),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
