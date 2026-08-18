import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/utils/about_links_helper.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/utils/preset_launcher.dart';
import 'package:theme_dice/models/preselected_mode.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/models/theme.dart';
import 'package:theme_dice/models/polyhedron_type.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/widgets/home/home_ambient_background.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_random_button.dart';
import 'package:theme_dice/widgets/home/home_theme_card.dart';
import 'package:theme_dice/widgets/home/home_preset_chip.dart';
import 'package:theme_dice/widgets/home/preset_library_sheet.dart';
import 'package:theme_dice/widgets/home/preset_manage_hint.dart';
import 'initial_settings_page.dart';
import 'session_setup_page.dart';
import 'tutorial_page.dart';
import 'package:theme_dice/pages/one_on_one_session_page.dart';
import 'session_history_page.dart';

/// 初回画面：ランダム（サイコロ） / 価値観・グループディスカッション
class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  /// トップの「次回起動もランダムで決める」チェックを一時非表示
  static const bool _showStartupFollowRandomOption = false;

  static const int _quickStartLimit = 3;

  bool _alwaysOpenWithDice = false;
  List<SessionPreset> _allPresets = [];
  List<SessionPreset> _quickStartPresets = [];

  @override
  void initState() {
    super.initState();
    if (_showStartupFollowRandomOption) {
      _loadDefaultPlayMode();
    }
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final all = await PresetService.listPresets();
    final recent =
        await PresetService.listRecentPresets(limit: _quickStartLimit);
    if (!mounted) return;
    setState(() {
      _allPresets = all;
      _quickStartPresets = recent;
    });
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

    if (deck.type == CardDeckType.groupDiscussion) {
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
            discussionDeckType: deck.type,
          ),
        ),
      );
      return;
    }

    if (deck.type == CardDeckType.oneOnOne) {
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(
        RouteTransitions.forwardRoute(
          page: const OneOnOneSessionPage(),
        ),
      )
          .then((_) => _loadPresets());
      return;
    }
  }

  Future<void> _launchQuickStartPreset(SessionPreset preset) async {
    await PresetLauncher.launch(context, preset);
    if (!mounted) return;
    await _loadPresets();
  }

  Future<void> _confirmDeletePreset(SessionPreset preset) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.presetDeleteConfirmTitle),
        content: Text(l10n.presetDeleteConfirmMessage(preset.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.presetDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await PresetService.deletePreset(preset.id);
    if (!mounted) return;
    await _loadPresets();
  }

  void _openPresetLibrary() {
    showPresetLibrarySheet(
      context: context,
      onPresetsChanged: _loadPresets,
      onLaunchPreset: _launchQuickStartPreset,
    );
  }

  Widget _buildQuickStartPresetStrip(AppLocalizations l10n) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickStartPresets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final preset = _quickStartPresets[index];
          return HomePresetChip(
            preset: preset,
            l10n: l10n,
            showModeBadge: true,
            compact: true,
            onTap: () => _launchQuickStartPreset(preset),
            onDelete: () => _confirmDeletePreset(preset),
          );
        },
      ),
    );
  }

  Widget _buildQuickStartSection(AppLocalizations l10n) {
    if (_quickStartPresets.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMorePresets = _allPresets.length > _quickStartPresets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        _buildCardLabel(l10n.presetQuickStartLabel),
        const SizedBox(height: 12),
        _buildQuickStartPresetStrip(l10n),
        PresetManageHint(text: l10n.presetDeleteHint),
        if (hasMorePresets)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _openPresetLibrary,
              style: TextButton.styleFrom(
                foregroundColor: HomePalette.textMuted,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.presetSeeAll,
                style: _bodyFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HomePalette.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCardLabel(l10n.homeCardLabel),
        const SizedBox(height: 12),
        _buildTitle(l10n),
        _buildQuickStartSection(l10n),
      ],
    );
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

  TextStyle _bodyFont({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.zenKakuGothicNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? HomePalette.text,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          decoration: const BoxDecoration(
            color: HomePalette.headerBg,
            border: Border(bottom: BorderSide(color: HomePalette.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      HomePalette.logoGradient.createShader(bounds),
                  child: Text(
                    l10n.appTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _headerIconButton(
                icon: Icons.history,
                tooltip: l10n.historyTitle,
                onPressed: () {
                  Navigator.of(context).push(
                    RouteTransitions.forwardRoute(
                      page: const SessionHistoryPage(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              _headerIconButton(
                icon: Icons.bookmarks_outlined,
                tooltip: l10n.presetLibraryTitle,
                onPressed: _openPresetLibrary,
              ),
              const SizedBox(width: 4),
              _headerIconButton(
                icon: Icons.help_outline,
                tooltip: l10n.showTutorial,
                onPressed: _showTutorial,
              ),
              const SizedBox(width: 4),
              _headerIconButton(
                icon: Icons.info_outline,
                tooltip: l10n.aboutApp,
                onPressed: _showAboutSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
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

  Widget _buildCardLabel(String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: HomePalette.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: _bodyFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: HomePalette.accent,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(AppLocalizations l10n) {
    const titleStyle = TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w900,
      height: 1.1,
      letterSpacing: -1.5,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${l10n.homeThemeTitleLine1}\n',
            style: GoogleFonts.zenKakuGothicNew(
              color: HomePalette.text,
            ).merge(titleStyle),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  HomePalette.accentGradient.createShader(bounds),
              child: Text(
                l10n.homeThemeTitleAccent,
                style: GoogleFonts.zenKakuGothicNew(
                  color: Colors.white,
                ).merge(titleStyle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: HomePalette.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: HomeAmbientBackground()),
          Column(
            children: [
              SafeArea(bottom: false, child: _buildHeader(l10n)),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeroSection(l10n),
                                const SizedBox(height: 24),
                                HomeRandomButton(
                                  label: l10n.homeRandomDecideLabel,
                                  onPressed: _goToDice,
                                ),
                                const SizedBox(height: 20),
                                HomeThemeCard(
                                  icon: Icons.eco_outlined,
                                  name: l10n.homeThemeShortValues,
                                  description: l10n.homeThemeDescValues,
                                  accentColor: HomePalette.purple,
                                  animationIndex: 0,
                                  onTap: () => _goToWorkDeck(
                                    CardDeckType.teamBuilding,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                HomeThemeCard(
                                  icon: Icons.forum_outlined,
                                  name: l10n.homeThemeShortGroupDiscussion,
                                  description:
                                      l10n.homeThemeDescGroupDiscussion,
                                  accentColor: HomePalette.accentCoral,
                                  animationIndex: 1,
                                  onTap: () => _goToWorkDeck(
                                    CardDeckType.groupDiscussion,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                HomeThemeCard(
                                  icon: Icons.psychology_outlined,
                                  name: l10n.homeThemeShortOneOnOne,
                                  description: l10n.homeThemeDescOneOnOne,
                                  accentColor: const Color(0xFF64B5F6),
                                  animationIndex: 2,
                                  onTap: () =>
                                      _goToWorkDeck(CardDeckType.oneOnOne),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
