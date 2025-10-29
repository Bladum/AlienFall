# FAQ: Analytics & Auto-Balance System

> **Audience**: Players and modders interested in game balance and AI testing  
> **Last Updated**: 2025-10-28  
> **Related Mechanics**: [Analytics.md](../mechanics/Analytics.md), [AI.md](../mechanics/AI.md)

---

## Quick Navigation

- [How Does Auto-Balance Work?](#how-does-auto-balance-work)
- [Autonomous Playtesting](#autonomous-playtesting)
- [KPIs and Metrics](#kpis-and-metrics)
- [Player Data Privacy](#player-data-privacy)
- [Comparison to Other Games](#comparison-to-other-games)

---

## How Does Auto-Balance Work?

### Q: How does AlienFall balance itself automatically?

**A**: **Continuous data-driven feedback loop** (nothing like this exists in other strategy games).

**The 5-Stage Pipeline**:

```
1. SIMULATION → AI plays game millions of times
2. DATA COLLECTION → Every action logged to files
3. ANALYSIS → SQL queries extract patterns
4. METRICS → Compare actual vs target values
5. AUTO-ADJUST → Change game files if metrics fail
```

**Example Auto-Balance in Action**:
```
Week 1: Rifles used in 60% of loadouts (target: 40%)
  → Analytics detects: "Rifle overused"
  → Auto-balance adjusts: Rifle accuracy 75 → 71 (-5%)
  → TOML file updated automatically

Week 2: Re-test with simulations
  → Rifles now used in 42% of loadouts ✓
  → Metric passes, adjustment confirmed

Week 3: Deploy to players
  → All players get balanced rifles
  → No patch download needed (data file change)
```

**Philosophy**: Game should tune itself based on data, not designer intuition.

---

### Q: Can I disable auto-balance?

**A**: **Yes** - Multiple control levels.

**Options**:
- **Full Auto** (default): Game adjusts itself based on analytics
- **Manual Approve**: Game suggests changes, you approve/reject
- **Purist Mode**: Disable all auto-balance (fixed values)
- **View Only**: See analytics but no adjustments

**How to Enable Purist Mode**:
```toml
# mods/your_mod/config/analytics.toml
[settings]
auto_balance_enabled = false
show_analytics_dashboard = true  # Still see data
```

**Why You Might Disable**:
- Speedrunning (fixed rules for competition)
- Challenge runs (deliberate imbalance)
- Modding (testing your own balance)
- Nostalgia (preserve specific game version)

---

### Q: What happens if auto-balance makes game worse?

**A**: **A/B testing prevents bad changes** (like tech companies test website changes).

**Safety Process**:
1. **Detect Issue**: Metric fails (e.g., mission too easy at 85% win rate)
2. **Calculate Fix**: Increase enemy count by 15%
3. **Test on 10%**: Deploy to 10% of AI simulations only
4. **Compare Results**: Did 10% improve? Check all metrics.
5. **Multi-Metric Check**:
   - Mission difficulty: 85% → 75% ✓ (improved)
   - Mission duration: 25min → 28min ✓ (acceptable)
   - Player casualties: 2 → 2.5 ✓ (acceptable)
   - Economy impact: No change ✓
6. **Deploy or Revert**:
   - If ALL metrics improve or acceptable → Deploy to 100%
   - If ANY metric fails threshold → Revert, try different adjustment

**Comparison**:
- **XCOM 2**: Patches deployed to everyone, reverted if broken (weeks)
- **AlienFall**: Test first, deploy only if verified (hours)

---

## Autonomous Playtesting

### Q: How does AI test the game?

**A**: **Dual-AI architecture** - One AI plays as player, other plays as enemy.

**The Two AIs**:

### 1. Faction AI (Enemy)
- **What**: Native game AI controlling alien factions
- **Purpose**: Generate realistic enemy behavior
- **Like**: The aliens in XCOM playing optimally
- **Capabilities**: Mission generation, unit deployment, tactical combat

### 2. Player AI (Tester)
- **What**: Separate AI mimicking human player behavior
- **Purpose**: Test game from player perspective
- **Like**: Robotic QA tester playing 24/7
- **Capabilities**: Base building, research, unit deployment, UI clicks

**How They Interact**:
```
Turn 1: Player AI decides "Build research lab" → Clicks menus → Confirms
Turn 2: Faction AI spawns UFO → Approaches player base
Turn 3: Player AI detects UFO → Deploys craft → Starts interception
Turn 4: Combat resolves → Player AI wins or loses
Turn 5: Faction AI adjusts strategy based on outcome
... Repeat for 12 months game time = 1 campaign
```

**Scale**:
- **Simulations running**: 100+ simultaneously
- **Campaigns per day**: 50-100 full campaigns
- **Data generated**: 10M+ events per week
- **Analysis time**: Overnight (runs during low activity)

---

### Q: Is the Player AI smart?

**A**: **Yes, but not perfect** (intentionally).

**Player AI Intelligence Levels**:
- **Novice** (30%): Makes beginner mistakes (overbuilds, ignores research)
- **Average** (50%): Competent but not optimal (like typical player)
- **Veteran** (15%): Strong strategic play (like experienced player)
- **Expert** (5%): Near-optimal play (like speedrunner)

**Why Mix Skill Levels?**:
- Beginner players need balanced experience too
- Ensures game works for all skill ranges
- Identifies newbie trap mechanics
- Veteran data shows upper limits

**Comparison to Other Games**:
- **XCOM 2**: Manual QA testers (expensive, slow)
- **Civilization VI**: Some automated testing (limited scope)
- **AlienFall**: Fully autonomous AI players at all skill levels

---

### Q: Does Player AI click through UI like humans?

**A**: **Yes** - Simulates actual UI interaction.

**What Player AI Does**:
- Opens menus by name (`geoscape_menu.research`)
- Clicks buttons with mouse coordinates
- Waits for animations/transitions
- Reads UI state (button enabled/disabled)
- Makes decisions based on visible information
- Tracks time spent per screen (heatmaps)

**Why This Matters**:
- Detects UI bugs (button doesn't work)
- Identifies slow UI flows (too many clicks)
- Measures UI discoverability (AI can't find feature)
- Optimizes UI performance (slow rendering)

**Example Analytics**:
```
Research Screen Performance:
- Average load time: 1.2 seconds
- Average clicks to start research: 3.5
- Average time to decision: 8 seconds
- Success rate: 97% (AI completes action)

→ Insight: 3% failure rate needs investigation
→ Action: Investigate why AI can't complete 3% of actions
```

---

## KPIs and Metrics

### Q: What are KPIs?

**A**: **Key Performance Indicators** - Measurable goals defining "good game."

**Core KPI Categories**:

### 1. Combat Balance KPIs
- **Unit Win Rate Variance**: All unit classes 45-55% win rate (<5% variance)
- **Weapon Usage Distribution**: No weapon >50% usage (avoid dominance)
- **Mission Success Rates**: Easy 70-80%, Normal 50-60%, Hard 30-40%

### 2. Progression Pacing KPIs
- **Research Completion Time**: Critical path research in 100-140 days
- **Campaign Completion Rate**: 40%+ players reach endgame
- **Level Progression Speed**: Players reach level 5 by month 3

### 3. Economy Sustainability KPIs
- **Monthly Budget Balance**: Break-even by month 6
- **Manufacturing Profitability**: 70%+ items profitable vs marketplace
- **Funding Stability**: <20% funding variance month-to-month

### 4. Technical Performance KPIs
- **Frame Rate (P95)**: 95% of frames >55 FPS
- **Load Times**: Scene loading <3 seconds
- **Memory Usage**: <2GB RAM (stable, no leaks)

### 5. Player Engagement KPIs
- **Campaign Retention**: 40%+ complete campaigns
- **UI Success Rate**: 95%+ intended actions succeed
- **Feature Discovery**: 70%+ players use advanced features

---

### Q: What happens when KPI fails?

**A**: **Automatic root cause analysis** → **Suggested fix** → **A/B test** → **Deploy or revert**.

**Example: Research Pacing Failure**

```
FAILED KPI: Research Pacing
Current Value: 158 days | Target: 120±20 days | Status: FAIL (+38 days)

ROOT CAUSE ANALYSIS:
Alien Research Category: +35% slower than expected
  - Alien Interrogation: 85 days (expected 60) → Bottleneck
  - Alien Autopsy: 72 days (expected 50)
  
RECOMMENDED ACTIONS:
1. Reduce alien_interrogation cost: 85 → 65 man-days (-23%)
2. Reduce alien_autopsy cost: 72 → 50 man-days (-31%)
3. Impact estimate: Total = 120 days (meets target)

IMPLEMENTATION:
File: mods/core/rules/research/alien_projects.toml
Changes:
  [project.alien_interrogation]
  - cost = 85
  + cost = 65
  
  [project.alien_autopsy]
  - cost = 72
  + cost = 50

A/B TEST RESULTS (10% of simulations):
- Research pacing: 158 → 122 days ✓ (passes)
- Campaign completion: 28% → 34% ✓ (improves)
- Economy: -2.5K → -4.2K ⚠ (acceptable)

DECISION: DEPLOY (3 metrics improve, 0 fail)
```

---

### Q: Can I see the analytics dashboard?

**A**: **Yes** - Multiple ways to view data.

**Access Methods**:

### 1. In-Game Dashboard (Future)
- Press F12 in main menu
- Shows current KPI status (PASS/WARN/FAIL)
- Displays trend graphs
- Links to detailed reports

### 2. HTML Dashboard (Available Now)
- Run: `tools/analytics/generate_dashboard.bat`
- Opens in browser
- Shows all KPIs with charts
- Export to PDF

### 3. Raw Data (Advanced)
- Location: `logs/analytics/*.parquet`
- Query with: DuckDB (`duckdb analytics.db`)
- SQL examples: `tools/analytics/example_queries.sql`

**Example Dashboard**:
```
==================================
ALIENFALL ANALYTICS DASHBOARD
Generated: 2025-10-28 14:30:00
==================================

CRITICAL METRICS:
✓ Combat Balance: 4.2% variance (Target: <5%) - PASS
✗ Frame Rate (P95): 48 FPS (Target: >55) - FAIL
✓ UI Success Rate: 97.1% (Target: >95%) - PASS

HIGH PRIORITY METRICS:
⚠ Research Pacing: 158 days (Target: 120±20) - WARN
✓ Economy: -2.5K credits (Target: ±0) - PASS
⚠ Retention: 28% (Target: >30%) - WARN

TRENDS (Last 30 Days):
Combat Balance: 5.1% → 4.6% → 4.2% (IMPROVING ↗)
Frame Rate: 42 → 45 → 48 FPS (IMPROVING ↗)
Research Pacing: 145 → 152 → 158 days (REGRESSING ↘)
```

---

## Player Data Privacy

### Q: Is my gameplay data collected?

**A**: **Optional** - Off by default, transparent if enabled.

**Default Behavior**:
- Local analytics only (never leaves your PC)
- Used for single-player balance
- No internet connection required
- Stored in `logs/analytics/` (you can delete)

**Optional Telemetry** (requires explicit opt-in):
- Anonymous gameplay statistics
- Helps improve balance for everyone
- No personal information collected
- Can opt-out anytime

**What IS Collected** (if enabled):
- Mission outcomes (win/loss)
- Weapon usage rates
- Unit survival rates
- Performance metrics (FPS, load times)
- UI interaction patterns (which menus used)

**What IS NOT Collected**:
- ❌ Personal information (name, email, etc.)
- ❌ System information (beyond OS type)
- ❌ Screenshots or video
- ❌ Mods installed
- ❌ Save file contents

**How to Check**:
```toml
# engine/config/analytics.toml
[telemetry]
enabled = false  # Default OFF
anonymous_id = "uuid"  # Random, not tied to you
upload_frequency = "never"  # Options: never, weekly, monthly
```

---

## Comparison to Other Games

### Q: How is this different from other games?

**A**: **No other strategy game has this level of auto-balance**.

| Game | Balance Method | Speed | Transparency |
|------|----------------|-------|--------------|
| **XCOM 2** | Designer intuition + QA | Patches every 3-6 months | Opaque (no metrics shown) |
| **Civilization VI** | AI gets stat cheats on Hard | Fixed (never rebalanced) | Hidden (cheats not disclosed upfront) |
| **Phoenix Point** | Forum feedback + designer | Patches every 2-3 months | Partial (patch notes) |
| **Slay the Spire** | Designer + community data | Patches every 6-12 months | Good (detailed patch notes) |
| **AlienFall** | **Automated AI testing + SQL analytics** | **Continuous (daily)** | **Full (dashboards, KPIs, open data)** |

**What Makes AlienFall Unique**:
1. **Fully Automated**: AI plays game 24/7, no human QA needed
2. **Data-Driven**: SQL queries define balance, not opinions
3. **Continuous**: Improves daily, not quarterly patches
4. **Transparent**: Players see metrics and adjustments
5. **A/B Tested**: Changes verified before deployment
6. **Player Control**: Can disable or customize auto-balance

---

### Q: Do professional esports games use auto-balance?

**A**: **No** - They use manual balance patches after tournaments.

**Comparison**:

### StarCraft II (RTS)
- **Method**: Pro player feedback + win rate data
- **Frequency**: Patches every 2-3 months
- **Transparency**: Detailed patch notes
- **Limitation**: Reactive (after meta becomes stale)

### League of Legends (MOBA)
- **Method**: Large data team + designer judgment
- **Frequency**: Patches every 2 weeks
- **Transparency**: Win rate data published
- **Limitation**: Still manual analysis and decisions

### AlienFall (Strategy)
- **Method**: Autonomous AI testing + SQL analytics
- **Frequency**: Continuous (daily adjustments possible)
- **Transparency**: Full KPI dashboards
- **Advantage**: Proactive (detects issues before players notice)

**Why Others Don't Use This**:
- Competitive games need stable meta (players practice)
- Auto-balance could disrupt tournament preparation
- Single-player games don't need daily balance
- AlienFall benefits: Single-player, moddable, sandbox (no fixed meta)

---

### Q: Is this like machine learning game design?

**A**: **Similar but simpler** - Rule-based analytics, not neural networks (yet).

**Current System**:
- **Analytics**: SQL queries on gameplay data
- **Rules**: If-then logic (if weapon overused → reduce accuracy)
- **Transparent**: You can read the rules
- **Predictable**: Same input = same output

**Future ML Enhancements** (ideas/experiments):
- **Predictive Balance**: ML predicts future issues
- **Multi-Objective Optimization**: Balance competing KPIs
- **Play-Style Clustering**: Identify player archetypes
- **Content Generation**: AI suggests new units/weapons

**Why Start Simple**:
- Easier to debug and understand
- Transparent to players
- Predictable behavior
- Foundation for future ML

---

### Q: Can modders use the analytics system?

**A**: **Yes** - Full access to infrastructure.

**What Modders Can Do**:
1. **Define Custom KPIs**: Add your own balance metrics
2. **Run Simulations**: Test your mod with AI players
3. **View Analytics**: See how players use your content
4. **Auto-Balance Mods**: Enable auto-tuning for your content
5. **Export Data**: Share balance data with community

**Example Mod KPI**:
```toml
# mods/my_mod/config/analytics_kpis.toml
[kpi.my_weapon_balance]
name = "Laser Rifle Usage"
category = "gameplay"
target_value = 40.0  # 40% usage ideal
sql_query = """
  SELECT COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM unit_loadouts) 
  FROM unit_loadouts 
  WHERE weapon_type = 'laser_rifle'
"""
threshold_warn = 50.0
threshold_fail = 60.0
auto_adjust = true
adjustment_target = "weapon_accuracy"
adjustment_factor = -0.05
```

**Community Benefits**:
- Mods stay balanced automatically
- Data-driven mod development
- Compare mod balance to core game
- Share analytics with other modders

---

## Advanced Topics

### Q: How does correlation analysis work?

**A**: **Identifies relationships between metrics**.

**Example: Research Speed vs Campaign Completion**

```sql
-- Do players who research faster complete more campaigns?
SELECT 
  CASE 
    WHEN avg_research_ratio < 0.8 THEN 'Fast Research'
    WHEN avg_research_ratio < 1.2 THEN 'Normal Research'
    ELSE 'Slow Research'
  END as research_pace,
  AVG(CASE WHEN completed THEN 100 ELSE 0 END) as completion_rate
FROM research_speed
JOIN completion ON research_speed.campaign_id = completion.campaign_id
GROUP BY research_pace;

Results:
Fast Research: 45% completion rate
Normal Research: 35% completion rate
Slow Research: 22% completion rate

→ Insight: Faster research correlates with completion
→ Hypothesis: Players who research faster enjoy game more
→ Action: Review slow research projects (possible bottlenecks)
```

**Other Correlations Tracked**:
- Economy health ↔ Campaign length
- Unit diversity ↔ Mission success
- Base count ↔ Difficulty scaling
- Craft fleet size ↔ UFO interception rate

---

### Q: What's the most innovative KPI?

**A**: **Cascading Effects Analysis** - Tracks secondary impacts.

**Problem**: Changing one value affects many systems.

**Example**:
```
PROPOSED CHANGE: Reduce research costs by 20%

DIRECT IMPACT:
✓ Research pacing: 158 → 125 days (IMPROVES)

CASCADING EFFECTS:
✓ Campaign completion: 28% → 34% (IMPROVES - players progress faster)
⚠ Economy: -2.5K → -4.2K (WORSENS - less time to earn money)
✓ Player retention: 28% → 32% (IMPROVES - less grind)
✓ Difficulty: Easier (IMPROVES - players get tech faster)
⚠ Manufacturing: +15% idle time (WORSENS - less time to produce)

NET ASSESSMENT:
+3 metrics improve, -2 metrics worsen (but within threshold)
DECISION: DEPLOY (net positive impact)
```

**Why This Matters**:
- Prevents "whack-a-mole" balance (fix one, break another)
- Holistic view of game health
- Identifies unintended consequences

---

## Resources

- **[Analytics System Design](../mechanics/Analytics.md)** - Complete technical specification
- **[AI Systems](../mechanics/AI.md)** - Faction AI and Player AI details
- **[SQL Query Examples](../../tools/analytics/example_queries.sql)** - Copy-paste analytics
- **[Analytics Setup Guide](../../docs/handbook/ANALYTICS_SETUP.md)** - Developer guide

---

[← Back to FAQ Index](FAQ_INDEX.md)

