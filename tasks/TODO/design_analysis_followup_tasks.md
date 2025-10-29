# Design Analysis Follow-Up Tasks

**Created**: 2025-10-28  
**Priority**: High  
**Category**: Documentation & Analytics System  
**Related**: `temp/design_analysis_2025-10-28.md`, `temp/design_analysis_summary.md`

---

## Overview

Tasks identified from comprehensive design folder analysis. Auto-balance system is production-ready but needs implementation. Documentation gaps need filling.

**Context**: Analysis complete, 7 files created/updated, 20 KPIs defined, system ready for implementation.

---

## 🔴 HIGH PRIORITY - Immediate (Week 1)

### Task 1: Add Missing Template Sections to Mechanics Files
**Status**: 🔲 TODO  
**Estimate**: 2 hours  
**Priority**: High  
**Dependencies**: None

**Files to Update**:
1. `design/mechanics/Environment.md` - Add "Balance Parameters" section
2. `design/mechanics/BlackMarket.md` - Add "Testing Scenarios" section  
3. `design/mechanics/MoraleBraverySanity.md` - Add "Design Goals" section

**Template Reference**: `design/DESIGN_TEMPLATE.md`

**Acceptance Criteria**:
- [ ] All 3 files follow DESIGN_TEMPLATE.md structure
- [ ] Balance Parameters section includes numeric values and reasoning
- [ ] Testing Scenarios section includes test cases and expected results
- [ ] Design Goals section includes 3+ goals with justification

**Related Files**:
- `design/DESIGN_TEMPLATE.md` (reference)
- `design/mechanics/Environment.md`
- `design/mechanics/BlackMarket.md`
- `design/mechanics/MoraleBraverySanity.md`

---

### Task 2: Review Analysis Report with Team
**Status**: 🔲 TODO  
**Estimate**: 1 hour meeting  
**Priority**: High  
**Dependencies**: None

**Agenda**:
1. Present findings from `temp/design_analysis_2025-10-28.md`
2. Review auto-balance KPI targets (adjust if needed)
3. Prioritize implementation phases
4. Assign owners for follow-up tasks

**Discussion Points**:
- Auto-balance system innovation (9/10 score)
- KPI target values (are they realistic?)
- Implementation timeline (6 weeks feasible?)
- Resource allocation for analytics implementation

**Materials to Review**:
- `temp/design_analysis_2025-10-28.md` (comprehensive report)
- `design/faq/FAQ_ANALYTICS.md` (player-facing documentation)
- `mods/core/config/analytics_kpis.toml` (20 KPIs)

**Deliverable**: Meeting notes with decisions and adjusted priorities

---

## 🟡 MEDIUM PRIORITY - Short-Term (Weeks 2-4)

### Task 3: Create Balance Formulas Consolidation Document
**Status**: 🔲 TODO  
**Estimate**: 4 hours  
**Priority**: Medium  
**Dependencies**: None

**File to Create**: `design/mechanics/BalanceFormulas.md`

**Content Required**:
1. **Combat Accuracy Formula**
   - Base accuracy calculation
   - Range modifier formula
   - Cover modifier formula
   - Visibility modifier formula
   - Final accuracy clamping (5-95%)

2. **Damage Calculation Formula**
   - Base damage
   - Armor reduction
   - Critical hit multiplier
   - Damage variance

3. **Research Cost Scaling**
   - Base cost formula
   - Complexity multiplier
   - Scientist efficiency bonuses
   - Facility bonuses

4. **Manufacturing Efficiency**
   - Production time calculation
   - Engineer efficiency
   - Batch bonuses
   - Facility bonuses

5. **Facility Adjacency Bonuses**
   - Lab + Workshop synergy (+10%)
   - Research adjacency rules
   - Manufacturing adjacency rules

6. **Pilot Experience Progression**
   - XP per kill formula
   - Rank progression thresholds
   - Ace pilot requirements

7. **Interception Card Costs**
   - Energy cost formula
   - AP cost formula
   - Card power balancing

8. **Economy Sustainability Model**
   - Income calculation
   - Expense calculation
   - Break-even formula
   - Funding tier scaling

