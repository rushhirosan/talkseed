/// マッシュアップの 1 軸（テーマ / 切り口 / 制約）
class MashupAxis {
  final String id;
  final String label;
  final List<String> items;

  /// 起動時デフォルトでオフにする軸（制約など）。UI 上は全軸トグル可。
  final bool optional;

  const MashupAxis({
    required this.id,
    required this.label,
    required this.items,
    this.optional = false,
  });

  factory MashupAxis.fromJson(Map<String, dynamic> json) {
    return MashupAxis(
      id: json['id'] as String,
      label: json['label'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e.toString()).toList(),
      optional: json['optional'] as bool? ?? false,
    );
  }
}

/// 制約軸の ID（オン/オフと合成文テンプレートの切り替えに使う）
const String mashupConstraintAxisId = 'constraint';

/// topic_mashup_*.json 全体
class MashupDeck {
  final List<MashupAxis> axes;

  /// 全軸ぶんの合成文テンプレート（`{軸ID}` を置換）
  final String template;

  /// 制約軸オフのときのテンプレート
  final String templateWithoutConstraint;

  /// 避けたい組み合わせ（各要素は [category, angle] のテキスト）
  final List<List<String>> blocklist;

  const MashupDeck({
    required this.axes,
    required this.template,
    required this.templateWithoutConstraint,
    this.blocklist = const [],
  });

  factory MashupDeck.fromJson(Map<String, dynamic> json) {
    final blocklistRaw = json['blocklist'] as List<dynamic>? ?? [];
    final blocklist = blocklistRaw
        .map(
          (entry) => (entry as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
        )
        .where((pair) => pair.length >= 2)
        .toList();

    return MashupDeck(
      axes: (json['axes'] as List<dynamic>)
          .map((e) => MashupAxis.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      template: json['template'] as String,
      templateWithoutConstraint: json['templateWithoutConstraint'] as String,
      blocklist: blocklist,
    );
  }

  MashupAxis? axisById(String id) {
    for (final axis in axes) {
      if (axis.id == id) return axis;
    }
    return null;
  }

  /// 軸ID -> 選ばれた語 から 1 行の合成文を作る。
  /// オフにした軸のプレースホルダは空になり、前後の助詞・接続を整える。
  String compose(Map<String, String> picks) {
    final hasConstraint =
        (picks[mashupConstraintAxisId] ?? '').isNotEmpty;
    var text = hasConstraint ? template : templateWithoutConstraint;
    for (final axis in axes) {
      text = text.replaceAll('{${axis.id}}', picks[axis.id] ?? '');
    }
    return _cleanupComposeResidue(text);
  }

  /// 欠落プレースホルダ由来の助詞・接続詞を落とす（日英テンプレ両対応）。
  /// 両側が埋まっている接続語（JA「の」「を」、EN「about」）は消さない。
  static String _cleanupComposeResidue(String raw) {
    var text = raw.trim();
    // EN: dangling "about" when angle or category is missing
    text = text.replaceAll(RegExp(r'^about\s+'), '');
    text = text.replaceAll(RegExp(r'\s+about\s*$'), '');
    // EN: "{angle} about  — {constraint}" when category is empty
    text = text.replaceAll(RegExp(r'\s+about\s+—'), ' —');
    // EN: dangling em dash around constraint
    text = text.replaceAll(RegExp(r'\s*—\s*$'), '');
    text = text.replaceAll(RegExp(r'^\s*—\s*'), '');
    // JA: "{category}の{angle}を{constraint}"
    text = text.replaceAll('のを', 'を');
    text = text.replaceAll(RegExp(r'^の'), '');
    text = text.replaceAll(RegExp(r'の$'), '');
    text = text.replaceAll(RegExp(r'^を'), '');
    text = text.replaceAll(RegExp(r'を$'), '');
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ');
    return text.trim();
  }

  /// [category] × [angle] の blocklist に該当するか
  bool isBlocked(Map<String, String> picks) {
    if (blocklist.isEmpty) {
      return false;
    }
    final category = picks['category'];
    final angle = picks['angle'];
    if (category == null || angle == null) {
      return false;
    }
    for (final rule in blocklist) {
      if (rule.length >= 2 && category == rule[0] && angle == rule[1]) {
        return true;
      }
    }
    return false;
  }
}
