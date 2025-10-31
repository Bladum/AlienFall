# 🎯 CRITICAL_007: Fix XP Progression Speed

**Severity**: 🔴 CRITICAL
**Blocker For**: Campaign balance, unit progression, long-term engagement
**Estimated Effort**: 6 hours
**Dependencies**: C4 (Master Stat Table) - referenced for progression arcs

---

## OVERVIEW

**Problem**: XP progression speed creates pacing contradictions:

1. **Current Specification**:
   - Average mission reward: 110 XP
   - Rank 6 requires: 2100 total XP
   - Calculation: 2100 ÷ 110 = ~19 missions to max rank

2. **Contradictions Found**:
   - Units.md says "unit reaches elite status at rank 5-6"
   - Progression suggests 19+ missions to reach elite
   - Campaign duration unclear: Is 19 missions realistic? (3-4 months of play?)
   - Is leveling meant to be fast or slow?

3. **Design Intent Missing**:
   - No statement of intended campaign length
   - No guidance on leveling pace (should roster rotate or specialize?)
   - Balance assumptions unclear (one strong unit vs. balanced roster?)

4. **Impact**:
   - Campaign balance can't be tuned without known progression speed
   - Difficulty scaling impossible
   - Roster rotation strategy undefined
   - Long-term engagement unclear

**Solution**: Define intended progression speed explicitly and resolve contradictions.

---

## DESIGN SPECIFICATION

### Section 1: Current Progression Analysis

#### Existing Specifications (From Units.md)

```
XP Sources per mission:
  Kill (alien):           10 XP per kill
  Kill (soldier):         0 XP (friendly fire penalty)
  Damage dealt:           0.2 XP per damage point
  Mission completion:     50 XP flat bonus
  Squad alive bonus:      10 XP (all squad alive)
  Objective bonus:        10-30 XP (per objective)

Average mission:
  Kills: 8 aliens × 10 = 80 XP
  Damage: 500 damage × 0.2 = 100 XP (alternative calculation)
  Completion: 50 XP
  Bonuses: 10-30 XP
  Total: 110-150 XP per mission

Used value: 110 XP (conservative estimate)
```

#### Rank XP Requirements (From Units.md)

```
Rank    Total XP Needed    XP to Next    Cumulative Missions
──────────────────────────────────────────────────────────────
1       0                  0             0 (start)
2       100                100           0.9
3       300                200           1.8
4       600                300           2.7
5       1100               500           4.5
6       2100               1000          9.1
7       3500               1400          12.7
8       5000               1500          13.6
```

**Problem**: Column "Cumulative Missions" is rough estimate - XP varies per mission

#### Current Progression Speed

```
At average 110 XP/mission:

Rank 1→2: 0.9 missions (reached immediately)
Rank 2→3: 1.8 missions
Rank 3→4: 2.7 missions
Rank 4→5: 4.5 missions
Rank 5→6: 9.1 missions (MAJOR JUMP)
Rank 6→7: 12.7 missions
Rank 7→8: 13.6 missions

Total to Rank 5 (elite): ~9 missions
Total to Rank 6: ~19 missions
Total to Rank 8: ~45+ missions
```

**Question**: Is 9 missions the intended "elite" threshold, or 19 missions?

### Section 2: Design Intent - Choose Progression Philosophy

#### Option A: FAST PROGRESSION (Roster Specialization)

**Philosophy**:
- Units reach combat effectiveness quickly
- Focus on specialization and role variety
- Roster rotation less necessary
- Campaign emphasis on strategy, not grinding

**Specifications**:

```
Progression Speed:     Reach max rank in 20-25 missions (~2-3 months play)
XP per mission:        150 XP average (higher rewards)
Rank 5 (elite):        9-12 missions (1-2 weeks of play)
Rank 8 (veteran):      30-35 missions (3-4 months)

Implications:
- Soldiers become powerful quickly
- Individual unit specialization matters
- Roster: 12-16 soldiers rotate
- Campaign spans 60-80 missions total
- Difficulty scaling: Late game uses harder missions
```

**Impact on Campaign**:
```
Early game (Missions 1-10): Rookies learn
Mid game (Missions 11-30): Mixed rookie/elite squads
Late game (Missions 31+): All elite, various specializations
End game (Missions 70+): Veteran elite force vs. final threats
```

