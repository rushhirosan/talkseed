import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/bingo_deck.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

const Color bingoAccent = Color(0xFF4ECDC4);

const List<Color> bingoPlayerColors = [
  Color(0xFF4ECDC4),
  Color(0xFFFFB347),
  Color(0xFFA78BFA),
  Color(0xFFFF6B6B),
  Color(0xFF6BCB77),
  Color(0xFF4D96FF),
  Color(0xFFFF85C0),
  Color(0xFFE8E87C),
  Color(0xFF98D8C8),
];

Color bingoPlayerColor(int playerIndex) =>
    bingoPlayerColors[playerIndex % bingoPlayerColors.length];

/// 3×3 会話ビンゴの盤面
class BingoBoardWidget extends StatelessWidget {
  final BingoBoard board;
  final int? selectedIndex;
  final Set<int> hotCells;
  final int? freeCenterIndex;
  final int? bonusIndex;
  final int? blockedIndex;
  final bool adjacentOnly;
  final bool flipMode;
  final Set<int> revealedIndices;
  final ValueChanged<int> onSelect;

  const BingoBoardWidget({
    super.key,
    required this.board,
    required this.selectedIndex,
    this.hotCells = const {},
    this.freeCenterIndex,
    this.bonusIndex,
    this.blockedIndex,
    this.adjacentOnly = false,
    this.flipMode = false,
    this.revealedIndices = const {},
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final winning = board.cellsInCompletedLines;
    final compact = board.size >= BingoBoard.sizeLarge;
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        children: [
          for (var row = 0; row < board.size; row++) ...[
            if (row > 0) SizedBox(height: compact ? 2 : 8),
            Expanded(
              child: Row(
                children: [
                  for (var col = 0; col < board.size; col++) ...[
                    if (col > 0)
                      SizedBox(
                        width: compact ? 2 : 8,
                      ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final index = row * board.size + col;
                          final marked = board.isMarked(index);
                          final jammed = blockedIndex == index && !marked;
                          final selectable = !marked &&
                              !jammed &&
                              board.canSelect(
                                index,
                                adjacentOnly: adjacentOnly,
                              );
                          final owner = board.ownerOf(index);
                          final revealed = !flipMode ||
                              marked ||
                              revealedIndices.contains(index);
                          return _BingoCell(
                            prompt: board.cells[index],
                            selected: selectedIndex == index,
                            marked: marked,
                            hidden: !revealed,
                            hot: hotCells.contains(index),
                            isFreeCenter: freeCenterIndex == index && marked,
                            isBonus: bonusIndex == index && !marked,
                            jammed: jammed,
                            dimmed: !marked && (!selectable || jammed),
                            inWinningLine: winning.contains(index),
                            compact: board.size >= BingoBoard.sizeLarge,
                            ownerColor: owner == null
                                ? null
                                : bingoPlayerColor(owner),
                            ownerNumber: owner == null ? null : owner + 1,
                            onTap: () => onSelect(index),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BingoCell extends StatelessWidget {
  final BingoPrompt prompt;
  final bool selected;
  final bool marked;
  final bool hidden;
  final bool hot;
  final bool isFreeCenter;
  final bool isBonus;
  final bool jammed;
  final bool dimmed;
  final bool inWinningLine;
  final bool compact;
  final Color? ownerColor;
  final int? ownerNumber;
  final VoidCallback onTap;

  const _BingoCell({
    required this.prompt,
    required this.selected,
    required this.marked,
    required this.hidden,
    required this.hot,
    required this.isFreeCenter,
    required this.isBonus,
    required this.jammed,
    required this.dimmed,
    required this.inWinningLine,
    required this.compact,
    required this.ownerColor,
    required this.ownerNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ownerColor ?? bingoAccent;
    final borderColor = jammed
        ? HomePalette.accentCoral.withValues(alpha: 0.85)
        : selected
            ? bingoAccent
            : isBonus
                ? HomePalette.accent.withValues(alpha: 0.9)
                : hot
                    ? HomePalette.accentOrange.withValues(alpha: 0.85)
                    : inWinningLine
                        ? accent.withValues(alpha: 0.7)
                        : HomePalette.border;
    final fill = marked
        ? accent.withValues(alpha: inWinningLine ? 0.28 : 0.16)
        : jammed
            ? HomePalette.accentCoral.withValues(alpha: 0.1)
            : hidden
                ? HomePalette.surface
                : isBonus
                    ? HomePalette.accent.withValues(alpha: 0.1)
                    : hot
                        ? HomePalette.accentOrange.withValues(alpha: 0.1)
                        : selected
                            ? bingoAccent.withValues(alpha: 0.14)
                            : HomePalette.surface2;

    return Opacity(
      opacity: dimmed ? 0.38 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: marked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(compact ? 8 : 12),
              border: Border.all(
                color: borderColor,
                width: selected || hot || inWinningLine || isBonus || jammed
                    ? 1.8
                    : 1,
              ),
              boxShadow: hot || isBonus
                  ? [
                      BoxShadow(
                        color: (isBonus
                                ? HomePalette.accent
                                : HomePalette.accentOrange)
                            .withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 2 : 8,
                    compact ? 4 : 10,
                    compact ? 2 : 8,
                    compact ? 4 : 10,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: hidden
                          ? Text(
                              AppLocalizations.of(context)!
                                  .bingoFlipHiddenBadge,
                              key: const ValueKey('hidden'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.zenKakuGothicNew(
                                fontSize: compact ? 16 : 20,
                                fontWeight: FontWeight.w800,
                                color: HomePalette.textMuted,
                                height: 1,
                              ),
                            )
                          : Text(
                              isFreeCenter
                                  ? AppLocalizations.of(context)!
                                      .bingoFreeCenterBadge
                                  : prompt.text,
                              key: ValueKey(prompt.id),
                              textAlign: TextAlign.center,
                              maxLines: compact ? 4 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.zenKakuGothicNew(
                                fontSize: isFreeCenter
                                    ? (compact ? 10 : 14)
                                    : (compact ? 9 : 12),
                                fontWeight: selected || marked || isFreeCenter
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.2,
                                color: marked
                                    ? HomePalette.text.withValues(alpha: 0.7)
                                    : HomePalette.text,
                              ),
                            ),
                    ),
                  ),
                ),
                if (marked && !isFreeCenter)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(
                      Icons.check_circle,
                      size: compact ? 12 : 16,
                      color: accent.withValues(alpha: 0.9),
                    ),
                  ),
                if (isFreeCenter)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(
                      Icons.star_rounded,
                      size: compact ? 12 : 16,
                      color: bingoAccent.withValues(alpha: 0.9),
                    ),
                  ),
                if (isBonus)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      size: compact ? 12 : 16,
                      color: HomePalette.accent.withValues(alpha: 0.95),
                    ),
                  ),
                if (jammed)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Icon(
                      Icons.lock_rounded,
                      size: compact ? 12 : 16,
                      color: HomePalette.accentCoral.withValues(alpha: 0.95),
                    ),
                  ),
                if (ownerNumber != null)
                  Positioned(
                    left: 3,
                    bottom: 3,
                    child: Container(
                      width: compact ? 13 : 16,
                      height: compact ? 13 : 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$ownerNumber',
                        style: GoogleFonts.zenKakuGothicNew(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: HomePalette.bg,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
