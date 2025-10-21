--- Mission Selection UI Integration
-- Integrates UI with strategic_planner and real mission data
-- Connects: mission_selection_ui.lua → strategic_planner.lua
--
-- @module mission_selection_ui_integration
-- @author AI Development Team
-- @license MIT

local MissionSelectionUIIntegration = {}

--- Load and initialize mission selection UI with real data
-- @param strategic_planner Strategic planner instance
-- @param missions Real mission table from geoscape
-- @return Integrated mission UI instance
function MissionSelectionUIIntegration:new(strategic_planner, missions)
    local instance = {
        strategicPlanner = strategic_planner,
        missions = missions or {},
        selectedMission = 1,
        viewMode = "overview",
        sortBy = "score",
        scroll = 0,
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Calculate mission score using strategic planner
function MissionSelectionUIIntegration:scoreMission(mission)
    if self.strategicPlanner then
        return self.strategicPlanner:calculateMissionScore(mission)
    end
    -- Fallback calculation if strategic planner unavailable
    return self:fallbackScoreMission(mission)
end

--- Fallback score calculation (when strategic planner not available)
function MissionSelectionUIIntegration:fallbackScoreMission(mission)
    local score = 0
    
    -- Reward factor (40%)
    local maxReward = 10000
    local rewardFactor = math.min(mission.reward or 0, maxReward) / maxReward
    score = score + rewardFactor * 40
    
    -- Risk factor (30%) - lower risk = higher score
    local maxRisk = 100
    local riskFactor = 1 - (math.min(mission.risk or 50, maxRisk) / maxRisk)
    score = score + riskFactor * 30
    
    -- Relations factor (20%)
    local relFactor = (mission.relationsImpact or 0) / 50
    score = score + math.min(relFactor * 20, 20)
    
    -- Strategic factor (10%)
    local stratFactor = mission.strategic or 5
    score = score + (stratFactor / 10) * 10
    
    return math.min(math.max(score, 0), 100)
end

--- Get recommendation tier based on score
function MissionSelectionUIIntegration:getRecommendationTier(score)
    if score >= 75 then
        return "CRITICAL", {1, 0, 0}, "Deploy immediately - high value with acceptable risk"
    elseif score >= 60 then
        return "IMPORTANT", {1, 1, 0}, "Consider deploying - good strategic value"
    elseif score >= 40 then
        return "MINOR", {0, 1, 1}, "Lower priority - may improve relations"
    else
        return "TRIVIAL", {0.5, 0.5, 0.5}, "Not recommended - high risk, low reward"
    end
end

--- Score all missions and sort
function MissionSelectionUIIntegration:scoreMissions()
    for i, mission in ipairs(self.missions) do
        mission.score = self:scoreMission(mission)
        local tier, tierColor, recommendation = self:getRecommendationTier(mission.score)
        mission.tier = tier
        mission.tierColor = tierColor
        mission.recommendation = recommendation
    end
    
    self:sortMissions()
end

--- Sort missions by selected criteria
function MissionSelectionUIIntegration:sortMissions()
    local sortBy = self.sortBy or "score"
    
    table.sort(self.missions, function(a, b)
        if sortBy == "score" then
            return a.score > b.score
        elseif sortBy == "reward" then
            return (a.reward or 0) > (b.reward or 0)
        elseif sortBy == "risk" then
            return (a.risk or 0) < (b.risk or 0)
        elseif sortBy == "relations" then
            return (a.relationsImpact or 0) > (b.relationsImpact or 0)
        else
            return a.score > b.score
        end
    end)
end

--- Get mission resource impact
function MissionSelectionUIIntegration:getMissionResourceImpact(mission)
    return {
        estimatedCost = mission.estimatedCost or 500,
        expectedCasualties = mission.expectedCasualties or 1,
        equipmentNeeded = mission.equipmentNeeded or {"standard_rifle", "body_armor"},
        durationDays = mission.durationDays or 3,
        personnelRequired = mission.personnelRequired or 4,
        followUpMissions = mission.followUpMissions or 0,
    }
end

--- Get mission difficulty assessment
function MissionSelectionUIIntegration:getMissionDifficulty(mission)
    local enemyCount = mission.enemyCount or 5
    local enemyTypes = mission.enemyTypes or {"Sectoid", "Thin Man"}
    local mapTerrain = mission.mapTerrain or "URBAN"
    
    if enemyCount >= 8 or mission.risk >= 80 then
        return "INSANE"
    elseif enemyCount >= 6 or mission.risk >= 60 then
        return "CLASSIC"
    elseif enemyCount >= 4 or mission.risk >= 40 then
        return "NORMAL"
    else
        return "EASY"
    end
end

--- Get mission strategic importance
function MissionSelectionUIIntegration:getMissionStrategicImportance(mission)
    local importance = {
        preventsAlienActivity = mission.preventsAlienActivity or false,
        recoversAlienTechnology = mission.recoversAlienTechnology or false,
        bolstersCountrySupport = mission.bolstersCountrySupport or false,
        improvesCommunications = mission.improvesCommunications or false,
        gainsMilitarySupplies = mission.gainsMilitarySupplies or false,
        unlocksTech = mission.unlocksTech or false,
    }
    
    local count = 0
    for k, v in pairs(importance) do
        if v then count = count + 1 end
    end
    
    return importance, count
end

--- Draw mission list view with real data
function MissionSelectionUIIntegration:drawListView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Mission Selection", 20, 20)
    
    -- Sort buttons
    local sortX = 20
    local sortY = 55
    local sortOptions = {"SCORE", "REWARD", "RISK", "RELATIONS"}
    
    for i, option in ipairs(sortOptions) do
        local buttonX = sortX + (i - 1) * 110
        local selected = (self.sortBy == option:lower())
        
        if selected then
            love.graphics.setColor(0, 1, 0, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", buttonX, sortY, 100, 25)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", buttonX, sortY, 100, 25)
        
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(option, buttonX, sortY + 5, 100, "center")
    end
    
    -- Mission list header
    local headerY = 100
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("MISSION", 30, headerY)
    love.graphics.print("SCORE", 150, headerY)
    love.graphics.print("REWARD", 220, headerY)
    love.graphics.print("RISK", 300, headerY)
    love.graphics.print("DURATION", 360, headerY)
    love.graphics.print("DIFFICULTY", 450, headerY)
    
    -- Mission rows
    local rowY = headerY + 30
    local missionCount = 0
    
    for i, mission in ipairs(self.missions) do
        if missionCount >= 10 then break end
        
        if self.selectedMission == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", 20, rowY - 2, 920, 50)
        end
        
        -- Tier indicator
        love.graphics.setColor(mission.tierColor[1], mission.tierColor[2], mission.tierColor[3])
        love.graphics.rectangle("fill", 22, rowY, 4, 48)
        
        -- Mission name
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(mission.name or "Unknown Mission", 30, rowY)
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(mission.location or "Unknown", 30, rowY + 16)
        
        -- Score
        love.graphics.setColor(mission.tierColor[1], mission.tierColor[2], mission.tierColor[3])
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(string.format("%.0f", mission.score), 150, rowY + 8, 50, "center")
        
        -- Reward
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf("$" .. (mission.reward or 0), 220, rowY + 8, 70, "center")
        
        -- Risk
        local riskColor = mission.risk > 70 and {1, 0, 0} or (mission.risk > 40 and {1, 1, 0} or {0, 1, 0})
        love.graphics.setColor(riskColor[1], riskColor[2], riskColor[3])
        love.graphics.printf(math.floor(mission.risk or 50) .. "%", 300, rowY + 8, 50, "center")
        
        -- Duration
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf((mission.durationDays or 3) .. "d", 360, rowY + 8, 70, "center")
        
        -- Difficulty
        local diffColor = mission.difficulty == "INSANE" and {1, 0, 0} or (mission.difficulty == "CLASSIC" and {1, 0.5, 0} or (mission.difficulty == "NORMAL" and {1, 1, 0} or {0, 1, 0}))
        love.graphics.setColor(diffColor[1], diffColor[2], diffColor[3])
        love.graphics.printf(mission.difficulty or "NORMAL", 450, rowY + 8, 100, "center")
        
        rowY = rowY + 55
        missionCount = missionCount + 1
    end
end

--- Draw mission details view with full analysis
function MissionSelectionUIIntegration:drawDetailsView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Mission Details", 20, 20)
    
    if self.selectedMission > #self.missions then
        return
    end
    
    local mission = self.missions[self.selectedMission]
    
    -- Left panel: Mission info
    local infoX = 20
    local infoY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", infoX, infoY, 450, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", infoX, infoY, 450, 600)
    
    love.graphics.setColor(mission.tierColor[1], mission.tierColor[2], mission.tierColor[3])
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print(mission.name or "Mission", infoX + 10, infoY + 10)
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    local detailY = infoY + 45
    
    local details = {
        {"Location:", mission.location or "Unknown"},
        {"Mission Type:", mission.missionType or "Combat"},
        {"Difficulty:", mission.difficulty or "NORMAL"},
        {"Duration:", (mission.durationDays or 3) .. " days"},
        {"", ""},
        {"Reward:", "$" .. (mission.reward or 0)},
        {"Risk Level:", math.floor(mission.risk or 50) .. "%"},
        {"Expected Casualties:", mission.expectedCasualties or 1},
        {"Estimated Cost:", "$" .. (mission.estimatedCost or 500)},
        {"Relations Impact:", (mission.relationsImpact or 0) > 0 and "+" or "" .. (mission.relationsImpact or 0)},
        {"", ""},
        {"Enemy Count:", mission.enemyCount or 5},
    }
    
    for i, detail in ipairs(details) do
        if detail[1] == "" then
            detailY = detailY + 10
        else
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(detail[1], infoX + 10, detailY)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tostring(detail[2]), infoX + 200, detailY)
            
            detailY = detailY + 20
        end
    end
    
    -- Right panel: Score breakdown and recommendations
    local scoreX = 490
    local scoreY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", scoreX, scoreY, 450, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", scoreX, scoreY, 450, 600)
    
    love.graphics.setColor(mission.tierColor[1], mission.tierColor[2], mission.tierColor[3])
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Score Analysis", scoreX + 10, scoreY + 10)
    
    -- Score display
    love.graphics.setColor(mission.tierColor[1], mission.tierColor[2], mission.tierColor[3])
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf(string.format("%.0f", mission.score), scoreX + 10, scoreY + 50, 400, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(mission.tier or "UNKNOWN", scoreX + 10, scoreY + 110, 400, "center")
    
    -- Score breakdown bars
    local barX = scoreX + 10
    local barY = scoreY + 160
    
    local components = {
        {label = "Reward", value = mission.scoreReward or 30, max = 40},
        {label = "Risk", value = mission.scoreRisk or 22, max = 30},
        {label = "Relations", value = mission.scoreRelations or 15, max = 20},
        {label = "Strategic", value = mission.scoreStrategic or 8, max = 10},
    }
    
    for i, comp in ipairs(components) do
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(comp.label .. ":", barX, barY)
        
        -- Bar
        love.graphics.setColor(0.2, 0.2, 0.3)
        local barWidth = 300
        love.graphics.rectangle("fill", barX, barY + 15, barWidth, 15)
        
        love.graphics.setColor(0, 1, 0)
        local fillWidth = (comp.value / comp.max) * barWidth
        love.graphics.rectangle("fill", barX, barY + 15, fillWidth, 15)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(comp.value .. "/" .. comp.max, barX, barY + 16, barWidth, "center")
        
        barY = barY + 45
    end
    
    -- Recommendation
    barY = barY + 20
    love.graphics.setColor(mission.tierColor[1], mission.tierColor[2], mission.tierColor[3])
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("Recommendation:", barX, barY)
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.printf(mission.recommendation or "Unknown", barX, barY + 20, 420, "left")
end

--- Handle input
function MissionSelectionUIIntegration:handleInput(key)
    if key == "up" then
        self.selectedMission = math.max(1, self.selectedMission - 1)
    elseif key == "down" then
        self.selectedMission = math.min(#self.missions, self.selectedMission + 1)
    elseif key == "s" then
        self.sortBy = "score"
        self:sortMissions()
    elseif key == "r" then
        self.sortBy = "reward"
        self:sortMissions()
    elseif key == "k" then
        self.sortBy = "risk"
        self:sortMissions()
    elseif key == "e" then
        self.sortBy = "relations"
        self:sortMissions()
    elseif key == "tab" then
        self.viewMode = self.viewMode == "list" and "details" or "list"
    end
end

--- Draw main interface
function MissionSelectionUIIntegration:draw()
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    if self.viewMode == "details" then
        self:drawDetailsView()
    else
        self:drawListView()
    end
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[TAB]Toggle View  [↑↓]Select  [S/R/K/E]Sort  [ESC]Close", 10, 705)
end

return MissionSelectionUIIntegration



