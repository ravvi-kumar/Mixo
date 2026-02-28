# Mixo MVP Project Tasks

## How to use this file
1. Update checkboxes daily, keep progress real not aspirational.
2. Do not start next phase until current phase exit criteria is met.
3. If blocked more than 1 day, add blocker with owner and date.
4. After each completed phase, add short retro note: worked / slowed / next fix.
5. Rough grammar in task names and descriptions is acceptable, clarity first.

## Overall Status
- Overall Status: `In Progress`
- Current Phase: `Phase 3 - break overlay (target: Week 3) [while P1 notification blocker remains]`
- Blockers:
  - `2026-02-28` - `P1-T1/P1-T5`: current Xcode run mode launches a bare executable, not a bundled `.app`; `UNUserNotificationCenter` cannot initialize.
- Decision Log:
  - `2026-02-28`: Sprint size set to 1-week micro-phases.
  - `2026-02-28`: Task format set to checklist + estimate + dependencies + DoD.
  - `2026-02-28`: Scope set to MVP execution + explicit post-MVP backlog.
  - `2026-02-28`: Single source tracking file set to `docs/PROJECT_TASKS.md`.
  - `2026-02-28`: Target platform baseline set to macOS 13+ (SwiftUI native).
  - `2026-02-28`: Settings open action uses `SettingsLink` on macOS 14+ with legacy fallback on macOS 13.
  - `2026-02-28`: Notification service guarded to bundled `.app` context to prevent `UNUserNotificationCenter` assertion crash.
  - `2026-02-28`: Implemented timer state machine (`idle/running/paused/takingBreak`) and wired menu actions (`start/pause/resume/take break/reset`).
  - `2026-02-28`: Added `swift test` coverage for timer boundaries and 2-hour drift simulation (7 passing tests).
  - `2026-02-28`: Added timer persistence (`UserDefaults`) and restart restore path for configuration + checkpointed state.
  - `2026-02-28`: Added AppState persistence integration tests; full test suite now 12 passing tests.
  - `2026-02-28`: Started Phase 3 with per-display overlay window manager scaffold and menu preview controls.

## Phase Roadmap
| Phase | Week | Focus | Target Effort |
|---|---|---|---|
| Phase 1 | Week 1 | repo boot + menu bar shell + settings skeleton | 20h |
| Phase 2 | Week 2 | timer core for short breaks | 23h |
| Phase 3 | Week 3 | break overlay/blur + countdown | 22h |
| Phase 4 | Week 4 | long breaks + skip/delay/lock logic | 22h |
| Phase 5 | Week 5 | notifications + pre-break heads-up | 20h |
| Phase 6 | Week 6 | smart pause basic (idle/fullscreen/video-audio signal) | 21h |
| Phase 7 | Week 7 | shortcuts + menu quick actions | 20h |
| Phase 8 | Week 8 | settings polish + persistence + presets | 21h |
| Phase 9 | Week 9 | multi-monitor + sound + stability hardening | 20h |
| Phase 10 | Week 10 | QA pass + packaging + release checklist | 20h |

## Detailed Phases
Phase sections below are execution contract. Keep task IDs stable for whole project lifecycle.

## Phase 1 - foundation shell (target: Week 1)
Goal: runnable macOS menu bar app with empty settings shell.

Exit Criteria: app launches, menu bar icon visible, settings window opens with placeholder tabs.

Tasks:
- [ ] `P1-T1` init xcode app target and bundle ids  
  Description: make base macOS target, set bundle ids for debug/release, set deployment target and signing settings.  
  Estimate: `4h`  
  Dependencies: `None`  
  Definition of Done: clean checkout builds and app binary has expected bundle identifiers.

- [x] `P1-T2` menubar extra + app lifecycle wire  
  Description: wire `MenuBarExtra`, startup lifecycle, and process model as menu bar utility app.  
  Estimate: `5h`  
  Dependencies: `P1-T1`  
  Definition of Done: app runs as menu bar app and lifecycle hooks log startup/shutdown events.

- [x] `P1-T3` settings window tabs skeleton (General/Breaks/Advanced placeholders)  
  Description: create settings window with 3 tabs and placeholder content blocks for future features.  
  Estimate: `4h`  
  Dependencies: `P1-T1`  
  Definition of Done: settings window opens from menu and tab switching works without crashes.

