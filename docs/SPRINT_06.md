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
- [ ] `P6-T1` idle detection threshold (pause timer)
  - Est: `5h`
  - Depends: `P2-T1`
  - Done means: timer pauses after configured idle threshold and resumes on activity.

- [ ] `P6-T2` long idle threshold (reset timer)
  - Est: `4h`
  - Depends: `P6-T1`
  - Done means: cycle reset occurs after long idle and logs reason.

- [ ] `P6-T3` fullscreen app detection hook
  - Est: `4h`
  - Depends: `P2-T1`
  - Done means: pending break waits until fullscreen exits.

- [ ] `P6-T4` media activity signal integration (basic heuristic)
  - Est: `5h`
  - Depends: `P6-T3`
  - Done means: playback-active signal defers break trigger.

- [ ] `P6-T5` smart pause reason indicator in menu/status
  - Est: `3h`
  - Depends: `P6-T1, P6-T3, P6-T4`
  - Done means: active pause reason is visible and clears when resume conditions are met.

## Daily Execution Checklist

### Day 1 - idle pause baseline
- [ ] Add idle detector service abstraction.
- [ ] Add pause threshold config and defaults.
- [ ] Wire idle-pause command path to timer state machine.
- [ ] Log note in daily log.

### Day 2 - long idle reset
- [ ] Add long-idle threshold config.
- [ ] Implement reset-on-long-idle behavior.
- [ ] Add transition tests for pause vs reset thresholds.
- [ ] Log note in daily log.

### Day 3 - fullscreen deferral
- [ ] Add fullscreen detection hook abstraction.
- [ ] Defer break start while fullscreen is active.
- [ ] Ensure deferred break triggers once fullscreen exits.
- [ ] Log note in daily log.

### Day 4 - media signal deferral
- [ ] Add basic media activity heuristic service.
- [ ] Defer break trigger during media playback signal.
- [ ] Validate deferral recovery behavior.
- [ ] Log note in daily log.

### Day 5 - status + close
- [ ] Add smart-pause reason status in menu/settings.
- [ ] Run full build + tests.
- [ ] Update `docs/PROJECT_TASKS.md` and sprint retro.
- [ ] Capture follow-up items for Phase 7 handoff.

## Verification Checklist (Run Before Marking Done)
- [ ] Idle pause triggers at configured threshold.
- [ ] Long idle resets timer cycle at configured threshold.
- [ ] Fullscreen defers break trigger and resumes correctly.
- [ ] Media activity defers break trigger and resumes correctly.
- [ ] Menu reason indicator matches active pause/defer state.
- [ ] Unit tests for new transitions pass.

## Blockers
- `None`

## Daily Log
Use this section every day; keep short.

### 2026-03-04
- Focus: Sprint 05 close-out and Sprint 06 kickoff.
- Done: Closed Sprint 05 tasks (`P5-T1` to `P5-T5`) and validated with full `MixoTests` pass in bundled Xcode setup.
- Issues: none.
- Next: implement `P6-T1` idle detection pause threshold.

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
