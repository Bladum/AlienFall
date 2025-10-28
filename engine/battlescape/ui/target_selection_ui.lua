---Target Selection UI - Visual Targeting System
---
---Implements visual targeting interface for tactical combat. Shows crosshair,
---hit chance calculation, body part selection, shot preview with line of sight,
---and cover indicators. Integrates with cover, flanking, and accuracy systems.
---
---Features:
---  - Crosshair overlay on target hex
---  - Hit chance percentage display
---  - Body part selection (head, torso, arms, legs)
---  - Shot line with LOS indicators
---  - Cover value display
---  - Flanking bonus indicators
---  - Range and accuracy modifiers
---  - Ammo type effects preview
---
---Integration:
---  - Call setAttacker() to set shooting unit
---  - Call setTarget() to set target unit
---  - Call calculateHitChance() for accuracy
---  - Call draw() to render targeting UI
---  - Call handleBodyPartSelection() for part targeting
---
---Key Exports:
---  - TargetSelectionUI.setAttacker(unit): Set attacking unit
---  - TargetSelectionUI.setTarget(unit): Set target unit
---  - TargetSelectionUI.calculateHitChance(): Calculate accuracy
---  - TargetSelectionUI.draw(): Render targeting interface
---  - TargetSelectionUI.handleBodyPartSelection(part): Handle part selection
---
---Dependencies:
---  - Accuracy system for hit calculations
---  - Cover system for cover bonuses
---  - LOS system for line of sight
---  - Unit system for unit data
---
---@module battlescape.ui.target_selection_ui
---@author UI Systems
---@license Open Source

local TargetSelectionUI = {}

-- Configuration
local CONFIG = {
    -- Crosshair
    CROSSHAIR_SIZE = 48,
    CROSSHAIR_COLOR = {r = 220, g = 60, b = 60, a = 200},
    CROSSHAIR_LINE_WIDTH = 2,
    
    -- Hit chance display
    HIT_CHANCE_OFFSET_Y = -60,
    HIT_CHANCE_FONT_SIZE = 24,
    HIT_CHANCE_COLORS = {
        VERY_HIGH = {r = 80, g = 220, b = 80, a = 255},    -- >80%
        HIGH = {r = 160, g = 200, b = 80, a = 255},        -- 60-80%
        MEDIUM = {r = 220, g = 180, b = 60, a = 255},      -- 40-60%
        LOW = {r = 220, g = 120, b = 60, a = 255},         -- 20-40%
        VERY_LOW = {r = 220, g = 60, b = 60, a = 255},     -- <20%
    },
    
    -- Body part selection
    BODY_PARTS = {
        {id = "HEAD", label = "Head", accuracyMod = -20, damageMod = 1.5, chance = 10},
        {id = "TORSO", label = "Torso", accuracyMod = 0, damageMod = 1.0, chance = 50},
        {id = "ARMS", label = "Arms", accuracyMod = -10, damageMod = 0.7, chance = 20},
        {id = "LEGS", label = "Legs", accuracyMod = -10, damageMod = 0.7, chance = 20},
    },
    BODY_PART_PANEL_WIDTH = 240,
    BODY_PART_PANEL_HEIGHT = 200,
    
    -- Shot line
    SHOT_LINE_COLOR = {r = 220, g = 180, b = 60, a = 150},
    SHOT_LINE_BLOCKED_COLOR = {r = 220, g = 60, b = 60, a = 150},
    SHOT_LINE_WIDTH = 2,
    
    -- Cover indicator
    COVER_BAR_WIDTH = 60,
    COVER_BAR_HEIGHT = 8,
    COVER_COLOR = {r = 100, g = 100, b = 200, a = 200},
    
    -- Modifier display
    MODIFIER_PANEL_X = 720,
    MODIFIER_PANEL_Y = 100,
    MODIFIER_PANEL_WIDTH = 220,
    MODIFIER_LINE_HEIGHT = 20,
    
    -- Colors
    TEXT_COLOR = {r = 220, g = 220, b = 230, a = 255},
    POSITIVE_COLOR = {r = 80, g = 220, b = 80, a = 255},
    NEGATIVE_COLOR = {r = 220, g = 60, b = 60, a = 255},
    NEUTRAL_COLOR = {r = 200, g = 200, b = 200, a = 255},
}