- [x] `P1-T4` local logging utility for timer + state transitions  
  Description: add lightweight structured logger for app state and timer transition debugging.  
  Estimate: `4h`  
  Dependencies: `P1-T2`  
  Definition of Done: state transition events print with timestamp and subsystem tags.

- [ ] `P1-T5` basic notification permission request flow  
  Description: add permission request flow and capture accepted/denied state for later reminder features.  
  Estimate: `3h`  
  Dependencies: `P1-T2`  
  Definition of Done: permission prompt can be triggered and status is visible in debug logs.

Retro note (fill after complete):  
worked: `Menu bar + settings + lifecycle scaffolding came together quickly with low churn.`  
slowed: `Notification permission depends on bundled app execution context; bare package launch path blocks prompt.`  
next fix: `Create/validate true macOS app target and re-run permission flow in bundled context.`

## Phase 2 - timer core short break (target: Week 2)
Goal: reliable 20-20-20 timer flow with pause/resume.

Exit Criteria: short break starts on interval and timer state survives app restart.

Tasks:
- [x] `P2-T1` timer engine state machine (`running/paused/break/idle`)  
  Description: implement deterministic timer state machine with transition guards and explicit events.  
  Estimate: `6h`  
  Dependencies: `P1-T2`  
  Definition of Done: state machine can run through all core states in unit-level simulation.

- [x] `P2-T2` short break config model + defaults  
  Description: model interval/duration defaults for 20-20-20 and expose mutable settings object.  
  Estimate: `4h`  
  Dependencies: `P2-T1`  
  Definition of Done: defaults load on first run and changed values reflect in active timer logic.

- [x] `P2-T3` persistence via `UserDefaults`  
  Description: persist timer and settings state needed for app restart continuity.  
  Estimate: `4h`  
  Dependencies: `P2-T2`  
  Definition of Done: app restart restores active configuration and last safe timer checkpoint.

- [x] `P2-T4` pause/resume/manual start next break actions  
  Description: add command handlers for pause, resume, and forcing next break from menu actions.  
  Estimate: `4h`  
  Dependencies: `P2-T1`  
  Definition of Done: each action updates state machine correctly and logs event source.

- [x] `P2-T5` unit tests for timer math drift + boundary behavior  
  Description: build tests for interval drift, near-zero countdown edge, and pause/resume boundaries.  
  Estimate: `5h`  
  Dependencies: `P2-T1, P2-T4`  
  Definition of Done: tests pass and prove no cumulative drift beyond 1 second in 2-hour simulation.

Retro note (fill after complete):  
worked: `Timer engine, controls, and settings came together quickly once state transitions were explicit and logged.`  
slowed: `Phase 2 ran in parallel while bundled app target setup from Phase 1 remains pending.`  
next fix: `Start Phase 3 overlay window manager and keep notification blocker isolated until bundled target is ready.`

## Phase 3 - break overlay (target: Week 3)
Goal: full-screen blur/overlay with countdown for break sessions.

Exit Criteria: break overlay appears on all active displays and exits cleanly after timer end.

Tasks:
- [ ] `P3-T1` overlay window manager per display  
  Description: build per-screen overlay window creation and teardown manager with z-order control.  
  Estimate: `5h`  
  Dependencies: `P2-T1`  
  Definition of Done: overlay opens on each connected display and closes without orphan windows.

- [ ] `P3-T2` blur + dim layer + countdown component  
  Description: render blur background, dim tint, countdown text, and short instruction message.  
  Estimate: `6h`  
  Dependencies: `P3-T1`  
  Definition of Done: overlay visuals render smoothly at 60fps on target hardware.

- [ ] `P3-T3` break end chime integration  
  Description: play calm chime when break ends, include mute-safe fallback path.  
  Estimate: `3h`  
  Dependencies: `P3-T2`  
  Definition of Done: end sound triggers once per break and respects user mute setting.

- [ ] `P3-T4` safe escape path for critical interruptions  
  Description: add emergency dismiss path for urgent workflows while logging event as forced break end.  
  Estimate: `4h`  
  Dependencies: `P3-T2`  
  Definition of Done: emergency exit works from keyboard and event is audit-logged.

