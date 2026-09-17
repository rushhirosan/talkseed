import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/bingo_deck.dart';
import 'package:theme_dice/models/session_config.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/pages/bingo_page.dart';
import 'package:theme_dice/pages/mode_tips_page.dart';
import 'package:theme_dice/services/bingo_picker.dart';
import 'package:theme_dice/services/bingo_service.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/services/timer_service.dart';
import 'package:theme_dice/utils/dispose_text_controller.dart';
import 'package:theme_dice/utils/error_dialog_helper.dart';
import 'package:theme_dice/utils/preset_display.dart';
import 'package:theme_dice/utils/pro_access.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/widgets/bingo_board_widget.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';
import 'package:theme_dice/widgets/talk_shuffle_dialog.dart';

/// 会話ビンゴのセッション設定（終了条件・人数・タイマー）
class BingoSetupPage extends StatefulWidget {
  final SessionConfig? initialConfig;

  const BingoSetupPage({super.key, this.initialConfig});

  @override
  State<BingoSetupPage> createState() => _BingoSetupPageState();
}

class _BingoSetupPageState extends State<BingoSetupPage> {
  static const List<Duration> _timerDurations = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 3),
    Duration(minutes: 5),
    TimerService.unlimitedDuration,
  ];

  BingoDeck? _deck;
  bool _loading = true;

  late SessionConfig _config;

  final List<TextEditingController> _playerNameControllers = [];
  final List<FocusNode> _playerNameFocusNodes = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialConfig;
    var config = initial ??
        SessionConfig.defaultConfig.copyWith(
          timerDuration: const Duration(minutes: 1),
        );
    if (config.playerCount > BingoBoard.maxPlayers) {
      config = config.copyWith(playerCount: BingoBoard.maxPlayers);
    }
    _config = config;
    _initializePlayerNames(initialNames: initial?.playerNames);
  }

  void _initializePlayerNames({List<String>? initialNames}) {
    final preserved = initialNames ??
        _playerNameControllers.map((c) => c.text).toList(growable: false);

    for (final controller in _playerNameControllers) {
      controller.dispose();
    }
    for (final node in _playerNameFocusNodes) {
      node.dispose();
    }
    _playerNameControllers.clear();
    _playerNameFocusNodes.clear();

    for (var i = 0; i < _config.playerCount; i++) {
      final controller = TextEditingController();
      if (i < preserved.length) {
        controller.text = preserved[i];
      }
      _playerNameControllers.add(controller);
      _playerNameFocusNodes.add(FocusNode());
    }
  }

  void _updatePlayerCount(int count) {
    setState(() {
      _config = _config.copyWith(playerCount: count);
      _initializePlayerNames();
    });
  }

  @override
  void dispose() {
    for (final controller in _playerNameControllers) {
      controller.dispose();
    }
    for (final node in _playerNameFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_deck == null && _loading) {
      _loadDeck();
    }
  }

  Future<void> _loadDeck() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_loading) {
      setState(() => _loading = true);
    }
    try {
      final deck = await BingoService.loadDeck(languageCode: l10n.localeName);
      if (!mounted) return;
      setState(() {
        _deck = deck;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      await ErrorDialogHelper.showDataLoadError(context, onRetry: _loadDeck);
    }
  }

  SessionConfig _buildSessionConfig() {
    final playerNames = List.generate(
      _config.playerCount,
      (i) => _playerNameControllers[i].text.trim(),
    );
    final playerCount = _config.playerCount.clamp(2, BingoBoard.maxPlayers);
    return _config.copyWith(
      playerCount: playerCount,
      playerNames: playerNames,
      bingoWinOnBlackout: _config.bingoWinOnBlackout,
      bingoFreeCenter: _config.bingoFreeCenter,
      bingoAdjacentOnly: _config.bingoAdjacentOnly,
      bingoFlipMode: _config.bingoFlipMode,
    );
  }

  Color _playerFieldTint(int index) {
    final tints = [
      HomePalette.purple.withValues(alpha: 0.22),
      HomePalette.accent.withValues(alpha: 0.16),
      HomePalette.purple.withValues(alpha: 0.14),
      HomePalette.accentOrange.withValues(alpha: 0.16),
    ];
    return tints[index % tints.length];
  }

  Widget _buildPlayerNameField(AppLocalizations l10n, int index) {
    final tint = _playerFieldTint(index);
    return Container(
      decoration: BoxDecoration(
        color: tint,
        border: Border.all(color: HomePalette.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _playerNameControllers[index],
        focusNode: _playerNameFocusNodes[index],
        cursorColor: HomePalette.accent,
        style: _bodyStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: l10n.playerName(index + 1),
          hintStyle: GoogleFonts.zenKakuGothicNew(
            fontSize: 12,
            color: HomePalette.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPlayerNamesGrid(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const minFieldWidth = 140.0;
        final columns = constraints.maxWidth >= minFieldWidth * 2 + spacing
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(_config.playerCount, (i) {
            return SizedBox(
              width: itemWidth,
              child: _buildPlayerNameField(l10n, i),
            );
          }),
        );
      },
    );
  }

  TextStyle _labelStyle() => GoogleFonts.zenKakuGothicNew(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: HomePalette.textSecondary,
        letterSpacing: 1.5,
      );

  TextStyle _bodyStyle({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? HomePalette.text,
      );

  String _timerLabel(AppLocalizations l10n, Duration d) {
    if (d == const Duration(seconds: 30)) return l10n.timer30Seconds;
    if (d == const Duration(minutes: 1)) return l10n.timer1Minute;
    if (d == const Duration(minutes: 2)) return l10n.timer2Minutes;
    if (d == const Duration(minutes: 3)) return l10n.timer3Minutes;
    if (d == const Duration(minutes: 5)) return l10n.timer5Minutes;
    if (d == TimerService.unlimitedDuration) return l10n.timerUnlimited;
    return l10n.timer1Minute;
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
    bool dense = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 14),
      decoration: BoxDecoration(
        color: HomePalette.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HomePalette.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: dense,
          dropdownColor: HomePalette.surface2,
          iconEnabledColor: HomePalette.textMuted,
          style: _bodyStyle(fontSize: dense ? 14 : 15, weight: FontWeight.w600),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildWinModeSection(AppLocalizations l10n) {
    final size = BingoBoard.sizeForPlayerCount(_config.playerCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.bingoWinModeLabel, style: _labelStyle()),
        const SizedBox(height: 6),
        _dropdown<bool>(
          value: _config.bingoWinOnBlackout,
          items: const [false, true],
          labelBuilder: (blackout) => blackout
              ? l10n.bingoWinModeBlackout
              : l10n.bingoWinModeLine,
          onChanged: (v) => v == null
              ? null
              : setState(
                  () => _config = _config.copyWith(bingoWinOnBlackout: v),
                ),
          dense: true,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bingoBoardSizeHint(size, size),
          style: _bodyStyle(fontSize: 12, color: HomePalette.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRuleToggles(AppLocalizations l10n) {
    Widget toggleRow({
      required String label,
      required String hint,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: HomePalette.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: HomePalette.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _bodyStyle(fontSize: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: _bodyStyle(fontSize: 12, color: HomePalette.textSecondary),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeThumbColor: bingoAccent,
              onChanged: onChanged,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        toggleRow(
          label: l10n.bingoFlipModeLabel,
          hint: l10n.bingoFlipModeHint,
          value: _config.bingoFlipMode,
          onChanged: (v) => setState(() {
            _config = _config.copyWith(
              bingoFlipMode: v,
              bingoAdjacentOnly: v ? _config.bingoAdjacentOnly : false,
            );
          }),
        ),
        const SizedBox(height: 8),
        toggleRow(
          label: l10n.bingoFreeCenterLabel,
          hint: l10n.bingoFreeCenterHint,
          value: _config.bingoFreeCenter,
          onChanged: (v) => setState(
            () => _config = _config.copyWith(bingoFreeCenter: v),
          ),
        ),
        if (!_config.bingoFlipMode) ...[
          const SizedBox(height: 8),
          toggleRow(
            label: l10n.bingoAdjacentOnlyLabel,
            hint: l10n.bingoAdjacentOnlyHint,
            value: _config.bingoAdjacentOnly,
            onChanged: (v) => setState(
              () => _config = _config.copyWith(bingoAdjacentOnly: v),
            ),
          ),
        ],
        if (_config.bingoFlipMode) ...[
          const SizedBox(height: 8),
          toggleRow(
            label: l10n.bingoFlipAdjacentOnlyLabel,
            hint: l10n.bingoFlipAdjacentOnlyHint,
            value: _config.bingoAdjacentOnly,
            onChanged: (v) => setState(
              () => _config = _config.copyWith(bingoAdjacentOnly: v),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSessionSettingsRow(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: _config.enableTimer ? 2 : 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.playerCount, style: _labelStyle()),
              const SizedBox(height: 6),
              _dropdown<int>(
                value: _config.playerCount,
                items: List.generate(
                  BingoBoard.maxPlayers - 1,
                  (i) => i + 2,
                ),
                labelBuilder: (v) => '$v',
                onChanged: (v) =>
                    v == null ? null : _updatePlayerCount(v),
                dense: true,
              ),
            ],
          ),
        ),
        if (_config.enableTimer) ...[
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.timerDuration, style: _labelStyle()),
                const SizedBox(height: 6),
                _dropdown<Duration>(
                  value: _config.timerDuration,
                  items: _timerDurations,
                  labelBuilder: (d) => _timerLabel(l10n, d),
                  onChanged: (v) => v == null
                      ? null
                      : setState(
                          () => _config = _config.copyWith(timerDuration: v),
                        ),
                  dense: true,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(width: 6),
        Column(
          children: [
            Text(l10n.enableTimer, style: _labelStyle()),
            const SizedBox(height: 2),
            Switch.adaptive(
              value: _config.enableTimer,
              activeThumbColor: bingoAccent,
              onChanged: (v) => setState(
                () => _config = _config.copyWith(enableTimer: v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showSavePresetDialog(AppLocalizations l10n) async {
    final allowed = await ProAccess.ensure(
      context,
      feature: ProFeature.presetSave,
    );
    if (!allowed || !mounted) {
      return;
    }

    final config = _buildSessionConfig();
    final summaryPreset = SessionPreset.bingo(
      id: 'preview',
      name: l10n.presetModeBingo,
      config: config,
      updatedAt: DateTime.now(),
    );

    final controller = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => TalkShuffleAlertDialog(
        title: Text(l10n.presetSaveDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              cursorColor: HomePalette.accent,
              style: _bodyStyle(color: HomePalette.text),
              decoration: TalkShuffleAlertDialog.inputDecoration(
                hintText: l10n.presetSaveDialogHintBingo,
              ),
              onSubmitted: (_) => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 12),
            Text(
              summaryPreset.configSummary(l10n),
              style: _bodyStyle(fontSize: 13, color: HomePalette.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) {
      disposeTextControllerSoon(controller);
      return;
    }

    final name = controller.text;
    disposeTextControllerSoon(controller);

    try {
      await PresetService.saveBingoPreset(name: name, config: config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.presetSavedMessage)),
      );
    } on PresetValidationException catch (e) {
      if (!mounted) return;
      final message = e.isEmptyName
          ? l10n.presetEmptyNameError
          : e.isInvalidConfig
              ? l10n.presetInvalidConfigError
              : l10n.presetMaxReachedError(PresetService.maxPresets);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _openTips() {
    ModeTipsPage.open(context, ModeTipsKind.bingo);
  }

  void _start(BingoDeck deck) {
    final board = BingoPicker(deck: deck).deal(
      playerCount: _buildSessionConfig().playerCount,
    );
    Navigator.of(context).push(
      RouteTransitions.forwardRoute(
        page: BingoPage(
          board: board,
          config: _buildSessionConfig(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deck = _deck;

    return HomeScaffold(
      title: l10n.bingoTitle,
      leading: HomeBackButton(onPressed: () => Navigator.of(context).pop()),
      actions: [
        const ModeTipsHeaderButton(kind: ModeTipsKind.bingo),
      ],
      body: _loading || deck == null
          ? const Center(
              child: CircularProgressIndicator(color: bingoAccent),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.bingoSetupHint,
                                style: _bodyStyle(
                                  fontSize: 13,
                                  color: HomePalette.textSecondary,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _openTips,
                                  icon: Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 18,
                                    color: bingoAccent,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: bingoAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  label: Text(
                                    l10n.bingoTipsCta,
                                    style: _bodyStyle(
                                      fontSize: 13,
                                      weight: FontWeight.w700,
                                      color: bingoAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildWinModeSection(l10n),
                              const SizedBox(height: 12),
                              _buildRuleToggles(l10n),
                              const SizedBox(height: 12),
                              _buildSessionSettingsRow(l10n),
                              const SizedBox(height: 12),
                              Text(
                                l10n.playerNamesOptional,
                                style: _labelStyle(),
                              ),
                              const SizedBox(height: 8),
                              _buildPlayerNamesGrid(l10n),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      HomePrimaryButton(
                        label: l10n.startSession,
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => _start(deck),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showSavePresetDialog(l10n),
                        icon: Icon(
                          Icons.bookmark_add_outlined,
                          color: HomePalette.textSecondary,
                          size: 18,
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        label: Text(
                          l10n.presetSave,
                          style: _bodyStyle(
                            fontSize: 13,
                            weight: FontWeight.w600,
                            color: HomePalette.textSecondary,
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
