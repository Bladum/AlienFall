---Prison Disposal System - Prisoner Management and Disposal
---
---Manages captured alien prisoners, their storage, lifetime mechanics, and disposal
---options. Each prisoner provides unique strategic opportunities: interrogation for
---research bonus, experimentation for unethical research, exchange for diplomacy,
---or execution for quick resource recovery.
---
---Prisoner Lifecycle:
---  1. Capture: Unit captured during battlescape combat
---  2. Storage: Prisoner held in prison facility (max 30-60 days)
---  3. Interrogation: Provides research boost (+30 man-days)
---  4. Disposal: Execute, Experiment, Release, or Exchange
---
---Disposal Options:
---  - Execute: Quick disposal, -5 karma, -2000 credits (body disposal cost)
---  - Experiment: Unethical testing, -3 karma, +50 man-days research
---  - Release: Return to wild, +5 karma, risk of intelligence leak
---  - Exchange: Trade for diplomatic favor, +1 relations, +5 karma
---
---Key Exports:
---  - PrisonerSystem.new(): Create prisoner management instance
---  - storePrisoner(prisoner): Add prisoner to facility
---  - getPrisoners(base): Get all prisoners in base
---  - getPrisonerStatus(prisoner): Get lifetime and disposal options
---  - disposePrisoner(prisoner, method, callback): Execute disposal
---
---Dependencies:
---  - politics.karma.karma_system: Karma impact tracking
---  - economy.economy_system: Credit transactions
---  - geoscape.research.research_system: Research bonuses
---  - politics.relations.relations_system: Diplomatic favor
---
---@module basescape.systems.prisoner_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local PrisonerSystem = require("basescape.systems.prisoner_system")
---  local prisoners = PrisonerSystem.new()
---  prisoners:storePrisoner(capturedAlien, base)
---  local status = prisoners:getPrisonerStatus(capturedAlien)
---  print("Days remaining: " .. status.daysRemaining)
---

local PrisonerSystem = {}
PrisonerSystem.__index = PrisonerSystem

--- Prisoner disposal methods and their effects
local DISPOSAL_METHODS = {
    execute = {
        name = "Execute",
        description = "Quick execution. Recovers some resources.",
        karmaImpact = -5,
        costRefund = 2000,
        researchBonus = 0,
        relationImpact = 0,
        requirement = "none"
    },
    experiment = {
        name = "Experimental Research",
        description = "Unethical experiments. Provides research breakthrough.",
        karmaImpact = -3,
        costRefund = 0,
        researchBonus = 50,  -- man-days
        relationImpact = 0,
        requirement = "ethics_research"
    },
    release = {
        name = "Release into Wild",
        description = "Return prisoner to freedom. Risk of intelligence leak.",
        karmaImpact = 5,
        costRefund = 0,
        researchBonus = 0,
        relationImpact = 0,
        requirement = "none"
    },
    exchange = {
        name = "Diplomatic Exchange",
        description = "Trade for diplomatic favor with sponsor nation.",
        karmaImpact = 5,
        costRefund = 0,
        researchBonus = 0,
        relationImpact = 3,  -- relations with sponsor
        requirement = "sponsor"
    }
}

--- Prisoner lifetime range (days)
local PRISONER_LIFETIME = {
    min = 30,
    max = 60
}

--- Initialize prison system
-- @return table Prison system instance
function PrisonerSystem.new()
    local self = setmetatable({}, PrisonerSystem)
    self.prisoners = {}  -- All active prisoners
    self.disposed = {}   -- History of disposed prisoners
    return self
end

