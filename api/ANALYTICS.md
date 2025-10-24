````markdown
# Analytics System API Documentation

## Overview

The Analytics System provides comprehensive data collection, processing, and analysis enabling continuous game balance improvement, performance optimization, and design validation. The system operates on a five-stage pipeline: autonomous simulation → log capture → data aggregation → metric calculation → action planning.

**Design Philosophy:**
Analytics enables data-driven game design through continuous feedback loops. Rather than relying on manual playtesting or intuition, the analytics system captures millions of game events, extracts meaningful patterns, and surfaces actionable insights. The system supports both automated AI-driven testing and organic player-generated data, creating a unified data corpus for holistic game understanding.

**Key Responsibilities:**
- Autonomous simulation execution (AI agents playing complete campaigns)
- Real-time metrics collection from all game systems
- Performance monitoring (FPS, memory, load times)
- Player behavior and engagement tracking
- Event recording with complete traceability
- Data persistence in queryable formats (Parquet, SQL)
- Custom analytics and actionable insights generation
- Balance validation and design verification

**Integration Points:**
- All game systems report events to Analytics
- Autonomous simulations run in backend generating log data
- Dual AI architecture (Player AI + Faction AI) interaction tracking
- Geoscape, Basescape, Battlescape metrics
- UI systems track user interactions
- Performance monitoring hooks into engine core
- Data exported to Parquet/SQL for analysis

---

## Architecture

### Data Flow

```
Game Systems → Analytics Events → Data Collection → Storage → Queries/Reports
                      ↓
              Event Aggregation
              Performance Metrics
              Custom Analytics
                      ↓
              Data Analysis & Export
```

### System Components

1. **Event System** - Capture and categorize game events
2. **Metrics Collector** - Real-time metrics aggregation
3. **Performance Monitor** - Engine performance tracking
4. **Data Storage** - Persistent analytics database
5. **Report Generator** - Custom analytics reports
6. **Data Exporter** - Export data for external tools

### Event Categories

- **System Events** - Game state changes, loading, saves
- **Player Actions** - Mission completion, research, purchases
- **Combat Events** - Unit actions, damage, kills, objectives
- **Economy Events** - Funds changes, trades, research progress
- **Performance Events** - FPS dips, lag, resource usage
- **Engagement Events** - Session time, playtime, retention

---

## Autonomous Simulation & Data Capture

### Overview

Autonomous simulations run miniature game instances where AI agents execute both strategic decisions (faction operations) and tactical decisions (player actions). Simulations execute entirely in backend, generating granular logs of all game events for analysis.

### Simulation Types

| Simulation Type | Scope | Duration | Frequency | Purpose |
|---|---|---|---|---|
| **Geoscape Sim** | Strategic layer only | 12-24 hours/day | Continuous | Mission generation, diplomacy, funding |
| **Basescape Sim** | Base management only | 30-day cycles | Daily | Research, manufacturing, facility management |
| **Interception Sim** | Craft vs UFO combat | Single engagement | Per-encounter | Defense systems, craft effectiveness |
| **Battlescape Sim** | Tactical ground combat | Single mission | Per-mission | Unit balance, weapon effectiveness, AI tactics |
| **Full Campaign Sim** | All systems integrated | 6-12 months gameplay | Weekly | Emergent interactions, long-term dynamics |

**Strategic Purpose:**
- **Balance Validation:** Verify game mechanics function as intended
- **Performance Profiling:** Identify bottlenecks and optimization opportunities
- **Design Verification:** Confirm design goals are met through gameplay data
- **AI Behavior Analysis:** Understand how autonomous agents play the game
- **Early Warning:** Detect issues before they reach players
- **Iteration Support:** Quantify improvements across versions

### Dual AI Architecture

Simulations employ two independent AI systems working together:

**Player AI:**
- Meta-AI making high-level strategic decisions
- Mimics human player behavior (base building, research prioritization)
- Craft deployment and UI interaction patterns
- Receives game state, makes decisions, translates to actions/UI clicks
- Learns from outcomes and adapts strategy

