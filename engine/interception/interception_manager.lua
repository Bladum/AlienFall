---Interception Manager - Master Orchestrator for Air Combat
---
---Coordinates UFO interception mechanics including altitude management,
---target selection, combat resolution, and facility integration.
---
---@module interception_manager
---@author AlienFall Development Team
---@license Open Source

local InterceptionManager = {}
InterceptionManager.__index = InterceptionManager

---Initialize the Interception Manager
---
---@return table self Reference to the interception manager singleton
function InterceptionManager.new()
    local self = setmetatable({}, InterceptionManager)

    print("[InterceptionManager] Initializing interception systems...")

    self.altitudeMechanics = require("interception.altitude_mechanics")
    self.combatUI = require("interception.combat_ui")
    self.facilityIntegration = require("interception.facility_integration")
    self.targetDisplay = require("interception.target_display")
    self.ufoAI = require("interception.ufo_ai_behavior")

    self.activeInterceptions = {}
    self.currentCombat = nil

    print("[InterceptionManager] Interception systems initialized")

    return self
end

---Start a new interception event
---
---@param ufoData table UFO details (position, altitude, speed, etc.)
---@param interceptorData table Interceptor craft details
---@return table The interception session
function InterceptionManager:startInterception(ufoData, interceptorData)
    print("[InterceptionManager] Starting interception...")

    local interception = {
        id = #self.activeInterceptions + 1,
        ufo = ufoData,
        interceptor = interceptorData,
        state = "active",
        altitude = ufoData.altitude,
        distance = ufoData.distance,
    }

    table.insert(self.activeInterceptions, interception)

    if self.combatUI and self.combatUI.startCombat then
        self.combatUI:startCombat(interception)
    end

    return interception
end

---Update all active interceptions
---
---@param dt number Delta time in seconds
function InterceptionManager:update(dt)
    for i = #self.activeInterceptions, 1, -1 do
        local interception = self.activeInterceptions[i]

        if self.altitudeMechanics and self.altitudeMechanics.update then
            self.altitudeMechanics:update(dt, interception)
        end

        if self.ufoAI and self.ufoAI.update then
            self.ufoAI:update(dt, interception)
        end

        -- Check if interception ended
        if interception.state == "completed" or interception.state == "failed" then
            table.remove(self.activeInterceptions, i)
        end
    end
end

---Draw interception UI
function InterceptionManager:draw()
    if self.targetDisplay and self.targetDisplay.draw then
        self.targetDisplay:draw(self.activeInterceptions)
    end
    if self.combatUI and self.combatUI.draw then
        self.combatUI:draw()
    end
end

---Get active interceptions
---
---@return table Array of active interception sessions
function InterceptionManager:getActiveInterceptions()
    return self.activeInterceptions
end

return InterceptionManager
