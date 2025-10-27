7)# Logging and Analytics System
**Pattern: Centralized Runtime Output for Debugging, Analytics, and AI Agent Intelligence**

**Purpose:** Capture all runtime behavior for error diagnosis, performance optimization, and automated balancing  
**Problem Solved:** Silent failures, unclear debugging, manual balance tuning, reactive problem-solving  
**Universal Pattern:** Applicable to any software project requiring observability and data-driven improvements

---

## 🎯 Core Concept

**Principle:** Every runtime event is logged in structured format, making the system observable, debuggable, and self-improving.

```
RUNTIME EVENTS
↓ Log to structured files
LOGS FOLDER (game/, tests/, mods/, system/, analytics/)
↓ Read by
AI AGENTS + ANALYTICS + DEVELOPERS
↓ Used for
ERROR FIXING + OPTIMIZATION + BALANCE + IMPROVEMENT
```

---

## 📁 System Architecture

### Concern 1: LOG COLLECTION (logs/ folder)

**Purpose:** Centralized storage for all runtime output with categorization

**Structure:**
```
logs/
├── game/           Runtime gameplay logs
├── tests/          Test execution logs
├── mods/           Mod loading logs
├── system/         Engine/core logs
└── analytics/      Aggregated metrics
```

**Format:**
- Text logs: `[TIMESTAMP] [LEVEL] [COMPONENT] Message`
- JSON metrics: Structured data for analytics
- Timestamped files: One file per session
- Rotation: Keep 30 days, archive 90 days

**Input:** Runtime events from all subsystems  
**Output:** Structured logs for consumption

**Validation Rules:**
- ✅ All output goes to logs/ (never system TEMP)
- ✅ Timestamps in ISO 8601 format
- ✅ Log levels: DEBUG, INFO, WARN, ERROR, FATAL
- ✅ Component tags for filtering
- ✅ JSON for structured data
- ❌ No sensitive data (passwords, keys)
- ❌ No excessive logging (>1000 lines/sec)

---

### Concern 2: LOG PRODUCERS (All Subsystems)

**Purpose:** Generate logs from all runtime activities

**Producers:**
- **Game (engine/):** Player actions, state changes, events
- **Tests (tests2/):** Test runs, failures, coverage
- **Mods (mods/):** Loading, conflicts, errors
- **System (engine/core/):** Startup, performance, warnings
- **Analytics (engine/analytics/):** Aggregated metrics

**Implementation:**
```lua
-- Centralized logger (engine/core/logger.lua)
local Logger = {}

function Logger:log(level, component, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local line = string.format("[%s] [%s] [%s] %s\n", 
                               timestamp, level, component, message)
    self:write_to_file(line)
    print(line)  -- Also console output
end
```

**Usage:**
```lua
Logger:log("INFO", "MISSION", "Mission started: Terror Site")
Logger:log("ERROR", "COMBAT", "Invalid target: Unit not found")
```

---

### Concern 3: LOG CONSUMERS (AI Agents + Tools)

**Purpose:** Read logs to fix errors, optimize, and improve

**Consumers:**

#### 1. AI Agents (Primary Consumer)
**Use Cases:**
- **Error Fixing:** Read `logs/tests/` or `logs/game/` to identify failures, fix root causes
- **Test Improvement:** Read coverage reports, generate tests for untested code
- **Game Balancing:** Read `logs/analytics/` to identify overpowered/underpowered content
- **Performance Optimization:** Read `logs/system/` to find bottlenecks, memory leaks
- **Mod Compatibility:** Read `logs/mods/` to fix conflicts, improve loader

**Workflow:**
```
1. User reports issue OR Test fails
   ↓
2. AI agent reads relevant logs
   ↓
3. Identifies root cause (stack trace, metrics)
   ↓
4. Proposes fix (code changes, balance tweaks)
   ↓
5. Implements fix
   ↓
6. Verifies in logs (error gone, metrics improved)
```

