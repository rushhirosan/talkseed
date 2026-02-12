import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import '../models/session_config.dart' show SessionConfig, PlayMode;
import '../models/polyhedron_type.dart';
import '../utils/preferences_helper.dart';
import '../utils/route_transitions.dart';
import 'dice_page.dart';
import 'initial_settings_page.dart';
import 'topics_page.dart';

/// セッション設定画面（設定画面とデザインテイストを統一）
class SessionSetupPage extends StatefulWidget {
  final Map<PolyhedronType, List<String>> themes;
  /// DicePage から戻ってきた場合 true（戻るボタンで pushReplacement を使うため）
  final bool fromDicePage;

  const SessionSetupPage({
    super.key,
    required this.themes,
    this.fromDicePage = false,
  });

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  late SessionConfig _config;
  final List<TextEditingController> _playerNameControllers = [];

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
  }

  void _initializePlayerNames() {
    for (var controller in _playerNameControllers) {
      controller.dispose();
    }
    _playerNameControllers.clear();
    for (int i = 0; i < _config.playerCount; i++) {
      _playerNameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _playerNameControllers) {
      controller.dispose();
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

  void _updatePlayMode(PlayMode mode) {
    setState(() {
      _config = _config.copyWith(playMode: mode);
    });
  }

  void _startSession() {
    // 入力された名前を順番通りに渡す（空欄は空文字）。1人でも名前があれば表示に使う
    final playerNames = List.generate(
      _config.playerCount,
      (i) => _playerNameControllers[i].text.trim(),
    );

    final finalConfig = _config.copyWith(playerNames: playerNames);
    final themes = widget.themes[PolyhedronType.cube];
    if (themes != null) {
      PreferencesHelper.saveLastThemes(themes);
    }

    if (finalConfig.playMode == PlayMode.topicCard) {
      Navigator.of(context).pushReplacement(
        RouteTransitions.forwardRoute(
          page: TopicsPage(
            initialThemes: widget.themes,
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
    return Scaffold(
      backgroundColor: _white,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: () {
            if (widget.fromDicePage) {
              // DicePage から来た場合: pushReplacement で戻るトランジションを明示
              Navigator.of(context).pushReplacement(
                RouteTransitions.backRoute(
                  page: const InitialSettingsPage(),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          tooltip: l10n.backToThemeSettings,
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
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: _mustardYellow,
              padding: const EdgeInsets.all(24),
              child: _buildLeftSection(l10n),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: _white,
              padding: const EdgeInsets.all(24),
              child: _buildRightSection(l10n),
            ),
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.playModeLabel,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdown<PlayMode>(
          value: _config.playMode,
          items: PlayMode.values,
          labelBuilder: (v) => v == PlayMode.dice ? l10n.playModeDice : l10n.playModeTopicCard,
          onChanged: (v) => v != null ? _updatePlayMode(v) : null,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.playerCount,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdown<int>(
          value: _config.playerCount,
          items: List.generate(9, (i) => i + 2),
          labelBuilder: (v) => '$v',
          onChanged: (v) => v != null ? _updatePlayerCount(v) : null,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.timerSettings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _black,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: _buildTimerToggle(l10n)),
        if (_config.enableTimer) ...[
          const SizedBox(height: 12),
          Text(
            l10n.timerDuration,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: _black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown<Duration>(
            value: _config.timerDuration,
            items: _timerDurations,
            labelBuilder: (d) => _getTimerLabel(l10n, d),
            onChanged: (v) => v != null ? _updateTimerDuration(v) : null,
          ),
        ],
        const Spacer(),
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
            _config.playMode == PlayMode.dice ? l10n.playModeDice : l10n.playModeTopicCard,
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

  Widget _buildRightSection(AppLocalizations l10n) {
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
        const SizedBox(height: 8),
        Text(
          l10n.playerNamesHint,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: _black.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
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
              padding: const EdgeInsets.only(right: 20, bottom: 16),
              children: [
                ...List.generate(_config.playerCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPlayerNameField(l10n, index),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              side: const BorderSide(color: _black, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: _mustardYellow.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerNameField(AppLocalizations l10n, int index) {
    final pastel = _getPastelColor(index);
    return Container(
      decoration: BoxDecoration(
        color: pastel,
        border: Border.all(color: _black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _playerNameControllers[index],
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}
