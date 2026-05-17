import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';
import 'package:theme_dice/widgets/player_indicator.dart';

/// 価値観カード・グループディスカッションなどプレイ画面で共通のレイアウト・スタイル。
class PlaySessionScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final String? backTooltip;
  final Widget body;
  final bool resizeToAvoidBottomInset;

  const PlaySessionScaffold({
    super.key,
    required this.title,
    required this.onBack,
    this.backTooltip,
    required this.body,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final playTheme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        onSurface: PlayColors.text,
        onSurfaceVariant: PlayColors.textSecondary,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: PlayColors.text,
        displayColor: PlayColors.text,
      ),
    );

    return HomeScaffold(
      title: title,
      leading: HomeBackButton(
        onPressed: onBack,
        tooltip: kIsWeb ? '' : backTooltip,
      ),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Theme(
        data: playTheme,
        child: DefaultTextStyle(
          style: GoogleFonts.zenKakuGothicNew(
            fontSize: 14,
            height: 1.4,
            color: PlayColors.text,
          ),
          child: body,
        ),
      ),
    );
  }
}

/// プレイ画面共通色（セッション設定などと同じ [HomePalette]）。
abstract final class PlayColors {
  static const text = HomePalette.text;
  /// ダーク背景でも読める補助テキスト（[HomePalette.textMuted] より明るめ）
  static const textSecondary = Color(0xFFB8B8D4);
  static const textMuted = HomePalette.textMuted;
  static const surface = HomePalette.surface2;
  static const border = HomePalette.border;
  static const accent = HomePalette.accent;
}

abstract final class PlayTextStyles {
  /// [emphasis] 1.0 = そのまま、それ未満は不透明度で弱める（旧ライトテーマ API 互換）
  static Color _emphasis(Color base, double emphasis) {
    if (emphasis >= 1) return base;
    return base.withValues(alpha: emphasis.clamp(0.35, 1.0));
  }

  static TextStyle _base({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.4,
    required Color color,
  }) {
    return GoogleFonts.zenKakuGothicNew(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle appBarTitle() => _base(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: PlayColors.text,
      );

  static TextStyle hint([double emphasis = 0.88]) => _base(
        fontSize: 14,
        color: _emphasis(PlayColors.textSecondary, emphasis),
      );

  static TextStyle bodyEmphasis([double emphasis = 1]) => _base(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _emphasis(PlayColors.text, emphasis),
      );

  static TextStyle caption([double emphasis = 0.88]) => _base(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _emphasis(PlayColors.textSecondary, emphasis),
      );

  static TextStyle sectionTitle([double emphasis = 1]) => _base(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: _emphasis(PlayColors.text, emphasis),
      );

  /// 議論お題など、大きめの本文
  static TextStyle prompt({double fontSize = 17, double emphasis = 1}) => _base(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.45,
        color: _emphasis(PlayColors.text, emphasis),
      );

  static TextStyle timerNote([double emphasis = 0.88]) => _base(
        fontSize: 12,
        height: 1.35,
        color: _emphasis(PlayColors.textSecondary, emphasis),
      );

  static TextStyle playerBanner() => _base(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: HomePalette.bg,
      );

  static TextStyle listItem() => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: PlayColors.text,
      );

  static TextStyle buttonLabel() => GoogleFonts.zenKakuGothicNew(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: HomePalette.bg,
        letterSpacing: 0.3,
      );
}

/// ディスカッション画面と同じ 1 本スクロールの本文。
class PlayPageScroll extends StatelessWidget {
  final List<Widget> children;
  final double bottomPadding;

  const PlayPageScroll({
    super.key,
    required this.children,
    this.bottomPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        playScreenHorizontalPadding,
        playScreenVerticalPadding,
        playScreenHorizontalPadding,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// プレイ画面共通の黄 CTA（ホーム画面と同系統）。
class PlayPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PlayPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return Opacity(
        opacity: 0.45,
        child: _buildButton(onPressed: () {}),
      );
    }
    return _buildButton(onPressed: onPressed!);
  }

