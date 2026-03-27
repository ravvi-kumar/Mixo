# Sprint 08 - Mixo Settings Polish + Persistence Checklist

Sprint window: `Week 8`  
Primary phase: `Phase 8 - settings polish + persistence + presets`  
Linked tasks: `P8-T1, P8-T2, P8-T3, P8-T4, P8-T5`

## Sprint Goal
Finish MVP-level settings so break behavior is configurable, persisted, and reliable across restarts.

## Sprint Exit Criteria
- Break schedule settings (including work hours) persist and drive runtime behavior.
- Smart-pause detector toggles are configurable and persisted.
- Appearance controls for overlay message/style are available.
- Import/export path restores settings safely on the same app version.
- Presets apply coherent bundles of settings.

## Scope Lock
In scope this sprint:
- Work-hours schedule configuration and runtime gating.
- Smart-pause detector toggle wiring.
- Appearance configuration for overlay messaging/style.
- Settings import/export utility.
- Preset profiles.

Out of scope this sprint:
- New detector signal types beyond idle/fullscreen/media.
- Cross-version settings migration guarantees.
- Release packaging tasks.

## Task Board (Phase 8 Mapping)
- [x] `P8-T1` breaks config screen (durations, intervals, work hours)
  - Est: `5h`
  - Depends: `P2-T2, P4-T1`
  - Done means: break timing + work hours settings persist and drive runtime behavior.

- [x] `P8-T2` smart pause config (toggle per detector)
  - Est: `4h`
  - Depends: `P6-T1, P6-T3, P6-T4`
  - Done means: idle/fullscreen/media detector toggles are configurable and persisted through timer settings.

- [ ] `P8-T3` appearance config (overlay intensity, message text)
  - Est: `4h`
  - Depends: `P3-T2`
  - Done means: appearance settings update overlay style on next rendered break.

- [ ] `P8-T4` import/export config JSON (optional small utility)
  - Est: `4h`
  - Depends: `P2-T3, P8-T1`
  - Done means: exported JSON imports on same app version and restores settings.

- [ ] `P8-T5` preset profiles (`Default`, `Deep Work`, `Light Mode`)
  - Est: `4h`
  - Depends: `P8-T1, P8-T2, P8-T3`
  - Done means: selecting preset applies linked settings with user confirmation.

## Verification Checklist (Run Before Sprint Close)
- [x] Work-hours start/resume and outside-window pause behavior validated.
- [x] Smart-pause detector toggles persisted and respected by runtime checks.
- [ ] Overlay appearance controls verified in live break overlay.
- [ ] Import/export round-trip verified with non-default settings.
- [ ] Each preset validated for expected setting bundle.

## Blockers
- `None`

## Daily Log
### 2026-03-27
- Focus: Start Sprint 08 and land settings/persistence foundation tasks.
- Done: Completed `P8-T1` work-hours schedule settings + runtime enforcement + persistence, and `P8-T2` detector toggles (idle/fullscreen/media) with unit coverage updates.
- Issues: none.
- Next: implement `P8-T3` appearance controls for overlay text/style.

## Sprint Retro (Fill at end)
- worked: `TBD`
- slowed: `TBD`
- next fix: `TBD`
