-- Interception Combat UI System
-- Displays craft vs UFO combat in real-time turn-based format
-- Shows targeting, altitude, weapons status, and tactical options

local InterceptionCombatUI = {}
InterceptionCombatUI.__index = InterceptionCombatUI

-- Initialize combat UI system
function InterceptionCombatUI.new()
    local self = setmetatable({}, InterceptionCombatUI)
    
    self.screenWidth = 960
    self.screenHeight = 720
    self.gridSize = 24
    
    -- UI Panels
    self.craftPanel = {
        x = 10, y = 10,
        width = 300, height = 280,
        title = "YOUR CRAFT",
        visible = true
    }
    
    self.targetPanel = {
        x = 10, y = 300,
        width = 300, height = 150,
        title = "TARGET",
        visible = true
    }
    
    self.weaponPanel = {
        x = 320, y = 10,
        width = 320, height = 280,
        title = "WEAPONS STATUS",
        visible = true
    }
    
    self.tacticsPanel = {
        x = 320, y = 300,
        width = 320, height = 150,
        title = "TACTICAL OPTIONS",
        visible = true
    }
    
    self.altitudePanel = {
        x = 650, y = 10,
        width = 300, height = 280,
        title = "ALTITUDE DISPLAY",
        visible = true
    }
    
    self.combatLogPanel = {
        x = 650, y = 300,
        width = 300, height = 150,
        title = "COMBAT LOG",
        visible = true,
        messages = {},
        maxMessages = 8
    }
    
    return self
end

-- Draw entire UI
function InterceptionCombatUI:draw(craftData, targetData)
    -- Draw panels
    self:drawCraftPanel(craftData)
    self:drawTargetPanel(targetData)
    self:drawWeaponPanel(craftData)
    self:drawTacticsPanel()
    self:drawAltitudePanel(craftData, targetData)
    self:drawCombatLogPanel()
end

-- Draw craft information panel
function InterceptionCombatUI:drawCraftPanel(craftData)
    local panel = self.craftPanel
    
    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Panel border
    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(panel.title, panel.x + 5, panel.y + 5, panel.width - 10, "left")
    
    -- Craft info
    local yOffset = panel.y + 25
    local lineHeight = 20
    local info = {
        { label = "Type:", value = craftData.type or "INTERCEPTOR" },
        { label = "Health:", value = craftData.health .. "/" .. craftData.maxHealth },
        { label = "Armor:", value = craftData.armor .. "%" },
        { label = "Fuel:", value = craftData.fuel .. "/" .. craftData.fuelCapacity },
        { label = "Position:", value = "X:" .. craftData.x .. " Y:" .. craftData.y },
        { label = "Heading:", value = craftData.heading .. "°" },
        { label = "Speed:", value = craftData.speed .. " kph" },
        { label = "Status:", value = craftData.status or "READY" }
    }
    
    for _, line in ipairs(info) do
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf(line.label, panel.x + 10, yOffset, 70, "left")
        
        -- Color status based on value
        if line.label == "Status:" then
            if line.value == "DAMAGED" then
                love.graphics.setColor(1, 0.3, 0.3)
            elseif line.value == "READY" then
                love.graphics.setColor(0.3, 1, 0.3)
            else
                love.graphics.setColor(1, 1, 0)
            end
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.printf(line.value, panel.x + 85, yOffset, panel.width - 95, "left")
        yOffset = yOffset + lineHeight
    end
end

-- Draw target information panel
function InterceptionCombatUI:drawTargetPanel(targetData)
    local panel = self.targetPanel
    
    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Panel border
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(panel.title, panel.x + 5, panel.y + 5, panel.width - 10, "left")
    
    -- Target info
    local yOffset = panel.y + 25
    local lineHeight = 16
    local info = {
        { label = "Type:", value = targetData.type or "UFO" },
        { label = "Class:", value = targetData.class or "UNKNOWN" },
        { label = "Health:", value = targetData.health .. "/" .. targetData.maxHealth },
        { label = "Distance:", value = targetData.distance .. " km" },
        { label = "Heading:", value = targetData.heading .. "°" },
        { label = "Speed:", value = targetData.speed .. " kph" }
    }
    
    for _, line in ipairs(info) do
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf(line.label, panel.x + 10, yOffset, 70, "left")
        love.graphics.setColor(1, 0.5, 0.5)
        love.graphics.printf(line.value, panel.x + 85, yOffset, panel.width - 95, "left")
        yOffset = yOffset + lineHeight
    end
end

-- Draw weapon status panel
function InterceptionCombatUI:drawWeaponPanel(craftData)
    local panel = self.weaponPanel
    
    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Panel border
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(panel.title, panel.x + 5, panel.y + 5, panel.width - 10, "left")
    
    -- Weapons
    local yOffset = panel.y + 25
    local lineHeight = 32
    local weapons = craftData.weapons or {}
    
    for i, weapon in ipairs(weapons) do
        if yOffset + lineHeight <= panel.y + panel.height - 10 then
            -- Weapon name
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(weapon.name, panel.x + 10, yOffset, panel.width - 20, "left")
            
            -- Ammo bar
            local barWidth = panel.width - 20
            local barHeight = 10
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", panel.x + 10, yOffset + 16, barWidth, barHeight)
            
            -- Ammo fill
            local ammoPercent = weapon.ammo / weapon.maxAmmo
            if ammoPercent > 0.5 then
                love.graphics.setColor(0.3, 1, 0.3)
            elseif ammoPercent > 0.2 then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 0.3, 0.3)
            end
            love.graphics.rectangle("fill", panel.x + 10, yOffset + 16, barWidth * ammoPercent, barHeight)
            
            -- Ammo text
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.printf(weapon.ammo .. "/" .. weapon.maxAmmo, panel.x + 10, yOffset + 18, barWidth - 5, "right")
            
            yOffset = yOffset + lineHeight
        end
    end