#### 2. Analytics System (engine/analytics/)
**Use Cases:**
- Aggregate gameplay metrics (win rates, completion times)
- Identify balance issues (weapon usage, unit survival)
- Track player behavior (strategies, common mistakes)
- Generate reports for designers

#### 3. Developers
**Use Cases:**
- Debug issues (reproduce from logs)
- Profile performance (identify slow functions)
- Monitor system health (error rates, warnings)
- Validate changes (before/after metrics)

#### 4. QA System (tools/qa_system/)
**Use Cases:**
- Automated issue detection (error patterns)
- Regression detection (new failures)
- Health monitoring (crash rates)
- Alert generation (critical issues)

---

## 🎯 Log Categories Explained

### game/ - Runtime Gameplay Logs

**Purpose:** Track player actions and game state

**Contents:**
- Mission events (started, completed, failed)
- Unit actions (moved, attacked, died)
- Resource changes (money, research, manufacturing)
- State transitions (turn started, combat resolved)

**Example:**
```
[2025-10-27 14:32:15] [INFO] [MISSION] Started: Terror Mission, Location: NYC
[2025-10-27 14:32:20] [INFO] [COMBAT] Soldier 'John' hit Sectoid (dmg: 12)
[2025-10-27 14:32:20] [INFO] [ENEMY] Sectoid killed, XP: 5
[2025-10-27 14:32:25] [WARN] [AI] No valid targets for Sectoid
```

**AI Agent Use:**
- Identify gameplay issues (AI getting stuck)
- Balance analysis (too easy/hard)
- Bug reproduction (exact sequence of events)

---

### tests/ - Test Execution Logs

**Purpose:** Track test runs and failures

**Contents:**
- Test execution (pass/fail counts)
- Failure details (stack traces, assertions)
- Coverage reports (% tested, missing modules)
- Performance data (runtime, memory)

**Example:**
```
[2025-10-27 14:45:10] [INFO] [TEST] Running: battlescape subsystem
[2025-10-27 14:45:11] [PASS] combat_resolver_test (12/12)
[2025-10-27 14:45:11] [FAIL] pathfinding_test (11/12)
[2025-10-27 14:45:11] [ERROR] 'pathfinding with obstacles' failed
    Expected path length: 8
    Actual path length: 10
    Stack: tests2/battlescape/pathfinding_test.lua:45
```

**AI Agent Use:**
- Fix failing tests (read stack trace, understand failure)
- Improve coverage (identify untested modules)
- Optimize slow tests (read performance data)

---

### mods/ - Mod Loading Logs

**Purpose:** Track mod system behavior

**Contents:**
- Mod discovery (found mods, load order)
- Dependency resolution (missing, conflicts)
- Content registration (units, items loaded)
- Override tracking (mod priorities)
- Runtime errors (script errors, invalid data)

**Example:**
```
[2025-10-27 15:00:05] [INFO] [MOD] Found: core v1.0.0
[2025-10-27 15:00:05] [INFO] [MOD] Found: alien_expansion v1.2.0
[2025-10-27 15:00:06] [INFO] [MOD] Loaded core: 45 units, 120 items
[2025-10-27 15:00:06] [WARN] [MOD] Override: unit 'sectoid' (core → alien_expansion)
[2025-10-27 15:00:06] [ERROR] [MOD] Invalid schema: 'plasma_rifle' missing 'damage'
```

**AI Agent Use:**
- Fix mod compatibility (resolve conflicts)
- Validate mod content (schema errors)
- Improve mod system (better error messages)

---

### system/ - Engine/Core Logs

**Purpose:** Track engine initialization and performance

**Contents:**
- Startup (Love2D version, OS, hardware)
- Core systems (state manager, mod loader)
- Configuration (settings, keybinds)
- Performance (frame time, memory, GC)
- Warnings (deprecated APIs, missing assets)

