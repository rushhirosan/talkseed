import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

/// プレイヤー情報を表示するウィジェット
class PlayerIndicator extends StatelessWidget {
  final int currentPlayerIndex;
  final int totalPlayers;
  final String? currentPlayerName;

  /// [build] と同じ規則で、番のラベル文字列だけを返す（お題との対応説明用）
  static String turnDisplayText({
    required AppLocalizations l10n,
    required int currentPlayerIndex,
    required int totalPlayers,
    String? currentPlayerName,
  }) {
    if (currentPlayerName != null) {
      return '$currentPlayerName (${currentPlayerIndex + 1}/$totalPlayers)';
    }
    return l10n.currentPlayer(currentPlayerIndex + 1, totalPlayers);
  }

  const PlayerIndicator({
    super.key,
    required this.currentPlayerIndex,
    required this.totalPlayers,
    this.currentPlayerName,
  });
  
  // カラーパレット（設定画面と統一）
  static const Color _mustardYellow = Color(0xFFFFEB3B);
  static const Color _black = Colors.black87;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final displayText = turnDisplayText(
      l10n: l10n,
      currentPlayerIndex: currentPlayerIndex,
      totalPlayers: totalPlayers,
      currentPlayerName: currentPlayerName,
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _mustardYellow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _black, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: _black, size: 20),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _black,
            ),
          ),
        ],
      ),
    );
  }
}
