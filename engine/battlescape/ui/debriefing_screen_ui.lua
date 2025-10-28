---DebriefingScreenUI - Detailed Mission Analysis Screen
---
---Detailed post-mission analysis and resource management screen. Shows comprehensive
---mission breakdown including casualties, loot, statistics, and narrative debriefing.
---More detailed than BattleEndScreenUI. Part of mission setup and deployment systems.
---
---Features:
---  - Tabbed interface (Casualties, Loot, Stats, Narrative)
---  - Detailed casualty list with injuries
---  - Loot recovery and sale interface
---  - Mission statistics graphs
---  - Debriefing narrative text
---  - Resource management integration
---
---Tab Sections:
---  - Casualties: Dead, wounded, MIA with details
---  - Loot: Recovered items with value and sale options
---  - Statistics: Combat metrics, graphs, achievements
---  - Narrative: Story debriefing with choices
---
---Configuration:
---  - Screen size: 960×720 pixels (full screen)
---  - Tab height: 36 pixels
---  - Padding: 12 pixels
---  - Line height: 18 pixels
---
---Key Exports:
---  - DebriefingScreenUI.init(): Initializes UI
---  - DebriefingScreenUI.setResults(results): Sets mission data
---  - DebriefingScreenUI.draw(): Renders screen
---  - DebriefingScreenUI.update(dt): Updates animations
---  - DebriefingScreenUI.keypressed(key): Tab switching
---  - DebriefingScreenUI.mousepressed(x, y, button): Click handling
---  - DebriefingScreenUI.setTab(tab): Changes active tab
---
---Dependencies:
---  - None (standalone UI system)
---
---@module battlescape.ui.debriefing_screen_ui
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DebriefingScreenUI = require("battlescape.ui.debriefing_screen_ui")
---  DebriefingScreenUI.setResults(missionResults)
---  DebriefingScreenUI.setTab("casualties")
---  DebriefingScreenUI.draw()
---
---@see battlescape.ui.battle_end_screen_ui For quick results screen

-- Debriefing Screen UI System
-- Detailed post-mission analysis and resource management
-- Part of Batch 8: Mission Setup & Deployment Systems

local DebriefingScreenUI = {}

-- Configuration
local SCREEN_WIDTH = 960
local SCREEN_HEIGHT = 720
local PADDING = 12
local LINE_HEIGHT = 18
local TAB_HEIGHT = 36
local SECTION_SPACING = 16

-- Colors
local COLORS = {
    BACKGROUND = {r=20, g=20, b=30, a=255},
    PANEL_BG = {r=30, g=30, b=40, a=240},
    BORDER = {r=80, g=100, b=120},
    HEADER = {r=220, g=220, b=240},
    TEXT = {r=200, g=200, b=200},
    TAB_ACTIVE = {r=60, g=80, b=100},
    TAB_INACTIVE = {r=40, g=50, b=60},
    STAT_LABEL = {r=180, g=180, b=200},
    STAT_VALUE = {r=220, g=220, b=240},
    POSITIVE = {r=100, g=220, b=100},
    NEGATIVE = {r=255, g=80, b=60},
    NEUTRAL = {r=200, g=200, b=200},
    RESEARCH_UNLOCK = {r=255, g=200, b=100},
    RELATIONS_UP = {r=100, g=220, b=100},
    RELATIONS_DOWN = {r=255, g=80, b=60}
}

-- Tabs
local TABS = {
    {id = "SUMMARY", label = "Summary"},
    {id = "SOLDIERS", label = "Soldiers"},
    {id = "LOOT", label = "Loot & Research"},
    {id = "RELATIONS", label = "Relations"},
    {id = "STATS", label = "Statistics"}
}

-- State
local visible = false
local activeTab = "SUMMARY"
local debriefData = nil  -- Complete mission data
local scrollOffset = 0
local confirmCallback = nil
local saveCallback = nil

--- Initialize debriefing screen
function DebriefingScreenUI.init()
    visible = false
    activeTab = "SUMMARY"
    debriefData = nil
    scrollOffset = 0
    confirmCallback = nil
    saveCallback = nil
end

--- Show debriefing screen
-- @param data Table {result, objectives[], soldiers[], loot[], research[], relations[], stats{}}
-- @param onConfirm Callback to return to geoscape
-- @param onSave Callback to save game
function DebriefingScreenUI.show(data, onConfirm, onSave)
    debriefData = data
    confirmCallback = onConfirm
    saveCallback = onSave
    visible = true
    activeTab = "SUMMARY"
    scrollOffset = 0
