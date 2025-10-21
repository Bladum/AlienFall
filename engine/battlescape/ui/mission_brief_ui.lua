---MissionBriefUI - Pre-Mission Briefing and Deployment Screen
---
---Displays comprehensive mission information before soldier deployment including objectives,
---enemy intelligence, terrain details, rewards, and threat assessment. Allows players to
---review mission details and make final deployment decisions. Part of mission setup and
---deployment systems (Batch 8).
---
---Features:
---  - Mission objectives and requirements
---  - Enemy force composition and threat level
---  - Terrain and environmental conditions
---  - Reward structure (experience, items, funding)
---  - Deployment confirmation with accept/abort options
---  - Color-coded threat level indicators
---  - Scrollable content for detailed briefings
---
---Key Exports:
---  - init(): Initialize/reset the UI state
---  - show(missionData, onAccept, onAbort): Display mission briefing
---  - hide(): Hide the briefing screen
---  - isVisible(): Check if UI is currently visible
---  - update(dt): Update animations and hover states
---  - draw(): Render the mission briefing interface
---  - mousepressed(x, y, button): Handle mouse input
---  - keypressed(key): Handle keyboard input (A to accept, ESC to abort)
---
---Dependencies:
---  - require("widgets"): UI widget library for panels and buttons
---
---@module battlescape.ui.mission_brief_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MissionBriefUI = require("battlescape.ui.mission_brief_ui")
---  MissionBriefUI.init()
---  MissionBriefUI.show(missionData, onAcceptCallback, onAbortCallback)
---
---@see battlescape.ui.squad_selection_ui For squad assignment after briefing
---@see battlescape.ui.loadout_management_ui For equipment selection after briefing

-- Mission Brief UI System
-- Displays mission objectives, enemy intel, rewards before deployment
-- Part of Batch 8: Mission Setup & Deployment Systems

local MissionBriefUI = {}

-- Configuration
local PANEL_WIDTH = 600
local PANEL_HEIGHT = 480
local PANEL_X = (960 - PANEL_WIDTH) / 2  -- Centered horizontally
local PANEL_Y = (720 - PANEL_HEIGHT) / 2  -- Centered vertically
local PADDING = 12
local LINE_HEIGHT = 18
local SECTION_SPACING = 24

-- Colors (matching theme)
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    OBJECTIVE_PRIMARY = {r=255, g=200, b=60},
    OBJECTIVE_SECONDARY = {r=180, g=200, b=255},
    ENEMY_LOW = {r=100, g=220, b=100},
    ENEMY_MEDIUM = {r=255, g=200, b=60},
    ENEMY_HIGH = {r=255, g=80, b=60},
    REWARD = {r=100, g=220, b=100},
    PENALTY = {r=255, g=100, b=80},
    BUTTON_ACCEPT = {r=60, g=160, b=60},
    BUTTON_ABORT = {r=180, g=60, b=60},
    BUTTON_HOVER = {r=120, g=180, b=220}
}

-- Button definitions
local BUTTONS = {
    ACCEPT = {
        x = PANEL_X + PANEL_WIDTH - 144 - PADDING,
        y = PANEL_Y + PANEL_HEIGHT - 48 - PADDING,
        width = 144,
        height = 48,
        label = "ACCEPT MISSION",
        hotkey = "A"
    },
    ABORT = {
        x = PANEL_X + PADDING,
        y = PANEL_Y + PANEL_HEIGHT - 48 - PADDING,
        width = 144,
        height = 48,
        label = "ABORT",
        hotkey = "ESC"
    }
}

-- Mission data state
local missionData = nil
local visible = false
local hoveredButton = nil
local acceptCallback = nil
local abortCallback = nil

-- Threat level display strings
local THREAT_LABELS = {
    LOW = "Low Threat",
    MEDIUM = "Medium Threat",
    HIGH = "High Threat",
    EXTREME = "Extreme Threat"
}

