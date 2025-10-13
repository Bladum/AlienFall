-- Battlescape Logic Module
-- Contains game logic and state management

local StateManager = require("core.state_manager")
local Widgets = require("widgets.init")
local Unit = require("battlescape.combat.unit")
local Team = require("shared.team")
local ActionSystem = require("battlescape.combat.action_system")
local Pathfinding = require("shared.pathfinding")
local LOS = require("battlescape.combat.los_optimized")  -- OPTIMIZED VERSION
local Assets = require("core.assets")
local AnimationSystem = require("battlescape.effects.animation_system")

-- Battle components
local Battlefield = require("battlescape.logic.battlefield")
local Camera = require("battlescape.rendering.camera")
local UnitSelection = require("battlescape.logic.unit_selection")
local BattlefieldRenderer = require("battlescape.rendering.renderer")
local TurnManager = require("battlescape.logic.turn_manager")

-- Fire and Smoke systems
local FireSystem = require("battlescape.effects.fire_system")
local SmokeSystem = require("battlescape.effects.smoke_system")

-- MapBlock system
local MapBlock = require("battlescape.map.map_block")
local GridMap = require("battlescape.map.grid_map")

-- Map generation system
local MapGenerator = require("battlescape.map.map_generator")

-- New ECS Battle System
local HexSystem = require("battle.systems.hex_system")
local MovementSystem = require("battle.systems.movement_system")
local VisionSystem = require("battle.systems.vision_system")
local UnitEntity = require("battle.entities.unit_entity")
local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

-- Load viewport system
local Viewport = require("utils.viewport")

local BattlescapeLogic = {}

-- Constants
local TILE_SIZE = 24
local MAP_WIDTH = 90
local MAP_HEIGHT = 90
local GUI_WIDTH = 240  -- 10 tiles × 24px
local GUI_HEIGHT = 720  -- 30 tiles × 24px
local SECTION_HEIGHT = 240  -- 10 tiles × 24px

-- Day/Night
BattlescapeLogic.isNight = false

function BattlescapeLogic:enter(battlescape)
    print("[Battlescape] Entering battlescape state")
    
    -- Start profiling
    local startTime = love.timer.getTime()
    local stepStartTime = startTime
    
    -- Initialize core systems
    battlescape.actionSystem = ActionSystem.new()
    battlescape.pathfinding = Pathfinding.new()
    battlescape.teamManager = Team.Manager.new()
    battlescape.losSystem = LOS.new()
    battlescape.animationSystem = AnimationSystem.new()
    
    -- Initialize fire and smoke systems
    battlescape.fireSystem = FireSystem.new()
    battlescape.smokeSystem = SmokeSystem.new()
    print("[Battlescape] Fire and Smoke systems initialized")
    
    -- Log optimization status
    print("[Battlescape] Using OPTIMIZED LOS system with shadow casting + caching")
    
    print(string.format("[PROFILE] Core systems init: %.3f ms", (love.timer.getTime() - stepStartTime) * 1000))
    stepStartTime = love.timer.getTime()

    -- Initialize turn system first
    battlescape.turnManager = TurnManager.new(battlescape.teamManager, battlescape.actionSystem)
    
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
        local ModManager = require("core.mod_manager")
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
                battlescape.battlefield = MapGenerator.generate({
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
    if generationMethod == "procedural" or not battlescape.battlefield then
        battlescape.battlefield = MapGenerator.generate({
            method = "procedural",
            width = 60,
            height = 60,
            seed = nil  -- Random seed
        })
    end
    
    if not battlescape.battlefield then
        print("[Battlescape] ERROR: Failed to generate battlefield")
        return
    end
    
    print(string.format("[Battlescape] Generated battlefield: %dx%d tiles", battlescape.battlefield.width, battlescape.battlefield.height))
    
    -- Update MAP_WIDTH and MAP_HEIGHT constants for this session
    MAP_WIDTH = battlescape.battlefield.width
    MAP_HEIGHT = battlescape.battlefield.height
    
    -- Initialize camera
    battlescape.camera = Camera.new(battlescape.battlefield.width * TILE_SIZE / 2, battlescape.battlefield.height * TILE_SIZE / 2)
    
    -- Initialize battlefield renderer
    battlescape.battlefieldRenderer = BattlefieldRenderer.new(TILE_SIZE)
    
    -- Initialize teams and units
    self:initTeams(battlescape)
    self:initUnits(battlescape)
    
    -- Initialize UI
    self:initUI(battlescape)
    
    print(string.format("[PROFILE] Total init time: %.3f ms", (love.timer.getTime() - startTime) * 1000))
end

function BattlescapeLogic:exit(battlescape)
    print("[Battlescape] Exiting battlescape state")
end

function BattlescapeLogic:initTeams(battlescape)
    -- Create teams
    battlescape.teams = {}
    
    -- Player team (blue)
    local playerTeam = Team.new("player", "Player", Team.SIDES.PLAYER)
    table.insert(battlescape.teams, playerTeam)
    
    -- AI team (red)
    local aiTeam = Team.new("aliens", "Aliens", Team.SIDES.ENEMY)
    table.insert(battlescape.teams, aiTeam)
    
    -- Register teams with team manager
    for _, team in ipairs(battlescape.teams) do
        battlescape.teamManager:addTeam(team)
    end
end

function BattlescapeLogic:initUnits(battlescape)
    -- Create units for each team
    battlescape.units = {}
    
    -- Player units
    local playerTeam = battlescape.teams[1]
    for i = 1, 4 do
        local unit = Unit.new("soldier", playerTeam, i * 48, i * 48)
        table.insert(battlescape.units, unit)
        playerTeam:addUnit(unit)
    end
    
    -- AI units
    local aiTeam = battlescape.teams[2]
    for i = 1, 3 do
        local unit = Unit.new("sectoid", aiTeam, (MAP_WIDTH - i) * TILE_SIZE, (MAP_HEIGHT - i) * TILE_SIZE)
        table.insert(battlescape.units, unit)
        aiTeam:addUnit(unit)
    end
end

function BattlescapeLogic:getNextUnitId()
    self.nextUnitId = (self.nextUnitId or 0) + 1
    return self.nextUnitId
end

function BattlescapeLogic:countUnits(battlescape)
    local count = 0
    for _, team in ipairs(battlescape.teams) do
        count = count + #team.units
    end
    return count
end

function BattlescapeLogic:centerCameraOnFirstUnit()
    if #self.units > 0 then
        local firstUnit = self.units[1]
        self.camera:centerOn(firstUnit.x, firstUnit.y)
    end
end

function BattlescapeLogic:updateVisibility(battlescape)
    -- Update line of sight for all units
    for _, unit in ipairs(battlescape.units) do
        unit:updateVisibility(battlescape.battlefield, battlescape.units)
    end
end

function BattlescapeLogic:toggleDayNight(battlescape)
    battlescape.isNight = not battlescape.isNight
    print("[Battlescape] Day/Night toggled:", battlescape.isNight)
    
    -- Update visibility for all units
    self:updateVisibility(battlescape)
end

return BattlescapeLogic