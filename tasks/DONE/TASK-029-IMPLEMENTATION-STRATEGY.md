# TASK-029 IMPLEMENTATION STRATEGY
## Mission Deployment & Planning Screen - Detailed Implementation

**Date:** October 21, 2025  
**Task:** TASK-029 - Mission Deployment Planning  
**Estimated Time:** 35-40 hours  
**Status:** STARTING

---

## Quick Summary

This task implements the pre-battle deployment planning screen where players:
1. See a visual map overview of the mission (4×4 to 7×7 MapBlock grid)
2. View landing zones (1-4 positions where units can spawn)
3. View objective sectors (MapBlocks with mission targets)
4. Assign squad units to landing zones
5. Start battle with units positioned strategically

---

## Architecture Overview

### State Flow

```
Geoscape Mission Select
    ↓
Deployment Planning Screen (NEW - THIS TASK)
    ├─ Show map overview
    ├─ Show available landing zones
    ├─ Show objective markers
    ├─ Allow unit assignment to LZ
    └─ Validate deployment
    ↓
Battlescape
    └─ Units spawn at assigned landing zones
```

### File Structure (11 new files)

```
engine/battlescape/
├── logic/
│   ├── deployment_config.lua           (Data structure for deployment)
│   ├── landing_zone.lua                (Landing zone management)
│   └── deployment_validator.lua        (Validation logic)
├── map/
│   └── mapblock_metadata.lua           (MapBlock objective types)
├── ui/
│   ├── deployment_screen.lua           (Main UI screen)
│   ├── deployment_map_viewer.lua       (Map visualization)
│   ├── landing_zone_selector.lua       (LZ selection UI)
│   ├── unit_assignment_panel.lua       (Unit assignment UI)
│   └── deployment_preview.lua          (Preview before start)
└── scenes/
    └── deployment_scene.lua            (Scene manager for deployment)
```

---

## Detailed Phase Breakdown

### PHASE 1: Core Data Structures (6 hours)
**Goal:** Define all data structures needed for deployment system

#### 1.1 DeploymentConfig (2 hours)
**File:** `engine/battlescape/logic/deployment_config.lua`

```lua
-- Main deployment configuration
DeploymentConfig = {}

function DeploymentConfig.create()
    return {
        missionId = nil,
        mapSize = nil,           -- "small"(1), "medium"(2), "large"(3), "huge"(4)
        mapBlockGrid = nil,      -- Width/height (4-7)
        totalMapBlocks = nil,    -- mapBlockGrid * mapBlockGrid
        
        landingZones = {},       -- List of LZ definitions
        objectiveBlocks = {},    -- List of objective MapBlocks
        availableUnits = {},     -- List of units to deploy
        
        deployment = {},         -- Map: unitId → landingZoneId
        
        validated = false,
        errors = {}
    }
end

function DeploymentConfig:setMapSize(size)
    if size == "small" then self.mapBlockGrid = 4; self.numLZs = 1
    elseif size == "medium" then self.mapBlockGrid = 5; self.numLZs = 2
    elseif size == "large" then self.mapBlockGrid = 6; self.numLZs = 3
    elseif size == "huge" then self.mapBlockGrid = 7; self.numLZs = 4
    end
    self.mapSize = size
    self.totalMapBlocks = self.mapBlockGrid * self.mapBlockGrid
end

function DeploymentConfig:assignUnitToLZ(unitId, lzId)
    self.deployment[unitId] = lzId
end

function DeploymentConfig:getUnitsInLZ(lzId)
    local units = {}
    for unitId, assignedLz in pairs(self.deployment) do
        if assignedLz == lzId then table.insert(units, unitId) end
    end
    return units
end

function DeploymentConfig:isDeploymentComplete()
    return #self.availableUnits > 0 and 
           table.countKeys(self.deployment) == #self.availableUnits
end
```

#### 1.2 LandingZone (2 hours)
**File:** `engine/battlescape/logic/landing_zone.lua`

