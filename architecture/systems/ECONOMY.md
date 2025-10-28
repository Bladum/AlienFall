# Economy System Architecture

**System:** Economy & Finance  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The economy system manages finances, resources, marketplace transactions, and economic balance across all game systems.

---

## Economy Flow

```mermaid
graph TB
    subgraph "Income Sources"
        Funding[Monthly Funding]
        Sales[Marketplace Sales]
        Salvage[Mission Salvage]
        BlackMarket[Black Market]
    end
    
    subgraph "Treasury"
        Balance[Current Balance]
        History[Transaction History]
    end
    
    subgraph "Expenses"
        BaseMaint[Base Maintenance]
        Salaries[Personnel Salaries]
        Construction[Facility Construction]
        Manufacturing[Production Costs]
        Purchases[Market Purchases]
    end
    
    subgraph "Economic Events"
        Bonus[Mission Success Bonus]
        Penalty[Nation Panic Penalty]
        Crisis[Economic Crisis]
    end
    
    Funding --> Balance
    Sales --> Balance
    Salvage --> Balance
    BlackMarket --> Balance
    
    Bonus --> Funding
    Penalty --> Funding
    Crisis --> Balance
    
    Balance --> BaseMaint
    Balance --> Salaries
    Balance --> Construction
    Balance --> Manufacturing
    Balance --> Purchases
    
    BaseMaint --> History
    Salaries --> History
    Construction --> History
    Manufacturing --> History
    Purchases --> History
    
    style Balance fill:#FFD700
    style Bonus fill:#90EE90
    style Penalty fill:#FF6B6B
```

---

## Monthly Financial Cycle

```mermaid
sequenceDiagram
    participant Calendar
    participant Nations
    participant Treasury
    participant Bases
    participant Personnel
    participant Player
    
    Note over Calendar: Month End
    
    Calendar->>Nations: Process Nation Funding
    
    loop For Each Nation
        Nations->>Nations: base_funding × (1 - panic_factor)
        Nations->>Treasury: Transfer Funds
    end
    
    Nations-->>Calendar: Total: $2,450,000
    
    Calendar->>Bases: Calculate Maintenance
    
    loop For Each Base
        Bases->>Bases: Sum facility costs
        Bases->>Treasury: Deduct Maintenance
    end
    
    Bases-->>Calendar: Total: -$350,000
    
    Calendar->>Personnel: Calculate Salaries
    
    Personnel->>Personnel: Sum all personnel
    Personnel->>Treasury: Deduct Salaries
    
    Personnel-->>Calendar: Total: -$580,000
    
    Calendar->>Treasury: Calculate Net Balance
    Treasury-->>Calendar: Net: +$1,520,000
    
    Calendar->>Player: Show Monthly Report
    
    Player->>Player: Review Finances
```

---

## Resource Management

```mermaid
erDiagram
    TREASURY {
        int balance
        table transaction_history
        int monthly_income
        int monthly_expenses
    }
    
    RESOURCE {
        string id PK
        string name
        int quantity
        int storage_capacity
        int market_value
    }
    
    TRANSACTION {
        string id PK
        string type
        int amount
        string date
        string source
        string description
    }
    
    MARKET_PRICE {
        string item_id PK
        int buy_price
        int sell_price
        int supply
        int demand
    }
    
    TREASURY ||--o{ TRANSACTION : "records"
    RESOURCE ||--|| MARKET_PRICE : "has_price"
```

---

## Marketplace System

```mermaid
graph TD
    Market[Marketplace] --> Suppliers[Suppliers]
    
    Suppliers --> Military[Military Surplus<br/>Weapons, Armor]
    Suppliers --> Tech[Tech Vendors<br/>Electronics, Parts]
    Suppliers --> Medical[Medical Supply<br/>Medikits, Drugs]
    Suppliers --> BlackMkt[Black Market<br/>Alien Tech, Rare Items]
    
    Military --> Inventory[Player Inventory]
    Tech --> Inventory
    Medical --> Inventory
    BlackMkt --> Inventory
    
    Inventory --> SellBack[Sell Items]
    
    SellBack --> PriceCalc[Price = 50% Buy Value]
    PriceCalc --> Treasury[Add to Treasury]
    
    Treasury --> BuyNew[Purchase New Items]
    BuyNew --> Military
    
    style Market fill:#FFD700
    style Military fill:#90EE90
    style BlackMkt fill:#E0BBE4
    style Treasury fill:#87CEEB
```

