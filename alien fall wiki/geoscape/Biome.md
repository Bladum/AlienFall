# Biome

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Assignment and Mutability](#assignment-and-mutability)
  - [Terrain Selection Framework](#terrain-selection-framework)
  - [Economy-Driven Variation](#economy-driven-variation)
  - [World-Specific Biome Systems](#world-specific-biome-systems)
  - [Tags and Mission Filtering](#tags-and-mission-filtering)
  - [Visual and UI Integration](#visual-and-ui-integration)
- [Examples](#examples)
  - [Biome Assignment Scenarios](#biome-assignment-scenarios)
  - [Terrain Selection Cases](#terrain-selection-cases)
  - [Economy-Driven Variations](#economy-driven-variations)
  - [World-Specific Biome Examples](#world-specific-biome-examples)
  - [Mission Filtering Applications](#mission-filtering-applications)
  - [Visual Integration Examples](#visual-integration-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Biome system establishes environmental themes as high-level descriptors that define province visual appearance and tactical flavor through simplified configuration. Each biome specifies the color of its province on the world map, a weighted list of terrains for battlefield generation, background imagery for interception scenes, and potential weather conditions during battles. Biomes are classified as water, land, or mixed types to determine tactical and strategic constraints.

From a design perspective, a Biome is assigned to each province and serves as the primary determinant of:
- **Visual Identity**: Province color on world map for quick recognition
- **Terrain Selection**: List of terrains with weights for random battlefield generation
- **Interception Background**: Visual backdrop during air/naval combat scenes
- **Weather Options**: Potential weather conditions affecting tactical gameplay
- **Movement Type**: Water, land, or mixed classification for craft and unit operations

This simplified approach ensures biomes are easy to configure in TOML files while providing essential environmental variety without overcomplicating the system.

## Mechanics

### Core Biome Properties

Each biome defines essential characteristics through TOML configuration:

- **Province Color**: RGB color value defining how provinces with this biome appear on the world map for visual identification
- **Terrain List with Weights**: Weighted array of terrain types used for random battlefield selection during mission generation
- **Interception Background Image**: Background artwork displayed during interception scenes set in this biome's environment
- **Weather Conditions**: Optional list of potential weather effects (rain, snow, fog, etc.) that may occur during battles
- **Type Classification**: Biome categorized as `water`, `land`, or `mixed` determining movement and operational constraints

### Biome Assignment

- **Province Assignment**: Each province is assigned a biome during world creation
- **Fixed Assignment**: Biomes remain static during normal gameplay for consistency
- **Event-Driven Changes**: Scripted events may change province biomes for narrative purposes (e.g., alien terraforming)

### Terrain Selection

During mission generation, the system uses the biome's terrain list:

- **Weighted Random Selection**: Terrain chosen randomly based on weights (e.g., urban: 40, forest: 30, farmland: 20, village: 10)
- **Deterministic Seeding**: Selection uses mission seed for reproducible results
- **Mission Overrides**: Special missions (alien base assault, base defense) may force specific terrain types

### Type Classification

Biome type affects tactical and strategic gameplay:

- **Land Biomes**: Support ground operations, standard craft operations, typical mission types
- **Water Biomes**: Require naval craft or amphibious operations, affect detection and movement rules
- **Mixed Biomes**: Coastal or amphibious zones supporting both land and naval operations with transitional terrain

### Weather Integration

Biomes may specify potential weather conditions:

- **Weather Pool**: List of possible weather types for this biome (e.g., desert: [sandstorm, clear, hot], arctic: [blizzard, snow, clear])
- **Battle Effects**: Selected weather affects visibility, movement, and tactical conditions during battles
- **Random Selection**: Weather chosen randomly from biome's pool during mission generation or set by mission script

## Examples

### Biome Assignment Scenarios
- Temperate Forest: 40% mixed woods, 30% farmland, 20% woodland clearing, 10% rural village weights
- Desert Environment: 50% sand dunes, 30% rocky outcrops, 15% oasis, 5% abandoned settlement distribution
- Urban Center: 35% city center, 25% suburbs, 20% industrial zone, 20% commercial district composition
- Arctic Wasteland: 45% tundra, 30% ice floes, 20% glacier, 5% research outpost terrain mix
- Alien Jungle: 40% bioluminescent flora, 30% xeno-caverns, 20% fungal forests, 10% alien ruins selection

### Terrain Selection Cases
- Economic Urban Bonus: Province with economy value 75 (threshold 70) gains +25 weight to urban terrains
- Mission Override: Alien base assault forces alien facility terrain regardless of biome weights (1000 preference)
- Seasonal Modification: Winter season adds +30 weight to snow-covered terrain in temperate biomes
- Coastal Province: Coastal tag adds +15 weight to coastal areas, +10 weight to beachfront terrain
- Mountainous Region: Mountain tag provides +20 weight to mountain passes, +15 weight to high ground

### Economy-Driven Variations
- High-Economy Province: Economy value 80 triggers urban bonus, increasing city center weight from 10 to 35
- Resource-Rich Region: Economic modifier 1.3 increases urban terrain spawn probability by 30%
- Industrial Zone: Economy threshold 85 enables industrial terrain selection with 25 weight bonus
- Rural Development: Economy value 60 provides moderate urban bonus for village and town terrain
- Metropolitan Center: Economy value 95 maximizes urban terrain weights for dense city environments

### World-Specific Biome Examples
- Cydonia (Mars): Red rock canyons, ancient ruins, dust storms with specialized alien adaptations
- Europa (Jupiter): Ice caverns, subsurface oceans, cryovolcanic features with aquatic alien life
- Titan (Saturn): Methane lakes, hydrocarbon rain, thick atmosphere with exotic environmental hazards
- Ganymede (Jupiter): Cratered ice plains, magnetic storms, radiation zones with shielded alien technology

### Mission Filtering Applications
- Ocean Biome: Restricts to submarine and aquatic missions, requires amphibious craft capabilities
- Underground Biome: Modifies detection rules, enables subterranean infiltration missions
- Mountain Biome: Affects interception ranges, enables high-altitude reconnaissance missions
- Urban Biome: Increases population-based objectives, enables hostage rescue and infiltration scenarios
- Arctic Biome: Modifies movement penalties, enables environmental survival challenges

### Visual Integration Examples
- Color-Coded Provinces: Temperate forests in green, deserts in tan, urban areas in gray
- Weather Overlays: Dynamic storm systems, seasonal color changes, atmospheric effects
- Strategic UI: Biome information in mission briefings, province detail panels, radar displays
- Diagnostic Visualization: Debug overlays showing biome boundaries, terrain weights, mission spawn probabilities

## Related Wiki Pages

- [World.md](../geoscape/World.md) - World generation and province systems.
- [Terrain.md](../geoscape/Terrain.md) - Terrain types and selection.
- [Province.md](../geoscape/Province.md) - Province management and biomes.
- [Universe.md](../geoscape/Universe.md) - Planetary biome variations.
- [World time.md](../geoscape/World%20time.md) - Seasonal biome changes.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [Mission.md](../lore/Mission.md) - Mission generation and biome filtering.
- [Economy.md](../economy/Economy.md) - Economic biome influences.

## References to Existing Games and Mechanics

- **Civilization Series**: Terrain and biome systems for map generation
- **Europa Universalis**: Province-based terrain and development
- **Crusader Kings**: Terrain and biome effects on warfare
- **Hearts of Iron**: Terrain and weather systems
- **Victoria Series**: Terrain and economic development
- **Stellaris**: Planetary biome and habitability systems
- **Endless Space**: Planetary terrain and biome mechanics
- **Galactic Civilizations**: Planet type and terrain systems
- **Total War Series**: Campaign map terrain and provinces
- **Warcraft III**: Terrain types and map generation