end

-- Draw tactical options panel
function InterceptionCombatUI:drawTacticsPanel()
    local panel = self.tacticsPanel
    
    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Panel border
    love.graphics.setColor(1, 1, 0.3)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(panel.title, panel.x + 5, panel.y + 5, panel.width - 10, "left")
    
    -- Options (buttons)
    local yOffset = panel.y + 25
    local lineHeight = 18
    local options = {
        "[ F ] Fire Weapon",
        "[ A ] Ascend Altitude",
        "[ D ] Descend Altitude",
        "[ E ] Evade Maneuver",
        "[ R ] Repair Systems",
        "[ F ] Flee Combat"
    }
    
    for _, option in ipairs(options) do
        love.graphics.setColor(0.3, 1, 0.7)
        love.graphics.printf(option, panel.x + 10, yOffset, panel.width - 20, "left")
        yOffset = yOffset + lineHeight
    end
end

-- Draw altitude display panel
function InterceptionCombatUI:drawAltitudePanel(craftData, targetData)
    local panel = self.altitudePanel
    
    -- Panel background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Panel border
    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(panel.title, panel.x + 5, panel.y + 5, panel.width - 10, "left")
    
    -- Altitude scale (left side - craft, right side - target)
    local scaleHeight = 180
    local scaleX1 = panel.x + 30
    local scaleX2 = panel.x + 200
    local scaleY = panel.y + 40
    
    -- Draw altitude scales
    love.graphics.setColor(0.3, 0.5, 0.8)
    love.graphics.line(scaleX1, scaleY, scaleX1, scaleY + scaleHeight)
    love.graphics.line(scaleX2, scaleY, scaleX2, scaleY + scaleHeight)
    
    -- Maximum altitude markers
    local maxAltitude = 30000
    local craftAltitude = craftData.altitude or 15000
    local targetAltitude = targetData.altitude or 20000
    
    -- Craft altitude indicator
    love.graphics.setColor(0.3, 1, 0.3)
    local craftY = scaleY + scaleHeight - (craftAltitude / maxAltitude) * scaleHeight
    love.graphics.circle("fill", scaleX1, craftY, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(craftAltitude .. "m", scaleX1 - 40, craftY - 10, 35, "center")
    
    -- Target altitude indicator
    love.graphics.setColor(1, 0.3, 0.3)
    local targetY = scaleY + scaleHeight - (targetAltitude / maxAltitude) * scaleHeight
    love.graphics.circle("fill", scaleX2, targetY, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(targetAltitude .. "m", scaleX2 - 40, targetY - 10, 35, "center")
    
    -- Labels
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("YOUR CRAFT", panel.x + 5, panel.y + 230, 60, "center")
    love.graphics.printf("TARGET", panel.x + 170, panel.y + 230, 60, "center")
end

-- Draw combat log panel
function InterceptionCombatUI:drawCombatLogPanel()
    local panel = self.combatLogPanel
    
    -- Panel background
    love.graphics.setColor(0.05, 0.05, 0.05)
    love.graphics.rectangle("fill", panel.x, panel.y, panel.width, panel.height)
    
    -- Panel border
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", panel.x, panel.y, panel.width, panel.height)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(panel.title, panel.x + 5, panel.y + 5, panel.width - 10, "left")
    
    -- Messages
    local yOffset = panel.y + 25
    local lineHeight = 14
    
    for i, message in ipairs(panel.messages) do
        if i > panel.maxMessages - 8 then -- Show last 8 messages
            love.graphics.setColor(message.color or {0.7, 0.7, 0.7})
            local msgText = message.text:sub(1, 45) -- Truncate long messages
            love.graphics.printf(msgText, panel.x + 5, yOffset, panel.width - 10, "left")
            yOffset = yOffset + lineHeight
        end
    end
end

-- Add message to combat log
function InterceptionCombatUI:addCombatLog(message, color)
    table.insert(self.combatLogPanel.messages, {
        text = message,
        color = color or {0.7, 0.7, 0.7}
    })
end

-- Update UI with new combat data
function InterceptionCombatUI:update(craftData, targetData, deltaTime)
    -- Update any animations or transitions here
end

-- Handle input for tactical actions
function InterceptionCombatUI:handleInput(key)
    local action = nil
    
    if key == "f" then
        action = "FIRE"
    elseif key == "a" then
        action = "ASCEND"
    elseif key == "d" then
        action = "DESCEND"
    elseif key == "e" then
        action = "EVADE"
    elseif key == "r" then
        action = "REPAIR"
    elseif key == "escape" then
        action = "FLEE"
    end
    
    return action
end

return InterceptionCombatUI
