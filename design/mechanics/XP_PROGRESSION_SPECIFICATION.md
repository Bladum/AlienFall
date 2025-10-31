# XP Progression Specification

**Status**: Design Specification
**Last Updated**: 2025-10-31
**Related Systems**: Units.md, Missions.md, Economy.md

## Overview

This specification defines the Experience Point (XP) progression system for AlienFall units. The system has been redesigned to resolve pacing contradictions and provide meaningful campaign progression.

**Design Decision**: Medium Progression (Option B)
- Campaign length: 50-75 missions over 12-15 months
- XP per mission: 110 XP average
- Elite threshold (Rank 5): 13-17 missions (~1870 XP total)
- Hero threshold (Rank 6): 35-45 missions (~4950 XP total)

## Core XP Reward Formula

### Mission XP = Base Completion XP + Performance XP + Bonus XP

```
Base Completion XP:    50 XP (any mission won)

Performance XP:
  Per alien kill:      10 XP
  Per damage dealt:    0.15 XP per point (max 100 XP per mission)
  Per turn survived:   1 XP (max 20 XP per mission)
  Per squad alive:     10 XP (full squad bonus)

Bonus XP (optional objectives):
  Per objective complete: 10-30 XP
  Research reward:        10-50 XP (mission-specific)
  Difficulty bonus:       0-30 XP (scaled by difficulty)

Typical Mission Breakdown:
  Normal difficulty:     100-150 XP per soldier
  Hard difficulty:       150-220 XP per soldier
  Impossible difficulty: 200-300 XP per soldier
```

### Example Calculation

```
Normal difficulty mission, squad of 4, 8 aliens:

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
Average per soldier: 242 XP
```

## Rank XP Requirements (Medium Progression)

| Rank | Total XP Needed | XP to Next | Missions @ 110 XP/avg | Status |
|------|-----------------|------------|----------------------|--------|
| 1    | 0              | 0          | 0                    | Recruit |
| 2    | 120            | 120        | 1.1                  | Agent |
| 3    | 360            | 240        | 2.2                  | Specialist |
| 4    | 720            | 360        | 3.3                  | Expert |
| 5    | 1,200          | 480        | 4.4                  | Master |
| 6    | 1,800          | 600        | 5.5                  | Elite |
| 7    | 2,600          | 800        | 7.3                  | Veteran |
| 8    | 3,600          | 1,000      | 9.1                  | Hero |

**Wait, correction needed**: The current system only has Rank 6. Let me adjust for the actual 6-rank system:

| Rank | Total XP Needed | XP to Next | Missions @ 110 XP/avg | Status |
|------|-----------------|------------|----------------------|--------|
| 1    | 0              | 0          | 0                    | Recruit |
| 2    | 120            | 120        | 1.1                  | Agent |
| 3    | 360            | 240        | 2.2                  | Specialist |
| 4    | 720            | 360        | 3.3                  | Expert |
| 5    | 1,200          | 480        | 4.4                  | Master |
| 6    | 1,800          | 600        | 5.5                  | Elite |

**Revised for Medium Progression** (35-45 missions to max):

| Rank | Total XP Needed | XP to Next | Missions @ 110 XP/avg | Status |
|------|-----------------|------------|----------------------|--------|
| 1    | 0              | 0          | 0                    | Recruit |
| 2    | 200            | 200        | 1.8                  | Agent |
| 3    | 500            | 300        | 2.7                  | Specialist |
| 4    | 900            | 400        | 3.6                  | Expert |
| 5    | 1,500          | 600        | 5.5                  | Master |
| 6    | 2,500          | 1,000      | 9.1                  | Elite |

**Elite Threshold**: Rank 5 (Master) at ~5.5 missions, Rank 6 (Elite) at ~9 missions
**Campaign Pacing**: 35-45 missions total campaign length

## Difficulty Scaling

```
Difficulty    XP Multiplier    Base Mission    Example
─────────────────────────────────────────────────────────────
Tutorial      0.6x             50 XP           30-45 XP
Rookie        0.8x             110 XP          88-140 XP
Normal        1.0x             110 XP          110 XP
Hard          1.4x             110 XP          154 XP
Impossible    1.8x             110 XP          198 XP
```

## Campaign Duration & Pacing

### Medium Progression Campaign Structure

```
Campaign Structure:
  Geoscape months:      12-15 months in-game
  Missions per month:   3-4 missions average
  Total missions:       35-45 campaign length
  Playtime estimate:    30-40 hours

Unit Progression Milestones:
  Month 1-2: Rookies only, high casualties (Ranks 1-2)
  Month 3-4: First specialists emerging (Rank 3)
  Month 5-6: Experts becoming common (Rank 4)
  Month 7-9: Masters dominating (Rank 5)
  Month 10-12: Elite units standard (Rank 6)
  Month 13+: Veteran elite force, endgame challenges
```

