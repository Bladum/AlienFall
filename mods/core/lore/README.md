# Core Mod: Lore Content

## Goal / Purpose

The Lore folder contains narrative content, faction lore, and story elements that provide world-building and context for the game.

## Content

- **factions/** - Faction lore, histories, and descriptions
- **narrative/** - Story narrative and world-building

## Features

- **Faction Descriptions**: History and characteristics of each faction
- **World Background**: Context and setting for game world
- **Character Narratives**: NPC backstories and development
- **Cultural Context**: Lore explaining game mechanics
- **Story Integration**: How lore feeds into gameplay

## Integrations with Other Systems

### Narrative System
- Content loaded by `engine/lore/narrative_hooks.lua`
- Events integrate with `engine/lore/lore_manager.lua`
- Dialog and story triggers

### Lore Content
- Complements lore in `lore/` folder
- References story content from `lore/story/`
- Visual context from `lore/images/`

### Geoscape
- Faction presence on world map
- Regional lore and history
- Culture-based faction behavior

### Design Specifications
- Lore design in `design/mechanics/Lore.md`
- Faction design in `design/mechanics/`

### API Documentation
- Lore format in `api/LORE.md`
- Faction specifications in `api/GEOSCAPE.md`

## See Also

- [Core Mod README](../README.md) - Core content overview
- [Lore Documentation](../../lore/README.md) - Story content
- [Story Content](../../lore/story/README.md) - Narrative documentation
- [Lore API](../../api/LORE.md) - Lore system interface