### Market Pricing Table

| Item Category | Buy Price | Sell Price | Availability |
|--------------|-----------|------------|--------------|
| **Basic Weapons** | $1,000 - $5,000 | 50% | Always |
| **Advanced Weapons** | $10,000 - $50,000 | 50% | Tech required |
| **Basic Armor** | $2,000 - $8,000 | 50% | Always |
| **Advanced Armor** | $15,000 - $80,000 | 50% | Tech required |
| **Equipment** | $500 - $5,000 | 50% | Always |
| **Alien Artifacts** | N/A | $10,000 - $100,000 | Mission loot |
| **Alien Corpses** | N/A | $2,000 - $20,000 | Mission loot |
| **Live Aliens** | N/A | $50,000 - $200,000 | Mission capture |

---

## Salvage System

```mermaid
graph LR
    Mission[Mission Complete] --> Loot[Generate Loot]
    
    Loot --> UFO[UFO Parts]
    Loot --> Alien[Alien Equipment]
    Loot --> Corps[Alien Corpses]
    Loot --> Artifacts[Artifacts]
    
    UFO --> Evaluate[Evaluate Value]
    Alien --> Evaluate
    Corps --> Evaluate
    Artifacts --> Evaluate
    
    Evaluate --> Choice{Player Choice}
    
    Choice --> Keep[Keep for Research]
    Choice --> Sell[Sell to Market]
    
    Keep --> Storage[Add to Storage]
    Sell --> Revenue[Generate Revenue]
    
    Revenue --> Treasury[Add to Balance]
    
    Storage --> ResearchMaterial[Research Input]
    Storage --> MfgMaterial[Manufacturing Input]
    
    style Mission fill:#90EE90
    style Revenue fill:#87CEEB
    style Evaluate fill:#FFD700
```

---

## Budget Allocation

```mermaid
graph TD
    MonthlyIncome[Monthly Income<br/>$2,450,000] --> Allocation[Budget Allocation]
    
    Allocation --> Reserve[Reserve Fund<br/>20%: $490,000]
    Allocation --> Operations[Operations<br/>40%: $980,000]
    Allocation --> Development[Development<br/>25%: $612,500]
    Allocation --> Emergency[Emergency Fund<br/>15%: $367,500]
    
    Operations --> Salaries[Personnel Salaries]
    Operations --> Maintenance[Base Maintenance]
    Operations --> FuelAmmo[Fuel & Ammunition]
    
    Development --> Research[Research Projects]
    Development --> Construction[New Facilities]
    Development --> Manufacturing[Item Production]
    
    Emergency --> Contingency[Unexpected Costs]
    Emergency --> BaseDamage[Base Repairs]
    Emergency --> Recruitment[Emergency Hiring]
    
    style MonthlyIncome fill:#90EE90
    style Reserve fill:#87CEEB
    style Operations fill:#FFD700
    style Development fill:#E0BBE4
    style Emergency fill:#FF6B6B
```

---

## Economic Crisis Events

```mermaid
stateDiagram-v2
    [*] --> Normal: Stable Economy
    
    Normal --> Warning: Balance < $500k
    Normal --> Crisis: Balance < $100k
    
    Warning --> Normal: Income Increase
    Warning --> Crisis: Continued Deficit
    
    state Crisis {
        [*] --> Cuts
        Cuts --> FirePersonnel: Reduce Salaries
        Cuts --> SellAssets: Liquidate Inventory
        Cuts --> CloseBase: Shut Down Base
        
        FirePersonnel --> [*]
        SellAssets --> [*]
        CloseBase --> [*]
    }
    
    Crisis --> Bankruptcy: Balance < $0
    Crisis --> Recovery: Positive Income
    
    Recovery --> Normal
    
    Bankruptcy --> GameOver: Campaign Failure
```

---

## Financial Reports

