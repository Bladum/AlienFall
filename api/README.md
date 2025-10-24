# API Documentation

## Goal / Purpose

The API folder contains comprehensive documentation of game systems, entities, and interfaces. It serves as the authoritative reference for understanding how different game systems work, what data structures they use, and how other systems can integrate with them.

## Content

### Master Schema & Guides (NEW!)

**Foundation for all API documentation:**

- **GAME_API.toml** - ⭐ Master API schema definition file
  - Single source of truth for ALL mod TOML configurations
  - Defines every entity type, field, type constraint, and validation rule
  - Used by validators, tools, and IDE plugins
  - See [GAME_API_GUIDE.md](GAME_API_GUIDE.md) for usage

- **GAME_API_GUIDE.md** - Complete guide to using the schema
  - How to read field definitions
  - Type reference and constraints
  - Enum values and cross-references
  - Examples for each entity type
  - Troubleshooting common errors

- **SYNCHRONIZATION_GUIDE.md** - Keep engine, schema, and docs in sync
  - Process for updating API when code changes
  - Synchronization checklist
  - Version management and deprecation
  - Tools and validation
  - Automation opportunities

### System Documentation

API documentation files for each major game system:

- **AI_SYSTEMS.md** - AI decision-making, tactical behaviors, strategic planning
- **ANALYTICS.md** - Analytics, telemetry, and data collection systems
- **ASSETS.md** - Asset management, loading, and resource handling
- **BASESCAPE.md** - Base management, facilities, and infrastructure
- **BATTLESCAPE.md** - Tactical combat, map systems, and unit interactions
- **CRAFTS.md** - Spacecraft specifications, capabilities, and interception
- **ECONOMY.md** - Economic systems, resources, and financial management
- **FACILITIES.md** - Base facilities, construction, and upgrades
- **FINANCE.md** - Financial tracking, budgets, and transactions
- **GEOSCAPE.md** - World map, regions, provinces, and strategic layer
- **GUI.md** - User interface framework, widgets, and scene management
- **INTEGRATION.md** - System integration patterns and cross-system communication
- **INTERCEPTION.md** - UFO interception mechanics and air combat
- **ITEMS.md** - Items, equipment, and inventory systems
- **LORE.md** - Story content, narrative, and world-building
- **MISSIONS.md** - Mission generation, objectives, and mission types
- **POLITICS.md** - Political systems, factions, and government relations
- **RENDERING.md** - Graphics rendering, sprite management, and visual systems
- **RESEARCH_AND_MANUFACTURING.md** - Research trees, tech progression, and crafting
- **UNITS.md** - Unit specifications, class systems, and soldier mechanics
- **WEAPONS_AND_ARMOR.md** - Weapon stats, armor properties, and combat equipment

## Features

- **System Contracts**: Defined interfaces and data structures for each system
- **Configuration Format**: TOML-based configuration specifications
- **Usage Examples**: Code examples showing how to use each system
- **Data Models**: Entity and component definitions
- **Integration Points**: Where systems connect with each other
- **Extension Hooks**: Customization and modding points

## Integrations with Other Systems

### Engine Implementation
- Each API file documents a system in `engine/`
- Direct correspondence between API docs and engine code
- TOML configurations in `mods/core/rules/` implement these APIs

### Mods System
- Mod developers use API documentation to create content
- TOML format defined in API files
- Enables custom units, weapons, facilities, and more

### Design Documentation
- API reflects design decisions documented in `design/mechanics/`
- Architecture patterns from `architecture/` are implemented here
- Design gaps documented in `design/gaps/`

### Testing
- Test cases in `tests/` verify API compliance
- Mock data in `tests/mock/` follows API specifications
- Integration tests validate system interactions

## File Organization

Each API file typically contains:

1. **Overview** - System purpose and high-level description
2. **Data Structures** - Entity types, components, and configurations
3. **Configuration** - TOML format and required/optional fields
4. **Usage Examples** - Lua code showing how to use the system
5. **Integration** - How this system connects to others
6. **Events/Callbacks** - Events triggered by the system
7. **Limitations** - Known constraints and workarounds

## Contributing

When adding new systems or features:

1. Document the API in this folder
2. Define data structures and TOML formats
3. Update corresponding system in `engine/`
4. Create tests in `tests/`
5. Add example content in `mods/core/rules/`

## See Also

- [Architecture README](../architecture/README.md) - System design and integration flows
- [Design Mechanics](../design/mechanics/) - Game design specifications
- [Engine Main](../engine/README.md) - Core engine implementation
- [Mods System](../mods/README.md) - Modding and content creation
