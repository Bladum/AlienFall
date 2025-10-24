# Geoscape Missions Subsystem

**Purpose:** Manages mission template definitions, generation, and campaign event missions for strategic gameplay.

**Layer:** Strategic (Geoscape)

**Parent:** Geoscape

## Contents

This folder contains mission system implementations:
- Mission template definitions
- Campaign mission generation logic
- Mission objectives and parameters
- Mission rewards and failure conditions
- Mission difficulty scaling

## Key Components

- **Mission Generator:** Creates missions from templates
- **Mission Templates:** Pre-defined mission types
- **Objectives:** Mission goal definitions
- **Rewards:** Mission completion rewards

## Dependencies

- Depends on: `geoscape` (campaign), `content` (data)
- Used by: Campaign events, player decisions

## Architecture Notes

- Missions are generated from templates with randomization
- Difficulty scaling based on campaign progression
- Multiple mission objectives per mission
- Rewards vary by difficulty and performance

## See Also

- `api/MISSIONS.md` - Mission API documentation
- `design/missions/` - Mission design documentation
