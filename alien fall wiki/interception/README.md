# Interception Overview

Interception is the tactical bridge between the geoscape and battlescape. This Love2D-aligned plan replaces legacy descriptions with actionable guidance for the 3×3 engagement grid.

## Role in AlienFall
- Resolve air, land, and underwater confrontations before a missions reaches the ground.
- Let bases contribute via defensive facilities and allow bombers to soften targets.
- Determine whether a mission proceeds to battlescape, aborts, or escalates into new threats.

## Player Experience Goals
- **Single interface:** One 3×3 grid handles every scenario—no mini-game hopping.
- **Readable pacing:** Each round shows AP, energy, cooldowns, and structure health clearly.
- **Strategic spillover:** Outcomes affect morale, salvage, and mission difficulty downstream.

## System Boundaries
- Covers detection handoff, interception grid resolution, base defense artillery, bombardment, land assault transitions, and underwater combat.
- Interfaces with crafts (loadouts, stats), geoscape (mission queue, timing), battlescape (crash/landing setup), and bases (defensive modules).

## Core Mechanics
### Engagement Grid
- 3×3 layout: player slots X/Y/Z vs alien slots A/B/C representing air, surface, and sub-surface layers.
- Slots map to 60×60 logical pixels (3 tiles) on the UI for clarity. Craft sprites are 10×10 scaled ×2.
- Movement actions swap slots within a column or shift layers; cost: 1 AP + optional energy.

### Action Economy
- Each craft acts with 4 AP per round. Weapons consume AP + energy; cooldown measured in rounds.
- Base facilities participating as “weapons on grid” draw from base energy services and share cooldown rules.
- Addons can modify costs (e.g., afterburners reduce move AP but increase energy burn).

### Detection & Ambush
- Missions enter interception only if detected. Undetected missions can ambush, granting aliens a surprise round.
- Detection checks rely on radar/satellite services and craft sensor tags.
- Missions time out if interception takes too long, handing victory to the attacker.

### Outcomes
- **Victory:** Destroy/route all hostile craft. May spawn crash site if craft HP drops below threshold.
- **Stalemate:** Either side disengages; geoscape mission persists or resets depending on objective.
- **Defeat:** Player crafts destroyed or base defenses overwhelmed ➜ base damage, panic, or forced battlescape.

### Special Modes
- **Base Defense:** Facilities occupy grid slots; destroying them damages the base layout.
- **Bombardment:** Player bombers target enemy bases; success reduces battlescape difficulty modifiers.
- **Underwater:** Only craft tagged `underwater` or `naval` can occupy lower layer; weapons respect environment tags.

## Implementation Hooks
- **State Handling:** Interception runs as its own Love2D state with per-round timers and UI overlay. Transition in/out from geoscape via `stateStack:push("interception", payload)`.
- **Data Tables:** `data/interception/weapons.toml`, `data/interception/addons.toml`, `data/interception/scenarios.toml`, `data/interception/base_defense.toml`.
- **Event Bus:** `interception:started`, `interception:round_resolved`, `interception:craft_destroyed`, `interception:facility_damaged`, `interception:ended`.
- **Animation & FX:** Use Love2D tweens (or flux) snapped to the 20×20 grid so missiles and beams travel between slot centres deterministically.

## Grid & Visual Standards
- Slot size: 60×60 logical pixels (3×3 tiles) to highlight craft sprites.
- UI controls align to the 20×20 base grid; action buttons arranged in two rows of 20px height each.
- Effects (missiles, beams) travel along grid-aligned paths; avoid sub-pixel motion.

## Data & Tags
- Scenario tags: `base_defense`, `bombardment`, `site_landing`, `ufo_intercept`, `convoy`.
- Craft tags: `air`, `land`, `naval`, `underwater`, `support`.
- Weapon tags: `air_to_air`, `air_to_land`, `anti_sub`, `support`, `debuff`.

## Master References

📖 **For comprehensive system documentation, see:**
- **[Action Economy](../core/Action_Economy.md)** - Complete AP system including operational-level 4 AP per 30-second round
- **[Time Systems](../core/Time_Systems.md)** - Time scale definitions across all game layers

The Interception system uses operational-level time (30-second rounds) with 4 AP per round. For understanding how this integrates with:
- Tactical time (6-second turns in Battlescape)
- Strategic time (5-minute ticks on Geoscape)
- AP equivalence formulas (1 operational AP = 5 tactical turns)

Please refer to the master documents linked above.

## Related Reading
- [Crafts README](../crafts/README.md)
- [Geoscape README](../geoscape/README.md)
- [Battlescape README](../battlescape/README.md)
- [Basescape README](../basescape/README.md)
- [AI README](../ai/README.md)

## Tags
`#interception` `#grid20x20` `#crafts` `#love2d`