-- Targeting state
local targetState = {
    attacker = nil,             -- Attacking unit data
    target = nil,               -- Target unit data
    selectedBodyPart = "TORSO", -- Selected body part
    hitChance = 0,              -- Calculated hit chance
    modifiers = {},             -- Accuracy modifiers
    losBlocked = false,         -- Line of sight blocked
    showModifiers = false,      -- Show detailed modifiers
}

--[[
    Initialize targeting UI
]]
function TargetSelectionUI.init()
    targetState = {
        attacker = nil,
        target = nil,
        selectedBodyPart = "TORSO",
        hitChance = 0,
        modifiers = {},
        losBlocked = false,
        showModifiers = false,
    }
    print("[TargetSelectionUI] Targeting UI initialized")
end

--[[
    Set attacker unit
    
    @param unit: Attacker unit data { id, x, y, accuracy, weapon }
]]
function TargetSelectionUI.setAttacker(unit)
    targetState.attacker = unit
    if unit and targetState.target then
        TargetSelectionUI.calculateHitChance()
    end
end

--[[
    Set target unit
    
    @param unit: Target unit data { id, x, y, cover, facing }
]]
function TargetSelectionUI.setTarget(unit)
    targetState.target = unit
    if unit and targetState.attacker then
        TargetSelectionUI.calculateHitChance()
    end
end

--[[
    Clear targeting
]]
function TargetSelectionUI.clearTarget()
    targetState.target = nil
    targetState.hitChance = 0
    targetState.modifiers = {}
end

--[[
    Set selected body part
    
    @param bodyPartId: Body part ID (HEAD, TORSO, ARMS, LEGS)
]]
function TargetSelectionUI.setBodyPart(bodyPartId)
    targetState.selectedBodyPart = bodyPartId
    if targetState.attacker and targetState.target then
        TargetSelectionUI.calculateHitChance()
    end
    print(string.format("[TargetSelectionUI] Body part selected: %s", bodyPartId))
end

--[[
    Get selected body part
    
    @return bodyPartId
]]
function TargetSelectionUI.getSelectedBodyPart()
    return targetState.selectedBodyPart
end

--[[
    Calculate hit chance with all modifiers
    
    @return hitChance: 0-100
]]
function TargetSelectionUI.calculateHitChance()
    if not targetState.attacker or not targetState.target then
        return 0
    end
    
    local attacker = targetState.attacker
    local target = targetState.target
    local modifiers = {}
    
    -- Base accuracy (from weapon + unit skill)
    local baseAccuracy = (attacker.weapon and attacker.weapon.accuracy or 70) + (attacker.accuracy or 0)
    table.insert(modifiers, {label = "Base Accuracy", value = baseAccuracy})
    
    -- Body part modifier
    local bodyPart = nil
    for _, part in ipairs(CONFIG.BODY_PARTS) do
        if part.id == targetState.selectedBodyPart then
            bodyPart = part
            break
        end
    end
    if bodyPart and bodyPart.accuracyMod ~= 0 then
        table.insert(modifiers, {label = bodyPart.label .. " Target", value = bodyPart.accuracyMod})
    end
    
    -- Range modifier (placeholder - would integrate with weapon range)
    local distance = math.sqrt((target.x - attacker.x)^2 + (target.y - attacker.y)^2)
    local rangeMod = 0
    if distance > 15 then
        rangeMod = -10 * math.floor((distance - 15) / 5)
        table.insert(modifiers, {label = "Range Penalty", value = rangeMod})
    end
    
    -- Cover modifier (would integrate with cover system)
    if target.cover and target.cover > 0 then
        local coverPenalty = math.floor(target.cover * 0.4)  -- 40% of cover value
        table.insert(modifiers, {label = "Cover Penalty", value = -coverPenalty})
    end
    
    -- Flanking bonus (would integrate with flanking system)
    if target.flanked then
        table.insert(modifiers, {label = "Flanking Bonus", value = 25})
    end
    
    -- Suppression penalty (would integrate with suppression system)
    if attacker.suppressed then
        table.insert(modifiers, {label = "Suppressed", value = -30})
    end
    
    -- Calculate total
    local totalAccuracy = baseAccuracy
    for _, mod in ipairs(modifiers) do
        if mod.label ~= "Base Accuracy" then
            totalAccuracy = totalAccuracy + mod.value
        end
    end
    
    -- Clamp to 5-95%
    totalAccuracy = math.max(5, math.min(95, totalAccuracy))
    
    targetState.hitChance = totalAccuracy
    targetState.modifiers = modifiers
    
    print(string.format("[TargetSelectionUI] Hit chance: %d%% (base %d, mods %d)",
        totalAccuracy, baseAccuracy, totalAccuracy - baseAccuracy))
    
    return totalAccuracy
