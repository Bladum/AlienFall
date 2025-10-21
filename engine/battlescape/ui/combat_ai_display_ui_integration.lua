--- Combat AI Display UI Integration
-- Integrates threat display with threat assessment and real combat data
-- Connects: combat_ai_display_ui.lua → threat_assessment.lua
--
-- @module combat_ai_display_ui_integration
-- @author AI Development Team
-- @license MIT

local CombatAIDisplayUIIntegration = {}

--- Initialize combat AI display with real data
-- @param threatAssessor Threat assessor instance
-- @param squad Squad entity
-- @param enemies Enemies on battlefield
-- @return Integrated combat AI display instance
function CombatAIDisplayUIIntegration:new(threatAssessor, squad, enemies)
    local instance = {
        threatAssessor = threatAssessor,
        squad = squad,
        enemies = enemies or {},
        selectedTarget = 1,
        viewMode = "overview",
        threatCache = {},
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Calculate threat for each enemy using threat assessor
function CombatAIDisplayUIIntegration:assessThreats()
    for i, enemy in ipairs(self.enemies) do
        if self.threatAssessor then
            local threat = self.threatAssessor:calculateThreat(enemy, self.squad)
            self.threatCache[i] = threat
        else
            self.threatCache[i] = self:fallbackThreatCalculation(enemy)
        end
    end
    
    -- Sort by threat descending
    table.sort(self.enemies, function(a, b)
        local threatA = self.threatCache[self:findEnemyIndex(a)] or 0
        local threatB = self.threatCache[self:findEnemyIndex(b)] or 0
        return threatA > threatB
    end)
end

--- Find enemy index in original list
function CombatAIDisplayUIIntegration:findEnemyIndex(enemy)
    for i, e in ipairs(self.enemies) do
        if e == enemy then return i end
    end
    return 0
end

--- Fallback threat calculation (0-10 scale)
function CombatAIDisplayUIIntegration:fallbackThreatCalculation(enemy)
    local threat = 0
    
    -- Distance factor (40%)
    local distanceFactor = 1 - (math.min(enemy.distance or 5, 10) / 10)
    threat = threat + distanceFactor * 4
    
    -- Firepower factor (30%)
    local firepower = math.min(enemy.firepower or 5, 10)
    threat = threat + (firepower / 10) * 3
    
    -- Armor factor (20%)
    local armor = math.min(enemy.armor or 5, 10)
    threat = threat + (armor / 10) * 2
    
    -- Accuracy factor (10%)
    local accuracy = math.min(enemy.accuracy or 60, 100) / 100
    threat = threat + accuracy * 1
    
    return math.min(threat, 10)
end

--- Get threat tier
function CombatAIDisplayUIIntegration:getThreatTier(threat)
    if threat >= 8 then
        return "CRITICAL", {1, 0, 0}
    elseif threat >= 6 then
        return "HIGH", {1, 0.5, 0}
    elseif threat >= 4 then
        return "MEDIUM", {1, 1, 0}
    else
        return "LOW", {0, 1, 0}
    end
end

--- Get tactical recommendation for threat
function CombatAIDisplayUIIntegration:getTacticalRecommendation(enemy, threat)
    local tier, _ = self:getThreatTier(threat)
    
    if tier == "CRITICAL" then
        if enemy.distance and enemy.distance <= 3 then
            return "SUPPRESS IMMEDIATELY", "Close contact - suppress before advancing"
        elseif enemy.firepower and enemy.firepower >= 8 then
            return "TAKE COVER", "Heavy firepower detected - seek cover immediately"
        else
            return "SUPPRESS", "Critical threat - prioritize suppression"
        end
    elseif tier == "HIGH" then
        if enemy.distance and enemy.distance <= 5 then
            return "ENGAGE", "Medium range threat - engage directly"
        else
            return "MONITOR", "Distant high threat - maintain vigilance"
        end
    elseif tier == "MEDIUM" then
        return "STANDARD COMBAT", "Proceed with normal engagement protocols"
    else
        return "LOWER PRIORITY", "Minimal threat - focus on critical targets"
    end
end

--- Draw threat overview panel
function CombatAIDisplayUIIntegration:drawThreatOverview()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Threat Analysis", 20, 20)
    
    -- Assess all threats
    self:assessThreats()
    
    -- Left panel: Threat list
    local listX = 20
    local listY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", listX, listY, 350, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", listX, listY, 350, 600)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Detected Threats", listX + 10, listY + 10)
    
    local threatY = listY + 40
    for i, enemy in ipairs(self.enemies) do
        if i > 6 then break end
        
        local threat = self.threatCache[self:findEnemyIndex(enemy)] or 0
        local tier, tierColor = self:getThreatTier(threat)
        
        if self.selectedTarget == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", listX + 5, threatY - 2, 340, 85)
        end
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("line", listX + 5, threatY - 2, 340, 85)
        
        -- Name
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(enemy.name or ("Enemy " .. i), listX + 15, threatY)
        
        -- Threat level
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.printf(tier .. " (" .. string.format("%.1f", threat) .. "/10)", listX + 200, threatY, 145, "right")
        
        -- Stats
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print("Dist:" .. (enemy.distance or 0) .. "  HP:" .. (enemy.hp or 50), listX + 15, threatY + 18)
        
        love.graphics.print("Fire:" .. (enemy.firepower or 5) .. "  Arm:" .. (enemy.armor or 3) .. "  Acc:" .. (enemy.accuracy or 60) .. "%", listX + 15, threatY + 33)
        
        -- Flags
        local flags = {}
        if enemy.flanking then table.insert(flags, "FLANKING") end
        if enemy.suppressed then table.insert(flags, "SUPPRESSED") end
        if #flags > 0 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print(table.concat(flags, " "), listX + 15, threatY + 48)
        end
        
        threatY = threatY + 90
    end
    
    -- Middle panel: Selected threat analysis
    local analysisX = 390
    local analysisY = 70
    
    if self.selectedTarget <= #self.enemies then
        local enemy = self.enemies[self.selectedTarget]
        local threat = self.threatCache[self:findEnemyIndex(enemy)] or 0
        local tier, tierColor = self:getThreatTier(threat)
        
        love.graphics.setColor(0.15, 0.15, 0.2)
        love.graphics.rectangle("fill", analysisX, analysisY, 280, 600)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", analysisX, analysisY, 280, 600)
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print(enemy.name or "Enemy", analysisX + 10, analysisY + 10)
        
        -- Threat meter
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", analysisX + 10, analysisY + 50, 260, 25)
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("fill", analysisX + 10, analysisY + 50, 260 * (threat / 10), 25)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.printf(string.format("%.1f / 10", threat), analysisX + 10, analysisY + 54, 260, "center")
        
        -- Detailed analysis
        local detailY = analysisY + 90
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        
        local analysis = {
            {"Distance:", (enemy.distance or 0) .. " tiles"},
            {"Health:", (enemy.hp or 50)},
            {"Firepower:", enemy.firepower or 5},
            {"Armor:", enemy.armor or 3},
            {"Accuracy:", (enemy.accuracy or 60) .. "%"},
            {"Evasion:", (enemy.evasion or 30) .. "%"},
            {"Status:", enemy.suppressed and "SUPPRESSED" or "ACTIVE"},
        }
        
        for i, item in ipairs(analysis) do
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(item[1], analysisX + 10, detailY)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tostring(item[2]), analysisX + 150, detailY)
            
            detailY = detailY + 22
        end
        
        -- Tactical recommendation
        local action, reason = self:getTacticalRecommendation(enemy, threat)
        
        detailY = detailY + 15
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("Action:", analysisX + 10, detailY)
        
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(action, analysisX + 10, detailY + 18, 260, "left")
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(reason, analysisX + 10, detailY + 40, 260, "left")
    end
    
    -- Right panel: Squad resource status
    local resourceX = 690
    local resourceY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", resourceX, resourceY, 250, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", resourceX, resourceY, 250, 600)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Squad Resources", resourceX + 10, resourceY + 10)
    
    -- Resources
    local resources = {
        {name = "Ammunition", current = 45, max = 60, color = {1, 1, 0}},
        {name = "Medical", current = 3, max = 5, color = {0, 1, 0}},
        {name = "Grenades", current = 8, max = 12, color = {1, 0.5, 0}},
        {name = "Armor", current = 70, max = 100, color = {0, 1, 1}},
    }
    
    local resY = resourceY + 45
    for i, res in ipairs(resources) do
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print(res.name, resourceX + 10, resY)
        
        -- Bar
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", resourceX + 10, resY + 16, 200, 12)
        
        love.graphics.setColor(res.color[1], res.color[2], res.color[3])
        love.graphics.rectangle("fill", resourceX + 10, resY + 16, 200 * (res.current / res.max), 12)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(res.current .. "/" .. res.max, resourceX + 10, resY + 17, 200, "center")
        
        resY = resY + 50
    end
    
    -- AI Summary
    resY = resY + 15
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("AI Assessment:", resourceX + 10, resY)
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(8))
    local assessment = #self.enemies .. " threats detected. "
    if self.selectedTarget <= #self.enemies then
        local enemy = self.enemies[self.selectedTarget]
        local threat = self.threatCache[self:findEnemyIndex(enemy)] or 0
        assessment = assessment .. "Priority: " .. (self:getThreatTier(threat))
    end
    
    love.graphics.printf(assessment, resourceX + 10, resY + 18, 230, "left")
end

--- Handle input
function CombatAIDisplayUIIntegration:handleInput(key)
    if key == "up" then
        self.selectedTarget = math.max(1, self.selectedTarget - 1)
    elseif key == "down" then
        self.selectedTarget = math.min(#self.enemies, self.selectedTarget + 1)
    end
end

--- Draw main interface
function CombatAIDisplayUIIntegration:draw()
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    self:drawThreatOverview()
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[↑↓]Select Threat  [ESC]Close", 10, 705)
end

return CombatAIDisplayUIIntegration



