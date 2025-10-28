# Integration & Meta Systems API Reference

**System:** Meta Layer (Cross-System Communication & Analytics)  
**Module:** `engine/core/`, `engine/analytics/`  
**Latest Update:** October 22, 2025  
**Status:** ✅ Complete

---

## Overview

The Integration and Analytics systems provide cross-system coordination, performance measurement, and event broadcasting. Integration manages system initialization, data flow, inter-system communication, and event propagation. Analytics tracks game metrics, player statistics, and performance data for optimization and balance analysis. Together they provide the backbone for coordinating all game systems and measuring progress.

**Layer Classification:** Meta / Core Infrastructure  
**Primary Responsibility:** System coordination, event broadcasting, data aggregation, performance tracking, metrics collection  
**Integration Points:** All systems (data source and consumers), UI (reporting), Files (data persistence)

---

## Implementation Status

### ✅ Implemented (in engine/core/)
- System initialization and coordination
- Event broadcasting system
- Error handling and logging
- Performance tracking
- Data persistence
- System health monitoring

### 🚧 Partially Implemented
- Real-time metrics aggregation
- Advanced debugging tools
- Performance profiling

### 📋 Planned
- Hot-reloading system
- Distributed system support
- Advanced logging analytics

---

## Core Entities

### Entity: SystemManager

Coordinates initialization and shutdown of all game systems.

**Properties:**
```lua
SystemManager = {
  -- Status
  systems = table,                -- {system_id: status}
  initialization_order = string[],
  is_initialized = boolean,
  initialization_time = number,   -- ms to initialize
  
  -- Logging
  debug_enabled = boolean,
  error_log = string[],
  warning_log = string[],
  system_health = table,          -- {system_id: health_percent}
}
```

**Functions:**
```lua
-- System initialization
SystemManager.initializeAllSystems() → boolean
SystemManager.initializeSystem(system_id: string) → boolean
SystemManager.shutdown() → void
SystemManager.getSystemStatus(system_id: string) → string

-- Error handling
SystemManager.logError(error_message: string) → void
SystemManager.logWarning(warning_message: string) → void
SystemManager.getErrorLog() → string[]
SystemManager.getWarningLog() → string[]
```

---

### Entity: EventBus

Central hub for all game events with queue and broadcasting.

**Properties:**
```lua
EventBus = {
  listeners = table,              -- {event_type: {callback_id: callback}}
  event_queue = table[],          -- Queued events pending dispatch
  event_history = string[],       -- Recent event names
  
  -- Statistics
  events_dispatched = number,
  total_listeners = number,
  queue_size = number,
  is_paused = boolean,
}
```

**Functions:**
```lua
-- Event registration
bus:registerListener(event_type: string, callback: function) → listener_id
bus:unregisterListener(listener_id: string) → void

-- Event triggering
bus:emit(event_name: string, event_data: table) → void  -- Immediate
bus:queue(event_name: string, event_data: table, priority: number) → void  -- Queued

-- Event management
bus:processQueue(max_events: number) → number (events processed)
bus:flushQueue() → void
bus:setpaused(paused: boolean) → void
bus:getStatistics() → table
```

---

### Entity: GameMetrics

Collection of tracked game statistics.

**Properties:**
```lua
GameMetrics = {
  -- Session Info
  session_start_turn = number,
  current_turn = number,
  session_duration = number,     -- Seconds
  
  -- Combat Stats
  battles_fought = number,
  battles_won = number,
  battles_lost = number,
  units_killed_by_player = number,
  units_lost_by_player = number,
  total_damage_dealt = number,
  total_damage_taken = number,
  
  -- Resource Stats
  total_credits_earned = number,
  total_credits_spent = number,
  research_points_generated = number,
  items_manufactured = number,
  
  -- Progression Stats
  techs_researched = number,
  buildings_constructed = number,
  units_recruited = number,
  units_promoted = number,
  bases_constructed = number,
  
  -- Strategic Stats
  provinces_controlled = number,
  ufos_intercepted = number,
  missions_completed = number,
  missions_failed = number,
  average_mission_success_rate = number,
}
```

---

### Entity: PerformanceMetrics

System performance and optimization data.

**Properties:**
```lua
PerformanceMetrics = {
  -- FPS & Timing
  average_fps = number,
  min_fps = number,
  max_fps = number,
  frame_time_ms = number,         -- Average frame time
  frame_time_budget = number,     -- Target (16.67ms for 60fps)
  
  -- Memory
  memory_used = number,           -- MB
  memory_peak = number,           -- MB
  memory_warning_threshold = number,
  
  -- System Load
  system_timings = table,         -- {system_id: time_ms}
  slowest_system = string,
  slowest_system_time = number,
  
  -- Frame budget allocation
  frame_budget_allocation = table,-- {system: percent}
}
```

