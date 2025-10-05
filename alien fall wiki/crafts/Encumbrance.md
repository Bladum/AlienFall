# Craft Encumbrance System

> **📖 Master Reference:** For a comprehensive overview of capacity systems across all game layers, see [Capacity Systems](../core/Capacity_Systems.md). This document focuses specifically on craft-level cargo and unit capacity in the operational layer.

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Cargo Capacity](#cargo-capacity)
  - [Unit Capacity](#unit-capacity)
  - [Loadout Validation](#loadout-validation)
- [Examples](#examples)
  - [Cargo Capacity Examples](#cargo-capacity-examples)
  - [Unit Capacity Examples](#unit-capacity-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The craft encumbrance system uses the same simple binary restriction approach as unit equipment. Crafts have two separate capacity systems: cargo capacity for items and weapons, and unit capacity for personnel. Any loadout exceeding these capacities cannot be equipped or used, creating strategic tradeoffs without complex penalty systems.

The system maintains clear and predictable gameplay by enforcing hard limits during craft configuration. Cargo capacity determines what equipment can be mounted, while unit capacity determines how many personnel can be transported based on their size classifications.

## Mechanics

### Cargo Capacity

Crafts have a cargo capacity that limits the total weight of mounted items and weapons.

Capacity Types:
- Item Capacity: Total weight limit for weapons, addons, and equipment
- Size-Based: Each craft class has a defined cargo capacity value
- Equipment Weight: All mounted items contribute to total cargo weight
- Validation: Total equipment weight must not exceed cargo capacity

Capacity Examples:
- Small Fighter: 5 cargo capacity units
- Medium Fighter: 8 cargo capacity units
- Heavy Bomber: 15 cargo capacity units
- Transport: 20 cargo capacity units

### Unit Capacity

Crafts have a separate unit capacity that limits personnel transport based on unit size.

Capacity System:
- Unit Size Classes: Units classified as size 1, 2, or 4
- Capacity Tracking: Total unit sizes cannot exceed craft's unit capacity
- Size Examples: Standard soldier (size 1), heavy trooper (size 2), mech (size 4)
- Validation: Sum of unit sizes must not exceed unit capacity limit

Capacity Examples:
- Small Fighter: 2 unit capacity (2 size-1 units or 1 size-2 unit)
- Medium Fighter: 4 unit capacity (4 size-1 units or 1 size-4 unit)
- Heavy Bomber: 8 unit capacity
- Transport: 20 unit capacity

### Loadout Validation

Craft configuration validation occurs during equipment and crew assignment.

Validation Process:
- Cargo Check: Total equipment weight compared to cargo capacity
- Unit Check: Total unit sizes compared to unit capacity
- Binary Result: Configuration either accepted or rejected
- No Penalties: No performance penalties - simply cannot equip overweight loadouts

Validation Features:
- Real-time Feedback: Immediate validation during craft configuration
- Clear Messages: "Over capacity - cannot equip" with breakdown
- Component Highlighting: Problematic items or units clearly marked
- Resolution Guidance: Suggestions for lighter equipment or smaller crews

## Examples

### Cargo Capacity Examples

Equipment validation for craft cargo capacity:

- Small Fighter: Cargo capacity 5 units
- Equipment Load: Light cannon (2), sensor suite (2), armor plating (1)
- Total Weight: 5 units exactly
- Validation Result: Loadout accepted, equipment can be mounted
- UI Feedback: Green checkmark, "Cargo loadout valid"

- Medium Fighter: Cargo capacity 8 units
- Equipment Load: Heavy cannon (4), missile launcher (3), sensor suite (2)
- Total Weight: 9 units (exceeds 8 capacity)
- Validation Result: Loadout rejected, cannot equip or use items
- UI Feedback: Red X, "Over cargo capacity - cannot equip" with weight breakdown

### Unit Capacity Examples

Personnel validation for craft unit capacity:

- Transport Craft: Unit capacity 12
- Crew Load: 8 size-1 soldiers + 2 size-2 heavy troopers
- Total Size: 8×1 + 2×2 = 12 exactly
- Validation Result: Crew assignment accepted
- UI Feedback: "Unit capacity valid"

- Small Fighter: Unit capacity 2
- Crew Load: 1 size-1 pilot + 1 size-2 heavy trooper
- Total Size: 1 + 2 = 3 (exceeds 2 capacity)
- Validation Result: Crew assignment rejected, cannot deploy
- UI Feedback: "Over unit capacity - cannot assign" with size breakdown

## Related Wiki Pages

- [Craft Stats](Stats.md) - Cargo and unit capacity specifications
- **[Capacity Systems (Core)](../core/Capacity_Systems.md)** - Complete capacity system overview across all game layers
- [Unit Encumbrance](../units/Encumbrance.md) - Unit equipment capacity system
- [Craft Items](Items.md) - Equipment weights and component specifications
- [Craft Operations](geoscape/Craft%20Operations.md) - Capacity impacts on mission execution
- [Manufacturing](economy/Manufacturing.md) - Production capacity considerations
- [Transfers](economy/Transfers.md) - Transport capacity and logistics
- [Mission preparation](battlescape/Mission%20preparation.md) - Craft deployment validation
- [Units](units/Units.md) - Unit size classifications for transport
- [Encumbrance](units/Encumbrance.md) - Unit equipment capacity system

## References to Existing Games and Mechanics

- **Dungeons & Dragons**: Character encumbrance and movement penalties
- **Fallout Series**: Carry weight limits and inventory management
- **XCOM Series**: Equipment loadouts and soldier capacity limits
- **Civilization**: Unit capacity limits and upgrade restrictions
- **Master of Orion**: Ship component limits and design constraints
- **Homeworld**: Ship loadout constraints and performance trade-offs
- **Freespace**: Weapon loadout restrictions and ship balancing
- **Wing Commander**: Craft configuration limits and equipment choices
- **Elite**: Ship equipment limits and cargo capacity systems
- **X3: Reunion**: Component weight systems and ship performance

