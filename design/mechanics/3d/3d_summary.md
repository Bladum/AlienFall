# 3D Battlescape Summary

## Purpose & Parity

- Provides an optional first-person presentation layer; every mechanic (AP, accuracy, damage, morale, campaign results) stays 100% identical to 2D Battlescape.
- Lets players swap perspectives instantly (key **V**) without cost, enabling moment-to-moment choice between full tactical overview and immersive view.

## Controls & Navigation

- Movement: `W/S` advance/retreat 1 hex (1 AP), `A/D` free 60° rotations, `Shift` sprint (0.5× AP, no firing), `Ctrl` sneak (2× AP, +3 cover).
- Combat shortcuts mirror 2D bindings (`Space`/`LMB` fire, `R` reload, `G` grenades, `C` stance, number keys for quick select); HUD toggles: `T` hex overlay, `M` minimap, `H` HUD, `ESC` pause.
- Unit changes (`Tab`, `Shift+Tab`, numeric hotkeys) snap camera to new unit facing while preserving AP/morale budgets.

## Camera, Vision & Awareness

- First-person camera anchors to head position with 90° FOV; sight still constrained by unit vision stats (day 8-12 hex, night 3-6, equipment modifiers).
- Minimap reproduces 2D fog-of-war and unit markers, keeping situational awareness despite limited FOV; 3D reticle colours reflect LOS (green/yellow/red) but final accuracy still uses 2D formula.
- Hex overlay aids orientation and training; rotation being free allows scanning without bleeding AP.

## HUD & Information Layer

- Left roster lists HP/AP/morale/status; center reticle and weapon panel show ammo, fire mode feedback, obstruction warnings.
- Ability bar, objective tracker, and turn counter stay consistent with 2D UI, ensuring muscle memory and tutorial compatibility.

## Performance & QA Notes

- Target frame rates: 60 FPS on mid-tier GPUs (GTX 1070 class), 30 FPS on low-end with adjustable LOD; camera swaps must be hitch-free.
- Tests: verify AP costs/initiative identical across perspectives, ensure minimap and FOV logic respect fog rules, confirm event logs, XP gains, and battle outcomes remain synchronized when mixing 2D/3D playthroughs.
