import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

/// テーマ表示ウィジェット
class ThemeDisplay extends StatelessWidget {
  final String? selectedTheme;
  /// true: カードモード用のプロンプト（「下のボタンで1枚引こう」）
  /// false: サイコロモード用のプロンプト（「サイコロをタップして」）
  final bool useCardPrompt;

  const ThemeDisplay({
    super.key,
    this.selectedTheme,
    this.useCardPrompt = false,
  });

  // カラーパレット（設定画面と統一）
  static const Color _black = Colors.black87;
  static const Color _white = Colors.white;
  static const Color _mustardYellow = Color(0xFFFFEB3B);

  @override
  Widget build(BuildContext context) {
    if (selectedTheme != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: _BounceThemeResult(
          key: ValueKey(selectedTheme),
          selectedTheme: selectedTheme!,
        ),
      );
    } else {
      final l10n = AppLocalizations.of(context)!;
      final prompt = useCardPrompt
          ? l10n.selectThemePromptCard
          : l10n.selectThemePrompt;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          prompt,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: _black.withOpacity(0.7),
          ),
        ),
      );
    }
  }
}

/// バウンスアニメーション付きのテーマ結果表示
/// サイコロが止まったような弾む演出で「このテーマが出たー！」を表示
class _BounceThemeResult extends StatelessWidget {
  final String selectedTheme;

  const _BounceThemeResult({
    super.key,
    required this.selectedTheme,
  });

  static const Color _black = Colors.black87;
  static const Color _white = Colors.white;
  static const Color _mustardYellow = Color(0xFFFFEB3B);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _black.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: _black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          selectedTheme,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _black,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
