-- Battlescape State (Refactored)
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

-- Load submodules
local BattlescapeLogic = require("modules.battlescape.logic")
local BattlescapeRender = require("modules.battlescape.render")
local BattlescapeInput = require("modules.battlescape.input")
local BattlescapeUI = require("modules.battlescape.ui")

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

function Battlescape.new()
    local self = setmetatable({}, {__index = Battlescape})
    
    -- Initialize state variables
    self.turnNumber = 1
    self.currentTeam = nil
    self.showDebug = false
    self.hoveredTile = nil
    
    return self
end

function Battlescape:enter()
    print("[Battlescape] Entering battlescape state")
    
    -- Delegate to logic module
    BattlescapeLogic:enter(self)
    
    -- Initialize UI after logic setup
    BattlescapeUI:initUI(self)
end

function Battlescape:exit()
    print("[Battlescape] Exiting battlescape state")
    
    -- Delegate to logic module
    BattlescapeLogic:exit(self)
end

function Battlescape:update(dt)
    -- Update game logic
    if self.turnManager then
        self.turnManager:update(dt)
    end
    
    -- Update animations
    if self.animationSystem then
        self.animationSystem:update(dt)
    end
    
    -- Update fire and smoke systems
    if self.fireSystem then
        self.fireSystem:update(dt)
    end
    if self.smokeSystem then
        self.smokeSystem:update(dt)
    end
    
    -- Update UI
    BattlescapeUI:updateUI(self, dt)
end

function Battlescape:draw()
    -- Delegate to render module
    BattlescapeRender:draw(self)
    
    -- Draw UI on top
    BattlescapeUI:drawUI(self)
end

function Battlescape:keypressed(key, scancode, isrepeat)
    -- Delegate to input module
    return BattlescapeInput:keypressed(self, key)
end

function Battlescape:mousepressed(x, y, button, istouch, presses)
    -- Delegate to input module
    return BattlescapeInput:mousepressed(self, x, y, button)
end

function Battlescape:mousemoved(x, y, dx, dy, istouch)
    -- Delegate to input module
    return BattlescapeInput:mousemoved(self, x, y, dx, dy)
end

function Battlescape:wheelmoved(x, y)
    -- Delegate to input module
    return BattlescapeInput:wheelmoved(self, x, y)
end

-- Delegate methods to logic module
function Battlescape:countUnits()
    return BattlescapeLogic:countUnits(self)
end

function Battlescape:toggleDayNight()
    BattlescapeLogic:toggleDayNight(self)
end

return Battlescape