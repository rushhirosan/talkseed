import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// プレイヤー情報を表示するウィジェット
class PlayerIndicator extends StatelessWidget {
  final int currentPlayerIndex;
  final int totalPlayers;
  final String? currentPlayerName;
  final bool useHomeStyle;

  static String turnDisplayText({
    required AppLocalizations l10n,
    required int currentPlayerIndex,
    required int totalPlayers,
    String? currentPlayerName,
  }) {
    if (currentPlayerName != null) {
      return '$currentPlayerName (${currentPlayerIndex + 1}/$totalPlayers)';
    }
    return l10n.currentPlayer(currentPlayerIndex + 1, totalPlayers);
  }

  const PlayerIndicator({
    super.key,
    required this.currentPlayerIndex,
    required this.totalPlayers,
    this.currentPlayerName,
    this.useHomeStyle = false,
  });

  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ts = context.talkShuffle;
    final displayText = turnDisplayText(
      l10n: l10n,
      currentPlayerIndex: currentPlayerIndex,
      totalPlayers: totalPlayers,
      currentPlayerName: currentPlayerName,
    );

    if (useHomeStyle) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: HomePalette.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HomePalette.accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, color: HomePalette.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: GoogleFonts.zenKakuGothicNew(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomePalette.text,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ts.brandYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, color: _black, size: 20),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _black,
            ),
          ),
        ],
      ),
    );
  }
}