**Source Files to Consolidate**:
- `design/mechanics/Battlescape.md` (combat formulas)
- `design/mechanics/Economy.md` (research/manufacturing)
- `design/mechanics/Basescape.md` (facility bonuses)
- `design/mechanics/Pilots.md` (pilot progression)
- `design/mechanics/Interception.md` (card costs)
- `design/mechanics/Finance.md` (economy)

**Acceptance Criteria**:
- [ ] All formulas in one place
- [ ] Each formula has example calculation
- [ ] Cross-references to source mechanics files
- [ ] Modder-friendly format (easy to copy values)

---

### Task 4: Create SQL Query Examples File
**Status**: 🔲 TODO  
**Estimate**: 3 hours  
**Priority**: Medium  
**Dependencies**: None

**File to Create**: `tools/analytics/example_queries.sql`

**Content Required** (7 categories):
1. **Combat Balance Analysis** (3 queries)
   - Unit class win rate distribution
   - Weapon effectiveness ranking
   - Mission difficulty validation

2. **Economy & Progression Analysis** (3 queries)
   - Research pacing analysis
   - Manufacturing profitability
   - Economic sustainability check

3. **Performance & Technical Metrics** (3 queries)
   - Frame rate analysis (P95)
   - Memory usage tracking
   - Load time analysis

4. **Player Behavior Analysis** (3 queries)
   - Campaign completion rates
   - UI interaction success rate
   - Player decision patterns

5. **Auto-Balance Triggers** (3 queries)
   - Identify overused weapons needing nerf
   - Identify too-easy missions needing buff
   - Identify research bottlenecks needing speed-up

6. **Trend Analysis** (1 query)
   - Metric trends over time (historical)

7. **Correlation Analysis** (1 query)
   - Research speed vs campaign completion correlation

**Structure** (per query):
```sql
-- Query Name
-- Purpose: What it measures
-- Target: Expected value range
SELECT ...
```

**Reference**: See `temp/design_analysis_2025-10-28.md` Section 7 for query templates

**Acceptance Criteria**:
- [ ] 17+ example queries
- [ ] Each query has purpose and target documented
- [ ] Queries tested with DuckDB syntax
- [ ] Comments explain each calculation
- [ ] Ready for copy-paste by developers

---

### Task 5: Create Analytics Setup Guide
**Status**: 🔲 TODO  
**Estimate**: 4 hours  
**Priority**: Medium  
**Dependencies**: Task 4 (SQL queries)

**File to Create**: `docs/handbook/ANALYTICS_SETUP.md`

**Content Required**:
1. **Introduction**
   - What is the analytics system?
   - Why use it?
   - Prerequisites

2. **Installation**
   - Install DuckDB (Windows/Linux/Mac)
   - Install Python dependencies
   - Verify installation

3. **Log Collection Setup**
   - Configure log paths
   - Enable analytics logging
   - Test log generation

4. **Parquet Conversion**
   - Run conversion script
   - Verify Parquet files created
   - Check data quality

5. **Running Queries**
   - Connect to DuckDB
   - Load Parquet files
   - Execute example queries
   - Interpret results

6. **KPI Configuration**
   - Edit `mods/core/config/analytics_kpis.toml`
   - Add custom KPIs
   - Set thresholds
   - Enable auto-adjust

7. **Dashboard Access**
   - Generate HTML dashboard
   - View metrics
   - Export reports

8. **Troubleshooting**
   - Common errors
   - Log file issues
   - Query performance
   - Data quality checks

**Format**: Tutorial style with step-by-step instructions and screenshots placeholders

**Acceptance Criteria**:
- [ ] Complete step-by-step guide
- [ ] Code examples for all steps
- [ ] Troubleshooting section
- [ ] Links to related documentation
- [ ] Tested on clean install

---

### Task 6: Implement Auto-Balance Phase 1 - Log Collection
**Status**: 🔲 TODO  
**Estimate**: 8 hours  
**Priority**: Medium  
**Dependencies**: None

**Goal**: Enable structured gameplay data collection

