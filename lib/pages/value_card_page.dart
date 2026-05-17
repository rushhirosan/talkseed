import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../utils/preferences_helper.dart';
import '../utils/timer_feedback.dart';
import '../models/session_config.dart';
import '../models/game_session.dart';
import '../models/polyhedron_type.dart';
import '../models/value_game_state.dart';
import '../models/session_record.dart';
import '../services/session_record_service.dart';
import '../services/timer_service.dart';
import '../utils/route_transitions.dart';
import '../utils/session_end_dialog.dart';
import '../widgets/home/home_palette.dart';
import '../widgets/play/play_session_ui.dart';
import 'mode_selection_page.dart';

/// 価値観カード フルルールのゲーム画面
/// ファシリテーター持ち or 場に置いて、スマホを回さずにプレイ
/// sessionConfig ありのときはセッション設定済み（プレイヤー数・タイマー・名前を表示）
class ValueCardPage extends StatefulWidget {
  /// デッキのテーマ一覧（ローカライズ済み）
  final List<String> themes;
  /// セッション設定（参加人数・タイマー・プレイヤー名）。null のときは画面内で人数のみ選択
  final SessionConfig? sessionConfig;

  const ValueCardPage({
    super.key,
    required this.themes,
    this.sessionConfig,
  });

  @override
  State<ValueCardPage> createState() => _ValueCardPageState();
}

class _ValueCardPageState extends State<ValueCardPage> {
  ValueGameState? _gameState;
  int _playerCount = 4; // セットアップ用（sessionConfig が null のときのみ使用）

  /// セッション設定ありのときのセッション・タイマー（サイコロと同様のUI）
  GameSession? _session;
  TimerService? _timerService;

  /// プレイヤー切り替え時のバナー表示中（null = 非表示）
  int? _playerSwitchBannerPlayer;

  /// ランキング用の並べ替え可能な手札（needsToRank 時に使用）
  List<String>? _rankedCards;

  /// 手放すアニメーション表示中のカード文言（null = 非表示）
  String? _discardAnimationCard;

  /// 履歴を保存済みか（重複保存防止）
  bool _didSaveHistory = false;

  /// 終了ダイアログを表示済みか
  bool _didShowEndDialog = false;

  @override
  void initState() {
    super.initState();
    final config = widget.sessionConfig;
    if (config != null) {
      _playerCount = config.playerCount;
      var state = ValueGameLogic.createGame(widget.themes, config.playerCount);
      if (state.needsToDraw) {
        state = ValueGameLogic.drawCard(state);
      }
      _gameState = state;
      _session = GameSession(
        config: config,
        themes: {PolyhedronType.cube: widget.themes},
        isActive: true,
      );
      _session!.startSession();
      _session!.currentPlayerIndex = 0;
      if (config.enableTimer) {
        _timerService = TimerService(
          initialDuration: config.timerDuration,
          onTick: () => setState(() {}),
          onFinished: _onTimerFinished,
        );
        _timerService!.start();
      }
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

  Future<void> _triggerVibration() async {
    final enabled = await PreferencesHelper.loadVibrationEnabled();
    if (!enabled) return;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 80);
    }
  }

  void _startGame() {
    setState(() {
      var state = ValueGameLogic.createGame(widget.themes, _playerCount);
      if (state.needsToDraw) {
        state = ValueGameLogic.drawCard(state);
      }
      _gameState = state;
    });
  }

  void _onDrawCard() {
    if (_gameState == null || !_gameState!.needsToDraw) return;
    setState(() {
      _gameState = ValueGameLogic.drawCard(_gameState!);
    });
  }

  void _onConfirmRanking() {
    if (_gameState == null || !_gameState!.needsToRank || _rankedCards == null) {
      return;
    }
    if (_discardAnimationCard != null) return; // アニメーション中は無視

    final discardedCard = _rankedCards!.last;
    setState(() => _discardAnimationCard = discardedCard);
    _triggerVibration();
  }

