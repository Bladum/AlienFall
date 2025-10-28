# Diplomatic Relations System

> **Status**: Technical Specification  
> **Last Updated**: 2025-10-28  
> **Related Systems**: Politics.md, Countries.md, Economy.md, ai_systems.md

## Table of Contents

- [Overview](#overview)
- [Universal Relationship Scale](#universal-relationship-scale)
- [Relationship Change Mechanics](#relationship-change-mechanics)
- [Entity-Specific Modifiers](#entity-specific-modifiers)
- [Threshold Effects](#threshold-effects)
- [Special Relationship Events](#special-relationship-events)
- [Diplomatic UI Elements](#diplomatic-ui-elements)
- [Integration with Other Systems](#integration-with-other-systems)
- [Balance Considerations](#balance-considerations)
- [Future Enhancements](#future-enhancements)

---

## Overview

The Diplomatic Relations System is a universal framework for tracking trust, reputation, and cooperation between the player organization and other entities (countries, suppliers, alien factions). All relationship mechanics use a consistent -100 to +100 scale with standardized thresholds and effects.

**Core Principle**: One universal relationship system eliminates confusion and enables complex cross-system interactions.

---

## Universal Relationship Scale

### Scale Definition

**Range**: -100 (hostile/embargo) to +100 (allied/partnership)

**Standard Thresholds**:

| Range | Label | Color Code | Status | Effects |
|-------|-------|------------|--------|---------|
| +75 to +100 | **Allied** | 🟢 Green | Strategic partnership | Maximum benefits, exclusive access |
| +50 to +74 | **Friendly** | 🔵 Blue | Strong cooperation | Major benefits, priority treatment |
| +25 to +49 | **Positive** | 🟡 Yellow | Good relations | Moderate benefits, standard access |
| 0 to +24 | **Neutral** | ⚪ White | Normal relations | No bonuses or penalties |
| -1 to -24 | **Cool** | 🟠 Orange | Strained relations | Minor penalties, reduced access |
| -25 to -49 | **Unfriendly** | 🟠 Dark Orange | Poor relations | Moderate penalties, limited access |
| -50 to -74 | **Hostile** | 🔴 Red | Active opposition | Major penalties, embargo threats |
| -75 to -100 | **Enemy** | 🔴 Dark Red | Total conflict | No cooperation, active sabotage |

---

## Relationship Change Mechanics

### Change Rate Formula

```
Monthly Change = Base Change + Event Modifiers + Time Decay

Where:
- Base Change: ±0 (neutral baseline)
- Event Modifiers: Sum of all actions/events in the month
- Time Decay: -1 point per 3 months of inactivity (friendship atrophy)
```

### Standard Event Values

**Positive Actions** (improve relations):

| Action | Relation Change | Category | Notes |
|--------|----------------|----------|-------|
| Mission Success (in territory) | +5 | Countries | Per mission completed |
| UFO Destroyed (near territory) | +3 | Countries | Defensive action |
| Civilian Lives Saved | +2 | Countries | Per 10 civilians |
| Trade Agreement | +10 | Suppliers | Contract signing |
| Research Shared | +15 | Factions | Technology exchange |
| Diplomatic Gift | +5 to +20 | All | Based on gift value |
| Peaceful Resolution | +15 | Factions | Avoided conflict |
| Base Construction (with permission) | +10 | Countries | Infrastructure investment |
| Alliance Treaty | +25 | All | Major diplomatic milestone |

**Negative Actions** (damage relations):

| Action | Relation Change | Category | Notes |
|--------|----------------|----------|-------|
| Mission Failure (in territory) | -3 | Countries | Failed to protect |
| Civilian Casualties | -5 | Countries | Per 10 casualties |
| Black Market Purchase (discovered) | -10 | Countries | Illegal activity |
| Base Construction (without permission) | -20 | Countries | Sovereignty violation |
| Resource Theft | -15 | Suppliers | Economic crime |
| Technology Betrayal | -30 | Factions | Shared tech with enemies |
| Assassination (discovered) | -40 | All | Extreme act |
| War Declaration | -50 | All | Direct hostility |
| Base Attack | -60 | All | Invasion act |

### Relationship Momentum

**Momentum System**: Relationships have inertia - harder to change at extremes.

```
Change Multiplier = 1.0 - (|Current Relation| / 100) × 0.5

Example:
- At +0 relation: 1.0× change (normal rate)
- At +50 relation: 0.75× change (harder to improve)
- At +90 relation: 0.55× change (very slow improvement)
- At -50 relation: 0.75× change (harder to repair)
```

**Design Rationale**: Prevents instant alliance/enmity, creates gradual relationship building/decay.

---

## Entity-Specific Modifiers

### Countries

**Fame Bonus**: Country relations affected by player organization fame
```
Relation Change Modifier = (Fame / 100) × Event Value × 0.2

Example: +80 Fame = +16% bonus to all relation gains
```

**Panic Penalty**: High panic reduces relation gain effectiveness
```
Relation Change Modifier = (1 - Panic / 100) × Event Value

Example: 60% Panic = 40% effectiveness of relation gains
```

**Funding Link**: Relations directly affect funding level
```
Funding Level = (Relation + 100) / 20

Example: +60 Relation = Level 8 funding (80% of max)
```

### Suppliers

**Economic History**: Relations affected by trade volume
```
Trade Volume Bonus = (Total Credits Spent / 100,000) × 0.5

Example: $500K spent = +2.5 relation bonus (cumulative)
```

**Competitor Factor**: Buying from rivals damages relations
```
Rival Purchase Penalty = -5 per transaction with competing supplier
```

### Alien Factions

**Karma Alignment**: Some factions prefer high/low karma
```
Karma Modifier = |Player Karma - Faction Preferred Karma| / 50

Example: Ethereals prefer +50 karma
- Player at +60 karma: 0.2× penalty (close match)
- Player at -30 karma: 1.6× penalty (misaligned)
```

**Military Pressure**: Relations decay faster during active conflict
```
War Decay = -5 per month if faction is hostile to player
```

---

## Threshold Effects

### Country Threshold Effects

| Threshold | Effect | Mechanical Impact |
|-----------|--------|------------------|
| **+75 (Allied)** | Strategic partnership | +50% funding, exclusive tech access, joint bases |
| **+50 (Friendly)** | Priority status | +25% funding, preferential marketplace pricing |
| **+25 (Positive)** | Good standing | +10% funding, standard cooperation |
| **0 (Neutral)** | Baseline | No bonuses or penalties |
| **-25 (Unfriendly)** | Reduced cooperation | -10% funding, price markups begin |
| **-50 (Hostile)** | Active opposition | -50% funding, embargo threats, sanctions |
| **-75 (Enemy)** | Open conflict | 0% funding, no trade, possible attacks |

### Supplier Threshold Effects

| Threshold | Effect | Mechanical Impact |
|-----------|--------|------------------|
| **+75 (Preferred)** | VIP customer | -20% prices, exclusive inventory, priority restocking |
| **+50 (Valued)** | Good customer | -10% prices, expanded inventory |
| **+25 (Regular)** | Standard customer | Normal prices, standard inventory |
| **0 (Neutral)** | Unknown | Normal prices, basic inventory |
| **-25 (Problematic)** | Watched customer | +10% prices, reduced stock |
| **-50 (Blacklisted)** | Banned | +25% prices, minimal stock, trade restrictions |
| **-75 (Embargo)** | Total ban | No trade, market closure |

### Faction Threshold Effects

| Threshold | Effect | Mechanical Impact |
|-----------|--------|------------------|
| **+75 (Allied)** | Coalition | Shared research, joint missions, technology exchange |
| **+50 (Friendly)** | Non-aggression | No attacks, trade routes, intelligence sharing |
| **+25 (Neutral-Positive)** | Reduced hostility | 50% fewer attacks, negotiation possible |
| **0 (Neutral)** | Status quo | Normal aggression, no special interaction |
| **-25 (Unfriendly)** | Increased aggression | +25% attack frequency |
| **-50 (Hostile)** | Active war | +50% attack frequency, priority target |
| **-75 (Vendetta)** | Total war | +100% attack frequency, assassination attempts |

---

## Special Relationship Events

### Diplomatic Crises

**Threshold Crossing Events**: Major changes trigger special events.

**Crossing from Friendly to Hostile** (-50 threshold):
```
Event: "Diplomatic Breakdown"
- Country demands: Public apology + 100K credits + base inspection
- Player choice:
  - Accept: Relation restored to -40, temporary scrutiny
  - Refuse: Relation drops to -60, funding cut completely
  - Counter-offer: Diplomatic skill check (success: -45, failure: -65)
```

**Crossing from Hostile to Allied** (+75 threshold):
```
Event: "Historic Alliance"
- Country offers: Joint military operations, technology sharing, permanent base rights
- Unlock: Alliance missions, combined research projects, unified victory conditions
- Risk: If betrayed later, relation drops to -100 permanently
```

### Betrayal Mechanics

**Trust Breaking**: Certain actions cause permanent relation caps.

**Betrayal Types**:

| Betrayal | Permanent Cap | Recovery Time | Special Consequence |
|----------|--------------|---------------|---------------------|
| Technology sold to enemy | -50 max | 12 months | Supplier blacklist |
| Alliance broken | -75 max | Never | Permanent enemy status |
| Assassination (discovered) | -80 max | Never | International incident |
| Base attack on ally | -100 max | Never | All allies turn hostile |

---

## Diplomatic UI Elements

### Relationship Display

**HUD Indicators**:
- **Color-coded bar**: Visual representation of current relation
- **Trend arrows**: ↑ improving, ↓ declining, → stable
- **Historical graph**: Last 6 months of relation changes
- **Event log**: Recent actions affecting relation

**Relationship Details**:
```
Country: United States
Current Relation: +63 (Friendly)
Trend: ↑ Improving (+5 last month)
Next Threshold: Allied (+75) - requires +12 more

Recent Events:
  +5: Mission success (Terror Site, New York)
  +3: UFO destroyed (East Coast)
  -2: Civilian casualties (collateral damage)
  +2: Time bonus (consistent performance)

Projected: +68 in 1 month (if current trend continues)
```

---

## Integration with Other Systems

### Cross-System Effects

**Fame System** (Politics.md):
- High fame: +20% relation gain with countries
- Low fame: -10% relation gain with countries
- Fame affects relation visibility (famous orgs are watched closely)

**Karma System** (Politics.md):
- Karma affects faction relation preferences
- High karma: Bonus with peaceful factions
- Low karma: Bonus with aggressive factions

**Economy System** (Economy.md):
- Supplier relations affect marketplace prices
- Country relations affect funding levels
- Trade volume improves supplier relations

**Mission System** (Geoscape.md):
- Mission success improves country relations
- Mission failure damages country relations
- Special missions can dramatically shift relations

**AI Systems** (ai_systems.md):
- Factions prioritize attacks based on relation
- Countries adjust funding based on relation
- Suppliers adjust prices based on relation

---

## Balance Considerations

### Preventing Relation Exploitation

**Caps on Gain Farming**:
- Diminishing returns: 2nd+ identical action same month = 50% effect
- Cooldown: Major diplomatic events have 30-day cooldown
- Cost scaling: Diplomatic gifts cost more at higher relations

**Preventing Relation Tanking**:
- Minimum cooperation: Even at -75 relation, basic trade available (expensive)
- Redemption arcs: Special missions unlock relation recovery paths
- Neutral mediators: Third-party countries can broker peace (cost: credits + mission)

### Strategic Depth

**Multi-Entity Balancing**:
- Players cannot be allied with all entities (resource constraints)
- Some factions have mutual exclusivity (Sectoids vs Ethereals)
- Countries have regional blocs (EU nations move together)

**Opportunity Cost**:
- Improving one relation may damage another (rival nations, competing suppliers)
- Players must choose diplomatic priorities
- Late-game: Can achieve global unity OR focused alliances, not both easily

---

## Future Enhancements

**Potential Additions**:
- **Relation Forecasting**: AI predicts future relation based on current trajectory
- **Diplomatic Missions**: Special missions to improve relations (humanitarian aid, joint operations)
- **Relation Inheritance**: New entities start with relation based on similar entities
- **Reputation System**: Public actions affect all relations simultaneously (fame-like but for relations)
- **Diplomatic Victory Condition**: Achieve +75 with all major powers for peaceful ending

---

**End of Technical Specification**

*This document serves as the single source of truth for diplomatic relationship mechanics across all design documents.*