```mermaid
graph TD
    Report[Monthly Report] --> Income[Income Summary]
    Report --> Expenses[Expense Summary]
    Report --> Assets[Asset Summary]
    Report --> Forecast[Financial Forecast]
    
    Income --> Nations[Nation Funding: $2.45M]
    Income --> Sales[Item Sales: $150k]
    Income --> Salvage[Mission Salvage: $200k]
    
    Expenses --> BaseCost[Base Costs: $350k]
    Expenses --> Personnel[Personnel: $580k]
    Expenses --> Other[Other Expenses: $120k]
    
    Assets --> Cash[Cash: $1.8M]
    Assets --> Inventory[Inventory Value: $3.2M]
    Assets --> Facilities[Facility Value: $15M]
    
    Forecast --> Next3Months[3-Month Projection]
    Forecast --> Warnings[Financial Warnings]
    
    style Report fill:#FFD700
    style Income fill:#90EE90
    style Expenses fill:#FF6B6B
    style Assets fill:#87CEEB
```

---

## Pricing Algorithm

```mermaid
graph LR
    Item[Item Base Value] --> Factors[Price Factors]
    
    Factors --> Rarity[Rarity Multiplier<br/>×1.0 - ×5.0]
    Factors --> Tech[Tech Level<br/>×1.0 - ×3.0]
    Factors --> Supply[Supply/Demand<br/>×0.5 - ×2.0]
    
    Rarity --> Calculate[Calculate Price]
    Tech --> Calculate
    Supply --> Calculate
    
    Calculate --> BuyPrice[Buy Price = Base × Factors]
    Calculate --> SellPrice[Sell Price = Buy × 0.5]
    
    BuyPrice --> Display[Display to Player]
    SellPrice --> Display
    
    style Item fill:#90EE90
    style Calculate fill:#FFD700
    style Display fill:#87CEEB
```

---

## Economic Balance Tuning

| Phase | Average Income | Average Expenses | Target Balance | Difficulty |
|-------|---------------|------------------|----------------|------------|
| **Early (Months 1-3)** | $800k/month | $400k/month | $1-2M | Easy |
| **Mid (Months 4-8)** | $2.5M/month | $1.5M/month | $5-8M | Medium |
| **Late (Months 9-12)** | $4M/month | $3M/month | $10-15M | Hard |
| **End Game (13+)** | $5M/month | $4M/month | $20M+ | Hardest |

---

## Transaction System

```mermaid
sequenceDiagram
    participant Player
    participant UI
    participant Economy
    participant Treasury
    participant Inventory
    
    Player->>UI: Initiate Transaction
    UI->>Economy: Request Price
    Economy-->>UI: Display Price
    
    Player->>UI: Confirm Transaction
    
    alt Purchase
        UI->>Treasury: Check Balance >= Price
        
        alt Sufficient Funds
            Treasury->>Treasury: Deduct Amount
            Treasury-->>UI: Transaction OK
            UI->>Inventory: Add Item
            Inventory-->>UI: Item Added
            UI-->>Player: Purchase Complete
        else Insufficient Funds
            Treasury-->>UI: Error: Not Enough Funds
            UI-->>Player: Cannot Afford
        end
        
    else Sale
        UI->>Inventory: Check Item Exists
        
        alt Item Available
            Inventory->>Inventory: Remove Item
            Inventory-->>UI: Item Removed
            UI->>Treasury: Add Revenue
            Treasury-->>UI: Funds Added
            UI-->>Player: Sale Complete
        else Item Not Found
            Inventory-->>UI: Error: Item Not Found
            UI-->>Player: Cannot Sell
        end
    end
```

---

## Black Market System

**Module**: `engine/economy/marketplace/black_market_system.lua`  
**Status**: Expanded with 5 service categories  
**Related**: `design/mechanics/BlackMarket.md`

### Black Market Architecture

