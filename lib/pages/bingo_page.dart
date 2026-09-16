import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/bingo_deck.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/pages/mode_tips_page.dart';
import 'package:theme_dice/services/bingo_rules.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/utils/session_end_dialog.dart';
import 'package:theme_dice/utils/timer_feedback.dart';
import 'package:theme_dice/widgets/bingo_board_widget.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';
import 'package:theme_dice/widgets/player_indicator.dart';
import 'package:theme_dice/widgets/talk_shuffle_dialog.dart';
import 'package:theme_dice/widgets/timer_display.dart';

/// 会話ビンゴのプレイ画面。共有 3×3 ボードをマスごとに埋める。
class BingoPage extends StatefulWidget {
  final BingoBoard board;
  final SessionConfig config;

  const BingoPage({
    super.key,
    required this.board,
    required this.config,
  });

  @override
  State<BingoPage> createState() => _BingoPageState();
}

class _BingoPageState extends State<BingoPage> {
  late BingoBoard _board;
  int? _selectedIndex;
  int _currentPlayerIndex = 0;
  final Map<int, List<String>> _topicsByPlayer = {};
  bool _bingoCelebrated = false;

  late List<int> _scores;
  late List<bool> _jammerLeft;
  int? _bonusIndex;
  int? _lastMarkPlayerIndex;
  int? _blockedIndex;
  int? _blockedForPlayer;
  bool _holdingExtraTurn = false;
  Duration _pendingTimerBonus = Duration.zero;
  final Set<int> _revealedIndices = {};

  TimerService? _timerService;

  bool get _flipMode => widget.config.bingoFlipMode;

  bool _isRevealed(int index) {
    if (!_flipMode) {
      return true;
    }
    if (_board.isMarked(index)) {
      return true;
    }
    return _revealedIndices.contains(index);
  }

  bool get _canMark =>
      _selectedIndex != null && !_board.isMarked(_selectedIndex!);

  bool get _hasSessionProgress =>
      _topicsByPlayer.values.any((topics) => topics.isNotEmpty);

  bool get _winConditionMet {
    if (widget.config.bingoWinOnBlackout) {
      return _board.isBlackout;
    }
    return _board.hasBingo;
  }

  bool get _hasJammer => _jammerLeft[_currentPlayerIndex];

  bool get _canJam =>
      _hasJammer &&
      _selectedIndex != null &&
      !_board.isMarked(_selectedIndex!) &&
      _blockedIndex != _selectedIndex;

  Duration get _timerLength =>
      widget.config.timerDuration + _pendingTimerBonus;

  @override
  void initState() {
    super.initState();
    _board = widget.board;
    _scores = List<int>.filled(widget.config.playerCount, 0);
    _jammerLeft = List<bool>.filled(widget.config.playerCount, true);
    if (widget.config.bingoFreeCenter) {
      final center = _board.centerIndex;
      if (center != null) {
        _board = _board.mark(center);
        if (_flipMode) {
          _revealedIndices.add(center);
        }
      }
    }
    _bonusIndex = pickBingoBonusIndex(_board, Random());
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
    _timerService?.dispose();
    super.dispose();
  }

