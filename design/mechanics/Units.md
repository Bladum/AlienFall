# Units System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Battlescape.md, Items.md, Crafts.md, Pilots.md, Economy.md

## Table of Contents

- [Overview](#overview)
- [Unit Classification](#unit-classification)
- [Unit Recruitment](#unit-recruitment)
- [Unit Statistics](#unit-statistics)
- [Experience & Progression](#experience--progression)
- [Unit Inventory & Equipment](#unit-inventory--equipment)
- [Unit Traits](#unit-traits)
- [Transformations](#transformations)
- [Unit Roles & Specializations](#unit-roles--specializations)
- [Unit Health & Recovery](#unit-health--recovery)
- [Unit Morale & Psychology](#unit-morale--psychology)
- [Unit Customization & Individuality](#unit-customization--individuality)
- [Unit Cost & Maintenance](#unit-cost--maintenance)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

---

## Overview

### Design Context

The Unit system is the foundation of tactical gameplay in AlienFall. Units represent individual soldiers, specialized operatives, and alien entities that form the backbone of combat operations. The system features a deep progression mechanic inspired by XCOM and Battle for Wesnoth, where units advance through experience-based ranks with branching specialization paths.

**Core Philosophy**: Units are persistent, valuable assets that grow stronger through combat experience. Player attachment and strategic planning around unit composition is essential to the game experience.

---

## Unit Classification

### Class System

Units are organized through a **class hierarchy** that represents both their role and their specialization level. The class system follows a **promotion tree** model where units progress through increasingly specialized paths.

#### Rank Structure

All units are categorized by **Rank**, representing their experience and specialization level:

| Rank | Experience Required | Description |
|------|-------------------|-------------|
| **Rank 0** | 0 XP | Basic/Conscript (recruit level, limited supplies) |
| **Rank 1** | 200 XP | Agent (trained operative, basic role assignment) |
| **Rank 2** | 500 XP | Specialist (role proficiency achieved) |
| **Rank 3** | 900 XP | Expert (significant specialization begins) |
| **Rank 4** | 1,500 XP | Master (advanced specialization) |
| **Rank 5** | 2,500 XP | Elite (peak specialization, rare) |
| **Rank 6** | 4,500 XP | Hero (unique, one per squad maximum) |

**Note**: Smart trait accelerates XP gain by +20%, while Stupid trait decelerates it accordingly.

#### Class Hierarchy

The class structure follows a three-tier progression within each faction:

- **Rank 0**: Base unit (e.g., Sectoid for alien faction, Conscript for humans)
- **Rank 1**: Role assignment (Soldier, Support, Leader, Scout, Specialist, **Pilot**)
- **Rank 2**: Role specialization (e.g., within Soldier: Rifleman, Grenadier, Gunner; within Pilot: Fighter Pilot, Bomber Pilot, Transport Pilot)
- **Rank 3**: Specialization begins (e.g., Sniper specialist training; Ace Fighter for pilots)
- **Rank 4**: Advanced specialization (e.g., Marksman with special abilities; Strategic Bomber for pilots)
- **Rank 5**: Master specialization (e.g., Legendary Sniper with unique bonuses; Master Pilot with fleet command)
- **Rank 6**: Hero class (e.g., Supreme Commander with faction-wide bonuses)

**Class Synergy**: Equipment and abilities scale with unit class. A unit of a lower class attempting to use Rank 4+ equipment suffers -30% accuracy penalty. Units trained in a class bonus matching their equipment receive +50% effectiveness (e.g., Medic using Medikit heals for +50%).


#### Rank Progression Requirements

**Unit Acquisition Tiers**:
- Rank 0 units: Available early, limited quantity, purchased as raw recruits
- Rank 1+ units: Require prerequisite facility levels and technology research
- Specialist ranks (2+): Require either promotion or specialist recruitment contracts

**Rank Limits** (enforced by squad depth):
- Rank 0: Unlimited quantity
- Rank 1: Unlimited quantity
- Rank 2: Minimum 3 Rank 1 units required in squad
- Rank 3: Minimum 3 Rank 2 units required (implies 9 Rank 1 minimum)
- Rank 4: Minimum 3 Rank 3 units required (implies 27 Rank 1 minimum)
- Rank 5: Minimum 3 Rank 4 units required (implies 81 Rank 1 minimum)
- Rank 6: Minimum 3 Rank 5 units required (implies 243 Rank 1 minimum); only **one hero per player**

**Starting Units**: Player-recruited units begin at Rank 1 with "Agent" class. Subsequent recruits may be purchased at Rank 0 for cheaper cost or higher ranks through specialist suppliers.

### Unit Type

Units are classified by their biological or mechanical nature, which determines maintenance and healing methods:

- **Biological**: Healed through medical facilities and medikit items. Subject to morale effects and panic.
- **Mechanical**: Repaired using maintenance facilities and repair kits. Immune to morale/panic but require specialized maintenance resources.

### Faction Association

Every unit belongs to a **faction** (Humans, Sectoids, Ethereals, etc.), but within the player's organization:
- **Race**: Humans (default for player forces; visual and cultural identity)
- **Alien Races**: Available through recruitment, alliance, or capture
- Races themselves provide no stat bonuses—all stat distribution is class-based

---

## Unit Recruitment

### Standard Recruitment

Recruits are typically acquired through the **Marketplace** at **Rank 1** as "Agent" class, the basic operative template. Standard recruitment is limited by marketplace availability and monthly budget.

### Specialized Recruitment

Access to specialized units unlocks through:

1. **Technology Research**: Unlock new supplier contracts for specialized operatives or unique ranks
2. **Supplier Relationships**: Establish relations with weapon dealers, mercenary groups, and underground networks
3. **Specialist Recruitment**: Hire operatives at Rank 2+ for premium costs
4. **Robot Manufacturing**: Unlock mechanical unit production through engineering research
5. **Resurrection Program**: Recover fallen units from corpse specimens (high resource cost, unpredictable outcomes)
6. **Black Market Access**: High-cost recruitment of elite or rare units; impacts faction relations and ethics score

### Recruitment Constraints

- **Fame/Reputation**: Negative karma may block access to legitimate suppliers
- **Supplier Relations**: Poor standing reduces recruitment options and increases costs
- **Facility Availability**: Limited barracks space restricts new unit acquisition
- **Economic Capacity**: Monthly budget limits recruitment quantity

---

## Unit Statistics

## Unit Statistics

All units are defined by a core set of **stats** that determine combat effectiveness, utility, and survival. Base stat ranges for humans vary between 6-12, with aliens and specialists outside this range.

---

## Experience & Progression

### Experience Acquisition

Units gain experience through multiple channels:

#### Base Training
- **Passive Training**: +1 XP per week in barracks (no cost)
- **Active Training**: +1 to +3 XP per week (requires training facility, costs credits)
- **Smart Trait**: Accelerates XP gain by +20% across all sources
- **Stupid Trait**: Decelerates XP gain by -20%

#### Combat Experience
Experience awarded at end of battle for:

1. **Enemy Eliminations**: +10 XP per kill
2. **Damage Inflicted**: +0.15 XP per damage point (max 100 XP per mission)
3. **Survival Bonus**: +1 XP per turn survived (max 20 XP per mission)
4. **Squad Cohesion**: +10 XP if all squad members survive
5. **Mission Participation**: +50 XP just for completing the mission

#### Mission Objectives
- **Secondary Objectives**: +10-30 XP per completed objective
- **Research Data**: +10-50 XP for recovered alien technology
- **Difficulty Bonus**: ×1.0-1.8 multiplier based on mission difficulty

#### Medals & Commendations
Earned through achievement conditions; each unit can earn each medal only once:

- **Survivor**: Survive 20 consecutive battles → +25 XP (one-time)
- **Destroyer**: Kill 100 enemies across all battles → +50 XP (one-time)
- **Sharpshooter**: Achieve 50 headshots (or crits on non-humanoids) → +40 XP (one-time)
- **Guardian**: Take 200 damage and survive → +30 XP (one-time)
- **Hero**: Complete mission objective solo → +100 XP (one-time)
- **Legendary**: Complete entire campaign without casualty → +200 XP (one-time, squad-wide)

**Medal Impact**: Medals are universal—not faction or class-specific. They reward strategic play and bravery.

### Rank Promotion

#### Promotion Mechanic
- **Location**: Promotion occurs in base facilities (Personnel Center or Barracks)
- **Trigger**: Automatic when XP threshold reached
- **Cost**: Free (no credits required)
- **Time**: Instant (occurs end-of-turn or during admin phase)
- **Timing**: Promotions are never calculated mid-battle; experience is awarded post-battle and promotions applied during next base phase

#### Choosing Specialization Path
When promoting to **Rank 2+**, the player selects the unit's new class from available **promotion branches**:

Example progression tree:
```
Rank 1: Agent
├─ Rank 2: Rifleman → Rank 3: Assault Specialist → Rank 4: Commando → Rank 5: Battle Master
├─ Rank 2: Support → Rank 3: Medic → Rank 4: Surgeon → Rank 5: Field Commander
└─ Rank 2: Specialist → Rank 3: Marksman → Rank 4: Sniper → Rank 5: Ghost Operative
```

**One-Time Choice**: Each promotion branch is permanent. Demoting a unit allows switching paths (see Demotion below).

### Class Requirements for Equipment

**Class Hierarchy in Equipment**:
- A unit of Class X may use equipment requiring Class X
- A unit of Class Y (descended from X through promotion tree) may use equipment requiring Class X
- Example: Commando (Rank 4) may use Rifleman (Rank 2) equipment; Rifleman cannot use Commando equipment

**Class Mismatch Penalty**: Using equipment from a class path the unit never trained in: **-30% accuracy, -1 movement**

### Demotion System

**COMPREHENSIVE DEMOTION SPECIFICATION (A5)**

#### Overview

Demotion is a **strategic game mechanic** that allows players to voluntarily reduce a unit's rank in exchange for re-specialization opportunities. This enables creative squad composition without permanently abandoning veteran units.

#### Core Demotion Rules

**Demotion Definition**:
- Unit rank drops by 1 level (Rank 4 → Rank 3, etc.)
- Unit may re-choose specialization path from available branches at target rank
- Traits are unaffected (remain with unit)
- Equipment remains equipped (may cause equipment incompatibility, see below)

**Demotion Requirements**:
- Unit must be Rank 2 or higher (Rank 0-1 units cannot demote)
- Unit must have no active missions (in barracks only)
- Cost: **FREE** (no credits required)
- Time: **1 week** retraining period (unit unavailable for deployment)

#### Experience Retention (CLARIFIED - PROPORTIONAL SCALING)

**Demotion XP Calculation** (NOT flat 50%):

When unit demotes, XP is scaled proportionally to the previous rank level. This ensures units retain meaningful progress without losing all advancement.

```
Formula:
- Current rank XP threshold (lower bound): 1000 XP (example Rank 4)
- Current rank XP threshold (upper bound): 1500 XP (example Rank 5)
- Current unit XP: 1200 XP
- Target rank (previous): Rank 3

Step 1: Calculate progress within current rank
  Progress = (1200 - 1000) / (1500 - 1000) = 200 / 500 = 0.40 (40% progress)

Step 2: Calculate target rank boundaries
  Target lower: 600 XP (Rank 3 threshold)
  Target upper: 1000 XP (Rank 4 threshold)
  Target range: 1000 - 600 = 400 XP

Step 3: Apply proportional scaling
  New XP = 600 + (0.40 × 400) = 600 + 160 = 760 XP

Result: Unit demotes to Rank 3 with 760 XP (~76% progress toward Rank 4)
```

**Why Proportional Scaling**:
- Preserves veteran status (unit retains significant XP)
- Encourages careful re-specialization (meaningful cost without being punitive)
- Maintains long-term progression (can re-promote reasonably quickly)
- Prevents XP farming (cannot repeatedly demote/promote for gain)

**Examples**:
- Rank 4 unit with 1200 XP → Demotes to Rank 3 with 760 XP
- Rank 3 unit with 700 XP → Demotes to Rank 2 with 460 XP
- Rank 2 unit with 350 XP → Demotes to Rank 1 with 175 XP

#### Specialization Re-selection

**Available Paths**:
- When demoting to Rank 2, player selects from **all available Rank 2 specializations** (not just previous path)
- When demoting to Rank 1, unit becomes generic "Agent" class (no specialization choice)
- Rank 3+ demotions: Choose any valid specialization from target rank

**Example Re-specialization Paths**:

```
Current: Rank 4 Sniper (Rifleman → Assault → Sniper branch)
         [1,000 XP]

Demote to Rank 3:
    → 500 XP retained
    → Can now choose: Marksman OR Medic OR Specialist OR Scout
       (any Rank 3 available, not just Rifleman branch)

Option 1: Become Rank 3 Marksman
    → Different specialization within Rifleman tree

Option 2: Become Rank 3 Medic
    → Completely different role (support class)

Option 3: Become Rank 3 Specialist
    → Heavy weapons focus instead of precision
```

#### Equipment Compatibility After Demotion

**Compatibility Rules**:
- Equipment from lower ranks: **Fully compatible** (Rank 3 can use Rank 2 equipment)
- Equipment from higher ranks: **-30% accuracy, -1 movement penalty**
- Example: Rank 4 Sniper demotes to Rank 3, equipped with Rank 4 Sniper Rifle
  - Sniper rifle now imposes -30% accuracy (until unit re-promotes to Rank 4)
  - Unit should swap to Rank 3 equipment (Marksman Rifle) or accept penalty

**Recommendation**: Players should replace high-rank equipment with appropriate lower-rank alternatives after demotion to avoid mechanical penalties.

#### Stat Impact After Demotion

**Stat Loss**:
- Base stats revert to Rank 3 baselines (from Rank 4 level)
- Traits remain (traits are permanent)
- Transformations remain (transformation bonuses persist)
- Equipment bonuses remain

**Example Stat Change**:
```
Before Demotion (Rank 4 Sniper):
  - Accuracy: 80% (Rank 4 base)
  - Sight: 14 hexes (Rank 4 bonus)
  - Health: 15 HP

After Demotion (Rank 3 Marksman):
  - Accuracy: 75% (Rank 3 base)
  - Sight: 12 hexes (Rank 3 base)
  - Health: 13 HP

Change: -5% accuracy, -2 sight, -2 HP
```

**No Stat Bonus Retention**: Stats revert to base Rank 3 values; specialty bonuses do not carry forward.

#### Demotion Use Cases

**Strategic Use**:
1. **Path Correction**: Unit trained as Rifleman but player needs Medic → Demote to Rank 3, specialize as Medic
2. **Economic Efficiency**: Veteran unit with salary too high → Demote briefly to reduce salary burn, then re-promote
3. **Team Flexibility**: Squad composition changed → Demote units to re-specialize for new team roles
4. **Experience Recycling**: Veteran unit at max specialization → Demote to explore alternative career path

**Timing Considerations**:
- Only available between missions (barracks phase)
- Retraining takes 1 week (during which unit unavailable)
- XP loss is permanent (cannot be recovered)

#### Demotion Limitations

**Cannot Demote**:
- Rank 0-1 units (too junior, nothing to demote from)
- Units with "Stubborn" trait (trait prevents demotion)
- Units currently mid-transformation
- Mechanical units (cyborgs do not follow normal promotion tree)

**Irreversibility**:
- Demotion is permanent (cannot undo)
- Only way to recover lost XP: Combat in new role
- Lost stats do not return (must re-earn promotions)

#### Demotion vs. Retirement

**Alternative Options**:
- **Demotion**: Unit stays in service, changes specialization, retains 50% XP
- **Retirement**: Unit leaves service permanently (freed salary slot)
- **Storage**: Unit placed in barracks without assignments (still costs maintenance)

**Decision Tree**:
```
Does player want this unit?
├─ YES, different role → DEMOTE (re-specialize)
├─ YES, same role → KEEP (continue advancement)
└─ NO → RETIRE (free up barracks slot)
```

#### Implementation Guidelines

**For Engine Developers**:
1. Allow demotion only in barracks phase (not mid-mission)
2. Calculate XP retention (current × 0.5, rounded down)
3. Revert stats to target rank defaults
4. Keep traits and transformation status
5. Flag equipment for compatibility check
6. Apply 1-week retraining period
7. Display UI showing stat changes before confirmation

**For Designers**:
1. Use demotion to enable long-term squad engagement
2. Balance XP loss vs. specialization benefit
3. Consider Stubborn trait as demotion blocker
4. Design specialization branches to incentivize diverse play

**For Modders**:
1. Create new specialization branches accessible at different ranks
2. Adjust XP retention % if balance requires
3. Add rank-specific demotion restrictions
4. Define equipment compatibility penalties

---

## Respecialization System

### Overview

Respecialization is a **player-choice mechanic** that allows changing a unit's specialization without losing rank. Unlike demotion, respecialization keeps all stats and experience while enabling tactical flexibility. This enables players to adapt veteran units to new strategic needs without the penalties of demotion.

### Respecialization Definition

**Core Mechanics**:
- Unit rank remains unchanged (no level loss)
- Unit specialization changes to new class
- All stats remain at current levels (no decay)
- Perks reset and reassigned based on new specialization
- Experience and progress toward next rank preserved
- Costs funds and requires 1 week training time

### Respecialization Requirements

**Eligibility**:
- Unit must be Rank 2 or higher (Rank 0-1 units cannot respecialize)
- Unit must be in barracks (not deployed or mid-mission)
- Unit must have available respecialization uses (see limits below)
- Cost: **15,000 credits** per respecialization
- Time: **1 week** retraining period (unit unavailable for deployment)

### Specialization Change Process

**Available Specializations**:
- Player selects from **all valid specializations at current rank**
- Cannot respecialize to same specialization (must change)
- New specialization determines perk assignments and stat focuses

**Example Respecialization**:
```
Current: Rank 4 Assault Specialist
  - Accuracy: 88
  - Perks: "Suppressive Fire", "Combat Reflexes"
  - Specialization: Assault (high damage, close-quarters)

Respecialize to Rank 4 Support Specialist:
  - Accuracy: Stays 88 (no stat change)
  - Perks: Reset to "Medic Training", "Tactical Genius"
  - Specialization: Support (healing, buffing)
  - Result: Same rank, different role, all stats preserved
```

### Stat Preservation

**What Stays the Same**:
- All base stats (Accuracy, Health, Speed, etc.)
- Current rank and experience points
- Traits (permanent, unaffected by respecialization)
- Transformations (permanent modifications preserved)
- Equipment compatibility (may need gear adjustment for new role)

**What Changes**:
- Specialization class designation
- Perk assignments (reset and reassigned)
- Stat focus (new specialization emphasizes different attributes)
- Tactical role (from Assault to Support, etc.)

### Perk Reset and Reassignment

**Perk Handling**:
- All current perks removed (specialization-specific perks lost)
- New perks assigned based on new specialization
- Perk count remains the same (maintains power level)
- Player cannot choose individual perks (automatic assignment)

**Example Perk Changes**:
```
Assault Specialist → Support Specialist:
Lost: "Suppressive Fire", "Combat Reflexes", "Close Quarters Expert"
Gained: "Medic Training", "Tactical Genius", "Field Surgery"
```

### Respecialization Limits

**Usage Restrictions**:
- Maximum **2 respecializations** per unit (career limit)
- Once per 3 ranks: Can respec at Rank 2, then Rank 5, then Rank 8, etc.
- Cannot respecialize more than once per rank tier

**Example Limits**:
```
Unit at Rank 6:
- Can respecialize (used 1 of 2 lifetime uses)
- Next respecialization available at Rank 8
- Final respecialization available at Rank 11+

Unit at Rank 4:
- Can respecialize (first use)
- Next available at Rank 7
- One more use remaining
```

### Respecialization Timeline

**Process Flow**:
1. **Day 0**: Player initiates respecialization (pay 15,000 credits)
2. **Day 1-7**: Unit in training (unavailable for missions)
3. **Day 8**: Respecialization complete, unit available with new specialization

**Interruption Handling**:
- If unit dies during training week: Respecialization canceled, funds lost
- If mission called during training: Unit cannot deploy (training continues)
- No refunds for interrupted training (represents wasted training investment)

### Strategic Use Cases

**Tactical Adaptation**:
1. **Squad Role Change**: Veteran Assault unit needed as Medic → Respecialize to Support
2. **Meta Adaptation**: Game balance shifts, old specialization less viable → Switch to stronger role
3. **Campaign Evolution**: Early-game Assault becomes late-game Support → Adapt to new threats
4. **Player Preference**: Enjoyed different playstyle → Experiment with new specialization

**Economic Considerations**:
- 15,000 credit cost represents significant investment
- 1 week downtime means missed missions/revenue
- Limited uses encourage commitment to chosen path
- Cheaper than recruiting new specialist (but keeps veteran stats)

### Respecialization vs. Demotion Comparison

| Aspect | Respecialization | Demotion |
|--------|------------------|----------|
| **Rank Change** | No change | -1 to -3 levels |
| **Stat Impact** | No change | Decay to 75% |
| **XP Loss** | None | Proportional retention |
| **Perks** | Reset/reassigned | Specialization-appropriate |
| **Cost** | 15,000 credits | Free (but rank loss penalty) |
| **Time** | 1 week training | 1 week retraining |
| **Use Case** | Strategic adaptation | Path correction/punishment |
| **Limits** | 2 per unit, once per 3 ranks | No limits (but painful) |

### UI and Player Communication

**Respecialization Screen**:
```
Respecialize [Unit Name] from Assault to Support?
Cost: 15,000 credits
Training Duration: 1 week
Stats: Remain unchanged
Perks: Will be reset and reassigned
Remaining Uses: 1 of 2
Proceed? [YES] [NO]
```

**Status Display**:
- Unit shows "In Training" status during respecialization
- Progress bar for training week
- Notification when complete
- Respecialization count in unit details

### Balance Considerations

**Power Level Maintenance**:
- Stats preserved = veteran effectiveness maintained
- Perks reset = specialization-appropriate abilities
- Cost and time = meaningful investment barrier
- Limited uses = prevents constant switching

**Strategic Depth**:
- Enables long-term squad adaptation
- Rewards keeping veteran units alive
- Creates meaningful specialization choices
- Balances flexibility vs. commitment

### Implementation Guidelines

**For Engine Developers**:
1. Track respecialization uses per unit (lifetime counter)
2. Preserve all stats during respecialization
3. Reset and reassign perks based on new specialization
4. Implement 1-week training timer
5. Handle interruption cases (death, mission conflicts)

**For Designers**:
1. Balance respecialization cost vs. demotion pain
2. Design specialization perks to be meaningfully different
3. Consider respecialization as meta-adaptation tool
4. Use limits to encourage specialization commitment

**For Modders**:
1. Define respecialization costs and time requirements
2. Create specialization perk sets
3. Adjust usage limits for balance
4. Add custom respecialization logic

---

## Unit Inventory & Equipment

### Capacity System

**Inventory Capacity**:
- Each unit has **Strength stat-based capacity** (6-12, representing carrying capacity)
- Total item weight cannot exceed capacity, or unit cannot carry the load
- **Binary System**: Unit either carries all items or cannot carry them at all—no partial equipping

### Equipment Slots

Units have **3 primary equipment slots**:

1. **Primary Weapon**: Rifle, Pistol, Grenade Launcher, Heavy Cannon, etc.
2. **Secondary Weapon**: Backup weapon, grenades, or utility item
3. **Armor**: Body armor, environmental suit, or specialized protective gear

**Slot Modifications**:
- Some traits, wounds, or transformations may reduce available slots
- In-built weapons (mechanical units) may occupy slots permanently
- Grenades and consumables can occupy secondary weapon slot

### Weapon Categories

All items that can be wielded as weapons:

#### Ranged Weapons
- **Pistol**: 8-hex range, 1 AP, 12 base damage, 70% accuracy, 5 EP cost
- **Rifle**: 15-hex range, 2 AP, 18 base damage, 70% accuracy, 8 EP cost
- **Sniper Rifle**: 25-hex range, 3 AP, 35 base damage, 85% accuracy, 12 EP cost
- **Shotgun**: 3-hex range, 2 AP, 45 base damage, 60% accuracy, 10 EP cost, 3-hex area blast
- **Grenade Launcher**: 12-hex range, 2 AP, 30 area damage, 65% accuracy, 15 EP cost
- **Heavy Cannon**: 20-hex range, 3 AP, 60 base damage, 55% accuracy, 20 EP cost (Specialist requirement)

#### Melee Weapons
- **Knife**: 1-hex range, 1 AP, 8 base damage, 8 melee to hit, infinite energy
- **Sword**: 1-hex range, 1 AP, 15 base damage, 10 melee to hit, infinite energy
- **Plasma Blade**: 1-hex range, 1 AP, 25 base damage (Specialist requirement), 12 melee to hit, 8 EP cost

#### Thrown Weapons
- **Grenade**: 1 AP, 30 area damage, 3-hex radius blast, uses Aim stat
- **Incendiary Grenade**: 1 AP, 20 damage + fire DoT, 3-hex radius
- **Smoke Grenade**: 1 AP, creates 3-hex smoke area (blocks vision), 2-turn duration
- **Flashbang**: 1 AP, stuns enemies in 2-hex radius for 1 turn, 2 AP cost to act while stunned
- **Flashlight**: Handheld torch, +2 night vision, no AP cost to equip

#### Support Weapons
- **Psionic Amplifier**: 1 AP to activate, enables psionic attacks, 30 EP per attack
- **Stun Baton**: 1 AP, 10 damage + 50% stun chance, 5 EP cost, no range requirement
- **EMP Grenade**: 1 AP, disables mechanical units in 3-hex area for 1 turn

#### Medical Equipment
- **Medikit**: 5 charges, 1 AP per use, heals 25 HP (Medic) or 15 HP (non-Medic), 1 per unit
- **Stimulant Injector**: 1 AP, restores 10 HP and +2 morale, costs 50 credits

#### Utility Equipment
- **Motion Scanner**: +3 sight range, 50-turn battery, 1 AP to activate
- **Night Vision Goggles**: +5 night vision, 100-turn battery, passive when equipped
- **Repair Kit**: Repairs mechanical units, 25 HP per use, 3 charges
- **Scope Attachment**: +20% accuracy for aimed shots, can attach to any rifle

### Armor Categories

All items worn as body armor. Armor provides Armor Value (damage reduction), movement/AP modifiers, accuracy bonuses/penalties, and damage type resistances. Armor Value: 1 point = 1 damage reduction.

#### Standard Armor Types

| Armor Type | Armor Value | Movement Penalty | AP Penalty | Accuracy | Cost | Special |
|-----------|-----------|------------------|-----------|----------|------|---------|
| **Light Scout** | +5 | +1 hex/turn | 0 | +5% | 8K | Mobility-focused; no penalties |
| **Combat Armor** | +15 | -1 hex/turn | -1 AP | -5% | 15K | Balanced; standard protection |
| **Heavy Assault** | +25 | -2 hex/turn | -2 AP | -10% | 25K | Max protection; mobility cost |
| **Hazmat Suit** | +10 | 0 | 0 | -5% | 12K | +100% poison/hazard resistance |
| **Stealth Suit** | +8 | 0 | 0 | Normal | 20K | +20% concealment/stealth |
| **Medic Vest** | +8 | 0 | 0 | Normal | 10K | +50% medikit healing effectiveness |
| **Sniper Ghillie** | +10 | -1 hex/turn | 0 | +10% | 18K | +1 sight range; marksman-optimized |

#### Armor Classification

**Armor Weight Categories**:
- **Light armor** (Scout): 0 movement penalty, 0 AP penalty
- **Medium armor** (Combat): -1 hex/turn movement, -1 AP/turn
- **Heavy armor** (Assault): -2 hex/turn movement, -2 AP/turn, -5% accuracy penalty
- **Specialized armor** (Hazmat/Stealth/Medic/Sniper): Varies by type

#### Damage Type Resistances

Different armor types provide varying resistances to damage types:

**Armor Resistance Ranges**:
- Kinetic: 0-50% reduction
- Energy: 0-40% reduction
- Hazard (poison/chemical): 0-30% reduction

**Resistance-Bearing Armor**:
- **Ablative Armor**: -50% explosive damage; degrades 10% per explosive hit (temporary defense)
- **Reactive Armor**: -40% explosive, -20% kinetic (reactive tiles absorb impact)
- **Energy Shield** (power-dependent): -50% all damage types; requires fuel/energy to regenerate
- **Standard Armor**: No special resistances; base Kinetic reduction only

### Inventory Management

**Weight Capacity**: Based on unit's Strength stat (6-12)
- Strength 6 = 6 item capacity
- Strength 12 = 12 item capacity
- Each weapon = 1-2 weight units
- Each armor = 2-3 weight units
- Each utility item = 0.5-1 weight unit

**Overflow Penalty**: Carrying beyond capacity inflicts +5% maintenance costs per overflow unit (representing damage from overexertion)

**Quick-Access System**: Unused inventory slots can hold ammunition, consumables, or mission-specific items

---

## Unit Traits

### Trait System

**Traits** are permanent modifiers assigned to units during recruitment or advancement. Each unit can possess **multiple traits**, balanced by point value.

### Trait Mechanics

**Trait Point Value**:
- Each trait has a point cost (positive traits cost 1-2 points, negative traits refund 1-2 points)
- **Units have exactly 4 trait points available** to spend on positive traits or save via negative traits
  - Starting trait points: 4 (all units recruit at full allocation)
  - Minimum: Units can drop to 0 points by taking enough negative traits
  - Maximum: 4 points (fixed cap, cannot exceed)
- Positive traits (speed +2, strong +2) **consume points** from the 4-point pool
- Negative traits (fragile -1 HP, clumsy -1 accuracy) **refund points** back into the pool (up to 4 max)
- Example builds:
  - Tank: Fast (1) + Strong (1) + Brave (2) = 4 points used
  - Scout: Fast (1) + Sharp Eyes (1) + Lucky (1) + Stupid (-1 refunded) = 3 points used, 1 point available
  - Budget: Coward (-1 refunded) + Fragile (-1 refunded) + Stupid (-1 refunded) = 6 points available but still capped at 4 max

**Scope**: Traits are assigned at unit recruitment and cannot be changed without special interventions (transformation, research)

**Trait Point Constraints by Rank**:
- **Rank 0 (Recruit):** 4 points available, can only pick traits without rank requirement
- **Rank 2+:** Unlock Rank 2 traits (e.g., Agile, Leader, Brave)
- **Rank 4+:** Unlock Rank 4 traits (e.g., Legendary traits - if implemented)

**Trait Synergies & Conflicts**:
- Smart + Stupid: **Mutually exclusive** (cannot have both)
- Leader + Brave: Strong synergy (creates squad anchor unit)
- Psychic + Research: Psionic requires both trait purchase AND "Psionic Research" tech unlock


### Positive Traits

| Trait | Effect | Point Cost | Requirements |
|-------|--------|------------|--------------|
| **Fast** | Speed +2 | 1 | Any |
| **Strong** | Strength +2 | 1 | Any |
| **Agile** | Action Points +1 | 2 | Rank 2+ |
| **Sharp Eyes** | Sight +2 hexagons | 1 | Any |
| **Smart** | XP Gain +20% | 1 | Any (conflicts with Stupid) |
| **Loyal** | Salary -50% | 1 | Any |
| **Leader** | Morale Aura +1 (allies in 3-hex radius gain +1 morale) | 2 | Rank 2+ |
| **Brave** | Panic immunity until morale ≤ 0 | 2 | Rank 2+ |
| **Sharpshooter** | Accuracy +10% | 1 | Any |
| **Bloodthirsty** | Melee damage +5 | 1 | Any |
| **Psychic** | Unlocks psionic abilities (base psi stat 5) | 2 | Research required |
| **Lucky** | +10% critical hit chance (if crits exist) | 1 | Any |

### Negative Traits

| Trait | Effect | Points Refunded | Restrictions |
|-------|--------|-----------------|--------------|
| **Fragile** | Health -2 | 1 | Prevents Heavy Armor |
| **Clumsy** | Accuracy -10%, Speed -1 | 1 | None |
| **Stupid** | XP Gain -20% | 1 | Conflicts with Smart |
| **Coward** | Morale penalty -2, panic threshold +1 | 1 | Rank 1-2 only |
| **Pacifist** | Damage -25% (ideological penalty) | 2 | Ethical restriction |
| **Weak** | Strength -2 (carry capacity reduced) | 1 | Limits heavy weapons |
| **Stubborn** | Cannot be demoted/promoted normally | 2 | Permanent choice |

### Trait Requirements & Synergies

**Class Requirements**: Some traits are locked to specific classes or ranks
- Example: "Leader" trait requires Rank 2+ and leadership-class specialization

**Race Requirements**: Some traits may be faction or race-restricted
- Example: "Alien Biology" trait only available to alien units

**Synergies**: Traits can interact:
- Smart + XP boost from medals creates rapid advancement
- Leader + Brave combo creates valuable squad anchors
- Psychic + Psi stat improves psionic effectiveness

---

## COMPREHENSIVE TRAITS SPECIFICATION (A4)

### Overview
This section consolidates and clarifies the traits system, establishing it as canonical (A4 specification from gap analysis). **Traits are permanent, randomly-assigned unit modifiers that affect gameplay from recruitment through entire career.**

### Trait Definition

**What are Traits?**
- Permanent behavioral/physical characteristics assigned at unit recruitment
- Cannot be changed except through rare interventions (Transformation, research)
- Generated randomly during recruitment (1-3 traits per unit depending on modder configuration)
- **Immutable by default** (traits stay with unit for entire career)
- Affect combat stats, special abilities, economic cost, and progression

### Trait Point System (Revised & Complete)

#### Point Allocation

**Basic Rule**: Each unit has exactly **4 trait points** to allocate at recruitment.

**Point Flow**:
```
Starting: 4 points
↓
Add positive traits (cost 1-2 points each): Reduces available points
Add negative traits (refund 1-2 points each): Increases available points
↓
Final: Total available points capped at 4 (cannot exceed original)
```

**Examples**:
1. **Balanced Unit**: Fast (1) + Strong (1) + Loyal (1) = 3 points spent, 1 point unused
2. **Specialist Unit**: Agile (2) + Leader (2) = 4 points spent (fully maxed)
3. **Budget Unit**: Smart (1) + Fragile (refund 1) + Coward (refund 1) = 2 points spent, 2 points available
4. **Maximum Trait Unit**: Brave (2) + Psychic (2) + Agile (2) + Lucky (1) = INVALID (exceeds 4, must be 4 max)

#### Trait Point Constraints by Rank

| Rank | Trait Points Available | Lockouts |
|------|----------------------|----------|
| **Rank 0 (Recruit)** | 4 points | Cannot pick Rank 2+ traits |
| **Rank 1 (Agent)** | 4 points | Cannot pick Rank 2+ traits |
| **Rank 2+ (Specialist)** | 4 points | All traits unlocked |
| **Rank 4+ (Master)** | 4 points | Can pick Rank 4 traits if implemented |

**Note**: Units never gain additional trait points during progression. Trait point pool remains fixed at 4 throughout career.

#### Trait Assignment Process

**Recruitment**:
1. Player selects unit for recruitment
2. System randomly generates 1-3 traits (modder-configurable: E.g., 50% 1 trait, 30% 2 traits, 20% 3 traits)
3. Traits assigned with total cost ≤ 4 points
4. Player can accept/reject and re-roll traits (costs additional recruitment fee)
5. Once accepted, traits are permanent

**Re-rolling Cost**: 500 credits per re-roll (modder-configurable)

### Trait Categories

#### POSITIVE TRAITS (Cost Points)

| # | Trait | Effect | Points | Requirements | Conflicts |
|---|-------|--------|--------|--------------|-----------|
| 1 | **Fast** | Speed +2, Movement +1 hex | 1 | Any | None |
| 2 | **Strong** | Strength +2, Carry +2 | 1 | Any | Weak |
| 3 | **Agile** | Action Points +1 (max 5 AP) | 2 | Rank 2+ | None |
| 4 | **Sharp Eyes** | Sight +2 hexagons, +1 accuracy | 1 | Any | None |
| 5 | **Smart** | XP Gain +20%, faster promotion | 1 | Any | Stupid |
| 6 | **Loyal** | Salary -50% (economic savings) | 1 | Any | None |
| 7 | **Leader** | Morale Aura +1 (allies 3-hex radius) | 2 | Rank 2+ | None |
| 8 | **Brave** | Bravery +1, panic delayed 1 turn | 2 | Rank 2+ | Coward |
| 9 | **Sharpshooter** | Accuracy +10%, ranged only | 1 | Any | None |
| 10 | **Bloodthirsty** | Melee damage +5, +1 wound chance | 1 | Any | Pacifist |
| 11 | **Psychic** | Unlocks psionic abilities (Psi +5 base) | 2 | Tech required | None |
| 12 | **Lucky** | Critical Hit +10% chance | 1 | Any | None |
| 13 | **Resilient** | Health +2, damage -1 | 1 | Any | Fragile |
| 14 | **Hawkeyed** | Detect hidden enemies +3 range | 2 | Rank 2+ | None |
| 15 | **Charming** | Recruitment cost -20% when this unit leads | 1 | Any | None |

#### NEGATIVE TRAITS (Refund Points)

| # | Trait | Effect | Refund | Restrictions | Conflicts |
|---|-------|--------|--------|--------------|-----------|
| 1 | **Fragile** | Health -2, cannot use heavy armor | 1 | Any | Resilient |
| 2 | **Clumsy** | Accuracy -10%, Speed -1 | 1 | Any | None |
| 3 | **Stupid** | XP Gain -20%, slower promotion | 1 | Any | Smart |
| 4 | **Coward** | Morale -2, panic +1 threshold | 1 | Rank 1-2 only | Brave |
| 5 | **Pacifist** | Damage -25% (ideological) | 2 | Rank 1 only | Bloodthirsty |
| 6 | **Weak** | Strength -2, carry reduced by 2 | 1 | Any | Strong |
| 7 | **Stubborn** | Cannot be promoted/demoted easily | 2 | Permanent | None |
| 8 | **Paranoid** | Sight +1, but morale -1 + sanity -1 | 2 | Rank 2+ | None |
| 9 | **Reckless** | Accuracy +5%, but defense -10% | 1 | Any | None |
| 10 | **Sickly** | Health -1, healing -25% effectiveness | 1 | Any | None |

### Trait Inheritance & Randomization

#### Recruitment Trait Generation

**Default Randomization** (modder-configurable):
- 50% of recruits spawn with 1 trait
- 30% of recruits spawn with 2 traits
- 15% of recruits spawn with 3 traits
- 5% of recruits spawn with no traits

**Point Distribution**:
- Traits generated must total ≤ 4 points
- System automatically prevents invalid combinations (e.g., both Smart + Stupid)
- Conflicts resolved: If random roll produces conflict, one trait replaced

**Example Generation**:
- Roll generates: Smart (1) + Agile (2) + Loyal (1) = 4 points ✓ Valid
- Roll generates: Brave (2) + Agile (2) + Smart (1) = 5 points ✗ Invalid; system removes Loyal if possible

#### Trait Persistence

**Permanent Nature**:
- Traits do NOT change during unit career
- Demotion does NOT remove traits
- Wounds do NOT affect traits
- Transformations do NOT add/remove traits (only modify stats)

**Exception - Transformation Interaction**:
- Some Transformations may temporarily disable certain traits during transformation period
- Upon completion, traits resume normal function

### Trait Effects on Gameplay

#### Combat Effects

| Trait | Battlescape Impact | Example |
|-------|-------------------|---------|
| **Fast** | Move 1 additional hex per turn | Normal: 5 hexes → With Fast: 6 hexes |
| **Strong** | Melee damage +5 | Normal 15 damage → With Strong: 20 damage |
| **Agile** | +1 action point (max 5) | Normal 4 AP → With Agile: 5 AP |
| **Sharp Eyes** | +2 sight range | Normal 10 hex sight → With Sharp Eyes: 12 hexes |
| **Sharpshooter** | +10% ranged accuracy | Normal 70% accuracy → With Sharpshooter: 80% |
| **Bloodthirsty** | Melee +5 damage, +1 crit chance | Increased wound infliction |
| **Brave** | Morale -1 at mission start instead of normal | Delayed panic threshold |
| **Lucky** | +10% critical hit chance | Approximately +2 crits per 20-shot average |
| **Leader** | Allies within 3 hexes gain +1 morale | Squad cohesion bonus |
| **Psychic** | Unlock psionic attacks (Psi stat +5) | New attack type available |

#### Economic Effects

| Trait | Impact | Calculation |
|-------|--------|------------|
| **Loyal** | Salary -50% | 1,000 credits → 500 credits/month |
| **Smart** | XP +20% | 100 XP earned → 120 XP gained |
| **Charming** | Recruitment -20% | When this unit leads squad, recruitment costs -20% |
| **Fragile** | Equipment locked | Cannot equip heavy armor (+25 armor) |

#### Progression Effects

| Trait | Career Impact | Notes |
|--------|--------------|-------|
| **Smart** | Promotion 20% faster | Rank 0→1: 100 XP (normal) → 83 XP (Smart) |
| **Stupid** | Promotion 20% slower | Rank 0→1: 100 XP (normal) → 120 XP (Stupid) |
| **Brave** | Morale management better | Panic threshold delayed 1 turn |
| **Coward** | Morale management harder | Panic threshold accelerated 1 turn |

### Trait Combinations & Conflicts

#### Mutually Exclusive Pairs

These traits **cannot** both be on the same unit:

| Pair | Reason |
|------|--------|
| **Smart + Stupid** | XP gain conflict |
| **Strong + Weak** | Strength conflict |
| **Brave + Coward** | Morale philosophy conflict |
| **Resilient + Fragile** | Health philosophy conflict |
| **Bloodthirsty + Pacifist** | Damage philosophy conflict |

**Enforcement**: System prevents both from being randomly assigned; if conflict detected, re-roll one trait.

#### Synergistic Combinations

These traits work well together (bonus effectiveness):

| Combo | Effect | Example |
|-------|--------|---------|
| **Leader + Brave** | Squad anchor unit | Creates valuable anchor for morale management |
| **Smart + Agile** | Tactical unit | Promotion faster + more actions per turn |
| **Sharp Eyes + Sharpshooter** | Marksman specialist | +2 sight + +10% accuracy = sniper build |
| **Fast + Agile** | Hyper-mobile scout | Additional movement + additional action point |
| **Loyal + Strong** | Economic tank | Low salary + high carrying capacity |

**No Mechanical Bonus**: Synergies provide strategic advantage but no automatic combat bonus.

### Trait Interactions with Other Systems

#### With Promotion System
- Traits do NOT change rank or progression requirement
- Demotion does NOT remove traits
- Example: Stupid unit still requires same XP as Smart unit, just takes longer

#### With Transformation System
- Traits persist through transformation
- Transformation may temporarily disable trait effectiveness (modder-specific)
- Transformation bonuses stack with trait bonuses
- Example: Strong (+2 STR) + Berserker (+3 STR) = +5 STR total

#### With Wounds System
- Traits do NOT reduce wound recovery time
- Traits do NOT change damage taken from wounds
- Bloodthirsty trait increases wound infliction (see Combat Effects)

#### With Equipment System
- Traits affect equipment compatibility (e.g., Fragile blocks heavy armor)
- Traits do NOT reduce equipment effectiveness
- Example: Sharp Eyes trait doesn't reduce scope benefit; they stack

### Trait Implementation Guidelines

**For Engine Developers**:
1. Generate traits at recruitment time using random seeding
2. Store traits as immutable list on unit object
3. Apply trait bonuses/penalties at combat calculation
4. Prevent conflicting trait combinations
5. Display traits in unit inspector/status window

**For Modders**:
1. Create new trait definitions with point cost, effects, conflicts
2. Add traits to random generation pool with probability weight
3. Test that generated combinations don't exceed 4 points
4. Verify all trait conflicts are properly enforced
5. Rebalance recruitment costs if new traits significantly affect power level

**For Balancers**:
1. Monitor win rate correlation with specific trait combinations
2. Adjust trait point cost if meta becomes dominated by single traits
3. Ensure negative traits actually cost players decisions (not just RP flavor)
4. Test that trait generation provides varied unit types

---

## Transformations

### Transformation System

**Transformations** are permanent surgical or biological modifications that fundamentally alter a unit.

**Rules**:
- Each unit can undergo **exactly one transformation** (permanent, irreversible)
- Transformations are either **Biological** or **Mechanical**
- Transformations can modify stats, unlock new abilities, or change equipment slots
- Transformations are difficult, require high-level research, and are expensive

### Transformation Categories

#### Biological Transformations

| Transformation | Stat Bonus | Cost | Requirements | Effects |
|---|---|---|---|---|
| **Combat Augmentation** | Speed +2, Aim +2 | 5,000 credits | Rank 3+, Biology Lab | Standard combat enhancement |
| **Psionic Awakening** | Psi +5, Sanity -2 | 8,000 credits | Rank 3+, Psi Lab | Enables psionic abilities |
| **Berserker Protocol** | Strength +3, Health +3, Aim -1 | 6,000 credits | Rank 3+, Combat Lab | Melee-focused enhancement |
| **Enhanced Perception** | Sight +3, Sense +2, Speed +1 | 7,000 credits | Rank 2+, Sensory Lab | Scout/Recon enhancement |
| **Regeneration** | Health Regen +2/turn in battle | 10,000 credits | Rank 4+, Gene Lab | Passive healing during combat |

#### Mechanical Transformations

| Transformation | Stat Bonus | Cost | Requirements | Effects |
|---|---|---|---|---|
| **Cyborg Framework** | Strength +2, Speed +1, Armor +2 | 8,000 credits | Rank 3+, Robotics Lab | Hybrid human-machine |
| **Full Mechanization** | Health +5, Armor +5, Morale immune | 15,000 credits | Rank 4+, Advanced Robotics | Becomes full robot (no morale/sanity) |
| **Targeting System** | Accuracy +15%, Aim +2 | 6,000 credits | Rank 2+, Targeting Lab | Precision enhancement |
| **Kinetic Absorption** | Kinetic Resistance +30%, Speed -1 | 7,000 credits | Rank 3+, Defense Lab | Absorbs impact damage |

### Transformation Effects on Equipment

**Equipment Slot Changes**:
- Some transformations disable equipment slots (e.g., Full Mechanization doesn't allow armor swapping)
- Others unlock new slots (e.g., Cyborg Framework allows equipment-less operation)
- Transformation weapons are built-in and cannot be swapped

**Stat Interactions**: Transformation bonuses stack with trait bonuses and equipment bonuses

### Transformation Recovery & Reversal

- Transformations are **permanent and irreversible**
- No refund of transformation credits upon unit removal
- Transformed units cannot be cloned or resurrected; the transformation data is lost

---

## Unit Roles & Specializations

### Combat Roles

Based on class and rank, units fill different battlefield roles:

#### Soldier
- **Primary**: General combat, adaptable
- **Strengths**: Balanced stats, flexible equipment
- **Progression**: Rifleman → Assault Specialist → Commando

#### Support
- **Primary**: Healing, buffing, utility
- **Strengths**: Medical abilities, morale bonuses
- **Progression**: Medic → Combat Medic → Field Surgeon

#### Scout
- **Primary**: Reconnaissance, high movement
- **Strengths**: Speed, sight range, light armor
- **Progression**: Scout → Ranger → Ghost Operative

#### Specialist
- **Primary**: Heavy weapons, area control
- **Strengths**: High damage, area effects
- **Progression**: Grenadier → Heavy Specialist → Demolitions Expert

#### Leader
- **Primary**: Command, morale, squad support
- **Strengths**: Leadership aura, decision-making bonuses
- **Progression**: Squad Leader → Commander → Legendary Commander

### Role Customization

Players can mix and match traits, equipment, and specializations to create hybrid roles:
- Agile Specialist (Scout + Heavy Weapons for unique mobility)
- Melee Combat Medic (Support role with close-range healing)
- Recon Soldier (Soldier class with Scout equipment and traits)

---

## Unified Pilot Specification

> **⚠️ CANONICAL SOURCE**: This section is the authoritative specification for pilot mechanics.
> **See also**: Pilots.md (detailed pilot specialization), Crafts.md (craft requirements)
> **Core Principle**: Pilot is a Unit Role with standard 6-12 stat that grows with unit promotion

### Overview

**Pilots are specialized unit roles** that can operate craft (aircraft/spacecraft). The pilot system uses the standard unit system where Pilot is a class specialization available from Rank 1, with a Piloting stat (6-12 range) that improves as the unit is promoted through ranks.

**Key Principle**: All units start with Piloting 0 (untrained). Only units trained in Pilot class specialization have Piloting stat 6-12. Piloting grows with unit rank/promotion like all other stats.

---

### Pilot Mechanics - Core Rules

#### Pilot as Unit Role/Class

**Pilot Specialization Path**:
```
Rank 0: Conscript (base unit, Piloting 0)
    ↓
Rank 1: **Pilot** (role assignment - Piloting 6-8 baseline)
    ↓
Rank 2: Specialization branches:
    → Fighter Pilot (Piloting 8-10)
    → Bomber Pilot (Piloting 8-10)
    → Transport Pilot (Piloting 8-10)
    → Scout Pilot (Piloting 8-10)
    ↓
Rank 3: Advanced Specialization:
    → Ace Fighter (Piloting 10-11)
    → Strategic Bomber (Piloting 10-11)
    → Master Transport (Piloting 10-11)
    → Recon Expert (Piloting 10-11)
    ↓
Rank 4: Elite Specialization:
    → Squadron Commander (Piloting 11-12)
```

#### Piloting Stat: 6-12 Scale (Standard)

**Universal Rule**: Piloting is a standard 6-12 stat like Aim, Melee, Speed, Bravery, etc.

**Default Ranges by Rank**:

| **Rank** | **Piloting Range** | **Status** | **Craft Access** |
|---|---|---|---|
| **Rank 1 (Pilot)** | 6-8 | Recruit | Scout/Transport |
| **Rank 2** | 8-10 | Experienced | Combat craft (Fighter/Bomber) |
| **Rank 3** | 10-11 | Advanced | Specialized aircraft |
| **Rank 4+** | 11-12 | Master | All craft available |

**No Units Have Piloting**:
- Non-pilot class units: Piloting 0 (untrained, cannot pilot any craft)
- Standard soldiers: Piloting 0 (even with high Accuracy)
- Medics, Snipers, Scouts: Piloting 0 (unless trained in Pilot class)

#### Pilot Experience & Promotion

**Experience Tracks**:

Pilots have **one unified XP track** that advances them through ranks. Piloting stat improves **as unit is promoted through ranks**, following the standard progression mechanic.

**XP Sources**:
- **Battlescape missions**: 5-20 XP per mission (standard unit XP)
- **Interception missions**: 10-20 XP per mission (when flying craft)
- **UFO destroyed**: +10 XP bonus (impressive feat)
- **Promotion**: Unit gains rank → Piloting stat increases (+1-2 points)

**Promotion Progression**:
- Pilot gains XP from all missions (battles + flying)
- XP accumulates normally (100 XP → Rank 2, 300 XP → Rank 3, etc.)
- Upon promotion, Piloting automatically increases per new rank

---

### Craft Assignment & Operation

#### Pilot Assignment

**Requirements**:
- Unit must have Piloting stat (Rank 1+ Pilot class)
- Unit Piloting ≥ minimum craft requirement
- Unit cannot be deployed to Battlescape if assigned to craft

**Assignment Process**:
1. Select craft from hangar
2. Assign Pilot unit from roster
3. Pilot locked to craft until reassigned
4. Cannot reassign during active mission (must wait for admin phase)

**Reassignment**:
- **Time**: 1 day retraining period
- **Cost**: 100 credits administrative fee
- **Restrictions**: Cannot during active mission

#### Craft Requirements by Type

| **Craft Type** | **Min Piloting** | **Recommended Class** | **Crew** |
|---|---|---|---|
| **Scout** | 6 | Any Pilot | 1 |
| **Transport** | 7 | Transport Pilot | 1 + passengers |
| **Fighter** | 8 | Fighter Pilot | 1 |
| **Bomber** | 8 | Bomber Pilot | 1 |
| **Advanced** | 10 | Rank 3 Pilot | 1 |
| **Capital Ship** | 12 | Squadron Commander | 1 + crew |

**Performance Impact**:

| **Piloting vs Requirement** | **Effect** | **Notes** |
|---|---|---|
| Below minimum | Cannot operate | Craft cannot be deployed |
| At minimum (6) | -20% accuracy, -10% speed | Baseline access only |
| Recommended (8+) | Normal performance | Full capability |
| Above recommended (+2) | +10% accuracy, +5% speed | Experienced pilot |
| Maximum (12) | +20% accuracy, +10% speed | Ace pilot bonuses |

---

### Pilot Craft Bonuses

**Performance Bonus Formula**:

Each Piloting point provides bonus to assigned craft:

```
Bonus% = (Piloting - 6) × 5%    [For Piloting 6-12]

Examples:
- Piloting 6: (6-6) × 5% = 0% (baseline only)
- Piloting 8: (8-6) × 5% = +10% accuracy bonus
- Piloting 10: (10-6) × 5% = +20% accuracy bonus
- Piloting 12: (12-6) × 5% = +30% accuracy bonus (maximum)
```

**Bonus Categories**:
- **Speed Bonus**: +5% per Piloting point (max +30% at Piloting 12)
- **Accuracy Bonus**: +7.5% per Piloting point (max +45% at Piloting 12)
- **Dodge Bonus**: +5% per Piloting point (max +30% at Piloting 12)

**Multiple Pilots (Crew)**:

If craft has multiple pilot crew slots:
```
Pilot 1 (Piloting 10): +20% accuracy
Pilot 2 (Piloting 8): +10% accuracy
Combined: +30% accuracy (bonuses stack)
```

---

### Pilot Specialization Benefits

**Fighter Pilot (Rank 2)**:
- Focus on air combat accuracy
- +10% accuracy in interception vs UFOs
- Unlock: Dogfighting maneuvers

**Bomber Pilot (Rank 2)**:
- Focus on payload and targeting
- +20% payload capacity
- Unlock: Precision bombing

**Transport Pilot (Rank 2)**:
- Focus on efficiency and cargo
- +2 passenger capacity
- -10% fuel consumption

**Ace Fighter (Rank 3)**:
- +20% accuracy vs UFOs
- +10% critical hit chance
- Unlock: Aggressive pursuit (chase retreating UFOs)

**Squadron Commander (Rank 4)**:
- Can command wing of 2-4 craft
- Allied craft in wing gain +5% accuracy
- Unlock: Coordinated attack bonus

---

### Pilot Dual Role Limitation

**Cannot Simultaneously**:
- Pilot craft AND deploy to Battlescape (same mission)
- Must choose: fly craft OR fight in squad

**Options**:
- **During Geoscape Phase**: Pilot assigned to craft → flies interception
- **During Battlescape Phase**: Pilot NOT assigned to craft → deploys to ground combat
- **Choice Per Mission**: Reassign pilot before mission to switch roles

---

### Pilot Training

**Academy Facility** (Optional Enhancement):
- Pilots gain Piloting stat automatically through promotion
- Academy provides supplemental training (roleplay/flavor)
- Academy can enable specialist paths (Fighter training, Bomber training, etc.)

**Field Experience**:
- Interception missions grant XP automatically
- Real combat = fastest learning (flying actual missions)
- No training time required (happens naturally)

---

### Integration with Other Systems

**Craft System** (Crafts.md):
- Pilots assigned to craft determine craft performance
- Craft can only deploy if pilot assigned
- Pilot Piloting stat modifies craft stats

**Battlescape** (Battlescape.md):
- Pilots can deploy to ground if not assigned to craft
- Pilot class bonuses apply to ground combat (no special bonus)
- Pilots use standard unit combat rules

**Economy** (Economy.md):
- Pilot units have standard salary (like any unit)
- Pilot training (via Academy) has optional costs
- No premium for pilots

**Geoscape** (Geoscape.md):
- Pilots assigned to craft enable craft deployment
- Craft without pilot cannot deploy
- Pilot Piloting stat affects interception success

---

## Unit Health & Recovery

### Health Management

**Passive Recovery**:
- +0 HP per turn in battle (no passive healing)
- +1 HP per week in barracks
- +3 HP per week in Medical Facility

**Active Recovery**:
- Medikit use: 3 HP (Medic class) or 2 HP (other classes), 5 charges per kit
- Surgical facility: Instant full healing, costs 50K
- Stimulant injection: +1 HP, one-time use item

---

### HEALTH RECOVERY SYSTEM (B2)

#### Overview

Health Recovery is the **post-mission healing system** that determines how quickly damaged units return to combat readiness. The system uses facility capacity and healing tiers to control recovery speed.

#### Unit Capacity (Housing)

**Barracks Mechanics**:
- Units require barracks slot to stay in base (no slots = units must be sent away or dismissed)
- Barracks provide default recovery: **+1 HP/week** (standard recovery for all units)
- Capacity calculation: Base barracks slots determine max unit population

**Facility Dependency**:
- Unit cannot recover without assigned barracks slot
- All units in base consume one barracks slot
- Recovery occurs passively during base phase (between missions)

#### Healing Facility Types

| Facility | Capacity | Recovery Rate | Purpose |
|----------|----------|----------------|---------|
| **Barracks** | Unit storage | +1 HP/week | Default housing/recovery |
| **Clinic** | 3 healing slots | +3 HP/week | Basic medical facility |
| **Hospital** | 5 healing slots | +5 HP/week | Advanced medical facility |

**Key Design Points**:
- Barracks = unlimited capacity but slow recovery (+1 HP/week baseline)
- Clinics = limited healing slots (3) but faster recovery (+3 HP/week total)
- Hospitals = most healing slots (5) and fastest recovery (+5 HP/week total)
- Healing slots are the **limiting resource**, not unit slots

#### Recovery Examples

**Example 1: Light Damage (5 HP healed)**
```
Unit: 10 max HP, currently 5 HP (5 HP damage)

Option A (Barracks only):
  Recovery: 5 HP ÷ 1 HP/week = 5 weeks

Option B (Clinic available):
  Recovery: 5 HP ÷ 3 HP/week = ~2 weeks (if clinic slot available)

Option C (Hospital available):
  Recovery: 5 HP ÷ 5 HP/week = 1 week (if hospital slot available)
```

**Example 2: Heavy Damage (15 HP healed)**
```
Unit: 20 max HP, currently 5 HP (15 HP damage)

Option A (Barracks only):
  Recovery: 15 HP ÷ 1 HP/week = 15 weeks (3.5 months)

Option B (Clinic available):
  Recovery: 15 HP ÷ 3 HP/week = 5 weeks (if slot available)

Option C (Hospital available):
  Recovery: 15 HP ÷ 5 HP/week = 3 weeks (if slot available)
```

#### Recovery Priority System

**Healing Slot Allocation**:
- When multiple units need healing, priority follows:
  1. Highest rank units (veterans recover first)
  2. Most damaged units (worst health first)
  3. FIFO for tie-breakers

**Clinic Slot Scheduling**:
- Clinics have 3 healing slots available each week
- Assign units to slots manually or via priority system
- Unassigned damaged units recover in barracks (+1 HP/week only)

**Hospital Slot Scheduling**:
- Hospitals have 5 healing slots available each week
- Takes priority over clinic slots
- Assign units manually or via priority system

#### Recovery Facilities as Strategic Constraint

**Why This Matters**:
- Limited healing capacity forces tactical decisions about unit rotation
- Heavily damaged units tie up barracks/clinic/hospital slots
- Player must balance unit conservation vs. mission readiness
- Encourages careful unit management and damage mitigation

**Strategic Examples**:
- Minimize damage = faster recovery = more missions possible
- Heavy losses require weeks of recovery before next mission
- Hospital investment improves campaign flexibility
- Mission frequency limited by unit recovery needs

#### Unit Evacuation During Recovery

**Unneeded Units**:
- Damaged units not needed immediately can be sent away
- Frees up barracks slot and healing capacity
- Unit recovers off-base (faster IRL progression between campaigns)
- Recalled later when fully healed

**Stasis Pods** (Optional Equipment):
- Cryogenic storage for units mid-recovery
- Pauses recovery timer (unit neither heals nor degrades)
- Useful for bench units during active campaign phase
- Reactivation takes 1 week (unit wakes up)

---

### Wound System

Severe damage can cause **permanent wounds**:
- Critical hit while at <3 HP: Wound inflicted
- Wound reduces max HP by -1 permanently until healed surgically
- Multiple wounds can reduce a unit's max HP to dangerous levels
- Surgical facility can remove wounds (heals max HP): 300 credits per wound

### Death & Extraction

**Unit Death**:
- HP drops to 0 → Unit is incapacitated
- If unit is not evacuated within 3 turns, unit is **permanently lost**
- Enemy captures unit after 5 turns (prisoner status)

**Extraction**:
- Requires friendly unit to perform Rescue action (1 AP, move to incapacitated unit)
- Rescued unit is carried to extraction zone
- Extraction vehicle transports rescued units back to base

**Corpse Recovery**:
- Dead unit becomes a resource item (Corpse)
- Can be used in Resurrection protocols for significant cost
- Resurrection success rate: 60-80% (varies by facility quality)

---

## Unit Morale & Psychology

### Morale System

**Morale Overview**:
- Morale is the **in-battle psychological buffer** that affects unit action availability during combat
- Resets to baseline each mission (see Bravery stat for starting value)
- Simple threshold system - morale acts as a buffer pool with no accuracy impact

**Starting Morale**:
- Determined by Bravery stat: Base morale = Bravery value (typically 6-12)
- Same for all units at mission start regardless of previous battles
- Fresh start each mission (no carryover from previous engagement)

**Morale Thresholds & Effects** (Action Point Buffer Only):

| Morale | Status | Effect | Recovery |
|--------|--------|--------|----------|
| 9-12 | Confident | Normal actions (no penalty) | Normal |
| 6-8 | Steady | Normal actions (no penalty) | Normal |
| 4-5 | Strained | Normal actions (no penalty) | Rest action (2 AP) → +1 morale |
| 2-3 | Shaken | -1 AP per turn available | Rest action (3 AP) → +1 morale |
| 1 | Panicking | -2 AP per turn available | Rest + cover (next turn) → +1 morale |
| 0 | PANIC | Cannot act (action locked) | Requires safe cover + end turn → reset to 1 |

**Key Design Point**: Morale does NOT affect accuracy. Only action availability is reduced at low thresholds.

**Morale Loss Events**:
- Ally killed in sight: -1 morale
- Unit takes damage hit: -1 morale (per significant impact)
- Critical hit received: -2 morale
- Flanked for 1+ turns: -1 morale per turn in flank
- Outnumbered 3:1 or more: -1 morale per turn
- Squad leader dies: -2 morale (nearby units in 8-hex radius)

**Morale Recovery Options**:
- **Rest Action** (costs 2-3 AP): +1 morale (in-battle recovery)
- **Leader Aura** (passive): +1 morale/turn (leadership within 8-hex radius)
- **Leader Rally** (costs 4 AP): +2 morale to one specific unit
- **Safety/Cover** (no damage taken): +1 morale per turn in cover

**Morale System Design**:
- Simple thresholds (no continuous degradation)
- Action availability buffer (at 0 = completely locked down)
- Leadership matters (leader aura and rally actions provide recovery)
- Tactical recovery possible (cover, rest, regrouping all restore morale)
- Encourages squad tactics (units help each other stay effective)

---

### Sanity System

**Sanity Overview**:
- Sanity is the **long-term psychological state** tracked between missions
- Pre-mission lock: If sanity = 0 at mission start, unit cannot deploy
- Managed via hospital rest and recovery facilities
- Independent from morale (morale resets each mission, sanity is cumulative)
- Sanity does NOT affect in-battle accuracy or performance

**Sanity Degradation Events** (during missions):
- Witnessing alien transformation or spawning: -1 sanity
- Witnessing brutal unit death: -1 sanity
- Surviving critical near-death (reduced to 1 HP): -1 sanity
- Exposure to psychological horror (alien hive, dimensional rift, reality distortion): -1 sanity per turn exposed
- Killing civilians or friendly units: -1 sanity per incident

**Sanity Thresholds & Effects** (Deployment Only):

| Sanity | Status | Effect | Deployment |
|--------|--------|--------|-----------|
| 8-12 | Stable | No penalty | ✅ Can deploy |
| 5-7 | Stressed | No in-battle penalty | ✅ Can deploy |
| 2-4 | Fragile | No in-battle penalty | ✅ Can deploy |
| 1 | Critical | No in-battle penalty | ✅ Can deploy (risky) |
| 0 | Broken | Cannot participate | ❌ Cannot deploy |

**Key Design Point**: Sanity does NOT affect in-battle accuracy or performance. It only determines pre-mission deployment eligibility.

**Sanity Recovery Options** (between missions):
- **Hospital Rest** (facility): +1 sanity per week of rest in hospital
- **Psychological Counseling** (facility action): +2-3 sanity per session (100 credits)
- **Leave** (time off): +1 sanity per 2 weeks off-duty
- **Promotion**: +2 sanity upon rank advancement
- **Mission Success**: +1 sanity upon completing objective successfully (if sanity <8)

**Hospital Sanity Recovery Mechanics**:
- Unit must be assigned to hospital bed for recovery
- Hospitals have limited beds (3-5 depending on facility tier)
- Recovery rate: +1 sanity per week in bed (passive)
- Unit cannot participate in missions while in hospital recovery

**Sanity vs. Morale Distinction**:
- **Sanity** = Can unit deploy? (pre-mission check, between-mission system, persistent damage)
- **Morale** = How many actions does unit have? (in-battle only, resets each mission)
- Sanity has NO in-battle effects (purely deployment gate)
- Morale affects action point budget (at 0 = no actions)

**Example Scenario**:
```
Unit Status Over Campaign:
- Mission 1: Witnesses alien transformation → -1 sanity (now 11)
- Mission 2: Takes critical hit near death → -1 sanity (now 10)
- Mission 3: Sees ally brutalized → -1 sanity (now 9)
- Mission 4: Long exposure to hive environment → -1 sanity per turn (exposed 5 turns) = -5 sanity (now 4)
- Result: Unit at 4 sanity (Fragile status)
  - Still fights normally in missions (no accuracy loss, morale unaffected)
  - But requires healing before next mission
  - If sanity drops to 0: Unit locked out of deployment entirely
  - Recovery: Hospital bed +1 sanity/week or counseling for faster recovery
```

**Strategic Implication**:
- Players must rotate heavily-exposed units to prevent sanity breakdown
- Heavy missions (hive exposure, high horror environments) cause rapid sanity loss
- Recovery requires time/resources (hospital beds are limited, counseling is expensive)
- Sanity creates long-term campaign management pressure (similar to XCOM morale)
- Losing unit to sanity breakdown is different from death (unit still exists but unusable until recovered)

---

## Unit Customization & Individuality

### Face & Appearance System

**Character Customization**:
- Player-controlled units have **individualized appearances**
- Options for humans: 4 skin tones × 2 genders × 8 face variants = **64 unique face combinations**
- Each unit retains the same face throughout their career

**Visual Identity**:
- Armor color customization (cosmetic, no gameplay effect)
- Personal insignia/markings unlocked through medals
- Named units displayed with their custom name and rank insignia

**Future Expansions**:
- Alien race faces (Sectoid, Ethereal, Muton variants)
- Robot visual customization (chassis color, design variants)
- Cosmetic cosmetic customization slots (hats, scarves, emblems)

### Unit Naming

- Player assigns custom name at recruitment
- Names are displayed in combat HUD and base UI
- Unit nickname earned through medals/achievements

### Personal Statistics

Each unit tracks:
- Mission count (total battles participated)
- Enemy kills (cumulative)
- Damage dealt (cumulative)
- Damage taken (cumulative)
- Wounds received (total, some permanent)
- Commendations earned (medals, promotions)
- Squad assignment history
- Favorite weapon/equipment choice

---

## Unit Cost & Maintenance

### Recruitment Cost

| Unit Rank | Cost | Training Time | Availability |
|-----------|------|---------|------|
| **Rank 0 (Recruit)** | 500 credits | 1 week | Marketplace |
| **Rank 1 (Agent)** | 800 credits | Immediate | Marketplace |
| **Rank 2 (Specialist)** | 2,000 credits | 2 weeks | Specialist suppliers |
| **Rank 3 (Expert)** | 5,000 credits | 3 weeks | Elite suppliers |
| **Rank 4+ (Master)** | 10,000+ credits | 4 weeks | Rare/black market |

### Maintenance Cost

**Monthly Salary**:
- Base cost per unit per month: 200 credits
- Loyal trait: -50% salary (100 credits)
- High rank units: Higher salary (Rank 3+ = 300 credits, Rank 5+ = 500 credits)
- Mechanical units: -50% salary (electronics cheaper than food)

**Facility Costs**:
- Barracks (base cost): included in monthly upkeep
- Advanced barracks: +50 credits per unit per month (faster recovery)
- Medical facility: +100 credits per unit per month (passive healing available)

### Budget Impact

- Early game: 4-6 units × 200-300 credits = 800-1,800 credits/month maintenance
- Mid game: 12-16 units × average 300 credits = 3,600-4,800 credits/month
- Late game: 20+ units × 300-500 credits = 6,000-10,000+ credits/month

---

## Perks System

### Overview

Perks are behavioral modifications, training enhancements, and psychological conditioning that customize unit abilities beyond base class capabilities. Both soldiers and pilots can receive perks through training, events, or special circumstances. Perks represent specific tactical advantages or roleplay elements that make units feel unique and memorable.

### Perk Categories

Perks are organized into eight functional categories:

| **Category** | **Function** | **Examples** | **Typical Effect** |
|---|---|---|---|
| **Basic** | Foundational traits | "Well Trained", "Hardened" | +Stat bonuses, +morale |
| **Combat** | Weapon & accuracy | "Crack Shot", "Headshot Specialist" | +Damage, +accuracy in conditions |
| **Movement** | Mobility & positioning | "Fleet Footed", "Sprinter" | +Movement range, +speed |
| **Defense** | Protection & survival | "Iron Skin", "Bulletproof Intuition" | +Armor, +dodge, damage reduction |
| **Special** | Unique abilities | "Leader", "Medic" | Squad effects, healing abilities |
| **Resistance** | Status immunities | "Iron Lungs", "Toxin Resistant" | Immune/resistant to specific effects |
| **Skill** | Specialized knowledge | "Technician", "Scout" | Interact with objects, detect enemies |
| **Trait** | Personality/background | "Veteran", "Survivor" | Roleplay elements, narrative hooks |

### How Perks Work

#### Perk Assignment

- Perks are assigned to unit classes during recruitment
- Individual units can override defaults during squad setup
- Perks persist on unit even after equipping different gear
- Perks are tied to the unit, not the equipment

#### Perk Activation

- Perks are **always active** unless disabled by special event
- Some perks activate conditionally (e.g., "Ambush Expert" only in ambush missions)
- Combat perks check conditions before applying effect
- UI displays active perks on unit summary

#### Perk Stacking

- Multiple perks on same unit stack their effects
- Contradictory perks cancel each other (cannot have both "Brave" and "Coward")
- Same perk cannot be applied twice
- Perk combinations enable unique synergy builds

### Common Perk Reference

#### Basic Perks (General Training)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Well Trained | +10% accuracy, +1 AIM stat | Soldier, Officer |
| Hardened | +15% morale resistance | Soldier, Veteran |
| Alert | +1 REACTION stat, easier to spot ambush | Scout, Pilot |
| Steady Aim | +5% accuracy at range | Sniper, Sharpshooter |
| Quick Reflexes | +1 SPEED stat | Scout, Infiltrator |

#### Combat Perks (Offensive)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Crack Shot | +15% accuracy with rifles | Sharpshooter, Sniper |
| Headshot Specialist | +50% crit damage on headshots | Sniper, Assassin |
| Close Quarters Combat | +20% accuracy with melee, +1 damage | Assault, Berserker |
| Suppressive Fire | Enemies in target area suffer -20% accuracy | Heavy Weapons |
| Ricochet Shot | Bullets can pierce thin walls | Sniper, Marksman |

#### Movement Perks (Mobility)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Fleet Footed | +2 movement range | Scout, Infiltrator |
| Sprinter | +1 SPEED stat, can dash | Scout, Athlete |
| Acrobatics | No falling damage, +movement over obstacles | Scout, Infiltrator |
| Sneaker | +30% stealth when not moving | Infiltrator, Spy |
| Long Stride | Movement doesn't trigger overwatch | Scout, Ranger |

#### Defense Perks (Protection)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Iron Skin | +20% armor | Tank, Heavy Soldier |
| Bulletproof Intuition | 20% chance to dodge incoming shots | Veteran, Officer |
| Pain Suppression | Injuries don't reduce accuracy | Veteran, Soldier |
| Reinforced Armor | Additional armor layer (similar to Heavy Armor) | Tank, Juggernaut |
| Evasion Expert | +15% evasion stat | Scout, Infiltrator |

#### Special Perks (Squad Effects)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Leader | Squad accuracy +5%, morale +1 | Officer, Commander |
| Medic | Can heal allies (10 HP per action) | Support, Medical |
| Motivator | Nearby allies gain +1 morale | Officer, Sergeant |
| Discipline | Nearby allies resist panic (20% better) | Officer, Sergeant |
| Scout Master | Reveals hidden enemies in area | Scout, Intel Officer |

#### Resistance Perks (Status Immunity)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Iron Lungs | Immune to gas/poison | Support, Hazmat |
| Toxin Resistant | 50% damage reduction from poison | Engineer, Scientist |
| Cold Blooded | Immune to panic from alien presence | Veteran, Psychic |
| Thick Skull | +50% resistance to stun effects | Tank, Heavy Soldier |
| Disease Resistant | Immune to infection/mutation | Support, Medical |

#### Skill Perks (Specialized Knowledge)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Technician | Can hack computers, disable bombs | Engineer, Hacker |
| Lockpick | Can open locked doors/containers | Infiltrator, Spy |
| Medic Training | Can perform field surgery (+20 HP) | Support, Medical |
| Archaeologist | Can identify ancient artifacts | Scientist, Explorer |
| Linguist | Can communicate with aliens (reduces aggression) | Diplomat, Scientist |

#### Trait Perks (Personality & Background)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Survivor | +20% health, permanent aura of determination | Veteran |
| Coward | -15% morale, but flees danger faster | Conscript (negative trait) |
| Hothead | +20% damage when angry, +15% friendly fire risk | Assault |
| Brave | +20% accuracy, immune to fear | Officer, Hero |
| Humorous | +1 morale to squad through humor | Recruit, Support |

### Perk Combinations & Synergies

#### Combo Examples

| **Combo Name** | **Perks** | **Synergy Effect** | **Playstyle** |
|---|---|---|---|
| **Sharpshooter** | Crack Shot + Headshot Specialist + Steady Aim | +60% accuracy, +50% crit | Long-range sniper |
| **Assault Tank** | Close Quarters Combat + Iron Skin + Pain Suppression | Melee tank that doesn't care about damage | Frontline brawler |
| **Ghost Scout** | Fleet Footed + Sneaker + Acrobatics | Mobile infiltrator that moves silently | Hit-and-run tactician |
| **Squad Leader** | Leader + Motivator + Discipline | Command presence that buffs entire squad | Support commander |
| **Lone Wolf** | Survivor + Brave + Long Stride | Solo unit that excels when separated | Independent operator |

#### Stacking Rules

- **Stat bonuses stack additively** (Well Trained +10% AIM, Steady Aim +5% = +15%)
- **Percentage effects can stack** but with diminishing returns
- **Conditional perks don't conflict** if conditions don't overlap
- **Contradictory perks cancel** (Brave vs Coward, Leader vs Loner)

### Perk Unlocking & Progression

#### How Units Gain Perks

1. **Class Default**: Assigned on recruitment (Soldier gets "Well Trained", Sniper gets "Crack Shot")
2. **Achievement**: Earn through in-game actions
   - Get 10 kills = unlock "Veteran"
   - Land headshots = unlock "Headshot Specialist"
   - Survive critical hit = unlock "Bulletproof Intuition"
3. **Research**: Unlock through research projects
   - Research "Advanced Combat Training" = unlock "Suppressive Fire"
4. **Event**: Special story events or random moments
   - Surviving alien terror attack = unlock "Cold Blooded"

#### Perk Rarity Tiers (Optional)

| **Tier** | **Frequency** | **Impact** | **Examples** |
|---|---|---|---|
| **Common** | Every soldier has | +5-10% to stats | Well Trained, Alert |
| **Uncommon** | ~50% of soldiers | +10-20% or situational | Crack Shot, Sneaker |
| **Rare** | ~20% of soldiers | +20-30% or powerful effect | Headshot Specialist, Leader |
| **Legendary** | <5% of soldiers | Major gameplay change | Survivor, Cold Blooded |

### Perks in UI

#### Squad Setup Screen

- Unit card displays active perks as icons
- Hover over perk icon = tooltip with description
- Option to disable/enable perk if conflicts exist
- Perk counts affect unit rating/reliability

#### Unit Summary

- Perk list shows all perks and active status
- Green = active, Red = disabled/conflicting
- Statistics panel shows how perks modify base stats
- History section tracks perk unlock events

### Perk Design Philosophy

The Perk system serves multiple strategic and narrative purposes:

1. **Customization & Identity**: Perks enable unique builds and let players create memorable unit personas
2. **Progression Rewards**: Perk unlocks provide long-term goals and reward player investment
3. **Tactical Depth**: Perk combinations create synergies and force build decisions
4. **Balance Tool**: Perks allow granular difficulty adjustment per unit without direct stat changes
5. **Narrative Hooks**: Perks represent unit history, personality, and special backgrounds
6. **Roleplay Support**: Perks enable player storytelling ("My Brave Sniper who survived 50 missions")
7. **Asymmetric Strength**: Perks allow specialist units to excel in specific roles without breaking general balance

---

## Examples

### Scenario 1: Rookie Squad Assembly
**Setup**: Player starts campaign with 4 Rank 0 recruits and limited budget
**Action**: Recruit basic soldiers, assign roles, equip with starter weapons
**Result**: Mixed squad with rifleman, grenadier, medic, sniper roles; balanced but inexperienced

### Scenario 2: Veteran Unit Progression
**Setup**: Unit survives 20 missions, reaches Rank 3 with specialization
**Action**: Choose between Marksman or Sharpshooter path, unlock relevant perks
**Result**: Elite specialist with unique abilities, significantly stronger than new recruits

### Scenario 3: Pilot Training Program
**Setup**: Player researches pilot training facility, recruits potential pilots
**Action**: Assign recruits to pilot training, monitor progress through missions
**Result**: Qualified pilots available for craft operation, enabling interception capabilities

### Scenario 4: Unit Loss Recovery
**Setup**: Veteran unit killed in difficult mission, squad composition disrupted
**Action**: Recruit replacement, train through missions, rebuild squad synergy
**Result**: New unit eventually reaches veteran's level, but with different trait/perk combinations

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Base Recruitment Cost | 500 credits | 200-1000 | Entry barrier for new units | ×0.8 on Easy |
| Rank XP Requirements | 100-2100 | 50-3000 | Progression pacing | ×0.7 on Easy |
| Max Squad Size | 8 units | 4-12 | Tactical complexity limit | No scaling |
| Trait Frequency | 70% common | 50-90% | Unit individuality | +10% on Hard |
| Perk Unlock Rate | 15% per level | 10-25% | Specialization rewards | ×1.5 on Impossible |
| Maintenance Cost | 50 credits/month | 25-100 | Resource management | ×0.5 on Easy |
| Pilot Training Time | 30 days | 15-60 | Strategic investment | ×0.75 on Easy |

---

## Difficulty Scaling

### Easy Mode
- Recruitment costs: 20% reduction
- XP requirements: 30% reduction (faster progression)
- Trait frequency: +10% (more interesting units)
- Maintenance costs: 50% reduction
- Pilot training: 50% faster

### Normal Mode
- All parameters at standard values
- Balanced progression and resource management
- Standard trait distribution and costs

### Hard Mode
- Recruitment costs: +25% increase
- XP requirements: +20% increase (slower progression)
- Maintenance costs: +50% increase
- Unit loss impact: More severe consequences
- Pilot training: +25% longer

### Impossible Mode
- Recruitment costs: +50% increase
- XP requirements: +50% increase (much slower progression)
- Maintenance costs: +100% increase
- Trait frequency: -20% (fewer interesting units)
- Perk unlocks: 50% reduction
- Pilot training: +100% longer

---

## Testing Scenarios

- [ ] **Unit Progression**: Verify XP requirements and rank advancement work correctly
  - **Setup**: Create unit at Rank 0, complete missions with XP rewards
  - **Action**: Accumulate XP through combat and objectives
  - **Expected**: Unit advances through ranks at correct XP thresholds
  - **Verify**: Check rank progression and ability unlocks

- [ ] **Trait Distribution**: Test that unit traits appear at expected frequencies
  - **Setup**: Generate 100 new units with random traits
  - **Action**: Analyze trait distribution across population
  - **Expected**: Common traits ~70%, Uncommon ~20%, Rare ~8%, Legendary ~2%
  - **Verify**: Statistical analysis of trait frequency

- [ ] **Perk System**: Validate perk unlocks and effects function properly
  - **Setup**: Unit with multiple perks unlocked
  - **Action**: Activate perks in combat scenarios
  - **Expected**: Perk effects apply correctly to stats and abilities
  - **Verify**: Combat results with and without perk activation

- [ ] **Pilot Training**: Test pilot qualification and craft operation
  - **Setup**: Recruit unit for pilot training
  - **Action**: Complete training program and assign to craft
  - **Expected**: Pilot gains craft operation abilities and bonuses
  - **Verify**: Successful interception and craft performance

- [ ] **Resource Management**: Verify maintenance costs and budget impact
  - **Setup**: Squad of 8 units with varying ranks
  - **Action**: Calculate monthly maintenance costs
  - **Expected**: Costs scale appropriately with unit count and rank
  - **Verify**: Budget calculations and resource allocation

---

## Related Features

- **[Battlescape System]**: Unit combat mechanics and tactical deployment (Battlescape.md)
- **[Items System]**: Equipment and weapon assignments (Items.md)
- **[Crafts System]**: Pilot assignments and vehicle operation (Crafts.md)
- **[Pilots System]**: Specialized pilot training and abilities (Pilots.md)
- **[Economy System]**: Recruitment costs and maintenance expenses (Economy.md)
- **[Morale System]**: Unit psychology and combat effectiveness (MoraleBraverySanity.md)

---

## Implementation Notes

**Priority Systems**:
1. Core unit statistics and combat integration
2. Experience and rank progression
3. Trait and perk systems
4. Pilot specialization
5. Recruitment and maintenance costs

**Balance Considerations**:
- Unit progression should feel rewarding but not overwhelming
- Trait distribution creates interesting variety without frustration
- Maintenance costs encourage strategic squad sizing
- Pilot system provides meaningful specialization path
- Perk combinations enable unique playstyles

**Testing Focus**:
- XP progression curves and rank advancement
- Trait frequency distribution
- Perk effect calculations
- Pilot training mechanics
- Resource cost calculations

---

## Alien Unit Stat Scaling System

**Overview**
Alien units use a **different stat scale than humans** to represent their otherworldly nature and varying threat levels. While human units operate on a 6-12 scale for most stats, alien units use higher base values that are then scaled by difficulty and campaign progression. This creates dynamic threat escalation while maintaining balance against human units.

**Alien Stat Scale Decision**
- **Different Scale from Humans**: Aliens use higher base stats (50-110 range) to represent their alien nature
- **Rationale**: Allows for meaningful scaling multipliers, represents alien superiority, maintains balance through scaling
- **Alternative Considered**: Same 6-12 scale but rejected for insufficient scaling range

**Base Alien Stats (Human Equivalent)**

| Alien Type | Health | Accuracy | Reactions | Strength | Armor | Psionic | Classification | Human Equivalent |
|------------|--------|----------|-----------|----------|--------|---------|----------------|------------------|
| **Sectoid** | 60 | 50 | 55 | 6 | 20 | 8 | Weak individual, dangerous in groups | Rank 1-2 Human (green recruit) |
| **Floater** | 75 | 65 | 70 | 7 | 35 | 0 | Mobile medium threat, flight advantage | Rank 2-3 Human (trained soldier) |
| **Muton** | 110 | 70 | 65 | 11 | 60 | 0 | Strong frontline, melee focus | Rank 4-5 Human (veteran/elite) |
| **Chryssalid** | 95 | 55 | 85 | 10 | 50 | 0 | Extreme melee threat, very fast | Rank 5-6 Human (specialist/dangerous) |
| **Ethereal** | 85 | 75 | 80 | 9 | 45 | 12 | Leader class, expert psionics | Rank 6 Human (expert level) |

**Stat Scaling Formula**
```
Final Stat = Base Stat × Difficulty Multiplier × Campaign Multiplier
```

**Difficulty Multipliers**

| Difficulty | Multiplier | Description |
|------------|------------|-------------|
| **Normal** | 1.0× | Standard alien threat |
| **Classic** | 1.1× | +10% stronger aliens |
| **Impossible** | 1.3× | +30% stronger aliens (extreme challenge) |

**Campaign Progression Multipliers**

| Campaign Month | Multiplier | Description |
|----------------|------------|-------------|
| **Months 1-2** | 0.9× | Early game: Slightly weakened aliens |
| **Months 3-6** | 1.0× | Mid game: Standard alien strength |
| **Months 7-10** | 1.1× | Late game: +10% stronger aliens |
| **Months 11-12** | 1.2× | End game: +20% stronger aliens |

**Combined Scaling Examples**

**Muton on Normal Difficulty, Month 6:**
- Base: Health 110, Accuracy 70, Reactions 65, Strength 11
- Difficulty: 1.0×, Campaign: 1.0×, Total: 1.0×
- Final: Health 110, Accuracy 70, Reactions 65, Strength 11

**Muton on Impossible Difficulty, Month 12:**
- Base: Health 110, Accuracy 70, Reactions 65, Strength 11
- Difficulty: 1.3×, Campaign: 1.2×, Total: 1.56×
- Final: Health 171, Accuracy 109, Reactions 101, Strength 17

**Alien Ability Effectiveness**

**Psionic Attack (Ethereal):**
- Base success rate: 40%
- Increases: +2% per Psionic point
- Ethereal (Psionic 12): 40% + 24% = 64% base success rate
- On Impossible Month 12: 64% × 1.56 = ~100% success rate

**Melee Attack (Chryssalid/Muton):**
- Base damage: 50% of Strength × 5
- Chryssalid (Strength 10): 50% × 10 × 5 = 25 damage
- With equipment bonuses: +50% = 37.5 damage
- Human armor 50: Reduces/nullifies damage

**Coordinated Fire:**
- Aliens in group: +10% accuracy per additional alien
- Group of 3: +20% total accuracy bonus
- Encourages player to break up alien formations

**Mission Composition Scaling**

**Early Mission (Month 1, Normal):**
- 2 Sectoids (weak, numbers advantage)
- Player equivalent: Rank 2-3 humans
- Challenge: Learning alien behavior

**Mid Mission (Month 6, Normal):**
- 1 Muton + 2 Floaters + 1 Sectoid
- Player equivalent: Rank 3-4 humans
- Challenge: Mixed threats, Muton frontline

**Late Mission (Month 12, Normal):**
- 1 Ethereal + 2 Mutons + 1 Chryssalid
- Player equivalent: Rank 5-6 humans
- Challenge: Extreme combined threats

**Implementation Notes**
- Stat multipliers apply to: Health, Accuracy, Reactions, Strength, Armor, Psionic
- Do NOT apply to: Special abilities, morale/sanity (aliens don't have these)
- Campaign progression is global (all aliens scale together)
- Difficulty multiplier applies per mission when loaded
- Aliens can exceed human stat caps on higher difficulties

**Balance Testing Scenarios**

- [ ] **Early Sectoid Encounter**: Normal, Month 1
  - Sectoid: Health 54, Accuracy 45, Reactions 50
  - Expected: Training mission, easily winnable

- [ ] **Mid Muton Encounter**: Normal, Month 6
  - Muton: Health 110, Accuracy 70, Reactions 65, Strength 11
  - Expected: Challenging, requires veteran squad

- [ ] **Late Ethereal Encounter**: Normal, Month 12
  - Ethereal: Health 102, Accuracy 90, Reactions 96, Psionic 14
  - Expected: Extreme threat, psionic control risk

- [ ] **Impossible Muton**: Impossible, Month 6
  - Muton: Health 143, Accuracy 91, Reactions 84, Strength 14
  - Expected: Very dangerous, exceeds human accuracy cap

- [ ] **Impossible Endgame Ethereal**: Impossible, Month 12
  - Ethereal: Health 132, Accuracy 117, Reactions 125, Psionic 19
  - Expected: GODLIKE threat, nearly unkillable

---

## Review Checklist

- [ ] Unit classification system clearly defined
- [ ] Rank progression requirements specified
- [ ] Trait and perk systems documented
- [ ] Pilot specialization mechanics detailed
- [ ] Balance parameters quantified with reasoning
- [ ] Difficulty scaling implemented
- [ ] Testing scenarios comprehensive
- [ ] Related systems properly linked
- [ ] No undefined terminology
- [ ] Implementation feasible

---

## Design Philosophy

The Unit system emphasizes:

1. **Permanent Consequences**: Unit death is meaningful; loss impacts squad composition
2. **Strategic Growth**: Progression through ranked classes creates investment
3. **Customization**: Traits, equipment, and specialization paths allow unique builds
4. **Psychological Depth**: Morale and sanity add narrative weight to combat
5. **Resource Management**: Salary and maintenance balance unit acquisition vs. operational cost
6. **Individuality**: Named, customized units create roleplay and emotional attachment
7. **Specialized Roles**: Pilots and perks enable unique unit identities beyond class designation
8. **Long-term Development**: Progression systems reward keeping veteran units alive and trained

This system rewards careful squad composition, tactical positioning, and long-term planning while maintaining the high-stakes, consequences-matter feel of tactical strategy games. Pilots represent permanent strategic assets, while perks allow deep customization and create memorable unit personalities.
