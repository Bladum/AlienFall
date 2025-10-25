# Portal Systems

## Goal / Purpose

The Portal Systems folder manages interdimensional and spatial portal mechanics in the game. This includes portal generation, detection, interaction, and cross-dimensional entity management.

## Content

- `portal_system.lua` - Main portal management system for creating, tracking, and updating portals

## Features

- **Portal Creation**: Generate portals at strategic locations
- **Dimensional Tracking**: Manage entities across dimensional planes
- **Portal Interactions**: Handle player/unit interactions with portals
- **Cross-Dimensional Mechanics**: Support for alternate dimensions and parallel spaces
- **Event System**: Portal-triggered events and consequences
- **Persistence**: Save/load portal state across sessions

## Integrations with Other Systems

### Geoscape
- Portals appear on the world map as strategic objectives
- Dimensional rifts affect regional stability and politics
- Portal missions are generated and tracked

### Battlescape
- Portals can appear during tactical missions
- Units can move through portals to alternate battlefields
- Dimensional effects impact combat mechanics (e.g., reality distortion)

### Lore & Campaign
- Portals are part of the narrative progression
- Connected to Phase 3-5 campaign events
- Alien faction objectives involve portal control

### Core Systems
- Uses `state_manager` for state transitions
- Integrates with `data_loader` for portal configuration
- Connected to `event_system` for trigger responses

## See Also

- [Geoscape README](../geoscape/README.md) - World map and campaign management
- [Battlescape README](../battlescape/README.md) - Tactical combat system
- [Lore Content](../../lore/README.md) - Campaign and story narrative
