#!/usr/bin/env bash
# Flatten exported screenshots for App Store Connect (no alpha channel).
#
# Usage:
#   ./scripts/strip-alpha-for-app-store.sh path/to/1284x2778_thissize
#   ./scripts/strip-alpha-for-app-store.sh path/to/unzipped-export
#
# Converts each *.png under the given directory to RGB JPEG (App Store accepts
# JPEG). Original PNGs are removed after a successful conversion.

set -euo pipefail

ROOT="${1:?Pass the folder that contains locale subdirs (e.g. 1284x2778_thissize)}"

if [[ ! -d "$ROOT" ]]; then
  echo "Not a directory: $ROOT" >&2
  exit 1
fi

count=0
while IFS= read -r -d '' f; do
  out="${f%.png}.jpg"
  sips -s format jpeg -s formatOptions 95 "$f" --out "$out" >/dev/null
  rm -f "$f"
  count=$((count + 1))
  echo "OK ${out}"
done < <(find "$ROOT" -name '*.png' -type f -print0)

if [[ "$count" -eq 0 ]]; then
  echo "No PNG files under $ROOT" >&2
  exit 1
fi

echo "Converted $count file(s). Upload the .jpg files to App Store Connect."
