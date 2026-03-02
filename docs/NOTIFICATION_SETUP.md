# Notification Capability Setup

`UNUserNotificationCenter` only works when Mixo runs as a real macOS app bundle (`.app`) with a valid bundle identifier.

## Quick Start (Current Repository)

This repository is a Swift Package executable, so running directly from Xcode package mode can launch a bare binary (no `.app` bundle). Use this helper instead:

```bash
scripts/run_bundled_app.sh
```

Optional:

```bash
MIXO_BUNDLE_ID="com.yourname.mixo.dev" scripts/run_bundled_app.sh
```

This will:
1. Build `Mixo`.
2. Create `.build/debug/Mixo.app`.
3. Add an `Info.plist` with `CFBundleIdentifier`.
4. Ad-hoc sign the app.
5. Launch the bundled app.

## Verified Notes About Alternative SwiftPM-Only App Target Setups

1. Adding another SwiftPM `.executable` product/target does not by itself create a native macOS app target in the way an `.xcodeproj` app target does.
2. A target should have either `@main` or a `main.swift` entry point, not both.
3. Moving the existing SwiftUI app files into a second package executable target is unnecessary for notification permission; the critical requirement is launching from a valid `.app` bundle with stable bundle identifier.

## First Permission Grant

1. Launch the bundled app (`Mixo.app`).
2. Click `Request Notification Permission` once.
3. In macOS Settings, go to `Notifications > Mixo` and allow alerts/sounds.

## If Permission Still Does Not Prompt

1. Quit Mixo.
2. Remove the app entry from notification settings (if present).
3. If `tccutil reset Notifications <bundle-id>` fails on your macOS version, use a new bundle identifier to force a clean prompt:
   - `MIXO_BUNDLE_ID="com.yourname.mixo.dev.v2" scripts/run_bundled_app.sh`
4. Click `Request Notification Permission` again.

## Recommended Long-Term Setup

Create a native macOS app target in Xcode and keep a stable bundle identifier for Debug/Release. That gives consistent notification identity and avoids package-mode launch issues.
