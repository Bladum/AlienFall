---
title: Interception UI Specification
summary: Craft engagement interface for UFO and site encounters.
tags:
  - gui
  - interception
  - ux
  - love2d
  - grid20x20
---

# Interception UI Specification

## Purpose
- Provide real-time tactical control over interception craft while preserving deterministic outcomes.
- Bridge geoscape launches and battlescape deployments with clear feedback.
- Support multi-craft engagements inspired by UFO Defense dogfights.

## Layout Summary
- **Engagement Canvas**: Top-left 70% displaying relative positions, altitude bands, and engagement ranges on a 20×20 grid overlay.
- **Craft Status Panels**: Right column showing player craft vitals (armor, fuel, weapons, pilots) and target information.
- **Command Deck (bottom)**: Action buttons for formations, attack stances, disengage, and special abilities.
- **Timeline Strip (top-right)**: Event queue with upcoming volleys, cooldowns, and escape thresholds.

## Core Interactions
### Craft Control
- Select craft via status panels or directly on canvas (click hitbox). Selected craft highlights with bracket HUD.
- Attack modes: `Aggressive`, `Standard`, `Cautious`, each with deterministic modifiers displayed in tooltip.
- Formation commands: `Line`, `V`, `Scatter` adjusting positioning and evasion.
- Disengage button prompts confirmation; success odds shown based on speed differential.

### Weapon Management
- Each weapon slot displays ammo, cooldown, optimal range band.
- Clicking weapon opens targeting cone preview; greyed out when outside band.
- Special weapon actions (EMP burst, torpedoes) require hold-to-confirm to avoid misfires.

### Target Intel
- Target pane shows UFO class, hull integrity, behaviour (aggressive, evasive), escape timer.
- Sensor check progress bar indicates chances to identify subsystems (e.g., weapon pods, shields).

### Multi-Craft Coordination
- Up to three friendly craft; use hotkeys `1-3` to focus.
- `Sync Volley` button aligns weapon fire across selected craft.
- Support craft (tankers, AWACS) appear as auxiliary cards with ability triggers (refuel, radar boost).

## Information Architecture
- **Altitude Bands**: Horizontal markers labelled `Low`, `Mid`, `High`, `Stratosphere`; craft icons show current band.
- **Range Circles**: Concentric rings representing weapon range thresholds (short, medium, long).
- **Damage Feedback**: Floating combat text indicates hits, misses, criticals with seeded roll IDs for QA.
- **Escape Vector**: Arrow showing UFO escape direction and estimated time to exit.

## Transition Flows
- **From Geoscape**: Launch overlay fades into interception canvas, retaining mission card in right column for reference.
- **Victory**: Post-engagement modal summarises damage, ammo spent, salvage tags. Offers `Deploy Strike Team` (if crash site) or `Return to Base`.
- **Defeat/Abort**: Craft status updates push healing timers to basescape hospital; geoscape resumes paused state with warning toast.

## Accessibility
- Toggle for simplified mode: condenses data to numerical bars, adds text callouts for events.
- Colour-blind friendly palette for range circles.
- All command deck buttons accessible via keyboard shortcuts (displayed on buttons).

## Modding Hooks
- Command deck layout defined in `data/gui/interception_commands.toml`.
- Range circle styling configurable via `data/gui/interception_overlays.toml`.
- Event timeline entries derived from `data/interception/events.toml`; mods can append additional phases.

## Related Reading
- [GUI Overview](../GUI.md)
- [Interception README](../interception/README.md)
- [Geoscape Overview](../geoscape/README.md)
- [Battlescape README](../battlescape/README.md)

## Tags
`#gui` `#interception` `#craft` `#ux` `#grid20x20`
