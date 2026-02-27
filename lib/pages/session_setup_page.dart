import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/session_config.dart' show SessionConfig;
import '../models/polyhedron_type.dart';
import '../utils/preferences_helper.dart';
import '../utils/route_transitions.dart';
import 'dice_page.dart';
import 'initial_settings_page.dart';
import 'value_card_page.dart';
import 'mode_selection_page.dart';
import 'card_settings_page.dart';

/// セッション設定画面（設定画面とデザインテイストを統一）
/// サイコロ用・価値観カード用の両方で利用（参加人数・タイマー・プレイヤー名）
class SessionSetupPage extends StatefulWidget {
  final Map<PolyhedronType, List<String>> themes;
  /// DicePage から戻ってきた場合 true（戻るボタンで pushReplacement を使うため）
  final bool fromDicePage;
  /// true のとき「スタート」で ValueCardPage へ遷移（価値観カード用セッション設定）
  final bool forValueCard;
  /// forValueCard 時のみ。true なら戻るで CardSettingsPage、false なら ModeSelectionPage
  final bool fromCardSettings;

  const SessionSetupPage({
    super.key,
    required this.themes,
    this.fromDicePage = false,
    this.forValueCard = false,
    this.fromCardSettings = false,
  });

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  late SessionConfig _config;
  final List<TextEditingController> _playerNameControllers = [];
  final List<FocusNode> _playerNameFocusNodes = [];
  bool _vibrationEnabled = true;

  final ScrollController _rightScrollController = ScrollController();

  // デザインカラーパレット（設定画面と同じ）
  static const Color _mustardYellow = Color(0xFFFFEB3B);
  static const Color _lightGreen = Color(0xFFB8E6B8);
  static const Color _lightOrange = Color(0xFFFFE5CC);
  static const Color _lightPink = Color(0xFFFFCCCC);
  static const Color _lightBlueGreen = Color(0xFFCCE5E5);
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;

  @override
  void initState() {
    super.initState();
    _config = SessionConfig.defaultConfig;
    _initializePlayerNames();
    _loadVibrationSetting();
  }

  Future<void> _loadVibrationSetting() async {
    final enabled = await PreferencesHelper.loadVibrationEnabled();
    if (mounted) setState(() => _vibrationEnabled = enabled);
  }

  void _initializePlayerNames() {
    for (var controller in _playerNameControllers) {
      controller.dispose();
    }
    for (var node in _playerNameFocusNodes) {
      node.dispose();
    }
    _playerNameControllers.clear();
    _playerNameFocusNodes.clear();
    for (int i = 0; i < _config.playerCount; i++) {
      _playerNameControllers.add(TextEditingController());
      _playerNameFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _playerNameControllers) {
      controller.dispose();
    }
    for (var node in _playerNameFocusNodes) {
      node.dispose();
    }
    _rightScrollController.dispose();
    super.dispose();
  }

  void _updatePlayerCount(int count) {
    setState(() {
      _config = _config.copyWith(playerCount: count);
      _initializePlayerNames();
    });
  }

  void _updateTimerDuration(Duration duration) {
    setState(() {
      _config = _config.copyWith(timerDuration: duration);
    });
  }

  void _toggleTimer(bool enabled) {
    setState(() {
      _config = _config.copyWith(enableTimer: enabled);
    });
  }

  Future<void> _toggleVibration(bool enabled) async {
    await PreferencesHelper.saveVibrationEnabled(enabled);
    if (mounted) setState(() => _vibrationEnabled = enabled);
  }

