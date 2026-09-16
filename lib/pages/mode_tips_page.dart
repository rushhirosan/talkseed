import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/widgets/bingo_board_widget.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';

/// 各モードの遊び方ヒント種別
enum ModeTipsKind {
  dice,
  valueCards,
  discussion,
  oneOnOne,
  mashup,
  bingo,
}

/// モード共通のヒント画面（ページめくり）
class ModeTipsPage extends StatefulWidget {
  final String title;
  final Color accent;
  final List<ModeTipPageData> pages;

  const ModeTipsPage({
    super.key,
    required this.title,
    required this.accent,
    required this.pages,
  });

  factory ModeTipsPage.forKind(ModeTipsKind kind, AppLocalizations l10n) {
    switch (kind) {
      case ModeTipsKind.dice:
        return ModeTipsPage(
          title: l10n.diceTipsTitle,
          accent: HomePalette.accent,
          pages: [
            ModeTipPageData(
              icon: Icons.casino,
              title: l10n.diceTipRollTitle,
              body: l10n.diceTipRollBody,
            ),
            ModeTipPageData(
              icon: Icons.groups_outlined,
              title: l10n.diceTipSessionTitle,
              body: l10n.diceTipSessionBody,
            ),
            ModeTipPageData(
              icon: Icons.history,
              title: l10n.diceTipHistoryTitle,
              body: l10n.diceTipHistoryBody,
            ),
          ],
        );
      case ModeTipsKind.valueCards:
        return ModeTipsPage(
          title: l10n.valuesTipsTitle,
          accent: HomePalette.purple,
          pages: [
            ModeTipPageData(
              icon: Icons.groups,
              title: l10n.valueTutorialPage1Title,
              body: l10n.valueTutorialPage1Body,
            ),
            ModeTipPageData(
              icon: Icons.reorder,
              title: l10n.valueTutorialPage2Title,
              body: l10n.valueTutorialPage2Body,
            ),
            ModeTipPageData(
              icon: Icons.share,
              title: l10n.valueTutorialPage3Title,
              body: l10n.valueTutorialPage3Body,
            ),
          ],
        );
      case ModeTipsKind.discussion:
        return ModeTipsPage(
          title: l10n.discussionTipsTitle,
          accent: HomePalette.accent,
          pages: [
            ModeTipPageData(
              icon: Icons.category_outlined,
              title: l10n.discussionTipSetupTitle,
              body: l10n.discussionTipSetupBody,
            ),
            ModeTipPageData(
              icon: Icons.forum_outlined,
              title: l10n.discussionTipPickTitle,
              body: l10n.discussionTipPickBody,
            ),
            ModeTipPageData(
              icon: Icons.timer_outlined,
              title: l10n.discussionTipFlowTitle,
              body: l10n.discussionTipFlowBody,
            ),
          ],
        );
      case ModeTipsKind.oneOnOne:
        return ModeTipsPage(
          title: l10n.oneOnOneTipsTitle,
          accent: HomePalette.accent,
          pages: [
            ModeTipPageData(
              icon: Icons.people_outline,
              title: l10n.oneOnOneTipFormatTitle,
              body: l10n.oneOnOneTipFormatBody,
            ),
            ModeTipPageData(
              icon: Icons.chat_bubble_outline,
              title: l10n.oneOnOneTipPhaseTitle,
              body: l10n.oneOnOneTipPhaseBody,
            ),
            ModeTipPageData(
              icon: Icons.checklist_outlined,
              title: l10n.oneOnOneTipReviewTitle,
              body: l10n.oneOnOneTipReviewBody,
            ),
          ],
        );
      case ModeTipsKind.mashup:
        return ModeTipsPage(
          title: l10n.mashupTipsTitle,
          accent: HomePalette.accentOrange,
          pages: [
            ModeTipPageData(
              icon: Icons.shuffle_rounded,
              title: l10n.mashupTipCombineTitle,
              body: l10n.mashupTipCombineBody,
            ),
            ModeTipPageData(
              icon: Icons.lock_outline,
              title: l10n.mashupTipLockTitle,
              body: l10n.mashupTipLockBody,
            ),
            ModeTipPageData(
              icon: Icons.groups_outlined,
              title: l10n.mashupTipTurnTitle,
              body: l10n.mashupTipTurnBody,
            ),
          ],
        );
      case ModeTipsKind.bingo:
        return ModeTipsPage(
          title: l10n.bingoTipsTitle,
          accent: bingoAccent,
          pages: [
            ModeTipPageData(
              icon: Icons.grid_3x3_rounded,
              title: l10n.bingoTipBasicTitle,
              body: l10n.bingoTipBasicBody,
            ),
            ModeTipPageData(
              icon: Icons.local_fire_department_rounded,
              title: l10n.bingoTipBoardTitle,
              body: l10n.bingoTipBoardBody,
            ),
            ModeTipPageData(
              icon: Icons.stars_rounded,
              title: l10n.bingoTipScoreTitle,
              body: l10n.bingoTipScoreBody,
            ),
            ModeTipPageData(
              icon: Icons.tune_rounded,
              title: l10n.bingoTipRulesTitle,
              body: l10n.bingoTipRulesBody,
            ),
            ModeTipPageData(
              icon: Icons.flag_rounded,
              title: l10n.bingoTipEndTitle,
              body: l10n.bingoTipEndBody,
            ),
          ],
        );
    }
  }

  /// 右上ヒントボタンなどから開く共通エントリ
  static Future<void> open(BuildContext context, ModeTipsKind kind) {
    final l10n = AppLocalizations.of(context)!;
    return Navigator.of(context).push<void>(
      RouteTransitions.forwardRoute(
        page: ModeTipsPage.forKind(kind, l10n),
      ),
    );
  }

  @override
  State<ModeTipsPage> createState() => _ModeTipsPageState();
}

class _ModeTipsPageState extends State<ModeTipsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < widget.pages.length - 1) {
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
    final pages = widget.pages;
    final accent = widget.accent;

    return HomeScaffold(
      title: widget.title,
      leading: HomeBackButton(onPressed: () => Navigator.of(context).pop()),
      body: pages.isEmpty
          ? Center(child: CircularProgressIndicator(color: accent))
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
                                      color: accent.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.45),
                                      ),
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 40,
                                      color: accent,
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
                                      ? accent
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

class ModeTipPageData {
  final IconData icon;
  final String title;
  final String body;

  const ModeTipPageData({
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// AppBar 右上用のヒントボタン
class ModeTipsHeaderButton extends StatelessWidget {
  final ModeTipsKind kind;

  const ModeTipsHeaderButton({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HomeHeaderIconButton(
      icon: Icons.lightbulb_outline_rounded,
      tooltip: l10n.modeTipsOpen,
      onPressed: () => ModeTipsPage.open(context, kind),
    );
  }
}
