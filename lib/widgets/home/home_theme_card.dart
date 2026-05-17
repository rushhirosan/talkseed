import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

class HomeThemeCard extends StatefulWidget {
  final String emoji;
  final String name;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;
  final int animationIndex;

  const HomeThemeCard({
    super.key,
    required this.emoji,
    required this.name,
    required this.description,
    required this.accentColor,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  State<HomeThemeCard> createState() => _HomeThemeCardState();
}

class _HomeThemeCardState extends State<HomeThemeCard> {
  bool _hovered = false;
  bool _pressed = false;

  static const _curve = Cubic(0.34, 1.56, 0.64, 1);
  static const _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final showAccent = _hovered || _pressed;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + widget.animationIndex * 100),
      curve: const Cubic(0.22, 1, 0.36, 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - value)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: _duration,
              curve: _curve,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: _hovered ? HomePalette.surface2 : HomePalette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hovered
                      ? Colors.white.withValues(alpha: 0.12)
                      : HomePalette.border,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 3,
                    height: 44,
                    child: AnimatedOpacity(
                      duration: _duration,
                      curve: _curve,
                      opacity: showAccent ? 1 : 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedScale(
                        scale: _hovered ? 1.08 : 1,
                        duration: _duration,
                        curve: _curve,
                        alignment: Alignment.center,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: HomePalette.border),
                          ),
                          child: Center(
                            child: Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.zenKakuGothicNew(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: HomePalette.text,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.description,
                          style: GoogleFonts.zenKakuGothicNew(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: HomePalette.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                    child: AnimatedPadding(
                      padding: EdgeInsets.only(left: _hovered ? 4 : 0),
                      duration: _duration,
                      curve: _curve,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: _hovered
                            ? HomePalette.text
                            : HomePalette.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
