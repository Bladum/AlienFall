# Craft Items

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Hardpoint System](#hardpoint-system)
  - [Capacity Management](#capacity-management)
  - [Item Categories](#item-categories)
  - [Slot Constraints](#slot-constraints)
  - [Compatibility Rules](#compatibility-rules)
- [Examples](#examples)
  - [Interceptor Loadouts](#interceptor-loadouts)
  - [Bomber Loadouts](#bomber-loadouts)
  - [Recon Loadouts](#recon-loadouts)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Craft Items system enables modular equipment fitting for spacecraft in Alien Fall, allowing players to customize their fleet for specific tactical roles and mission requirements. Each craft has a limited number of hardpoints and total capacity that constrain which items can be equipped, creating strategic trade-offs between offensive power, defensive capabilities, and operational endurance. Items include weapons for combat, addons for enhanced performance, and utilities for specialized functions, all integrated with the craft's energy pool and action economy.

Craft items have both Action Point (AP) and energy costs, with range mechanics based on 10-point distance calculations, cooldowns between uses, and hit chances modified by craft class. Weapon combinations define craft roles: AIR-to-AIR (interceptors), LAND-to-LAND (artillery), AIR-to-LAND (bombers), and unit capacity (transports).

## Mechanics

### Hardpoint System

Physical mounting points on craft:

- Slot Types: 2 weapon slots + 1 addon slot per craft
- Limited Count: Fixed equipment configuration for all craft classes
- Type Restrictions: Weapons fit weapon slots, addons fit addon slot
- Physical Constraints: Hardpoints represent actual mounting locations
- Standardized Design: All crafts use same slot layout for consistency

### Capacity Management

Overall craft limitations on equipment:

- Total Capacity: Maximum combined item size/weight
- Item Sizing: Each item has capacity cost
- Budget System: Must stay within craft's total capacity
- No Overloading: Hard limits prevent unrealistic configurations
- Balance Tool: Creates trade-offs between item quantity and quality

### Item Categories

Functional classifications of equipment:

- Weapons: Active combat systems for dogfights with AP and energy costs
- Addons: Passive or activatable support systems contributing to energy pool
- Utilities: Specialized equipment for specific roles
- Energy Consumption: All items use craft's battle energy pool
- Cooldown Management: Items have recovery times between uses

### Weapon Mechanics

Detailed combat characteristics for weapon items:

- AP Cost: Action Points consumed per use (crafts have 4 AP per turn)
- Energy Cost: Energy pool consumption for firing
- Range: Travel speed calculation (10-point distance ÷ weapon range = turns to reach)
- Cooldown: Turns weapon is unavailable after use
- Hit Chance: Base accuracy modified by craft class and conditions
- Targeting: AIR-to-AIR, LAND-to-AIR, WATER-to-WATER, etc. combinations
- Craft Roles: Weapon combinations define roles (interceptors, artillery, bombers, transports)

### Slot Constraints

Rules governing item installation:

- Slot Type Matching: Items require specific slot types
- Size Limits: Some slots have size restrictions
- Craft Compatibility: Items may be restricted to certain craft types
- Mutual Exclusions: Some items cannot be equipped together
- Prerequisite Requirements: Advanced items may require other items

### Compatibility Rules

Item interaction and restriction system:

- Craft Type Limits: Items restricted to specific craft classes
- Size Restrictions: Heavy items require appropriate craft
- Dependency Chains: Some items require others to function
- Exclusive Combinations: Conflicting items cannot coexist
- Role Enforcement: Items support specific tactical roles

## Examples

### Interceptor Loadouts

Dogfighter Configuration
- Weapon Slot 1: Fast-firing laser gun
- Weapon Slot 2: Fast-firing laser gun
- Addon Slot: Shield generator
- Role: Close-range dogfighting and interception

Heavy Interceptor
- Weapon Slot 1: Heavy cannon
- Weapon Slot 2: Heavy cannon
- Addon Slot: Extra fuel tank
- Role: Long-range patrol with heavy firepower

### Bomber Loadouts

Strike Bomber
- Weapon Slot 1: Large missile pod
- Weapon Slot 2: Point defense cannon
- Addon Slot: Additional fuel tank
- Role: Heavy strike operations with extended range

Tactical Bomber
- Weapon Slot 1: Precision bombs
- Weapon Slot 2: Precision bombs
- Addon Slot: Radar jammer
- Role: Surgical strikes with electronic warfare support

### Recon Loadouts

Surveillance Craft
- Weapon Slot 1: Advanced radar system
- Weapon Slot 2: Advanced radar system
- Addon Slot: Stealth coating
- Role: Long-range detection with minimal combat capability

Electronic Warfare Craft
- Weapon Slot 1: Radar detection suite
- Weapon Slot 2: Radar detection suite
- Addon Slot: Communications jammer
- Role: Intelligence gathering and signal disruption

## Related Wiki Pages

- [Crafts.md](../crafts/Crafts.md) - Craft systems and vehicle management
- [Items.md](../items/Items.md) - Item definitions and equipment types
- [Energy.md](../units/Energy.md) - Energy systems and power management
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic deployment and mission planning
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission integration and tactical requirements
- [Economy.md](../economy/Economy.md) - Manufacturing and production systems
- [Research tree.md](../economy/Research%20tree.md) - Technology advancement and unlocks
- [AI.md](../ai/AI.md) - AI usage and automated systems
- [Transfers.md](../economy/Transfers.md) - Logistics and equipment transfers
- [Modding.md](../technical/Modding.md) - Customization and mod support

## References to Existing Games and Mechanics

- **X-COM Series**: Craft equipment and loadout systems
- **Homeworld Series**: Ship module and equipment customization
- **StarCraft Series**: Unit upgrade and equipment systems
- **Warhammer 40,000**: Vehicle wargear and equipment options
- **Battlefleet Gothic**: Ship equipment and weapon systems
- **Star Trek Series**: Ship system upgrades and modifications
- **Mass Effect Series**: Ship upgrade and equipment systems
- **Wing Commander Series**: Ship loadout and customization
- **FreeSpace Series**: Ship customization and module systems
- **Elite Dangerous**: Ship module and equipment management

