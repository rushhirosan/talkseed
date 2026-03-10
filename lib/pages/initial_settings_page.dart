import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/polyhedron_type.dart';
import '../models/theme.dart';
import '../utils/preferences_helper.dart';
import '../utils/route_transitions.dart';
import 'dice_page.dart';
import 'session_setup_page.dart';
import 'topics_page.dart';
import 'mode_selection_page.dart';
import '../models/preselected_mode.dart';

/// テーマ設定画面（モード選択後、テーマ編集して遊ぶ画面へ遷移）
class InitialSettingsPage extends StatefulWidget {
  /// モード選択画面から指定された場合、そのモードのボタンのみ表示
  final PreselectedMode? preselectedMode;
  /// 起動時などで渡す場合のサイコロ6面の初期テーマ（null の場合はデフォルト）
  final List<String>? initialThemesForCube;

  const InitialSettingsPage({
    super.key,
    this.preselectedMode,
    this.initialThemesForCube,
  });

  @override
  State<InitialSettingsPage> createState() => _InitialSettingsPageState();
}

class _InitialSettingsPageState extends State<InitialSettingsPage> {
  PolyhedronType _selectedType = PolyhedronType.cube;
  Map<PolyhedronType, List<String>>? _themes;
  bool _vibrationEnabled = true;

  final Map<PolyhedronType, List<TextEditingController>> _controllers = {};
  final Random _random = Random();
  bool _initialized = false;

  final ScrollController _rightScrollController = ScrollController();
  /// ドロップ直後の面インデックス（アニメーション用）
  int? _lastDroppedIndex;
  /// 編集中の面インデックス（null のときは右側と同じ Center+Text で表示）
  int? _focusedFaceIndex;
  final List<FocusNode> _faceFocusNodes = List.generate(6, (_) => FocusNode());
  /// ensureVisible の重複呼び出し防止用
  bool _ensureVisibleScheduled = false;

  @override
  void initState() {
    super.initState();
    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    final enabled = await PreferencesHelper.loadVibrationEnabled();
    if (mounted) setState(() => _vibrationEnabled = enabled);
  }