**Faction AI:**
- Native game AI executing enemy strategy
- Campaign generation and mission creation
- Unit deployment and tactical engagement
- Responds dynamically to player AI actions
- Represents baseline difficulty

**Interaction Model:**
```
Player AI Decision Loop:
  1. Analyze Game State
     - Current resources, base status
     - Threats and opportunities
     - Research/manufacturing progress

  2. Strategic Planning
     - Prioritize objectives (research/defense/expansion)
     - Resource allocation strategy
     - Long-term goals

  3. Tactical Execution
     - Queue research projects
     - Deploy craft
     - Manage facilities
     - Train units

  4. UI Interaction
     - Translate decisions to clicks
     - Navigate menus
     - Confirm dialogs

  5. Feedback & Adaptation
     - Record outcomes and costs
     - Analyze effectiveness
     - Adjust future decisions
```

### Log Structure & Format

**Unified Event Schema:**

All game events logged with consistent structure for streaming processing:

```toml
timestamp = "2025-10-22T14:32:15Z"
simulation_id = "uuid-v4"
session_id = "uuid-v4"
event_type = "research_started"  # research_started|facility_built|unit_killed|mission_failed|...
actor = "player"  # player|faction_x|neutral
outcome = "success"  # success|partial|failure

[context]
base_id = "base_main_001"
location = "province_122"

[context.resources_before]
credits = 50000
salvage = 150
scientists = 5

[context.resources_after]
credits = 42000
salvage = 150
scientists = 4

[metrics]
cost_credits = 8000
time_days = 10
difficulty_multiplier = 1.2
impact_severity = "high"

cascading_effects = ["research_bonus_applied", "facility_bonus_calculated"]
```

**Log Management:**
- All simulation logs written to structured files (JSON-Lines format)
- Hourly log rotation to manageable sizes
- Organized by simulation type and timestamp
- Backup/archival for historical trend analysis
- Real-time log streaming to processing pipeline

**Player Session Logging:**
- Player-driven sessions logged separately
- Same schema as simulation logs
- Additional metadata (player difficulty, mods, version)
- Consent and privacy compliance tracking

### Log Analysis Pipeline

**Stage 1: Event Aggregation**
```
Raw Logs → Parse JSON → Validate Schema → Deduplicate → Enrich Context
```

**Stage 2: Data Transformation**
```
Aggregated Events → Calculate Deltas → Derive Statistics → Create Metrics
```

**Stage 3: Analysis**
```
Metrics → Pattern Detection → Anomaly Identification → Insight Generation
```

---

## Core Entities

### Analytics Controller

Root entity managing all analytics operations and system coordination.

```lua
-- Create analytics instance
analytics = Analytics.create(save_path, auto_flush_interval)

-- Record custom event
Analytics.record_event(event_type, event_data, category)

-- Get metric value
value = Analytics.get_metric(metric_name)

-- Get metrics batch
metrics = Analytics.get_metrics_batch(metric_names)

-- Flush data to storage
Analytics.flush()

-- Generate report
report = Analytics.generate_report(start_time, end_time, filters)

-- Query events
events = Analytics.query_events(event_type, time_range, filters)

-- Export data
Analytics.export_data(format, destination)

-- Reset session
Analytics.reset_session()

-- Get session duration
duration = Analytics.get_session_duration()
```

### Performance Monitor

Tracks engine performance metrics in real-time.

```lua
-- Create performance monitor
perf_monitor = PerformanceMonitor.create()

-- Record frame
perf_monitor:record_frame(fps, memory_usage, draw_calls)

-- Get average FPS
avg_fps = perf_monitor:get_average_fps(time_window)

-- Get memory peak
peak_mem = perf_monitor:get_peak_memory()

-- Check for performance issue
has_issue = perf_monitor:check_performance_issue(threshold)

-- Get performance report
report = perf_monitor:get_report(duration)

-- Reset metrics
perf_monitor:reset()

-- Enable/disable monitoring
perf_monitor:set_enabled(state)
```

