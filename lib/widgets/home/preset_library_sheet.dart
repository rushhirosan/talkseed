import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/models/session_preset.dart';
import 'package:theme_dice/services/preset_service.dart';
import 'package:theme_dice/utils/preset_display.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';
import 'package:theme_dice/widgets/home/home_preset_chip.dart';
import 'package:theme_dice/widgets/home/preset_manage_hint.dart';

/// ヘッダーのプリセットアイコンから開く一覧ボトムシート
Future<void> showPresetLibrarySheet({
  required BuildContext context,
  required VoidCallback onPresetsChanged,
  required Future<void> Function(SessionPreset preset) onLaunchPreset,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PresetLibrarySheet(
      onPresetsChanged: onPresetsChanged,
      onLaunchPreset: onLaunchPreset,
    ),
  );
}

class _PresetLibrarySheet extends StatefulWidget {
  final VoidCallback onPresetsChanged;
  final Future<void> Function(SessionPreset preset) onLaunchPreset;

  const _PresetLibrarySheet({
    required this.onPresetsChanged,
    required this.onLaunchPreset,
  });

  @override
  State<_PresetLibrarySheet> createState() => _PresetLibrarySheetState();
}

class _PresetLibrarySheetState extends State<_PresetLibrarySheet> {
  List<SessionPreset> _presets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await PresetService.listPresets();
    if (!mounted) return;
    setState(() {
      _presets = presets;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(
    AppLocalizations l10n,
    SessionPreset preset,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.presetDeleteConfirmTitle),
        content: Text(l10n.presetDeleteConfirmMessage(preset.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.presetDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await PresetService.deletePreset(preset.id);
    widget.onPresetsChanged();
    await _loadPresets();
  }

  Future<void> _launchPreset(SessionPreset preset) async {
    Navigator.of(context).pop();
    await widget.onLaunchPreset(preset);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final grouped = groupPresetsByMode(_presets);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: _presets.isEmpty ? 0.35 : 0.55,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: HomePalette.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: HomePalette.border),
                left: BorderSide(color: HomePalette.border),
                right: BorderSide(color: HomePalette.border),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: HomePalette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.presetLibraryTitle,
                          style: GoogleFonts.zenKakuGothicNew(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: HomePalette.text,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: HomePalette.textMuted,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                if (!_loading && _presets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: PresetManageHint(text: l10n.presetDeleteHint),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _presets.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  l10n.presetLibraryEmpty,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.zenKakuGothicNew(
                                    fontSize: 14,
                                    color: HomePalette.textMuted,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            )
                          : ListView(
                              controller: scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 0, 20, 32),
                              children: [
                                for (final entry in grouped.entries) ...[
                                  Text(
                                    presetModeSectionTitle(entry.key, l10n),
                                    style: GoogleFonts.zenKakuGothicNew(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: HomePalette.accent,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (final preset in entry.value)
                                        HomePresetChip(
                                          preset: preset,
                                          l10n: l10n,
                                          onTap: () => _launchPreset(preset),
                                          onDelete: () =>
                                              _confirmDelete(l10n, preset),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ],
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