**Files to Create**:
1. `engine/analytics/log_writer.lua` - Main logging module
2. `engine/analytics/event_schema.lua` - Event structure definitions
3. `engine/analytics/init.lua` - Module initialization

**Features Required**:
- JSON-Lines format (one event per line)
- Structured event schema
- Async writing (non-blocking)
- Log rotation (hourly)
- Performance: <1ms per event
- Error handling

**Event Types to Log**:
- `research_started` / `research_completed`
- `manufacturing_started` / `manufacturing_completed`
- `mission_started` / `mission_completed`
- `unit_killed` / `unit_recruited`
- `weapon_fired` / `weapon_hit` / `weapon_kill`
- `facility_built` / `facility_destroyed`
- `craft_deployed` / `craft_returned`
- `ufo_detected` / `ufo_intercepted`

**Event Schema Example**:
```lua
{
  timestamp = "2025-10-28T14:32:15Z",
  simulation_id = "uuid",
  event_type = "weapon_fired",
  actor = "player",
  context = {
    weapon_type = "rifle",
    unit_class = "soldier",
    mission_type = "ufo_crash"
  },
  metrics = {
    accuracy = 75,
    range = 8,
    hit = true
  },
  outcome = "hit"
}
```

**Testing**:
- [ ] Generate 1000 events in <1 second
- [ ] Verify JSON-Lines format valid
- [ ] Test log rotation
- [ ] Check file sizes manageable

**Deliverables**:
- Working log collection system
- Test suite for logging
- Performance benchmarks
- Documentation in code

---

### Task 7: Implement Auto-Balance Phase 2 - DuckDB Integration
**Status**: 🔲 TODO  
**Estimate**: 12 hours  
**Priority**: Medium  
**Dependencies**: Task 6 (Log Collection)

**Goal**: Enable SQL queries on collected data

**Files to Create**:
1. `tools/analytics/convert_logs_to_parquet.py` - Conversion script
2. `tools/analytics/duckdb_schema.sql` - Table definitions
3. `tools/analytics/test_queries.sql` - Test queries
4. `tools/analytics/requirements.txt` - Python dependencies

**Python Dependencies**:
```txt
duckdb>=0.9.0
pyarrow>=14.0.0
pandas>=2.0.0
```

**Parquet Tables to Create** (9 tables):
1. `game_events` - Raw event stream
2. `research_projects` - Research metrics
3. `manufacturing_jobs` - Production metrics
4. `combat_encounters` - Combat data
5. `unit_statistics` - Unit performance
6. `weapon_usage` - Weapon stats
7. `mission_results` - Mission data
8. `base_snapshots` - Base state history
9. `performance_metrics` - Technical metrics

**Conversion Script Features**:
- Read JSON-Lines logs
- Validate schema
- Convert to Parquet
- Partition by date
- Incremental updates
- Error handling

**Testing**:
- [ ] Convert 100K events successfully
- [ ] Query performance <100ms for aggregations
- [ ] Parquet files compressed efficiently
- [ ] Incremental updates work

**Deliverables**:
- Working conversion pipeline
- DuckDB schema
- Test queries working
- Performance benchmarks

---

## 🟢 LOW PRIORITY - Medium-Term (Weeks 5-8)

### Task 8: Implement Auto-Balance Phase 3 - KPI Calculation Engine
**Status**: 🔲 TODO  
**Estimate**: 16 hours  
**Priority**: Low  
**Dependencies**: Task 7 (DuckDB Integration)

**Goal**: Automatically calculate KPIs from data

**Files to Create**:
1. `tools/analytics/calculate_metrics.py` - Main calculation engine
2. `tools/analytics/kpi_loader.py` - TOML config loader
3. `tools/analytics/report_generator.py` - JSON report generator

**Features Required**:
- Load KPIs from `analytics_kpis.toml`
- Execute SQL queries
- Compare to targets
- Calculate status (PASS/WARN/FAIL)
- Track trends (IMPROVING/STABLE/REGRESSING)
- Generate JSON report

