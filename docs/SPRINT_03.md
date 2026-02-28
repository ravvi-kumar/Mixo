# Sprint 03 - Mixo Break Overlay Execution Checklist

Sprint window: `Week 3`  
Primary phase: `Phase 3 - break overlay`  
Linked tasks: `P3-T1, P3-T2, P3-T3, P3-T4, P3-T5`

## Sprint Goal
Ship a fullscreen break overlay flow that appears reliably on all active displays and exits cleanly.

## Sprint Exit Criteria
- Overlay window manager handles all connected displays.
- Overlay visuals (blur/dim/countdown) render smoothly.
- Break-end chime triggers once per completed break.
- Emergency dismiss path works and is logged.
- Single and dual monitor QA passes.

## Scope Lock
In scope this sprint:
- Per-display overlay window lifecycle.
- Overlay visual component and countdown presentation.
- Break-end chime.
- Emergency dismiss handling.
- Visual QA checklists.

Out of scope this sprint:
- Long break policy logic.
- Notification actions and fallbacks.
- Smart pause detectors.
- Global shortcut recording.

## Task Board (Phase 3 Mapping)
- [x] `P3-T1` overlay window manager per display
  - Est: `5h`
  - Depends: `P2-T1`
  - Done means: overlay opens on each connected display and closes without orphan windows.

- [x] `P3-T2` blur + dim layer + countdown component
  - Est: `6h`
  - Depends: `P3-T1`
  - Done means: overlay visuals render smoothly at 60fps on target hardware.

- [x] `P3-T3` break end chime integration
  - Est: `3h`
  - Depends: `P3-T2`
  - Done means: end sound triggers once per break and respects user mute setting.

- [x] `P3-T4` safe escape path for critical interruptions
  - Est: `4h`
  - Depends: `P3-T2`
  - Done means: emergency exit works from keyboard and event is audit-logged.

- [x] `P3-T5` visual QA on single + dual monitor
  - Est: `4h`
  - Depends: `P3-T2, P3-T4`
  - Done means: no critical visual defects remain in tested monitor configs.

## Daily Execution Checklist

### Day 1 - overlay manager foundation
- [x] Create overlay window manager scaffold.
- [x] Add menu actions for showing/hiding overlay preview.
- [x] Validate behavior on dual-monitor setup.
- [x] Log note in daily log.

### Day 2 - visual component
- [x] Implement blur and dim visual layering.
- [x] Add countdown text component and binding hooks.
- [x] Verify accessibility contrast/readability.
- [x] Log note in daily log.

### Day 3 - behavior wiring
- [x] Hook overlay show/hide to real break state transitions.
- [x] Add break-end chime trigger.
- [x] Prevent duplicate overlays during rapid state changes.
- [x] Log note in daily log.

### Day 4 - safety path
- [x] Implement emergency dismiss shortcut path.
- [x] Log forced-dismiss events.
- [x] Add guard rails for accidental re-entry.
- [x] Log note in daily log.

### Day 5 - QA and close
- [x] Execute single + dual monitor checklist.
- [x] Run full build + test suite.
- [x] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [x] Capture remaining defects for next sprint.

## Verification Checklist (Run Before Marking Done)
- [x] `swift build` succeeds.
- [x] `swift test` passes.
- [x] Overlay appears on each active display.
- [x] Overlay close removes all windows cleanly.
- [x] Countdown is visible and updates correctly.
- [x] Chime fires once at break completion.
- [x] Emergency dismiss path exits overlay safely.

## Blockers
- `2026-02-28` - `P1-T1/P1-T5` bundled app target still pending for notification permission validation. Owner: `Ravi + Codex`.

## Daily Log
Use this section every day; keep short.

### 2026-02-28
- Focus: Start Phase 3 overlay infrastructure after closing Phase 2 persistence.
- Done: Added per-display overlay manager scaffold, break-state wiring with live countdown, blur+dim visuals, break-end chime trigger, Escape emergency dismiss, re-entry guard rails, and overlay diagnostics + QA checklist at `docs/OVERLAY_QA_CHECKLIST.md`; user validated working behavior.
- Issues: `None` from Sprint 03 close checks.
- Next: Start Sprint 04 with `P4-T1` long-break scheduler + ratio configuration.

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
- worked: Explicit state transitions plus diagnostics made overlay behavior easy to validate and stabilize.
- slowed: Phase 1 notification context blocker stayed open and required parallel tracking.
- next fix: Start policy-mode scheduler core in Phase 4 before adding more UI surface area.