--- Store a captured prisoner in facility
-- @param prisoner table Prisoner data {race, name, rank, stats}
-- @param base table Base data for facility capacity check
-- @return boolean Success
-- @return string Error message if false
function PrisonerSystem:storePrisoner(prisoner, base)
    -- Validate input
    if not prisoner then
        return false, "Invalid prisoner data"
    end
    if not base then
        return false, "Invalid base"
    end
    
    -- Check prison facility exists
    local hasPrison = false
    local currentCapacity = 0
    local maxCapacity = 0
    
    for _, facility in ipairs(base.facilities or {}) do
        if facility.type == "prison" then
            hasPrison = true
            maxCapacity = facility.capacities and facility.capacities.prisoners or 10
            currentCapacity = #(facility.prisoners or {})
        end
    end
    
    if not hasPrison then
        return false, "No prison facility in base"
    end
    
    if currentCapacity >= maxCapacity then
        return false, "Prison at maximum capacity (" .. maxCapacity .. ")"
    end
    
    -- Create prisoner record
    local prisonerRecord = {
        id = "prisoner_" .. os.time() .. "_" .. math.random(10000),
        race = prisoner.race,
        name = prisoner.name or ("Alien " .. prisoner.race),
        rank = prisoner.rank or "Soldier",
        stats = prisoner.stats or {},
        
        -- Lifetime tracking
        daysCaptured = 1,
        lifetime = math.random(PRISONER_LIFETIME.min, PRISONER_LIFETIME.max),
        
        -- Status
        status = "interrogation",  -- interrogation, ready_disposal, disposed
        
        -- Interrogation bonus
        interrogationDone = false,
        interrogationBonus = 30,  -- man-days of research
        
        -- Storage location
        baseId = base.id,
        facilityId = nil,  -- Will be set by facility
        
        -- Disposal history
        disposedMethod = nil,
        disposedDate = nil
    }
    
    self.prisoners[prisonerRecord.id] = prisonerRecord
    
    -- Add to facility
    for _, facility in ipairs(base.facilities or {}) do
        if facility.type == "prison" then
            if not facility.prisoners then
                facility.prisoners = {}
            end
            table.insert(facility.prisoners, prisonerRecord.id)
            prisonerRecord.facilityId = facility.id
            break
        end
    end
    
    print("[PrisonerSystem] Prisoner stored: " .. prisonerRecord.name .. " (" .. prisonerRecord.race .. ")")
    return true, "Prisoner stored successfully"
end

--- Get all prisoners in base
-- @param base table Base data
-- @return table Array of prisoner records
function PrisonerSystem:getPrisoners(base)
    local result = {}
    
    for _, facility in ipairs(base.facilities or {}) do
        if facility.type == "prison" then
            for _, prisonerId in ipairs(facility.prisoners or {}) do
                if self.prisoners[prisonerId] then
                    table.insert(result, self.prisoners[prisonerId])
                end
            end
        end
    end
    
    return result
end

--- Get prisoner status and options
-- @param prisoner table Prisoner record
-- @return table Status {daysRemaining, lifetime, availableMethods, interrogationBonus}
function PrisonerSystem:getPrisonerStatus(prisoner)
    if not prisoner then
        return nil
    end
    
    local daysRemaining = prisoner.lifetime - prisoner.daysCaptured
    
    -- Determine available disposal methods
    local availableMethods = {}
    for method, details in pairs(DISPOSAL_METHODS) do
        if details.requirement == "none" then
            table.insert(availableMethods, method)
        elseif details.requirement == "ethics_research" then
            -- Check if ethics research is completed (simplified)
            table.insert(availableMethods, method)
        elseif details.requirement == "sponsor" then
            -- Check if player has sponsor (simplified)
            table.insert(availableMethods, method)
        end
    end
    
    return {
        id = prisoner.id,
        name = prisoner.name,
        race = prisoner.race,
        rank = prisoner.rank,
        daysCaptured = prisoner.daysCaptured,
        daysRemaining = daysRemaining,
        lifetime = prisoner.lifetime,
        status = prisoner.status,
        interrogationDone = prisoner.interrogationDone,
        interrogationBonus = prisoner.interrogationBonus,
        availableMethods = availableMethods,
        isExpired = daysRemaining <= 0
    }
end

--- Perform interrogation to gain research bonus
-- @param prisoner table Prisoner record
-- @param researchSystem table Research system instance
-- @return boolean Success
-- @return number Bonus man-days or error message
function PrisonerSystem:interrogate(prisoner, researchSystem)
    if not prisoner then
        return false, "Invalid prisoner"
    end
    
    if prisoner.interrogationDone then
        return false, "Already interrogated"
    end
    
    if not researchSystem then
        return false, "Invalid research system"
    end
    
    prisoner.interrogationDone = true
    
    -- Add research bonus
    local bonus = prisoner.interrogationBonus
    if researchSystem.addBonus then
        researchSystem:addBonus("alien_interrogation", bonus)
    end
    
    print("[PrisonerSystem] Interrogation complete: +" .. bonus .. " man-days")
    return true, bonus
end

