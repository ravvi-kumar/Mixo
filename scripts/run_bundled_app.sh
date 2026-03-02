#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Mixo"
CONFIGURATION="debug"
SHOULD_OPEN=true

for arg in "$@"; do
  case "$arg" in
    --release)
      CONFIGURATION="release"
      ;;
    --no-open)
      SHOULD_OPEN=false
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: scripts/run_bundled_app.sh [--release] [--no-open]" >&2
      exit 2
      ;;
  esac
done

BUNDLE_ID="${MIXO_BUNDLE_ID:-com.ravikumar.mixo.dev}"
BUILD_DIR="$ROOT_DIR/.build/$CONFIGURATION"
EXECUTABLE_PATH="$BUILD_DIR/$APP_NAME"
APP_BUNDLE_PATH="$BUILD_DIR/$APP_NAME.app"
INFO_PLIST_PATH="$APP_BUNDLE_PATH/Contents/Info.plist"
PROCESS_PATTERN="/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

echo "Building $APP_NAME ($CONFIGURATION)..."
swift build -c "$CONFIGURATION" --package-path "$ROOT_DIR"

mkdir -p "$APP_BUNDLE_PATH/Contents/MacOS" "$APP_BUNDLE_PATH/Contents/Resources"
cp "$EXECUTABLE_PATH" "$APP_BUNDLE_PATH/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE_PATH/Contents/MacOS/$APP_NAME"

cat >"$INFO_PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
EOF

codesign --force --deep --sign - "$APP_BUNDLE_PATH" >/dev/null

echo "Bundled app ready: $APP_BUNDLE_PATH"
echo "Bundle identifier: $BUNDLE_ID"

if [ "$SHOULD_OPEN" = true ]; then
  pkill -f "$PROCESS_PATTERN" >/dev/null 2>&1 || true
  sleep 0.3

  echo "Opening app bundle..."
  open "$APP_BUNDLE_PATH"

  sleep 1
  if pgrep -f "$PROCESS_PATTERN" >/dev/null; then
    echo "Mixo is running."
  else
    echo "Mixo did not stay running. Check crash reports in ~/Library/Logs/DiagnosticReports/Mixo-*.ips" >&2
    exit 1
  fi
fi
