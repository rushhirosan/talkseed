import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/theme.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/models/game_session.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/utils/dice_3d_utils.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/widgets/dice_widget.dart';
import 'package:theme_dice/widgets/theme_display.dart';
import 'package:theme_dice/widgets/timer_display.dart';
import 'package:theme_dice/widgets/player_indicator.dart';
import 'package:theme_dice/pages/initial_settings_page.dart';
import 'package:theme_dice/pages/session_setup_page.dart';
import 'package:theme_dice/services/session_record_service.dart';

/// サイコロゲームのメインページ。
/// 3Dサイコロのアニメーション、テーマ表示、セッション（複数プレイヤー・タイマー）を担当。
class DicePage extends StatefulWidget {
  final PolyhedronType? initialType;
  final Map<PolyhedronType, List<String>>? initialThemes;
  final SessionConfig? sessionConfig;

  const DicePage({
    super.key,
    this.initialType,
    this.initialThemes,
    this.sessionConfig,
  });

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedTheme;
  int? _selectedFaceNumber;
  final Random _random = Random();

  // 多面体タイプとテーマの管理
  late PolyhedronType _selectedPolyhedronType;
  Map<PolyhedronType, List<String>>? _themes;

  // セッション管理（新規追加）
  GameSession? _session;
  TimerService? _timerService;
  /// 全員振り終えた後に表示する振り返り画面を表示中か
  bool _showingSessionSummary = false;

