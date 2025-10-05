# Unit Encumbrance System

> **📖 Master Reference:** For a comprehensive overview of capacity systems across all game layers, see [Capacity Systems](../core/Capacity_Systems.md). This document focuses specifically on unit-level carrying capacity in tactical combat.

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Item Weight](#item-weight)
  - [Carry Capacity](#carry-capacity)
  - [Equipment Validation](#equipment-validation)
- [Examples](#examples)
  - [Standard Equipment Loadout](#standard-equipment-loadout)
  - [Overweight Loadout](#overweight-loadout)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Encumbrance system in Alien Fall implements a simple binary restriction on equipment loadouts. Units have a carrying capacity determined by their strength attribute, and any item combination exceeding this capacity cannot be equipped or used. This creates strategic tradeoffs between equipment choices without complex penalty systems, maintaining clear and predictable gameplay.

The system uses a hard limit approach where total item weight must not exceed unit strength. For human units, strength typically ranges from 6 to 12, though traits, transformations, or special armor may modify this capacity. All validation occurs during equipment selection, preventing overweight loadouts from being deployed.

## Mechanics

### Item Weight

Every equippable item has a defined weight value that contributes to total encumbrance.

Weight Assignment:
- Numeric Values: Each item declares a specific weight value
- Equipment Categories: Weapons, armor, and gear have appropriate weights
- Bulk Considerations: Weight reflects both mass and physical bulk
- Data-Driven: All weights defined in item data files

Weight Components:
- Base Weight: Fundamental item mass and size
- Ammo Weight: Additional weight for carried ammunition
- Attachment Weight: Modifications and accessories add weight
- Utility Weight: Tools and supplies contribute to total load

### Carry Capacity

Units have a maximum carrying capacity determined by their strength attribute.

Capacity Calculation:
- Strength Basis: Capacity equals unit's Strength stat (typically 6-12 for humans)
- Direct Mapping: 1 Strength = 1 weight unit capacity
- Trait Effects: Certain traits can increase or decrease capacity
- Equipment Bonuses: Special armor or gear may provide capacity bonuses
- Temporary Modifiers: Status effects may alter carrying capacity

Capacity Range:
- Human Units: Strength 6-12 provides 6-12 weight unit capacity
- Modified Units: Traits, transformations, or special equipment can change this
- Validation: Capacity checked against total equipment weight

### Equipment Validation

Loadout validation occurs during equipment selection to enforce capacity limits.

Validation Process:
- Weight Summation: Total weight of all equipped items calculated
- Capacity Comparison: Total weight checked against unit strength
- Binary Result: Loadout either accepted or rejected based on weight limit
- No Penalties: No movement, AP, or other penalties - simply cannot equip overweight items

Validation Features:
- Real-time Feedback: Immediate validation during equipment changes
- Clear Messages: "Overweight - cannot equip" with weight breakdown
- Item Highlighting: Offending items clearly marked in inventory
- Resolution Guidance: Suggestions for lighter equipment alternatives

## Examples

### Standard Equipment Loadout

Basic equipment validation for acceptable loadouts:

- Soldier Profile: Strength 10, carry capacity 10 weight units
- Equipment Load: Assault rifle (3), body armor (4), medikit (1), grenades (2)
- Total Weight: 10 weight units exactly
- Validation Result: Loadout accepted, equipment can be used
- UI Feedback: Green checkmark, "Loadout valid" message

### Overweight Loadout

Equipment rejection for excessive weight:

- Soldier Profile: Strength 8, carry capacity 8 weight units
- Equipment Load: Assault rifle (3), heavy armor (4), medikit (1), extra ammo (2)
- Total Weight: 10 weight units (exceeds 8 capacity)
- Validation Result: Loadout rejected, cannot equip or use items
- UI Feedback: Red X, "Overweight - cannot equip" with weight breakdown
- Resolution: Must remove items or choose lighter alternatives

## Related Wiki Pages

- [Inventory.md](../units/Inventory.md) - Item storage and management systems
- [Item Usage.md](../units/Item%20Usage.md) - Equipment usage and restrictions
- **[Capacity Systems (Core)](../core/Capacity_Systems.md)** - Complete capacity system overview across all game layers
- [Craft Encumbrance](../crafts/Encumbrance.md) - Craft cargo and unit capacity mechanics
- [Units.md](../units/Units.md) - Unit statistics and equipment loadouts
- [Classes.md](../units/Classes.md) - Class-specific equipment and restrictions
- [Mission preparation.md](../battlescape/Mission%20preparation.md) - Pre-mission equipment validation
- [Transfers.md](../economy/Transfers.md) - Item transfer and logistics
- [Items.md](../items/Items.md) - Item properties and weight definitions
- [Ranks.md](../units/Ranks.md) - Rank-based equipment allowances
- [Promotion.md](../units/Promotion.md) - Equipment progression and unlocks

## References to Existing Games and Mechanics

- **Baldur's Gate Series**: Inventory weight limits and movement penalties
- **Fallout Series**: Carry weight system with strength-based capacity
- **The Elder Scrolls Series**: Encumbrance affecting movement and fatigue
- **Pathfinder**: Bulk system for equipment and inventory management
- **Dungeons & Dragons**: Carrying capacity rules and strength modifiers
- **Mount & Blade Series**: Inventory management and equipment restrictions
- **Kingdom Come: Deliverance**: Realistic weight system for equipment
- **The Witcher 3**: Inventory weight affecting combat mobility
- **Dragon Age Series**: Equipment weight and inventory capacity
- **Pillars of Eternity**: Encumbrance system with recovery mechanics