- [ ] `P3-T5` visual QA on single + dual monitor  
  Description: run visual QA checklist on 1-monitor and 2-monitor setups for layout and transitions.  
  Estimate: `4h`  
  Dependencies: `P3-T2, P3-T4`  
  Definition of Done: no critical visual defects remain in tested monitor configs.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 4 - long breaks + skip/delay/lock (target: Week 4)
Goal: support long break cadence and enforcement policy modes.

Exit Criteria: short and long break schedule works with skip-anytime, skip-after-delay, and lock mode.

Tasks:
- [ ] `P4-T1` long break scheduler and ratio config  
  Description: add long break cadence model (example every N short breaks) and config controls.  
  Estimate: `5h`  
  Dependencies: `P2-T1, P2-T2`  
  Definition of Done: scheduler can trigger long break on configured ratio with deterministic behavior.

- [ ] `P4-T2` skip anytime mode  
  Description: implement unrestricted skip policy and reset logic after user skips a break.  
  Estimate: `4h`  
  Dependencies: `P4-T1`  
  Definition of Done: skip action always available and timer re-enters running state correctly.

- [ ] `P4-T3` skip after delay mode  
  Description: enforce minimum lock period before skip becomes available on break UI.  
  Estimate: `4h`  
  Dependencies: `P4-T1`  
  Definition of Done: skip button stays disabled until configured delay elapses.

- [ ] `P4-T4` lock break mode (no skip UI)  
  Description: hide skip controls entirely while break active unless emergency escape used.  
  Estimate: `4h`  
  Dependencies: `P4-T1`  
  Definition of Done: no normal skip path exists in lock mode during active break.

- [ ] `P4-T5` state transition tests across all modes  
  Description: test scheduler + policy combinations for invalid transitions and stuck states.  
  Estimate: `5h`  
  Dependencies: `P4-T2, P4-T3, P4-T4`  
  Definition of Done: tests cover all policy modes and pass with no transition deadlocks.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 5 - notifications and heads-up (target: Week 5)
Goal: add pre-break warning and postpone controls.

Exit Criteria: heads-up notifications fire reliably and delay actions adjust schedule correctly.

Tasks:
- [ ] `P5-T1` pre-break notification timing setting  
  Description: add settings field for warning lead-time before short or long break starts.  
  Estimate: `4h`  
  Dependencies: `P1-T5, P2-T2`  
  Definition of Done: selected lead-time value drives actual notification scheduling.

- [ ] `P5-T2` notification actions (`Start now`, `Delay`)  
  Description: implement actionable notifications with fast start and postpone options.  
  Estimate: `5h`  
  Dependencies: `P5-T1`  
  Definition of Done: action clicks route to timer commands and state updates are logged.

- [ ] `P5-T3` floating mini countdown near cursor/menu bar  
  Description: show tiny pre-break countdown indicator and keep it non-intrusive.  
  Estimate: `4h`  
  Dependencies: `P5-T1`  
  Definition of Done: mini countdown appears during warning window and auto-hides at break start.

- [ ] `P5-T4` take break now quick action from menu  
  Description: add immediate break trigger in menu for manual usage.  
  Estimate: `3h`  
  Dependencies: `P2-T4`  
  Definition of Done: selecting menu action starts break overlay instantly.

- [ ] `P5-T5` notification delivery failure fallback path  
  Description: add fallback UI signal when notification center drops or blocks reminder alerts.  
  Estimate: `4h`  
  Dependencies: `P5-T2`  
  Definition of Done: fallback status is visible in menu when alert delivery fails.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 6 - smart pause basic (target: Week 6)
Goal: stop interruptions during idle/fullscreen/media conditions.

Exit Criteria: timer auto-pauses for idle/fullscreen/media signal and resumes/reset follows rules.

Tasks:
- [ ] `P6-T1` idle detection threshold (pause timer)  
  Description: detect short idle and pause countdown while user away from device.  
  Estimate: `5h`  
  Dependencies: `P2-T1`  
  Definition of Done: timer pauses after configured idle threshold and resumes on activity.