### Event Collector

Handles event recording and aggregation.

```lua
-- Create event collector
collector = EventCollector.create(buffer_size)

-- Record event
collector:record(event_type, event_data, timestamp)

-- Get events by type
events = collector:get_events_by_type(event_type, time_range)

-- Get event count
count = collector:get_event_count(event_type)

-- Aggregate events
aggregated = collector:aggregate_events(grouping_key, aggregation_func)

-- Clear old events
collector:clear_old_events(days)

-- Export events
collector:export(format)
```

### Metrics Calculator

Computes analytics and statistics from collected data.

```lua
-- Create calculator
calculator = MetricsCalculator.create()

-- Calculate statistic
value = calculator:calculate(metric_name, data)

-- Get average
avg = calculator:get_average(values)

-- Get percentile
p90 = calculator:get_percentile(values, 90)

-- Get distribution
dist = calculator:get_distribution(values, bucket_count)

-- Trending
trend = calculator:calculate_trend(values, time_periods)

-- Correlation
corr = calculator:get_correlation(series1, series2)
```

### Report Builder

Generates comprehensive analytics reports.

```lua
-- Create report builder
builder = ReportBuilder.create(title)

-- Add section
builder:add_section(section_name, content)

-- Add chart
builder:add_chart(chart_type, data, title)

-- Add table
builder:add_table(columns, rows, title)

-- Add summary
builder:add_summary(metrics)

-- Generate report
report = builder:build(format)

-- Export report
builder:export(destination, format)
```

---

## Integration Examples

### Example 1: Track Mission Completion

```lua
-- Record mission completion event
Analytics.record_event("mission_completed", {
  mission_id = "mission_001",
  mission_type = "terror_site",
  difficulty = "classic",
  completion_time = 1800,  -- seconds
  squad_size = 4,
  units_lost = 1,
  enemies_killed = 12,
  success = true,
  player_id = "player_abc123"
}, "gameplay")

-- Console output:
-- [Analytics] Event recorded: mission_completed (1234567890)
-- [Analytics] Data stored: mission_id=mission_001, completion_time=1800
```

### Example 2: Monitor Performance Metrics

```lua
-- In love.update() or equivalent
function update_analytics()
  local fps = love.timer.getFPS()
  local memory_mb = collectgarbage("count") / 1024
  local draw_calls = get_draw_call_count()
  
  perf_monitor:record_frame(fps, memory_mb, draw_calls)
  
  -- Check for performance issues
  if perf_monitor:check_performance_issue(30) then
    Analytics.record_event("performance_issue", {
      avg_fps = perf_monitor:get_average_fps(60),
      memory_peak = perf_monitor:get_peak_memory(),
      draw_calls = draw_calls
    }, "performance")
    print("[Analytics] Performance issue detected and recorded")
  end
end

-- Console output:
-- [Analytics] Frame recorded: fps=60, memory=245MB, draw_calls=152
-- [Analytics] Performance issue detected and recorded
```

### Example 3: Query Battle Statistics

```lua
-- Get all combat events from today
local today_start = os.time({year=2025, month=10, day=21, hour=0})
local today_end = today_start + 86400

local combat_events = Analytics.query_events("unit_attack", {
  start_time = today_start,
  end_time = today_end
})

-- Calculate statistics
local total_attacks = #combat_events
local total_damage = 0
local total_hits = 0

for _, event in ipairs(combat_events) do
  total_damage = total_damage + (event.damage or 0)
  if event.hit then total_hits = total_hits + 1 end
end

local avg_damage = total_damage / total_attacks
local hit_rate = (total_hits / total_attacks) * 100

print(string.format("[Analytics] Combat Stats: %d attacks, %.1f avg damage, %.1f%% hit rate",
  total_attacks, avg_damage, hit_rate))

-- Console output:
-- [Analytics] Combat Stats: 342 attacks, 18.5 avg damage, 72.3% hit rate
```

