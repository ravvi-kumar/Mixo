# Sprint 04 - Mixo Long Break Policy Execution Checklist

Sprint window: `Week 4`  
Primary phase: `Phase 4 - long breaks + skip/delay/lock`  
Linked tasks: `P4-T1, P4-T2, P4-T3, P4-T4, P4-T5`

## Sprint Goal
Ship deterministic long-break scheduling and enforceable skip/lock policy modes on top of the timer core.

## Sprint Exit Criteria
- Long-break cadence triggers correctly after configured short-break cycles.
- Skip-anytime mode transitions cleanly without deadlocks.
- Skip-after-delay mode blocks skip until configured delay elapses.
- Lock mode removes standard skip path during active breaks.
- State-transition tests cover all policy modes and pass.

## Scope Lock
In scope this sprint:
- Long-break scheduler + cadence configuration.
- Policy mode transitions (`skip-anytime`, `skip-after-delay`, `lock`).
- Menu/state integration of policy mode behavior.
- Tests for scheduler/policy transition correctness.

Out of scope this sprint:
- Notification action workflows.
- Smart pause detectors.
- Global shortcuts recording UX.
- Packaging/release tasks.

## Task Board (Phase 4 Mapping)
- [x] `P4-T1` long break scheduler and ratio config
  - Est: `5h`
  - Depends: `P2-T1, P2-T2`
  - Done means: scheduler can trigger long break on configured ratio with deterministic behavior.

- [x] `P4-T2` skip anytime mode
  - Est: `4h`
  - Depends: `P4-T1`
  - Done means: skip action always available and timer re-enters running state correctly.

- [x] `P4-T3` skip after delay mode
  - Est: `4h`
  - Depends: `P4-T1`
  - Done means: skip button stays disabled until configured delay elapses.

- [x] `P4-T4` lock break mode (no skip UI)
  - Est: `4h`
  - Depends: `P4-T1`
  - Done means: no normal skip path exists in lock mode during active break.

- [x] `P4-T5` state transition tests across all modes
  - Est: `5h`
  - Depends: `P4-T2, P4-T3, P4-T4`
  - Done means: tests cover all policy modes and pass with no transition deadlocks.

## Daily Execution Checklist

### Day 1 - scheduler core
- [x] Implement long-break cadence model.
- [x] Add default ratio config and bounds.
- [x] Integrate cadence counter into timer state transitions.
- [x] Log note in daily log.

### Day 2 - policy mode model
- [x] Add policy mode enum and runtime state.
- [x] Implement skip-anytime behavior.
- [x] Add policy-aware transition guards.
- [x] Log note in daily log.

### Day 3 - delayed skip mode
- [x] Implement skip-after-delay timer/guard.
- [x] Expose lock-delay status in app state.
- [x] Validate delayed skip behavior manually.
- [x] Log note in daily log.

### Day 4 - lock mode
- [x] Implement lock mode transition restrictions.
- [x] Hide/disable skip controls in lock mode.
- [x] Ensure emergency escape path still works.
- [x] Log note in daily log.

### Day 5 - tests and close
- [x] Add scheduler/policy transition tests.
- [x] Run full build + test suite.
- [x] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [x] Capture known policy edge cases for next sprint.

## Verification Checklist (Run Before Marking Done)
- [x] `swift build` succeeds.
- [x] `swift test` passes with new policy tests.
- [x] Long break triggers on configured cadence.
- [x] Skip-anytime mode transitions cleanly.
- [x] Skip-after-delay enforces lock window.
- [x] Lock mode prevents normal skip path.
- [x] No deadlocks across policy mode transitions.

## Blockers
- `2026-02-28` - `P1-T1/P1-T5` bundled app target still pending for notification permission validation. Owner: `Ravi + Codex`.

## Daily Log
Use this section every day; keep short.

### 2026-02-28
- Focus: Transition from Sprint 03 overlay close-out to Phase 4 policy scheduler work.
- Done: Sprint 03 closed; implemented `P4-T1` long-break cadence scheduler, long-break settings, persistence updates, and deterministic scheduler tests.
- Issues: Phase 1 notification context blocker remains open.
- Next: Implement `P4-T2` skip-anytime policy mode.

### 2026-03-03
- Focus: Complete Phase 4 policy modes and transition coverage.
- Done: Implemented policy model (`skip-anytime`, `skip-after-delay`, `lock`), wired menu/settings controls, persisted policy metadata, and added policy transition tests.
- Issues: Phase 1 bundled-app notification blocker still open for notification-specific work.
- Next: Start Phase 5 by unblocking bundled app target for notification flow validation.

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
- worked: Centralizing policy rules in the state machine made menu/settings integration straightforward.
- slowed: Notification-specific validation remains blocked by bare executable launch context.
- next fix: Prioritize bundled app target work, then execute Phase 5 notification tasks.