```mermaid
graph TB
    subgraph "Access Control"
        KARMA[Karma System<br/>-100 to +100]
        FAME[Fame System<br/>0 to 100]
        ACCESS_TIER[Access Tier<br/>restricted/standard/<br/>enhanced/complete]
    end
    
    subgraph "Service Categories"
        ITEMS[Restricted Items<br/>200-500% markup]
        UNITS[Special Units<br/>Mercenaries, Defectors]
        CRAFT[Special Craft<br/>Stolen Military]
        MISSIONS[Mission Generation<br/>7 types]
        EVENTS[Event Purchasing<br/>8 types]
        CORPSES[Corpse Trading<br/>5 types]
    end
    
    subgraph "Transaction Processing"
        PURCHASE[Purchase Request]
        KARMA_CHECK[Karma Penalty<br/>-5 to -40]
        DISCOVERY[Discovery Check<br/>5-15% risk]
        PAYMENT[Credit Deduction]
        DELIVERY[Service Delivery]
    end
    
    subgraph "Consequences"
        KARMA_LOSS[Karma Reduction]
        FAME_LOSS[Fame Damage<br/>-20 to -50 if discovered]
        RELATIONS[Relations Penalty<br/>-30 to -70]
        INVESTIGATION[Investigation Mission]
    end
    
    KARMA --> ACCESS_TIER
    FAME --> ACCESS_TIER
    ACCESS_TIER --> ITEMS
    ACCESS_TIER --> UNITS
    ACCESS_TIER --> CRAFT
    ACCESS_TIER --> MISSIONS
    ACCESS_TIER --> EVENTS
    ACCESS_TIER --> CORPSES
    
    ITEMS --> PURCHASE
    UNITS --> PURCHASE
    CRAFT --> PURCHASE
    MISSIONS --> PURCHASE
    EVENTS --> PURCHASE
    CORPSES --> PURCHASE
    
    PURCHASE --> KARMA_CHECK
    KARMA_CHECK --> DISCOVERY
    DISCOVERY --> PAYMENT
    PAYMENT --> DELIVERY
    
    KARMA_CHECK --> KARMA_LOSS
    DISCOVERY --> FAME_LOSS
    DISCOVERY --> RELATIONS
    DISCOVERY --> INVESTIGATION
```

### Transaction Flow

```mermaid
sequenceDiagram
    participant Player
    participant BlackMarket
    participant KarmaSystem
    participant FameSystem
    participant Treasury
    participant Geoscape
    
    Player->>BlackMarket: Request service
    BlackMarket->>KarmaSystem: Check access level
    KarmaSystem-->>BlackMarket: Access tier
    
    alt Access Granted
        BlackMarket->>Treasury: Check funds
        
        alt Sufficient Funds
            Treasury-->>BlackMarket: Funds available
            BlackMarket->>KarmaSystem: Apply karma penalty
            KarmaSystem-->>BlackMarket: Karma updated
            
            BlackMarket->>BlackMarket: Roll for discovery
            
            alt Discovered
                BlackMarket->>FameSystem: Apply fame penalty
                BlackMarket->>Geoscape: Reduce relations
                BlackMarket->>Geoscape: Trigger investigation
                FameSystem-->>Player: Discovery consequences
            else Not Discovered
                BlackMarket-->>Player: Transaction complete
            end
            
            BlackMarket->>Treasury: Deduct payment
            BlackMarket->>Player: Deliver service
            
        else Insufficient Funds
            Treasury-->>Player: Cannot afford
        end
        
    else Access Denied
        BlackMarket-->>Player: Karma/fame too low
    end
```

### Service Categories Detail

#### 1. Mission Generation

**Module**: `engine/economy/mission_generation.lua`

**Mission Types**:
- Assassination (50K, -30 karma)
- Sabotage (40K, -20 karma)
- Heist (30K, -15 karma)
- Kidnapping (35K, -25 karma)
- False Flag (60K, -40 karma)
- Data Theft (25K, -10 karma)
- Smuggling (20K, -5 karma)

**Process**:
1. Player pays cost
2. Karma penalty applied immediately
3. Mission spawns on Geoscape in 3-7 days
4. Mission appears in target region
5. Completion: 150-300% profit potential
6. Failure: Traced back to player (-50 relations)

#### 2. Event Purchasing

**Module**: `engine/economy/event_purchasing.lua`

**Event Types**:
- Improve Relations (30K, -10 karma, +20 relations)
- Sabotage Economy (50K, -25 karma, drops economy tier)
- Incite Rebellion (80K, -35 karma, province contested 3 months)
- Spread Propaganda (20K, -5 karma, +10 fame +10 relations)
- Frame Rival (60K, -30 karma, rival -30 relations)
- Bribe Officials (40K, -15 karma, ignore activity 6 months)
- Crash Market (70K, -20 karma, 30% cheaper items 3 months)
- False Intelligence (35K, -15 karma, fake UFO sighting)

