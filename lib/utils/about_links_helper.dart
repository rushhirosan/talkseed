import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:theme_dice/l10n/app_localizations.dart';

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
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
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
            ],
          ),
        ),
      ),
    );
  }
}
