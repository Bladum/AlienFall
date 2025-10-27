# 🎮 Game Mechanics Best Practices for AlienFall

**Domain**: Game Design & Mechanics  
**Focus**: Turn-based systems, balance, difficulty, progression  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Core Design Principles](#core-design-principles)
2. [Turn-Based Combat Mechanics](#turn-based-combat-mechanics)
3. [Strategic Layer Design](#strategic-layer-design)
4. [Base Management Systems](#base-management-systems)
5. [Progression & Difficulty](#progression--difficulty)
6. [Resource Management](#resource-management)
7. [Risk & Reward](#risk--reward)
8. [Decision Design](#decision-design)
9. [Emergent Gameplay](#emergent-gameplay)
10. [Edge Cases & Playtesting](#edge-cases--playtesting)

---

## Core Design Principles

### ✅ DO: Design Around Player Agency

Players should feel in control of outcomes.

**Good Agency Design:**

```
XCOM Combat Scenario:
- Player sees enemy positions (complete information)
- Player calculates hit percentages (transparent odds)
- Player chooses action order (tactical decisions)
- Player accepts outcome variance (% chance is honest)

Result: Even when losing, player feels decisions mattered
```

**Bad Agency Design:**

```
Hidden Modifiers:
- Enemy accuracy secretly reduced by difficulty level
- Damage rolls happen behind the scenes
- Hit percentages don't match actual outcomes
- Player feels cheated when losing

Result: Even when winning, player feels lucky, not skilled
```

### ✅ DO: Implement Consistent Rules

Players need to understand and predict outcomes.

**Rule Consistency Example:**

```
Cover Mechanics - CONSISTENT RULES:
- Unit in light cover: +50% dodge chance
- Unit in heavy cover: +75% dodge chance
- Flanked unit: -50% cover bonus
- Suppressed unit: Cannot use cover bonus

Players learn: "If enemy is flanked, cover doesn't help"
This becomes tactical knowledge, enabling strategy
```

### ✅ DO: Balance Complexity vs. Learning Curve

Not everything needs to be complex.

**Complexity Progression:**

```
Beginner Tutorial:
- Movement: Click destination, unit moves
- Shooting: Click enemy, unit shoots
- Simple hit/miss (visible % chance)

Intermediate (5-10 hours):
- Positioning for cover benefits
- Action point management
- Equipment loadouts

Advanced (20+ hours):
- Cover stacking
- Suppression mechanics
- Advanced squad tactics
- Resource optimization

Each layer learned when ready
```

---

## Turn-Based Combat Mechanics

### ✅ DO: Design Clear Turn Structure

Players need to understand action flow.

**Good Turn Structure:**

```
Turn Order:
1. Determine initiative (sometimes random, sometimes unit-based)
2. Player 1 - All units act
   a. Unit A: Move + Attack
   b. Unit B: Move only
   c. Unit C: Attack + Move
3. Enemy - All units act
4. Environmental effects (explosions, fire spread)
5. Resolve status effects
6. End turn
7. Repeat

Each phase is predictable and understandable
```

### ✅ DO: Implement Action Point Systems

Limit unit capabilities per turn.

**Action Point Design:**

```
Combat Unit - Action Points per turn: 2

Possible Actions:
- Move (costs 1 AP)
- Move Far (costs 2 AP)
- Attack (costs 1 AP)
- Overwatch (costs 1 AP, waits for enemy)
- Reload (costs 1 AP)
- Use Item (costs 1 AP)

Turn Examples:
Option 1: Move(1) + Attack(1) = Full turn used
Option 2: Move(1) + Move(1) = Can move far
Option 3: Attack(1) + Attack(1) = Suppressing fire
Option 4: Move(2) = Movement focused

Player chooses action combinations
```

### ✅ DO: Make Hit Chances Visible

Never hide probability from players.

**Hit Chance Display:**

```
UI shows when aiming:
┌─────────────────────┐
│ Enemy: Sectoid      │
│ Distance: 8 tiles   │
│ Cover: Light (+50%) │
│ Weather: Clear      │
│                     │
│ Base Hit: 75%       │
│ - Cover: -50%       │
│ - Distance: -10%    │
│ ─────────────────   │
│ FINAL: 15%          │
│                     │
│ [SHOOT] [CANCEL]    │
└─────────────────────┘

Player makes informed decision
```

### ✅ DO: Implement Meaningful Damage Variance

Vary damage enough to matter, not so much that it's random.

**Damage Variance Design:**

```
Rifle Base Damage: 20

GOOD VARIANCE:
Range: 18-22 (±10%)
- Damage always significant
- Variation matters but predictable
- Player can plan around average damage

BAD VARIANCE:
Range: 5-35 (±75%)
- Sometimes useless, sometimes overpowered
- Unpredictable, undermines strategy
- Player feels lucky/unlucky more than skilled

Implement as:
- Base Damage × (0.9 + Random(0,0.2))
- Variance applied AFTER armor reduction
```

---

## Strategic Layer Design

### ✅ DO: Create Multiple Victory Paths

Don't force one strategy.

**Multiple Paths Example:**

```
Base Defense Mission

Path 1 - Aggressive:
- Flank enemy position
- Minimize casualties
- Loot valuable items
Risk: High casualty potential

Path 2 - Defensive:
- Fortify key positions
- Let enemy come to you
- Higher survival rate
Risk: May run out of ammo

Path 3 - Infiltration:
- Sabotage enemy equipment
- Avoid direct combat
- Complete objective quietly
Risk: Requires specific units/equipment

All paths valid, different tradeoffs
```

### ✅ DO: Implement Territory Control

Make space matter strategically.

**Territory Mechanics:**

```
Geoscape (World Map):
- World divided into regions
- Each region: Resources, Population, Strategic Value
- Player controls: Which missions to deploy to
- Enemy threat: UFO activity increases in controlled regions

Strategic Decisions:
"Do I defend this region (protect population, resources)
or let it fall and mass forces elsewhere?"
```

### ✅ DO: Create Meaningful Choices

Each decision should matter.

**Choice Design:**

```
Research Dilemma:
- Armor Research (3 days): +20% survival rate
- Weapon Research (3 days): +25% damage output
- Interceptor Tech (3 days): Can shoot down more UFOs

Can only do 2 before next alien assault
Which 2?

Option A: Armor + Weapon = Better at combat
Option B: Armor + Interceptor = Better at defense
Option C: Weapon + Interceptor = Better at offense

Each choice has tradeoffs, no "best" answer
```

---

## Base Management Systems

### ✅ DO: Make Resources Visible and Scarce

Players need to see what they have and make tradeoffs.

**Resource Display:**

```
Base Resources UI:
┌──────────────────────────┐
│ Personnel:  285/300      │ (95% capacity)
│ Funds:      $125,000     │ (Medium - 15 days of ops)
│ Research:   150 points   │ (2 days remaining)
│ Supplies:   420 units    │ (Normal consumption rate)
│ Morale:     85%          │ (Satisfied)
│ Interceptors: 2/4 ready │ (Half operational)
└──────────────────────────┘

All resources visible, player can calculate capacity
```

### ✅ DO: Create Resource Sinks (Costs)

Everything should cost something.

**Resource Costs:**

```
Hiring Soldier: $3,000 + 1 personnel slot
Training Soldier: 5 days + $500/day
Equipment: $1,000 per loadout
Monthly Base Maintenance: $50,000
Research: 200 scientist-days
Interceptor Fuel: $500 per mission

Player must balance:
- Can I afford more soldiers?
- Is training worth the time?
- Which research is most important?
```

### ✅ DO: Implement Facility Management

Base layout should matter.

**Facility Design:**

```
Base Layout (25x25 grid):

┌─────────────────────────┐
│ Barracks    │ Armory    │
│ (80 troops) │ (gun lock)│
├─────────────────────────┤
│ Lab         │ Workshop  │
│(200 pts/day)│(1 item/d) │
├─────────────────────────┤
│ Radar (8)   │ Reactor   │
│ (scan range)│ (power)   │
└─────────────────────────┘

Upgrades:
- Adjacent facilities → +10% efficiency
- Power facility → enables all tech
- Multiple radars → combined coverage

Strategic building placement matters
```

---

## Progression & Difficulty

### ✅ DO: Implement Difficulty Scaling

Challenge should increase as player improves.

**Difficulty Curve:**

```
Early Game (Missions 1-5):
- Enemy Units: 3-4 aliens per mission
- Firepower: Light weapons only
- Tactical Complexity: Simple ambush patterns
- Survival Rate: ~70% expected

Mid Game (Missions 10-15):
- Enemy Units: 6-8 aliens per mission
- Firepower: Advanced weapons
- Tactical Complexity: Coordinated tactics, cover usage
- Survival Rate: ~50% expected

Late Game (Missions 20+):
- Enemy Units: 10-15 aliens per mission
- Firepower: Plasma weapons, explosives
- Tactical Complexity: Multi-wave attacks, flanking
- Survival Rate: ~30% expected

Difficulty increases predictably
```

### ✅ DO: Allow Player-Driven Progression

Let players choose their path.

**Progression Choices:**

```
Unit Advancement:
Each soldier gains experience

Rank: Rookie → Squaddie → Corporal → Sergeant → Lieutenant

Each rank unlocks abilities:
- Squaddie: +1 accuracy
- Corporal: New ability (Fire Burst)
- Sergeant: New ability (Suppress)
- Lieutenant: Squad bonuses

Player chooses which units to promote
```

### ✅ DO: Create Meaningful Leveling

Progression should feel rewarding.

**Experience Progression:**

```
Actions Granting XP:
- Kill alien: 50 XP
- Hit with weapon: 10 XP per hit
- Use special ability: 25 XP
- Complete mission: 100 XP bonus
- Keep unit alive: +5 XP per turn alive

Level Thresholds:
- Level 1: 0 XP
- Level 2: 100 XP (unlocks Stability)
- Level 3: 250 XP (unlocks new ability)
- Level 4: 450 XP (stat boost)
- Level 5: 700 XP (advanced tactics)

Veterans feel more powerful
```

---

## Resource Management

### ✅ DO: Create Economy Balance

Resources in must equal resources out.

**Economy Tracking:**

```
INCOME (Monthly):
- Country funding: $150,000
- Salvage from missions: ~$25,000
- Technology sales: $10,000
Total Income: ~$185,000/month

EXPENSES (Monthly):
- Soldier salary: $30,000 (60 troops × $500)
- Base maintenance: $50,000
- Research: $15,000
- Equipment: ~$20,000
- Fuel/Operations: $25,000
Total Expenses: ~$140,000/month

Net: +$45,000/month buffer (stable economy)

If expenses > income for 2+ months: Economic crisis
```

### ✅ DO: Make Spending Decisions Matter

Resources shouldn't be infinite.

**Spending Decisions:**

```
Available Funds: $50,000
Options:
A) 15 new soldiers @ $3,000 = $45,000 (expand army)
B) Research project = $30,000 (tech advantage, save $20k)
C) Base expansion = $40,000 (more capacity)

Can't do all three - player chooses strategy
```

---

## Risk & Reward

### ✅ DO: Tie Rewards to Difficulty

Harder missions should pay better.

**Reward Scaling:**

```
Mission Difficulty Levels:

EASY (Rookie aliens, 4 units):
- Reward: $5,000 salvage, 100 XP
- Risk: Low casualty rate
- Worth: Safe but low reward

NORMAL (Experienced aliens, 6 units):
- Reward: $10,000 salvage, 200 XP
- Risk: Moderate casualty rate
- Worth: Balanced risk/reward

HARD (Elite aliens, 10 units):
- Reward: $25,000 salvage, 500 XP
- Risk: High casualty rate
- Worth: Big payoff if successful

Player chooses which missions to take
```

### ✅ DO: Create Consequences for Failure

Failure should matter.

**Failure Consequences:**

```
Mission Failure Results:
- Wounded soldiers (recover time): -5 soldiers for 2 weeks
- Lost equipment: -$5,000 value lost
- Civilian casualties: -Countries' funding next month
- Panic increase: -Strategic position
- UFO escapes: +Future alien attack elsewhere

Success vs. Failure have real consequences
```

---

## Decision Design

### ✅ DO: Create Interesting Dilemmas

Decisions should have tradeoffs, no obvious choice.

**Dilemma Example:**

```
Interrogation Scenario:
"Captured alien has information about UFO location"

Option A - Interrogate:
- Pro: Learn UFO location
- Con: Takes 3 days, alien might die
- Risk: Intelligence might be false

Option B - Release alien:
- Pro: Use as double agent, track it to base
- Con: Might attack another country
- Risk: Country relationship suffers

Option C - Execute:
- Pro: Prevents potential escape
- Con: Lose information opportunity
- Risk: Other aliens retaliate

No "best" choice - all have pros/cons
```

### ✅ DO: Avoid Dominant Strategies

Every viable strategy should have counters.

**Anti-Dominant Design:**

```
Anti-Camper Design:
If everyone just "stay in base" strategy:
- Aliens learn location
- Constant base attacks
- Can't defend indefinitely
- Forces player to attack

Anti-Aggressive Design:
If everyone "rush and shoot" strategy:
- Heavy casualties
- No time for positioning
- Suppressive fire pins down units
- Must retreat sometimes

Multiple viable approaches, no one "best"
```

---

## Emergent Gameplay

### ✅ DO: Enable Creative Solutions

Don't force specific tactics.

**Emergent Solution Examples:**

```
Scenario: Defend against incoming UFO

Expected Solution: "Position units at landing zone, wait"

Emergent Solutions Possible:
1. Pre-position explosives → Detonate when UFO lands
2. Use environment → Collapse building on landing zone
3. Intercept before landing → Use interceptor craft
4. Evacuate area → Let it land empty, ambush soldiers later
5. Sabotage power → UFO can't unload properly
6. Fake evacuation → Lead aliens into trap

All valid! Different tradeoffs
```

### ✅ DO: Create Interesting Failure States

Players should learn from mistakes.

**Learning from Failure:**

```
Failed Ambush:
"I placed my soldiers wrong - next time I'll position differently"
→ Player learns spatial tactics

Ran Out of Ammo:
"I need to conserve ammunition better or bring more"
→ Player learns resource management

Lost High-Rank Soldier:
"I shouldn't have taken that risk with a veteran"
→ Player learns unit value preservation

Failure becomes teacher, not punishment
```

---

## Edge Cases & Playtesting

### ✅ DO: Test Extreme Strategies

Find and fix exploits.

**Edge Cases to Test:**

```
"What if player only moves units, never attacks?"
- Game should progress (turns pass, aliens act)
- Stalemate should be possible but losing (economy drain)

"What if player spends all money on one unit?"
- Unit can still die (not guaranteed victory)
- Other soldiers should be viable backup

"What if player never promotes soldiers?"
- Game should still be winnable (harder, but possible)
- Promotion should give advantage, not be required

Test these to find balance
```

### ✅ DO: Playtest with Target Audience

Mechanics make sense to developers, maybe not players.

**Playtesting Checklist:**

```
□ Objectives are clear
□ Rules are understandable
□ Progress feels rewarding
□ Failure feels fair (not arbitrary)
□ Decisions feel meaningful
□ Tutorial teaches without hand-holding
□ Difficulty curve is smooth
□ No obvious exploits
□ Core gameplay loop is fun
□ Enough variety to stay engaging
```

### ✅ DO: Track Player Decisions

Learn what players actually do.

**Decision Tracking:**

```
Analytics to track:
- Which missions players choose (hardest vs. easiest)
- Building prioritization (which facilities first)
- Unit retention (do players protect veterans)
- Research paths (which techs chosen first)
- Money spending habits (hoarders vs. spenders)

Use data to balance game:
"Players always pick research first, never build"
→ Maybe research is too valuable, rebalance
```

---

## Resource Type Reference

### Military Resources

- **Personnel**: Soldiers, specialists, support staff
  - Cost: $3,000 each
  - Training: 5 days
  - Limit: Base capacity
  - Loss: Permanent (can be wounded but recover)

- **Equipment**: Weapons, armor, items
  - Cost: $500-$5,000 per item
  - Degradation: 5% per mission
  - Reusable: Can equip multiple soldiers

- **Ammunition**: Mission-specific
  - Cost: $100 per magazine
  - Consumption: 10-50 rounds per mission
  - Resupply: Automatic at base

### Research & Technology

- **Research Points**: Scientist output
  - Generation: 200 points/day with 10 scientists
  - Usage: 500 points for typical research
  - Duration: 2-3 days per project

- **Technology Tiers**:
  - Tier 1 (Modern): Available immediately
  - Tier 2 (Advanced): After first alien contact
  - Tier 3 (Alien): After first alien autopsy
  - Tier 4 (Hybrid): Late-game combinations

### Strategic Resources

- **Funding**: International support
  - Monthly stipend: $150,000 baseline
  - Variance: ±$30,000 based on country satisfaction
  - Loss: 50% per country leaving organization

- **Satellite Coverage**: Geoscape visibility
  - Satellites: $50,000 each
  - Coverage: 30% of world per satellite
  - Maintenance: $5,000/month per satellite

---

## Balance Reference Numbers

### Difficulty Tuning (Mission Difficulty)

```
Easy: 1.0x multiplier
- Enemy count: ×0.6
- Enemy accuracy: ×0.8
- Damage taken: ×0.7

Normal: 1.0x multiplier
- Enemy count: ×1.0
- Enemy accuracy: ×1.0
- Damage taken: ×1.0

Classic: 1.3x multiplier
- Enemy count: ×1.3
- Enemy accuracy: ×1.1
- Damage taken: ×1.2

Legendary: 2.0x multiplier
- Enemy count: ×2.0
- Enemy accuracy: ×1.3
- Damage taken: ×1.5
```

### Unit Tiers

```
Rookie (Level 0):
- Accuracy: 60%
- Health: 30
- Abilities: None

Squaddie (Level 1):
- Accuracy: 70%
- Health: 35
- Abilities: +1 action

Corporal (Level 2):
- Accuracy: 80%
- Health: 40
- Abilities: Burst Fire

Sergeant (Level 3):
- Accuracy: 90%
- Health: 45
- Abilities: Suppress

Lieutenant (Level 4):
- Accuracy: 100%
- Health: 50
- Abilities: Squad Bonus (+10% to all)
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*See also: BATTLESCAPE_TACTICS_AI.md for detailed combat mechanics*
