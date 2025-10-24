# Mission Templates Subsystem

**Purpose:** Defines campaign mission types that players encounter during strategic gameplay

**Layer:** Strategic (Geoscape)

**Parent:** Geoscape

## Contents

This folder contains mission template definitions:
- Mission type definitions with objectives
- Enemy composition templates
- Reward scaling and calculation
- Map generation parameters
- Difficulty and availability rules
- Victory and failure conditions

## Key Components

- **Mission Template:** Core mission definition
- **Objectives:** Primary, secondary, and optional goals
- **Forces:** Enemy composition and difficulty
- **Rewards:** Science, money, artifacts, reputation
- **Map:** Terrain and layout generation

## Dependencies

- Depends on: `geoscape` (campaign), `factions` (enemy types)
- Used by: Campaign mission generation, player decisions

## Architecture Notes

- Each mission type defines structure and rewards
- Difficulty scaling based on campaign progress
- Multiple mission objectives per mission
- Rewards vary by difficulty and performance
- Dynamic mission generation uses these templates

## Available Mission Types

### Current Missions
- `mission_alien_harvesting.toml` - Stop alien abductions
- `mission_ufo_crash_recovery.toml` - Salvage technology

### Future Missions
Additional mission types can be added following the same template format.

## See Also

- `api/MISSIONS.md` - Mission API documentation
- `design/missions/` - Mission design documentation
- `mods/core/factions/` - Faction definitions (enemy types)
