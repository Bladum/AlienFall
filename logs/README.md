# Logs - Runtime Data & Analytics

**Purpose:** Centralized runtime logging, metrics, and analytics for debugging and optimization  
**Audience:** Developers, AI agents, QA testers, data analysts  
**Status:** Active collection  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Content](#content)
- [Input/Output](#inputoutput)
- [Relations to Other Modules](#relations-to-other-modules)
- [Format Standards](#format-standards)
- [How to Use](#how-to-use)
- [AI Agent Instructions](#ai-agent-instructions)
- [Good Practices](#good-practices)
- [Quick Reference](#quick-reference)

---

## Overview

The `logs/` folder is the **primary data source** for debugging, performance optimization, game balancing, and quality assurance. All runtime output from the engine is written here in structured formats.

**Core Purpose:**
- Debug runtime errors and crashes
- Profile performance bottlenecks
- Track game balance metrics
- Monitor mod loading and validation
- Collect system health data
- Analyze player behavior patterns

**🎯 CRITICAL FOR AI AGENTS:** Always read logs FIRST before proposing fixes or optimizations. This is data-driven development.

---

## Folder Structure

```
logs/
├── README.md                          ← This file
├── .gitignore                         ← Ignore log files in git
│
├── game/                              ← Gameplay Logs
│   ├── game_YYYY-MM-DD.log           ← General gameplay events
│   ├── mission_YYYY-MM-DD.log        ← Mission start/end, results
│   ├── combat_YYYY-MM-DD.log         ← Combat events, actions
│   ├── economy_YYYY-MM-DD.log        ← Economic transactions
│   └── [other gameplay logs]
│
├── tests/                             ← Test Execution Logs
│   ├── test_results_YYYY-MM-DD.log   ← Test pass/fail results
│   ├── test_failures_YYYY-MM-DD.log  ← Failed test details
│   ├── coverage_YYYY-MM-DD.json      ← Code coverage metrics
│   ├── performance_YYYY-MM-DD.json   ← Test performance data
│   └── [test logs]
│
├── mods/                              ← Mod Loading Logs
│   ├── mod_loading_YYYY-MM-DD.log    ← Mod load sequence
│   ├── mod_errors_YYYY-MM-DD.log     ← Mod validation errors
│   ├── mod_conflicts_YYYY-MM-DD.log  ← Content conflicts
│   └── [mod logs]
│
├── system/                            ← Engine System Logs
│   ├── startup_YYYY-MM-DD.log        ← Engine initialization
│   ├── errors_YYYY-MM-DD.log         ← Runtime errors, exceptions
│   ├── warnings_YYYY-MM-DD.log       ← Warnings, deprecated usage
│   ├── performance_YYYY-MM-DD.json   ← FPS, memory, profiling
│   └── [system logs]
│
└── analytics/                         ← Game Analytics & Metrics
    ├── balance_data_YYYY-MM-DD.json  ← Weapon usage, unit survival, etc.
    ├── player_actions_YYYY-MM-DD.json ← Player decision tracking
    ├── difficulty_YYYY-MM-DD.json    ← Success rates, challenge metrics
    └── [analytics data]
```

**Note:** All log files include timestamps and are rotated daily. Old logs are archived after 30 days.

---

## Key Features

- **Structured Logging:** Consistent format across all logs
- **Timestamped:** Every log entry has precise timestamp
- **Categorized:** Logs organized by source (game, tests, mods, system, analytics)
- **JSON Analytics:** Structured data for easy parsing
- **Daily Rotation:** New files daily, prevents huge log files
- **Error Tracking:** Stack traces for debugging
- **Performance Metrics:** FPS, memory, frame times
- **Balance Data:** Real-world usage statistics
- **Test Results:** Complete test execution records

---

## Content

### Log Categories

| Category | Files | Purpose | Format |
|----------|-------|---------|--------|
| **game/** | ~5 types | Gameplay events, player actions | Text |
| **tests/** | ~4 types | Test execution, coverage, performance | Text + JSON |
| **mods/** | ~3 types | Mod loading, errors, conflicts | Text |
| **system/** | ~4 types | Engine health, errors, performance | Text + JSON |
| **analytics/** | ~3 types | Balance data, metrics, telemetry | JSON |

### Log Entry Format

**Text Logs:**
```
[YYYY-MM-DD HH:MM:SS.mmm] [LEVEL] [COMPONENT] Message
[2025-10-28 14:32:15.123] [INFO] [MISSION] Mission started: Terror Site (difficulty: Hard)
[2025-10-28 14:32:20.456] [ERROR] [COMBAT] Invalid target: Unit ID 42 not found
```

**JSON Logs:**
```json
{
  "timestamp": "2025-10-28T14:32:15.123Z",
  "category": "balance",
  "data": {
    "weapon_usage": {
      "rifle": 145,
      "shotgun": 67,
      "sniper": 23
    },
    "hit_rates": {
      "rifle": 0.65,
      "shotgun": 0.78,
      "sniper": 0.45
    }
  }
}
```

### Log Levels

| Level | Use Case | Example |
|-------|----------|---------|
| **DEBUG** | Detailed trace | "Pathfinding: checking hex (5,3)" |
| **INFO** | General events | "Mission started: Terror Site" |
| **WARN** | Potential issues | "Mod uses deprecated field 'accuracy'" |
| **ERROR** | Errors (handled) | "Failed to load asset: sprite.png" |
| **FATAL** | Critical failures | "Out of memory, shutting down" |

---

## Input/Output

### Inputs (What Logs Consume)

| Input | Source | Purpose |
|-------|--------|---------|
| Game events | `engine/**/*.lua` | Record gameplay |
| Test results | `tests2/**/*_test.lua` | Record test execution |
| Mod loading | `engine/mods/mod_loader.lua` | Record mod status |
| System health | `engine/core/*.lua` | Record engine state |
| Analytics | `engine/analytics/*.lua` | Collect metrics |

### Outputs (What Logs Produce)

| Output | Target | Purpose |
|--------|--------|---------|
| Debug info | Developers | Fix bugs |
| Performance data | Developers | Optimize code |
| Balance metrics | Designers | Tune gameplay |
| Test results | QA team | Verify quality |
| Error reports | All | Track issues |

---

## Relations to Other Modules

### Upstream Dependencies (Logs Read From)

```
engine/**/*.lua → logs/**/*.log
    ↓
Engine writes logs during execution

tests2/**/*_test.lua → logs/tests/*.log
    ↓
Tests write execution results

engine/mods/mod_loader.lua → logs/mods/*.log
    ↓
Mod system writes loading status
```

### Downstream Dependencies (Logs Write To)

```
logs/analytics/*.json → design/mechanics/*.md
    ↓
Analytics inform balance decisions

logs/system/errors_*.log → engine/**/*.lua
    ↓
Error logs reveal bugs to fix

logs/tests/coverage_*.json → tests2/**/*_test.lua
    ↓
Coverage data reveals test gaps
```

### Integration Map

| Module | Relationship | Details |
|--------|--------------|---------|
| **engine/** | Input | Engine writes all runtime logs |
| **tests2/** | Input | Tests write execution logs |
| **design/** | Output | Analytics inform design decisions |
| **docs/** | Reference | Logging system pattern |

---

## Format Standards

### Text Log Format

```
[Timestamp] [Level] [Component] Message [Context]

Components:
- Timestamp: YYYY-MM-DD HH:MM:SS.mmm (ISO 8601)
- Level: DEBUG/INFO/WARN/ERROR/FATAL
- Component: System name (UPPERCASE)
- Message: Human-readable description
- Context: Optional key=value pairs

Example:
[2025-10-28 14:32:15.123] [ERROR] [COMBAT] Attack failed unit_id=42 target_id=17 reason="out_of_range"
```

### JSON Log Format

```json
{
  "timestamp": "ISO 8601 format",
  "level": "DEBUG|INFO|WARN|ERROR|FATAL",
  "component": "SYSTEM_NAME",
  "message": "Human readable",
  "context": {
    "key": "value",
    "nested": {
      "data": "structure"
    }
  }
}
```

### File Naming

- Text logs: `[category]_YYYY-MM-DD.log`
- JSON logs: `[category]_YYYY-MM-DD.json`
- Archived: `archive/[category]_YYYY-MM-DD.log.gz`

---

## How to Use

### For Developers (Debugging)

**Finding Errors:**
```bash
# Check recent errors
tail -n 50 logs/system/errors_*.log

# Find specific error
grep "ERROR" logs/game/game_*.log

# Search across all logs
grep -r "NullPointerException" logs/

# Watch live logs
tail -f logs/system/errors_*.log
```

**Reading Stack Traces:**
```
[2025-10-28 14:32:15.123] [ERROR] [COMBAT] Attack resolution failed
Stack trace:
  engine/battlescape/combat_resolver.lua:45: in function 'resolveAttack'
  engine/battlescape/battle_manager.lua:123: in function 'processTurn'
  engine/core/state_manager.lua:78: in function 'update'
```

**Performance Profiling:**
```bash
# Check FPS and frame times
cat logs/system/performance_*.json | jq '.fps, .frame_time'

# Find slow functions
cat logs/system/performance_*.json | jq '.slow_functions[]'
```

### For Designers (Balancing)

**Reading Balance Data:**
```bash
# Check weapon usage
cat logs/analytics/balance_data_*.json | jq '.weapon_usage'

# Check unit survival rates
cat logs/analytics/balance_data_*.json | jq '.unit_survival'

# Difficulty metrics
cat logs/analytics/difficulty_*.json | jq '.mission_success_rate'
```

**Example Balance Decision:**
```json
{
  "weapon_usage": {
    "rifle": 0.78,      ← Too high (overpowered)
    "shotgun": 0.15,    ← Too low (underpowered)
    "sniper": 0.07
  }
}

Action: Nerf rifle accuracy, buff shotgun damage
```

### For QA (Testing)

**Checking Test Results:**
```bash
# Latest test results
cat logs/tests/test_results_*.log | tail -n 50

# Failed tests only
cat logs/tests/test_failures_*.log

# Coverage report
cat logs/tests/coverage_*.json | jq '.coverage_percentage'
```

### For AI Agents

See [AI Agent Instructions](#ai-agent-instructions) section below.

---

## AI Agent Instructions

### When to Read Logs

| Scenario | Logs to Read | Action |
|----------|--------------|--------|
| **User reports bug** | `logs/system/errors_*.log` | Find stack trace, fix bug |
| **Performance issue** | `logs/system/performance_*.json` | Profile, optimize bottlenecks |
| **Balance problem** | `logs/analytics/balance_data_*.json` | Identify imbalance, tune values |
| **Test failure** | `logs/tests/test_failures_*.log` | Find failure reason, fix code |
| **Mod not loading** | `logs/mods/mod_errors_*.log` | Find validation error, fix TOML |

### Log-Driven Workflow

```
1. User reports issue
    ↓
2. Identify relevant log category:
   - Bug/crash? → logs/system/errors_*.log
   - Performance? → logs/system/performance_*.json
   - Balance? → logs/analytics/balance_data_*.json
   - Test? → logs/tests/test_failures_*.log
   - Mod? → logs/mods/mod_errors_*.log
    ↓
3. Read log file (most recent)
    ↓
4. Analyze data:
   - Error: Read stack trace, find line number
   - Performance: Identify slow functions
   - Balance: Find statistical outliers
   - Test: Read failure reason
   - Mod: Read validation error
    ↓
5. Propose fix based on data
    ↓
6. Implement fix
    ↓
7. Verify in new logs (error gone, metrics improved)
    ↓
8. Report success with before/after data
```

### Reading Performance Logs

```json
{
  "timestamp": "2025-10-28T14:32:15.123Z",
  "fps": 45,                    ← Low FPS (target 60)
  "frame_time_ms": 22,          ← High frame time
  "memory_mb": 512,
  "slow_functions": [           ← Bottlenecks
    {
      "function": "pathfinding.findPath",
      "time_ms": 15,            ← Takes 15ms (too slow)
      "calls": 23
    }
  ]
}

AI Action:
1. Identify slow function: pathfinding.findPath
2. Profile that function in engine/battlescape/pathfinding.lua
3. Optimize algorithm (A* → JPS, caching, etc.)
4. Verify FPS improves in next performance log
```

### Reading Balance Logs

```json
{
  "weapon_usage": {
    "rifle": 0.78,      ← 78% of attacks use rifle (overpowered)
    "shotgun": 0.15,
    "sniper": 0.07
  },
  "weapon_hit_rates": {
    "rifle": 0.85,      ← 85% hit rate (too high)
    "shotgun": 0.65,
    "sniper": 0.45
  }
}

AI Action:
1. Identify imbalance: rifle overpowered
2. Update design/mechanics/Items.md (reduce rifle accuracy)
3. Update mods/core/rules/items/weapons.toml (accuracy: 75% → 65%)
4. Verify usage drops to ~50% in next analytics
```

### Common AI Tasks

| Task | Log Analysis Steps |
|------|-------------------|
| **Fix crash** | 1. Read logs/system/errors_*.log<br>2. Find stack trace<br>3. Locate file:line<br>4. Fix bug<br>5. Verify error gone |
| **Optimize** | 1. Read logs/system/performance_*.json<br>2. Identify slow functions<br>3. Profile code<br>4. Optimize<br>5. Verify FPS improved |
| **Balance** | 1. Read logs/analytics/balance_data_*.json<br>2. Find outliers<br>3. Update design + TOML<br>4. Verify metrics normalized |
| **Fix test** | 1. Read logs/tests/test_failures_*.log<br>2. Find failure reason<br>3. Fix code<br>4. Verify test passes |

---

## Good Practices

### ✅ Logging

- Log at appropriate level (DEBUG/INFO/WARN/ERROR)
- Include context (unit_id, position, etc.)
- Use structured format (JSON for analytics)
- Rotate logs daily
- Archive old logs
- Don't log sensitive data

### ✅ Analytics

- Collect meaningful metrics
- Aggregate data over time
- Use JSON for structured data
- Track both successes and failures
- Respect player privacy

### ✅ Performance

- Profile regularly
- Track frame times
- Monitor memory usage
- Identify bottlenecks
- Benchmark optimizations

---

## Quick Reference

### Essential Log Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `system/errors_*.log` | Runtime errors | Debugging crashes |
| `system/performance_*.json` | Performance metrics | Optimization |
| `analytics/balance_data_*.json` | Game balance | Tuning gameplay |
| `tests/test_failures_*.log` | Failed tests | Fixing tests |
| `mods/mod_errors_*.log` | Mod errors | Mod debugging |

### Quick Commands

```bash
# Find recent errors
tail -n 100 logs/system/errors_*.log

# Watch live logs
tail -f logs/system/errors_*.log

# Search for text
grep -r "ERROR" logs/

# Parse JSON logs
cat logs/analytics/balance_data_*.json | jq '.weapon_usage'

# Count log entries
grep -c "ERROR" logs/system/errors_*.log
```

### Related Documentation

- **Engine:** [engine/README.md](../engine/README.md) - What writes logs
- **Tests:** [tests2/README.md](../tests2/README.md) - Test logging
- **Design:** [design/README.md](../design/README.md) - Balance decisions
- **Docs:** [docs/system/09_LOGGING_AND_ANALYTICS_SYSTEM.md](../docs/system/09_LOGGING_AND_ANALYTICS_SYSTEM.md) - Logging pattern

---

**Last Updated:** 2025-10-28  
**Maintainers:** Engine Team  
**Questions:** See [docs/instructions/](../docs/instructions/) or ask in project Discord

