---Mission Timer System - Turn-Based Countdown Mechanics
---
---Implements mission-critical countdown timers, timed objectives, and turn-based event scheduling.
---Supports multiple independent timers per mission, evacuation windows, reinforcement schedules,
---and time-sensitive objectives. All timers are turn-based (not real-time) for tactical gameplay.
---
---Timer Types:
---  - Mission Timer: Overall time limit to complete mission objectives
---  - Evacuation Timer: Countdown to extraction zone closure
---  - Reinforcement Timer: Schedules enemy wave spawns
---  - Objective Timer: Time limit for specific sub-objectives
---  - Event Timer: Triggers scripted events at specific turns
---
---Turn-Based Mechanics:
---  - No Real-Time: All timers count down by turns, not seconds
---  - Player Turn End: Timers decrement when player ends turn
---  - Enemy Turn: Timers also tick during enemy turns
---  - Flexible Duration: Timers can be 5 turns to 50+ turns
---
---Timed Objectives:
---  - Rescue VIP: Reach and extract VIP within 15 turns
---  - Hack Terminal: Complete hack before reinforcements (10 turns)
---  - Defend Location: Hold position for 8 turns
---  - Bomb Defusal: Disarm explosive within 6 turns
---  - Escape Mission: Reach evac zone before timer expires
---
---Evacuation Windows:
---  - Initial Delay: Evac zone available after turn 5
---  - Closing Window: Evac closes after turn 20 (15-turn window)
---  - Warning System: Alerts at 10 turns, 5 turns, 2 turns remaining
---  - Mission Failure: Units not evacuated are lost
---
---Reinforcement Schedules:
---  - Wave 1: Enemies spawn at turn 8 (north entrance)
---  - Wave 2: Enemies spawn at turn 16 (south entrance)
---  - Wave 3: Heavy reinforcements at turn 24 (all entrances)
---  - Dynamic Scaling: Waves scale based on mission difficulty
---
---Scripted Events:
---  - Turn 5: Civilian panic event
---  - Turn 10: Power outage (lights disabled)
---  - Turn 15: Backup generator activates
---  - Turn 20: Building collapse warning
---
---Warning Notifications:
---  - 1/3 Progress: Yellow warning "66% time remaining"
---  - 2/3 Progress: Orange warning "33% time remaining"
---  - Final Warning: Red alert "5 turns remaining!"
---  - Audio Cues: Beep sounds for critical warnings
---
---Key Exports:
---  - createTimer(name, duration, callback): Creates new mission timer
---  - updateTimers(): Decrements all active timers by 1 turn
---  - getTimeRemaining(timerName): Returns turns remaining
---  - isTimerExpired(timerName): Checks if timer reached zero
---  - pauseTimer(timerName): Temporarily stops timer countdown
---  - resumeTimer(timerName): Resumes paused timer
---
---Integration:
---  - Works with turn_system.lua for turn end events
---  - Uses objective_system.lua for timed objectives
---  - Integrates with ui system for timer display
---  - Connects to mission_system.lua for failure conditions
---
---@module battlescape.systems.mission_timer_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MissionTimer = require("battlescape.systems.mission_timer_system")
---  MissionTimer.createTimer("evacuation", 20, function()
---      print("Evac window closed - mission failed!")
---  end)
---  MissionTimer.updateTimers() -- Call at end of each turn
---
---@see battlescape.logic.turn_system For turn end integration
---@see battlescape.ui.objective_tracker_ui For timer display

local MissionTimerSystem = {}

-- Configuration
local CONFIG = {
    -- Timer Types
    TIMER_TYPES = {
        MISSION = "MISSION",                    -- Overall mission timer
        OBJECTIVE = "OBJECTIVE",                -- Objective-specific timer
        EVACUATION = "EVACUATION",              -- Evacuation window
        REINFORCEMENT = "REINFORCEMENT",        -- Enemy reinforcement schedule
        EVENT = "EVENT",                        -- Scripted event trigger
    },
    
    -- Warning Thresholds (percentage of timer remaining)
    WARNING_THRESHOLDS = {
        FIRST = 0.66,       -- Warning at 66% time remaining (1/3 elapsed)
        SECOND = 0.33,      -- Warning at 33% time remaining (2/3 elapsed)
        FINAL = 0.10,       -- Final warning at 10% time remaining
    },
    
    -- Timer States
    TIMER_STATES = {
        ACTIVE = "ACTIVE",
        PAUSED = "PAUSED",
        EXPIRED = "EXPIRED",
        COMPLETED = "COMPLETED",
    },
    
    -- Notification Settings
    NOTIFICATION_DURATION = 3,      -- Turns to show notification
    PLAY_SOUND_ON_WARNING = true,   -- Play sound when warning triggered
    PLAY_SOUND_ON_EXPIRED = true,   -- Play sound when timer expires
}

-- Active timers
-- Format: timers[timerId] = { type, turnsTotal, turnsRemaining, state, callback, data }
local timers = {}
local timerIdCounter = 0

-- Notification queue
local notifications = {}

