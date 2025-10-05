# Line of Fire

## Overview
Line of Fire calculations determine valid shooting paths, accounting for obstructions and angles to ensure realistic projectile trajectories. This system prevents shooting through walls or units, enforcing geometric constraints on combat. It integrates with terrain and unit positioning for accurate targeting validation.

## Mechanics
- **Path Calculation**: Checks for clear line between shooter and target.
- **Obstructions**: Walls, units, or terrain block fire unless penetrable.
- **Angle Limits**: Weapons have firing arcs; indirect fire may bypass some blocks.
- **Validation**: Only unobstructed paths allow shots.

## Examples

Fire Path Diagram:
- Clear: Direct line, no blocks.
- Blocked: Wall in path, invalid.
- Partial: Low wall allows if weapon can arc.

Scenario: Sniper behind cover has clear line; infantry blocked by building.

## References
- **XCOM Series**: Line of sight blocking by cover.
- **Doom Series**: Hitscan and projectile paths.
- **Rainbow Six Siege**: Destructible environments affecting lines of fire.