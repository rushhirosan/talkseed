import 'package:flutter/material.dart';
import 'dart:math';
import '../models/polyhedron_type.dart';
import '../models/theme.dart';
import '../main.dart' show DicePage;

/// 初期設定画面（アプリ起動時に表示）
class InitialSettingsPage extends StatefulWidget {
  const InitialSettingsPage({super.key});

  @override
  State<InitialSettingsPage> createState() => _InitialSettingsPageState();
}

class _InitialSettingsPageState extends State<InitialSettingsPage> {
  PolyhedronType _selectedType = PolyhedronType.cube;
  Map<PolyhedronType, List<String>> _themes = {
    PolyhedronType.tetrahedron: ThemeModel.getDefaultThemes(PolyhedronType.tetrahedron),
    PolyhedronType.cube: ThemeModel.getDefaultThemes(PolyhedronType.cube),
    PolyhedronType.octahedron: ThemeModel.getDefaultThemes(PolyhedronType.octahedron),
  };

  final Map<PolyhedronType, List<TextEditingController>> _controllers = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // テキストフィールドのコントローラーを初期化
    for (var type in PolyhedronType.values) {
      final themes = _themes[type] ?? ThemeModel.getDefaultThemes(type);
      _controllers[type] = themes.map((theme) => TextEditingController(text: theme)).toList();
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
    super.dispose();
  }

  void _updateThemesFromControllers() {
    for (var type in PolyhedronType.values) {
      final controllers = _controllers[type] ?? [];
      _themes[type] = controllers.map((c) => c.text).toList();
    }
  }

  void _complete() {
    _updateThemesFromControllers();
    // サイコロを振る画面に遷移（元の画面を置き換える）
    // 現在は正六面体のみをサポートしているため、cubeのテーマのみを渡す
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DicePage(
          initialType: PolyhedronType.cube,
          initialThemes: {PolyhedronType.cube: _themes[PolyhedronType.cube] ?? ThemeModel.getDefaultThemes(PolyhedronType.cube)},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: Row(
        children: [
          // 左側: テーマ入力エリア
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildThemeEditSection(),
                  ),
                  const SizedBox(height: 16),
                  // 完了ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _complete,
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'サイコロを振る',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
      final controllers = _controllers[_selectedType] ?? [];
      // 既存のコントローラーを破棄
      for (var controller in controllers) {
        controller.dispose();
      }
      // 新しいコントローラーを作成
      _controllers[_selectedType] = selectedThemes.map((theme) => TextEditingController(text: theme)).toList();
    });
  }

  /// テーマ編集セクション
  Widget _buildThemeEditSection() {
    final currentThemes = _themes[_selectedType] ?? [];
    final controllers = _controllers[_selectedType] ?? [];
    
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
                      // コントローラーを再作成
                      final oldControllers = _controllers[_selectedType] ?? [];
                      for (var controller in oldControllers) {
                        controller.dispose();
                      }
                      _controllers[_selectedType] = defaultThemes.map((theme) => TextEditingController(text: theme)).toList();
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
              if (index >= controllers.length) {
                // コントローラーが足りない場合は追加
                controllers.add(TextEditingController(text: currentThemes[index]));
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDraggableTextField(
                  index: index,
                  controller: controllers[index],
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
