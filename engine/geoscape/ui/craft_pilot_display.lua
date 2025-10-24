--- Craft Pilot Display UI
---
--- Displays pilot information, ranks, XP, and craft bonuses in the geoscape.
--- Shows pilot roster, assignment status, and progression metrics.
---
--- Features:
--- - Pilot info panel with name, rank, insignia
--- - XP progress bar
--- - Assigned craft display
--- - Perk indicators
--- - Craft bonus breakdown
---
--- @module engine.geoscape.ui.craft_pilot_display
--- @author AlienFall Development Team

local PilotProgression = require("basescape.logic.pilot_progression")
local CraftPilotSystem = require("geoscape.logic.craft_pilot_system")
local PerkSystem = require("battlescape.systems.perks_system")

local CraftPilotDisplay = {}
CraftPilotDisplay.__index = CraftPilotDisplay

--- Panel dimensions
CraftPilotDisplay.PANEL_WIDTH = 300
CraftPilotDisplay.PANEL_HEIGHT = 200
CraftPilotDisplay.PADDING = 8
CraftPilotDisplay.LINE_HEIGHT = 20

--- Initialize display
---@return table Display instance
function CraftPilotDisplay:new()
    local self = setmetatable({}, CraftPilotDisplay)
    
    self.visible = false
    self.selectedPilot = nil
    self.targetX = 0
    self.targetY = 0
    
    return self
end

--- Show pilot panel
---@param pilot table Pilot unit
---@param x number Screen X
---@param y number Screen Y
---@return boolean Success
function CraftPilotDisplay:show(pilot, x, y)
    if not pilot then
        return false
    end
    
    self.visible = true
    self.selectedPilot = pilot
    self.targetX = x
    self.targetY = y
    
    print(string.format("[CraftPilotDisplay] Showing pilot: %s", pilot.name or "Unknown"))
    
    return true
end

--- Hide pilot panel
---@return boolean Success
function CraftPilotDisplay:hide()
    self.visible = false
    self.selectedPilot = nil
    return true
end

--- Draw pilot info panel
---@param pilot table Pilot unit
---@param x number Panel X
---@param y number Panel Y
---@return boolean Success
function CraftPilotDisplay:drawPilotPanel(pilot, x, y)
    if not pilot or not self.visible then
        return false
    end
    
    -- Panel background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, self.PANEL_WIDTH, self.PANEL_HEIGHT)
    love.graphics.setColor(0.5, 0.7, 1, 1)
    love.graphics.rectangle("line", x, y, self.PANEL_WIDTH, self.PANEL_HEIGHT)
    
    local lineY = y + self.PADDING
    
    -- Pilot name and rank
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(pilot.name or "Unknown Pilot", x + self.PADDING, lineY)
    lineY = lineY + self.LINE_HEIGHT
    
    -- Rank display
    local rank = PilotProgression.getRank(pilot.id) or 0
    local insignia = PilotProgression.getRankInsignia(pilot.id)
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print(string.format("Rank: %s", insignia.name or "Unknown"),
        x + self.PADDING, lineY)
    lineY = lineY + self.LINE_HEIGHT
    
    -- XP progress
    local xp = PilotProgression.getXP(pilot.id) or 0
    local totalXp = PilotProgression.getTotalXP(pilot.id) or 0
    love.graphics.setColor(0.5, 0.8, 0.5, 1)
    love.graphics.print(string.format("XP: %d/%d", xp, totalXp),
        x + self.PADDING, lineY)
    lineY = lineY + self.LINE_HEIGHT
    
    -- Missions flown
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print(string.format("Missions: %d", pilot.missions or 0),
        x + self.PADDING, lineY)
    lineY = lineY + self.LINE_HEIGHT
    
    -- Status
    local status = "Available"
    if pilot.assigned_craft then
        status = "Assigned"
    end
    love.graphics.setColor(status == "Available" and {0.5, 1, 0.5, 1} or {1, 0.7, 0.5, 1})
    love.graphics.print(string.format("Status: %s", status),
        x + self.PADDING, lineY)
    
    return true
end

