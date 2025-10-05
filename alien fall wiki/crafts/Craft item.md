# Craft Items

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Item Definition Structure](#item-definition-structure)
  - [Action Economy System](#action-economy-system)
  - [Equipment Categories](#equipment-categories)
  - [Mounting and Compatibility](#mounting-and-compatibility)
  - [Battery Aggregation Systems](#battery-aggregation-systems)
  - [Energy Pool Management](#energy-pool-management)
  - [Loadout Management](#loadout-management)
  - [Usage Validation](#usage-validation)
- [Examples](#examples)
  - [Weapon Examples](#weapon-examples)
    - [Light Laser Cannon](#light-laser-cannon)
    - [Heavy Plasma Cannon](#heavy-plasma-cannon)
    - [Railgun Battery (4-barrel)](#railgun-battery-4-barrel)
  - [Utility Examples](#utility-examples)
    - [Repair Drone Launcher](#repair-drone-launcher)
    - [Sensor Booster](#sensor-booster)
  - [Battery Examples](#battery-examples)
    - [Dual Laser Battery](#dual-laser-battery)
    - [Quad Missile Battery](#quad-missile-battery)
  - [Loadout Examples](#loadout-examples)
    - [Interceptor "Dogfighter" Loadout](#interceptor-"dogfighter"-loadout)
    - [Bomber "Heavy Striker" Loadout](#bomber-"heavy-striker"-loadout)
    - [Capital "Battleship" Loadout](#capital-"battleship"-loadout)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Craft items define modular equipment that can be mounted on spacecraft, providing offensive, defensive, and utility capabilities for both geoscape operations and tactical dogfights. The system creates tactical decision-making through resource management, with items consuming Action Points (AP), energy, and having cooldown periods. Items are data-driven to support extensive modding while maintaining deterministic behavior through seeded random generation.

The craft item system enables fleet customization where individual ships can be optimized for specific roles such as interception, heavy strike, or reconnaissance. Items determine a craft's offensive, defensive, and operational capabilities while interacting with dogfight mechanics and strategic dispatch systems. The modular design allows players to balance trade-offs between raw damage, sustained throughput, and utility functions.

## Mechanics

### Item Definition Structure

Each craft item has a comprehensive definition specifying capabilities, resource requirements, and behavioral characteristics:

- Identification: Unique identifier, display name, and description
- Categorization: Equipment category and size classification
- Resource Costs: AP cost, energy consumption, and cooldown duration
- Combat Parameters: Damage, range, accuracy, penetration, and special effects
- Mounting Requirements: Hardpoint needs, size constraints, and compatibility tags
- Usage Limits: Charge counts, mount limits, and activation conditions

### Action Economy System

Items consume three types of resources creating tactical decision-making:

- Action Points (AP): Limited per turn, representing crew attention and command capacity
- Energy: Shared pool that depletes with usage, recharges over time with depletion penalties
- Cooldown: Recovery turns before reuse, representing weapon cycling or system recovery

### Equipment Categories

Items are classified into functional categories with distinct behaviors:

- Weapons: Offensive systems dealing damage in dogfights
- Utility: Support systems providing buffs, repairs, or special abilities
- Sensors: Detection and targeting enhancement systems
- ECM (Electronic Countermeasures): Jamming and deception systems
- Batteries: Aggregated weapon systems combining multiple identical items

### Mounting and Compatibility

Items have physical and logical limitations on installation:

- Hardpoint System: Required mounting points with size categories (small, medium, large)
- Capacity Constraints: Weight and power draw limits per craft
- Compatibility Tags: Craft type restrictions (fighter, interceptor, bomber, transport)
- Dependency Rules: Items requiring or conflicting with other equipment
- Slot Type Validation: Weapon slots vs. addon/utility slots

### Battery Aggregation Systems

Multiple identical weapons combine into batteries for enhanced effectiveness:

- Damage Scaling: Increased firepower with diminishing returns (up to 4-6 barrels)
- Energy Efficiency: Non-linear power consumption scaling
- Firing Patterns: Tight grouping (+accuracy), spread pattern (+coverage), alternating fire
- Cooldown Management: Battery-wide recovery times and synchronization

### Energy Pool Management

Enhanced energy systems with depletion mechanics:

- Capacity Range: 100-500 energy based on craft class and upgrades
- Depletion Thresholds: Performance penalties at 75%, 50%, and 25% capacity
- Recharge Rates: Turn-based recovery with crew quality modifiers
- Efficiency Penalties: Reduced effectiveness during low-energy states

### Loadout Management

Craft loadouts require validation and optimization:

- Compatibility Checking: All items fit within craft constraints and capacity budgets
- Resource Analysis: Total power draw, weight calculations, and energy consumption
- Effectiveness Metrics: Damage output, resource efficiency, and versatility scoring
- Warning System: Alerts for suboptimal configurations and compatibility issues

### Usage Validation

System validates item usage before activation:

- Resource Availability: Sufficient AP and energy reserves
- Cooldown Status: Recovery period completion
- Charge Limits: Ammunition or usage count verification
- Mount Integrity: Proper installation and functionality
- Compatibility Verification: Craft type and equipment matching

## Examples

### Weapon Examples

#### Light Laser Cannon
- Damage: 25 energy damage
- Range: 30 units, Accuracy: 85%
- Resource Cost: 2 AP, 20 energy, 0 cooldown
- Mounting: 1 hardpoint, small size, fighter/interceptor compatible
- Effects: Clean energy weapon with high accuracy

#### Heavy Plasma Cannon
- Damage: 60 energy with 20% burn chance (2 turns)
- Range: 25 units, Accuracy: 75%
- Resource Cost: 3 AP, 45 energy, 1 turn cooldown
- Mounting: 2 hardpoints, medium size, bomber compatible
- Effects: High damage with DoT capability

#### Railgun Battery (4-barrel)
- Damage: 160 kinetic total (40 per barrel)
- Range: 40 units, Accuracy: 70% (tight), 60% (spread)
- Resource Cost: 4 AP (shared), 180 energy, 2 turn cooldown
- Mounting: 8 hardpoints, large size, capital ship compatible
- Effects: Sustained kinetic damage with area options

### Utility Examples

#### Repair Drone Launcher
- Effect: Restores 30 hull to target craft
- Range: 15 units, Accuracy: 90%
- Resource Cost: 2 AP, 25 energy, 1 turn cooldown
- Charges: 3 per mission
- Mounting: 1 hardpoint, small size, universal compatibility

#### Sensor Booster
- Effect: +25% detection range, +15% weapon accuracy (3 turns)
- Range: Self, Accuracy: N/A
- Resource Cost: 1 AP, 15 energy sustained, 0 cooldown
- Mounting: 1 hardpoint, small size, universal compatibility

### Battery Examples

#### Dual Laser Battery
- Configuration: 2x Light Laser Cannon
- Total Damage: 50 energy (110% efficiency)
- Resource Cost: 2 AP shared, 44 energy, 0 cooldown
- Firing Pattern: Alternating for sustained pressure

#### Quad Missile Battery
- Configuration: 4x Standard Missile Launcher
- Total Damage: 160 explosive (130% efficiency)
- Resource Cost: 3 AP shared, 120 energy, 1 turn cooldown
- Firing Pattern: Spread for area denial

### Loadout Examples

#### Interceptor "Dogfighter" Loadout
- Weapons: Dual Light Laser Cannons (50 DPS sustained)
- Utility: Chaff Launcher (ECM), Afterburner (speed boost)
- Energy Draw: 55/turn, AP Efficiency: 6.2 damage/AP
- Versatility: 35 (energy damage, close range, mobility)

#### Bomber "Heavy Striker" Loadout
- Weapons: Heavy Plasma Cannon (60 DPS burst)
- Utility: Repair Drone Launcher, Sensor Booster
- Energy Draw: 70/turn, AP Efficiency: 8.5 damage/AP
- Versatility: 42 (energy damage, burn effects, sustainability)

#### Capital "Battleship" Loadout
- Weapons: Quad Railgun Battery (160 DPS sustained)
- Utility: Point Defense Lasers, Shield Booster
- Energy Draw: 200/turn, AP Efficiency: 12.3 damage/AP
- Versatility: 58 (kinetic damage, long range, defense)

## Related Wiki Pages

- [Craft Stats](crafts/Stats.md) - Item performance characteristics and capabilities
- [Craft Energy](crafts/Energy.md) - Energy consumption and battery systems
- [Craft Encumbrance](crafts/Encumbrance.md) - Weight and mounting constraints
- [Manufacturing](economy/Manufacturing.md) - Item production and assembly
- [Research](basescape/Research.md) - Item development and technology progression
- [Suppliers](economy/Suppliers.md) - Item procurement and supply chains
- [Finance](finance/Finance.md) - Item costs and maintenance expenses
- [Technical Architecture](architecture.md) - Item data structures and systems
- [Interception](interception/Overview.md) - Combat item usage mechanics
- [Geoscape](geoscape/Geoscape.md) - Strategic item deployment

## References to Existing Games and Mechanics

- **XCOM Series**: Equipment and weapon systems for unit customization
- **Master of Orion**: Ship components and equipment loadouts
- **Homeworld**: Ship modules, weapons, and subsystem upgrades
- **Freespace**: Weapon loadouts and ship equipment systems
- **Wing Commander**: Craft upgrades and equipment customization
- **Star Control**: Equipment systems and ship modification mechanics
- **Elite**: Ship equipment and component installation systems
- **X3: Reunion**: Component systems and ship equipment management
- **Civilization**: Unit upgrades and equipment enhancement
- **MechWarrior**: Mech equipment and weapon loadout systems

