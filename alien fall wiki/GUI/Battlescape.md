---
title: Battlescape UI Specification
summary: Tactical interface layout, controls, and combat feedback systems.
tags:
  - gui
  - battlescape
  - ux
  - love2d
  - grid20x20
---

# Battlescape UI Specification

## Purpose
- Deliver deterministic, readable combat information while keeping the playfield unobstructed.
- Support squad-level tactics inspired by classic UFO Defense with modern clarity.
- Align with the 20×20 grid across HUD and camera systems.

## Layout Summary
- **Main Viewport**: 40×30 logical tiles (800×600) rendered with camera offsets of 10 pixels for smooth panning.
- **Bottom Command Bar**: Order buttons, unit portrait, stats cluster, inventory slots, and end-turn controls.
- **Left Alert Column**: Event feed (overwatch triggers, wounds), objective tracker, morale status.
- **Top Status Header**: Turn counter, engagement seed, weather/day-night indicator.

## Interaction Model
### Unit Selection
- Left-click selects unit; double-click recentres camera.
- `TAB`/`SHIFT+TAB` cycles units; `CTRL+number` creates fire teams (control groups).
- Selection indicator: glowing base circle aligned to tile bounds.

### Orders & Abilities
- Command bar exposes stance buttons: `WATCH (Overwatch)`, `CROUCH`, `STEADY`, `HOLD`. Each button shows AP cost and hotkey.
- Contextual ability carousel appears above command bar for unit-specific skills (grenades, psionics).
- Right-click on tile displays radial menu: `Move`, `Dash`, `Inspect`. Movement preview shows AP expenditure per segment and exposure changes.

### Weapon & Inventory Handling
- Three item slots: primary weapon, secondary, armour/utility. Clicking opens item cards with stats, ammo count, modifiers.
- Drag-and-drop between squad members allowed in deployment/loot phases only.
- Reload, swap, and discard actions available via context ribbon above item slots.

### Camera & Visibility
- Edge scrolling (10 px threshold), WASD keyboard panning, mouse wheel zoom (two levels).
- Fog-of-war shading uses tile overlay; hovered tiles display LOS preview in tooltip with hit odds.
- Enemy silhouettes appear when spotted; color-coded outlines indicate cover state (green full, yellow half, red exposed).

## Feedback Systems
- **Hit Chance Panel**: When targeting, overlay shows base chance, modifiers (cover, elevation, morale), and deterministic seed hash for QA.
- **Damage Forecast**: Displays min/max damage, crit chance, status effect odds.
- **Action Log**: Timestamped log with icons; clicking entry replays cinematic camera highlight.
- **Morale Meter**: Horizontal bar under unit portrait; thresholds marked for panic/berserk triggers.

## Phase Flow
1. **Deployment Phase**: Pre-battle placement UI with grid snapping, loadout adjustments, objective briefing modal.
2. **Player Turn**: Command bar active, end-turn button available once AP spent or user confirms skip.
3. **Alien Turn**: Command bar greyed out, action log animates enemy activity, interrupts highlight reactive fire.
4. **After-Action**: Victory/defeat modal summarises casualties, salvage, timeline of key events.

## Accessibility
- Colour filters for colour-blind modes (toggle via `F6`).
- Optional auto-zoom for action events disabled by default; accessible via settings gear on command bar.
- Tooltips include text-to-speech cues (if system supports). Subtitle area above command bar captions barks.

## Modding Hooks
- Command bar layout defined in `data/gui/battlescape_command_bar.toml`.
- Ability carousel reads metadata from `data/units/abilities.toml`; mods can add icon and tooltip references.
- Action log templates stored in `data/gui/battlescape_log.toml` for consistent phrasing.

## Related Reading
- [GUI Overview](../GUI.md)
- [Battlescape Overview](../battlescape/README.md)
- [Items README](../items/README.md)
- [Units README](../units/README.md)
- [AI README](../ai/README.md)

## Tags
`#gui` `#battlescape` `#tactics` `#ux` `#grid20x20`