### Squad Composition Over Time

```
Month 1: 100% Rookies (4-6 soldiers)
Month 3: 60% Rookies, 40% Specialists (6-8 soldiers)
Month 6: 30% Rookies, 50% Experts, 20% Masters (8-10 soldiers)
Month 9: 10% Rookies, 30% Experts, 60% Masters/Elite (10-12 soldiers)
Month 12: 100% Masters/Elite (12-14 soldiers)
```

## XP Sources Detail

### Combat Experience
- **Enemy Eliminations**: +10 XP per kill (standard alien)
- **Damage Inflicted**: +0.15 XP per damage point (max 100 XP/mission)
- **Survival Bonus**: +1 XP per turn survived (max 20 XP/mission)
- **Squad Cohesion**: +10 XP if all squad members survive

### Mission Objectives
- **Primary Objective**: +50 XP (already included in base)
- **Secondary Objectives**: +10-30 XP each
- **Research Data**: +10-50 XP for recovered alien tech
- **Difficulty Modifier**: ×1.0-1.8 based on mission difficulty

### Special Events
- **First Blood**: +5 XP for first kill of mission
- **Last Stand**: +20 XP for surviving with <25% health
- **Heroic Action**: +15 XP for rescuing downed ally
- **Perfect Mission**: +25 XP for completing all objectives

## Progression Philosophy

### Why Medium Progression?

**Advantages**:
1. Matches player expectation (40-50 mission campaign)
2. Provides enough specialization time without grind
3. Balances unit rotation vs. investment
4. Allows meaningful veteran development
5. Risk/reward: Losing elites hurts but replacement possible

**Campaign Flow**:
- **Early Game**: Focus on survival and basic tactics
- **Mid Game**: Unit specialization and role development
- **Late Game**: Elite squad composition and advanced strategies
- **End Game**: Veteran force vs. campaign finale

### Addressing Original Contradictions

**Contradiction 1**: "Elite at rank 5-6" vs. "takes 19 missions"
**Resolution**: Elite threshold = Rank 5 (Master) at ~5.5 missions, Rank 6 (Elite) at ~9 missions

**Contradiction 2**: Campaign duration unclear
**Resolution**: Clear 35-45 mission campaign over 12-15 months

**Contradiction 3**: Roster rotation strategy undefined
**Resolution**: Medium rotation - keep elites but rotate rookies for fresh blood

## Implementation Notes

### XP Calculation Function
```lua
function calculate_mission_xp(unit, mission_data)
    local xp = 50  -- Base completion

    -- Performance XP
    xp = xp + (mission_data.kills * 10)
    xp = xp + math.min(mission_data.damage_dealt * 0.15, 100)
    xp = xp + math.min(mission_data.turns_survived, 20)
    if mission_data.full_squad_alive then
        xp = xp + 10
    end

    -- Bonus XP
    xp = xp + mission_data.objective_bonus
    xp = xp + mission_data.difficulty_bonus

    -- Apply difficulty multiplier
    xp = xp * get_difficulty_multiplier(mission_data.difficulty)

    return math.floor(xp)
end
```

### Rank Check Function
```lua
function get_rank_xp_requirement(rank)
    local requirements = {
        [1] = 0,
        [2] = 200,
        [3] = 500,
        [4] = 900,
        [5] = 1500,
        [6] = 2500
    }
    return requirements[rank] or 999999
end
```

## Testing Scenarios

### Scenario 1: XP Reward Calculation
```
Normal mission: 8 kills, 600 damage, 12 turns, full squad alive
XP = 50 + 80 + 90 + 12 + 10 = 242 XP ✓
```

### Scenario 2: Progression to Elite
```
At 110 XP/mission:
Rank 5 (1500 XP): ~14 missions
Rank 6 (2500 XP): ~23 missions
Campaign total: ~35-45 missions ✓
```

### Scenario 3: Difficulty Scaling
```
Hard mission (1.4x): Base 110 XP → 154 XP
Impossible (1.8x): Base 110 XP → 198 XP ✓
```

## Balance Validation

**Progression Curve Check**:
- Early ranks (1-3): Fast progression encourages learning
- Mid ranks (4-5): Moderate progression rewards consistency
- Final rank (6): Significant investment creates meaningful achievement

**Campaign Pacing Check**:
- 35-45 missions: Reasonable completion time
- Elite units by mission 15-20: Balanced power curve
- Veteran units by end: Satisfying progression arc

**Player Experience**:
- Units feel like they grow with player skill
- Loss of elites is painful but recoverable
- Specialization matters but not required
- Campaign has clear progression milestones
