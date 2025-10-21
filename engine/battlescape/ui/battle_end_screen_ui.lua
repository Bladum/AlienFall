---BattleEndScreenUI - Post-Battle Results Screen
---
---Post-battle results screen displaying casualties, loot, experience gained, and mission
---outcome. Shows detailed breakdown of soldier performance, items recovered, enemies
---killed, and mission objectives completed. Part of mission setup and deployment systems.
---
---Features:
---  - Mission outcome display (success/failure)
---  - Casualty list (killed, wounded, MIA)
---  - Loot recovered (items, corpses, artifacts)
---  - Experience gained per soldier
---  - Mission statistics (kills, accuracy, turns)
---  - Debriefing text and narrative
---
---Screen Sections:
---  - Header: Mission name and outcome
---  - Casualties: Dead, wounded, MIA soldiers
---  - Loot: Recovered items and resources
---  - Experience: XP gains and promotions
---  - Statistics: Combat performance metrics
---  - Narrative: Debriefing story text
---
---Configuration:
---  - Panel size: 800×600 pixels (centered)
---  - Layout: Vertical sections with spacing
---  - Colors: Color-coded by outcome (green/red)
---
---Key Exports:
---  - BattleEndScreenUI.init(): Initializes UI system
---  - BattleEndScreenUI.setResults(results): Sets mission results data
---  - BattleEndScreenUI.draw(): Renders results screen
---  - BattleEndScreenUI.update(dt): Updates animations
---  - BattleEndScreenUI.keypressed(key): Handles input
---  - BattleEndScreenUI.mousepressed(x, y, button): Click handling
---
---Dependencies:
---  - None (standalone UI system)
---
---@module battlescape.ui.battle_end_screen_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local BattleEndScreenUI = require("battlescape.ui.battle_end_screen_ui")
---  BattleEndScreenUI.setResults({
---    success = true,
---    casualties = {killed = 1, wounded = 2},
---    loot = {items = 5, corpses = 3},
---    experience = {{name = "Sgt. Johnson", xp = 25}}
---  })
---  BattleEndScreenUI.draw()
---
---@see battlescape.ui.debriefing_screen_ui For detailed debriefing

-- Battle End Screen UI System
-- Post-battle results with casualties, loot, experience
-- Part of Batch 8: Mission Setup & Deployment Systems

local BattleEndScreenUI = {}

-- Configuration
local PANEL_WIDTH = 800
local PANEL_HEIGHT = 600
local PANEL_X = (960 - PANEL_WIDTH) / 2
local PANEL_Y = (720 - PANEL_HEIGHT) / 2
local PADDING = 12
local LINE_HEIGHT = 18
local SECTION_SPACING = 24

-- Colors
local COLORS = {
    BACKGROUND = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    VICTORY = {r=100, g=220, b=100},
    DEFEAT = {r=255, g=80, b=60},
    PARTIAL = {r=255, g=200, b=60},
    OBJECTIVE_COMPLETE = {r=100, g=220, b=100},
    OBJECTIVE_FAILED = {r=255, g=80, b=60},
    UNIT_SURVIVED = {r=100, g=220, b=100},
    UNIT_WOUNDED = {r=255, g=200, b=60},
    UNIT_KIA = {r=255, g=80, b=60},
    UNIT_MIA = {r=160, g=160, b=160},
    LOOT = {r=180, g=200, b=255},
    EXPERIENCE = {r=255, g=220, b=100},
    RANK_UP = {r=255, g=180, b=60}
}

-- State
local visible = false
local battleResults = nil  -- {result, objectives[], units[], loot[], score, rewards{}}
local scrollOffset = 0
local confirmCallback = nil

--- Initialize battle end screen
function BattleEndScreenUI.init()
    visible = false
    battleResults = nil
    scrollOffset = 0
    confirmCallback = nil
end

--- Show battle end screen
-- @param results Table {result, objectives[], units[], loot[], score, rewards{}}
-- @param onConfirm Callback function
function BattleEndScreenUI.show(results, onConfirm)
    battleResults = results
    confirmCallback = onConfirm
    visible = true
    scrollOffset = 0
