import 'package:flutter/material.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/utils/about_links_helper.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/utils/error_dialog_helper.dart';
import 'package:theme_dice/models/preselected_mode.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/theme.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/services/checkin_checkout_service.dart';
import 'package:theme_dice/services/self_reflection_service.dart';
import 'initial_settings_page.dart';
import 'session_setup_page.dart';
import 'tutorial_page.dart';
import 'topics_page.dart';
import 'session_history_page.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';

/// 初回画面：みんなで盛り上がる（サイコロ） / 仕事で盛り上がる（価値観・問題解決・社会課題などカードデッキ）
class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  bool _alwaysOpenWithDice = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultPlayMode();
  }

  Future<void> _loadDefaultPlayMode() async {
    final mode = await PreferencesHelper.loadDefaultPlayMode();
    if (!mounted) return;
    setState(() {
      _alwaysOpenWithDice = mode == 'dice';
    });
  }

  void _goToDice() async {
    final l10n = AppLocalizations.of(context)!;
    final themes = ThemeModel.getDefaultThemes(PolyhedronType.cube, l10n);
    PreferencesHelper.saveLastThemes(themes);
    if (_alwaysOpenWithDice) {
      await PreferencesHelper.saveDefaultPlayMode('dice');
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      RouteTransitions.forwardRoute(
        page: InitialSettingsPage(preselectedMode: PreselectedMode.dice),
      ),
    );
  }

  /// 仕事で盛り上がる：デッキを直接起動（CardSettings をスキップしてワンタップ減）
  void _goToWorkDeck(CardDeckType type) async {
    final l10n = AppLocalizations.of(context)!;
    final deck = CardDeck.allDecks.firstWhere((d) => d.type == type);
    if (!mounted) return;

    if (deck.type == CardDeckType.teamBuilding) {
      final themes = deck.themes(l10n);
      await PreferencesHelper.saveLastCardThemes(themes);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: SessionSetupPage(
            themes: {PolyhedronType.cube: themes},
            forValueCard: true,
            fromCardSettings: false,
          ),
        ),
      );
      return;
    }

    if (deck.type == CardDeckType.problemSolving ||
        deck.type == CardDeckType.socialIssues) {
      final themes = deck.themes(l10n);
      await PreferencesHelper.saveLastCardThemes(themes);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: SessionSetupPage(
            themes: {PolyhedronType.cube: themes},
            forDiscussion: true,
            fromCardSettings: false,
            deckLabel: deck.name(l10n),
          ),
        ),
      );
      return;
    }

    try {
      if (deck.type == CardDeckType.checkIn) {
        final checkInItems =
            await CheckInCheckOutService.loadCheckInItems();
        final checkOutItems =
            await CheckInCheckOutService.loadCheckOutItems();
        final combined = [
          ...checkInItems.map((e) => e.text),
          ...checkOutItems.map((e) => e.text),
        ];
        await PreferencesHelper.saveLastCardThemes(combined);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          RouteTransitions.forwardRoute(
            page: TopicsPage(
              initialThemes: {PolyhedronType.cube: combined},
              sessionConfig: null,
              checkInItems: checkInItems,
              checkOutItems: checkOutItems,
            ),
          ),
        );
      } else if (deck.type == CardDeckType.oneOnOne) {
        // 自己内省・1on1
        final data = await SelfReflectionService.loadThemesWithSections();
        await PreferencesHelper.saveLastCardThemes(data.themes);
        if (!mounted) return;
        final themeCategoryMap =
            CardDeck.buildReflectionCategoryMap(data.sectionIdByTheme);
        Navigator.of(context).pushReplacement(
          RouteTransitions.forwardRoute(
            page: TopicsPage(
              initialThemes: {PolyhedronType.cube: data.themes},
              sessionConfig: null,
              themeCategoryMap: themeCategoryMap,
            ),
          ),
        );
      }
    } on ThemeDiceException {
      if (!mounted) return;
      await ErrorDialogHelper.showDataLoadError(
        context,
        onRetry: () => _goToWorkDeck(type),
      );
    } catch (_) {
      if (!mounted) return;
      await ErrorDialogHelper.showDataLoadError(
        context,
        onRetry: () => _goToWorkDeck(type),
      );
    }
  }

  void _showAboutSheet() {
    AboutLinksHelper.showAboutSheet(context);
  }

  void _showTutorial() {
    Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: TutorialPage(
          onComplete: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// 案B：ランダム＝紫の主ボタン（リスト先頭）
  Widget _buildRandomPrimaryButton(
    BuildContext context,
    AppLocalizations l10n,
    VoidCallback onPressed,
  ) {
    final purple = context.talkShuffle.brandPurple;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: _white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎲', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              l10n.homeRandomDecideLabel,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// テーマ行（白／薄紫ボーダー、絵文字＋短いラベル）
  Widget _buildThemeRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    final borderColor = context.talkShuffle.borderLavender;
    final bg = backgroundColor ?? _white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 上の「ランダムで決める」と同じ経路で次回起動する（文言は homeRandomDecideLabel を埋め込む）
  Widget _buildStartupFollowRandomOption(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final accent = context.talkShuffle.brandPurple;

    Future<void> toggle(bool v) async {
      setState(() => _alwaysOpenWithDice = v);
      await PreferencesHelper.saveDefaultPlayMode(
        _alwaysOpenWithDice ? 'dice' : null,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 14),
      decoration: BoxDecoration(
        color: context.talkShuffle.shellLavender,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: () async => toggle(!_alwaysOpenWithDice),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _alwaysOpenWithDice,
                  onChanged: (v) async => toggle(v ?? false),
                  activeColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.7)),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return accent;
                    return Colors.white;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.alwaysOpenWithDice(l10n.homeRandomDecideLabel),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _black,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.alwaysOpenWithDiceHint,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: _black.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ts = context.talkShuffle;
    return Scaffold(
      backgroundColor: ts.scaffoldHome,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: _black),
            onPressed: () {
              Navigator.of(context).push(
                RouteTransitions.forwardRoute(
                  page: const SessionHistoryPage(),
                ),
              );
            },
            tooltip: l10n.historyTitle,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: _black),
            onPressed: _showTutorial,
            tooltip: l10n.showTutorial,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: _black),
            onPressed: _showAboutSheet,
            tooltip: l10n.aboutApp,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: ts.surfaceCard,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.homeThemePickTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        _buildRandomPrimaryButton(context, l10n, _goToDice),
                        const SizedBox(height: 12),
                        _buildStartupFollowRandomOption(context, l10n),
                        const SizedBox(height: 18),
                        _buildThemeRow(
                          context: context,
                          icon: Icons.groups_rounded,
                          iconColor: ts.deckIconValues,
                          label: l10n.homeThemeShortValues,
                          onPressed: () =>
                              _goToWorkDeck(CardDeckType.teamBuilding),
                        ),
                        const SizedBox(height: 12),
                        _buildThemeRow(
                          context: context,
                          icon: Icons.psychology_alt_rounded,
                          iconColor: ts.deckIconProblem,
                          label: l10n.homeThemeShortProblem,
                          backgroundColor: ts.rowHighlightLavender,
                          onPressed: () =>
                              _goToWorkDeck(CardDeckType.problemSolving),
                        ),
                        const SizedBox(height: 12),
                        _buildThemeRow(
                          context: context,
                          icon: Icons.public_rounded,
                          iconColor: ts.deckIconSocial,
                          label: l10n.homeThemeShortSocial,
                          onPressed: () =>
                              _goToWorkDeck(CardDeckType.socialIssues),
                        ),
                      ],
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
