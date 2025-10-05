---
title: Menu and Meta UI Specification
summary: Structure and interactions for front-end menus, options, archives, and meta-progression.
tags:
  - gui
  - menu
  - ux
  - love2d
  - accessibility
---

# Menu and Meta UI Specification

## Purpose
- Provide quick access to campaigns, tactical tests, options, and archives.
- Maintain AlienFall theming while enabling efficient navigation with keyboard, mouse, or controller.
- Host meta-progression features (achievements, codex) and game configuration.

## Screen Inventory
1. **Main Menu**
2. **New Campaign Setup**
3. **Instant Battle Launcher**
4. **Options Suite** (Gameplay, Controls, Audio, Video, Accessibility)
5. **Archives** (Codex, Mission Replays, Reports)
6. **Credits & Support**

## Main Menu Layout
- Background: Animated geoscape vignette at 20×20 snap points.
- Menu stack aligned centre-left with large buttons:
  - `NEW GAME`
  - `BATTLE TEST`
  - `ARCHIVES`
  - `OPTIONS`
  - `MOD MANAGER`
  - `EXIT`
- Bottom footer shows build version, seed hash, quick patch notes ticker.

## New Campaign Setup
- Multi-step wizard with progress breadcrumbs:
  1. **Difficulty & Ironman**: Toggle checkboxes, tooltip explaining modifiers.
  2. **Campaign Seed**: Random generator (display seed string) with manual entry field.
  3. **Starting Base**: Map preview, starting province selection, base name input.
  4. **Advanced Rules**: Optional toggles (Long War pacing, research randomisation) referencing mod hooks.
- Final confirmation summary emphasises determinism (seed, modifiers) before starting geoscape.

## Instant Battle Launcher
- Allows quick access to tactical scenarios for testing.
- Dropdown for mission template, squad preset, map tileset.
- `Launch` button transitions directly to battlescape with debug overlay optional.

## Options Suite
### Gameplay
- Toggles for tutorial, autosave frequency, pause on alerts.
- Sliders for mission timer buffer, interception autopause.

### Controls
- Rebind menu with device tabs (Keyboard/Mouse, Controller).
- Conflict detection prompts players to resolve duplicates.

### Audio & Video
- Audio sliders (master, music, sfx, voice).
- Video options: resolution scale, fullscreen toggle, shader quality preset.

### Accessibility
- Colour-blind modes, text scaling, tooltip persistence duration, screen shake toggle.
- Narration toggle enabling assistive voice overlays.

## Archives
- **Codex**: Unlockable encyclopedia entries, searchable by tag; includes unit, weapon, alien lore.
- **Mission Replays**: List of completed missions; selecting entry replays timeline or exports log.
- **Reports**: Monthly finance/morale reports stored for review, referencing geoscape analytics.

## Mod Manager Integration
- Shows installed mods, load order, compatibility warnings.
- Buttons for enabling/disabling, viewing details (pulls from mod metadata), and opening mod documentation.
- Export load order to clipboard for sharing.

## Accessibility Focus
- Menus navigable entirely via keyboard/controller.
- High-contrast skin available for accessibility tab; persists between sessions.
- Narration cues read menu selections and descriptions when enabled.

## Technical Notes
- Menu state is Love2D root state; push geoscape or battlescape states after selection.
- UI widgets primarily from `widgets/` library with theme applied via `themes/menu.toml`.
- Font sizes anchored to base 16 px, scaled by text accessibility slider.

## Modding Hooks
- Menu entries configurable via `data/gui/menu_entries.toml` (support adding new front-end buttons).
- Options suite panels defined in `data/gui/options_panels.toml`; mods can append new categories.
- Codex draws from `data/pedia/*.toml`; new entries auto-populate when tags set.

## Related Reading
- [GUI Overview](../GUI.md)
- [Organization README](../organization/README.md)
- [Technical README](../technical/README.md)
- [Modding Guide](../technical/Modding.md)

## Tags
`#gui` `#menu` `#accessibility` `#ux` `#modding`
