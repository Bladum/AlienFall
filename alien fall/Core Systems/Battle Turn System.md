# Battle Turn System

## Overview
The Battle Turn System manages the flow of tactical combat on land or water environments, where units engage in turn-based actions over short time intervals. Each turn represents approximately 10 seconds of real-time action, allowing for dynamic positioning, firing, and item usage. This system integrates with the Action Point System and Energy Pool System to regulate unit capabilities and ensure balanced gameplay.

## Mechanics
- **Turn Duration**: Each turn lasts about 10 seconds in real-time, enabling quick tactical decisions.
- **Unit Actions**: Units can move, fire weapons, discover map areas, and use items within their AP budget.
- **Reaction Fire**: Overwatch actions allow units to react to enemy movements with automatic fire.
- **Integration**: Relies on AP for action limits and Energy Pool for stamina and resource management.
- **Environment**: Supports both land and water-based battles with appropriate terrain considerations.

## Examples

Turn Flow Diagram:
1. Player Phase: Select unit, allocate AP for actions (move, fire, overwatch).
2. AI Phase: Enemy units perform similar actions based on AI logic.
3. Resolution: Apply damage, check for reactions, update energy pools.
4. End Turn: Reset AP, regenerate energy partially.

In a typical turn, a unit might move into position (2 AP), fire at an enemy (1 AP), and set overwatch (1 AP), conserving 0 AP for the next turn.

## References
- **XCOM Series**: Turn-based battles with action points and overwatch mechanics.
- **Final Fantasy Tactics**: Grid-based turn system with action limits.
- **Advance Wars**: Tactical turn-based combat on varied terrain.