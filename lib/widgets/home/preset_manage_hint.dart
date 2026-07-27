import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/play/play_session_ui.dart';

/// プリセットの長押し削除など、操作ヒント用の1行テキスト
class PresetManageHint extends StatelessWidget {
  final String text;

  /// ホーム系画面 vs プレイ系画面（1on1 設定など）
  final bool usePlayStyle;

  const PresetManageHint({
    super.key,
    required this.text,
    this.usePlayStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        usePlayStyle ? PlayColors.textMuted : HomePalette.textMuted;
    final textStyle = usePlayStyle
        ? PlayTextStyles.hint()
        : GoogleFonts.zenKakuGothicNew(
            fontSize: 12,
            color: HomePalette.textMuted,
            height: 1.4,
          );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.touch_app_outlined,
              size: 15,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: textStyle),
          ),
        ],
      ),
    );
  }
}