```lua
LandingZone = {}

function LandingZone.create(id, mapBlockIdx, gridPos, spawnCount)
    return {
        id = id,
        mapBlockIndex = mapBlockIdx,    -- Which MapBlock in grid (0-based)
        gridPosition = gridPos,          -- {x, y} in MapBlock grid
        capacity = spawnCount,           -- How many units can fit
        assignedUnits = {},              -- Unit IDs assigned here
        spawnPoints = {},                -- {x,y} positions within MapBlock
        accessible = true,
        name = "LZ-" .. id
    }
end

function LandingZone:addUnit(unitId)
    if #self.assignedUnits >= self.capacity then
        return false, "Landing zone at capacity"
    end
    table.insert(self.assignedUnits, unitId)
    return true
end

function LandingZone:removeUnit(unitId)
    for i, id in ipairs(self.assignedUnits) do
        if id == unitId then
            table.remove(self.assignedUnits, i)
            return true
        end
    end
    return false
end

function LandingZone:isFull()
    return #self.assignedUnits >= self.capacity
end

function LandingZone:canFitMore()
    return #self.assignedUnits < self.capacity
end
```

#### 1.3 MapBlockMetadata (2 hours)
**File:** `engine/battlescape/map/mapblock_metadata.lua`

```lua
MapBlockMetadata = {}

-- Objective types for MapBlocks
MapBlockMetadata.OBJECTIVE_TYPES = {
    NONE = "none",
    DEFEND = "defend",         -- Must protect/survive here
    CAPTURE = "capture",       -- Must take control here
    CRITICAL = "critical",     -- VIP/high-value target
}

function MapBlockMetadata.create(mapBlockId)
    return {
        mapBlockId = mapBlockId,
        objectiveType = MapBlockMetadata.OBJECTIVE_TYPES.NONE,
        isObjectiveBlock = false,
        isLandingZone = false,
        spawnPoints = {},        -- Pre-defined spawn positions
        environment = "generic",
        difficulty = "normal"
    }
end

function MapBlockMetadata:setObjective(objType)
    if MapBlockMetadata.OBJECTIVE_TYPES[string.upper(objType)] then
        self.objectiveType = objType
        self.isObjectiveBlock = true
        return true
    end
    return false, "Invalid objective type"
end

function MapBlockMetadata:addSpawnPoint(x, y)
    table.insert(self.spawnPoints, {x = x, y = y})
end
```

---

### PHASE 2: Landing Zone Algorithm (8 hours)
**Goal:** Automatically select appropriate MapBlocks as landing zones

#### 2.1 LandingZoneSelector (8 hours)
**File:** `engine/battlescape/logic/landing_zone_selector.lua`

