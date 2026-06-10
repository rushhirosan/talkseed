import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:theme_dice/exceptions/theme_dice_exceptions.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/card_deck.dart';
import 'package:theme_dice/models/session_record.dart';
import 'package:theme_dice/pages/mode_selection_page.dart';
import 'package:theme_dice/services/self_reflection_service.dart';
import 'package:theme_dice/services/session_record_service.dart';
import 'package:theme_dice/utils/session_end_dialog.dart';
import 'package:theme_dice/theme/talk_shuffle_theme.dart';
import 'package:theme_dice/utils/preferences_helper.dart';
import 'package:theme_dice/utils/route_transitions.dart';

/// 定例1on1向け：check-in → 仕事 → 振り返り → 締め の順で進むガイド付きセッション
class OneOnOneSessionPage extends StatefulWidget {
  const OneOnOneSessionPage({super.key});

  @override
  State<OneOnOneSessionPage> createState() => _OneOnOneSessionPageState();
}

class _OneOnOneSessionPageState extends State<OneOnOneSessionPage> {
  static const Color _white = Colors.white;
  static const Color _black = Colors.black87;
  static const int _candidateCount = 3;

  final Random _random = Random();

  Map<ReflectionDeckCategory, List<String>>? _questionsByPhase;
  Set<String> _deepDiveThemes = {};
  int _phaseIndex = 0;
  List<String> _candidateQuestions = [];
  String? _selectedQuestion;
  /// フェーズごとに確定した問い（sectionId → 問い）
  final Map<String, String> _selectedByPhaseId = {};
  /// 候補差し替え用：このフェーズで直近表示した問い
  final Set<String> _recentlyShownInPhase = {};

  bool _loading = true;
  Object? _loadError;

  ReflectionDeckCategory get _currentPhase =>
      ReflectionDeckCategory.orderedPhases[_phaseIndex];

