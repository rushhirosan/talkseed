import 'package:flutter/material.dart';
import 'dart:math';
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

  @override
  void initState() {
    super.initState();
    // 現在は正六面体のみをサポートしているため、常にcubeを使用
    _selectedType = PolyhedronType.cube;
    // テーマをコピーして編集可能にする（正六面体のみ）
    final themes = List<String>.from(
      widget.themes[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube),
    );
    _themes = {
      PolyhedronType.cube: themes,
    };
    // コントローラーを初期化
    _controllers = themes.map((theme) => TextEditingController(text: theme)).toList();
  }

  @override
  void dispose() {
    // コントローラーを破棄
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    // 現在は正六面体のみをサポートしているため、cubeのテーマのみを保存
    final cubeThemes = {PolyhedronType.cube: _themes[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube)};
    widget.onSave(PolyhedronType.cube, cubeThemes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: '保存',
          ),
        ],
      ),
      body: Row(
        children: [
          // 左側: テーマ入力エリア
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildThemeEditSection(),
            ),
          ),
          // 右側: テーマ候補エリア
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
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
      final candidates = List<String>.from(ThemeModel.themeCandidates);
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

  /// テーマ編集セクション
  Widget _buildThemeEditSection() {
    final currentThemes = _themes[_selectedType] ?? [];
    
    // コントローラーの数を調整
    while (_controllers.length < currentThemes.length) {
      _controllers.add(TextEditingController(text: currentThemes[_controllers.length]));
    }
    while (_controllers.length > currentThemes.length) {
      _controllers.removeLast().dispose();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'テーマ（正六面体）',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                // ランダムセットボタン
                OutlinedButton.icon(
                  onPressed: _setRandomThemes,
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('ランダムにセット'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                // リセットボタン
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      final defaultThemes = ThemeModel.getDefaultThemes(_selectedType);
                      _themes[_selectedType] = List<String>.from(defaultThemes);
                      // コントローラーを更新
                      for (var controller in _controllers) {
                        controller.dispose();
                      }
                      _controllers = defaultThemes.map((theme) => TextEditingController(text: theme)).toList();
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('リセット'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: List.generate(currentThemes.length, (index) {
              // コントローラーのテキストを最新の状態に更新
              if (_controllers[index].text != currentThemes[index]) {
                _controllers[index].text = currentThemes[index];
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDraggableTextField(
                  index: index,
                  controller: _controllers[index],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// ドラッグアンドドロップ対応のテキストフィールド
  Widget _buildDraggableTextField({
    required int index,
    required TextEditingController controller,
  }) {
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          controller.text = data;
          _themes[_selectedType]![index] = data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isHighlighted ? Theme.of(context).primaryColor : Colors.grey.shade400,
              width: isHighlighted ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
            color: isHighlighted ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '面${index + 1}',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              hintText: isHighlighted ? 'ここにドロップ' : 'テーマを入力またはドラッグ',
            ),
            onChanged: (value) {
              _themes[_selectedType]![index] = value;
            },
          ),
        );
      },
    );
  }

  /// テーマ候補セクション
  Widget _buildThemeCandidatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'テーマ候補',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '左のテキストボックスにドラッグ＆ドロップ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
            ),
            itemCount: ThemeModel.themeCandidates.length,
            itemBuilder: (context, index) {
              final candidate = ThemeModel.themeCandidates[index];
              return _buildDraggableCandidate(candidate);
            },
          ),
        ),
      ],
    );
  }

  /// ドラッグ可能なテーマ候補アイテム
  Widget _buildDraggableCandidate(String theme) {
    return Draggable<String>(
      data: theme,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColor,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            theme,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            child: Text(
              theme,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Center(
          child: Text(
            theme,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
