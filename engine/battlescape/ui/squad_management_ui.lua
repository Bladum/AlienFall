--- Squad Management UI
-- Squad formation and role assignment screen
-- Shows: squad roles, formations, cohesion, recommended actions per role
-- Integrates with: squad_coordination.lua, threat_assessment.lua
--
-- @module squad_management_ui
-- @author AI Development Team
-- @license MIT

local SquadManagementUI = {}

--- Create new squad management UI instance
-- @param squad Squad entity with units and coordinator
-- @return Squad management UI instance
function SquadManagementUI:new(squad)
    local instance = {
        squad = squad,
        selectedUnit = 1, -- Index of selected unit
        selectedFormation = "diamond", -- Current formation
        formations = {"diamond", "line", "wedge", "column"},
        formationNames = {
            diamond = "Diamond (Flexible)",
            line = "Line (Maximum Firepower)",
            wedge = "Wedge (Concentrated Attack)",
            column = "Column (Narrow Spaces)",
        },
        formationDescriptions = {
            diamond = "Protects center unit, good for mixed squads",
            line = "Wide engagement front, maximum firepower",
            wedge = "Concentrated attack formation, good breakthrough",
            column = "Single-file for corridors and tight spaces",
        },
        viewMode = "overview", -- overview, formation, cohesion, actions
        scroll = 0,
    }
    setmetatable(instance, { __index = self })
    return instance
end

--- Get role display information
function SquadManagementUI:getRoleInfo(role)
    local roleInfo = {
        LEADER = {
            name = "Leader",
            color = {1, 0, 0},
            responsibility = "Decision-making, holds ground, heals support",
            bonus = "+10 morale to nearby allies",
            action = "Rally team / Issue commands",
        },
        HEAVY = {
            name = "Heavy Weapons",
            color = {1, 1, 0},
            responsibility = "Heavy weapons, suppressive fire, crowd control",
            bonus = "Heavy weapon mastery",
            action = "Suppressing Fire / Area Control",
        },
        MEDIC = {
            name = "Medic",
            color = {0, 1, 0},
            responsibility = "Healing support, stays with squad, high retreat threshold",
            bonus = "Medical training (+20% heal)",
            action = "Heal Ally / Stabilize Wounded",
        },
        SCOUT = {
            name = "Scout",
            color = {0, 1, 1},
            responsibility = "Speed, flanking, reconnaissance",
            bonus = "+20% movement speed, +25% flanking damage",
            action = "Flank / Advance / Reconnaissance",
        },
        SUPPORT = {
            name = "Support",
            color = {1, 0, 1},
            responsibility = "General combat, standard engagement",
            bonus = "Balanced skills",
            action = "Standard Combat / Support",
        },
    }
    return roleInfo[role or "SUPPORT"] or roleInfo.SUPPORT
end

--- Draw overview panel
function SquadManagementUI:drawOverview()
    local panelWidth = 960
    local panelHeight = 720
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Squad Management", 20, 20)
    
    -- Left panel: Squad roster
    self:drawSquadRoster(20, 70, 300, 600)
    
    -- Middle panel: Formation selector and cohesion
    self:drawFormationSelector(330, 70, 300, 350)
    self:drawCohesionPanel(330, 430, 300, 240)
    
    -- Right panel: Selected unit details
    self:drawUnitDetails(640, 70, 300, 600)
end

