import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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

  @override
  Widget build(BuildContext context) {
    if (selectedTheme != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              selectedTheme!,
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _black,
              ),
              speed: const Duration(milliseconds: 50),
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
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

