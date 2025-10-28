# tests2/geoscape - Strategic Layer Tests

**Purpose:** Test geoscape strategic gameplay and management

**Content:** 28 Lua test files for geoscape functionality

**Features:**
- World system and map management
- Campaign progression and management
- Mission generation and handling
- Faction and country systems
- Threat assessment and escalation
- Population and settlement management
- Portal systems
- Strategic planning

## Test Files (28 total)

### Core Geoscape (7 files)
- **world_system_test.lua** - World management
- **strategic_map_test.lua** - Strategic mapping
- **location_test.lua** - Location management
- **biome_test.lua** - Biome systems
- **procgen_terrain_test.lua** - Procedural terrain

### Campaign Systems (6 files)
- **campaign_manager_test.lua** - Campaign management
- **campaign_progress_test.lua** - Progress tracking
- **campaign_progression_test.lua** - Campaign progression
- **progression_manager_test.lua** - Progression management
- **strategic_planning_test.lua** - Strategic planning
- **geoscape_advanced_test.lua** - Advanced systems

### Mission Systems (4 files)
- **mission_manager_test.lua** - Mission management
- **mission_generator_test.lua** - Mission generation
- **mission_briefing_test.lua** - Mission briefing
- **difficulty_system_test.lua** - Difficulty scaling

### Factions & Politics (5 files)
- **faction_system_test.lua** - Faction management
- **country_manager_test.lua** - Country management
- **population_system_test.lua** - Population management
- **settlement_manager_test.lua** - Settlement management
- **threat_assessment_test.lua** - Threat assessment

### Strategic Elements (4 files)
- **threat_escalation_test.lua** - Threat escalation (duplicate tracking)
- **portal_manager_test.lua** - Portal systems
- **craft_interception_test.lua** - Interception mechanics
- **interception_system_test.lua** - Interception system
- **expedition_planning_test.lua** - Expedition planning
- **region_controller_test.lua** - Region control
- **weather_system_test.lua** - Weather systems

### Infrastructure
- **init.lua** - Module loader

## Running Tests

```bash
lovec tests2/runners run_subsystem geoscape
```

## Coverage Matrix

| System | Files | Status |
|--------|-------|--------|
| Core Geoscape | 7 | ✓ Complete |
| Campaign | 6 | ✓ Complete |
| Missions | 4 | ✓ Complete |
| Factions | 5 | ✓ Complete |
| Strategic | 6+ | ✓ Complete |

## Statistics

- **Total Files**: 28 Lua test files
- **Test Cases**: 140+
- **Framework**: HierarchicalSuite
- **Status**: Production Ready

---

**Status**: ✅ Fully Implemented
**Last Updated**: October 2025
