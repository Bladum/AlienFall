# Task: Mission Deployment & Planning Screen

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a pre-battle mission deployment and planning screen where players can assign units to multiple landing zones based on map size. This screen shows critical mission information (objective sectors, defended/captured blocks) and allows strategic unit placement before combat begins, similar to Sudden Strike's pre-mission planning panel.

---

## Purpose

**Why is this needed?**
- Provides strategic depth by allowing players to position units across multiple entry points
- Gives players tactical information about mission objectives before battle
- Enables better tactical planning by showing key map sectors
- Follows classic tactical game design (Sudden Strike, Silent Storm) for pre-battle preparation
- Scales naturally with mission difficulty through variable landing zone counts

**What problem does it solve?**
- Currently all units spawn in a single location with no planning phase
- Players have no visibility of mission objectives before combat starts
- No way to strategically position squads at different map entry points
- Mission difficulty scaling lacks deployment complexity dimension

---

## Requirements

### Functional Requirements
- [ ] Map size determines landing zone count (small=1, medium=2, large=3, huge=4)
- [ ] Maps are built from 15×15 tile MapBlocks arranged in grids (4×4 to 7×7)
- [ ] Player can see which MapBlocks contain objectives (defend/capture/critical sectors)
- [ ] Player can assign available units to landing zones before battle
- [ ] Each landing zone is a specific MapBlock on the battle map
- [ ] Visual map overview showing all MapBlocks with objective markers
- [ ] Drag-and-drop or list-based unit assignment interface
- [ ] Clear visual distinction between landing zones and objective sectors
- [ ] Validation that at least one unit is assigned to a landing zone
- [ ] Ability to proceed to battle once deployment is complete

### Technical Requirements
- [ ] New game state: `deployment_planning` between geoscape mission selection and battlescape
- [ ] MapBlock metadata system for objective marking (defend, capture, critical)
- [ ] Landing zone selection algorithm based on map size and layout
- [ ] Unit roster integration with current squad/craft assignment
- [ ] Grid-based UI respecting 24×24 pixel snap rules
- [ ] State transition: Mission Select → Deployment Planning → Battlescape
- [ ] Data structure for deployment configuration passed to battlescape
- [ ] Widget system integration for unit cards and map display

### Acceptance Criteria
- [ ] Deployment screen appears after mission selection, before battle
- [ ] Map overview shows all MapBlocks with correct size (4×4, 5×5, 6×6, or 7×7)
- [ ] Landing zones visually distinct (e.g., green highlight)
- [ ] Objective MapBlocks visually distinct (e.g., yellow=defend, red=capture)
- [ ] Player can assign all available units to landing zones
- [ ] Cannot proceed if any landing zone is empty (configurable requirement)
- [ ] "Start Battle" button transitions to battlescape with units at landing zones
- [ ] Units spawn at correct positions within their assigned MapBlock landing zones
- [ ] Map generation respects landing zone MapBlock selections

---

## Plan

### Step 1: Data Structures & MapBlock Metadata (6 hours)
**Description:** Define data structures for mission deployment, landing zones, and MapBlock objective types

**Files to create:**
- `engine/battlescape/logic/deployment_config.lua` - Deployment configuration
- `engine/battlescape/logic/landing_zone.lua` - Landing zone definition
- `engine/battlescape/map/mapblock_metadata.lua` - Objective metadata for MapBlocks

**Data Structures:**
```lua
-- DeploymentConfig
{
    missionId = "mission_001",
    mapSize = "medium",  -- "small", "medium", "large", "huge"
    mapBlockGrid = 5,    -- 4-7 (grid dimensions)
    
    landingZones = {
        {
            id = "lz_1",
            mapBlockIndex = 12,  -- Which MapBlock (0-indexed in grid)
            position = {x = 2, y = 1},  -- Grid position
            spawnPoints = {      -- Tile positions within MapBlock
                {x = 7, y = 3},
                {x = 7, y = 5},
                {x = 7, y = 7},
            },
            assignedUnits = {}  -- Unit IDs assigned to this zone
        }
    },
    
    objectiveBlocks = {
        {
            mapBlockIndex = 18,
            objectiveType = "defend",  -- "defend", "capture", "critical"
            position = {x = 3, y = 2}
        }
    },
    
    availableUnits = {
        -- List of unit definitions from squad/craft
    }
}
```

