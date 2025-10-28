# Black Market System - Comprehensive Design

> **Status**: Design Document  
> **Last Updated**: 2025-10-28  
> **Related Systems**: Economy.md, Politics.md, Items.md, Units.md

## Table of Contents

- [Overview](#overview)
- [Access Requirements](#access-requirements)
- [Black Market Categories](#black-market-categories)
- [Mission Generation](#mission-generation)
- [Event Purchasing](#event-purchasing)
- [Karma & Fame Impact](#karma--fame-impact)
- [Corpse Trading System](#corpse-trading-system)
- [Supplier Integration](#supplier-integration)
- [Risk & Consequences](#risk--consequences)

---

## Overview

The Black Market is a comprehensive underground economy system that goes far beyond simple item purchasing. Players can acquire restricted units, special craft, illegal items, generate custom missions, trigger political events, and trade in morally questionable goods like corpses from fallen soldiers.

**Core Philosophy**: High risk, high reward. Every Black Market transaction carries consequences for karma, fame, and relations, but provides access to otherwise unavailable strategic options.

---

## Access Requirements

### Unlocking the Black Market

**Initial Access**:
- Karma below +40 (cannot be "too good")
- Fame above 25 (must be known enough to find contacts)
- Discovery of Black Market contact (special mission or event)
- Payment of entry fee (10,000 credits one-time)

### Access Tiers

| Karma Range | Fame Range | Access Level | Available Categories |
|-------------|-----------|--------------|---------------------|
| +40 to +10 | 25-59 | **Restricted** | Items only, no services |
| +9 to -39 | 25-100 | **Standard** | Items, Units, some Services |
| -40 to -74 | 60-100 | **Enhanced** | All except extreme services |
| -75 to -100 | 75-100 | **Complete** | Everything including assassination |

**Dynamic Access**: Access level recalculates monthly based on current karma/fame values.

---

## Black Market Categories

### 1. Restricted Items

**Available Items**:
- Experimental weapons (not yet researched)
- Alien technology (before capture)
- Banned munitions (chemical, biological)
- Stolen military hardware
- Prototype equipment
- Black market modifications

**Pricing**: 200-500% of normal market value

**Karma Impact**: -5 to -20 per purchase (severity-based)

**Example Items**:
```
Plasma Rifle (unreseached): 150,000 credits, -15 karma
Chemical Grenade (banned): 50,000 credits, -20 karma
Stolen Interceptor Parts: 80,000 credits, -10 karma
Experimental Armor: 120,000 credits, -12 karma
```

---

### 2. Special Units

**Available Unit Types**:
- **Mercenaries**: Elite soldiers with unique skills
- **Defectors**: Enemy faction units who switched sides
- **Criminals**: High-risk, high-reward specialists
- **Augmented Soldiers**: Illegally enhanced humans
- **Clone Units**: Banned genetic copies

**Unit Recruitment Costs**:

| Unit Type | Cost | Monthly Salary | Karma Impact | Special Traits |
|-----------|------|----------------|--------------|---------------|
| **Elite Mercenary** | 50,000 | 5,000 | -10 | +2 all stats, "Ruthless" trait |
| **Alien Defector** | 80,000 | 8,000 | -15 | Faction knowledge, "Traitor" trait |
| **Augmented Soldier** | 120,000 | 10,000 | -25 | Enhanced stats, unstable sanity |
| **Master Assassin** | 150,000 | 15,000 | -30 | Stealth specialist, "Killer" trait |
| **Clone Trooper** | 100,000 | 7,000 | -20 | Uniform stats, no personality |

**Restrictions**:
- Maximum 3 black market units per base
- Units cannot be used in diplomatic missions (relations penalty if discovered)
- Some countries will discover and sanction use (-20 relations)

**Fame Impact**: -5 per black market unit recruited (if discovered)

---

### 3. Special Craft

**Available Craft**:
- **Stolen Military Craft**: Confiscated or hijacked
- **Prototype Craft**: Experimental designs
- **Modified Craft**: Illegal enhancements
- **Enemy Craft**: Captured and repaired UFOs

**Craft Purchase Options**:

| Craft Type | Cost | Karma | Fame | Special Features |
|------------|------|-------|------|------------------|
| **Black Interceptor** | 200,000 | -15 | -10 | +20% speed, stealth coating |
| **Modified Bomber** | 300,000 | -20 | -5 | +50% payload, illegal weapons |
| **Captured UFO** | 500,000 | -30 | +10 | Alien tech, intimidation factor |
| **Stealth Transport** | 250,000 | -15 | 0 | Undetectable by radar |

**Discovery Risk**: 10% chance per month that black market craft are discovered by authorities (-30 relations with discovering country).

---

### 4. Mission Generation (NEW)

**Purchase Custom Missions**: Players can buy specific mission types to spawn on the world map.

#### Mission Types Available

| Mission Type | Cost | Karma Impact | Description |
|--------------|------|--------------|-------------|
| **Assassination Contract** | 50,000 | -30 | Generate mission to eliminate specific political figure |
| **Sabotage Operation** | 40,000 | -20 | Destroy enemy facility or infrastructure |
| **Heist Mission** | 30,000 | -15 | Steal valuable items from secure location |
| **Kidnapping** | 35,000 | -25 | Capture VIP for interrogation or ransom |
| **False Flag Attack** | 60,000 | -40 | Frame another faction for attack |
| **Data Theft** | 25,000 | -10 | Steal intelligence from target |
| **Smuggling Run** | 20,000 | -5 | Transport illegal goods across borders |

#### Mission Generation Mechanics

**How It Works**:
1. Player pays cost to Black Market
2. Mission spawns on Geoscape within 3-7 days
3. Mission appears in target region/province
4. Completion rewards include: credits, items, karma change
5. Failure risks: discovery, relations loss, fame decrease

**Mission Rewards**:
- Base reward: 150-300% of purchase cost (profit potential)
- Special items exclusive to mission type
- Karma shift based on completion method
- Fame impact if mission is traced back to player

**Example**:
```
Purchase: Assassination Contract (50,000 credits, -30 karma)
Spawn: Mission "Eliminate Minister" in European province
Success: 120,000 credits reward, unique weapon, -10 relations with country
Failure: Mission exposed, -50 relations, -20 fame
```

---

### 5. Event Purchasing (NEW)

**Purchase Political/Economic Events**: Trigger specific world events through Black Market manipulation.

#### Available Events

| Event Type | Cost | Karma Impact | Effect Duration | Description |
|------------|------|--------------|----------------|-------------|
| **Improve Relations** | 30,000 | -10 | Permanent | +20 relations with target country |
| **Sabotage Economy** | 50,000 | -25 | 6 months | Target province economy level drops 1 tier |
| **Incite Rebellion** | 80,000 | -35 | 3 months | Target province becomes contested territory |
| **Spread Propaganda** | 20,000 | -5 | 3 months | +10 fame, target country relations +10 |
| **Frame Rival Faction** | 60,000 | -30 | Permanent | Target faction loses -30 relations with country |
| **Bribe Officials** | 40,000 | -15 | 6 months | Ignore black market transactions in region |
| **Crash Market** | 70,000 | -20 | 3 months | All items 30% cheaper in region |
| **False Intelligence** | 35,000 | -15 | Immediate | Generate fake UFO sighting, distract enemies |

#### Event Mechanics

**Triggering Events**:
1. Select event type from Black Market menu
2. Pay cost (immediate)
3. Karma penalty applied instantly
4. Event triggers within 1-3 days
5. Effects apply per event description

**Stacking Rules**:
- Cannot stack same event type in same region
- Maximum 3 active purchased events at once
- Some events conflict (cannot improve & sabotage same country)

**Discovery Risk**:
- 15% chance per active event to be discovered
- Discovery: -50 relations with affected country, -30 fame, criminal investigation

**Example**:
```
Purchase: Sabotage Economy in hostile territory (50,000 credits)
Effect: Province economy drops from "Thriving" to "Stable"
Result: Enemy faction income -30%, your operations easier
Risk: If discovered, war declaration possible
```

---

## Karma & Fame Impact

### Karma Changes from Black Market

**Transaction-Based Karma Loss**:

| Action | Karma Impact | Visibility |
|--------|--------------|-----------|
| Browse Black Market | 0 | Hidden |
| Purchase Item | -5 to -20 | Low chance discovery |
| Recruit Unit | -10 to -30 | Medium chance discovery |
| Purchase Craft | -15 to -30 | High chance discovery |
| Generate Mission | -10 to -40 | Medium chance discovery |
| Purchase Event | -10 to -35 | High chance discovery |
| Trade Corpse | -10 to -25 | Low chance discovery |

**Cumulative Effects**:
- 10+ Black Market transactions: -5 fame
- 25+ Black Market transactions: -15 fame, "Known Criminal" status
- 50+ Black Market transactions: -30 fame, "Crime Lord" reputation

### Fame Changes from Black Market

**Discovery Impacts**:

| Discovery Type | Fame Impact | Relations Impact |
|----------------|-------------|------------------|
| Item Purchase Discovered | -5 | -10 with 1 country |
| Unit Recruitment Discovered | -10 | -20 with 1 country |
| Craft Purchase Discovered | -15 | -30 with discovering country |
| Mission Traced Back | -20 | -40 with target country |
| Event Exposed | -30 | -50 with affected countries |

**Fame Recovery**:
- Complete 5 legitimate missions: +5 fame
- Public heroism: +10 fame (cancels some black market stigma)
- Time passage: +1 fame per 6 months if no black market activity

---

## Corpse Trading System (NEW)

### Corpse as Salvage Items

**Mechanics**:
- Dead units become "Corpse" items after battle
- Corpses occupy inventory slots (2 slots per corpse)
- Cannot be sold through normal marketplace
- Can only be sold through Black Market

### Corpse Types & Values

| Corpse Type | Base Value | Karma Impact | Black Market Demand |
|-------------|-----------|--------------|---------------------|
| **Human Soldier** | 5,000 | -10 | Organ trade, experiments |
| **Alien (Common)** | 15,000 | -15 | Research black market |
| **Alien (Rare)** | 50,000 | -25 | High-value specimens |
| **VIP/Hero** | 100,000 | -30 | Political leverage |
| **Mechanical Unit** | 8,000 | -5 | Scrap/parts market |

**Special Corpse Mechanics**:
- Fresh corpses (within 7 days): +50% value
- Preserved corpses (cryogenic storage): +100% value, requires facility
- Damaged corpses (explosions): -50% value
- Alien corpses can be researched OR sold (choice)

### Selling Corpses

**Process**:
1. Collect corpse from battlefield (post-battle salvage)
2. Store in base inventory (requires 2 slots per corpse)
3. Access Black Market → Corpse Trading section
4. Sell corpse for credits + karma penalty
5. Optional: Preserve corpse for higher value (requires Cold Storage facility)

**Ethical Considerations**:
- Selling human corpses: -10 karma per corpse
- Selling allied soldier corpses: -15 karma, -5 relations with country
- Selling civilian corpses: -20 karma, -10 fame if discovered
- Selling enemy corpses: -5 karma (minimal ethical concern)

**Discovery Consequences**:
- 5% chance per corpse sale to be discovered
- Discovery: -40 fame, "Body Trade" scandal
- All countries: -20 relations
- Public outcry: -30 fame immediately
- Can trigger special "Investigation" mission against player

### Alternative Corpse Uses

**Non-Black Market Options**:
- **Research**: Study for biological data (0 karma, scientific value)
- **Burial**: Proper disposal (0 karma, +5 morale to squad)
- **Preservation**: Store for future research (0 karma)
- **Ransom**: Return enemy corpses for payment (0 karma, +relations)

**Strategic Choice**:
```
Alien Corpse Options:
1. Sell to Black Market: 15,000 credits, -15 karma
2. Research: Unlock alien biology tech, 0 karma
3. Preserve: Store for later, 0 karma
4. Ransom to faction: 10,000 credits, +10 relations
```

---

## Supplier Integration

### Dual-Market Suppliers

Some suppliers operate in BOTH legitimate marketplace AND Black Market:

| Supplier Name | Marketplace Access | Black Market Access | Karma Requirements |
|---------------|-------------------|---------------------|-------------------|
| **Military Supply Corp** | Yes (legal items) | No | Any karma |
| **Syndicate Trade Co.** | Yes (gray market) | Yes (illegal items) | Karma < +40 |
| **Exotic Arms Dealer** | Yes (alien tech) | Yes (banned weapons) | Karma < +10 |
| **Research Materials Ltd** | Yes (components) | No | Any karma |
| **Tactical Supply Network** | Yes (armor) | No | Any karma |
| **Black Market Operations** | No | Yes (everything) | Karma < 0 |
| **Shadow Broker** | No | Yes (services) | Karma < -40 |
| **Corpse Traders** | No | Yes (bodies only) | Karma < -25 |

### Supplier Availability Gates

**Karma-Based Access**:

| Supplier | Min Karma | Max Karma | Access Restrictions |
|----------|-----------|-----------|---------------------|
| **Syndicate Trade Co.** | -100 | +40 | Blocked if Saint alignment |
| **Exotic Arms Dealer** | -100 | +10 | Requires famous status |
| **Black Market Operations** | -100 | 0 | Blocked if positive karma |
| **Shadow Broker** | -100 | -40 | Only ruthless/evil players |
| **Corpse Traders** | -100 | -25 | Requires multiple corpse sales |

**Fame-Based Access**:

| Supplier | Min Fame | Max Fame | Reason |
|----------|----------|----------|--------|
| **Syndicate Trade Co.** | 25 | 100 | Need reputation to find |
| **Exotic Arms Dealer** | 60 | 100 | Exclusive high-profile clients |
| **Black Market Operations** | 25 | 100 | Need to be "known" |
| **Shadow Broker** | 75 | 100 | Only deals with famous criminals |

### Relationship with Black Market Suppliers

**Building Relations**:
- Each purchase: +1 relation with supplier
- Large purchases (50,000+): +3 relation
- Repeat customer (10+ purchases): +5 relation bonus
- Failed payment: -20 relation

**Relation Benefits**:
- +50 relation: 10% discount on all items
- +75 relation: Access to exclusive items
- +100 relation: 25% discount, priority access, early warnings

**Relation Penalties**:
- Betrayal (informing authorities): -100 relation, permanent ban
- Failed missions: -10 relation per failure
- Publicizing deals: -50 relation

---

## Risk & Consequences

### Discovery Mechanics

**Discovery Chance Per Transaction**:

| Transaction Type | Base Discovery % | Modifiers |
|------------------|------------------|-----------|
| Item Purchase | 5% | +2% per 10 fame above 50 |
| Unit Recruitment | 10% | +5% per black market unit owned |
| Craft Purchase | 15% | +10% if craft deployed |
| Mission Generation | 8% | +5% if mission fails |
| Event Purchase | 12% | +8% if event affects major power |
| Corpse Sale | 5% | +3% per human corpse |

**Cumulative Risk**:
- 1-5 transactions: Normal risk
- 6-15 transactions: +5% discovery chance
- 16-30 transactions: +10% discovery chance
- 31+ transactions: +15% discovery chance, "Under Investigation" status

### Consequences of Discovery

**Immediate Effects**:
- Fame: -20 to -50 (severity-based)
- Relations: -30 to -70 with discovering country
- Karma: -10 additional penalty
- Funding: -20% from discovering country

**Investigation Missions**:
- 30% chance to trigger "Investigation" mission
- Authorities raid your base
- Must defend or cooperate
- Cooperation: Give up Black Market contact, lose access
- Resistance: Combat mission, maintain access if win

**Long-Term Consequences**:
- "Criminal Organization" reputation (persists 12 months)
- All countries: -10 relations
- Marketplace prices: +20% (stigma tax)
- Random inspections: 10% chance per month

### Mitigation Strategies

**Reducing Discovery Risk**:
- **Bribe Officials** event: -50% discovery chance in region (6 months)
- **Cover Operations**: Spend 10,000 credits per transaction to reduce risk by 50%
- **Low Profile**: Keep fame below 60 (-5% discovery chance)
- **Limited Transactions**: Maximum 2 per month (cumulative risk resets)

**Damage Control After Discovery**:
- **Public Relations Campaign**: 50,000 credits, +10 fame restoration
- **Diplomatic Apology**: Give up 1 black market unit, +20 relations
- **Scapegoat**: Blame rogue operative, -5 karma, relations restored 50%
- **Evidence Destruction**: 80,000 credits, 70% chance to erase discovery

---

## Strategic Integration

### When to Use Black Market

**Optimal Scenarios**:
- Need specific unit type unavailable elsewhere
- Must counter enemy faction with unique equipment
- Economic manipulation to weaken rivals
- Political event timing critical for strategy
- Corpse trading for emergency funds

**High-Risk, High-Reward**:
- Black Market accelerates progression at karma/fame cost
- Can turn losing campaign into winning one
- Enables "evil playthrough" strategies
- Unlocks unique story paths and endings

### Balancing Act

**Karma Management**:
- Use Black Market sparingly to stay above critical thresholds
- Balance with humanitarian missions (+karma)
- Accept that some endings require low karma

**Fame Management**:
- Keep fame high enough for Black Market access
- But not so high that discovery is guaranteed
- "Sweet spot": 60-75 fame, -20 to -40 karma

---

## Implementation Notes

**Data Structure**:
```lua
BlackMarket = {
  access_level = "standard", -- restricted, standard, enhanced, complete
  discovery_risk = 0.05, -- 5% base
  active_events = {}, -- purchased events
  transaction_count = 0,
  last_discovery = nil, -- turn number
  supplier_relations = {
    syndicate = 0,
    exotic_arms = 0,
    black_ops = 0,
    shadow_broker = 0,
    corpse_traders = 0
  }
}
```

**Integration Points**:
- Economy.md: Marketplace system
- Politics.md: Karma/Fame systems
- Items.md: Corpse items
- Units.md: Black market unit recruitment
- Geoscape.md: Mission generation, event triggering

---

**Last Updated**: 2025-10-28  
**Version**: 1.0  
**Status**: Complete Design Specification

