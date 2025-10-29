# FAQ: Basescape - Base Building

[← Back to FAQ Index](FAQ_INDEX.md)

---

## Q: What is Basescape? Is it like X-COM base building?

**A**: **Yes, but grid-based like SimCity**:

Basescape is where you:
- Design facility layouts on a hex grid
- Recruit and train soldiers
- Research alien technologies
- Manufacture equipment
- Store resources and equipment
- Defend against alien base assaults

**Comparisons**:
- **Like X-COM**: Facility construction, research labs, workshops
- **Like SimCity**: Grid placement with adjacency bonuses
- **Like Factorio**: Production chains and efficiency optimization
- **Unlike XCOM 2**: Not a simple menu - physical spatial planning

---

## Q: How does the facility grid work?

**A**: **Hex grid placement with adjacency bonuses**:

### Grid Sizes by Base Size

| Base Size | Grid | Total Tiles | Available Slots | SimCity Comparison |
|-----------|------|-------------|----------------|-------------------|
| **Small** | 4×4 | 16 | 8-10 | Small town |
| **Medium** | 5×5 | 25 | 15-18 | Medium city |
| **Large** | 6×6 | 36 | 24-28 | Large city |
| **Huge** | 7×7 | 49 | 35-40 | Metropolis |

### Adjacency System

**Like SimCity**:
- Facilities benefit from neighbors (e.g., Lab + Lab = +10% research)
- Power plants boost adjacent facilities
- Storage facilities benefit from clustering
- Defensive facilities create overlapping coverage

**Unlike X-COM original**:
- Not random underground generation
- Planned layout like a city
- Optimization is key to efficiency

**Like Factorio**:
- Production chains benefit from proximity
- Resource flow matters
- Efficiency through layout optimization

---

## Q: What types of facilities exist?

**A**: **Specialized buildings for different functions**:

### Facility Categories

| Category | Function | SimCity Equivalent | X-COM Equivalent |
|----------|----------|-------------------|-----------------|
| **Command** | Base operations | City Hall | Command Center |
| **Research** | Technology projects | University | Research Lab |
| **Manufacturing** | Equipment production | Industrial Zone | Workshop |
| **Storage** | Resource/item storage | Warehouse District | General Stores |
| **Housing** | Personnel capacity | Residential Zone | Living Quarters |
| **Defense** | Base protection | Police/Military | Defense Systems |
| **Power** | Energy generation | Power Plant | Power Source |
| **Radar** | Detection range | Communication Tower | Radar System |

### Facility Examples

**Research Facilities**:
- Basic Lab (small, cheap, low capacity)
- Advanced Lab (medium, expensive, high capacity)
- Alien Containment (special, requires tech)

**Manufacturing Facilities**:
- Workshop (general production)
- Foundry (metal working)
- Bio-Engineering Lab (organic items)

**Storage Facilities**:
- General Storage (items/equipment)
- Fuel Depot (craft fuel)
- Cold Storage (biological materials)

---

## Q: How do adjacency bonuses work?

**A**: **Like SimCity industrial/commercial synergies**:

### Bonus Types

**Research Speed**:
- Lab + Lab = +10% research speed
- Lab + Power Plant = +5% bonus
- Lab + Command Center = +5% bonus
- 3 Labs clustered = +25% total

**Production Efficiency**:
- Workshop + Workshop = +15% production
- Workshop + Storage = +10% bonus
- Workshop + Power = +5% bonus

**Defense Coverage**:
- Defense Facility + Defense Facility = overlapping fields
- Defense + Power = +20% effectiveness
- Defense + Command = +10% coordination

**Strategic Planning**:
- Plan clusters before building (like SimCity zoning)
- Leave space for future expansion
- Balance immediate needs vs. long-term optimization

---

## Q: How does base expansion work?

**A**: **Sequential upgrades, like Civilization city growth**:

