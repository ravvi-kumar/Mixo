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
- [x] `P1-T1` init xcode app target and bundle ids
  - Est: `4h`
  - Depends: `None`
  - Done means: buildable app target scaffold exists and identifiers configured.

- [x] `P1-T2` menubar extra + app lifecycle wire
  - Est: `5h`
  - Depends: `P1-T1`
  - Done means: menu bar app runs and lifecycle events logged.

- [x] `P1-T3` settings tabs skeleton
  - Est: `4h`
  - Depends: `P1-T1`
  - Done means: settings window opens and tab switch works.

- [x] `P1-T4` local logging utility
  - Est: `4h`
  - Depends: `P1-T2`
  - Done means: timer/state/lifecycle logs have timestamp + subsystem labels.

- [x] `P1-T5` notification permission request flow
  - Est: `3h`
  - Depends: `P1-T2`
  - Done means: permission request action works and status is persisted in runtime state.

## Daily Execution Checklist

### Day 1 - boot and base app shell
- [x] Create project scaffold and folder conventions.
- [x] Add menu bar app entrypoint.
- [x] Validate app launches from local machine.
- [x] Log note in daily log.

### Day 2 - settings skeleton
- [x] Add settings scene and 3 tabs placeholders.
- [x] Add open settings action from menu bar.
- [x] Verify tab switch and window lifecycle.
- [x] Log note in daily log.

### Day 3 - logging utility
- [x] Add structured logger wrapper.
- [x] Instrument startup/shutdown and menu actions.
- [x] Verify log lines format is consistent.
- [x] Log note in daily log.

### Day 4 - notification permission flow
- [x] Add permission service and state model.
- [x] Add menu action to request permission.
- [x] Surface current permission status in UI.
- [x] Log note in daily log.

### Day 5 - harden and sprint close
- [x] Run clean build and launch check.
- [x] Run Phase 1 exit criteria checklist.
- [x] Update `docs/PROJECT_TASKS.md` checkboxes and retro note.
- [x] Write sprint retro bullets.

## Verification Checklist (Run Before Marking Done)
- [x] Build command succeeds from clean state.
- [x] Menu bar icon appears within 3 seconds of launch.
- [x] Settings window opens from menu command.
- [x] All settings tabs render without crash.
- [x] Notification prompt can be triggered.
- [x] Permission state updates after user choice.
- [x] Lifecycle logs show startup/shutdown.

## Blockers
- `2026-03-04` - `Resolved`: migrated to bundled Xcode app structure and validated notification permission flow in app context.

## Daily Log
Use this section every day; keep short.

### 2026-02-28
- Focus: Phase 1 shell completion and notification permission path.
- Done: Menu bar app shell, settings tabs, lifecycle logs, settings open flow, and permission state UI/logging are implemented; build is green.
- Issues: Permission prompt remains blocked in non-bundled execution context from current Xcode run mode.
- Next: Create/run via real macOS app target (`.app`) and close `P1-T1/P1-T5`.

### 2026-03-04
- Focus: close bundled app + notifications blocker and finalize Phase 1 closure.
- Done: migrated to Xcode bundled app structure, validated notification permission prompt/status updates, and confirmed working run path from `Mixo.xcodeproj`.
- Issues: none for Phase 1 notification context.
- Next: continue Phase 5 feature implementation (heads-up timing + actions).

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
- worked: `Bundled Xcode app structure removed runtime context issues and made notification flow stable.`
- slowed: `Initial SwiftPM bare-executable run path blocked UserNotifications API initialization.`
- next fix: `Keep all notification feature work on bundled app path and expand Phase 5 reminder behaviors.`