- [ ] `P6-T2` long idle threshold (reset timer)  
  Description: detect long-away state and reset break cycle to avoid immediate break on return.  
  Estimate: `4h`  
  Dependencies: `P6-T1`  
  Definition of Done: cycle reset occurs after long idle and is visible in state logs.

- [ ] `P6-T3` fullscreen app detection hook  
  Description: watch active app fullscreen state and defer break trigger while fullscreen active.  
  Estimate: `4h`  
  Dependencies: `P2-T1`  
  Definition of Done: pending break waits until fullscreen exits before overlay starts.

- [ ] `P6-T4` media activity signal integration (basic audio/video heuristic)  
  Description: integrate basic media signal to defer break while likely video playback is active.  
  Estimate: `5h`  
  Dependencies: `P6-T3`  
  Definition of Done: playback-active condition pauses break trigger and resumes when media stops.

- [ ] `P6-T5` smart pause reason indicator in menu/status  
  Description: show why timer paused (idle/fullscreen/media) so state is explainable to user.  
  Estimate: `3h`  
  Dependencies: `P6-T1, P6-T3, P6-T4`  
  Definition of Done: menu status shows active pause reason and clears when resume occurs.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 7 - keyboard shortcuts + controls (target: Week 7)
Goal: full control from keyboard and menu quick actions.

Exit Criteria: global shortcuts are configurable, conflict aware, and consistent with timer state.

Tasks:
- [ ] `P7-T1` shortcut manager for pause/resume/skip/start  
  Description: create shortcut registry and route bindings to timer command handlers.  
  Estimate: `5h`  
  Dependencies: `P2-T4, P4-T2`  
  Definition of Done: registered shortcuts trigger expected actions from any app focus state.

- [ ] `P7-T2` shortcut recording UI in settings  
  Description: add key capture controls for user-defined shortcut mapping.  
  Estimate: `4h`  
  Dependencies: `P7-T1, P1-T3`  
  Definition of Done: user can record and save custom shortcut combinations in settings.

- [ ] `P7-T3` conflict detection and user warning  
  Description: detect duplicate internal bindings and warn on unsupported collisions.  
  Estimate: `4h`  
  Dependencies: `P7-T2`  
  Definition of Done: collisions show warning and invalid binding is not persisted.

- [ ] `P7-T4` menu quick controls sync with timer state  
  Description: keep menu labels and enabled/disabled states in sync with current timer mode.  
  Estimate: `3h`  
  Dependencies: `P2-T4, P4-T4`  
  Definition of Done: menu controls always reflect current state without stale actions.

- [ ] `P7-T5` shortcut behavior tests when app unfocused  
  Description: validate shortcuts still work while another app is frontmost.  
  Estimate: `4h`  
  Dependencies: `P7-T1, P7-T3`  
  Definition of Done: test checklist passes for unfocused app context and conflict cases.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 8 - settings polish + persistence + presets (target: Week 8)
Goal: make all MVP controls easy to configure and stable across restarts.

Exit Criteria: user can configure core MVP behavior end-to-end from settings UI.

Tasks:
- [ ] `P8-T1` breaks config screen (durations, intervals, work hours)  
  Description: complete break settings fields and add schedule window for active work hours only.  
  Estimate: `5h`  
  Dependencies: `P2-T2, P4-T1`  
  Definition of Done: break timing + work hours settings persist and drive runtime behavior.

- [ ] `P8-T2` smart pause config (toggle per detector)  
  Description: add per-detector toggles for idle/fullscreen/media smart pause behavior.  
  Estimate: `4h`  
  Dependencies: `P6-T1, P6-T3, P6-T4`  
  Definition of Done: each detector can be enabled/disabled and change applies immediately.

- [ ] `P8-T3` appearance config (overlay intensity, message text)  
  Description: user controls for blur/dim amount and break message customization.  
  Estimate: `4h`  
  Dependencies: `P3-T2`  
  Definition of Done: appearance settings update overlay style in next rendered break.

- [ ] `P8-T4` import/export config JSON (optional small utility)  
  Description: add import/export utility for settings backup and transfer.  
  Estimate: `4h`  
  Dependencies: `P2-T3, P8-T1`  
  Definition of Done: exported JSON can be imported on same app version and restores settings.