  Widget _buildButton({required VoidCallback onPressed}) {
    return HomePrimaryButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}

class PlayOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PlayOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: PlayColors.text,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: PlayColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.zenKakuGothicNew(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: PlayColors.text,
          ),
        ),
      ),
    );
  }
}

class PlaySurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  const PlaySurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.minHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: PlayColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PlayColors.border),
      ),
      child: child,
    );
  }
}

const double playScreenHorizontalPadding = 20;
const double playScreenVerticalPadding = 12;

/// プレイヤーの番（黄バナー）。
class PlayPlayerBanner extends StatelessWidget {
  final int currentPlayerIndex;
  final int totalPlayers;
  final String? currentPlayerName;

  const PlayPlayerBanner({
    super.key,
    required this.currentPlayerIndex,
    required this.totalPlayers,
    this.currentPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayText = PlayerIndicator.turnDisplayText(
      l10n: l10n,
      currentPlayerIndex: currentPlayerIndex,
      totalPlayers: totalPlayers,
      currentPlayerName: currentPlayerName,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: HomePalette.accentGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HomePalette.accent.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: HomePalette.bg, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              style: PlayTextStyles.playerBanner(),
            ),
          ),
        ],
      ),
    );
  }
}

/// タイマー（ダークサーフェス・中央表示）。
class PlayTimerPanel extends StatelessWidget {
  final TimerService timerService;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onExtendOneMinute;

  const PlayTimerPanel({
    super.key,
    required this.timerService,
    this.onPause,
    this.onResume,
    this.onExtendOneMinute,
  });

  static const Color _timeUpBorder = Color(0xFFFF6B6B);
  static const Color _timeUpBg = Color(0x33FF6B6B);

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _timeColor(Duration remaining, bool timeUp) {
    if (timeUp) return _timeUpBorder;
    final sec = remaining.inSeconds;
    if (sec <= 10) return const Color(0xFFFF6B6B);
    if (sec <= 30) return HomePalette.accentOrange;
    return PlayColors.text;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = timerService.remainingTime;
    final timeUp = timerService.hasFinished;
    final isRunning = timerService.isRunning;
    final isPaused = timerService.isPaused;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: timeUp ? _timeUpBg : PlayColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: timeUp ? _timeUpBorder : PlayColors.border,
          width: timeUp ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _format(remaining),
                style: GoogleFonts.zenKakuGothicNew(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _timeColor(remaining, timeUp),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (!timeUp) ...[
                const SizedBox(width: 4),
                if (isRunning && !isPaused)
                  IconButton(
                    icon: const Icon(Icons.pause, color: PlayColors.textMuted),
                    onPressed: onPause,
                    tooltip: l10n.pause,
                  )
                else if (isPaused)
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: PlayColors.textMuted),
                    onPressed: onResume,
                    tooltip: l10n.resume,
                  ),
              ],
            ],
          ),
          if (timeUp) ...[
            const SizedBox(height: 4),
            Text(
              l10n.timerTimeUp,
              style: PlayTextStyles.caption().copyWith(color: _timeUpBorder),
            ),
            if (onExtendOneMinute != null)
              TextButton(
                onPressed: onExtendOneMinute,
                child: Text(
                  l10n.timerExtendOneMinute,
                  style: PlayTextStyles.timerNote().copyWith(
                    color: _timeUpBorder,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class PlayReorderListTile extends StatelessWidget {
  final int index;
  final int rank;
  final String text;
  final bool isLast;
  final String? trailingLabel;

  const PlayReorderListTile({
    super.key,
    required this.index,
    required this.rank,
    required this.text,
    this.isLast = false,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLast ? HomePalette.surface : PlayColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLast
              ? PlayColors.textMuted.withValues(alpha: 0.5)
              : PlayColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HomePalette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PlayColors.border),
              ),
              child: const Icon(
                Icons.drag_handle,
                color: PlayColors.textMuted,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$rank. $text',
              style: PlayTextStyles.listItem(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              trailingLabel!,
              style: PlayTextStyles.timerNote(),
            ),
          ],
        ],
      ),
    );
  }
}