end

--[[
    Get hit chance color based on percentage
    
    @param chance: Hit chance 0-100
    @return color table
]]
function TargetSelectionUI.getHitChanceColor(chance)
    if chance >= 80 then
        return CONFIG.HIT_CHANCE_COLORS.VERY_HIGH
    elseif chance >= 60 then
        return CONFIG.HIT_CHANCE_COLORS.HIGH
    elseif chance >= 40 then
        return CONFIG.HIT_CHANCE_COLORS.MEDIUM
    elseif chance >= 20 then
        return CONFIG.HIT_CHANCE_COLORS.LOW
    else
        return CONFIG.HIT_CHANCE_COLORS.VERY_LOW
    end
end

--[[
    Draw targeting UI
    
    @param camera: Camera transform { offsetX, offsetY, zoom }
]]
function TargetSelectionUI.draw(camera)
    if not targetState.target then return end
    
    -- Draw shot line
    if targetState.attacker then
        TargetSelectionUI.drawShotLine(camera)
    end
    
    -- Draw crosshair
    TargetSelectionUI.drawCrosshair(camera)
    
    -- Draw hit chance
    TargetSelectionUI.drawHitChance(camera)
    
    -- Draw cover indicator
    TargetSelectionUI.drawCoverIndicator(camera)
    
    -- Draw modifiers panel (if enabled)
    if targetState.showModifiers then
        TargetSelectionUI.drawModifiersPanel()
    end
end

--[[
    Draw crosshair on target
    
    @param camera: Camera transform
]]
function TargetSelectionUI.drawCrosshair(camera)
    local target = targetState.target
    local screenX = (target.x * 24 + camera.offsetX) * camera.zoom
    local screenY = (target.y * 24 + camera.offsetY) * camera.zoom
    local size = CONFIG.CROSSHAIR_SIZE * camera.zoom
    
    love.graphics.setColor(CONFIG.CROSSHAIR_COLOR.r, CONFIG.CROSSHAIR_COLOR.g,
        CONFIG.CROSSHAIR_COLOR.b, CONFIG.CROSSHAIR_COLOR.a)
    love.graphics.setLineWidth(CONFIG.CROSSHAIR_LINE_WIDTH)
    
    -- Horizontal line
    love.graphics.line(screenX - size/2, screenY, screenX + size/2, screenY)
    -- Vertical line
    love.graphics.line(screenX, screenY - size/2, screenX, screenY + size/2)
    
    -- Corner brackets
    local bracketSize = size / 4
    -- Top-left
    love.graphics.line(screenX - size/2, screenY - size/2, screenX - size/2 + bracketSize, screenY - size/2)
    love.graphics.line(screenX - size/2, screenY - size/2, screenX - size/2, screenY - size/2 + bracketSize)
    -- Top-right
    love.graphics.line(screenX + size/2, screenY - size/2, screenX + size/2 - bracketSize, screenY - size/2)
    love.graphics.line(screenX + size/2, screenY - size/2, screenX + size/2, screenY - size/2 + bracketSize)
    -- Bottom-left
    love.graphics.line(screenX - size/2, screenY + size/2, screenX - size/2 + bracketSize, screenY + size/2)
    love.graphics.line(screenX - size/2, screenY + size/2, screenX - size/2, screenY + size/2 - bracketSize)
    -- Bottom-right
    love.graphics.line(screenX + size/2, screenY + size/2, screenX + size/2 - bracketSize, screenY + size/2)
    love.graphics.line(screenX + size/2, screenY + size/2, screenX + size/2, screenY + size/2 - bracketSize)