**Report Format**:
```json
{
  "timestamp": "2025-10-28T14:30:00Z",
  "kpis": [
    {
      "id": "combat_balance_variance",
      "name": "Combat Unit Balance",
      "category": "gameplay",
      "target": 5.0,
      "actual": 4.2,
      "delta": -0.8,
      "status": "PASS",
      "trend": "IMPROVING"
    }
  ],
  "summary": {
    "total": 20,
    "pass": 15,
    "warn": 3,
    "fail": 2
  }
}
```

**Testing**:
- [ ] All 20 KPIs calculate correctly
- [ ] Status determination accurate
- [ ] Trend calculation works
- [ ] Report generation <1 second

**Deliverables**:
- Working KPI engine
- JSON report generator
- Command-line interface
- Documentation

---

### Task 9: Create Analytics Dashboard (HTML)
**Status**: 🔲 TODO  
**Estimate**: 20 hours  
**Priority**: Low  
**Dependencies**: Task 8 (KPI Engine)

**Goal**: Visualize metrics for developers/players

**Files to Create**:
1. `tools/analytics/dashboard.html` - Main dashboard
2. `tools/analytics/dashboard.js` - JavaScript for charts
3. `tools/analytics/dashboard.css` - Styling
4. `tools/analytics/generate_dashboard.py` - Data preparation

**Dashboard Sections**:
1. **Overview** - Pass/Warn/Fail summary cards
2. **Critical KPIs** - Combat balance, FPS, economy
3. **Gameplay Metrics** - Charts for win rates
4. **Technical Metrics** - Performance graphs
5. **Trends** - Historical progression (30 days)
6. **Actions** - Auto-balance adjustments log
7. **Raw Data** - Links to Parquet files

**Visualization**:
- Use Chart.js for graphs
- Color coding: Green (PASS), Yellow (WARN), Red (FAIL)
- Responsive design (works on mobile)
- Export to PDF button

**Testing**:
- [ ] Dashboard loads <2 seconds
- [ ] Charts render correctly
- [ ] Real-time data updates
- [ ] PDF export works

**Deliverables**:
- Working HTML dashboard
- Chart visualizations
- Export functionality
- User guide

---

### Task 10: Test Auto-Balance with Simulations
**Status**: 🔲 TODO  
**Estimate**: 16 hours  
**Priority**: Low  
**Dependencies**: Task 8 (KPI Engine)

**Goal**: Verify auto-balance system works end-to-end

**Test Scenarios**:
1. **Overused Weapon Test**
   - Generate data: 60% rifle usage
   - Verify KPI fails
   - Check auto-balance suggests accuracy nerf
   - Apply adjustment
   - Re-run simulation
   - Verify usage drops to ~40%

2. **Too-Easy Mission Test**
   - Generate data: 85% easy mission success
   - Verify KPI fails
   - Check auto-balance suggests enemy count increase
   - Apply adjustment
   - Re-run simulation
   - Verify success drops to ~75%

3. **Research Pacing Test**
   - Generate data: 158 day research completion
   - Verify KPI fails
   - Check auto-balance suggests cost reduction
   - Apply adjustment
   - Re-run simulation
   - Verify completion drops to ~120 days

**Metrics to Verify**:
- KPI detection accuracy (100%)
- Auto-balance suggestions correct
- A/B testing works
- No cascading failures
- Performance acceptable

**Deliverables**:
- Test suite
- Test reports
- Performance benchmarks
- Bug fixes

---

### Task 11: Document Test Results
**Status**: 🔲 TODO  
**Estimate**: 4 hours  
**Priority**: Low  
**Dependencies**: Task 10 (Testing)

**File to Create**: `docs/handbook/ANALYTICS_TEST_RESULTS.md`

**Content**:
1. Test methodology
2. Test scenarios executed
3. Results per scenario
4. Performance measurements
5. Issues found and resolved
6. Lessons learned
7. Recommendations

**Format**: Technical report with tables and graphs

---

## 🔵 FUTURE - Long-Term (Months 2-3)

### Task 12: Implement Auto-Balance Phase 4-5 (Auto-Adjust)
**Status**: 🔲 TODO  
**Estimate**: 24 hours  
**Priority**: Future

