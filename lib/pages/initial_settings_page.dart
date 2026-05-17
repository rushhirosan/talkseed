import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';
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

  final Map<PolyhedronType, List<TextEditingController>> _controllers = {};
  final Random _random = Random();
  bool _initialized = false;

  final ScrollController _rightScrollController = ScrollController();
  /// ドロップ直後の面インデックス（アニメーション用）
  int? _lastDroppedIndex;
  /// 編集中の面インデックス（null のときは右側と同じ Center+Text で表示）
  int? _focusedFaceIndex;
  /// モバイル: 候補タップで入れ替える対象の面（初期は1面目を選択）
  int? _selectedFaceIndex = 0;
  final List<FocusNode> _faceFocusNodes = List.generate(6, (_) => FocusNode());
  /// ensureVisible の重複呼び出し防止用
  bool _ensureVisibleScheduled = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeThemes(AppLocalizations.of(context)!);
    }
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
        RouteTransitions.forwardRoute(
          page: SessionSetupPage(themes: themes),
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

  TextStyle _labelStyle({double fontSize = 20}) => GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: HomePalette.text,
      );

  TextStyle _hintStyle({double fontSize = 13}) => GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        height: 1.35,
        color: HomePalette.textMuted,
      );

  Widget _panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HomePalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomePalette.border),
      ),
      padding: padding,
      child: child,
    );
  }

  bool _isMobileTapMode(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 560;

  Widget _buildSettingsBody(AppLocalizations l10n, EdgeInsets panelPadding) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    final mobileTap = _isMobileTapMode(context);

    if (keyboardVisible) {
      final slotWidth = _panelContentWidth(context, twoColumn: false);
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 80),
        child: _panel(
          padding: panelPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeTitleSection(),
              const SizedBox(height: 8),
              Text(l10n.faceThemesList, style: _hintStyle(fontSize: 14)),
              if (mobileTap) ...[
                const SizedBox(height: 4),
                Text(l10n.themeLongPressToEdit, style: _hintStyle(fontSize: 12)),
              ],
              const SizedBox(height: 32),
              _buildFaceColumn(slotWidth, mobileTapMode: mobileTap),
              const SizedBox(height: 12),
              _buildRandomResetRow(l10n),
              const SizedBox(height: 12),
              ..._buildPlayButtons(l10n),
              const SizedBox(height: 16),
              _buildThemeCandidatesSection(
                slotWidth,
                expandGrid: false,
                mobileTapMode: mobileTap,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 560;
        final panelWidth = _panelContentWidth(
          context,
          twoColumn: !stacked,
        );

        if (stacked) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _panel(
                    padding: panelPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLeftPanelContent(
                          l10n,
                          slotWidth: panelWidth,
                          scrollable: false,
                          mobileTapMode: true,
                        ),
                        const SizedBox(height: 12),
                        ..._buildPlayButtons(l10n),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _panel(
                    padding: panelPadding,
                    child: _buildThemeCandidatesSection(
                      panelWidth,
                      expandGrid: false,
                      mobileTapMode: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _panel(
                  padding: panelPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildLeftPanelContent(
                          l10n,
                          slotWidth: panelWidth,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildPlayButtons(l10n),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _panel(
                  padding: panelPadding,
                  child: _buildThemeCandidatesSection(panelWidth),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 左右2カラム時の1パネル内コンテンツ幅（LayoutBuilder を避けるため MediaQuery で算出）
  double _panelContentWidth(BuildContext context, {required bool twoColumn}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const bodyPadding = 16.0 * 2;
    const panelPadding = 16.0 * 2;
    const columnGap = 12.0;
    if (!twoColumn) {
      return (screenWidth - bodyPadding - panelPadding).clamp(200.0, 600.0);
    }
    return ((screenWidth - bodyPadding - columnGap) / 2 - panelPadding)
        .clamp(160.0, 360.0);
  }

  Widget _buildLeftPanelContent(
    AppLocalizations l10n, {
    required double slotWidth,
    bool scrollable = true,
    bool mobileTapMode = false,
  }) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildThemeTitleSection(),
        const SizedBox(height: 8),
        Text(l10n.faceThemesList, style: _hintStyle(fontSize: 14)),
        if (mobileTapMode) ...[
          const SizedBox(height: 4),
          Text(l10n.themeLongPressToEdit, style: _hintStyle(fontSize: 12)),
        ],
        const SizedBox(height: 8),
        _buildFaceColumn(slotWidth, mobileTapMode: mobileTapMode),
        const SizedBox(height: 12),
        _buildRandomResetRow(l10n),
      ],
    );
    if (!scrollable) return column;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: column,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_initialized || _themes == null) {
      return HomeScaffold(
        title: l10n.settings,
        leading: HomeBackButton(
          onPressed: _goBackToModeSelection,
          tooltip: l10n.backToModeSelection,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: HomePalette.accent),
        ),
      );
    }
    const panelPadding = EdgeInsets.fromLTRB(16, 12, 16, 16);

    return HomeScaffold(
      title: l10n.settings,
      leading: HomeBackButton(
        onPressed: _goBackToModeSelection,
        tooltip: l10n.backToModeSelection,
      ),
      body: _buildSettingsBody(l10n, panelPadding),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return HomePrimaryButton(
        label: label,
        icon: icon,
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    }
    return Material(
      color: HomePalette.surface2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomePalette.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: HomePalette.text),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: GoogleFonts.zenKakuGothicNew(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.themeCube, style: _labelStyle()),
        const SizedBox(height: 4),
        Text(l10n.yourThemes, style: _hintStyle()),
      ],
    );
  }

  /// ランダム・リセットをアイコンのみで1行に表示
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
      child: Material(
        color: isActive ? HomePalette.accent : HomePalette.surface2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? HomePalette.accent
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? HomePalette.bg : HomePalette.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  /// 面1〜面6を縦一列に表示（Columnで単一スクロールに統合、ensureVisibleが正しく効く）
  Widget _buildFaceColumn(double slotWidth, {bool mobileTapMode = false}) {
    final currentThemes = _themes![_selectedType] ?? [];
    final controllers = _controllers[_selectedType] ?? [];
    const double slotHeight = 64;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < currentThemes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              height: slotHeight,
              width: double.infinity,
              child: _buildFaceSlot(
                index: i,
                currentThemes: currentThemes,
                controllers: controllers,
                slotWidth: slotWidth,
                mobileTapMode: mobileTapMode,
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
    required double slotWidth,
    bool mobileTapMode = false,
  }) {
    return Builder(
      builder: (slotContext) {
        return _buildDraggableTextField(
          index: index,
          controller: controllers[index],
          compact: true,
          availableWidth: slotWidth,
          mobileTapMode: mobileTapMode,
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
  void _selectFaceForTap(int index) {
    setState(() {
      _selectedFaceIndex = index;
      _focusedFaceIndex = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _openFaceTextEdit(int index, void Function()? onFocused) {
    setState(() {
      _focusedFaceIndex = index;
      _selectedFaceIndex = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _faceFocusNodes[index].requestFocus();
      onFocused?.call();
    });
  }

  void _assignThemeToFace(int faceIndex, String theme) {
    final controllers = _controllers[_selectedType];
    if (controllers == null || faceIndex < 0 || faceIndex >= controllers.length) {
      return;
    }

    final themes = _themes![_selectedType]!;
    final previous = controllers[faceIndex].text;
    final otherIndex = themes.indexWhere((t) => t == theme);

    setState(() {
      if (otherIndex >= 0 && otherIndex != faceIndex) {
        controllers[otherIndex].text = previous;
        themes[otherIndex] = previous;
      }
      controllers[faceIndex].text = theme;
      themes[faceIndex] = theme;
      _lastDroppedIndex = faceIndex;
      _selectedFaceIndex = faceIndex;
      _focusedFaceIndex = null;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _lastDroppedIndex = null);
    });
  }

  Widget _buildDraggableTextField({
    required int index,
    required TextEditingController controller,
    bool compact = false,
    double availableWidth = 280,
    bool mobileTapMode = false,
    void Function()? onFocused,
  }) {
    final l10n = AppLocalizations.of(context)!;

    Widget buildField(BuildContext context, bool isHighlighted) {
        final isJustDropped = _lastDroppedIndex == index;
        final isSelected = mobileTapMode && _selectedFaceIndex == index;
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final currentText = value.text;
            final currentFontSize = _calculateFontSize(
              currentText,
              availableWidth,
              compact: compact,
            );

            return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: compact ? double.infinity : null,
                  height: compact ? 64 : null,
                  decoration: BoxDecoration(
                    color: isJustDropped
                        ? HomePalette.accent.withValues(alpha: 0.12)
                        : isSelected
                            ? HomePalette.accent.withValues(alpha: 0.08)
                            : HomePalette.surface2,
                    border: Border.all(
                      color: isJustDropped
                          ? HomePalette.accent
                          : isSelected
                              ? HomePalette.accent
                              : isHighlighted
                                  ? HomePalette.purple
                                  : Colors.white.withValues(alpha: 0.12),
                      width: isHighlighted || isJustDropped || isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isJustDropped
                        ? [
                            BoxShadow(
                              color: HomePalette.accent.withValues(alpha: 0.25),
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
                                        style: GoogleFonts.zenKakuGothicNew(
                                          fontSize: currentFontSize,
                                          color: HomePalette.text,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        cursorColor: HomePalette.accent,
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
                                          hintStyle: GoogleFonts.zenKakuGothicNew(
                                            color: HomePalette.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
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
                                      onTap: mobileTapMode
                                          ? () => _selectFaceForTap(index)
                                          : () => _openFaceTextEdit(index, onFocused),
                                      onLongPress: mobileTapMode
                                          ? () => _openFaceTextEdit(index, onFocused)
                                          : null,
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
                                              style: GoogleFonts.zenKakuGothicNew(
                                                fontSize: currentText.isEmpty ? 12 : currentFontSize,
                                                color: currentText.isEmpty
                                                    ? HomePalette.textMuted
                                                    : HomePalette.text,
                                                fontWeight: FontWeight.w400,
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
                          style: GoogleFonts.zenKakuGothicNew(
                            fontSize: currentFontSize,
                            color: HomePalette.text,
                            fontWeight: FontWeight.w400,
                          ),
                          cursorColor: HomePalette.accent,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            labelText: l10n.faceLabel(index + 1),
                            labelStyle: GoogleFonts.zenKakuGothicNew(
                              color: HomePalette.textMuted,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: isHighlighted ? l10n.dropHere : l10n.themeInputHint,
                            hintStyle: GoogleFonts.zenKakuGothicNew(
                              color: HomePalette.textMuted,
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
    }

    if (mobileTapMode) {
      return buildField(context, false);
    }

    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        _assignThemeToFace(index, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return buildField(context, candidateData.isNotEmpty);
      },
    );
  }

  /// テーマ候補セクション
  ///
  /// [expandGrid] が false のときは [SingleChildScrollView] 内向けに
  /// shrinkWrap グリッドを使う（モバイル縦レイアウト）。
  Widget _buildThemeCandidatesSection(
    double gridWidth, {
    bool expandGrid = true,
    bool mobileTapMode = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = gridWidth >= 280;
    final candidates = ThemeModel.getThemeCandidates(l10n);
    final hintText = mobileTapMode
        ? l10n.themeTapToReplaceHint
        : l10n.useVariantsToChooseTheme;

    final grid = GridView.builder(
      controller: expandGrid ? _rightScrollController : null,
      primary: false,
      shrinkWrap: !expandGrid,
      physics: expandGrid
          ? const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            )
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isWide ? 180 : gridWidth,
        mainAxisExtent: 64,
        crossAxisSpacing: isWide ? 8 : 0,
        mainAxisSpacing: 10,
      ),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        return mobileTapMode
            ? _buildTappableCandidate(context, candidates[index], index)
            : _buildDraggableCandidate(context, candidates[index], index);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  hintText,
                  style: GoogleFonts.zenKakuGothicNew(
                    fontSize: 15,
                    height: 1.3,
                    color: HomePalette.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
        if (expandGrid) Expanded(child: grid) else grid,
      ],
    );
  }

  void _onCandidateTapped(String theme) {
    final l10n = AppLocalizations.of(context)!;
    final target = _selectedFaceIndex;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.themeSelectFaceFirst,
            style: GoogleFonts.zenKakuGothicNew(color: HomePalette.text),
          ),
          backgroundColor: HomePalette.surface2,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _assignThemeToFace(target, theme);
  }

  Color _candidateTint(int index) {
    final tints = [
      HomePalette.purple.withValues(alpha: 0.22),
      HomePalette.accent.withValues(alpha: 0.16),
      HomePalette.purple.withValues(alpha: 0.14),
      HomePalette.accentOrange.withValues(alpha: 0.16),
    ];
    return tints[index % tints.length];
  }

  /// モバイル: タップで選択中の面と入れ替え
  Widget _buildTappableCandidate(
    BuildContext context,
    String theme,
    int index,
  ) {
    final tint = _candidateTint(index);
    final themes = _themes![_selectedType] ?? [];
    final isOnFace = themes.contains(theme);
    final isReplacingSelected = _selectedFaceIndex != null &&
        themes.length > _selectedFaceIndex! &&
        themes[_selectedFaceIndex!] == theme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCandidateTapped(theme),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isReplacingSelected
                  ? HomePalette.accent
                  : isOnFace
                      ? HomePalette.purple.withValues(alpha: 0.5)
                      : HomePalette.border,
              width: isReplacingSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Center(
            child: Text(
              theme,
              style: GoogleFonts.zenKakuGothicNew(
                color: HomePalette.text,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// ドラッグ可能なテーマ候補アイテム（Web・広い画面）
  Widget _buildDraggableCandidate(
    BuildContext context,
    String theme,
    int index,
  ) {
    final tint = _candidateTint(index);

    return Draggable<String>(
      data: theme,
      onDragStarted: () => FocusScope.of(context).unfocus(),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: HomePalette.surface2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HomePalette.accent, width: 1.5),
          ),
          child: Text(
            theme,
            style: GoogleFonts.zenKakuGothicNew(
              color: HomePalette.text,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Center(
            child: Text(
              theme,
              style: GoogleFonts.zenKakuGothicNew(
                color: HomePalette.textMuted,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      child: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HomePalette.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Center(
            child: Text(
              theme,
              style: GoogleFonts.zenKakuGothicNew(
                color: HomePalette.text,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
