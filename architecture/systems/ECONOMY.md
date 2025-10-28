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

## Performance Metrics

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| **Monthly Net Income** | > $500k | < $200k | < $0 |
| **Cash Reserve** | > $2M | < $500k | < $100k |
| **Asset Value** | > $10M | < $5M | < $2M |
| **Expense Ratio** | < 60% | > 80% | > 100% |
| **Nation Satisfaction** | > 70% | < 50% | < 30% |

---

**End of Economy System Architecture**