**Example:**
```
[2025-10-27 14:30:00] [INFO] [ENGINE] Love2D 11.5, Windows 10, OpenGL 4.6
[2025-10-27 14:30:00] [INFO] [CORE] StateManager initialized
[2025-10-27 14:30:01] [INFO] [CORE] Loaded 3 mods
[2025-10-27 14:30:01] [PERF] Startup: 1.23s, Memory: 45MB
[2025-10-27 14:30:01] [WARN] Missing asset: 'ui/icon_research.png'
```

**AI Agent Use:**
- Diagnose startup issues (missing dependencies)
- Optimize performance (slow initialization)
- Platform compatibility (OS-specific bugs)

---

### analytics/ - Aggregated Metrics

**Purpose:** Structured data for balance analysis

**Contents (JSON):**
- Gameplay metrics (win rates, completion times)
- Balance data (weapon usage, unit survival)
- Player behavior (strategies, mistakes)
- System health (crash rates, errors)

**Example (balance_data_2025-10-27.json):**
```json
{
  "date": "2025-10-27",
  "weapon_usage": {
    "rifle": 0.45,
    "shotgun": 0.25,
    "sniper": 0.20,
    "rocket": 0.10
  },
  "unit_survival": {
    "rookie": 0.65,
    "veteran": 0.89
  },
  "mission_outcomes": {
    "victory": 0.73,
    "defeat": 0.27
  }
}
```

**AI Agent Use:**
- **Auto-balance game:** If weapon_usage["rifle"] > 0.50, reduce rifle effectiveness
- **Identify issues:** If unit_survival["rookie"] < 0.30, rookies too weak
- **Design improvements:** If mission_outcomes["defeat"] > 0.50, missions too hard

---

## 🔄 Workflow: From Log to Improvement

### Example 1: AI Agent Fixes Failing Test

```
1. Test fails: pathfinding_test.lua (11/12 pass)
   ↓
2. AI agent reads logs/tests/test_failures_2025-10-27.log
   ↓
3. Identifies issue: "Expected path length 8, got 10"
   ↓
4. Reads engine/battlescape/pathfinding.lua
   ↓
5. Identifies bug: Not accounting for diagonal movement cost
   ↓
6. Fixes code: Update pathfinding algorithm
   ↓
7. Runs tests again: All 12/12 pass
   ↓
8. Verifies in logs: No more failures
```

---

### Example 2: AI Agent Auto-Balances Game

```
1. Analytics runs weekly, generates logs/analytics/balance_data_2025-10-27.json
   ↓
2. AI agent reads analytics data
   ↓
3. Identifies issue: weapon_usage["rifle"] = 0.78 (overpowered)
   ↓
4. Reads design/mechanics/Combat.md for balance guidelines
   ↓
5. Proposes change: Reduce rifle accuracy from 75% to 65%
   ↓
6. Updates mods/core/rules/items/weapons.toml
   ↓
7. Updates design/mechanics/Combat.md with rationale
   ↓
8. Runs game, collects new analytics
   ↓
9. Verifies: weapon_usage["rifle"] = 0.52 (balanced)
```

---

### Example 3: Developer Debugs Crash

```
1. User reports crash during mission
   ↓
2. Developer reads logs/game/crash_2025-10-27_14-32-15.log
   ↓
3. Finds stack trace: engine/battlescape/combat.lua:142
   ↓
4. Identifies cause: Nil reference when unit dies during reaction fire
   ↓
5. Fixes code: Add nil check before accessing unit
   ↓
6. Runs game, cannot reproduce crash
   ↓
7. Verifies: No crashes in logs/game/ after fix
```

---

## 🛠️ Implementation Checklist

### Phase 1: Basic Logging
- [ ] Create logs/ folder structure
- [ ] Implement Logger class (engine/core/logger.lua)
- [ ] Add logging to main.lua (startup, shutdown)
- [ ] Add logging to state manager (state transitions)
- [ ] Test: Run game, verify logs/game/ populated

### Phase 2: Comprehensive Logging
- [ ] Add logging to battlescape (missions, combat)
- [ ] Add logging to geoscape (world events, UFOs)
- [ ] Add logging to basescape (construction, research)
- [ ] Add logging to economy (purchases, sales)
- [ ] Test: Play game, verify all actions logged

