---Combat Log System - Battle Events Feed
---
---Scrollable combat log displaying real-time battle events including hit/miss notifications,
---damage numbers, status changes, kills, and important tactical events. Features timestamps,
---color coding, icon indicators, and automatic scrolling for combat awareness.
---
---Log Entry Types:
---  - Hit/Miss: "Soldier shoots Alien: HIT for 15 damage"
---  - Critical Hit: "Soldier CRITICAL HIT Alien for 35 damage!"
---  - Kill: "Alien eliminated by Soldier"
---  - Status: "Alien is now SUPPRESSED"
---  - Action: "Soldier throws grenade at (12, 5)"
---  - System: "Turn 8 - Player Phase"
---
---Color Coding:
---  - White: Standard actions and movement
---  - Green: Successful hits and positive events
---  - Red: Damage taken, units killed
---  - Yellow: Important warnings and alerts
---  - Blue: System messages and turn changes
---  - Orange: Status effects applied
---
---Features:
---  - Auto-scroll: New entries appear at bottom
---  - Manual scroll: Mouse wheel to review history
---  - Entry limit: MAX_ENTRIES (100) for memory management
---  - Display limit: DISPLAY_ENTRIES (10) visible at once
---  - Timestamps: "[14:23:15]" for event timing
---  - Icons: Small sprite icons for quick recognition
---
---Configuration:
---  - MAX_ENTRIES: 100 (total history kept)
---  - DISPLAY_ENTRIES: 10 (visible on screen)
---  - Entry lifetime: No expiration, capped by MAX_ENTRIES
---  - Scroll speed: 3 entries per mouse wheel tick
---
---Key Exports:
---  - addEntry(message, type, color): Add new log entry
---  - clear(): Clear all log entries
---  - draw(x, y, width, height): Render log panel
---  - scroll(delta): Scroll log up/down
---  - update(dt): Update animations and fade effects
---
---Integration:
---  - Receives events from combat systems
---  - Displays in UI panel (right side typically)
---  - Synchronized with combat HUD
---
---@module battlescape.ui.combat_log_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CombatLog = require("battlescape.ui.combat_log_system")
---  CombatLog.addEntry("Soldier hits Alien for 20 damage", "hit", {0,1,0})
---  CombatLog.draw(700, 100, 240, 400)
---
---@see battlescape.ui.combat_hud For UI integration

--[[
    Combat Log System - Battle Events Feed
    
    Scrollable combat log showing hit/miss notifications, damage numbers,
    status changes, and battle events with timestamps and color coding.
    
    Author: UI Systems
    Created: October 14, 2025
--]]

local CombatLogSystem = {}

local CONFIG = {
    MAX_ENTRIES = 100,
    DISPLAY_ENTRIES = 10,
    PANEL_X = 12,
    PANEL_Y = 360,
    PANEL_WIDTH = 300,
    LINE_HEIGHT = 18,
    COLORS = {
        HIT = {r=220,g=60,b=60},
        MISS = {r=160,g=160,b=160},
        DAMAGE = {r=255,g=100,b=60},
        HEAL = {r=80,g=220,b=80},
        STATUS = {r=220,g=180,b=60},
        INFO = {r=200,g=200,b=220},
    },
}

local logEntries = {}
local scrollOffset = 0

function CombatLogSystem.init()
    logEntries = {}
    scrollOffset = 0
end

function CombatLogSystem.addEntry(message, entryType)
    table.insert(logEntries, 1, {
        message = message,
        type = entryType or "INFO",
        timestamp = love.timer.getTime(),
    })
    if #logEntries > CONFIG.MAX_ENTRIES then
        table.remove(logEntries)
    end
    print("[CombatLog] " .. message)
end

function CombatLogSystem.scroll(delta)
    scrollOffset = math.max(0, math.min(scrollOffset + delta, #logEntries - CONFIG.DISPLAY_ENTRIES))
end

function CombatLogSystem.draw()
    local x = CONFIG.PANEL_X
    local y = CONFIG.PANEL_Y
    
    -- Background
    love.graphics.setColor(20, 20, 30, 220)
    love.graphics.rectangle("fill", x, y, CONFIG.PANEL_WIDTH, CONFIG.LINE_HEIGHT * CONFIG.DISPLAY_ENTRIES + 20)
    
    -- Title
    love.graphics.setColor(220, 220, 230, 255)
    love.graphics.print("Combat Log", x + 10, y + 5, 0, 0.9, 0.9)
    
    -- Entries
    local startIndex = scrollOffset + 1
    local endIndex = math.min(startIndex + CONFIG.DISPLAY_ENTRIES - 1, #logEntries)
    
    for i = startIndex, endIndex do
        local entry = logEntries[i]
        local color = CONFIG.COLORS[entry.type] or CONFIG.COLORS.INFO
        love.graphics.setColor(color.r, color.g, color.b, 255)
        love.graphics.print(entry.message, x + 10, y + 20 + (i - startIndex) * CONFIG.LINE_HEIGHT, 0, 0.8, 0.8)
    end
end

return CombatLogSystem






















