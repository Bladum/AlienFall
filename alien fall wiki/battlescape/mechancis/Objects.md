# Objects

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Object Types](#object-types)
  - [Placement and Duration](#placement-and-duration)
  - [Object Effects](#object-effects)
  - [Interaction and Removal](#interaction-and-removal)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [Grenade Deployment](#grenade-deployment)
  - [Mine Field Tactics](#mine-field-tactics)
  - [Body Positioning](#body-positioning)
  - [Throwable Object Usage](#throwable-object-usage)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Objects are temporary elements placed on battle tiles during combat that persist for the duration of the mission. These are items deployed by units that occupy single tiles and provide tactical effects such as area denial, environmental hazards, or strategic positioning advantages. Objects create dynamic battlefield conditions that affect movement, visibility, and combat outcomes while maintaining deterministic behavior through seeded random generation and complete provenance logging.

## Mechanics

### Object Types
Objects are categorized by their deployment method and primary function.

**Deployment Objects:**
- **Grenades**: Explosive devices that detonate after placement, creating damage zones
- **Mines**: Hidden traps that trigger on proximity or contact
- **Throwable Items**: Non-explosive objects like caltrops or flares thrown onto tiles

**Environmental Objects:**
- **Bodies**: Fallen unit remains that may block movement or provide cover
- **Debris**: Scattered remains from destroyed terrain or equipment
- **Hazard Markers**: Visual indicators of dangerous areas

### Placement and Duration
Objects exist only during the active battle mission.

**Placement Rules:**
- Single Tile Occupation: Each object occupies exactly one battle tile
- Unit Deployment: Objects placed by unit actions during combat
- Position Validation: Cannot place on occupied tiles or invalid terrain
- Instant Activation: Most objects become active immediately upon placement

**Duration Management:**
- Mission-Scoped: Objects persist until mission end or explicit removal
- No Carryover: Objects do not transfer between missions
- State Persistence: Object effects maintain throughout mission duration
- Cleanup Handling: Automatic removal at mission conclusion

### Object Effects
Objects provide tactical gameplay effects on their occupied tiles.

**Tile Effects:**
- **Movement Blocking**: Bodies and debris prevent tile traversal
- **Visibility Modification**: Smoke-generating objects reduce line of sight
- **Damage Zones**: Explosive objects create hazardous areas
- **Cover Provision**: Some objects provide defensive positioning

**Trigger Effects:**
- **Proximity Activation**: Mines trigger when units enter adjacent tiles
- **Contact Effects**: Objects that activate on direct tile occupation
- **Timed Detonation**: Grenades with configurable fuse delays
- **Environmental Impact**: Objects that alter tile properties

### Interaction and Removal
Objects can be manipulated or eliminated during combat.

**Removal Methods:**
- **Explosion**: Mines and grenades destroy themselves on activation
- **Manual Clearance**: Units can spend actions to remove objects
- **Environmental Effects**: Fire or other hazards may destroy objects
- **Mission End**: Automatic cleanup when battle concludes

**Interaction Rules:**
- **Detection**: Some objects are hidden until discovered
- **Disarmament**: Skilled units can safely remove dangerous objects
- **Utilization**: Certain objects can be repurposed by enemy units
- **Chain Reactions**: Object removal may trigger secondary effects

### Determinism and Provenance
All object behaviors use seeded random generation for reproducible outcomes.

**Deterministic Elements:**
- Placement Success: Seeded rolls for object deployment accuracy
- Trigger Timing: Predictable activation delays and conditions
- Effect Resolution: Consistent damage and area calculations
- Discovery Rolls: Deterministic detection of hidden objects

**Provenance Tracking:**
- Deployment Logging: Complete record of object placement and conditions
- Trigger History: Detailed log of activation events and outcomes
- Effect Documentation: All tile modifications and unit impacts recorded
- State Transitions: Object lifecycle changes fully traceable

## Examples

### Grenade Deployment
Unit throws grenade onto target tile, object appears with 2-turn fuse. On activation, creates 3x3 damage zone with 50% damage falloff. Adjacent units take full damage, corner units take reduced damage. Provenance logs exact damage calculations and unit positioning.

### Mine Field Tactics
Engineer unit places proximity mine on strategic chokepoint. Mine remains hidden until enemy unit enters adjacent tile, then detonates for 80 damage. Detection rolls use seeded RNG, with scout class having +20% discovery chance. Mine persists until triggered or manually cleared.

### Body Positioning
Fallen unit creates body object that blocks movement through its tile. Adjacent tiles gain +10% cover bonus from low wall effect. Body can be dragged by friendly units (2 AP cost) to create impromptu barricades. Body remains until mission end or battlefield cleanup.

### Throwable Object Usage
Unit throws flare onto dark tile, creating light source that increases visibility radius by 3 tiles for 5 turns. Throwable caltrops create hazardous tile that damages (10 HP) and slows (1 AP penalty) units attempting to move through. All effects use deterministic timing and seeded random modifiers.

## Data Structure

```toml
[object]
id = "frag_grenade"
name = "Fragmentation Grenade"
category = "explosive"

[object.properties]
size = { width = 1, height = 1 }
blocking = false
destructible = false
flammable = false
interactive = false

[object.combat]
damage_type = "area"
damage_power = 60
damage_dropoff = 15
max_radius = 3
fuse_turns = 2

[object.visual]
sprite = "objects/grenade.png"
detonation_effect = "explosion_large.png"
animation_states = ["armed", "detonating"]

[object.effects]
detonation = ["area_damage", "create_debris"]
placement = ["play_sound_arm"]
special = []

[object.metadata]
rarity = "common"
value = 25
material = "metal"
```

## Related Wiki Pages

- [Throwing.md](./Throwing.md) - Object deployment mechanics
- [Line of sight.md](./Line%20of%20sight.md) - Visibility effects from objects
- [Movement.md](../battlescape/Movement.md) - Tile occupation and blocking
- [Terrain damage.md](./Terrain%20damage.md) - Object creation from destruction
- [Smoke & Fire.md](./Smoke%20&%20Fire.md) - Environmental object effects

## References to Existing Games and Mechanics

- X-COM series: Grenade and mine placement with area effects
- Jagged Alliance series: Throwable object and trap mechanics
- Commandos series: Environmental object interaction
- Rainbow Six Siege: Throwable gadget deployment
- Counter-Strike: Grenade and flashbang positioning
- Fire Emblem series: Terrain object and hazard placement