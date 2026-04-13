#!/bin/sh
# Xcode Cloud: generate Flutter iOS artifacts before xcodebuild archive.
# See https://docs.flutter.dev/deployment/cd#xcode-cloud

set -e

cd "${CI_PRIMARY_REPOSITORY_PATH}"

# Install Flutter SDK (not present on Xcode Cloud runners).
# Pin FLUTTER_VERSION in the workflow’s environment if stable clone misbehaves.
FLUTTER_HOME="${HOME}/flutter"
if [ -n "${FLUTTER_VERSION:-}" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 --branch "${FLUTTER_VERSION}" "${FLUTTER_HOME}"
else
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "${FLUTTER_HOME}"
fi
export PATH="${PATH}:${FLUTTER_HOME}/bin"

flutter precache --ios
flutter pub get

if ! command -v pod >/dev/null 2>&1; then
  HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
fi

cd ios
pod install

exit 0
