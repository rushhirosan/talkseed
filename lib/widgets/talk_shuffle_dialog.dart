import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// ダーク UI 向けの共通 [AlertDialog]。
///
/// グローバル Theme が light のままでも、白地×白文字や黒字×暗背景にならないよう
/// 背景・文字色をここで固定する。
class TalkShuffleAlertDialog extends StatelessWidget {
  const TalkShuffleAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.actionsAlignment,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final MainAxisAlignment? actionsAlignment;

  static TextStyle get titleStyle => GoogleFonts.zenKakuGothicNew(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: HomePalette.text,
      );

  static TextStyle get contentStyle => GoogleFonts.zenKakuGothicNew(
        fontSize: 14,
        height: 1.4,
        color: HomePalette.textSecondary,
      );

  static TextStyle get actionStyle => GoogleFonts.zenKakuGothicNew(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: HomePalette.accent,
      );

  static InputDecoration inputDecoration({
    String? hintText,
    TextStyle? hintStyle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle ??
          GoogleFonts.zenKakuGothicNew(
            fontSize: 14,
            color: HomePalette.textMuted,
          ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: HomePalette.border),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: HomePalette.accent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          surface: HomePalette.surface,
          onSurface: HomePalette.text,
          onSurfaceVariant: HomePalette.textSecondary,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: HomePalette.text,
          displayColor: HomePalette.text,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: HomePalette.accent,
            textStyle: actionStyle,
          ),
        ),
      ),
      child: AlertDialog(
        backgroundColor: HomePalette.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: titleStyle,
        contentTextStyle: contentStyle,
        title: title,
        content: content,
        actionsAlignment: actionsAlignment,
        actions: actions,
      ),
    );
  }
}

/// ダーク UI 向けボトムシートの見た目を揃える。
Future<T?> showTalkShuffleModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  Color backgroundColor = HomePalette.surface,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final base = Theme.of(ctx);
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            surface: backgroundColor,
            onSurface: HomePalette.text,
            onSurfaceVariant: HomePalette.textSecondary,
          ),
          textTheme: base.textTheme.apply(
            bodyColor: HomePalette.text,
            displayColor: HomePalette.text,
          ),
          iconTheme: const IconThemeData(color: HomePalette.textSecondary),
          listTileTheme: ListTileThemeData(
            iconColor: HomePalette.textSecondary,
            textColor: HomePalette.text,
            titleTextStyle: GoogleFonts.zenKakuGothicNew(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HomePalette.text,
            ),
            subtitleTextStyle: GoogleFonts.zenKakuGothicNew(
              fontSize: 13,
              height: 1.35,
              color: HomePalette.textSecondary,
            ),
          ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return HomePalette.accent;
              }
              return HomePalette.textMuted;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return HomePalette.accent.withValues(alpha: 0.35);
              }
              return HomePalette.surface2;
            }),
          ),
        ),
        child: DefaultTextStyle(
          style: GoogleFonts.zenKakuGothicNew(
            fontSize: 14,
            height: 1.4,
            color: HomePalette.text,
          ),
          child: builder(ctx),
        ),
      );
    },
  );
}
