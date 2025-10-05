# Unit (Battlescape Context)

## Table of Contents

- [Overview](#overview)
- [Core Properties](#core-properties)
- [Unit Categories](#unit-categories)
- [Unit Systems](#unit-systems)
- [Data Structure](#data-structure)
- [Related Concepts](#related-concepts)

## Overview

In the battlescape context, a unit is a selectable entity that occupies a single battle tile and participates in tactical combat. Units represent individual soldiers, vehicles, or other combatants that players control or fight against during missions.

## Core Properties

### Physical Presence
Units exist as tangible entities within the battle grid.

**Tile Occupation:**
- **Single Tile**: Each unit occupies exactly one battle tile
- **Exclusive Space**: No tile-sharing between units
- **Position Tracking**: Precise (x,y) coordinates on battle grid
- **Movement**: Units can change tiles through movement actions

### Combat Participation
Units are the primary actors in tactical combat.

**Action Types:**
- **Movement**: Changing position on the battlefield
- **Attacks**: Ranged and melee combat actions
- **Abilities**: Special skills and unit-specific actions
- **Interaction**: Using objects, opening doors, etc.

### Visual Representation
Units have distinct visual identities on the battlefield.

**Appearance:**
- **Sprites**: Animated character graphics
- **Facing**: Directional orientation (north, south, east, west)
- **Status Effects**: Visual indicators for health, morale, etc.
- **Equipment**: Visible weapons and armor

## Unit Categories

### Player Units
Units under direct player control during missions.

**Control Types:**
- **Squad Members**: Core team members with unique abilities
- **Reinforcements**: Additional units arriving during battle
- **Allied Forces**: Supporting units from other factions
- **Specialists**: Units with unique roles and capabilities

### Enemy Units
Opposing forces that AI controls during combat.

**AI Behavior:**
- **Tactical AI**: Decision-making based on unit type and situation
- **Group Coordination**: Units working together as squads
- **Dynamic Response**: Adapting to player actions and tactics
- **Morale Systems**: Panic, berserk, and surrender states

### Neutral Units
Non-combatant entities that may affect battlefield dynamics.

**Types:**
- **Civilians**: Non-combatants that may need protection
- **Wildlife**: Animals that can become threats or distractions
- **Robots**: Automated systems with predictable behavior
- **Special Entities**: Unique units with specific mission roles

## Unit Systems

### Health and Status
Tracking unit condition throughout combat.

**Vital Statistics:**
- **Health Points**: Physical damage tracking
- **Morale**: Psychological state affecting performance
- **Stamina**: Action point availability
- **Status Effects**: Temporary conditions (poisoned, stunned, etc.)

### Equipment and Inventory
Items and gear that units carry and use.

**Equipment Types:**
- **Weapons**: Primary combat tools
- **Armor**: Protective gear
- **Utilities**: Grenades, medkits, tools
- **Special Items**: Mission-specific equipment

### Progression and Development
How units improve and change over time.

**Growth Systems:**
- **Experience**: Learning from combat encounters
- **Promotion**: Advancing through rank structures
- **Equipment Upgrades**: Better gear and capabilities
- **Specialization**: Developing unique abilities

## Data Structure

```toml
[unit]
id = "soldier_001"
name = "Rookie Soldier"
faction = "player"
class = "rifleman"

[unit.position]
x = 25
y = 15
facing = "north"
elevation = 0

[unit.stats]
health = { current = 100, max = 100 }
morale = 85
action_points = { current = 10, max = 10 }
experience = 150

[unit.equipment]
primary_weapon = "assault_rifle"
armor = "basic_armor"
inventory = ["medkit", "grenade"]

[unit.abilities]
movement_range = 6
accuracy = 65
damage_output = 45
special_skills = ["overwatch", "first_aid"]

[unit.metadata]
portrait = "soldier_portrait_01"
voice_set = "male_soldier_01"
rank = "rookie"
kills = 3
missions = 5
```

## Related Concepts
- [Spawn Point](Spawn Point.md) - Initial unit placement
- [Unit Distribution](Unit Distribution.md) - Battlefield placement process
- [Battle Tile](Battle tile.md) - Spaces units occupy
- [Action System](ActionSystem.md) - Unit capabilities and actions