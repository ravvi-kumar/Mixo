# Sprint 06 - Mixo Smart Pause Execution Checklist

Sprint window: `Week 6`  
Primary phase: `Phase 6 - smart pause basic`  
Linked tasks: `P6-T1, P6-T2, P6-T3, P6-T4, P6-T5`

## Sprint Goal
Pause or defer break flow when interruption signals are active (idle, fullscreen, media), while keeping timer behavior explainable.

## Sprint Exit Criteria
- Timer auto-pauses after short idle threshold and resumes safely.
- Long idle can reset cycle to avoid immediate break on return.
- Fullscreen activity defers break trigger until fullscreen exits.
- Basic media activity signal can defer break trigger.
- Menu shows active smart-pause reason.

## Scope Lock
In scope this sprint:
- Idle-based pause/reset signals.
- Fullscreen and basic media deferral hooks.
- Smart-pause reason indicator in menu/status.
- Unit tests for pause/defer transitions.

Out of scope this sprint:
- Shortcut recording UX.
- Preset profiles.
- Packaging/release tasks.

## Task Board (Phase 6 Mapping)
- [x] `P6-T1` idle detection threshold (pause timer)
  - Est: `5h`
  - Depends: `P2-T1`
  - Done means: timer pauses after configured idle threshold and resumes on activity.

- [x] `P6-T2` long idle threshold (reset timer)
  - Est: `4h`
  - Depends: `P6-T1`
  - Done means: cycle reset occurs after long idle and logs reason.

- [x] `P6-T3` fullscreen app detection hook
  - Est: `4h`
  - Depends: `P2-T1`
  - Done means: pending break waits until fullscreen exits.

- [x] `P6-T4` media activity signal integration (basic heuristic)
  - Est: `5h`
  - Depends: `P6-T3`
  - Done means: playback-active signal defers break trigger.

- [x] `P6-T5` smart pause reason indicator in menu/status
  - Est: `3h`
  - Depends: `P6-T1, P6-T3, P6-T4`
  - Done means: active pause reason is visible and clears when resume conditions are met.

## Daily Execution Checklist

### Day 1 - idle pause baseline
- [x] Add idle detector service abstraction.
- [x] Add pause threshold config and defaults.
- [x] Wire idle-pause command path to timer state machine.
- [x] Log note in daily log.

### Day 2 - long idle reset
- [x] Add long-idle threshold config.
- [x] Implement reset-on-long-idle behavior.
- [x] Add transition tests for pause vs reset thresholds.
- [x] Log note in daily log.

### Day 3 - fullscreen deferral
- [x] Add fullscreen detection hook abstraction.
- [x] Defer break start while fullscreen is active.
- [x] Ensure deferred break triggers once fullscreen exits.
- [x] Log note in daily log.

### Day 4 - media signal deferral
- [x] Add basic media activity heuristic service.
- [x] Defer break trigger during media playback signal.
- [x] Validate deferral recovery behavior.
- [x] Log note in daily log.

### Day 5 - status + close
- [x] Add smart-pause reason status in menu/settings.
- [x] Run full build + tests.
- [x] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [x] Capture follow-up items for Phase 7 handoff.

## Verification Checklist (Run Before Marking Done)
- [x] Idle pause triggers at configured threshold.
- [x] Long idle resets timer cycle at configured threshold.
- [x] Fullscreen defers break trigger and resumes correctly.
- [x] Media activity defers break trigger and resumes correctly.
- [x] Menu reason indicator matches active pause/defer state.
- [x] Unit tests for new transitions pass.

## Blockers
- `None`

## Daily Log
Use this section every day; keep short.

### 2026-03-04
- Focus: Sprint 05 close-out and Sprint 06 kickoff.
- Done: Closed Sprint 05 tasks (`P5-T1` to `P5-T5`) and validated with full `MixoTests` pass in bundled Xcode setup.
- Issues: none.
- Next: implement `P6-T1` idle detection pause threshold.

### 2026-03-18
- Focus: Implement `P6-T1` idle smart-pause baseline.
- Done: Added `IdleActivityService`, persisted `idlePauseThresholdSeconds` in timer config, wired auto pause/resume in `AppState`, exposed threshold in menu/settings UI, and added `AppStateSmartPauseTests`.
- Issues: none.
- Next: implement `P6-T2` long-idle reset behavior with transition tests.

### 2026-03-18
- Focus: Implement `P6-T2` long-idle reset behavior.
- Done: Added persisted `longIdleResetThresholdSeconds`, wired reset-on-long-idle path (running and idle-auto-paused states), and added pause-vs-reset transition tests in `AppStateSmartPauseTests`.
- Issues: none.
- Next: implement `P6-T3` fullscreen deferral hook and deferred-break release.

### 2026-03-18
- Focus: Implement `P6-T3` fullscreen smart-pause deferral.
- Done: Added `FullscreenActivityService`, deferred break-boundary tick while fullscreen is active, released deferred break immediately after fullscreen exits, and added `AppStateFullscreenDeferralTests`.
- Issues: none.
- Next: implement `P6-T4` media activity signal deferral.

### 2026-03-27
- Focus: Implement `P6-T4` media playback smart-pause deferral.
- Done: Added `MediaActivityService` (CoreAudio output-device activity heuristic), deferred break-boundary tick while media playback is active, added fullscreen-vs-media priority handling, and added `AppStateMediaDeferralTests`.
- Issues: none.
- Next: implement `P6-T5` smart-pause reason indicator in menu/settings.

### 2026-03-27
- Focus: Implement `P6-T5` smart-pause reason visibility and sprint close tasks.
- Done: Added `SmartPauseReason` state in `AppState`, surfaced reason in menu/settings runtime status, expanded smart-pause/fullscreen/media tests for reason set/clear behavior, and re-ran full `MixoTests` successfully.
- Issues: none.
- Next: kick off Sprint 07 with `P7-T1` shortcut manager baseline.

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
- worked: `Idle/fullscreen/media detectors stayed stable once each signal was isolated behind a service and tested through AppState stubs.`
- slowed: `Media detector introduced environment-coupling in fullscreen tests until the new service was stubbed there as well.`
- next fix: `Start Phase 7 by extracting action-command routing early so shortcut bindings can stay deterministic and testable.`
