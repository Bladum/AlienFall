-- ============================================================================
-- DEPLOYMENT SYSTEM
-- ============================================================================
-- Handles tactical deployment, landing zones, and unit placement for battlescape
-- ============================================================================

local DeploymentSystem = {}
DeploymentSystem.__index = DeploymentSystem

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function DeploymentSystem:new(battleMap)
    local self = setmetatable({}, DeploymentSystem)
    self.battleMap = battleMap
    self.landingZones = {}
    self.deployedUnits = {}
    self.deploymentOrder = {}
    self.maxDeploymentTurns = 3
    self.currentTurn = 1
    self.advanceAttempts = 0
    return self
end

-- ============================================================================
-- LANDING ZONE MANAGEMENT
-- ============================================================================

function DeploymentSystem:generateLandingZones(missionType, unitCount)
    -- Generate landing zones based on mission type
    self.landingZones = {}

    if missionType == "assault" then
        -- Assault missions have 2-3 landing zones
        table.insert(self.landingZones, {x = 5, y = 5, size = "large", reserved = false, occupied = false})
        table.insert(self.landingZones, {x = 15, y = 5, size = "medium", reserved = false, occupied = false})
        table.insert(self.landingZones, {x = 10, y = 15, size = "small", reserved = false, occupied = false})
    elseif missionType == "infiltration" then
        -- Infiltration has 1 hidden landing zone
        table.insert(self.landingZones, {x = 20, y = 20, size = "small", reserved = false, occupied = false, hidden = true})
    else
        -- Default: single landing zone
        table.insert(self.landingZones, {x = 10, y = 10, size = "medium", reserved = false, occupied = false})
    end

    return self.landingZones
end

function DeploymentSystem:getAvailableLandingZones()
    local available = {}
    for _, zone in ipairs(self.landingZones) do
        if not zone.reserved and not zone.occupied then
            table.insert(available, zone)
        end
    end
    return available
end

function DeploymentSystem:reserveLandingZone(zoneIndex)
    if zoneIndex <= #self.landingZones then
        local zone = self.landingZones[zoneIndex]
        if not zone.reserved and not zone.occupied then
            zone.reserved = true
            return zone
        end
    end
    return nil
end-- ============================================================================
-- UNIT DEPLOYMENT
-- ============================================================================

function DeploymentSystem:deployUnit(unitId, landingZone, position)
    -- Validate landing zone
    if not landingZone or landingZone.occupied then
        return false, "Invalid or occupied landing zone"
    end

    -- Check if position is valid on map
    if not self.battleMap:isValidPosition(position.x, position.y) then
        return false, "Invalid map position"
    end

    -- Validate position is adjacent to landing zone
    local distance = math.abs(position.x - landingZone.x) + math.abs(position.y - landingZone.y)
    if distance > 2 then
        return false, "Position too far from landing zone"
    end

    -- Deploy unit
    self.deployedUnits[unitId] = {
        id = unitId,
        position = position,
        landingZone = landingZone,
        deployed = true,
        deploymentTurn = self.currentTurn
    }

    table.insert(self.deploymentOrder, unitId)
    return true
end

function DeploymentSystem:getDeploymentOrder()
    return self.deploymentOrder
end

function DeploymentSystem:getDeployedUnits()
    return self.deployedUnits
end

-- ============================================================================
-- DEPLOYMENT TURN MANAGEMENT
-- ============================================================================

function DeploymentSystem:advanceDeploymentTurn()
    self.advanceAttempts = self.advanceAttempts + 1
    if self.currentTurn < self.maxDeploymentTurns then
        self.currentTurn = self.currentTurn + 1
    end
    return self.currentTurn <= self.maxDeploymentTurns
end

function DeploymentSystem:canDeployMoreUnits()
    return self.advanceAttempts <= self.maxDeploymentTurns
end

function DeploymentSystem:getCurrentDeploymentTurn()
    return self.currentTurn
end

function DeploymentSystem:getMaxDeploymentTurns()
    return self.maxDeploymentTurns
end

-- ============================================================================
-- SCORING AND VALIDATION
-- ============================================================================

function DeploymentSystem:calculateDeploymentScore()
    local score = 0
    local unitCount = 0

    for _, unit in pairs(self.deployedUnits) do
        unitCount = unitCount + 1
        -- Bonus for early deployment
        score = score + (self.maxDeploymentTurns - unit.deploymentTurn + 1) * 10
        -- Bonus for good positioning (closer to center)
        local centerDist = math.abs(unit.position.x - 12) + math.abs(unit.position.y - 12)
        score = score + math.max(0, 20 - centerDist)
    end

    return score, unitCount
end

function DeploymentSystem:validateDeployment()
    local errors = {}

    -- Check all units are deployed
    if #self.deploymentOrder == 0 then
        table.insert(errors, "No units deployed")
    end

    -- Check landing zones are used efficiently
    local usedZones = 0
    for _, zone in ipairs(self.landingZones) do
        if zone.reserved then
            usedZones = usedZones + 1
        end
    end

    if usedZones == 0 then
        table.insert(errors, "No landing zones used")
    end

    -- Check deployment turns
    if self.currentTurn > self.maxDeploymentTurns then
        table.insert(errors, "Exceeded maximum deployment turns")
    end

    return #errors == 0, errors
end

return DeploymentSystem