```lua
LandingZoneSelector = {}

-- Algorithm: Select N edge/corner MapBlocks as landing zones
-- Spread them out spatially, avoid objectives
function LandingZoneSelector.selectLandingZones(mapGrid, numNeeded, objectiveBlockIndices)
    local landingZones = {}
    local edgeBlocks = LandingZoneSelector:findEdgeBlocks(mapGrid)
    
    -- Score edge blocks by distance from objectives and from each other
    local scoredBlocks = {}
    for _, blockIdx in ipairs(edgeBlocks) do
        local score = LandingZoneSelector:scoreBlock(blockIdx, mapGrid, objectiveBlockIndices, scoredBlocks)
        table.insert(scoredBlocks, {index = blockIdx, score = score})
    end
    
    -- Sort by score (highest first) and take top N
    table.sort(scoredBlocks, function(a, b) return a.score > b.score end)
    
    for i = 1, math.min(numNeeded, #scoredBlocks) do
        local blockIdx = scoredBlocks[i].index
        local gridPos = LandingZoneSelector:indexToGridPos(blockIdx, mapGrid)
        local lz = LandingZone.create("lz_" .. i, blockIdx, gridPos, 3)
        table.insert(landingZones, lz)
    end
    
    return landingZones
end

function LandingZoneSelector:findEdgeBlocks(mapGrid)
    -- Return MapBlock indices that are on edges/corners of grid
    local edgeBlocks = {}
    local gridSize = mapGrid.width  -- Assuming square grid
    
    for i = 0, gridSize * gridSize - 1 do
        local x, y = LandingZoneSelector:indexToGridPos(i, mapGrid)
        -- Edge/corner blocks: x or y is 0 or max
        if x == 0 or x == gridSize-1 or y == 0 or y == gridSize-1 then
            table.insert(edgeBlocks, i)
        end
    end
    
    return edgeBlocks
end

function LandingZoneSelector:scoreBlock(blockIdx, mapGrid, objectiveIndices, selectedZones)
    local score = 0
    
    -- Penalty if it's an objective block (-100)
    for _, objIdx in ipairs(objectiveIndices) do
        if blockIdx == objIdx then score = score - 100 end
    end
    
    -- Bonus for corner positions (+50)
    local x, y = LandingZoneSelector:indexToGridPos(blockIdx, mapGrid)
    if (x == 0 or x == mapGrid.width-1) and (y == 0 or y == mapGrid.height-1) then
        score = score + 50
    end
    
    -- Penalty for proximity to already-selected zones
    for _, selectedZone in ipairs(selectedZones) do
        local dist = LandingZoneSelector:gridDistance(blockIdx, selectedZone.index, mapGrid)
        score = score - (10 / (dist + 1))  -- Closer = more penalty
    end
    
    return score
end

function LandingZoneSelector:indexToGridPos(index, mapGrid)
    local x = index % mapGrid.width
    local y = math.floor(index / mapGrid.width)
    return x, y
end

function LandingZoneSelector:gridDistance(idx1, idx2, mapGrid)
    local x1, y1 = LandingZoneSelector:indexToGridPos(idx1, mapGrid)
    local x2, y2 = LandingZoneSelector:indexToGridPos(idx2, mapGrid)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
end
```

---

### PHASE 3: UI Implementation (14 hours)

#### 3.1 Deployment Screen Main (5 hours)
**File:** `engine/battlescape/ui/deployment_screen.lua`

```lua
DeploymentScreen = {}

function DeploymentScreen:new(config, onConfirm, onCancel)
    local self = setmetatable({}, {__index = DeploymentScreen})
    self.config = config
    self.onConfirm = onConfirm
    self.onCancel = onCancel
    
    self.mapViewer = DeploymentMapViewer:new(config)
    self.unitPanel = UnitAssignmentPanel:new(config)
    self.preview = DeploymentPreview:new(config)
    
    self.visible = true
    return self
end

function DeploymentScreen:update(dt)
    self.mapViewer:update(dt)
    self.unitPanel:update(dt)
    self.preview:update(dt)
end

function DeploymentScreen:draw()
    -- Layout: Map (left), Units (middle), Preview (right)
    -- 960x720 resolution, 240 width each section
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    -- Map viewer (left third)
    love.graphics.push()
    love.graphics.translate(0, 0)
    self.mapViewer:draw()
    love.graphics.pop()
    
    -- Unit panel (middle third)
    love.graphics.push()
    love.graphics.translate(320, 0)
    self.unitPanel:draw()
    love.graphics.pop()
    
    -- Preview (right third)
    love.graphics.push()
    love.graphics.translate(640, 0)
    self.preview:draw()
    love.graphics.pop()
    
    -- Buttons
    self:drawButtons()
end

function DeploymentScreen:drawButtons()
    -- "Start Battle" button (green, 120x40, bottom right)
    local btnX, btnY = 820, 680
    love.graphics.setColor(0.2, 0.6, 0.2)
    love.graphics.rectangle("fill", btnX, btnY, 120, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Start Battle", btnX, btnY+5, 120, "center")
end

function DeploymentScreen:handleClick(x, y, button)
    -- Check buttons first
    if x >= 820 and x <= 940 and y >= 680 and y <= 710 then
        if self.config:isDeploymentComplete() then
            self.onConfirm(self.config)
        else
            print("Not all units assigned!")
        end
        return
    end
    
    -- Route to components
    self.mapViewer:handleClick(x, y, button)
    self.unitPanel:handleClick(x, y, button)
end
```