end

--[[
    Draw hit chance percentage
    
    @param camera: Camera transform
]]
function TargetSelectionUI.drawHitChance(camera)
    local target = targetState.target
    local screenX = (target.x * 24 + camera.offsetX) * camera.zoom
    local screenY = (target.y * 24 + camera.offsetY) * camera.zoom + CONFIG.HIT_CHANCE_OFFSET_Y
    
    local chanceText = string.format("%d%%", targetState.hitChance)
    local color = TargetSelectionUI.getHitChanceColor(targetState.hitChance)
    
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    local textWidth = love.graphics.getFont():getWidth(chanceText)
    love.graphics.print(chanceText, screenX - textWidth/2, screenY, 0, 1.5, 1.5)
end

--[[
    Draw shot line from attacker to target
    
    @param camera: Camera transform
]]
function TargetSelectionUI.drawShotLine(camera)
    local attacker = targetState.attacker
    local target = targetState.target
    
    local x1 = (attacker.x * 24 + camera.offsetX) * camera.zoom
    local y1 = (attacker.y * 24 + camera.offsetY) * camera.zoom
    local x2 = (target.x * 24 + camera.offsetX) * camera.zoom
    local y2 = (target.y * 24 + camera.offsetY) * camera.zoom
    
    local color = targetState.losBlocked and CONFIG.SHOT_LINE_BLOCKED_COLOR or CONFIG.SHOT_LINE_COLOR
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.setLineWidth(CONFIG.SHOT_LINE_WIDTH)
    love.graphics.line(x1, y1, x2, y2)
end

--[[
    Draw cover indicator
    
    @param camera: Camera transform
]]
function TargetSelectionUI.drawCoverIndicator(camera)
    local target = targetState.target
    if not target.cover or target.cover == 0 then return end
    
    local screenX = (target.x * 24 + camera.offsetX) * camera.zoom
    local screenY = (target.y * 24 + camera.offsetY) * camera.zoom + 30
    
    local coverPercent = target.cover / 100
    
    -- Background
    love.graphics.setColor(40, 40, 50, 200)
    love.graphics.rectangle("fill", screenX - CONFIG.COVER_BAR_WIDTH/2, screenY,
        CONFIG.COVER_BAR_WIDTH, CONFIG.COVER_BAR_HEIGHT)
    
    -- Fill
    love.graphics.setColor(CONFIG.COVER_COLOR.r, CONFIG.COVER_COLOR.g,
        CONFIG.COVER_COLOR.b, CONFIG.COVER_COLOR.a)
    love.graphics.rectangle("fill", screenX - CONFIG.COVER_BAR_WIDTH/2, screenY,
        CONFIG.COVER_BAR_WIDTH * coverPercent, CONFIG.COVER_BAR_HEIGHT)
    
    -- Border
    love.graphics.setColor(100, 100, 120, 255)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", screenX - CONFIG.COVER_BAR_WIDTH/2, screenY,
        CONFIG.COVER_BAR_WIDTH, CONFIG.COVER_BAR_HEIGHT)
end