### Expansion Path
1. Start at chosen size (Small/Medium/Large/Huge)
2. Expand to next size when ready
3. All existing facilities preserved
4. New slots become available
5. Must follow sequential progression (can't skip sizes)

### Expansion Costs

| From → To | Cost | Build Time | Requirements |
|-----------|------|------------|--------------|
| **Small → Medium** | 250K | 45 days | Basic tech, +0 relations |
| **Medium → Large** | 400K | 60 days | Advanced tech, +50 relations |
| **Large → Huge** | 600K | 90 days | High tech, +75 relations |

**Like Civilization**:
- Growth requires resources and time
- Late-game cities are massive
- Strategic cities get priority expansion

**Unlike X-COM**:
- Not building new bases - expanding existing ones
- Diplomatic requirements for large expansions
- Expensive investment decision

---

## Q: How does research work? Is it like Civilization's tech tree?

**A**: **Yes, with X-COM's alien tech integration and man-day resource system**:

### Research System

**Like Civilization**:
- Tech tree with prerequisites
- Multiple research paths simultaneously
- Research speed based on scientist allocation
- Can choose research priorities

**Like X-COM**:
- Research alien items for reverse engineering
- Interrogate captured aliens for intel
- Autopsy aliens to understand biology
- Research unlocks manufacturing

**Unlike Civilization**:
- Research requires specific items (not just science points)
- Scientists are actual units with salaries
- Research can be paused/resumed without penalty

### Research Mechanics

**Resource Requirements**:
- **Scientists**: Allocated personnel (units assigned to research)
- **Research facility capacity**: Limited by facility size
- **Specific items**: Alien artifacts, samples, technology
- **Credits**: Funding the project (upfront cost)
- **Time**: Man-days of work (Scientists × Days)

**Progress Calculation**:
```
Man-Days Required: Project complexity (e.g., 30 man-days)
Daily Progress: Number of scientists allocated
Completion Time: Man-Days ÷ Scientists per day

Example 1: Basic Research
Project: Laser Weapons (50 man-days)
Scientists: 5 allocated
Time: 50 ÷ 5 = 10 days to complete

Example 2: Advanced Research
Project: Plasma Technology (150 man-days)
Scientists: 10 allocated
Time: 150 ÷ 10 = 15 days

Example 3: Alien Autopsy
Project: Sectoid Autopsy (30 man-days)
Scientists: 3 allocated
Time: 30 ÷ 3 = 10 days
Required: 1 Sectoid Corpse (consumed on completion)
```

**Diminishing Returns on Scientists**:
```
Adding more scientists speeds research, but with diminishing returns:

1 scientist = 100% efficiency (1 man-day per day)
5 scientists = 100% efficiency (5 man-days per day)
10 scientists = 80% efficiency (8 man-days per day)
15 scientists = 60% efficiency (9 man-days per day)
20 scientists = 50% efficiency (10 man-days per day)

Example: 100 man-day project
- 5 scientists: 100 ÷ 5 = 20 days
- 10 scientists: 100 ÷ 8 = 12.5 days (not 10 days)
- 20 scientists: 100 ÷ 10 = 10 days (not 5 days)

Reason: Coordination overhead, bottlenecks, equipment sharing
```

### Research Technology Tree

**Early Game Research Path**:
```
Starting Tech (free):
├─ Basic Weapons
├─ Combat Armor
└─ Scout Craft

First Tier (100-200 man-days each):
├─ Laser Weapons (requires Alien Power Source)
│  └─ Unlocks: Laser Rifle, Laser Pistol manufacturing
├─ Improved Armor (requires Alien Alloy)
│  └─ Unlocks: Combat Armor Mk.II manufacturing
└─ Interceptor Craft (requires UFO Navigation)
   └─ Unlocks: F-16 Interceptor manufacturing

Second Tier (200-400 man-days each):
├─ Plasma Weapons (requires Laser Weapons + Plasma Rifle)
│  └─ Unlocks: Plasma Rifle, Heavy Plasma manufacturing
├─ Power Armor (requires Improved Armor + Elerium)
│  └─ Unlocks: Power Armor manufacturing
└─ Advanced Craft (requires Interceptor + UFO Power Source)
   └─ Unlocks: Firestorm craft manufacturing
```

**Research Branching Example**:
```
Captured Sectoid Corpse → Multiple research options:

Option A: Sectoid Autopsy (30 man-days)
→ Unlocks: Sectoid biology knowledge
→ Benefits: +10% damage vs Sectoids
→ Leads to: Genetic Engineering research

Option B: Sectoid Interrogation (50 man-days, requires LIVING prisoner)
→ Unlocks: Alien command structure intel
→ Benefits: Reveals alien base locations
→ Leads to: Psionic Research

Option C: Sectoid Weapons Research (40 man-days, requires Plasma Pistol)
→ Unlocks: Plasma Pistol manufacturing
→ Benefits: Can manufacture alien weapons
→ Leads to: Advanced Plasma Weapons
```

### Cost Scaling Mechanics

**Research Cost Randomization** (adds replayability):
```
Each campaign has unique research costs within range:

Basic Rifle Research:
- Base: 50 man-days
- Random multiplier: 50%-150%
- Possible range: 25-75 man-days

Campaign A: 40 man-days (80% multiplier)
Campaign B: 60 man-days (120% multiplier)
Campaign C: 35 man-days (70% multiplier)

Effect: Forces different tech paths each playthrough
```

**Facility Bonuses**:
```
Advanced Lab facility: +20% research speed
Adjacent Labs: +10% per adjacent lab (max +30%)

Example: Plasma Research (150 man-days)
- Basic Lab: 150 man-days required
- Advanced Lab: 150 × 0.8 = 120 man-days
- Advanced Lab + 2 Adjacent Labs: 150 × 0.8 × 0.8 = 96 man-days

With 10 scientists (8 man-days/day after diminishing returns):
- Basic: 150 ÷ 8 = 19 days
- Optimized: 96 ÷ 8 = 12 days

Savings: 7 days faster research
```

**Scientist Specialization Bonus**:
```
Scientists gain expertise in research categories:
- Each completed research in category: +10% efficiency

Example: Dr. Smith specializes in Weapons research
- Completed 5 weapons projects: +50% efficiency
- Assigned to Plasma Weapons (100 man-days)
- Effective: 100 × 0.5 = 50 man-days contributed (as if 150 man-days)

Strategy: Keep scientists on specialized tracks
```

### Failed Research & Cancellation

**Research Cannot Fail**:
- No random failure chance
- Guaranteed completion if resources remain

**Cancellation Mechanics**:
```
Can cancel research anytime:
- Returns 50-75% of invested credits
- Partial progress retained (can resume later)
- Items consumed in research are lost (e.g., alien corpses)

Example:
Project: Sectoid Autopsy (30 man-days, costs 10,000 credits)
Progress: 15 man-days completed (50%)
Cancellation: Refund 5,000-7,500 credits (50-75%)
Resume later: Only need 15 more man-days (50% done)
```

### Multi-Track Research Strategy

**Example Base Research Setup**:
```
Base has: 3 Labs, 15 Scientists available

Track 1: Laser Weapons (100 man-days) - 5 scientists (20 days)
Track 2: Improved Armor (80 man-days) - 5 scientists (16 days)
Track 3: Sectoid Autopsy (30 man-days) - 5 scientists (6 days)

Day 0: All 3 projects start
Day 6: Sectoid Autopsy completes
  → Reassign 5 scientists to Track 1 (Laser Weapons)
Day 16: Improved Armor completes
  → Reassign 5 scientists to Track 1 (Laser Weapons)
Day 20: Laser Weapons completes

Total time: 20 days for 3 projects
vs. Sequential: 6 + 16 + 20 = 42 days

Savings: 22 days through parallel research
```

**Comparison**:
- **Like Civilization VI**: Eureka moments (item discoveries speed research)
- **Like X-COM**: Must research items to understand alien tech
- **Like StarCraft**: Research unlocks new units/buildings
- **Unlike XCOM 2**: No random research costs, predictable progression
- **Like Europa Universalis**: Tech groups with prerequisites

**For complete research mechanics, see: design/mechanics/Economy.md**

---

## Q: How does manufacturing work?

**A**: **Like StarCraft production queues + Factorio resource chains**:

### Manufacturing System

**Like StarCraft**:
- Production queue (build order list)
- Engineer allocation speeds production
- Multiple queues run in parallel
- Can prioritize urgent items

**Like Factorio**:
- Items require specific resources (input → output)
- Resources can be synthesized (Metal + Fuel → Titanium)
- Production chains create complex items

**Like X-COM**:
- Manufacture researched items only
- Sell manufactured goods for profit (50% of cost)
- Equip your soldiers with custom gear

### Manufacturing Requirements

**Prerequisites**:
1. **Research completion**: Technology must be researched first
2. **Raw resources**: Materials needed for production
3. **Manufacturing facility**: Workshop with engineer capacity
4. **Credits**: Upfront funding or ongoing costs
5. **Engineers**: Allocated workforce (man-days)
6. **Storage space**: Warehouse capacity for finished goods

### Production Cost Calculation

**Formula**:
```
Total Cost = (Base Item Cost) × Quantity
Daily Cost = Total Cost ÷ Days to Complete
Resource Consumption = Item Requirements × Quantity
Engineer Hours = Item Complexity × Quantity
```

**Example 1: Simple Production (Laser Rifle)**:
```
Item: Laser Rifle
Base Cost: 15,000 credits
Resource Requirements: 2 Alien Alloy, 1 Power Cell
Engineer Complexity: 25 man-days

Production Run: 5 Laser Rifles
Total Cost: 15,000 × 5 = 75,000 credits
Resources: 10 Alien Alloy, 5 Power Cells
Engineer Days: 25 × 5 = 125 man-days

Engineers Allocated: 10
Completion Time: 125 ÷ 10 = 12.5 days
Daily Cost: 75,000 ÷ 12.5 = 6,000 credits/day
```

**Example 2: Batch Bonus (10 Combat Armor)**:
```
Item: Combat Armor
Base Cost: 20,000 credits
Complexity: 40 man-days
Batch Size: 10 units

Without Batch Bonus:
Total: 40 × 10 = 400 man-days

With Batch Bonus (+10% for 10+ units):
Total: 400 × 0.9 = 360 man-days

Savings: 40 man-days (10% faster)

With 15 engineers:
- Without bonus: 400 ÷ 15 = 27 days
- With bonus: 360 ÷ 15 = 24 days
- Time saved: 3 days
```

### Batch Production Bonuses

**Scaling Bonuses**:

| Batch Size | Bonus | Effective Time | Example (100 man-day item) |
|-----------|-------|---------------|---------------------------|
| **1 unit** | 0% | 100% time | 100 man-days |
| **5 units** | 5% | 95% per unit | 475 man-days (vs 500) |
| **10 units** | 10% | 90% per unit | 900 man-days (vs 1000) |
| **20 units** | 15% | 85% per unit | 1700 man-days (vs 2000) |
| **50 units** | 20% | 80% per unit | 4000 man-days (vs 5000) |

**Strategic Implication**:
```
Producing 10 Laser Rifles at once:
- Sequential (1 at a time): 25 man-days × 10 = 250 man-days
- Batch (10 at once): 25 × 10 × 0.9 = 225 man-days
- Savings: 25 man-days (10% faster)

Why: Shared setup, tooling, materials, economies of scale
```

### Production Queue System

**Queue Mechanics**:
- **Queue limit**: 3-10 projects (depends on facility)
- **Auto-start**: Next project begins when current completes
- **Reordering**: Can reorder queue (1-2 day startup delay)
- **Pause/Resume**: Halt production without losing progress
- **Resource check**: Production pauses if materials unavailable

**Example Production Queue**:
```
Workshop Queue (10 engineers available):
┌─────────────────────────────────────────┐
│ Priority 1: 5 Laser Rifles (12 days)    │ ← Currently producing
│ Priority 2: 10 Combat Armor (24 days)   │ ← Starts after #1
│ Priority 3: 2 Interceptor Missiles (8d) │ ← Starts after #2
│ Priority 4: 1 Craft (60 days)           │ ← Starts after #3
└─────────────────────────────────────────┘

Day 0: Laser Rifles start
Day 12: Laser Rifles complete, Combat Armor starts
Day 36: Combat Armor complete, Missiles start
Day 44: Missiles complete, Craft starts
Day 104: All projects complete

Total time: 104 days (automated production chain)
```

**Queue Optimization Strategy**:
```
Strategy: Fast-turnaround items first

Bad Queue (slow items first):
1. Craft (60 days) → Day 60
2. Laser Rifles (12 days) → Day 72
3. Missiles (8 days) → Day 80
Result: Wait 60 days for first useful item

Good Queue (fast items first):
1. Laser Rifles (12 days) → Day 12 ✓ Equip now
2. Missiles (8 days) → Day 20 ✓ Equip now
3. Craft (60 days) → Day 80
Result: Usable equipment in 12 days, not 60
```

### Production Speed Factors

**Engineer Allocation**:
```
Diminishing Returns on Engineers:

Project: 100 man-day item

1 engineer: 100 days (100% efficiency)
5 engineers: 20 days (100% efficiency)
10 engineers: 12.5 days (80% efficiency)
20 engineers: 10 days (50% efficiency)

Why: Coordination overhead, tooling bottlenecks, workspace limits
```

**Facility Level Bonuses**:

| Facility Type | Production Speed | Example (100 man-days) |
|--------------|------------------|----------------------|
| **Workshop** | +0% | 100 man-days |
| **Advanced Workshop** | +20% faster | 80 man-days |
| **Manufacturing Hub** | +30% faster | 70 man-days |
| **Specialized Facility** | +40% faster (category-specific) | 60 man-days |

**Adjacency Bonuses** (see "How do adjacency bonuses work?" below):
```
Workshop + Workshop: +15% production speed
Workshop + Storage: +10% bonus (materials close)
Workshop + Power Plant: +5% bonus (reliable power)

Example: Manufacturing Hub + 2 adjacent Workshops
Base: 100 man-days
Facility bonus: 100 × 0.7 = 70 man-days (30% faster)
Adjacency: 70 × 0.85 = 59.5 man-days (15% adjacency)
Total savings: 40.5 man-days (40.5% faster than basic)
```

### Manufacturing Economics

**Production vs. Purchase Comparison**:

| Item | Marketplace Cost | Manufacturing Cost | Savings | Production Time |
|------|-----------------|-------------------|---------|----------------|
| **Laser Rifle** | 25,000 | 15,000 | 40% | 25 man-days (3 days w/ 8 engineers) |
| **Combat Armor** | 35,000 | 20,000 | 43% | 40 man-days (5 days w/ 8 engineers) |
| **Interceptor Missile** | 50,000 | 30,000 | 40% | 60 man-days (8 days w/ 8 engineers) |
| **Craft** | 500,000 | 300,000 | 40% | 400 man-days (50 days w/ 8 engineers) |

**Strategic Decision**:
```
Scenario: Need 10 Laser Rifles immediately

Option A: Buy from marketplace
Cost: 25,000 × 10 = 250,000 credits
Time: Instant delivery (1-3 days)
Benefit: Immediate use

Option B: Manufacture
Cost: 15,000 × 10 = 150,000 credits (batch discount: 135,000)
Time: 25 × 10 × 0.9 = 225 man-days ÷ 10 engineers = 22.5 days
Benefit: Save 100,000+ credits

Choice depends on urgency vs. budget
```

**Bulk Production for Export**:
```
Strategy: Manufacture surplus, sell for profit

Example: Laser Rifle
Manufacturing Cost: 15,000 credits (25 man-days)
Marketplace Sale Value: 25,000 × 0.5 = 12,500 credits

Wait, that's a LOSS!

Correct Strategy: Manufacture high-value items
Example: Plasma Rifle
Manufacturing Cost: 40,000 credits (80 man-days)
Marketplace Sale Value: 80,000 × 0.5 = 40,000 credits
Break-even (no profit from sales directly)

Actual profit strategy:
1. Manufacture items cheaper than marketplace
2. Use them for missions (saves buying cost)
3. Salvage alien equipment to manufacture
4. Sell alien items (pure profit, no manufacturing cost)
```

### Resource Scarcity & Production Pausing

**Scenario: Material Shortage**:
```
Queue: 10 Plasma Rifles
Required: 10 Alien Alloy, 10 Elerium (total)
Available: 5 Alien Alloy, 10 Elerium

Day 0-5: Produce 5 Plasma Rifles (consume 5 Alloy)
Day 5: Alloy depleted → Production PAUSES (not cancelled)
Day 10: Mission completes, recover 8 Alien Alloy
Day 10: Production RESUMES automatically
Day 10-15: Complete remaining 5 Plasma Rifles

Result: No waste, no restart penalty, just delay
```

**Strategic Resource Management**:
```
Priority System:
1. Critical equipment (needed for next mission)
2. Bulk production (long-term stocks)
3. Experimental items (if resources available)

Example: Alien Alloy shortage
- Pause: Bulk Combat Armor production
- Prioritize: 5 Laser Rifles for immediate mission
- Resume: Combat Armor after mission salvage
```

### Comparison to Other Games

| Game | Manufacturing Style | AlienFall Equivalent |
|------|-------------------|---------------------|
| **StarCraft** | Build queues, worker allocation | Exact match: Engineer allocation, queue system |
| **Factorio** | Automated production chains | Similar: Resource synthesis, batch production |
| **X-COM** | One-item-at-a-time, slow production | Different: AlienFall has queues, batch bonuses |
| **XCOM 2** | Instant manufacturing (time-gated) | Different: AlienFall has real-time production |
| **Civilization** | Production points per turn | Similar: Man-days system is production points |

**For complete manufacturing mechanics, see: design/mechanics/Economy.md**

---

## Q: How do I recruit units?

**A**: **Like Heroes of Might & Magic hero hiring**:

### Recruitment System

**Recruitment Sources**:
- **Base recruitment**: Standard soldiers from barracks
- **Suppliers**: Specialized units from marketplace
- **Faction rewards**: Elite units for diplomatic success
- **Promotions**: Existing units advance through ranks

**Cost Structure**:
- Recruitment cost (one-time payment)
- Monthly salary (ongoing maintenance)
- Equipment cost (gear them up)
- Training time (before deployment ready)

**Comparison**:
- **Like HOMM**: Heroes available for hire in taverns
- **Like X-COM**: Recruit soldiers from hiring screen
- **Like Fire Emblem**: Limited unit types per chapter
- **Unlike XCOM 2**: Not random stat generation (modded stats)

---

## Q: How does base storage work?

**A**: **Like Resident Evil inventory management**:

### Storage System

**Storage Capacity**:
- Each base has limited storage slots
- Storage facilities increase capacity
- Items have different stack sizes
- Resources stack to large quantities
- Unique items don't stack

**Storage Types**:
- General Storage (equipment, items)
- Fuel Depot (craft fuel only)
- Cold Storage (biological materials)
- Alien Containment (living prisoners)

**Management Strategy**:
- Sell excess items to free space
- Transfer items between bases
- Prioritize valuable/rare items
- Manufacture items into compact forms

**Comparison**:
- **Like Resident Evil**: Limited slots, strategic choices
- **Unlike X-COM**: Not unlimited storage
- **Like Diablo**: Inventory Tetris
- **Unlike Minecraft**: Not infinite chests

---

## Q: How does base defense work?

**A**: **Like tower defense + X-COM base defense**:

### Base Defense Mechanics

**When Attacked**:
1. Alien faction targets your base
2. Defense facilities engage automatically (like tower defense)
3. If defenses fail, ground battle begins (X-COM base defense)
4. Lose battle = base destroyed, units/items lost

**Defense Facilities**:
- **Turrets**: Automatic weapons (like tower defense towers)
- **Hangars**: Launch defensive interception
- **Barriers**: Slow enemy advance
- **Shields**: Absorb damage before penetration

**Defensive Strategy**:
- **Like tower defense**: Layered defenses
- **Like X-COM**: Soldier deployment matters
- **Like StarCraft**: Resource investment in defense
- **Unlike XCOM 2**: Can lose base permanently

---

## Q: Can I have multiple bases? How do they interact?

**A**: **Yes, like Civilization's multiple cities**:

### Multi-Base Management

**Base Network**:
- Each base operates independently
- Transfer items/units between bases
- Shared research (global progress)
- Independent manufacturing queues

**Strategic Specialization**:
- **Research base**: Maximum labs, scientists
- **Manufacturing base**: Maximum workshops, engineers
- **Military base**: Maximum hangars, soldiers
- **Hybrid bases**: Balanced approach

**Like Civilization**:
- Specialize cities for different roles
- Capital gets priority development
- Border cities focus on defense
- Commerce cities focus on economy

**Unlike X-COM**:
- One base per province limit
- Can't spam bases everywhere
- Each base is strategically placed

---

## Q: How does base maintenance work?

**A**: **Like Civilization city maintenance**:

### Monthly Costs

**Fixed Costs**:
- Facility maintenance (per facility)
- Power generation (energy costs)
- Storage upkeep (per storage facility)

**Variable Costs**:
- Personnel salaries (scientists, engineers, soldiers)
- Research funding (active projects)
- Manufacturing costs (production materials)

**Income Sources**:
- Country funding (monthly payments)
- Selling items (marketplace)
- Selling manufactured goods (profit margin)
- Mission rewards (salvage, bonuses)

**Balancing Act**:
- Expand carefully to avoid bankruptcy
- Maintain positive cash flow
- Plan major expenses in advance
- Emergency funds for unexpected costs

---

## Q: What happens if I run out of money?

**A**: **Like Civilization bankruptcy**:

### Financial Crisis

**Consequences**:
- Cannot start new research
- Cannot queue manufacturing
- Cannot recruit new units
- Existing projects continue (already paid)
- Can sell items for emergency cash

**Recovery Options**:
- Sell excess equipment
- Complete missions for rewards
- Improve country relations for funding
- Halt expensive projects temporarily

**Unlike X-COM**:
- No forced game over from debt
- Can recover through smart play
- Debt is manageable, not catastrophic

---

## Q: Can I demolish facilities?

**A**: **Yes, like SimCity bulldozer**:

**Demolition Rules**:
- Can demolish any facility (costs nothing)
- Get 50% of construction cost back
- Items stored in facility move to general storage
- Personnel reassigned automatically
- Cannot demolish if base would become inoperable

**Strategic Demolition**:
- Remove obsolete facilities
- Redesign base layout for better adjacency
- Free space for advanced facilities
- Adapt to changing strategic needs

---

## Q: What's the optimal base layout?

**A**: **Depends on strategy, like Factorio factory design**:

### Layout Strategies

**Research-Focused Base**:
```
[Command] [Lab] [Lab]
[Power] [Lab] [Lab] [Lab]
[Storage] [Living] [Radar]
```
- Maximize lab adjacency bonuses
- Central power for efficiency
- Compact design

**Manufacturing Base**:
```
[Workshop] [Workshop] [Workshop]
[Storage] [Workshop] [Workshop] [Storage]
[Power] [Living] [Hangar]
```
- Workshop clusters for +15% bonus
- Adjacent storage for materials
- Hangar for deliveries

**Defensive Base**:
```
[Turret] [Radar] [Turret]
[Hangar] [Command] [Hangar]
[Turret] [Shield] [Turret]
```
- Turrets cover all approaches
- Central command coordination
- Hangars for interceptors

**Like Factorio**:
- Optimize for throughput
- Plan for future expansion
- Balance aesthetics with efficiency

---

## Next Steps

- **Master tactical combat**: Read [Battlescape FAQ](FAQ_BATTLESCAPE.md)
- **Understand research**: Read [Economy FAQ](FAQ_ECONOMY.md)
- **Learn unit management**: Read [Units FAQ](FAQ_UNITS.md)
- **See full mechanics**: Check [design/mechanics/Basescape.md](../mechanics/Basescape.md)

[← Back to FAQ Index](FAQ_INDEX.md)

