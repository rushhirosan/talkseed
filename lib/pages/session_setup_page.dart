import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_primary_button.dart';
import 'package:theme_dice/widgets/home/home_scaffold.dart';
import 'package:theme_dice/widgets/home/home_toggle_icon_button.dart';
import '../models/card_deck.dart';
import '../models/session_config.dart' show SessionConfig;
import '../models/polyhedron_type.dart';
import '../utils/preferences_helper.dart';
import '../utils/route_transitions.dart';
import 'dice_page.dart';
import 'value_card_page.dart';
import 'discussion_prompt_page.dart';
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
  /// true のとき「スタート」で DiscussionPromptPage へ遷移（グループディスカッションデッキ）
  final bool forDiscussion;
  /// forValueCard / forDiscussion 時のみ。true なら戻るで CardSettingsPage、false なら ModeSelectionPage
  final bool fromCardSettings;
  /// セッションプレビューに表示するデッキ名（forDiscussion 時に使用）
  final String? deckLabel;
  /// 議論モード時カテゴリー別カード配置に使う（グループディスカッション）
  final CardDeckType? discussionDeckType;

  const SessionSetupPage({
    super.key,
    required this.themes,
    this.fromDicePage = false,
    this.forValueCard = false,
    this.forDiscussion = false,
    this.fromCardSettings = false,
    this.deckLabel,
    this.discussionDeckType,
  });

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  late SessionConfig _config;
  /// 議論モードのみ: 選んだ各カテゴリーから卓に出す枚数（カテゴリー内）
  int _discussionPromptsPerCategory = 1;
  /// 議論モードのみ: 話すお題の目安枚数。null = プール最大（「すべて」）
  int? _discussionTotalPromptsOnTableSelection;
  /// 議論モード: 卓に出すカテゴリー（空＝未選択。スタート時は1つ以上必須）
  Set<String> _discussionIncludedCategories = {};
  final List<TextEditingController> _playerNameControllers = [];
  final List<FocusNode> _playerNameFocusNodes = [];
  bool _vibrationEnabled = true;
  bool _timerSoundEnabled = true;

  final ScrollController _rightScrollController = ScrollController();

  TextStyle _labelStyle({double fontSize = 20}) => GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: HomePalette.text,
      );

  TextStyle _hintStyle() => GoogleFonts.zenKakuGothicNew(
        fontSize: 13,
        height: 1.35,
        color: HomePalette.textMuted,
      );

  TextStyle _bodyStyle({double fontSize = 14, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.zenKakuGothicNew(
        fontSize: fontSize,
        fontWeight: weight,
        color: const Color(0xFFB8B8D4),
      );

  static const double _stackedLayoutBreakpoint = 560;

  @override
  void initState() {
    super.initState();
    _config = SessionConfig.defaultConfig;
    _discussionPromptsPerCategory = 1;
    _discussionTotalPromptsOnTableSelection = null;
    _discussionIncludedCategories = {};
    _initializePlayerNames();
    _loadFeedbackSettings();
  }

  Future<void> _loadFeedbackSettings() async {
    final vibration = await PreferencesHelper.loadVibrationEnabled();
    final timerSound = await PreferencesHelper.loadTimerSoundEnabled();
    if (mounted) {
      setState(() {
        _vibrationEnabled = vibration;
        _timerSoundEnabled = timerSound;
      });
    }
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

  Future<void> _toggleTimerSound(bool enabled) async {
    await PreferencesHelper.saveTimerSoundEnabled(enabled);
    if (mounted) setState(() => _timerSoundEnabled = enabled);
  }

  void _startSession() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.forDiscussion && widget.discussionDeckType != null) {
      if (_discussionIncludedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.discussionSelectAtLeastOneCategory)),
        );
        return;
      }
    }

    final playerNames = List.generate(
      _config.playerCount,
      (i) => _playerNameControllers[i].text.trim(),
    );

    final finalConfig = _config.copyWith(
      playerNames: playerNames,
      applyDiscussionPromptCap: widget.forDiscussion,
      discussionPromptCap: null,
      applyDiscussionPromptsPerCategory: widget.forDiscussion,
      discussionPromptsPerCategory:
          widget.forDiscussion ? _discussionPromptsPerCategory : null,
      applyDiscussionTotalPromptsOnTable: widget.forDiscussion,
      discussionTotalPromptsOnTable:
          widget.forDiscussion ? _discussionTotalPromptsOnTableSelection : null,
      applyDiscussionCategoryIds:
          widget.forDiscussion && widget.discussionDeckType != null,
      discussionCategoryIds: widget.forDiscussion &&
              widget.discussionDeckType != null
          ? _discussionCategoryIdsForSession()
          : null,
    );
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
    } else if (widget.forDiscussion && themes != null) {
      Navigator.of(context).push(
        RouteTransitions.forwardRoute(
          page: DiscussionPromptPage(
            themes: themes,
            sessionConfig: finalConfig,
            deckTitle: widget.deckLabel ?? l10n.discussionScreenTitle,
            discussionDeckType: widget.discussionDeckType,
          ),
        ),
      );
    } else {
      // push にしてサイコロ画面の戻るでセッション設定へ pop できるようにする
      Navigator.of(context).push(
        RouteTransitions.forwardRoute(
          page: DicePage(
            initialThemes: widget.themes,
            sessionConfig: finalConfig,
          ),
        ),
      );
    }
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

  void _onBack() {
    if (widget.forValueCard || widget.forDiscussion) {
      if (widget.fromCardSettings) {
        Navigator.of(context).pushReplacement(
          RouteTransitions.backRoute(page: const CardSettingsPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          RouteTransitions.backRoute(page: const ModeSelectionPage()),
        );
      }
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _panel({
    required Widget child,
    required EdgeInsets padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HomePalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomePalette.border),
      ),
      padding: padding,
      child: child,
    );
  }

  Widget _buildSessionBody(AppLocalizations l10n, bool isValueCardLayout) {
    final panelPadding = isValueCardLayout
        ? const EdgeInsets.fromLTRB(20, 20, 20, 20)
        : const EdgeInsets.all(24);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < _stackedLayoutBreakpoint;
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final outerPadding = EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset);

        if (isValueCardLayout) {
          if (stacked) {
            return Padding(
              padding: outerPadding,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _panel(
                      padding: panelPadding,
                      child: _buildLeftSection(l10n),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      padding: panelPadding,
                      child: _buildRightSection(l10n, scrollEmbedded: true),
                    ),
                  ],
                ),
              ),
            );
          }
          return Padding(
            padding: outerPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 9,
                  child: _panel(
                    padding: panelPadding,
                    child: SingleChildScrollView(
                      child: _buildLeftSection(l10n),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 11,
                  child: _panel(
                    padding: panelPadding,
                    child: _buildRightSection(l10n),
                  ),
                ),
              ],
            ),
          );
        }

        if (stacked) {
          return Padding(
            padding: outerPadding,
            child: _panel(
              padding: panelPadding,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLeftSection(l10n),
                    const SizedBox(height: 24),
                    Divider(color: HomePalette.border, height: 1),
                    const SizedBox(height: 24),
                    _buildRightSection(l10n, scrollEmbedded: true),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: outerPadding,
          child: _panel(
            padding: panelPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildLeftSection(l10n),
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: HomePalette.border,
                ),
                Expanded(child: _buildRightSection(l10n)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isValueCardLayout = widget.forValueCard || widget.forDiscussion;
    final backTooltip = (widget.forValueCard || widget.forDiscussion)
        ? l10n.backToModeSelection
        : l10n.backToThemeSettings;

    return HomeScaffold(
      title: l10n.sessionSetup,
      leading: HomeBackButton(
        onPressed: _onBack,
        tooltip: backTooltip,
      ),
      body: _buildSessionBody(l10n, isValueCardLayout),
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
    final compact = widget.forValueCard || widget.forDiscussion;
    final sectionSpacing = compact ? 20.0 : 24.0;
    final itemSpacing = compact ? 8.0 : 12.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.playerCount, style: _labelStyle()),
        SizedBox(height: itemSpacing),
        _buildDropdown<int>(
          value: _config.playerCount,
          items: List.generate(9, (i) => i + 2),
          labelBuilder: (v) => '$v',
          onChanged: (v) => v != null ? _updatePlayerCount(v) : null,
        ),
        SizedBox(height: sectionSpacing),
        _buildFeedbackIconRow(l10n, gap: itemSpacing),
        if (_config.enableTimer) ...[
          SizedBox(height: itemSpacing),
          Text(l10n.timerDuration, style: _bodyStyle(fontSize: 14)),
          SizedBox(height: compact ? 6 : 8),
          _buildDropdown<Duration>(
            value: _config.timerDuration,
            items: _timerDurations,
            labelBuilder: (d) => _getTimerLabel(l10n, d),
            onChanged: (v) => v != null ? _updateTimerDuration(v) : null,
          ),
        ],
        if (widget.forDiscussion) ...[
          SizedBox(height: sectionSpacing),
          _buildDiscussionThemeFilter(l10n),
          SizedBox(height: sectionSpacing),
          _buildDiscussionDeckScope(l10n),
          SizedBox(height: sectionSpacing),
          _buildDiscussionTotalThemesOnTable(l10n),
        ],
        SizedBox(height: sectionSpacing),
        _buildSessionPreview(l10n),
      ],
    );
  }

  Widget _buildSessionPreview(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HomePalette.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.sessionPreviewTitle,
            style: _bodyStyle(fontSize: 12, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sessionPreviewPlayers(_config.playerCount),
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HomePalette.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _config.enableTimer
                ? l10n.sessionPreviewTimer(_getTimerLabel(l10n, _config.timerDuration))
                : l10n.sessionPreviewNoTimer,
            style: _bodyStyle(fontSize: 14),
          ),
          if (widget.forDiscussion) ...[
            const SizedBox(height: 8),
            Text(
              l10n.discussionPreviewSessionEnd,
              style: _hintStyle(),
            ),
          ],
        ],
      ),
    );
  }

  String _discussionPromptPreviewSummary(AppLocalizations l10n) {
    if (!widget.forDiscussion || widget.discussionDeckType == null) {
      return '';
    }
    final dt = widget.discussionDeckType!;
    if (_discussionIncludedCategories.isEmpty) {
      return l10n.discussionPreviewNeedCategorySelection;
    }
    final allOrder = CardDeck.discussionCategoryDisplayOrder(dt);
    final ids = _discussionIncludedCategories.length >= allOrder.length
        ? allOrder.toSet()
        : Set<String>.from(_discussionIncludedCategories);
    final total = CardDeck.discussionMaxCardsWithPerCategoryLimit(
      deckType: dt,
      categoryIds: ids,
      promptsPerCategory: _discussionPromptsPerCategory,
    );
    return l10n.discussionPreviewPerCategory(
      _discussionPromptsPerCategory,
      total,
    );
  }

  /// 現在のカテゴリー選択・カテゴリーごとの上限でのお題プール合計（上限）
  int _discussionMaxTablePrompts() {
    if (!widget.forDiscussion || widget.discussionDeckType == null) return 0;
    if (_discussionIncludedCategories.isEmpty) return 0;
    final dt = widget.discussionDeckType!;
    final allOrder = CardDeck.discussionCategoryDisplayOrder(dt);
    final ids = _discussionIncludedCategories.length >= allOrder.length
        ? allOrder.toSet()
        : Set<String>.from(_discussionIncludedCategories);
    return CardDeck.discussionMaxCardsWithPerCategoryLimit(
      deckType: dt,
      categoryIds: ids,
      promptsPerCategory: _discussionPromptsPerCategory,
    );
  }

  /// 話すお題の目安として選ばれている枚数（プール上限とドロップダウンから）
  int _discussionEffectiveTablePromptCount() {
    final max = _discussionMaxTablePrompts();
    if (max <= 0) return 0;
    final cap = _discussionTotalPromptsOnTableSelection;
    if (cap == null) return max;
    return cap < max ? cap : max;
  }

  void _clampDiscussionTotalPromptsOnTable() {
    final max = _discussionMaxTablePrompts();
    if (max <= 0) {
      _discussionTotalPromptsOnTableSelection = null;
      return;
    }
    final cap = _discussionTotalPromptsOnTableSelection;
    if (cap != null && cap > max) {
      _discussionTotalPromptsOnTableSelection = max;
    }
  }

  /// 全カテゴリ選択時は null（セッションは「絞りなし」）。未選択の [] は明示的に空
  List<String>? _discussionCategoryIdsForSession() {
    final dt = widget.discussionDeckType;
    if (dt == null) return null;
    final allOrder = CardDeck.discussionCategoryDisplayOrder(dt);
    if (_discussionIncludedCategories.isEmpty) {
      return [];
    }
    if (_discussionIncludedCategories.length >= allOrder.length) {
      return null;
    }
    return allOrder
        .where((id) => _discussionIncludedCategories.contains(id))
        .toList();
  }

  void _toggleDiscussionCategory(String categoryId) {
    if (widget.discussionDeckType == null) return;
    setState(() {
      if (_discussionIncludedCategories.contains(categoryId)) {
        _discussionIncludedCategories.remove(categoryId);
      } else {
        _discussionIncludedCategories.add(categoryId);
      }
      _clampDiscussionTotalPromptsOnTable();
    });
  }

  Widget _buildDiscussionThemeFilter(AppLocalizations l10n) {
    final dt = widget.discussionDeckType;
    if (dt == null) return const SizedBox.shrink();
    final order = CardDeck.discussionCategoryDisplayOrder(dt);
    if (order.length <= 1) return const SizedBox.shrink();
    final btnStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.discussionThemeFilterTitle, style: _labelStyle()),
        const SizedBox(height: 6),
        Text(l10n.discussionThemeFilterHint, style: _hintStyle()),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                style: btnStyle,
                onPressed: () {
                  setState(() {
                    _discussionIncludedCategories = Set<String>.from(order);
                    _clampDiscussionTotalPromptsOnTable();
                  });
                },
                child: Text(
                  l10n.discussionThemeFilterSelectAll,
                  style: GoogleFonts.zenKakuGothicNew(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: HomePalette.accent,
                  ),
                ),
              ),
              TextButton(
                style: btnStyle,
                onPressed: () {
                  setState(() {
                    _discussionIncludedCategories.clear();
                    _clampDiscussionTotalPromptsOnTable();
                  });
                },
                child: Text(
                  l10n.discussionThemeFilterClearAll,
                  style: GoogleFonts.zenKakuGothicNew(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: HomePalette.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 220;
            return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: narrow ? 1 : 2,
                mainAxisExtent: narrow ? 36 : 44,
                crossAxisSpacing: 6,
                mainAxisSpacing: 4,
              ),
              itemCount: order.length,
              itemBuilder: (context, index) {
                final id = order[index];
                final selected = _discussionIncludedCategories.contains(id);
                final title = CardDeck.discussionCategoryTitle(l10n, id);
                return Align(
                  alignment: Alignment.topLeft,
                  child: FilterChip(
                    label: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.zenKakuGothicNew(
                        fontSize: narrow ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: selected ? HomePalette.bg : HomePalette.text,
                        height: 1.15,
                      ),
                    ),
                selected: selected,
                showCheckmark: true,
                checkmarkColor: HomePalette.bg,
                selectedColor: HomePalette.purple,
                backgroundColor: HomePalette.surface2,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: selected
                      ? HomePalette.purple
                      : Colors.white.withValues(alpha: 0.15),
                  width: selected ? 2 : 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (_) => _toggleDiscussionCategory(id),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiscussionDeckScope(AppLocalizations l10n) {
    const itemSpacing = 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.discussionDeckScopeTitle, style: _labelStyle()),
        const SizedBox(height: 6),
        Text(l10n.discussionDeckScopeHint, style: _hintStyle()),
        const SizedBox(height: itemSpacing),
        _buildDropdown<int>(
          value: _discussionPromptsPerCategory,
          items: const [1, 2, 3, 5, 10],
          labelBuilder: (v) => l10n.discussionPerCategoryOption(v),
          onChanged: (v) => v != null
              ? setState(() {
                  _discussionPromptsPerCategory = v;
                  _clampDiscussionTotalPromptsOnTable();
                })
              : null,
        ),
        const SizedBox(height: itemSpacing),
        Text(
          _discussionPromptPreviewSummary(l10n),
          style: GoogleFonts.zenKakuGothicNew(
            fontSize: 14,
            height: 1.35,
            color: HomePalette.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionTotalThemesOnTable(AppLocalizations l10n) {
    const itemSpacing = 8.0;
    final maxPool = _discussionMaxTablePrompts();
    final bool poolReady = maxPool > 0;
    final items = poolReady
        ? <int?>[null, ...List.generate(maxPool, (i) => i + 1)]
        : <int?>[null];
    final selected = _discussionTotalPromptsOnTableSelection;
    final int? dropdownValue = poolReady
        ? (selected != null && selected > maxPool ? maxPool : selected)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.discussionTotalThemesOnTableTitle, style: _labelStyle()),
        const SizedBox(height: 6),
        Text(l10n.discussionTotalThemesOnTableHint, style: _hintStyle()),
        const SizedBox(height: itemSpacing),
        _buildDropdown<int?>(
          value: dropdownValue,
          items: items,
          labelBuilder: (v) {
            if (!poolReady) {
              return l10n.discussionTotalThemesOnTableDropdownDisabled;
            }
            return v == null
                ? l10n.discussionTotalThemesOnTableAllOption(maxPool)
                : l10n.discussionTotalThemesOnTableCountOption(v);
          },
          onChanged: poolReady
              ? (v) => setState(() => _discussionTotalPromptsOnTableSelection = v)
              : null,
        ),
        if (poolReady) ...[
          const SizedBox(height: itemSpacing),
          Text(
            l10n.discussionTotalThemesOnTableEffective(
              _discussionEffectiveTablePromptCount(),
            ),
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 14,
              height: 1.35,
              color: HomePalette.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ] else ...[
          const SizedBox(height: 6),
          Text(
            l10n.discussionPreviewNeedCategorySelection,
            style: _hintStyle(),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    void Function(T?)? onChanged,
  }) {
    final disabled = onChanged == null;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: HomePalette.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HomePalette.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: HomePalette.surface2,
            icon: Icon(
              Icons.arrow_drop_down,
              color: disabled ? HomePalette.textMuted : HomePalette.text,
            ),
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: disabled ? HomePalette.textMuted : HomePalette.text,
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
      ),
    );
  }

  Widget _buildFeedbackIconRow(AppLocalizations l10n, {required double gap}) {
    final timerEnabled = _config.enableTimer;
    return HomeToggleIconButtonRow(
      gap: gap,
      children: [
        HomeToggleIconButton(
          tooltip: l10n.timerSettings,
          enabled: timerEnabled,
          onPressed: () => _toggleTimer(!timerEnabled),
          icon: timerEnabled ? Icons.timer : Icons.timer_off,
        ),
        HomeToggleIconButton(
          tooltip: l10n.vibrationEnabled,
          enabled: _vibrationEnabled,
          onPressed: () => _toggleVibration(!_vibrationEnabled),
          icon: Icons.vibration,
        ),
        HomeToggleIconButton(
          tooltip: l10n.timerSoundEnabled,
          enabled: _timerSoundEnabled,
          onPressed: () => _toggleTimerSound(!_timerSoundEnabled),
          icon: _timerSoundEnabled ? Icons.volume_up : Icons.volume_off,
        ),
      ],
    );
  }

  Widget _buildRightSection(
    AppLocalizations l10n, {
    bool scrollEmbedded = false,
  }) {
    final compact = widget.forValueCard || widget.forDiscussion;
    final playerFields = List.generate(_config.playerCount, (index) {
      return Padding(
        padding: EdgeInsets.only(bottom: compact ? 10 : 12),
        child: _buildPlayerNameField(l10n, index),
      );
    });

    final playerList = scrollEmbedded
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: playerFields,
          )
        : Expanded(
            child: ListView(
              controller: _rightScrollController,
              primary: false,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                right: compact ? 12 : 20,
                bottom: (compact ? 16 : 12) +
                    MediaQuery.of(context).viewInsets.bottom +
                    (compact ? 12 : 24),
              ),
              children: playerFields,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: scrollEmbedded ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Text(
          l10n.playerNamesOptional,
          style: _labelStyle(fontSize: scrollEmbedded ? 20 : 24),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(l10n.playerNamesHint, style: _bodyStyle(fontSize: 14)),
        SizedBox(height: compact ? 16 : 24),
        playerList,
        const SizedBox(height: 12),
        HomePrimaryButton(
          label: l10n.startSession,
          icon: Icons.play_arrow,
          onPressed: _startSession,
          padding: EdgeInsets.symmetric(
            horizontal: scrollEmbedded ? 16 : 24,
            vertical: compact ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerNameField(AppLocalizations l10n, int index) {
    final tint = _playerFieldTint(index);
    final focusNode = _playerNameFocusNodes[index];
    final compact = widget.forValueCard || widget.forDiscussion;
    return Builder(
      builder: (fieldContext) {
        return Container(
          decoration: BoxDecoration(
            color: tint,
            border: Border.all(color: HomePalette.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _playerNameControllers[index],
            focusNode: focusNode,
            cursorColor: HomePalette.accent,
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!fieldContext.mounted) return;
                Scrollable.ensureVisible(
                  fieldContext,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: 0.35,
                );
              });
            },
            style: GoogleFonts.zenKakuGothicNew(
              fontSize: 14,
              color: HomePalette.text,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              labelText: l10n.playerName(index + 1),
              labelStyle: GoogleFonts.zenKakuGothicNew(
                fontSize: 12,
                color: HomePalette.textMuted,
                fontWeight: FontWeight.w400,
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
