-- Interception Facility Integration System
-- Manages SAM sites, radar, and base support for interception combat

local FacilityIntegration = {}
FacilityIntegration.__index = FacilityIntegration

-- Initialize facility system
function FacilityIntegration.new()
    local self = setmetatable({}, FacilityIntegration)
    
    -- Facility types for interception support
    self.FACILITIES = {
        RADAR = {
            name = "Radar Station",
            range = 30000,
            accuracy = 0.8,
            updateRate = 0.5 -- seconds
        },
        SAM_SITE = {
            name = "SAM Site",
            range = 20000,
            firepower = 1.2,
            ammunition = 100
        },
        COMMAND_CENTER = {
            name = "Command Center",
            commandBonus = 0.15,
            coordination = true
        },
        FIGHTER_BASE = {
            name = "Fighter Base",
            craftSupport = true,
            repairCapacity = 30
        },
        EARLY_WARNING = {
            name = "Early Warning System",
            range = 40000,
            accuracy = 0.6,
            altitude_coverage = 30000
        }
    }
    
    self.activeFacilities = {}
    
    return self
end

-- Register facility as active
function FacilityIntegration:activateFacility(facilityType, baseLocation)
    if not self.FACILITIES[facilityType] then
        return false
    end
    
    local facility = {
        type = facilityType,
        data = self.FACILITIES[facilityType],
        location = baseLocation,
        operational = true,
        health = 100,
        active = true
    }
    
    table.insert(self.activeFacilities, facility)
    return true
end

-- Deactivate facility
function FacilityIntegration:deactivateFacility(facilityType)
    for i, facility in ipairs(self.activeFacilities) do
        if facility.type == facilityType then
            facility.operational = false
            table.remove(self.activeFacilities, i)
            break
        end
    end
end

-- Get radar support for craft
function FacilityIntegration:getRadarSupport(craftPosition)
    local radarBonus = 1.0
    local coverage = 0
    
    for _, facility in ipairs(self.activeFacilities) do
        if facility.type == "RADAR" or facility.type == "EARLY_WARNING" then
            if facility.operational then
                local distance = self:calculateDistance(craftPosition, facility.location)
                
                if distance <= facility.data.range then
                    local coveragePercent = 1 - (distance / facility.data.range)
                    coverage = coverage + (coveragePercent * facility.data.accuracy)
                    radarBonus = radarBonus + (coveragePercent * 0.15)
                end
            end
        end
    end
    
    return math.min(2.0, radarBonus), math.min(1, coverage)
end

-- Get SAM site support for interception
function FacilityIntegration:getSAMSiteSupport(targetPosition)
    local samSupport = {}
    
    for _, facility in ipairs(self.activeFacilities) do
        if facility.type == "SAM_SITE" then
            if facility.operational and facility.data.ammunition > 0 then
                local distance = self:calculateDistance(targetPosition, facility.location)
                
                if distance <= facility.data.range then
                    table.insert(samSupport, {
                        facility = facility,
                        distance = distance,
                        firepower = facility.data.firepower,
                        available = true
                    })
                end
            end
        end
    end
    
    return samSupport
end

-- Get command center coordination bonus
function FacilityIntegration:getCommandCenterBonus()
    for _, facility in ipairs(self.activeFacilities) do
        if facility.type == "COMMAND_CENTER" then
            if facility.operational then
                return facility.data.commandBonus, facility.data.coordination
            end
        end
    end
    
    return 0, false
end

-- Get fighter base support
function FacilityIntegration:getFighterBaseSupport()
    for _, facility in ipairs(self.activeFacilities) do
        if facility.type == "FIGHTER_BASE" then
            if facility.operational then
                return {
                    craftSupport = facility.data.craftSupport,
                    repairCapacity = facility.data.repairCapacity,
                    available = true
                }
            end
        end
    end
    
    return nil
end

-- Fire SAM at target
function FacilityIntegration:fireSAM(samFacility, targetPosition, targetData)
    if samFacility.data.ammunition <= 0 then
        return false
    end
    
    local distance = self:calculateDistance(samFacility.location, targetPosition)
    
    if distance > samFacility.data.range then
        return false -- Out of range
    end
    
    -- Calculate hit probability
    local rangeFactor = 1 - (distance / samFacility.data.range)
    local accuracy = 0.7 * rangeFactor * samFacility.data.firepower
    
    local hitProbability = math.min(0.95, accuracy)
    
    -- Consume ammunition
    samFacility.data.ammunition = samFacility.data.ammunition - 1
    
    return true, hitProbability
end

