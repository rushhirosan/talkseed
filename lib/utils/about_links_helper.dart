import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/services/purchase_service.dart';
import 'package:theme_dice/widgets/pro_paywall_sheet.dart';

/// サポート・プライバシーポリシーへのリンクを表示する共通ヘルパー
class AboutLinksHelper {
  AboutLinksHelper._();

  static const String supportUrl = 'https://talk-seed.web.app/support.html';
  static const String privacyUrl = 'https://talk-seed.web.app/privacy.html';

  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static void showAboutSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parentContext = context;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: Text(l10n.support),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    openUrl(supportUrl);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyPolicy),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    openUrl(privacyUrl);
                  },
                ),
                if (PurchaseService.iapEnabled)
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: Text(l10n.proRestore),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final result = await PurchaseService.restorePurchases();
                      if (!parentContext.mounted) return;
                      final messenger = ScaffoldMessenger.of(parentContext);
                      final msg = switch (result) {
                        PurchaseActionResult.purchased ||
                        PurchaseActionResult.restored ||
                        PurchaseActionResult.unlockedLocally ||
                        PurchaseActionResult.alreadyPro =>
                          l10n.proRestoreSuccess,
                        PurchaseActionResult.nothingToRestore =>
                          l10n.proRestoreNothing,
                        PurchaseActionResult.canceled =>
                          l10n.proPurchaseCanceled,
                        PurchaseActionResult.pending => l10n.proPurchasePending,
                        PurchaseActionResult.error ||
                        PurchaseActionResult.unavailable =>
                          l10n.proPurchaseUnavailable,
                      };
                      messenger.showSnackBar(SnackBar(content: Text(msg)));
                    },
                  ),
                if (kDebugMode) _DebugProSection(parentContext: parentContext),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// debug ビルド専用: Pro ゲート / ON・OFF のローカル切替
class _DebugProSection extends StatefulWidget {
  const _DebugProSection({required this.parentContext});

  /// About シートの下の画面（ペイウォール表示用）
  final BuildContext parentContext;

  @override
  State<_DebugProSection> createState() => _DebugProSectionState();
}

class _DebugProSectionState extends State<_DebugProSection> {
  bool _loading = true;
  bool _gating = true;
  bool _pro = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final gating = await PurchaseService.debugGatingEnabledValue();
    final pro = await PurchaseService.isPro();
    if (!mounted) return;
    setState(() {
      _gating = gating;
      _pro = pro;
      _loading = false;
    });
  }

  Future<void> _setPro(bool enabled) async {
    await PurchaseService.setDebugProEnabled(enabled);
    await _reload();
  }

  Future<void> _showPaywall() async {
    // 繰り返し確認用: いったんオフにしてからペイウォールを出す
    await PurchaseService.setDebugGatingEnabled(true);
    await PurchaseService.setDebugProEnabled(false);
    if (!mounted) return;
    Navigator.of(context).pop();
    final parent = widget.parentContext;
    if (!parent.mounted) return;
    await showProPaywallSheet(parent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        ListTile(
          dense: true,
          title: Text(l10n.proDebugSectionTitle),
          subtitle: Text(l10n.proDebugSectionSubtitle),
        ),
        SwitchListTile(
          title: Text(l10n.proDebugGatingToggle),
          subtitle: Text(l10n.proDebugGatingSubtitle),
          value: _gating,
          onChanged: (value) async {
            await PurchaseService.setDebugGatingEnabled(value);
            await _reload();
          },
        ),
        SwitchListTile(
          title: Text(l10n.proDebugProToggle),
          subtitle: Text(l10n.proDebugProSubtitle),
          value: _pro,
          onChanged: _setPro,
        ),
        ListTile(
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(l10n.proDebugShowPaywall),
          subtitle: Text(l10n.proDebugShowPaywallSubtitle),
          onTap: _showPaywall,
        ),
      ],
    );
  }
}
