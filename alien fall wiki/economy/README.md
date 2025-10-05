# Economy Overview

The economy powers every AlienFall system—from soldier wages to late-game plasma cannons. This README consolidates manufacturing, marketplace, research, and logistics into a single Love2D-facing reference.

## Role in AlienFall
- Provide deterministic resource flows that reward long-term planning.
- Gate technological progress and equipment upgrades through research and suppliers.
- Tie campaign performance directly to funding, debt, and strategic options.

## Player Experience Goals
- **Transparent budgets:** Players know how much projects cost now and later.
- **Meaningful choices:** Manufacturing, purchasing, and research compete for the same resources.
- **Fair progression:** Access to advanced gear is earned through visible milestones, not unpredictable drops.

## System Boundaries
- Covers funding, income sources, black market, manufacturing, research, supplier stocking, and inter-base transfers.
- Interfaces with basescape (workshops, labs), units (equipment), items (recipes, stats), finance (reports), and organization (reputation).

---

## Economy System Diagrams

### Monthly Economic Cycle

```mermaid
graph TB
    START[Month Start] --> INCOME[Calculate Income]
    
    INCOME --> FUND[Primary Funding<br/>Country satisfaction]
    INCOME --> CONTRACT[Contract Rewards<br/>Mission bonuses]
    INCOME --> MARKET[Marketplace Sales<br/>Manufactured goods]
    INCOME --> BLACK[Black Market<br/>High-risk sales]
    INCOME --> INTEREST[Reserve Interest<br/>Savings bonus]
    
    FUND --> TOTAL[Total Income]
    CONTRACT --> TOTAL
    MARKET --> TOTAL
    BLACK --> TOTAL
    INTEREST --> TOTAL
    
    TOTAL --> EXPENSE[Calculate Expenses]
    
    EXPENSE --> SALARY[Personnel Salaries<br/>40% of budget]
    EXPENSE --> MAINT[Facility Maintenance<br/>30% of budget]
    EXPENSE --> MFG[Manufacturing Costs<br/>20% of budget]
    EXPENSE --> MISC[Miscellaneous<br/>10% of budget]
    
    SALARY --> TOTAL_EXP[Total Expenses]
    MAINT --> TOTAL_EXP
    MFG --> TOTAL_EXP
    MISC --> TOTAL_EXP
    
    TOTAL_EXP --> DEBT_CHECK{Outstanding Debt?}
    
    DEBT_CHECK -->|Yes| DEBT_PAY[Deduct Debt Payment<br/>+ Interest]
    DEBT_CHECK -->|No| NET
    
    DEBT_PAY --> NET[Calculate Net]
    NET --> SURPLUS{Surplus or Deficit?}
    
    SURPLUS -->|Positive| SAVE[Add to Reserves]
    SURPLUS -->|Negative| BORROW[Take on Debt<br/>Or sell assets]
    
    SAVE --> REPORT[Monthly Report]
    BORROW --> REPORT
    REPORT --> SCORE[Update Score]
    SCORE --> NEXT[Next Month]
    
    style TOTAL fill:#50c878
    style TOTAL_EXP fill:#e24a4a
    style SAVE fill:#4a90e2
    style BORROW fill:#ff6b6b
```

### Research Tree Flow

```mermaid
graph TB
    START[Research System] --> UNLOCK[Check Unlocked Research]
    
    UNLOCK --> AVAIL{Available Research?}
    AVAIL -->|No| WAIT[Wait for Unlock Conditions]
    AVAIL -->|Yes| SELECT[Player Selects Project]
    
    SELECT --> PREREQ{Prerequisites Met?}
    PREREQ -->|No| BLOCK[Cannot Start]
    PREREQ -->|Yes| COST{Credits Available?}
    
    COST -->|No| BLOCK
    COST -->|Yes| START_RES[Start Research]
    
    START_RES --> LAB[Assign Scientists]
    LAB --> PROGRESS[Daily Progress]
    
    PROGRESS --> CALC[Hours = Scientists × 10]
    CALC --> ACCUM[Accumulate Hours]
    
    ACCUM --> CHECK{Complete?}
    CHECK -->|No| PROGRESS
    CHECK -->|Yes| FINISH[Research Complete]
    
    FINISH --> UNLOCK_ITEMS[Unlock Items]
    FINISH --> UNLOCK_FAC[Unlock Facilities]
    FINISH --> UNLOCK_RES[Unlock New Research]
    FINISH --> STORY[Trigger Story Events]
    
    UNLOCK_ITEMS --> NEXT[Next Research]
    UNLOCK_FAC --> NEXT
    UNLOCK_RES --> NEXT
    STORY --> NEXT
    NEXT --> UNLOCK
    
    WAIT --> MISSION[Complete Missions]
    MISSION --> SALVAGE[Collect Salvage]
    SALVAGE --> TRIGGER[Trigger Unlocks]
    TRIGGER --> UNLOCK
    
    style START_RES fill:#4a90e2
    style FINISH fill:#50c878
    style BLOCK fill:#ff6b6b
```