-- Repair craft at facility
function FacilityIntegration:repairCraft(craft, facilityType)
    local repairCapacity = 0
    
    if facilityType == "FIGHTER_BASE" then
        repairCapacity = 30
    elseif facilityType == "COMMAND_CENTER" then
        repairCapacity = 10
    end
    
    if repairCapacity > 0 then
        craft.health = math.min(craft.maxHealth, craft.health + repairCapacity)
        return true
    end
    
    return false
end

-- Get facility status report
function FacilityIntegration:getFacilityStatus()
    local status = {}
    
    for _, facility in ipairs(self.activeFacilities) do
        table.insert(status, {
            type = facility.type,
            name = facility.data.name,
            operational = facility.operational,
            health = facility.health
        })
    end
    
    return status
end

-- Respond to UFO activity at location
function FacilityIntegration:respondToUFOActivity(ufoPosition, baseLocation)
    local alerts = {}
    
    -- Early warning detection
    for _, facility in ipairs(self.activeFacilities) do
        if (facility.type == "RADAR" or facility.type == "EARLY_WARNING") then
            local distance = self:calculateDistance(ufoPosition, facility.location)
            
            if distance <= facility.data.range then
                table.insert(alerts, {
                    type = "DETECTION",
                    facility = facility.type,
                    distance = distance
                })
            end
        end
    end
    
    -- SAM site response
    local samSupport = self:getSAMSiteSupport(ufoPosition)
    if #samSupport > 0 then
        for _, sam in ipairs(samSupport) do
            table.insert(alerts, {
                type = "SAM_AVAILABLE",
                facility = "SAM_SITE",
                firepower = sam.firepower
            })
        end
    end
    
    return alerts
end

-- Calculate distance between two positions
function FacilityIntegration:calculateDistance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    
    return math.sqrt(dx*dx + dy*dy)
end

-- Integrate facility support into combat
function FacilityIntegration:applyCombatSupport(craft, ufo, baseLocation)
    local modifiers = {
        hitBonus = 0,
        armorBonus = 0,
        speedBonus = 0,
        evasionBonus = 0
    }
    
    -- Radar support improves hit chance
    local radarBonus, radarCoverage = self:getRadarSupport(craft.position)
    modifiers.hitBonus = modifiers.hitBonus + (radarCoverage * 0.2)
    
    -- Command center provides coordination bonus
    local cmdBonus, hasCoordination = self:getCommandCenterBonus()
    if hasCoordination then
        modifiers.hitBonus = modifiers.hitBonus + cmdBonus
        modifiers.evasionBonus = modifiers.evasionBonus + cmdBonus
    end
    
    -- SAM site support
    local samSupport = self:getSAMSiteSupport(ufo.position)
    if #samSupport > 0 then
        modifiers.armorBonus = modifiers.armorBonus + (#samSupport * 0.1)
    end
    
    -- Fighter base support
    local baseSupport = self:getFighterBaseSupport()
    if baseSupport then
        modifiers.speedBonus = modifiers.speedBonus + 0.1
    end
    
    return modifiers
end

-- Generate facility support report
function FacilityIntegration:generateSupportReport(craft, ufo)
    local report = {
        timestamp = os.time(),
        craftStatus = {
            health = craft.health,
            position = craft.position
        },
        targetStatus = {
            detected = true,
            position = ufo.position,
            classification = ufo.class
        },
        facilitySupport = {}
    }
    
    -- Radar coverage
    local radarBonus, coverage = self:getRadarSupport(craft.position)
    report.facilitySupport.radarCoverage = coverage * 100 .. "%"
    
    -- SAM availability
    local samSupport = self:getSAMSiteSupport(ufo.position)
    report.facilitySupport.samSites = #samSupport
    
    -- Command support
    local cmdBonus, hasCmd = self:getCommandCenterBonus()
    report.facilitySupport.commandCoordination = hasCmd
    
    -- Fighter base
    local baseSupport = self:getFighterBaseSupport()
    report.facilitySupport.baseRepairAvailable = baseSupport ~= nil
    
    return report
end

-- Facility takes damage from UFO attack
function FacilityIntegration:damageFromUFO(facilityType, damage)
    for _, facility in ipairs(self.activeFacilities) do
        if facility.type == facilityType then
            facility.health = math.max(0, facility.health - damage)
            if facility.health == 0 then
                facility.operational = false
            end
            break
        end
    end
end

-- Facility repair/rebuild
function FacilityIntegration:repairFacility(facilityType, repairAmount)
    for _, facility in ipairs(self.activeFacilities) do
        if facility.type == facilityType then
            facility.health = math.min(100, facility.health + repairAmount)
            if facility.health > 0 then
                facility.operational = true
            end
            break
        end
    end
end

return FacilityIntegration

