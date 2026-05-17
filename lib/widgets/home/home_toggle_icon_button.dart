import 'package:flutter/material.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// 設定・セッション画面向けのトグル可能な正方形アイコンボタン。
class HomeToggleIconButton extends StatelessWidget {
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;
  final IconData icon;
  final double size;

  const HomeToggleIconButton({
    super.key,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
    required this.icon,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (size * 0.5).clamp(18.0, 24.0);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? HomePalette.accent : HomePalette.surface2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? HomePalette.accent
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: enabled ? HomePalette.bg : HomePalette.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// 親の幅に合わせて 3 つのアイコンを均等配置（はみ出し防止）。
class HomeToggleIconButtonRow extends StatelessWidget {
  final List<HomeToggleIconButton> children;
  final double gap;

  const HomeToggleIconButtonRow({
    super.key,
    required this.children,
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = children.length;
        if (count == 0) return const SizedBox.shrink();

        final available = constraints.maxWidth;
        const maxSize = 48.0;
        const minSize = 36.0;
        final size = available.isFinite && available > 0
            ? ((available - gap * (count - 1)) / count).clamp(minSize, maxSize)
            : maxSize;

        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(width: gap),
              HomeToggleIconButton(
                tooltip: children[i].tooltip,
                enabled: children[i].enabled,
                onPressed: children[i].onPressed,
                icon: children[i].icon,
                size: size,
              ),
            ],
          ],
        );
      },
    );
  }
}