- [ ] `P8-T5` preset profiles (`Default`, `Deep Work`, `Light Mode`)  
  Description: one-click preset packs for common break behavior profiles.  
  Estimate: `4h`  
  Dependencies: `P8-T1, P8-T2, P8-T3`  
  Definition of Done: choosing preset applies all linked settings with confirmation prompt.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 9 - multi-monitor + stability (target: Week 9)
Goal: reliability hardening for daily usage on varied hardware states.

Exit Criteria: no major overlay/timer glitches during two-day dogfooding on multi-monitor setup.

Tasks:
- [ ] `P9-T1` monitor hot-plug handling  
  Description: detect display attach/detach and rebuild overlay window map safely.  
  Estimate: `4h`  
  Dependencies: `P3-T1`  
  Definition of Done: plugging/unplugging monitor does not crash app or leave broken overlays.

- [ ] `P9-T2` app sleep/wake behavior corrections  
  Description: fix timer continuity around system sleep and wake transitions.  
  Estimate: `4h`  
  Dependencies: `P2-T1, P2-T3`  
  Definition of Done: sleep/wake cycle preserves valid timer state and avoids instant false breaks.

- [ ] `P9-T3` chime and notification polish  
  Description: tighten sound timing and remove duplicate/late reminder alerts.  
  Estimate: `4h`  
  Dependencies: `P3-T3, P5-T2`  
  Definition of Done: no duplicate chime/alerts in repeated break cycles.

- [ ] `P9-T4` crash guard around detector services  
  Description: isolate detector failures so timer keeps running even if one detector fails.  
  Estimate: `5h`  
  Dependencies: `P6-T1, P6-T3, P6-T4`  
  Definition of Done: simulated detector exception does not terminate app process.

- [ ] `P9-T5` performance check (CPU/memory baseline logging)  
  Description: log baseline runtime resource usage and identify spikes during break events.  
  Estimate: `3h`  
  Dependencies: `P1-T4`  
  Definition of Done: baseline metrics captured and regression thresholds documented.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Phase 10 - QA + ship prep (target: Week 10)
Goal: release-ready MVP with installable signed/notarized build.

Exit Criteria: installable notarized build works on clean test machine and release notes are ready.

Tasks:
- [ ] `P10-T1` end-to-end test checklist run  
  Description: run full functional checklist across all shipped MVP flows.  
  Estimate: `5h`  
  Dependencies: `P9-T4, P9-T5`  
  Definition of Done: checklist pass report complete with failures triaged or fixed.

- [ ] `P10-T2` accessibility + notification permission UX pass  
  Description: review onboarding copy and settings cues for accessibility/notification permissions.  
  Estimate: `4h`  
  Dependencies: `P1-T5, P5-T2`  
  Definition of Done: permission flow is understandable and recoverable after denial.

- [ ] `P10-T3` code signing + notarization  
  Description: setup release signing profile, notarize build, and validate ticket stapled.  
  Estimate: `4h`  
  Dependencies: `P10-T1`  
  Definition of Done: notarized artifact installs on clean macOS system without security warnings.

- [ ] `P10-T4` release notes + known limitations  
  Description: write first release notes and explicit known gaps to avoid support confusion.  
  Estimate: `3h`  
  Dependencies: `P10-T1`  
  Definition of Done: release note draft reviewed and stored with version tag candidate.

- [ ] `P10-T5` v1.0 tag criteria review  
  Description: final go/no-go review against MVP exit criteria and unresolved risk list.  
  Estimate: `4h`  
  Dependencies: `P10-T2, P10-T3, P10-T4`  
  Definition of Done: explicit launch decision logged with date and rationale.

Retro note (fill after complete):  
worked: `TBD`  
slowed: `TBD`  
next fix: `TBD`

## Post-MVP Backlog

### Bucket 1 - wellness reminders (blink/posture)
- [ ] `B1-T1` blink remind engine baseline  
  Description: add separate blink cadence reminders with soft nudge visual.
- [ ] `B1-T2` posture prompt animation pack  
  Description: build subtle posture cues and optional dim behavior.
- [ ] `B1-T3` wellness reminder config panel  
  Description: frequency toggles, snooze behavior, disable paths.

