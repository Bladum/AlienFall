# Engine Restructure Plan - Feature-Focused Organization

**Status:** IN_PROGRESS  
**Priority:** High  
**Created:** 2025-10-14  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Complete restructuring of the AlienFall engine to organize files by feature groups rather than technical categories. This creates a more intuitive, scalable architecture that better separates concerns and makes the codebase easier to navigate and maintain.

---

## Purpose

**Current Problems:**
- Mixed concerns across directories (battlescape contains both combat AND UI AND rendering)
- Difficult to locate related functionality
- Unclear boundaries between layers
- Widget system mixed with game logic
- Politics/economy/lore systems scattered across folders
- No clear AI organization

**Goals:**
- **Feature-focused organization**: Group related functionality together
- **Clear separation of concerns**: Each folder has ONE clear purpose
- **Future-proof architecture**: Easy to add new features without restructuring
- **Better AI navigation**: Clear patterns for where things belong
- **Modular design**: Features can be developed/tested independently

---

## Current Structure Analysis

### Current Top-Level Folders (engine/)
```
assets/         - Images, sounds, fonts, data files
basescape/      - Base management (init, logic/research)
battlescape/    - Tactical combat (ai, battle, combat, data, effects, entities, logic, map, rendering, systems, ui, utils)
core/           - Engine systems (assets, audio, data, mod, pathfinding, save, state, team, ui)
geoscape/       - Strategic layer (biomes, data, init, logic, rendering, screens, systems, ui, world_state)
interception/   - Craft interception (logic/interception_screen)
lore/           - Campaign content (calendar, campaign, deployment, faction, mission)
shared/         - Shared entities (crafts, facilities, items, units)
ui/             - Menu screens (main_menu, tests_menu, widget_showcase)
utils/          - Utilities (love, scaling, toml, verify_assets, viewport)
widgets/        - UI widget library (advanced, buttons, combat, containers, core, demo, display, input, navigation)
```

### Key Issues Identified

1. **Battlescape is bloated**: Contains 14 subdirectories mixing combat, UI, rendering, AI, systems, and map generation
2. **No economy folder**: Research is in basescape/logic, marketplace in geoscape/logic, manufacturing in shared/facilities
3. **No politics folder**: Reputation, karma, fame, relations scattered in geoscape/systems
4. **No scenes folder**: Screen/scene files scattered (geoscape/screens, ui/, lore/deployment_screen)
5. **Widgets buried**: Inside engine/ instead of top-level for easy access
6. **AI scattered**: Only battlescape/ai exists, no strategic AI organization
7. **Lore mixed with systems**: Calendar, missions, campaigns, factions all in one folder
8. **Assets are data**: Not processing/loading systems

---

## Proposed New Structure

### New Top-Level Folders (engine/)

