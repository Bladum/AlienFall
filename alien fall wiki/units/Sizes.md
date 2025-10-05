# Sizes

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Size Categories](#size-categories)
  - [Tile Occupancy and Footprint](#tile-occupancy-and-footprint)
  - [Combat Effects](#combat-effects)
  - [Movement and Navigation](#movement-and-navigation)
  - [Equipment and Interaction Compatibility](#equipment-and-interaction-compatibility)
- [Examples](#examples)
  - [Small Units](#small-units)
  - [Medium Units](#medium-units)
  - [Large Units](#large-units)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Sizes system defines physical dimensions and tactical characteristics of units on the battlefield, determining tile occupancy, combat modifiers, movement capabilities, and equipment interactions. Three categories (Small, Medium, Large) create graduated tactical options with distinct advantages and disadvantages. Small units are harder to hit but occupy minimal space, Medium units provide balanced capabilities, and Large units offer power advantages with increased vulnerability and mobility penalties.

Size affects battlefield footprint with Large units occupying 2×2 contiguous tiles while Small and Medium units use 1×1 spaces. Combat mechanics include accuracy modifiers based on target silhouette and area effect vulnerability scaling with footprint. Movement and placement require collision detection for multi-tile units, with navigation restrictions through narrow passages. All size effects are data-driven and orthogonal to unit type, enabling reliable tuning of tactical interactions.

## Mechanics
### Size Categories
Three distinct categories provide graduated tactical options: Small (compact units with stealth advantages), Medium (standard human-sized units with balanced capabilities), and Large (oversized units with power advantages but mobility penalties). Each category has defining physical attributes including volume, dimensions, movement modifiers, and concealment effects.

### Tile Occupancy and Footprint
Size determines battlefield space requirements with Small and Medium units occupying single 1×1 tiles, while Large units require contiguous 2×2 tile areas. This affects deployment validation, collision detection, and formation planning. Multi-tile units create positioning challenges and tactical bottlenecks.

### Combat Effects
Size influences hit probability in ranged combat, with Small units receiving accuracy penalties for attackers due to reduced silhouette, and Large units receiving accuracy bonuses due to increased profile. Area effects scale with footprint, making Large units more vulnerable to explosions and zone damage. Damage distribution across occupied tiles prevents instant elimination of large units.

### Movement and Navigation
Large units require 2×2 clear areas for movement and cannot traverse narrow passages, vents, or small doorways. Pathfinding and collision checks account for extended footprints, creating environmental strategy. Small and Medium units share identical 1×1 movement rules, differing only in combat modifiers.

### Equipment and Interaction Compatibility
Size restricts available gear and weapons, with Large units potentially accessing heavy equipment unavailable to smaller units. Size affects cargo capacity calculations and formation positioning. All size-based restrictions are data-driven and tunable.

## Examples
### Small Units
Dogs, bats, small drones, and alien critters occupy 1×1 tiles and receive accuracy penalties for attackers due to their compact size and agility, making them harder to hit in ranged combat while maintaining full movement flexibility.

### Medium Units
Human soldiers, typical aliens like Sectoids, and standard infantry occupy 1×1 tiles with baseline targeting characteristics and no special hit modifiers, providing balanced capabilities for most tactical scenarios.

### Large Units
Hulking alien monsters, robotic tanks, and oversized vehicles occupy 2×2 contiguous tiles, receiving accuracy bonuses for attackers due to their prominent silhouette while being more exposed to area-of-effect damage and restricted in narrow terrain.

## Related Wiki Pages

- [Unit actions.md](../battlescape/Unit%20actions.md) - Combat effects and size modifiers
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Size-based accuracy adjustments
- [Battle tile.md](../battlescape/Battle%20tile.md) - Tile occupancy and positioning
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Movement restrictions and navigation
- [Inventory.md](../units/Inventory.md) - Equipment compatibility and restrictions
- [Classes.md](../units/Classes.md) - Size-based class categories
- [Wounds.md](../battlescape/Wounds.md) - Damage scaling and area effects
- [Throwing.md](../battlescape/Throwing.md) - Size interactions and targeting
- [Battle size.md](../battlescape/Battle%20size.md) - Formation and deployment considerations
- [Mission preparation.md](../battlescape/Mission%20preparation.md) - Size-based deployment planning

## References to Existing Games and Mechanics

- **X-COM Series**: Unit sizes and positioning mechanics
- **Fire Emblem Series**: Character size differences and combat
- **Final Fantasy Tactics**: Size-based combat and positioning
- **Advance Wars**: Unit size categories and movement
- **Tactics Ogre**: Size differences and tactical positioning
- **Disgaea Series**: Size scaling and combat mechanics
- **Persona Series**: Size variations in party composition
- **Mass Effect Series**: Size differences in combat encounters
- **Dragon Age Series**: Size categories and positioning
- **Fallout Series**: Size-based combat and targeting

