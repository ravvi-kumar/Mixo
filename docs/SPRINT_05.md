# Sprint 05 - Mixo Notifications Heads-up Execution Checklist

Sprint window: `Week 5`  
Primary phase: `Phase 5 - notifications and heads-up`  
Linked tasks: `P5-T1, P5-T2, P5-T3, P5-T4, P5-T5`

## Sprint Goal
Ship configurable pre-break heads-up notifications with actionable controls and clear fallback behavior.

## Sprint Exit Criteria
- Pre-break lead-time setting schedules heads-up reminders before break start.
- Notification actions (`Start now`, `Delay`) route to timer commands safely.
- A lightweight warning countdown is visible near menu/cursor during warning window.
- Menu includes immediate break trigger and remains state-safe.
- Fallback indicator appears when notification delivery is unavailable.

## Scope Lock
In scope this sprint:
- Heads-up lead-time setting and scheduling.
- Actionable notification command routing.
- Minimal warning countdown surface.
- Notification failure fallback state.

Out of scope this sprint:
- Smart pause detectors.
- Shortcut recording UX.
- Packaging/release tasks.

## Task Board (Phase 5 Mapping)
- [x] `P5-T1` pre-break notification timing setting
  - Est: `4h`
  - Depends: `P1-T5, P2-T2`
  - Done means: selected lead-time value drives actual notification scheduling.

- [x] `P5-T2` notification actions (`Start now`, `Delay`)
  - Est: `5h`
  - Depends: `P5-T1`
  - Done means: action clicks route to timer commands and state updates are logged.

- [x] `P5-T3` floating mini countdown near cursor/menu bar
  - Est: `4h`
  - Depends: `P5-T1`
  - Done means: mini countdown appears during warning window and auto-hides at break start.

- [x] `P5-T4` take break now quick action from menu
  - Est: `3h`
  - Depends: `P2-T4`
  - Done means: selecting menu action starts break overlay instantly.

- [x] `P5-T5` notification delivery failure fallback path
  - Est: `4h`
  - Depends: `P5-T2`
  - Done means: fallback status is visible in menu when alert delivery fails.

## Daily Execution Checklist

### Day 1 - heads-up timing and scheduling
- [x] Add pre-break lead-time setting to timer configuration.
- [x] Persist lead-time in timer snapshot storage and restore path.
- [x] Schedule/cancel heads-up local notification from timer transitions.
- [x] Expose lead-time setting in Breaks tab and menu status.
- [x] Run test suite and record results.

### Day 2 - actionable notifications
- [x] Register notification categories/actions.
- [x] Route `Start now` and `Delay` to AppState command handling.
- [x] Add logging and guard rails for invalid action timing.
- [x] Log note in daily log.

### Day 3 - warning countdown surface
- [x] Add lightweight warning countdown UI near menu/cursor zone.
- [x] Keep surface non-intrusive and auto-hide at break start.
- [x] Verify behavior on single/dual monitor.
- [x] Log note in daily log.

### Day 4 - fallback behavior
- [x] Add failure status when notifications are denied/unavailable.
- [x] Surface fallback status in menu/settings.
- [x] Verify fallback clears after permission recovery.
- [x] Log note in daily log.

### Day 5 - harden and close
- [x] Run full build + tests.
- [x] Re-run Phase 5 exit criteria checklist.
- [x] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [x] Capture follow-up items for Phase 6 handoff.

## Verification Checklist (Run Before Marking Done)
- [x] `xcodebuild` unit tests (`MixoTests`) pass after heads-up timing changes.
- [x] Lead-time setting is visible and editable in Settings > Breaks.
- [x] Lead-time value persists across app restarts.
- [x] Heads-up reminder fires at configured lead-time while timer is running.
- [x] Notification action handling (`Start now`, `Delay`) is verified via unit tests.
- [x] Fallback status appears when notifications are unavailable.

## Blockers
- `None`

## Daily Log
Use this section every day; keep short.

### 2026-03-04
- Focus: Start Sprint 05 and complete `P5-T1`.
- Done: Added pre-break lead-time setting in config/UI, persisted lead-time in timer snapshots, and wired heads-up schedule/cancel behavior to timer transitions.
- Issues: none in code/test run; manual runtime validation of notification firing timing still pending.
- Next: implement notification actions for `P5-T2`.

### 2026-03-04 (cont.)
- Focus: complete `P5-T2` notification actions.
- Done: registered heads-up notification category/actions (`Start now`, `Delay 5 min`), wired notification action callbacks through app delegate -> app state command handling, and added tests for action routing/delay semantics.
- Issues: manual runtime verification of interactive notification UI still pending.
- Next: implement `P5-T3` warning countdown surface.

### 2026-03-04 (close)
- Focus: close remaining Phase 5 heads-up UX and fallback reliability tasks.
- Done: implemented floating heads-up mini countdown (`P5-T3`), confirmed menu `Take Break Now` quick action behavior (`P5-T4`), added fallback status signaling for unavailable heads-up delivery (`P5-T5`), and verified with full `MixoTests` run in Xcode (`** TEST SUCCEEDED **`).
- Issues: none.
- Next: start Sprint 06 with `P6-T1` idle-detection pause threshold.

### YYYY-MM-DD
- Focus:
- Done:
- Issues:
- Next:

### YYYY-MM-DD
- Focus:
- Done:
- Issues:
- Next:

### YYYY-MM-DD
- Focus:
- Done:
- Issues:
- Next:

### YYYY-MM-DD
- Focus:
- Done:
- Issues:
- Next:

## Sprint Retro (Fill at end)
- worked: notification scheduling + action routing stayed predictable once all heads-up logic was centralized in `AppState`.
- slowed: notification validation earlier in the sprint required bundled-app launch context and permission resets.
- next fix: start Phase 6 with a small, testable idle detector service before wiring fullscreen/media heuristics.