### Manufacturing Pipeline

```mermaid
graph LR
    subgraph "Project Start"
        SELECT[Select Recipe]
        CHECK[Check Requirements]
        QUEUE[Add to Queue]
    end
    
    subgraph "Requirements"
        MAT[Materials Available?]
        CRED[Credits Available?]
        WORK[Workshop Capacity?]
        TECH[Tech Unlocked?]
    end
    
    subgraph "Production"
        ASSIGN[Assign Engineers]
        PRODUCE[Daily Production]
        HOURS[Man-Hours × Engineers]
        PROGRESS[Accumulate Progress]
    end
    
    subgraph "Completion"
        FINISH[Project Complete]
        STORE[Store in Base]
        SELL[Sell to Market]
        EQUIP[Equip on Units]
    end
    
    SELECT --> CHECK
    CHECK --> MAT
    CHECK --> CRED
    CHECK --> WORK
    CHECK --> TECH
    
    MAT --> QUEUE
    CRED --> QUEUE
    WORK --> QUEUE
    TECH --> QUEUE
    
    QUEUE --> ASSIGN
    ASSIGN --> PRODUCE
    PRODUCE --> HOURS
    HOURS --> PROGRESS
    
    PROGRESS --> CHECK_DONE{Complete?}
    CHECK_DONE -->|No| PRODUCE
    CHECK_DONE -->|Yes| FINISH
    
    FINISH --> STORE
    FINISH --> SELL
    FINISH --> EQUIP
    
    style FINISH fill:#50c878
    style QUEUE fill:#4a90e2
```

### Resource Flow Diagram

```mermaid
graph TB
    subgraph "Income Sources"
        FUND[Monthly Funding<br/>$100K-300K]
        MISSION[Mission Rewards<br/>$5K-50K]
        SALES[Manufacturing Sales<br/>Variable]
        BLACK_M[Black Market<br/>High risk/reward]
    end
    
    subgraph "Central Treasury"
        RESERVES[Reserve Balance]
        DEBT_LEDGER[Debt Ledger]
    end
    
    subgraph "Expense Sinks"
        PAYROLL[Personnel Salaries<br/>Monthly]
        FACILITIES[Facility Costs<br/>Maintenance]
        MATERIALS[Manufacturing<br/>Materials]
        RESEARCH_COST[Research<br/>Credits]
        PURCHASES[Supplier Purchases<br/>Equipment]
    end
    
    subgraph "Asset Flow"
        SALVAGE[Mission Salvage]
        STORAGE[Base Storage]
        EQUIPPED[Unit Equipment]
        MARKET_GOODS[Market Inventory]
    end
    
    FUND --> RESERVES
    MISSION --> RESERVES
    SALES --> RESERVES
    BLACK_M --> RESERVES
    
    RESERVES --> PAYROLL
    RESERVES --> FACILITIES
    RESERVES --> MATERIALS
    RESERVES --> RESEARCH_COST
    RESERVES --> PURCHASES
    
    DEBT_LEDGER --> PAYROLL
    
    SALVAGE --> STORAGE
    STORAGE --> EQUIPPED
    STORAGE --> MATERIALS
    STORAGE --> MARKET_GOODS
    MARKET_GOODS --> SALES
    
    PURCHASES --> STORAGE
    
    style RESERVES fill:#50c878
    style DEBT_LEDGER fill:#ff6b6b
    style SALVAGE fill:#f5a623
```