--- Draw squad roster
function SquadManagementUI:drawSquadRoster(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Squad Roster", x + 10, y + 10)
    
    -- Mock squad data
    local squad = {
        {name = "Smith", role = "LEADER", hp = 100, status = "OK", level = 2},
        {name = "Johnson", role = "HEAVY", hp = 95, status = "OK", level = 1},
        {name = "Williams", role = "MEDIC", hp = 80, status = "OK", level = 1},
        {name = "Brown", role = "SCOUT", hp = 100, status = "OK", level = 2},
        {name = "Davis", role = "SUPPORT", hp = 90, status = "WOUNDED", level = 1},
        {name = "Miller", role = "SUPPORT", hp = 70, status = "CRITICAL", level = 0},
        {name = "Wilson", role = "SCOUT", hp = 100, status = "OK", level = 3},
        {name = "Moore", role = "HEAVY", hp = 110, status = "OK", level = 2},
    }
    
    local unitY = y + 40
    for i, unit in ipairs(squad) do
        -- Highlight selected unit
        if self.selectedUnit == i then
            love.graphics.setColor(0, 1, 0, 0.2)
        else
            love.graphics.setColor(0.15, 0.15, 0.2)
        end
        love.graphics.rectangle("fill", x + 5, unitY - 2, width - 10, 32)
        
        -- Border
        love.graphics.setColor(0.3, 0.3, 0.4)
        love.graphics.rectangle("line", x + 5, unitY - 2, width - 10, 32)
        
        -- Role indicator (small square)
        local roleInfo = self:getRoleInfo(unit.role)
        love.graphics.setColor(roleInfo.color[1], roleInfo.color[2], roleInfo.color[3])
        love.graphics.rectangle("fill", x + 10, unitY + 2, 6, 6)
        
        -- Unit name and info
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print(unit.name .. " [" .. roleInfo.name .. "]", x + 25, unitY)
        
        -- HP bar
        local hpPercent = unit.hp / 100
        local hpColor = hpPercent > 0.75 and {0, 1, 0} or (hpPercent > 0.5 and {1, 1, 0} or (hpPercent > 0.25 and {1, 0.5, 0} or {1, 0, 0}))
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", x + 25, unitY + 12, 50, 8)
        
        love.graphics.setColor(hpColor[1], hpColor[2], hpColor[3])
        love.graphics.rectangle("fill", x + 25, unitY + 12, 50 * hpPercent, 8)
        
        -- Status text
        local statusColor = unit.status == "OK" and {0, 1, 0} or (unit.status == "WOUNDED" and {1, 1, 0} or {1, 0, 0})
        love.graphics.setColor(statusColor[1], statusColor[2], statusColor[3])
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print(unit.status, x + 200, unitY + 5)
        
        unitY = unitY + 36
    end
end

--- Draw formation selector
function SquadManagementUI:drawFormationSelector(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Formation", x + 10, y + 10)
    
    -- Formation buttons
    local formX = x + 10
    local formY = y + 40
    local formWidth = (width - 25) / 2
    
    for i, formName in ipairs(self.formations) do
        local fX = formX + ((i - 1) % 2) * (formWidth + 5)
        local fY = formY + math.floor((i - 1) / 2) * 50
        
        if self.selectedFormation == formName then
            love.graphics.setColor(0, 1, 0, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.3)
        end
        love.graphics.rectangle("fill", fX, fY, formWidth, 40)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", fX, fY, formWidth, 40)
        
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(string.upper(formName), fX + 5, fY + 8, formWidth - 10, "center")
    end
    
    -- Formation description
    local description = self.formationDescriptions[self.selectedFormation] or ""
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.printf(description, x + 10, y + height - 40, width - 20, "left")
end

--- Draw cohesion panel
function SquadManagementUI:drawCohesionPanel(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Squad Cohesion", x + 10, y + 10)
    
    -- Mock cohesion data
    local cohesion = 85
    local baseCohesion = 100
    local separation = -15 -- 5 tiles separation penalty
    local casualties = -0 -- No casualties
    
    -- Cohesion bar
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", x + 10, y + 50, width - 20, 30)
    
    local cohesionColor = cohesion > 75 and {0, 1, 0} or (cohesion > 50 and {1, 1, 0} or {1, 0, 0})
    love.graphics.setColor(cohesionColor[1], cohesionColor[2], cohesionColor[3])
    love.graphics.rectangle("fill", x + 10, y + 50, (width - 20) * (cohesion / 100), 30)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.printf(cohesion .. "%", x + 10, y + 56, width - 20, "center")
    
    -- Breakdown
    local breakdownY = y + 95
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(0.7, 0.7, 0.8)
    
    love.graphics.print("Base Cohesion:", x + 10, breakdownY)
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("+" .. baseCohesion .. "%", x + 150, breakdownY)
    
    breakdownY = breakdownY + 20
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Separation Penalty:", x + 10, breakdownY)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print(separation .. "%", x + 150, breakdownY)
    
    breakdownY = breakdownY + 20
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Casualty Penalty:", x + 10, breakdownY)
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(casualties .. "%", x + 150, breakdownY)
    
    breakdownY = breakdownY + 30
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Effect: Units stay together", x + 10, breakdownY)
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("within formations", x + 10, breakdownY + 15)
end

--- Draw selected unit details
function SquadManagementUI:drawUnitDetails(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Unit Details", x + 10, y + 10)
    
    -- Mock selected unit
    local unit = {
        name = "Smith",
        role = "LEADER",
        rank = "Sergeant",
        experience = 250,
        nextLevel = 300,
        hp = 100,
        ap = 50,
        accuracy = 85,
        strength = 10,
        reactions = 75,
        psi = 5,
    }
    
    local roleInfo = self:getRoleInfo(unit.role)
    love.graphics.setColor(roleInfo.color[1], roleInfo.color[2], roleInfo.color[3])
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print(unit.name, x + 10, y + 40)
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    local detailsY = y + 70
    
    local details = {
        {"Rank:", unit.rank},
        {"Role:", roleInfo.name},
        {"", ""},
        {"Combat Stats:", ""},
        {"HP:", unit.hp},
        {"Action Points:", unit.ap},
        {"Accuracy:", unit.accuracy .. "%"},
        {"Strength:", unit.strength},
        {"Reactions:", unit.reactions},
        {"Psi Power:", unit.psi},
        {"", ""},
        {"Experience:", unit.experience .. " / " .. unit.nextLevel},
    }
    
    for i, detail in ipairs(details) do
        if detail[1] == "" then
            detailsY = detailsY + 10
        else
            love.graphics.setColor(0.7, 0.7, 0.8)
            love.graphics.print(detail[1], x + 10, detailsY)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(tostring(detail[2]), x + 120, detailsY)
            
            detailsY = detailsY + 20
        end
    end
    
    -- Role-specific actions
    detailsY = detailsY + 10
    love.graphics.setColor(roleInfo.color[1], roleInfo.color[2], roleInfo.color[3])
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("Primary Action:", x + 10, detailsY)
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.printf(roleInfo.action, x + 10, detailsY + 20, width - 20, "left")
    
    detailsY = detailsY + 50
    love.graphics.print("Responsibility:", x + 10, detailsY)
    love.graphics.printf(roleInfo.responsibility, x + 10, detailsY + 15, width - 20, "left")
end

--- Draw formation preview
function SquadManagementUI:drawFormationView()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Formation Preview - " .. self.formationNames[self.selectedFormation], 20, 20)
    
    -- Formation grid display
    self:drawFormationGrid(200, 100, 400, 400)
    
    -- Formation details (right side)
    local x = 650
    local y = 100
    
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, 280, 500)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, 280, 500)
    
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Formation Details", x + 10, y + 10)
    
    local formation = self.selectedFormation
    local details = {
        ["diamond"] = {
            positions = "1 center + 3 supporting",
            strength = "Flexible, good defense",
            weakness = "Lower firepower",
            radius = "3 hexes",
        },
        ["line"] = {
            positions = "4 in a line",
            strength = "Maximum firepower",
            weakness = "Linear, easy to flank",
            radius = "4 hexes wide",
        },
        ["wedge"] = {
            positions = "3-unit point + 1 support",
            strength = "Concentrated attack",
            weakness = "Vulnerable flanks",
            radius = "Narrow front",
        },
        ["column"] = {
            positions = "4 in column",
            strength = "Narrow profile",
            weakness = "Single-file movement",
            radius = "1 hex wide",
        },
    }
    
    local det = details[formation] or details.diamond
    
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.setFont(love.graphics.newFont(10))
    
    local infoY = y + 50
    love.graphics.print("Positions:", x + 10, infoY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(det.positions, x + 15, infoY + 18)
    
    infoY = infoY + 50
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Strength:", x + 10, infoY)
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(det.strength, x + 15, infoY + 18)
    
    infoY = infoY + 50
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Weakness:", x + 10, infoY)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print(det.weakness, x + 15, infoY + 18)
    
    infoY = infoY + 50
    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.print("Radius:", x + 10, infoY)
    love.graphics.setColor(0, 1, 1)
    love.graphics.print(det.radius, x + 15, infoY + 18)
end

--- Draw formation grid
function SquadManagementUI:drawFormationGrid(x, y, width, height)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Draw grid
    love.graphics.setColor(0.3, 0.3, 0.4)
    local cellSize = 40
    for gx = 0, width, cellSize do
        love.graphics.line(x + gx, y, x + gx, y + height)
    end
    for gy = 0, height, cellSize do
        love.graphics.line(x, y + gy, x + width, y + gy)
    end
    
    -- Draw unit positions based on formation
    local units = {}
    if self.selectedFormation == "diamond" then
        units = {
            {x = 5, y = 2, role = "LEADER"},
            {x = 4, y = 3, role = "HEAVY"},
            {x = 5, y = 3, role = "MEDIC"},
            {x = 6, y = 3, role = "SCOUT"},
        }
    elseif self.selectedFormation == "line" then
        units = {
            {x = 3, y = 3, role = "SCOUT"},
            {x = 4, y = 3, role = "LEADER"},
            {x = 5, y = 3, role = "MEDIC"},
            {x = 6, y = 3, role = "HEAVY"},
        }
    elseif self.selectedFormation == "wedge" then
        units = {
            {x = 5, y = 2, role = "LEADER"},
            {x = 4, y = 3, role = "HEAVY"},
            {x = 5, y = 3, role = "MEDIC"},
            {x = 6, y = 3, role = "SCOUT"},
        }
    elseif self.selectedFormation == "column" then
        units = {
            {x = 5, y = 2, role = "LEADER"},
            {x = 5, y = 3, role = "HEAVY"},
            {x = 5, y = 4, role = "MEDIC"},
            {x = 5, y = 5, role = "SCOUT"},
        }
    end
    
    for i, unit in ipairs(units) do
        local ux = x + unit.x * cellSize
        local uy = y + unit.y * cellSize
        
        local roleInfo = self:getRoleInfo(unit.role)
        love.graphics.setColor(roleInfo.color[1], roleInfo.color[2], roleInfo.color[3])
        love.graphics.circle("fill", ux + cellSize / 2, uy + cellSize / 2, 15)
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.printf(i, ux + cellSize / 4, uy + cellSize / 3, cellSize / 2, "center")
    end
end

--- Handle keyboard input
function SquadManagementUI:handleInput(key)
    if key == "tab" then
        if self.viewMode == "overview" then
            self.viewMode = "formation"
        else
            self.viewMode = "overview"
        end
    elseif key == "up" and self.viewMode == "overview" then
        self.selectedUnit = math.max(1, self.selectedUnit - 1)
    elseif key == "down" and self.viewMode == "overview" then
        self.selectedUnit = math.min(8, self.selectedUnit + 1)
    elseif key == "left" and self.viewMode == "formation" then
        local currentIndex = 1
        for i, f in ipairs(self.formations) do
            if f == self.selectedFormation then
                currentIndex = i
                break
            end
        end
        if currentIndex > 1 then
            self.selectedFormation = self.formations[currentIndex - 1]
        end
    elseif key == "right" and self.viewMode == "formation" then
        local currentIndex = 1
        for i, f in ipairs(self.formations) do
            if f == self.selectedFormation then
                currentIndex = i
                break
            end
        end
        if currentIndex < #self.formations then
            self.selectedFormation = self.formations[currentIndex + 1]
        end
    end
end

--- Main draw function
function SquadManagementUI:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    if self.viewMode == "overview" then
        self:drawOverview()
    elseif self.viewMode == "formation" then
        self:drawFormationView()
    end
    
    -- Footer
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("[TAB]Formation View  [↑↓]Select Unit  [←→]Formation  [ESC]Close", 10, 705)
end

return SquadManagementUI



