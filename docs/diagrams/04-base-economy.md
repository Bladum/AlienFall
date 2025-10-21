# Base Management & Economy Diagrams

**Created:** October 21, 2025  
**Purpose:** Visual representation of base building, facility management, and economic systems

---

## 1. Base Facility Grid System

### Diagram: 5×5 Hexagonal Facility Grid

```
┌──────────────────────────────────────────────────────────────┐
│            BASESCAPE FACILITY GRID (5×5 Layout)              │
└──────────────────────────────────────────────────────────────┘

BASE GRID STRUCTURE:
(Hexagonal topology = 6 neighbors per hex)

        [Row 0]
      (0,0) (1,0) (2,0) (3,0) (4,0)

        [Row 1]
      (0,1) (1,1) (2,1) (3,1) (4,1)

        [Row 2]
      (0,2) (1,2) (2,2) (3,2) (4,2)

        [Row 3]
      (0,3) (1,3) (2,3) (3,3) (4,3)

        [Row 4]
      (0,4) (1,4) (2,4) (3,4) (4,4)


EXAMPLE BASE LAYOUT (After 3 months):

      ┌─HQ─┬─HR─┬─RES┐
      │ ☆  │    │ ⚗  │
      ├─────────────┤
      │ENG │DOR │LAB│
      │ ⚙  │ □  │ 📚│
      ├──────HG──────┤
      │ ◯ │ ◯ │ 🚀 │
      │    │    │    │
      └────────────────┘

Legend:
☆ = HQ (Headquarters) - CENTER
⚗ = Lab (Research)
⚙ = Engineering (Manufacturing)
□ = Dormitory (Barracks)
📚 = Library (Alien Autopsy)
🚀 = Hangar (Aircraft)
◯ = Barracks (Personnel)
HR = Hydroponics/Residences
DOR = Dormitory
RES = Research
ENG = Engineering
HQ = Headquarters (mandatory center)
LAB = Laboratory
HG = Hangar


HEXAGONAL NEIGHBOR TOPOLOGY:

Each hex has 6 neighbors (in offset coordinates):

        NW       NE
         ↖ ╱╲ ↗
    W ←  ║(X,Y)║  → E
         ↙ ╲╱ ↘
        SW       SE

For hex (2,2):
├─ NW: (1,1)
├─ NE: (3,1)
├─ E:  (3,2)
├─ SE: (3,3)
├─ SW: (1,3)
└─ W:  (1,2)

ADJACENCY BONUS RULES:

Base Adjacency Bonuses (Hexes must touch):
│ Adjacent Pair           │ Bonus Effect        │ Value  │
├─────────────────────────┼─────────────────────┼────────┤
│ Research + Lab          │ +15% Research speed │ Science│
│ Engineering + Workshop  │ +15% Build speed    │ Craft  │
│ Hangar + Barracks       │ +10% Unit readiness │ Combat │
│ Hydroponics + Barracks  │ +20% Morale         │ Morale │
│ Generator + Facility    │ +10% Power output   │ Power  │
│ Radar + Radar           │ Radar overlap (wasteful) │ - │

Stacking Rules:
├─ Multiple adjacencies stack
├─ Example: Lab adjacent to 2 Research = 2 × 15% bonus
├─ Max bonus per facility = 3 adjacent bonuses
└─ Strategic placement = key to efficiency


FACILITY TYPES (12 Available):

┌─ MANDATORY ───────────────────────────────────────┐
│ 1. HEADQUARTERS (HQ) - Size 1×1                  │
│    ├─ Must be at grid center (2,2)              │
│    ├─ Provides base command & control           │
│    ├─ Cannot be moved or removed                │
│    ├─ Cost: 0 (given with base)                 │
│    ├─ Maintenance: 500 credits/month            │
│    └─ Capacity: N/A (administrative hub)        │
└────────────────────────────────────────────────────┘

┌─ EARLY GAME (Tier 1-2) ───────────────────────────┐
│ 2. BARRACKS (Personnel)                           │
│    ├─ Holds 4-8 soldiers per facility           │
│    ├─ Cost: 5,000 credits                       │
│    ├─ Build time: 7 days                        │
│    └─ Maintenance: 200 credits/month            │
│                                                  │
│ 3. HANGAR (Aircraft Storage)                    │
│    ├─ Holds 1 craft + crew                      │
│    ├─ Cost: 15,000 credits                      │
│    ├─ Build time: 14 days                       │
│    ├─ Maintenance: 500 credits/month            │
│    └─ Bonus: Repair/refuel functions           │
│                                                  │
│ 4. WORKSHOP (Manufacturing)                    │
│    ├─ Allows item manufacturing                 │
│    ├─ Cost: 8,000 credits                       │
│    ├─ Build time: 10 days                       │
│    ├─ Maintenance: 300 credits/month            │
│    └─ Capacity: 2 concurrent projects           │
│                                                  │
│ 5. LABORATORY (Research)                       │
│    ├─ Enables technology research               │
│    ├─ Cost: 12,000 credits                      │
│    ├─ Build time: 12 days                       │
│    ├─ Maintenance: 400 credits/month            │
│    └─ Capacity: Hold 3 scientists               │
└────────────────────────────────────────────────────┘

┌─ MID GAME (Tier 3) ────────────────────────────────┐
│ 6. POWER GENERATOR (Power Generation)             │
│    ├─ Provides 50 power units/day                │
│    ├─ Cost: 20,000 credits                      │
│    ├─ Build time: 15 days                       │
│    └─ Maintenance: 600 credits/month            │
│                                                  │
│ 7. HYDROPONICS (Food/Resources)                 │
│    ├─ Provides food for 8 soldiers/day          │
│    ├─ Cost: 10,000 credits                      │
│    ├─ Build time: 10 days                       │
│    ├─ Maintenance: 250 credits/month            │
│    └─ Bonus: Morale improvement                │
│                                                  │
│ 8. STORAGE (Item Storage)                      │
│    ├─ Increases inventory limit by 20 items    │
│    ├─ Cost: 5,000 credits                       │
│    ├─ Build time: 7 days                        │
│    └─ Maintenance: 100 credits/month            │
│                                                  │
│ 9. MEDICAL BAY (Medical Facilities)             │
│    ├─ Allows wound treatment/healing            │
│    ├─ Cost: 15,000 credits                      │
│    ├─ Build time: 12 days                       │
│    ├─ Maintenance: 350 credits/month            │
│    └─ Bonus: Faster recovery (1d4→1d6 heal)   │
└────────────────────────────────────────────────────┘

┌─ LATE GAME (Tier 4-5) ─────────────────────────────┐
│ 10. ADVANCED LAB (Exotic Research)                │
│     ├─ Unlock alien technology                    │
│     ├─ Cost: 30,000 credits                       │
│     ├─ Build time: 20 days                        │
│     ├─ Maintenance: 800 credits/month             │
│     ├─ Requirement: Main Lab first                │
│     └─ Capacity: 4 elite scientists               │
│                                                   │
│ 11. ALIEN CONTAINMENT (Study Aliens)             │
│     ├─ Capture and study alien specimens         │
│     ├─ Cost: 25,000 credits                      │
│     ├─ Build time: 18 days                       │
│     ├─ Maintenance: 500 credits/month            │
│     ├─ Requirement: Advanced Lab                 │
│     └─ Danger: Breach risk (aliens escape)       │
│                                                   │
│ 12. QUANTUM ACCELERATOR (Ultimate Tech)          │
│     ├─ Final technology research                 │
│     ├─ Cost: 50,000 credits                      │
│     ├─ Build time: 30 days                       │
│     ├─ Maintenance: 1,500 credits/month          │
│     ├─ Requirement: Advanced Lab + Resources     │
│     └─ Enables: Victory tech research            │
└────────────────────────────────────────────────────┘

FACILITY CONSTRUCTION GATING:

Facility availability depends on:
├─ Technology Research (must research first)
├─ Organization Level (level gates facility count)
├─ Biome Suitability (some facilities not viable on some worlds)
├─ Relations (some suppliers sell better facilities)
├─ Campaign Progress (endgame facilities locked early)
└─ Base Count (org level limits bases)

Example progression:
├─ Start: HQ only
├─ Week 1: Unlock Barracks (costs 5k)
├─ Week 2: Unlock Hangar (costs 15k)
├─ Month 1: Unlock Workshop (requires Tech: Manufacturing)
├─ Month 2: Unlock Lab (requires Tech: Research)
├─ Month 4: Unlock Advanced Lab (requires Lab + Tech: Alien Study)
└─ Month 12: Unlock Quantum Accelerator (endgame)
```