---

### Entity: DataIntegrator

Manages cross-system data flow and state synchronization.

**Properties:**
```lua
DataIntegrator = {
  -- System states
  system_states = table,          -- {system_id: state_table}
  state_version = table,          -- {system_id: version_number}
  
  -- Event listeners
  event_listeners = table,        -- {event_type: callback[]}
  
  -- Synchronization
  sync_schedule = table,          -- When each system syncs
  pending_syncs = table[],
}
```

**Functions:**
```lua
-- Cross-system events
DataIntegrator.registerEventListener(event_type: string, callback: function) → void
DataIntegrator.dispatchEvent(event_type: string, data: table) → void

-- Data aggregation
DataIntegrator.aggregateGameState() → table (all system states)
DataIntegrator.getSystemState(system_id: string) → table
DataIntegrator.setSystemState(system_id: string, state: table) → void

-- System calls
DataIntegrator.callSystem(source: string, target: string, func: string, args: table) → result
```

---

### Entity: AnalyticsCollector

Tracks and aggregates game metrics.

**Properties:**
```lua
AnalyticsCollector = {
  -- Metrics storage
  metrics = table,                -- {metric_name: value[]}
  metric_history = table,         -- Historical data by turn
  
  -- Report generation
  reports = table[],              -- Generated reports
  last_report_turn = number,
  
  -- Leaderboards
  achievements = string[],        -- Unlocked achievements
  leader_stats = table,           -- Top performers
}
```

**Functions:**
```lua
-- Metrics collection
Analytics.recordGameEvent(event_type: string, data: table) → void
Analytics.recordBattleStats(battle: Battle, result: string) → void
Analytics.recordUnitStats(unit: Unit) → void
Analytics.recordMissionStats(mission: Mission, result: string) → void

-- Report generation
Analytics.getGameMetrics() → GameMetrics
Analytics.getPerformanceMetrics() → PerformanceMetrics
Analytics.generateSessionReport() → table
Analytics.getMetricHistory(metric_name: string, turns: number) → number[]

-- Leaderboard/Achievement tracking
Analytics.recordAchievement(achievement_id: string) → void
Analytics.getAchievements() → string[]
Analytics.getLeaderboard(category: string) → table
```

---

## Services & Functions

### System Manager Service

```lua
-- Initialization
SystemInitializer.initializeGame() → boolean
SystemInitializer.initializeSystem(system_name: string, config: table) → boolean
SystemInitializer.shutdownGame() → void
SystemInitializer.getInitializationTime() → number

-- Health checks
SystemInitializer.checkSystemHealth(system_id: string) → (healthy: boolean, issues: string[])
SystemInitializer.validateAllSystems() → boolean
SystemInitializer.repairSystem(system_id: string) → boolean
```

### Event Bus Service

```lua
-- Bus creation & management
EventBusService.createBus() → EventBus
EventBusService.getBus() → EventBus

-- Listener management
EventBusService.registerListener(event_type: string, callback: function) → listener_id
EventBusService.unregisterListener(listener_id: string) → void
EventBusService.getListeners(event_type: string) → function[]
EventBusService.hasListeners(event_type: string) → boolean

-- Event processing
EventBusService.emit(event_name: string, event_data: table) → void
EventBusService.queue(event_name: string, event_data: table) → void
EventBusService.processQueue(max_count: number) → number
EventBusService.flushQueue() → void
```

### Data Integration Service

```lua
-- Cross-system events
DataIntegrator.registerEventListener(event_type: string, callback: function) → void
DataIntegrator.dispatchEvent(event_type: string, data: table) → void

-- Data aggregation
DataIntegrator.aggregateGameState() → table (all system states)
DataIntegrator.getSystemState(system_id: string) → table
DataIntegrator.setSystemState(system_id: string, state: table) → void

-- System calling
DataIntegrator.callSystem(source: string, target: string, method: string, args: table) → result
DataIntegrator.broadcastSystemCall(method: string, args: table) → results[]
```

### Analytics Service