### Bucket 2 - deep smart pause (meeting/typing/app list)
- [ ] `B2-T1` meeting and call detection plugin  
  Description: pause reminders when call apps in active meeting state.
- [ ] `B2-T2` active typing detector  
  Description: defer break if heavy typing still running near break boundary.
- [ ] `B2-T3` focus app allow/deny list  
  Description: user-defined apps that force pause or force reminders.

### Bucket 3 - iPhone companion sync and break mirror
- [ ] `B3-T1` pairing handshake and device registry  
  Description: add code-based pairing between Mac and companion iPhone app.
- [ ] `B3-T2` break mirror state sync  
  Description: broadcast break start/end and idle events to phone client.
- [ ] `B3-T3` mobile block profile management  
  Description: maintain blocked apps/web categories during mirrored break.

### Bucket 4 - automations (Shortcuts/AppleScript/shell hooks)
- [ ] `B4-T1` automation trigger bus  
  Description: emit typed events for break start/end/pause/resume.
- [ ] `B4-T2` Apple Shortcuts actions  
  Description: expose intents for pause, postpone, start break now.
- [ ] `B4-T3` AppleScript and shell hook support  
  Description: allow user script execution at lifecycle trigger points.

### Bucket 5 - licensing/billing/trial
- [ ] `B5-T1` trial window enforcement  
  Description: 7-day trial logic with clear expiry UX.
- [ ] `B5-T2` one-time license activation flow  
  Description: activation/deactivation with device limit handling.
- [ ] `B5-T3` update entitlement checks  
  Description: enforce update eligibility after 1-year window.

### Bucket 6 - team/admin features
- [ ] `B6-T1` seat management model  
  Description: org seats, ownership transfer, seat reclaim.
- [ ] `B6-T2` config policy profile push  
  Description: shared policy presets for team members.
- [ ] `B6-T3` admin analytics no-PII mode  
  Description: optional aggregate usage stats while preserving privacy rules.

## Risks & Mitigations
| Risk | Impact | Mitigation | Trigger to watch |
|---|---|---|---|
| macOS permissions friction | core features blocked if permissions denied | build clear onboarding + retry path + settings deep links | high setup drop-off in first run |
| detector false positives (idle/fullscreen/media) | breaks pause too often or fire at wrong times | keep detector toggles + expose pause reason + add logs for tuning | user reports "random pauses" |
| multi-monitor edge cases | overlays missing or stuck on one screen | central display map manager + hot-plug tests + safe teardown | monitor attach/detach defects |
| timer drift over long sessions | break timing loses trust | monotonic clock math + drift unit tests + restart checkpoint logic | >1s drift in 2h simulation |
| background app lifecycle quirks | stale state after sleep/wake/login | subscribe to system lifecycle events + state reconciliation on wake | immediate false break post-wake |

## Notes

### Test Cases and Scenarios

#### A. Plan document validation
1. Every phase has goal + exit criteria + tasks.
2. Every task has estimate + dependency + Definition of Done.
3. No phase exceeds one week target workload (about 20-30 hours).
4. MVP scope completes by Phase 10 without leaking post-MVP items into sprint execution.

#### B. Product acceptance scenarios mapped to phases
1. User gets short break every configured interval (Phase 2 and Phase 3).
2. User can delay or lock break by selected mode (Phase 4 and Phase 5).
3. App does not interrupt during idle/fullscreen/media-active situations (Phase 6).
4. User controls app from menu + shortcuts without opening settings (Phase 7).
5. App survives restart/sleep/monitor changes with consistent timer behavior (Phase 8 and Phase 9).
6. Signed/notarized build installs and runs on another Mac (Phase 10).

### Assumptions and Defaults Chosen
1. Sprint size is fixed to 1-week micro-phases.
2. Task format is checklist + Definition of Done + dependencies + estimate.
3. Scope includes MVP execution and explicit post-MVP backlog.
4. Tracking file path is fixed to `docs/PROJECT_TASKS.md`.
5. Task language can be concise and grammar-light when clarity remains.
6. Solo developer throughput target is 20-30 hours per week.
7. Target baseline is macOS 13+ with Swift/SwiftUI-native architecture.
