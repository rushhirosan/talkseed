import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/widgets/home/home_ambient_background.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// トップ画面と同じダーク背景・ヘッダーを使うサブ画面用スキャフォールド。
class HomeScaffold extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget body;
  final bool resizeToAvoidBottomInset;

  const HomeScaffold({
    super.key,
    this.title,
    this.leading,
    this.actions,
    required this.body,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: HomePalette.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: HomeAmbientBackground()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: _HomeAppBar(
                  title: title,
                  leading: leading,
                  actions: actions,
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;

  const _HomeAppBar({
    this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
          decoration: const BoxDecoration(
            color: HomePalette.headerBg,
            border: Border(bottom: BorderSide(color: HomePalette.border)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 96),
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.zenKakuGothicNew(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: HomePalette.text,
                    ),
                  ),
                ),
              Row(
                children: [
                  if (leading != null) leading! else const SizedBox(width: 48),
                  const Spacer(),
                  if (actions != null)
                    Row(mainAxisSize: MainAxisSize.min, children: actions!)
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 戻るボタン（ヘッダー左）
class HomeBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const HomeBackButton({
    super.key,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: HomePalette.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: HomePalette.border),
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: HomePalette.textMuted,
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

/// ヘッダー右のアイコンボタン
class HomeHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const HomeHeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: HomePalette.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HomePalette.border),
            ),
            child: Icon(icon, size: 20, color: HomePalette.textMuted),
          ),
        ),
      ),
    );
  }
}