#### 3.2 Map Viewer (4 hours)
**File:** `engine/battlescape/ui/deployment_map_viewer.lua`

```lua
DeploymentMapViewer = {}

function DeploymentMapViewer:new(config)
    local self = setmetatable({}, {__index = DeploymentMapViewer})
    self.config = config
    self.cellSize = 240 / config.mapBlockGrid  -- 240x240 viewer
    self.offsetX = 20
    self.offsetY = 20
    return self
end

function DeploymentMapViewer:draw()
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Map Overview", 20, 10, 240, "center")
    
    -- Draw grid
    local gridSize = self.config.mapBlockGrid
    for y = 0, gridSize-1 do
        for x = 0, gridSize-1 do
            local idx = y * gridSize + x
            local px = self.offsetX + x * self.cellSize
            local py = self.offsetY + y * self.cellSize
            
            -- Cell background
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", px, py, self.cellSize-1, self.cellSize-1)
            
            -- Check if it's a landing zone
            local isLZ = false
            for _, lz in ipairs(self.config.landingZones) do
                if lz.mapBlockIndex == idx then
                    love.graphics.setColor(0.2, 0.8, 0.2)  -- Green
                    isLZ = true
                    break
                end
            end
            
            if not isLZ then
                -- Check if it's an objective
                for _, obj in ipairs(self.config.objectiveBlocks) do
                    if obj.mapBlockIndex == idx then
                        local color = (obj.objectiveType == "defend") and 
                                      {0.2, 0.6, 1} or {1, 0.5, 0.2}
                        love.graphics.setColor(unpack(color))
                        break
                    end
                end
            end
            
            love.graphics.rectangle("fill", px, py, self.cellSize-2, self.cellSize-2)
            
            -- Border
            love.graphics.setColor(0.6, 0.6, 0.6)
            love.graphics.rectangle("line", px, py, self.cellSize-1, self.cellSize-1)
        end
    end
    
    -- Legend
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Green=Landing Zones", 20, 200, 200, "left")
    love.graphics.printf("Yellow=Capture", 20, 215, 200, "left")
    love.graphics.printf("Blue=Defend", 20, 230, 200, "left")
end

function DeploymentMapViewer:update(dt) end

function DeploymentMapViewer:handleClick(x, y, button) end
```

#### 3.3 Unit Assignment Panel (3 hours)
**File:** `engine/battlescape/ui/unit_assignment_panel.lua`

```lua
UnitAssignmentPanel = {}

function UnitAssignmentPanel:new(config)
    local self = setmetatable({}, {__index = UnitAssignmentPanel})
    self.config = config
    self.scroll = 0
    self.selectedUnit = nil
    return self
end

function UnitAssignmentPanel:draw()
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Squad", 20, 10, 240, "center")
    
    -- Unassigned units list
    love.graphics.setColor(0.8, 0.2, 0.2)  -- Red background for unassigned
    love.graphics.rectangle("fill", 20, 40, 240, 150)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Unassigned Units:", 25, 45, 235, "left")
    
    local y = 65
    for i, unit in ipairs(self.config.availableUnits) do
        local isAssigned = false
        for unitId, _ in pairs(self.config.deployment) do
            if unitId == unit.id then isAssigned = true; break end
        end
        
        if not isAssigned then
            love.graphics.setColor(0.9, 0.9, 0.9)
            if self.selectedUnit == unit.id then
                love.graphics.setColor(1, 1, 0.5)  -- Highlight
            end
            love.graphics.printf(unit.name or ("Unit " .. unit.id), 25, y, 235, "left")
            y = y + 15
        end
    end
    
    -- Landing zone summaries
    love.graphics.setColor(0.2, 0.5, 0.2)
    love.graphics.rectangle("fill", 20, 200, 240, 150)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Landing Zones:", 25, 205, 235, "left")
    
    y = 225
    for i, lz in ipairs(self.config.landingZones) do
        local unitCount = #lz.assignedUnits
        love.graphics.printf(
            lz.name .. " (" .. unitCount .. "/" .. lz.capacity .. ")",
            25, y, 235, "left"
        )
        y = y + 20
    end
end

function UnitAssignmentPanel:update(dt) end

function UnitAssignmentPanel:handleClick(x, y, button)
    -- Click to select unit, then click LZ to assign
end
```

