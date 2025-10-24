# Core Mod: Map Scripts

## Goal / Purpose

The Mapscripts folder contains mission template scripts that define how tactical battlescape maps are generated for specific mission types. Mapscripts control map composition, difficulty scaling, and mission-specific rules.

## Content

- Mapscript configuration files (.toml)
- Mission template definitions
- Map composition rules
- Difficulty scaling parameters
- Enemy placement and behavior
- Objective definitions

## Features

- **Mission Templates**: Pre-defined mission types (patrol, terror, defense, etc.)
- **Map Composition**: Rules for combining mapblocks
- **Difficulty Scaling**: How missions scale with difficulty
- **Enemy Configuration**: Alien unit types and counts
- **Objective System**: Mission objectives and success conditions
- **Dynamic Variance**: Procedural variation on templates
- **Replayability**: Varied missions from same template

## Integrations with Other Systems

### Mission Generation
- Used by `engine/geoscape/mission_manager.lua`
- Mapscripts selected based on mission type
- Provide template for map generation

### Map Generation
- Mapscripts compose mapblocks
- Control tileset selection
- Define spawn and objective placement

### Battlescape
- Map created from mapscript
- Dictates initial unit placement
- Defines mission objectives

### Campaign System
- Mission types progress through campaign
- Difficulty varies by campaign phase
- Availability controlled by narrative

### Procedural Generation
- Procedural variation within template
- Randomized enemy positions
- Variable map composition

### Design Specifications
- Mission types in `design/mechanics/Missions.md`
- Mission design in `design/mechanics/`

## Mission Types

- **Patrol**: Reconnaissance and exploration
- **Terror**: Assault on population centers
- **Crash Recovery**: Downed UFO salvage
- **Base Defense**: Alien assault on player base
- **Interrogation**: Prisoner rescue or extraction
- **Supply**: Resource acquisition
- **Artifact**: Recovery of important items
- **UFO Assault**: Direct alien facility attack

## Creating Mission Templates

1. Define template structure
2. Specify mapblock composition rules
3. Set difficulty parameters
4. Configure enemy placement
5. Define objectives
6. Test scaling across difficulties
7. Document in README

## See Also

- [Core Mod README](../README.md) - Core content overview
- [Mapblocks](../mapblocks/README.md) - Map components
- [Generation Config](../generation/README.md) - Generation system
- [Tilesets](../tilesets/README.md) - Visual assets
- [Missions API](../../api/MISSIONS.md) - Mission system interface
- [Battlescape Design](../../design/mechanics/Battlescape.md) - Tactical design
