# Overlay QA Checklist

Date: `2026-02-28`  
Scope: `Phase 3 - P3-T5 visual QA on single + dual monitor`

## Preconditions
- Build succeeds (`swift build`).
- Tests pass (`swift test`).
- App is running with menu bar controls visible.

## Single Monitor Checks
- Trigger `Take Break Now` and confirm fullscreen overlay appears.
- Confirm countdown text updates once per second.
- Confirm blur + dim background and text remain readable.
- Press `Esc` and confirm overlay exits immediately.
- Run `Overlay Diagnostics` and confirm:
  - `mode=hidden` after dismiss.
  - `windows == screens` when overlay is visible.

## Dual Monitor Checks
- Connect a second display and keep both displays active.
- Trigger `Take Break Now` and verify overlay appears on both displays.
- Run `Overlay Diagnostics` while overlay is visible and confirm `windows == screens == 2`.
- Press `Esc` and verify overlay closes on both displays.
- Disconnect/reconnect one display during preview and confirm window count re-syncs.

## Accessibility Checks
- Confirm title/subtitle are readable at normal viewing distance.
- Confirm countdown remains readable over light/dark desktop backgrounds.
- Confirm there is enough contrast in both displays if brightness differs.

## Result Template
- Single monitor: `Pass/Fail`
- Dual monitor: `Pass/Fail`
- Accessibility: `Pass/Fail`
- Issues found:
  - `None` or list exact behavior + reproduction steps.
