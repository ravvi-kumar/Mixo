# Notification Setup (Bundled App)

Last updated: `2026-03-04`

## Status
- Notification permission flow is working.
- App now runs as a bundled macOS app via Xcode project structure.

## Bundled App Structure
- Project: `Mixo.xcodeproj`
- App target: `Mixo`
- Test targets: `MixoTests`, `MixoUITests`
- App bundle identifier: `com.ravikumar.mixo.dev`

## Why This Works
`UNUserNotificationCenter` requires a real `.app` execution context with a valid bundle identifier.  
The previous bare executable run mode did not satisfy this requirement.

## Run Path
1. Open `Mixo.xcodeproj` in Xcode.
2. Select `Mixo` scheme.
3. Run the app (`Cmd+R`) so it launches as a bundled app.
4. Trigger notification permission request from app UI.

## Verification
- Permission prompt appears.
- Status updates in app state/UI.
- Notifications entry is visible under macOS system notification settings for Mixo.

## Optional Reset (If Re-testing Permission)
Run:

```bash
tccutil reset Notifications com.ravikumar.mixo.dev
```
