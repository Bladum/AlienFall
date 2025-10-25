--- Combat AI Display UI
-- Threat assessment and AI recommendation display
-- Shows: threat levels, priority targets, tactical hints, AI reasoning
-- Integrates with: threat_assessment.lua, squad_coordination.lua, resource_awareness.lua
--
-- @module combat_ai_display_ui
-- @author AI Development Team
-- @license MIT

local CombatAIDisplayUI = {}

--- Create new combat AI display instance
-- @param squad Squad entity
-- @param enemies Enemies on battlefield
-- @param terrain Terrain data
-- @return Combat AI display UI instance
function CombatAIDisplayUI:new(squad, enemies, terrain)
    local instance = {
        squad = squad,
        enemies = enemies or {},
        terrain = terrain or {},
        selectedTarget = 1, -- Index of selected target
        viewMode = "overview", -- overview, threats, tactics, resources
        scroll = 0,
        animationTime = 0,
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Calculate threat level (1-10 scale)
function CombatAIDisplayUI:getThreatLevel(enemy)
    -- Mock calculation based on enemy stats
    local threat = 0
    
    -- Distance factor (closer = more threat)
    local distanceFactor = (10 - (enemy.distance or 5)) / 10
    
    -- Firepower factor
    local firepower = enemy.firepower or 5
    local firearmFactor = firepower / 10
    
    -- Armor factor
    local armor = enemy.armor or 5
    local armorFactor = armor / 10
    
    -- Accuracy factor
    local accuracy = enemy.accuracy or 60
    local accuracyFactor = accuracy / 100
    
    -- Combined threat: distance(40%) + firepower(30%) + armor(20%) + accuracy(10%)
    threat = (distanceFactor * 0.4 + firearmFactor * 0.3 + armorFactor * 0.2 + accuracyFactor * 0.1) * 10
    
    return math.min(10, math.max(1, threat))
end

--- Get threat tier based on threat level
function CombatAIDisplayUI:getThreatTier(threatLevel)
    if threatLevel >= 8 then
        return "CRITICAL", {1, 0, 0}
    elseif threatLevel >= 6 then
        return "HIGH", {1, 0.5, 0}
    elseif threatLevel >= 4 then
        return "MEDIUM", {1, 1, 0}
    else
        return "LOW", {0, 1, 0}
    end
end

--- Get tactical recommendation
function CombatAIDisplayUI:getTacticalRecommendation(enemy, squad)
    local threats = {}
    
    if enemy.distance and enemy.distance <= 3 then
        table.insert(threats, "CLOSE RANGE: Take cover immediately")
    end
    
    if enemy.firepower and enemy.firepower >= 8 then
        table.insert(threats, "HEAVY FIREPOWER: Stay in cover")
    end
    
    if enemy.armor and enemy.armor >= 8 then
        table.insert(threats, "HEAVY ARMOR: Use heavy weapons")
    end
    
    if enemy.flanking then
        table.insert(threats, "FLANKING POSITION: Reposition squad")
    end
    
    if enemy.suppressed then
        table.insert(threats, "SUPPRESSED: Advance aggressively")
    end
    
    return threats
end

--- Draw overview panel (all threats at a glance)
function CombatAIDisplayUI:drawOverview()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Combat Status", 20, 20)
    
    -- Left panel: Threats (top)
    self:drawThreatsPanel(20, 70, 450, 330)
    
    -- Left panel: AI Reasoning (bottom)
    self:drawAIReasoningPanel(20, 410, 450, 280)
    
    -- Right panel: Tactical recommendations
    self:drawTacticalPanel(480, 70, 450, 330)
    
    -- Right panel: Resource status
    self:drawResourcePanel(480, 410, 450, 280)
end

--- Draw threats panel with all detected enemies
function CombatAIDisplayUI:drawThreatsPanel(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Detected Threats", x + 10, y + 10)
    
    -- Mock enemy data
    local enemies = {
        {name = "Sectoid", distance = 4, firepower = 6, armor = 3, accuracy = 75, hp = 30, flanking = false},
        {name = "Thin Man", distance = 6, firepower = 8, armor = 4, accuracy = 85, hp = 25, flanking = false},
        {name = "Muton", distance = 3, firepower = 9, armor = 7, accuracy = 70, hp = 50, flanking = true},
        {name = "Sectoid Commander", distance = 8, firepower = 7, armor = 5, accuracy = 80, hp = 35, flanking = false},
        {name = "Chryssalid", distance = 2, firepower = 8, armor = 6, accuracy = 75, hp = 40, flanking = true},
    }
    
    local threatY = y + 40
    local count = 0
    for i, enemy in ipairs(enemies) do
        if count >= 4 then break end
        
        local threat = self:getThreatLevel(enemy)
        local tier, tierColor = self:getThreatTier(threat)
        
        -- Highlight selected
        if self.selectedTarget == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", x + 5, threatY - 2, width - 10, 60)
        end
        
        -- Border
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("line", x + 5, threatY - 2, width - 10, 60)
        
        -- Threat indicator bar (left)
        love.graphics.rectangle("fill", x + 8, threatY, 4, 54)
        
        -- Enemy info
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print(enemy.name, x + 20, threatY)
        
        -- Threat level
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(tier .. " (" .. string.format("%.1f", threat) .. "/10)", x + 200, threatY, width - 220, "left")
        
        -- Distance and HP
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.print("Distance: " .. enemy.distance .. " tiles", x + 20, threatY + 18)
        love.graphics.print("HP: " .. enemy.hp, x + 200, threatY + 18)
        
        -- Threat factors
        love.graphics.setColor(0.6, 0.6, 0.7)
        love.graphics.setFont(love.graphics.newFont(8))
        
        local factors = "Fire:" .. enemy.firepower .. " Arm:" .. enemy.armor .. " Acc:" .. enemy.accuracy .. "%"
        if enemy.flanking then
            factors = factors .. " [FLANKING]"
        end
        love.graphics.print(factors, x + 20, threatY + 33)
        
        threatY = threatY + 65
        count = count + 1
    end
    
    if #enemies > 4 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("... and " .. (#enemies - 4) .. " more", x + 10, threatY)
    end
end

--- Draw AI reasoning panel
function CombatAIDisplayUI:drawAIReasoningPanel(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("AI Analysis", x + 10, y + 10)
    
    -- Mock analysis data
    local analysis = {
        "PRIORITY TARGET: Muton (closest threat)",
        "THREAT ASSESSMENT: 5 units detected",
        "SQUAD STATUS: 6/8 healthy, 1 wounded, 1 critical",
        "STRATEGIC: Outnumbered but in cover",
        "RECOMMENDATION: Hold ground, suppress Muton",
        "ESTIMATED DAMAGE: 15-25% squad HP next turn",
    }
    
    local analysisY = y + 40
    love.graphics.setFont(love.graphics.newFont(10))
    
    for i, line in ipairs(analysis) do
        if i <= 3 then
            love.graphics.setColor(1, 1, 0)
        elseif i <= 5 then
            love.graphics.setColor(0, 1, 1)
        else
            love.graphics.setColor(1, 0.5, 0)
        end
        
        love.graphics.printf(line, x + 10, analysisY, width - 20, "left")
        analysisY = analysisY + 35
    end
end

--- Draw tactical recommendations panel
function CombatAIDisplayUI:drawTacticalPanel(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Tactical Recommendations", x + 10, y + 10)
    
    -- Mock tactical data
    local tactics = {
        {priority = 1, action = "SUPPRESS Muton", reason = "Highest threat, blocks advance"},
        {priority = 2, action = "HEAL Wounded Scout", reason = "Restore combat effectiveness"},
        {priority = 3, action = "FLANK RIGHT", reason = "Cover is weak on right side"},
        {priority = 4, action = "DEFEND POSITION", reason = "Avoid casualties from superior numbers"},
        {priority = 5, action = "WAIT FOR BACKUP", reason = "Reinforcements arriving in 2 turns"},
    }
    
    local tacticY = y + 40
    local count = 0
    
    for i, tactic in ipairs(tactics) do
        if count >= 4 then break
        
        -- Priority indicator
        local priorityColor = tactic.priority == 1 and {1, 0, 0} or (tactic.priority == 2 and {1, 0.5, 0} or (tactic.priority <= 3 and {1, 1, 0} or {0, 1, 0}))
        
        love.graphics.setColor(priorityColor[1], priorityColor[2], priorityColor[3])
        love.graphics.rectangle("fill", x + 8, tacticY, 4, 60)
        
        -- Action text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print("[" .. tactic.priority .. "] " .. tactic.action, x + 20, tacticY + 5)
        
        -- Reason
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(tactic.reason, x + 20, tacticY + 22, width - 40, "left")
        
        tacticY = tacticY + 65
        count = count + 1
    end
    
    if count >= 4 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("... and more tactics", x + 10, tacticY + 10)
    end
end

--- Draw resource status panel
function CombatAIDisplayUI:drawResourcePanel(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Resource Status", x + 10, y + 10)
    
    -- Mock resource data
    local resources = {
        {name = "Ammunition", current = 45, max = 60, color = {1, 1, 0}},
        {name = "Medical Supplies", current = 3, max = 5, color = {0, 1, 0}},
        {name = "Grenades", current = 8, max = 12, color = {1, 0.5, 0}},
        {name = "Armor Integrity", current = 70, max = 100, color = {0, 1, 1}},
    }
    
    local resourceY = y + 45
    
    for i, res in ipairs(resources) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(res.name, x + 10, resourceY)
        
        -- Resource bar
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", x + 160, resourceY - 2, 150, 20)
        
        love.graphics.setColor(res.color[1], res.color[2], res.color[3])
        local percentage = res.current / res.max
        love.graphics.rectangle("fill", x + 160, resourceY - 2, 150 * percentage, 20)
        
        -- Text label
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(res.current .. "/" .. res.max, x + 160, resourceY + 1, 150, "center")
        
        -- Status indicator
        love.graphics.setColor(res.color[1], res.color[2], res.color[3])
        if percentage > 0.75 then
            love.graphics.print("OK", x + 320, resourceY)
        elseif percentage > 0.5 then
            love.graphics.print("NORMAL", x + 310, resourceY)
        elseif percentage > 0.25 then
            love.graphics.print("LOW", x + 315, resourceY)
        else
            love.graphics.print("CRITICAL", x + 310, resourceY)
        end
        
        resourceY = resourceY + 50
    end
end

--- Draw threat list view
function CombatAIDisplayUI:drawThreatsView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Threat Analysis", 20, 20)
    
    -- Mock threat data (detailed)
    local enemies = {
        {
            name = "Muton", tier = "CRITICAL", threat = 9.2,
            distance = 3, firepower = 9, armor = 7, accuracy = 70, hp = 50,
            flanking = true, suppressed = false, wounded = false,
            threat_factors = "Close range (9.2), Heavy armor (7), High firepower (9), Flanking position",
            recommendation = "SUPPRESS IMMEDIATELY - Use heavy weapons, maintain cover"
        },
        {
            name = "Thin Man", tier = "HIGH", threat = 7.5,
            distance = 6, firepower = 8, armor = 4, accuracy = 85, hp = 25,
            flanking = false, suppressed = false, wounded = false,
            threat_factors = "Medium range (7.5), High accuracy (85%), Can flank quickly",
            recommendation = "Suppress from distance, minimize exposure"
        },
        {
            name = "Sectoid Commander", tier = "HIGH", threat = 7.1,
            distance = 8, firepower = 7, armor = 5, accuracy = 80, hp = 35,
            flanking = false, suppressed = false, wounded = false,
            threat_factors = "Long range (7.1), Psi abilities, Tactical threat",
            recommendation = "Prioritize - Can control squad with psi power"
        },
    }
    
    -- Left panel: List
    local listX = 20
    local listY = 70
    local listWidth = 250
    local listHeight = 600
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", listX, listY, listWidth, listHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", listX, listY, listWidth, listHeight)
    
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("Enemy List", listX + 10, listY + 10)
    
    local itemY = listY + 40
    for i, enemy in ipairs(enemies) do
        if self.selectedTarget == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", listX + 5, itemY, listWidth - 10, 50)
        end
        
        local tierColor = enemy.tier == "CRITICAL" and {1, 0, 0} or (enemy.tier == "HIGH" and {1, 0.5, 0} or {1, 1, 0})
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.rectangle("line", listX + 5, itemY, listWidth - 10, 50)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(enemy.name, listX + 15, itemY + 5)
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(enemy.tier .. " " .. string.format("%.1f", enemy.threat), listX + 15, itemY + 20, listWidth - 30, "left")
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("HP:" .. enemy.hp .. " Dist:" .. enemy.distance, listX + 15, itemY + 33)
        
        itemY = itemY + 55
    end
    
    -- Right panel: Details
    if self.selectedTarget <= #enemies then
        local enemy = enemies[self.selectedTarget]
        local detailX = 300
        local detailY = 70
        local detailWidth = 620
        local detailHeight = 600
        
        love.graphics.setColor(0.15, 0.15, 0.2)
        love.graphics.rectangle("fill", detailX, detailY, detailWidth, detailHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", detailX, detailY, detailWidth, detailHeight)
        
        local tierColor = enemy.tier == "CRITICAL" and {1, 0, 0} or (enemy.tier == "HIGH" and {1, 0.5, 0} or {1, 1, 0})
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.print(enemy.name .. " - " .. enemy.tier, detailX + 10, detailY + 10)
        
        -- Threat meter
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print("Overall Threat Level:", detailX + 10, detailY + 40)
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", detailX + 200, detailY + 38, 300, 30)
        
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        local threatPercent = enemy.threat / 10
        love.graphics.rectangle("fill", detailX + 200, detailY + 38, 300 * threatPercent, 30)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(string.format("%.1f / 10", enemy.threat), detailX + 200, detailY + 43, 300, "center")
        
        -- Detailed stats
        local statsY = detailY + 85
        local stats = {
            {"Distance:", enemy.distance .. " tiles"},
            {"HP:", enemy.hp},
            {"Firepower:", enemy.firepower},
            {"Armor:", enemy.armor},
            {"Accuracy:", enemy.accuracy .. "%"},
            {"Flanking:", enemy.flanking and "YES" or "NO"},
            {"Suppressed:", enemy.suppressed and "YES" or "NO"},
        }
        
        love.graphics.setFont(love.graphics.newFont(11))
        for i, stat in ipairs(stats) do
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(stat[1], detailX + 10, statsY)
            
            if i >= 6 then
                love.graphics.setColor(stat[2] == "YES" and {1, 0, 0} or {0, 1, 0})
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.print(stat[2], detailX + 150, statsY)
            
            statsY = statsY + 25
        end
        
        -- Threat factors
        statsY = statsY + 15
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print("Threat Factors:", detailX + 10, statsY)
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(enemy.threat_factors, detailX + 10, statsY + 25, detailWidth - 20, "left")
        
        -- Recommendation
        statsY = statsY + 65
        love.graphics.setColor(tierColor[1], tierColor[2], tierColor[3])
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print("Recommendation:", detailX + 10, statsY)
        
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(enemy.recommendation, detailX + 10, statsY + 25, detailWidth - 20, "left")
    end
end

--- Handle keyboard input
function CombatAIDisplayUI:handleInput(key)
    if key == "tab" then
        local modes = {"overview", "threats", "tactics", "resources"}
        local currentIndex = 1
        for i, m in ipairs(modes) do
            if m == self.viewMode then
                currentIndex = i
                break
            end
        end
        self.viewMode = modes[(currentIndex % #modes) + 1]
    elseif key == "up" then
        self.selectedTarget = math.max(1, self.selectedTarget - 1)
    elseif key == "down" then
        self.selectedTarget = math.min(5, self.selectedTarget + 1)
    end
end

--- Main draw function
function CombatAIDisplayUI:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    if self.viewMode == "overview" then
        self:drawOverview()
    elseif self.viewMode == "threats" then
        self:drawThreatsView()
    end
    
    -- Footer
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[TAB]Change View  [↑↓]Select Target  [ESC]Close", 10, 705)
end
end

return CombatAIDisplayUI