  void _finishDiscardAndConfirm() {
    if (_gameState == null || _rankedCards == null) return;

    final prevPlayer = _gameState!.currentPlayerIndex;
    final prevRound = _gameState!.currentRound;

    setState(() {
      _gameState = ValueGameLogic.confirmRanking(_gameState!, _rankedCards!);
      _rankedCards = null;
      _discardAnimationCard = null;
    });

    if (prevRound >= 5 &&
        _gameState!.phase == ValuePhase.playing &&
        _gameState!.currentPlayerIndex != prevPlayer) {
      _showPlayerSwitchBanner(_gameState!.currentPlayerIndex);
      if (_session != null) {
        _session!.currentPlayerIndex = _gameState!.currentPlayerIndex;
        if (_session!.config.enableTimer && _timerService != null) {
          _timerService!.reset(_session!.config.timerDuration);
          _timerService!.start();
        }
      }
    }
  }

  void _onReorderRanking(int oldIndex, int newIndex) {
    if (_rankedCards == null) return;
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _rankedCards!.removeAt(oldIndex);
      _rankedCards!.insert(newIndex, item);
    });
  }

  void _showPlayerSwitchBanner(int playerIndex) {
    setState(() => _playerSwitchBannerPlayer = playerIndex);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _playerSwitchBannerPlayer = null);
      }
    });
  }

  void _onNextSharing() {
    if (_gameState == null || _gameState!.phase != ValuePhase.sharing) return;
    setState(() {
      _gameState = ValueGameLogic.nextSharingPlayer(_gameState!);
    });
    _triggerVibration();
    if (_gameState?.phase == ValuePhase.complete) {
      _saveValueCardRecord();
      _presentSessionEndDialog();
    }
  }

  void _presentSessionEndDialog() {
    if (_didShowEndDialog || !mounted) return;
    _didShowEndDialog = true;
    _saveValueCardRecord();
    SessionEndDialog.show(context);
  }

  void _goBackToHome() {
    // セッション中はセッション設定画面に戻る（push で開いているので pop）
    if (_session != null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  void _saveValueCardRecord() {
    if (_didSaveHistory || _gameState == null) return;
    final l10n = AppLocalizations.of(context)!;
    final playerCount = _gameState!.playerCount;
    final hands = _gameState!.hands;
    final names = widget.sessionConfig?.playerNames;
    final selectedCardsByPlayer = <String, List<String>>{};
    for (var i = 0; i < playerCount; i++) {
      final customName =
          (names != null && i < names.length && names[i].trim().isNotEmpty)
              ? names[i].trim()
              : null;
      final label = customName ?? l10n.playerName(i + 1);
      selectedCardsByPlayer[label] = List<String>.from(hands[i] ?? []);
    }
    final record = SessionRecord.create(
      mode: 'value_cards',
      topics: const [],
      selectedCardsByPlayer: selectedCardsByPlayer,
      playerCount: playerCount,
      playerNames: selectedCardsByPlayer.keys.toList(),
    );
    _didSaveHistory = true;
    SessionRecordService.addRecord(record);
  }

  /// セッション設定ありのときは設定画面で人数を決めているためセットアップ画面をスキップ
  bool get _hasSessionConfig => widget.sessionConfig != null;

  /// カード画面用の表示名（カスタム名があればそれ、なければ「プレイヤーn」）
  String _playerDisplayLabel(AppLocalizations l10n, int index) {
    final config = widget.sessionConfig;
    if (config != null) {
      final name = config.getPlayerName(index);
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }
    return l10n.playerName(index + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PlaySessionScaffold(
      title: l10n.deckTeamBuilding,
      onBack: _goBackToHome,
      backTooltip: l10n.backToSettings,
      body: _gameState == null && !_hasSessionConfig
          ? _buildSetup(l10n)
          : _buildGameScroll(l10n),
    );
  }

  List<Widget> _sessionHeaderWidgets(AppLocalizations l10n, ValueGameState state) {
    if (_session == null) return [];
    return [
      PlayPlayerBanner(
        currentPlayerIndex: _session!.currentPlayerIndex,
        totalPlayers: _session!.config.playerCount,
        currentPlayerName: _session!.currentPlayerName,
      ),
      if (_session!.config.enableTimer && _timerService != null) ...[
        const SizedBox(height: 8),
        PlayTimerPanel(
          timerService: _timerService!,
          onPause: () => setState(() => _timerService!.pause()),
          onResume: () => setState(() => _timerService!.resume()),
          onExtendOneMinute: _extendTimerOneMinute,
        ),
      ],
      const SizedBox(height: 12),
    ];
  }

  Widget _buildSetup(AppLocalizations l10n) {
    return PlayPageScroll(
      children: [
        const SizedBox(height: 48),
        Text(
          l10n.valuePlayerCount,
          style: PlayTextStyles.sectionTitle(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: _playerCount > 2
                  ? () => setState(() => _playerCount--)
                  : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: _playerCount > 2
                    ? HomePalette.surface2
                    : HomePalette.surface2.withValues(alpha: 0.4),
                foregroundColor: HomePalette.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$_playerCount',
                style: PlayTextStyles.sectionTitle().copyWith(fontSize: 48),
              ),
            ),
            IconButton.filled(
              onPressed: _playerCount < 10
                  ? () => setState(() => _playerCount++)
                  : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: _playerCount < 10
                    ? HomePalette.surface2
                    : HomePalette.surface2.withValues(alpha: 0.4),
                foregroundColor: HomePalette.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        PlayPrimaryButton(
          label: l10n.valueStart,
          icon: Icons.play_arrow,
          onPressed: _startGame,
        ),
      ],
    );
  }

  Widget _buildGameScroll(AppLocalizations l10n) {
    final state = _gameState!;
    if (_session != null) {
      _session!.currentPlayerIndex = state.currentPlayerIndex;
    }

    if (state.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _presentSessionEndDialog();
      });
      return PlayPageScroll(
        children: [
          ..._sessionHeaderWidgets(l10n, state),
          const SizedBox(height: 48),
        ],
      );
    }
    if (state.isSharing) {
      return PlayPageScroll(
        children: [
          ..._sessionHeaderWidgets(l10n, state),
          ..._sharingContent(l10n, state),
        ],
      );
    }
    return _buildPlayingScroll(l10n, state);
  }

  Widget _buildPlayingScroll(AppLocalizations l10n, ValueGameState state) {
    final hand = state.hands[state.currentPlayerIndex] ?? [];
    final showTurnBanner = _session == null;

    // 引く必要がある場合は自動で1枚引く
    if (state.needsToDraw) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _gameState?.needsToDraw == true) {
          _onDrawCard();
        }
      });
    }

    // ランキング用のローカルリストを初期化（6枚になったら）
    if (state.needsToRank && hand.length == 6) {
      _rankedCards ??= List<String>.from(hand);
    }

    final scrollChildren = <Widget>[
      ..._sessionHeaderWidgets(l10n, state),
      if (showTurnBanner) ...[
        PlayPlayerBanner(
          currentPlayerIndex: state.currentPlayerIndex,
          totalPlayers: state.playerCount,
          currentPlayerName: _playerDisplayLabel(
            l10n,
            state.currentPlayerIndex,
          ),
        ),
        const SizedBox(height: 8),
      ],
      Text(
        l10n.valueRound(state.currentRound),
        textAlign: TextAlign.center,
        style: PlayTextStyles.caption(0.7),
      ),
      const SizedBox(height: 12),
      if (state.needsToRank && _rankedCards != null) ...[
        Text(
          l10n.valueRankPrompt,
          textAlign: TextAlign.center,
          style: PlayTextStyles.bodyEmphasis(),
        ),
        const SizedBox(height: 10),
        RepaintBoundary(
          child: _buildRankingList(_rankedCards!, l10n.valueDiscardLabel),
        ),
        const SizedBox(height: 16),
        PlayPrimaryButton(
          label: l10n.valueConfirmRanking,
          icon: Icons.check,
          onPressed: _onConfirmRanking,
        ),
      ],
      if (state.needsToDraw) ...[
        const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: HomePalette.accent),
          ),
        ),
        Text(
          l10n.valueDrawCard,
          textAlign: TextAlign.center,
          style: PlayTextStyles.hint(0.7),
        ),
      ],
    ];

    return Stack(
      children: [
        PlayPageScroll(children: scrollChildren),
        if (_playerSwitchBannerPlayer != null)
          _PlayerSwitchBanner(
            message: l10n.valuePlayerTurn(
              _playerDisplayLabel(l10n, _playerSwitchBannerPlayer!),
            ),
          ),
        if (_discardAnimationCard != null)
          _DiscardCardOverlay(
            cardText: _discardAnimationCard!,
            discardLabel: l10n.valueDiscardLabel,
            onAnimationComplete: _finishDiscardAndConfirm,
          ),
      ],
    );
  }

  Widget _buildRankingList(List<String> cards, String discardLabel) {
    // 各カード約56px+余白6、semantics エラー回避のため明示的な高さを指定
    const itemHeight = 68.0;
    final listHeight = cards.length * itemHeight;
    return SizedBox(
      height: listHeight,
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: cards.length,
        onReorder: _onReorderRanking,
        itemBuilder: (context, index) {
          final rank = index + 1;
          final isLast = index == cards.length - 1;
          return PlayReorderListTile(
            key: ValueKey('${cards[index]}-$index'),
            index: index,
            rank: rank,
            text: cards[index],
            isLast: isLast,
            trailingLabel: isLast ? discardLabel : null,
          );
        },
      ),
    );
  }

  Widget _buildCardGrid(List<String> cards, {void Function(int)? onTap, bool compact = false}) {
    final spacing = compact ? 8.0 : 12.0;
    const columns = 2;
    final width = MediaQuery.sizeOf(context).width -
        playScreenHorizontalPadding * 2;
    final cardWidth = (width - spacing * (columns - 1)) / columns;
    final cardHeight = cardWidth * (compact ? 0.58 : 0.7);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        return SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: _ValueCard(
            key: ValueKey('$index-$card'),
            text: card,
            onTap: onTap != null ? () => onTap(index) : null,
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _sharingContent(AppLocalizations l10n, ValueGameState state) {
    final playerIndex = state.sharingPlayerIndex;
    final hand = state.hands[playerIndex] ?? [];

    return [
      PlayPlayerBanner(
        currentPlayerIndex: playerIndex,
        totalPlayers: state.playerCount,
        currentPlayerName: _playerDisplayLabel(l10n, playerIndex),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.valueSharePrompt,
        textAlign: TextAlign.center,
        style: PlayTextStyles.bodyEmphasis(),
      ),
      const SizedBox(height: 12),
      _buildCardGrid(hand, compact: true),
      const SizedBox(height: 16),
      PlayPrimaryButton(
        label: playerIndex < state.playerCount - 1
            ? l10n.valueNext
            : l10n.valueSessionCompleteAndBack,
        icon: playerIndex < state.playerCount - 1
            ? Icons.arrow_forward
            : Icons.check_circle,
        onPressed: () {
          if (playerIndex < state.playerCount - 1) {
            _onNextSharing();
          } else {
            _onNextSharing();
          }
        },
      ),
    ];
  }

}

/// 手放したカードを表示するオーバーレイ（アニメーション付き）
class _DiscardCardOverlay extends StatefulWidget {
  final String cardText;
  final String discardLabel;
  final VoidCallback onAnimationComplete;

  const _DiscardCardOverlay({
    required this.cardText,
    required this.discardLabel,
    required this.onAnimationComplete,
  });

  @override
  State<_DiscardCardOverlay> createState() => _DiscardCardOverlayState();
}

class _DiscardCardOverlayState extends State<_DiscardCardOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.8),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: HomePalette.bg.withValues(alpha: 0.72),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment.center,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                ),
              ),
            );
          },
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HomePalette.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HomePalette.border),
                  boxShadow: [
                    BoxShadow(
                      color: HomePalette.accent.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: HomePalette.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HomePalette.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_circle_outline,
                            size: 18,
                            color: HomePalette.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.discardLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: HomePalette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.cardText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HomePalette.text,
                        height: 1.3,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// プレイヤー切り替え時に表示するバナー
class _PlayerSwitchBanner extends StatefulWidget {
  final String message;

  const _PlayerSwitchBanner({
    required this.message,
  });

  @override
  State<_PlayerSwitchBanner> createState() => _PlayerSwitchBannerState();
}

class _PlayerSwitchBannerState extends State<_PlayerSwitchBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            color: HomePalette.bg.withValues(alpha: 0.72),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                gradient: HomePalette.accentGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: HomePalette.accent.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: HomePalette.bg, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: HomePalette.bg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 価値観カード（タップ可能・不可の両方）
class _ValueCard extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _ValueCard({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: PlaySurfaceCard(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: PlayTextStyles.listItem(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
