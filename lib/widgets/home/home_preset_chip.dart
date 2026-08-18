import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/utils/preset_display.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// ホーム・1on1 設定画面で使う保存済みプリセットのチップ
class HomePresetChip extends StatelessWidget {
  final SessionPreset preset;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  /// Quick Start / ライブラリ向けにモードバッジを表示
  final bool showModeBadge;

  /// バッジ表示時はサブタイトルを省略してコンパクトに
  final bool compact;

  const HomePresetChip({
    super.key,
    required this.preset,
    required this.l10n,
    required this.onTap,
    this.onDelete,
    this.showModeBadge = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = preset.configSummary(l10n);
    final showSubtitle = !compact || !showModeBadge;

    return Material(
      color: HomePalette.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 168,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: HomePalette.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showModeBadge) ...[
                _ModeBadge(
                  label: preset.modeLabel(l10n),
                  mode: preset.mode,
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  Icon(
                    preset.modeIcon(),
                    size: 18,
                    color: preset.modeAccentColor(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      preset.name,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.zenKakuGothicNew(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.text,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              if (showSubtitle) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.zenKakuGothicNew(
                    fontSize: 11,
                    height: 1.2,
                    color: HomePalette.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  final String label;
  final SessionPresetMode mode;

  const _ModeBadge({
    required this.label,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: presetModeBadgeBackground(mode),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.zenKakuGothicNew(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: presetModeBadgeForeground(mode),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