--[[
    Draw modifiers panel
]]
function TargetSelectionUI.drawModifiersPanel()
    local x = CONFIG.MODIFIER_PANEL_X
    local y = CONFIG.MODIFIER_PANEL_Y
    local width = CONFIG.MODIFIER_PANEL_WIDTH
    
    -- Background
    love.graphics.setColor(20, 20, 30, 220)
    local height = (#targetState.modifiers + 2) * CONFIG.MODIFIER_LINE_HEIGHT + 20
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Border
    love.graphics.setColor(100, 100, 120, 255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Title
    love.graphics.setColor(CONFIG.TEXT_COLOR.r, CONFIG.TEXT_COLOR.g,
        CONFIG.TEXT_COLOR.b, CONFIG.TEXT_COLOR.a)
    love.graphics.print("Accuracy Modifiers", x + 10, y + 10)
    
    -- Modifiers
    local offsetY = y + 35
    for _, mod in ipairs(targetState.modifiers) do
        local color = mod.value > 0 and CONFIG.POSITIVE_COLOR or
                     mod.value < 0 and CONFIG.NEGATIVE_COLOR or
                     CONFIG.NEUTRAL_COLOR
        
        love.graphics.setColor(CONFIG.TEXT_COLOR.r, CONFIG.TEXT_COLOR.g,
            CONFIG.TEXT_COLOR.b, CONFIG.TEXT_COLOR.a)
        love.graphics.print(mod.label, x + 10, offsetY, 0, 0.9, 0.9)
        
        love.graphics.setColor(color.r, color.g, color.b, color.a)
        local valueText = (mod.value >= 0 and "+" or "") .. tostring(mod.value)
        local valueWidth = love.graphics.getFont():getWidth(valueText)
        love.graphics.print(valueText, x + width - valueWidth - 10, offsetY, 0, 0.9, 0.9)
        
        offsetY = offsetY + CONFIG.MODIFIER_LINE_HEIGHT
    end
    
    -- Total
    love.graphics.setColor(CONFIG.TEXT_COLOR.r, CONFIG.TEXT_COLOR.g,
        CONFIG.TEXT_COLOR.b, CONFIG.TEXT_COLOR.a)
    love.graphics.print("Total Hit Chance", x + 10, offsetY + 5)
    
    local totalColor = TargetSelectionUI.getHitChanceColor(targetState.hitChance)
    love.graphics.setColor(totalColor.r, totalColor.g, totalColor.b, totalColor.a)
    local totalText = string.format("%d%%", targetState.hitChance)
    local totalWidth = love.graphics.getFont():getWidth(totalText)
    love.graphics.print(totalText, x + width - totalWidth - 10, offsetY + 5)
end

--[[
    Toggle modifiers panel display
]]
function TargetSelectionUI.toggleModifiers()
    targetState.showModifiers = not targetState.showModifiers
end

--[[
    Draw body part selection panel
    
    @param x, y: Panel position
]]
function TargetSelectionUI.drawBodyPartPanel(x, y)
    local width = CONFIG.BODY_PART_PANEL_WIDTH
    local height = CONFIG.BODY_PART_PANEL_HEIGHT
    
    -- Background
    love.graphics.setColor(20, 20, 30, 220)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Border
    love.graphics.setColor(100, 100, 120, 255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Title
    love.graphics.setColor(CONFIG.TEXT_COLOR.r, CONFIG.TEXT_COLOR.g,
        CONFIG.TEXT_COLOR.b, CONFIG.TEXT_COLOR.a)
    love.graphics.print("Select Body Part", x + 10, y + 10)
    
    -- Body parts
    local offsetY = y + 40
    for _, part in ipairs(CONFIG.BODY_PARTS) do
        local isSelected = part.id == targetState.selectedBodyPart
        
        if isSelected then
            love.graphics.setColor(80, 80, 110, 255)
            love.graphics.rectangle("fill", x + 5, offsetY - 2, width - 10, 24)
        end
        
        love.graphics.setColor(CONFIG.TEXT_COLOR.r, CONFIG.TEXT_COLOR.g,
            CONFIG.TEXT_COLOR.b, CONFIG.TEXT_COLOR.a)
        love.graphics.print(string.format("%s (%d%% chance)", part.label, part.chance),
            x + 15, offsetY)
        
        -- Modifiers
        love.graphics.print(string.format("Acc: %+d   Dmg: %.1fx",
            part.accuracyMod, part.damageMod),
            x + 15, offsetY + 18, 0, 0.8, 0.8)
        
        offsetY = offsetY + 40
    end
end

--[[
    Get targeting state for debugging
    
    @return targetState table
]]
function TargetSelectionUI.getState()
    return targetState
end

return TargetSelectionUI


























