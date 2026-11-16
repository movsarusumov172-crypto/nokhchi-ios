#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM to your Apple Developer Team ID}"
: "${EXPORT_OPTIONS:?Set EXPORT_OPTIONS to an absolute path to ExportOptions.plist}"

xcodebuild -project Nokhchi.xcodeproj -scheme Nokhchi -configuration Release \
    -destination 'generic/platform=iOS' -archivePath build/Nokhchi.xcarchive \
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath build/Nokhchi.xcarchive \
    -exportPath build/export -exportOptionsPlist "$EXPORT_OPTIONS" \
    -allowProvisioningUpdates
