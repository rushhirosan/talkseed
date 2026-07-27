import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/one_on_one_phase.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/pages/mode_selection_page.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/services/self_reflection_service.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/utils/pro_access.dart';
import 'package:theme_dice/utils/session_end_dialog.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/preset_display.dart';
import 'package:theme_dice/utils/route_transitions.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_preset_chip.dart';
import 'package:theme_dice/widgets/home/preset_manage_hint.dart';
import 'package:theme_dice/widgets/play/play_session_ui.dart';

/// 1on1向け：今日の型を選び、選んだフェーズで進むガイド付きセッション
class OneOnOneSessionPage extends StatefulWidget {
  /// ホームのプリセットから渡す初期型
  final OneOnOneSessionFormat? initialFormat;

  /// true のときデータ読み込み後に [initialFormat] でセッションを開始
  final bool autoStartSession;

  const OneOnOneSessionPage({
    super.key,
    this.initialFormat,
    this.autoStartSession = false,
  });

  @override
  State<OneOnOneSessionPage> createState() => _OneOnOneSessionPageState();
}

class _OneOnOneSessionPageState extends State<OneOnOneSessionPage> {
  static const int _candidateCount = 3;

  final Random _random = Random();

  Map<OneOnOnePhase, List<String>>? _questionsByPhase;
  OneOnOneSessionFormat _selectedFormat = OneOnOneSessionFormat.lite;
  List<OneOnOnePhase> _activePhases = OneOnOneSessionFormat.lite.phases;
  bool _sessionStarted = false;
  int _phaseIndex = 0;
  List<String> _candidateQuestions = [];
  String? _selectedQuestion;
  /// フェーズごとに確定した問い（sessionId → 問い）
  final Map<String, String> _selectedByPhaseId = {};
  /// 候補差し替え用：このフェーズで直近表示した問い
  final Set<String> _recentlyShownInPhase = {};

  bool _loading = true;
  Object? _loadError;
  bool _agendaExpanded = false;
  String? _loadedLanguageCode;
  final ScrollController _phaseStripScrollController = ScrollController();
  List<SessionPreset> _savedPresets = [];
  bool _autoStartPending = false;

  OneOnOnePhase get _currentPhase => _activePhases[_phaseIndex];

