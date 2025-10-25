-- Analytics System - Game Statistics and Telemetry Engine
-- Tracks comprehensive game metrics, player behavior, and performance data

local AnalyticsSystem = {}
AnalyticsSystem.__index = AnalyticsSystem

-- Initialize analytics system
function AnalyticsSystem.new()
    local self = setmetatable({}, AnalyticsSystem)
    
    -- Core session tracking
    self.session = {
        id = self:generateSessionId(),
        startTime = os.time(),
        endTime = nil,
        duration = 0,
        gameVersion = "0.1.0",
        platform = "love2d"
    }
    
    -- Game statistics
    self.gameStats = {
        totalMissions = 0,
        successfulMissions = 0,
        failedMissions = 0,
        casualtiesCount = 0,
        totalKills = 0,
        gameCompletion = 0,
        currentPhase = 0,
        geoscapeHours = 0,
        battlescapeHours = 0,
        mentalHours = 0
    }
    
    -- Economy statistics
    self.economyStats = {
        totalIncome = 0,
        totalExpenses = 0,
        equipmentCost = 0,
        researchCost = 0,
        maintenanceCost = 0,
        currentFunding = 0,
        fundingHistory = {}
    }
    
    -- Combat statistics
    self.combatStats = {
        totalShots = 0,
        shotsHit = 0,
        totalDamageDealt = 0,
        totalDamageReceived = 0,
        grenades = 0,
        grenadesHit = 0,
        melee = 0,
        meleeKills = 0
    }
    
    -- Unit statistics
    self.unitStats = {}
    
    -- Performance metrics
    self.performance = {
        averageFPS = 60,
        minFPS = 60,
        maxFPS = 60,
        frameCount = 0,
        lastFrameTime = os.time(),
        averageFrameTime = 16.67,
        memoryUsage = 0,
        peakMemoryUsage = 0
    }
    
    -- Behavior tracking
    self.behavior = {
        tacticalDecisions = 0,
        aggressiveDecisions = 0,
        defensiveDecisions = 0,
        recklessDecisions = 0,
        loadCount = 0,
        quicksaveCount = 0,
        restartCount = 0
    }
    
    -- Events log
    self.events = {}
    self.maxEvents = 10000
    
    return self
end

-- Generate unique session ID
function AnalyticsSystem:generateSessionId()
    local timestamp = os.time()
    local random = math.random(1000, 9999)
    return "SESSION_" .. timestamp .. "_" .. random
end

-- Record mission completion
function AnalyticsSystem:recordMission(missionData)
    self.gameStats.totalMissions = self.gameStats.totalMissions + 1
    
    if missionData.success then
        self.gameStats.successfulMissions = self.gameStats.successfulMissions + 1
    else
        self.gameStats.failedMissions = self.gameStats.failedMissions + 1
    end
    
    self.gameStats.casualtiesCount = self.gameStats.casualtiesCount + (missionData.casualties or 0)
    self.gameStats.totalKills = self.gameStats.totalKills + (missionData.kills or 0)
    
    self:logEvent({
        type = "MISSION_COMPLETE",
        missionType = missionData.type,
        success = missionData.success,
        difficulty = missionData.difficulty,
        timestamp = os.time()
    })
end

-- Record combat action
function AnalyticsSystem:recordCombatAction(action)
    if action.type == "SHOT" then
        self.combatStats.totalShots = self.combatStats.totalShots + 1
        if action.hit then
            self.combatStats.shotsHit = self.combatStats.shotsHit + 1
            self.combatStats.totalDamageDealt = self.combatStats.totalDamageDealt + (action.damage or 0)
        end
    elseif action.type == "GRENADE" then
        self.combatStats.grenades = self.combatStats.grenades + 1
        if action.hit then
            self.combatStats.grenadesHit = self.combatStats.grenadesHit + 1
        end
    elseif action.type == "MELEE" then
        self.combatStats.melee = self.combatStats.melee + 1
        if action.hit then
            self.combatStats.meleeKills = self.combatStats.meleeKills + 1
        end
    elseif action.type == "DAMAGE" then
        self.combatStats.totalDamageReceived = self.combatStats.totalDamageReceived + (action.damage or 0)
    end
    
    self:logEvent(action)
end