**MapBlock Metadata:**
```lua
-- In MapBlock structure
{
    -- Existing fields...
    metadata = {
        isLandingZone = false,
        objectiveType = nil,  -- "defend", "capture", "critical", nil
        isObjectiveBlock = false,
        spawnPoints = {}  -- Pre-defined spawn positions for units
    }
}
```

**Estimated time:** 6 hours

---

### Step 2: Landing Zone Selection Algorithm (8 hours)
**Description:** Algorithm to automatically select appropriate MapBlocks as landing zones based on map size and layout

**Files to create:**
- `engine/battlescape/logic/landing_zone_selector.lua`

**Algorithm Requirements:**
- Select N landing zones based on map size (1-4)
- Prefer edge/corner MapBlocks for landing zones
- Ensure landing zones are spatially distributed (not clustered)
- Avoid placing landing zones in objective MapBlocks if possible
- Generate spawn points within each landing zone MapBlock
- Validate landing zone accessibility and fairness

**Implementation:**
```lua
LandingZoneSelector = {}

function LandingZoneSelector:selectLandingZones(mapGrid, mapSize)
    local count = self:getLandingZoneCount(mapSize)
    local candidates = self:getEdgeMapBlocks(mapGrid)
    local selected = self:distributedSelection(candidates, count)
    
    for _, block in ipairs(selected) do
        block.metadata.isLandingZone = true
        block.metadata.spawnPoints = self:generateSpawnPoints(block)
    end
    
    return selected
end

function LandingZoneSelector:getLandingZoneCount(mapSize)
    -- small=1, medium=2, large=3, huge=4
    local counts = {small = 1, medium = 2, large = 3, huge = 4}
    return counts[mapSize] or 1
end

function LandingZoneSelector:getEdgeMapBlocks(mapGrid)
    -- Return MapBlocks on the grid edges/corners
end

function LandingZoneSelector:distributedSelection(candidates, count)
    -- Select 'count' blocks with maximum spatial distribution
    -- Use distance metrics to ensure spread
end

function LandingZoneSelector:generateSpawnPoints(mapBlock)
    -- Generate 4-8 spawn positions within the 15×15 MapBlock
    -- Prefer open terrain near the edge
    -- Return tile coordinates relative to MapBlock origin
end
```

**Estimated time:** 8 hours

---

### Step 3: Deployment Planning Game State (10 hours)
**Description:** New game state for deployment planning screen with full logic

**Files to create:**
- `engine/modules/deployment_planning.lua` - Main state module
- `engine/modules/deployment_planning/init.lua`
- `engine/modules/deployment_planning/logic.lua`
- `engine/modules/deployment_planning/render.lua`
- `engine/modules/deployment_planning/input.lua`

**State Flow:**
1. Mission selected on Geoscape → Generate deployment config
2. Enter `deployment_planning` state with config
3. Player assigns units to landing zones
4. Validate deployment (all zones have units, etc.)
5. Transition to `battlescape` state with deployment data

**DeploymentPlanning Module:**
```lua
local StateManager = require("core.state_manager")
local DeploymentConfig = require("battlescape.logic.deployment_config")

local DeploymentPlanning = {}

function DeploymentPlanning.enter(missionData)
    -- Generate deployment configuration
    local config = DeploymentConfig.generate(missionData)
    
    -- Initialize UI state
    DeploymentPlanning.config = config
    DeploymentPlanning.selectedUnit = nil
    DeploymentPlanning.hoveredZone = nil
    DeploymentPlanning.camera = Camera.new()
    
    -- Create UI widgets
    DeploymentPlanning:initUI()
end

function DeploymentPlanning.update(dt)
    -- Update UI state
end

function DeploymentPlanning.draw()
    -- Render deployment screen
end

function DeploymentPlanning.mousepressed(x, y, button)
    -- Handle unit assignment clicks
end

function DeploymentPlanning:assignUnitToZone(unitId, zoneId)
    -- Move unit from available pool to landing zone
    -- Update UI state
end

function DeploymentPlanning:validateDeployment()
    -- Check all zones have at least one unit (configurable)
    -- Check all units are assigned
    return valid, errorMessage
end

function DeploymentPlanning:startBattle()
    local valid, err = self:validateDeployment()
    if not valid then
        self:showError(err)
        return
    end
    
    StateManager.setState("battlescape", self.config)
end
```

**Estimated time:** 10 hours

---

### Step 4: Deployment Planning UI (12 hours)
**Description:** Visual interface for deployment planning with map overview and unit assignment

