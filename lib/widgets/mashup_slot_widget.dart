import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// マッシュアップの 1 軸スロット（縦スライド風の切り替え）
class MashupSlotWidget extends StatelessWidget {
  final String axisLabel;
  final String? value;
  final bool spinning;
  final bool locked;
  final String lockTooltip;
  final String unlockTooltip;
  final VoidCallback? onToggleLock;

  const MashupSlotWidget({
    super.key,
    required this.axisLabel,
    required this.value,
    required this.spinning,
    required this.locked,
    required this.lockTooltip,
    required this.unlockTooltip,
    required this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final display = value ?? '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: HomePalette.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked
              ? HomePalette.accent.withValues(alpha: 0.6)
              : HomePalette.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  axisLabel,
                  style: GoogleFonts.zenKakuGothicNew(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRect(
                  child: SizedBox(
                    height: 54,
                    child: AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: spinning ? 80 : 220,
                      ),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0, 0.45),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(
                          position: slide,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Align(
                        key: ValueKey<String>('$display-$spinning'),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          display,
                          maxLines: 2,
                          style: GoogleFonts.zenKakuGothicNew(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: spinning
                                ? HomePalette.textMuted
                                : HomePalette.text,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleLock,
            tooltip: locked ? unlockTooltip : lockTooltip,
            icon: Icon(
              locked ? Icons.lock : Icons.lock_open,
              size: 20,
              color: locked ? HomePalette.accent : HomePalette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
