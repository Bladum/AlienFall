# Item Action Economy

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Action Cost System](#action-cost-system)
  - [Resource Consumption](#resource-consumption)
  - [Cooldown Mechanics](#cooldown-mechanics)
  - [Charge System](#charge-system)
  - [Usage Validation](#usage-validation)
  - [Turn Processing](#turn-processing)
- [Examples](#examples)
  - [Basic Item Usage](#basic-item-usage)
  - [Craft Weapon Systems](#craft-weapon-systems)
  - [Tactical Planning](#tactical-planning)
  - [Resource Management](#resource-management)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Item Action Economy system governs how items compete with other actions and shape tactical decision-making by implementing clear resource costs, usage limitations, and turn-based mechanics in Alien Fall. Items become meaningful tactical resources through AP costs, energy consumption, cooldowns, and charge limitations that force players to make strategic choices about when and how to use equipment. The system ensures deterministic resolution and provides comprehensive preview tools for action planning and validation.

## Mechanics

### Action Cost System

AP consumption for item activation:

- AP Cost Range: 1-4 AP per use (recommended for balance)
- Flexible Items: Lower AP cost increases versatility in action sequencing
- Committed Actions: Higher AP cost limits combination possibilities
- Turn Budget: Items consume from finite per-turn action point pool
- Predictable Costs: Fixed AP costs enable reliable planning

### Resource Consumption

Energy requirements for item operation:

- Energy Cost: Variable consumption based on item power requirements
- Pool Management: Draws from unit or craft energy reserves
- Shared Resources: Craft energy shared across all mounted weapons
- Regeneration: Energy recovers between turns
- Capacity Limits: Items cannot be used if insufficient energy available

### Cooldown Mechanics

Turn-based usage limitations:

- Cooldown Duration: Number of turns item becomes unusable after activation
- Independent Blocking: Cooldown prevents use regardless of remaining AP/energy
- Turn Processing: Cooldowns decrement at turn end
- Strategic Spacing: Forces consideration of item timing
- No Cooldown: Items with 0 cooldown can be used multiple times per turn

### Charge System

Limited-use consumable mechanics:

- Charge Count: Number of uses before item becomes unusable
- Consumption Rate: Charges consumed per activation
- Permanent Exhaustion: Items with 0 charges cannot be used
- Strategic Scarcity: Creates tension around item availability
- No Charges: Items without charge limits have unlimited uses

### Usage Validation

Pre-execution requirement checking:

- AP Availability: Sufficient action points for item cost
- Energy Sufficiency: Adequate energy for consumption
- Cooldown Status: Item not currently on cooldown
- Charge Remaining: Available uses if charge-limited
- Target Validity: Appropriate target for item effects

### Turn Processing

End-of-turn and start-of-turn mechanics:

- Cooldown Reduction: Active cooldowns decrement by 1 each turn
- Item Refresh: Items become available when cooldown reaches 0
- State Persistence: Cooldowns and charges maintained across turns
- Turn Boundaries: Clear separation between turn-based phases
- Automatic Processing: No player intervention required for cleanup

## Examples

### Basic Item Usage

Craft Cannon (Dogfight)
- AP Cost: 1
- Energy Cost: 2
- Cooldown: 0 turns
- Usage: Can be fired repeatedly until AP/energy exhausted
- Tactical Role: Flexible, sustainable weapon system

Stingray Missile (Dogfight)
- AP Cost: 2
- Energy Cost: 12
- Cooldown: 2 turns
- Usage: Powerful single use with enforced reload gap
- Tactical Role: High-impact, limited availability weapon

Pistol (Close Quarters)
- AP Cost: 1
- Energy Cost: 0
- Cooldown: 0 turns
- Usage: Flexible sidearm for emergency situations
- Tactical Role: Backup weapon with minimal resource cost

Medikit (Consumable)
- AP Cost: 1
- Energy Cost: 0
- Charges: 1
- Cooldown: 0 turns
- Usage: Single-use healing item
- Tactical Role: Emergency medical support

### Craft Weapon Systems

Laser Battery
- AP Cost: 1
- Energy Cost: 2
- Cooldown: 0 turns
- Usage: Multiple shots per turn possible
- Energy Management: 10 energy allows 5 shots

Heavy Missile Pod
- AP Cost: 2
- Energy Cost: 12
- Cooldown: 2 turns
- Usage: Single powerful attack per engagement
- Resource Trade-off: High damage for limited flexibility

### Tactical Planning

Conservative Energy Use
- Starting Energy: 20
- Single Shot: -2 energy (remaining 18)
- Move: -1 energy (remaining 17)
- Grenade: -3 energy (remaining 14)
- Strategy: Sustainable pacing with energy reserves

Aggressive Energy Expenditure
- Starting Energy: 20
- Burst Fire: -6 energy (remaining 14)
- Sprint: -2 energy (remaining 12)
- Special Ability: -5 energy (remaining 7)
- Risk: High output but limited sustainability

### Resource Management

Turn Budget Planning
- Available AP: 4
- Move: 1 AP (remaining 3)
- Shoot: 2 AP (remaining 1)
- Item Use: 1 AP (remaining 0)
- Result: Complete turn utilization

Cooldown Timing
- Turn 1: Use missile (cooldown 2)
- Turn 2: Missile unavailable, use cannon
- Turn 3: Missile available again
- Strategy: Alternate weapon systems for sustained combat

## Related Wiki Pages

- [Resources.md](../items/Resources.md) - Resource consumption mechanics.
- [Unit items.md](../items/Unit%20items.md) - Item usage costs and limitations.
- [Special items.md](../items/Special%20items.md) - Special item action economy.
- [Crafts.md](../crafts/Crafts.md) - Craft action economy and resources.
- [Battlescape.md](../battlescape/Battlescape.md) - Combat action economy.
- [Units.md](../units/Units.md) - Unit action points and resources.
- [Economy.md](../economy/Economy.md) - Economic costs and resource management.
- [AI.md](../ai/AI.md) - AI action planning and resource allocation.

## References to Existing Games and Mechanics

- **XCOM Series**: Action points and item usage costs
- **Fire Emblem Series**: Action costs and item consumption
- **Final Fantasy Tactics**: Complex action economy systems
- **Disgaea Series**: Action points and item management
- **Into the Breach**: Turn-based action economy
- **Gears Tactics**: Action points and resource management
- **BattleTech**: Heat management and action economy
- **MechWarrior Series**: Action economy and resource constraints
- **Warhammer 40k**: Action economy in tactical combat
- **Dungeons & Dragons**: Action economy and resource management