-- Record economic transaction
function AnalyticsSystem:recordTransaction(transaction)
    if transaction.type == "INCOME" then
        self.economyStats.totalIncome = self.economyStats.totalIncome + transaction.amount
    elseif transaction.type == "EXPENSE" then
        self.economyStats.totalExpenses = self.economyStats.totalExpenses + transaction.amount
        
        if transaction.category == "EQUIPMENT" then
            self.economyStats.equipmentCost = self.economyStats.equipmentCost + transaction.amount
        elseif transaction.category == "RESEARCH" then
            self.economyStats.researchCost = self.economyStats.researchCost + transaction.amount
        elseif transaction.category == "MAINTENANCE" then
            self.economyStats.maintenanceCost = self.economyStats.maintenanceCost + transaction.amount
        end
    end
    
    self.economyStats.currentFunding = transaction.newBalance or 0
    table.insert(self.economyStats.fundingHistory, {
        time = os.time(),
        amount = self.economyStats.currentFunding
    })
    
    self:logEvent(transaction)
end

-- Record unit statistics
function AnalyticsSystem:recordUnitAction(unit, action)
    if not self.unitStats[unit.id] then
        self.unitStats[unit.id] = {
            name = unit.name,
            rank = unit.rank,
            missions = 0,
            kills = 0,
            deaths = 0,
            shotsFired = 0,
            accuracy = 0,
            health = unit.health,
            experience = 0
        }
    end
    
    local stats = self.unitStats[unit.id]
    
    if action == "MISSION_COMPLETE" then
        stats.missions = stats.missions + 1
    elseif action == "KILL" then
        stats.kills = stats.kills + 1
    elseif action == "DEATH" then
        stats.deaths = stats.deaths + 1
    elseif action == "SHOT" then
        stats.shotsFired = stats.shotsFired + 1
    end
end

-- Record player decision
function AnalyticsSystem:recordDecision(decisionType, context)
    if decisionType == "TACTICAL" then
        self.behavior.tacticalDecisions = self.behavior.tacticalDecisions + 1
    elseif decisionType == "AGGRESSIVE" then
        self.behavior.aggressiveDecisions = self.behavior.aggressiveDecisions + 1
    elseif decisionType == "DEFENSIVE" then
        self.behavior.defensiveDecisions = self.behavior.defensiveDecisions + 1
    elseif decisionType == "RECKLESS" then
        self.behavior.recklessDecisions = self.behavior.recklessDecisions + 1
    end
    
    self:logEvent({
        type = "DECISION",
        decisionType = decisionType,
        context = context,
        timestamp = os.time()
    })
end

-- Track performance metrics
function AnalyticsSystem:updatePerformanceMetrics(currentFPS, deltaTime)
    self.performance.frameCount = self.performance.frameCount + 1
    
    -- Update FPS metrics
    self.performance.averageFPS = (self.performance.averageFPS * 0.95) + (currentFPS * 0.05)
    self.performance.minFPS = math.min(self.performance.minFPS, currentFPS)
    self.performance.maxFPS = math.max(self.performance.maxFPS, currentFPS)
    
    -- Frame time
    self.performance.averageFrameTime = (self.performance.averageFrameTime * 0.95) + (deltaTime * 1000 * 0.05)
    
    -- Memory usage (approximate)
    local memoryUsage = collectgarbage("count")
    self.performance.memoryUsage = memoryUsage
    self.performance.peakMemoryUsage = math.max(self.performance.peakMemoryUsage, memoryUsage)
end

-- Log event to events history
function AnalyticsSystem:logEvent(event)
    if #self.events >= self.maxEvents then
        table.remove(self.events, 1) -- Remove oldest
    end
    
    event.timestamp = event.timestamp or os.time()
    table.insert(self.events, event)
end

-- Calculate combat statistics
function AnalyticsSystem:getCombatStatistics()
    local stats = {}
    
    stats.totalShots = self.combatStats.totalShots
    stats.accuracy = (self.combatStats.shotsHit / math.max(1, self.combatStats.totalShots)) * 100
    stats.damagePerShot = self.combatStats.totalDamageDealt / math.max(1, self.combatStats.shotsHit)
    
    stats.grenadeAccuracy = (self.combatStats.grenadesHit / math.max(1, self.combatStats.grenades)) * 100
    stats.kdRatio = (self.gameStats.totalKills / math.max(1, self.gameStats.casualtiesCount))
    
    stats.totalDamageDealt = self.combatStats.totalDamageDealt
    stats.totalDamageReceived = self.combatStats.totalDamageReceived
    
    return stats
end

-- Calculate mission statistics
function AnalyticsSystem:getMissionStatistics()
    local stats = {}
    
    stats.totalMissions = self.gameStats.totalMissions
    stats.successRate = (self.gameStats.successfulMissions / math.max(1, self.gameStats.totalMissions)) * 100
    stats.failureRate = (self.gameStats.failedMissions / math.max(1, self.gameStats.totalMissions)) * 100
    stats.casualtyRate = self.gameStats.casualtiesCount / math.max(1, self.gameStats.totalMissions)
    stats.killRate = self.gameStats.totalKills / math.max(1, self.gameStats.totalMissions)
    
    return stats
