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
- [ ] `P3-T1` overlay window manager per display
  - Est: `5h`
  - Depends: `P2-T1`
  - Done means: overlay opens on each connected display and closes without orphan windows.

- [ ] `P3-T2` blur + dim layer + countdown component
  - Est: `6h`
  - Depends: `P3-T1`
  - Done means: overlay visuals render smoothly at 60fps on target hardware.

- [ ] `P3-T3` break end chime integration
  - Est: `3h`
  - Depends: `P3-T2`
  - Done means: end sound triggers once per break and respects user mute setting.

- [ ] `P3-T4` safe escape path for critical interruptions
  - Est: `4h`
  - Depends: `P3-T2`
  - Done means: emergency exit works from keyboard and event is audit-logged.

- [ ] `P3-T5` visual QA on single + dual monitor
  - Est: `4h`
  - Depends: `P3-T2, P3-T4`
  - Done means: no critical visual defects remain in tested monitor configs.

## Daily Execution Checklist

### Day 1 - overlay manager foundation
- [x] Create overlay window manager scaffold.
- [x] Add menu actions for showing/hiding overlay preview.
- [ ] Validate behavior on dual-monitor setup.
- [x] Log note in daily log.

### Day 2 - visual component
- [ ] Implement blur and dim visual layering.
- [ ] Add countdown text component and binding hooks.
- [ ] Verify accessibility contrast/readability.
- [ ] Log note in daily log.

### Day 3 - behavior wiring
- [ ] Hook overlay show/hide to real break state transitions.
- [ ] Add break-end chime trigger.
- [ ] Prevent duplicate overlays during rapid state changes.
- [ ] Log note in daily log.

### Day 4 - safety path
- [ ] Implement emergency dismiss shortcut path.
- [ ] Log forced-dismiss events.
- [ ] Add guard rails for accidental re-entry.
- [ ] Log note in daily log.

### Day 5 - QA and close
- [ ] Execute single + dual monitor checklist.
- [ ] Run full build + test suite.
- [ ] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [ ] Capture remaining defects for next sprint.

## Verification Checklist (Run Before Marking Done)
- [x] `swift build` succeeds.
- [x] `swift test` passes.
- [ ] Overlay appears on each active display.
- [ ] Overlay close removes all windows cleanly.
- [ ] Countdown is visible and updates correctly.
- [ ] Chime fires once at break completion.
- [ ] Emergency dismiss path exits overlay safely.

## Blockers
- `2026-02-28` - `P1-T1/P1-T5` bundled app target still pending for notification permission validation. Owner: `Ravi + Codex`.

## Daily Log
Use this section every day; keep short.

### 2026-02-28
- Focus: Start Phase 3 overlay infrastructure after closing Phase 2 persistence.
- Done: Added per-display overlay window manager scaffold and menu preview actions.
- Issues: Dual-monitor validation and real break-state integration are pending.
- Next: Complete `P3-T1` validation and start `P3-T2` visuals.

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
