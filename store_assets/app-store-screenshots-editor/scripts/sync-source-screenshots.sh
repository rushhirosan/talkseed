#!/usr/bin/env bash
# Copy raw captures from store_assets/screenshots into the editor's public/ folder.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EDITOR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_IOS="$ROOT/screenshots/ios/6.5inch"
SRC_IPAD="$ROOT/screenshots/ios/ipad-13inch"

for lang in en ja; do
  mkdir -p "$EDITOR/public/screenshots/apple/iphone/$lang"
  mkdir -p "$EDITOR/public/screenshots/apple/ipad/$lang"
  cp "$SRC_IOS/$lang/01_mode_selection.png" "$EDITOR/public/screenshots/apple/iphone/$lang/01.png"
  cp "$SRC_IOS/$lang/02_dice.png" "$EDITOR/public/screenshots/apple/iphone/$lang/02.png"
  cp "$SRC_IOS/$lang/03_session_setting.png" "$EDITOR/public/screenshots/apple/iphone/$lang/03.png"
  cp "$SRC_IOS/$lang/04_value_card.png" "$EDITOR/public/screenshots/apple/iphone/$lang/04.png"
  cp "$SRC_IOS/$lang/05_group_discussion.png" "$EDITOR/public/screenshots/apple/iphone/$lang/05.png"
  cp "$SRC_IOS/$lang/06_play_history.png" "$EDITOR/public/screenshots/apple/iphone/$lang/06.png"
  cp "$SRC_IPAD/$lang/01_mode_selection.png" "$EDITOR/public/screenshots/apple/ipad/$lang/01.png"
  cp "$SRC_IPAD/$lang/02_dice.png" "$EDITOR/public/screenshots/apple/ipad/$lang/02.png"
  cp "$SRC_IPAD/$lang/03_value_card.png" "$EDITOR/public/screenshots/apple/ipad/$lang/03.png"
  cp "$SRC_IPAD/$lang/04_session_setup.png" "$EDITOR/public/screenshots/apple/ipad/$lang/04.png"
  cp "$SRC_IPAD/$lang/05_group_discussion.png" "$EDITOR/public/screenshots/apple/ipad/$lang/05.png"
  cp "$SRC_IPAD/$lang/06_play_history.png" "$EDITOR/public/screenshots/apple/ipad/$lang/06.png"
done

echo "Synced screenshots into $EDITOR/public/screenshots/"
