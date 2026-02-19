import 'package:flutter/material.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
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
import 'value_card_page.dart';

/// 初回画面：みんなで盛り上がる（サイコロ） / 仕事で盛り上がる（チームビルディング・チェックイン・自己内省・1on1）
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
      } else {
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

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _black.withOpacity(0.85),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    const Color white = Colors.white;
    const Color black = Colors.black87;

    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: white, size: 28),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: black, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: const BorderSide(color: black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: white.withOpacity(0.8),
          foregroundColor: black,
        ),
      ),
    );
  }

  /// 次回起動時はサイコロのみ選択可能（カードは複数あるため起動時指定は行わない）
  Widget _buildAlwaysOpenCheckboxes(AppLocalizations l10n) {
    const Color white = Colors.white;
    const Color black = Colors.black87;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: black.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.startupDefaultSection,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              setState(() => _alwaysOpenWithDice = !_alwaysOpenWithDice);
              await PreferencesHelper.saveDefaultPlayMode(
                _alwaysOpenWithDice ? 'dice' : null,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _alwaysOpenWithDice,
                    onChanged: (v) async {
                      setState(() => _alwaysOpenWithDice = v ?? false);
                      await PreferencesHelper.saveDefaultPlayMode(
                        _alwaysOpenWithDice ? 'dice' : null,
                      );
                    },
                    activeColor: black,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return black;
                      return white;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.alwaysOpenWithDice, style: const TextStyle(fontSize: 13, color: black))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const Color _mustardYellow = Color(0xFFFFEB3B);
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _mustardYellow,
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
            icon: const Icon(Icons.help_outline, color: _black),
            onPressed: _showTutorial,
            tooltip: l10n.showTutorial,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.modeSelectionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _black.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino, size: 36, color: _black.withOpacity(0.85)),
                  const SizedBox(width: 28),
                  Icon(Icons.style, size: 36, color: _black.withOpacity(0.85)),
                ],
              ),
              const SizedBox(height: 32),
              // みんなで盛り上がる
              _buildSectionTitle(l10n.homeSectionEveryone),
              const SizedBox(height: 12),
              _buildModeButton(
                icon: Icons.casino,
                label: l10n.homeDiceLabel,
                onPressed: _goToDice,
                isPrimary: true,
              ),
              const SizedBox(height: 32),
              // 仕事で盛り上がる
              _buildSectionTitle(l10n.homeSectionWork),
              const SizedBox(height: 12),
              _buildModeButton(
                icon: Icons.groups,
                label: l10n.deckTeamBuilding,
                onPressed: () => _goToWorkDeck(CardDeckType.teamBuilding),
                isPrimary: false,
              ),
              const SizedBox(height: 48),
              _buildAlwaysOpenCheckboxes(l10n),
            ],
          ),
        ),
      ),
    );
  }
}
