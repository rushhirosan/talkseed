import 'package:flutter/material.dart';
import 'package:theme_dice/l10n/app_localizations.dart';

/// プレイヤー情報を表示するウィジェット
class PlayerIndicator extends StatelessWidget {
  final int currentPlayerIndex;
  final int totalPlayers;
  final String? currentPlayerName;
  
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
    
    // カスタムプレイヤー名がある場合はそれを表示、ない場合は番号のみ
    final displayText = currentPlayerName != null
        ? '$currentPlayerName (${currentPlayerIndex + 1}/$totalPlayers)'
        : l10n.currentPlayer(currentPlayerIndex + 1, totalPlayers);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _mustardYellow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _black, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            color: _black,
          ),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _black,
            ),
          ),
        ],
      ),
    );
  }
}