#### Option B: MEDIUM PROGRESSION (Balanced Roster)

**Philosophy**:
- Units reach combat effectiveness in moderate time
- Encourages balanced roster with specialists
- Some rotation, some specialization
- Campaign emphasis on both strategy and progression

**Specifications**:

```
Progression Speed:     Reach max rank in 35-45 missions (~4-5 months)
XP per mission:        110 XP average (current)
Rank 5 (elite):        13-17 missions (2-3 weeks of play)
Rank 8 (veteran):      50-60 missions (5-6 months)

Implications:
- Soldiers develop slowly
- Roster requires rotation and training
- Roster: 16-20 soldiers with specialists
- Campaign spans 100-120 missions total
- Difficulty scaling: Combined with difficulty increase
```

**Impact on Campaign**:
```
Early game (Missions 1-15): Rookie squads, high casualty risk
Mid game (Missions 16-40): Mixed roster, veterans emerging
Late game (Missions 41-60): Mostly elite, specialists dominant
End game (Missions 80+): All veteran with specialists
```

#### Option C: SLOW PROGRESSION (Deep Specialization)

**Philosophy**:
- Units develop slowly over very long campaign
- Deep specialization and character attachment
- Heavy roster rotation required
- Campaign emphasizes long-term planning

**Specifications**:

```
Progression Speed:     Reach max rank in 60-80 missions (~6-8 months)
XP per mission:        75 XP average (lower rewards, slower gains)
Rank 5 (elite):        25-30 missions (3-4 weeks of play)
Rank 8 (veteran):      90-100 missions (9-10 months)

Implications:
- Soldiers stay weak for a long time
- Specialization takes commitment
- Roster requires heavy rotation
- Roster: 20-30 soldiers with deep specializations
- Campaign spans 150-200 missions total
- Difficulty scaling: Extended to very late game
```

**Impact on Campaign**:
```
Early game (Missions 1-25): Mostly rookies, permadeath emphasis
Mid game (Missions 26-65): Slow elite emergence
Late game (Missions 66-100): Mixed elite and specialists
End game (Missions 150+): Full veteran force
```

### Section 3: RECOMMENDED DECISION

**Based on XCOM 1 & 2 precedent + modern game engagement:**

**RECOMMENDED: Option B (Medium Progression)**

**Rationale**:
1. Matches player expectation (40-50 mission campaign)
2. Provides enough rotation to make roster matter
3. Balances grind vs. specialization
4. Mid-ground between grinding and too-fast power
5. Risk/reward: Specializing vs. keeping backup
6. Aligns with turn-based tactics games (Fire Emblem, XCOM 2)

**Decision Authority**: Lead Game Designer (must confirm)

### Section 4: Detailed XP System Specification

#### XP Reward Formula

**Mission XP = Base Completion XP + Performance XP + Bonus XP**

```
Base Completion XP:    50 XP (any mission won)

Performance XP:
  Per alien kill:      10 XP
  Per damage dealt:    0.15 XP (covers abilities, equipment effects)
  Per turn survived:   1 XP (encourages staying alive)
  Per squad alive:     10 XP (bonus if no casualties)

Bonus XP (optional objectives):
  Per objective complete: 10-20 XP
  Research reward:        10-50 XP (mission-specific)
  Difficulty bonus:       0-30 XP (scaled by difficulty)

Typical Mission Breakdown:
  Easy (tutorial):       50-80 XP
  Normal:               100-150 XP
  Hard:                 150-220 XP
  Impossible:           200-300 XP
```

#### Example Calculation

```
Normal difficulty, squad of 4, 8 aliens:

Base:              50 XP
Kills:      8 × 10 = 80 XP (4 kills per soldier on average)
Damage:   600 × 0.15 = 90 XP (150 damage per soldier)
Turns:    12 × 1 = 12 XP (12 turns in battle)
Alive:            10 XP (full squad survived)
──────────────────────────
Total:           242 XP per soldier

For full squad of 4:
  Soldier A: 242 XP
  Soldier B: 242 XP
  Soldier C: 242 XP
  Soldier D: 242 XP

Total pool: 242 × 4 = 968 XP distributed
Average per soldier: 242 XP (higher than current 110!)
```

#### Difficulty Scaling

