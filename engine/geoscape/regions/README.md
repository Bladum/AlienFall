# Geoscape Regions Subsystem

**Purpose:** Manages world regions, province system, terrain, and geopolitical territories during campaign gameplay.

**Layer:** Strategic (Geoscape)

**Parent:** Geoscape

## Contents

This folder contains region system implementations:
- Region/province definitions
- Terrain and geographic data
- Country and faction territorial control
- Regional population and economy
- Regional events and conflicts

## Key Components

- **Region Manager:** Central region data and queries
- **Territory Control:** Faction control tracking
- **Terrain System:** Geographic features and effects
- **Regional Events:** Region-specific incidents

## Dependencies

- Depends on: `geoscape` (campaign), `economy` (resources)
- Used by: Campaign logic, economy, events

## Architecture Notes

- World divided into regions/provinces
- Each region can be controlled by different factions
- Terrain affects mission difficulty
- Regional events influence campaign

## See Also

- `api/GEOSCAPE.md` - Geoscape API documentation
- `design/world/` - World design documentation