#### 3.4 Preview Panel (2 hours)
**File:** `engine/battlescape/ui/deployment_preview.lua`

```lua
DeploymentPreview = {}

function DeploymentPreview:new(config)
    local self = setmetatable({}, {__index = DeploymentPreview})
    self.config = config
    return self
end

function DeploymentPreview:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Deployment Summary", 20, 10, 240, "center")
    
    -- Show deployment status
    love.graphics.setColor(0.9, 0.9, 0.9)
    local y = 40
    
    y = y + 20
    love.graphics.printf("Total Units: " .. #self.config.availableUnits, 25, y, 235, "left")
    
    y = y + 20
    local assigned = table.countKeys(self.config.deployment)
    love.graphics.printf("Assigned: " .. assigned, 25, y, 235, "left")
    
    y = y + 20
    local unassigned = #self.config.availableUnits - assigned
    love.graphics.printf("Unassigned: " .. unassigned, 25, y, 235, "left")
    
    -- Status
    y = y + 30
    if self.config:isDeploymentComplete() then
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.printf("✓ Ready to deploy", 25, y, 235, "center")
    else
        love.graphics.setColor(1, 0.5, 0.2)
        love.graphics.printf("⚠ Incomplete deployment", 25, y, 235, "center")
    end
end

function DeploymentPreview:update(dt) end
```

---

### PHASE 4: Scene Integration (3 hours)

#### 4.1 Deployment Scene Manager
**File:** `engine/battlescape/scenes/deployment_scene.lua`

Manages state transitions and scene lifecycle for deployment planning.

---

### PHASE 5: Battlescape Integration (2 hours)

#### 5.1 Unit Spawning Integration
Modify battlescape initialization to:
- Read deployment configuration
- Spawn units at assigned landing zone MapBlocks
- Apply landing zone spawn points

---

### PHASE 6: Testing & Validation (3 hours)

- [ ] Unit assignment UI works correctly
- [ ] Landing zone algorithm produces valid zones
- [ ] Units spawn at correct landing zones in battlescape
- [ ] Deployment cannot proceed without all units assigned
- [ ] MapBlock objective marking works
- [ ] Edge cases handled (1-4 landing zones)

---

## Implementation Order (Recommended)

1. **Day 1 (8h):** Phases 1 & 2 - Data structures and landing zone algorithm
2. **Day 2 (8h):** Phase 3.1 & 3.2 - Main screen and map viewer
3. **Day 3 (8h):** Phase 3.3 & 3.4 - Unit panel and preview
4. **Day 4 (8h):** Phases 4, 5, 6 - Integration, testing, fixes

---

## Success Criteria

- ✅ Deployment screen appears after mission selection
- ✅ Players can see map overview with MapBlocks
- ✅ Landing zones are visually distinct
- ✅ Objectives are marked on map
- ✅ All units assigned to landing zones
- ✅ Cannot start battle until deployment complete
- ✅ Units spawn at correct landing zones in battlescape
- ✅ No errors in console

---

## Notes

- This is the critical blocking task for mission integration
- Depends on existing: Mission system, MapBlock system, UI framework
- Does NOT require: Strategic AI, advanced lore, multiplayer
- High impact: Enables full mission gameplay once complete