### Phase 3: Test Logging
- [ ] Update test framework to log results (logs/tests/)
- [ ] Log failures with stack traces
- [ ] Generate coverage reports (JSON)
- [ ] Test: Run tests, verify logs/tests/ populated

### Phase 4: Mod Logging
- [ ] Add logging to mod loader (discovery, loading)
- [ ] Log content registration (units, items)
- [ ] Log overrides and conflicts
- [ ] Test: Load mods, verify logs/mods/ populated

### Phase 5: Analytics
- [ ] Implement analytics aggregator (engine/analytics/)
- [ ] Read logs/game/, generate metrics
- [ ] Write to logs/analytics/ (JSON)
- [ ] Test: Run analytics, verify JSON output

### Phase 6: AI Agent Integration
- [ ] Document log reading patterns (for AI agents)
- [ ] Create examples of log-based debugging
- [ ] Test AI agent reading logs and proposing fixes
- [ ] Verify improvements (errors fixed, balance improved)

---

## 📊 Success Metrics

**System Health:**
- ✅ 100% of runtime output captured
- ✅ Logs parseable by automated tools
- ✅ No disk overflow (rotation working)
- ✅ Timestamps accurate, consistent

**AI Agent Effectiveness:**
- ✅ Errors fixed by reading logs (>80% success rate)
- ✅ Tests improved using coverage data
- ✅ Game balanced using analytics (weapon usage within 0.30-0.40 range)
- ✅ Performance optimized using metrics (FPS improved >10%)

**Developer Productivity:**
- ✅ Bugs reproduced from logs (>90% reproducible)
- ✅ Time to fix reduced (50% faster with logs)
- ✅ QA automation working (alerts triggered)

---

## 🌍 Universal Adaptation

### For Web Applications
```
logs/
├── requests/        HTTP request logs
├── database/        Query logs, slow queries
├── users/           User actions, sessions
├── errors/          Application errors
└── analytics/       User behavior, A/B tests
```

### For Data Pipelines
```
logs/
├── ingestion/       Data ingestion logs
├── processing/      ETL job logs
├── validation/      Data quality logs
├── outputs/         Sink/export logs
└── analytics/       Pipeline performance
```

### For Mobile Apps
```
logs/
├── app/             App lifecycle, crashes
├── network/         API calls, latency
├── user/            User interactions
├── performance/     FPS, memory, battery
└── analytics/       Usage patterns
```

### For Embedded Systems
```
logs/
├── sensors/         Sensor readings
├── control/         Control loop logs
├── errors/          Fault detection
├── performance/     Timing, resources
└── analytics/       System health
```

---

## 🎓 Key Takeaways

1. **Observability First:** If you can't see it, you can't fix it
2. **Structure Matters:** Categorized logs enable automation
3. **AI Agent Intelligence:** Logs are food for AI-driven improvements
4. **Balance by Data:** Analytics enable automated game balancing
5. **Proactive, Not Reactive:** Logs enable prevention, not just fixes

---

## 🔗 Integration Points

**Related Systems:**
- [Separation of Concerns](01_SEPARATION_OF_CONCERNS_SYSTEM.md) - Logs in their own folder
- [Pipeline Architecture](02_PIPELINE_ARCHITECTURE_SYSTEM.md) - Logs at each stage
- [Hierarchical Testing](04_HIERARCHICAL_TESTING_SYSTEM.md) - Test logs for coverage
- [Automation Tools](06_AUTOMATION_TOOLS_SYSTEM.md) - Tools read logs
- [AI Guidance](07_AI_GUIDANCE_SYSTEM.md) - AI agents consume logs

**Files:**
- logs/ (primary folder)
- engine/core/logger.lua (implementation)
- engine/analytics/ (analytics system)
- tools/qa_system/ (automated analysis)

---

**Last Updated:** 2025-10-27  
**Status:** 🟢 Pattern documented, ready for implementation  
**Next Step:** Implement Logger class in engine/core/logger.lua