  bool get _isLastPhase =>
      _phaseIndex >= ReflectionDeckCategory.orderedPhases.length - 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = await SelfReflectionService.loadSessionPhases();
      if (!mounted) return;
      setState(() {
        _questionsByPhase = data.questionsByPhase;
        _deepDiveThemes = data.deepDiveThemes;
        _loading = false;
      });
      _refreshCandidates(resetRecent: true);
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
    setState(() => _selectedQuestion = question);
    _triggerVibration();
  }

  void _clearSelection() {
    setState(() => _selectedQuestion = null);
  }

  void _commitCurrentPhaseSelection() {
    final question = _selectedQuestion;
    if (question == null || question.isEmpty) return;
    _selectedByPhaseId[_currentPhase.sectionId] = question;
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
          _selectedByPhaseId[_currentPhase.sectionId];
    });
    _refreshCandidates(
      resetRecent: true,
      clearSelection: _selectedQuestion == null,
    );
  }

  void _goToPreviousPhase() {
    if (_phaseIndex <= 0) return;
    setState(() {
      _phaseIndex--;
      _selectedQuestion =
          _selectedByPhaseId[_currentPhase.sectionId];
    });
    _refreshCandidates(
      resetRecent: true,
      clearSelection: _selectedQuestion == null,
    );
  }

  Map<String, List<String>> _buildHistoryPromptsByPhase() {
    final result = <String, List<String>>{};
    for (final phase in ReflectionDeckCategory.orderedPhases) {
      final question = _selectedByPhaseId[phase.sectionId];
      if (question != null && question.isNotEmpty) {
        result[phase.sectionId] = [question];
      }
    }
    return result;
  }

  Future<void> _completeSession() async {
    final record = SessionRecord.create(
      mode: SessionRecord.modeOneOnOne,
      topics: const [],
      selectedCardsByPlayer: _buildHistoryPromptsByPhase(),
    );
    await SessionRecordService.addRecord(record);
    if (!mounted) return;
    await SessionEndDialog.show(context);
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      RouteTransitions.backRoute(page: const ModeSelectionPage()),
    );
  }

  String _phaseTitle(AppLocalizations l10n, ReflectionDeckCategory phase) {
    switch (phase) {
      case ReflectionDeckCategory.checkin:
        return l10n.oneOnOnePhaseCheckin;
      case ReflectionDeckCategory.workStatus:
        return l10n.oneOnOnePhaseWorkStatus;
      case ReflectionDeckCategory.selfReflection:
        return l10n.oneOnOnePhaseSelfReflection;
      case ReflectionDeckCategory.growthRelationship:
        return l10n.oneOnOnePhaseGrowth;
    }
  }

  String _phaseHint(AppLocalizations l10n, ReflectionDeckCategory phase) {
    switch (phase) {
      case ReflectionDeckCategory.checkin:
        return l10n.oneOnOnePhaseHintCheckin;
      case ReflectionDeckCategory.workStatus:
        return l10n.oneOnOnePhaseHintWorkStatus;
      case ReflectionDeckCategory.selfReflection:
        return l10n.oneOnOnePhaseHintSelfReflection;
      case ReflectionDeckCategory.growthRelationship:
        return l10n.oneOnOnePhaseHintGrowth;
    }
  }

  String? _deepDiveLabel(AppLocalizations l10n, String? question) {
    if (question == null || question.isEmpty) return null;
    if (!_currentPhase.allowsDeepDiveLabel) return null;
    if (!_deepDiveThemes.contains(question)) return null;
    return l10n.reflectionDeepDiveLabel;
  }

  Widget _buildPhaseStrip(AppLocalizations l10n) {
    const phases = ReflectionDeckCategory.orderedPhases;
    return Row(
      children: [
        for (var i = 0; i < phases.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= _phaseIndex
                    ? _black.withValues(alpha: 0.35)
                    : _black.withValues(alpha: 0.12),
              ),
            ),
          _PhaseDot(
            label: _phaseTitle(l10n, phases[i]),
            isActive: i == _phaseIndex,
            isCompleted: i < _phaseIndex,
            category: phases[i],
          ),
          if (i < phases.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < _phaseIndex
                    ? _black.withValues(alpha: 0.35)
                    : _black.withValues(alpha: 0.12),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSelectedPrompt(AppLocalizations l10n) {
    final question = _selectedQuestion!;
    final style = ReflectionDeckCategoryStyle.forCategory(_currentPhase);
    final deepDive = _deepDiveLabel(l10n, question);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oneOnOneTalkingAbout,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _black.withValues(alpha: 0.55),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: style.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (deepDive != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    deepDive,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _black.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Icon(style.icon, size: 28, color: _black.withValues(alpha: 0.7)),
              const SizedBox(height: 12),
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _black,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: _clearSelection,
            child: Text(l10n.oneOnOneChangeQuestion),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateList(AppLocalizations l10n) {
    final style = ReflectionDeckCategoryStyle.forCategory(_currentPhase);
    final pool = _questionsByPhase?[_currentPhase] ?? [];
    final canShowMore = pool.length > _candidateCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.oneOnOnePickPrompt,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ..._candidateQuestions.map((question) {
          final isSelected = _selectedQuestion == question;
          final deepDive = _deepDiveLabel(l10n, question);
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
                    color: isSelected ? style.color : _white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _black : _black.withValues(alpha: 0.2),
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
                        color: _black.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (deepDive != null) ...[
                              Text(
                                deepDive,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _black.withValues(alpha: 0.55),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              question,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _black,
                                height: 1.35,
                              ),
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
        if (canShowMore) ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _moreCandidates,
            icon: const Icon(Icons.swap_horiz, color: _black),
            label: Text(l10n.oneOnOneMoreCandidates),
            style: OutlinedButton.styleFrom(
              foregroundColor: _black,
              side: BorderSide(color: _black.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ts = context.talkShuffle;
    final totalPhases = ReflectionDeckCategory.orderedPhases.length;

    return Scaffold(
      backgroundColor: ts.scaffoldPlayWarm,
      appBar: AppBar(
        backgroundColor: _white,
        elevation: 0,
        title: Text(
          l10n.homeThemeShortOneOnOne,
          style: const TextStyle(
            color: _black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _black),
          onPressed: _goHome,
          tooltip: l10n.backToModeSelection,
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.errorDataLoadMessage),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.oneOnOnePhaseProgress(
                            _phaseIndex + 1,
                            totalPhases,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _black.withValues(alpha: 0.55),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        _buildPhaseStrip(l10n),
                        const SizedBox(height: 20),
                        Text(
                          _phaseTitle(l10n, _currentPhase),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _phaseHint(l10n, _currentPhase),
                          style: TextStyle(
                            fontSize: 14,
                            color: _black.withValues(alpha: 0.65),
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        if (_selectedQuestion != null) ...[
                          _buildSelectedPrompt(l10n),
                          const SizedBox(height: 8),
                        ] else ...[
                          _buildCandidateList(l10n),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed:
                              _selectedQuestion == null ? null : _goToNextPhase,
                          icon: Icon(
                            _isLastPhase
                                ? Icons.check_circle
                                : Icons.arrow_forward,
                            color: _black,
                          ),
                          label: Text(
                            _isLastPhase
                                ? l10n.oneOnOneCompleteSession
                                : l10n.oneOnOneNextPhase,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ts.brandYellow,
                            foregroundColor: _black,
                            disabledBackgroundColor:
                                ts.brandYellow.withValues(alpha: 0.45),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                        ),
                        if (_phaseIndex > 0) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _goToPreviousPhase,
                            icon: Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: _black.withValues(alpha: 0.7),
                            ),
                            label: Text(
                              l10n.oneOnOnePreviousPhase,
                              style: TextStyle(
                                color: _black.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _PhaseDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;
  final ReflectionDeckCategory category;

  const _PhaseDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.category,
  });

  static const Color _black = Colors.black87;

  @override
  Widget build(BuildContext context) {
    final style = ReflectionDeckCategoryStyle.forCategory(category);
    final filled = isActive || isCompleted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: filled ? style.color : _black.withValues(alpha: 0.06),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? _black : _black.withValues(alpha: 0.2),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(
            style.icon,
            size: 18,
            color: _black.withValues(alpha: filled ? 0.85 : 0.35),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: _black.withValues(alpha: isActive ? 0.9 : 0.45),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
