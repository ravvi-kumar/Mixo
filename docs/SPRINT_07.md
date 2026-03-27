# Sprint 07 - Mixo Keyboard Shortcuts + Controls Checklist

Sprint window: `Week 7`  
Primary phase: `Phase 7 - keyboard shortcuts + controls`  
Linked tasks: `P7-T1, P7-T2, P7-T3, P7-T4, P7-T5`

## Sprint Goal
Give users reliable control from keyboard and menu with configurable shortcuts and clear conflict handling.

## Sprint Exit Criteria
- Global shortcuts trigger timer commands while app is unfocused.
- User can record and save custom shortcuts from settings.
- Duplicate shortcut collisions are rejected with clear warning.
- Menu quick actions remain accurately enabled/disabled by timer state.
- Verification checklist passes for focused + unfocused usage.

## Scope Lock
In scope this sprint:
- Global shortcut manager and app-state routing.
- Settings shortcut recording UI and persistence.
- Internal conflict detection and rejection.
- Menu quick-control state sync verification.
- Manual shortcut behavior checks with another app frontmost.

Out of scope this sprint:
- OS-level shortcut collision detection against external apps.
- Advanced profile/preset shortcut packs.
- Packaging/release tasks.

## Task Board (Phase 7 Mapping)
- [x] `P7-T1` shortcut manager for pause/resume/skip/start
  - Est: `5h`
  - Depends: `P2-T4, P4-T2`
  - Done means: registered shortcuts trigger expected actions from any app focus state.

- [x] `P7-T2` shortcut recording UI in settings
  - Est: `4h`
  - Depends: `P7-T1, P1-T3`
  - Done means: user can record and save custom shortcut combinations in settings.

- [x] `P7-T3` conflict detection and user warning
  - Est: `4h`
  - Depends: `P7-T2`
  - Done means: collisions show warning and invalid binding is not persisted.

- [x] `P7-T4` menu quick controls sync with timer state
  - Est: `3h`
  - Depends: `P2-T4, P4-T4`
  - Done means: menu controls always reflect current state without stale actions.

- [x] `P7-T5` shortcut behavior tests when app unfocused
  - Est: `4h`
  - Depends: `P7-T1, P7-T3`
  - Done means: test checklist passes for unfocused app context and conflict cases.

## Verification Checklist (Run Before Sprint Close)
- [x] Shortcut manager registers defaults and triggers actions.
- [x] Custom shortcuts persist across app restart.
- [x] Duplicate internal shortcuts are rejected and warning shown.
- [x] Menu button enabled/disabled states stay correct through full timer cycle.
- [x] Start/pause-resume/skip shortcuts work while another app is frontmost.

## Blockers
- `None`

## Daily Log
### 2026-03-27
- Focus: Kick off Sprint 07 and complete shortcut foundation + customization path.
- Done: Implemented `GlobalShortcutManager` baseline, settings shortcut recorder, shortcut persistence service, conflict rejection path (`AppStateShortcutTests`), and menu control sync coverage via `AppStateMenuControlStateTests`.
- Issues: none.
- Next: finish `P7-T5` unfocused behavior verification checklist.

### 2026-03-27 (Close)
- Focus: Complete Sprint 07 validation and hand off into Sprint 08 settings polish.
- Done: User validated global shortcuts while another app was frontmost; `P7-T5` and sprint exit checklist are complete.
- Issues: none.
- Next: execute `P8-T1` and `P8-T2` configuration work.

## Sprint Retro (Fill at end)
- worked: `Shortcut routing stayed reliable once command ownership was centralized in AppState.`
- slowed: `Unfocused shortcut behavior needed manual verification instead of pure unit-test coverage.`
- next fix: `Carry deterministic command wiring into Sprint 08 settings/persistence work.`