```lua
-- Metrics collection
Analytics.recordGameEvent(event_type: string, data: table) → void
Analytics.recordBattleStats(battle: Battle, result: string) → void
Analytics.recordUnitStats(unit: Unit) → void
Analytics.recordMissionStats(mission: Mission, result: string) → void
Analytics.recordCraftStats(craft: Craft, mission: Mission) → void

-- Report generation
Analytics.getGameMetrics() → GameMetrics
Analytics.getPerformanceMetrics() → PerformanceMetrics
Analytics.generateSessionReport() → table
Analytics.generateCampaignReport() → table
Analytics.getMetricHistory(metric_name: string, turns: number) → number[]
Analytics.getMetricAverage(metric_name: string, turns: number) → number

-- Leaderboard/Achievement tracking
Analytics.recordAchievement(achievement_id: string) → void
Analytics.getAchievements() → string[]
Analytics.getLeaderboard(category: string) → table
Analytics.updateLeaderboard() → void
```

### Performance Monitoring Service

```lua
-- Frame-by-frame monitoring
PerformanceMonitor.startFrameTimer() → void
PerformanceMonitor.recordFrameTime(time_ms: number) → void
PerformanceMonitor.getAverageFrameTime() → number
PerformanceMonitor.getFrameStats() → table (min, max, avg, current)

-- System profiling
PerformanceMonitor.profileSystem(system_id: string) → PerformanceMetrics
PerformanceMonitor.startProfile(system_id: string) → void
PerformanceMonitor.endProfile(system_id: string) → number (elapsed ms)
PerformanceMonitor.identifyBottlenecks() → string[] (slowest systems)

-- Performance optimization
PerformanceMonitor.getFrameBudgetAllocation() → table
PerformanceMonitor.warnIfSlowFrame(threshold_ms: number) → boolean
```

---

## Configuration (TOML)

### System Initialization Order

```toml
# core/system_initialization.toml

[initialization_order]
sequence = [
  "core",
  "assets",
  "geoscape",
  "basescape",
  "battlescape",
  "economy",
  "research",
  "ai",
  "politics",
  "lore",
  "ui",
]

[system_priorities]
core_priority = 100
critical_priority = 90
normal_priority = 50
ui_priority = 10

[initialization_timeouts]
core_timeout_ms = 5000
system_timeout_ms = 10000
ui_timeout_ms = 2000
```

### Event Definitions

```toml
# core/event_definitions.toml

[[events]]
id = "game_started"
category = "session"
description = "Game session initialized"
priority = 100

[[events]]
id = "turn_advanced"
category = "time"
description = "Turn incremented"
priority = 80

[[events]]
id = "battle_started"
category = "combat"
description = "Battle initialized"
priority = 90

[[events]]
id = "battle_ended"
category = "combat"
description = "Battle concluded"
priority = 90

[[events]]
id = "tech_researched"
category = "research"
description = "Technology completed"
priority = 50

[[events]]
id = "unit_promoted"
category = "progression"
description = "Unit ranked up"
priority = 40

[[events]]
id = "mission_completed"
category = "missions"
description = "Mission succeeded"
priority = 75

[[events]]
id = "funding_received"
category = "economy"
description = "Country funding received"
priority = 50
```

### Analytics Configuration

```toml
# analytics/analytics_config.toml

[tracking]
enabled = true
track_combat = true
track_economy = true
track_progression = true
track_performance = true
track_missions = true
track_diplomacy = true

[reporting]
auto_report_frequency = 3600  # Seconds (hourly)
report_to_file = true
report_filename = "session_analytics.json"
auto_generate_reports = true

[performance]
fps_target = 60
memory_warning_threshold = 1024  # MB
frame_time_budget = 16.67  # ms (for 60 FPS)
enable_profiling = false
profile_output = "performance_profile.txt"

[achievements]
enable_achievements = true
auto_unlock = false
```

---

## Supported Events

```lua
local EVENTS = {
  -- World & Time
  "world_created",
  "turn_advanced",
  "month_changed",
  "year_changed",
  "game_saved",
  "game_loaded",
  
  -- Province & Territory
  "province_discovered",
  "province_threatened",
  "threat_level_changed",
  "region_lost",
  "region_secured",
  
  -- Base & Facilities
  "base_constructed",
  "base_destroyed",
  "facility_completed",
  "facility_damaged",
  "facility_queued",
  "power_deficit",
  "power_restored",
  
  -- Units & Personnel
  "unit_created",
  "unit_promoted",
  "unit_killed",
  "unit_wounded",
  "squad_assigned_mission",
  "squad_returned",
  
  -- Research & Manufacturing
  "research_started",
  "research_completed",
  "manufacturing_started",
  "manufacturing_completed",
  "tech_unlocked",
  
  -- Missions & Combat
  "mission_generated",
  "mission_started",
  "battle_started",
  "battle_ended",
  "battle_won",
  "battle_lost",
  "objective_completed",
  
  -- Diplomacy & Funding
  "relations_changed",
  "funding_received",
  "trade_agreement_signed",
  "alliance_formed",
  "alliance_broken",
  
  -- Craft & Interception
  "craft_deployed",
  "craft_damaged",
  "craft_returned",
  "interception_started",
  "interception_ended",
  "ufo_detected",
  "ufo_intercepted",
  
  -- Economy & Finance
  "budget_calculated",
  "purchase_completed",
  "shortage_alert",
  "profit_recorded",
  "loss_recorded",
}
```