--- Draw pilot roster (list of pilots)
---@param pilots table Array of pilot units
---@param x number List X
---@param y number List Y
---@param maxRows number Max rows to display
---@return boolean Success
function CraftPilotDisplay:drawRoster(pilots, x, y, maxRows)
    if not pilots or #pilots == 0 then
        return false
    end
    
    maxRows = maxRows or 6
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("=== PILOT ROSTER ===", x, y)
    
    y = y + self.LINE_HEIGHT
    
    for i = 1, math.min(maxRows, #pilots) do
        local pilot = pilots[i]
        if pilot then
            local rank = PilotProgression.getRank(pilot.id) or 0
            local xp = PilotProgression.getXP(pilot.id) or 0
            
            -- Rank indicator color
            if rank == 0 then
                love.graphics.setColor(0.5, 0.5, 0.5, 1)  -- Gray for rookie
            elseif rank == 1 then
                love.graphics.setColor(0.8, 0.8, 0.5, 1)  -- Yellow for veteran
            else
                love.graphics.setColor(1, 0.8, 0.5, 1)    -- Gold for ace
            end
            
            local status = pilot.assigned_craft and "[A]" or "[ ]"
            love.graphics.print(string.format("%s %s (Rank %d)", status, pilot.name or "?", rank), x, y)
            
            y = y + self.LINE_HEIGHT
        end
    end
    
    return true
end

--- Draw craft bonuses from pilot
---@param craft table Craft
---@param x number Display X
---@param y number Display Y
---@return boolean Success
function CraftPilotDisplay:drawCraftBonuses(craft, x, y)
    if not craft or not craft.pilots or #craft.pilots == 0 then
        return false
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("=== CRAFT BONUSES ===", x, y)
    
    y = y + self.LINE_HEIGHT
    
    -- Get pilot stats
    local pilotStats = {}
    for _, pilotId in ipairs(craft.pilots) do
        local stats = PilotProgression.getPilotStats(pilotId)
        table.insert(pilotStats, stats)
    end
    
    -- Calculate bonuses
    local bonuses = CraftPilotSystem.calculateCombinedBonuses(pilotStats)
    
    -- Display bonuses
    for stat, bonus in pairs(bonuses) do
        if bonus > 0 then
            love.graphics.setColor(0.5, 1, 0.5, 1)
            love.graphics.print(string.format("+%d%% %s", bonus, stat), x, y)
        else
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            love.graphics.print(string.format("%d%% %s", bonus, stat), x, y)
        end
        
        y = y + self.LINE_HEIGHT
    end
    
    return true
end

--- Format pilot card for display
---@param pilot table Pilot unit
---@return string Formatted card
function CraftPilotDisplay:formatCard(pilot)
    if not pilot then
        return "No pilot data"
    end
    
    local rank = PilotProgression.getRank(pilot.id) or 0
    local insignia = PilotProgression.getRankInsignia(pilot.id)
    local xp = PilotProgression.getXP(pilot.id) or 0
    
    return string.format("%s | %s | XP: %d | Missions: %d",
        pilot.name or "Unknown",
        insignia.name or "Rookie",
        xp,
        pilot.missions or 0)
end

--- Get tooltip for pilot
---@param pilot table Pilot unit
---@return string Tooltip text
function CraftPilotDisplay:getTooltip(pilot)
    if not pilot then
        return ""
    end
    
    local tooltip = "--- PILOT INFO ---\n"
    
    local rank = PilotProgression.getRank(pilot.id) or 0
    local insignia = PilotProgression.getRankInsignia(pilot.id)
    tooltip = tooltip .. string.format("Rank: %s (%d)\n", insignia.name or "Unknown", rank)
    
    local xp = PilotProgression.getXP(pilot.id) or 0
    tooltip = tooltip .. string.format("XP: %d\n", xp)
    
    tooltip = tooltip .. string.format("Missions: %d\n", pilot.missions or 0)
    tooltip = tooltip .. string.format("Kills: %d\n", pilot.kills or 0)
    
    -- Show perks
    local perks = PerkSystem.getActivePerks(pilot.id)
    if perks and #perks > 0 then
        tooltip = tooltip .. "\nPerks:\n"
        for _, perkId in ipairs(perks) do
            local perk = PerkSystem.getPerk(perkId)
            if perk then
                tooltip = tooltip .. string.format("• %s\n", perk.name or perkId)
            end
        end
    end
    
    return tooltip
end

--- Update display
---@param dt number Delta time
---@return boolean Updated
function CraftPilotDisplay:update(dt)
    -- Animation/state updates here if needed
    return true
end

--- Draw display
---@param dt number Delta time
---@return boolean Drawn
function CraftPilotDisplay:draw(dt)
    if not self.visible or not self.selectedPilot then
        return false
    end
    
    self:drawPilotPanel(self.selectedPilot, self.targetX, self.targetY)
    
    return true
end

return CraftPilotDisplay
