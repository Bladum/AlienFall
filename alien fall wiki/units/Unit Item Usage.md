# Unit Item Usage

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Action Point and Energy Costs](#action-point-and-energy-costs)
  - [Cooldown and Charge Systems](#cooldown-and-charge-systems)
  - [Usage Types and Targeting](#usage-types-and-targeting)
  - [Prerequisites and Validation](#prerequisites-and-validation)
  - [Turn Processing and State Management](#turn-processing-and-state-management)
  - [Provenance and Determinism](#provenance-and-determinism)
- [Examples](#examples)
  - [Weapon Usage Examples](#weapon-usage-examples)
  - [Consumable Usage Examples](#consumable-usage-examples)
  - [Equipment Usage Examples](#equipment-usage-examples)
  - [Action Plan Validation Examples](#action-plan-validation-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Unit Item Usage system defines the per-activation economy for equipped gear using three canonical parameters: Action Points (AP), Energy, and Cooldown Turns. These parameters control how often and in what combinations items can be used in a turn, making weapon roles mechanically explicit. The system supports multiple usage types including weapons, consumables, and equipment, with deterministic validation and execution.

Usage mechanics include action point costs for tactical flexibility, energy consumption for resource management, cooldown turns to prevent overuse, and charge systems for limited-use items. All usage is validated against current unit state, available resources, and tactical context, with clear UI feedback about infeasible action plans. The system ensures reproducible outcomes through seeded randomization and comprehensive provenance tracking.

## Mechanics
### Action Point and Energy Costs
Action Points determine tactical flexibility with lower costs allowing more actions per turn, while energy consumption represents power requirements and encourages strategic resource management. AP costs range from 1-4 points with role differentiation (sidearms vs heavy weapons), and energy costs range from 0-50 units with regeneration between turns.

### Cooldown and Charge Systems
Cooldown turns prevent overuse of powerful equipment, enforcing tactical pacing and reload mechanics as the primary limitation tool. Cooldowns range from 0-5 turns with per-item instance tracking. Limited-use items have charges that deplete with usage, representing ammunition or durability, with configurable consumption rates and replenishment options.

### Usage Types and Targeting
Different item categories have distinct mechanics: weapons for combat with enemy targeting, consumables that deplete after use, equipment with passive or active abilities. Targeting rules include target types (self, ally, enemy, area), range limits, line-of-sight requirements, and area effects, with comprehensive pre-usage validation.

### Prerequisites and Validation
Items can require stat minimums, specific abilities, health thresholds, or morale conditions. Action plan validation checks complete sequences for feasibility, simulating resource consumption and cooldowns across planned actions. Validation provides detailed error feedback and supports optimal action sequence calculation.

### Turn Processing and State Management
Turn boundaries trigger cooldown updates, charge regeneration, and usage state management. Turn start decrements cooldowns and recalculates availability, while turn end logs usage history and cleans up state. Efficient batch processing handles multiple units with bounded log sizes for performance.

### Provenance and Determinism
Comprehensive logging tracks all usage events with timestamps, context, and random seeds for reproducible debugging. Usage history supports filtering by unit, item, or time range, with complete audit trails for issue investigation and deterministic reproduction of outcomes.

## Examples
### Weapon Usage Examples
Pistol provides flexible close-quarters capability with 1 AP cost, 0 energy, and 0 cooldown turns, enabling multiple shots per turn. Rocket launcher requires 4 AP, 0 energy, and 2-turn cooldown, enforcing heavy single-shot usage with reload downtime. Sniper rifle costs 3 AP and 25 energy with 1-turn cooldown, representing precision long-range capability with high resource demands.

### Consumable Usage Examples
Medikit restores health with 2 AP cost, 0 energy, and 0 cooldown but depletes after single use. Stimulant provides temporary boost with 1 AP, 0 energy, and 3-turn cooldown, requiring low health prerequisite. Smoke grenade creates concealment with 2 AP, 0 energy, and 1-turn cooldown, supporting tactical area denial.

### Equipment Usage Examples
Motion scanner reveals hidden enemies with 1 AP and 5 energy cost, 2-turn cooldown, enabling detection capabilities. Equipment usage integrates with unit abilities while consuming tactical resources and respecting cooldown limitations.

### Action Plan Validation Examples
Basic combat turn with 5 AP and 20 energy allows pistol (1 AP) followed by rifle (2 AP, 12 energy), leaving resources for additional actions. Heavy assault with rocket launcher (4 AP) followed by pistol (1 AP) succeeds but creates cooldown restrictions. Invalid plans with insufficient energy or AP receive detailed error feedback preventing infeasible combinations.

## Related Wiki Pages

- [Item Usage.md](../units/Item%20Usage.md) - General item usage mechanics
- [Action points.md](../units/Action%20points.md) - Action point cost systems
- [Energy.md](../units/Energy.md) - Energy cost and consumption
- [Inventory.md](../units/Inventory.md) - Equipment management and slots
- [Unit actions.md](../battlescape/Unit%20actions.md) - Action integration and planning
- [Classes.md](../units/Classes.md) - Class-specific usage restrictions
- [Morale.md](../battlescape/Morale.md) - Morale effects on usage
- [AI.md](../ai/AI.md) - AI decision making and item usage
- [Units.md](../units/Units.md) - Unit capabilities and restrictions
- [Modding.md](../technical/Modding.md) - Custom item creation and usage

## References to Existing Games and Mechanics

- **X-COM Series**: Item usage and equipment management in tactical combat
- **Fire Emblem Series**: Weapon usage and item consumption mechanics
- **Final Fantasy Tactics**: Item command system and tactical usage
- **Advance Wars**: Unit action economy and equipment usage
- **Tactics Ogre**: Equipment usage and item management systems
- **Disgaea Series**: Item usage and special ability systems
- **Persona Series**: Item usage and support abilities in combat
- **Mass Effect Series**: Power usage and cooldown systems
- **Dragon Age Series**: Ability usage and resource management
- **Fallout Series**: Item consumption and equipment usage