**Goal**: Automatically modify TOML files when KPIs fail

**Features**:
- Detect failed KPIs with `auto_adjust = true`
- Calculate new values
- Generate TOML patches
- Apply patches to files
- Log adjustments
- Re-run simulations
- Verify improvements

---

### Task 13: Add ML Enhancements (Predictive Balance)
**Status**: 🔲 TODO  
**Estimate**: 40 hours  
**Priority**: Future

**Goal**: Use machine learning to predict balance issues

**Features**:
- Train ML model on historical data
- Predict future KPI failures
- Pre-emptive adjustments
- Multi-objective optimization
- Player behavior clustering

---

### Task 14: Create Advanced Analytics Features
**Status**: 🔲 TODO  
**Estimate**: 32 hours  
**Priority**: Future

**Features**:
- Correlation analysis dashboard
- Anomaly detection
- Play-style clustering
- Content generation suggestions
- Community analytics integration

---

### Task 15: Document Lessons Learned
**Status**: 🔲 TODO  
**Estimate**: 8 hours  
**Priority**: Future

**File to Create**: `docs/handbook/ANALYTICS_LESSONS_LEARNED.md`

**Content**:
- What worked well
- What didn't work
- Unexpected challenges
- Solutions developed
- Recommendations for future projects
- Industry implications

---

## 📋 Task Dependencies Graph

```
Week 1 (Immediate):
  Task 1: Add Template Sections (2h) → No dependencies
  Task 2: Team Review (1h) → No dependencies

Week 2-4 (Short-Term):
  Task 3: Balance Formulas (4h) → No dependencies
  Task 4: SQL Queries (3h) → No dependencies
  Task 5: Setup Guide (4h) → Task 4
  Task 6: Phase 1 - Logs (8h) → No dependencies
  Task 7: Phase 2 - DuckDB (12h) → Task 6

Week 5-8 (Medium-Term):
  Task 8: Phase 3 - KPI Engine (16h) → Task 7
  Task 9: Dashboard (20h) → Task 8
  Task 10: Testing (16h) → Task 8
  Task 11: Test Results (4h) → Task 10

Months 2-3 (Future):
  Task 12: Phase 4-5 (24h) → Task 10
  Task 13: ML Enhancements (40h) → Task 12
  Task 14: Advanced Features (32h) → Task 12
  Task 15: Lessons Learned (8h) → Task 14
```

---

## 📊 Summary

**Total Tasks**: 15  
**Immediate Priority**: 2 tasks (3 hours)  
**Short-Term Priority**: 5 tasks (43 hours)  
**Medium-Term Priority**: 4 tasks (56 hours)  
**Future Priority**: 4 tasks (104 hours)

**Total Estimated Time**: 206 hours (~5 weeks full-time)

**Critical Path**:
1. Team Review (1h)
2. Phase 1: Logs (8h)
3. Phase 2: DuckDB (12h)
4. Phase 3: KPI Engine (16h)
5. Testing (16h)
6. Phase 4-5: Auto-Adjust (24h)

**Total Critical Path**: 77 hours (~2 weeks full-time)

---

## 🎯 Recommended Execution Order

**Sprint 1 (Week 1)**: Tasks 1, 2 → Quick wins, foundation
**Sprint 2 (Week 2)**: Tasks 3, 4, 6 → Documentation + Infrastructure
**Sprint 3 (Week 3)**: Tasks 5, 7 → Integration
**Sprint 4 (Week 4)**: Task 8 → Core functionality
**Sprint 5 (Week 5-6)**: Tasks 9, 10, 11 → Testing & UI
**Sprint 6+ (Months 2-3)**: Tasks 12-15 → Advanced features

---

## 📝 Notes

- All SQL queries and KPI definitions already complete (Phase 0)
- Documentation framework in place (FAQ, GLOSSARY updated)
- Auto-balance design fully specified in Analytics.md
- Focus on implementation, not design
- Test-driven approach recommended
- Incremental releases preferred

---

**Created**: 2025-10-28  
**Last Updated**: 2025-10-28  
**Next Review**: After Task 2 (Team Review)