```
Difficulty    XP Multiplier    Base Mission    Example Hard
─────────────────────────────────────────────────────────────
Tutorial      0.5x             50 XP           25-40 XP
Rookie        0.8x             110 XP          88-140 XP
Normal        1.0x             110 XP          110 XP
Hard          1.5x             110 XP          165 XP
Impossible    2.0x             110 XP          220 XP

Scaling logic:
  More aliens = more kills = more XP (automatic)
  Harder AI = longer battles = more turns = more XP
  Higher difficulty = higher bonus = more XP
```

### Section 5: Rank XP Rebalance

#### Option A: Faster Progression (Match decision if chosen)

```
Rank    New XP Total    XP Gain    Missions @ 140 XP/avg
──────────────────────────────────────────────────────────
1       0               0          0 (start)
2       70              70         0.5
3       180             110        0.8
4       340             160        1.1
5       580             240        1.7 (elite threshold)
6       1040            460        3.3
7       1680            640        4.6
8       2500            820        5.9
Total                              ~17-18 missions to rank 8
```

#### Option B: Medium Progression (RECOMMENDED)

```
Rank    New XP Total    XP Gain    Missions @ 110 XP/avg
──────────────────────────────────────────────────────────
1       0               0          0 (start)
2       100             100        0.9
3       280             180        1.6
4       580             300        2.7
5       1100            520        4.7 (elite threshold)
6       2100            1000       9.1 (veteran threshold)
7       3500            1400       12.7
8       5200            1700       15.5
Total                              ~47 missions to rank 8
```

#### Option C: Slower Progression

```
Rank    New XP Total    XP Gain    Missions @ 75 XP/avg
──────────────────────────────────────────────────────────
1       0               0          0 (start)
2       150             150        2.0
3       400             250        3.3
4       800             400        5.3
5       1600            800        10.7 (elite threshold)
6       3200            1600       21.3 (veteran threshold)
7       5200            2000       26.7
8       8000            2800       37.3
Total                              ~107 missions to rank 8
```

### Section 6: Campaign Duration & Pacing

#### Campaign Length Implications

**If using Option B (Medium, RECOMMENDED)**:

```
Campaign Structure:
  Geoscape months:      12-15 months in-game
  Missions per month:   4-5 missions average
  Total missions:       50-75 campaign length
  Playtime estimate:    40-60 hours

Unit Progression:
  Month 1-2: Rookies only, high casualties
  Month 3-4: First elites emerging, mixed squads
  Month 5-8: Balanced elite/rookie squads
  Month 9-12: Mostly elite, specialists rotating
  Month 13+: Full elite force, endgame challenge

Squad Composition Over Time:
  Month 1: 100% rookies (5 soldiers)
  Month 4: 40% elite, 60% rookie (8 soldiers, rotation)
  Month 8: 70% elite, 30% rookie (12 soldiers, specialization)
  Month 12: 90% elite, 10% rookie (14 soldiers, vets only)
```

#### Pacing Checkpoints

```
Story Milestone          Typical Mission    Unit Status
──────────────────────────────────────────────────────────
Game Start              1-5                All rookies
First Elite Promoted    7-10               Mixed rookie/elite
50% Squad Elite         15-20              Specialization emerges
Full Elite Squad        35-45              Veterans stabilize
Final Mission           50-75              Full veteran force
```

### Section 7: Addressing Original Contradictions

#### Contradiction 1: "Elite status at rank 5" vs. "takes 19 missions"

**Resolution**:
```
Elite threshold = Rank 5
Progression speed = Medium (Option B)
Result = 4-5 missions to Rank 5 elite status
So: "Rank 5 elite status typically achieved by mission 5-10"
This is aligned with XCOM 1 veteran pacing
```

#### Contradiction 2: Campaign duration unclear

**Resolution**:
```
Clear statement: "AlienFall campaign is 50-75 missions over 12-15 months"
This is standard for turn-based tactics games
Modular campaign: Can extend with DLC missions
```

#### Contradiction 3: Roster rotation strategy unclear

**Resolution**:
```
Design intent: "Mixed roster with rotating specialists"
- Early: Must rotate (limited elite)
- Mid: Choice to rotate or specialize
- Late: Can specialize (enough elite)
Balance goal: Specialization rewarded but not forced
```

