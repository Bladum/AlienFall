--- Squad Management UI Integration
-- Integrates UI with squad coordination and real squad data
-- Connects: squad_management_ui.lua → squad_coordination.lua
--
-- @module squad_management_ui_integration
-- @author AI Development Team
-- @license MIT

local SquadManagementUIIntegration = {}

--- Initialize squad management UI with real squad data
-- @param squad Squad entity
-- @param coordinator Squad coordinator instance
-- @return Integrated squad UI instance
function SquadManagementUIIntegration:new(squad, coordinator)
    local instance = {
        squad = squad,
        coordinator = coordinator,
        units = squad.units or {},
        selectedUnit = 1,
        selectedFormation = "diamond",
        formations = {"diamond", "line", "wedge", "column"},
        viewMode = "overview",
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Calculate squad cohesion from coordinator
function SquadManagementUIIntegration:calculateCohesion()
    if self.coordinator then
        return self.coordinator:calculateSquadCohesion(self.squad)
    end
    
    -- Fallback: Simple cohesion calculation
    local baseCohesion = 100
    local wounds = 0
    local separation = 0
    
    for i, unit in ipairs(self.units) do
        if unit.hp and unit.hp < unit.maxHp then
            wounds = wounds + (1 - unit.hp / unit.maxHp) * 10
        end
    end
    
    -- Separation penalty (simplified)
    separation = math.max(0, (#self.units - 1) * 5 - 15)
    
    return math.max(0, baseCohesion - wounds - separation)
end

--- Apply formation using coordinator
function SquadManagementUIIntegration:applyFormation(formationType)
    if self.coordinator then
        self.coordinator:applyFormation(self.squad, formationType)
    end
    self.selectedFormation = formationType
end

--- Get formation effectiveness bonus
function SquadManagementUIIntegration:getFormationBonus(formationType)
    local bonuses = {
        diamond = {defense = 15, flexibility = 20, firepower = 10},
        line = {defense = 5, flexibility = 5, firepower = 30},
        wedge = {defense = 10, flexibility = 15, firepower = 20},
        column = {defense = 5, flexibility = 25, firepower = 5},
    }
    return bonuses[formationType] or bonuses.diamond
end

--- Get role recommendations based on unit stats
function SquadManagementUIIntegration:getRoleRecommendation(unit)
    local stats = {
        strength = unit.strength or 5,
        accuracy = unit.accuracy or 60,
        reactions = unit.reactions or 60,
        speed = unit.speed or 5,
        medical = unit.medical or 0,
        psi = unit.psi or 0,
    }
    
    -- Analyze stats to recommend role
    if stats.strength >= 9 and stats.accuracy >= 70 then
        return "HEAVY", "High strength and accuracy - optimal for heavy weapons"
    elseif stats.reactions >= 75 and stats.speed >= 8 then
        return "SCOUT", "High reactions and speed - optimal for flanking"
    elseif stats.medical >= 7 or stats.strength >= 8 then
        return "LEADER", "Well-rounded stats - can lead squad"
    elseif stats.medical >= 5 then
        return "MEDIC", "Medical training available - support role"
    else
        return "SUPPORT", "General combat - flexible support"
    end
end

--- Calculate unit experience and leveling
function SquadManagementUIIntegration:getUnitExperience(unit)
    return {
        current = unit.experience or 0,
        nextLevel = ((unit.level or 0) + 1) * 100,
        level = unit.level or 0,
        progress = (unit.experience or 0) / (((unit.level or 0) + 1) * 100),
    }
end

--- Draw squad roster with real data
function SquadManagementUIIntegration:drawRoster()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Squad Management", 20, 20)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Squad Roster", 20, 70)
    
    local rosterY = 100
    local unitNum = 1
    
    for i, unit in ipairs(self.units) do
        if unitNum > 8 then break end
        
        if self.selectedUnit == i then
            love.graphics.setColor(0, 1, 0, 0.2)
            love.graphics.rectangle("fill", 20, rosterY - 2, 300, 60)
        end
        
        love.graphics.setColor(0.15, 0.15, 0.2)
        love.graphics.rectangle("fill", 20, rosterY - 2, 300, 60)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 20, rosterY - 2, 300, 60)
        
        -- Role indicator
        local role = unit.role or "SUPPORT"
        local roleColors = {
            LEADER = {1, 0, 0},
            HEAVY = {1, 1, 0},
            MEDIC = {0, 1, 0},
            SCOUT = {0, 1, 1},
            SUPPORT = {1, 0, 1},
        }
        love.graphics.setColor((roleColors[role] or {1, 1, 1})[1], (roleColors[role] or {1, 1, 1})[2], (roleColors[role] or {1, 1, 1})[3])
        love.graphics.rectangle("fill", 25, rosterY + 2, 6, 6)
        
        -- Unit name and role
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(unit.name or ("Unit " .. i) .. " [" .. role .. "]", 40, rosterY)
        
        -- HP bar
        local hp = unit.hp or 100
        local maxHp = unit.maxHp or 100
        local hpPercent = hp / maxHp
        local hpColor = hpPercent > 0.75 and {0, 1, 0} or (hpPercent > 0.5 and {1, 1, 0} or (hpPercent > 0.25 and {1, 0.5, 0} or {1, 0, 0}))
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", 40, rosterY + 20, 80, 8)
        
        love.graphics.setColor(hpColor[1], hpColor[2], hpColor[3])
        love.graphics.rectangle("fill", 40, rosterY + 20, 80 * hpPercent, 8)
        
        -- HP text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf(math.floor(hp) .. "/" .. maxHp, 40, rosterY + 21, 80, "center")
        
        -- Level
        local level = unit.level or 1
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf("Lvl " .. level, 135, rosterY + 5, 60, "center")
        
        -- Experience progress
        local exp = unit.experience or 0
        local maxExp = ((unit.level or 0) + 1) * 100
        local expPercent = exp / maxExp
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", 135, rosterY + 25, 60, 5)
        
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", 135, rosterY + 25, 60 * expPercent, 5)
        
        rosterY = rosterY + 70
        unitNum = unitNum + 1
    end
end

--- Draw formation management panel
function SquadManagementUIIntegration:drawFormationManager()
    local formX = 330
    local formY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", formX, formY, 300, 300)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", formX, formY, 300, 300)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Formation", formX + 10, formY + 10)
    
    -- Formation buttons
    local buttonY = formY + 45
    for i, formation in ipairs(self.formations) do
        local bX = formX + 10
        local bY = buttonY + (i - 1) * 55
        
        if self.selectedFormation == formation then
            love.graphics.setColor(0, 1, 0, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", bX, bY, 280, 45)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", bX, bY, 280, 45)
        
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print(string.upper(formation), bX + 10, bY + 5)
        
        -- Bonuses
        local bonus = self:getFormationBonus(formation)
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf("DEF:" .. bonus.defense .. " FLX:" .. bonus.flexibility .. " PWR:" .. bonus.firepower, bX + 10, bY + 22, 260, "left")
    end
