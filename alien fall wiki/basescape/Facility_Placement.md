# Facility Placement Strategy

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Grid System Framework](#grid-system-framework)
  - [Adjacency Bonus System](#adjacency-bonus-system)
  - [Facility Size Categories](#facility-size-categories)
  - [Excavation and Construction](#excavation-and-construction)
  - [Defensive Placement Strategy](#defensive-placement-strategy)
  - [Service Connectivity Requirements](#service-connectivity-requirements)
  - [Expansion Path Planning](#expansion-path-planning)
  - [Power Management Integration](#power-management-integration)
- [Examples](#examples)
  - [Research-Focused Base Layout](#research-focused-base-layout)
  - [Production-Focused Base Layout](#production-focused-base-layout)
  - [Balanced Multi-Role Base Layout](#balanced-multi-role-base-layout)
  - [Defensive Fortress Base Layout](#defensive-fortress-base-layout)
  - [Early Game Expansion Strategy](#early-game-expansion-strategy)
  - [Multi-Base Specialization](#multi-base-specialization)
  - [Common Layout Mistakes](#common-layout-mistakes)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Facility placement represents a critical strategic element in Alien Fall base management, transforming simple construction decisions into complex optimization puzzles with lasting operational consequences. This comprehensive placement system leverages a 6×6 facility grid where adjacency bonuses, defensive coverage, service connectivity, and expansion paths create meaningful strategic trade-offs. Proper base layout maximizes operational efficiency through facility clustering, optimizes defensive capabilities through overlapping turret coverage, and enables future expansion through thoughtful positioning decisions.

The placement framework emphasizes long-term planning where early construction choices significantly impact late-game optimization potential. Facilities provide adjacency bonuses to specific neighbors, creating natural clustering incentives for research laboratories and manufacturing workshops. Defense turrets achieve maximum effectiveness through overlapping fields of fire, while hangar positioning affects expansion flexibility. The system rewards strategic foresight while punishing haphazard construction through wasted excavation costs and suboptimal operational efficiency.

## Mechanics

### Grid System Framework
Bases operate on structured facility grid infrastructure:
- Grid Dimensions: 6×6 facility grid providing 36 total placement positions per base
- Access Lift Position: Starting point at C2 (center-left), cannot be removed or relocated
- Coordinate System: A1-F6 addressing with orthogonal adjacency (up to 4 neighbors)
- Logical Tile Size: 20×20 pixels per facility slot aligned with game-wide grid standards
- Placement Validation: Real-time checking ensures construction legality and connectivity

### Adjacency Bonus System
Facilities gain operational benefits from specific neighboring structures:
- Laboratory Bonuses: +10% research speed per adjacent laboratory, +5% per adjacent workshop
- Workshop Bonuses: +10% production speed per adjacent workshop, +5% per adjacent general stores
- Hangar Bonuses: +10% repair speed per adjacent workshop, +5% rearm speed per adjacent stores
- Defense Turret Bonuses: +15% effectiveness per adjacent turret through overlapping fire fields
- Power Plant Benefits: +5% production/research speed to adjacent facilities through priority power
- Maximum Potential: 4 neighbors × 10-15% = +40-60% peak effectiveness for optimally positioned facilities

### Facility Size Categories
Structures occupy varying grid footprints:
- Single Tile Facilities (1×1): Access lift, living quarters, laboratories, workshops, general stores, alien containment, psionic labs, small radar systems (most facilities)
- Double Tile Facilities (2×2): Hangars, large radar arrays, hyperwave decoders requiring 4-tile blocks
- Placement Constraints: 2×2 facilities require contiguous excavated space creating strategic positioning challenges
- Center vs Edge Trade-offs: Large facilities in center waste valuable adjacency opportunities versus corner placement preserving clustering potential

### Excavation and Construction
Grid development follows structured cost and timing framework:
- Excavation Cost: $100,000 per tile one-time investment before facility construction
- Build Timeline: 1-30 days per facility depending on complexity and technology level
- Sequential Dependencies: Construction requires adjacent excavated tiles with powered corridor access
- Expansion Planning: Strategic excavation patterns minimize costs while maximizing future flexibility
- Budget Constraints: 36-tile full base excavation costs $3.6M before facility construction expenses

### Defensive Placement Strategy
Base defense requires strategic turret positioning:
- Turret Coverage Range: 2-tile radius (orthogonal and diagonal) covering approximately 12 tiles per turret
- Perimeter Defense Pattern: 20 turrets forming complete base perimeter provides 100% coverage at $4M cost
- Corner Defense Pattern: 4 turrets at grid corners provides 60% coverage at $800K budget-friendly option
- Checkerboard Pattern: 18 turrets in alternating placement provides 95% coverage at $3.6M balanced cost
- Overlapping Fields: Adjacent turrets create +15% effectiveness bonuses through coordinated fire
- Defense Score Calculation: Coverage overlap plus adjacency bonuses determines base survivability rating

### Service Connectivity Requirements
Facilities require network integration for operation:
- Corridor Networks: Powered corridors provide connectivity between facilities and access lift
- Power Distribution: Power plants supply electrical service through connected corridor systems
- Service Propagation: All services require unbroken path to dependent facilities
- Connectivity Validation: Real-time checking prevents isolated facility construction
- Redundancy Planning: Multiple corridor paths prevent single-point-of-failure vulnerabilities

### Expansion Path Planning
Long-term growth requires strategic foresight:
- Core Facility Clustering: Early construction should group research labs or workshops for maximum adjacency
- Perimeter Reservation: Edge tiles reserved for defense turrets and low-value structures
- Hangar Corner Placement: Large facilities positioned in corners preserve center adjacency opportunities
- Sequential Build Priorities: Core operations first, then support facilities, finally defensive structures
- Scalability Considerations: Initial layout should accommodate planned endgame facility complement

### Power Management Integration
Electrical capacity constrains facility operations:
- Power Consumption: Hangars (30 power), hyperwave (40 power), psionic labs (20 power), workshops (10 power), laboratories (15 power)
- Power Generation: Power plants provide 100 power capacity each
- Safety Margin: Total generation should exceed consumption by 20% minimum for operational safety
- Strategic Positioning: Power plants adjacent to high-priority facilities provide +5% efficiency bonuses
- Capacity Planning: Base power requirements guide power plant quantity and positioning decisions

## Examples

### Research-Focused Base Layout
Central 9-laboratory cluster (B2-D4) creates research powerhouse with average +25% speed bonus. Laboratory at C3 position achieves +40% bonus from 4 laboratory neighbors representing peak efficiency. Total research capacity supports 450 scientists across 9 facilities. Three power plants (F1-F3) provide sufficient electrical capacity. 4-workshop secondary cluster (B5-D5) enables limited production. 5 defense turrets cover base approaches. Total cost approximately $15M with 180-day sequential construction timeline. Best for early-game technology race prioritization.

### Production-Focused Base Layout
9-workshop cluster (A3-C5) provides manufacturing focus with workshop at B4 achieving +40% production bonus from 4 workshop neighbors. Total production capacity supports 450 engineers. 5 general stores facilities (D2-D5) provide +5% production bonuses through material accessibility. Front-left hangar position (A1-B2) enables quick craft deployment. 7 defense turrets form defensive arc protecting production facilities. Total cost approximately $18M with 200-day timeline. Best for mid-game equipment manufacturing phase.

### Balanced Multi-Role Base Layout
6-laboratory research section (A2-B4) provides 300 scientist capacity with +20-30% average bonuses. 4-workshop production section (C3-D4) supports 200 engineers with +10-20% bonuses. Front-right hangar (D1-E2) balances accessibility. 8 defense turrets provide perimeter security. 4 general stores and 3 power plants supply support infrastructure. Total cost approximately $12M with 160-day timeline. Best for early-game main base requiring operational versatility across all mission categories.

### Defensive Fortress Base Layout
20 defense turrets form complete perimeter with each turret benefiting from 1-2 adjacent turrets (+15-30% bonuses). Core facilities (labs, workshops) protected by 4+ turret layers. Total defensive power approximately 24× standard through overlapping coverage and adjacency bonuses. 95%+ survivability against base assault attempts. No hangar included, designed as protected research/production facility. Total cost approximately $25M with 250-day construction timeline. Best for late-game high-value target protection in hostile regions.

### Early Game Expansion Strategy
Priority sequence: 2 living quarters → 2 laboratories → 1 workshop → 1 general stores → 1 power plant → 1 hangar. Total cost $3.5M with 60-day timeline and 8-tile excavation ($800K). Provides core functionality supporting 100 personnel, 100 scientists, 50 engineers with minimal operational capacity. Hangar positioned in bottom-left corner (B4-C5) preserving center expansion opportunities. Layout focuses on establishing research capacity quickly while maintaining budget discipline. Expansion path adds laboratories at C1 and E2, then workshops at D3-D4 for balanced growth.

### Multi-Base Specialization
Main Operations Base (Central North America): 6 laboratories, 4 workshops, 2 hangars, 10 defense turrets, full support facilities at $15M cost. Interception Base (Strategic Coverage Gap): 3 hangars (6 craft), 2 workshops, hyperwave decoder, 6 defense turrets at $10M cost. Satellite Detection Base (Remote Region): 1 hangar (2 craft), hyperwave decoder, 4 defense turrets, minimal support at $5M cost. Production Base (Low-Threat Region): 9 workshops, 5 general stores, 1 hangar, 8 defense turrets at $12M cost. Three-base strategy provides 80% Earth coverage with sub-2-hour response times at $35M total investment.

### Common Layout Mistakes
Mistake 1 - Haphazard Excavation: Random tile excavation scatters facilities preventing adjacency bonuses. Solution: cluster excavation for maximum neighbor benefits. Mistake 2 - Inadequate Defense: Single corner turret covers only 12 tiles enabling easy alien bypass. Solution: overlapping coverage patterns with multiple turrets. Mistake 3 - Ignoring Power: Building power-hungry facilities without sufficient generation capacity. Solution: maintain 20% power margin above consumption. Mistake 4 - Blocking Expansion: Center hangar placement wastes valuable adjacency tiles that provide no bonuses. Solution: corner/edge hangars preserve center for lab/workshop clusters.

## Related Wiki Pages

- [Facilities.md](Facilities.md) - Individual facility specifications and requirements
- [Base Defense.md](../integration/Base_Defense.md) - Defense mechanics and turret systems
- [Services.md](Services.md) - Service network and connectivity requirements
- [Capacities.md](Capacities.md) - Capacity management and resource constraints
- [New Base Building.md](New%20Base%20building.md) - Base construction mechanics
- [Monthly Base Report.md](Monthly%20base%20report.md) - Performance tracking and optimization
- [Grid System.md](../technical/Grid_System.md) - Core grid implementation
- [Research.md](../economy/Research.md) - Laboratory utilization
- [Manufacturing.md](../economy/Manufacturing.md) - Workshop utilization

## References to Existing Games and Mechanics

- **XCOM Series**: Base layout and facility adjacency bonuses
- **Dwarf Fortress**: Facility placement and optimization puzzles
- **RimWorld**: Base design and defensive positioning strategies
- **Prison Architect**: Facility layout and security coverage systems
- **Factorio**: Industrial layout optimization and throughput management
- **SimCity**: Zoning and infrastructure placement mechanics
- **Cities: Skylines**: Service coverage and building placement
- **Civilization**: City planning and district adjacency bonuses
- **Banished**: Town layout and resource access optimization
- **Oxygen Not Included**: Base design and infrastructure management

### Standard Base Grid

```
┌─────────────────────────────────────────────────────────┐
│           STANDARD BASE GRID (6×6)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   A1    B1    C1    D1    E1    F1                     │
│   ┌───┬───┬───┬───┬───┬───┐                           │
│   │   │   │   │   │   │   │                           │
│ 1 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │   │   │   │   │   │   │                           │
│ 2 │   │   │ X │   │   │   │  X = Access Lift (start) │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │   │   │   │   │   │   │                           │
│ 3 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │   │   │   │   │   │   │                           │
│ 4 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │   │   │   │   │   │   │                           │
│ 5 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │   │   │   │   │   │   │                           │
│ 6 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   └───┴───┴───┴───┴───┴───┘                           │
│                                                         │
│  Grid Coordinates: A1-F6 (36 total positions)          │
│  Starting Position: C2 (Access Lift)                   │
│  Adjacent Tiles: Up to 4 (orthogonal only)             │
└─────────────────────────────────────────────────────────┘
```

### Facility Size Categories

```
Single Tile (1×1):
  - Access Lift
  - Living Quarters
  - Laboratory
  - Workshop
  - General Stores
  - Alien Containment
  - Psionic Lab
  - Small Radar
  
Double Tile (2×2):
  - Hangar (requires 2×2 space)
  - Large Radar
  - Hyperwave Decoder
  
Note: All facilities except Hangars occupy 1 tile.
      Hangars require a 2×2 block.
```

---

## Adjacency Bonuses

### Bonus System Overview

```lua
function calculate_adjacency_bonus(facility, base_grid)
    local bonus = 0
    local neighbors = get_adjacent_facilities(facility.position, base_grid)
    
    for _, neighbor in ipairs(neighbors) do
        if adjacency_rules[facility.type] and 
           adjacency_rules[facility.type][neighbor.type] then
            bonus = bonus + adjacency_rules[facility.type][neighbor.type]
        end
    end
    
    return bonus
end

-- Adjacency bonus rules
local adjacency_rules = {
    laboratory = {
        laboratory = 0.10,      -- +10% research speed per adjacent lab
        workshop = 0.05         -- +5% research speed per adjacent workshop
    },
    
    workshop = {
        workshop = 0.10,        -- +10% production speed per adjacent workshop
        general_stores = 0.05   -- +5% production speed (easier material access)
    },
    
    power_plant = {
        workshop = 0.05,        -- +5% production speed (priority power)
        laboratory = 0.05       -- +5% research speed (priority power)
    },
    
    hangar = {
        workshop = 0.10,        -- +10% repair speed per adjacent workshop
        general_stores = 0.05   -- +5% rearm speed (easier access to ammo)
    },
    
    defense_turret = {
        defense_turret = 0.15   -- +15% effectiveness (overlapping fields of fire)
    }
}
```

### Adjacency Bonus Reference Table

```
┌──────────────────────────────────────────────────────────────────┐
│ Facility Type      │ Benefits From         │ Bonus Per Neighbor │
├────────────────────┼───────────────────────┼────────────────────┤
│ Laboratory         │ Laboratory            │ +10% research      │
│                    │ Workshop              │ +5% research       │
├────────────────────┼───────────────────────┼────────────────────┤
│ Workshop           │ Workshop              │ +10% production    │
│                    │ General Stores        │ +5% production     │
├────────────────────┼───────────────────────┼────────────────────┤
│ Hangar             │ Workshop              │ +10% repair speed  │
│                    │ General Stores        │ +5% rearm speed    │
├────────────────────┼───────────────────────┼────────────────────┤
│ Defense Turret     │ Defense Turret        │ +15% effectiveness │
├────────────────────┼───────────────────────┼────────────────────┤
│ Power Plant        │ (provides to others)  │ +5% to neighbors   │
├────────────────────┼───────────────────────┼────────────────────┤
│ Living Quarters    │ No bonus              │ —                  │
│ Alien Containment  │ No bonus              │ —                  │
│ Psionic Lab        │ No bonus              │ —                  │
│ Radar Systems      │ No bonus              │ —                  │
└──────────────────────────────────────────────────────────────────┘

Maximum Adjacency Bonus:
  Laboratory: 4 neighbors × 10% = +40% research speed
  Workshop:   4 neighbors × 10% = +40% production speed
  Hangar:     4 neighbors × 10% = +40% repair speed
  Defense:    4 neighbors × 15% = +60% effectiveness
```

---

## Optimal Layout Patterns

### Pattern 1: Research-Focused Base

```
┌─────────────────────────────────────────────────────────┐
│              RESEARCH-FOCUSED BASE                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   A     B     C     D     E     F                      │
│   ┌───┬───┬───┬───┬───┬───┐                           │
│   │LIV│RAD│ W │ W │STO│PWR│                           │
│ 1 │QTR│   │ S │ S │   │   │  Key:                     │
│   │   │   │   │   │   │   │  LIV = Living Quarters    │
│   ├───┼───┼───┼───┼───┼───┤  LAB = Laboratory          │
│   │LIV│ALF│LAB│LAB│STO│PWR│  WS  = Workshop            │
│ 2 │QTR│   │   │   │   │   │  STO = General Stores     │
│   │   │   │   │   │   │   │  ALF = Access Lift        │
│   ├───┼───┼───┼───┼───┼───┤  RAD = Radar System        │
│   │LIV│LAB│LAB│LAB│CON│PWR│  PWR = Power Plant         │
│ 3 │QTR│   │   │   │   │   │  CON = Alien Containment  │
│   │   │   │   │   │   │   │  PSI = Psionic Lab        │
│   ├───┼───┼───┼───┼───┼───┤  HNG = Hangar (2×2)        │
│   │PSI│LAB│LAB│LAB│HNG│HNG│  DEF = Defense Turret     │
│ 4 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│ W │ W │ W │HNG│HNG│                           │
│ 5 │   │ S │ S │ S │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│STO│STO│DEF│DEF│DEF│                           │
│ 6 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   └───┴───┴───┴───┴───┴───┘                           │
│                                                         │
│  Research Cluster: 9 Labs (B2-D4) = Core cluster       │
│    Lab at C3 has 4 lab neighbors = +40% bonus          │
│    Other labs have 2-3 neighbors = +20-30% bonus       │
│                                                         │
│  Total Research Capacity: 50 × 9 = 450 scientists      │
│  Average Bonus: +25% research speed                    │
│                                                         │
│  Defensive Layout: 5 turrets covering approaches       │
│  Hangar Position: Corner placement, easy access        │
└─────────────────────────────────────────────────────────┘

Expansion Priority:
  1. Build central lab cluster (C2-D4) first
  2. Add power plants (F1-F3) for capacity
  3. Complete workshop row (B5-D5) for production
  4. Add defense turrets (bottom row) last
  
Cost: ~$15,000,000 (excavation + facilities)
Build Time: ~180 days (sequential construction)
```

### Pattern 2: Production-Focused Base

```
┌─────────────────────────────────────────────────────────┐
│            PRODUCTION-FOCUSED BASE                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   A     B     C     D     E     F                      │
│   ┌───┬───┬───┬───┬───┬───┐                           │
│   │HNG│HNG│LIV│LIV│RAD│PWR│                           │
│ 1 │   │   │QTR│QTR│   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │HNG│HNG│ALF│STO│LAB│PWR│                           │
│ 2 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │ W │ W │ W │STO│LAB│PWR│                           │
│ 3 │ S │ S │ S │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │ W │ W │ W │STO│STO│LIV│                           │
│ 4 │ S │ S │ S │   │   │QTR│                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │ W │ W │ W │STO│DEF│DEF│                           │
│ 5 │ S │ S │ S │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│DEF│DEF│CON│DEF│DEF│                           │
│ 6 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   └───┴───┴───┴───┴───┴───┘                           │
│                                                         │
│  Workshop Cluster: 9 Workshops (A3-C5)                 │
│    Workshop at B4 has 4 WS neighbors = +40% bonus      │
│    Other workshops have 2-3 neighbors = +20-30% bonus  │
│                                                         │
│  Storage Integration: 5 General Stores adjacent        │
│    All workshops have +5% from nearby storage          │
│                                                         │
│  Total Production Capacity: 50 × 9 = 450 engineers     │
│  Average Bonus: +30% production speed                  │
│                                                         │
│  Defensive Layout: 7 turrets in defensive arc          │
│  Hangar Position: Front-left for quick deployment      │
└─────────────────────────────────────────────────────────┘

Expansion Priority:
  1. Build hangar (A1-B2) immediately
  2. Build workshop cluster (A3-C5) next
  3. Add storage facilities (D2-D5) for materials
  4. Complete defense perimeter (row 6) last
  
Cost: ~$18,000,000 (excavation + facilities)
Build Time: ~200 days (sequential construction)
```

### Pattern 3: Balanced Multi-Role Base

```
┌─────────────────────────────────────────────────────────┐
│              BALANCED MULTI-ROLE BASE                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   A     B     C     D     E     F                      │
│   ┌───┬───┬───┬───┬───┬───┐                           │
│   │LIV│LIV│RAD│HNG│HNG│PWR│                           │
│ 1 │QTR│QTR│   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │LAB│LAB│ALF│HNG│HNG│PWR│                           │
│ 2 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │LAB│LAB│ W │ W │CON│PWR│                           │
│ 3 │   │   │ S │ S │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │LAB│LAB│ W │ W │STO│LIV│                           │
│ 4 │   │   │ S │ S │   │QTR│                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │PSI│STO│STO│STO│DEF│DEF│                           │
│ 5 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│DEF│DEF│DEF│DEF│DEF│                           │
│ 6 │   │   │   │   │   │   │                           │
│   │   │   │   │   │   │   │                           │
│   └───┴───┴───┴───┴───┴───┘                           │
│                                                         │
│  Research Section: 6 Labs (A2-B4)                      │
│    Each lab has 2-3 neighbors = +20-30% bonus          │
│    Total: 300 scientists                               │
│                                                         │
│  Production Section: 4 Workshops (C3-D4)               │
│    Each workshop has 1-2 neighbors = +10-20% bonus     │
│    Total: 200 engineers                                │
│                                                         │
│  Storage: 4 General Stores (B5-D5, E4)                 │
│  Defense: 8 Turrets (bottom two rows)                  │
│  Hangar: 2×2 front position (D1-E2)                    │
└─────────────────────────────────────────────────────────┘

Expansion Priority:
  1. Build hangar (D1-E2) first
  2. Add lab cluster (A2-B4) for research
  3. Build workshops (C3-D4) for production
  4. Complete power/storage/defense last
  
Cost: ~$12,000,000 (excavation + facilities)
Build Time: ~160 days (sequential construction)
Best For: Early-game main base, versatile operations
```

### Pattern 4: Defensive "Fortress" Base

```
┌─────────────────────────────────────────────────────────┐
│              DEFENSIVE FORTRESS BASE                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   A     B     C     D     E     F                      │
│   ┌───┬───┬───┬───┬───┬───┐                           │
│   │DEF│DEF│DEF│DEF│DEF│DEF│                           │
│ 1 │   │   │   │   │   │   │  Perimeter Defense        │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│LIV│RAD│ALF│LIV│DEF│                           │
│ 2 │   │QTR│   │   │QTR│   │  Core Protected           │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│LAB│LAB│LAB│LAB│DEF│                           │
│ 3 │   │   │   │   │   │   │  Research Center          │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│ W │ W │ W │ W │DEF│                           │
│ 4 │   │ S │ S │ S │ S │   │  Production Center        │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│STO│STO│CON│PWR│DEF│                           │
│ 5 │   │   │   │   │   │   │  Storage & Power          │
│   │   │   │   │   │   │   │                           │
│   ├───┼───┼───┼───┼───┼───┤                           │
│   │DEF│DEF│DEF│DEF│DEF│DEF│                           │
│ 6 │   │   │   │   │   │   │  Perimeter Defense        │
│   │   │   │   │   │   │   │                           │
│   └───┴───┴───┴───┴───┴───┘                           │
│                                                         │
│  Defense Layout: 20 Turrets forming complete perimeter │
│    Each turret has 1-2 turret neighbors = +15-30% bonus│
│    Overlapping fields of fire on all approaches        │
│                                                         │
│  Core Protection: Critical facilities in center        │
│    Labs, Workshops protected by 4+ turret layers       │
│    Access Lift has maximum defensive coverage          │
│                                                         │
│  Note: No hangar - this is a research/production base  │
│        Use separate hangar base for air operations     │
│                                                         │
│  Total Defense: 20 Turrets × 1.2 avg bonus = 24× power │
│  Survivability: 95%+ against base assault              │
└─────────────────────────────────────────────────────────┘

Expansion Priority:
  1. Build perimeter turrets (row 1, row 6, cols A & F)
  2. Build core facilities (labs, workshops) inside
  3. Add final turrets and power as budget allows
  
Cost: ~$25,000,000 (excavation + 20 turrets!)
Build Time: ~250 days (sequential construction)
Best For: Late-game secondary base, high-value target protection
```

---

## Defense Considerations

### Defensive Facility Placement

#### Turret Coverage Calculation

```lua
function calculate_turret_coverage(turret_position, base_grid)
    -- Turrets have range of 2 tiles (orthogonal + diagonal)
    local coverage = {}
    local range = 2
    
    for row = -range, range do
        for col = -range, range do
            local target_pos = {
                x = turret_position.x + col,
                y = turret_position.y + row
            }
            
            -- Check if in range (Manhattan + Chebyshev distance)
            local distance = math.max(math.abs(col), math.abs(row))
            if distance <= range and is_valid_position(target_pos, base_grid) then
                table.insert(coverage, target_pos)
            end
        end
    end
    
    return coverage
end

function calculate_base_defense_score(base_grid)
    local turrets = get_facilities_by_type(base_grid, "defense_turret")
    local coverage_map = {}
    local defense_score = 0
    
    -- Calculate coverage for each turret
    for _, turret in ipairs(turrets) do
        local covered_tiles = calculate_turret_coverage(turret.position, base_grid)
        
        for _, tile in ipairs(covered_tiles) do
            local key = tile.x .. "," .. tile.y
            coverage_map[key] = (coverage_map[key] or 0) + 1
        end
    end
    
    -- Score based on coverage overlap
    for tile, coverage_count in pairs(coverage_map) do
        defense_score = defense_score + (coverage_count * 10)
    end
    
    -- Bonus for turret adjacency
    for _, turret in ipairs(turrets) do
        local neighbors = get_adjacent_facilities(turret.position, base_grid)
        for _, neighbor in ipairs(neighbors) do
            if neighbor.type == "defense_turret" then
                defense_score = defense_score + 20  -- Overlapping fields bonus
            end
        end
    end
    
    return defense_score
end
```

#### Optimal Defense Patterns

```
Pattern A: Corner Defense (Budget-Friendly)
┌───┬───┬───┬───┬───┬───┐
│DEF│   │   │   │   │DEF│
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│DEF│   │   │   │   │DEF│
└───┴───┴───┴───┴───┴───┘
Cost: 4 turrets ($800,000)
Coverage: ~60% of base
Best For: Early game, budget constraints

Pattern B: Perimeter Defense (Recommended)
┌───┬───┬───┬───┬───┬───┐
│DEF│DEF│DEF│DEF│DEF│DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│   │   │   │   │DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│   │   │   │   │DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│   │   │   │   │DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│   │   │   │   │DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│DEF│DEF│DEF│DEF│DEF│
└───┴───┴───┴───┴───┴───┘
Cost: 20 turrets ($4,000,000)
Coverage: 100% of base
Best For: Late game, high-value bases

Pattern C: Checkerboard Defense (Efficient)
┌───┬───┬───┬───┬───┬───┐
│DEF│   │DEF│   │DEF│   │
├───┼───┼───┼───┼───┼───┤
│   │DEF│   │DEF│   │DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│   │DEF│   │DEF│   │
├───┼───┼───┼───┼───┼───┤
│   │DEF│   │DEF│   │DEF│
├───┼───┼───┼───┼───┼───┤
│DEF│   │DEF│   │DEF│   │
├───┼───┼───┼───┼───┼───┤
│   │DEF│   │DEF│   │DEF│
└───┴───┴───┴───┴───┴───┘
Cost: 18 turrets ($3,600,000)
Coverage: ~95% of base (with overlap)
Best For: Mid game, balanced defense/cost
```

### Base Assault Survival Mechanics

```lua
function simulate_base_assault(base, alien_force)
    local defense_strength = calculate_base_defense_score(base.grid)
    local alien_strength = calculate_alien_force_strength(alien_force)
    
    -- Calculate survival probability
    local defense_ratio = defense_strength / alien_strength
    local survival_chance = math.min(0.95, 0.50 + (defense_ratio * 0.15))
    
    -- Turrets engage before battlescape
    local aliens_killed_by_turrets = math.floor(#alien_force * (defense_ratio * 0.1))
    
    -- If insufficient defense, enter battlescape
    if defense_ratio < 3.0 then
        -- Player must fight in tactical combat
        return {
            result = "BATTLESCAPE_REQUIRED",
            aliens_remaining = #alien_force - aliens_killed_by_turrets,
            survival_chance = survival_chance,
            defender_advantage = defense_ratio * 10  -- Bonus to player units
        }
    else
        -- Auto-resolve: turrets repel assault
        return {
            result = "AUTO_VICTORY",
            aliens_killed = aliens_killed_by_turrets,
            damage_to_facilities = math.random(0, 2)
        }
    end
end
```

---

## Expansion Strategies

### Early Game Expansion (Months 1-3)

```
Priority Order:
1. Living Quarters (2×) - Support 100 total personnel
2. Laboratory (2×) - Enable research capacity
3. Workshop (1×) - Enable item production
4. General Stores (1×) - Store recovered items
5. Power Plant (1×) - Support power needs
6. Hangar (1×) - House interceptor craft

Total Cost: ~$3,500,000
Total Time: ~60 days
Excavation: 8 tiles = $800,000
```

```
Example Early Layout:
┌───┬───┬───┬───┬───┬───┐
│   │   │ W │   │   │   │
│   │   │ S │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │LIV│ALF│LAB│   │   │
│   │QTR│   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │LIV│LAB│STO│PWR│   │
│   │QTR│   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │HNG│HNG│   │   │   │
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │HNG│HNG│   │   │   │
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │   │   │   │   │   │
│   │   │   │   │   │   │
└───┴───┴───┴───┴───┴───┘

Focuses on: Core functionality, research start, minimal cost
Expansion Path: Add more labs (C1, E2) then workshops
```

### Mid Game Expansion (Months 4-8)

```
Priority Order:
1. Laboratory (4× additional) - 6 labs total (300 scientists)
2. Workshop (3× additional) - 4 workshops total (200 engineers)
3. General Stores (2× additional) - 3 storage total
4. Power Plant (2× additional) - 3 power plants total
5. Alien Containment (1×) - Enable live capture research
6. Defense Turrets (4×) - Basic perimeter defense

Total Cost: ~$8,000,000
Total Time: ~120 days
Excavation: 16 additional tiles = $1,600,000
```

### Late Game Expansion (Months 9+)

```
Priority Order:
1. Psionic Lab (1×) - Enable psionic training
2. Hyperwave Decoder (1×) - Advanced detection
3. Defense Turrets (10× additional) - Complete perimeter
4. Living Quarters (2× additional) - 150+ total personnel
5. General Stores (2× additional) - 5+ storage total

Total Cost: ~$12,000,000
Total Time: ~150 days
Excavation: 15 additional tiles = $1,500,000

Goal: Full 36-tile base with optimal layout
```

---

## Multiple Base Strategy

### Base Specialization

```
Base Type 1: Main Operations Base (Balanced)
  Location: Central (North America, Europe, or Asia)
  Facilities:
    - 6 Laboratories (300 scientists)
    - 4 Workshops (200 engineers)
    - 2 Hangars (4 craft)
    - 10 Defense Turrets
    - Full support facilities
  Cost: ~$15,000,000
  Purpose: Research, production, primary defense

Base Type 2: Interception Base (Air Combat Focus)
  Location: Strategic coverage gap
  Facilities:
    - 3 Hangars (6 craft)
    - 2 Workshops (repair/rearm)
    - Hyperwave Decoder (detection)
    - 6 Defense Turrets
    - Minimal support facilities
  Cost: ~$10,000,000
  Purpose: Global interception coverage

Base Type 3: Satellite Base (Detection Only)
  Location: Remote regions (Australia, South America, Africa)
  Facilities:
    - 1 Hangar (2 craft)
    - Hyperwave Decoder
    - 4 Defense Turrets
    - Minimal support
  Cost: ~$5,000,000
  Purpose: Sensor coverage, emergency response

Base Type 4: Production Base (Manufacturing)
  Location: Low-threat region
  Facilities:
    - 9 Workshops (450 engineers)
    - 5 General Stores
    - 1 Hangar (2 craft)
    - 8 Defense Turrets
  Cost: ~$12,000,000
  Purpose: Mass production of equipment
```

### Geographic Coverage

```
Optimal Base Placement (3-base strategy):
  Base 1: North America (New York or Los Angeles)
  Base 2: Europe (London or Berlin)
  Base 3: Asia (Tokyo or Beijing)
  
  Coverage: ~80% of Earth's landmass
  Response Time: <2 hours to most threats
  Total Cost: ~$35,000,000

Optimal Base Placement (5-base strategy):
  Base 1: North America (New York)
  Base 2: Europe (London)
  Base 3: Asia (Tokyo)
  Base 4: South America (Brasilia)
  Base 5: Africa (Cairo)
  
  Coverage: ~95% of Earth's landmass
  Response Time: <1 hour to most threats
  Total Cost: ~$50,000,000
```

---

## Common Mistakes to Avoid

### Mistake 1: Haphazard Excavation

```
BAD LAYOUT:
┌───┬───┬───┬───┬───┬───┐
│ W │   │   │LAB│   │   │  Random excavation = wasted adjacency
│ S │   │   │   │   │   │  No bonus for isolated facilities
├───┼───┼───┼───┼───┼───┤
│   │   │ALF│   │   │PWR│
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │LAB│   │   │   │   │
│   │   │   │   │   │   │
└───┴───┴───┴───┴───┴───┘

GOOD LAYOUT:
┌───┬───┬───┬───┬───┬───┐
│   │   │   │   │   │   │  Clustered excavation = maximum adjacency
│   │   │   │   │   │   │  All labs benefit from neighbors
├───┼───┼───┼───┼───┼───┤
│   │LAB│ALF│LAB│PWR│   │
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │LAB│ W │LAB│PWR│   │
│   │   │ S │   │   │   │
└───┴───┴───┴───┴───┴───┘
```

### Mistake 2: Inadequate Defense

```
PROBLEM: Single turret in corner
┌───┬───┬───┬───┬───┬───┐
│DEF│   │   │   │   │   │  Only covers 12 tiles
│   │   │   │   │   │   │  Easy bypass by aliens
└───┴───┴───┴───┴───┴───┘

SOLUTION: Overlapping coverage
┌───┬───┬───┬───┬───┬───┐
│DEF│   │DEF│   │DEF│   │  Covers 32+ tiles
│   │   │   │   │   │   │  Crossfire on all approaches
└───┴───┴───┴───┴───┴───┘
```

### Mistake 3: Ignoring Power Needs

```
Common Error: Building power-hungry facilities without capacity

Power Consumption:
  Hangar: 30 power
  Hyperwave: 40 power
  Psionic Lab: 20 power
  Workshop: 10 power
  Laboratory: 15 power

Power Generation:
  Power Plant: 100 power
  
Always ensure: Total generation > Total consumption + 20% margin
```

### Mistake 4: Blocking Future Expansion

```
BAD: Placing hangar in center blocks expansion
┌───┬───┬───┬───┬───┬───┐
│   │   │   │   │   │   │
├───┼───┼───┼───┼───┼───┤
│   │HNG│HNG│   │   │   │  Center placement wastes valuable
│   │   │   │   │   │   │  adjacent tiles (hangars give no bonus)
├───┼───┼───┼───┼───┼───┤
│   │HNG│HNG│   │   │   │
└───┴───┴───┴───┴───┴───┘

GOOD: Corner/edge hangar preserves adjacency
┌───┬───┬───┬───┬───┬───┐
│HNG│HNG│   │   │   │   │  Corner placement leaves center
│   │   │   │   │   │   │  free for lab/workshop clusters
├───┼───┼───┼───┼───┼───┤
│HNG│HNG│LAB│LAB│LAB│   │
└───┴───┴───┴───┴───┴───┘
```

---

## Implementation Notes

### Love2D Grid Management

```lua
-- Base grid management (src/basescape/base_grid.lua)
local BaseGrid = {
    width = 6,
    height = 6,
    tile_size = 20,  -- Grid units (20px per tile)
    facilities = {}
}

function BaseGrid:new(base)
    local grid = {
        base = base,
        tiles = {},
        excavated = {},
        access_lift_pos = {x = 3, y = 2}  -- Starting position
    }
    
    -- Initialize grid
    for y = 1, self.height do
        grid.tiles[y] = {}
        grid.excavated[y] = {}
        for x = 1, self.width do
            grid.tiles[y][x] = nil  -- No facility
            grid.excavated[y][x] = (x == 3 and y == 2)  -- Only access lift excavated
        end
    end
    
    setmetatable(grid, {__index = self})
    return grid
end

function BaseGrid:can_build_at(x, y, facility_type)
    -- Check if tile is excavated
    if not self.excavated[y][x] then
        return false, "Tile not excavated"
    end
    
    -- Check if tile is empty
    if self.tiles[y][x] ~= nil then
        return false, "Tile occupied"
    end
    
    -- Check for 2×2 facilities (hangars)
    if facility_type.size == "2x2" then
        if not self:check_2x2_space(x, y) then
            return false, "Insufficient space for 2×2 facility"
        end
    end
    
    return true
end

function BaseGrid:place_facility(x, y, facility)
    if facility.size == "2x2" then
        -- Place in 2×2 block
        for dy = 0, 1 do
            for dx = 0, 1 do
                self.tiles[y + dy][x + dx] = facility
            end
        end
    else
        -- Place single tile
        self.tiles[y][x] = facility
    end
    
    facility.position = {x = x, y = y}
    table.insert(self.facilities, facility)
end

function BaseGrid:calculate_adjacency_bonuses()
    for _, facility in ipairs(self.facilities) do
        facility.adjacency_bonus = calculate_adjacency_bonus(facility, self)
    end
end
```

---

## Cross-References

### Related Systems
- [Facilities](Facilities.md) - Individual facility specifications
- [Base Defense](../integration/Base_Defense.md) - Defense mechanics
- [Construction](../economy/Construction.md) - Build costs and times
- [Power Management](Power.md) - Electrical grid system

### Related Mechanics
- [Grid System](../technical/Grid_System.md) - Core grid implementation
- [Research](../economy/Research.md) - Laboratory usage
- [Manufacturing](../economy/Manufacturing.md) - Workshop usage

---

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Status:** Complete