  void _lightHaptic() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 40);
      }
    });
  }

  void _bingoHaptic() {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 120);
      }
    });
  }

  void _resetTimer() {
    final timer = _timerService;
    timer?.stop();
    timer?.reset(_timerLength);
    _pendingTimerBonus = Duration.zero;
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectCell(int index) {
    if (_board.isMarked(index)) {
      return;
    }
    if (_blockedIndex == index) {
      _toast(AppLocalizations.of(context)!.bingoJammedCell);
      return;
    }
    if (!_board.canSelect(
      index,
      adjacentOnly: widget.config.bingoAdjacentOnly,
    )) {
      _toast(AppLocalizations.of(context)!.bingoAdjacentBlocked);
      return;
    }
    _resetTimer();
    final newlyRevealed = _flipMode && !_isRevealed(index);
    setState(() {
      if (newlyRevealed) {
        _revealedIndices.add(index);
      }
      _selectedIndex = index;
      _holdingExtraTurn = false;
    });
    if (newlyRevealed) {
      _lightHaptic();
    }
    _timerService?.start();
  }

  void _jamSelected() {
    final index = _selectedIndex;
    if (index == null || !_canJam) {
      if (_hasJammer && _selectedIndex == null) {
        _toast(AppLocalizations.of(context)!.bingoJamNeedSelect);
      }
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    _resetTimer();
    setState(() {
      _blockedIndex = index;
      _blockedForPlayer =
          (_currentPlayerIndex + 1) % widget.config.playerCount;
      _jammerLeft[_currentPlayerIndex] = false;
      _selectedIndex = null;
    });
    _toast(l10n.bingoJamDone);
  }

  Future<void> _markSelected() async {
    final index = _selectedIndex;
    if (index == null || _board.isMarked(index)) {
      return;
    }

    final outcome = resolveBingoMark(
      before: _board,
      index: index,
      playerIndex: _currentPlayerIndex,
      bonusIndex: _bonusIndex,
      lastMarkPlayerIndex: _lastMarkPlayerIndex,
    );

    final text = _board.cells[index].text;
    _resetTimer();
    setState(() {
      _board = outcome.board;
      _scores[_currentPlayerIndex] += outcome.points;
      _lastMarkPlayerIndex = _currentPlayerIndex;
      _topicsByPlayer.putIfAbsent(_currentPlayerIndex, () => []).add(text);
      _selectedIndex = null;
      if (_flipMode) {
        _revealedIndices.add(index);
      }
      if (outcome.claimedBonus) {
        _bonusIndex = null;
        _pendingTimerBonus = const Duration(minutes: 1);
        _holdingExtraTurn = true;
      }
    });
    _lightHaptic();
    _toastScore(outcome);

    if (_winConditionMet && !_bingoCelebrated) {
      _bingoCelebrated = true;
      _bingoHaptic();
      await _showBingoDialog(extraTurn: outcome.extraTurn);
    } else if (_board.isBlackout) {
      _bingoHaptic();
      await _showBingoDialog(extraTurn: outcome.extraTurn);
    } else if (!outcome.extraTurn) {
      _advancePlayer();
    }
  }

  void _toastScore(BingoMarkOutcome outcome) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[l10n.bingoPointsGained(outcome.points)];
    if (outcome.claimedBonus) {
      parts.add(l10n.bingoExtraTurn);
    }
    _toast(parts.join('  '));
  }

  Future<void> _showBingoDialog({required bool extraTurn}) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final blackout = widget.config.bingoWinOnBlackout || _board.isBlackout;
    final continuePlay = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TalkShuffleAlertDialog(
        title: Text(l10n.bingoBingoTitle),
        content: Text(
          [
            blackout
                ? l10n.bingoBingoMessageBlackout
                : l10n.bingoBingoMessageLine,
            '',
            _scoreSummary(l10n),
          ].join('\n'),
        ),
        actions: [
          if (!blackout)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.bingoContinue),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.endSession),
          ),
        ],
      ),
    );
    if (continuePlay != true && mounted) {
      await _finish();
    } else if (mounted && !extraTurn) {
      _advancePlayer();
    }
  }

  void _advancePlayer() {
    _resetTimer();
    setState(() {
      final leaving = _currentPlayerIndex;
      _currentPlayerIndex =
          (_currentPlayerIndex + 1) % widget.config.playerCount;
      _selectedIndex = null;
      _holdingExtraTurn = false;
      if (_blockedForPlayer == leaving) {
        _blockedIndex = null;
        _blockedForPlayer = null;
      }
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
        title: Text(l10n.bingoLeaveTitle),
        content: Text(l10n.bingoLeaveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.bingoLeaveConfirm),
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

  List<String> _playerLabels(AppLocalizations l10n) {
    return SessionRecord.labelsForPlayers(
      playerCount: widget.config.playerCount,
      configPlayerNames: widget.config.playerNames,
      defaultName: l10n.playerName,
    );
  }

  String _scoreSummary(AppLocalizations l10n) {
    final names = _playerLabels(l10n);
    final lines = [
      for (var i = 0; i < names.length; i++)
        '${names[i]}: ${l10n.bingoScorePoints(_scores[i])}',
    ];
    final maxScore = _scores.reduce((a, b) => a > b ? a : b);
    if (maxScore <= 0) {
      return lines.join('\n');
    }
    final winners = [
      for (var i = 0; i < _scores.length; i++)
        if (_scores[i] == maxScore) names[i],
    ];
    final footer = winners.length == 1
        ? l10n.bingoWinner(winners.first)
        : l10n.bingoTie;
    return '${lines.join('\n')}\n$footer';
  }

  Future<void> _finish() async {
    if (!_hasSessionProgress) {
      final l10n = AppLocalizations.of(context)!;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => TalkShuffleAlertDialog(
          title: Text(l10n.bingoEmptySessionTitle),
          content: Text(l10n.bingoEmptySessionMessage),
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
    _timerService?.stop();

    final playerNames = _playerLabels(l10n);

    final selectedCardsByPlayer = <String, List<String>>{};
    final topics = <String>[];
    final voteResults = <String, int>{};
    for (var i = 0; i < playerNames.length; i++) {
      voteResults[playerNames[i]] = _scores[i];
      final playerTopics = _topicsByPlayer[i];
      if (playerTopics != null && playerTopics.isNotEmpty) {
        selectedCardsByPlayer[playerNames[i]] = List<String>.from(playerTopics);
        topics.addAll(playerTopics);
      }
    }

    await SessionRecordService.addRecord(
      SessionRecord.create(
        mode: SessionRecord.modeBingo,
        topics: topics,
        selectedCardsByPlayer: selectedCardsByPlayer,
        playerCount: widget.config.playerCount,
        playerNames: playerNames,
        voteResults: voteResults,
        sessionConfig: widget.config,
      ),
    );
    if (!mounted) return;
    await SessionEndDialog.show(
      context,
      title: l10n.bingoScoreTitle,
      message: _hasSessionProgress
          ? _scoreSummary(l10n)
          : l10n.sessionCompleteAcknowledgeMessage,
    );
  }

  Widget _buildScoreRow() {
    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.config.playerCount,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: bingoPlayerColor(i).withValues(
                alpha: i == _currentPlayerIndex ? 0.22 : 0.1,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: bingoPlayerColor(i).withValues(
                  alpha: i == _currentPlayerIndex ? 0.7 : 0.3,
                ),
              ),
            ),
            child: Text(
              '${i + 1}: ${_scores[i]}',
              style: GoogleFonts.zenKakuGothicNew(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HomePalette.text,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotHint(AppLocalizations l10n, {bool compact = false}) {
    if (_holdingExtraTurn) {
      return _hintBanner(
        icon: Icons.replay_rounded,
        color: HomePalette.accent,
        text: l10n.bingoExtraTurn,
        compact: compact,
      );
    }
    if (widget.config.bingoWinOnBlackout || _board.hotCells.isEmpty) {
      return const SizedBox.shrink();
    }
    return _hintBanner(
      icon: Icons.local_fire_department_rounded,
      color: HomePalette.accentOrange,
      text: l10n.bingoHotHint,
      compact: compact,
    );
  }

  Widget _hintBanner({
    required IconData icon,
    required Color color,
    required String text,
    bool compact = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 5 : 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: compact ? 14 : 18, color: color.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.zenKakuGothicNew(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w700,
                color: HomePalette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _showHintBanner =>
      _holdingExtraTurn ||
      (!widget.config.bingoWinOnBlackout && _board.hotCells.isNotEmpty);

  Widget? _buildPickHint(AppLocalizations l10n) {
    if (_selectedIndex != null) {
      final index = _selectedIndex!;
      if (index == _bonusIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            l10n.bingoBonusCellHint,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: HomePalette.accent,
            ),
          ),
        );
      }
      if (_flipMode && _isRevealed(index)) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            _board.cells[index].text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: HomePalette.text,
            ),
          ),
        );
      }
      return null;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        _flipMode ? l10n.bingoFlipPickHint : l10n.bingoPickHint,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.zenKakuGothicNew(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: HomePalette.textMuted,
        ),
      ),
    );
  }

  Widget _buildActionBar(AppLocalizations l10n) {
    final pickHint = _buildPickHint(l10n);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?pickHint,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: _hasJammer ? 3 : 1,
              child: Opacity(
                opacity: _canMark ? 1 : 0.45,
                child: AbsorbPointer(
                  absorbing: !_canMark,
                  child: HomePrimaryButton(
                    label: l10n.bingoMarkCell,
                    icon: Icons.check_rounded,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    onPressed: _markSelected,
                  ),
                ),
              ),
            ),
            if (_hasJammer) ...[
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _canJam ? _jamSelected : null,
                  icon: Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: _canJam
                        ? HomePalette.accentCoral
                        : HomePalette.textMuted,
                  ),
                  label: Text(
                    l10n.bingoJamThisCell,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.zenKakuGothicNew(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _canJam
                        ? HomePalette.accentCoral
                        : HomePalette.textMuted,
                    side: BorderSide(
                      color: _canJam
                          ? HomePalette.accentCoral.withValues(alpha: 0.6)
                          : HomePalette.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _advancePlayer,
                style: TextButton.styleFrom(
                  foregroundColor: HomePalette.text,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(l10n.nextPlayer),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _finish,
                style: TextButton.styleFrom(
                  foregroundColor: HomePalette.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(l10n.endSession),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showTimer = _timerService != null && _selectedIndex != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: HomeScaffold(
        title: l10n.bingoTitle,
        leading: HomeBackButton(onPressed: _handleBack),
        actions: const [
          ModeTipsHeaderButton(kind: ModeTipsKind.bingo),
        ],
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, viewport) {
              final contentWidth = min(viewport.maxWidth, 520.0);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    height: viewport.maxHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: PlayerIndicator(
                                  currentPlayerIndex: _currentPlayerIndex,
                                  totalPlayers: widget.config.playerCount,
                                  currentPlayerName: widget.config
                                      .getPlayerName(_currentPlayerIndex),
                                  useHomeStyle: true,
                                ),
                              ),
                            ),
                            if (showTimer) ...[
                              const SizedBox(width: 8),
                              TimerDisplay(
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
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildScoreRow(),
                        if (_showHintBanner) ...[
                          const SizedBox(height: 6),
                          _buildHotHint(l10n, compact: true),
                        ],
                        const SizedBox(height: 6),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, boardConstraints) {
                              final side = min(
                                boardConstraints.maxWidth,
                                boardConstraints.maxHeight,
                              );
                              if (side <= 0) {
                                return const SizedBox.shrink();
                              }
                              return Center(
                                child: SizedBox(
                                  width: side,
                                  height: side,
                                  child: BingoBoardWidget(
                                    board: _board,
                                    selectedIndex: _selectedIndex,
                                    flipMode: _flipMode,
                                    revealedIndices: _revealedIndices,
                                    hotCells:
                                        widget.config.bingoWinOnBlackout
                                            ? const {}
                                            : _board.hotCells,
                                    freeCenterIndex:
                                        widget.config.bingoFreeCenter
                                            ? _board.centerIndex
                                            : null,
                                    bonusIndex: _bonusIndex,
                                    blockedIndex: _blockedIndex,
                                    adjacentOnly:
                                        widget.config.bingoAdjacentOnly,
                                    onSelect: _selectCell,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildActionBar(l10n),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