  void _initializeThemes(AppLocalizations l10n) {
    if (_initialized) return;
    final cubeThemes = (widget.initialThemesForCube != null &&
            widget.initialThemesForCube!.length == 6)
        ? List<String>.from(widget.initialThemesForCube!)
        : ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n);
    _themes = {
      PolyhedronType.tetrahedron: ThemeModel.getDefaultThemes(PolyhedronType.tetrahedron, l10n),
      PolyhedronType.cube: cubeThemes,
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
    for (final node in _faceFocusNodes) {
      node.dispose();
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
        const SizedBox(height: 16),
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
    // 全モード表示（サイコロで戻ってきた場合など）。カードで遊ぶはモード選択で選ぶためここでは表示しない
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
      const SizedBox(height: 16),
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
      resizeToAvoidBottomInset: true,
      backgroundColor: _white,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: _goBackToModeSelection,
          tooltip: l10n.backToModeSelection,
        ),
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: const [],
      ),
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // キーボード表示時は入力エリアのみ全幅表示（横並びだと圧縮されて文字が重なる）
            final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            if (keyboardVisible) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(top: 16, bottom: bottomPadding + 80),
                child: Container(
                  color: _mustardYellow,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildThemeTitleSection(),
                      const SizedBox(height: 8),
                      Text(
                        l10n.faceThemesList,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _black.withOpacity(0.85),
                        ),
                      ),
                      // キーボード表示時はラベルとスロットの間を広げて重なりを防ぐ
                      const SizedBox(height: 32),
                      _buildFaceColumn(),
                      const SizedBox(height: 12),
                      _buildRandomResetRow(l10n),
                      const SizedBox(height: 12),
                      ..._buildPlayButtons(l10n),
                      const SizedBox(height: 16),
                      Text(
                        l10n.useVariantsToChooseTheme,
                        style: TextStyle(
                          fontSize: 13,
                          color: _black.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Container(
                      color: _mustardYellow,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildThemeTitleSection(),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.faceThemesList,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _black.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildFaceColumn(),
                                const SizedBox(height: 12),
                                _buildRandomResetRow(l10n),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildPlayButtons(l10n),
                      ],
                    ),
                  ),
                ),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Container(
                        color: _white,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: _buildThemeCandidatesSection(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: _white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _white,
          ),
          maxLines: 2,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: _black),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
          maxLines: 2,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  /// テーマセクション（タイトルのみ）
  Widget _buildThemeTitleSection() {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeCube,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.yourThemes,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: _black.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// ランダム・リセット・バイブをアイコンのみで1行に3つ表示
  Widget _buildRandomResetRow(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildIconOnlyButton(
          icon: Icons.shuffle,
          tooltip: l10n.randomSet,
          onPressed: _setRandomThemes,
        ),
        const SizedBox(width: 8),
        _buildIconOnlyButton(
          icon: Icons.refresh,
          tooltip: l10n.reset,
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
        ),
        const SizedBox(width: 8),
        _buildIconOnlyButton(
          icon: Icons.vibration,
          tooltip: l10n.vibrationEnabled,
          isActive: _vibrationEnabled,
          onPressed: () async {
            final newValue = !_vibrationEnabled;
            await PreferencesHelper.saveVibrationEnabled(newValue);
            if (mounted) setState(() => _vibrationEnabled = newValue);
          },
        ),
      ],
    );
  }

  /// アイコンのみボタン（ランダム・リセット用）
  Widget _buildIconOnlyButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: _black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isActive ? _black : _white.withOpacity(0.6),
          foregroundColor: isActive ? _white : _black,
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
              return isActive ? _white.withOpacity(0.12) : _black.withOpacity(0.08);
            }
            return null;
          }),
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  /// 面1〜面6を縦一列に表示（Columnで単一スクロールに統合、ensureVisibleが正しく効く）
  Widget _buildFaceColumn() {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    final currentThemes = _themes![_selectedType] ?? [];
    final controllers = _controllers[_selectedType] ?? [];
    const double slotHeight = 56;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < currentThemes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              height: slotHeight,
              child: _buildFaceSlot(
                index: i,
                currentThemes: currentThemes,
                controllers: controllers,
              ),
            ),
          ),
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
    return Builder(
      builder: (slotContext) {
        return _buildDraggableTextField(
          index: index,
          controller: controllers[index],
          compact: true,
          onFocused: () {
            if (_ensureVisibleScheduled) return;
            _ensureVisibleScheduled = true;
            // キーボード表示のアニメーション後にスクロール（レイアウト遷移後の安全なタイミングで実行）
            // 面1は alignment 1.0 でビューポート下部に配置し、ラベルが上に表示されるようにする
            final alignment = index == 0 ? 1.0 : 0.3;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 450), () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _ensureVisibleScheduled = false;
                  if (!slotContext.mounted) return;
                  try {
                    Scrollable.ensureVisible(
                      slotContext,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: alignment,
                    );
                  } catch (_) {
                    // レイアウト競合時は握りつぶす（_debugMutationsLocked 等）
                  }
                });
              });
            });
          },
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
  /// [onFocused] フォーカス取得時に呼ばれる（キーボード表示で入力欄をスクロールするため）
  Widget _buildDraggableTextField({
    required int index,
    required TextEditingController controller,
    bool compact = false,
    void Function()? onFocused,
  }) {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          controller.text = data;
          _themes![_selectedType]![index] = data;
          _lastDroppedIndex = index;
          _focusedFaceIndex = null;
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _lastDroppedIndex = null);
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        final isJustDropped = _lastDroppedIndex == index;
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
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: compact ? double.infinity : null,
                  height: compact ? constraints.maxHeight : null,
                  decoration: BoxDecoration(
                    color: isJustDropped ? const Color(0xFFE8F5E9) : _white,
                    border: Border.all(
                      color: isJustDropped ? const Color(0xFF4CAF50) : _black,
                      width: isHighlighted ? 2.5 : (isJustDropped ? 2.5 : 1.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isJustDropped
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: compact
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _focusedFaceIndex == index
                                  ? TextField(
                                      focusNode: _faceFocusNodes[index],
                                        controller: controller,
                                        style: TextStyle(
                                          fontSize: currentFontSize,
                                          color: _black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        textAlignVertical: TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          hintText: isHighlighted ? l10n.dropHere : l10n.themeInputHint,
                                          hintStyle: TextStyle(
                                            color: _black.withOpacity(0.4),
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          isDense: true,
                                          filled: true,
                                          fillColor: Colors.transparent,
                                        ),
                                        onChanged: (value) {
                                          _themes ??= {};
                                          _themes![_selectedType]![index] = value;
                                        },
                                        onTapOutside: (_) {
                                          setState(() => _focusedFaceIndex = null);
                                        },
                                      )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() => _focusedFaceIndex = index);
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          _faceFocusNodes[index].requestFocus();
                                          onFocused?.call();
                                        });
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              currentText.isEmpty
                                                  ? (isHighlighted ? l10n.dropHere : l10n.themeInputHint)
                                                  : currentText,
                                              style: TextStyle(
                                                fontSize: currentText.isEmpty ? 12 : currentFontSize,
                                                color: currentText.isEmpty
                                                    ? _black.withOpacity(0.4)
                                                    : _black,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                    ),
                                  ),
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
                          textAlignVertical: TextAlignVertical.center,
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
        // 中央の指示テキスト
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.useVariantsToChooseTheme,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: Colors.black87.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
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
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(left: 8, right: 32, bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // 1列表示
                crossAxisSpacing: 0,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5, // 英語など長文表示のため高さを多めに確保
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
    const colors = [
      Color(0xFFB8E6B8), // _lightGreen
      Color(0xFFFFE5CC), // _lightOrange
      Color(0xFFFFCCCC), // _lightPink
      Color(0xFFCCE5E5), // _lightBlueGreen
    ];
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
            border: Border.all(color: Colors.black87, width: 1.5),
          ),
          child: Text(
            theme,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
            border: Border.all(color: Colors.black87.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Center(
            child: Text(
              theme,
              style: TextStyle(
                color: Colors.black87.withOpacity(0.5),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
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
          border: Border.all(color: Colors.black87, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Center(
          child: Text(
            theme,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
