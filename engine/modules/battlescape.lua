-- Battlescape State (Complete Refactor)
-- Turn-based tactical combat on 60x60 tile map
-- Implements: FOW, day/night, teams/sides, TOML terrain, proper GUI

local StateManager = require("systems.state_manager")
local Widgets = require("widgets.init")
local Unit = require("systems.unit")
local Team = require("systems.team")
local ActionSystem = require("systems.action_system")
local Pathfinding = require("systems.pathfinding")
local LOS = require("systems.los_optimized")  -- OPTIMIZED VERSION
local Assets = require("systems.assets")
local AnimationSystem = require("battle.animation_system")

-- Battle components
local Battlefield = require("battle.battlefield")
local Camera = require("battle.camera")
local UnitSelection = require("battle.unit_selection")
local BattlefieldRenderer = require("battle.renderer")
local TurnManager = require("battle.turn_manager")

-- Fire and Smoke systems
local FireSystem = require("battle.fire_system")
local SmokeSystem = require("battle.smoke_system")

-- MapBlock system
local MapBlock = require("battle.map_block")
local GridMap = require("battle.grid_map")

-- Map generation system
local MapGenerator = require("battle.map_generator")

-- New ECS Battle System
local HexSystem = require("battle.systems.hex_system")
local MovementSystem = require("battle.systems.movement_system")
local VisionSystem = require("battle.systems.vision_system")
local UnitEntity = require("battle.entities.unit_entity")
local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

-- Load viewport system
local Viewport = require("utils.viewport")

local Battlescape = {}

-- Constants
local TILE_SIZE = 24
local MAP_WIDTH = 90
local MAP_HEIGHT = 90
local GUI_WIDTH = 240  -- 10 tiles × 24px
local GUI_HEIGHT = 720  -- 30 tiles × 24px
local SECTION_HEIGHT = 240  -- 10 tiles × 24px

-- Day/Night
Battlescape.isNight = false