---

## 2. Economic Cycle Diagram

### Diagram: Monthly Income and Expenses

```
┌──────────────────────────────────────────────────────────────┐
│               MONTHLY ECONOMIC CYCLE                         │
└──────────────────────────────────────────────────────────────┘

START OF MONTH (1st of each month):

INPUT PHASE - Income Sources:
├─ Country Funding (base amount)
│  ├─ USA: 5,000 credits
│  ├─ UK: 3,000 credits  
│  ├─ Russia: 4,000 credits
│  ├─ EU: 4,000 credits
│  ├─ China: 3,000 credits
│  └─ Other: 1,000-2,000 each
│
├─ Funding Multipliers:
│  ├─ Relations < -50 (hostile): 0.5x (nations cut funding)
│  ├─ Relations -50 to 0 (neutral): 0.8x
│  ├─ Relations 0 to +50 (friendly): 1.0x
│  └─ Relations > +50 (allied): 1.5x
│
└─ Total Base Income: $16,000-18,000 (before multipliers)

EXPENSE PHASE - Cost Breakdown:

├─ FACILITY MAINTENANCE (per base)
│  ├─ HQ: 500 credits
│  ├─ Barracks (each): 200 credits
│  ├─ Hangar (each): 500 credits
│  ├─ Workshop (each): 300 credits
│  ├─ Lab (each): 400 credits
│  ├─ Advanced Lab (each): 800 credits
│  ├─ Power Generator (each): 600 credits
│  ├─ Hydroponics (each): 250 credits
│  ├─ Medical Bay (each): 350 credits
│  ├─ Storage (each): 100 credits
│  ├─ Alien Containment: 500 credits
│  └─ Quantum Accelerator: 1,500 credits
│
│  Example (3-base setup):
│  ├─ Base 1 (HQ + 2 Barracks + Hangar): 500 + 200×2 + 500 = 1,400
│  ├─ Base 2 (Lab + Workshop + Hangar): 400 + 300 + 500 = 1,200
│  ├─ Base 3 (Advanced Lab + Hangar): 800 + 500 = 1,300
│  └─ Total: 3,900 credits/month
│
├─ PERSONNEL COSTS
│  ├─ Soldier salary: 100 credits/month (per unit)
│  ├─ Scientist salary: 150 credits/month (per researcher)
│  ├─ Engineer salary: 150 credits/month (per engineer)
│  ├─ Commander salary: 300 credits/month (base commander)
│  │
│  ├─ Example (25 units + 8 scientists):
│  │  ├─ 25 soldiers × 100 = 2,500
│  │  ├─ 8 scientists × 150 = 1,200
│  │  └─ Total: 3,700 credits/month
│  │
│  └─ Casualties increase costs (new recruits)
│
├─ SUPPLIER COSTS (procurement)
│  ├─ Ammunition: 500 credits/month
│  ├─ Maintenance supplies: 300 credits/month
│  ├─ Medical supplies: 200 credits/month
│  └─ Other consumables: 200 credits/month
│  
│  └─ Total: 1,200 credits/month (baseline)
│
└─ TOTAL MONTHLY EXPENSES: ~8,800 credits/month (baseline)


BALANCE CALCULATION:

Income: $16,000 (before multipliers)
Expenses: $8,800 (baseline)
Available: $7,200 (positive balance)

Apply Relations Multipliers:
├─ If all relations average +20% friendly
│  └─ Income modifier: 1.1x (10% bonus)
│  └─ New income: 17,600 credits
│  └─ New balance: 8,800 credits (surplus)
│
├─ If relations average -30% hostile
│  └─ Income modifier: 0.75x (25% penalty)
│  └─ New income: 12,000 credits
│  └─ New balance: 3,200 credits (tight)
│
└─ If relations collapse (all hostile)
   └─ Income modifier: 0.4x (catastrophic)
   └─ New income: 6,400 credits
   └─ New balance: -2,400 credits (DEFICIT)


DEFICIT CONSEQUENCES:

If Monthly Balance < 0:
├─ Cannot build new facilities
├─ Cannot hire new soldiers
├─ Cannot manufacture new items
├─ Research slows by 50%
├─ Maintenance delayed (risk facility damage)
├─ Must sell items to cover deficit
└─ Risk of game over (bankruptcy)

SURPLUS MANAGEMENT:

If Monthly Balance > 5,000:
├─ Can accelerate research (bonus budget)
├─ Can build new facilities (expansion)
├─ Can hire additional soldiers
├─ Can manufacture high-value items
├─ Can offer country rewards (relationship boost)
└─ Can invest in future tech


CAMPAIGN PROGRESSION:

Early Game (Months 1-3):
├─ Limited facilities (4-5 total)
├─ Low expenses (3,000-4,000/month)
├─ High income (countries investing)
├─ Surplus: 10,000-13,000/month
└─ Strategy: Build foundational facilities

Mid Game (Months 4-6):
├─ Moderate facilities (8-10 total)
├─ Moderate expenses (6,000-8,000/month)
├─ Moderate income (relations matter more)
├─ Surplus: 6,000-10,000/month
└─ Strategy: Expand operations, build research

Late Game (Months 7-12):
├─ Many facilities (12-20 total)
├─ High expenses (10,000-15,000/month)
├─ Relations heavily influence income
├─ Surplus: 2,000-8,000/month (variable)
├─ Risk: Budget crisis if relations fail
└─ Strategy: Maintain stability, pursue endgame

Endgame (Month 13+):
├─ Max facilities (25+)
├─ Very high expenses (20,000+/month)
├─ Income highly dependent on relations
├─ Surplus: Highly variable (-5,000 to +10,000)
├─ Risk: Total economic collapse possible
└─ Objective: Complete victory conditions


FINANCIAL REPORTING:

Monthly Statement Template:
┌──────────────────────────────────────┐
│ FINANCE REPORT - MONTH 3             │
├──────────────────────────────────────┤
│ INCOME:                              │
│ • Country Funding:      $16,500      │
│ • Mission Rewards:      $2,300       │
│ • Alien Salvage:        $1,200       │
│ • Other Income:         $500         │
│ ────────────────────────────────     │
│ TOTAL INCOME:           $20,500      │
│                                      │
│ EXPENSES:               │
│ • Facility Maintenance: $4,200       │
│ • Personnel:            $3,900       │
│ • Supplies:             $1,200       │
│ • Research Acceleration: $800        │
│ ────────────────────────────────     │
│ TOTAL EXPENSES:         $10,100      │
│                                      │
│ MONTHLY BALANCE:        +$10,400     │
│ Year-to-Date Balance:   +$28,700     │
│                                      │
│ Status: ✓ HEALTHY                   │
│ Recommendation: Continue expansion   │
└──────────────────────────────────────┘


BUDGET ALERTS:

┌─ Warning Thresholds ─────────────────┐
│ Green (Surplus > 5k):  Expand        │
│ Yellow (Surplus 1-5k): Maintain      │
│ Orange (Surplus <1k):  Conserve      │
│ Red (Deficit):         Critical      │
│ Black (Very Negative): Game Over     │
└──────────────────────────────────────┘
```

