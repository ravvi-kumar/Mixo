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
- [ ] `P4-T1` long break scheduler and ratio config
  - Est: `5h`
  - Depends: `P2-T1, P2-T2`
  - Done means: scheduler can trigger long break on configured ratio with deterministic behavior.

- [ ] `P4-T2` skip anytime mode
  - Est: `4h`
  - Depends: `P4-T1`
  - Done means: skip action always available and timer re-enters running state correctly.

- [ ] `P4-T3` skip after delay mode
  - Est: `4h`
  - Depends: `P4-T1`
  - Done means: skip button stays disabled until configured delay elapses.

- [ ] `P4-T4` lock break mode (no skip UI)
  - Est: `4h`
  - Depends: `P4-T1`
  - Done means: no normal skip path exists in lock mode during active break.

- [ ] `P4-T5` state transition tests across all modes
  - Est: `5h`
  - Depends: `P4-T2, P4-T3, P4-T4`
  - Done means: tests cover all policy modes and pass with no transition deadlocks.

## Daily Execution Checklist

### Day 1 - scheduler core
- [ ] Implement long-break cadence model.
- [ ] Add default ratio config and bounds.
- [ ] Integrate cadence counter into timer state transitions.
- [ ] Log note in daily log.

### Day 2 - policy mode model
- [ ] Add policy mode enum and runtime state.
- [ ] Implement skip-anytime behavior.
- [ ] Add policy-aware transition guards.
- [ ] Log note in daily log.

### Day 3 - delayed skip mode
- [ ] Implement skip-after-delay timer/guard.
- [ ] Expose lock-delay status in app state.
- [ ] Validate delayed skip behavior manually.
- [ ] Log note in daily log.

### Day 4 - lock mode
- [ ] Implement lock mode transition restrictions.
- [ ] Hide/disable skip controls in lock mode.
- [ ] Ensure emergency escape path still works.
- [ ] Log note in daily log.

### Day 5 - tests and close
- [ ] Add scheduler/policy transition tests.
- [ ] Run full build + test suite.
- [ ] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [ ] Capture known policy edge cases for next sprint.

## Verification Checklist (Run Before Marking Done)
- [ ] `swift build` succeeds.
- [ ] `swift test` passes with new policy tests.
- [ ] Long break triggers on configured cadence.
- [ ] Skip-anytime mode transitions cleanly.
- [ ] Skip-after-delay enforces lock window.
- [ ] Lock mode prevents normal skip path.
- [ ] No deadlocks across policy mode transitions.

## Blockers
- `2026-02-28` - `P1-T1/P1-T5` bundled app target still pending for notification permission validation. Owner: `Ravi + Codex`.

## Daily Log
Use this section every day; keep short.

### 2026-02-28
- Focus: Transition from Sprint 03 overlay close-out to Phase 4 policy scheduler work.
- Done: Sprint 03 closed with working overlay flow and validated QA checklist.
- Issues: Phase 1 notification context blocker remains open.
- Next: Implement `P4-T1` long-break scheduler core.

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
- worked:
- slowed:
- next fix:
