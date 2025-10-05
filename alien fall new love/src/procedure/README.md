# Procedural Generation System

This folder contains the procedural content generation system for Alien Fall, providing dynamic mission creation, map generation, unit spawning, item creation, and event handling.

## Overview

The procedural generation system uses seeded random number generation to create consistent, replayable content while maintaining variety. All generators follow the same architectural patterns and use the shared random number generator for deterministic results.

## Core Components

### ProcGen.lua
Main coordinator class that manages all procedural generation subsystems.

**Key Features:**
- Unified interface for generating complete missions
- Seeded random number generation for consistency
- Integration of all generation subsystems

**Usage:**
```lua
local ProcGen = require('procedure.ProcGen')
local generator = ProcGen(seed)
local mission = generator:generateMission('assault', 3)
```

### MissionGenerator.lua
Generates complete mission structures with objectives, rewards, and parameters.

**Mission Types:**
- `recon` - Intelligence gathering missions
- `assault` - Direct combat operations
- `rescue` - Personnel extraction
- `defend` - Defensive operations
- `sabotage` - Destruction objectives
- `escort` - Convoy protection
- `hunt` - Target elimination
- `research` - Scientific investigation

**Features:**
- Dynamic objective generation
- Difficulty scaling
- Reward calculation
- Time limits and constraints

### MapGenerator.lua
Creates procedural battlefields with terrain, cover, and strategic elements.

**Map Types:**
- `urban` - City environments with buildings
- `forest` - Woodland areas with trees
- `desert` - Open sandy terrain
- `research` - Laboratory complexes
- `military` - Base and outpost layouts
- `underground` - Cave and tunnel systems

**Features:**
- Terrain generation with noise functions
- Cover object placement
- Objective positioning
- Spawn point generation
- Height mapping for 3D terrain

### UnitGenerator.lua
Creates procedural enemy units with stats, equipment, and abilities.

**Unit Types:**
- `sectoid` - Basic alien infantry
- `muton` - Heavy assault troops
- `floater` - Flying reconnaissance
- `cyberdisc` - Robotic combat units
- `chryssalid` - Biological terror units
- `berserker` - Rage-powered brutes
- `ethereal` - Psi-commanders

**Features:**
- Stat generation with variance
- Equipment assignment
- Trait system
- Difficulty scaling
- Boss unit generation

### ItemGenerator.lua
Generates procedural weapons, armor, and equipment.

**Item Types:**
- Weapons (pistols, rifles, shotguns, snipers, heavy weapons)
- Armor (light, medium, heavy, power armor)
- Grenades (frag, flash, smoke, alien)
- Medkits (basic, advanced, alien)
- Artifacts (research items)

**Features:**
- Tier-based quality scaling
- Modifier system
- Value calculation
- Mission-appropriate item generation

### EventGenerator.lua
Creates dynamic events and encounters during missions.

**Event Types:**
- `enemy_reinforcements` - Additional enemy spawns
- `environmental_hazard` - Area effects and dangers
- `enemy_ambush` - Surprise attacks
- `boss_encounter` - Powerful enemy commanders
- `scientific_discovery` - Research opportunities
- `civilian_rescue` - NPC rescue scenarios
- `equipment_cache` - Item discoveries
- `alien_technology` - Artifact finds

**Features:**
- Trigger-based activation
- Conditional execution
- Effect application
- Dynamic difficulty adjustment

## Technical Details

### Random Number Generation
All generators use a shared `love.math.newRandomGenerator()` instance for:
- Deterministic results with seeds
- Consistent generation across sessions
- Reproducible mission content

### Data Structures
Generated content follows consistent schemas:
- Missions have objectives, rewards, and constraints
- Maps include terrain, cover, and spawn points
- Units have stats, equipment, and traits
- Items have properties, modifiers, and values
- Events have triggers, conditions, and effects

### Integration Points
The system integrates with existing game systems:
- Mission system for objective tracking
- Map system for terrain rendering
- Unit system for character management
- Item system for equipment handling
- Event system for dynamic encounters

## Usage Examples

### Generate a Random Mission
```lua
local procGen = ProcGen(12345)  -- Seeded for consistency
local mission = procGen:generateMission('random', 3)
print("Generated mission:", mission.title)
```

### Create a Custom Encounter
```lua
local encounter = procGen:generateEncounter({
    difficulty = 4,
    location = 'forest',
    playerLevel = 2
})
```

### Generate Mission Rewards
```lua
local rewards = procGen.itemGen:generateRewards(5)
for _, item in ipairs(rewards) do
    print("Reward:", item.name, "Value:", item.value)
end
```

## Future Enhancements

- **Biome System**: More sophisticated terrain generation
- **Faction Balance**: Dynamic unit composition based on player progress
- **Narrative Integration**: Story-driven procedural elements
- **Mod Support**: Extensible generation templates
- **Performance Optimization**: Chunk-based generation for large maps
- **Quality Assurance**: Generation validation and balancing tools