### Supplier & Market System

```mermaid
stateDiagram-v2
    [*] --> GlobalMarket: Game Start
    
    GlobalMarket --> CheckStock: Monthly Refresh
    CheckStock --> GenerateStock: Deterministic Seed
    
    GenerateStock --> RegionalSupplier: Region-specific items
    GenerateStock --> MilitarySupplier: Reputation gate
    GenerateStock --> CorporateSupplier: Contract-based
    GenerateStock --> BlackMarket: High-risk items
    
    RegionalSupplier --> Available: Stock Ready
    MilitarySupplier --> Available
    CorporateSupplier --> Available
    BlackMarket --> Available
    
    Available --> Purchase: Player Buys
    Purchase --> Transfer: Create Transfer
    Transfer --> Delivery: Travel Time
    Delivery --> BaseStorage: Arrived
    
    Available --> Refresh: Month End
    Refresh --> CheckStock
    
    BlackMarket --> DetectionRoll: Purchase Attempt
    DetectionRoll --> AlertIncrease: Failed
    DetectionRoll --> Purchase: Success
    
    AlertIncrease --> OrgPenalty: Reputation Loss
    OrgPenalty --> Available
```

---

## Core Mechanics
### Funding & Income
- Monthly funding calculated from country satisfaction, score, and outstanding debt.
- Income sources: primary funding, contracts, marketplace profits, black market, and interest on reserve funds.
- Debt system offers short-term relief at escalating interest rates; failure to pay triggers penalties and story events.

### Research & Technology Tree
- Research entries are atomic TOML rows with prerequisites, cost (in research-hours), and unlock payloads (items, facilities, story beats).
- Directed acyclic graph ensures deterministic unlock paths. Branching choices record tags (e.g., `laser_focus`, `armor_focus`) for downstream content.
- Research progress ticks daily, consuming lab capacity tracked by the basescape.

### Manufacturing & Supplies
- Manufacturing projects consume materials, credits, and man-hours. Queues support priority reordering and partial progress saves.
- Suppliers provide curated stock lists with regional availability and reputation gates. Stock refreshes monthly using deterministic seeds keyed to supplier id + month.
- Black market ignores reputation but adds detection risk; higher risk raises alert level, feeding into organization and finance systems.

### Logistics & Transfers
- Transfers move items, units, and crafts between bases using deterministic travel times (province hops × craft speed).
- Cargo reservations ensure storage capacity at origin and destination; overflow policies set by basescape.
- All logistics events emit telemetry for replay and debugging.

## Implementation Hooks
- **Data Tables:**
	- `data/economy/funding.toml` – formulas for monthly payouts and debt interest.
	- `data/economy/research.toml` – research entries, tags, unlock payloads.
	- `data/economy/manufacturing.toml` – recipes, costs, requirements.
	- `data/economy/suppliers.toml` – vendor inventories, refresh rules.
- **Event Bus:** `economy:funding_paid`, `economy:debt_accrued`, `economy:research_progressed`, `economy:manufacturing_completed`, `economy:transfer_arrived`.
- **Love2D Services:** Implement `EconomyService` to own credit balance, debt ledger, and queue timers. Update once per day in geoscape time.

## Grid & Visual Standards
- Economic UI screens (manufacturing, research, suppliers) snap to the 20×20 grid. Tables use row heights of 20px multiples.
- Iconography uses 10×10 sprites scaled ×2 for clarity.

## Data & Tags
- Budget tags: `income`, `expense`, `debt`, `funding`, `manufacturing`, `research`.
- Research tags: `tech_weapon`, `tech_defense`, `tech_craft`, `tech_story`.
- Supplier tags: `global`, `regional`, `black_market`, `military`, `corporate`.

## Related Reading
- [Finance README](../finance/README.md)
- [Basescape README](../basescape/README.md)
- [Items README](../items/README.md)
- [Crafts README](../crafts/README.md)
- [Organization README](../organization/README.md)

## Tags
`#economy` `#manufacturing` `#research` `#funding` `#love2d`
