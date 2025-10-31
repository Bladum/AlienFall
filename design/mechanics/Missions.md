# Mission System Design Specification

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: AI.md, Geoscape.md, Countries.md, Battlescape.md, Interception.md
> **Source Note**: This file consolidates mission information from AI.md (Mission Generation), Geoscape.md (Mission Detection), Countries.md (Country Events & Missions), and BlackMarket.md (Custom Missions)

## Table of Contents

- [Overview](#overview)
- [Mission Generation System](#mission-generation-system)
- [Mission Types & Objectives](#mission-types--objectives)
- [Mission Rewards & Consequences](#mission-rewards--consequences)
- [Special Mission Types](#special-mission-types)
- [Integration with Other Systems](#integration-with-other-systems)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

---

## Overview

### System Architecture

Missions are the primary tactical engagement layer in AlienFall, bridging strategic decisions (Geoscape) with tactical execution (Battlescape). The mission system generates procedural combat scenarios based on faction activity, player actions, country relations, and campaign progression. Each mission type has distinct objectives, rewards, and strategic consequences.

**Design Philosophy**

Missions create meaningful strategic decisions through varied objectives, scaling difficulty, and cascading consequences. The procedural generation system ensures replay variety while maintaining balanced challenge progression. Mission outcomes affect diplomatic relations, faction standing, resource acquisition, and campaign escalation.

**Core Principle**: Missions are the feedback loop between strategic planning and tactical execution.

**Capacity Reference**: Squad size and deployment logistics defined in CRAFT_CAPACITY_MODEL.md

---

## Mission Generation System

### Generation Framework

**Source Reference**: AI.md §Mission Generation AI

Missions are procedurally generated based on faction state and escalation meter. The generation system operates on monthly cycles with dynamic triggers responding to player actions and campaign state.

#### Mission Generation Triggers

| Trigger Type | Frequency | Source | Parameters |
|--------------|-----------|--------|------------|
| **Faction Activity** | 2-5 per month | Alien factions | Based on escalation level |
| **Country Request** | 1-3 per month | Allied countries | Based on relations and panic |
| **Random Events** | 0-2 per month | Campaign system | Based on RNG and threat level |
| **Player Actions** | Variable | Geoscape decisions | Craft interceptions, base raids |
| **Black Market** | On purchase | Player-initiated | Purchased custom missions |
| **Escalation Events** | Milestone-based | Campaign progression | UFO armada, alien base assault |

#### Generation Algorithm

**Source Reference**: AI.md §Mission Framework

```
Mission Generation Process:
1. Select Mission Type → Based on faction goals and player threat level
2. Determine Difficulty → Campaign month × 0.2 + Player bases × 0.15 + Avg unit level × 0.1
3. Select Location → Province based on faction presence and player radar coverage
4. Generate Composition → Enemy squad count and unit types based on difficulty
5. Set Rewards → Credits, salvage, and diplomatic effects
6. Add to Mission Pool → Available for player interception
```

### Mission Types by Source

#### Alien Faction Missions

**Source Reference**: AI.md §Faction AI System

| Mission Type | Trigger | Composition | Strategic Impact |
|--------------|---------|-------------|------------------|
| **UFO Crash** | Craft interception success | UFO + 6-12 aliens | +1000 credits, salvage |
| **UFO Landing** | Unintercepted UFO | UFO + 10-15 aliens | +500 credits, research samples |
| **Alien Base Attack** | Faction escalation | Alien base + garrison (20-40 units) | +2000 credits, strategic value |
| **Terror Mission** | Panic escalation | Aliens + civilians (15-25 aliens) | +1500 credits, country favor |
| **Abduction Site** | Random event | Aliens + captives (8-12 aliens) | +800 credits, rescued units |
| **Supply Raid** | Low player resources | Aliens vs storage (10-15 aliens) | +300 credits + loot |

#### Country-Generated Missions

**Source Reference**: Countries.md §Country Events & Missions

| Mission Type | Relations Required | Frequency | Purpose |
|--------------|-------------------|-----------|---------|
| **Base Defense** | Any | Random (threat-based) | Defend player base from attack |
| **Colony Defense** | +25 or higher | 1-2 per month | Protect civilian settlements |
| **Escort Mission** | +50 or higher | 0-1 per month | Protect VIP or convoy |
| **Research Facility** | +40 or higher | Rare | Secure alien research site |
| **Diplomatic Mission** | +75 or higher | Rare | Special diplomatic operations |

#### Black Market Missions

**Source Reference**: BlackMarket.md §Mission Generation

Purchased missions spawning within 3-7 days in target region:

| Mission Type | Cost | Karma Impact | Rewards |
|--------------|------|--------------|---------|
| **Assassination Contract** | 50,000 | -30 | 120,000 credits, unique weapon |
| **Sabotage Operation** | 40,000 | -20 | 100,000 credits, intel |
| **Heist Mission** | 30,000 | -15 | 80,000 credits, rare items |
| **Kidnapping** | 35,000 | -25 | 90,000 credits, prisoner |
| **False Flag Attack** | 60,000 | -40 | 150,000 credits, faction blame |
| **Data Theft** | 25,000 | -10 | 60,000 credits, research bonus |
| **Smuggling Run** | 20,000 | -5 | 50,000 credits, items |

---

## Mission Types

### Standard Mission Types

#### 1. UFO Crash Mission

**Generation**: Player successfully intercepts UFO via craft combat

**Map**: Crash site with UFO wreckage, scattered debris, potential fire/smoke

**Objectives**:
- Primary: Eliminate all aliens OR secure UFO wreckage
- Secondary: Recover alien technology intact
- Bonus: No civilian casualties (if crash in populated area)

**Enemy Composition**: 50% of original UFO crew (6-12 aliens)
- 40% Grunts, 35% Warriors, 20% Specialists, 5% Heavy

**Rewards**:
- Base: 1000 credits
- Salvage: UFO components, alien weapons, corpses
- Research: Alien tech samples (varies by UFO type)

**Failure Consequences**: UFO wreckage secured by aliens, -5 relations with country

---

#### 2. UFO Interception Mission

**Generation**: Player craft encounters UFO during patrol or deployment

**Map**: Aerial combat zone (see Interception.md for full mechanics)

**Objectives**:
- Primary: Destroy or disable UFO
- Secondary: Prevent UFO escape

**Enemy Composition**: 1 UFO with variable weapons

**Rewards**:
- Base: 500 credits
- Bounty: +200 credits per UFO size tier
- Follow-up: If UFO crashes, generates UFO Crash Mission

**Failure Consequences**: UFO escapes, continues mission objective (may attack base or country)

---

#### 3. Alien Base Attack

**Generation**: Faction escalation threshold reached, player discovers alien base location

**Map**: Large facility map with multiple rooms, defensive positions, command center

**Objectives**:
- Primary: Destroy alien base command center
- Secondary: Eliminate all alien defenders
- Bonus: Capture alien commander alive

**Enemy Composition**: Garrison force (20-40 aliens)
- 30% Grunts, 40% Warriors, 20% Specialists, 10% Heavy + Commander

**Rewards**:
- Base: 2000 credits
- Strategic: Faction loses base, -10 faction escalation points
- Salvage: Major alien technology cache
- Research: Advanced alien research samples

**Failure Consequences**: -20 relations with country, alien base remains operational

---

#### 4. Terror Mission

**Generation**: Country panic level exceeds threshold, faction terror strategy

**Map**: Urban environment with civilians, destructible buildings

**Objectives**:
- Primary: Eliminate all aliens
- Secondary: Save at least 50% of civilians
- Bonus: Save 80%+ civilians

**Enemy Composition**: Terror squad (15-25 aliens)
- 20% Grunts, 30% Warriors, 40% Terror units, 10% Specialists

**Neutral Units**: 10-20 civilians (non-combatants)

**Rewards**:
- Base: 1500 credits
- Diplomatic: +10 to +30 relations with country (based on civilian survival)
- Fame: +5 to +15 (based on performance)

**Failure Consequences**: -30 relations, +20 panic, country may withdraw funding

---

#### 5. Base Defense Mission

**Generation**: Random event, alien retaliation, escalation milestone

**Map**: Player's base layout (exact facility configuration)

**Objectives**:
- Primary: Eliminate all aliens
- Secondary: Protect base facilities (prevent destruction)
- Critical: Protect base command center

**Enemy Composition**: Assault force (variable, 20-50 aliens based on base size)

**Special Rules**:
- Player units deploy from barracks/hangars
- Base turrets participate as defensive units (see Basescape.md §Base Defense)
- Facility staff (neutral units) may assist if armed
- Facility destruction has permanent consequences

**Rewards**:
- Base: 800 credits
- Survival: Retain base operations
- Salvage: Alien equipment

**Failure Consequences**: Base destroyed, lose all facilities, -50K credits rebuild cost, 90 day rebuild time

---

#### 6. Colony Defense Mission

**Generation**: Country request, faction attack on civilian settlement

**Map**: Settlement with buildings, civilians, defensive positions

**Objectives**:
- Primary: Eliminate all aliens
- Secondary: Save colony command center
- Bonus: Zero civilian casualties

**Enemy Composition**: Raid force (12-20 aliens)

**Neutral Units**: 15-30 civilians, 3-5 militia (armed neutrals)

**Rewards**:
- Base: 1200 credits
- Diplomatic: +15 relations with country
- Country bonus: +1 funding level for 2 months

**Failure Consequences**: -20 relations, colony destroyed, -10 country morale

---

#### 7. Research Facility Mission

**Generation**: Random event, alien intelligence gathering

**Map**: Scientific facility with labs, containment areas

**Objectives**:
- Primary: Secure research data
- Secondary: Eliminate all aliens
- Bonus: Rescue scientists

**Enemy Composition**: Infiltration squad (8-15 aliens)
- 50% Specialists (stealth), 30% Warriors, 20% Grunts

**Neutral Units**: 5-10 scientists (non-combatant)

**Rewards**:
- Base: 500 credits
- Research: +50 man-days to current project
- Tech: Exclusive research samples

**Failure Consequences**: Research data lost, -10 relations

---

#### 8. Supply Raid Mission

**Generation**: Low player resources trigger, opportunistic alien attack

**Map**: Storage facility or supply depot

**Objectives**:
- Primary: Defend supplies
- Secondary: Eliminate all aliens

**Enemy Composition**: Raiding party (10-15 aliens)

**Rewards**:
- Base: 300 credits
- Loot: Items, ammunition, equipment

**Failure Consequences**: Lose stored items, -500 credits value

---

### Special Mission Types

#### Assassination Contract (Black Market)

**Source Reference**: BlackMarket.md §Mission Generation

**Map**: Urban or facility environment with target location

**Objectives**:
- Primary: Eliminate specific target
- Secondary: No witnesses
- Bonus: Make it look like accident

**Rewards**: 120,000 credits, unique weapon, -10 relations if traced

---

#### Sabotage Operation (Black Market)

**Map**: Industrial or military facility

**Objectives**:
- Primary: Destroy target infrastructure
- Secondary: No alarm raised
- Bonus: Frame another faction

**Rewards**: 100,000 credits, intel, -20 relations if discovered

---

#### Escort Mission (Country Request)

**Map**: Route with multiple waypoints

**Objectives**:
- Primary: Protect VIP to destination
- Secondary: Zero VIP damage

**Enemy Composition**: Ambush forces at waypoints

**Rewards**: +20 relations, 1500 credits

---

## Examples

### Scenario 1: UFO Crash Recovery
**Setup**: Player intercepts UFO over urban area, it crashes in city outskirts
**Action**: Player deploys squad to crash site, eliminates alien survivors while avoiding civilian casualties
**Result**: Mission success with +1000 credits, alien tech samples, +5 relations for protecting civilians

### Scenario 2: Terror Mission Gone Wrong
**Setup**: Aliens attack city center with civilians present
**Action**: Player squad engages aliens but fails to save most civilians due to aggressive tactics
**Result**: Partial success with +750 credits (50% of base), -10 relations, increased country panic

### Scenario 3: Base Defense Success
**Setup**: Aliens launch assault on player base during low radar coverage
**Action**: Player units deploy from facilities, coordinate with base turrets to repel attack
**Result**: Complete defense with +800 credits, base intact, alien salvage for research

### Scenario 4: Black Market Assassination
**Setup**: Purchased contract to eliminate alien commander in urban environment
**Action**: Squad infiltrates at night, eliminates target quietly without witnesses
**Result**: Success with 120,000 credits, unique weapon reward, neutral karma impact

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Base Mission Frequency | 3-5 per month | 1-8 | Provides steady challenge without overwhelming | +1 per difficulty level |
| UFO Crash Reward | 1000 credits | 500-2000 | Rewards interception success | ×1.5 on Hard |
| Terror Mission Relations | +10 to +30 | 0-50 | Civilian protection matters | ×2 on Impossible |
| Base Defense Cost | 800 credits | 300-1500 | Compensates for facility risk | ×1.25 on Hard |
| Black Market Karma | -10 to -40 | -50 to 0 | Moral choices have consequences | No scaling |
| Difficulty Multiplier | 1.0 base | 0.5-2.0 | Campaign progression scaling | +0.2 per month |
| Salvage Value | 50% market | 25-75% | Equipment recovery incentive | +10% on Easy |
| Base Mission XP | 50 XP | 30-80 | Unit progression incentive | ×1.5 on Hard |

### XP Rewards

**Source Reference**: XP_PROGRESSION_SPECIFICATION.md §Mission XP Rewards

Mission completion grants XP to all participating units based on performance, difficulty, and mission type. XP rewards follow the formula:

```
Base XP = 50
+ Performance Bonus (0-50 XP based on objectives completed)
+ Difficulty Multiplier (0.6x - 1.8x based on mission difficulty)
+ Mission Type Modifier (varies by mission type)

Total XP = Base XP × Difficulty Multiplier × Mission Type Modifier + Performance Bonus
```

**XP Reward Parameters**:
- **Base XP**: 50 XP (standard mission completion)
- **Performance Bonus**: 0-50 XP based on secondary objectives and completion time
- **Difficulty Scaling**: 0.6x (Easy) to 1.8x (Impossible)
- **Mission Type Modifiers**: UFO Crash (1.0x), Terror (1.2x), Base Defense (1.5x), Alien Base (2.0x)

**Example Calculations**:
- Easy UFO Crash (all objectives): 50 × 0.6 × 1.0 + 30 = 60 XP
- Hard Terror Mission (partial success): 50 × 1.2 × 1.2 + 15 = 102 XP
- Impossible Alien Base (full success): 50 × 1.8 × 2.0 + 50 = 230 XP

---

## Difficulty Scaling

### Easy Mode
- Mission frequency: 2-3 per month
- Enemy squad size: 75% of normal
- Rewards: ×1.25 (easier missions more lucrative)
- XP rewards: ×0.6 (reduced progression pressure)
- Failure penalties: 50% reduction
- Black market availability: Limited options

### Normal Mode
- Mission frequency: 3-5 per month
- Enemy squad size: 100% of normal
- Rewards: Standard values from balance parameters
- XP rewards: Standard values (balanced progression)
- Failure penalties: Full impact
- Black market availability: Standard options

### Hard Mode
- Mission frequency: 4-6 per month
- Enemy squad size: 125% of normal
- Rewards: ×0.8 (harder missions less rewarding)
- XP rewards: ×1.2 (accelerated progression for challenge)
- Failure penalties: ×1.5 increased impact
- Black market availability: Expanded dangerous options

### Impossible Mode
- Mission frequency: 5-8 per month
- Enemy squad size: 150% of normal
- Rewards: ×0.6 (maximum challenge, minimal reward)
- XP rewards: ×1.8 (maximum progression pressure)
- Failure penalties: ×2.0 devastating impact
- Black market availability: All options including extreme contracts

---

## Testing Scenarios

- [ ] **Mission Generation Distribution**: Generate 100 missions and verify type distribution matches expected frequencies
  - **Setup**: Run mission generation algorithm with standard parameters
  - **Action**: Generate missions over multiple campaign months
  - **Expected**: UFO missions 40%, Terror 20%, Base Defense 15%, others proportional
  - **Verify**: Count mission types in generated pool

- [ ] **Difficulty Scaling**: Test that mission difficulty increases with campaign progression
  - **Setup**: Start campaign at month 1, advance to month 12
  - **Action**: Generate missions at each month milestone
  - **Expected**: Enemy count increases by ~2.4x, rewards increase by ~1.8x
  - **Verify**: Compare mission parameters across months

- [ ] **Reward Calculation**: Verify reward formula produces expected values
  - **Setup**: Complete mission with known parameters (2 secondary objectives, fast completion)
  - **Action**: Calculate total reward using formula
  - **Expected**: Base × (1 + 0.2 + 0.2) + salvage = correct total
  - **Verify**: Compare calculated vs. actual reward values

- [ ] **XP Reward Calculation**: Verify XP formula produces expected progression values
  - **Setup**: Complete mission with known parameters (Hard difficulty, Terror mission, 3 objectives completed)
  - **Action**: Calculate XP using formula: 50 × 1.2 × 1.2 + 30 = 102 XP
  - **Expected**: Units gain 102 XP each, progressing toward rank advancement
  - **Verify**: Check unit XP totals and rank progression after mission completion

- [ ] **Diplomatic Impact**: Test that mission outcomes affect country relations
  - **Setup**: Mission in country with neutral relations
  - **Action**: Complete terror mission with 80% civilian survival
  - **Expected**: +24 relations increase
  - **Verify**: Check country relations after mission completion

- [ ] **Black Market Integration**: Verify purchased missions spawn correctly
  - **Setup**: Purchase assassination contract for 50,000 credits
  - **Action**: Wait for mission spawn timer (3-7 days)
  - **Expected**: Mission appears in target region with correct objectives
  - **Verify**: Mission parameters match contract specifications

---

## Related Features

- **[AI System]**: Mission generation algorithms and enemy composition (AI.md)
- **[Geoscape System]**: Mission detection and craft deployment (Geoscape.md)
- **[Battlescape System]**: Tactical combat and map generation (Battlescape.md)
- **[Countries System]**: Diplomatic relations and country-specific missions (Countries.md)
- **[Black Market System]**: Purchased custom missions (BlackMarket.md)
- **[Economy System]**: Salvage processing and research unlocks (Economy.md)
- **[XP Progression System]**: Unit advancement and mission XP rewards (XP_PROGRESSION_SPECIFICATION.md)

---

## Implementation Notes

**Priority Systems**:
1. Core mission types (UFO Crash, Base Defense, Terror)
2. Mission generation algorithm
3. XP reward calculation (unit progression)
4. Difficulty scaling
5. Reward calculation
6. Special mission types (Black Market, Escort)

**Balance Considerations**:
- Mission frequency should match player capability
- XP rewards should enable steady unit progression without grind
- Difficulty progression should feel fair
- Rewards should incentivize engagement
- Failure should be recoverable, not campaign-ending

**Testing Focus**:
- Mission generation distribution
- XP reward calculation and unit progression
- Difficulty scaling curve
- Reward vs. effort balance
- Diplomatic consequence impact

---

## Review Checklist

- [ ] System architecture clearly defined
- [ ] All core mechanics documented with examples
- [ ] Balance parameters specified with reasoning
- [ ] Difficulty scaling implemented
- [ ] Testing scenarios comprehensive
- [ ] Edge cases addressed
- [ ] Related systems properly linked
- [ ] No undefined terminology
- [ ] Implementation feasible