end

--- Hide debriefing screen
function DebriefingScreenUI.hide()
    visible = false
end

--- Check if visible
function DebriefingScreenUI.isVisible()
    return visible
end

--- Draw the debriefing screen
function DebriefingScreenUI.draw()
    if not visible or not debriefData then return end
    
    -- Full screen background
    love.graphics.setColor(COLORS.BACKGROUND.r/255, COLORS.BACKGROUND.g/255, COLORS.BACKGROUND.b/255)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Header
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("MISSION DEBRIEFING", PADDING, PADDING, 0, 1.5, 1.5)
    
    -- Tabs
    local tabX = PADDING
    local tabY = 60
    
    for _, tab in ipairs(TABS) do
        local isActive = (tab.id == activeTab)
        local tabColor = isActive and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE
        local tabWidth = 144
        
        love.graphics.setColor(tabColor.r/255, tabColor.g/255, tabColor.b/255)
        love.graphics.rectangle("fill", tabX, tabY, tabWidth, TAB_HEIGHT)
        
        love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", tabX, tabY, tabWidth, TAB_HEIGHT)
        
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        local textWidth = love.graphics.getFont():getWidth(tab.label)
        love.graphics.print(tab.label, tabX + (tabWidth - textWidth) / 2, tabY + 10)
        
        tabX = tabX + tabWidth + 6
    end
    
    -- Content area
    local contentY = tabY + TAB_HEIGHT + 12
    local contentHeight = SCREEN_HEIGHT - contentY - 72
    
    -- Panel background
    love.graphics.setColor(COLORS.PANEL_BG.r/255, COLORS.PANEL_BG.g/255, COLORS.PANEL_BG.b/255, COLORS.PANEL_BG.a/255)
    love.graphics.rectangle("fill", PADDING, contentY, SCREEN_WIDTH - PADDING * 2, contentHeight)
    
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", PADDING, contentY, SCREEN_WIDTH - PADDING * 2, contentHeight)
    
    -- Draw active tab content
    love.graphics.setScissor(PADDING + 12, contentY + 12, SCREEN_WIDTH - PADDING * 2 - 24, contentHeight - 24)
    
    if activeTab == "SUMMARY" then
        drawSummaryTab(contentY + 12)
    elseif activeTab == "SOLDIERS" then
        drawSoldiersTab(contentY + 12)
    elseif activeTab == "LOOT" then
        drawLootTab(contentY + 12)
    elseif activeTab == "RELATIONS" then
        drawRelationsTab(contentY + 12)
    elseif activeTab == "STATS" then
        drawStatsTab(contentY + 12)
    end
    
    love.graphics.setScissor()
    
    -- Bottom buttons
    local buttonY = SCREEN_HEIGHT - 60
    
    -- Save button
    local saveX = PADDING
    love.graphics.setColor(COLORS.TAB_ACTIVE.r/255, COLORS.TAB_ACTIVE.g/255, COLORS.TAB_ACTIVE.b/255)
    love.graphics.rectangle("fill", saveX, buttonY, 144, 48)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", saveX, buttonY, 144, 48)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("SAVE GAME", saveX + 24, buttonY + 18)
    
    -- Continue button
    local continueX = SCREEN_WIDTH - 180 - PADDING
    love.graphics.setColor(COLORS.POSITIVE.r/255, COLORS.POSITIVE.g/255, COLORS.POSITIVE.b/255, 0.8)
    love.graphics.rectangle("fill", continueX, buttonY, 168, 48)
    love.graphics.setColor(COLORS.BORDER.r/255, COLORS.BORDER.g/255, COLORS.BORDER.b/255)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", continueX, buttonY, 168, 48)
    love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
    love.graphics.print("RETURN TO BASE", continueX + 12, buttonY + 18)
end