function Battlescape:enter()
    print("[Battlescape] Entering battlescape state")
    
    -- Start profiling
    local startTime = love.timer.getTime()
    local stepStartTime = startTime
    
    -- Initialize core systems
    self.actionSystem = ActionSystem.new()
    self.pathfinding = Pathfinding.new()
    self.teamManager = Team.Manager.new()
    self.losSystem = LOS.new()
    self.animationSystem = AnimationSystem.new()
    
    -- Initialize fire and smoke systems
    self.fireSystem = FireSystem.new()
    self.smokeSystem = SmokeSystem.new()
    print("[Battlescape] Fire and Smoke systems initialized")
    
    -- Log optimization status
    print("[Battlescape] Using OPTIMIZED LOS system with shadow casting + caching")
    
    print(string.format("[PROFILE] Core systems init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()

    -- Initialize turn system first
    self.turnManager = TurnManager.new(self.teamManager, self.actionSystem)
    
    print(string.format("[PROFILE] Turn system init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()

    -- Initialize battlefield using MapGenerator system
    print("[Battlescape] Initializing map generation...")
    
    -- Get generation method from config (can be "procedural" or "mapblock")
    local generationMethod = MapGenerator.getMethod()  -- Default: "mapblock"
    print("[Battlescape] Map generation method: " .. generationMethod)
    
    -- Generate based on method
    if generationMethod == "mapblock" then
        -- Load all MapBlock templates from active mod
        local ModManager = require("systems.mod_manager")
        local mapblocksPath = ModManager.getContentPath("mapblocks")
        if not mapblocksPath then
            print("[Battlescape] ERROR: Could not get mapblocks path from mod")
            print("[Battlescape] Falling back to procedural generation")
            generationMethod = "procedural"
        else
            local blockPool = MapBlock.loadAll(mapblocksPath)
            print(string.format("[Battlescape] Loaded %d MapBlock templates", #blockPool))
            
            if #blockPool == 0 then
                print("[Battlescape] WARNING: No mapblocks available, using procedural")
                generationMethod = "procedural"
            else
                -- Generate using mapblocks
                local gridSize = math.random(4, 7)
                self.battlefield = MapGenerator.generate({
                    method = "mapblock",
                    blockPool = blockPool,
                    gridSize = gridSize,
                    biomePreferences = {
                        urban = 0.3,
                        forest = 0.25,
                        industrial = 0.2,
                        water = 0.1,
                        rural = 0.1,
                        mixed = 0.05
                    }
                })
            end
        end
    end
    
    -- Fallback to procedural if mapblock failed or was chosen
    if generationMethod == "procedural" or not self.battlefield then
        self.battlefield = MapGenerator.generate({
            method = "procedural",
            width = 60,
            height = 60,
            seed = nil  -- Random seed
        })
    end
    
    if not self.battlefield then
        print("[Battlescape] ERROR: Failed to generate battlefield")
        return
    end
    
    print(string.format("[Battlescape] Generated battlefield: %dx%d tiles", self.battlefield.width, self.battlefield.height))
    
    -- Update MAP_WIDTH and MAP_HEIGHT constants for this session
    MAP_WIDTH = self.battlefield.width
    MAP_HEIGHT = self.battlefield.height
    
    self.camera = Camera.new(0, 0)
    self.selection = UnitSelection.new(self.actionSystem, self.pathfinding, self.battlefield, self.turnManager, self.animationSystem, function() self:updateVisibility() end)
    self.renderer = BattlefieldRenderer.new(TILE_SIZE)
    
    print(string.format("[PROFILE] Battle components init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()

    -- Initialize new hex battle system (use dynamic map size)
    self.hexSystem = HexSystem.new(self.battlefield.width, self.battlefield.height, TILE_SIZE)
    Debug.enabled = false  -- Enable with F10 key
    Debug.showHexGrid = false  -- Toggle with F9
    Debug.showFOW = true  -- Toggle with F8
    self.showVisibleTiles = false  -- Toggle with F3 key
    print("[Battlescape] Hex system initialized (" .. self.battlefield.width .. "x" .. self.battlefield.height .. ")")
    
    print(string.format("[PROFILE] Hex system init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()

    -- Initialize game state
    self.unitIdCounter = 1
    
    -- Initialize middle mouse drag state
    self.isDraggingMap = false
    self.dragStartX = 0
    self.dragStartY = 0
    self.dragStartCameraX = 0
    self.dragStartCameraY = 0
    
    self:initTeams()
    
    print(string.format("[PROFILE] Teams init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()
    
    self:initUnits()
    
    print(string.format("[PROFILE] Units init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()
    
    -- Initialize hover state
    self.hoveredTileX = nil
    self.hoveredTileY = nil
    
    -- Initialize animation state
    self.gameTime = 0  -- For animation timing
    
    -- Initialize turn system
    if self.turnManager:initialize(self.units) then
        self.turnManager:startTeamTurn(self.units)
        self:updateVisibility()
        self:centerCameraOnFirstUnit()
    end
    
    print(string.format("[PROFILE] Turn system + visibility + camera: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()

    -- UI elements
    self:initUI()
    
    print(string.format("[PROFILE] UI init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    
    -- Day/night
    self.isNight = false
    
    local totalTime = (love.timer.getTime() - startTime) * 1000
    print(string.format("[PROFILE] Total battlescape initialization: %.3f ms", totalTime))
end

function Battlescape:exit()
    print("[Battlescape] Exiting battlescape state")
end

function Battlescape:initUI()
    -- GUI positioned on LEFT side of screen
    local guiX = 0
    local margin = 2  -- Small margin between frames

    -- SECTION 1: Minimap (Top)
    self.minimapFrame = Widgets.FrameBox.new(guiX, 0, 240, 240, "")
    self.minimapClickable = true
    self.minimapContentX = guiX + 0
    self.minimapContentY = 0
    self.minimapContentWidth = 240
    self.minimapContentHeight = 240

    -- SECTION 2: Info Frame (Middle) - Now with scrollable content
    self.infoFrame = Widgets.FrameBox.new(guiX, SECTION_HEIGHT, 240, SECTION_HEIGHT, "Info")
    
    -- Create scrollable text area for info content
    self.infoScrollBox = Widgets.ScrollBox.new(guiX + 4, SECTION_HEIGHT + 24, 232, SECTION_HEIGHT - 28)
    self.infoFrame:addChild(self.infoScrollBox)

    -- SECTION 3: Actions Frame (Bottom) - Redesigned as 4x4 button grid
    self.actionsFrame = Widgets.FrameBox.new(guiX, SECTION_HEIGHT * 2, 240, SECTION_HEIGHT, "Actions")
    
    -- Clear existing action buttons
    self.actionButtons = {}
    
    -- Button layout: 4 columns x 4 rows = 16 buttons total
    local buttonWidth = 56  -- (240 - 8*2 - 4*2) / 4 = 56
    local buttonHeight = 48
    local startX = guiX + 8
    local startY = SECTION_HEIGHT * 2 + 24
    local colSpacing = 2
    local rowSpacing = 2
    
    -- Row 1: Unit Inventory (WEAPON LEFT | WEAPON RIGHT | ARMOUR | SKILL)
    local inventoryButtons = {
        {label = "W.L", action = "weapon_left"},
        {label = "W.R", action = "weapon_right"}, 
        {label = "ARM", action = "armour"},
        {label = "SKILL", action = "skill"}
    }
    
    for col = 1, 4 do
        local btnData = inventoryButtons[col]
        local x = startX + (col - 1) * (buttonWidth + colSpacing)
        local y = startY
        local btn = Widgets.Button.new(x, y, buttonWidth, buttonHeight, btnData.label)
        btn.onClick = function() self:performInventoryAction(btnData.action) end
        table.insert(self.actionButtons, btn)
        self.actionsFrame:addChild(btn)
    end
    
    -- Row 2: Unit Actions (REST | OVERWATCH | COVER | AIM)
    local actionButtons = {
        {label = "REST", action = "rest"},
        {label = "OVER", action = "overwatch"},
        {label = "COVER", action = "cover"},
        {label = "AIM", action = "aim"}
    }
    
    for col = 1, 4 do
        local btnData = actionButtons[col]
        local x = startX + (col - 1) * (buttonWidth + colSpacing)
        local y = startY + buttonHeight + rowSpacing
        local btn = Widgets.Button.new(x, y, buttonWidth, buttonHeight, btnData.label)
        btn.onClick = function() self:performUnitAction(btnData.action) end
        table.insert(self.actionButtons, btn)
        self.actionsFrame:addChild(btn)
    end
    
    -- Row 3: Unit Movement Mode (WALK | SNEAK | RUN | FLY)
    local movementButtons = {
        {label = "WALK", action = "walk"},
        {label = "SNEAK", action = "sneak"},
        {label = "RUN", action = "run"},
        {label = "FLY", action = "fly"}
    }
    
    for col = 1, 4 do
        local btnData = movementButtons[col]
        local x = startX + (col - 1) * (buttonWidth + colSpacing)
        local y = startY + 2 * (buttonHeight + rowSpacing)
        local btn = Widgets.Button.new(x, y, buttonWidth, buttonHeight, btnData.label)
        btn.onClick = function() self:performMovementAction(btnData.action) end
        table.insert(self.actionButtons, btn)
        self.actionsFrame:addChild(btn)
    end
    
    -- Row 4: Map Actions (NEXT UNIT | MAP ZOOM ON OFF | MENU | END TURN)
    local mapButtons = {
        {label = "NEXT", action = "next_unit"},
        {label = "ZOOM", action = "toggle_zoom"},
        {label = "MENU", action = "menu"},
        {label = "END", action = "end_turn"}
    }
    
    for col = 1, 4 do
        local btnData = mapButtons[col]
        local x = startX + (col - 1) * (buttonWidth + colSpacing)
        local y = startY + 3 * (buttonHeight + rowSpacing)
        local btn = Widgets.Button.new(x, y, buttonWidth, buttonHeight, btnData.label)
        btn.onClick = function() self:performMapAction(btnData.action) end
        table.insert(self.actionButtons, btn)
        self.actionsFrame:addChild(btn)
    end
end
function Battlescape:initTeams()
    -- Create 6 teams with colors
    local teams = {
        {name = "team1", displayName = "Red Team", side = Team.SIDES.PLAYER, color = {1, 0, 0}},
        {name = "team2", displayName = "Blue Team", side = Team.SIDES.ALLY, color = {0, 0, 1}},
        {name = "team3", displayName = "Green Team", side = Team.SIDES.ENEMY, color = {0, 1, 0}},
        {name = "team4", displayName = "Yellow Team", side = Team.SIDES.ENEMY, color = {1, 1, 0}},
        {name = "team5", displayName = "Purple Team", side = Team.SIDES.ENEMY, color = {1, 0, 1}},
        {name = "team6", displayName = "Cyan Team", side = Team.SIDES.ENEMY, color = {0, 1, 1}},
    }
    
    for _, teamData in ipairs(teams) do
        local team = Team.new(teamData.name, teamData.displayName, teamData.side)
        team.color = teamData.color
        self.teamManager:addTeam(team)
    end

    -- Initialize FOW
    self.teamManager:initializeVisibility(MAP_WIDTH, MAP_HEIGHT)

    print("[Battlescape] Initialized 6 teams with color system")
end

function Battlescape:initUnits()
    local unitsStartTime = love.timer.getTime()
    self.units = {}
    
    -- Create spatial hash for O(1) collision detection
    local SpatialHash = require("systems.spatial_hash")
    local spatialHash = SpatialHash.new(MAP_WIDTH, MAP_HEIGHT, 10)  -- 10x10 cell size
    
    -- Helper function to find valid spawn position using spatial hash
    local function findValidPosition(minX, maxX, minY, maxY)
        for attempt = 1, 100 do
            local x = math.random(minX, maxX)
            local y = math.random(minY, maxY)
            
            -- Check if tile is walkable (not wall)
            local walkable = self.battlefield:isWalkable(x, y)
            
            if walkable then
                -- Check if no unit already there using spatial hash (O(1) instead of O(n))
                if not spatialHash:isOccupied(x, y) then
                    return x, y
                end
            end
        end
        return nil, nil
    end

    -- Spawn units for each of the 6 teams
    local teamData = {
        {name = "team1", spawnArea = {2, 29, 2, 29}},     -- Top-left
        {name = "team2", spawnArea = {31, 58, 2, 29}},    -- Top-center
        {name = "team3", spawnArea = {61, 88, 2, 29}},    -- Top-right
        {name = "team4", spawnArea = {2, 29, 61, 88}},    -- Bottom-left
        {name = "team5", spawnArea = {31, 58, 61, 88}},   -- Bottom-center
        {name = "team6", spawnArea = {61, 88, 61, 88}},   -- Bottom-right
    }
    
    local totalUnits = 0
    for _, td in ipairs(teamData) do
        local team = self.teamManager:getTeam(td.name)
        if team then
            local numUnits = math.random(12, 36)  -- Random 12-36 units per team
            print(string.format("[Battlescape] Spawning %d units for %s", numUnits, td.name))
            
            for i = 1, numUnits do
                local x, y = findValidPosition(td.spawnArea[1], td.spawnArea[2], td.spawnArea[3], td.spawnArea[4])
                if x and y then
                    local unit = Unit.new("soldier", td.name, x, y)
                    if unit then
                        unit.id = self:getNextUnitId()
                        unit.name = td.name .. " Unit " .. i
                        unit.actionPoints = 4
                        unit.actionPointsLeft = 4
                        unit.movementPoints = 24
                        unit.movementPointsLeft = 24
                        team:addUnit(unit)
                        self.units[unit.id] = unit
                        self.battlefield:placeUnit(unit)
                        spatialHash:insert(x, y, unit)  -- Add to spatial hash
                        totalUnits = totalUnits + 1
                    end
                end
            end
        end
    end
    
    -- Log spatial hash statistics
    local stats = spatialHash:getStats()
    print(string.format("[SpatialHash] Stats: %d items, %.1f%% load, avg %.2f items/cell", 
        stats.totalItems, stats.loadFactor * 100, stats.avgItemsPerCell))

    print(string.format("[Battlescape] Initialized %d units across 6 teams", totalUnits))
    print(string.format("[PROFILE] Unit spawning details: %.3f ms total, %.3f ms per unit", 
          (love.timer.getTime() - unitsStartTime) * 1000, 
          ((love.timer.getTime() - unitsStartTime) * 1000) / totalUnits))
end

function Battlescape:getNextUnitId()
    local id = self.unitIdCounter
    self.unitIdCounter = self.unitIdCounter + 1
    return id
end

function Battlescape:countUnits()
    local count = 0
    for _ in pairs(self.units) do
        count = count + 1
    end
    return count
end

function Battlescape:centerCameraOnFirstUnit()
    local activeTeam = self.turnManager:getCurrentTeam()
    if activeTeam and activeTeam.units and #activeTeam.units > 0 then
        local firstUnitId = activeTeam.units[1]
        local firstUnit = self.units[firstUnitId]
        if firstUnit then
            self.camera:centerOn(firstUnit.x, firstUnit.y, TILE_SIZE, 360, 360)
            print(string.format("[Battlescape] Centered camera on %s at (%d, %d)", 
                firstUnit.name, firstUnit.x, firstUnit.y))
        end
    end
end

function Battlescape:updateVisibility()
    local visStartTime = love.timer.getTime()
    
    -- Calculate FOW for active team only
    local activeTeam = self.turnManager:getCurrentTeam()
    if activeTeam then
        local teamStartTime = love.timer.getTime()
        
        -- Get living units from active team
        local livingUnits = activeTeam:getLivingUnits(self.units)
        
        -- Count dirty units (need visibility recalculation)
        local dirtyCount = 0
        for _, unit in ipairs(livingUnits) do
            if unit.visibilityDirty then
                dirtyCount = dirtyCount + 1
            end
        end
        
        print(string.format("[PROFILE] Get living units (%d, %d dirty): %.3f ms", #livingUnits, dirtyCount, (love.timer.getTime() - teamStartTime) * 1000))
        
        local losStartTime = love.timer.getTime()
        local allVisible = {}
        local calculatedCount = 0

        -- Aggregate visibility from all units in team
        for i, unit in ipairs(livingUnits) do
            -- Only recalculate LOS for dirty units
            if unit.visibilityDirty then
                local unitStartTime = love.timer.getTime()
                local visible = self.losSystem:calculateVisibilityForUnit(unit, self.battlefield, not self.isNight, unitStartTime)
                local unitTime = (love.timer.getTime() - unitStartTime) * 1000
                calculatedCount = calculatedCount + 1
                
                if visible then
                    -- Cache visibility for this unit
                    unit.cachedVisibility = visible
                    
                    -- Use numeric keys for better performance
                    for _, tile in ipairs(visible) do
                        local key = tile.y * MAP_WIDTH + tile.x
                        allVisible[key] = tile
                    end
                end
                
                -- Mark unit as clean
                unit.visibilityDirty = false
                
                if unitTime > 1.0 then  -- Log slow units
                    print(string.format("[PROFILE] Unit %s LOS (%d tiles): %.3f ms", unit.name, visible and #visible or 0, unitTime))
                end
            else
                -- Use cached visibility for stationary units
                if unit.cachedVisibility then
                    for _, tile in ipairs(unit.cachedVisibility) do
                        local key = tile.y * MAP_WIDTH + tile.x
                        allVisible[key] = tile
                    end
                end
            end
        end
        
        print(string.format("[PROFILE] LOS calculation for %d units (%d calculated, %d skipped): %.3f ms", 
            #livingUnits, calculatedCount, #livingUnits - calculatedCount, (love.timer.getTime() - losStartTime) * 1000))
        
        local aggregateStartTime = love.timer.getTime()
        -- Convert back to array
        local visibleArray = {}
        for _, tile in pairs(allVisible) do
            table.insert(visibleArray, tile)
        end
        
        print(string.format("[PROFILE] Aggregate %d visible tiles: %.3f ms", #visibleArray, (love.timer.getTime() - aggregateStartTime) * 1000))

        -- Update team visibility
        local updateStartTime = love.timer.getTime()
        activeTeam:updateFromUnitLOS(nil, visibleArray)
        print(string.format("[PROFILE] Update team visibility: %.3f ms", (love.timer.getTime() - updateStartTime) * 1000))
        
        -- Log cache stats
        if self.losSystem.getCacheStats then
            local stats = self.losSystem:getCacheStats()
            print(string.format("[CACHE] Hit rate: %.1f%% (Hits: %d, Misses: %d, Size: %d)", 
                stats.hit_rate, stats.hits, stats.misses, stats.size))
        end
    end
    
    print(string.format("[PROFILE] Total updateVisibility: %.3f ms", (love.timer.getTime() - visStartTime) * 1000))
end

function Battlescape:toggleDayNight()
    self.isNight = not self.isNight
    print(string.format("[Battlescape] Time of day: %s", self.isNight and "Night" or "Day"))
    -- Recalculate FOW for active team
    self:updateVisibility()
    -- Refresh visible tiles for selected unit
    if self.selection and self.selection.selectedUnit then
        local visibleTiles = self.losSystem:calculateVisibilityForUnit(
            self.selection.selectedUnit,
            self.battlefield,
            not self.isNight
        )
        self.selection.visibleTiles = visibleTiles or {}
    end
end

function Battlescape:switchTeam()
    -- Cycle to next team
    self.turnManager:nextTeam()
    -- Reset overlays
    if self.selection then
        self.selection:clearSelection()
    end
    -- Update visibility for new active team
    self:updateVisibility()
    -- Center camera on first unit
    self:centerCameraOnFirstUnit()
    -- Auto-select first unit and refresh visible tiles
    if self.units and #self.units > 0 then
        for _, unit in ipairs(self.units) do
            if unit and unit.alive and unit.team == self.turnManager:getCurrentTeam().name then
                self.selection:selectUnit(unit, self.battlefield)
                local visibleTiles = self.losSystem:calculateVisibilityForUnit(
                    unit,
                    self.battlefield,
                    not self.isNight
                )
                self.selection.visibleTiles = visibleTiles or {}
                self.camera:centerOn(unit.x, unit.y, TILE_SIZE, 360, 360)
                break
            end
        end
    end
end

function Battlescape:update(dt)
    -- Update game time for animations
    self.gameTime = self.gameTime + dt
    
    -- Update animation system
    self.animationSystem:update(dt)
    
    -- Camera has no update method, just position tracking
end

function Battlescape:draw()
    -- Get battlefield viewport (dynamically sized based on window)
    local viewX, viewY, viewWidth, viewHeight = Viewport.getBattlefieldViewport()
    
    -- Set scissor for battlefield area (physical pixels)
    love.graphics.setScissor(viewX, viewY, viewWidth, viewHeight)
    
    -- Draw battlefield (no scaling, just viewport)
    love.graphics.push()
    love.graphics.translate(viewX, viewY)
    
    -- Day/night tint
    if self.isNight then
        love.graphics.setColor(0.8, 0.8, 1, 1)  -- Blue tint for night (reduce R/G by 20%)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    -- Draw battlefield using the correct method
    local activeTeam = self.turnManager:getCurrentTeam()
    self.renderer:draw(self.battlefield, self.camera, self.teamManager, activeTeam, self.isNight, viewWidth, viewHeight)
    
    -- Draw fire and smoke effects
    self:drawFireAndSmoke()
    
    -- Draw units
    self:drawUnits()
    
    -- Draw FOW for active team
    local activeTeam = self.turnManager:getCurrentTeam()
    if activeTeam then
        self:drawFogOfWar(activeTeam)
    end
    
    -- Draw selection
    if self.selection.selectedUnit then
        self.renderer:drawSelection(self.selection, self.camera, self.animationSystem, self.losSystem, not self.isNight, self.showVisibleTiles)
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color
    love.graphics.pop()
    
    -- Reset scissor
    love.graphics.setScissor()
    
    -- Draw GUI panels (no scaling - always 240×720)
    self:drawGUI()
    
    -- Draw debug overlays on top of everything (after GUI)
    if Debug.showHexGrid then
        HexSystem.drawHexGrid(self.hexSystem, self.camera)
    end
    
    if Debug.showVisionCones then
        local activeTeam = self.turnManager:getCurrentTeam()
        if activeTeam and activeTeam.units then
            -- Convert units table to array if needed
            local unitArray = {}
            for _, unit in pairs(activeTeam.units) do
                if unit.transform and unit.vision then
                    table.insert(unitArray, unit)
                end
            end
            if #unitArray > 0 then
                VisionSystem.drawVisionCones(unitArray, self.hexSystem, self.camera)
            end
        end
    end
    
    -- Draw debug overlay on top of everything
    if Debug.enabled then
        Debug.drawPerformanceStats()
    end
end

function Battlescape:drawGUI()
    -- Draw minimap content first
    self:drawMinimap()

    -- Draw minimap frame border on top (without background fill)
    self:drawMinimapFrame()

    -- Draw info frame
    self.infoFrame:draw()
    self:drawInformation()

    -- Draw actions frame
    self.actionsFrame:draw()
    -- Buttons are drawn by frame's children
end

function Battlescape:drawMinimap()
    -- Minimap content area
    local contentX = self.minimapContentX
    local contentY = self.minimapContentY
    local contentW = self.minimapContentWidth
    local contentH = self.minimapContentHeight
    
    -- Calculate minimap scale
    local pixelsPerTileX = contentW / MAP_WIDTH
    local pixelsPerTileY = contentH / MAP_HEIGHT
    
    -- Draw minimap tiles
    local currentTeam = self.turnManager:getCurrentTeam()
    
    -- Note: Removed dynamic visibility calculation during movement
    -- Minimap now only shows static team visibility, updated when movement completes
    
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local visibility = "hidden"
            
            -- Use team visibility (no dynamic calculation during movement)
            if currentTeam and currentTeam.visibility[y] and currentTeam.visibility[y][x] then
                visibility = currentTeam.visibility[y][x]
            end
            
            local mx = contentX + (x - 1) * pixelsPerTileX
            local my = contentY + (y - 1) * pixelsPerTileY
            
            -- Find unit at this tile
            local unitAtTile = nil
            for _, unit in pairs(self.units) do
                if unit.x == x and unit.y == y and unit.alive then
                    unitAtTile = unit
                    break
                end
            end
            
            if visibility == "hidden" then
                -- Black for unexplored terrain
                love.graphics.setColor(0, 0, 0, 1)
            elseif unitAtTile and visibility == "visible" then
                -- Team color for units
                local team = self.teamManager:getTeam(unitAtTile.team)
                if team and team.color then
                    love.graphics.setColor(team.color[1], team.color[2], team.color[3], 1)
                else
                    love.graphics.setColor(1, 1, 1, 1)
                end
            elseif visibility == "visible" then
                -- White for currently visible terrain
                love.graphics.setColor(1, 1, 1, 1)
            elseif visibility == "explored" then
                -- Light gray for explored terrain
                love.graphics.setColor(0.6, 0.6, 0.6, 1)
            else
                -- Check terrain walkability for fallback
                local tile = self.battlefield:getTile(x, y)
                if tile and tile:getMoveCost() == 0 then
                    -- Dark gray for impassable terrain
                    love.graphics.setColor(0.3, 0.3, 0.3, 1)
                else
                    -- Light gray for passable terrain
                    love.graphics.setColor(0.6, 0.6, 0.6, 1)
                end
            end
            
            love.graphics.rectangle("fill", mx, my, pixelsPerTileX, pixelsPerTileY)
        end
    end
    
    -- Draw minimap tiles (already shows actual visibility - no need for circular overlays)
    -- self:drawMinimapSightRanges(contentX, contentY, pixelsPerTileX, pixelsPerTileY, currentTeam)
    
    -- Draw viewport rectangle
    local _, _, viewWidth, viewHeight = Viewport.getBattlefieldViewport()
    local visibleWidth = viewWidth
    local visibleHeight = viewHeight
    
    -- Calculate center of viewport in tile coordinates
    local centerTileX = (viewWidth/2 - self.camera.x) / (TILE_SIZE * self.camera.zoom)
    local centerTileY = (viewHeight/2 - self.camera.y) / (TILE_SIZE * self.camera.zoom)
    
    local viewportTileWidth = visibleWidth / TILE_SIZE
    local viewportTileHeight = visibleHeight / TILE_SIZE
    
    local vpMinimapX = (centerTileX - viewportTileWidth/2) * pixelsPerTileX
    local vpMinimapY = (centerTileY - viewportTileHeight/2) * pixelsPerTileY
    local vpMinimapWidth = viewportTileWidth * pixelsPerTileX
    local vpMinimapHeight = viewportTileHeight * pixelsPerTileY
    
    vpMinimapX = math.max(0, math.min(vpMinimapX, contentW - vpMinimapWidth))
    vpMinimapY = math.max(0, math.min(vpMinimapY, contentH - vpMinimapHeight))
    
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", 
        contentX + vpMinimapX,
        contentY + vpMinimapY,
        vpMinimapWidth,
        vpMinimapHeight
    )
    
    love.graphics.setColor(1, 1, 1, 1)
end

-- REMOVED: drawMinimapSightRanges function - minimap now shows actual visible tiles instead of circular overlays
-- The minimap already displays visibility correctly using team.visibility data

function Battlescape:drawInformation()
    -- Clear existing content
    self.infoScrollBox:clear()
    
    local infoLines = {}
    
    -- Active team info
    local activeTeam = self.turnManager:getCurrentTeam()
    if activeTeam then
        table.insert(infoLines, "Team: " .. activeTeam.name)
    end
    
    -- Day/Night
    table.insert(infoLines, "Time: " .. (self.isNight and "Night" or "Day"))
    table.insert(infoLines, "")  -- Extra spacing
    
    -- Selected unit info
    if self.selection.selectedUnit then
        table.insert(infoLines, "=== SELECTED UNIT ===")
        local unit = self.selection.selectedUnit
        table.insert(infoLines, "Unit: " .. unit.name)
        
        -- Health and Energy
        local healthPercent = math.floor((unit.health / unit.maxHealth) * 100)
        table.insert(infoLines, string.format("HP: %d/%d (%d%%)", unit.health, unit.maxHealth, healthPercent))
        
        if unit.energy and unit.maxEnergy then
            local energyPercent = math.floor((unit.energy / unit.maxEnergy) * 100)
            table.insert(infoLines, string.format("Energy: %d/%d (%d%%)", unit.energy, unit.maxEnergy, energyPercent))
        end
        
        -- Action Points
        table.insert(infoLines, string.format("AP: %d/%d", unit.actionPointsLeft, unit.actionPoints))
        table.insert(infoLines, string.format("MP: %d/%d", unit.movementPointsLeft, unit.movementPoints))
        
        -- Combat Stats
        if unit.stats then
            if unit.stats.aim then
                table.insert(infoLines, string.format("Accuracy: %d", unit.stats.aim))
            end
            if unit.stats.armour then
                table.insert(infoLines, string.format("Armor: %d", unit.stats.armour))
            end
            if unit.stats.strength then
                table.insert(infoLines, string.format("Strength: %d", unit.stats.strength))
            end
            if unit.stats.react then
                table.insert(infoLines, string.format("Reactions: %d", unit.stats.react))
            end
        end
        
        -- Position and Facing
        table.insert(infoLines, string.format("Pos: (%d, %d)", unit.x, unit.y))
        table.insert(infoLines, string.format("Facing: %d°", unit.facing or 0))
        
        -- Weapon Info
        if unit.weapon1 then
            table.insert(infoLines, "Weapon: " .. unit.weapon1)
        end
        
        table.insert(infoLines, "")  -- Extra spacing
    end
    
    -- Hovered tile/unit info
    if self.hoveredTileX and self.hoveredTileY then
        table.insert(infoLines, "=== HOVER INFO ===")
        
        local tile = self.battlefield:getTile(self.hoveredTileX, self.hoveredTileY)
        if tile then
            table.insert(infoLines, "Tile: (" .. self.hoveredTileX .. ", " .. self.hoveredTileY .. ")")
            table.insert(infoLines, "Terrain: " .. tile.terrain.name)
            table.insert(infoLines, "Move Cost: " .. tile:getMoveCost())
            local cover = math.floor(tile:getCover() * 100)
            table.insert(infoLines, "Cover: " .. cover .. "%")
        end
        
        -- Check for unit at hovered position
        local hoveredUnit = self:getUnitAt(self.hoveredTileX, self.hoveredTileY)
        if hoveredUnit and hoveredUnit ~= self.selection.selectedUnit then
            table.insert(infoLines, "--- Unit Here ---")
            table.insert(infoLines, hoveredUnit.name)
            table.insert(infoLines, string.format("HP: %d/%d", hoveredUnit.health, hoveredUnit.maxHealth))
            local team = self.teamManager:getTeam(hoveredUnit.team)
            if team then
                table.insert(infoLines, "Team: " .. team.name)
            end
        end
    end
    
    -- Create labels for each line and add to scroll box
    local y = 0
    for i, line in ipairs(infoLines) do
        if line == "" then
            y = y + 8  -- Smaller spacing for empty lines
        else
            local label = Widgets.Label.new(4, y, 200, 20, line)
            self.infoScrollBox:addChild(label)
            y = y + 20
        end
    end
end

function Battlescape:drawMinimapFrame()
    -- Draw only the frame border on top of minimap content
    local Theme = require("widgets.theme")
    Theme.setColor("border")
    love.graphics.setLineWidth(Theme.borderWidth or 1)
    love.graphics.rectangle("line", self.minimapFrame.x, self.minimapFrame.y, self.minimapFrame.width, self.minimapFrame.height)

    -- Draw title if present
    if self.minimapFrame.title and self.minimapFrame.title ~= "" then
        Theme.setFont("default")
        Theme.setColor("text")
        local font = Theme.getFont("default")
        local titleWidth = font:getWidth(self.minimapFrame.title)
        local titleX = self.minimapFrame.x + (Theme.padding or 4) * 2
        local titleY = self.minimapFrame.y + (Theme.padding or 4)

        -- Background for title text
        Theme.setColor("backgroundLight")
        love.graphics.rectangle("fill", titleX - (Theme.padding or 4), titleY, titleWidth + (Theme.padding or 4) * 2, font:getHeight())

        -- Title text
        Theme.setColor("text")
        love.graphics.print(self.minimapFrame.title, titleX, titleY)
    end
end

function Battlescape:drawFogOfWar(team)
    -- Draw FOW overlay (respects Debug.showFOW flag)
    if not Debug.showFOW then return end
    if not team or not team.visibility then return end
    
    for y = 1, MAP_HEIGHT do
        for x = 1, MAP_WIDTH do
            local state = team:getVisibility(x, y)
            if state == "hidden" then
                -- Draw black tile for hidden areas
                local screenX = ((x - 1) * TILE_SIZE) * self.camera.zoom + self.camera.x
                -- Offset alternate columns to simulate hex grid
                local offsetY = (x % 2 == 0) and (TILE_SIZE * self.camera.zoom * 0.5) or 0
                local screenY = ((y - 1) * TILE_SIZE) * self.camera.zoom + self.camera.y + offsetY
                love.graphics.setColor(0, 0, 0, 0.8)
                love.graphics.rectangle("fill", screenX, screenY, TILE_SIZE * self.camera.zoom, TILE_SIZE * self.camera.zoom)
            end
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Battlescape:drawUnits()
    -- Draw all units
    local activeTeam = self.turnManager:getCurrentTeam()
    for _, unit in pairs(self.units) do
        if unit and unit.alive then
            -- Check if unit's tile is visible to active team
            local tileVisible = false
            if activeTeam then
                local visibility = activeTeam:getVisibility(unit.x, unit.y)
                tileVisible = (visibility == "visible")
            end
            
            if tileVisible then
                local screenX = ((unit.x - 1) * TILE_SIZE) * self.camera.zoom + self.camera.x
                -- Offset alternate columns to simulate hex grid
                local offsetY = (unit.x % 2 == 0) and (TILE_SIZE * self.camera.zoom * 0.5) or 0
                local screenY = ((unit.y - 1) * TILE_SIZE) * self.camera.zoom + self.camera.y + offsetY
            
            -- Get team color
            local team = self.teamManager:getTeam(unit.team)
            local color = {1, 1, 1}  -- Default white
            if team and team.color then
                color = team.color
            end
            
            -- Get unit sprite
            local sprite = Assets.get("units", "unit test")
            if sprite then
                love.graphics.setColor(color[1], color[2], color[3], 1)
                love.graphics.draw(sprite, screenX, screenY, 0, self.camera.zoom, self.camera.zoom)
            else
                -- Fallback: draw colored square
                love.graphics.setColor(color[1], color[2], color[3], 1)
                love.graphics.rectangle("fill", screenX, screenY, TILE_SIZE * self.camera.zoom, TILE_SIZE * self.camera.zoom)
            end
            
            -- Draw health bar
            if unit.health < unit.maxHealth then
                local barWidth = TILE_SIZE * self.camera.zoom
                local barHeight = 3 * self.camera.zoom
                local healthPercent = unit.health / unit.maxHealth
                
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle("fill", screenX, screenY - 5 * self.camera.zoom, barWidth, barHeight)
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.rectangle("fill", screenX, screenY - 5 * self.camera.zoom, barWidth * healthPercent, barHeight)
            end
            end
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Battlescape:drawFireAndSmoke()
    -- Draw fire tiles (orange/red)
    if self.fireSystem then
        for _, fire in ipairs(self.fireSystem.activeFires) do
            local screenX = ((fire.x - 1) * TILE_SIZE) * self.camera.zoom + self.camera.x
            local offsetY = (fire.x % 2 == 0) and (TILE_SIZE * self.camera.zoom * 0.5) or 0
            local screenY = ((fire.y - 1) * TILE_SIZE) * self.camera.zoom + self.camera.y + offsetY
            
            -- Animated fire effect (flicker)
            local flicker = 0.8 + math.sin(self.gameTime * 10) * 0.2
            love.graphics.setColor(1, 0.4 * flicker, 0, 0.7)  -- Orange fire
            love.graphics.rectangle("fill", screenX, screenY, 
                TILE_SIZE * self.camera.zoom, TILE_SIZE * self.camera.zoom)
        end
    end
    
    -- Draw smoke tiles (gray with transparency)
    if self.smokeSystem then
        for _, smoke in ipairs(self.smokeSystem.activeSmoke) do
            local screenX = ((smoke.x - 1) * TILE_SIZE) * self.camera.zoom + self.camera.x
            local offsetY = (smoke.x % 2 == 0) and (TILE_SIZE * self.camera.zoom * 0.5) or 0
            local screenY = ((smoke.y - 1) * TILE_SIZE) * self.camera.zoom + self.camera.y + offsetY
            
            -- Smoke opacity based on level (1=light, 2=medium, 3=heavy)
            local alpha = smoke.level * 0.2  -- 0.2, 0.4, 0.6
            love.graphics.setColor(0.5, 0.5, 0.5, alpha)  -- Gray smoke
            love.graphics.rectangle("fill", screenX, screenY, 
                TILE_SIZE * self.camera.zoom, TILE_SIZE * self.camera.zoom)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)  -- Reset
end

function Battlescape:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("menu")
        return
    end
    
    -- F4: Toggle day/night
    if key == "f4" then
        self:toggleDayNight()
        return
    end
    
    -- F3: Toggle visible tile indicators
    if key == "f3" then
        self.showVisibleTiles = not self.showVisibleTiles
        print("[Battlescape] Visible tile indicators:", self.showVisibleTiles and "ON" or "OFF")
        return
    end
    
    -- F5: Save map to PNG
    if key == "f5" then
        local MapSaver = require("battle.map_saver")
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local filename = "battlefield_" .. timestamp .. ".png"
        local success, filepath = MapSaver.saveMapToPNG(self.battlefield, filename)
        if success then
            print(string.format("[Battlescape] Map saved: %s", filepath))
        end
        return
    end
    
    -- F6: Start test fire at camera center
    if key == "f6" then
        if self.fireSystem then
            local centerX = math.floor(-self.camera.x / (TILE_SIZE * self.camera.zoom)) + 15
            local centerY = math.floor(-self.camera.y / (TILE_SIZE * self.camera.zoom)) + 15
            centerX = math.max(1, math.min(centerX, MAP_WIDTH))
            centerY = math.max(1, math.min(centerY, MAP_HEIGHT))
            
            local success = self.fireSystem:startFire(self.battlefield, centerX, centerY)
            if success then
                print(string.format("[Battlescape] Test fire started at (%d, %d)", centerX, centerY))
            else
                print(string.format("[Battlescape] Cannot start fire at (%d, %d) - not flammable", centerX, centerY))
            end
        end
        return
    end
    
    -- F7: Clear all fires and smoke
    if key == "f7" then
        if self.fireSystem and self.smokeSystem then
            self.fireSystem:clearAllFires(self.battlefield)
            self.smokeSystem:clearAllSmoke(self.battlefield)
            print("[Battlescape] All fires and smoke cleared")
        end
        return
    end
    
    -- F8: Toggle FOW display
    if key == "f8" then
        Debug.toggleFOW()
        print("[Battlescape] FOW display:", Debug.showFOW and "ON" or "OFF")
        return
    end
    
    -- F9: Toggle hex grid
    if key == "f9" then
        Debug.toggleHexGrid()
        print("[Battlescape] Hex grid:", Debug.showHexGrid and "ON" or "OFF")
        return
    end
    
    -- F10: Toggle debug mode
    if key == "f10" then
        Debug.toggle()
        return
    end
    
    -- Space: Switch team
    if key == "space" then
        self:switchTeam()
        return
    end
    
    -- Arrow keys: Move camera
    local moveSpeed = TILE_SIZE * 5
    if key == "left" then
        self.camera.x = self.camera.x + moveSpeed
    elseif key == "right" then
        self.camera.x = self.camera.x - moveSpeed
    elseif key == "up" then
        self.camera.y = self.camera.y + moveSpeed
    elseif key == "down" then
        self.camera.y = self.camera.y - moveSpeed
    end
    
    -- Rotation keys: Q/E
    if (key == "q" or key == "e") and self.selection.selectedUnit then
        local unit = self.selection.selectedUnit
        
        -- Check if unit has enough MP for rotation
        if unit.movementPointsLeft >= 1 then
            local direction = (key == "q") and -1 or 1
            unit.facing = ((unit.facing or 0) + direction) % 8
            unit.movementPointsLeft = unit.movementPointsLeft - 1
            print(string.format("[Battlescape] %s rotated to facing %d (MP: %d)", 
                unit.name, unit.facing, unit.movementPointsLeft))
        else
            print(string.format("[Battlescape] %s has no MP to rotate", unit.name))
        end
        return
    end
end

function Battlescape:mousepressed(x, y, button, istouch, presses)
    -- Block input during animations
    if self.animationSystem:isAnimating() then
        return
    end
    
    -- Middle mouse button: start dragging map
    if button == 2 then
        self.isDraggingMap = true
        self.dragStartX = x
        self.dragStartY = y
        self.dragStartCameraX = self.camera.x
        self.dragStartCameraY = self.camera.y
        print("[Battlescape] Middle mouse drag started")
        return
    end
    
    -- Right mouse button: rotate selected unit
    if button == 3 and self.selection.selectedUnit then
        self:handleUnitRotation(x, y)
        return
    end
    
    -- Check minimap click
    if x >= self.minimapContentX and x <= self.minimapContentX + self.minimapContentWidth and
       y >= self.minimapContentY and y <= self.minimapContentY + self.minimapContentHeight then
        self:handleMinimapClick(x, y)
        return
    end
    
    -- Check GUI button clicks
    if x < GUI_WIDTH then
        self.actionsFrame:mousepressed(x, y, button)
        return
    end
    
    -- Battlefield click
    if button == 1 then
        -- Use viewport system to convert screen to tile coordinates
        local tileX, tileY = Viewport.screenToTile(x, y, self.camera, TILE_SIZE)
        
        -- Adjust for hex offset
        if tileX % 2 == 0 then
            local bfX, bfY = Viewport.screenToBattlefield(x, y)
            local worldY = (bfY - self.camera.y) / self.camera.zoom
            tileY = math.floor((worldY - (TILE_SIZE * 0.5)) / TILE_SIZE) + 1
        end
        
        self.selection:handleClick(tileX, tileY, self.battlefield, self.units)
        
        -- Update visible tiles for selected unit
        if self.selection.selectedUnit then
            local visibleTiles = self.losSystem:calculateVisibilityForUnit(
                self.selection.selectedUnit, 
                self.battlefield, 
                not self.isNight
            )
            self.selection.visibleTiles = visibleTiles or {}
        else
            self.selection.visibleTiles = {}
        end
    end
end

function Battlescape:handleMinimapClick(x, y)
    -- Convert minimap coordinates to world coordinates
    local relX = x - self.minimapContentX
    local relY = y - self.minimapContentY
    
    -- Scale: pixels per tile on minimap
    local pixelsPerTileX = self.minimapContentWidth / MAP_WIDTH
    local pixelsPerTileY = self.minimapContentHeight / MAP_HEIGHT
    
    local worldX = relX / pixelsPerTileX
    -- No Y inversion: top of minimap = top of map
    local worldY = relY / pixelsPerTileY
    
    -- Center camera on clicked position (convert world coords to tile coords)
    local tileX = math.floor(worldX) + 1  -- Convert to 1-based coordinates
    local tileY = math.floor(worldY) + 1  -- Convert to 1-based coordinates
    self.camera:centerOn(tileX, tileY, TILE_SIZE, 360, 360)
    print(string.format("[Battlescape] Minimap clicked: camera moved to tile (%d, %d)", tileX, tileY))
end

function Battlescape:performAction(actionIndex)
    print(string.format("[Battlescape] Action %d triggered", actionIndex))
    
    if actionIndex == 9 then
        -- End Turn button
        self:endTurn()
    end
end

function Battlescape:endTurn()
    print("[Battlescape] Ending turn")
    
    -- Update fire and smoke before turn ends
    if self.fireSystem and self.smokeSystem then
        self.fireSystem:update(self.battlefield, self.units, self.smokeSystem)
        self.smokeSystem:update(self.battlefield)
        
        -- Invalidate LOS cache since terrain effects changed
        if self.losSystem and self.losSystem.cache then
            self.losSystem.cache:invalidateArea(1, 1, MAP_WIDTH, MAP_HEIGHT)
        end
    end
    
    if self.turnManager:endTurn(self.units) then
        self:updateVisibility()
        self:centerCameraOnFirstUnit()
    end
end

function Battlescape:mousereleased(x, y, button, istouch, presses)
    -- Middle mouse button: stop dragging map
    if button == 2 then
        self.isDraggingMap = false
        print("[Battlescape] Middle mouse drag ended")
        return
    end
    
    -- Handle UI releases
    if x < GUI_WIDTH then
        self.actionsFrame:mousereleased(x, y, button)
    end
end

function Battlescape:mousemoved(x, y, dx, dy, istouch)
    -- Handle middle mouse dragging
    if self.isDraggingMap then
        local deltaX = x - self.dragStartX
        local deltaY = y - self.dragStartY
        
        -- Update camera position (dragging moves camera in opposite direction)
        self.camera.x = self.dragStartCameraX + deltaX
        self.camera.y = self.dragStartCameraY + deltaY
        
        return
    end
    
    -- Update hovered tile
    self:updateHoveredTile(x, y)
    
    -- Handle UI hover
    if x < GUI_WIDTH then
        self.actionsFrame:mousemoved(x, y, dx, dy)
    else
        -- Update path preview if unit is selected and hovering battlefield
        if self.hoveredTileX and self.hoveredTileY then
            self.selection:updateHover(self.hoveredTileX, self.hoveredTileY, 
                self.battlefield, self.actionSystem, self.pathfinding)
        end
    end
end

function Battlescape:updateHoveredTile(x, y)
    -- Check if mouse is over battlefield
    if x < GUI_WIDTH then
        self.hoveredTileX = nil
        self.hoveredTileY = nil
        return
    end
    
    -- Use viewport system to convert screen to tile coordinates
    local tileX, tileY = Viewport.screenToTile(x, y, self.camera, TILE_SIZE)
    
    -- Adjust for hex offset
    if tileX % 2 == 0 then
        local bfX, bfY = Viewport.screenToBattlefield(x, y)
        local worldY = (bfY - self.camera.y) / self.camera.zoom
        tileY = math.floor((worldY - (TILE_SIZE * 0.5)) / TILE_SIZE) + 1
    end
    
    -- Validate tile is within map bounds
    if tileX >= 1 and tileX <= MAP_WIDTH and tileY >= 1 and tileY <= MAP_HEIGHT then
        self.hoveredTileX = tileX
        self.hoveredTileY = tileY
    else
        self.hoveredTileX = nil
        self.hoveredTileY = nil
    end
end

function Battlescape:getUnitAt(x, y)
    for _, unit in pairs(self.units) do
        if unit and unit.alive and unit.x == x and unit.y == y then
            return unit
        end
    end
    return nil
end

function Battlescape:wheelmoved(x, y)
    -- Zoom functionality could go here
end

function Battlescape:resize(w, h)
    print(string.format("[Battlescape] Window resized to %dx%d (GUI fixed on left side)", w, h))
    -- GUI is now fixed on left side, no repositioning needed
end

-- Handle right-click unit rotation
function Battlescape:handleUnitRotation(x, y)
    if not self.selection.selectedUnit then
        return
    end
    
    -- Convert screen coordinates to tile coordinates
    local tileX, tileY = Viewport.screenToTile(x, y, self.camera, TILE_SIZE)
    
    -- Adjust for hex offset
    if tileX % 2 == 0 then
        local bfX, bfY = Viewport.screenToBattlefield(x, y)
        local worldY = (bfY - self.camera.y) / self.camera.zoom
        tileY = math.floor((worldY - (TILE_SIZE * 0.5)) / TILE_SIZE) + 1
    end
    
    -- Calculate direction from unit to clicked position
    local unit = self.selection.selectedUnit
    local dx = tileX - unit.x
    local dy = tileY - unit.y
    
    -- Convert to hex direction (0-5, where 0 = east, increasing clockwise)
    local targetFacing = self:calculateHexFacing(dx, dy)
    
    -- Rotate unit with animation
    local success = self.actionSystem:rotateUnitAnimated(unit, targetFacing, self.animationSystem, function()
        -- Update LOS after rotation completes
        self:updateVisibility()
    end)
    
    if success then
        print(string.format("[Battlescape] Rotating %s to face (%d,%d) - direction %d", 
              unit.name, tileX, tileY, targetFacing))
    end
end

-- Calculate hex facing direction from delta coordinates
function Battlescape:calculateHexFacing(dx, dy)
    -- Hex directions: 0=east, 1=southeast, 2=southwest, 3=west, 4=northwest, 5=northeast
    
    -- Handle exact cardinal directions first
    if dx > 0 and dy == 0 then return 0 end      -- East
    if dx < 0 and dy == 0 then return 3 end      -- West
    if dx == 0 and dy > 0 then return 1 end      -- Southeast (assuming pointy-top hex)
    if dx == 0 and dy < 0 then return 4 end      -- Northwest
    
    -- Handle diagonal directions
    if dx > 0 and dy > 0 then return 1 end       -- Southeast
    if dx > 0 and dy < 0 then return 5 end       -- Northeast
    if dx < 0 and dy > 0 then return 2 end       -- Southwest
    if dx < 0 and dy < 0 then return 4 end       -- Northwest
    
    -- Default to current facing if no clear direction
    return self.selection.selectedUnit.facing or 0
end

-- New action handler functions for 4x4 button layout
function Battlescape:performInventoryAction(action)
    print("[Battlescape] Inventory action: " .. action)
    if not self.selection.selectedUnit then
        print("[Battlescape] No unit selected for inventory action")
        return
    end
    
    if action == "weapon_left" then
        -- Switch to left weapon
        print("[Battlescape] Switching to left weapon")
    elseif action == "weapon_right" then
        -- Switch to right weapon
        print("[Battlescape] Switching to right weapon")
    elseif action == "armour" then
        -- Show armour menu
        print("[Battlescape] Opening armour menu")
    elseif action == "skill" then
        -- Show skills menu
        print("[Battlescape] Opening skills menu")
    end
end

function Battlescape:performUnitAction(action)
    print("[Battlescape] Unit action: " .. action)
    if not self.selection.selectedUnit then
        print("[Battlescape] No unit selected for action")
        return
    end
    
    if action == "rest" then
        -- Unit rests (regain some AP)
        print("[Battlescape] Unit resting")
    elseif action == "overwatch" then
        -- Enter overwatch mode
        print("[Battlescape] Entering overwatch mode")
    elseif action == "cover" then
        -- Take cover
        print("[Battlescape] Taking cover")
    elseif action == "aim" then
        -- Aim for better accuracy
        print("[Battlescape] Aiming")
    end
end

function Battlescape:performMovementAction(action)
    print("[Battlescape] Movement action: " .. action)
    if not self.selection.selectedUnit then
        print("[Battlescape] No unit selected for movement")
        return
    end
    
    if action == "walk" then
        -- Normal walking speed
        print("[Battlescape] Switching to walk mode")
    elseif action == "sneak" then
        -- Sneaking (quieter but slower)
        print("[Battlescape] Switching to sneak mode")
    elseif action == "run" then
        -- Running (faster but noisier)
        print("[Battlescape] Switching to run mode")
    elseif action == "fly" then
        -- Flying (if unit can fly)
        print("[Battlescape] Switching to fly mode")
    end
end

function Battlescape:performMapAction(action)
    print("[Battlescape] Map action: " .. action)
    
    if action == "next_unit" then
        -- Select next unit in team
        self:selectNextUnit()
    elseif action == "toggle_zoom" then
        -- Toggle minimap zoom
        self:toggleMinimapZoom()
    elseif action == "menu" then
        -- Open game menu
        StateManager.switch("menu")
    elseif action == "end_turn" then
        -- End current team's turn
        self:switchTeam()
    end
end

function Battlescape:selectNextUnit()
    local activeTeam = self.turnManager:getCurrentTeam()
    if not activeTeam or not activeTeam.units then return end
    
    -- Find current selected unit index
    local currentIndex = 0
    if self.selection.selectedUnit then
        for i, unitId in ipairs(activeTeam.units) do
            if unitId == self.selection.selectedUnit.id then
                currentIndex = i
                break
            end
        end
    end
    
    -- Find next living unit
    local nextIndex = currentIndex + 1
    if nextIndex > #activeTeam.units then
        nextIndex = 1
    end
    
    for i = 1, #activeTeam.units do
        local unitId = activeTeam.units[nextIndex]
        local unit = self.units[unitId]
        if unit and unit.alive then
            self.selection:selectUnit(unit, self.battlefield)
            self.camera:centerOn(unit.x, unit.y, TILE_SIZE, 360, 360)
            print(string.format("[Battlescape] Selected next unit: %s", unit.name))
            return
        end
        nextIndex = nextIndex + 1
        if nextIndex > #activeTeam.units then
            nextIndex = 1
        end
    end
end

function Battlescape:toggleMinimapZoom()
    -- Toggle between different zoom levels for minimap
    print("[Battlescape] Toggling minimap zoom")
end

return Battlescape