**Files to create:**
- `engine/modules/deployment_planning/ui/map_overview.lua`
- `engine/modules/deployment_planning/ui/unit_roster.lua`
- `engine/modules/deployment_planning/ui/landing_zone_panel.lua`

**UI Layout (960×720, 24px grid):**
```
┌─────────────────────────────────────────┐
│  Mission: [Name]    Map: [Size]         │ 24px header
├─────────────────────────────────────────┤
│                                          │
│      ┌─────────────────┐                │
│      │                 │                │ Map Overview
│      │   Map Grid      │  Unit Roster   │ (center-left)
│      │   Overview      │  - Unit 1      │
│      │   (MapBlocks)   │  - Unit 2      │ Unit Roster
│      │                 │  - Unit 3      │ (right panel)
│      └─────────────────┘  - Unit 4      │
│                                          │
│  Landing Zones:                          │ Landing Zone
│  [LZ1: 2 units] [LZ2: 1 unit] ...       │ Status Bar
├─────────────────────────────────────────┤
│  [Cancel] [Start Battle]                │ 48px footer
└─────────────────────────────────────────┘
```

**Map Overview Widget:**
- Render MapBlock grid (4×4 to 7×7)
- Each MapBlock rendered as colored square
- Landing zones: Green border/fill
- Objective blocks: Yellow (defend), Red (capture), Blue (critical)
- Hovering shows MapBlock details
- Clicking landing zone selects it for unit assignment

**Unit Roster Widget:**
- List of available units (not yet assigned)
- Unit card shows: Name, portrait, class, stats
- Drag-and-drop or click-to-assign interaction
- Visual feedback when unit assigned

**Landing Zone Panel:**
- Shows all landing zones with assigned unit count
- Click to select landing zone for assignment
- Visual indicator of selected zone

**Estimated time:** 12 hours

---

### Step 5: Battlescape Integration (8 hours)
**Description:** Modify battlescape initialization to use deployment configuration

**Files to modify:**
- `engine/battlescape/ui/logic.lua` - Accept deployment config
- `engine/battlescape/logic/battlefield.lua` - Unit spawning from deployment
- `engine/modules/battlescape/init.lua` - Entry point with deployment

**Changes:**
1. Battlescape.enter() accepts optional `deploymentConfig` parameter
2. If deployment config present, use it for unit placement
3. Otherwise, use default single-zone spawning (backward compatibility)
4. Map generation respects landing zone MapBlock selections
5. Units spawn at designated spawn points within MapBlocks

**Implementation:**
```lua
-- In battlescape/ui/logic.lua
function BattlescapeLogic:initUnits(battlescape, deploymentConfig)
    battlescape.units = {}
    
    if deploymentConfig then
        -- Use deployment configuration
        for _, zone in ipairs(deploymentConfig.landingZones) do
            for i, unitDef in ipairs(zone.assignedUnits) do
                local spawnPoint = zone.spawnPoints[i]
                local worldX, worldY = self:mapBlockToWorld(
                    zone.mapBlockIndex,
                    spawnPoint.x,
                    spawnPoint.y
                )
                
                local unit = Unit.new(
                    unitDef.type,
                    battlescape.teams[1],
                    worldX,
                    worldY
                )
                unit.deploymentZone = zone.id
                table.insert(battlescape.units, unit)
                battlescape.teams[1]:addUnit(unit)
            end
        end
    else
        -- Default spawning (backward compatibility)
        self:spawnDefaultUnits(battlescape)
    end
end

function BattlescapeLogic:mapBlockToWorld(blockIndex, localX, localY)
    -- Convert MapBlock grid index + local tile coords to world coords
    local gridSize = self.battlefield.mapBlockGridSize
    local blockX = blockIndex % gridSize
    local blockY = math.floor(blockIndex / gridSize)
    
    local worldX = (blockX * 15 + localX) * TILE_SIZE
    local worldY = (blockY * 15 + localY) * TILE_SIZE
    
    return worldX, worldY
end
```

**Estimated time:** 8 hours

---

### Step 6: State Transition Flow (4 hours)
**Description:** Connect geoscape → deployment → battlescape state flow

**Files to modify:**
- `engine/geoscape/ui/mission_panel.lua` - "Launch Mission" button
- `engine/core/state_manager.lua` - State registration