---

## 3. Research & Manufacturing Pipeline

### Diagram: Tech Tree to Production

```
┌──────────────────────────────────────────────────────────────┐
│        RESEARCH → MANUFACTURING → DEPLOYMENT FLOW            │
└──────────────────────────────────────────────────────────────┘

RESEARCH SYSTEM:

┌─ Research Queue ─────────────────────────────────────┐
│                                                      │
│ Active Research:                                     │
│ 1. Plasma Rifle (IN PROGRESS - 4 days left)         │
│    ├─ Progress: ████░░░░░░ (40%)                   │
│    ├─ Scientists assigned: 2/2                      │
│    ├─ Completion date: Day 34                       │
│    └─ Unlock: Plasma Rifle manufacturing            │
│                                                      │
│ 2. Alien Autopsy (QUEUED - 0 days progress)         │
│    ├─ Progress: ░░░░░░░░░░ (0%)                    │
│    ├─ Scientists assigned: 0/3                      │
│    ├─ Est. completion: Day 52 (with 3 scientists)  │
│    ├─ Priority: High                               │
│    └─ Unlock: Alien technologies branch             │
│                                                      │
│ 3. Armor Plating (AVAILABLE)                        │
│    ├─ Prerequisites: Basic Materials (complete)    │
│    ├─ Cost: 0 (already researched)                 │
│    ├─ Est. time: 8 days with 1 scientist           │
│    └─ Unlock: Better armor manufacturing           │
│                                                      │
│ Locked (Prerequisites Not Met):                     │
│ - Advanced Psionics (Need: Psionic Basics)         │
│ - Quantum Computing (Need: Advanced Electronics)   │
│ - UFO Reconstruction (Need: UFO Analysis)          │
│                                                      │
└──────────────────────────────────────────────────────┘

RESEARCH PROGRESSION:

Tier 1 (Days 1-7): Basic Technologies
├─ Infantry Armor II
├─ Assault Rifle II  
├─ Grenades
└─ Medkits

Tier 2 (Days 8-21): Intermediate Tech
├─ Plasma Rifle
├─ Laser Carbine
├─ Advanced Armor
└─ Motion Tracker

Tier 3 (Days 22-42): Advanced Tech
├─ Plasma Cannon
├─ Advanced Psionics
├─ UAV Drone
└─ Alien Autopsy

Tier 4 (Days 43-70): Exotic Tech
├─ Alien Weapon System
├─ Quantum Computing
├─ Anti-Grav Armor
└─ Mind Control

Tier 5 (Days 71+): Ultimate Tech
├─ UFO Reconstruction
├─ Dimensional Portal
├─ Alien Brain Integration
└─ Victory Tech (endgame)


MANUFACTURING SYSTEM:

┌─ Manufacturing Queue ────────────────────────────────┐
│                                                      │
│ Active Manufacturing:                               │
│                                                      │
│ 1. Plasma Rifle (IN PROGRESS - 2 days left)        │
│    ├─ Progress: ███████░░░ (70%)                   │
│    ├─ Engineers assigned: 2/2                      │
│    ├─ Completion date: Tomorrow                    │
│    ├─ Resource cost: 3,000 credits + 15 alien ore │
│    ├─ Output location: Storage facility            │
│    └─ Assigned to: Squad "Alpha" (automatic)      │
│                                                      │
│ 2. Combat Armor x3 (QUEUED - 0% progress)          │
│    ├─ Engineers assigned: 0/2                      │
│    ├─ Est. completion: 6 days with 2 engineers    │
│    ├─ Resource cost: 1,500 credits × 3 = 4,500   │
│    ├─ Output location: Barracks                    │
│    └─ Priority: Medium                             │
│                                                      │
│ 3. Medkit x5 (AVAILABLE)                           │
│    ├─ Prerequisite: Basic Research complete       │
│    ├─ Est. time: 2 days with 1 engineer           │
│    ├─ Resource cost: 2,500 credits total          │
│    └─ Output: Medical Bay inventory               │
│                                                      │
└──────────────────────────────────────────────────────┘

MANUFACTURING TIME CALCULATION:

Formula: Base Time × (1 - Engineer Efficiency)
├─ Base Time: Technology-dependent (3-20 days)
├─ Engineer Count: 1-3 engineers per project
├─ Efficiency: 1 eng = 100%, 2 eng = 70%, 3 eng = 50%
├─ Funding boost: Can accelerate by 50% for 2x cost
└─ Disruption: Facility damage adds time

Example:
├─ Plasma Rifle base time: 8 days
├─ 2 engineers assigned: 50% efficiency
├─ Actual time: 8 × (1 - 0.5) = 4 days
├─ With funding boost: 4 × 0.5 = 2 days (cost: 6k instead of 3k)
└─ Current progress: 70% (2.8 days in, 1.2 days left)


DEPLOYMENT WORKFLOW:

New Item Completed:
│
├─ Automatic assignment to squad (if configured)
│  ├─ Rifle → Soldier with matching weapon slot
│  ├─ Armor → Unit with lowest armor currently
│  ├─ Utility → Designated role unit
│  └─ Ammo → Weapons magazine (auto-load)
│
├─ OR Manual assignment (player chooses)
│  ├─ Item moved to specific unit inventory
│  ├─ Unit assigned to specific squad
│  └─ Squad deployed to mission
│
└─ Item ready for combat use next mission

RESOURCE MANAGEMENT:

Raw Materials:
├─ Alien Ore (harvested from alien tech)
├─ Alien Alloy (processed from ore)
├─ Electronic Components (found in crashed UFOs)
├─ Rare Earth Minerals (mined or found)
└─ Biochemical Compounds (research by-product)

Manufacturing Requirements:
├─ Credits (primary cost)
├─ Raw materials (specific per item)
├─ Engineers (time multiplier)
├─ Research completion (prerequisite)
└─ Facility space (manufacturing capacity)

Inventory Limits:
├─ Soldiers: 5-10 inventory slots each
├─ Base Storage: 50-100 item capacity
├─ Hangar: Craft + ammo storage
├─ Manufacturing: 2-3 concurrent projects
└─ Research: 1-3 concurrent projects


STRATEGIC BALANCE:

Early Game (Months 1-3):
├─ Limited research (basic tech only)
├─ Fast manufacturing (4-7 days)
├─ Small production volume (1-2 items/month)
└─ Challenge: Choose right tech path

Mid Game (Months 4-6):
├─ Expanded research options (tier 2-3)
├─ Moderate manufacturing (6-12 days)
├─ Higher production (5-10 items/month)
└─ Challenge: Balance priorities with limited engineers

Late Game (Months 7-12):
├─ Advanced research (tier 3-4)
├─ Slower manufacturing (10-20 days)
├─ High production demand (20+ items/month)
├─ Challenge: Resource bottlenecks
└─ Focus: Endgame tech race

Endgame (Month 13+):
├─ Ultimate research (tier 5 - victory tech)
├─ Very slow manufacturing (20-40 days)
├─ Massive production demand (30+ items/month)
├─ Challenge: Economic sustainability
└─ Goal: Complete victory tech before defeat
```

---

## Summary

Base management and economy create strategic depth:

1. **Facility Grid:** 5×5 hexagonal layout with adjacency bonuses
2. **Economic Cycle:** Monthly income/expenses with relations multipliers
3. **Research & Manufacturing:** Tech tree → production pipeline

These systems ensure:
- Strategic facility placement (adjacency bonuses matter)
- Economic balance (relations influence funding)
- Long-term planning (research unlocks manufacturing)
- Resource management (limited engineers/funds)

---

**Related Documentation:**
- `wiki/systems/Basescape.md` - Base management detailed mechanics
- `wiki/systems/Economy.md` - Economic system details
- `engine/basescape/base_manager.lua` - Implementation
- `engine/economy/research/research_system.lua` - Research implementation