end

--- Draw cohesion panel
function SquadManagementUIIntegration:drawCohesionPanel()
    local cohX = 640
    local cohY = 70
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", cohX, cohY, 300, 300)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", cohX, cohY, 300, 300)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Squad Cohesion", cohX + 10, cohY + 10)
    
    local cohesion = self:calculateCohesion()
    
    -- Cohesion bar
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", cohX + 10, cohY + 50, 280, 30)
    
    local cohColor = cohesion > 75 and {0, 1, 0} or (cohesion > 50 and {1, 1, 0} or {1, 0, 0})
    love.graphics.setColor(cohColor[1], cohColor[2], cohColor[3])
    love.graphics.rectangle("fill", cohX + 10, cohY + 50, 280 * (cohesion / 100), 30)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(string.format("%.0f%%", cohesion), cohX + 10, cohY + 54, 280, "center")
    
    -- Status text
    local cohStatus = cohesion > 75 and "EXCELLENT" or (cohesion > 50 and "GOOD" or "POOR")
    local statColor = cohesion > 75 and {0, 1, 0} or (cohesion > 50 and {1, 1, 0} or {1, 0, 0})
    
    love.graphics.setColor(statColor[1], statColor[2], statColor[3])
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.printf(cohStatus, cohX + 10, cohY + 100, 280, "center")
    
    -- Effects
    local effects = {
        {label = "Morale Bonus:", value = "+" .. math.floor(cohesion / 10) .. "%"},
        {label = "Flank Defense:", value = "+" .. math.floor(cohesion / 15) .. "%"},
        {label = "Suppression Resist:", value = "+" .. math.floor(cohesion / 20) .. "%"},
    }
    
    local effectY = cohY + 145
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(9))
    
    for i, effect in ipairs(effects) do
        love.graphics.print(effect.label, cohX + 10, effectY)
        
        love.graphics.setColor(0, 1, 0)
        love.graphics.print(effect.value, cohX + 180, effectY)
        
        love.graphics.setColor(0.7, 0.7, 0.8)
        effectY = effectY + 20
    end
