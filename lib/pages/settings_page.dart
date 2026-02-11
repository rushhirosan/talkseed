import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/polyhedron_type.dart';
import '../models/theme.dart';

/// 設定画面
class SettingsPage extends StatefulWidget {
  final PolyhedronType selectedType;
  final Map<PolyhedronType, List<String>> themes;
  final Function(PolyhedronType, Map<PolyhedronType, List<String>>) onSave;

  const SettingsPage({
    super.key,
    required this.selectedType,
    required this.themes,
    required this.onSave,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late PolyhedronType _selectedType;
  late Map<PolyhedronType, List<String>> _themes;
  final Random _random = Random();
  late List<TextEditingController> _controllers;

  bool _initialized = false;
  
  final ScrollController _rightScrollController = ScrollController();

  void _initializeThemes(AppLocalizations l10n) {
    if (_initialized) return;
    // 現在は正六面体のみをサポートしているため、常にcubeを使用
    _selectedType = PolyhedronType.cube;
    // テーマをコピーして編集可能にする（正六面体のみ）
    final themes = List<String>.from(
      widget.themes[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n),
    );
    _themes = {
      PolyhedronType.cube: themes,
    };
    // コントローラーを初期化
    _controllers = themes.map((theme) => TextEditingController(text: theme)).toList();
    _initialized = true;
  }

  @override
  void dispose() {
    // コントローラーを破棄
    for (var controller in _controllers) {
      controller.dispose();
    }
    _rightScrollController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    // 現在は正六面体のみをサポートしているため、cubeのテーマのみを保存
    final cubeThemes = {PolyhedronType.cube: _themes[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n)};
    widget.onSave(PolyhedronType.cube, cubeThemes);
    Navigator.of(context).pop();
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
    _initializeThemes(l10n);
    return Scaffold(
      backgroundColor: _white,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
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
            icon: const Icon(Icons.check, color: _black),
            onPressed: _save,
            tooltip: l10n.save,
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
              child: _buildThemeEditSection(),
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
      _themes[_selectedType] = selectedThemes;
      
      // コントローラーを更新
      // 既存のコントローラーを破棄
      for (var controller in _controllers) {
        controller.dispose();
      }
      // 新しいコントローラーを作成
      _controllers = selectedThemes.map((theme) => TextEditingController(text: theme)).toList();
    });
  }

  /// テーマ編集セクション（タイトル・ランダム/リセットボタン・面1〜6を一列表示）
  Widget _buildThemeEditSection() {
    final l10n = AppLocalizations.of(context)!;
    _initializeThemes(l10n);
    final currentThemes = _themes[_selectedType] ?? [];
    
    while (_controllers.length < currentThemes.length) {
      _controllers.add(TextEditingController(text: currentThemes[_controllers.length]));
    }
    while (_controllers.length > currentThemes.length) {
      _controllers.removeLast().dispose();
    }
    
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
                      _themes[_selectedType] = List<String>.from(defaultThemes);
                      for (var controller in _controllers) {
                        controller.dispose();
                      }
                      _controllers = defaultThemes.map((theme) => TextEditingController(text: theme)).toList();
                    });
                  },
                  maxWidth: constraints.maxWidth,
                ),
              ],
            ),
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
          ],
        );
      },
    );
  }

  /// 面1〜面6を縦一列に表示（上から面1、面2、面3、面4、面5、面6）
  Widget _buildFaceColumn() {
    final currentThemes = _themes[_selectedType] ?? [];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < currentThemes.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _buildFaceSlot(
            index: i,
            currentThemes: currentThemes,
          ),
        ],
      ],
    );
  }

  /// 面スロット（コントローラー同期＋ドラッグ可能テキストフィールド）
  Widget _buildFaceSlot({
    required int index,
    required List<String> currentThemes,
  }) {
    if (_controllers[index].text != currentThemes[index]) {
      _controllers[index].text = currentThemes[index];
    }
    return _buildDraggableTextField(
      index: index,
      controller: _controllers[index],
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

  /// テキストの長さに応じてフォントサイズを計算（より正確に）
  /// [compact] 2x3グリッド用：狭いセルで全文表示するためパディング・最小サイズを調整
  double _calculateFontSize(String text, double availableWidth, {bool compact = false}) {
    if (text.isEmpty) return compact ? 12.0 : 14.0;
    
    final padding = compact ? 20.0 : 32.0;
    final effectiveWidth = availableWidth - padding;
    
    // テキストの長さに基づいてフォントサイズを計算
    final baseSize = compact ? 12.0 : 14.0;
    final japaneseCharWidth = baseSize * 1.2;
    final englishCharWidth = baseSize * 0.6;
    
    final japaneseChars = text.runes.where((rune) => rune >= 0x3040 && rune <= 0x9FFF).length;
    final englishChars = text.length - japaneseChars;
    final estimatedWidth = (japaneseChars * japaneseCharWidth) + (englishChars * englishCharWidth);
    
    // 2行表示時は幅の2倍まで許容（compact時）
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
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          controller.text = data;
          _themes[_selectedType]![index] = data;
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
                                  _themes[_selectedType]![index] = value;
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
                            _themes[_selectedType]![index] = value;
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
