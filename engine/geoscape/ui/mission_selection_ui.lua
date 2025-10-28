--- Mission Selection UI
-- Geoscape mission selection screen with AI mission scoring
-- Shows: mission list with scores, recommendations, resource impact, planning timeline
-- Integrates with: strategic_planner.lua, squad_coordination.lua, resource_awareness.lua
--
-- @module mission_selection_ui
-- @author AI Development Team
-- @license MIT

local MissionSelectionUI = {}

--- Create new mission selection UI instance
-- @param gameState Global game state with strategic planner
-- @param base Base entity with resources
-- @return Mission selection UI instance
function MissionSelectionUI:new(gameState, base)
    local instance = {
        gameState = gameState,
        base = base,
        missions = {}, -- Array of missions with scores
        selectedMission = nil, -- Currently selected mission
        viewMode = "list", -- list, details, timeline
        sortBy = "score", -- score, reward, risk, relations
        scroll = 0,
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Initialize with mission data and calculate scores
function MissionSelectionUI:initialize(missionList)
    self.missions = {}
    
    for i, mission in ipairs(missionList) do
        -- Calculate score using strategic planner logic
        local score, breakdown = self:calculateMissionScore(mission)
        
        table.insert(self.missions, {
            id = mission.id or i,
            name = mission.name or ("Mission " .. i),
            location = mission.location or "Unknown",
            type = mission.type or "Combat",
            score = score,
            breakdown = breakdown,
            reward = mission.reward or 1000,
            risk = mission.risk or 50,
            relations = mission.relations or 0,
            strategic = mission.strategic or 0,
            estimatedCost = mission.estimatedCost or 5000,
            casualties = mission.casualties or 0,
            duration = mission.duration or 3,
            difficulty = mission.difficulty or "Medium",
        })
    end
    
    -- Sort by score descending
    table.sort(self.missions, function(a, b) return a.score > b.score end)
end

--- Calculate mission score (0-100)
-- 4 factors: Reward (40%), Risk (30%), Relations (20%), Strategic (10%)
function MissionSelectionUI:calculateMissionScore(mission)
    local rewardScore = (mission.reward / 2000) * 40 -- Normalize to 0-40
    local riskScore = math.max(0, 30 - (mission.risk / 5)) -- 30 points minus risk penalty
    local relationsScore = (math.max(mission.relations, 0) / 100) * 20 -- 0-20
    local strategicScore = (mission.strategic / 10) * 10 -- 0-10
    
    local totalScore = math.min(100, rewardScore + riskScore + relationsScore + strategicScore)
    
    return totalScore, {
        reward = rewardScore,
        risk = riskScore,
        relations = relationsScore,
        strategic = strategicScore,
    }
end

--- Get recommendation tier for mission score
function MissionSelectionUI:getRecommendationTier(score)
    if score >= 75 then
        return "CRITICAL", {1, 0, 0} -- Red
    elseif score >= 60 then
        return "IMPORTANT", {1, 1, 0} -- Yellow
    elseif score >= 40 then
        return "MINOR", {0, 1, 1} -- Cyan
    else
        return "TRIVIAL", {0.5, 0.5, 0.5} -- Gray
    end
end

--- Draw mission list view
function MissionSelectionUI:drawListView()
    local panelWidth = 960
    local panelHeight = 720
    
    -- Title and sorting options
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Mission Selection", 20, 20)
    
    -- Sort buttons
    self:drawSortButtons(20, 60, 920, 30)
    
    -- Mission list
    self:drawMissionList(20, 100, 920, 580)
    
    -- Footer
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("[↑↓]Select  [ENTER]Details  [D]Deploy  [R]Recommend", 20, 690)
end

--- Draw sort option buttons
function MissionSelectionUI:drawSortButtons(x, y, width, height)
    local sortOptions = {"Score", "Reward", "Risk", "Relations"}
    local buttonWidth = 100
    
    for i, option in ipairs(sortOptions) do
        local bx = x + (i - 1) * (buttonWidth + 10)
        
        if self.sortBy == option:lower() then
            love.graphics.setColor(0, 1, 0, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", bx, y, buttonWidth, height)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", bx, y, buttonWidth, height)
        
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.printf(option, bx + 5, y + 6, buttonWidth - 10, "center")
    end
end

--- Draw list of missions with scores
function MissionSelectionUI:drawMissionList(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Header row
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Mission", x + 15, y + 10)
    love.graphics.print("Score", x + 350, y + 10)
    love.graphics.print("Reward", x + 450, y + 10)
    love.graphics.print("Risk", x + 550, y + 10)
    love.graphics.print("Duration", x + 650, y + 10)
    love.graphics.print("Difficulty", x + 780, y + 10)
    
    -- Separator line
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.line(x + 10, y + 30, x + width - 10, y + 30)
    
    -- Mission rows
    local missionY = y + 40
    local rowHeight = 50
    local maxRows = math.floor((height - 50) / rowHeight)
    
    for i, mission in ipairs(self.missions) do
        if i > maxRows then break end
        
        -- Highlight selected mission
        if self.selectedMission == mission.id then
            love.graphics.setColor(0, 1, 0, 0.2)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
        end
        love.graphics.rectangle("fill", x + 5, missionY - 2, width - 10, rowHeight)
        
        -- Border
        love.graphics.setColor(0.3, 0.3, 0.4)
        love.graphics.rectangle("line", x + 5, missionY - 2, width - 10, rowHeight)
        
        -- Recommendation tier indicator
        local tier, tierColor = self:getRecommendationTier(mission.score)
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("fill", x + 10, missionY, 8, 40)
        
        -- Mission info
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print(mission.name, x + 25, missionY + 2)
        
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print(mission.location .. " (" .. mission.type .. ")", x + 25, missionY + 18)
        
        -- Score
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.printf(string.format("%.0f", mission.score), x + 350, missionY + 10, 80, "center")
        
        -- Reward
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.printf("$" .. mission.reward, x + 450, missionY + 15, 80, "center")
        
        -- Risk
        local riskColor = mission.risk < 30 and {0, 1, 0} or (mission.risk < 70 and {1, 1, 0} or {1, 0, 0})
        love.graphics.setColor(riskColor[1], riskColor[2], riskColor[3])
        love.graphics.printf(mission.risk .. "%", x + 550, missionY + 15, 80, "center")
        
        -- Duration
        love.graphics.setColor(0, 1, 1)
        love.graphics.printf(mission.duration .. " days", x + 650, missionY + 15, 100, "center")
        
        -- Difficulty
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(mission.difficulty, x + 780, missionY + 15, 100, "center")
        
        missionY = missionY + rowHeight
    end
end

--- Draw mission details view
function MissionSelectionUI:drawDetailsView()
    if not self.selectedMission then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print("Select a mission to view details", 300, 350)
        return
    end
    
    -- Find selected mission
    local mission = nil
    for i, m in ipairs(self.missions) do
        if m.id == self.selectedMission then
            mission = m
            break
        end
    end
    
    if not mission then return end
    
    local panelWidth = 960
    local panelHeight = 720
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print(mission.name, 20, 20)
    
    -- Left panel: Mission info
    self:drawMissionDetails(mission, 20, 70, 450, 600)
    
    -- Right panel: Score breakdown and analysis
    self:drawScoreBreakdown(mission, 490, 70, 450, 600)
end

--- Draw mission details panel
function MissionSelectionUI:drawMissionDetails(mission, x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Mission Information", x + 15, y + 15)
    
    local infoY = y + 50
    love.graphics.setFont(love.graphics.newFont(12))
    
    -- Basic info
    local info = {
        {"Location:", mission.location},
        {"Type:", mission.type},
        {"Difficulty:", mission.difficulty},
        {"Duration:", mission.duration .. " days"},
        {"", ""},
        {"Tactical Info:", ""},
        {"Reward:", "$" .. mission.reward},
        {"Risk Level:", mission.risk .. "%"},
        {"Expected Casualties:", mission.casualties},
        {"Estimated Cost:", "$" .. mission.estimatedCost},
        {"", ""},
        {"Relations Impact:", mission.relations > 0 and "+" .. mission.relations or mission.relations},
    }
    
    for i, pair in ipairs(info) do
        if pair[1] == "" then
            infoY = infoY + 10
        else
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(pair[1], x + 20, infoY)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(pair[2], x + 200, infoY)
            
            infoY = infoY + 25
        end
    end
end

--- Draw mission score breakdown
function MissionSelectionUI:drawScoreBreakdown(mission, x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Score Breakdown", x + 15, y + 15)
    
    -- Overall score (big display)
    local tier, tierColor = self:getRecommendationTier(mission.score)
    love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf(string.format("%.0f", mission.score), x + 20, y + 50, width - 40, "center")
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(tier, x + 20, y + 110, width - 40, "center")
    
    -- Component breakdown (horizontal bars)
    local breakdownY = y + 160
    local components = {
        {label = "Reward Value", value = mission.breakdown.reward, maxValue = 40, color = {0, 1, 0}},
        {label = "Risk Assessment", value = mission.breakdown.risk, maxValue = 30, color = {1, 0.5, 0}},
        {label = "Relations Impact", value = mission.breakdown.relations, maxValue = 20, color = {0, 1, 1}},
        {label = "Strategic Value", value = mission.breakdown.strategic, maxValue = 10, color = {1, 0, 1}},
    }
    
    for i, component in ipairs(components) do
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print(component.label, x + 20, breakdownY)
        
        -- Background bar
        love.graphics.setColor(0.25, 0.25, 0.35)
        love.graphics.rectangle("fill", x + 200, breakdownY, 200, 20)
        
        -- Value bar
        love.graphics.setColor(component.color[1], component.color[2], component.color[3])
        local barWidth = (component.value / component.maxValue) * 200
        love.graphics.rectangle("fill", x + 200, breakdownY, barWidth, 20)
        
        -- Value text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(string.format("%.0f / %.0f", component.value, component.maxValue), x + 410, breakdownY + 2, 30, "left")
        
        breakdownY = breakdownY + 35
    end
    
    -- Recommendation text
    breakdownY = breakdownY + 20
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.printf("Recommendation:", x + 20, breakdownY, width - 40, "left")
    
    local recommendation = tier == "CRITICAL" and "Deploy immediately - excellent opportunity" or
                          tier == "IMPORTANT" and "Good option - consider deploying" or
                          tier == "MINOR" and "Available - lower priority" or
                          "Low value - recommend decline"
    
    love.graphics.setFont(love.graphics.newFont(10))
    breakdownY = breakdownY + 25
    love.graphics.printf(recommendation, x + 20, breakdownY, width - 40, "left")
end

--- Draw timeline view (3-6 month strategy)
function MissionSelectionUI:drawTimelineView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("3-Month Strategy Timeline", 20, 20)
    
    -- Draw 3 months of mission recommendations
    local months = {
        {month = "October", missions = 5, totalReward = 8000, trend = "↑"},
        {month = "November", missions = 7, totalReward = 12000, trend = "↑"},
        {month = "December", missions = 6, totalReward = 10000, trend = "→"},
    }
    
    local monthX = 30
    for i, monthData in ipairs(months) do
        self:drawMonthBlock(monthData, monthX, 80, 280, 580)
        monthX = monthX + 300
    end
end

--- Draw a single month block in timeline
function MissionSelectionUI:drawMonthBlock(monthData, x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Month header
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print(monthData.month, x + 15, y + 15)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(monthData.trend == "↑" and {0, 1, 0} or {1, 1, 0})
    love.graphics.print(monthData.trend, x + width - 25, y + 15)
    
    -- Statistics
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(11))
    local statsY = y + 60
    love.graphics.print("Missions: " .. monthData.missions, x + 15, statsY)
    
    love.graphics.setColor(0, 1, 0)
    statsY = statsY + 30
    love.graphics.print("Total Reward:", x + 15, statsY)
    love.graphics.print("$" .. monthData.totalReward, x + 15, statsY + 20)
    
    -- Recommended actions
    love.graphics.setColor(0.7, 0.7, 0.8)
    statsY = statsY + 70
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Priority Actions:", x + 15, statsY)
    
    local actions = {
        "• Build Research Lab",
        "• Train 2 Soldiers",
        "• Repair Craft",
        "• Stock Ammunition",
    }
    
    for i, action in ipairs(actions) do
        love.graphics.print(action, x + 15, statsY + 20 + (i - 1) * 20)
    end
end

--- Handle keyboard input
function MissionSelectionUI:handleInput(key)
    if key == "tab" then
        if self.viewMode == "list" then
            self.viewMode = "details"
        elseif self.viewMode == "details" then
            self.viewMode = "timeline"
        else
            self.viewMode = "list"
        end
    elseif key == "up" then
        if self.selectedMission and self.selectedMission > 1 then
            self.selectedMission = self.selectedMission - 1
        elseif not self.selectedMission and #self.missions > 0 then
            self.selectedMission = self.missions[1].id
        end
    elseif key == "down" then
        if self.selectedMission and self.selectedMission < #self.missions then
            self.selectedMission = self.selectedMission + 1
        elseif not self.selectedMission and #self.missions > 0 then
            self.selectedMission = self.missions[1].id
        end
    elseif key == "1" or key == "s" then
        self.sortBy = "score"
    elseif key == "2" or key == "r" then
        self.sortBy = "reward"
    elseif key == "3" or key == "k" then
        self.sortBy = "risk"
    elseif key == "4" or key == "e" then
        self.sortBy = "relations"
    end
end

--- Main draw function
function MissionSelectionUI:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    if self.viewMode == "list" then
        self:drawListView()
    elseif self.viewMode == "details" then
        self:drawDetailsView()
    elseif self.viewMode == "timeline" then
        self:drawTimelineView()
    end
    
    -- Help text
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[TAB]Switch View  [ESC]Close", 20, 705)
end

return MissionSelectionUI