end

--- Draw unit details panel
function SquadManagementUIIntegration:drawUnitDetails()
    local detailX = 330
    local detailY = 390
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", detailX, detailY, 610, 280)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", detailX, detailY, 610, 280)
    
    if self.selectedUnit > #self.units then return end
    
    local unit = self.units[self.selectedUnit]
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Unit Details: " .. (unit.name or "Unit"), detailX + 10, detailY + 10)
    
    -- Left column: Basic stats
    local col1X = detailX + 10
    local statY = detailY + 40
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(9))
    
    local stats = {
        {"Role:", unit.role or "SUPPORT"},
        {"Rank:", unit.rank or "Rookie"},
        {"HP:", math.floor(unit.hp or 100) .. "/" .. (unit.maxHp or 100)},
        {"Accuracy:", math.floor(unit.accuracy or 60) .. "%"},
        {"Reactions:", math.floor(unit.reactions or 60) .. "%"},
    }
    
    for i, stat in ipairs(stats) do
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print(stat[1], col1X, statY)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tostring(stat[2]), col1X + 100, statY)
        
        statY = statY + 20
    end
    
    -- Middle column: Combat stats
    local col2X = detailX + 280
    statY = detailY + 40
    
    local combatStats = {
        {"Strength:", unit.strength or 5},
        {"Speed:", unit.speed or 5},
        {"Psi Power:", unit.psi or 0},
        {"Medical:", unit.medical or 0},
        {"Experience:", math.floor(unit.experience or 0) .. " / " .. ((unit.level or 0) + 1) * 100},
    }
    
    for i, stat in ipairs(combatStats) do
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.print(stat[1], col2X, statY)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tostring(stat[2]), col2X + 100, statY)
        
        statY = statY + 20
    end
    
    -- Right column: Recommended role
    local col3X = detailX + 550
    local recRole, recReason = self:getRoleRecommendation(unit)
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Recommendation:", col3X - 520, detailY + 40)
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print(recRole, col3X - 520, detailY + 60)
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(8))
    love.graphics.printf(recReason, col3X - 520, detailY + 80, 150, "left")
end

--- Handle input
function SquadManagementUIIntegration:handleInput(key)
    if key == "up" then
        self.selectedUnit = math.max(1, self.selectedUnit - 1)
    elseif key == "down" then
        self.selectedUnit = math.min(#self.units, self.selectedUnit + 1)
    elseif key == "left" then
        local idx = 1
        for i, f in ipairs(self.formations) do
            if f == self.selectedFormation then idx = i break end
        end
        if idx > 1 then
            self:applyFormation(self.formations[idx - 1])
        end
    elseif key == "right" then
        local idx = 1
        for i, f in ipairs(self.formations) do
            if f == self.selectedFormation then idx = i break end
        end
        if idx < #self.formations then
            self:applyFormation(self.formations[idx + 1])
        end
    end
end

--- Draw main interface
function SquadManagementUIIntegration:draw()
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    self:drawRoster()
    self:drawFormationManager()
    self:drawCohesionPanel()
    self:drawUnitDetails()
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[↑↓]Select Unit  [←→]Change Formation  [ESC]Close", 10, 705)
end

return SquadManagementUIIntegration



