---Economy Manager - Master Orchestrator for Economic Systems
---
---Coordinates all economic subsystems including finance, marketplace,
---production, and research. Acts as central hub for economy-wide events,
---resource management, and economic state synchronization.
---
---@module economy_manager
---@author AlienFall Development Team
---@license Open Source

local EconomyManager = {}
EconomyManager.__index = EconomyManager

---Initialize the Economy Manager
---
---@return table self Reference to the economy manager singleton
function EconomyManager.new()
    local self = setmetatable({}, EconomyManager)

    print("[EconomyManager] Initializing economy systems...")

    -- Load subsystems
    self.finance = require("economy.finance.finance_system")
    self.marketplace = require("economy.marketplace.marketplace_system")
    self.production = require("economy.production.production_system")
    self.research = require("economy.research.research_system")

    print("[EconomyManager] Economy systems initialized")

    return self
end

---Update economy systems each frame
---
---@param dt number Delta time in seconds
function EconomyManager:update(dt)
    if self.finance and self.finance.update then
        self.finance:update(dt)
    end
    if self.marketplace and self.marketplace.update then
        self.marketplace:update(dt)
    end
    if self.production and self.production.update then
        self.production:update(dt)
    end
    if self.research and self.research.update then
        self.research:update(dt)
    end
end

---Get current economic status
---
---@return table Economic status including resources, budget, production, research
function EconomyManager:getStatus()
    return {
        finance = self.finance and self.finance:getStatus(),
        marketplace = self.marketplace and self.marketplace:getStatus(),
        production = self.production and self.production:getStatus(),
        research = self.research and self.research:getStatus(),
    }
end

---Synchronize economy state (e.g., after loading game)
function EconomyManager:synchronize()
    print("[EconomyManager] Synchronizing economic state...")

    if self.finance and self.finance.synchronize then
        self.finance:synchronize()
    end
    if self.marketplace and self.marketplace.synchronize then
        self.marketplace:synchronize()
    end
    if self.production and self.production.synchronize then
        self.production:synchronize()
    end
    if self.research and self.research.synchronize then
        self.research:synchronize()
    end
end

return EconomyManager
