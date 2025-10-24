# AI Systems

## Table of Contents

- [Overview](#overview)
- [Strategic AI (Geoscape)](#strategic-ai-geoscape)
- [Operational AI (Interception)](#operational-ai-interception)
- [Tactical AI (Battlescape)](#tactical-ai-battlescape)
- [Autonomous Player AI](#autonomous-player-ai)
- [Real-Time AI Behavior Adjustment](#real-time-ai-behavior-adjustment)
- [AI System Integration & Emergent Behavior](#ai-system-integration--emergent-behavior)
- [AI Configuration & Tuning](#ai-configuration--tuning)

---

## Overview

### Architecture

AI in AlienFall operates on a multi-layered hierarchical system spanning three scales: Strategic (Geoscape), Operational (Interception), and Tactical (Battlescape). Each layer maintains independent decision-making while coordinating through state messaging. AI agents execute deterministic decision trees rather than randomization—apparent randomness emerges from imperfect information and probabilistic mission generation.

### Design Philosophy

- **Hierarchical**: Strategic decisions filter to tactical implementation
- **Deterministic**: Decisions based on state rules, not random rolls
- **Transparent**: All AI decisions loggable for analysis and tuning
- **Emergent**: Complex behavior emerges from simple rule interactions
- **Player-Mimic**: Autonomous agents can replicate human player strategy for testing

### Scope Overview

AI systems manage:
- **Strategic Layer**: Campaign progression, faction diplomacy, mission generation, resource escalation
- **Operational Layer**: Interception mechanics, UFO positioning, craft combat decisions
- **Tactical Layer**: Unit positioning, combat resolution, target selection, retreat decisions
- **Autonomous Play**: Complete player-replacement behavior for analytics and testing

---

## Strategic AI (Geoscape)

### Overview

Strategic AI orchestrates global operations: faction behavior, mission generation, economic dynamics, and player threat escalation. The layer operates at campaign scale with 30-day cycles coordinating multiple subordinate systems.

### Faction AI System

#### Faction Autonomy & Objectives

Each faction (e.g., Sectoids, Ethereals, Hybrids) maintains independent strategic goals:

| Faction Component | Behavior | Escalation Path |
|---|---|---|
| **Attack Strategy** | Raid player-controlled provinces, establish bases | +1 Province per 3 successful attacks |
| **Base Building** | Construct/upgrade faction bases (resource production) | Max 3-5 bases per faction by endgame |
| **Diplomatic Pressure** | Influence country relations, create anti-player sentiment | Fame -1 per hostile action, -5 per base destroyed |
| **Tactical Adaptation** | Adjust unit deployment based on player composition | Deploy hard-counters to dominant player units |
| **Resource Management** | Generate resources, manufacture units, conduct research | Allocation mirrors player economy (10% research, 30% military) |
| **Escalation Trigger** | Launch special attacks when campaign meter reaches threshold | Campaign points accumulate each mission cycle |

#### Faction Decision Algorithm
```
Each Turn:
1. Assess Player Threat Level (military strength, base count, fame)
2. Evaluate Available Resources (units, crafts, materials)
3. Choose Action:
   - If Threat > Resources: Aggressive push (attack 2-3 provinces)
   - If Threat ≈ Resources: Maintain pressure (attack 1 province, defend bases)
   - If Threat < Resources: Expand aggressively (attack 3+ provinces, build bases)
4. Execute Action → Generate corresponding missions
5. Update Faction State → Resources consumed, bases placed, diplomatic pressure applied
```

### Country & Supplier AI

#### Country Behavior

Countries provide funding, claim territories, and respond to player performance:

| Country Decision | Trigger | Effect |
|---|---|---|
| **Funding Bonus** | Player win streak (3+ consecutive missions) | +10K monthly for 2 months |
| **Funding Reduction** | Player loss (base destroyed, campaign lost) | -30% monthly funding for 3 months |
| **Hostility Shift** | Fame < Threshold | Country becomes hostile, halts funding, sanctions marketplace |
| **Diplomatic Reward** | Fame > Threshold + Alliance Bonus | +20K one-time reward, +1 supplier relationship |
| **Territory Claim** | Undefended province during faction attack | Country loses province, can become hostile |

#### Supplier Behavior

Suppliers control marketplace inventory and pricing based on relationship:

| Supplier State | Inventory Behavior | Pricing | Special Events |
|---|---|---|---|
| **Allied (Favor +2)** | +50% stock availability | -10% pricing | Priority access to rare items |
| **Neutral (Favor 0)** | Normal inventory | Normal pricing | Standard sales |
| **Hostile (Favor -2)** | -50% stock availability | +15% pricing | Temporary market closures |
| **Betrayal** | Inventory freeze, no sales | N/A | Can block critical items for 2 weeks |

#### Mission Generation AI

##### Mission Framework

Missions are procedurally generated based on faction state and escalation meter:

| Mission Type | Trigger | Composition | Reward Scaling |
|---|---|---|---|
| **UFO Crash** | Periodic | UFO + 6-12 aliens | +1000 base, salvage varies |
| **UFO Interception** | Player craft deployed | UFO vs Craft | +500 base + bounty |
| **Alien Base Attack** | Faction escalation | Alien base + garrison | +2000 base, strategic value |
| **Colony Defense** | Country in danger | Aliens vs Civilians | +1500 base + country favor |
| **Research Facility** | Alien tech site | Researchers + guards | +500 base + tech samples |
| **Supply Raid** | Low player resources | Aliens vs Storage | +300 base + loot |

##### Mission Difficulty Scaling

Mission composition scales with player progression:
```
Difficulty = BASE_DIFFICULTY + (CAMPAIGN_MONTH × 0.2) + (PLAYER_BASE_COUNT × 0.15) + (PLAYER_AVG_UNIT_LEVEL × 0.1)

Alien Team Composition:
- Total Units = 3 + (Difficulty × 0.8)
- Unit Classes = [40% Grunts, 35% Warriors, 20% Specialists, 5% Heavy] × Difficulty scaling
- Equipment Tier = MIN(Player_Equipment_Tier + 1, MAX_TIER)
```

#### Campaign Escalation Mechanics

##### Escalation Meter

Campaign progress tracked through escalation points:
- Each faction attack: +1 point
- Each player victory: -2 points (suppresses escalation)
- Each player base destroyed: -3 points (major setback)
- Monthly tick (no player action): +1 point (passive escalation)

```
Escalation Thresholds:
0-10 pts: Early game, factions establishing presence
10-25 pts: Mid game, visible faction pressure building
25-50 pts: Late game, multiple factions coordinating
50+ pts: Crisis, UFO armada incoming (endgame event)
```

---

## Operational AI (Interception)

### Overview

Interception AI manages UFO behavior during craft vs. UFO combat: movement decisions, attack/flee calculations, energy management, and tactical positioning. Operates at individual UFO scale with action-per-turn resolution.

### UFO Decision Tree

#### UFO Behavior States

| State | Trigger | Behavior | Transition |
|---|---|---|---|
| **Aggressive** | Player craft nearby, HP > 50% | Pursue, attack every turn | → Retreat if HP < 25% |
| **Tactical Withdrawal** | HP 25-50%, outgunned | Maintain distance, selective attacks | → Aggressive if reinforced |
| **Escape** | HP < 25% or outnumbered 2:1 | Flee toward objective/edge | → Complete escape or intercept |
| **Defensive** | Defending base/cargo | Hold position, return fire | → Aggressive if player retreats |

#### UFO Attack Resolution

Each turn UFO calculates attack viability:
```
UFO Decision:
1. Calculate Target Threat (player craft health, weapons, positioning)
2. Calculate Survival Odds:
   - If (Survival_Odds > 60%): ATTACK
   - If (Survival_Odds 30-60%): TACTICAL_WITHDRAWAL
   - If (Survival_Odds < 30%): ESCAPE
3. Execute Action → Damage/energy costs applied
4. Update State → HP, energy, ammunition adjusted
```

---

## Tactical AI (Battlescape)

### Overview

Battlescape AI orchestrates squad-level combat with hierarchical decision-making: Side coordinates strategy, Teams manage squad groupings, Squads coordinate unit tactics, Units execute individual actions. All decisions derive from deterministic evaluation of game state.

### Side-Level AI

#### Faction Alignment & Engagement Rules

| Side Type | Engagement Rules | Behavioral Goals | Coordination |
|---|---|---|---|
| **Player** | Attack enemies, defend allies | Complete mission objective | Manual control via player input |
| **Enemy** | Attack player, destroy objectives | Eliminate player units, control map | Coordinates all squads toward player elimination |
| **Ally** | Attack enemies, protect player | Support player mission | Follows player lead, focuses fire on player targets |
| **Neutral** | Avoid all sides unless attacked | Survival, maintain position | Defensive reactions only |

**Side Strategy Selection**
```
Based on:
- Mission Objective (defense/elimination/extraction)
- Relative Unit Strength (player vs. enemy force ratio)
- Terrain Advantage (UFO interior vs. open ground)
- Unit Health Status (casualties, low morale)

Chosen Strategy:
- Aggressive: Immediate frontal assault, overwhelming force
- Tactical: Flanking maneuvers, cover-based positioning
- Defensive: Hold positions, reaction fire focus
- Retreat: Staged withdrawal toward objectives/extraction points
```

#### Team-Level AI (Squad Coordination)

##### Team Composition & Roles

Each Team manages 2-4 Squads with coordinated objectives:

| Team Role | Squad Count | Composition | Objective |
|---|---|---|---|
| **Assault** | 2-3 squads | Heavy weapons, close combat | Breach enemy lines, eliminate priority targets |
| **Support** | 1-2 squads | Medics, engineers, ammo carriers | Keep assault squads operational |
| **Flanking** | 1 squad | Mobile, accurate shooters | Outflank enemy positions, eliminate scattered targets |
| **Defense** | 1-2 squads | Static positioning, heavy fire | Hold choke points, defend objectives |

**Team Coordination Decision**
```
Each Turn:
1. Assess Team Situation (unit health, ammo, position vs. enemy)
2. Identify Tactical Opportunities:
   - Enemy exposed/flanked? → Assault squad attacks
   - Team damage? → Support squad provides healing/ammo
   - Strategic position available? → Flanking squad repositions
   - Defensive need? → Defense squad fortifies
3. Coordinate Squad Actions → All squads execute coordinated turn
4. Evaluate Outcome → Adjust tactics for next turn
```

#### Squad-Level AI (1-10 Unit Groups)

##### Squad Formation Mechanics

Squads maintain formations optimizing cover and firepower:

| Formation | Unit Density | Firepower | Vulnerability | Use Case |
|---|---|---|---|---|
| **Line** | Spread horizontally | High (all units fire) | Flanking exposure | Open terrain, suppressive fire |
| **Column** | Single file | Medium | Frontal area attack | Narrow corridors, UFO interiors |
| **Wedge** | Triangle apex | Medium-High | Limited forward coverage | Balanced approach |
| **Cluster** | Tight group | Low (blocked fire) | Explosive vulnerability | Urban cover, defensive position |
| **Dispersed** | Maximum spread | Low-Medium | Coordination difficulty | Defensive holding |

**Squad Movement & Targeting**
```
Squad Decision Loop:
1. Determine Squad Objective (from Team)
2. Evaluate Enemy Positions:
   - Visible enemies? → Plan intercept/suppression
   - No visible enemies? → Move toward last known position
   - Objective location? → Move toward objective
3. Calculate Movement:
   - Distance to next position
   - Cover availability
   - Exposure risk
   - Movement action point cost
4. Form/Maintain Formation → Adjust formation based on terrain
5. Identify Targets → Distribute fire based on threat/distance
6. Execute Action → Move and attack according to priority
```

#### Unit-Level AI

##### Unit State Machine

Individual units operate through discrete states:

| State | Action | Transition |
|---|---|---|
| **Idle** | No action, face forward | → Alert on enemy contact |
| **Alert** | Rotate to face threat, ready weapon | → Move or Engage |
| **Move** | Pathfind toward waypoint, maintain formation | → Idle or Engage |
| **Engage** | Attack visible enemy, use cover | → Suppressed or Reposition |
| **Suppressed** | Take cover, return fire only | → Move when exposed enemy flees |
| **Reaction Fire** | Fire on newly visible enemy | → Suppress or Continue action |

##### Unit Confidence & Behavioral Modulation

Units maintain an internal confidence level affecting aggression, accuracy, and tactical decisions:

**Confidence System Mechanics:**

```
Base Confidence: 60% (all units start at moderate confidence)
Range: 0-100% (0% = cowardly retreat, 100% = reckless aggression)

Confidence Decay (per turn without combat success):
- -5% per friendly unit casualty
- -3% per suppression effect
- -2% per mission turn elapsed (time pressure)

Confidence Gain (per success):
- +3% per successful hit on enemy
- +5% per enemy unit eliminated
- +2% per objective completed
- +1% per allied unit nearby (morale boost)

Confidence Floor: 10% (units retain some tactical capability even when routing)
Confidence Ceiling: 95% (prevents pure recklessness even with massive advantage)
```

**Behavioral Effects of Confidence:**

| Confidence Level | Behavior | Combat Approach | Accuracy Effect |
|---|---|---|---|
| 0-20% | Terrified | Immediate retreat/surrender | -30% accuracy (panic fire) |
| 21-40% | Frightened | Defensive, seek cover, suppress | -15% accuracy (cautious) |
| 41-60% | Normal | Balanced tactics, coordinated | No modifier |
| 61-80% | Aggressive | Advance, close distance, suppress | +10% accuracy (focused fire) |
| 81-100% | Dominant | Frontal assault, risk-taking | +20% accuracy (overconfidence) |

**Confidence and Decision-Making:**

```
Unit Movement Decision:
- Low Confidence (0-40%): Move toward squad, away from enemy
- Moderate Confidence (41-60%): Standard tactical movement
- High Confidence (61-100%): Advance toward enemy, seek combat

Unit Combat Decision:
- Low Confidence: Prefer defense, use cover defensively
- Moderate Confidence: Balanced offense/defense
- High Confidence: Aggressive tactics, minimal cover usage

Unit Retreat Decision:
- Low Confidence: Retreat at 40% HP
- Moderate Confidence: Retreat at 25% HP (standard)
- High Confidence: Retreat only at <10% HP
```

**Unit Target Selection Algorithm**
```
For Each Visible Enemy:
  Calculate Priority Score:
    - Threat_Level (damage dealt, weapon type)
    - Distance (closer = higher priority, within 10 tiles significant threat)
    - Exposed (no cover = significantly higher priority)
    - Armor_Type (prioritize weak-to-strong matchups)
    
  Highest_Priority_Target = Enemy with MAX(Priority_Score)
  
  Fire_Action:
    - Accuracy = Base_Accuracy + (Stat_Bonus) - (Distance_Penalty) - (Cover_Bonus)
    - Damage = Weapon_Damage × (Crit_Chance + Body_Part_Modifier)
```

**Threat Assessment Scoring Formula**

Target priority is calculated using a weighted threat assessment system:

```
Threat Score = (Threat_Level × 0.5) + (Distance_Factor × 0.3) + (Exposure_Factor × 0.2)

Where:
- Threat_Level (0-100): Calculated from enemy weapon damage, armor, and unit type
  - Grunt: 30
  - Warrior: 50
  - Specialist: 70
  - Heavy: 90
  - Officer/Elite: 100

- Distance_Factor (0-100): Inverse relationship to proximity
  - Within 2 hexes: 100 (critical threat)
  - 3-5 hexes: 70 (high threat)
  - 6-10 hexes: 50 (medium threat)
  - 11+ hexes: 20 (low threat)

- Exposure_Factor (0-100): Cover status significantly increases priority
  - No cover: 100 (critical priority)
  - Partial cover: 60 (medium priority)
  - Full cover: 30 (lower priority)
  - In smoke/obscured: 20 (lowest priority)

Final Threat Score Range: 0-100
- Score < 20: Ignore unless no other targets
- Score 20-50: Secondary targets, prioritize only if closer threats neutralized
- Score 50-80: Primary targets, allocate firepower accordingly
- Score > 80: Immediate priority, all available firepower focused
```

**Formation-Based Targeting Priority**

Different squad formations adjust targeting emphasis:

| Formation | Primary Target | Secondary Target | Rationale |
|-----------|-----------------|------------------|-----------|
| Line | Closest enemy | Most exposed | Maximize firepower density |
| Column | Furthest enemy | Ambush flanks | Suppress distant threats |
| Wedge | Highest threat | Flanking units | Balanced threat management |
| Cluster | Area effect (grenades) | Exposed units | Group vulnerability forces area tactics |
| Dispersed | Isolated units | Any threat | Divide & conquer approach |

**Pathfinding & Movement**

Units use A* pathfinding with obstacle avoidance:
```
Pathfinding Heuristic:
- Start from current position
- Evaluate movement cost (terrain, obstacles, squad positioning)
- Prefer cover positions (behind walls, objects)
- Prefer positions with line-of-sight to enemies
- Penalize isolated positions (away from squad)

Movement Cost = Base_Cost + Terrain_Modifier + Cover_Bonus - Squad_Cohesion_Penalty
```

##### Action Point System

All units operate on a turn-based Action Point (AP) economy determining available actions per turn:

**Base Action Points:**
- Base AP per turn: **4** (fixed across all unit types and difficulty levels)

**Action Point Range After Modifiers:**
- Minimum AP: **1** (guaranteed action even at critical status)
- Maximum AP: **5** (after positive modifiers)
- Valid range: **1-5 AP per turn**

**AP Reduction Sources:**
- Health Status: Up to -2 AP when below 25% health
- Morale Status: Up to -2 AP when panicked (morale ≤ 0)
- Sanity Status: Up to -1 AP when heavily traumatized
- Stun Effect: -2 AP (subject to stun effect for 1 turn)
- Suppressed: No AP reduction, but limited to defensive actions only

**AP Stacking Rules:**
- All modifiers stack additively: Final AP = 4 + Bonuses - Penalties
- Example: Base 4 - 1 (health penalty) - 1 (morale penalty) = 2 AP minimum
- Absolute floor: 1 AP guaranteed (unit can always perform 1 action minimum)

**Difficulty Scaling:**
- Easy difficulty: +1 AP bonus for player units, no change for enemies
- Normal difficulty: No modifiers
- Hard difficulty: -1 AP for player units, +1 AP for enemies
- Impossible difficulty: -2 AP for player units, +2 AP for enemies

**Action Point Costs:**

| Action | AP Cost | Notes |
|--------|---------|-------|
| Move 1 hex | 1 AP | Standard movement in any direction |
| Move (tactical) | 1-2 AP | 2 AP for moving through rough terrain |
| Attack (snap) | 1 AP | Quick shot, -5% accuracy |
| Attack (aimed) | 2 AP | Careful shot, +15% accuracy |
| Attack (burst) | 2 AP | 3-round burst, balanced |
| Attack (overwatch) | 2 AP | Reaction shot if enemy moves |
| Use item | 1 AP | Activate grenade, medikit, etc. |
| Reload | 1 AP | Switch ammunition or recharge weapon |
| Take cover | 1 AP | Change cover position (passive benefit) |
| Rest | 1 AP | Recover morale +1 per turn spent resting |

---

## Autonomous Player AI

### Overview

Autonomous Player AI replicates human decision-making across all game systems: base management, research planning, manufacturing, unit recruitment, resource allocation, and tactical decision-making. Enables full campaign simulation without human intervention.

### Basescape Player AI

#### Base Management Decision-Making

The autonomous player makes decisions for facility construction, research prioritization, and resource allocation:

```
Monthly Base Management Loop:
1. Evaluate Base Capacity
   - How many facilities fit? (grid space)
   - What's the priority? (production vs. defense vs. research)
2. Decide Facility Construction
   - Manufacturing bottleneck? → Build Workshop
   - Research slow? → Build Lab
   - Defense weak? → Build Turret
   - Personnel growing? → Build Barracks
   - Storage full? → Build Storage
3. Allocate Scientists
   - Distribute across research projects based on priority
   - Prioritize: (Weapons Research > Facilities > Unit Abilities)
4. Queue Manufacturing
   - Profitable items? → Manufacture for credits
   - Equipment needed? → Manufacture for units
5. Recruit Units
   - Slots available? → Recruit from country/suppliers
   - Specialization needed? → Target recruitment by role
6. Transfer Resources
   - Excess equipment? → Transfer between bases
   - Damaged units? → Transfer to bases with hospitals
```

#### Geoscape Player AI

##### Strategic Decision-Making

Autonomous player makes province targeting, craft deployment, and research priority decisions:

```
Campaign Strategic Loop:
1. Assess Threats
   - Where are factions strongest? (province control)
   - What missions are available? (player regions)
   - Where are vulnerabilities? (undefended bases)
2. Prioritize Targets
   - High-value mission available? → Accept mission
   - Craft available? → Deploy to contested province
   - Alien base discovered? → Plan assault
3. Research Planning
   - Weapons research complete? → Start armor research
   - Armor complete? → Start facility upgrades
   - Tech tree bottleneck? → Switch priority
4. Diplomatic Relations
   - Country hostile? → Avoid missions in that region
   - Supplier favorable? → Increase manufacturing
   - Faction winning? → Escalate defense
```

#### Tactical Combat Player AI

##### Mission Acceptance & Unit Preparation

Autonomous player chooses which missions to accept and how to equip units:

```
Mission Preparation:
1. Evaluate Mission
   - Difficulty vs. player strength (acceptable risk?)
   - Reward value (worth deploying units?)
   - Strategic location (value to campaign?)
2. Unit Selection
   - How many units needed? (based on alien count)
   - Which classes? (balanced squad comp)
   - Specializations available? (medics, snipers, etc.)
3. Equipment Loadout
   - What weapons available? (best accuracy + damage)
   - Armor selection? (balance defense vs. speed)
   - Special items? (medkits, grenades, ammunition)
4. Deployment Strategy
   - Entry point (tactical vs. direct?)
   - Formation (aggressive vs. cautious?)
   - Objective priority (elimination vs. objective?)
```

---

## Real-Time AI Behavior Adjustment

### Overview

AI difficulty scales dynamically based on player performance, creating appropriate challenge without frustration.

### Difficulty Scaling Mechanisms

| Difficulty Level | Alien Unit Count | Equipment Tier | Reaction Speed | Special Abilities |
|---|---|---|---|---|
| **Easy** | -30% | T1 only | 1-turn delay | None |
| **Normal** | 0% | T1-T2 mix | Standard | Occasional |
| **Hard** | +30% | T2-T3 mix | Immediate | Regular |
| **Legendary** | +50% | T3-T4 mix | Predictive | Frequent |

---

## AI System Integration & Emergent Behavior

### Overview

Complex behavior emerges from simple subsystem interactions creating believable faction behavior, strategic depth, and replayable campaigns.

### Cascading Decision Effects

When Strategic AI decides to attack a province:
1. **Strategic Effect**: Escalation meter +1, faction presence grows
2. **Operational Effect**: UFO generated, interception mission available
3. **Tactical Effect**: Unit teams created, combat mission available
4. **Economic Effect**: Salvage available from victory, equipment manufacturing unlocked
5. Campaign Effect: Player reputation affected (fame/karma), country relations shift

---

## AI Configuration & Tuning

### Overview

AI behavior is entirely controlled via TOML configuration, enabling rapid balance iteration without code changes.

### Configuration Example
```toml
[ai.faction.attack_decision]
min_force_ratio = 1.5  # Faction needs 1.5x player force to attack
aggression_bonus = 0.2  # +20% aggression when escalation > 50%
retreat_threshold = 0.25  # Retreat when HP < 25%

[ai.player_autonomous.research_priority]
weapons_weight = 0.4
facilities_weight = 0.35
abilities_weight = 0.25
randomness = 0.1  # Vary priority by ±10%

[ai.unit_combat.targeting]
priority_exposed_enemies = 3.0  # 3x priority weight
priority_ranged_threats = 2.5
priority_low_health = 1.5
priority_distance_close = 2.0  # Closer enemies 2x priority

[ai.difficulty.legendary]
alien_count_multiplier = 1.5
equipment_tier_shift = +2
reaction_time_turns = 0  # Immediate reactions
accuracy_bonus = 1.2  # 20% accuracy boost
```
