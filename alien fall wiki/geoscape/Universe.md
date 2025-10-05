# Universe

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Campaign Composition](#campaign-composition)
  - [Per-World Isolation](#per-world-isolation)
  - [Inter-World Travel and Access](#inter-world-travel-and-access)
  - [Establishing Presence on Another World](#establishing-presence-on-another-world)
  - [World-Specific Overrides](#world-specific-overrides)
  - [Processing and Determinism](#processing-and-determinism)
- [Examples](#examples)
  - [Campaign Progression](#campaign-progression)
  - [Establishing Forward Base](#establishing-forward-base)
  - [Transit Policy Variants](#transit-policy-variants)
  - [Operational Consequences](#operational-consequences)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Universe serves as the campaign container that manages multiple worlds and facilitates travel between them. The Universe is essentially:
- **List of Worlds**: All worlds available in the campaign (Earth, Mars, alien dimensions, etc.)
- **Portal Management**: Connections between provinces on different worlds enabling inter-world travel
- **Travel Duration System**: Distance-based calculations determining time required for inter-world journeys
- **High-Level Summaries**: Aggregated statistics and information across all worlds (total population, active factions, mission counts, biome distribution)

Worlds remain largely isolated for most systems, enabling bespoke rules and content per world while preserving determinism for testing. Unlocking inter-world travel becomes a meaningful mid-game progression mechanic that expands strategic and narrative possibilities. The Universe simplifies campaign composition and supports modular content delivery for designers and modders.

## Mechanics
### Campaign Composition
Campaigns include one or more worlds, with each world functioning as its own simulation instance. This enables modular campaign design where worlds can be added or removed without affecting core systems.

### Per-World Isolation
Each world maintains separate state including background images, province graphs, time counters, active factions, and world-specific rules. Isolation simplifies deterministic scheduling, state management, and testing while allowing bespoke world rules for scale, biomes, and build constraints.

### Inter-World Travel and Access
Travel between worlds requires special technologies or scripted narrative events like discovering and activating portals. Activation enables transit and access to destination worlds. Inter-world actions including portal prerequisites, transit time, fuel cost, and allowed craft types are explicit and data-driven.

### Establishing Presence on Another World
Founding footholds requires building bases or transferring/rebasing craft and resources. Operations follow existing transfer, logistics, and base rules, but worlds may apply modifiers for grid size, excavation cost, and permitted facilities. Designers can implement temporary portal transit or permanent transfer/rebasing.

### World-Specific Overrides
Worlds may define unique sensor, travel, and environmental rules including under-ice provinces, different detection systems, or special portal mechanics. These rules are authored in data files and applied by the destination world's simulation.

### Processing and Determinism
Cross-world transfers consume calendar days and reserve resources/craft for transit duration. Transit state persists across saves. En-route hooks and cross-world director logic run on the shared scheduler and are seeded for deterministic replay.

## Examples
### Campaign Progression
Campaign begins on Earth with research project and mission chain revealing and activating portal to alien world "Xylos" featuring distinct biomes, factions, and rare resources.

### Establishing Forward Base
After portal activation, player sends transport through gateway to found forward base on Xylos. Transported hangar slots, local radars, and base construction follow usual rules but use Xylos's grid size and excavation costs.

### Transit Policy Variants
Portal transit enables temporary deployment where crafts consume transit days and fuel but remain same unit on return. Permanent rebasing reassigns crafts to new base and counts against its hangar/capacity pools.

### Operational Consequences
Inter-world logistics create predictable costs and scheduling choices. Resupply lines, repair turnaround, and project completion depend on transit rules and world modifiers.

## Related Wiki Pages

- [World.md](../geoscape/World.md) - World generation and systems.
- [Portal.md](../geoscape/Portal.md) - Inter-world travel mechanics.
- [Province.md](../geoscape/Province.md) - Province and world structure.
- [Biome.md](../geoscape/Biome.md) - Biome systems and variations.
- [World time.md](../geoscape/World%20time.md) - Time and calendar systems.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [Research tree.md](../economy/Research%20tree.md) - Portal technology research.
- [Transfers.md](../economy/Transfers.md) - Inter-world logistics.

## References to Existing Games and Mechanics

- **Civilization Series**: Multi-continent and world exploration
- **Europa Universalis**: Colonial empires and world spanning
- **Crusader Kings**: Multi-realm campaigns and travel
- **Hearts of Iron**: Global warfare and multi-theater operations
- **Victoria Series**: Imperial expansion and world trade
- **Stellaris**: Multi-system empires and colonization
- **Endless Space**: Interstellar exploration and colonization
- **Galactic Civilizations**: Galactic empire management
- **Total War Series**: Multi-continent campaigns
- **Warcraft III**: Multi-world campaigns and portals

