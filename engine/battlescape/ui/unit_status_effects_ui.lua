---Unit Status Effects UI - Visual Status Indicators
---
---Displays visual status effect icons above units (suppressed, wounded,
---stunned, burning, panicked, berserk). Icon-based system with tooltips
---for tactical awareness during battlescape missions.
---
---Supported Status Effects:
---  - SUPPRESSED: Yellow icon, reduced accuracy
---  - WOUNDED: Red icon, health damage
---  - STUNNED: Blue icon, action penalty
---  - BURNING: Orange icon, fire damage over time
---  - PANICKED: Purple icon, erratic behavior
---  - BERSERK: Dark red icon, increased aggression
---  - POISONED: Green icon, poison damage over time
---  - OVERWATCH: Blue icon, reaction fire ready
---
---Key Exports:
---  - UnitStatusEffectsUI.init(): Initialize status tracking
---  - UnitStatusEffectsUI.setStatus(unitId, status, active): Set status
---  - UnitStatusEffectsUI.hasStatus(unitId, status): Check status
---  - UnitStatusEffectsUI.draw(unitId, x, y, camera): Render status icons
---  - UnitStatusEffectsUI.getTooltip(unitId, status): Get status description
---
---Dependencies:
---  - Status effects system for status definitions
---  - Unit system for unit positions
---  - Camera system for screen coordinates
---
---@module battlescape.ui.unit_status_effects_ui
---@author UI Systems
---@license Open Source

local UnitStatusEffectsUI = {}

local CONFIG = {
    STATUS_EFFECTS = {
        SUPPRESSED = {icon = "S", color = {r=220,g=180,b=60}, label = "Suppressed"},
        WOUNDED = {icon = "W", color = {r=220,g=60,b=60}, label = "Wounded"},
        STUNNED = {icon = "Z", color = {r=100,g=100,b=200}, label = "Stunned"},
        BURNING = {icon = "F", color = {r=255,g=100,b=0}, label = "On Fire"},
        PANICKED = {icon = "P", color = {r=220,g=120,b=220}, label = "Panicked"},
        BERSERK = {icon = "B", color = {r=180,g=40,b=40}, label = "Berserk"},
        POISONED = {icon = "T", color = {r=120,g=220,b=60}, label = "Poisoned"},
        OVERWATCH = {icon = "O", color = {r=60,g=140,b=220}, label = "Overwatch"},
    },
    ICON_SIZE = 16,
    ICON_SPACING = 4,
    OFFSET_Y = -30,
}

local unitStatuses = {}  -- [unitId] = {SUPPRESSED=true, ...}

function UnitStatusEffectsUI.init()
    unitStatuses = {}
end

function UnitStatusEffectsUI.setStatus(unitId, status, active)
    if not unitStatuses[unitId] then unitStatuses[unitId] = {} end
    unitStatuses[unitId][status] = active
end

function UnitStatusEffectsUI.hasStatus(unitId, status)
    return unitStatuses[unitId] and unitStatuses[unitId][status]
end

function UnitStatusEffectsUI.draw(unitId, x, y, camera)
    if not unitStatuses[unitId] then return end
    
    local screenX = (x * 24 + camera.offsetX) * camera.zoom
    local screenY = (y * 24 + camera.offsetY + CONFIG.OFFSET_Y) * camera.zoom
    local iconX = screenX
    
    for status, active in pairs(unitStatuses[unitId]) do
        if active and CONFIG.STATUS_EFFECTS[status] then
            local effect = CONFIG.STATUS_EFFECTS[status]
            love.graphics.setColor(effect.color.r, effect.color.g, effect.color.b, 255)
            love.graphics.circle("fill", iconX, screenY, CONFIG.ICON_SIZE / 2)
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(effect.icon, iconX - 4, screenY - 6, 0, 0.8, 0.8)
            iconX = iconX + CONFIG.ICON_SIZE + CONFIG.ICON_SPACING
        end
    end
end

return UnitStatusEffectsUI






