  void _startSession() {
    final playerNames = List.generate(
      _config.playerCount,
      (i) => _playerNameControllers[i].text.trim(),
    );

    final finalConfig = _config.copyWith(playerNames: playerNames);
    final themes = widget.themes[PolyhedronType.cube];
    if (themes != null) {
      PreferencesHelper.saveLastThemes(themes);
    }

    if (widget.forValueCard && themes != null) {
      // push にすることで、価値観カード画面の戻るでこのセッション設定に戻れる
      Navigator.of(context).push(
        RouteTransitions.forwardRoute(
          page: ValueCardPage(
            themes: themes,
            sessionConfig: finalConfig,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: DicePage(
            initialThemes: widget.themes,
            sessionConfig: finalConfig,
          ),
        ),
      );
    }
  }

  Color _getPastelColor(int index) {
    final colors = [_lightGreen, _lightOrange, _lightPink, _lightBlueGreen];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isValueCardLayout = widget.forValueCard;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _white,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: () {
            if (widget.fromDicePage) {
              Navigator.of(context).pushReplacement(
                RouteTransitions.backRoute(
                  page: const InitialSettingsPage(),
                ),
              );
            } else if (widget.forValueCard) {
              if (widget.fromCardSettings) {
                Navigator.of(context).pushReplacement(
                  RouteTransitions.backRoute(
                    page: const CardSettingsPage(),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  RouteTransitions.backRoute(
                    page: const ModeSelectionPage(),
                  ),
                );
              }
            } else {
              Navigator.of(context).pop();
            }
          },
          tooltip: widget.forValueCard ? l10n.backToModeSelection : l10n.backToThemeSettings,
        ),
        title: Text(
          l10n.sessionSetup,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // キーボード表示時はプレイヤー名入力エリアのみ全幅表示（横並びだと圧縮されて文字が重なる）
          final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
          if (keyboardVisible) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Container(
                color: _white,
                padding: const EdgeInsets.all(24),
                child: _buildRightSection(l10n),
              ),
            );
          }
          return SizedBox(
            height: constraints.maxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: isValueCardLayout ? 9 : 1,
                  child: Container(
                    color: _mustardYellow,
                    padding: isValueCardLayout
                        ? const EdgeInsets.fromLTRB(20, 20, 16, 20)
                        : const EdgeInsets.all(24),
                    child: LayoutBuilder(
                      builder: (context, leftConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: leftConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: _buildLeftSection(l10n),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: isValueCardLayout ? 11 : 1,
                  child: Container(
                    color: _white,
                    padding: isValueCardLayout
                        ? const EdgeInsets.fromLTRB(16, 20, 20, 20)
                        : const EdgeInsets.all(24),
                    child: _buildRightSection(l10n),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static const List<Duration> _timerDurations = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(hours: 1),
  ];

  String _getTimerLabel(AppLocalizations l10n, Duration d) {
    if (d == const Duration(seconds: 30)) return l10n.timer30Seconds;
    if (d == const Duration(minutes: 1)) return l10n.timer1Minute;
    if (d == const Duration(minutes: 2)) return l10n.timer2Minutes;
    if (d == const Duration(minutes: 3)) return l10n.timer3Minutes;
    if (d == const Duration(minutes: 5)) return l10n.timer5Minutes;
    if (d == const Duration(hours: 1)) return l10n.timerUnlimited;
    return l10n.timer3Minutes;
  }

  Widget _buildLeftSection(AppLocalizations l10n) {
    final compact = widget.forValueCard;
    final sectionSpacing = compact ? 20.0 : 24.0;
    final itemSpacing = compact ? 8.0 : 12.0;
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.playerCount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
        SizedBox(height: itemSpacing),
        _buildDropdown<int>(
          value: _config.playerCount,
          items: List.generate(9, (i) => i + 2),
          labelBuilder: (v) => '$v',
          onChanged: (v) => v != null ? _updatePlayerCount(v) : null,
        ),
        SizedBox(height: sectionSpacing),
        Text(
          l10n.timerSettings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
        SizedBox(height: itemSpacing),
        SizedBox(width: double.infinity, child: _buildTimerToggle(l10n)),
        if (_config.enableTimer) ...[
          SizedBox(height: itemSpacing),
          Text(
            l10n.timerDuration,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: _black.withOpacity(0.7),
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          _buildDropdown<Duration>(
            value: _config.timerDuration,
            items: _timerDurations,
            labelBuilder: (d) => _getTimerLabel(l10n, d),
            onChanged: (v) => v != null ? _updateTimerDuration(v) : null,
          ),
        ],
        SizedBox(height: sectionSpacing),
        SizedBox(
          width: double.infinity,
          child: _buildVibrationToggle(l10n),
        ),
        if (compact) const Spacer(),
        SizedBox(height: sectionSpacing),
        _buildSessionPreview(l10n),
      ],
    );
  }

  Widget _buildSessionPreview(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.sessionPreviewTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sessionPreviewPlayers(_config.playerCount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.forValueCard ? l10n.deckTeamBuilding : l10n.playModeDice,
            style: TextStyle(
              fontSize: 14,
              color: _black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _config.enableTimer
                ? l10n.sessionPreviewTimer(_getTimerLabel(l10n, _config.timerDuration))
                : l10n.sessionPreviewNoTimer,
            style: TextStyle(
              fontSize: 14,
              color: _black.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _black, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: _black),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _black,
          ),
          items: items.map((v) {
            return DropdownMenuItem<T>(
              value: v,
              child: Text(labelBuilder(v)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimerToggle(AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleTimer(!_config.enableTimer),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _black, width: 1.5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _config.enableTimer,
                  onChanged: (v) => _toggleTimer(v ?? false),
                  activeColor: _black,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return _black;
                    return _white;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.enableTimer,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _black,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVibrationToggle(AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleVibration(!_vibrationEnabled),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _black, width: 1.5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _vibrationEnabled,
                  onChanged: (v) => _toggleVibration(v ?? false),
                  activeColor: _black,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) return _black;
                    return _white;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.vibrationEnabled,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _black,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightSection(AppLocalizations l10n) {
    final compact = widget.forValueCard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.playerNamesOptional,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _black,
            ),
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          l10n.playerNamesHint,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: _black.withOpacity(0.7),
          ),
        ),
        SizedBox(height: compact ? 16 : 24),
        Expanded(
          child: Scrollbar(
            controller: _rightScrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(3),
            child: ListView(
              controller: _rightScrollController,
              primary: false,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                right: compact ? 12 : 20,
                // iOS の入力候補バー分を加味
                bottom: (compact ? 16 : 12) +
                    MediaQuery.of(context).viewInsets.bottom +
                    (compact ? 12 : 24),
              ),
              children: [
                ...List.generate(_config.playerCount, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: compact ? 10 : 12),
                    child: _buildPlayerNameField(l10n, index),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow, size: 22, color: _black),
              label: Text(
                l10n.startSession,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _black,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: compact ? 12 : 14,
                ),
                side: const BorderSide(color: _black, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: _mustardYellow.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerNameField(AppLocalizations l10n, int index) {
    final pastel = _getPastelColor(index);
    final focusNode = _playerNameFocusNodes[index];
    final compact = widget.forValueCard;
    return Builder(
      builder: (fieldContext) {
        return Container(
          decoration: BoxDecoration(
            color: pastel,
            border: Border.all(color: _black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _playerNameControllers[index],
            focusNode: focusNode,
            onTap: () {
              Future.delayed(const Duration(milliseconds: 350), () {
                if (fieldContext.mounted) {
                  Scrollable.ensureVisible(
                    fieldContext,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: 0.3,
                  );
                }
              });
            },
            style: const TextStyle(
              fontSize: 14,
              color: _black,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              labelText: l10n.playerName(index + 1),
              labelStyle: TextStyle(
                fontSize: 12,
                color: _black.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: compact ? 10 : 12,
              ),
              isDense: true,
            ),
          ),
        );
      },
    );
  }
}