### Example 4: Generate Session Report

```lua
-- Build comprehensive session report
local report = ReportBuilder.create("Daily Session Report - Oct 21, 2025")

-- Add performance summary
local perf_data = perf_monitor:get_report(86400)  -- last 24 hours
report:add_section("Performance", string.format(
  "Average FPS: %.1f\nPeak Memory: %.0f MB\nLongest Frame: %.2fms",
  perf_data.avg_fps,
  perf_data.peak_memory,
  perf_data.max_frame_time * 1000
))

-- Add gameplay summary
local gameplay_events = Analytics.query_events("mission_completed", {
  start_time = today_start,
  end_time = today_end
})
report:add_section("Gameplay", string.format(
  "Missions Completed: %d\nTotal Playtime: %d hours\nAverage Mission Time: %.1f min",
  #gameplay_events,
  total_playtime_hours,
  total_mission_time / #gameplay_events / 60
))

-- Add charts
local fps_distribution = calculator:get_distribution(fps_values, 10)
report:add_chart("histogram", fps_distribution, "FPS Distribution")

-- Generate and export
local report_html = report:build("html")
report:export("/reports/session_report_20251021.html", "html")

print("[Analytics] Session report generated and exported")

-- Console output:
-- [Analytics] Report sections: 2 (Performance, Gameplay)
-- [Analytics] Charts added: 1 (FPS Distribution)
-- [Analytics] Session report generated and exported
-- [Analytics] File: /reports/session_report_20251021.html
```

### Example 5: Track Economy Changes

```lua
-- Record economy event
Analytics.record_event("funds_transaction", {
  transaction_type = "mission_reward",
  amount = 5000,
  from_balance = 25000,
  to_balance = 30000,
  reason = "Completed Abduction Mission",
  timestamp = os.time()
}, "economy")

-- Get economy metrics
local today_earnings = Analytics.get_metric("daily_earnings")
local total_spent = Analytics.get_metric("total_research_spending")
local balance = Analytics.get_metric("current_balance")

print(string.format("[Analytics] Balance: $%d | Today Earnings: $%d | Research Spending: $%d",
  balance, today_earnings, total_spent))

-- Query economy trend
local economy_events = Analytics.query_events("funds_transaction", {
  start_time = week_ago,
  end_time = now
})

local daily_net = {}
for _, event in ipairs(economy_events) do
  local day = os.date("%Y-%m-%d", event.timestamp)
  daily_net[day] = (daily_net[day] or 0) + event.amount
end

print("[Analytics] Weekly Economy Trend:")
for day, net in pairs(daily_net) do
  print(string.format("  %s: $%d", day, net))
end

-- Console output:
-- [Analytics] Balance: $30000 | Today Earnings: $5000 | Research Spending: $8500
-- [Analytics] Weekly Economy Trend:
--   2025-10-15: $2500
--   2025-10-16: $1200
--   2025-10-17: $3800
--   2025-10-18: -$500 (research)
--   2025-10-19: $4200
--   2025-10-20: $2100
--   2025-10-21: $5000
```

---

## Standard Events Reference

### Mission Events
- `mission_started` - Mission started
- `mission_completed` - Mission completed successfully
- `mission_failed` - Mission failed
- `mission_aborted` - Mission aborted by player
- `unit_killed_in_mission` - Unit KIA in battle

### Combat Events
- `unit_attack` - Unit performed attack
- `unit_took_damage` - Unit received damage
- `unit_defeated_enemy` - Unit killed enemy
- `item_used` - Item/grenade used
- `objective_completed` - Objective completed in battle

### Economy Events
- `funds_transaction` - Money changed
- `item_purchased` - Item bought
- `item_sold` - Item sold
- `research_started` - Research project started
- `research_completed` - Research project finished

### System Events
- `session_started` - Play session began
- `session_ended` - Play session ended
- `save_game` - Game saved
- `load_game` - Game loaded
- `settings_changed` - Settings modified

