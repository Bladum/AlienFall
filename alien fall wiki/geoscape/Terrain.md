# Terrain

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Map Blocks Framework](#map-blocks-framework)
  - [Map Scripts Architecture](#map-scripts-architecture)
  - [Common Script Patterns](#common-script-patterns)
  - [Special Mission Sources and Overrides](#special-mission-sources-and-overrides)
  - [Biome-Terrain Selection and Determinism](#biome-terrain-selection-and-determinism)
  - [Validation and Constraints](#validation-and-constraints)
- [Examples](#examples)
  - [Map Blocks Configurations](#map-blocks-configurations)
  - [Map Scripts Applications](#map-scripts-applications)
  - [Script Pattern Implementations](#script-pattern-implementations)
  - [Special Mission Overrides](#special-mission-overrides)
  - [Biome-Terrain Selection Cases](#biome-terrain-selection-cases)
  - [Validation and Constraint Examples](#validation-and-constraint-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Terrain system defines tactical battlefield generation specifications that are randomly selected from a biome's weighted list during mission creation. Each terrain specifies the pool of map blocks available for battlefield construction, the map script that assembles those blocks into a coherent battlefield, and environmental effects like day/night cycles and weather conditions. Terrains may be forced to specific values for special missions (e.g., base defense missions use the player's base layout as terrain).

From a design perspective, Terrain serves as the complete specification for how a battlefield is generated and what environmental conditions apply during combat. It bridges the strategic biome system with the tactical battlescape by providing all necessary data for map generation and environmental setup.

## Mechanics

### Terrain Selection

Terrain is selected during mission generation through deterministic process:

- **Random Selection from Biome**: When a mission is generated in a province, the system randomly selects a terrain from the province's biome terrain list using the configured weights
- **Deterministic Seeding**: Selection uses mission seed ensuring reproducible battlefield generation
- **Mission Overrides**: Special missions (base defense, alien base assault) may force specific terrain types, bypassing biome selection

### Core Terrain Properties

Each terrain defines essential configuration through TOML data:

- **Map Blocks List**: Complete list of available map blocks that can be used to construct the battlefield for this terrain type
- **Map Script**: Reference to the map script (assembly algorithm) used to arrange map blocks into a coherent battlefield layout
- **Day/Night Setting**: Environmental lighting condition (day, night, twilight) affecting visibility and tactical options
- **Environment Effects**: Additional environmental modifiers (fog, rain, snow, etc.) affecting gameplay conditions

### Map Blocks Integration

Terrain specifies which building blocks are available for battlefield assembly:

- **Block Pool**: Curated list of compatible map blocks appropriate for the terrain theme (urban blocks for city terrain, forest blocks for woodland terrain)
- **Weighted Selection**: Map script samples from block pool using weights and tags during battlefield generation
- **Reusable Content**: Same blocks may appear in multiple terrain types with different assembly patterns

### Map Script Execution

The map script assembles the battlefield using the terrain's block pool:

- **Deterministic Assembly**: Script follows "anchors → connectors → large areas → small fills → validate" workflow
- **Seeded Generation**: Same seed + terrain + script produces identical battlefield every time
- **Validation**: Script ensures reachability, line-of-sight, and playability before finalizing battlefield

### Environmental Effects

Terrain defines battlefield environmental conditions:

- **Lighting Conditions**: Day (full visibility), night (reduced range, light sources important), twilight (partial visibility)
- **Weather Effects**: Clear, rain, snow, fog, sandstorm affecting visibility, movement, and tactical decisions
- **Special Conditions**: Terrain-specific environmental hazards or modifiers (radiation, toxic atmosphere, etc.)

## Examples

### Map Blocks Configurations
- Urban High-Rise Block: Contains multiple floors, elevators, stairwells with anchors for player deployment and objective placement
- Industrial Factory Block: Large open spaces with machinery, catwalks, and hazardous areas tagged for industrial terrain
- Rural Farm Block: Open fields, barns, fences with natural cover elements and spawn points for alien encounters

### Map Scripts Applications
- Intact Center Script: Places central objective first, then builds outward with connecting corridors and defensive positions
- Rush Hour Script: Creates urban chaos with blocked streets, civilian vehicles, and multiple access routes
- Salvage Run Script: Generates scattered debris fields with valuable objectives and ambush points

### Script Pattern Implementations
- Anchor-First Placement: UFO crash site positioned centrally, then connecting roads laid to ensure accessibility
- Connector Pathways: Main corridors established between key anchors before filling with tactical spaces
- Large Area Definition: Central plaza or factory floor placed to create primary combat arena
- Weighted Filler Distribution: Smaller alleyways and side rooms sampled by probability to add variety

### Special Mission Overrides
- Base Defense: Uses player's strategic base layout with facility blocks, placing command center and defensive positions
- Alien Base Assault: Forces alien terrain script with sealed chambers, technology nodes, and alien architecture
- Underground Ruins: Overrides with cavern terrain featuring natural formations, ancient artifacts, and hidden passages

### Biome-Terrain Selection Cases
- Urban Biome: Downtown Financial District (weight 30) vs Industrial Wasteland (weight 20) selection
- Rural Biome: Farmland (weight 40) vs Forest Clearing (weight 30) based on province characteristics
- Special Mission: Alien Base terrain forced regardless of biome weights for invasion scenarios

### Validation and Constraint Examples
- Reachability Check: Ensures all objectives can be accessed through navigable paths without blocked routes
- Line-of-Sight Validation: Verifies critical sight lines remain open for tactical gameplay balance
- Seam Compatibility: Confirms connecting blocks align properly with matching doorways and passages

## Related Wiki Pages

- [Biome.md](../geoscape/Biome.md) - Biome-terrain selection framework.
- [Battle map.md](../battlescape/Battle%20map.md) - Battle map generation.
- [Map scripts.md](../battlescape/Map%20scripts.md) - Map script architecture.
- [Battle Map generator.md](../battlescape/Battle%20Map%20generator.md) - Map generation systems.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission-specific terrain.
- [Terrain damage.md](../battlescape/Terrain%20damage.md) - Terrain destruction mechanics.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Elevation and positioning.
- [World.md](../geoscape/World.md) - World terrain composition.

## References to Existing Games and Mechanics

- **Civilization Series**: Terrain types and map generation
- **Europa Universalis**: Province terrain and development
- **Crusader Kings**: Terrain effects on warfare and movement
- **Hearts of Iron**: Terrain and weather systems
- **Victoria Series**: Terrain and economic development
- **Stellaris**: Planetary terrain and habitability
- **Endless Space**: Planetary terrain and biome mechanics
- **Galactic Civilizations**: Planet type and terrain systems
- **Total War Series**: Campaign map terrain and provinces
- **Warcraft III**: Terrain types and map generation

