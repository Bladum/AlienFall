---Battle Manager - Master Orchestrator for Battlescape Systems
---
---Coordinates all tactical combat systems including ECS, combat resolution,
---UI, pathfinding, and effects. Acts as central hub for battle-wide events
---and state management.
---
---@module battle_manager
---@author AlienFall Development Team
---@license Open Source

local BattleManager = {}
BattleManager.__index = BattleManager

---Initialize the Battle Manager
---
---@return table self Reference to the battle manager singleton
function BattleManager.new()
    local self = setmetatable({}, BattleManager)

    print("[BattleManager] Initializing battlescape systems...")

    self.ecs = nil           -- Entity Component System
    self.combat = nil        -- Combat resolution
    self.map = nil           -- Map and terrain
    self.ai = nil            -- Tactical AI
    self.effects = nil       -- Visual effects
    self.ui = nil            -- Battlescape UI
    self.currentBattle = nil -- Active battle state

    print("[BattleManager] Battle manager initialized")

    return self
end

---Initialize a new battle session
---
---@param battleData table Battle configuration and initial state
---@return boolean Success or failure
function BattleManager:initializeBattle(battleData)
    print("[BattleManager] Initializing new battle...")

    self.currentBattle = {
        state = "initialize",
        teams = {},
        entities = {},
        terrain = nil,
    }

    if self.map and self.map.load then
        self.map:load(battleData)
    end

    if self.ecs and self.ecs.initialize then
        self.ecs:initialize(battleData)
    end

    print("[BattleManager] Battle initialized successfully")
    return true
end

---Update battle systems each frame
---
---@param dt number Delta time in seconds
function BattleManager:update(dt)
    if self.currentBattle == nil then return end

    if self.ecs and self.ecs.update then
        self.ecs:update(dt)
    end
    if self.ai and self.ai.update then
        self.ai:update(dt)
    end
    if self.effects and self.effects.update then
        self.effects:update(dt)
    end
    if self.ui and self.ui.update then
        self.ui:update(dt)
    end
end

---Draw battle to screen
function BattleManager:draw()
    if self.currentBattle == nil then return end

    if self.map and self.map.draw then
        self.map:draw()
    end
    if self.ecs and self.ecs.draw then
        self.ecs:draw()
    end
    if self.effects and self.effects.draw then
        self.effects:draw()
    end
    if self.ui and self.ui.draw then
        self.ui:draw()
    end
end

---Get current battle state
---
---@return table Battle state, or nil if no active battle
function BattleManager:getBattleState()
    return self.currentBattle
end

---End current battle
---
---@param result string "victory", "defeat", or "retreat"
---@param data table Additional result data
function BattleManager:endBattle(result, data)
    print("[BattleManager] Battle ended: " .. result)

    if self.ecs and self.ecs.cleanup then
        self.ecs:cleanup()
    end

    self.currentBattle = nil
end

return BattleManager
