# Craft Inventory

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Slot-Based Mounting System](#slot-based-mounting-system)
  - [Cargo Capacity Management](#cargo-capacity-management)
  - [Item Categories and Compatibility](#item-categories-and-compatibility)
  - [Energy Pool and Resource Management](#energy-pool-and-resource-management)
  - [Loadout Validation and Optimization](#loadout-validation-and-optimization)
- [Examples](#examples)
  - [Weapon Examples](#weapon-examples)
    - [Light Laser](#light-laser)
    - [Light Laser Battery](#light-laser-battery)
    - [Laser Cannon](#laser-cannon)
    - [Auto Cannon](#auto-cannon)
    - [Small Missile Pod](#small-missile-pod)
  - [Addon Examples](#addon-examples)
    - [Small Radar Array](#small-radar-array)
    - [Advanced Radar](#advanced-radar)
    - [Passive Shield](#passive-shield)
    - [Active Shield Generator](#active-shield-generator)
    - [Fuel Tank](#fuel-tank)
    - [Lightweight Frame](#lightweight-frame)
  - [Loadout Examples](#loadout-examples)
    - [Small Interceptor "Dogfighter"](#small-interceptor-"dogfighter")
    - [Light Bomber "Strike Craft"](#light-bomber-"strike-craft")
    - [Heavy Bomber "Assault Platform"](#heavy-bomber-"assault-platform")
    - [Transport "Utility Carrier"](#transport-"utility-carrier")
    - [Scout "Reconnaissance"](#scout-"reconnaissance")
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft inventory system transforms equipment choices into strategic trade-offs through discrete slot limitations, cargo capacity constraints, and unit capacity restrictions. Each craft has limited weapon and addon slots, a total cargo capacity for mounted equipment, and a unit capacity for personnel transport based on size classifications. This creates meaningful decisions between firepower, utility capabilities, crew size, and operational flexibility. The shared energy pool ensures tactical resource management during combat, while deterministic validation maintains consistent, reproducible behavior across all game systems.

The system supports extensive modding through data-driven item definitions and compatibility rules, enabling players to specialize craft for different roles while maintaining balanced strategic depth. Equipment choices affect both tactical combat performance and strategic operational capabilities.

## Mechanics

### Slot-Based Mounting System

Craft have discrete mounting points for different equipment types:

- Weapon Slots: Dedicated mounting points for offensive systems (1-2 slots typical)
- Addon Slots: Specialized slots for support and utility systems (0-1 slots typical)
- Slot Availability: Must have free slot of correct type to mount item
- Role Specialization: Slot counts define craft roles (interceptor vs bomber vs transport)
- Disabled Slots: Some craft may have certain slot types disabled based on chassis

### Cargo Capacity Management

Numeric capacity system enables flexible equipment combinations:

- Total Capacity: Craft-wide cargo limit varying by craft size and class
- Item Size: Each item consumes cargo space (positive or negative values)
- Capacity Validation: Total item sizes cannot exceed craft capacity
- Negative Size Items: Special items (lightweight frames) that increase available capacity
- Remaining Capacity: Determines what additional items can be mounted

### Unit Capacity Management

Personnel transport capacity based on unit size classifications:

- Unit Size Classes: Personnel classified as size 1, 2, or 4 based on equipment and type
- Total Capacity: Craft-wide unit limit varying by craft size and class
- Capacity Validation: Sum of unit sizes cannot exceed craft unit capacity
- Size Examples: Standard soldier (size 1), heavy trooper (size 2), mech suit (size 4)
- Transport Limits: Determines maximum personnel that can be deployed

### Item Categories and Compatibility

Equipment organized by function with tag-based compatibility system:

- Weapons: Offensive systems for combat (energy, ballistic, missile, bomb systems)
- Addons: Support and utility systems (sensors, defense, utility, modifications)
- Compatibility Tags: Required and banned tags for logical equipment combinations
- Family Restrictions: Item families with special rules and upgrade paths
- Chassis Limitations: Certain items restricted to specific craft types

### Energy Pool and Resource Management

Shared resource system for battle systems:

- Energy Pool: Craft-wide energy capacity for all mounted items
- Per-Use Costs: Energy consumed each time item is activated
- Pool Depletion: Items unavailable when energy insufficient
- Recharge Mechanics: Energy recovery between encounters
- Resource Balancing: Energy costs create tactical decision-making

### Loadout Validation and Optimization

Comprehensive validation ensures viable equipment combinations:

- Slot Matching: Item must fit available slot type
- Capacity Check: Item size must fit within remaining cargo
- Compatibility Validation: All tag requirements must be satisfied
- Energy Impact Assessment: Resulting energy pool remains viable
- Optimization Feedback: Clear guidance for loadout improvements

## Examples

### Weapon Examples

#### Light Laser
- Size: 2 cargo units, Slot: Weapon
- Resource Cost: 1 AP, 4 energy per shot, 0 cooldown
- Damage: 10 energy damage
- Description: Fast-firing interceptor weapon

#### Light Laser Battery
- Size: 3 cargo units, Slot: Weapon
- Resource Cost: 1 AP, 6 energy per shot, 0 cooldown
- Damage: 15 energy damage
- Description: Enhanced single laser with higher power

#### Laser Cannon
- Size: 6 cargo units, Slot: Weapon
- Resource Cost: 2 AP, 12 energy per shot, 0 cooldown
- Damage: 30 energy damage
- Description: Heavy energy cannon for medium craft

#### Auto Cannon
- Size: 4 cargo units, Slot: Weapon
- Resource Cost: 1 AP, 8 energy per burst, 1 turn cooldown
- Damage: 25 ballistic damage
- Description: Ballistic burst weapon with cooldown

#### Small Missile Pod
- Size: 5 cargo units, Slot: Weapon
- Resource Cost: 2 AP, 6 energy per launch, 0 cooldown
- Damage: 40 explosive damage
- Description: Light ordnance system

### Addon Examples

#### Small Radar Array
- Size: 1 cargo unit, Slot: Addon
- Effect: +15% detection range (passive)
- Description: Basic detection enhancement

#### Advanced Radar
- Size: 3 cargo units, Slot: Addon
- Effect: +25% detection range, +10% accuracy (passive)
- Description: Enhanced detection and targeting

#### Passive Shield
- Size: 4 cargo units, Slot: Addon
- Effect: 20% damage reduction (passive)
- Description: Always-active damage mitigation

#### Active Shield Generator
- Size: 6 cargo units, Slot: Addon
- Effect: Absorb 50 damage (5 energy/turn when active)
- Activation: 1 AP to activate
- Description: Activated damage absorption system

#### Fuel Tank
- Size: 4 cargo units, Slot: Addon
- Effect: +50% fuel capacity (geoscape)
- Description: Increases strategic fuel reserves

#### Lightweight Frame
- Size: -3 cargo units, Slot: Addon
- Effect: Increases available cargo capacity
- Description: Structural modification for more equipment

### Loadout Examples

#### Small Interceptor "Dogfighter"
- Slots: 2 weapon, 1 addon, Cargo: 5 capacity
- Equipment: Light Laser (2) + Light Laser (2) + Small Radar (1)
- Total Cargo: 5/5 used, Energy Pool: 80/100 remaining
- Role: Close-range dogfighting with enhanced detection

#### Light Bomber "Strike Craft"
- Slots: 1 weapon, 1 addon, Cargo: 20 capacity
- Equipment: Bomb Bay (16) + Fuel Tank (4)
- Total Cargo: 20/20 used, Energy Pool: 60/100 remaining
- Role: Precision strike missions with extended range

#### Heavy Bomber "Assault Platform"
- Slots: 1 weapon, 1 addon, Cargo: 30 capacity
- Equipment: Large Missile Pod (12) + Laser Battery (10) + Passive Shield (4)
- Total Cargo: 26/30 used, Energy Pool: 40/100 remaining
- Role: Heavy assault operations with protection

#### Transport "Utility Carrier"
- Slots: 1 weapon, 0 addon, Cargo: 20 capacity
- Equipment: Heavy Cannon (10) + Cargo Rack (6)
- Total Cargo: 16/20 used, Energy Pool: 70/100 remaining
- Role: Transport with defensive capability

#### Scout "Reconnaissance"
- Slots: 0 weapon, 1 addon, Cargo: 6 capacity
- Equipment: Advanced Radar (3) + Lightweight Frame (-3)
- Total Cargo: 0/6 used (net gain), Energy Pool: 95/100 remaining
- Role: Detection and surveillance specialist

## Related Wiki Pages

- [Items.md](Items.md) - Craft equipment and weapons
- [Encumbrance.md](Encumbrance.md) - Weight and capacity systems
- [Stats.md](Stats.md) - Performance impacts of loadouts
- [Energy.md](Energy.md) - Energy consumption of equipment
- [Classes.md](Classes.md) - Craft class slot configurations
- [Inventory.md](../units/Inventory.md) - Unit inventory systems comparison
- [Crafts.md](../crafts/Crafts.md) - Main craft systems overview
- [Manufacturing.md](../economy/Manufacturing.md) - Equipment production

## References to Existing Games and Mechanics

- **XCOM Series**: Craft equipment and loadout systems
- **Civilization Series**: Unit equipment and capacity limits
- **Europa Universalis**: Ship equipment and capacity systems
- **Crusader Kings**: Equipment and inventory management
- **Hearts of Iron**: Naval and air equipment loadouts
- **Victoria Series**: Military equipment and capacity
- **Stellaris**: Ship component and capacity systems
- **Endless Space**: Fleet equipment and loadout management
- **Galactic Civilizations**: Ship equipment and capacity limits
- **Total War Series**: Unit equipment and capacity systems

