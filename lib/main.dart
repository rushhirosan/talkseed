import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';
import 'models/theme.dart';
import 'utils/dice_3d_utils.dart';
import 'widgets/dice_widget.dart';
import 'widgets/theme_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Dice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DicePage(),
    );
  }
}

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedTheme;
  int? _selectedFaceNumber;
  final Random _random = Random();
  
  // 回転アニメーション用
  double _startRotationX = 0.0;
  double _startRotationY = 0.0;
  double _startRotationZ = 0.0;
  double _endRotationX = 0.0;
  double _endRotationY = 0.0;
  double _endRotationZ = 0.0;
  
  // Z座標（深度）アニメーション用
  // 初期値は画面の奥（大きい値）、手前は0に近い値
  double _startZ = 1000.0; // 画面の奥
  double _endZ = 0.0; // 手前
  double _currentZ = 1000.0; // 現在のZ座標
  
  bool _isAligningToFront = false;
  bool _isDiceVisible = false; // サイコロが表示されているか
  bool _isRollingFromBack = false; // 奥から手前への移動アニメーション中かどうか

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 奥から手前への移動時間
      vsync: this,
    );
    

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
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      _isAligningToFront = false;
      
      // サイコロを画面の奥に配置
      _startZ = 1000.0;
      _endZ = 0.0;
      _currentZ = 1000.0;
      
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
    final randomFaceNumber = _random.nextInt(6) + 1;
    _selectedFaceNumber = randomFaceNumber;
    
    // 回転アニメーション用の値を設定
    // 奥から手前に移動しながら、複数回転させる（最終的な回転値は後で設定）
    _startRotationX = 0.0;
    _startRotationY = 0.0;
    _startRotationZ = 0.0;
    // 移動中は複数回転させるが、最終的な回転値は後で正確に設定する
    _endRotationX = 6 * pi; // 移動中は回転させるだけ
    _endRotationY = 6 * pi;
    _endRotationZ = 6 * pi;
    
    // Z座標アニメーション：奥から手前へ
    _startZ = 1000.0;
    _endZ = 0.0;
    _currentZ = 1000.0; // 初期値を確実に設定
    
    // アニメーション時間を設定（奥から手前への移動時間）
    _animationController.duration = const Duration(milliseconds: 2000);
    _animationController.reset();
    _animationController.forward();
  }
  
  // ============================================
  // サイコロが回転する
  // ============================================
  /// サイコロが回転するアニメーションを開始
  /// 回転終了後は選んだ面が正面を向くようにする
  void _startRotationAnimation() {
    // 最終的な回転値を計算（選んだ面が正面を向くように）
    // 追加のランダム回転なしで、正確に正面を向く
    final baseRotations = {
      1: {'x': 0.0, 'y': 0.0, 'z': 0.0},
      2: {'x': pi / 2, 'y': 0.0, 'z': 0.0},
      3: {'x': 0.0, 'y': pi / 2, 'z': 0.0},
      4: {'x': 0.0, 'y': -pi / 2, 'z': 0.0},
      5: {'x': -pi / 2, 'y': 0.0, 'z': 0.0},
      6: {'x': 0.0, 'y': pi, 'z': 0.0},
    };
    
    final targetRotation = baseRotations[_selectedFaceNumber!] ?? baseRotations[1]!;
    
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
    _animationController.duration = const Duration(milliseconds: 1500);
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
    final theme = ThemeModel.getThemeByFaceNumber(_selectedFaceNumber!);
    
    // 最終的な回転値を正確に設定（選んだ面が正面を向くように）
    final baseRotations = {
      1: {'x': 0.0, 'y': 0.0, 'z': 0.0},
      2: {'x': pi / 2, 'y': 0.0, 'z': 0.0},
      3: {'x': 0.0, 'y': pi / 2, 'z': 0.0},
      4: {'x': 0.0, 'y': -pi / 2, 'z': 0.0},
      5: {'x': -pi / 2, 'y': 0.0, 'z': 0.0},
      6: {'x': 0.0, 'y': pi, 'z': 0.0},
    };
    
    final targetRotation = baseRotations[_selectedFaceNumber!] ?? baseRotations[1]!;
    
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
    
    // 成功時の演出
    _triggerVibration();
    
    // アニメーションをリセット（自動継続しない）
    _animationController.reset();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Theme Dice'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // サイコロ表示エリア
                SizedBox(
                  width: Dice3DUtils.diceSize + 50,
                  height: Dice3DUtils.diceSize + 50,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final progress = _animationController.value;
                      final curveValue = Curves.easeOutCubic.transform(progress);
                      
                      // Z座標の補間（奥から手前へ）
                      // 奥から手前への移動アニメーション中は常に更新
                      double currentZPosition = _currentZ;
                      if (_isRollingFromBack) {
                        // 奥から手前へ：1000 → 0
                        currentZPosition = _startZ + (_endZ - _startZ) * curveValue;
                        _currentZ = currentZPosition;
                      }
                      
                      // 回転値の補間（奥から手前への移動中も回転する）
                      final currentX = _startRotationX + (_endRotationX - _startRotationX) * curveValue;
                      final currentY = _startRotationY + (_endRotationY - _startRotationY) * curveValue;
                      final currentZ = _startRotationZ + (_endRotationZ - _startRotationZ) * curveValue;
                      
                      // Z座標に基づいて透明度とスケールを計算
                      // 奥から手前への移動中のみ適用、回転アニメーション中は常に1.0
                      double opacity = 1.0;
                      double scale = 1.0;
                      
                      if (_isRollingFromBack) {
                        // Z座標が大きい（奥）= 透明度が低く、スケールが小さい
                        // Z座標が小さい（手前）= 透明度が高く、スケールが大きい
                        // currentZPosition: 1000（奥）→ 0（手前）
                        final normalizedZ = (currentZPosition / 1000.0).clamp(0.0, 1.0);
                        // 奥（normalizedZ=1.0）→ 透明度0、スケール0.1（非常に小さい）
                        // 手前（normalizedZ=0.0）→ 透明度1、スケール1.0
                        // より滑らかな変化のため、easeOutカーブを使用
                        final opacityCurve = Curves.easeOut.transform(1.0 - normalizedZ);
                        opacity = opacityCurve.clamp(0.0, 1.0);
                        final scaleCurve = Curves.easeOut.transform(1.0 - normalizedZ);
                        scale = 0.1 + scaleCurve * 0.9; // 0.1から1.0まで（非常に小さく開始）
                      }
                      
                      // 3D遠近感を持たせるためのperspectiveマトリックス
                      // Z座標が大きい（奥）= 画面の奥に配置
                      // Z座標が小さい（手前）= 画面の手前に配置
                      const double perspective = 0.001;
                      final perspectiveMatrix = Matrix4.identity()
                        ..setEntry(3, 2, perspective)
                        ..translate(0, 0, -currentZPosition * 0.5); // Z座標で奥行きを表現
                      // 回転はDiceWidget内で適用するため、ここでは適用しない
                      
                      // 初期状態（Z座標が1000に近い）では完全に非表示
                      if (currentZPosition > 950 && !_isRollingFromBack) {
                        return const SizedBox.shrink();
                      }
                      
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // サイコロの下に落ちる影
                              Transform.translate(
                                offset: const Offset(0, 8),
                                child: Container(
                                  width: Dice3DUtils.diceSize,
                                  height: Dice3DUtils.diceSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3 * opacity),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // サイコロ本体（perspectiveのみ適用、回転はDiceWidget内で）
                              Transform(
                                transform: perspectiveMatrix,
                                alignment: Alignment.center,
                                child: DiceWidget(
                                  rotX: currentX,
                                  rotY: currentY,
                                  rotZ: currentZ,
                                  themes: ThemeModel.themes,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // 「サイコロを振る」ボタン
                // アニメーション中は無効化、それ以外は有効
                ElevatedButton.icon(
                  onPressed: _animationController.isAnimating
                      ? null
                      : _rollDice,
                  icon: const Icon(Icons.casino),
                  label: const Text(
                    'サイコロを振る',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 選択されたテーマを表示
                ThemeDisplay(selectedTheme: _selectedTheme),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
