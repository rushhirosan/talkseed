import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// テーマ表示ウィジェット
class ThemeDisplay extends StatelessWidget {
  final String? selectedTheme;

  const ThemeDisplay({
    super.key,
    this.selectedTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTheme != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              selectedTheme!,
              textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ) ?? const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
              speed: const Duration(milliseconds: 50),
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'サイコロをタップして\nテーマを選ぼう！',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }
  }
}