  @override
  void initState() {
    super.initState();
    // 現在は正六面体のみをサポート（常にcubeを使用）
    _selectedPolyhedronType = PolyhedronType.cube;
    // 初期設定画面からテーマを取得（デフォルト値はbuild内で設定）
    if (widget.initialThemes != null && widget.initialThemes!.containsKey(PolyhedronType.cube)) {
      _themes = {PolyhedronType.cube: widget.initialThemes![PolyhedronType.cube]!};
    }

    _initializeAnimationController();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isRollingFromBack) {
          // サイコロが奥から手前に移動した後、回転アニメーションを開始
          _isRollingFromBack = false;
          _startRotationAnimation();
        } else {
          // 回転アニメーションが終了したら、ランダムな面を表示
          // 回転は既に正面を向いているので、テーマを表示するだけ
          _selectRandomFace();
        }
      }
    });

    // セッション設定があれば初期化
    if (widget.sessionConfig != null) {
      _initializeSession(widget.sessionConfig!);
    }
  }

  /// セッションを初期化
  void _initializeSession(SessionConfig config) {
    setState(() {
      _session = GameSession(
        config: config,
        themes: widget.initialThemes ?? {},
        isActive: true,
      );
      _session!.startSession();

      if (config.enableTimer) {
        _timerService = TimerService(
          initialDuration: config.timerDuration,
          onTick: () => setState(() {}),
          onFinished: () {
            _onTimerFinished();
          },
        );
      }
    });
  }

  /// タイマー終了時の処理
  void _onTimerFinished() {
    _triggerVibration();
    // タイマー終了を通知（必要に応じてダイアログ表示など）
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000), // 奥から手前への移動時間
      vsync: this,
    );
  }

  // 回転アニメーション用
  double _startRotationX = 0.0;
  double _startRotationY = 0.0;
  double _startRotationZ = 0.0;
  double _endRotationX = 0.0;
  double _endRotationY = 0.0;
  double _endRotationZ = 0.0;

  bool _isDiceVisible = false; // サイコロが表示されているか
  bool _isRollingFromBack = false; // 奥から手前への移動アニメーション中かどうか

  @override
  void dispose() {
    _animationController.dispose();
    _timerService?.dispose();
    super.dispose();
  }

  // ============================================
  // サイコロを振るボタンの処理
  // ============================================
  /// 「サイコロを振る」ボタンをクリックした時の処理
  void _rollDice() {
    // 状態をリセット
    setState(() {
      _isDiceVisible = false;
      _isRollingFromBack = true;
      _selectedTheme = null;
      _selectedFaceNumber = null;

      // 回転値をリセット
      _startRotationX = 0.0;
      _startRotationY = 0.0;
      _startRotationZ = 0.0;
      _endRotationX = 0.0;
      _endRotationY = 0.0;
      _endRotationZ = 0.0;
    });

    // 触覚フィードバック
    _triggerVibration();

    // サイコロが奥から手前に転がってくるアニメーションを開始
    _startRollingFromBack();
  }

  // ============================================
  // サイコロが奥から手前に転がってくる
  // ============================================
  /// サイコロが画面の奥から手前に転がってくるアニメーション
  void _startRollingFromBack() {
    // ランダムな面を選ぶ
    final faceCount = _selectedPolyhedronType.faceCount;
    final randomFaceNumber = _random.nextInt(faceCount) + 1;
    _selectedFaceNumber = randomFaceNumber;

    setState(() {
      // サイコロを表示
      _isDiceVisible = true;

      // 回転アニメーション用の値を設定
      // 奥から手前に移動しながら、複数回転させる（最終的な回転値は後で設定）
      _startRotationX = 0.0;
      _startRotationY = 0.0;
      _startRotationZ = 0.0;
      // 移動中は複数回転させるが、最終的な回転値は後で正確に設定する
      _endRotationX = 6 * pi; // 移動中は回転させるだけ
      _endRotationY = 6 * pi;
      _endRotationZ = 6 * pi;
    });

    // アニメーション時間を設定（奥から手前への移動時間）
    _animationController.duration = const Duration(milliseconds: 3000);
    _animationController.reset();
    _animationController.forward();
  }

  // ============================================
  // サイコロが回転する
  // ============================================
  /// 正六面体の各面を正面に向ける回転値を取得
  /// 現在は正六面体のみをサポートしています
  /// 正四面体・正八面体の回転値は将来的に実装予定
  Map<int, Map<String, double>> _getBaseRotations() {
    // 正六面体（立方体）の各面を正面に向ける回転値
    return {
      1: {'x': 0.0, 'y': 0.0, 'z': 0.0},     // 前面
      2: {'x': -pi / 2, 'y': 0.0, 'z': 0.0}, // 下面
      3: {'x': 0.0, 'y': pi / 2, 'z': 0.0},  // 右面
      4: {'x': 0.0, 'y': -pi / 2, 'z': 0.0}, // 左面
      5: {'x': pi / 2, 'y': 0.0, 'z': 0.0},  // 上面
      6: {'x': 0.0, 'y': pi, 'z': 0.0},      // 後面
    };
  }

  /// サイコロが回転するアニメーションを開始
  /// 回転終了後は選んだ面が正面を向くようにする
  void _startRotationAnimation() {
    // 最終的な回転値を計算（選んだ面が正面を向くように）
    // 追加のランダム回転なしで、正確に正面を向く
    final baseRotations = _getBaseRotations();

    final targetRotation = baseRotations[_selectedFaceNumber!] ?? baseRotations[baseRotations.keys.first]!;

    setState(() {
      _isDiceVisible = true;

      // 回転アニメーション用の値を設定
      // 現在の回転状態（移動中の回転）から開始
      _startRotationX = _endRotationX;
      _startRotationY = _endRotationY;
      _startRotationZ = _endRotationZ;

      // 最終的な回転値：選んだ面が正面を向くように正確に設定
      // 現在の回転値に、目標回転値への差分を加える（2πの倍数を考慮）
      final targetRotX = targetRotation['x'] as double;
      final targetRotY = targetRotation['y'] as double;
      final targetRotZ = targetRotation['z'] as double;

      // 現在の回転値を0-2πの範囲に正規化
      final currentRotX = _endRotationX % (2 * pi);
      final currentRotY = _endRotationY % (2 * pi);
      final currentRotZ = _endRotationZ % (2 * pi);

      // 目標回転値への差分を計算（最短経路）
      double diffX = targetRotX - currentRotX;
      double diffY = targetRotY - currentRotY;
      double diffZ = targetRotZ - currentRotZ;

      // -πからπの範囲に正規化
      if (diffX > pi) diffX -= 2 * pi;
      if (diffX < -pi) diffX += 2 * pi;
      if (diffY > pi) diffY -= 2 * pi;
      if (diffY < -pi) diffY += 2 * pi;
      if (diffZ > pi) diffZ -= 2 * pi;
      if (diffZ < -pi) diffZ += 2 * pi;

      // 最終的な回転値を設定（現在の値に差分を加える）
      _endRotationX = _endRotationX + diffX;
      _endRotationY = _endRotationY + diffY;
      _endRotationZ = _endRotationZ + diffZ;
    });

    // 回転アニメーション時間を設定
    _animationController.duration = const Duration(milliseconds: 2500);
    _animationController.reset();
    _animationController.forward();
  }

  // ============================================
  // ランダムな面が出る
  // ============================================
  /// 回転終了後に選ばれたランダムな面を表示する処理
  /// 回転は既に正面を向いているので、テーマを表示するだけ
  /// 自動的にアニメーションを継続しない
  void _selectRandomFace() {
    if (_selectedFaceNumber == null) return;

    // 面の番号からテーマを取得
    final l10n = AppLocalizations.of(context)!;
    final themes = ThemeModel.getThemesForType(_selectedPolyhedronType, _themes ?? {}, l10n);
    final theme = ThemeModel.getThemeByFaceNumber(_selectedFaceNumber!, themes);

    // 最終的な回転値を正確に設定（選んだ面が正面を向くように）
    final baseRotations = _getBaseRotations();

    final targetRotation = baseRotations[_selectedFaceNumber!] ?? baseRotations[baseRotations.keys.first]!;

    setState(() {
      _selectedTheme = theme;
      // 回転値を正確に設定（選んだ面が正面を向くように）
      _endRotationX = targetRotation['x'] as double;
      _endRotationY = targetRotation['y'] as double;
      _endRotationZ = targetRotation['z'] as double;
      _startRotationX = _endRotationX;
      _startRotationY = _endRotationY;
      _startRotationZ = _endRotationZ;
    });

    // セッションがある場合は結果を記録
    if (_session != null && _selectedTheme != null) {
      _session!.addRoundResult(_selectedTheme!);
      // タイマーを開始（有効な場合）
      if (_session!.config.enableTimer && _timerService != null) {
        _timerService!.reset(_session!.config.timerDuration);
        _timerService!.start();
      }
    }
    if (_session == null && _selectedTheme != null) {
      _saveDiceRecord(
        topics: [_selectedTheme!],
        playerCount: 1,
      );
    }

    // 成功時の演出
    _triggerVibration();

    // アニメーションをリセット（自動継続しない）
    _animationController.reset();
  }

  /// 次のプレイヤーに進む（最後のプレイヤーの場合はセッション終了）
  void _nextPlayer() {
    if (_session == null) return;

    final wasLastPlayer = _session!.isLastPlayer;

    setState(() {
      _session!.nextPlayer();
      _selectedTheme = null;
      _selectedFaceNumber = null;

      // タイマーをリセット
      if (_timerService != null) {
        _timerService!.stop();
        if (_session?.config.enableTimer == true) {
          _timerService!.reset(_session!.config.timerDuration);
        }
      }
    });

    // 最後のプレイヤーが終わってセッション終了したら振り返り画面を表示
    if (wasLastPlayer && _session != null && !_session!.isActive) {
      setState(() => _showingSessionSummary = true);
    }
  }

  /// 振り返り画面で「セッションを終了」を押したときの処理
  void _onSessionSummaryEnd() {
    final l10n = AppLocalizations.of(context)!;
    if (_session != null) {
      _saveDiceRecord(
        topics: _session!.rounds.map((e) => e.theme).toList(),
        playerCount: _session!.config.playerCount,
      );
    }
    setState(() => _showingSessionSummary = false);
    if (widget.sessionConfig != null) {
      final themes = _themes ?? widget.initialThemes ?? {
        PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n),
      };
      Navigator.of(context).pushReplacement(
        RouteTransitions.backRoute(
          page: SessionSetupPage(themes: themes, fromDicePage: true),
        ),
      );
    } else {
      setState(() => _session = null);
    }
  }

  void _saveDiceRecord({
    required List<String> topics,
    required int? playerCount,
  }) {
    final record = SessionRecord.create(
      mode: 'dice',
      topics: topics,
      selectedCardsByPlayer: {},
      playerCount: playerCount,
    );
    SessionRecordService.addRecord(record);
  }

  /// セッション振り返り画面の本文を構築
  Widget _buildSessionSummaryBody(AppLocalizations l10n) {
    final rounds = _session!.rounds;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              l10n.sessionSummaryScreenTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _black.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ...rounds.map((result) {
              final playerLabel = result.playerName?.isNotEmpty == true
                  ? result.playerName!
                  : l10n.playerName(result.playerIndex + 1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _black.withOpacity(0.3), width: 1),
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
                        l10n.sessionSummaryPlayerTheme(playerLabel),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.theme,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onSessionSummaryEnd,
                icon: const Icon(Icons.check_circle, color: _black),
                label: Text(
                  l10n.sessionEndButton,
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
      ),
    );
  }

  /// セッション終了ダイアログを表示
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
              Navigator.of(context).pop(); // ダイアログを閉じる
              if (widget.sessionConfig != null) {
                // セッション設定画面から来た場合はセッション設定画面に戻る
                final themes = _themes ?? widget.initialThemes ?? {
                  PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n),
                };
                Navigator.of(context).pushReplacement(
                  RouteTransitions.backRoute(
                    page: SessionSetupPage(themes: themes, fromDicePage: true),
                  ),
                );
              } else {
                setState(() => _session = null);
              }
            },
            child: Text(l10n.newSession),
          ),
        ],
      ),
    );
  }

  /// タイマーを一時停止/再開
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

  // ============================================
  // 補助関数
  // ============================================
  /// 触覚フィードバックをトリガー
  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  /// 設定画面に戻る（セッション開始からの場合はセッション設定画面へ）
  void _goBackToSettings() {
    final themes = _themes ?? widget.initialThemes ?? {
      PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube, AppLocalizations.of(context)!),
    };
    if (widget.sessionConfig != null) {
      // セッション設定画面から来た場合はセッション設定画面に戻る（戻るトランジション）
      Navigator.of(context).pushReplacement(
        RouteTransitions.backRoute(
          page: SessionSetupPage(themes: themes, fromDicePage: true),
        ),
      );
    } else {
      // テーマ設定画面から来た場合はテーマ設定画面に戻る（戻るトランジション）
      Navigator.of(context).pushReplacement(
        RouteTransitions.backRoute(
          page: const InitialSettingsPage(),
        ),
      );
    }
  }

  // デザインカラーパレット（設定画面と統一）
  static const Color _mustardYellow = Color(0xFFFFEB3B); // マスタードイエロー
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const Color _lightYellow = Color(0xFFFFFDE7); // 非常に薄い黄色の背景

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // テーマが初期化されていない場合はデフォルト値を設定
    _themes ??= {PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n)};
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
      body: _showingSessionSummary && _session != null
          ? _buildSessionSummaryBody(l10n)
          : SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // プレイヤー表示（セッション中の場合）
              if (_session != null) ...[
                PlayerIndicator(
                  currentPlayerIndex: _session!.currentPlayerIndex,
                  totalPlayers: _session!.config.playerCount,
                  currentPlayerName: _session!.currentPlayerName,
                ),
                const SizedBox(height: 10),
              ],

              // タイマー表示（セッション中でタイマー有効の場合）
              if (_session != null && _session!.config.enableTimer && _timerService != null) ...[
                TimerDisplay(
                  timerService: _timerService,
                  onPause: _toggleTimer,
                  onResume: _toggleTimer,
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 12),

              // サイコロ表示エリア（アニメーション付き）
              // diceDisplaySize を使用し回転時に角が切れない十分な領域を確保
              SizedBox(
                width: Dice3DUtils.diceDisplaySize + 40,
                height: Dice3DUtils.diceDisplaySize + 40,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      // _themesが変更されたときにも再構築されるようにする
                      final l10n = AppLocalizations.of(context)!;
                      final currentThemes = ThemeModel.getThemesForType(_selectedPolyhedronType, _themes ?? {}, l10n);

                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          if (!_isDiceVisible) {
                            return const SizedBox.shrink();
                          }

                          final progress = _animationController.value;
                          final curveValue = Curves.easeOutCubic.transform(progress);

                          // 回転値の補間
                          final currentX = _startRotationX + (_endRotationX - _startRotationX) * curveValue;
                          final currentY = _startRotationY + (_endRotationY - _startRotationY) * curveValue;
                          final currentZ = _startRotationZ + (_endRotationZ - _startRotationZ) * curveValue;

                          return DiceWidget(
                            rotX: currentX,
                            rotY: currentY,
                            rotZ: currentZ,
                            polyhedronType: _selectedPolyhedronType,
                            themes: currentThemes,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // 「サイコロを振る」ボタン（設定画面のスタイルに統一）
              ElevatedButton.icon(
                onPressed: _rollDice,
                icon: const Icon(Icons.casino, color: _black),
                label: Text(
                  l10n.rollDice,
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

              const SizedBox(height: 20),

              // 選択されたテーマを表示
              ThemeDisplay(selectedTheme: _selectedTheme),

              const SizedBox(height: 16),

              // セッション中の場合、次のプレイヤー／セッション終了ボタンを表示
              if (_session != null && _selectedTheme != null) ...[
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
              // 画面下部に余白を確保（セーフエリア＋追加マージン）
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
