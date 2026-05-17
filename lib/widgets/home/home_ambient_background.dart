import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// トップ画面のぼかしグロー（blob）
class HomeAmbientBackground extends StatefulWidget {
  const HomeAmbientBackground({super.key});

  @override
  State<HomeAmbientBackground> createState() => _HomeAmbientBackgroundState();
}

class _HomeAmbientBackgroundState extends State<HomeAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 背面ルートのアニメーションが前面のレイアウトと競合しないよう、表示中のみ tick
    final routeActive = ModalRoute.of(context)?.isCurrent ?? true;
    final size = MediaQuery.sizeOf(context);
    return TickerMode(
      enabled: routeActive,
      child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _blob(
              color: HomePalette.accent,
              size: 500,
              top: -200 + 30 * t,
              right: -100 + 20 * t,
              opacity: 0.15,
            ),
            _blob(
              color: HomePalette.purple,
              size: 400,
              bottom: -150 - 40 * t,
              left: -100 + 30 * t,
              opacity: 0.15,
            ),
            _blob(
              color: HomePalette.accentCoral,
              size: 300,
              top: size.height * 0.35 + 40 * t,
              left: size.width * 0.25 + 30 * t,
              opacity: 0.07,
            ),
          ],
        );
      },
    ),
    );
  }

  Widget _blob({
    required Color color,
    required double size,
    double? top,
    double? right,
    double? bottom,
    double? left,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}
