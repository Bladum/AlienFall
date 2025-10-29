# Mission System

> **Status**: Design Document  
> **Last Updated**: 2025-10-28  
> **Related Systems**: AI.md, Geoscape.md, Countries.md, Battlescape.md, Interception.md  
> **Source Note**: This file consolidates mission information from AI.md (Mission Generation), Geoscape.md (Mission Detection), Countries.md (Country Events & Missions), and BlackMarket.md (Custom Missions)

## Table of Contents

- [Overview](#overview)
- [Mission Generation System](#mission-generation-system)
- [Mission Types](#mission-types)
- [Mission Objectives](#mission-objectives)
- [Mission Difficulty Scaling](#mission-difficulty-scaling)
- [Mission Rewards](#mission-rewards)
- [Victory & Failure Conditions](#victory--failure-conditions)
- [Special Mission Types](#special-mission-types)
- [Integration with Other Systems](#integration-with-other-systems)

---

## Overview

### System Architecture

Missions are the primary tactical engagement layer in AlienFall, bridging strategic decisions (Geoscape) with tactical execution (Battlescape). The mission system generates procedural combat scenarios based on faction activity, player actions, country relations, and campaign progression. Each mission type has distinct objectives, rewards, and strategic consequences.

**Design Philosophy**

Missions create meaningful strategic decisions through varied objectives, scaling difficulty, and cascading consequences. The procedural generation system ensures replay variety while maintaining balanced challenge progression. Mission outcomes affect diplomatic relations, faction standing, resource acquisition, and campaign escalation.

**Core Principle**: Missions are the feedback loop between strategic planning and tactical execution.

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

## Mission Objectives

### Objective Types

#### Elimination Objectives
- **Eliminate All Enemies**: Standard combat objective, mission ends when all hostiles eliminated
- **Eliminate Target**: Specific enemy must be killed (commander, terror leader, VIP)
- **Eliminate Commander**: Priority target with enhanced rewards

#### Defense Objectives
- **Defend Location**: Prevent enemy from reaching/destroying specific tile
- **Protect Units**: Keep specific friendly units alive (civilians, VIP, scientists)
- **Protect Facilities**: Prevent facility destruction (base defense)

#### Acquisition Objectives
- **Secure Object**: Reach and interact with specific object (data terminal, artifact)
- **Retrieve Item**: Pick up and carry item to extraction point
- **Capture Target**: Subdue and extract living enemy

#### Extraction Objectives
- **Reach Extraction**: All units must reach designated tile
- **Survive Duration**: Hold position for X turns
- **Escape**: Reach map edge before time limit

#### Hybrid Objectives
- **Eliminate + Extract**: Kill all enemies then extract
- **Defend + Survive**: Hold position for duration while under attack
- **Secure + Defend**: Capture objective then defend from reinforcements

---

## Mission Difficulty Scaling

### Difficulty Calculation

**Source Reference**: AI.md §Mission Difficulty Scaling

```
Difficulty = BASE_DIFFICULTY + (CAMPAIGN_MONTH × 0.2) + (PLAYER_BASE_COUNT × 0.15) + (PLAYER_AVG_UNIT_LEVEL × 0.1)

Alien Team Composition:
- Total Units = 3 + (Difficulty × 0.8)
- Unit Classes = [40% Grunts, 35% Warriors, 20% Specialists, 5% Heavy] × Difficulty scaling
- Equipment Tier = MIN(Player_Equipment_Tier + 1, MAX_TIER)
```

### Difficulty Modifiers by Mission Type

| Mission Type | Base Difficulty | Unit Multiplier | Equipment Bonus |
|--------------|----------------|-----------------|-----------------|
| UFO Crash | 1.0 | 0.5 (half crew) | Standard |
| Alien Base | 2.5 | 2.0 (garrison) | +1 tier |
| Terror Mission | 1.8 | 1.5 | Standard |
| Base Defense | 2.0 | Variable | +1 tier |
| Colony Defense | 1.5 | 1.2 | Standard |
| Research Facility | 1.2 | 0.8 (stealth) | Standard |

### Player Difficulty Setting

**Source Reference**: Battlescape.md §Difficulty Scaling

| Difficulty | Squad Size | AI Intelligence | Reinforcements |
|------------|-----------|-----------------|----------------|
| **Easy** | 75% | 50% | None |
| **Normal** | 100% | 100% | None |
| **Hard** | 125% | 200% | 1 wave |
| **Impossible** | 150% | 300% | 2-3 waves |

---

## Mission Rewards

### Reward Types

#### Credits (Cash Rewards)
- **Base Reward**: Fixed amount per mission type
- **Performance Bonus**: +10% per secondary objective completed
- **Perfect Bonus**: +50% for zero casualties + all objectives
- **Speed Bonus**: +20% for completing within turn limit

#### Salvage (Equipment & Materials)
- **Enemy Equipment**: Weapons, armor, items from defeated aliens
- **Mission Loot**: Special items found on map
- **Corpses**: Alien bodies for research (autopsy projects)
- **Technology**: UFO components, alien artifacts

#### Research Opportunities
- **Research Items**: Alien technology samples enabling new research
- **Man-Day Bonuses**: Accelerate current research projects
- **Unlock Gates**: Required items for prerequisite research

#### Diplomatic Effects
- **Relations**: +5 to +30 with mission-requesting country
- **Fame**: +5 to +15 based on performance
- **Karma**: +10 to +30 for heroic actions (save civilians)
- **Funding**: Temporary or permanent funding level increases

#### Strategic Effects
- **Faction Escalation**: -2 to -10 escalation points for successful defense
- **Territory Control**: Secure province, extend radar coverage
- **Base Security**: Prevent base destruction, maintain operations

### Reward Scaling Formula

```
Total Reward = Base Reward × (1 + Performance Bonus + Speed Bonus) + Salvage Value

Performance Bonus = 0.1 × Secondary Objectives Completed
Speed Bonus = 0.2 if completed ≤ Half expected turns, else 0
Salvage Value = Sum of (Enemy Equipment × 50% market value)
```

---

## Victory & Failure Conditions

### Victory Conditions

#### Mission Complete (Success)
- All primary objectives achieved
- Player units survive or successfully extract
- Mission timer (if applicable) not expired

#### Tactical Victory (Partial Success)
- Primary objective achieved
- High casualties or secondary objectives failed
- Reduced rewards (50-75% of full)

#### Strategic Withdrawal (Retreat)
- Player chooses to extract before objectives complete
- Minimal rewards (10-25% of full)
- No diplomatic penalty if justified

### Failure Conditions

#### Mission Failed (Complete Failure)
- Primary objective not achieved
- All player units killed or incapacitated
- Mission timer expired without completion
- Critical objective destroyed (base command center, VIP killed)

#### Consequences of Failure
- Zero rewards
- Diplomatic penalties (-10 to -30 relations)
- Strategic losses (base destroyed, territory lost)
- Karma/Fame penalties
- Equipment lost (dead units' gear)

### Retreat Mechanics

**Player May Retreat If**:
- Overwhelming enemy force
- Mission unwinnable
- Preserve veteran units

**Retreat Process**:
1. Choose extract option from menu
2. Units move toward extraction point
3. Enemies continue to engage
4. Mission ends when all units extracted or turn limit

**Retreat Penalties**:
- 10-25% credit reward only
- Zero diplomatic bonus
- -5 to -10 relations
- Karma neutral (no penalty for tactical wisdom)

---

## Special Mission Types

### Night Missions

**Source Reference**: Battlescape.md §Day vs. Night Missions

**Characteristics**:
- Extremely short sight range (3-6 hexes)
- Sanity penalty: -1 per unit
- Blue screen tint effect
- Some enemies have natural night vision

**Common Night Mission Types**:
- Infiltration operations
- Alien abductions
- Terror missions
- Black market contracts

---

### Underground Missions

**Characteristics**:
- Forced night conditions
- No weather effects
- Claustrophobic linear maps
- Echo effects on audio

**Common Underground Mission Types**:
- Alien base assaults
- Underground facility raids
- Sewer/tunnel missions

---

### Facility Missions (Base Defense)

**Source Reference**: Basescape.md §Base Defense

**Characteristics**:
- Limited map area (player base layout)
- Neutral NPCs in facility areas
- Stationary defensive emplacements
- Reinforcements arrive from specific entrances
- Base turrets participate as units

**Integration**: Turrets from Basescape.md participate as defensive units with fixed positions and preset armaments

---

## Integration with Other Systems

### Geoscape Integration

**Mission Detection**:
- Radar coverage determines mission visibility
- Stealth UFOs remain hidden until detected
- Mission availability window (12-48 hours typical)

**Mission Response**:
- Craft deployment to mission site
- Travel time based on distance and craft speed
- Interception combat may occur en route

---

### Battlescape Integration

**Map Generation**:
- Mission type determines map script
- Biome selection based on province terrain
- Weather conditions from Geoscape state

**Enemy Composition**:
- Generated by AI system based on difficulty
- Squad deployment from AI.md §Deployment Process
- Unit promotion from experience budget

---

### Economy Integration

**Salvage Processing**:
- Mission loot transferred to base inventory
- Corpses available for autopsy research
- Equipment sold or used by player units

**Research Unlocks**:
- Alien technology samples enable research projects
- Research tree progression (see Economy.md §Research Tree)

---

### Diplomatic Integration

**Country Relations**:
- Mission success improves relations
- Mission failure damages relations
- Terror mission performance critical for funding

**Faction Relations**:
- Alien base destruction reduces faction escalation
- Successful defenses slow alien expansion
- Black market missions affect karma/fame

---

## Related Content

**For detailed information, see**:
- **AI.md** - Mission generation algorithms, enemy AI behavior
- **Geoscape.md** - Mission detection, craft deployment
- **Battlescape.md** - Tactical combat mechanics, map generation
- **Countries.md** - Country-specific mission generation
- **BlackMarket.md** - Purchased custom missions
- **Economy.md** - Salvage processing, research unlocks
- **Interception.md** - UFO interception mechanics

---

## Implementation Notes

**Priority Systems**:
1. Core mission types (UFO Crash, Base Defense, Terror)
2. Mission generation algorithm
3. Difficulty scaling
4. Reward calculation
5. Special mission types (Black Market, Escort)

**Balance Considerations**:
- Mission frequency should match player capability
- Difficulty progression should feel fair
- Rewards should incentivize engagement
- Failure should be recoverable, not campaign-ending

**Testing Focus**:
- Mission generation distribution
- Difficulty scaling curve
- Reward vs. effort balance
- Diplomatic consequence impact

