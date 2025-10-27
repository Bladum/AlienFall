# 📊 Analytics & Telemetry Best Practices

**Domain:** Analytics & Data Collection  
**Focus:** Player metrics, performance monitoring, crash reporting, A/B testing  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers implementing analytics, tracking player behavior, monitoring performance, and collecting crash data.

## Analytics Implementation

### ✅ DO: Track Key Metrics

```lua
-- analytics.lua
Analytics = {
    sessionStartTime = 0,
    events = {},
    metrics = {}
}

function Analytics:trackEvent(eventName, data)
    local event = {
        timestamp = love.timer.getTime(),
        event_name = eventName,
        data = data or {}
    }
    table.insert(self.events, event)
    print("[ANALYTICS] Event: " .. eventName)
end

-- Track gameplay events
Analytics:trackEvent("game_started", {difficulty = "normal"})
Analytics:trackEvent("mission_completed", {mission_id = 1, time_taken = 300})
Analytics:trackEvent("unit_killed", {unit_type = "soldier", killed_by = "alien_sniper"})
```

---

### ✅ DO: Implement Session Tracking

```lua
function startSession()
    Analytics.sessionStartTime = love.timer.getTime()
    Analytics.sessionId = generateUUID()
    
    Analytics:trackEvent("session_start", {
        version = getVersionString(),
        platform = love.system.getOS(),
        date = os.date("%Y-%m-%d")
    })
end

function endSession()
    local sessionLength = love.timer.getTime() - Analytics.sessionStartTime
    
    Analytics:trackEvent("session_end", {
        duration_seconds = sessionLength,
        total_events = #Analytics.events
    })
    
    -- Send to server
    sendAnalyticsData(Analytics.events)
end

-- Hook into game lifecycle
function love.load()
    startSession()
end

function love.quit()
    endSession()
end
```

---

### ✅ DO: Track Performance Metrics

```lua
Analytics.performanceMetrics = {
    fps_samples = {},
    memory_samples = {},
    load_times = {}
}

function trackPerformanceMetrics()
    -- Sample FPS every frame
    local fps = love.timer.getFPS()
    table.insert(Analytics.performanceMetrics.fps_samples, fps)
    
    -- Sample memory usage
    local memory = collectgarbage("count") / 1024  -- MB
    table.insert(Analytics.performanceMetrics.memory_samples, memory)
    
    -- Alert if performance drops
    if fps < 50 then
        print("[WARNING] Low FPS: " .. fps)
        Analytics:trackEvent("low_fps", {fps = fps})
    end
    
    if memory > 256 then
        print("[WARNING] High memory: " .. memory .. "MB")
        Analytics:trackEvent("high_memory", {mb = memory})
    end
end

function love.update(dt)
    trackPerformanceMetrics()
end
```

---

## Crash Reporting

### ✅ DO: Implement Crash Logging

```lua
function love.errhand(msg)
    -- Capture crash information
    local crashReport = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        message = msg,
        version = getVersionString(),
        platform = love.system.getOS(),
        memory_mb = collectgarbage("count") / 1024,
        stack_trace = debug.traceback()
    }
    
    -- Log locally
    local crashPath = love.filesystem.getSaveDirectory() .. "/crashes.log"
    local content = love.filesystem.read(crashPath) or ""
    content = content .. jsonEncode(crashReport) .. "\n\n"
    love.filesystem.write(crashPath, content)
    
    -- Send to crash server
    sendCrashReport(crashReport)
    
    -- Show error screen
    return msg .. "\n\nStack Trace:\n" .. debug.traceback()
end
```

---

### ✅ DO: Batch and Compress Data

```lua
function compressAnalyticsData(events)
    -- Compress event data for transmission
    local json = jsonEncode(events)
    
    -- Simple compression (use zlib in production)
    local compressed = {}
    for i = 1, #json do
        local byte = string.byte(json, i)
        table.insert(compressed, byte)
    end
    
    return compressed
end

function uploadAnalytics()
    if #Analytics.events == 0 then return end
    
    -- Compress
    local compressed = compressAnalyticsData(Analytics.events)
    
    -- Batch and send
    local batch = {
        session_id = Analytics.sessionId,
        event_count = #Analytics.events,
        data = compressed,
        timestamp = os.time()
    }
    
    sendToServer("https://analytics.example.com/batch", batch)
end
```

---

## Practical Implementation

### ✅ DO: Implement A/B Testing

```lua
local ABTests = {
    active = {}
}

function ABTests:startTest(testName, variants)
    local userVariant = math.random(1, #variants)
    self.active[testName] = {
        variant = userVariant,
        start_time = love.timer.getTime()
    }
    
    Analytics:trackEvent("ab_test_start", {
        test_name = testName,
        variant = userVariant
    })
    
    return variants[userVariant]
end

-- Usage
local uiLayout = ABTests:startTest("ui_layout", {"sidebar", "topbar", "overlay"})
if uiLayout == "sidebar" then
    -- Show sidebar layout
elseif uiLayout == "topbar" then
    -- Show topbar layout
end
```

---

### ✅ DO: Respect Privacy Settings

```lua
function shouldCollectAnalytics()
    local prefs = loadPlayerPreferences()
    return prefs.analytics_enabled ~= false  -- Opt-in by default
end

function uploadAnalytics()
    if not shouldCollectAnalytics() then
        print("[ANALYTICS] Collection disabled by user")
        return
    end
    
    -- Only send if enabled
    sendToServer("https://analytics.example.com", Analytics.events)
end

function getPrivacyStatement()
    return [[
    We collect:
    - Gameplay events (missions, achievements)
    - Performance metrics (FPS, memory)
    - Crashes and errors
    - Device information
    
    You can disable analytics in Settings > Privacy
    ]]
end
```

---

### ❌ DON'T: Collect Unnecessary Data

```lua
-- BAD: Over-collection
function trackEventBad(event)
    Analytics:trackEvent("keypress", {
        key = event.key,
        timestamp = love.timer.getTime(),
        x = mouse.x,
        y = mouse.y,
        memory = collectgarbage("count")
    })  -- Too much data
end

-- GOOD: Only essential data
function trackEventGood(event)
    Analytics:trackEvent("action_taken", {
        action_type = "unit_moved"
    })
end
```

---

### ❌ DON'T: Block Game on Analytics Upload

```lua
-- BAD: Blocking I/O
function uploadAnalyticsBad()
    local response = httpRequest(url, data)  -- Blocks!
end

-- GOOD: Non-blocking upload
function uploadAnalyticsGood()
    thread = love.thread.newThread([[
        local data = ...
        httpRequest(url, data)
    ]])
    thread:start(analyticsData)
end
```

---

## Common Patterns & Checklist

- [x] Track key gameplay events
- [x] Implement session tracking
- [x] Monitor performance metrics (FPS, memory)
- [x] Log crashes with stack traces
- [x] Compress data before transmission
- [x] Implement A/B testing framework
- [x] Respect user privacy preferences
- [x] Use non-blocking uploads
- [x] Batch events before sending
- [x] Document what data is collected

---

## References

- Google Analytics: https://analytics.google.com/
- Telemetry Best Practices: https://docs.microsoft.com/en-us/windows/desktop/etw/
- Privacy Regulations: https://gdpr-info.eu/

