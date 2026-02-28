# Sprint 01 - Mixo Foundation Shell Execution Checklist

Sprint window: `Week 1`  
Primary phase: `Phase 1 - foundation shell`  
Linked tasks: `P1-T1, P1-T2, P1-T3, P1-T4, P1-T5`

## Sprint Goal
Ship a runnable macOS menu bar app shell with settings placeholders, local lifecycle logging, and notification permission flow.

## Sprint Exit Criteria
- App launches and menu bar icon is visible.
- Settings window opens with `General`, `Breaks`, `Advanced` tabs.
- Startup and shutdown lifecycle logs are visible.
- Notification permission can be requested and status is captured in app state/logs.

## Scope Lock
In scope this sprint:
- Repo boot and app scaffold.
- Menu bar shell.
- Settings skeleton.
- Logging utility.
- Notification permission request.

Out of scope this sprint:
- Break timer logic.
- Overlay blur.
- Smart pause detection.
- Hotkeys.

## Task Board (Phase 1 Mapping)
- [ ] `P1-T1` init xcode app target and bundle ids
  - Est: `4h`
  - Depends: `None`
  - Done means: buildable app target scaffold exists and identifiers configured.

- [ ] `P1-T2` menubar extra + app lifecycle wire
  - Est: `5h`
  - Depends: `P1-T1`
  - Done means: menu bar app runs and lifecycle events logged.

- [ ] `P1-T3` settings tabs skeleton
  - Est: `4h`
  - Depends: `P1-T1`
  - Done means: settings window opens and tab switch works.

- [ ] `P1-T4` local logging utility
  - Est: `4h`
  - Depends: `P1-T2`
  - Done means: timer/state/lifecycle logs have timestamp + subsystem labels.

- [ ] `P1-T5` notification permission request flow
  - Est: `3h`
  - Depends: `P1-T2`
  - Done means: permission request action works and status is persisted in runtime state.

## Daily Execution Checklist

### Day 1 - boot and base app shell
- [ ] Create project scaffold and folder conventions.
- [ ] Add menu bar app entrypoint.
- [ ] Validate app launches from local machine.
- [ ] Log note in daily log.

### Day 2 - settings skeleton
- [ ] Add settings scene and 3 tabs placeholders.
- [ ] Add open settings action from menu bar.
- [ ] Verify tab switch and window lifecycle.
- [ ] Log note in daily log.

### Day 3 - logging utility
- [ ] Add structured logger wrapper.
- [ ] Instrument startup/shutdown and menu actions.
- [ ] Verify log lines format is consistent.
- [ ] Log note in daily log.

### Day 4 - notification permission flow
- [ ] Add permission service and state model.
- [ ] Add menu action to request permission.
- [ ] Surface current permission status in UI.
- [ ] Log note in daily log.

### Day 5 - harden and sprint close
- [ ] Run clean build and launch check.
- [ ] Run Phase 1 exit criteria checklist.
- [ ] Update `docs/PROJECT_TASKS.md` checkboxes and retro note.
- [ ] Write sprint retro bullets.

## Verification Checklist (Run Before Marking Done)
- [ ] Build command succeeds from clean state.
- [ ] Menu bar icon appears within 3 seconds of launch.
- [ ] Settings window opens from menu command.
- [ ] All settings tabs render without crash.
- [ ] Notification prompt can be triggered.
- [ ] Permission state updates after user choice.
- [ ] Lifecycle logs show startup/shutdown.

## Blockers
- `None` (update with owner + date when blocked > 1 day)

## Daily Log
Use this section every day; keep short.

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

### YYYY-MM-DD
- Focus:
- Done:
- Issues:
- Next:

## Sprint Retro (Fill at end)
- worked:
- slowed:
- next fix:
