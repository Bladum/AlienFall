# Logs System - Runtime Output & Analytics

**Purpose:** Centralized logging for all runtime output, error tracking, and analytics data  
**Audience:** AI agents, developers, analytics systems, QA  
**Critical:** Used for auto-balancing, error fixing, test improvement, and system optimization

---

## 📁 Folder Structure

```
logs/
├── README.md                    ← You are here
│
├── game/                        Game runtime logs
│   ├── game_YYYY-MM-DD_HH-MM-SS.log
│   └── crash_YYYY-MM-DD_HH-MM-SS.log
│
├── tests/                       Test execution logs
│   ├── test_run_YYYY-MM-DD_HH-MM-SS.log
│   ├── test_failures_YYYY-MM-DD.log
│   └── coverage_YYYY-MM-DD.json
│
├── mods/                        Mod loading and runtime logs
│   ├── mod_load_YYYY-MM-DD_HH-MM-SS.log
│   └── mod_errors_YYYY-MM-DD.log
│
├── system/                      System-level logs (engine, core)
│   ├── engine_YYYY-MM-DD_HH-MM-SS.log
│   └── performance_YYYY-MM-DD.json
│
└── analytics/                   Analytics and metrics
    ├── gameplay_metrics_YYYY-MM-DD.json
    ├── balance_data_YYYY-MM-DD.json
    └── user_behavior_YYYY-MM-DD.json
```

---

## 🎯 Log Types & Purposes

### game/ - Game Runtime Logs
**Purpose:** Track gameplay events, player actions, game state changes

**Contents:**
- Player actions (mission started, unit moved, shot fired)
- Game state transitions (turn started, combat resolved)
- Resource changes (money spent, research completed)
- Mission outcomes (victory, defeat, casualties)
- Performance metrics (FPS, memory usage)

**Used By:**
- Analytics system for balance analysis
- AI agents for understanding gameplay flow
- QA for reproducing bugs
- Developers for debugging

**Example:**
```
[2025-10-27 14:32:15] [MISSION] Mission started: Terror Mission, Location: New York
[2025-10-27 14:32:18] [UNIT] Soldier 'John Doe' moved from (5,3) to (7,3)
[2025-10-27 14:32:20] [COMBAT] Soldier 'John Doe' fired at Sectoid (Hit: 85%, Damage: 12)
[2025-10-27 14:32:20] [ENEMY] Sectoid killed, XP awarded: 5
```

---

### tests/ - Test Execution Logs
**Purpose:** Track test runs, failures, coverage, performance

**Contents:**
- Test execution results (pass/fail counts)
- Failure details (stack traces, assertions)
- Coverage reports (% tested, untested modules)
- Performance data (test runtime, memory)
- Regression detection (new failures)

**Used By:**
- AI agents for fixing failing tests
- AI agents for improving test coverage
- Developers for debugging tests
- CI/CD for automated validation

**Example:**
```
[2025-10-27 14:45:10] [TEST] Running subsystem: battlescape
[2025-10-27 14:45:11] [PASS] battlescape/combat_resolver_test.lua (12/12 tests)
[2025-10-27 14:45:11] [FAIL] battlescape/pathfinding_test.lua (11/12 tests)
[2025-10-27 14:45:11] [ERROR] Test 'pathfinding with obstacles' failed: Expected path length 8, got 10
[2025-10-27 14:45:11] [COVERAGE] battlescape: 87% (23/26 modules tested)
```

---

### mods/ - Mod Loading & Runtime Logs
**Purpose:** Track mod loading, conflicts, errors, content registration

**Contents:**
- Mod discovery (found mods, load order)
- Dependency resolution (missing deps, conflicts)
- Content registration (units, items, rules loaded)
- Override tracking (which mod overrides what)
- Runtime errors (script errors, invalid data)

**Used By:**
- AI agents for fixing mod compatibility issues
- Developers for debugging mod system
- Modders for troubleshooting their mods
- Players for understanding mod conflicts

**Example:**
```
[2025-10-27 15:00:05] [MOD] Discovered: core v1.0.0
[2025-10-27 15:00:05] [MOD] Discovered: alien_expansion v1.2.0
[2025-10-27 15:00:05] [MOD] Loading: core (dependencies: none)
[2025-10-27 15:00:06] [MOD] Loaded 45 units, 120 items, 15 missions from core
[2025-10-27 15:00:06] [MOD] Loading: alien_expansion (dependencies: core)
[2025-10-27 15:00:06] [MOD] Override: unit 'sectoid' (core → alien_expansion)
[2025-10-27 15:00:06] [ERROR] Invalid item schema: 'plasma_rifle' missing required field 'damage'
```

---

### system/ - System-Level Logs
**Purpose:** Track engine initialization, core systems, performance

**Contents:**
- Engine startup (Love2D version, OS, hardware)
- Core system initialization (state manager, mod loader)
- Configuration loading (settings, keybinds)
- Performance metrics (frame time, memory, GC)
- Warnings (deprecated APIs, missing assets)

**Used By:**
- AI agents for diagnosing system issues
- Developers for performance optimization
- QA for identifying platform-specific bugs
- Support for troubleshooting user issues

**Example:**
```
[2025-10-27 14:30:00] [ENGINE] Love2D 11.5, OS: Windows 10, Renderer: OpenGL 4.6
[2025-10-27 14:30:00] [CORE] Initializing StateManager...
[2025-10-27 14:30:00] [CORE] Initializing ModLoader...
[2025-10-27 14:30:01] [CORE] Loaded 3 mods (core, alien_expansion, quality_of_life)
[2025-10-27 14:30:01] [PERF] Startup time: 1.23s, Memory: 45MB
[2025-10-27 14:30:01] [WARN] Asset missing: 'ui/icon_research.png' (using placeholder)
```

---

### analytics/ - Analytics & Metrics
**Purpose:** Aggregate data for balance analysis, player behavior, system health

**Contents:**
- Gameplay metrics (win rates, mission completion times)
- Balance data (weapon usage, unit survival rates)
- Player behavior (most used strategies, common mistakes)
- System health (crash rates, error frequency)
- Performance trends (FPS over time, memory leaks)

**Used By:**
- **AI agents for auto-balancing game mechanics**
- **AI agents for improving game design**
- Analytics system for generating reports
- Designers for balance decisions
- Developers for optimization priorities

**Example (JSON):**
```json
{
  "date": "2025-10-27",
  "gameplay": {
    "missions_played": 42,
    "victory_rate": 0.73,
    "average_mission_time": 18.5,
    "soldier_death_rate": 0.12
  },
  "balance": {
    "weapon_usage": {
      "rifle": 0.45,
      "shotgun": 0.25,
      "sniper": 0.20,
      "rocket": 0.10
    },
    "unit_survival": {
      "rookie": 0.65,
      "squaddie": 0.78,
      "veteran": 0.89
    }
  }
}
```

---

## 🤖 AI Agent Usage

### Critical: AI agents MUST read logs for:

1. **Error Fixing:**
   - Read `logs/tests/` for failing tests
   - Read `logs/game/` for runtime crashes
   - Read `logs/mods/` for mod errors
   - Identify patterns, fix root causes

2. **Test Improvement:**
   - Read `logs/tests/test_failures_*.log` for common failures
   - Read `logs/tests/coverage_*.json` for untested modules
   - Generate new tests for untested code
   - Improve test coverage

3. **Game Balancing:**
   - Read `logs/analytics/balance_data_*.json` for usage patterns
   - Identify overpowered/underpowered content
   - Propose balance changes
   - Update design/ and mods/core/rules/

4. **Performance Optimization:**
   - Read `logs/system/performance_*.json` for bottlenecks
   - Identify slow functions, memory leaks
   - Optimize critical paths
   - Validate improvements

5. **Mod Compatibility:**
   - Read `logs/mods/mod_errors_*.log` for conflicts
   - Fix mod loading issues
   - Improve mod system robustness

---

## 📊 Log Format Standards

### Timestamp Format
**Standard:** `[YYYY-MM-DD HH:MM:SS]` (ISO 8601, 24-hour)

### Log Level
**Levels:** `[DEBUG]` `[INFO]` `[WARN]` `[ERROR]` `[FATAL]`

### Component Tag
**Format:** `[COMPONENT]` (e.g., `[MISSION]`, `[UNIT]`, `[MOD]`, `[ENGINE]`)

### Full Format
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] [COMPONENT] Message with details
```

### Example
```
[2025-10-27 14:32:15] [INFO] [MISSION] Mission started: Terror Mission
[2025-10-27 14:32:20] [ERROR] [COMBAT] Invalid target: Unit ID 42 not found
[2025-10-27 14:32:25] [WARN] [MOD] Deprecated field 'accuracy' in weapon schema
```

---

## 🔄 Log Rotation

**Policy:** Keep logs organized, prevent disk overflow

**Rules:**
- One log file per session (timestamped filename)
- Keep last 30 days of logs
- Archive older logs to `logs/archive/`
- Compress archived logs (`.log.gz`)
- Delete archives older than 90 days

**Auto-cleanup:** Run `tools/log_cleanup.lua` weekly

---

## 🛠️ Implementation

### Logging in Lua (Love2D)
```lua
-- In engine/core/logger.lua
local Logger = {}
Logger.file = nil

function Logger:init()
    local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
    local filename = string.format("logs/game/game_%s.log", timestamp)
    self.file = io.open(filename, "w")
end

function Logger:log(level, component, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local line = string.format("[%s] [%s] [%s] %s\n", 
                               timestamp, level, component, message)
    if self.file then
        self.file:write(line)
        self.file:flush()  -- Immediate write for crash recovery
    end
    print(line)  -- Also print to console
end

function Logger:close()
    if self.file then
        self.file:close()
    end
end

return Logger
```

### Usage in Code
```lua
local Logger = require("engine.core.logger")

-- In main.lua
function love.load()
    Logger:init()
    Logger:log("INFO", "ENGINE", "Game started")
end

-- In battlescape
function Mission:start()
    Logger:log("INFO", "MISSION", string.format("Mission started: %s", self.name))
end

-- On error
function love.errhand(msg)
    Logger:log("FATAL", "ENGINE", string.format("Crash: %s", msg))
    Logger:close()
end
```

---

## 🔗 Integration with Other Systems

### Analytics System (engine/analytics/)
```lua
-- Reads from logs/game/ and logs/analytics/
-- Aggregates metrics for balance analysis
-- Writes reports to logs/analytics/
```

### Test Framework (tests2/)
```lua
-- Writes test results to logs/tests/
-- Tracks coverage, failures, performance
```

### Mod Loader (engine/mods/)
```lua
-- Writes mod loading info to logs/mods/
-- Tracks conflicts, errors, content registration
```

### QA System (tools/qa_system/)
```lua
-- Reads all logs for automated issue detection
-- Generates reports in temp/
-- Triggers alerts for critical issues
```

---

## 📈 Success Metrics

**Log System Health:**
- ✅ All runtime output captured (no silent failures)
- ✅ Logs parseable by automated tools
- ✅ Timestamps accurate and consistent
- ✅ No disk overflow (rotation working)
- ✅ AI agents successfully using logs

**AI Agent Effectiveness:**
- ✅ Errors fixed by reading logs
- ✅ Tests improved by coverage analysis
- ✅ Game balanced using analytics data
- ✅ Performance optimized using metrics

---

## 🚀 Quick Start

### For Developers
1. Run game: `lovec "engine"` → logs in `logs/game/`
2. Run tests: `lovec "tests2/runners" run_all` → logs in `logs/tests/`
3. Check logs after errors
4. Use logs to reproduce bugs

### For AI Agents
1. Before fixing errors: Read `logs/tests/` or `logs/game/`
2. Before balancing: Read `logs/analytics/balance_data_*.json`
3. Before optimizing: Read `logs/system/performance_*.json`
4. After changes: Verify logs show improvements

### For Analytics
1. Read `logs/analytics/*.json` for aggregate metrics
2. Generate reports in `temp/analytics_reports/`
3. Update balance in `mods/core/rules/`


