/// チェックイン・チェックアウトの問い1件（難易度付き）
class CheckInCheckOutItem {
  final String text;
  final CheckInLevel level;

  const CheckInCheckOutItem({required this.text, required this.level});
}

/// 問いの難易度（初級・中級・上級）
enum CheckInLevel {
  beginner,
  intermediate,
  advanced,
}

extension CheckInLevelExtension on CheckInLevel {
  /// 表示用ラベル（l10n で上書きする想定のため、フォールバック用）
  String get label {
    switch (this) {
      case CheckInLevel.beginner:
        return '初級';
      case CheckInLevel.intermediate:
        return '中級';
      case CheckInLevel.advanced:
        return '上級';
    }
  }
}