```
engine/
├── scenes/              -- ALL GAME SCREENS/STATES
│   ├── main_menu.lua
│   ├── geoscape_screen.lua
│   ├── basescape_screen.lua
│   ├── battlescape_screen.lua
│   ├── interception_screen.lua
│   ├── deployment_screen.lua
│   ├── mission_briefing.lua
│   ├── debriefing_screen.lua
│   ├── research_screen.lua
│   ├── manufacturing_screen.lua
│   ├── marketplace_screen.lua
│   ├── diplomacy_screen.lua
│   ├── personnel_screen.lua
│   ├── craft_screen.lua
│   ├── map_editor_screen.lua
│   └── widget_showcase.lua
│
├── widgets/             -- ALL UI WIDGETS (UNCHANGED STRUCTURE)
│   ├── core/            -- Base, theme, grid
│   ├── buttons/
│   ├── containers/
│   ├── display/
│   ├── input/
│   ├── navigation/
│   ├── advanced/
│   ├── combat/
│   ├── demo/
│   └── init.lua
│
├── basescape/           -- BASE MANAGEMENT LAYER
│   ├── init.lua
│   ├── base/            -- Base construction and layout
│   │   ├── base.lua
│   │   ├── base_grid.lua
│   │   └── base_builder.lua
│   ├── facilities/      -- Facility types and management
│   │   ├── facility.lua
│   │   ├── facility_types.lua
│   │   └── facility_system.lua
│   └── services/        -- Base services (storage, healing, training)
│       ├── storage_service.lua
│       ├── medical_service.lua
│       └── training_service.lua
│
├── geoscape/            -- STRATEGIC WORLD LAYER
│   ├── init.lua
│   ├── world/           -- World map and structure
│   │   ├── world.lua
│   │   ├── world_state.lua
│   │   └── world_renderer.lua
│   ├── geography/       -- Geographic systems
│   │   ├── province.lua
│   │   ├── province_graph.lua
│   │   ├── region.lua
│   │   ├── country.lua
│   │   ├── biomes.lua
│   │   └── terrain.lua
│   ├── systems/         -- Geoscape-specific systems
│   │   ├── hex_grid.lua
│   │   ├── daynight_cycle.lua
│   │   └── detection_manager.lua
│   └── ui/              -- Geoscape UI (camera, input, overlays)
│       ├── input.lua
│       └── render.lua
│
├── battlescape/         -- TACTICAL COMBAT LAYER
│   ├── init.lua
│   ├── combat/          -- Combat mechanics
│   │   ├── unit.lua
│   │   ├── action_system.lua
│   │   ├── weapon_system.lua
│   │   ├── weapon_modes.lua
│   │   ├── damage_system.lua
│   │   ├── damage_types.lua
│   │   ├── damage_models.lua
│   │   ├── equipment_system.lua
│   │   ├── morale_system.lua
│   │   ├── psionics_system.lua
│   │   ├── projectile_system.lua
│   │   ├── battle_tile.lua
│   │   └── combat_3d.lua
│   ├── maps/            -- Map generation and management
│   │   ├── map_generator.lua
│   │   ├── map_generation_pipeline.lua
│   │   ├── mission_map_generator.lua
│   │   ├── grid_map.lua
│   │   ├── pathfinding.lua
│   │   ├── trajectory.lua
│   │   ├── map_saver.lua
│   │   ├── mapblock_system.lua
│   │   ├── mapblock_loader_v2.lua
│   │   ├── map_block.lua
│   │   └── legacy/
│   ├── battlefield/     -- Battlefield state and management
│   │   ├── battlefield.lua
│   │   ├── turn_manager.lua
│   │   ├── team_placement.lua
│   │   └── objectives_system.lua
│   ├── systems/         -- Battlescape-specific systems
│   │   ├── los_system.lua
│   │   ├── cover_system.lua
│   │   ├── flanking_system.lua
│   │   ├── inventory_system.lua
│   │   ├── abilities_system.lua
│   │   ├── ammo_system.lua
│   │   ├── reaction_fire_system.lua
│   │   ├── suppression_system.lua
│   │   ├── status_effects_system.lua
│   │   ├── wounds_system.lua
│   │   ├── regen_system.lua
│   │   ├── morale_system.lua
│   │   ├── melee_system.lua
│   │   ├── throwables_system.lua
│   │   ├── grenade_trajectory_system.lua
│   │   ├── destructible_terrain_system.lua
│   │   ├── environmental_hazards.lua
│   │   ├── sound_detection_system.lua
│   │   ├── mission_timer_system.lua
│   │   ├── camera_control_system.lua
│   │   ├── movement_3d.lua
│   │   └── mouse_picking_3d.lua
│   ├── rendering/       -- Rendering systems
│   │   ├── renderer.lua
│   │   ├── renderer_3d.lua
│   │   ├── object_renderer_3d.lua
│   │   ├── item_renderer_3d.lua
│   │   ├── hex_renderer.lua
│   │   ├── effects_3d.lua
│   │   ├── camera.lua
│   │   └── billboard.lua
│   ├── effects/         -- Visual effects
│   │   ├── animation_system.lua
│   │   ├── explosion_system.lua
│   │   ├── fire_system.lua
│   │   └── smoke_system.lua
│   ├── battle_ecs/      -- ECS-based battle system (alternative)
│   │   ├── init.lua
│   │   ├── unit_entity.lua
│   │   ├── team.lua
│   │   ├── transform.lua
│   │   ├── health.lua
│   │   ├── vision.lua
│   │   ├── vision_system.lua
│   │   ├── movement.lua
│   │   ├── movement_system.lua
│   │   ├── move_mode_system.lua
│   │   ├── shooting_system.lua
│   │   ├── accuracy_system.lua
│   │   ├── range_system.lua
│   │   ├── hex_system.lua
│   │   ├── hex_math.lua
│   │   ├── hex_combat_advanced.lua
│   │   └── debug.lua
│   ├── mapscripts/      -- Map scripting
│   │   ├── mapscript_executor.lua
│   │   ├── mapscript_selector.lua
│   │   ├── terrain_selector.lua
│   │   └── commands/
│   │       ├── addBlock.lua
│   │       ├── addCraft.lua
│   │       ├── addLine.lua
│   │       ├── addUFO.lua
│   │       ├── checkBlock.lua
│   │       ├── digTunnel.lua
│   │       ├── fillArea.lua
│   │       ├── removeBlock.lua
│   │       └── resize.lua
│   ├── logic/           -- Battlescape logic
│   │   ├── integration.lua
│   │   ├── unit_selection.lua
│   │   ├── unit_recovery.lua
│   │   └── unit_progression.lua
│   ├── entities/        -- Battlescape entities
│   │   └── projectile.lua
│   ├── ui/              -- Battlescape UI components (NOT SCREENS)
│   │   ├── combat_hud.lua
│   │   ├── unit_status_effects_ui.lua
│   │   ├── target_selection_ui.lua
│   │   ├── action_menu_system.lua
│   │   ├── weapon_mode_selector.lua
│   │   ├── combat_log_system.lua
│   │   ├── minimap_system.lua
│   │   ├── objective_tracker_ui.lua
│   │   ├── inventory_system.lua
│   │   ├── squad_selection_ui.lua
│   │   ├── unit_deployment_ui.lua
│   │   ├── loadout_management_ui.lua
│   │   ├── landing_zone_preview_ui.lua
│   │   ├── craft_selection_ui.lua
│   │   ├── mission_brief_ui.lua
│   │   ├── battle_end_screen_ui.lua
│   │   ├── debriefing_screen_ui.lua
│   │   ├── map_editor.lua
│   │   ├── tileset_browser.lua
│   │   ├── tile_palette.lua
│   │   ├── ui.lua
│   │   ├── render.lua
│   │   ├── input.lua
│   │   └── logic.lua
│   ├── data/            -- Battlescape data
│   │   ├── tilesets.lua
│   │   ├── terrains.lua
│   │   ├── maptile.lua
│   │   ├── mapscripts.lua
│   │   └── mapscripts_v2.lua
│   └── utils/           -- Battlescape utilities
│       └── multitile.lua
│
├── interception/        -- CRAFT INTERCEPTION LAYER
│   ├── init.lua
│   ├── interception_manager.lua
│   └── interception_combat.lua
│
├── lore/                -- CAMPAIGN & NARRATIVE CONTENT
│   ├── calendar.lua
│   ├── campaign/        -- Campaign management
│   │   ├── campaign_system.lua
│   │   └── campaign_manager.lua
│   ├── missions/        -- Mission definitions
│   │   ├── mission.lua
│   │   └── mission_system.lua
│   ├── factions/        -- Faction system
│   │   └── faction_system.lua
│   ├── events/          -- Game events (NEW)
│   └── quests/          -- Quest system (NEW)
│
├── economy/             -- ECONOMIC SYSTEMS (NEW FOLDER)
│   ├── research/        -- Research system
│   │   └── research_system.lua
│   ├── production/      -- Manufacturing system
│   │   └── manufacturing_system.lua
│   ├── marketplace/     -- Market and trade
│   │   ├── marketplace_system.lua
│   │   ├── black_market_system.lua
│   │   └── salvage_system.lua
│   └── finance/         -- Financial management (NEW)
│       ├── budget.lua
│       ├── funding.lua
│       └── costs.lua
│
├── politics/            -- POLITICAL SYSTEMS (NEW FOLDER)
│   ├── organization/    -- Player organization
│   │   ├── organization.lua
│   │   └── organization_level.lua
│   ├── karma/           -- Karma system
│   │   └── karma_system.lua
│   ├── government/      -- Country governments (NEW)
│   │   └── government_types.lua
│   ├── fame/            -- Fame system
│   │   └── fame_system.lua
│   ├── relations/       -- Relations between entities
│   │   ├── relations_manager.lua
│   │   └── reputation_system.lua
│   └── diplomacy/       -- Diplomatic actions (NEW)
│       └── diplomacy_system.lua
│
├── mods/                -- MOD LOADING & MANAGEMENT
│   ├── mod_manager.lua
│   ├── mod_loader.lua
│   └── mod_validator.lua
│
├── core/                -- ENGINE-LEVEL CORE SYSTEMS
│   ├── state_manager.lua
│   ├── data_loader.lua
│   ├── save_system.lua
│   ├── audio_system.lua
│   ├── input_manager.lua   (NEW - centralized input)
│   └── config.lua          (NEW - game configuration)
│
├── shared/              -- SHARED GAME ENTITIES
│   ├── units/           -- Unit definitions and systems
│   │   └── units.lua
│   ├── crafts/          -- Craft definitions
│   │   └── craft.lua
│   ├── items/           -- Item definitions
│   │   ├── items.lua
│   │   └── mock_data.lua
│   ├── terrain/         -- Terrain definitions (NEW)
│   │   └── terrain_types.lua
│   └── data/            -- Shared game data (NEW)
│       └── constants.lua
│
├── assets/              -- ASSET PROCESSING & LOADING
│   ├── assets.lua       -- Asset manager
│   ├── image_loader.lua (NEW)
│   ├── audio_loader.lua (NEW)
│   ├── font_loader.lua  (NEW)
│   ├── data/            -- Data files
│   │   ├── mapgen_config.lua
│   │   └── terrain_movement_costs.lua
│   ├── fonts/
│   ├── images/
│   └── sounds/
│
├── ai/                  -- AI SYSTEMS (NEW FOLDER)
│   ├── strategic/       -- Strategic AI (geoscape)
│   │   ├── mission_ai.lua
│   │   └── resource_ai.lua
│   ├── tactical/        -- Tactical AI (battlescape)
│   │   └── decision_system.lua
│   ├── diplomacy/       -- Diplomatic AI (NEW)
│   │   └── diplomacy_ai.lua
│   └── pathfinding/     -- Shared pathfinding
│       └── pathfinding.lua
│
├── utils/               -- UTILITY FUNCTIONS
│   ├── viewport.lua
│   ├── scaling.lua
│   ├── toml.lua
│   ├── verify_assets.lua
│   ├── love.lua         -- Love2D definitions
│   └── helpers.lua      (NEW - general helpers)
│
├── main.lua             -- ENTRY POINT
└── conf.lua             -- LOVE2D CONFIGURATION
```

