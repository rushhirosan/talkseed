import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// テーマ表示ウィジェット
class ThemeDisplay extends StatelessWidget {
  final String? selectedTheme;
  /// true: カードモード用のプロンプト（「下のボタンで1枚引こう」）
  /// false: サイコロモード用のプロンプト（「サイコロをタップして」）
  final bool useCardPrompt;
  /// トップ画面と同じダーク UI
  final bool useHomeStyle;

  const ThemeDisplay({
    super.key,
    this.selectedTheme,
    this.useCardPrompt = false,
    this.useHomeStyle = false,
  });

  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    if (selectedTheme != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: _BounceThemeResult(
          key: ValueKey(selectedTheme),
          selectedTheme: selectedTheme!,
          useHomeStyle: useHomeStyle,
        ),
      );
    }
    final l10n = AppLocalizations.of(context)!;
    final prompt = useCardPrompt
        ? l10n.selectThemePromptCard
        : l10n.selectThemePrompt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        prompt,
        textAlign: TextAlign.center,
        style: useHomeStyle
            ? GoogleFonts.zenKakuGothicNew(
                fontSize: 16,
                color: HomePalette.textMuted,
              )
            : TextStyle(
                fontSize: 16,
                color: _black.withValues(alpha: 0.7),
              ),
      ),
    );
  }
}

class _BounceThemeResult extends StatelessWidget {
  final String selectedTheme;
  final bool useHomeStyle;

  const _BounceThemeResult({
    super.key,
    required this.selectedTheme,
    this.useHomeStyle = false,
  });

  static const Color _black = Colors.black87;
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final bg = useHomeStyle ? HomePalette.surface2 : _white;
    final border = useHomeStyle
        ? HomePalette.border
        : _black.withValues(alpha: 0.2);
    final textColor = useHomeStyle ? HomePalette.text : _black;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
          boxShadow: useHomeStyle
              ? null
              : [
                  BoxShadow(
                    color: _black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Text(
          selectedTheme,
          style: useHomeStyle
              ? GoogleFonts.zenKakuGothicNew(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.4,
                )
              : const TextStyle(
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