--[[
    Create a new mission timer
    
    @param timerType: Timer type (MISSION, OBJECTIVE, etc.)
    @param turnCount: Number of turns for this timer
    @param callback: Function to call when timer expires (optional)
    @param data: Custom data to attach to timer (optional)
    @return timerId: Unique timer identifier
]]
function MissionTimerSystem.createTimer(timerType, turnCount, callback, data)
    timerIdCounter = timerIdCounter + 1
    local timerId = timerIdCounter
    
    timers[timerId] = {
        id = timerId,
        type = timerType or CONFIG.TIMER_TYPES.MISSION,
        turnsTotal = turnCount,
        turnsRemaining = turnCount,
        turnsElapsed = 0,
        state = CONFIG.TIMER_STATES.ACTIVE,
        callback = callback,
        data = data or {},
        warningsFired = {},  -- Track which warnings have been fired
    }
    
    print(string.format("[MissionTimerSystem] Created %s timer %d: %d turns",
        timerType, timerId, turnCount))
    
    return timerId
end

--[[
    Remove a timer
    
    @param timerId: Timer identifier
]]
function MissionTimerSystem.removeTimer(timerId)
    if timers[timerId] then
        print(string.format("[MissionTimerSystem] Removed timer %d", timerId))
        timers[timerId] = nil
    end
end

--[[
    Pause a timer
    
    @param timerId: Timer identifier
]]
function MissionTimerSystem.pauseTimer(timerId)
    if timers[timerId] then
        timers[timerId].state = CONFIG.TIMER_STATES.PAUSED
        print(string.format("[MissionTimerSystem] Paused timer %d", timerId))
    end
end

--[[
    Resume a paused timer
    
    @param timerId: Timer identifier
]]
function MissionTimerSystem.resumeTimer(timerId)
    if timers[timerId] and timers[timerId].state == CONFIG.TIMER_STATES.PAUSED then
        timers[timerId].state = CONFIG.TIMER_STATES.ACTIVE
        print(string.format("[MissionTimerSystem] Resumed timer %d", timerId))
    end
end

--[[
    Add time to a timer
    
    @param timerId: Timer identifier
    @param additionalTurns: Turns to add (can be negative to reduce)
]]
function MissionTimerSystem.addTime(timerId, additionalTurns)
    if timers[timerId] then
        timers[timerId].turnsRemaining = timers[timerId].turnsRemaining + additionalTurns
        timers[timerId].turnsTotal = timers[timerId].turnsTotal + additionalTurns
        print(string.format("[MissionTimerSystem] Added %d turns to timer %d (now %d remaining)",
            additionalTurns, timerId, timers[timerId].turnsRemaining))
    end
end

--[[
    Get time remaining on timer
    
    @param timerId: Timer identifier
    @return turnsRemaining: Number of turns left, or nil if timer doesn't exist
]]
function MissionTimerSystem.getTimeRemaining(timerId)
    if timers[timerId] then
        return timers[timerId].turnsRemaining
    end
    return nil
end

--[[
    Get timer state
    
    @param timerId: Timer identifier
    @return state: Timer state string, or nil
]]
function MissionTimerSystem.getTimerState(timerId)
    if timers[timerId] then
        return timers[timerId].state
    end
    return nil
end

--[[
    Check if timer has expired
    
    @param timerId: Timer identifier
    @return expired: Boolean
]]
function MissionTimerSystem.isTimerExpired(timerId)
    if timers[timerId] then
        return timers[timerId].state == CONFIG.TIMER_STATES.EXPIRED
    end
    return false
end

--[[
    Mark timer as completed (before expiration)
    Used when objective is completed before time runs out
    
    @param timerId: Timer identifier
]]
function MissionTimerSystem.completeTimer(timerId)
    if timers[timerId] then
        timers[timerId].state = CONFIG.TIMER_STATES.COMPLETED
        print(string.format("[MissionTimerSystem] Timer %d marked as completed", timerId))
        
        MissionTimerSystem.addNotification(
            string.format("Objective completed with %d turns remaining!", timers[timerId].turnsRemaining),
            "success"
        )
    end
end

--[[
    Check and fire warnings for timer
    
    @param timer: Timer data
]]
local function checkWarnings(timer)
    local percentRemaining = timer.turnsRemaining / timer.turnsTotal
    
    -- Check first warning (66% remaining = 1/3 elapsed)
    if not timer.warningsFired.FIRST and percentRemaining <= CONFIG.WARNING_THRESHOLDS.FIRST then
        timer.warningsFired.FIRST = true
        MissionTimerSystem.addNotification(
            string.format("Warning: %d turns remaining on %s timer!", timer.turnsRemaining, timer.type),
            "warning"
        )
        if CONFIG.PLAY_SOUND_ON_WARNING then
            -- Trigger sound effect (implementation dependent)
            print(string.format("[MissionTimerSystem] SOUND: Warning for timer %d", timer.id))
        end
    end
    
    -- Check second warning (33% remaining = 2/3 elapsed)
    if not timer.warningsFired.SECOND and percentRemaining <= CONFIG.WARNING_THRESHOLDS.SECOND then
        timer.warningsFired.SECOND = true
        MissionTimerSystem.addNotification(
            string.format("Warning: Only %d turns remaining!", timer.turnsRemaining),
            "warning"
        )
        if CONFIG.PLAY_SOUND_ON_WARNING then
            print(string.format("[MissionTimerSystem] SOUND: Second warning for timer %d", timer.id))
        end
    end
    
    -- Check final warning (10% remaining)
    if not timer.warningsFired.FINAL and percentRemaining <= CONFIG.WARNING_THRESHOLDS.FINAL then
        timer.warningsFired.FINAL = true
        MissionTimerSystem.addNotification(
            string.format("CRITICAL: %d turns remaining!", timer.turnsRemaining),
            "critical"
        )
        if CONFIG.PLAY_SOUND_ON_WARNING then
            print(string.format("[MissionTimerSystem] SOUND: Final warning for timer %d", timer.id))
        end
    end