end

--- Hide battle end screen
function BattleEndScreenUI.hide()
    visible = false
end

--- Check if visible
function BattleEndScreenUI.isVisible()
    return visible
end

--- Draw the battle end screen
function BattleEndScreenUI.draw()
    if not visible or not battleResults then return end
    
    -- Panel background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255, COLORS.BACKGROUND.a/255)
    love.graphics.rectangle("fill", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Panel border
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PANEL_X, PANEL_Y, PANEL_WIDTH, PANEL_HEIGHT)
    
    -- Mission result header
    local resultColor = COLORS.VICTORY
    local resultText = "MISSION SUCCESS"
    if battleResults.result == "DEFEAT" then
        resultColor = COLORS.DEFEAT
        resultText = "MISSION FAILED"
    elseif battleResults.result == "PARTIAL" then
        resultColor = COLORS.PARTIAL
        resultText = "PARTIAL SUCCESS"
    elseif battleResults.result == "ABORT" then
        resultColor = COLORS.DEFEAT
        resultText = "MISSION ABORTED"
    end
    
    love.graphics.setColor(resultColor.r/255, resultColor.g/255, resultColor.b/255)
    local resultTextWidth = love.graphics.getFont():getWidth(resultText)
    love.graphics.print(resultText, PANEL_X + (PANEL_WIDTH - resultTextWidth) / 2, PANEL_Y + PADDING, 0, 1.5, 1.5)
    
    -- Mission score
    if battleResults.score then
        love.graphics.setColor(COLORS.EXPERIENCE.r/255, COLORS.EXPERIENCE.g/255, COLORS.EXPERIENCE.b/255)
        local scoreText = "Score: " .. battleResults.score
        local scoreWidth = love.graphics.getFont():getWidth(scoreText)
        love.graphics.print(scoreText, PANEL_X + (PANEL_WIDTH - scoreWidth) / 2, PANEL_Y + PADDING + 32)
    end
    
    -- Scrollable content area
    local contentY = PANEL_Y + 80
    local contentHeight = PANEL_HEIGHT - 160
    
    love.graphics.setScissor(PANEL_X + PADDING, contentY, PANEL_WIDTH - PADDING * 2, contentHeight)
    
    local yPos = contentY - scrollOffset
    
    -- Objectives section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("OBJECTIVES", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if battleResults.objectives then
        for _, obj in ipairs(battleResults.objectives) do
            local objColor = obj.complete and COLORS.OBJECTIVE_COMPLETE or COLORS.OBJECTIVE_FAILED
            love.graphics.setColor(objColor.r/255, objColor.g/255, objColor.b/255)
            local statusIcon = obj.complete and "[✓] " or "[✗] "
            love.graphics.print(statusIcon .. obj.description, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    end
    yPos = yPos + SECTION_SPACING
    
    -- Unit casualties section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("UNIT STATUS", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if battleResults.units then
        for _, unit in ipairs(battleResults.units) do
            local statusColor = COLORS.UNIT_SURVIVED
            local statusText = "SURVIVED"
            
            if unit.status == "WOUNDED" then
                statusColor = COLORS.UNIT_WOUNDED
                statusText = "WOUNDED"
            elseif unit.status == "KIA" then
                statusColor = COLORS.UNIT_KIA
                statusText = "KIA"
            elseif unit.status == "MIA" then
                statusColor = COLORS.UNIT_MIA
                statusText = "MIA"
            end
            
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(unit.name, PANEL_X + PADDING + 12, yPos)
            
            love.graphics.setColor(statusColor.r/255, statusColor.g/255, statusColor.b/255)
            love.graphics.print(statusText, PANEL_X + PADDING + 240, yPos)
            
            -- Experience gained (if survived)
            if unit.status ~= "KIA" and unit.status ~= "MIA" and unit.experienceGained then
                love.graphics.setColor(COLORS.EXPERIENCE.r/255, COLORS.EXPERIENCE.g/255, COLORS.EXPERIENCE.b/255)
                love.graphics.print("+" .. unit.experienceGained .. " XP", PANEL_X + PADDING + 360, yPos)
                
                -- Rank up indicator
                if unit.rankUp then
                    love.graphics.setColor(COLORS.RANK_UP.r/255, COLORS.RANK_UP.g/255, COLORS.RANK_UP.b/255)
                    love.graphics.print("RANK UP!", PANEL_X + PADDING + 480, yPos)
                end
            end
            
            yPos = yPos + LINE_HEIGHT
        end
    end
    yPos = yPos + SECTION_SPACING
    
    -- Loot section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("LOOT COLLECTED", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if battleResults.loot and #battleResults.loot > 0 then
        love.graphics.setColor(COLORS.LOOT.r/255, COLORS.LOOT.g/255, COLORS.LOOT.b/255)
        for _, item in ipairs(battleResults.loot) do
            local itemText = "• " .. (item.name or item.type) .. " x" .. (item.quantity or 1)
            love.graphics.print(itemText, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    else
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print("No items recovered", PANEL_X + PADDING + 12, yPos)
        yPos = yPos + LINE_HEIGHT
    end
    yPos = yPos + SECTION_SPACING
    
    -- Rewards section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("MISSION REWARDS", PANEL_X + PADDING, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if battleResults.rewards then
        if battleResults.rewards.money then
            love.graphics.setColor(COLORS.EXPERIENCE.r/255, COLORS.EXPERIENCE.g/255, COLORS.EXPERIENCE.b/255)
            love.graphics.print("• $" .. battleResults.rewards.money, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if battleResults.rewards.intel then
            love.graphics.setColor(COLORS.LOOT.r/255, COLORS.LOOT.g/255, COLORS.LOOT.b/255)
            love.graphics.print("• " .. battleResults.rewards.intel .. " Intel Points", PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
        if battleResults.rewards.relations then
            love.graphics.setColor(COLORS.VICTORY.r/255, COLORS.VICTORY.g/255, COLORS.VICTORY.b/255)
            love.graphics.print("• Relations: " .. battleResults.rewards.relations, PANEL_X + PADDING + 12, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    end
    
    love.graphics.setScissor()
    
    -- Continue button
    local continueX = PANEL_X + PANEL_WIDTH - 180 - PADDING
    local continueY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    love.graphics.setColor(COLORS.VICTORY.r/255, COLORS.VICTORY.g/255, COLORS.VICTORY.b/255, 0.8)
    love.graphics.rectangle("fill", continueX, continueY, 168, 36)
    
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", continueX, continueY, 168, 36)
    
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("CONTINUE [ENTER]", continueX + 12, continueY + 12)
    
    -- Scroll hint
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255, 0.5)
    love.graphics.print("Scroll for more...", PANEL_X + PADDING, PANEL_Y + PANEL_HEIGHT - 48 - PADDING + 12, 0, 0.8, 0.8)
end

--- Handle mouse click
function BattleEndScreenUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Continue button
    local continueX = PANEL_X + PANEL_WIDTH - 180 - PADDING
    local continueY = PANEL_Y + PANEL_HEIGHT - 48 - PADDING
    
    if mouseX >= continueX and mouseX <= continueX + 168 and
       mouseY >= continueY and mouseY <= continueY + 36 then
        if confirmCallback then
            confirmCallback(battleResults)
        end
        BattleEndScreenUI.hide()
        return true
    end
    
    return false
end

--- Handle keyboard input
function BattleEndScreenUI.handleKeyPress(key)
    if not visible then return false end
    
    if key == "return" or key == "space" then
        if confirmCallback then
            confirmCallback(battleResults)
        end
        BattleEndScreenUI.hide()
        return true
    end
    
    return false
end

--- Handle scroll
function BattleEndScreenUI.handleScroll(mouseX, mouseY, scrollY)
    if not visible then return false end
    
    scrollOffset = math.max(0, scrollOffset - scrollY * 20)
    return true
end

--- Get battle results
function BattleEndScreenUI.getResults()
    return battleResults
end

return BattleEndScreenUI

























