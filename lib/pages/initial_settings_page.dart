import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/polyhedron_type.dart';
import '../models/theme.dart';
import '../utils/preferences_helper.dart';
import '../utils/route_transitions.dart';
import 'dice_page.dart';
import 'tutorial_page.dart';
import 'session_setup_page.dart';
import 'topics_page.dart';
import 'mode_selection_page.dart';
import '../models/preselected_mode.dart';

/// テーマ設定画面（モード選択後、テーマ編集して遊ぶ画面へ遷移）
class InitialSettingsPage extends StatefulWidget {
  /// モード選択画面から指定された場合、そのモードのボタンのみ表示
  final PreselectedMode? preselectedMode;

  const InitialSettingsPage({super.key, this.preselectedMode});

  @override
  State<InitialSettingsPage> createState() => _InitialSettingsPageState();
}

class _InitialSettingsPageState extends State<InitialSettingsPage> {
  PolyhedronType _selectedType = PolyhedronType.cube;
  Map<PolyhedronType, List<String>>? _themes;

  final Map<PolyhedronType, List<TextEditingController>> _controllers = {};
  final Random _random = Random();
  bool _initialized = false;

  final ScrollController _rightScrollController = ScrollController();

  void _initializeThemes(AppLocalizations l10n) {
    if (_initialized) return;
    _themes = {
      PolyhedronType.tetrahedron: ThemeModel.getDefaultThemes(PolyhedronType.tetrahedron, l10n),
      PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n),
      PolyhedronType.octahedron: ThemeModel.getDefaultThemes(PolyhedronType.octahedron, l10n),
    };
    // テキストフィールドのコントローラーを初期化
    for (var type in PolyhedronType.values) {
      final themes = _themes![type]!;
      _controllers[type] = themes.map((theme) => TextEditingController(text: theme)).toList();
    }
    _initialized = true;
  }

  @override
  void dispose() {
    // コントローラーを破棄
    for (var controllers in _controllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    _rightScrollController.dispose();
    super.dispose();
  }

  void _updateThemesFromControllers() {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    for (var type in PolyhedronType.values) {
      final controllers = _controllers[type] ?? [];
      _themes![type] = controllers.map((c) => c.text).toList();
    }
  }

  /// サイコロで遊ぶ（サイコロ画面へ）
  void _goToDice() async {
    _updateThemesFromControllers();
    final l10n = AppLocalizations.of(context)!;
    final themes = _themes?[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n);
    PreferencesHelper.saveLastThemes(themes);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      RouteTransitions.forwardRoute(
        page: DicePage(
          initialType: PolyhedronType.cube,
          initialThemes: {PolyhedronType.cube: themes},
        ),
      ),
    );
  }

  /// カードで遊ぶ（トピックカード画面へ）
  void _goToCards() async {
    _updateThemesFromControllers();
    final l10n = AppLocalizations.of(context)!;
    final themes = _themes?[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n);
    PreferencesHelper.saveLastThemes(themes);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      RouteTransitions.forwardRoute(
        page: TopicsPage(
          initialThemes: {PolyhedronType.cube: themes},
          sessionConfig: null,
        ),
      ),
    );
  }

  /// セッション設定画面に遷移
  void _goToSessionSetup() {
    _updateThemesFromControllers();
    final l10n = AppLocalizations.of(context)!;
    final themes = {PolyhedronType.cube: _themes?[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n)};

    if (widget.preselectedMode == PreselectedMode.group) {
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: SessionSetupPage(themes: themes),
        ),
      );
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => SessionSetupPage(themes: themes),
        ),
      );
    }
  }

  /// モード選択画面に戻る
  void _goBackToModeSelection() {
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  /// preselectedMode に応じて遊ぶボタンを構築
  List<Widget> _buildPlayButtons(AppLocalizations l10n) {
    final mode = widget.preselectedMode;
    if (mode == PreselectedMode.dice) {
      return [
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            icon: Icons.casino,
            label: l10n.playWithDice,
            onPressed: _goToDice,
            isPrimary: true,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            icon: Icons.group,
            label: l10n.playWithOthers,
            onPressed: _goToSessionSetup,
            isPrimary: false,
          ),
        ),
      ];
    }
    if (mode == PreselectedMode.card) {
      return [
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            icon: Icons.style,
            label: l10n.playWithCards,
            onPressed: _goToCards,
            isPrimary: true,
          ),
        ),
      ];
    }
    if (mode == PreselectedMode.group) {
      return [
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            icon: Icons.group,
            label: l10n.playWithOthers,
            onPressed: _goToSessionSetup,
            isPrimary: true,
          ),
        ),
      ];
    }
    // 全モード表示（従来の動作）
    return [
      SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          icon: Icons.casino,
          label: l10n.playWithDice,
          onPressed: _goToDice,
          isPrimary: true,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          icon: Icons.style,
          label: l10n.playWithCards,
          onPressed: _goToCards,
          isPrimary: false,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: _buildActionButton(
          icon: Icons.group,
          label: l10n.playWithOthers,
          onPressed: _goToSessionSetup,
          isPrimary: false,
        ),
      ),
    ];
  }

  /// チュートリアルを表示
  void _showTutorial() {
    Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: TutorialPage(
          onComplete: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // デザインカラーパレット（チュートリアル画面の黄色に合わせる）
  static const Color _mustardYellow = Color(0xFFFFEB3B); // 鮮やかな黄色（チュートリアル画面と同じ）
  static const Color _lightGreen = Color(0xFFB8E6B8); // ライトグリーン
  static const Color _lightOrange = Color(0xFFFFE5CC); // ライトオレンジ
  static const Color _lightPink = Color(0xFFFFCCCC); // ライトレッド/ピンク
  static const Color _lightBlueGreen = Color(0xFFCCE5E5); // ライトブルーグリーン
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _white,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        automaticallyImplyLeading: widget.preselectedMode != null,
        leading: widget.preselectedMode != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: _black),
                onPressed: _goBackToModeSelection,
                tooltip: l10n.backToModeSelection,
              )
            : null,
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: _black),
            onPressed: _showTutorial,
            tooltip: l10n.showTutorial,
          ),
        ],
      ),
      body: Row(
        children: [
          // 左側: マスタードイエローの背景セクション
          Expanded(
            flex: 1,
            child: Container(
              color: _mustardYellow,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemeEditSection(),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.faceThemesList,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _black.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildFaceColumn(),
                    const SizedBox(height: 16),
                    // preselectedMode が指定されている場合はそのボタンのみ、なければ3つすべて表示
                    ..._buildPlayButtons(l10n),
                  ],
                ),
              ),
            ),
          ),
          // 右側: 白背景のテーマ候補エリア
          Expanded(
            flex: 1,
            child: Container(
              color: _white,
              padding: const EdgeInsets.all(24),
              child: _buildThemeCandidatesSection(),
            ),
          ),
        ],
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: _white),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _white,
                ),
                maxLines: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: _black),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
                maxLines: 1,
              ),
            ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            side: const BorderSide(color: _black, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: _white.withOpacity(0.6),
            foregroundColor: _black,
          ).copyWith(
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.hovered)) {
                return const BorderSide(color: _black, width: 2.5);
              }
              return const BorderSide(color: _black, width: 1.5);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return _black.withOpacity(0.08);
              }
              return null;
            }),
          ),
          );
        },
      );
    }
  }

  // 注意: 多面体タイプ選択セクションは削除されました
  // 現在は正六面体のみをサポートしています
  // 将来的に他の多面体タイプを使用する場合は、このセクションを復元してください

  /// テーマ候補からランダムにセット
  void _setRandomThemes() {
    setState(() {
      final l10n = AppLocalizations.of(context)!;
      final candidates = ThemeModel.getThemeCandidates(l10n);
      final faceCount = _selectedType.faceCount;
      
      // 候補から重複しないようにランダムに選択
      final selectedThemes = <String>[];
      final availableCandidates = List<String>.from(candidates);
      
      for (int i = 0; i < faceCount && availableCandidates.isNotEmpty; i++) {
        final randomIndex = _random.nextInt(availableCandidates.length);
        selectedThemes.add(availableCandidates.removeAt(randomIndex));
      }
      
      // 不足分は候補から繰り返し選択
      while (selectedThemes.length < faceCount) {
        final randomIndex = _random.nextInt(candidates.length);
        selectedThemes.add(candidates[randomIndex]);
      }
      
      // テーマを設定
      _themes ??= {};
      _themes![_selectedType] = selectedThemes;
      
      // コントローラーを更新
      final controllers = _controllers[_selectedType] ?? [];
      // 既存のコントローラーを破棄
      for (var controller in controllers) {
        controller.dispose();
      }
      // 新しいコントローラーを作成
      _controllers[_selectedType] = selectedThemes.map((theme) => TextEditingController(text: theme)).toList();
    });
  }

  /// テーマ編集セクション（タイトル・ランダム/リセットボタンのみ）
  Widget _buildThemeEditSection() {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.themeCube,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.yourThemes,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: _black.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRoundedButton(
                  icon: Icons.shuffle,
                  label: l10n.randomSet,
                  onPressed: _setRandomThemes,
                  maxWidth: constraints.maxWidth,
                ),
                _buildRoundedButton(
                  icon: Icons.refresh,
                  label: l10n.reset,
                  onPressed: () {
                    setState(() {
                      final l10n = AppLocalizations.of(context)!;
                      final defaultThemes = ThemeModel.getDefaultThemes(_selectedType, l10n);
                      _themes ??= {};
                      _themes![_selectedType] = List<String>.from(defaultThemes);
                      final oldControllers = _controllers[_selectedType] ?? [];
                      for (var controller in oldControllers) {
                        controller.dispose();
                      }
                      _controllers[_selectedType] = defaultThemes.map((theme) => TextEditingController(text: theme)).toList();
                    });
                  },
                  maxWidth: constraints.maxWidth,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 面1〜面6を縦一列に表示（上から面1、面2、面3、面4、面5、面6）
  Widget _buildFaceColumn() {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    final currentThemes = _themes![_selectedType] ?? [];
    final controllers = _controllers[_selectedType] ?? [];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < currentThemes.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _buildFaceSlot(
            index: i,
            currentThemes: currentThemes,
            controllers: controllers,
          ),
        ],
      ],
    );
  }

  /// 面スロット（面番号を明確に表示＋ドラッグ可能テキストフィールド）
  Widget _buildFaceSlot({
    required int index,
    required List<String> currentThemes,
    required List<TextEditingController> controllers,
  }) {
    if (index >= controllers.length) {
      controllers.add(TextEditingController(text: currentThemes[index]));
    }
    if (controllers[index].text != currentThemes[index]) {
      controllers[index].text = currentThemes[index];
    }
    return _buildDraggableTextField(
      index: index,
      controller: controllers[index],
      compact: true,
    );
  }

  /// 角の丸いボタン
  Widget _buildRoundedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double? maxWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonMaxWidth = maxWidth ?? constraints.maxWidth;
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18, color: _black),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: _black),
              maxLines: 1,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            side: const BorderSide(color: _black, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: _white.withOpacity(0.6),
            foregroundColor: _black,
          ).copyWith(
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.hovered)) {
                return const BorderSide(color: _black, width: 2.5);
              }
              return const BorderSide(color: _black, width: 1.5);
            }),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return _black.withOpacity(0.08);
              }
              return null;
            }),
          ),
        );
      },
    );
  }

  /// テキストの長さに応じてフォントサイズを計算
  /// [compact] 2x3グリッド用：狭いセルで全文表示するためパディング・最小サイズを調整
  double _calculateFontSize(String text, double availableWidth, {bool compact = false}) {
    if (text.isEmpty) return compact ? 12.0 : 14.0;
    
    final padding = compact ? 20.0 : 32.0;
    final effectiveWidth = availableWidth - padding;
    final baseSize = compact ? 12.0 : 14.0;
    final japaneseCharWidth = baseSize * 1.2;
    final englishCharWidth = baseSize * 0.6;
    
    final japaneseChars = text.runes.where((rune) => rune >= 0x3040 && rune <= 0x9FFF).length;
    final englishChars = text.length - japaneseChars;
    final estimatedWidth = (japaneseChars * japaneseCharWidth) + (englishChars * englishCharWidth);
    
    final allowedWidth = compact ? effectiveWidth * 2 : effectiveWidth;
    if (estimatedWidth <= allowedWidth) {
      return baseSize;
    }
    
    final scaleFactor = allowedWidth / estimatedWidth;
    final calculatedSize = baseSize * scaleFactor;
    return calculatedSize.clamp(compact ? 8.0 : 10.0, baseSize);
  }

  /// ドラッグアンドドロップ対応のテキストフィールド
  /// [compact] trueの場合、一列表示用：面番号を明確に表示
  Widget _buildDraggableTextField({
    required int index,
    required TextEditingController controller,
    bool compact = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          controller.text = data;
          _themes![_selectedType]![index] = data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return LayoutBuilder(
          builder: (context, constraints) {
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final currentText = value.text;
                final currentFontSize = _calculateFontSize(
                  currentText,
                  constraints.maxWidth,
                  compact: compact,
                );
                
                return Container(
                  decoration: BoxDecoration(
                    color: _white,
                    border: Border.all(
                      color: _black,
                      width: isHighlighted ? 2.5 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: compact
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                style: TextStyle(
                                  fontSize: currentFontSize,
                                  color: _black,
                                ),
                                maxLines: 1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  hintText: isHighlighted ? l10n.dropHere : l10n.themeInputHint,
                                  hintStyle: TextStyle(
                                    color: _black.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  _themes ??= {};
                                  _themes![_selectedType]![index] = value;
                                },
                              ),
                            ),
                          ],
                        )
                      : TextField(
                          controller: controller,
                          style: TextStyle(
                            fontSize: currentFontSize,
                            color: _black,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: l10n.faceLabel(index + 1),
                            labelStyle: TextStyle(
                              color: _black.withOpacity(0.6),
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: isHighlighted ? l10n.dropHere : l10n.themeInputHint,
                            hintStyle: TextStyle(
                              color: _black.withOpacity(0.4),
                              fontSize: currentFontSize,
                            ),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _themes ??= {};
                            _themes![_selectedType]![index] = value;
                          },
                        ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// テーマ候補セクション
  Widget _buildThemeCandidatesSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 中央の指示テキスト（オーバーフローを防ぐためFlexibleでラップ）
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.useVariantsToChooseTheme,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: _black.withOpacity(0.7),
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _rightScrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(3),
            child: GridView.builder(
              controller: _rightScrollController,
              primary: false,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 20, bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // 1列表示
                crossAxisSpacing: 0,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8, // 高さを十分に確保（幅:高さ = 1.8:1）
              ),
              itemCount: ThemeModel.getThemeCandidates(l10n).length,
              itemBuilder: (context, index) {
                final candidates = ThemeModel.getThemeCandidates(l10n);
                final candidate = candidates[index];
                return _buildDraggableCandidate(candidate, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// パステルカラーを取得（インデックスに基づいて循環）
  Color _getPastelColor(int index) {
    final colors = [_lightGreen, _lightOrange, _lightPink, _lightBlueGreen];
    return colors[index % colors.length];
  }

  /// ドラッグ可能なテーマ候補アイテム
  Widget _buildDraggableCandidate(String theme, int index) {
    final pastelColor = _getPastelColor(index);
    
    return Draggable<String>(
      data: theme,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: pastelColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: pastelColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _black, width: 1.5),
          ),
          child: Text(
            theme,
            style: const TextStyle(
              color: _black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: pastelColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _black.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Text(
              theme,
              style: TextStyle(
                color: _black.withOpacity(0.5),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 60, // 最小高さを確保
        ),
        decoration: BoxDecoration(
          color: pastelColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _black, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              theme,
              style: const TextStyle(
                color: _black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}