**Flow:**
```lua
-- In Geoscape, when launching mission:
function MissionPanel:launchMission(mission)
    local missionData = {
        missionId = mission.id,
        mapSize = mission:getMapSize(),
        biome = mission.biome,
        difficulty = mission.difficulty,
        squad = self:getCurrentSquad(),
        craft = self:getCurrentCraft()
    }
    
    StateManager.setState("deployment_planning", missionData)
end

-- In DeploymentPlanning, when starting battle:
function DeploymentPlanning:startBattle()
    StateManager.setState("battlescape", {
        deploymentConfig = self.config,
        missionData = self.missionData
    })
end
```

**Estimated time:** 4 hours

---

### Step 7: Testing & Validation (6 hours)
**Description:** Test deployment system with various map sizes and configurations

**Test Cases:**
- Small map (4×4): 1 landing zone
- Medium map (5×5): 2 landing zones
- Large map (6×6): 3 landing zones
- Huge map (7×7): 4 landing zones
- Landing zones are properly distributed
- Objective MapBlocks correctly marked
- Units spawn at correct positions
- Deployment validation works
- State transitions smooth
- UI responsive and clear
- Edge cases (no units, all units in one zone, etc.)

**Manual Testing Steps:**
1. Run game with Love2D console: `lovec "engine"`
2. Navigate to Geoscape, select mission
3. Verify deployment screen appears
4. Assign units to landing zones
5. Verify map overview shows correct layout
6. Click "Start Battle"
7. Verify units spawn at correct positions
8. Test with different map sizes
9. Test validation (empty zones, etc.)
10. Test Cancel button returns to geoscape

**Estimated time:** 6 hours

---

## Implementation Details

### Architecture

**State Machine Pattern:**
- New `deployment_planning` state between geoscape and battlescape
- Self-contained module with init/logic/render/input separation
- Clean data flow through deployment configuration object

**Map Generation Integration:**
- MapBlock system already supports 15×15 tile blocks
- Landing zone selection happens during/after map generation
- Metadata system extends MapBlock without breaking existing code

**Widget System:**
- Map overview as custom widget
- Unit roster uses existing list/card widgets
- Grid-snapped UI following 24×24 pixel rules

### Key Components

- **DeploymentConfig:** Central data structure for mission deployment
- **LandingZoneSelector:** Algorithm for intelligent landing zone placement
- **DeploymentPlanning State:** Game state with full UI logic
- **MapOverview Widget:** Visual map display with objective markers
- **UnitRoster Widget:** Unit assignment interface
- **Battlescape Integration:** Modified unit spawning system

### Dependencies

- MapBlock system (already implemented)
- Map generation system (already implemented)
- Widget system (already implemented)
- State manager (already implemented)
- Geoscape mission system (TASK-026, TASK-027)
- Squad/craft management (to be implemented or mocked)

---

## Testing Strategy

### Unit Tests

**DeploymentConfig:**
- Test configuration generation from mission data
- Test landing zone count calculation
- Test objective block marking

**LandingZoneSelector:**
- Test edge MapBlock detection
- Test distributed selection algorithm
- Test spawn point generation within MapBlocks
- Test validation of landing zone placement

**Data Structure Validation:**
- Test DeploymentConfig serialization
- Test landing zone assignment/removal
- Test unit roster management

### Integration Tests

**State Transitions:**
- Geoscape → Deployment Planning
- Deployment Planning → Battlescape
- Deployment Planning → Geoscape (cancel)

**Map Generation:**
- Test MapBlock metadata persistence
- Test landing zone MapBlock selection
- Test objective block marking during generation

**Unit Spawning:**
- Test units spawn at correct world positions
- Test multiple landing zones with multiple units
- Test backward compatibility (no deployment config)

### Manual Testing Steps

1. **Small Mission (4×4 map):**
   - Select small mission from geoscape
   - Verify 1 landing zone shown
   - Assign 4 units to landing zone
   - Start battle, verify units spawn correctly

2. **Medium Mission (5×5 map):**
   - Select medium mission
   - Verify 2 landing zones shown
   - Assign 2 units to each zone
   - Verify zones are spatially separated
   - Start battle, verify correct spawning

3. **Large Mission (6×6 map):**
   - Select large mission
   - Verify 3 landing zones
   - Test different unit distributions (3-1-0, 2-2-0, 2-1-1)
   - Verify validation prevents empty zones (if enabled)

