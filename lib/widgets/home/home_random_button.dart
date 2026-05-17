import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

class HomeRandomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const HomeRandomButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<HomeRandomButton> createState() => _HomeRandomButtonState();
}

class _HomeRandomButtonState extends State<HomeRandomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  double _diceRotation(double t) {
    if (t < 0.8) return 0;
    if (t < 0.85) return -0.26;
    if (t < 0.92) return 0.26;
    if (t < 0.96) return -0.14;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: HomePalette.randomButtonGradient,
              boxShadow: [
                BoxShadow(
                  color: HomePalette.accent.withValues(alpha: 0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.6],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _wiggle,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _diceRotation(_wiggle.value),
                            child: child,
                          );
                        },
                        child: const Text('🎲', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: GoogleFonts.zenKakuGothicNew(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: HomePalette.bg,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
