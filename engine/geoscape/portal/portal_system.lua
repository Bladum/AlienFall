-- Portal System - Late Game Dimensional Gateway Feature
-- Enables cross-dimensional travel and alternate reality mechanics

local PortalSystem = {}
PortalSystem.__index = PortalSystem

-- Initialize portal system
function PortalSystem.new()
    local self = setmetatable({}, PortalSystem)
    
    -- Portal states
    self.PORTAL_STATES = {
        INACTIVE = "inactive",
        CHARGING = "charging",
        ACTIVE = "active",
        COLLAPSING = "collapsing",
        CLOSED = "closed"
    }
    
    -- Portal types
    self.PORTAL_TYPES = {
        RESEARCH = { costToOpen = 500000, cooldown = 24, destinationType = "RESEARCH_DIMENSION" },
        RESOURCE = { costToOpen = 400000, cooldown = 48, destinationType = "RESOURCE_DIMENSION" },
        ENEMY = { costToOpen = 600000, cooldown = 12, destinationType = "ENEMY_DIMENSION" },
        ESCAPE = { costToOpen = 300000, cooldown = 1, destinationType = "SAFE_DIMENSION" }
    }
    
    -- Active portals
    self.portals = {}
    self.nextPortalId = 1
    
    -- Portal destinations
    self.destinations = {}
    self:initializeDestinations()
    
    return self
end

-- Initialize portal destinations
function PortalSystem:initializeDestinations()
    self.destinations = {
        RESEARCH_DIMENSION = {
            name = "Research Dimension",
            type = "RESEARCH",
            rewards = { researchPoints = 50000, tech = "ALIEN_TECHNOLOGY" },
            difficulty = 3,
            duration = 3600 -- 1 hour
        },
        RESOURCE_DIMENSION = {
            name = "Resource Dimension",
            type = "RESOURCE",
            rewards = { supplies = 5000, ammo = 2000, materials = 1000 },
            difficulty = 2,
            duration = 1800 -- 30 minutes
        },
        ENEMY_DIMENSION = {
            name = "Enemy Dimension",
            type = "ENEMY",
            rewards = { aliens = 50, tech = 2, prestige = 1000 },
            difficulty = 5,
            duration = 7200 -- 2 hours
        },
        SAFE_DIMENSION = {
            name = "Safe Dimension",
            type = "ESCAPE",
            rewards = { credits = 250000, morale = 50 },
            difficulty = 1,
            duration = 900 -- 15 minutes
        }
    }
end

-- Create portal at location
function PortalSystem:createPortal(portalType, location)
    if not self.PORTAL_TYPES[portalType] then
        return nil
    end
    
    local portal = {
        id = self.nextPortalId,
        type = portalType,
        location = location,
        state = self.PORTAL_STATES.CHARGING,
        createdAt = os.time(),
        chargeProgress = 0,
        chargeTime = 60, -- seconds
        active = false,
        expiresAt = nil
    }
    
    self.nextPortalId = self.nextPortalId + 1
    table.insert(self.portals, portal)
    
    return portal
end

-- Update portal charging/expiration
function PortalSystem:updatePortals(deltaTime)
    for i = #self.portals, 1, -1 do
        local portal = self.portals[i]
        
        if portal.state == self.PORTAL_STATES.CHARGING then
            portal.chargeProgress = portal.chargeProgress + deltaTime
            
            if portal.chargeProgress >= portal.chargeTime then
                portal.state = self.PORTAL_STATES.ACTIVE
                portal.active = true
                portal.expiresAt = os.time() + 3600 -- Stays active for 1 hour
            end
            
        elseif portal.state == self.PORTAL_STATES.ACTIVE then
            if os.time() >= portal.expiresAt then
                portal.state = self.PORTAL_STATES.COLLAPSING
            end
            
        elseif portal.state == self.PORTAL_STATES.COLLAPSING then
            portal.collapseProgress = (portal.collapseProgress or 0) + deltaTime
            
            if portal.collapseProgress >= 5 then
                portal.state = self.PORTAL_STATES.CLOSED
                table.remove(self.portals, i)
            end
        end
    end
end

-- Enter portal (travel to destination)
function PortalSystem:enterPortal(portal, squad)
    if not portal.active or portal.state ~= self.PORTAL_STATES.ACTIVE then
        return false, "Portal not active"
    end
    
    local destination = self.destinations[self.PORTAL_TYPES[portal.type].destinationType]
    
    if not destination then
        return false, "Unknown destination"
    end
    
    -- Create expedition
    local expedition = {
        id = portal.id,
        destination = destination,
        squad = squad,
        startTime = os.time(),
        status = "TRAVELING",
        difficulty = destination.difficulty
    }
    
    return true, expedition
end

