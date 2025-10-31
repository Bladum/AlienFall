# Countries System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Geoscape.md, Politics.md, DiplomaticRelations_Technical.md, Finance.md

## Table of Contents

- [Overview](#overview)
- [Country Types & Classifications](#country-types--classifications)
- [Country Properties & Attributes](#country-properties--attributes)
- [Integrated Relations System](#integrated-relations-system)
- [Funding System](#funding-system)
- [Country Events & Missions](#country-events--missions)
- [Terror & Panic Mechanics](#terror--panic-mechanics)
- [Strategic Positioning](#strategic-positioning)
- [Balance Philosophy](#balance-philosophy)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

---

## Overview

Countries are geographical entities that exist on the world map within the geoscape system. They serve as the primary diplomatic and economic stakeholders in AlienFall, with integrated relations tracking and state management. The country system is entirely contained within the geoscape, eliminating separation between geographical and diplomatic concerns.

**Key Functions:**
- Provide monthly funding based on defense budget allocation and diplomatic relations
- Generate missions in their territories based on threat levels and relations
- React to player performance through integrated panic and relations changes
- Influence game difficulty and alien invasion patterns through unified state
- Provide strategic diversity through regional specialization and nation types

**Strategic Importance:**
Countries create a dynamic web of diplomatic constraints and opportunities within the geoscape. A single player action (successful or failed mission) can cascade across multiple countries' panic levels and relations, affecting funding, mission availability, and game difficulty. Players must balance defending all nations fairly against operational constraints and resource limitations.

## Integrated Relations System

**See Also**: [DiplomaticRelations_Technical.md](./DiplomaticRelations_Technical.md) for complete relationship mechanics

- Diplomatic relations tracked with history and trends
- Time-based decay and growth mechanics
- UI-ready status labels and color coding
- Unified with country state management

---

## Country Types & Classifications

### Nation Classifications

**Major Powers** (5-8 per game)
- Examples: USA, China, Russia, EU Federation, India
- Characteristics: Large economies, significant influence, high funding potential
- Special Rules: Start with +30 relation bonus, generate 40% more missions
- Strategic Role: Primary funding sources; protecting them is critical

**Secondary Powers** (8-12 per game)
- Examples: Japan, Germany, Brazil, Canada, UK
- Characteristics: Medium economies, moderate influence, balanced funding
- Special Rules: Standard relationship starting point, standard mission frequency
- Strategic Role: Stable income sources; good diplomatic hedging

**Minor Nations** (10-15 per game)
- Examples: New Zealand, Singapore, Cyprus, Costa Rica
- Characteristics: Smaller economies, local influence, modest funding
- Special Rules: Reduced mission frequency, but lower protective burden
- Strategic Role: Easy wins for relationship building; strategic locations

**Supranational Organizations** (2-3 per game)
- Examples: UN-XCOM Alliance, International Space Authority, Global Economic Union
- Characteristics: Political rather than economic entities, special mission types
- Special Rules: Cannot declare war, always neutral or allied, generate diplomatic missions
- Strategic Role: Mechanism for ending/continuing campaigns, diplomatic victories

### Regional Blocs

Countries are organized into geographic regions:
- **North America**: USA, Canada, Mexico
- **South America**: Brazil, Chile, Colombia, Peru
- **Europe**: EU nations grouped together
- **Middle East**: Diverse countries with regional tensions
- **Asia-Pacific**: China, India, Japan, Australia, ASEAN nations
- **Africa**: Regional bloc with internal cooperation/conflict

**Regional Effects:**
- Regions share panic and morale
- Regional stability affects UFO sighting frequency
- Collective regional defense efforts provide bonuses
- Regional bloc relationships create diplomatic cascades

---

## Country Properties & Attributes

### Core Attributes

| Attribute | Type | Range | Description |
|-----------|------|-------|-------------|
| Name | String | - | Country identifier and display name |
| Nation Type | Enum | MAJOR, SECONDARY, MINOR, SUPRANATIONAL | Country classification |
| GDP | Number | 1-1000 | Economic power scale (millions USD) |
| Military Power | Number | 1-10 | Military capability rating |
| Starting Relation | Number | -50 to +50 | Initial diplomatic standing |
| Base Funding Level | Number | 1-10 | Default defense budget allocation |
| Region | String | - | Geographic region assignment |
| Capital Province | String | - | Primary territory province |

### Dynamic Properties

| Property | Range | Purpose |
|----------|-------|---------|
| Current Relation | -100 to +100 | Diplomatic standing (affects funding, missions) |
| Panic Level | 0-100 | Population fear from alien activity (100+ triggers loss) |
| Funding Level | 1-10 | Monthly budget allocation (% of GDP) |
| Stability | 0-100 | Political stability (affects mission generation) |
| Military Readiness | 0-100 | Defense preparedness (affects alien attacks) |
| Morale | 0-100 | Public support for defense efforts (affects panic) |

### Relationship Categories

Each country maintains relationships with:
- **The Player**: Primary diplomatic relationship
- **Other Countries**: Influence on player missions and support
- **Factions**: Terrorist and alien faction standing
- **Suppliers**: Trade relationship for black market access

---

## Funding System

### Funding Calculation

**Monthly Country Funding Formula:**
```
Monthly Income = Funding Level Amount × Relationship Modifier
Relationship Modifier = 0.5 + (Relation / 100 × 0.5)
```

**Examples:**
- USA (Level 5, Relation +50): 40,000 × 0.75 = 30,000 credits/month
- Germany (Level 7, Relation +20): 65,000 × 0.6 = 39,000 credits/month
- Russia (Level 3, Relation -30): 22,000 × 0.35 = 7,700 credits/month

### Funding Levels (1-10)

| Level | Monthly Funding | Income Amount | Notes |
|-------|---|---|---|
| 1 | 1% of GDP | 10,000 credits | Minimal defense allocation |
| 2 | 2% of GDP | 15,000 credits | Reduced budget |
| 3 | 3% of GDP | 22,000 credits | Below-average commitment |
| 4 | 4% of GDP | 30,000 credits | Below-average commitment |
| 5 | 5% of GDP | 40,000 credits | Standard baseline |
| 6 | 6% of GDP | 50,000 credits | Above-average commitment |
| 7 | 7% of GDP | 65,000 credits | High priority |
| 8 | 8% of GDP | 80,000 credits | Maximum priority |
| 9 | 9% of GDP | 100,000 credits | Emergency measures |
| 10 | 10% of GDP | 125,000 credits | Full mobilization |

### Funding Level Changes

**Relationship-Based Changes:**
- Relation +75 to +100 (Allied): Automatic increase to level 8-10
- Relation +40 to +74 (Cooperative): Automatic increase to level 6-8
- Relation +11 to +39 (Friendly): Standard level 5-7
- Relation -10 to +10 (Neutral): Level 3-5
- Relation -40 to -9 (Cold): Level 2-4
- Relation -75 to -40 (Hostile): Level 1-2
- Relation -100 to -75 (War): Funding suspended (0)

**Events That Trigger Changes:**
- Major military victory: +1 level for 1 month
- Mission failure: -1 level for 2 months
- Terror mission success: +1-2 levels permanently
- Player bases raided: -2 levels for 3 months
- Funding crisis: -1 level per month (cascading)

### Funding Crisis Mechanics

When a country is under heavy alien pressure or political instability:

**Crisis Levels:**
- Level 1 (Stress): Funding reduced 20%, increased mission frequency
- Level 2 (Crisis): Funding reduced 40%, demanding missions increase
- Level 3 (Collapse): Funding reduced 60%, potential loss of nation

**Recovery:**
- Successful defense missions: -1 crisis level
- Major alien victory: +2 crisis levels
- 3 months without attacks: Full recovery to normal
- Diplomatic support: -1 crisis level from allied nations

---

## Integrated Relations System

The country system includes a comprehensive diplomatic relations system that tracks player relationships with each nation. Relations are managed entirely within the geoscape and affect funding levels, mission generation, and strategic options.

### Relation Values & Categories

Countries operate on a unified Relationship System integrated with their state management:
- **Range**: -100 (war/embargo) to +100 (strategic partnership)
- **Monthly changes**: ±1 to ±5 based on player actions and time decay
- **Visible to player** in geoscape UI with color coding and trend indicators
- **Direct integration** with funding calculations and mission generation

### Relationship Categories

| Range | Category | Funding Multiplier | Mission Frequency | Description |
|-------|----------|-------------------|------------------|-------------|
| 75-100 | Allied | 1.5x | 2-3/month | Strategic partnership, shared intelligence |
| 50-74 | Friendly | 1.0x | 1-2/month | Cooperative relationship, standard operations |
| 25-49 | Positive | 0.75x | 1/month | Good relations, reduced support |
| -24-24 | Neutral | 0.5x | 0.5/month | Balanced, minimal support |
| -49--25 | Negative | 0.25x | 0.25/month | Strained, defensive only |
| -74--50 | Hostile | 0.0x | 0/month | Adversarial, no cooperation |
| -100--75 | War | 0.0x | 0/month | Active conflict, embargo |

### Relation Trends & History

The system tracks diplomatic history to determine trends:
- **Improving**: Relations getting better over time
- **Declining**: Relations deteriorating
- **Stable**: Relations holding steady

Recent changes (last 20 events) are tracked with timestamps and reasons for UI display and strategic planning.

### Time-Based Decay & Growth

Relations naturally evolve over time:
- **Positive relations** slowly decay towards neutral (maintaining alliances requires effort)
- **Negative relations** gradually improve towards neutral (reconciliation over time)
- **Decay rate**: ~1 point per 100 days for extreme relations
- **Growth rate**: ~0.5 points per 100 days for negative relations

### Diplomatic Events

**Major Events Affecting Relations:**

| Event | Relation Change | Frequency | Notes |
|-------|---|---|---|
| Successful Defense Mission | +2-5 | Per mission | Scales with difficulty |
| Mission Failure | -3-5 | Per failure | Includes civilian casualties |
| UFO Destroyed in Territory | +3-8 | Per UFO kill | Threat level bonus |
| Terror Mission Completed | +8-15 | Major events | Significant diplomatic boost |
| Civilian Casualties | -1-10 | Per incident | Severity dependent |
| Base Raided by Aliens | -5-10 | Per base attack | Territory violation |
| Trade/Intelligence Shared | +5-10 | Diplomatic actions | Alliance building |
| Military Defeat | -10-15 | When allied forces defeated | Credibility loss |

### Multi-Nation Effects

Countries influence each other's relations:
- **Regional stability** affects neighboring countries
- **Alliance networks** create cascading diplomatic effects
- **Global events** impact all countries simultaneously
- **Supranational organizations** provide diplomatic leverage

---

## Country Events & Missions

### Mission Generation

Countries generate missions based on:
- **Current threat level** (alien activity in region)
- **Panic level** (civilian morale)
- **Player relation** (diplomatic standing)
- **Recent events** (mission success/failure history)

**Mission Frequency:**
- Allied country (+40 to +100): 2-3 missions per month (30% bonus)
- Friendly country (+10 to +39): 1-2 missions per month
- Neutral country (-10 to +10): 1 mission per month
- Cold country (-40 to -9): 0.5 missions per month (defensive only)
- Hostile country (-75 to -39): 0.25 missions per month (only if mutual benefit)
- War country: 0 missions available

**Mission Types by Country Type:**
- **Major Powers**: Elite defensive, strategic intel, high-value targets
- **Secondary Powers**: Balanced defensive/strategic mix
- **Minor Nations**: Local defense, counter-terror, evacuation
- **Supranational**: Diplomatic, UN coordination, multi-nation operations

### Event Consequences

**Country-Specific Events:**

| Event | Trigger | Effect | Duration |
|-------|---------|--------|----------|
| Political Crisis | Low relation + bad events | -1 funding level/month, -20% mission generation | 3 months or until resolved |
| Military Coup | Very low relation + lost bases | -30 relation, 1 month no missions | 1 month |
| Alien Invasion Wave | Terror activity spike | +50% mission rate, funding doubled | Variable |
| Trade Agreement | Diplomatic action | +1 funding level, +10% marketplace prices | Permanent until broken |
| Intelligence Breakthrough | Tech progress + diplomacy | +5 relation, special mission unlocked | 1 mission |
| Refugee Crisis | Civilian evacuation failure | -20 relation, -2 funding levels | 2 months |

---

## Terror & Panic Mechanics

### Panic System

**Panic Accumulation:**
- Successful terror mission in territory: +8-12 panic
- UFO sighting without engagement: +1-3 panic
- Alien base discovered: +15-25 panic
- Monthly decay without alien activity: -1 panic

**Panic Thresholds:**

| Panic Level | Effects | Consequences |
|---|---|---|
| 0-25 | Low | No effect, normal operations |
| 26-50 | Moderate | -20% funding from country, morale events |
| 51-75 | High | -40% funding, mission rate doubled (desperate) |
| 76-100 | Critical | -60% funding, all available missions urgent |
| 100+ | Collapse | Country falls, all benefits revoked, alien base established |

### Country Collapse

When panic reaches 101+:
- Country surrenders to alien occupation
- All funding from that country ceases immediately
- Missions switch to liberation/evacuation operations (high risk)
- Other nations lose -10 relation (loss of trust)
- Region becomes alien stronghold (higher threat level)

**Recovery After Collapse:**
- Player must defeat alien base in country
- Liberate at least 50% of territory
- Diplomatic restoration mission (political action)
- Nation returns with -50 relation penalty, normal panic

---

## Strategic Positioning

### Geographic Specialization

Different regions offer strategic advantages:

**North America:**
- Highest funding (+20% modifier)
- Advanced technology markets
- Defensive mission focus
- Heavy alien interest (strategic value)

**Europe:**
- Balanced funding
- Diplomatic hub (faction missions)
- Infrastructure support
- Moderate alien threat

**Asia-Pacific:**
- Large population (high panic swings)
- Economic centers (marketplace diversity)
- Mixed mission types
- Variable alien interest

**Other Regions:**
- Lower funding but strategic locations
- Specialized mission types
- Regional tensions create complications
- Lower alien threat but localized intensity

### Diplomatic Strategy

**Funding Optimization:**
- Protect high-GDP nations for maximum income
- Build relations with major powers early
- Negotiate funding agreements for stability
- Use minor nations for tactical victories

**Relationship Strategy:**
- Cannot please all nations simultaneously
- Regional blocs create cascading effects
- War declarations have major consequences
- Diplomacy is permanent (no quick resets)

**Crisis Response:**
- Multiple crises compound (regions destabilize)
- Player must prioritize strategically
- Failed nations reduce overall campaign income 40-60%
- Preventing collapse is easier than recovery

---

## Balance Philosophy

### Design Goals

1. **Meaningful Consequences**: Player decisions create lasting diplomatic effects
2. **Strategic Diversity**: Multiple viable approaches (military vs diplomatic)
3. **Resource Constraints**: Protecting all nations creates operational challenge
4. **Dynamic Difficulty**: Alien threat scales with player success
5. **Long-Term Planning**: Campaign success requires multi-month thinking

### Balancing Factors

**Counterweights to High Funding:**
- Higher-funded nations generate harder missions
- More visible failure consequences (reputation damage)
- Alien forces prioritize high-value targets
- Regional destabilization can cascade quickly

**Supporting Lower-Income Players:**
- Black market operations provide alternate income
- Marketplace sales add revenue diversity
- Faction missions can be high-value
- Base raiding generates salvage

**Mid-Campaign Scaling:**
- Country relationships become stable after 6 months
- Funding stabilizes at sustainable levels
- Alien threat adapts to player capability
- Crisis frequency decreases with successful operations

### Difficulty Modifiers

**By Game Difficulty:**
- **Easy**: +20% country funding, -20% alien mission frequency
- **Normal**: Baseline (no modifiers)
- **Difficult**: -20% country funding, +30% alien mission frequency
- **Impossible**: -40% funding, doubled alien missions, cascading crises

---

## See Also

- [Politics.md](Politics.md) - Relationship system, fame, karma
- [Finance.md](Finance.md) - Income and expense calculations
- [Geoscape.md](Geoscape.md) - Strategic layer overview
- [api/GEOSCAPE.md](../api/GEOSCAPE.md) - Country API documentation
---
## Integration with Other Systems
Countries integrate with:
### Geoscape System
- Define territorial boundaries and provinces
- Determine regional mission generation
- Affect world map strategic decisions
### Politics System
- Relationship values affect funding and cooperation
- Diplomatic actions modify country relations
- Alliance and war states change game dynamics
### Finance System
- Monthly funding based on performance
- Economic power determines contribution levels
- Satisfaction affects financial support
### Missions System
- Country distress triggers missions
- Relations determine mission availability
- Country defense success affects funding
**For complete system integration details, see [Integration.md](Integration.md)**

---

## Examples

### Scenario 1: Funding Crisis Management
**Setup**: Multiple countries experiencing terror attacks, funding declining
**Action**: Prioritize defense missions in highest-funding nations while managing panic
**Result**: Stabilized funding from key allies but increased panic in neglected regions

### Scenario 2: Diplomatic Balancing Act
**Setup**: Black market operations damage relations with major powers
**Action**: Conduct high-profile missions to rebuild trust while maintaining covert operations
**Result**: Restored diplomatic standing but delayed strategic objectives

### Scenario 3: Regional Escalation Response
**Setup**: Alien activity concentrated in specific region, causing panic cascade
**Action**: Deploy crafts strategically to contain threat and prevent diplomatic collapse
**Result**: Contained escalation but strained military resources across multiple countries

### Scenario 4: Alliance Building Strategy
**Setup**: Starting campaign with neutral relations across all nations
**Action**: Focus initial missions on building relations with resource-rich countries
**Result**: Strong economic foundation but vulnerability in distant regions

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Base Funding | 10,000 credits | 5K-20K | Economic contribution | ×0.7 on Easy |
| Relations Range | -100 to +100 | -200 to +200 | Diplomatic spectrum | No scaling |
| Panic Threshold | 50% | 30-70% | Mission trigger point | +20% on Hard |
| Funding Decay | -10% per month | 5-20% | Crisis penalty | ×1.5 on Hard |
| Mission Bonus | +20% funding | 10-30% | Success reward | ×0.5 on Easy |

---

## Difficulty Scaling

### Easy Mode
- Base funding: +30% increase
- Relations decay: 50% slower
- Panic thresholds: +20% higher
- Mission frequency: 20% reduction
- More forgiving diplomatic mistakes

### Normal Mode
- All parameters at standard values
- Balanced diplomatic challenges
- Standard funding and mission generation
- Normal consequence severity

### Hard Mode
- Base funding: -20% reduction
- Relations decay: 25% faster
- Panic thresholds: -15% lower
- Mission frequency: +30% increase
- Severe diplomatic consequences

### Impossible Mode
- Base funding: -40% reduction
- Relations decay: 50% faster
- Panic thresholds: -30% lower
- Mission frequency: Doubled
- Cascading diplomatic crises
- Limited recovery options

---

## Testing Scenarios

- [ ] **Funding Calculations**: Verify monthly funding reflects relations and performance
  - **Setup**: Countries with varying relation levels
  - **Action**: Process monthly funding cycle
  - **Expected**: Funding scales with diplomatic standing
  - **Verify**: Credit calculations and country contributions

- [ ] **Panic Escalation**: Test terror events trigger appropriate mission generation
  - **Setup**: Country with rising panic levels
  - **Action**: Allow panic to exceed thresholds
  - **Expected**: Mission generation increases with panic
  - **Verify**: Mission spawn rates and types

- [ ] **Relations Decay**: Verify diplomatic relations change over time appropriately
  - **Setup**: Country with mixed mission outcomes
  - **Action**: Process multiple mission cycles
  - **Expected**: Relations reflect performance history
  - **Verify**: Relation changes and decay calculations

- [ ] **Strategic Positioning**: Test base placement affects country relations
  - **Setup**: Base construction in various territories
  - **Action**: Monitor diplomatic reactions
  - **Expected**: Territory control influences relations
  - **Verify**: Relation bonuses and diplomatic events

- [ ] **Crisis Management**: Verify cascading panic affects multiple countries
  - **Setup**: Regional alien activity spike
  - **Action**: Allow panic to spread geographically
  - **Expected**: Neighboring countries affected
  - **Verify**: Panic spread mechanics and mission generation

---

## Related Features

- **[Geoscape System]**: Country territories and strategic positioning (Geoscape.md)
- **[Politics System]**: Diplomatic relations and faction management (Politics.md)
- **[Finance System]**: Funding calculations and economic impacts (Finance.md)
- **[Missions System]**: Country-generated missions and consequences (Missions.md)
- **[AI System]**: Faction behavior and diplomatic AI (AI.md)

---

## Implementation Notes

**Priority Systems**:
1. Country classification and attributes system
2. Integrated relations tracking and decay
3. Funding calculation and monthly cycles
4. Mission generation based on panic/relations
5. Terror and panic escalation mechanics

**Balance Considerations**:
- Funding should create meaningful strategic trade-offs
- Relations decay prevents passive diplomatic management
- Panic mechanics drive mission frequency appropriately
- Country diversity creates varied strategic challenges
- Diplomatic consequences should feel significant but recoverable

**Testing Focus**:
- Funding calculation accuracy
- Relations decay curves
- Panic escalation triggers
- Mission generation distribution
- Diplomatic consequence severity

---

## Review Checklist

- [ ] Country types and classifications clearly defined
- [ ] Country properties and attributes specified
- [ ] Integrated relations system implemented
- [ ] Funding system balanced and comprehensive
- [ ] Country events and missions mechanics clear
- [ ] Terror and panic mechanics specified
- [ ] Strategic positioning effects documented
- [ ] Balance philosophy articulated
- [ ] Balance parameters quantified with reasoning
- [ ] Difficulty scaling implemented
- [ ] Testing scenarios comprehensive
- [ ] Related systems properly linked
- [ ] No undefined terminology
- [ ] Implementation feasible
