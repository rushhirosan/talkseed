import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vibration/vibration.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'models/theme.dart';
import 'models/polyhedron_type.dart';
import 'utils/dice_3d_utils.dart';
import 'utils/preferences_helper.dart';
import 'widgets/dice_widget.dart';
import 'widgets/theme_display.dart';
import 'pages/settings_page.dart';
import 'pages/initial_settings_page.dart';
import 'pages/tutorial_page.dart';

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
      home: const MainPage(),
    );
  }
}

/// 初回起動チェックとチュートリアル表示を管理するメインページ
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = true;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  /// 初回起動かどうかをチェック
  Future<void> _checkFirstLaunch() async {
    try {
      final isFirstLaunch = await PreferencesHelper.isFirstLaunch();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showTutorial = isFirstLaunch;
        });
      }
    } catch (e) {
      // エラーが発生した場合は、チュートリアルをスキップして初期設定画面を表示
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showTutorial = false;
        });
      }
    }
  }

  /// チュートリアル完了時のコールバック
  void _onTutorialComplete() {
    setState(() {
      _showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ローディング中
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // チュートリアル表示
    if (_showTutorial) {
      return TutorialPage(onComplete: _onTutorialComplete);
    }

    // 通常の初期設定画面
    return const InitialSettingsPage();
  }
}

class DicePage extends StatefulWidget {
  final PolyhedronType? initialType;
  final Map<PolyhedronType, List<String>>? initialThemes;

  const DicePage({
    super.key,
    this.initialType,
    this.initialThemes,
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
  late Map<PolyhedronType, List<String>> _themes;

  @override
  void initState() {
    super.initState();
    // 現在は正六面体のみをサポート（常にcubeを使用）
    _selectedPolyhedronType = PolyhedronType.cube;
    // 初期設定画面からテーマを取得、またはデフォルト値を使用
    if (widget.initialThemes != null && widget.initialThemes!.containsKey(PolyhedronType.cube)) {
      _themes = {PolyhedronType.cube: widget.initialThemes![PolyhedronType.cube]!};
    } else {
      _themes = {PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube)};
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
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // 奥から手前への移動時間
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
  
  // Z座標（深度）アニメーション用
  // 初期値は画面の奥（大きい値）、手前は0に近い値
  double _startZ = 1000.0; // 画面の奥
  double _endZ = 0.0; // 手前
  double _currentZ = 1000.0; // 現在のZ座標
  
  bool _isAligningToFront = false;
  bool _isDiceVisible = false; // サイコロが表示されているか
  bool _isRollingFromBack = false; // 奥から手前への移動アニメーション中かどうか

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
      
      // Z座標アニメーション：奥から手前へ
      _startZ = 1000.0;
      _endZ = 0.0;
      _currentZ = 1000.0; // 初期値を確実に設定
    });
    
    // アニメーション時間を設定（奥から手前への移動時間）
    _animationController.duration = const Duration(milliseconds: 2000);
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
    final themes = ThemeModel.getThemesForType(_selectedPolyhedronType, _themes);
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

  /// 設定画面を開く
  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          selectedType: _selectedPolyhedronType,
          themes: _themes,
          onSave: (type, themes) {
            setState(() {
              // 現在は正六面体のみをサポート（常にcubeを使用）
              _selectedPolyhedronType = PolyhedronType.cube;
              // 正六面体のテーマのみを更新
              if (themes.containsKey(PolyhedronType.cube)) {
                _themes = {PolyhedronType.cube: themes[PolyhedronType.cube]!};
              }
            });
          },
        ),
      ),
    );
  }

  /// 設定画面に戻る
  void _goBackToSettings() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InitialSettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Theme Dice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToSettings,
          tooltip: '設定に戻る',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '設定',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // サイコロ表示エリア（アニメーション付き）
                SizedBox(
                  width: Dice3DUtils.diceSize + 50,
                  height: Dice3DUtils.diceSize + 50,
                  child: AnimatedBuilder(
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
                        themes: ThemeModel.getThemesForType(_selectedPolyhedronType, _themes),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // 「サイコロを振る」ボタン
                ElevatedButton.icon(
                  onPressed: _rollDice,
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