--- Draw summary tab
function drawSummaryTab(startY)
    local yPos = startY - scrollOffset
    
    -- Mission result
    local resultColor = COLORS.POSITIVE
    if debriefData.result == "DEFEAT" then
        resultColor = COLORS.NEGATIVE
    end
    
    love.graphics.setColor(resultColor.r/255, resultColor.g/255, resultColor.b/255)
    love.graphics.print("MISSION: " .. debriefData.result, PADDING + 24, yPos, 0, 1.2, 1.2)
    yPos = yPos + 32
    
    -- Quick stats
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Mission Score:", PADDING + 24, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(debriefData.score or 0, PADDING + 180, yPos)
    yPos = yPos + LINE_HEIGHT
    
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Turns Completed:", PADDING + 24, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(debriefData.turns or 0, PADDING + 180, yPos)
    yPos = yPos + LINE_HEIGHT
    
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Enemies Killed:", PADDING + 24, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(debriefData.enemiesKilled or 0, PADDING + 180, yPos)
    yPos = yPos + LINE_HEIGHT + SECTION_SPACING
    
    -- Objectives summary
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("OBJECTIVES COMPLETED", PADDING + 24, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if debriefData.objectives then
        local completed = 0
        for _, obj in ipairs(debriefData.objectives) do
            if obj.complete then completed = completed + 1 end
        end
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print(completed .. " / " .. #debriefData.objectives .. " objectives completed", PADDING + 36, yPos)
    end
end

--- Draw soldiers tab
function drawSoldiersTab(startY)
    local yPos = startY - scrollOffset
    
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("SOLDIER STATUS & PROMOTIONS", PADDING + 24, yPos)
    yPos = yPos + LINE_HEIGHT + 8
    
    if debriefData.soldiers then
        for _, soldier in ipairs(debriefData.soldiers) do
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(soldier.name, PADDING + 36, yPos)
            
            -- Status/wounds
            if soldier.wounds then
                love.graphics.setColor(COLORS.NEGATIVE.r/255, COLORS.NEGATIVE.g/255, COLORS.NEGATIVE.b/255)
                love.graphics.print("Wounded (" .. soldier.wounds .. " days)", PADDING + 240, yPos)
            else
                love.graphics.setColor(COLORS.POSITIVE.r/255, COLORS.POSITIVE.g/255, COLORS.POSITIVE.b/255)
                love.graphics.print("Healthy", PADDING + 240, yPos)
            end
            
            -- Experience
            if soldier.xpGained then
                love.graphics.setColor(COLORS.RESEARCH_UNLOCK.r/255, COLORS.RESEARCH_UNLOCK.g/255, COLORS.RESEARCH_UNLOCK.b/255)
                love.graphics.print("+" .. soldier.xpGained .. " XP", PADDING + 420, yPos)
            end
            
            -- Promotion
            if soldier.promoted then
                love.graphics.setColor(COLORS.POSITIVE.r/255, COLORS.POSITIVE.g/255, COLORS.POSITIVE.b/255)
                love.graphics.print("PROMOTED!", PADDING + 540, yPos)
            end
            
            yPos = yPos + LINE_HEIGHT
        end
    end
end

--- Draw loot & research tab
function drawLootTab(startY)
    local yPos = startY - scrollOffset
    
    -- Loot section
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("ITEMS RECOVERED", PADDING + 24, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if debriefData.loot and #debriefData.loot > 0 then
        for _, item in ipairs(debriefData.loot) do
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print("• " .. item.name .. " x" .. (item.quantity or 1), PADDING + 36, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    else
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print("No items recovered", PADDING + 36, yPos)
        yPos = yPos + LINE_HEIGHT
    end
    
    yPos = yPos + SECTION_SPACING
    
    -- Research unlocks
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("RESEARCH UNLOCKS", PADDING + 24, yPos)
    yPos = yPos + LINE_HEIGHT + 4
    
    if debriefData.researchUnlocks and #debriefData.researchUnlocks > 0 then
        for _, research in ipairs(debriefData.researchUnlocks) do
            love.graphics.setColor(COLORS.RESEARCH_UNLOCK.r/255, COLORS.RESEARCH_UNLOCK.g/255, COLORS.RESEARCH_UNLOCK.b/255)
            love.graphics.print("• " .. research.name, PADDING + 36, yPos)
            yPos = yPos + LINE_HEIGHT
        end
    else
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print("No new research available", PADDING + 36, yPos)
    end
end

--- Draw relations tab
function drawRelationsTab(startY)
    local yPos = startY - scrollOffset
    
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("DIPLOMATIC RELATIONS CHANGES", PADDING + 24, yPos)
    yPos = yPos + LINE_HEIGHT + 8
    
    if debriefData.relationsChanges and #debriefData.relationsChanges > 0 then
        for _, change in ipairs(debriefData.relationsChanges) do
            love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
            love.graphics.print(change.country, PADDING + 36, yPos)
            
            local changeColor = change.amount > 0 and COLORS.RELATIONS_UP or COLORS.RELATIONS_DOWN
            local changeText = (change.amount > 0 and "+" or "") .. change.amount
            love.graphics.setColor(changeColor.r/255, changeColor.g/255, changeColor.b/255)
            love.graphics.print(changeText, PADDING + 300, yPos)
            
            yPos = yPos + LINE_HEIGHT
        end
    else
        love.graphics.setColor(COLORS.TEXT.r/255, COLORS.TEXT.g/255, COLORS.TEXT.b/255)
        love.graphics.print("No relations changes", PADDING + 36, yPos)
    end
end

--- Draw statistics tab
function drawStatsTab(startY)
    local yPos = startY - scrollOffset
    
    if not debriefData.stats then return end
    
    love.graphics.setColor(COLORS.HEADER.r/255, COLORS.HEADER.g/255, COLORS.HEADER.b/255)
    love.graphics.print("DETAILED MISSION STATISTICS", PADDING + 24, yPos)
    yPos = yPos + LINE_HEIGHT + 8
    
    local stats = debriefData.stats
    
    -- Combat stats
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Shots Fired:", PADDING + 36, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(stats.shotsFired or 0, PADDING + 240, yPos)
    yPos = yPos + LINE_HEIGHT
    
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Shots Hit:", PADDING + 36, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    local accuracy = stats.shotsFired > 0 and math.floor((stats.shotsHit / stats.shotsFired) * 100) or 0
    love.graphics.print((stats.shotsHit or 0) .. " (" .. accuracy .. "%)", PADDING + 240, yPos)
    yPos = yPos + LINE_HEIGHT
    
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Damage Dealt:", PADDING + 36, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(stats.damageDealt or 0, PADDING + 240, yPos)
    yPos = yPos + LINE_HEIGHT
    
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Damage Taken:", PADDING + 36, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(stats.damageTaken or 0, PADDING + 240, yPos)
    yPos = yPos + LINE_HEIGHT
    
    love.graphics.setColor(COLORS.STAT_LABEL.r/255, COLORS.STAT_LABEL.g/255, COLORS.STAT_LABEL.b/255)
    love.graphics.print("Enemies Killed:", PADDING + 36, yPos)
    love.graphics.setColor(COLORS.STAT_VALUE.r/255, COLORS.STAT_VALUE.g/255, COLORS.STAT_VALUE.b/255)
    love.graphics.print(stats.enemiesKilled or 0, PADDING + 240, yPos)
    yPos = yPos + LINE_HEIGHT
end

--- Handle mouse click
function DebriefingScreenUI.handleClick(mouseX, mouseY)
    if not visible then return false end
    
    -- Check tab clicks
    local tabX = PADDING
    local tabY = 60
    
    for _, tab in ipairs(TABS) do
        local tabWidth = 144
        if mouseX >= tabX and mouseX <= tabX + tabWidth and
           mouseY >= tabY and mouseY <= tabY + TAB_HEIGHT then
            activeTab = tab.id
            scrollOffset = 0
            return true
        end
        tabX = tabX + tabWidth + 6
    end
    
    -- Check button clicks
    local buttonY = SCREEN_HEIGHT - 60
    
    -- Save button
    local saveX = PADDING
    if mouseX >= saveX and mouseX <= saveX + 144 and
       mouseY >= buttonY and mouseY <= buttonY + 48 then
        if saveCallback then
            saveCallback()
        end
        return true
    end
    
    -- Continue button
    local continueX = SCREEN_WIDTH - 180 - PADDING
    if mouseX >= continueX and mouseX <= continueX + 168 and
       mouseY >= buttonY and mouseY <= buttonY + 48 then
        if confirmCallback then
            confirmCallback()
        end
        DebriefingScreenUI.hide()
        return true
    end
    
    return false
end

--- Handle scroll
function DebriefingScreenUI.handleScroll(mouseX, mouseY, scrollY)
    if not visible then return false end
    
    scrollOffset = math.max(0, scrollOffset - scrollY * 20)
    return true
end

return DebriefingScreenUI


























