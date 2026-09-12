/// マッシュアップの 1 軸（テーマ / 切り口 / 制約）
class MashupAxis {
  final String id;
  final String label;
  final List<String> items;

  /// セッション設定でオフにできる軸（制約軸など）
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
  String compose(Map<String, String> picks) {
    final hasConstraint =
        (picks[mashupConstraintAxisId] ?? '').isNotEmpty;
    var text = hasConstraint ? template : templateWithoutConstraint;
    for (final axis in axes) {
      text = text.replaceAll('{${axis.id}}', picks[axis.id] ?? '');
    }
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
