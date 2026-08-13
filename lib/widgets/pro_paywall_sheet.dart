import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:theme_dice/l10n/app_localizations.dart';
import 'package:theme_dice/services/purchase_service.dart';
import 'package:theme_dice/widgets/home/home_palette.dart';

/// Pro 案内（簡易ペイウォール）。購入・復元成功で true を返す。
Future<bool?> showProPaywallSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: HomePalette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _ProPaywallSheet(),
  );
}

class _ProPaywallSheet extends StatefulWidget {
  const _ProPaywallSheet();

  @override
  State<_ProPaywallSheet> createState() => _ProPaywallSheetState();
}

class _ProPaywallSheetState extends State<_ProPaywallSheet> {
  bool _busy = false;
  bool _loadingPrice = false;
  String? _price;

  TextStyle get _titleStyle => GoogleFonts.zenKakuGothicNew(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: HomePalette.text,
      );

  TextStyle get _bodyStyle => GoogleFonts.zenKakuGothicNew(
        fontSize: 14,
        height: 1.45,
        color: HomePalette.textMuted,
      );

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    if (!PurchaseService.iapEnabled) {
      return;
    }
    setState(() => _loadingPrice = true);
    await PurchaseService.refreshProducts();
    if (!mounted) return;
    setState(() {
      _price = PurchaseService.proPrice;
      _loadingPrice = false;
    });
  }

  String _purchaseLabel(AppLocalizations l10n) {
    if (!PurchaseService.iapEnabled && kDebugMode) {
      return l10n.proUnlockDebug;
    }
    final price = _price;
    if (price != null && price.isNotEmpty) {
      return l10n.proUnlockWithPrice(price);
    }
    return l10n.proUnlock;
  }

  Future<void> _onPurchase() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = await PurchaseService.purchasePro();
      if (!mounted) return;
      _handleResult(result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onRestore() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = await PurchaseService.restorePurchases();
      if (!mounted) return;
      _handleResult(result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _handleResult(PurchaseActionResult result) {
    final l10n = AppLocalizations.of(context)!;
    switch (result) {
      case PurchaseActionResult.unlockedLocally:
      case PurchaseActionResult.purchased:
      case PurchaseActionResult.restored:
      case PurchaseActionResult.alreadyPro:
        Navigator.of(context).pop(true);
      case PurchaseActionResult.nothingToRestore:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proRestoreNothing)),
        );
      case PurchaseActionResult.canceled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proPurchaseCanceled)),
        );
      case PurchaseActionResult.pending:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proPurchasePending)),
        );
      case PurchaseActionResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proPurchaseError)),
        );
      case PurchaseActionResult.unavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.proPurchaseUnavailable)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useStore = PurchaseService.iapEnabled;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.proPaywallTitle, style: _titleStyle),
            const SizedBox(height: 8),
            Text(l10n.proPaywallSubtitle, style: _bodyStyle),
            const SizedBox(height: 16),
            _BenefitRow(text: l10n.proBenefitExport),
            _BenefitRow(text: l10n.proBenefitPreset),
            if (kDebugMode && !useStore) ...[
              const SizedBox(height: 12),
              Text(l10n.proDebugHint, style: _bodyStyle),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy || _loadingPrice ? null : _onPurchase,
              style: FilledButton.styleFrom(
                backgroundColor: HomePalette.accent,
                foregroundColor: HomePalette.bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _busy || _loadingPrice
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _purchaseLabel(l10n),
                      style: GoogleFonts.zenKakuGothicNew(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _onRestore,
              child: Text(l10n.proRestore),
            ),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: HomePalette.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.zenKakuGothicNew(
                fontSize: 14,
                color: HomePalette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