end

-- Calculate economy statistics
function AnalyticsSystem:getEconomyStatistics()
    local stats = {}
    
    stats.totalIncome = self.economyStats.totalIncome
    stats.totalExpenses = self.economyStats.totalExpenses
    stats.netProfit = stats.totalIncome - stats.totalExpenses
    stats.profitMargin = (stats.netProfit / math.max(1, stats.totalIncome)) * 100
    
    stats.equipmentPercent = (self.economyStats.equipmentCost / math.max(1, stats.totalExpenses)) * 100
    stats.researchPercent = (self.economyStats.researchCost / math.max(1, stats.totalExpenses)) * 100
    stats.maintenancePercent = (self.economyStats.maintenanceCost / math.max(1, stats.totalExpenses)) * 100
    
    stats.currentFunding = self.economyStats.currentFunding
    
    return stats
end

-- Get player behavior analysis
function AnalyticsSystem:getBehaviorAnalysis()
    local totalDecisions = self.behavior.tacticalDecisions + self.behavior.aggressiveDecisions + 
                          self.behavior.defensiveDecisions + self.behavior.recklessDecisions
    
    local analysis = {}
    
    analysis.totalDecisions = totalDecisions
    analysis.tacticalPercent = (self.behavior.tacticalDecisions / math.max(1, totalDecisions)) * 100
    analysis.aggressivePercent = (self.behavior.aggressiveDecisions / math.max(1, totalDecisions)) * 100
    analysis.defensivePercent = (self.behavior.defensiveDecisions / math.max(1, totalDecisions)) * 100
    analysis.recklessPercent = (self.behavior.recklessDecisions / math.max(1, totalDecisions)) * 100
    
    analysis.restarts = self.behavior.restartCount
    analysis.loads = self.behavior.loadCount
    
    return analysis
end

-- Get session summary
function AnalyticsSystem:getSessionSummary()
    self.session.endTime = os.time()
    self.session.duration = self.session.endTime - self.session.startTime
    
    local summary = {
        sessionId = self.session.id,
        duration = self.session.duration,
        totalMissions = self.gameStats.totalMissions,
        successRate = (self.gameStats.successfulMissions / math.max(1, self.gameStats.totalMissions)) * 100,
        totalCasualties = self.gameStats.casualtiesCount,
        totalKills = self.gameStats.totalKills,
        combat = self:getCombatStatistics(),
        economy = self:getEconomyStatistics(),
        behavior = self:getBehaviorAnalysis(),
        performance = {
            avgFPS = string.format("%.1f", self.performance.averageFPS),
            minFPS = self.performance.minFPS,
            maxFPS = self.performance.maxFPS,
            peakMemory = string.format("%.1f", self.performance.peakMemoryUsage) .. " MB"
        }
    }
    
    return summary
end

-- Export session data
function AnalyticsSystem:exportSessionData()
    local sessionData = {
        session = self.session,
        gameStats = self.gameStats,
        economyStats = self.economyStats,
        combatStats = self.combatStats,
        unitStats = self.unitStats,
        behavior = self.behavior,
        performance = self.performance,
        summary = self:getSessionSummary()
    }
    
    return sessionData
end

-- Export to JSON (simplified)
function AnalyticsSystem:exportJSON()
    local data = self:exportSessionData()
    
    -- Simple JSON serialization
    local jsonStr = "{\n"
    jsonStr = jsonStr .. '  "sessionId": "' .. data.session.id .. '",\n'
    jsonStr = jsonStr .. '  "duration": ' .. data.session.duration .. ',\n'
    jsonStr = jsonStr .. '  "totalMissions": ' .. data.gameStats.totalMissions .. ',\n'
    jsonStr = jsonStr .. '  "successRate": ' .. data.summary.successRate .. ',\n'
    jsonStr = jsonStr .. '  "totalKills": ' .. data.gameStats.totalKills .. ',\n'
    jsonStr = jsonStr .. '  "totalCasualties": ' .. data.gameStats.casualtiesCount .. '\n'
    jsonStr = jsonStr .. "}\n"
    
    return jsonStr
end

-- Save analytics to file
function AnalyticsSystem:saveToFile(filename)
    local jsonData = self:exportJSON()
    
    local file = io.open(filename, "w")
    if file then
        file:write(jsonData)
        file:close()
        return true
    end
    
    return false
end

return AnalyticsSystem