--- Dispose of prisoner
-- @param prisoner table Prisoner record
-- @param method string Disposal method (execute, experiment, release, exchange)
-- @param gameState table Game state {karma, economy, relations}
-- @param callback function Async callback(success, result)
-- @return boolean Success
-- @return string Error message if false
function PrisonerSystem:disposePrisoner(prisoner, method, gameState, callback)
    if not prisoner then
        return false, "Invalid prisoner"
    end
    
    if not DISPOSAL_METHODS[method] then
        return false, "Unknown disposal method: " .. method
    end
    
    if prisoner.status == "disposed" then
        return false, "Prisoner already disposed"
    end
    
    local methodData = DISPOSAL_METHODS[method]
    
    -- Apply effects
    if gameState then
        -- Karma impact
        if gameState.karma and gameState.karma.modifyKarma then
            gameState.karma:modifyKarma(methodData.karmaImpact, 
                "Prisoner " .. method .. ": " .. prisoner.name)
        end
        
        -- Economy impact
        if methodData.costRefund > 0 and gameState.economy then
            if gameState.economy.addCredits then
                gameState.economy:addCredits(methodData.costRefund)
            end
        end
        
        -- Research bonus
        if methodData.researchBonus > 0 and gameState.research then
            if gameState.research.addBonus then
                gameState.research:addBonus("prisoner_research", methodData.researchBonus)
            end
        end
        
        -- Relations bonus (exchange)
        if methodData.relationImpact > 0 and gameState.relations then
            if gameState.relations.modifyRelations then
                gameState.relations:modifyRelations("sponsor", methodData.relationImpact)
            end
        end
    end
    
    -- Mark as disposed
    prisoner.status = "disposed"
    prisoner.disposedMethod = method
    prisoner.disposedDate = os.time()
    
    -- Record in disposal history
    table.insert(self.disposed, prisoner)
    
    print("[PrisonerSystem] Prisoner disposed via " .. method .. ": " .. prisoner.name)
    
    -- Callback
    if callback then
        callback(true, {
            method = method,
            prisoner = prisoner.name,
            karmaImpact = methodData.karmaImpact,
            creditsRefund = methodData.costRefund,
            researchBonus = methodData.researchBonus,
            relationImpact = methodData.relationImpact
        })
    end
    
    return true, "Prisoner disposed successfully"
end

--- Age all prisoners by one day
-- @param base table Base with prisoners
-- @return table Array of expired prisoners
function PrisonerSystem:updatePrisonerAges(base)
    local expired = {}
    
    for _, prisoner in pairs(self.prisoners) do
        if prisoner.status ~= "disposed" then
            prisoner.daysCaptured = prisoner.daysCaptured + 1
            
            -- Check if lifetime exceeded
            if prisoner.daysCaptured > prisoner.lifetime then
                prisoner.status = "expired"
                table.insert(expired, prisoner)
                print("[PrisonerSystem] Prisoner lifetime exceeded: " .. prisoner.name)
            end
        end
    end
    
    return expired
end

--- Get disposal method details
-- @param method string Method name
-- @return table Method details or nil
function PrisonerSystem:getMethodDetails(method)
    return DISPOSAL_METHODS[method]
end

--- Get all disposal methods
-- @return table All disposal methods
function PrisonerSystem:getAllMethods()
    return DISPOSAL_METHODS
end

--- Get disposal history
-- @param limit number Maximum results (optional)
-- @return table Array of disposed prisoners
function PrisonerSystem:getDisposalHistory(limit)
    limit = limit or 10
    local result = {}
    
    for i = #self.disposed, math.max(1, #self.disposed - limit + 1), -1 do
        table.insert(result, self.disposed[i])
    end
    
    return result
end

--- Summary statistics
-- @return table Stats {totalCaptured, totalDisposed, byMethod, karmaFromDisposals}
function PrisonerSystem:getStats()
    local totalCaptured = 0
    local totalDisposed = 0
    local byMethod = {}
    local karmaFromDisposals = 0
    
    -- Count active prisoners
    for _, prisoner in pairs(self.prisoners) do
        totalCaptured = totalCaptured + 1
    end
    
    -- Count disposed
    for _, prisoner in ipairs(self.disposed) do
        totalDisposed = totalDisposed + 1
        
        local method = prisoner.disposedMethod
        byMethod[method] = (byMethod[method] or 0) + 1
        
        if DISPOSAL_METHODS[method] then
            karmaFromDisposals = karmaFromDisposals + DISPOSAL_METHODS[method].karmaImpact
        end
    end
    
    return {
        totalCaptured = totalCaptured,
        totalDisposed = totalDisposed,
        byMethod = byMethod,
        karmaFromDisposals = karmaFromDisposals
    }
end

return PrisonerSystem




