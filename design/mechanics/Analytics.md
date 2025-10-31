# Analytics System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: ai_systems.md, Economy.md, Units.md, Battlescape.md

## Table of Contents

- [Overview](#overview)
- [Stage 1: Autonomous Simulation & Log Capture](#stage-1-autonomous-simulation--log-capture)
- [Stage 2: Data Aggregation & Processing](#stage-2-data-aggregation--processing)
- [Stage 3: Metric Calculation](#stage-3-metric-calculation)
- [Stage 4: Insights & Visualization](#stage-4-insights--visualization)
- [Stage 5: Action Planning](#stage-5-action-planning)

---

## Overview

### System Architecture

Analytics is a comprehensive data collection, processing, and analysis framework that enables continuous game balance improvement, performance optimization, and design validation. The system operates on a five-stage pipeline: autonomous simulation → log capture → data aggregation → metric calculation → action planning. All analytics data flows through structured, queryable formats (Parquet, SQL) enabling rapid insights and automated decision-making.

### Design Philosophy

Analytics enables data-driven game design through continuous feedback loops. Rather than relying on manual playtesting or intuition, the analytics system captures millions of game events, extracts meaningful patterns, and surfaces actionable insights. The system supports both automated AI-driven testing and organic player-generated data, creating a unified data corpus for holistic game understanding.

### Strategic Purpose

- **Balance Validation**: Verify that game mechanics function as intended
- **Performance Profiling**: Identify bottlenecks and optimization opportunities
- **Design Verification**: Confirm design goals are met through gameplay data
- **Player Behavior**: Understand how players interact with systems
- **Early Warning**: Detect issues before they reach players
- **Iteration Support**: Quantify improvements across versions

---

## Stage 1: Autonomous Simulation & Log Capture

### Overview

Autonomous simulations run miniature game instances where AI agents execute both strategic decisions (faction operations) and tactical decisions (player actions including UI clicks). Simulations execute entirely in backend, generating granular logs of all game events.

### Simulation Types

| Simulation Type | Scope | Duration | Frequency | Purpose |
|---|---|---|---|---|
| **Geoscape Simulation** | Strategic layer only | 12-24 hours/day | Continuous | Mission generation, diplomacy, funding |
| **Basescape Simulation** | Base management only | 30-day cycles | Daily | Research, manufacturing, facility management |
| **Interception Simulation** | Craft vs UFO combat | Single engagement | Per-encounter | Defense systems, craft effectiveness |
| **Battlescape Simulation** | Tactical ground combat | Single mission | Per-mission | Unit balance, weapon effectiveness, AI tactics |
| **Full Campaign Simulation** | All systems integrated | 6-12 months gameplay | Weekly | Emergent interactions, long-term dynamics |

### Dual AI Architecture

- **Faction AI**: Native game AI executing enemy strategy (campaign generation, unit deployment, tactical decisions)
- **Player AI**: Separate meta-AI making high-level strategic decisions mimicking human player behavior (base building, research prioritization, craft deployment, UI interaction patterns)
- **Interaction Layer**: Player AI receives game state, makes decisions, translates to actions/UI clicks, feeds into Faction AI reactions

### Player AI Decision-Making
```
Player AI Decision Loop:
1. Analyze Game State → Current resources, base status, threats, opportunities
2. Strategic Planning → Prioritize objectives (research/defense/expansion), allocate resources
3. Tactical Execution → Queue research/manufacturing, deploy craft, move units
4. UI Interaction → Translate decisions to clicks, menu navigation, confirmation dialogs
5. Feedback → Record all actions, outcomes, costs, durations
```

### Log Structure & Format

All game events logged with consistent schema:
```
{
  "timestamp": "2025-10-20T14:32:15Z",
  "simulation_id": "uuid",
  "session_id": "uuid",
  "event_type": "research_started|facility_built|unit_killed|mission_failed|...",
  "actor": "player|faction_x|neutral",
  "context": {
    "base_id": "id",
    "location": "province_x",
    "resources_before": {...},
    "resources_after": {...}
  },
  "metrics": {
    "cost_credits": 5000,
    "time_days": 10,
    "difficulty_multiplier": 1.2
  },
  "outcome": "success|partial|failure",
  "cascading_effects": [...]
}
```

**Log Aggregation**
- All simulation logs written to structured files (JSON-Lines format for streaming)
- Hourly log rotation to manageable file sizes
- Log files organized by simulation type and timestamp
- Backup/archival for historical trend analysis
- Real-time log streaming to processing pipeline

**Player Session Logging**
In addition to autonomous simulations:
- Every player session generates identical log structure
- UI interaction tracking (heatmaps of clicks, menu usage patterns)
- Decision timing (how long player deliberates before acting)
- Resource management patterns (spending distribution, priority shifts)
- Mission success/failure data with player decision analysis
- All player logs merged into unified data corpus with "source" tag

---

## Stage 2: Data Aggregation & Processing

**Overview**
Raw logs are transformed into queryable SQL databases using DuckDB and Parquet files. This stage enables rapid analysis and historical comparisons without manual log parsing.

**Data Pipeline Architecture**

```
Raw Logs (JSON-Lines)
    ↓
Streaming Parser
    ↓
Schema Validation & Normalization
    ↓
Parquet File Writing (time-partitioned)
    ↓
DuckDB SQL Indexing
    ↓
Analytics Queries & Aggregation
```

**Parquet Schema Definition**

Core tables created from log aggregation:

| Table | Records | Key Fields | Purpose |
|---|---|---|---|
| **game_events** | Millions | timestamp, event_type, actor, outcome | Raw event stream |
| **research_projects** | Thousands | project_id, duration, cost, scientist_count | Research metrics |
| **manufacturing_jobs** | Thousands | job_id, item, quantity, duration, profitability | Production metrics |
| **combat_encounters** | Thousands | encounter_id, units_deployed, casualties, mission_type | Combat data |
| **unit_statistics** | Millions | unit_id, class, stats, experience, survival_rate | Unit performance |
| **weapon_usage** | Millions | weapon_id, hits, misses, kills, damage_dealt | Weapon stats |
| **mission_results** | Thousands | mission_id, type, difficulty, success_rate, reward | Mission data |
| **base_snapshots** | Thousands | base_id, timestamp, facility_count, capacity, efficiency | Base state history |
| **player_actions** | Millions | player_id, action_type, timestamp, resources_spent | Player behavior |
| **ui_interactions** | Millions | session_id, ui_element, click_position, duration | UI usage patterns |

**Automated Data Processing**
```sql
-- Example aggregation: Weapon effectiveness by type
SELECT
  weapon_type,
  COUNT(*) as usage_count,
  SUM(hits) / SUM(shots_fired) as accuracy,
  SUM(kills) as total_kills,
  AVG(damage_per_shot) as average_damage,
  STDDEV(damage_per_shot) as damage_variance
FROM weapon_usage
GROUP BY weapon_type
ORDER BY usage_count DESC
```

**Data Quality Assurance**
- Schema validation on ingestion (reject malformed records)
- Duplicate detection (same event logged twice)
- Outlier detection (impossible values: damage > max_hp, time < 0)
- Completeness checks (required fields present)
- Temporal consistency (events in chronological order)

---

## Stage 3: Metric Calculation

**Overview**
Aggregated data enables extraction of actionable insights. Analytics stage compares actual performance against expected behavior, identifies deviations, and surfaces balance issues or implementation problems.

**Built-In Analytics Queries**

#### Combat System Analysis

**Unit Class Balance**
```sql
SELECT
  unit_class,
  COUNT(*) as deployments,
  SUM(CASE WHEN survived THEN 1 ELSE 0 END) / COUNT(*) as survival_rate,
  AVG(kills_in_mission) as avg_kills,
  AVG(damage_taken) as avg_damage,
  SUM(CASE WHEN casualties_inflicted > 5 THEN 1 ELSE 0 END) as high_kill_missions
FROM unit_statistics
GROUP BY unit_class
HAVING COUNT(*) > 100  -- Minimum sample size
ORDER BY survival_rate DESC
```

**Weapon Effectiveness**
```sql
SELECT
  weapon_id,
  weapon_name,
  COUNT(*) as shots_fired,
  SUM(hits) as total_hits,
  SUM(hits) / COUNT(*) as hit_rate,
  SUM(kills) as kill_count,
  AVG(CASE WHEN hit THEN damage ELSE 0 END) as avg_damage_per_hit,
  (SUM(kills) / COUNT(*)) * 100 as kill_per_shot_percent
FROM weapon_usage
GROUP BY weapon_id, weapon_name
ORDER BY hit_rate DESC, kill_per_shot_percent DESC
```

**Enemy AI Effectiveness**
```sql
SELECT
  faction_id,
  mission_type,
  COUNT(*) as missions_deployed,
  SUM(CASE WHEN player_victory THEN 0 ELSE 1 END) / COUNT(*) as faction_success_rate,
  AVG(player_casualties) as avg_player_losses,
  AVG(faction_casualties) as avg_faction_losses,
  AVG(mission_duration_minutes) as avg_mission_length
FROM mission_results
GROUP BY faction_id, mission_type
ORDER BY faction_success_rate DESC
```

#### Economic System Analysis

**Research Efficiency**
```sql
SELECT
  research_category,
  COUNT(*) as projects_completed,
  AVG(actual_duration / expected_duration) as duration_ratio,
  SUM(CASE WHEN was_bottleneck THEN 1 ELSE 0 END) as bottleneck_count,
  AVG(downstream_impact) as avg_impact_on_progression
FROM research_projects
GROUP BY research_category
HAVING COUNT(*) > 50
ORDER BY duration_ratio DESC
```

**Manufacturing Profitability**
```sql
SELECT
  item_id,
  item_name,
  COUNT(*) as units_produced,
  AVG(manufacturing_cost) as avg_cost,
  AVG(marketplace_price) as avg_price,
  AVG(marketplace_price - manufacturing_cost) as avg_profit_per_unit,
  SUM(units_produced * (marketplace_price - manufacturing_cost)) as total_profit
FROM manufacturing_jobs
GROUP BY item_id, item_name
ORDER BY avg_profit_per_unit DESC
```

**Funding Sustainability**
```sql
SELECT
  organization_id,
  MONTH(timestamp) as month,
  SUM(funding_received) as total_income,
  SUM(base_maintenance + unit_salary + facility_cost) as total_expenses,
  SUM(funding_received - (base_maintenance + unit_salary + facility_cost)) as net_balance,
  COUNT(*) as base_count
FROM base_snapshots
GROUP BY organization_id, MONTH(timestamp)
HAVING net_balance < 0
ORDER BY net_balance ASC  -- Shows deficit months
```

#### Strategic Layer Analysis

**Mission Success Patterns**
```sql
SELECT
  mission_type,
  difficulty_tier,
  COUNT(*) as total_missions,
  SUM(CASE WHEN success THEN 1 ELSE 0 END) / COUNT(*) as success_rate,
  AVG(player_units_deployed) as avg_units,
  AVG(CASE WHEN success THEN reward ELSE 0 END) as avg_reward_on_success,
  STDDEV(duration_minutes) as duration_variance
FROM mission_results
WHERE player_level > 5  -- Filter for minimum level
GROUP BY mission_type, difficulty_tier
HAVING COUNT(*) > 50
ORDER BY success_rate ASC  -- Identify too-hard missions
```

**Campaign Escalation Dynamics**
```sql
SELECT
  faction_id,
  campaign_month,
  COUNT(*) as total_campaigns,
  SUM(campaign_points) as total_points,
  AVG(player_defenses_used) as avg_player_defense,
  SUM(CASE WHEN player_defeated_campaign THEN 1 ELSE 0 END) as campaigns_blocked,
  (SUM(CASE WHEN player_defeated_campaign THEN 1 ELSE 0 END) / COUNT(*)) as block_rate
FROM campaign_results
GROUP BY faction_id, campaign_month
ORDER BY faction_id, campaign_month
```

#### Gameplay Pattern Analysis

**Player Decision Patterns**
```sql
SELECT
  decision_type,  -- research_priority, base_placement, craft_deployment
  chosen_option,
  COUNT(*) as frequency,
  SUM(CASE WHEN led_to_victory THEN 1 ELSE 0 END) as victories,
  (SUM(CASE WHEN led_to_victory THEN 1 ELSE 0 END) / COUNT(*)) as win_rate,
  AVG(decision_time_seconds) as avg_deliberation_time
FROM player_decisions
GROUP BY decision_type, chosen_option
ORDER BY decision_type, frequency DESC
```

**UI Interaction Heatmap**
```sql
SELECT
  ui_element,
  click_x,
  click_y,
  COUNT(*) as click_frequency,
  AVG(time_on_screen_seconds) as avg_dwell_time,
  SUM(CASE WHEN action_succeeded THEN 1 ELSE 0 END) / COUNT(*) as success_rate
FROM ui_interactions
WHERE session_length_minutes > 10  -- Filter for engaged players
GROUP BY ui_element, click_x, click_y
ORDER BY click_frequency DESC
```

#### Performance Profiling

**Execution Time Analysis**
```sql
SELECT
  operation_type,  -- pathfinding, map_generation, combat_resolution
  COUNT(*) as executions,
  AVG(duration_ms) as avg_duration,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) as p95_duration,
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration_ms) as p99_duration,
  MAX(duration_ms) as max_duration
FROM performance_metrics
WHERE timestamp > CURRENT_DATE - INTERVAL '7 days'
GROUP BY operation_type
ORDER BY avg_duration DESC
```

**Memory Usage Patterns**
```sql
SELECT
  system_component,
  COUNT(*) as samples,
  AVG(memory_usage_mb) as avg_memory,
  MAX(memory_usage_mb) as peak_memory,
  STDDEV(memory_usage_mb) as memory_variance
FROM memory_metrics
WHERE timestamp > CURRENT_DATE - INTERVAL '7 days'
GROUP BY system_component
ORDER BY peak_memory DESC
```

---

## Stage 4: Insights & Visualization

**Overview**
Global metrics define success criteria for game design. They answer: "Is the game good?" across multiple dimensions. Metrics are defined in configuration and automatically calculated from analytics data to track progress toward design goals.

**Metric Configuration Schema**:

Metrics define name (human-readable title), category (gameplay/progression/technical), target value (success goal), and description. Examples include:

**Combat Balance Metric**: Tracks if all unit classes maintain 45-55% win rates (target variance < 5%). Priority marked as critical to ensure fair combat mechanics.

**Research Progression Metric**: Tracks total research tree completion time (target 100-140 days). Ensures pacing feels neither rushed nor tedious. Priority marked as high.

**Frame Rate Performance Metric**: Tracks 95th percentile FPS (target ≥60 FPS, minimum acceptable 55 FPS). Critical for smooth gameplay experience.

Each metric includes: acceptance threshold (allowed deviation from target), priority level (critical/high/medium/low), and query specifications for automatic calculation.

[metric.ui_usability]
name = "UI Interaction Success Rate"
category = "usability"
target_value = 98.0
description = "Players successfully complete intended UI actions 98% of time"
queries = [
  "SELECT SUM(CASE WHEN action_succeeded THEN 1 ELSE 0 END) / COUNT(*) * 100 FROM ui_interactions"
]
acceptance_threshold = 95.0  # Minimum 95% success
priority = "high"

[metric.economy_sustainability]
name = "Economic System Sustainability"
category = "economy"
target_value = 100.0  # Balanced income/costs
description = "Average player organization breaks even monthly"
queries = [
  "SELECT AVG(monthly_income - monthly_expense) FROM organization_monthly_finance WHERE game_month > 6"
]
acceptance_threshold = 0.0  # Within ±10K credits
priority = "high"

[metric.player_retention]
name = "Campaign Completion Rate"
category = "engagement"
target_value = 40.0  # 40% of campaigns reached endgame
description = "Players progress to endgame in 40% of campaigns started"
queries = [
  "SELECT SUM(CASE WHEN final_level >= 9 THEN 1 ELSE 0 END) / COUNT(*) * 100 FROM campaigns"
]
acceptance_threshold = 30.0  # Minimum 30%
priority = "high"
```

**Metric Calculation Engine**
```
For Each Metric:
  1. Load acceptance criteria from TOML
  2. Execute SQL queries against Parquet data
  3. Compare result against target_value
  4. Calculate delta (variance from target)
  5. Determine status: PASS (within threshold), WARN (close), FAIL (outside)
  6. Record timestamp, value, status
  7. Generate trend chart (historical metric progression)
```

**Metric Dashboard Output**
```
GAME DESIGN METRICS REPORT
Generated: 2025-10-20 14:00:00

=== CRITICAL METRICS ===
✓ Combat Balance: 4.2% variance (Target: <5%) - PASS
✗ Frame Rate (P95): 48 FPS (Target: >55) - FAIL (-7 FPS)
✓ UI Success Rate: 97.1% (Target: >95%) - PASS

=== HIGH PRIORITY METRICS ===
⚠ Research Pacing: 158 days (Target: 120±20) - WARN (+38 days, needs -18 to pass)
✓ Economy Sustainability: -2,500 credits (Target: ±0) - PASS
⚠ Campaign Completion: 28% (Target: >30%) - WARN (-2%)

=== METRIC TRENDS ===
Combat Balance: 5.1% → 4.6% → 4.2% (IMPROVING)
Frame Rate: 42 → 45 → 48 FPS (IMPROVING)
Research Pacing: 145 → 152 → 158 days (REGRESSING)

=== FAILURE ANALYSIS ===
Frame Rate Issue: Identified in Battlescape map rendering
  - Pathfinding queries: 12ms (acceptable)
  - Graphics render: 4.2ms (acceptable)
  - UI draw: 2.1ms (acceptable)
  - Unknown overhead: 3.7ms (investigate)

Research Pacing Issue: Mid-tier research taking 40% longer
  - Alien Interrogation: +35% longer than expected
  - Advanced Weapons: +25% longer
  - Facility Upgrades: -10% faster (good)
  → Action: Review TOML costs for Alien research
```

---

## Stage 5: Action Planning

**Overview**
Metrics that fail acceptance criteria automatically generate action plans. These plans identify whether issues lie in game configuration (MOD/TOML) or engine implementation, enabling targeted fixes.

**Action Plan Generation**

For each failed metric:
1. **Root Cause Analysis**: Drill down into underlying factors
2. **Categorization**: Configuration issue vs. Engine issue vs. Design flaw
3. **Solution Generation**: Suggest specific TOML edits or engine changes
4. **Impact Estimation**: Predict outcome if solution implemented
5. **Priority Ranking**: Order fixes by impact/effort ratio

**Example: Research Pacing Issue**

```
FAILED METRIC: Research Pacing
Current Value: 158 days | Target: 120±20 | Status: FAIL (+38 days)

ROOT CAUSE ANALYSIS:
├─ Alien Research Category: +35% slower than expected
│  ├─ Alien Interrogation: 85 days (expected 60)
│  ├─ Alien Autopsy: 72 days (expected 50)
│  └─ Alien Analysis: 58 days (expected 40)
├─ Standard Research Category: +15% slower
│  ├─ Basic Rifle: 12 days (expected 10)
│  └─ Advanced Laser: 28 days (expected 24)
└─ Facility Research Category: -5% faster (good)

CATEGORIZATION:
Primary: Configuration Issue (TOML)
  - Alien research costs set too high
  - Expected vs. actual man-days misaligned
Secondary: Design Issue
  - Alien research gating preventing parallel research
  - Bottleneck in early-mid game progression

RECOMMENDED ACTIONS:
1. Lower alien_interrogation cost: 85 → 65 man-days (-23%)
2. Lower alien_autopsy cost: 72 → 50 man-days (-31%)
3. Lower alien_analysis cost: 58 → 40 man-days (-31%)
4. Impact Estimate: New total = 120 days (meets target)
5. Implementation: Edit research/alien_projects.toml
6. Verification: Re-run simulation, confirm pacing improved

ALTERNATIVE ACTIONS (if configuration insufficient):
1. Increase scientist efficiency bonus for alien research (+15%)
2. Unlock alien research 2 weeks earlier (game progression issue)
3. Reduce prerequisite research requirements (parallel research)
```

**Configuration Adjustment Workflow**

```
Metric FAILS
  ↓
Root Cause Analysis (SQL queries)
  ↓
Issue Type Identified (Config vs. Engine)
  ↓
IF Config Issue:
  - Generate TOML adjustment
  - Estimate impact
  - Create patch file
  - Queue for implementation
  ↓
IF Engine Issue:
  - Create performance profile
  - Generate code review suggestions
  - Assign to developer
  - Create bug/task ticket
  ↓
Implement Fix
  ↓
Re-run Simulation
  ↓
Verify Metric now PASSES
  ↓
Document change in patch notes
```

**Multi-Metric Impact Analysis**

When adjusting values, analyze cascading effects:
```
Proposed Change: Reduce research costs by 20%
┌─ Research Pacing: 158 → 125 days (IMPROVES, now passes)
├─ Campaign Completion: 28% → 34% (IMPROVES, now passes)
├─ Economy Sustainability: -2.5K → -4.2K (WORSENS, still passes but closer to fail)
├─ Player Retention: 28% → 32% (IMPROVES)
└─ Faction Escalation: Slower (allows player more breathing room, IMPROVES overall difficulty balance)

Net Impact Assessment: +3 metrics improve, -0 metrics fail → PROCEED
```

---

### Player Session Data Collection

**Overview**
In addition to autonomous simulation data, all player session data is captured in identical format. Player and AI data merge into unified analytics corpus with "source" metadata.

**Session Event Logging**
```
Player Session Event Examples:
├─ Session Start: Player launches game
├─ Base Construction: Player builds facility ($cost, duration)
├─ Research Decision: Player prioritizes research ($cost, scientist allocation)
├─ Craft Deployment: Player sends craft to region (destination, units, equipment)
├─ Mission Acceptance: Player engages generated mission (mission_type, difficulty)
├─ Combat Action: Player moves unit, fires weapon, uses item (combat_action, outcome)
├─ Loadout Decision: Player equips units (unit_id, weapon_id, armor_id, item_id)
├─ Base Layout: Player places facility (facility_type, grid_position, adjacency_bonuses)
├─ UI Interaction: Player clicks element (ui_element, element_id, click_position)
└─ Session End: Player quits game

All events timestamped and correlated for timeline analysis
```

**Player Behavior Analytics**

**UI Heatmap Generation**
```sql
SELECT
  ui_element,
  ROUND(click_x / 10) * 10 as grid_x,
  ROUND(click_y / 10) * 10 as grid_y,
  COUNT(*) as click_count,
  SUM(CASE WHEN action_succeeded THEN 1 ELSE 0 END) / COUNT(*) as success_rate,
  AVG(time_before_next_action_ms) as avg_time_to_next_action
FROM ui_interactions
WHERE source = 'player_session'
GROUP BY ui_element, grid_x, grid_y
ORDER BY click_count DESC
LIMIT 100
```

**Player Decision Time Analysis**
```sql
SELECT
  decision_type,
  COUNT(*) as decision_count,
  AVG(deliberation_time_seconds) as avg_time,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY deliberation_time_seconds) as quick_decision_25th,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY deliberation_time_seconds) as median_time,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY deliberation_time_seconds) as slow_decision_75th
FROM player_decisions
GROUP BY decision_type
ORDER BY avg_time DESC
```

**Item Usage Patterns**
```sql
SELECT
  item_id,
  item_name,
  COUNT(*) as usage_count,
  SUM(CASE WHEN used_in_successful_mission THEN 1 ELSE 0 END) / COUNT(*) as success_rate,
  AVG(mission_difficulty) as avg_mission_difficulty_used,
  RANK() OVER (ORDER BY usage_count DESC) as popularity_rank
FROM item_usage
WHERE source = 'player_session'
GROUP BY item_id, item_name
ORDER BY usage_count DESC
```

**Campaign Success vs. Failure Patterns**
```sql
SELECT
  CASE WHEN final_level >= 9 THEN 'Victory' ELSE 'Defeat' END as outcome,
  COUNT(*) as campaign_count,
  AVG(avg_campaign_duration_days) as avg_campaign_length,
  AVG(total_bases_built) as avg_bases,
  AVG(total_units_recruited) as avg_unit_count,
  ARRAY_AGG(DISTINCT preferred_research_first) as common_research_orders,
  ARRAY_AGG(DISTINCT preferred_biome) as preferred_regions
FROM player_campaigns
GROUP BY outcome
```

---

### Comparative Analytics: Player vs. AI

**Overview**
By running identical metrics on both player and AI data, we identify where AI behavior diverges from player expectations and where player behavior surprises designers.

**Behavior Comparison**

```sql
-- Compare decision-making speed
SELECT
  'Player' as actor_type,
  AVG(deliberation_time_seconds) as avg_decision_time,
  COUNT(*) as decision_count
FROM player_decisions

UNION ALL

SELECT
  'AI' as actor_type,
  AVG(deliberation_time_ms / 1000) as avg_decision_time,
  COUNT(*) as decision_count
FROM ai_decisions
```

**Resource Management Comparison**
```sql
SELECT
  source,  -- 'player_session' vs 'ai_simulation'
  AVG(monthly_research_budget_percent) as avg_research_allocation,
  AVG(monthly_manufacturing_budget_percent) as avg_manufacturing_allocation,
  AVG(monthly_defense_budget_percent) as avg_defense_allocation,
  AVG(monthly_expansion_budget_percent) as avg_expansion_allocation
FROM organization_budget_allocation
GROUP BY source
```

**Playstyle Divergence**
```sql
SELECT
  playstyle,  -- research_focused, manufacturing_focused, defense_focused, balanced
  source,
  COUNT(*) as adoption_count,
  AVG(campaign_success_rate) as success_rate,
  AVG(avg_campaign_duration_days) as avg_length
FROM campaign_playstyles
GROUP BY playstyle, source
ORDER BY playstyle, source
```

---

### Advanced Analytics: Emergent Patterns

**Overview**
Beyond direct metric calculation, sophisticated queries identify emergent phenomena, unexpected interactions, and design insights.

**Synergy Discovery**
```sql
-- Find facility adjacency bonuses with highest impact
SELECT
  facility_pair,
  COUNT(*) as bases_with_pair,
  AVG(production_with_adjacency) / AVG(production_without_adjacency) as efficiency_multiplier,
  AVG(profitability_improvement_percent) as avg_profitability_boost,
  RANK() OVER (ORDER BY efficiency_multiplier DESC) as synergy_rank
FROM facility_combinations
WHERE ADJACENCY_BONUS > 0
GROUP BY facility_pair
ORDER BY efficiency_multiplier DESC
LIMIT 20
```

**Skill Expression Analysis**
```sql
-- Identify decisions where skilled players outperform
SELECT
  decision_type,
  SUM(CASE WHEN player_level > 50 AND successful THEN 1 ELSE 0 END) as high_skill_success,
  SUM(CASE WHEN player_level < 20 AND successful THEN 1 ELSE 0 END) as low_skill_success,
  (SUM(CASE WHEN player_level > 50 AND successful THEN 1 ELSE 0 END) /
   SUM(CASE WHEN player_level < 20 AND successful THEN 1 ELSE 0 END)) as skill_multiplier
FROM player_decisions
GROUP BY decision_type
HAVING skill_multiplier > 1.5
ORDER BY skill_multiplier DESC
```

**Meta-Game Evolution**
```sql
-- Track dominant strategies over time
SELECT
  MONTH(session_date) as month,
  preferred_faction,
  preferred_playstyle,
  COUNT(*) as adoption_count,
  AVG(win_rate) as avg_win_rate,
  ROW_NUMBER() OVER (PARTITION BY MONTH(session_date) ORDER BY COUNT(*) DESC) as rank
FROM player_campaigns
GROUP BY MONTH(session_date), preferred_faction, preferred_playstyle
HAVING rank <= 5  -- Top 5 strategies per month
```

**Balance Oscillation Detection**
```sql
-- Detect if balance patches overcorrect
SELECT
  patch_version,
  metric_name,
  metric_value_before,
  metric_value_after,
  ABS(metric_value_after - metric_target) as distance_from_target_after,
  CASE
    WHEN ABS(metric_value_after - metric_target) > ABS(metric_value_before - metric_target) THEN 'OVERCORRECTED'
    WHEN ABS(metric_value_after - metric_target) < ABS(metric_value_before - metric_target) THEN 'IMPROVED'
    ELSE 'NEUTRAL'
  END as adjustment_impact
FROM metric_patch_history
WHERE patch_applied_date > CURRENT_DATE - INTERVAL '30 days'
ORDER BY ABS(ABS(metric_value_after - metric_target) - ABS(metric_value_before - metric_target)) DESC
```

---

### Real-Time Alerting & Anomaly Detection

**Overview**
Automated systems monitor live data streams for anomalies indicating bugs, imbalance, or performance issues requiring immediate attention.

**Alert Thresholds**

| Alert Type | Threshold | Action |
|---|---|---|
| **Crash Rate** | >5% mission failures with crash logs | Pause simulation, flag for debugging |
| **Balance Anomaly** | Unit win rate >70% or <30% | Generate balance alert |
| **Performance Regression** | FPS drops >20% from baseline | Alert performance team |
| **Exploit Detection** | Player income >10x expected | Flag for investigation |
| **Progression Block** | >50% players stuck at same research | Adjust difficulty |
| **UI Failure** | UI action success <90% | Investigate UI logic |

**Real-Time Anomaly Example**
```
ALERT TRIGGERED: 2025-10-20 14:15:00
Type: Balance Anomaly
Severity: Medium

Weapon Performance Deviation:
├─ Plasma Rifle: Win Rate 72% (Expected: 50-55%)
├─ Laser Pistol: Win Rate 28% (Expected: 45-50%)
├─ Rifle Accuracy: 92% (Expected: 65-75%)

Investigation Required:
├─ TOML parameter issue? (check weapon stats)
├─ Ammunition availability? (check marketplace)
├─ Recent code change? (check git log)
└─ Environmental factor? (check map generation)

Recommendation: Pause AI simulations using Plasma Rifle, investigate TOML
```

---

### Implementation Roadmap

**Phase 1: Foundation** (Completed)
- [x] Autonomous simulation architecture
- [x] Log capture and structuring
- [x] Parquet/DuckDB pipeline

**Phase 2: Analytics** (In Progress)
- [ ] Core metric calculation queries
- [ ] Metric dashboard generation
- [ ] Action plan automation

**Phase 3: Integration** (Planned)
- [ ] Live player session logging
- [ ] Real-time alerting system
- [ ] Automated TOML patch generation

**Phase 4: Advanced** (Future)
- [ ] Machine learning for anomaly detection
- [ ] Predictive balance forecasting
- [ ] Automated tuning using optimization algorithms

---

### Key Insights Enabled by Analytics

**Design Validation**
- "Is the economy balanced?" → Check metric_economy_sustainability
- "Is progression pacing correct?" → Check metric_research_pacing
- "Are all unit classes viable?" → Check metric_combat_balance

**Performance Profiling**
- "Where are framerate bottlenecks?" → Query performance_metrics filtered by component
- "Which operations are slowest?" → Percentile analysis of operation_duration

**Player Behavior**
- "What playstyles do players prefer?" → Aggregate playstyle distribution from player_campaigns
- "Which UI elements confuse players?" → UI heatmap analysis from ui_interactions
- "How do players prioritize resources?" → Analyze organization_budget_allocation

**Balance Tuning**
- "Is this item overpowered?" → Win rate analysis of weapon_usage
- "Is this research cost too high?" → Duration vs. expected ratio from research_projects
- "Is the economy sustainable?" → Monthly balance tracking from organization_finance

**Prediction & Planning**
- "Will this change break the game?" → Impact simulation using multi-metric analysis
- "What metric improvements compound?" → Correlation analysis across metrics
- "What's the best way to improve?" → Action plan ranking by impact/effort





---
## Integration with Other Systems
The Analytics system collects data from and influences:
### AI Systems
- Provides balance data for autonomous playtesting
- AI vs AI simulations generate analytics data
- Used for difficulty tuning and faction balancing
### Economy System
- Tracks resource usage, income patterns
- Manufacturing and research efficiency metrics
- Balance data for tech tree progression
### Units System
- Survival rates, kill ratios, experience progression
- Class effectiveness and weapon usage statistics
- Informs unit balance adjustments
### Battlescape System
- Combat encounter data, win/loss ratios
- Map balance, spawn position fairness
- Tactical effectiveness metrics
**For complete system integration details, see [Integration.md](Integration.md)**

---

## Examples

- Scenario: Automatic balance patch generation where weapon X becomes dominant; analytics pipeline detects >70% win rate and proposes TOML adjustments. Validate by re-running simulation and confirming metrics return within thresholds.
- Scenario: Performance regression detected in Battlescape draw calls; analytics isolates component and generates ticket for engine profiling.

---

## Balance Parameters

| Parameter | Default | Range | Notes |
|---|---:|---|---|
| Metric sample size threshold | 100 | 50-1000 | Minimum samples before metrics considered valid |
| Alert win-rate threshold | 70% | 60-90% | Above/below triggers balance alert |
| Performance p95 target (FPS) | 55 | 30-75 | Threshold for acceptable perf |

---

## Difficulty Scaling

- Easy: Longer aggregation windows; relax alert thresholds by +10%.
- Normal: Standard thresholds and sampling cadence.
- Hard: Shorter sampling windows, stricter thresholds (−10% alert margin) to surface issues faster.

---

## Testing Scenarios

- [ ] Data Ingestion: Verify logs from simulation and player sessions are accepted and parsed.
- [ ] Metric Calculation: Run core metric queries and verify outputs against known fixtures.
- [ ] Alerting: Inject synthetic anomaly and confirm alert is generated and action plan proposed.

---

## Related Features

- [Integration.md] for pipeline hookup details
- [Economy.md] for finance-related metrics
- [Battlescape.md], [Geoscape.md] for source data of combat and map metrics

---

## Implementation Notes

- Prefer idempotent ingestion (dedupe by event_id). Use DuckDB + Parquet for fast ad-hoc queries. Keep metric definitions in TOML for easy patch generation.
- Ensure metric queries include sample-size guards and null handling.

---

## Review Checklist

- [ ] Examples documented
- [ ] Core metrics implemented in SQL
- [ ] TOML metric definitions available
- [ ] Alerting rules configured
- [ ] Ingestion schema validated
- [ ] Unit tests for key aggregations
