# Countries System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Geoscape.md, Politics.md, Relations.md, Finance.md, Economy.md

## Table of Contents

- [Overview](#overview)
- [Country Properties](#country-properties)
- [Funding System](#funding-system)
- [Relations & Diplomacy](#relations--diplomacy)
- [Territory Control](#territory-control)
- [Country AI Behavior](#country-ai-behavior)
- [Events & Crises](#events--crises)
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

The Countries System manages the geopolitical landscape of AlienFall, defining nation-states, their territories, relationships with the player organization, and their responses to alien threats. Countries provide funding, control territories, influence research access, and react to player actions through a sophisticated diplomatic framework.

### Design Philosophy

Countries represent humanity's fragmented response to the alien threat. Each nation has distinct economic capacity, military strength, political stability, and willingness to cooperate. The player must balance multiple competing interests: maintaining funding from multiple countries, preventing territorial losses, and managing diplomatic relations while prosecuting the alien war.

### Strategic Purpose

- **Economic Foundation**: Countries provide primary funding for player operations
- **Territory Control**: Define the strategic map through province ownership
- **Diplomatic Complexity**: Create meaningful choices through competing national interests
- **Research Access**: Gate certain technologies behind diplomatic relationships
- **Victory Conditions**: Global cooperation required for campaign success

---

## Country Properties

### Core Attributes

Each country maintains persistent state across the campaign:

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| **Country ID** | String | Unique identifier | Database key for all operations |
| **Name** | String | "United States", "China", etc. | Display name |
| **Capital Province** | Province ID | Reference to province | Strategic center |
| **Controlled Provinces** | Array[Province ID] | 1-50 provinces | Territory extent |
| **Population** | Integer | 1M - 1.4B | Economic scale factor |
| **GDP** | Integer | 100B - 25T USD | Funding capacity |
| **Military Strength** | Integer | 1-10 | Defense capability |
| **Political Stability** | Integer | 1-10 | Crisis resistance |
| **Tech Level** | Integer | 1-5 | Research advancement |
| **Relations Score** | Integer | -100 to +100 | Player relationship |
| **Funding Commitment** | Integer | 0-10M/month | Player funding |
| **Last Contact** | Date | Timestamp | Diplomatic tracking |

### Country Classification

Countries grouped by strategic importance and economic capacity:

#### Superpower Tier (3-5 countries)
- **GDP**: >$15 trillion
- **Funding Capacity**: 5-10M credits/month
- **Province Count**: 20-50
- **Examples**: USA, China, European Union
- **Strategic Value**: Critical funding sources, major research partners

#### Major Power Tier (10-15 countries)
- **GDP**: $2-15 trillion
- **Funding Capacity**: 1-5M credits/month
- **Province Count**: 10-20
- **Examples**: Japan, India, Brazil, Russia
- **Strategic Value**: Significant funding, regional stability anchors

#### Regional Power Tier (20-30 countries)
- **GDP**: $500B-2T
- **Funding Capacity**: 200K-1M credits/month
- **Province Count**: 5-10
- **Examples**: South Korea, Australia, Mexico
- **Strategic Value**: Strategic positioning, specialized research

#### Minor Nation Tier (40-60 countries)
- **GDP**: <$500B
- **Funding Capacity**: 50-200K credits/month
- **Province Count**: 1-5
- **Examples**: Small nations, city-states
- **Strategic Value**: Tactical locations, niche capabilities

---

## Funding System

### Monthly Funding Calculation

Each country contributes monthly funding based on multiple factors:

```
Monthly Funding = Base Funding × Relations Modifier × Threat Modifier × Performance Modifier × Stability Modifier

Where:
- Base Funding = (GDP / 100,000) × (Country Tier Multiplier)
- Relations Modifier = (Relations Score + 100) / 200  [0.0 to 1.0]
- Threat Modifier = 1.0 + (Alien Activity Level × 0.1)  [1.0 to 2.0]
- Performance Modifier = (Successful Missions / Total Missions) × 0.5 + 0.75  [0.75 to 1.25]
- Stability Modifier = Political Stability / 10  [0.1 to 1.0]
```

**Example Calculation (USA, Month 6):**
```
Base Funding = (25,000,000 / 100,000) × 2.0 = 500K
Relations Modifier = (60 + 100) / 200 = 0.8
Threat Modifier = 1.0 + (4 × 0.1) = 1.4
Performance Modifier = (15 / 20) × 0.5 + 0.75 = 1.125
Stability Modifier = 8 / 10 = 0.8

Monthly Funding = 500K × 0.8 × 1.4 × 1.125 × 0.8 = 504K credits
```

### Funding Changes & Events

Countries adjust funding in response to player actions and global events:

| Event | Funding Impact | Duration |
|-------|---------------|----------|
| **Mission Success in Territory** | +10% | 1 month |
| **Mission Failure in Territory** | -15% | 2 months |
| **Alien Base Destroyed** | +25% | 3 months |
| **Base Defense Success** | +20% | 2 months |
| **Base Defense Failure** | -40% | 6 months |
| **Civilian Casualties** | -5% per incident | 1 month |
| **Province Lost to Aliens** | -30% | Permanent until reclaimed |
| **Research Breakthrough** | +15% | 2 months |
| **Diplomatic Crisis** | -50% | Until resolved |

### Funding Withdrawal & Restoration

**Withdrawal Triggers:**
- Relations score drops below -40 (hostile)
- Country leaves player coalition
- Economic collapse (stability < 3)
- Government overthrow (political crisis)

**Restoration Requirements:**
- Relations score above +10 (neutral)
- Successful diplomatic mission
- Demonstrated player value (3+ successful missions)
- Payment of restoration fee (100K credits)

---

## Relations & Diplomacy

### Relations Scoring System

Relations tracked on -100 to +100 scale with discrete state transitions:

| Relations Range | State | Funding | Access | Behavior |
|-----------------|-------|---------|--------|----------|
| **+75 to +100** | Allied | 100% | Full research, marketplace priority | Active cooperation |
| **+40 to +74** | Friendly | 90% | Standard access | Supportive |
| **+10 to +39** | Neutral+ | 75% | Limited access | Cautiously supportive |
| **0 to +9** | Neutral | 50% | Basic access | Indifferent |
| **-9 to -1** | Neutral- | 40% | Restricted access | Skeptical |
| **-40 to -10** | Unfriendly | 25% | Minimal access | Obstructive |
| **-75 to -41** | Hostile | 0% | No access | Active opposition |
| **-100 to -76** | Enemy | 0% | Blocked | Declares war |

### Relations Change Sources

**Positive Relations Changes:**
- Successful mission in country territory: +5
- Alien base destroyed in territory: +10
- Research shared with country: +3
- Diplomatic mission success: +8
- Trade agreement: +5
- Military cooperation: +7
- Intelligence sharing: +4

**Negative Relations Changes:**
- Mission failure in territory: -3
- Civilian casualties: -5 per incident
- Province lost to aliens: -8
- Unauthorized operations: -10
- Espionage discovered: -15
- Treaty violation: -20
- Base construction without permission: -12

### Diplomatic Actions

Player can initiate diplomatic actions to influence relations:

| Action | Cost | Relations Change | Requirements | Cooldown |
|--------|------|------------------|--------------|----------|
| **Gift Credits** | 50K-500K | +3 to +10 | Relations > -40 | None |
| **Share Intelligence** | Free | +4 | Active intel | 1 month |
| **Trade Agreement** | 100K | +5 | Relations > 0 | 3 months |
| **Research Partnership** | 200K | +8 | Relations > +20 | 6 months |
| **Military Alliance** | 500K | +15 | Relations > +40 | 12 months |
| **Diplomatic Summit** | 250K | +12 or -8 | Relations > -20 | 6 months |

---

## Territory Control

### Province Ownership

Each province belongs to exactly one country at any time:

**Ownership States:**
- **Controlled**: Normal governance, full funding contribution
- **Contested**: Under alien attack, reduced funding (-50%)
- **Occupied**: Alien control, no funding, possible reclamation
- **Abandoned**: No effective governance, neutral territory

### Territory Changes

**Province Loss Conditions:**
- Alien base established (automatic occupation)
- Mission failure + alien presence > 3 months
- Country withdrawal from coalition
- Economic collapse (country ceases operations)

**Province Reclamation:**
- Destroy alien base in province
- Complete liberation mission
- Restore country relations to positive
- Pay reconstruction cost (variable)

---

## Country AI Behavior

### Decision Making

Countries make autonomous decisions each month:

**Funding Adjustment:**
```
Each Month:
1. Evaluate Player Performance
   - Success rate in territory
   - Overall campaign progress
   - Alien threat level
2. Calculate Relations Change
   - Recent events (missions, casualties)
   - Long-term trend
3. Adjust Funding
   - Apply modifiers
   - Update commitment
```

**Strategic Actions:**
```
Possible Actions:
- Increase military spending (self-defense)
- Request player intervention (mission generation)
- Form regional alliances (coordination)
- Withdraw from coalition (if hostile)
- Declare independence (player becomes enemy)
```

---

## Events & Crises

### Country-Specific Events

Random events affect individual countries:

| Event | Frequency | Effect | Duration |
|-------|-----------|--------|----------|
| **Economic Boom** | 10%/month | +25% funding | 3 months |
| **Economic Crisis** | 5%/month | -40% funding | 6 months |
| **Political Instability** | 8%/month | -20% stability | 4 months |
| **Military Coup** | 2%/month | Relations reset to 0 | Permanent |
| **Alien Infiltration** | 5%/month | -15 relations | Until mission |
| **Research Breakthrough** | 3%/month | +Tech level | Permanent |
| **Natural Disaster** | 4%/month | -30% funding | 2 months |

---

## Examples

### Scenario 1: Maintaining Alliance
**Setup**: USA relations at +60, providing 400K/month
**Action**: Complete 3 successful missions in USA territory
**Result**: Relations +15 → +75 (Allied), funding +10% → 440K/month

### Scenario 2: Diplomatic Crisis
**Setup**: China relations at +20, civilian casualties in mission
**Action**: Casualties -5, unauthorized operation -10
**Result**: Relations -15 → +5 (Neutral), funding reduced 75% → 50%

### Scenario 3: Territory Loss
**Setup**: Province in India under alien attack
**Action**: Mission failure, alien base established
**Result**: Province occupied, India funding -30%, relations -8

---

## Balance Parameters

| Parameter | Value | Range | Reasoning |
|-----------|-------|-------|-----------|
| Base Funding (Superpower) | 500K-2M | 100K-5M | Economic foundation |
| Relations Gain (Success) | +5 | +3 to +10 | Reward performance |
| Relations Loss (Failure) | -3 | -1 to -10 | Punish failure |
| Funding Recovery Time | 2-6 months | 1-12 months | Economic inertia |

---

## Difficulty Scaling

### Easy Mode
- Base funding +30%
- Relations changes +50% positive, -25% negative
- Slower territory loss (6 months vs 3)

### Normal Mode
- Standard values

### Hard Mode
- Base funding -20%
- Relations changes -25% positive, +50% negative
- Faster territory loss (1 month vs 3)

---

## Testing Scenarios

- [ ] **Funding Calculation**: Verify monthly funding formula
- [ ] **Relations Changes**: Test all positive/negative events
- [ ] **Territory Loss**: Confirm province occupation mechanics
- [ ] **Diplomatic Actions**: Validate action costs and effects

---

## Related Features

- **[Geoscape System]**: Province control and mission generation (Geoscape.md)
- **[Politics System]**: Diplomatic complexity and coalitions (Politics.md)
- **[Finance System]**: Economic management and budgets (Finance.md)
- **[Relations System]**: Diplomatic relations technical implementation (Relations.md)

---

## Implementation Notes

**Priority Systems**:
1. Funding calculation and distribution
2. Relations tracking and state transitions
3. Territory control and ownership
4. Diplomatic action framework
5. Event system integration

---

## Review Checklist

- [ ] Country properties fully specified
- [ ] Funding system documented with formulas
- [ ] Relations system defined with thresholds
- [ ] Territory control mechanics clear
- [ ] AI behavior patterns specified
- [ ] Events and crises documented
- [ ] Balance parameters quantified
- [ ] Difficulty scaling implemented
- [ ] Testing scenarios comprehensive
- [ ] Related features properly linked
