# Resource Scarcity & Economic Pressure System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: HIGH  
> **Related Systems**: Economy.md, Basescape.md, Manufacturing.md, Geoscape.md

## Table of Contents

- [Overview](#overview)
- [Design Philosophy](#design-philosophy)
- [Fuel Capacity System](#fuel-capacity-system)
- [Material Shortage Events](#material-shortage-events)
- [Manufacturing Capacity Limits](#manufacturing-capacity-limits)
- [Progressive Taxation System](#progressive-taxation-system)
- [Funding Volatility](#funding-volatility)
- [Resource Competition](#resource-competition)
- [Strategic Reserve Management](#strategic-reserve-management)
- [Black Market Integration](#black-market-integration)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

Addresses **economic balance issues** by introducing resource scarcity, manufacturing constraints, and dynamic economic pressure. Prevents runaway wealth accumulation and maintains strategic tension throughout campaign.

**Core Goals**:
- Break "infinite wealth spiral" exploit (salvage → manufacturing → wealth)
- Force meaningful resource allocation decisions
- Create supply/demand dynamics (scarcity drives strategy)
- Maintain economic pressure in mid-late game
- Reward planning and diversification over hoarding

### Key Principles

1. **Scarcity Creates Choice**: Limited resources force prioritization
2. **Dynamic Markets**: Prices and availability fluctuate realistically
3. **Strategic Reserves**: Planning ahead rewarded, poor planning punished
4. **Risk/Reward Balance**: High-risk strategies offer high rewards
5. **No Soft Locks**: Scarcity creates challenges, never unwinnable situations

---

## Design Philosophy

### Current Problem

```
Broken Economic Loop:
Mission Success → Salvage Items → Manufacture Equipment → 
Sell Excess → Infinite Credits → Buy Everything → 
No Strategic Pressure → Boring Mid-Game
```

### Proposed Solution

```
Balanced Economic Loop:
Mission Success → Salvage Items → Resource Capacity Full → 
Must Choose: Sell/Store/Manufacture → Manufacturing Queue Limited → 
Strategic Prioritization Required → Funding Volatile → 
Reserves Needed → Engaging Strategic Tension
```

---

## Fuel Capacity System

### Current State vs. Proposed

**Current (Broken)**:
- Fuel is infinite resource
- Crafts never stranded
- No strategic deployment decisions
- "Deploy everything everywhere" is optimal

**Proposed (Balanced)**:
- Fuel capacity per base: 1,000 units (not infinite)
- Craft consumption: 10-50 fuel per hex traveled
- Strategic choice: Deploy multiple craft OR maintain reserves
- Empty tank = stranded craft (rescue mission required)

### Fuel Mechanics

```yaml
Fuel Storage:
  - Base Fuel Capacity: 1,000 units (default)
  - Fuel Tank Facility (2×2): +500 units per facility
  - Maximum Capacity: 3,000 units (1 base + 4 tanks)

Fuel Consumption:
  - Scout Craft: 10 fuel per hex (efficient)
  - Interceptor: 20 fuel per hex (standard)
  - Transport: 30 fuel per hex (heavy)
  - Bomber: 40 fuel per hex (fuel-hungry)
  - Capital Ship: 50 fuel per hex (massive consumption)

Refueling:
  - Automatic at base (no manual action)
  - Craft must return to base to refuel
  - Refueling speed: 100 fuel per day
  - Emergency refuel: 2× cost, instant (black market)
```

### Stranded Craft Mechanics

**What Happens When Fuel Depleted**:

1. **Craft Grounded**: Cannot move from current hex
2. **Rescue Mission Spawns**: Player must send fuel tanker (special craft)
3. **Risk Exposure**: Stranded craft vulnerable to alien attacks
4. **Time Pressure**: 7 days to rescue or craft destroyed
5. **Reputation Hit**: -10 fame if crew lost

**Rescue Mission Types**:
- **Easy**: Craft in friendly territory (no enemies)
- **Medium**: Craft in neutral territory (ambush risk)
- **Hard**: Craft in hostile territory (guaranteed combat)

### Strategic Implications

**Deployment Planning**:
```yaml
Example Mission Calculation:
  Destination: 15 hexes from base
  Craft: Interceptor (20 fuel per hex)
  Fuel Required: 300 fuel (15 × 20 = round trip)
  
  Current Fuel: 800 / 1,000
  After Mission: 500 / 1,000 (sufficient reserve)
  
Decision: SAFE TO DEPLOY

Alternative Scenario:
  Current Fuel: 250 / 1,000
  After Mission: -50 (INSUFFICIENT!)
  
Decision: MUST REFUEL FIRST or SEND DIFFERENT CRAFT
```

**Reserve Management**:
- Always maintain 30% fuel reserve (emergency buffer)
- Plan multi-mission deployments carefully
- Consider fuel efficiency when choosing craft
- Build Fuel Tank facilities in high-activity bases

---

## Material Shortage Events

### Overview

Random monthly events create temporary material scarcity, forcing adaptation.

### Shortage Types

```yaml
Titanium Shortage:
  Frequency: 10% chance per month
  Duration: 2 months
  Effect: Titanium unavailable or 3× price
  Cause: Mining disaster, supply route disrupted
  
  Player Options:
    - Wait it out (delay manufacturing)
    - Black market purchase (3× price, -karma)
    - Alternative materials research (50 man-days)
    - Raid alien bases for salvage (high risk)

Elerium Shortage:
  Frequency: 15% chance per month (mid-late game)
  Duration: 3 months
  Effect: Elerium completely unavailable
  Cause: Alien supply chain disrupted
  
  Player Options:
    - Synthesize from existing stocks (50% efficiency)
    - Capture alien transports (special missions)
    - Alternative power source research (100 man-days)
    - Hoard existing elerium (opportunity cost)

Fuel Crisis:
  Frequency: 5% chance per month
  Duration: 1 month
  Effect: Fuel production halved globally
  Cause: Geopolitical crisis, refinery sabotage
  
  Player Options:
    - Emergency rationing (-50% operations)
    - Develop synthetic fuel (75 man-days)
    - Import from black market (2× price)
    - Raid civilian fuel depots (-karma, easy fuel)

Alloy Shortage:
  Frequency: 8% chance per month
  Duration: 2 months
  Effect: Alien Alloy prices double
  Cause: Increased global demand
  
  Player Options:
    - Stockpile earlier (prediction/planning)
    - Focus on non-alloy equipment
    - Increase salvage missions
    - Negotiate bulk contracts (-10% if diplomatic)
```

### Multiple Simultaneous Shortages

Chance of 2+ shortages overlapping: 3% per month (crisis scenario)

**Example Crisis**:
```
Month 8: Titanium Shortage (2 months)
Month 9: Titanium Shortage continues + Fuel Crisis (1 month)

Result: Cannot manufacture AND cannot deploy effectively
Player Response: Emergency resource redistribution, black market dependence
```

### Shortage Warning System

**Intelligence Network** (research unlock):
- 1 month warning before shortages
- Allows strategic preparation (buy early, stockpile)
- Costs 50K to unlock, 5K per month maintenance
- 70% accuracy (sometimes false alarms)

---

## Manufacturing Capacity Limits

### Current vs. Proposed

**Current (Broken)**:
- Unlimited manufacturing queue
- No constraints on production
- "Queue everything" is optimal
- No strategic prioritization

**Proposed (Balanced)**:
- Workshop capacity: 5 concurrent projects max
- Advanced Workshop: 10 concurrent projects
- Manufacturing Hub: 20 concurrent projects
- Queue overflow = 2× production time penalty

### Capacity Mechanics

```yaml
Manufacturing Facilities:

Workshop (2×2):
  Cost: 50K credits
  Capacity: 5 concurrent projects
  Engineer Bonus: Standard (100%)
  Build Time: 15 days

Advanced Workshop (3×3):
  Cost: 150K credits
  Capacity: 10 concurrent projects
  Engineer Bonus: +20% speed
  Build Time: 30 days
  Prerequisites: Research "Advanced Manufacturing"

Manufacturing Hub (4×4):
  Cost: 400K credits
  Capacity: 20 concurrent projects
  Engineer Bonus: +40% speed
  Build Time: 60 days
  Prerequisites: Research "Industrial Automation"
```

### Queue Overflow Penalty

**How It Works**:
```
Workshop Capacity: 5 projects
Queue: 8 projects (3 overflow)

Effect:
  - First 5 projects: Normal speed
  - Projects 6-8: 2× production time (delayed)
  - Engineers reallocate inefficiently
  - Morale penalty (overworked engineers)

Strategic Decision:
  - Build more workshops (expensive, space-consuming)
  - Prioritize critical items (accept delays)
  - Cancel low-priority projects (opportunity cost)
```

### Specialization Bonuses

Facilities can specialize for efficiency:

```yaml
Weapon Workshop:
  Specialization: Weapons only
  Bonus: +30% weapon production speed
  Penalty: Cannot produce armor/equipment

Armor Workshop:
  Specialization: Armor only
  Bonus: +30% armor production speed
  Penalty: Cannot produce weapons/equipment

General Workshop:
  Specialization: None
  Bonus: Can produce anything
  Penalty: No speed bonuses
```

---

## Progressive Taxation System

### Current vs. Proposed

**Current (Broken)**:
- Inflation penalty at 20× monthly income (unrealistic threshold)
- No pressure to reinvest wealth
- Hoarding credits is optimal

**Proposed (Balanced)**:
- Progressive taxation based on wealth tiers
- Forces reinvestment to avoid taxes
- Strategic spending encouraged

### Tax Brackets

```yaml
Wealth Tiers (relative to monthly income):

Tier 1: Credits < 5× monthly
  Tax Rate: 0% (no penalty)
  Status: "Modest Reserves"

Tier 2: Credits 5-10× monthly
  Tax Rate: 5% per month
  Status: "Comfortable Reserves"
  Explanation: "Markets notice your wealth, mild inflation"

Tier 3: Credits 10-20× monthly
  Tax Rate: 10% per month
  Status: "Significant Wealth"
  Explanation: "You're printing money, markets react"

Tier 4: Credits 20×+ monthly
  Tax Rate: 15% per month + marketplace inflation
  Status: "Economic Distortion"
  Explanation: "Your wealth destabilizes economy"
  Effect: +20% all marketplace prices (suppliers raise prices)
```

### Tax Avoidance Strategies

**Legitimate**:
- Reinvest in bases (facilities, upgrades)
- Purchase equipment immediately (use it or lose it)
- Research investments (hire more scientists)
- Expand operations (build new bases)

**Grey Area**:
- Offshore accounts (research unlock, -karma)
- Shell companies (hide wealth, risky)
- Barter economy (trade equipment, avoid credits)

**Illegal**:
- Black market transfers (-karma, high penalties if caught)
- Money laundering (complex, 30% loss)

---

## Funding Volatility

### Current vs. Proposed

**Current (Broken)**:
- Stable monthly funding
- Predictable income
- Budget planning trivial

**Proposed (Balanced)**:
- Monthly variance ±20% based on performance
- Unpredictable income requires reserves
- Strategic financial planning essential

### Volatility Factors

```yaml
Funding Calculation:
Base Funding = Country Defense Budget × Relationship Level

Monthly Modifiers:
  Recent Performance (last 3 missions):
    - 3 successes: +15%
    - 2 successes, 1 fail: +5%
    - 1 success, 2 fails: -10%
    - 3 failures: -25%
  
  Public Confidence:
    - No civilian casualties: +10%
    - Minor casualties (1-10): 0%
    - Major casualties (11-50): -15%
    - Mass casualties (51+): -30%
  
  Political Stability:
    - Stable government: 0%
    - Elections ongoing: -10%
    - Coup/civil war: -50%
    - War with neighbor: -20%
  
  Competing Priorities:
    - Economic crisis: -20%
    - Natural disaster: -15%
    - Domestic terrorism: -10%

Final Funding = Base × (1 + Sum_of_Modifiers)
Clamped to: 50% to 150% of base
```

### Example Funding Scenarios

**Best Case (Month 7)**:
```
Base Funding: 100K
Modifiers:
  + Recent Performance (3 wins): +15%
  + Public Confidence (no casualties): +10%
  + Political Stability (stable): 0%
  + No Competing Priorities: 0%

Total: 100K × 1.25 = 125K (excellent month)
```

**Worst Case (Month 9)**:
```
Base Funding: 100K
Modifiers:
  - Recent Performance (3 losses): -25%
  - Public Confidence (mass casualties): -30%
  - Political Stability (coup): -50%
  - Competing Priorities (economic crisis): -20%

Total: 100K × -0.25 = 50K (floor minimum, crisis!)
```

### Reserve Requirements

**Recommended Reserves**:
- Minimum: 2 months operating expenses
- Comfortable: 4 months operating expenses
- Safe: 6 months operating expenses

**Operating Expenses** (typical mid-game):
```
Personnel Maintenance: 30K per month
Facility Maintenance: 20K per month
Craft Operations: 15K per month
Equipment Purchases: 25K per month
Research Costs: 10K per month

Total: 100K per month

Recommended Reserves: 400-600K credits
```

---

## Resource Competition

### Overview

Aliens and countries also compete for resources, creating dynamic marketplace.

### Competitive Dynamics

```yaml
Alien Purchasing:
  - Aliens buy human technology from black market
  - Increases prices by 10-30% (demand surge)
  - Can buy out entire supplier stock
  - Creates scarcity events (sold out items)

Country Stockpiling:
  - Countries preparing for war stockpile materials
  - Titanium/fuel become scarce
  - Prices increase 50-100%
  - Diplomatic leverage required for access

Corporate Competition:
  - Rival organizations compete for resources
  - Bid wars drive prices up
  - Can lock player out of contracts
  - Espionage missions to sabotage rivals
```

### Supply & Demand

**Dynamic Pricing**:
```
Base Price × Demand Modifier × Supply Modifier

Demand Modifier:
  - Low demand (unused): 0.8× price
  - Normal demand: 1.0× price
  - High demand (popular): 1.3× price
  - Extreme demand (crisis): 2.0× price

Supply Modifier:
  - Oversupply: 0.7× price
  - Normal supply: 1.0× price
  - Limited supply: 1.5× price
  - Scarcity: 3.0× price
```

---

## Strategic Reserve Management

### Reserve Types

**Physical Reserves**:
```yaml
Material Stockpile:
  - Store excess salvage/materials
  - Warehouse capacity: 1,000 units
  - Additional storage: Warehouse facility (+500 per facility)
  - Opportunity cost: Space could be other facilities

Fuel Reserves:
  - Base fuel capacity: 1,000 units
  - Fuel tank facilities: +500 per tank
  - Strategic reserve: 30% minimum recommended
  - Emergency refuel: 2× cost from black market

Equipment Reserves:
  - Armory capacity: 50 items
  - Additional storage: Armory expansion (+25 items)
  - Pre-manufactured equipment ready for deployment
  - Insurance against manufacturing disruptions
```

**Financial Reserves**:
```yaml
Emergency Fund:
  - Minimum: 2× monthly expenses
  - Recommended: 4-6× monthly expenses
  - Purpose: Weather funding volatility
  - Avoids debt spiral

War Chest:
  - Offensive reserve for opportunities
  - Bulk purchases when prices low
  - Black market opportunities
  - Emergency recruitment
```

### Reserve Management UI

```
╔══════════════════════════════════════════╗
║      STRATEGIC RESERVES STATUS          ║
╠══════════════════════════════════════════╣
║                                          ║
║ FUEL:          650 / 1,000  [████████░░] ║
║   Status: Adequate (65%)                 ║
║   Missions Supported: 4-5 deployments    ║
║                                          ║
║ MATERIALS:     780 / 1,000  [█████████░] ║
║   Status: Good (78%)                     ║
║   Manufacturing Queue: 15 days supply    ║
║                                          ║
║ CREDITS:       450K (4.5× monthly)       ║
║   Status: Comfortable Reserve            ║
║   Tax Rate: 5% per month                 ║
║   Months of Operations: 4.5 months       ║
║                                          ║
║ WARNING: Titanium shortage predicted     ║
║          next month (70% confidence)     ║
║   Recommendation: Buy 200 units now      ║
║                                          ║
╚══════════════════════════════════════════╝
```

---

## Black Market Integration

### Overview

Black market becomes essential safety valve during scarcity, with ethical tradeoffs.

### Black Market Mechanics

```yaml
Access Requirements:
  - Karma < 0 (unethical actions unlock access)
  - OR complete "Underworld Contact" mission
  - OR pay 50K bribe to gain entry

Pricing:
  - Standard items: 2× marketplace price
  - Scarce items: 3× marketplace price
  - Illegal items: 5× marketplace price
  - Emergency refuel: 2× normal fuel cost

Advantages:
  - Always available (no stock limits)
  - Instant delivery (no wait time)
  - No questions asked (karma irrelevant after purchase)
  - Exclusive items unavailable elsewhere

Disadvantages:
  - Expensive (2-5× normal prices)
  - Karma penalty (-5 to -20 per transaction)
  - Discovery risk (10% chance per transaction)
  - Supplier betrayal (5% chance, trap/ambush)

Discovery Consequences:
  - -30 fame (public scandal)
  - -20 relation with 3+ countries
  - 3 month "investigation" (restricted marketplace)
  - Possible advisor resignation (high-karma advisors leave)
```

### When to Use Black Market

**Legitimate Use Cases**:
- Emergency fuel during crisis (save stranded craft)
- Material shortage bypass (keep production running)
- Time-critical purchases (mission depends on equipment)
- Exclusive items (not available anywhere else)

**Abuse Cases** (heavily penalized):
- Routine purchasing (lazy resource planning)
- Profit arbitrage (buy low, sell high)
- Avoiding taxation (wealth hiding)

---

## Technical Implementation

### Resource Manager Module

```lua
-- engine/economy/resource_manager.lua

ResourceManager = {
  fuel = {
    capacity = 1000,
    current = 800,
    consumption_history = {},
    reserve_threshold = 0.30 -- 30% minimum
  },
  
  materials = {
    titanium = {stock = 500, capacity = 1000},
    elerium = {stock = 200, capacity = 500},
    alien_alloy = {stock = 300, capacity = 800}
  },
  
  manufacturing = {
    workshop_capacity = 5,
    active_projects = 3,
    queue = {}
  }
}

function ResourceManager:checkFuelCapacity(craft, destination_hex)
  local current_hex = craft.position
  local distance = HexGrid:distance(current_hex, destination_hex)
  local fuel_cost = distance * craft.fuel_consumption_per_hex
  local round_trip_cost = fuel_cost * 2
  
  if self.fuel.current < round_trip_cost then
    return false, "Insufficient fuel for round trip"
  end
  
  local remaining_after = self.fuel.current - round_trip_cost
  local reserve_amount = self.fuel.capacity * self.fuel.reserve_threshold
  
  if remaining_after < reserve_amount then
    return false, "Would deplete strategic fuel reserve"
  end
  
  return true, "Sufficient fuel"
end

function ResourceManager:triggerShortageEvent(material_type, duration_months)
  local shortage = {
    material = material_type,
    start_month = GameState.current_month,
    end_month = GameState.current_month + duration_months,
    price_multiplier = 3.0,
    availability = 0.0 -- completely unavailable
  }
  
  table.insert(self.active_shortages, shortage)
  
  -- Notify player
  GUI:showShortageNotification(shortage)
  
  -- Log event
  Analytics:recordShortage(material_type, duration_months)
end

function ResourceManager:checkManufacturingCapacity()
  local capacity = self.manufacturing.workshop_capacity
  local active = self.manufacturing.active_projects
  local queued = #self.manufacturing.queue
  
  if active >= capacity then
    -- Apply overflow penalty to queued items
    for _, project in ipairs(self.manufacturing.queue) do
      project.production_time = project.production_time * 2
    end
    
    return false, "Manufacturing capacity exceeded - queue delayed"
  end
  
  return true, "Capacity available"
end
```

---

## Conclusion

The Resource Scarcity & Economic Pressure System transforms AlienFall's economy from trivial wealth accumulation into dynamic strategic resource management. By introducing scarcity, capacity limits, and market volatility, players must engage in meaningful financial planning throughout the campaign.

**Key Success Metrics**:
- Credit accumulation slows by 40% (balanced economy)
- Strategic decision frequency increases (more choices)
- Reserve management becomes essential (player behavior change)
- Mid-game economic pressure maintained (no more autopilot)

**Implementation Priority**: HIGH (Tier 1)  
**Estimated Development Time**: 2-3 weeks  
**Dependencies**: Economy.md, Basescape.md, Geoscape.md  
**Risk Level**: Medium (requires careful balance tuning)

---

**Document Status**: Design Proposal - Ready for Review  
**Next Steps**: Prototype fuel system, implement shortage events, playtest  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28