end

--[[
    Process turn for all active timers
    
    Should be called at the end of each turn
]]
function MissionTimerSystem.processTurn()
    for timerId, timer in pairs(timers) do
        if timer.state == CONFIG.TIMER_STATES.ACTIVE then
            timer.turnsRemaining = timer.turnsRemaining - 1
            timer.turnsElapsed = timer.turnsElapsed + 1
            
            print(string.format("[MissionTimerSystem] Timer %d: %d turns remaining",
                timerId, timer.turnsRemaining))
            
            -- Check for warnings
            if timer.turnsRemaining > 0 then
                checkWarnings(timer)
            end
            
            -- Check for expiration
            if timer.turnsRemaining <= 0 then
                timer.state = CONFIG.TIMER_STATES.EXPIRED
                print(string.format("[MissionTimerSystem] Timer %d EXPIRED!", timerId))
                
                MissionTimerSystem.addNotification(
                    string.format("%s timer expired!", timer.type),
                    "critical"
                )
                
                if CONFIG.PLAY_SOUND_ON_EXPIRED then
                    print(string.format("[MissionTimerSystem] SOUND: Timer %d expired", timerId))
                end
                
                -- Call callback if provided
                if timer.callback then
                    local success, err = pcall(timer.callback, timer)
                    if not success then
                        print(string.format("[MissionTimerSystem] ERROR in timer callback: %s", tostring(err)))
                    end
                end
            end
        end
    end
    
    -- Process notifications (age them)
    MissionTimerSystem.processNotifications()
end

--[[
    Add notification to queue
    
    @param message: Notification message
    @param priority: Priority level (info, warning, critical, success)
]]
function MissionTimerSystem.addNotification(message, priority)
    table.insert(notifications, {
        message = message,
        priority = priority or "info",
        turnsRemaining = CONFIG.NOTIFICATION_DURATION,
    })
    print(string.format("[MissionTimerSystem] NOTIFICATION [%s]: %s", priority, message))
end

--[[
    Process notifications (age and remove expired)
]]
function MissionTimerSystem.processNotifications()
    for i = #notifications, 1, -1 do
        notifications[i].turnsRemaining = notifications[i].turnsRemaining - 1
        if notifications[i].turnsRemaining <= 0 then
            table.remove(notifications, i)
        end
    end
end

--[[
    Get all active notifications
    
    @return notifications: Table of notification data
]]
function MissionTimerSystem.getActiveNotifications()
    return notifications
end

--[[
    Get all active timers
    
    @return table of timer data
]]
function MissionTimerSystem.getAllTimers()
    return timers
end

--[[
    Get timers of specific type
    
    @param timerType: Timer type to filter
    @return table of matching timers
]]
function MissionTimerSystem.getTimersByType(timerType)
    local matching = {}
    for _, timer in pairs(timers) do
        if timer.type == timerType then
            table.insert(matching, timer)
        end
    end
    return matching
end

--[[
    Clear all timers (for mission end)
]]
function MissionTimerSystem.clearAllTimers()
    timers = {}
    notifications = {}
    timerIdCounter = 0
    print("[MissionTimerSystem] All timers cleared")
end

--[[
    Visualize timer for UI display
    
    @param timerId: Timer identifier
    @return visualization data
]]
function MissionTimerSystem.visualizeTimer(timerId)
    if not timers[timerId] then
        return nil
    end
    
    local timer = timers[timerId]
    local percentRemaining = timer.turnsRemaining / timer.turnsTotal
    local percentElapsed = timer.turnsElapsed / timer.turnsTotal
    
    return {
        id = timer.id,
        type = timer.type,
        turnsRemaining = timer.turnsRemaining,
        turnsElapsed = timer.turnsElapsed,
        turnsTotal = timer.turnsTotal,
        percentRemaining = percentRemaining * 100,
        percentElapsed = percentElapsed * 100,
        state = timer.state,
        urgency = percentRemaining <= CONFIG.WARNING_THRESHOLDS.FINAL and "CRITICAL" or
                  percentRemaining <= CONFIG.WARNING_THRESHOLDS.SECOND and "HIGH" or
                  percentRemaining <= CONFIG.WARNING_THRESHOLDS.FIRST and "MEDIUM" or "LOW",
    }
end

return MissionTimerSystem

