---

## ACCEPTANCE CRITERIA

This task is complete when:

- ✅ Progression speed philosophy chosen (Option A/B/C decided)
- ✅ XP reward formula documented with examples
- ✅ Rank XP requirements finalized
- ✅ Campaign duration/pacing specified
- ✅ All contradictions resolved
- ✅ Documentation updated (Units.md, Economy.md if needed)
- ✅ Difficulty scaling integrated
- ✅ Designer decision documented
- ✅ Team communicated
- ✅ Code ready to implement

---

## IMPLEMENTATION PLAN

### Step 1: Design Decision Meeting (1h)
1. Present 3 options to designer
2. Get explicit decision: Option A, B, or C?
3. Document decision in Design Decisions Log
4. Confirm with balance team

### Step 2: Create Authoritative Specification (1h)
1. Create `design/mechanics/XP_PROGRESSION_SPECIFICATION.md`
2. Include chosen option with full specification
3. Add campaign pacing timeline
4. Add example progression curves

### Step 3: Update Core Documents (1h)
1. Update Units.md: Reference chosen progression speed
2. Update Economy.md: Align reward scaling with progression
3. Update Missions.md: Document XP per mission type
4. Update README.md: Clarify campaign duration

### Step 4: Implement XP System (1.5h)
1. Create `engine/utils/xp_calculator.lua`
2. Implement `calculate_mission_xp()` function
3. Implement `get_rank_xp_requirement()` function
4. Create unit tests for XP calculations

### Step 5: Integrate Difficulty Scaling (1h)
1. Connect mission difficulty to XP multiplier
2. Create XP projection table
3. Validate progression against pacing
4. Get balance designer approval

### Step 6: Communicate & Test (0.5h)
1. Brief development team on progression speed
2. Create quick-reference progression chart
3. Verify implementation matches specification
4. Document in developer handbook

---

## TESTING STRATEGY

### Test Scenarios

**Scenario 1: XP Reward Calculation**
```
Normal mission, 8 aliens killed:
  Base: 50 XP
  Kills: 8 × 10 = 80 XP
  Damage: 500 × 0.15 = 75 XP
  Turns: 10 × 1 = 10 XP
  Bonus: 10 XP (all alive)
  Total: 225 XP per soldier ✓
```

**Scenario 2: Progression to Elite**
```
Using Option B (Medium):
  Rank 1→5 progression should reach ~4-5 missions
  Average 110 XP/mission = 550 total needed
  550 ÷ 110 = 5 missions ✓
```

**Scenario 3: Campaign Duration**
```
Option B: 50-75 missions expected
  If 5 missions/month: 10-15 months campaign
  Matches design intent ✓
```

**Scenario 4: Difficulty Scaling**
```
Hard mission (1.5x multiplier):
  Base calculation: 110 XP
  Hard multiplier: 110 × 1.5 = 165 XP
  Verify difficulty tier bonuses stack correctly
```

---

## DOCUMENTATION TO UPDATE

| File | Section | Change |
|------|---------|--------|
| design/mechanics/Units.md | XP Progression | Reference new progression speed |
| design/mechanics/Missions.md | Mission XP | Add XP calculation details |
| design/mechanics/Economy.md | Campaign timing | Add campaign duration estimate |
| design/DESIGN_DECISIONS_LOG.md | New | Document XP progression decision |
| api/GAME_API.toml | [unit.ranks] | Update XP thresholds |

---

## COMPLETION CHECKLIST

- [ ] Get designer decision on Option A/B/C
- [ ] Create specification document
- [ ] Update all cross-references
- [ ] Create XP calculator code
- [ ] Test progression speed
- [ ] Verify campaign pacing
- [ ] Get balance designer approval
- [ ] Brief team on progression speed
- [ ] Create progression reference chart
- [ ] Validate against XCOM precedent

---

## NOTES

**Decision Authority**: Lead Game Designer - must choose progression speed
**Coordinates With**: Economy system, difficulty scaling, mission design
**Impact**: Campaign pacing, long-term engagement, roster strategy
**Reference**: XCOM 1 (40-50 mission campaign) and XCOM 2 (40+ hour campaign)

---

**Created**: October 31, 2025
**Status**: AWAITING DESIGNER DECISION
**Approver**: Lead Game Designer
