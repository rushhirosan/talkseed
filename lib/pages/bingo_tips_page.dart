import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/widgets/bingo_board_widget.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';

/// 会話ビンゴの遊び方ヒント（ページめくり）
class BingoTipsPage extends StatefulWidget {
  const BingoTipsPage({super.key});

  @override
  State<BingoTipsPage> createState() => _BingoTipsPageState();
}

class _BingoTipsPageState extends State<BingoTipsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<_BingoTipPage>? _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pages == null) {
      final l10n = AppLocalizations.of(context)!;
      _pages = [
        _BingoTipPage(
          icon: Icons.grid_3x3_rounded,
          title: l10n.bingoTipBasicTitle,
          body: l10n.bingoTipBasicBody,
        ),
        _BingoTipPage(
          icon: Icons.local_fire_department_rounded,
          title: l10n.bingoTipBoardTitle,
          body: l10n.bingoTipBoardBody,
        ),
        _BingoTipPage(
          icon: Icons.stars_rounded,
          title: l10n.bingoTipScoreTitle,
          body: l10n.bingoTipScoreBody,
        ),
        _BingoTipPage(
          icon: Icons.tune_rounded,
          title: l10n.bingoTipRulesTitle,
          body: l10n.bingoTipRulesBody,
        ),
        _BingoTipPage(
          icon: Icons.flag_rounded,
          title: l10n.bingoTipEndTitle,
          body: l10n.bingoTipEndBody,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    final pages = _pages;
    if (pages == null) return;
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages ?? const <_BingoTipPage>[];

    return HomeScaffold(
      title: l10n.bingoTipsTitle,
      leading: HomeBackButton(onPressed: () => Navigator.of(context).pop()),
      body: pages.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: bingoAccent),
            )
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Column(
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: bingoAccent.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: bingoAccent.withValues(alpha: 0.45),
                                      ),
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 40,
                                      color: bingoAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    page.title,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.zenKakuGothicNew(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: HomePalette.text,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    page.body,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.zenKakuGothicNew(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: HomePalette.textSecondary,
                                      height: 1.65,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < pages.length; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: i == _currentPage ? 18 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: i == _currentPage
                                      ? bingoAccent
                                      : HomePalette.textMuted,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: IconButton(
                                onPressed: _currentPage > 0 ? _goPrev : null,
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: _currentPage > 0
                                      ? HomePalette.text
                                      : HomePalette.textMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              child: HomePrimaryButton(
                                label: _currentPage < pages.length - 1
                                    ? l10n.valueNext
                                    : l10n.dismiss,
                                onPressed: _goNext,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _BingoTipPage {
  final IconData icon;
  final String title;
  final String body;

  const _BingoTipPage({
    required this.icon,
    required this.title,
    required this.body,
  });
}
