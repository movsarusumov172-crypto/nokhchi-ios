#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Formatting and linting use the tool bundled with a recent Xcode toolchain.
xcrun swift-format lint --strict --recursive Nokhchi NokhchiTests NokhchiUITests
xcodebuild -project Nokhchi.xcodeproj -scheme Nokhchi \
    -configuration Debug -destination "${1:-platform=iOS Simulator,name=iPhone 16}" \
    -derivedDataPath build/DerivedData -resultBundlePath build/Tests.xcresult test
xcodebuild -project Nokhchi.xcodeproj -scheme Nokhchi \
    -configuration Release -destination 'generic/platform=iOS' \
    -derivedDataPath build/Release CODE_SIGNING_ALLOWED=NO build