-- Threat level colors
local THREAT_COLORS = {
    LOW = COLORS.ENEMY_LOW,
    MEDIUM = COLORS.ENEMY_MEDIUM,
    HIGH = COLORS.ENEMY_HIGH,
    EXTREME = COLORS.PENALTY
}

--- Initialize the mission brief UI
function MissionBriefUI.init()
    missionData = nil
    visible = false
    hoveredButton = nil
    acceptCallback = nil
    abortCallback = nil
end

--- Show mission brief with data
-- @param mission Table with: name, objectives[], enemyFaction, threatLevel, biome, terrain, rewards{}, penalties{}, mapSize
-- @param onAccept Function to call when accept button clicked
-- @param onAbort Function to call when abort button clicked
function MissionBriefUI.show(mission, onAccept, onAbort)
    missionData = mission
    visible = true
    acceptCallback = onAccept
    abortCallback = onAbort
end

--- Hide mission brief
function MissionBriefUI.hide()
    visible = false
    missionData = nil
    hoveredButton = nil
end

--- Check if mission brief is visible
function MissionBriefUI.isVisible()
    return visible
end

--- Draw the mission brief UI
function MissionBriefUI.draw()
    if not visible or not missionData then return end
    
    -- Panel background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, COLORS.BACKGROUND.a/255)
    love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Panel border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    local yPos = PANEL_Y + PADDING
    
    -- Mission name header
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("MISSION BRIEFING", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print(missionData.name or "Unknown Mission", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + SECTION_SPACING
    
    -- Objectives section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("OBJECTIVES:", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if missionData.objectives then
        for i, obj in ipairs(missionData.objectives) do
            local color = obj.type == "PRIMARY" and COLORS.OBJECTIVE_PRIMARY or COLORS.OBJECTIVE_SECONDARY
            love.graphics.setColor(color.r/255, color.g/255, color.b/255)
            local prefix = obj.type == "PRIMARY" and "[PRIMARY] " or "[SECONDARY] "
            love.graphics.print(prefix .. obj.description, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    end
    yPos = yPos + SECTION_SPACING
    
    -- Enemy intel section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("ENEMY INTEL:", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Faction: " .. (missionData.enemyFaction or "Unknown"), PANEL_X + PADDING + 12, yPos)
    yPos = yPos + LINE_HEIGHT
    
    local threatLevel = missionData.threatLevel or "MEDIUM"
    local threatColor = THREAT_COLORS[threatLevel]
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Threat Level: ", PANEL_X + PADDING + 12, yPos)
    love.graphics.setColor(threatColor.r/255, threatColor.g/255, threatColor.b/255)
    love.graphics.print(THREAT_LABELS[threatLevel], PANEL_X + PADDING + 12 + 120, yPos)
    yPos = yPos + LINE_HEIGHT + SECTION_SPACING
    
    -- Map preview section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("MAP INFO:", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("Biome: " .. (missionData.biome or "Unknown"), PANEL_X + PADDING + 12, yPos)
    yPos = yPos + LINE_HEIGHT
    love.graphics.print("Terrain: " .. (missionData.terrain or "Unknown"), PANEL_X + PADDING + 12, yPos)
    yPos = yPos + LINE_HEIGHT
    love.graphics.print("Map Size: " .. (missionData.mapSize or "Medium") .. " (" .. (missionData.gridSize or "5x5") .. " blocks)", PANEL_X + PADDING + 12, yPos)
    yPos = yPos + LINE_HEIGHT + SECTION_SPACING
    
    -- Rewards section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("REWARDS:", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if missionData.rewards then
        love.graphics.setColor(COLORS.REWARD.r/255, COLORS.REWARD.g/255, COLORS.REWARD.b/255)
        if missionData.rewards.money then
            love.graphics.print("+ $" .. missionData.rewards.money, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if missionData.rewards.items then
            love.graphics.print("+ " .. missionData.rewards.items, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if missionData.rewards.intel then
            love.graphics.print("+ " .. missionData.rewards.intel .. " Intel Points", PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if missionData.rewards.relations then
            love.graphics.print("+ Relations with " .. missionData.rewards.relations, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    end
    yPos = yPos + SECTION_SPACING
    
    -- Penalties section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("FAILURE PENALTIES:", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if missionData.penalties then
        love.graphics.setColor(COLORS.PENALTY.r/255, COLORS.PENALTY.g/255, COLORS.PENALTY.b/255)
        if missionData.penalties.death then
            love.graphics.print("- Soldiers killed or captured", PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if missionData.penalties.relations then
            love.graphics.print("- Relations penalty: " .. missionData.penalties.relations, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if missionData.penalties.funding then
            love.graphics.print("- Monthly funding reduced", PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    end
    
    -- Draw buttons
    drawButton(BUTTONS.ACCEPT, hoveredButton == "ACCEPT")
    drawButton(BUTTONS.ABORT, hoveredButton == "ABORT")
end

--- Draw a button
local function drawButton(button, isHovered)
    local color = button == BUTTONS.ACCEPT and COLORS.BUTTON_ACCEPT or COLORS.BUTTON_ABORT
    if isHovered then
        color = COLORS.BUTTON_HOVER
    end
    
    -- Button background
    love.graphics.setColor(color.r/255, color.g/255, color.b/255, 0.8)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    
    -- Button border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    
    -- Button text
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    local textWidth = love.graphics.getFont():getWidth(button.label)
    local textX = button.x + (button.width - textWidth) / 2
    local textY = button.y + (button.height - LINE_HEIGHT) / 2
    love.graphics.print(button.label, textX, textY)
    
    -- Hotkey hint
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("[" .. button.hotkey .. "]", button.x + 4, button.y + button.height - 16)
end

--- Handle mouse click
function MissionBriefUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Check accept button
    if mouseX >= BUTTONS.ACCEPT.x and mouseX <= BUTTONS.ACCEPT.x + BUTTONS.ACCEPT.width and
       mouseY >= BUTTONS.ACCEPT.y and mouseY <= BUTTONS.ACCEPT.y + BUTTONS.ACCEPT.height then
        if acceptCallback then
            acceptCallback(missionData)
        end
        MissionBriefUI.hide()
        return true
    end
    
    -- Check abort button
    if mouseX >= BUTTONS.ABORT.x and mouseX <= BUTTONS.ABORT.x + BUTTONS.ABORT.width and
       mouseY >= BUTTONS.ABORT.y and mouseY <= BUTTONS.ABORT.y + BUTTONS.ABORT.height then
        if abortCallback then
            abortCallback()
        end
        MissionBriefUI.hide()
        return true
    end
    
    return false
end

--- Handle mouse movement for hover effects
function MissionBriefUI.handleMouseMove(mouseX, mouseY)
    if not visible then return end
    
    hoveredButton = nil
    
    -- Check accept button hover
    if mouseX >= BUTTONS.ACCEPT.x and mouseX <= BUTTONS.ACCEPT.x + BUTTONS.ACCEPT.width and
       mouseY >= BUTTONS.ACCEPT.y and mouseY <= BUTTONS.ACCEPT.y + BUTTONS.ACCEPT.height then
        hoveredButton = "ACCEPT"
    end
    
    -- Check abort button hover
    if mouseX >= BUTTONS.ABORT.x and mouseX <= BUTTONS.ABORT.x + BUTTONS.ABORT.width and
       mouseY >= BUTTONS.ABORT.y and mouseY <= BUTTONS.ABORT.y + BUTTONS.ABORT.height then
        hoveredButton = "ABORT"
    end
end

--- Handle keyboard input
function MissionBriefUI.handleKeyPress(key)
    if not visible then return false end
    
    if key == "a" then
        if acceptCallback then
            acceptCallback(missionData)
        end
        MissionBriefUI.hide()
        return true
    elseif key == "escape" then
        if abortCallback then
            abortCallback()
        end
        MissionBriefUI.hide()
        return true
    end
    
    return false
end

--- Get mission data
function MissionBriefUI.getMissionData()
    return missionData
end

return MissionBriefUI

