---

## Additional Folders to Consider

### Recommended Additions

1. **network/** (Future multiplayer support)
   - `client.lua`
   - `server.lua`
   - `synchronization.lua`

2. **localization/** (Multi-language support)
   - `i18n.lua`
   - `languages/`

3. **analytics/** (Gameplay tracking)
   - `metrics.lua`
   - `telemetry.lua`

4. **accessibility/** (Accessibility features)
   - `colorblind_modes.lua`
   - `screen_reader.lua`

5. **tutorial/** (Tutorial system)
   - `tutorial_manager.lua`
   - `tutorial_steps.lua`

---

## Key Architectural Improvements

### 1. Clear Separation of Scenes vs UI
- **scenes/** = Full game screens/states (complete Love2D state machines)
- **widgets/** = Reusable UI components (no game logic)
- **[layer]/ui/** = Layer-specific UI components (not full screens)

### 2. Feature Cohesion
- All economy features together (research, manufacturing, marketplace, finance)
- All politics features together (karma, fame, relations, diplomacy)
- All AI features together (strategic, tactical, diplomacy)

### 3. Layer Independence
- Each layer (geoscape, basescape, battlescape) is self-contained
- Shared entities in `shared/`
- Cross-layer communication through events/state manager

### 4. Data Separation
- Configuration data in `assets/data/`
- Game state data handled by individual systems
- Mock data in root `mock/` folder

### 5. Modular Systems
- Each system folder contains related functionality
- Easy to test systems independently
- Clear dependencies

---

## Migration Strategy

### Phase 1: Create New Structure
1. Create all new folder directories
2. Document the migration plan for each folder
3. Update require paths in documentation

### Phase 2: Move Core Systems
1. Move `core/` files (minimal changes needed)
2. Move `utils/` files
3. Move `widgets/` (no changes needed)
4. Move `assets/` and reorganize loaders

### Phase 3: Extract and Organize Scenes
1. Move UI screens from `ui/` to `scenes/`
2. Move screen files from layers to `scenes/`
3. Update state_manager.lua paths

### Phase 4: Reorganize Layers
1. **Geoscape**: Split into world/, geography/, systems/, ui/
2. **Basescape**: Split into base/, facilities/, services/
3. **Battlescape**: Split into combat/, maps/, battlefield/, systems/, rendering/, effects/, battle_ecs/, mapscripts/, logic/, entities/, ui/, data/, utils/
4. **Interception**: Minimal changes

### Phase 5: Create New Feature Folders
1. **Economy**: Gather research, manufacturing, marketplace, salvage, add finance/
2. **Politics**: Gather karma, fame, reputation, relations, add organization/, government/, diplomacy/
3. **Lore**: Reorganize into campaign/, missions/, factions/, events/, quests/
4. **AI**: Gather decision_system, add strategic/, tactical/, diplomacy/, pathfinding/
5. **Mods**: Reorganize mod management

### Phase 6: Update Shared
1. Reorganize shared entities
2. Add terrain/ and data/

### Phase 7: Testing & Validation
1. Update all require() paths
2. Run game and verify all screens load
3. Test each layer independently
4. Update documentation
5. Update tests paths

---

## File Movement Map

### Scenes (NEW folder)
```
FROM ui/main_menu.lua → TO scenes/main_menu.lua
FROM ui/tests_menu.lua → TO scenes/tests_menu.lua
FROM ui/widget_showcase.lua → TO scenes/widget_showcase.lua
FROM geoscape/init.lua → TO scenes/geoscape_screen.lua
FROM basescape/init.lua → TO scenes/basescape_screen.lua
FROM battlescape/init.lua → TO scenes/battlescape_screen.lua
FROM interception/logic/interception_screen.lua → TO scenes/interception_screen.lua
FROM lore/deployment_screen.lua → TO scenes/deployment_screen.lua
[CREATE NEW] → TO scenes/mission_briefing.lua
[CREATE NEW] → TO scenes/debriefing_screen.lua
[CREATE NEW] → TO scenes/research_screen.lua
[CREATE NEW] → TO scenes/manufacturing_screen.lua
[CREATE NEW] → TO scenes/marketplace_screen.lua
[CREATE NEW] → TO scenes/diplomacy_screen.lua
[CREATE NEW] → TO scenes/personnel_screen.lua
[CREATE NEW] → TO scenes/craft_screen.lua
FROM battlescape/ui/map_editor.lua → TO scenes/map_editor_screen.lua
```

### Economy (NEW folder)
```
FROM basescape/logic/research_system.lua → TO economy/research/research_system.lua
FROM shared/facilities/manufacturing_system.lua → TO economy/production/manufacturing_system.lua
FROM geoscape/logic/marketplace_system.lua → TO economy/marketplace/marketplace_system.lua
FROM geoscape/logic/black_market_system.lua → TO economy/marketplace/black_market_system.lua
FROM geoscape/logic/salvage_system.lua → TO economy/marketplace/salvage_system.lua
[CREATE NEW] → TO economy/finance/budget.lua
[CREATE NEW] → TO economy/finance/funding.lua
[CREATE NEW] → TO economy/finance/costs.lua
```

### Politics (NEW folder)
```
FROM geoscape/systems/karma_system.lua → TO politics/karma/karma_system.lua
FROM geoscape/systems/fame_system.lua → TO politics/fame/fame_system.lua
FROM geoscape/systems/reputation_system.lua → TO politics/relations/reputation_system.lua
FROM geoscape/systems/relations_manager.lua → TO politics/relations/relations_manager.lua
[CREATE NEW] → TO politics/organization/organization.lua
[CREATE NEW] → TO politics/organization/organization_level.lua
[CREATE NEW] → TO politics/government/government_types.lua
[CREATE NEW] → TO politics/diplomacy/diplomacy_system.lua
```

### AI (NEW folder)
```
FROM battlescape/ai/decision_system.lua → TO ai/tactical/decision_system.lua
FROM core/pathfinding.lua → TO ai/pathfinding/pathfinding.lua
FROM battlescape/map/pathfinding.lua → TO ai/pathfinding/tactical_pathfinding.lua
[CREATE NEW] → TO ai/strategic/mission_ai.lua
[CREATE NEW] → TO ai/strategic/resource_ai.lua
[CREATE NEW] → TO ai/diplomacy/diplomacy_ai.lua
```

### Lore Reorganization
```
KEEP lore/calendar.lua
FROM lore/campaign_system.lua → TO lore/campaign/campaign_system.lua
FROM lore/campaign_manager.lua → TO lore/campaign/campaign_manager.lua
FROM lore/mission.lua → TO lore/missions/mission.lua
FROM lore/mission_system.lua → TO lore/missions/mission_system.lua
FROM lore/faction_system.lua → TO lore/factions/faction_system.lua
[CREATE NEW] → TO lore/events/
[CREATE NEW] → TO lore/quests/
```

### Basescape Reorganization
```
REMOVE basescape/init.lua (moved to scenes/)
REMOVE basescape/logic/research_system.lua (moved to economy/)
FROM shared/facilities/facility_system.lua → TO basescape/facilities/facility_system.lua
FROM shared/facilities/facility_types.lua → TO basescape/facilities/facility_types.lua
[CREATE NEW] → TO basescape/base/base.lua
[CREATE NEW] → TO basescape/base/base_grid.lua
[CREATE NEW] → TO basescape/base/base_builder.lua
[CREATE NEW] → TO basescape/services/storage_service.lua
[CREATE NEW] → TO basescape/services/medical_service.lua
[CREATE NEW] → TO basescape/services/training_service.lua
```

### Geoscape Reorganization
```
REMOVE geoscape/init.lua (moved to scenes/)
FROM geoscape/world_state.lua → TO geoscape/world/world_state.lua
FROM geoscape/logic/world.lua → TO geoscape/world/world.lua
FROM geoscape/rendering/world_renderer.lua → TO geoscape/world/world_renderer.lua
FROM geoscape/biomes.lua → TO geoscape/geography/biomes.lua
FROM geoscape/logic/province.lua → TO geoscape/geography/province.lua
FROM geoscape/logic/province_graph.lua → TO geoscape/geography/province_graph.lua
[CREATE NEW] → TO geoscape/geography/region.lua
[CREATE NEW] → TO geoscape/geography/country.lua
[CREATE NEW] → TO geoscape/geography/terrain.lua
FROM geoscape/systems/hex_grid.lua → TO geoscape/systems/hex_grid.lua (KEEP)
FROM geoscape/systems/daynight_cycle.lua → TO geoscape/systems/daynight_cycle.lua (KEEP)
FROM geoscape/systems/detection_manager.lua → TO geoscape/systems/detection_manager.lua (KEEP)
KEEP geoscape/ui/ (input, render)
REMOVE geoscape/logic/marketplace_system.lua (moved to economy/)
REMOVE geoscape/logic/black_market_system.lua (moved to economy/)
REMOVE geoscape/logic/salvage_system.lua (moved to economy/)
REMOVE geoscape/systems/karma_system.lua (moved to politics/)
REMOVE geoscape/systems/fame_system.lua (moved to politics/)
REMOVE geoscape/systems/reputation_system.lua (moved to politics/)
REMOVE geoscape/systems/relations_manager.lua (moved to politics/)
```

### Battlescape Reorganization
```
REMOVE battlescape/init.lua (moved to scenes/)
KEEP battlescape/combat/ (mostly unchanged)
KEEP battlescape/rendering/ (unchanged)
KEEP battlescape/effects/ (unchanged)
KEEP battlescape/entities/ (unchanged)
KEEP battlescape/data/ (unchanged)
KEEP battlescape/utils/ (unchanged)

FROM battlescape/map/*.lua → TO battlescape/maps/*.lua
FROM battlescape/logic/battlefield.lua → TO battlescape/battlefield/battlefield.lua
FROM battlescape/logic/turn_manager.lua → TO battlescape/battlefield/turn_manager.lua
FROM battlescape/logic/team_placement.lua → TO battlescape/battlefield/team_placement.lua
FROM battlescape/logic/objectives_system.lua → TO battlescape/battlefield/objectives_system.lua

FROM battlescape/battle/*.lua → TO battlescape/battle_ecs/*.lua

FROM battlescape/logic/mapscript_executor.lua → TO battlescape/mapscripts/mapscript_executor.lua
FROM battlescape/logic/mapscript_selector.lua → TO battlescape/mapscripts/mapscript_selector.lua
FROM battlescape/logic/terrain_selector.lua → TO battlescape/mapscripts/terrain_selector.lua
FROM battlescape/logic/mapscript_commands/*.lua → TO battlescape/mapscripts/commands/*.lua

KEEP battlescape/logic/integration.lua → TO battlescape/logic/integration.lua
KEEP battlescape/logic/unit_selection.lua → TO battlescape/logic/unit_selection.lua
KEEP battlescape/logic/unit_recovery.lua → TO battlescape/logic/unit_recovery.lua
KEEP battlescape/logic/unit_progression.lua → TO battlescape/logic/unit_progression.lua

KEEP battlescape/ui/ (mostly unchanged - these are components not screens)
REMOVE from battlescape/ui/ any full screen implementations → move to scenes/
```

### Assets Reorganization
```
FROM core/assets.lua → TO assets/assets.lua
[CREATE NEW] → TO assets/image_loader.lua
[CREATE NEW] → TO assets/audio_loader.lua
[CREATE NEW] → TO assets/font_loader.lua
KEEP assets/data/
KEEP assets/fonts/
KEEP assets/images/
KEEP assets/sounds/
```

### Mods (NEW folder)
```
FROM core/mod_manager.lua → TO mods/mod_manager.lua
[CREATE NEW] → TO mods/mod_loader.lua
[CREATE NEW] → TO mods/mod_validator.lua
```

### Core Simplification
```
KEEP core/state_manager.lua
FROM core/data_loader.lua → TO core/data_loader.lua (KEEP)
KEEP core/save_system.lua
FROM core/audio_system.lua → TO core/audio_system.lua (KEEP)
[CREATE NEW] → TO core/input_manager.lua
[CREATE NEW] → TO core/config.lua
REMOVE core/assets.lua (moved to assets/)
REMOVE core/mod_manager.lua (moved to mods/)
REMOVE core/pathfinding.lua (moved to ai/)
REMOVE core/team.lua (DEPRECATED - moved to battle systems)
REMOVE core/ui.lua (DEPRECATED - use state_manager)
REMOVE core/mapblock_validator.lua (move to tools/ or battlescape/maps/)
REMOVE core/spatial_hash.lua (move to utils/)
```

### Shared Simplification
```
KEEP shared/units/
KEEP shared/crafts/
KEEP shared/items/
REMOVE shared/facilities/ (moved to basescape/)
[CREATE NEW] → TO shared/terrain/terrain_types.lua
[CREATE NEW] → TO shared/data/constants.lua
```

### Utils Additions
```
KEEP utils/viewport.lua
KEEP utils/scaling.lua
KEEP utils/toml.lua
KEEP utils/verify_assets.lua
KEEP utils/love.lua
[CREATE NEW] → TO utils/helpers.lua
FROM core/spatial_hash.lua → TO utils/spatial_hash.lua
```

---

## Require Path Updates

### Before (Examples)
```lua
local Geoscape = require("geoscape.init")
local Battlescape = require("battlescape.init")
local Basescape = require("basescape.init")
local ResearchSystem = require("basescape.logic.research_system")
local KarmaSystem = require("geoscape.systems.karma_system")
local DecisionSystem = require("battlescape.ai.decision_system")
local ModManager = require("core.mod_manager")
```

### After (Examples)
```lua
local GeoscapeScreen = require("scenes.geoscape_screen")
local BattlescapeScreen = require("scenes.battlescape_screen")
local BasescapeScreen = require("scenes.basescape_screen")
local ResearchSystem = require("economy.research.research_system")
local KarmaSystem = require("politics.karma.karma_system")
local DecisionSystem = require("ai.tactical.decision_system")
local ModManager = require("mods.mod_manager")
```

---

## Implementation Checklist

### Phase 1: Planning & Documentation
- [x] Create comprehensive restructure plan
- [ ] Document all file movements
- [ ] Create migration scripts
- [ ] Update PROJECT_STRUCTURE.md
- [ ] Update API.md with new paths
- [ ] Update DEVELOPMENT.md workflow

### Phase 2: Create Structure
- [ ] Create all new folders in engine/
- [ ] Create placeholder README.md in each new folder
- [ ] Document folder purpose and contents

### Phase 3: Move Core Systems (Low Risk)
- [ ] Move core/ files (update paths)
- [ ] Move utils/ files
- [ ] Move widgets/ (should be no changes)
- [ ] Test: Verify widgets demo still works

### Phase 4: Extract Scenes (Medium Risk)
- [ ] Create scenes/ folder
- [ ] Move ui/main_menu.lua → scenes/main_menu.lua
- [ ] Move ui/tests_menu.lua → scenes/tests_menu.lua
- [ ] Move ui/widget_showcase.lua → scenes/widget_showcase.lua
- [ ] Update state_manager.lua to use new paths
- [ ] Test: Verify menu navigation works

### Phase 5: Reorganize Geoscape (Medium Risk)
- [ ] Create geoscape/world/, geography/, systems/, ui/
- [ ] Move files according to map
- [ ] Update all geoscape require() paths
- [ ] Update scenes/geoscape_screen.lua
- [ ] Test: Verify geoscape loads and displays

### Phase 6: Reorganize Basescape (Low Risk)
- [ ] Create basescape/base/, facilities/, services/
- [ ] Move files according to map
- [ ] Update all basescape require() paths
- [ ] Update scenes/basescape_screen.lua
- [ ] Test: Verify basescape loads

### Phase 7: Reorganize Battlescape (HIGH RISK)
- [ ] Create all battlescape subfolders
- [ ] Move combat/ (minimal changes)
- [ ] Move and rename map/ → maps/
- [ ] Move and rename battle/ → battle_ecs/
- [ ] Create battlefield/ and move files
- [ ] Create mapscripts/ and move files
- [ ] Reorganize logic/
- [ ] Keep rendering/, effects/, entities/, data/, utils/, ui/
- [ ] Update all battlescape require() paths (MANY)
- [ ] Update scenes/battlescape_screen.lua
- [ ] Test: Verify battlescape loads and combat works

### Phase 8: Create Economy (Medium Risk)
- [ ] Create economy/research/, production/, marketplace/, finance/
- [ ] Move research_system from basescape
- [ ] Move manufacturing_system from shared
- [ ] Move marketplace, black_market, salvage from geoscape
- [ ] Create new finance/ systems
- [ ] Update all economy require() paths
- [ ] Test: Verify research and manufacturing work

### Phase 9: Create Politics (Medium Risk)
- [ ] Create politics subfolders
- [ ] Move karma, fame, reputation, relations from geoscape
- [ ] Create new organization/, government/, diplomacy/ systems
- [ ] Update all politics require() paths
- [ ] Test: Verify karma and fame systems work

### Phase 10: Create AI (Low Risk)
- [ ] Create ai/strategic/, tactical/, diplomacy/, pathfinding/
- [ ] Move decision_system from battlescape
- [ ] Move pathfinding from core and battlescape
- [ ] Create new strategic and diplomacy AI
- [ ] Update all AI require() paths
- [ ] Test: Verify tactical AI works in battle

### Phase 11: Reorganize Lore (Low Risk)
- [ ] Create lore/campaign/, missions/, factions/, events/, quests/
- [ ] Move existing files
- [ ] Create new event and quest systems
- [ ] Update all lore require() paths
- [ ] Test: Verify campaign and missions load

### Phase 12: Create Mods (Low Risk)
- [ ] Create mods/ folder
- [ ] Move mod_manager from core
- [ ] Create mod_loader and mod_validator
- [ ] Update mod require() paths
- [ ] Test: Verify mod loading works

### Phase 13: Reorganize Assets (Low Risk)
- [ ] Move assets.lua from core to assets/
- [ ] Create image_loader, audio_loader, font_loader
- [ ] Update asset loading system
- [ ] Update all asset require() paths
- [ ] Test: Verify assets load correctly

### Phase 14: Reorganize Shared (Low Risk)
- [ ] Create shared/terrain/ and shared/data/
- [ ] Move facilities to basescape
- [ ] Add new shared systems
- [ ] Update all shared require() paths
- [ ] Test: Verify units and items load

### Phase 15: Testing & Validation
- [ ] Run full game test (all screens)
- [ ] Run unit tests (update paths)
- [ ] Run integration tests (update paths)
- [ ] Fix any broken require() paths
- [ ] Verify all assets load
- [ ] Verify all screens navigate correctly

### Phase 16: Documentation Updates
- [ ] Update PROJECT_STRUCTURE.md
- [ ] Update API.md
- [ ] Update FAQ.md
- [ ] Update DEVELOPMENT.md
- [ ] Update copilot-instructions.md
- [ ] Create MIGRATION_GUIDE.md for future developers

### Phase 17: Cleanup
- [ ] Remove old empty folders
- [ ] Remove deprecated files
- [ ] Update .luarc.json if needed
- [ ] Update tasks/tasks.md
- [ ] Move this task to DONE/

---

## Testing Strategy

### Unit Tests
- Update all test require() paths in tests/ folder
- Run each layer's tests independently
- Verify no broken dependencies

### Integration Tests
- Test screen transitions
- Test cross-layer communication
- Test mod loading

### Manual Testing
1. **Main Menu**: Launch game, verify menu loads
2. **Geoscape**: Enter geoscape, verify world displays
3. **Basescape**: Enter basescape, verify base displays
4. **Battlescape**: Start battle, verify combat works
5. **Interception**: Test interception screen
6. **Research**: Test research screen
7. **Manufacturing**: Test manufacturing screen
8. **Marketplace**: Test marketplace
9. **Widgets**: Test widget showcase

---

## Risk Assessment

### Low Risk
- Moving core/ files (few dependencies)
- Moving utils/ files (pure utilities)
- Creating new folders
- Moving lore/ files (self-contained)
- Moving mods/ (single system)

### Medium Risk
- Extracting scenes (changes state management)
- Reorganizing geoscape (many files)
- Creating economy folder (cross-layer)
- Creating politics folder (cross-layer)
- Reorganizing basescape (dependencies)

### HIGH Risk
- Reorganizing battlescape (MANY files, MANY dependencies)
- Moving AI systems (affects combat)
- Updating all require() paths (hundreds of changes)

### Mitigation Strategies
1. **Incremental migration**: Do one phase at a time
2. **Test after each phase**: Don't move forward until tests pass
3. **Backup frequently**: Commit after each successful phase
4. **Document changes**: Keep detailed log of what changed
5. **Battlescape last**: Save highest risk for when experience is gained

---

## Benefits of New Structure

### For Developers
- **Easier navigation**: Know exactly where to find features
- **Faster development**: Add new features without restructuring
- **Better testing**: Test feature groups independently
- **Clear boundaries**: Understand system dependencies

### For AI Agents
- **Better context**: Feature folders give clear semantic meaning
- **Faster search**: Find related files quickly
- **Clear patterns**: Consistent organization across features
- **Less confusion**: No ambiguity about where files belong

### For Maintainability
- **Scalable**: Easy to add new features
- **Modular**: Replace/refactor systems independently
- **Documented**: Folder structure is self-documenting
- **Future-proof**: Supports planned features (quests, events, diplomacy)

---

## Future-Proofing Considerations

### Already Planned For
- **Economy**: Research, manufacturing, marketplace, finance
- **Politics**: Organization, karma, government, fame, relations, diplomacy
- **Lore**: Campaign, missions, factions, events, quests
- **AI**: Strategic, tactical, diplomacy AI with shared pathfinding
- **Scenes**: All screens in one place, easy to add new ones

### Additional Folders Recommended
1. **network/** - For future multiplayer
2. **localization/** - For multi-language support
3. **analytics/** - For gameplay metrics
4. **accessibility/** - For accessibility features
5. **tutorial/** - For tutorial system

### Extensibility Points
- Each layer folder can add new subfolders as needed
- Scenes folder can add unlimited new screens
- AI folder can add new AI types (squad AI, base AI, etc.)
- Economy can add trading, stock market, etc.
- Politics can add elections, coups, etc.

---

## Estimated Time

- **Planning & Documentation**: 2-3 hours
- **Phase 1-2 (Structure creation)**: 1 hour
- **Phase 3-6 (Core, Scenes, Geoscape, Basescape)**: 4-6 hours
- **Phase 7 (Battlescape - HIGH RISK)**: 8-12 hours
- **Phase 8-14 (New folders)**: 6-8 hours
- **Phase 15-17 (Testing, Documentation, Cleanup)**: 4-6 hours

**Total Estimated Time**: 25-38 hours

**Recommendation**: Break into multiple work sessions, test after each phase.

---

## Success Criteria

- [ ] All files moved to new structure
- [ ] All require() paths updated
- [ ] Game launches without errors
- [ ] All screens navigate correctly
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No broken dependencies
- [ ] Widget demo works
- [ ] Combat works in battlescape
- [ ] Research/manufacturing works
- [ ] Geoscape displays correctly

---

## Notes

- This is a LARGE refactor touching ~500 files
- Must be done incrementally with testing
- High risk phase is battlescape reorganization
- Benefits are substantial for long-term maintenance
- Structure supports all planned future features
- Clear separation of concerns achieved

---

## References

- Current structure: `wiki/PROJECT_STRUCTURE.md`
- API documentation: `wiki/API.md`
- Copilot instructions: `.github/copilot-instructions.md`
- File list: See file_search results (474 Lua files)
