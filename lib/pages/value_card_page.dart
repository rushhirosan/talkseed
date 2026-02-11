import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/value_game_state.dart';
import '../utils/route_transitions.dart';
import 'mode_selection_page.dart';

/// 価値観カード フルルールのゲーム画面
/// ファシリテーター持ち or 場に置いて、スマホを回さずにプレイ
class ValueCardPage extends StatefulWidget {
  /// デッキのテーマ一覧（ローカライズ済み）
  final List<String> themes;

  const ValueCardPage({
    super.key,
    required this.themes,
  });

  @override
  State<ValueCardPage> createState() => _ValueCardPageState();
}

class _ValueCardPageState extends State<ValueCardPage> {
  ValueGameState? _gameState;
  int _playerCount = 4; // セットアップ用

  /// プレイヤー切り替え時のバナー表示中（null = 非表示）
  int? _playerSwitchBannerPlayer;

  /// ランキング用の並べ替え可能な手札（needsToRank 時に使用）
  List<String>? _rankedCards;

  static const Color _mustardYellow = Color(0xFFFFEB3B);
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _lightYellow = Color(0xFFFFFDE7);

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 80);
    }
  }

  void _startGame() {
    setState(() {
      _gameState = ValueGameLogic.createGame(widget.themes, _playerCount);
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
    final prevPlayer = _gameState!.currentPlayerIndex;
    final prevRound = _gameState!.currentRound;

    setState(() {
      _gameState = ValueGameLogic.confirmRanking(_gameState!, _rankedCards!);
      _rankedCards = null;
    });
    _triggerVibration();

    if (prevRound >= 5 &&
        _gameState!.phase == ValuePhase.playing &&
        _gameState!.currentPlayerIndex != prevPlayer) {
      _showPlayerSwitchBanner(_gameState!.currentPlayerIndex);
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
  }

  void _goBackToHome() {
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _lightYellow,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: _goBackToHome,
          tooltip: l10n.valueBackToDeck,
        ),
        title: Text(
          l10n.deckTeamBuilding,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: _gameState == null ? _buildSetup(l10n) : _buildGame(l10n),
      ),
    );
  }

  Widget _buildSetup(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.valuePlayerCount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _black,
            ),
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
                  backgroundColor: _playerCount > 2 ? _black : _black.withOpacity(0.3),
                  foregroundColor: _white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_playerCount',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _black,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: _playerCount < 10
                    ? () => setState(() => _playerCount++)
                    : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: _playerCount < 10 ? _black : _black.withOpacity(0.3),
                  foregroundColor: _white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow, color: _black),
              label: Text(
                l10n.valueStart,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mustardYellow,
                foregroundColor: _black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame(AppLocalizations l10n) {
    final state = _gameState!;

    if (state.isComplete) {
      return _buildComplete(l10n);
    }

    if (state.isSharing) {
      return _buildSharing(l10n, state);
    }

    return _buildPlaying(l10n, state);
  }

  Widget _buildPlaying(AppLocalizations l10n, ValueGameState state) {
    final hand = state.hands[state.currentPlayerIndex] ?? [];
    final playerLabel = state.currentPlayerIndex + 1;

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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _black, width: 1.5),
                ),
                child: Text(
                  l10n.valuePlayerTurn(playerLabel),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.valueRound(state.currentRound),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              if (state.needsToRank && _rankedCards != null) ...[
                Text(
                  l10n.valueRankPrompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: _black.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _buildRankingList(_rankedCards!, l10n.valueDiscardLabel),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onConfirmRanking,
                    icon: const Icon(Icons.check, color: _black),
                    label: Text(
                      l10n.valueConfirmRanking,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mustardYellow,
                      foregroundColor: _black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
              if (state.needsToDraw) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: _black),
                  ),
                ),
                Text(
                  l10n.valueDrawCard,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _black.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_playerSwitchBannerPlayer != null)
          _PlayerSwitchBanner(
            playerLabel: _playerSwitchBannerPlayer! + 1,
            message: l10n.valuePlayerTurn(_playerSwitchBannerPlayer! + 1),
          ),
      ],
    );
  }

  Widget _buildRankingList(List<String> cards, String discardLabel) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: cards.length,
      onReorder: _onReorderRanking,
      itemBuilder: (context, index) {
        final rank = index + 1;
        final isLast = index == cards.length - 1;
        return _RankableCard(
          key: ValueKey('${cards[index]}-$index'),
          text: cards[index],
          rank: rank,
          index: index,
          isLast: isLast,
          discardLabel: discardLabel,
        );
      },
    );
  }

  Widget _buildCardGrid(List<String> cards, {void Function(int)? onTap}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const columns = 2;
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            return SizedBox(
              width: cardWidth,
              height: cardWidth * 0.7,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _ValueCard(
                  key: ValueKey('$index-$card'),
                  text: card,
                  onTap: onTap != null ? () => onTap(index) : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSharing(AppLocalizations l10n, ValueGameState state) {
    final playerIndex = state.sharingPlayerIndex;
    final hand = state.hands[playerIndex] ?? [];
    final playerLabel = playerIndex + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _black, width: 1.5),
            ),
            child: Text(
              l10n.valuePlayerFinalCards(playerLabel),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.valueSharePrompt,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _black.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _buildCardGrid(hand),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onNextSharing,
              icon: Icon(
                playerIndex < state.playerCount - 1
                    ? Icons.arrow_forward
                    : Icons.check_circle,
                color: _black,
              ),
              label: Text(
                playerIndex < state.playerCount - 1
                    ? l10n.valueNext
                    : l10n.valueGameComplete,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _mustardYellow,
                foregroundColor: _black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplete(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 64, color: _black),
            const SizedBox(height: 24),
            Text(
              l10n.valueGameComplete,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _black,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _goBackToHome,
                icon: const Icon(Icons.arrow_back, color: _black),
                label: Text(
                  l10n.valueBackToDeck,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// プレイヤー切り替え時に表示するバナー
class _PlayerSwitchBanner extends StatefulWidget {
  final int playerLabel;
  final String message;

  const _PlayerSwitchBanner({
    required this.playerLabel,
    required this.message,
  });

  @override
  State<_PlayerSwitchBanner> createState() => _PlayerSwitchBannerState();
}

class _PlayerSwitchBannerState extends State<_PlayerSwitchBanner>
    with SingleTickerProviderStateMixin {
  static const Color _mustardYellow = Color(0xFFFFEB3B);
  static const Color _black = Colors.black87;

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
            color: _black.withOpacity(0.4),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                color: _mustardYellow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: _black, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _black,
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

/// ランキング用カード（ドラッグで並べ替え可能）
class _RankableCard extends StatelessWidget {
  final String text;
  final int rank;
  final int index;
  final bool isLast;
  final String discardLabel;

  const _RankableCard({
    super.key,
    required this.text,
    required this.rank,
    required this.index,
    required this.isLast,
    required this.discardLabel,
  });

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLast ? _black.withOpacity(0.5) : _black,
          width: isLast ? 1 : 1.5,
        ),
      ),
      color: _white,
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.drag_handle, color: _black, size: 24),
          ),
        ),
        title: Text(
          '$rank. $text',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _black,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isLast
            ? Text(
                discardLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: _black.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
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

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _black,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