---

## Usage Examples

### Example 1: Initialize Game Systems

```lua
-- Initialize all systems
print("Initializing game...")
local success = SystemInitializer.initializeGame()

if success then
  print("Game initialized successfully")
else
  print("Initialization failed - checking system health")
  
  -- Check each system
  local systems = {"geoscape", "basescape", "battlescape", "economy"}
  for _, system in ipairs(systems) do
    local healthy, issues = SystemInitializer.checkSystemHealth(system)
    if not healthy then
      print("  " .. system .. " issues:")
      for _, issue in ipairs(issues) do
        print("    - " .. issue)
      end
    end
  end
end
```

### Example 2: Register Event Listeners

```lua
-- Get event bus
local bus = EventBusService.getBus()

-- Register battlescape listener for combat events
bus:registerListener("battle_started", function(data)
  print("Battle started: " .. data.battle_id)
  print("Location: " .. data.location)
  print("Player units: " .. #data.player_units)
  print("Enemy units: " .. #data.enemy_units)
end)

-- Register economy listener for transactions
bus:registerListener("funding_received", function(data)
  print("Funding received from " .. data.country_name)
  print("Amount: $" .. data.amount)
  print("Total balance: $" .. data.new_balance)
end)

-- Register analytics listener (listens to everything)
bus:registerListener("*", function(data)
  Analytics.recordGameEvent(data.event_type, data)
end)
```

### Example 3: Record Game Events

```lua
-- Record battle completion
Analytics.recordBattleStats(battle, "victory")

-- Record unit promotion
Analytics.recordUnitStats(promoted_unit)
print("Recorded unit promotion: " .. promoted_unit:getName())

-- Record tech research
EventBusService.getBus():emit("tech_researched", {
  tech_id = "plasma_weaponry",
  turn = current_turn,
  researcher_count = 5,
})

-- Record achievement
Analytics.recordAchievement("first_victory")
```

### Example 4: Get Performance Metrics

```lua
-- Get performance data
local perf = Analytics.getPerformanceMetrics()

print("Performance Report:")
print("  Average FPS: " .. math.floor(perf.average_fps))
print("  Frame time: " .. math.floor(perf.frame_time_ms * 100) / 100 .. "ms")
print("  Memory: " .. perf.memory_used .. "MB")
print("  Slowest system: " .. perf.slowest_system .. " (" .. perf.slowest_system_time .. "ms)")

if perf.memory_used > perf.memory_warning_threshold then
  print("  ⚠️ WARNING: High memory usage!")
end
```

### Example 5: Generate Session Report

```lua
-- Generate comprehensive session report
local report = Analytics.generateSessionReport()

print("Session Report:")
print("  Duration: " .. report.session_duration .. " seconds")
print("  Turns: " .. report.current_turn)
print("  Battles: " .. report.battles_fought)
print("  Win rate: " .. math.floor(report.average_mission_success_rate * 100) .. "%")
print("  Technologies: " .. report.techs_researched)
print("  Credits spent: $" .. report.total_credits_spent)
```

---

## Integration Points

**Inputs from:**
- All game systems (events, state changes)
- Performance monitors (FPS, memory data)
- Analytics recorders (game statistics)

**Outputs to:**
- All game systems (initialization, shutdown)
- UI (metrics displays, reports)
- Files (save/load data)
- Analytics tools (performance reports)

**Dependencies:**
- Core system infrastructure
- Event broadcasting system
- Metrics collection services
- Performance monitoring

---

## Error Handling

```lua
-- Event dispatch with error handling
local success, result = pcall(function()
  EventBusService.getBus():emit("battle_started", battleData)
end)

if not success then
  print("[ERROR] Failed to dispatch battle_started event: " .. result)
  Analytics.recordGameEvent("event_dispatch_error", {
    event_type = "battle_started",
    error = result,
  })
end

-- System initialization with validation
local healthy, issues = SystemInitializer.checkSystemHealth("battlescape")
if not healthy then
  print("[ERROR] Battlescape system unhealthy:")
  for _, issue in ipairs(issues) do
    print("  - " .. issue)
  end
  SystemInitializer.repairSystem("battlescape")
end
```

---

**Last Updated:** October 22, 2025  
**Status:** ✅ COMPLETE
