# Inventory

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Equipment Slots and Categories](#equipment-slots-and-categories)
  - [Carry Capacity and Encumbrance](#carry-capacity-and-encumbrance)
  - [Item Restrictions and Compatibility](#item-restrictions-and-compatibility)
  - [Energy-Based Weapon System](#energy-based-weapon-system)
  - [Consumable Management](#consumable-management)
  - [Persistence and Mission Locking](#persistence-and-mission-locking)
  - [Battlescape Integration](#battlescape-integration)
  - [User Interface and Validation](#user-interface-and-validation)
  - [Determinism and Data-Driven Design](#determinism-and-data-driven-design)
- [Examples](#examples)
  - [Standard Soldier Loadout](#standard-soldier-loadout)
  - [Heavy Weapons Specialist Configuration](#heavy-weapons-specialist-configuration)
  - [Reconnaissance Scout Optimization](#reconnaissance-scout-optimization)
  - [Encumbrance Validation Scenario](#encumbrance-validation-scenario)
  - [Energy Depletion During Combat](#energy-depletion-during-combat)
  - [Class Restriction Violation](#class-restriction-violation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Inventory system manages the equipment carried by units in Alien Fall, determining what items can be equipped, how they are organized, and what gameplay effects they provide. It balances strategic depth with accessibility by implementing limited equipment slots and capacity constraints while enabling meaningful loadout decisions. Equipment integrates with the unit's energy system for weapon usage rather than traditional ammunition stacks, and inventory state persists across missions with deterministic validation and complete provenance tracking for all equipment changes and consumption events.

The system enforces realistic logistical constraints through weight and volume limits, forcing players to make tradeoffs between firepower, protection, and mobility. Equipment compatibility is strictly validated based on unit class, race, traits, and available facilities, with clear failure messages guiding players toward valid loadouts. All mechanics are data-driven and deterministic, ensuring reproducible outcomes for mission planning, combat effectiveness, and strategic resource management.

## Mechanics
### Equipment Slots and Categories
Units have defined equipment positions including primary and secondary weapon slots, a single armor slot, and a backpack for consumables and utility items. Some advanced units may have specialized slots for implants or augmentations. Items are categorized by type (weapons, armor, consumables, utilities) and must fit appropriate slots, with weapons limited to two total to prevent overwhelming firepower combinations.

### Carry Capacity and Encumbrance
Carrying capacity is determined by unit strength, typically ranging from 6 to 12 for human units. Total equipment weight must not exceed this capacity, or the items cannot be equipped. Traits, transformations, or special armor may modify carrying capacity. The system uses a simple binary validation: loadouts either fit within capacity limits or are rejected entirely, with no penalties for partial overloads.

### Item Restrictions and Compatibility
Equipment may have requirements or bans based on unit class, race, traits, or manufacturing facilities. Validation occurs during loadout changes, returning specific failure codes like slot incompatibility, insufficient capacity, missing prerequisites, or banned characteristics. This ensures equipment feels specialized and prevents inappropriate combinations while providing clear feedback for resolution.

### Energy-Based Weapon System
Rather than individual ammunition stacks, all weapons consume from the unit's shared energy pool. Each weapon defines an energy cost per shot, with burst modes multiplying consumption. Weapons become unusable when energy depletes, creating strategic decisions about firing rate versus sustainability. Energy pools recharge fully after missions according to campaign rules.

### Consumable Management
Single-use items like medkits and grenades are tracked individually or in stacks, consumed upon use to provide immediate effects. These remain separate from energy-based weapons, allowing for traditional consumable gameplay alongside the streamlined energy system.

### Persistence and Mission Locking
Unit inventories persist across the campaign unless items are consumed, destroyed, or transferred. Major equipment changes are restricted to pre-mission preparation, with loadouts locked upon deployment confirmation. This prevents mid-mission micromanagement while maintaining strategic depth in equipment planning.

### Battlescape Integration
During missions, equipped items determine available actions and abilities. Weapon usage consumes energy in real-time, consumables can be deployed tactically, and equipment provides ongoing bonuses. Post-mission processing updates inventory based on consumption, damage, and acquired loot, with all changes recorded for provenance and replay compatibility.

### User Interface and Validation
The loadout interface displays slot usage, capacity indicators, projected penalties, and compatibility status. Pre-mission validation prevents deployment with invalid configurations, showing detailed error messages and suggestions. In-mission displays show energy availability and remaining consumables, with immediate feedback on equipment effects.

### Determinism and Data-Driven Design
All parameters (weights, energy costs, capacity limits, penalty thresholds) are defined in external configuration files. Any random elements use seeded streams for reproducibility, and complete audit trails track all inventory changes for debugging, modding, and balance analysis.

## Examples
### Standard Soldier Loadout
A basic soldier equips an assault rifle (weight: 3, energy/shot: 6), pistol (weight: 1, energy/shot: 4), body armor (weight: 2), and backpack containing a medkit and two grenades. Total load is 8/10 capacity (80% utilization), allowing full effectiveness with no penalties in strict mode.

### Heavy Weapons Specialist Configuration
A heavy specialist carries a machine gun (weight: 5, energy/shot: 12), combat knife (weight: 0.5), heavy armor (weight: 4), and an energy canister in their backpack. With class capacity bonuses, they reach 11.5/14 capacity (82% utilization), maintaining effectiveness despite the heavy load.

### Reconnaissance Scout Optimization
A scout uses a sniper rifle (weight: 3), submachine gun (weight: 2), light armor (weight: 1), and backpack with binoculars and three medkits. At 8/8 capacity (100% utilization), they maximize capability within their reduced carrying limits, requiring careful equipment selection.

### Encumbrance Validation Scenario
A unit attempting to equip gear totaling 11 weight units with only 10 strength capacity receives a validation error: "Overweight - cannot equip". The system highlights the problematic items and suggests lighter alternatives, preventing deployment until the loadout fits within capacity limits.

### Energy Depletion During Combat
A soldier with 80/100 energy firing an assault rifle can manage approximately 13 shots before depletion. When energy reaches zero, all weapons become unavailable, requiring either waiting for regeneration, using energy-restoring consumables, or retreating to end the mission.

### Class Restriction Violation
Attempting to equip a psionic amplifier on a standard soldier fails validation with "Psychic class required" message, guiding players toward appropriate unit types for specialized equipment.

## Related Wiki Pages

- [Items.md](../items/Items.md) - Item definitions and equipment properties
- [Item Usage.md](../units/Item%20Usage.md) - Item usage and consumption mechanics
- [Encumbrance.md](../units/Encumbrance.md) - Carry capacity and weight limits
- [Energy.md](../units/Energy.md) - Energy-based weapon systems
- [Classes.md](../units/Classes.md) - Class-specific equipment restrictions
- [Mission preparation.md](../battlescape/Mission%20preparation.md) - Loadout setup and validation
- [Transfers.md](../economy/Transfers.md) - Item transfer and logistics
- [Crafts.md](../crafts/Crafts.md) - Craft inventory and cargo systems
- [Economy.md](../economy/Economy.md) - Manufacturing and economic integration
- [Units.md](../units/Units.md) - Unit equipment and loadout management

## References to Existing Games and Mechanics

- **X-COM Series**: Equipment loadouts and inventory management
- **Fire Emblem Series**: Inventory management and equipment slots
- **Final Fantasy Tactics**: Equipment and item inventory system
- **Advance Wars**: Unit inventory and equipment management
- **Tactics Ogre**: Equipment system and inventory management
- **Disgaea Series**: Item management and equipment systems
- **Persona Series**: Inventory system and item management
- **Mass Effect Series**: Equipment and inventory management
- **Dragon Age Series**: Inventory and equipment systems
- **Fallout Series**: Inventory management and equipment slots