4. **Huge Mission (7×7 map):**
   - Select huge mission
   - Verify 4 landing zones at map corners/edges
   - Assign units across all zones
   - Verify objective blocks are distinct from landing zones

5. **UI Interaction:**
   - Test drag-and-drop unit assignment
   - Test clicking unit then clicking zone
   - Test hover effects on map overview
   - Test landing zone selection highlighting
   - Test Cancel button returns to geoscape

6. **Edge Cases:**
   - Try to start battle with empty landing zones
   - Try to assign more units than available
   - Try to assign unit to multiple zones
   - Test with squad of 1 unit vs 12 units

### Expected Results

- Deployment screen transitions smoothly from geoscape
- Map overview clearly shows landing zones and objectives
- Unit assignment is intuitive and responsive
- Validation prevents invalid deployments
- Battlescape units spawn at correct positions
- System works with all map sizes (4×4 to 7×7)
- No console errors or warnings

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game" (Ctrl+Shift+P > Tasks: Run Task > Run XCOM Simple Game)

### Debugging

**Love2D Console:**
- Console enabled in `conf.lua` (t.console = true)
- All debug output visible in console window

**Debug Print Statements:**
```lua
print("[DeploymentPlanning] Entering state with mission: " .. missionData.missionId)
print("[LandingZone] Selected " .. #zones .. " landing zones for " .. mapSize .. " map")
print("[MapOverview] Rendering " .. gridSize .. "×" .. gridSize .. " MapBlock grid")
print("[UnitAssignment] Assigned unit " .. unit.name .. " to zone " .. zone.id)
```

**On-Screen Debug:**
```lua
-- In deployment_planning/render.lua
love.graphics.print("Map Size: " .. self.config.mapSize, 10, 10)
love.graphics.print("Landing Zones: " .. #self.config.landingZones, 10, 30)
love.graphics.print("Units: " .. #self.config.availableUnits, 10, 50)
```

**Debug Visualization:**
- F9: Toggle grid overlay on deployment screen
- F10: Toggle MapBlock indices on map overview
- F11: Toggle spawn point visualization

### Temporary Files

- All temporary files use: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- No temp files in project directories
- Deployment config can be saved to temp for debugging:
  ```lua
  local tempPath = os.getenv("TEMP") .. "\\deployment_debug.json"
  ```

---

## Documentation Updates

### Files to Update

- [x] `tasks/tasks.md` - Add TASK-029 to active high priority tasks
- [ ] `wiki/API.md` - Document DeploymentConfig, LandingZone, DeploymentPlanning state APIs
- [ ] `wiki/FAQ.md` - Add section on deployment planning screen usage
- [ ] `wiki/DEVELOPMENT.md` - Add deployment system architecture notes
- [ ] `wiki/wiki/maps.md` - Document landing zone selection and MapBlock metadata
- [ ] `wiki/wiki/missions.md` - Add deployment planning to mission flow
- [ ] Code comments - Full documentation in all new modules

---

## Notes

**Design Considerations:**
- Landing zone count scales naturally with map size (1-4)
- MapBlock-based approach ensures clean integration with existing map system
- Spawn points within MapBlocks allow fine-grained unit placement
- Objective visualization gives players tactical foresight
- Validation can be made configurable (allow empty zones, minimum units per zone, etc.)

**Future Enhancements:**
- AI-suggested optimal deployment based on mission type
- Save/load deployment templates for quick setup
- Pre-mission intel showing enemy expected spawn locations
- Deployment time limit for added challenge
- Unit equipment/loadout selection in deployment screen
- Vehicle/equipment deployment alongside units

**Balancing:**
- More landing zones = more tactical options but harder to defend all
- Landing zone distance from objectives affects mission difficulty
- Spawn point density in MapBlocks affects initial unit clustering

---

## Blockers

**Dependencies:**
- None - can be implemented with current MapBlock and widget systems
- Optional: Squad/craft management system (can be mocked for testing)
- Optional: Geoscape mission selection (TASK-026/027, can use standalone entry for testing)

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Grid snapping for all UI elements (24×24 pixel grid)
- [ ] Theme system used for all visual styling
- [ ] Widget API documented
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in Love2D console
- [ ] State transitions work smoothly
- [ ] Backward compatibility maintained

---

## Post-Completion

### What Worked Well
- (To be filled after implementation)

### What Could Be Improved
- (To be filled after implementation)

### Lessons Learned
- (To be filled after implementation)