-- Execute portal mission (events/encounters in alternate dimension)
function PortalSystem:executeMission(expedition)
    local results = {
        success = false,
        casualties = 0,
        rewards = {}
    }
    
    -- Difficulty-based success calculation
    local successChance = 1 - (expedition.difficulty * 0.15)
    
    if math.random() < successChance then
        results.success = true
        results.rewards = self:getDestinationRewards(expedition.destination)
        results.casualties = math.floor(#expedition.squad * (math.random() * 0.2))
    else
        results.success = false
        results.casualties = math.floor(#expedition.squad * (math.random() * 0.4))
    end
    
    return results
end

-- Get rewards from portal destination
function PortalSystem:getDestinationRewards(destination)
    local rewards = destination.rewards or {}
    
    -- Scale rewards by difficulty
    local scaledRewards = {}
    for key, value in pairs(rewards) do
        if type(value) == "number" then
            scaledRewards[key] = math.floor(value * (1 + destination.difficulty * 0.2))
        else
            scaledRewards[key] = value
        end
    end
    
    return scaledRewards
end

-- Validate portal execution
function PortalSystem:validatePortalExecution(portal, squad, base)
    local errors = {}
    
    -- Check portal state
    if not portal.active then
        table.insert(errors, "Portal not active")
    end
    
    -- Check squad size
    if not squad or #squad == 0 then
        table.insert(errors, "Squad required")
    end
    
    -- Check cost
    local cost = self.PORTAL_TYPES[portal.type].costToOpen
    if base.funding < cost then
        table.insert(errors, "Insufficient funding")
    end
    
    -- Check equipment
    if not self:hasRequiredEquipment(squad, portal.type) then
        table.insert(errors, "Squad lacks required equipment for portal travel")
    end
    
    return #errors == 0, errors
end

-- Check if squad has required equipment for portal travel
function PortalSystem:hasRequiredEquipment(squad, portalType)
    -- Simplified - in reality would check inventory
    local requiredItems = {
        RESEARCH = { "ALIEN_DETECTOR", "RESEARCH_KIT" },
        RESOURCE = { "COLLECTION_KIT" },
        ENEMY = { "ADVANCED_WEAPONS" },
        ESCAPE = { "EMERGENCY_BEACON" }
    }
    
    if not requiredItems[portalType] then
        return true
    end
    
    -- Check if squad leader has equipment
    if squad[1] and squad[1].inventory then
        for _, item in ipairs(requiredItems[portalType]) do
            local hasItem = false
            for _, invItem in ipairs(squad[1].inventory) do
                if invItem == item then
                    hasItem = true
                    break
                end
            end
            if not hasItem then
                return false
            end
        end
    end
    
    return true
end

-- Deduct cost from base funding
function PortalSystem:deductPortalCost(base, portalType)
    local cost = self.PORTAL_TYPES[portalType].costToOpen
    
    if base.funding >= cost then
        base.funding = base.funding - cost
        return true
    end
    
    return false
end

-- Handle world state changes from portal mission
function PortalSystem:applyWorldStateChanges(expedition, results, world)
    if results.success then
        -- Apply research rewards
        if expedition.destination.type == "RESEARCH" then
            world.research = world.research + (results.rewards.researchPoints or 0)
        end
        
        -- Apply resource rewards
        if expedition.destination.type == "RESOURCE" then
            world.supplies = (world.supplies or 0) + (results.rewards.supplies or 0)
            world.ammunition = (world.ammunition or 0) + (results.rewards.ammo or 0)
        end
        
        -- Apply mission achievements
        if expedition.destination.type == "ENEMY" then
            world.aliensDefeated = (world.aliensDefeated or 0) + (results.rewards.aliens or 0)
        end
        
        -- Credits
        world.funding = (world.funding or 0) + (results.rewards.credits or 0)
    end
    
    -- Always apply casualties
    if results.casualties > 0 then
        world.totalCasualties = (world.totalCasualties or 0) + results.casualties
    end
end

-- Get active portals at location
function PortalSystem:getActivePortalsAt(location)
    local active = {}
    
    for _, portal in ipairs(self.portals) do
        if portal.active and portal.location == location then
            table.insert(active, portal)
        end
    end
    
    return active
end

-- Get portal status report
function PortalSystem:getStatusReport()
    local report = {
        activePortals = 0,
        chargingPortals = 0,
        availableTypes = {}
    }
    
    for _, portal in ipairs(self.portals) do
        if portal.state == self.PORTAL_STATES.ACTIVE then
            report.activePortals = report.activePortals + 1
        elseif portal.state == self.PORTAL_STATES.CHARGING then
            report.chargingPortals = report.chargingPortals + 1
        end
    end
    
    for portalType, data in pairs(self.PORTAL_TYPES) do
        table.insert(report.availableTypes, {
            type = portalType,
            cost = data.costToOpen,
            cooldown = data.cooldown
        })
    end
    
    return report
end

-- Cooldown system for portal types
function PortalSystem:getPortalCooldown(portalType)
    local cooldownTime = self.PORTAL_TYPES[portalType].cooldown * 3600 -- Convert hours to seconds
    
    -- Find last portal of this type
    local lastPortalTime = 0
    for _, portal in ipairs(self.portals) do
        if portal.type == portalType then
            lastPortalTime = math.max(lastPortalTime, portal.createdAt)
        end
    end
    
    local timeRemaining = cooldownTime - (os.time() - lastPortalTime)
    
    return math.max(0, timeRemaining)
end

-- Draw portal visualization (simple)
function PortalSystem:drawPortal(portal, x, y, radius)
    if not portal or not portal.active then
        return
    end
    
    -- Portal glow
    love.graphics.setColor(0.3 + math.sin(os.time()) * 0.3, 0.2, 0.8, 0.5)
    love.graphics.circle("fill", x, y, radius)
    
    -- Portal ring
    love.graphics.setColor(0.5, 0.3, 1)
    love.graphics.circle("line", x, y, radius)
    
    -- Charge progress if charging
    if portal.state == self.PORTAL_STATES.CHARGING then
        local progress = portal.chargeProgress / portal.chargeTime
        love.graphics.setColor(1, 1, 0, 0.7)
        love.graphics.arc("line", "open", x, y, radius + 10, 0, progress * 2 * math.pi, 32)
    end
end

-- Portal cooldown display
function PortalSystem:getPortalReadiness(portalType)
    local cooldownRemaining = self:getPortalCooldown(portalType)
    
    if cooldownRemaining <= 0 then
        return "READY", 1.0
    else
        local percentage = 1 - (cooldownRemaining / (self.PORTAL_TYPES[portalType].cooldown * 3600))
        return "COOLING", percentage
    end
end

return PortalSystem
