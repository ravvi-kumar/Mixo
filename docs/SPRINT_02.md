# Sprint 02 - Mixo Timer Core Execution Checklist

Sprint window: `Week 2`  
Primary phase: `Phase 2 - timer core short break`  
Linked tasks: `P2-T1, P2-T2, P2-T3, P2-T4, P2-T5`

## Sprint Goal
Ship a reliable short-break timer core with pause/resume controls, persistence scaffolding, and test coverage.

## Sprint Exit Criteria
- 20-20-20 timer flow runs reliably in menu bar app state.
- Pause/resume/manual break actions are functional and logged.
- Timer configuration model is represented in runtime state.
- Timer settings/state persistence survives app restart.
- Automated tests cover drift and boundary behavior.

## Scope Lock
In scope this sprint:
- Timer state machine.
- Timer controls and command wiring.
- Timer defaults/config model.
- Timer state persistence.
- Unit tests for drift and boundaries.

Out of scope this sprint:
- Overlay rendering.
- Long break policy modes.
- Notifications heads-up actions.
- Smart pause detection.

## Task Board (Phase 2 Mapping)
- [x] `P2-T1` timer engine state machine (`running/paused/break/idle`)
  - Est: `6h`
  - Depends: `P1-T2`
  - Done means: state machine can run through all core states in unit-level simulation.

- [x] `P2-T2` short break config model + defaults
  - Est: `4h`
  - Depends: `P2-T1`
  - Done means: defaults load on first run and changed values reflect in active timer logic.

- [x] `P2-T3` persistence via `UserDefaults`
  - Est: `4h`
  - Depends: `P2-T2`
  - Done means: app restart restores active configuration and last safe timer checkpoint.

- [x] `P2-T4` pause/resume/manual start next break actions
  - Est: `4h`
  - Depends: `P2-T1`
  - Done means: each action updates state machine correctly and logs event source.

- [x] `P2-T5` unit tests for timer math drift + boundary behavior
  - Est: `5h`
  - Depends: `P2-T1, P2-T4`
  - Done means: tests pass and prove no cumulative drift beyond 1 second in 2-hour simulation.

## Daily Execution Checklist

### Day 1 - timer engine
- [x] Implement deterministic timer state machine.
- [x] Wire state machine into app state.
- [x] Validate transitions manually from menu actions.
- [x] Log note in daily log.

### Day 2 - controls and behavior
- [x] Add menu actions for start/pause/resume/take break/reset.
- [x] Disable invalid actions per state.
- [x] Add transition logging for each event.
- [x] Log note in daily log.

### Day 3 - test coverage
- [x] Add unit tests for transitions and invalid events.
- [x] Add near-boundary tests for work/break rollovers.
- [x] Add 2-hour drift simulation test.
- [x] Run `swift test`.

### Day 4 - config model
- [x] Implement mutable timer configuration model in state.
- [x] Expose config values in settings placeholders.
- [x] Ensure runtime timer uses configured values.
- [x] Log note in daily log.

### Day 5 - persistence and close
- [x] Persist timer config/state via `UserDefaults`.
- [x] Verify restart restore behavior.
- [x] Run full build + test checks.
- [x] Update `docs/PROJECT_TASKS.md` and sprint retro.

## Verification Checklist (Run Before Marking Done)
- [x] `swift build` succeeds.
- [x] `swift test` passes.
- [x] Menu timer controls trigger expected state transitions.
- [x] Timer countdown enters break mode and returns to running mode.
- [x] Timer settings are editable and applied at runtime.
- [x] Timer state/config restores after app restart.

## Blockers
- `2026-02-28` - `P1-T1/P1-T5` bundled app target still pending for notification permission validation. Owner: `Ravi + Codex`.

## Daily Log
Use this section every day; keep short.

### 2026-02-28
- Focus: Kick off Phase 2 timer core while notification-context blocker is pending.
- Done: Implemented state machine, menu timer actions, editable timer settings in Breaks tab, timer persistence/restart restore, and automated tests (12 passing total).
- Issues: Phase 1 notification flow still blocked on bundled `.app` run context, isolated from Phase 2 work.
- Next: Start Sprint 03 (`P3-T1` overlay window manager).

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
- worked: Explicit state model + test-first checks made timer behavior and persistence predictable.
- slowed: Notification permission remains context-blocked until true app bundle target setup is complete.
- next fix: Begin overlay infrastructure with per-display window manager and keep tests around state transitions green.