**Process**:
1. Player selects event and target
2. Payment and karma penalty
3. Event triggers in 1-3 days
4. Effects apply per event type
5. Duration: 3-6 months or permanent
6. Discovery risk: 12%

#### 3. Corpse Trading

**Module**: `engine/economy/corpse_trading.lua`

**Corpse Types & Values**:
- Human Soldier: 5K, -10 karma
- Alien Common: 15K, -15 karma
- Alien Rare: 50K, -25 karma
- VIP/Hero: 100K, -30 karma
- Mechanical: 8K, -5 karma

**Modifiers**:
- Fresh (+50% value, < 7 days)
- Preserved (+100% value, cryogenic)
- Damaged (-50% value, explosion)

**Process**:
1. Corpse collected from battlefield
2. Stored as item (2 slots)
3. Sold through Black Market
4. Karma penalty applied
5. Discovery risk: 5%

**Alternatives** (0 karma):
- Research (unlock biology tech)
- Burial (+5 morale to squad)
- Ransom (+relations with faction)

#### 4. Special Units

**Unit Types**:
- Elite Mercenary (50K, -10 karma)
- Alien Defector (80K, -15 karma)
- Augmented Soldier (120K, -25 karma)
- Master Assassin (150K, -30 karma)
- Clone Trooper (100K, -20 karma)

**Restrictions**:
- Maximum 3 per base
- Cannot use in diplomatic missions
- Discovery: -20 relations if found

#### 5. Special Craft

**Craft Types**:
- Black Interceptor (200K, -15 karma, +20% speed)
- Modified Bomber (300K, -20 karma, +50% payload)
- Captured UFO (500K, -30 karma, alien tech)
- Stealth Transport (250K, -15 karma, undetectable)

**Discovery Risk**: 10% per month if deployed

### Access Tier System

| Karma Range | Fame Range | Access Level | Available Services |
|-------------|-----------|--------------|-------------------|
| +40 to +10 | 25-59 | **Restricted** | Items only |
| +9 to -39 | 25-100 | **Standard** | Items, Units, some Services |
| -40 to -74 | 60-100 | **Enhanced** | All except extreme |
| -75 to -100 | 75-100 | **Complete** | Everything |

### Discovery System

**Base Discovery Chances**:
- Item purchase: 5%
- Unit recruitment: 10%
- Craft purchase: 15%
- Mission generation: 8%
- Event purchasing: 12%
- Corpse trading: 5%

**Modifiers**:
- +2% per 10 fame above 50
- +5% per black market unit owned
- +10% if black market craft deployed
- +5% per active event
- +3% per human corpse sold

**Cumulative Risk**:
- 1-5 transactions: Normal risk
- 6-15 transactions: +5% discovery
- 16-30 transactions: +10% discovery
- 31+ transactions: +15% discovery

**Consequences**:
- Fame: -20 to -50
- Relations: -30 to -70 with discovering country
- Karma: -10 additional
- Investigation mission: 30% chance

### Integration Points

**With Karma System**:
- Check karma before allowing access
- Apply karma penalties per transaction
- Update access tier dynamically

**With Fame System**:
- Check fame for discovery visibility
- Apply fame penalties on discovery
- Update reputation status

**With Geoscape**:
- Spawn generated missions on map
- Apply event effects to provinces/countries
- Trigger investigation missions

**With Relations System**:
- Apply relation penalties on discovery
- Update diplomatic status
- Trigger sanctions/embargos

---

## Performance Metrics

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| **Monthly Net Income** | > $500k | < $200k | < $0 |
| **Cash Reserve** | > $2M | < $500k | < $100k |
| **Asset Value** | > $10M | < $5M | < $2M |
| **Expense Ratio** | < 60% | > 80% | > 100% |
| **Nation Satisfaction** | > 70% | < 50% | < 30% |
| **Black Market Risk** | < 20% | > 40% | > 60% |
| **Karma Level** | > -40 | < -75 | -100 |

---

**End of Economy System Architecture**