  bool get _isLastPhase => _phaseIndex >= _activePhases.length - 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialFormat != null) {
      _selectedFormat = widget.initialFormat!;
      _activePhases = widget.initialFormat!.phases;
    }
    _autoStartPending = widget.autoStartSession && widget.initialFormat != null;
    _loadSavedPresets();
  }

  Future<void> _loadSavedPresets() async {
    final presets =
        await PresetService.listPresets(mode: SessionPresetMode.oneOnOne);
    if (!mounted) return;
    setState(() => _savedPresets = presets);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_loadedLanguageCode == languageCode) return;

    final previousLanguageCode = _loadedLanguageCode;
    _loadedLanguageCode = languageCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (previousLanguageCode != null) {
        _resetSessionForLocaleChange();
      }
      _loadData();
    });
  }

  void _resetSessionForLocaleChange() {
    setState(() {
      _sessionStarted = false;
      _phaseIndex = 0;
      _selectedQuestion = null;
      _selectedByPhaseId.clear();
      _recentlyShownInPhase.clear();
      _agendaExpanded = false;
      _candidateQuestions = [];
    });
  }

  @override
  void dispose() {
    _phaseStripScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final languageCode = Localizations.localeOf(context).languageCode;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = await SelfReflectionService.loadSessionPhases(
        languageCode: languageCode,
      );
      if (!mounted) return;
      setState(() {
        _questionsByPhase = data;
        _loading = false;
      });
      if (_autoStartPending && !_sessionStarted) {
        _autoStartPending = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startSession();
        });
      }
    } on ThemeDiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  Future<void> _triggerVibration() async {
    final enabled = await PreferencesHelper.loadVibrationEnabled();
    if (!enabled) return;
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 100);
    }
  }

  void _startSession() {
    setState(() {
      _sessionStarted = true;
      _activePhases = _selectedFormat.phases;
      _phaseIndex = 0;
      _selectedQuestion = null;
      _selectedByPhaseId.clear();
      _recentlyShownInPhase.clear();
    });
    _refreshCandidates(resetRecent: true);
  }

  void _refreshCandidates({bool resetRecent = false, bool clearSelection = true}) {
    final pool = _questionsByPhase?[_currentPhase] ?? [];
    if (pool.isEmpty) return;

    if (resetRecent) {
      _recentlyShownInPhase.clear();
    }

    var available =
        pool.where((q) => !_recentlyShownInPhase.contains(q)).toList();
    if (available.length < _candidateCount) {
      _recentlyShownInPhase.clear();
      available = List<String>.from(pool);
    }

    available.shuffle(_random);
    final picked = available.take(_candidateCount).toList();
    _recentlyShownInPhase.addAll(picked);

    setState(() {
      _candidateQuestions = picked;
      if (clearSelection) {
        _selectedQuestion = null;
      } else if (_selectedQuestion != null &&
          !picked.contains(_selectedQuestion) &&
          !pool.contains(_selectedQuestion)) {
        _selectedQuestion = null;
      }
    });
  }

  void _moreCandidates() {
    _refreshCandidates(clearSelection: false);
    _triggerVibration();
  }

  void _selectQuestion(String question) {
    setState(() {
      _selectedQuestion = question;
      if (_isLastPhase) _agendaExpanded = true;
    });
    _triggerVibration();
  }

  void _clearSelection() {
    setState(() => _selectedQuestion = null);
  }

  void _commitCurrentPhaseSelection() {
    final question = _selectedQuestion;
    if (question == null || question.isEmpty) return;
    _selectedByPhaseId[_currentPhase.sessionId] = question;
  }

  void _goToNextPhase() {
    if (_selectedQuestion == null) return;
    _commitCurrentPhaseSelection();
    if (_isLastPhase) {
      _completeSession();
      return;
    }
    setState(() {
      _phaseIndex++;
      _selectedQuestion =
          _selectedByPhaseId[_currentPhase.sessionId];
    });
    _refreshCandidates(
      resetRecent: true,
      clearSelection: _selectedQuestion == null,
    );
    _scrollActivePhaseIntoView();
  }

  void _goToPreviousPhase() {
    if (_phaseIndex <= 0) return;
    setState(() {
      _phaseIndex--;
      _selectedQuestion =
          _selectedByPhaseId[_currentPhase.sessionId];
    });
    _refreshCandidates(
      resetRecent: true,
      clearSelection: _selectedQuestion == null,
    );
    _scrollActivePhaseIntoView();
  }

  void _scrollActivePhaseIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_phaseStripScrollController.hasClients) return;
      final position = _phaseStripScrollController.position;
      if (position.maxScrollExtent <= 0) return;

      final metrics = _PhaseStripMetrics.forLayout(
        width: position.viewportDimension,
        phaseCount: _activePhases.length,
        languageCode: Localizations.localeOf(context).languageCode,
      );
      final itemCenter =
          _phaseIndex * metrics.itemStride + metrics.dotWidth / 2;
      final targetOffset = (itemCenter - position.viewportDimension / 2)
          .clamp(0.0, position.maxScrollExtent);

      _phaseStripScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Map<String, List<String>> _buildHistoryPromptsByPhase() {
    final result = <String, List<String>>{};
    for (final phase in _activePhases) {
      final question = _selectedByPhaseId[phase.sessionId];
      if (question != null && question.isNotEmpty) {
        result[phase.sessionId] = [question];
      }
    }
    return result;
  }

  Future<void> _completeSession() async {
    final record = SessionRecord.create(
      mode: SessionRecord.modeOneOnOne,
      topics: const [],
      selectedCardsByPlayer: _buildHistoryPromptsByPhase(),
      oneOnOneFormatName: _selectedFormat.name,
    );
    await SessionRecordService.addRecord(record);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await SessionEndDialog.show(
      context,
      title: l10n.oneOnOneSessionCompleteTitle,
      message: l10n.oneOnOneSessionCompleteMessage(_activePhases.length),
    );
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  String _phaseTitle(AppLocalizations l10n, OneOnOnePhase phase) =>
      phase.title(l10n);

  String _phaseHint(AppLocalizations l10n, OneOnOnePhase phase) =>
      phase.hint(l10n);

  String? _questionForPhaseAt(int index) {
    final phase = _activePhases[index];
    if (index == _phaseIndex && _selectedQuestion != null) {
      return _selectedQuestion;
    }
    return _selectedByPhaseId[phase.sessionId];
  }

  int get _selectedThemeCount {
    var count = 0;
    for (var i = 0; i < _activePhases.length; i++) {
      if (_questionForPhaseAt(i) != null) count++;
    }
    return count;
  }

  void _jumpToPhase(int index) {
    if (index >= _phaseIndex || index < 0) return;
    setState(() {
      _phaseIndex = index;
      _selectedQuestion = _selectedByPhaseId[_currentPhase.sessionId];
    });
    _refreshCandidates(
      resetRecent: true,
      clearSelection: _selectedQuestion == null,
    );
    _scrollActivePhaseIntoView();
  }

  Widget _buildThemeAgenda(AppLocalizations l10n) {
    if (_selectedThemeCount == 0) return const SizedBox.shrink();

    final total = _activePhases.length;
    final selected = _selectedThemeCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _agendaExpanded = !_agendaExpanded),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: PlayColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _agendaExpanded
                    ? PlayColors.accent.withValues(alpha: 0.45)
                    : PlayColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.checklist_rtl,
                      size: 18,
                      color: PlayColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.oneOnOneThemeAgendaTitle,
                        style: PlayTextStyles.listItem().copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      l10n.oneOnOneThemeAgendaCount(selected, total),
                      style: PlayTextStyles.caption(),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _agendaExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 20,
                      color: PlayColors.textSecondary,
                    ),
                  ],
                ),
                if (_agendaExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: PlayColors.border),
                  const SizedBox(height: 10),
                  ...List.generate(_activePhases.length, (index) {
                    final phase = _activePhases[index];
                    final question = _questionForPhaseAt(index);
                    final isCurrent = index == _phaseIndex;
                    final accent = _OneOnOnePhaseColors.accentFor(phase);
                    final canJump = index < _phaseIndex && question != null;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _activePhases.length - 1 ? 12 : 0,
                      ),
                      child: InkWell(
                        onTap: canJump ? () => _jumpToPhase(index) : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _OneOnOnePhaseColors.iconFor(phase),
                                size: 16,
                                color: question != null
                                    ? accent
                                    : PlayColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _phaseTitle(l10n, phase),
                                      style: PlayTextStyles.caption(
                                        question != null ? 0.9 : 0.55,
                                      ).copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: question != null
                                            ? accent
                                            : PlayColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      question ??
                                          (isCurrent
                                              ? l10n.oneOnOneThemeAgendaSelecting
                                              : l10n
                                                  .oneOnOneThemeAgendaPending),
                                      style: PlayTextStyles.hint().copyWith(
                                        fontStyle: question == null
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                        color: question != null
                                            ? PlayColors.text
                                            : PlayColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (canJump)
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: PlayColors.textMuted,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
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

    final summary = SessionPreset.oneOnOne(
      id: '',
      name: '',
      format: _selectedFormat,
      updatedAt: DateTime.now(),
    ).configSummary(l10n);
    final controller = TextEditingController(text: _selectedFormat.title(l10n));
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.presetSaveDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(hintText: l10n.presetSaveDialogHint),
                onSubmitted: (_) => Navigator.of(ctx).pop(true),
              ),
              const SizedBox(height: 12),
              Text(
                summary,
                style: PlayTextStyles.hint(),
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
        );
      },
    );
    if (saved != true || !mounted) {
      controller.dispose();
      return;
    }

    try {
      await PresetService.saveOneOnOnePreset(
        name: controller.text,
        format: _selectedFormat,
      );
      if (!mounted) return;
      await _loadSavedPresets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.presetSavedMessage)),
      );
    } on PresetValidationException catch (e) {
      if (!mounted) return;
      final message = e.isEmptyName
          ? l10n.presetEmptyNameError
          : l10n.presetMaxReachedError(PresetService.maxPresets);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _confirmDeletePreset(
    AppLocalizations l10n,
    SessionPreset preset,
  ) async {
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
    await _loadSavedPresets();
  }

  void _applySavedPreset(SessionPreset preset) {
    final format = preset.oneOnOneFormat;
    if (format == null) return;
    setState(() => _selectedFormat = format);
  }

  Widget _buildSavedPresetsSection(AppLocalizations l10n) {
    if (_savedPresets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.presetSavedSectionTitle,
          style: PlayTextStyles.caption(),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _savedPresets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final preset = _savedPresets[index];
              return HomePresetChip(
                preset: preset,
                l10n: l10n,
                onTap: () => _applySavedPreset(preset),
                onDelete: () => _confirmDeletePreset(l10n, preset),
              );
            },
          ),
        ),
        PresetManageHint(
          text: l10n.presetDeleteHint,
          usePlayStyle: true,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormatSetup(AppLocalizations l10n) {
    return PlayPageScroll(
      children: [
        _buildSavedPresetsSection(l10n),
        Text(
          l10n.oneOnOneFormatTitle,
          style: PlayTextStyles.prompt(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.oneOnOneFormatSubtitle,
          style: PlayTextStyles.hint(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...OneOnOneSessionFormat.values.map((format) {
          final selected = _selectedFormat == format;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedFormat = format),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? PlayColors.accent.withValues(alpha: 0.1)
                        : PlayColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? PlayColors.accent : PlayColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 22,
                        color: selected
                            ? PlayColors.accent
                            : PlayColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        format.icon,
                        size: 22,
                        color: selected
                            ? PlayColors.accent
                            : PlayColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format.title(l10n),
                              style: PlayTextStyles.listItem().copyWith(
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              format.description(l10n),
                              style: PlayTextStyles.hint(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        PlayPrimaryButton(
          label: l10n.oneOnOneStartSession,
          icon: Icons.play_arrow,
          onPressed: _startSession,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showSavePresetDialog(l10n),
          icon: Icon(Icons.bookmark_add_outlined, color: PlayColors.textSecondary),
          label: Text(
            l10n.presetSave,
            style: PlayTextStyles.hint(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseStrip(AppLocalizations l10n) {
    final phases = _activePhases;
    final languageCode = Localizations.localeOf(context).languageCode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _PhaseStripMetrics.forLayout(
          width: constraints.maxWidth,
          phaseCount: phases.length,
          languageCode: languageCode,
        );
        final strip = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < phases.length; i++) ...[
              if (i > 0)
                SizedBox(
                  width: metrics.connectorWidth,
                  child: Container(
                    height: 2,
                    margin: EdgeInsets.only(bottom: metrics.labelSpacing + 12),
                    color: i <= _phaseIndex
                        ? PlayColors.accent.withValues(alpha: 0.55)
                        : PlayColors.border,
                  ),
                ),
              _PhaseDot(
                label: _phaseTitle(l10n, phases[i]),
                isActive: i == _phaseIndex,
                isCompleted: i < _phaseIndex,
                phase: phases[i],
                dotWidth: metrics.dotWidth,
                iconCircleSize: metrics.iconCircleSize,
                iconSize: metrics.iconSize,
                labelFontSize: metrics.labelFontSize,
              ),
            ],
          ],
        );

        return SingleChildScrollView(
          controller: _phaseStripScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: strip,
          ),
        );
      },
    );
  }

  Widget _buildSelectedPrompt(AppLocalizations l10n) {
    final question = _selectedQuestion!;
    final accent = _OneOnOnePhaseColors.accentFor(_currentPhase);
    final icon = _OneOnOnePhaseColors.iconFor(_currentPhase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oneOnOneTalkingAbout,
          style: PlayTextStyles.caption(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.65), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: accent),
              const SizedBox(height: 12),
              Text(
                question,
                textAlign: TextAlign.center,
                style: PlayTextStyles.prompt(fontSize: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: _clearSelection,
            child: Text(
              l10n.oneOnOneChangeQuestion,
              style: PlayTextStyles.hint().copyWith(
                color: PlayColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateList(AppLocalizations l10n) {
    final pool = _questionsByPhase?[_currentPhase] ?? [];
    final canShowMore = pool.length > _candidateCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oneOnOnePickPrompt,
          style: PlayTextStyles.sectionTitle(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ..._candidateQuestions.map((question) {
          final isSelected = _selectedQuestion == question;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectQuestion(question),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PlayColors.accent.withValues(alpha: 0.1)
                        : PlayColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? PlayColors.accent
                          : PlayColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 22,
                        color: isSelected
                            ? PlayColors.accent
                            : PlayColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question,
                          style: PlayTextStyles.listItem().copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (canShowMore) ...[
          const SizedBox(height: 4),
          PlayOutlineButton(
            label: l10n.oneOnOneMoreCandidates,
            onPressed: _moreCandidates,
          ),
        ],
      ],
    );
  }

  Widget _buildSessionBody(AppLocalizations l10n) {
    final totalPhases = _activePhases.length;

    return PlayPageScroll(
      children: [
        Text(
          l10n.oneOnOnePhaseProgress(
            _phaseIndex + 1,
            totalPhases,
          ),
          style: PlayTextStyles.caption(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _buildPhaseStrip(l10n),
        const SizedBox(height: 16),
        _buildThemeAgenda(l10n),
        if (_selectedThemeCount == 0) ...[
          const SizedBox(height: 20),
          Text(
            _phaseTitle(l10n, _currentPhase),
            style: PlayTextStyles.prompt(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _phaseHint(l10n, _currentPhase),
            style: PlayTextStyles.hint(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
        ] else
          const SizedBox(height: 20),
        if (_selectedQuestion != null) ...[
          _buildSelectedPrompt(l10n),
          const SizedBox(height: 8),
        ] else ...[
          _buildCandidateList(l10n),
        ],
        const SizedBox(height: 20),
        PlayPrimaryButton(
          label: _isLastPhase
              ? l10n.oneOnOneCompleteSession
              : l10n.oneOnOneNextPhase,
          icon: _isLastPhase ? Icons.check_circle : Icons.arrow_forward,
          onPressed: _selectedQuestion == null ? null : _goToNextPhase,
        ),
        if (_phaseIndex > 0) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _goToPreviousPhase,
            icon: Icon(
              Icons.arrow_back,
              size: 18,
              color: PlayColors.textSecondary,
            ),
            label: Text(
              l10n.oneOnOnePreviousPhase,
              style: PlayTextStyles.hint(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: PlayColors.accent),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.errorDataLoadMessage,
                style: PlayTextStyles.hint(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              PlayPrimaryButton(
                label: l10n.retry,
                onPressed: _loadData,
              ),
            ],
          ),
        ),
      );
    }

    if (!_sessionStarted) {
      return _buildFormatSetup(l10n);
    }

    return _buildSessionBody(l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PlaySessionScaffold(
      title: l10n.homeThemeShortOneOnOne,
      onBack: _goHome,
      backTooltip: l10n.backToModeSelection,
      body: _buildBody(l10n),
    );
  }
}

/// ダーク UI 向けのフェーズ別アクセント色
abstract final class _OneOnOnePhaseColors {
  static Color accentFor(OneOnOnePhase phase) {
    switch (phase) {
      case OneOnOnePhase.checkin:
        return HomePalette.accent;
      case OneOnOnePhase.workAndWorkstyle:
        return const Color(0xFF64B5F6);
      case OneOnOnePhase.growthAndCareer:
        return HomePalette.accentOrange;
      case OneOnOnePhase.growthRelationship:
        return HomePalette.accentCoral;
      case OneOnOnePhase.closing:
        return HomePalette.purple;
    }
  }

  static IconData iconFor(OneOnOnePhase phase) {
    switch (phase) {
      case OneOnOnePhase.checkin:
        return Icons.wb_sunny_outlined;
      case OneOnOnePhase.workAndWorkstyle:
        return Icons.work_outline;
      case OneOnOnePhase.growthAndCareer:
        return Icons.psychology_outlined;
      case OneOnOnePhase.growthRelationship:
        return Icons.people_outline;
      case OneOnOnePhase.closing:
        return Icons.flag_outlined;
    }
  }
}

class _PhaseStripMetrics {
  final double dotWidth;
  final double connectorWidth;
  final double iconCircleSize;
  final double iconSize;
  final double labelFontSize;
  final double labelSpacing;

  const _PhaseStripMetrics({
    required this.dotWidth,
    required this.connectorWidth,
    required this.iconCircleSize,
    required this.iconSize,
    required this.labelFontSize,
    required this.labelSpacing,
  });

  double get itemStride => dotWidth + connectorWidth;

  static _PhaseStripMetrics forLayout({
    required double width,
    required int phaseCount,
    required String languageCode,
  }) {
    final base = _baseForWidth(width);
    if (languageCode != 'en' || phaseCount <= 3) {
      return base;
    }

    final extraDotWidth = phaseCount >= 5 ? 10.0 : 6.0;
    return _PhaseStripMetrics(
      dotWidth: base.dotWidth + extraDotWidth,
      connectorWidth: base.connectorWidth,
      iconCircleSize: base.iconCircleSize,
      iconSize: base.iconSize,
      labelFontSize: base.labelFontSize,
      labelSpacing: base.labelSpacing,
    );
  }

  static _PhaseStripMetrics _baseForWidth(double width) {
    if (width >= 520) {
      return const _PhaseStripMetrics(
        dotWidth: 56,
        connectorWidth: 12,
        iconCircleSize: 36,
        iconSize: 18,
        labelFontSize: 9,
        labelSpacing: 4,
      );
    }
    if (width >= 380) {
      return const _PhaseStripMetrics(
        dotWidth: 48,
        connectorWidth: 8,
        iconCircleSize: 32,
        iconSize: 16,
        labelFontSize: 8.5,
        labelSpacing: 4,
      );
    }
    return const _PhaseStripMetrics(
      dotWidth: 42,
      connectorWidth: 6,
      iconCircleSize: 28,
      iconSize: 14,
      labelFontSize: 8,
      labelSpacing: 3,
    );
  }
}

class _PhaseDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;
  final OneOnOnePhase phase;
  final double dotWidth;
  final double iconCircleSize;
  final double iconSize;
  final double labelFontSize;

  const _PhaseDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.phase,
    required this.dotWidth,
    required this.iconCircleSize,
    required this.iconSize,
    required this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _OneOnOnePhaseColors.accentFor(phase);
    final icon = _OneOnOnePhaseColors.iconFor(phase);
    final filled = isActive || isCompleted;

    return SizedBox(
      width: dotWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconCircleSize,
            height: iconCircleSize,
            decoration: BoxDecoration(
              color: filled
                  ? accent.withValues(alpha: isActive ? 0.22 : 0.14)
                  : PlayColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? accent
                    : filled
                        ? accent.withValues(alpha: 0.45)
                        : PlayColors.border,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: filled ? accent : PlayColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: dotWidth,
            height: labelFontSize * 2.6,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: PlayTextStyles.caption(isActive ? 1 : 0.65).copyWith(
                  fontSize: labelFontSize,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