### Performance Events
- `performance_issue` - Performance degradation detected
- `memory_spike` - Sudden memory usage increase
- `frame_drop` - FPS dropped below threshold
- `resource_loaded` - Asset loaded

---

## Performance Considerations

### Data Storage Optimization
- Events are buffered in memory before flushing to disk
- Configure buffer size based on typical event rate
- Older events automatically archived to reduce database size
- Indexes created on frequently queried fields

### Performance Impact
- Event recording: <0.1ms per event (negligible)
- Metrics aggregation: Batched to reduce overhead
- Performance monitor: Uses circular buffer for memory efficiency
- Reports generated asynchronously to avoid UI blocking

### Best Practices
- Flush analytics data regularly (recommended every 5-10 minutes)
- Archive old data after 30 days to reduce query time
- Use event batching for bulk recordings
- Query events with time ranges for better performance
- Generate reports off-frame during loading screens

### Scaling Considerations
- Event buffer size: 1000-5000 events typical
- Data storage: ~100KB per hour of gameplay
- Memory overhead: ~2-5MB with normal usage
- Query performance: O(n) in event count for linear scans

---

## See Also

- **AI_SYSTEMS.md** - AI behavior tracking events
- **BATTLESCAPE.md** - Combat event details
- **ECONOMY.md** - Economy event specification
- **GEOSCAPE.md** - Mission event tracking
- **INTEGRATION.md** - Event system architecture

---

## Related Systems

### Linked to:
- Battlescape (combat events)
- Geoscape (mission events)
- Basescape (facility events)
- Economy (transaction events)
- UI System (interaction events)

### Depends On:
- Core time/date functions
- Data serialization (JSON/binary)
- Database/storage system
- Mathematical functions

### Used By:
- Balance team (analytics reports)
- QA (testing metrics)
- Players (session statistics)
- Modders (custom analytics)

---

## Implementation Status

### IN DESIGN (Implemented Systems)

**Core Analytics System (`engine/analytics/analytics_system.lua`)**
- Session tracking with unique IDs, start/end times, and duration
- Game statistics collection (missions, casualties, kills, completion rates)
- Economy statistics (income, expenses, funding history)
- Combat statistics (shots, hits, damage dealt/received)
- Unit performance tracking (kills, deaths, accuracy, damage)
- Mission analytics (success rates, time taken, difficulty)
- Research and technology progress tracking
- Base facility and construction statistics
- Data export functionality for external analysis

**Statistics Categories**
- **Session Metrics**: Game time, version tracking, platform data
- **Mission Metrics**: Success/failure rates, completion times, difficulty analysis
- **Combat Metrics**: Accuracy, damage, casualty tracking
- **Economic Metrics**: Income/expense tracking, funding history
- **Unit Metrics**: Individual performance, class effectiveness
- **Progress Metrics**: Research completion, base development

### FUTURE IDEAS (Not Yet Implemented)

**Autonomous Simulation System**
- AI-driven gameplay simulation for testing and balancing
- Automated campaign runs with statistical analysis
- Performance benchmarking against baseline metrics
- Regression testing through automated playthroughs

**Advanced Data Processing**
- Real-time metrics aggregation and alerting
- Custom analytics queries and reporting
- Predictive modeling for player behavior
- Machine learning integration for pattern recognition

**Data Persistence & Storage**
- Parquet/SQL database integration for large-scale data storage
- Time-series data analysis and trending
- Historical data archiving and retrieval
- Cross-session analytics and player progression tracking

**Performance Monitoring**
- FPS tracking and performance bottleneck identification
- Memory usage analysis and leak detection
- Load time monitoring and optimization insights
- System resource utilization tracking

**Advanced Analytics Features**
- Player behavior segmentation and clustering
- Balance validation through statistical testing
- Design iteration support with A/B testing frameworks
- Custom event tracking and funnel analysis

---

**API Version:** 1.0  
**Last Updated:** October 22, 2025  
**Status:** ✅ Production Ready

````
