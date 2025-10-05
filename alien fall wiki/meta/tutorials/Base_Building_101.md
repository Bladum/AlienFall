# Base Building 101

**Tags:** `#tutorial` `#player-guide` `#basescape` `#facilities` `#management`  
**Related:** [[QuickStart_Guide]], [[Research_Strategy_Guide]], [[../balance/README]]  
**Audience:** New Players  
**Reading Time:** 12 minutes

---

## Overview

Your base is the strategic heart of your operations in Alien Fall. This guide covers everything from initial base layout to optimal facility placement, resource management, and expansion strategies.

**What You'll Learn:**
- Base grid system and facility placement
- Core facilities and their functions
- Expansion priorities and build order
- Resource management and upkeep costs
- Multi-base strategies

---

## Base Grid System

### Understanding the Grid

Every base uses a **6x6 grid layout** (36 tiles total):

```
   1  2  3  4  5  6
A [·][·][·][·][·][·]
B [·][·][·][·][·][·]
C [·][·][A][L][·][·]  <- Starting facilities
D [·][·][H][P][·][·]
E [·][·][·][·][·][·]
F [·][·][·][·][·][·]

Legend:
A = Access Lift (entry point)
L = Living Quarters
H = Hangar
P = Power Generator
· = Empty tile
```

**Grid Rules:**
- Each facility occupies 1 tile (20x20 pixels)
- Facilities must be connected (adjacent) to Access Lift
- No diagonal connections (must share edges)
- Cannot build over existing facilities
- Access Lift is permanent (cannot move/destroy)

---

## Starting Base Analysis

### Initial Facilities (Day 1)

Your starting base includes 4 pre-built facilities:

```
STARTING FACILITIES
═══════════════════════════════════════════════
Facility         | Size | Function           
─────────────────┼──────┼───────────────────
Access Lift      | 1x1  | Base entry (required)
Living Quarters  | 1x1  | Houses 10 soldiers
Hangar           | 1x1  | Stores 1 craft
Power Generator  | 1x1  | Provides 10 power
═══════════════════════════════════════════════
```

**Starting Capacity:**
- **Soldiers**: 10 maximum (recruit 6 more!)
- **Craft**: 1 interceptor
- **Power**: 10 units (5 surplus)
- **Scientists**: 0 (need lab!)
- **Engineers**: 0 (need workshop!)

### Immediate Needs

**Critical Gaps:**
- ❌ No Laboratory (cannot research)
- ❌ No Workshop (cannot manufacture)
- ❌ No Stores (limited item storage)
- ❌ Limited soldier capacity
- ⚠️ Low power margin

**First Priority Builds:**
1. **Laboratory** - Unlock research (Day 2)
2. **Workshop** - Enable manufacturing (Day 5)
3. **Stores** - Expand storage (Day 8)

---

## Core Facilities Guide

### Laboratory

**Purpose:** Research alien technology

```
LABORATORY
─────────────────────────────────────
Build Cost: $400,000
Build Time: 15 days
Maintenance: $30,000/month
Power: -2 units

Provides:
• 10 scientist capacity
• 1 active research project
• +10% research speed per adjacent lab
─────────────────────────────────────
```

**Why Build First:**
- Research unlocks new weapons, armor, facilities
- Early research = faster tech progression
- Aliens get stronger over time (must keep pace)

**Optimal Placement:**
- Adjacent to Access Lift (easy connection)
- Leave space for 2nd lab (stacking bonus!)
- Near power generators

### Workshop

**Purpose:** Manufacture items and craft

```
WORKSHOP
─────────────────────────────────────
Build Cost: $500,000
Build Time: 20 days
Maintenance: $35,000/month
Power: -3 units

Provides:
• 10 engineer capacity
• 1 active manufacturing project
• +10% production speed per adjacent workshop
─────────────────────────────────────
```

**Why Build Second:**
- Manufacture advanced weapons/armor
- Build additional craft
- Sell manufactured items for profit
- Required for late-game equipment

**Optimal Placement:**
- Near laboratory (tech synergy)
- Stack multiple workshops
- Close to stores (material access)

### Stores

**Purpose:** Expand item storage capacity

```
STORES
─────────────────────────────────────
Build Cost: $100,000
Build Time: 10 days
Maintenance: $5,000/month
Power: -1 unit

Provides:
• +50 item storage slots
• Organized inventory
• No capacity penalties
─────────────────────────────────────
```

**Starting Storage:** 50 slots (from Access Lift)  
**With 1 Stores:** 100 slots  
**With 2 Stores:** 150 slots

**When to Build:**
- When inventory >80% full
- Before major missions (loot storage)
- After Laboratory and Workshop

### Living Quarters

**Purpose:** House soldiers and personnel

```
LIVING QUARTERS
─────────────────────────────────────
Build Cost: $300,000
Build Time: 12 days
Maintenance: $10,000/month
Power: -1 unit

Provides:
• +10 soldier capacity
• +5 scientist capacity
• +5 engineer capacity
• Morale bonus (+5%)
─────────────────────────────────────
```

**Capacity Planning:**
- Start: 10 soldiers
- +1 Quarters: 20 soldiers
- +2 Quarters: 30 soldiers (recommended max)

**Build Priority:** Medium (expand when recruiting)

### Power Generator

**Purpose:** Provide electricity for facilities

```
POWER GENERATOR
─────────────────────────────────────
Build Cost: $250,000
Build Time: 18 days
Maintenance: $20,000/month
Power: +10 units

Provides:
• 10 power units
• Enables advanced facilities
• +5% efficiency per adjacent generator
─────────────────────────────────────
```

**Power Budget Example:**
```
Facility              | Power Cost
──────────────────────┼───────────
Access Lift           | -1
Living Quarters       | -1
Hangar                | -2
Laboratory            | -2
Workshop              | -3
Stores                | -1
──────────────────────┼───────────
TOTAL CONSUMPTION     | -10
──────────────────────┼───────────
1x Power Generator    | +10
──────────────────────┼───────────
NET POWER             | 0 (critical!)
──────────────────────┼───────────
```

**Build 2nd Generator When:**
- Net power < 2 units
- Planning to build 2+ facilities
- Expanding to advanced facilities (radar, defense)

---

## Optimal Build Order

### Month 1: Foundation (Days 1-30)

```
DAY 1-2: Planning Phase
─────────────────────────────────────
[✓] Hire 4 soldiers (fill starting capacity)
[✓] Assign starting cash:
    • Reserve $800,000 for Laboratory
    • Reserve $500,000 for Workshop
    • Keep $200,000 emergency fund
[✓] Plan base layout on paper

DAY 3-17: Laboratory Construction
─────────────────────────────────────
[✓] Begin Laboratory build (tile C3)
[✓] Hire 5 scientists ($50k each)
[✓] Run missions for funding
[ ] Wait for completion...

DAY 18: Laboratory Complete!
─────────────────────────────────────
[✓] Assign scientists to lab
[✓] Start "Alien Biology" research
[✓] Begin Workshop build (tile C4)

DAY 19-38: Workshop Construction
─────────────────────────────────────
[✓] Continue missions
[✓] Hire 5 engineers ($45k each)
[ ] Wait for workshop completion...
```

### Month 2: Expansion (Days 31-60)

```
DAY 38: Workshop Complete!
─────────────────────────────────────
[✓] Assign engineers
[✓] Begin Stores construction (tile C5)
[✓] Start Power Generator #2 (tile D5)

DAY 48: Stores Complete
─────────────────────────────────────
[✓] Organize inventory
[✓] Sell excess items
[✓] Start Living Quarters #2 (tile B3)

DAY 56: Power Generator Complete
─────────────────────────────────────
[✓] +10 power capacity
[✓] Plan advanced facilities
```

### Month 3: Specialization (Days 61-90)

```
Choose Your Path:
─────────────────────────────────────
PATH A: Research Focus
  → Laboratory #2 (stacking bonus)
  → Advanced Research projects
  → Faster tech unlocks

PATH B: Production Focus
  → Workshop #2 (stacking bonus)
  → Mass production
  → Income from sales

PATH C: Military Focus
  → Hangar #2 (second interceptor)
  → Training Center
  → Elite soldier development
```

---

## Advanced Facilities (Month 3+)

### Radar System

```
RADAR SYSTEM
─────────────────────────────────────
Build Cost: $600,000
Build Time: 20 days
Maintenance: $40,000/month
Power: -4 units

Provides:
• Extended UFO detection range
• Earlier mission warnings
• +25% detection radius
• Strategic intel
─────────────────────────────────────
```

**Build When:** Month 3-4 (after core facilities)

### Alien Containment

```
ALIEN CONTAINMENT
─────────────────────────────────────
Build Cost: $500,000
Build Time: 18 days
Maintenance: $30,000/month
Power: -3 units
Prerequisite: Research "Alien Biology"

Provides:
• Capture live aliens
• Advanced research options
• Intel gathering
• 5 alien capacity
─────────────────────────────────────
```

**Build When:** Mid-game (Month 4-6)

### Psi Lab

```
PSI LAB
─────────────────────────────────────
Build Cost: $750,000
Build Time: 25 days
Maintenance: $50,000/month
Power: -5 units
Prerequisite: Research "Psionics"

Provides:
• Psionic soldier training
• Psi testing
• Counter-psi research
• 10 trainee capacity
─────────────────────────────────────
```

**Build When:** Late game (Month 6+)

---

## Facility Placement Strategies

### Efficiency Layout (Recommended)

```
   1  2  3  4  5  6
A [·][·][R][S][·][·]
B [·][Q][L][L][W][·]
C [·][·][A][H][W][P]
D [·][·][H][S][P][·]
E [·][·][D][·][·][·]
F [·][·][·][·][·][·]

Legend:
A = Access Lift
L = Laboratory (x2, stacked!)
W = Workshop (x2, stacked!)
P = Power Generator (x2)
Q = Living Quarters
H = Hangar (x2)
S = Stores (x2)
R = Radar System
D = Defense System
```

**Benefits:**
- ✓ Labs adjacent (+10% research bonus)
- ✓ Workshops adjacent (+10% production bonus)
- ✓ Power generators grouped (efficiency)
- ✓ Compact design (short connections)
- ✓ Expansion space available

### Defensive Layout (For Harder Difficulties)

```
   1  2  3  4  5  6
A [·][·][D][D][·][·]
B [·][T][A][L][T][·]
C [·][D][H][W][D][·]
D [·][·][P][P][·][·]
E [·][·][·][·][·][·]
F [·][·][·][·][·][·]

Legend:
A = Access Lift
L = Laboratory
W = Workshop
P = Power Generator
H = Hangar
D = Defense Turret
T = Training Center
```

**Benefits:**
- ✓ Defense turrets guard Access Lift
- ✓ Training centers near entry (soldier response)
- ✓ Critical facilities protected in core
- ✓ Multiple defensive layers

---

## Resource Management

### Monthly Budget Example (Month 2)

```
INCOME
═══════════════════════════════════════
Funding Council:        $1,000,000
Mission Rewards:          $300,000
Item Sales:               $150,000
─────────────────────────────────────
TOTAL INCOME:           $1,450,000
═══════════════════════════════════════

EXPENSES
═══════════════════════════════════════
Facility Maintenance:
  • Living Quarters x1    -$10,000
  • Laboratory x1         -$30,000
  • Workshop x1           -$35,000
  • Hangar x1             -$25,000
  • Power Generator x2    -$40,000
  • Stores x1             -$5,000
  
Personnel Salaries:
  • Soldiers x10          -$100,000
  • Scientists x5         -$75,000
  • Engineers x5          -$60,000
  
Craft Maintenance:
  • Interceptor x1        -$20,000
─────────────────────────────────────
TOTAL EXPENSES:           -$400,000
═══════════════════════════════════════

NET INCOME:             $1,050,000/month
═══════════════════════════════════════
```

### Budget Allocation Guidelines

**50% - Construction/Research**
- $525,000 for new facilities
- Save for expensive late-game builds

**30% - Personnel**
- $315,000 for hiring/recruiting
- Expand staff as facilities complete

**20% - Emergency Reserve**
- $210,000 liquid cash
- Cover unexpected expenses
- Mission failures, repairs

---

## Multi-Base Strategy

### When to Build a Second Base

**Indicators:**
- Month 6+ (established economy)
- $3,000,000+ in reserves
- First base at 90%+ capacity
- Want global coverage (radar/response)

### Second Base Planning

```
BASE #1: Research & Production Hub
─────────────────────────────────────
• Laboratory x3
• Workshop x3
• Living Quarters x2
• Full manufacturing capacity
• Main research facility
─────────────────────────────────────

BASE #2: Military Outpost
─────────────────────────────────────
• Hangar x2
• Living Quarters x2
• Radar System
• Defense Turrets x4
• Rapid response team
─────────────────────────────────────
```

**Cost of Second Base:**
- Base construction: $800,000
- Core facilities: $2,000,000
- Personnel: $500,000
- **Total**: ~$3,300,000

---

## Common Mistakes to Avoid

### Building Errors ❌

**Mistake 1: Building Too Fast**
- Building multiple facilities simultaneously
- Draining cash reserves
- Cannot afford maintenance

**Solution:** Build 1-2 facilities at a time, maintain reserves

**Mistake 2: Poor Power Planning**
- Brownouts (insufficient power)
- Facilities shut down
- Research/production halted

**Solution:** Build Power Generator when net < 2 units

**Mistake 3: No Expansion Space**
- Blocking future placement
- Inefficient layout
- Forced to demolish facilities

**Solution:** Plan ahead, leave adjacency space

### Financial Errors ❌

**Mistake 4: Overhiring Personnel**
- 20 soldiers with 10 capacity
- Scientists with no lab
- Paying salaries with no benefit

**Solution:** Hire capacity = facility capacity

**Mistake 5: Neglecting Maintenance Costs**
- Building without considering upkeep
- Monthly deficit
- Forced to sell facilities

**Solution:** Ensure income > expenses before building

---

## Optimization Tips

### Research Efficiency

**Stacking Labs:**
```
[L][L] = +10% research bonus
[L][L]
[L]    = +20% bonus (3 adjacent)
```

Each adjacent lab provides +10% speed boost!

**Scientist Allocation:**
- 10 scientists = 100% research speed
- 20 scientists = 150% speed (diminishing returns)
- 30 scientists = 175% speed

**Optimal:** 10 scientists per laboratory

### Production Efficiency

**Stacking Workshops:**
```
[W][W] = +10% production bonus
[W][W]
[W]    = +20% bonus (3 adjacent)
```

**Engineer Allocation:**
- 10 engineers = 100% production speed
- 20 engineers = 150% speed (diminishing returns)

**Optimal:** 10 engineers per workshop

### Storage Management

**Item Categories:**
```
PRIORITY ITEMS (Keep):
• Alien Corpses (research)
• Alien Weapons (research/selling)
• Alien Alloys (manufacturing)
• Elerium (late-game fuel)

LOW PRIORITY (Sell):
• Excess corpses (>5 of same type)
• Outdated weapons
• Damaged armor
• Common materials
```

**Storage Audit (Monthly):**
1. Identify duplicate/excess items
2. Sell items worth >$10,000 each
3. Keep 1-2 of each research item
4. Clear space for mission loot

---

## Progression Checklist

### Month 1 Goals
- [ ] Laboratory built and operational
- [ ] 5 scientists hired and assigned
- [ ] First research project active
- [ ] Workshop construction started

### Month 2 Goals
- [ ] Workshop operational
- [ ] 5 engineers hired
- [ ] Stores facility built
- [ ] Power Generator #2 online
- [ ] 15+ soldiers recruited

### Month 3 Goals
- [ ] Laboratory #2 built (stacking bonus)
- [ ] Workshop #2 built (stacking bonus)
- [ ] Radar system operational
- [ ] All core facilities present

### Month 6 Goals
- [ ] Base at 80%+ capacity
- [ ] Advanced facilities researched
- [ ] Alien Containment operational
- [ ] Considering second base

---

## Quick Reference Tables

### Facility Build Times

| Facility          | Build Time | Cost       |
|-------------------|------------|------------|
| Stores            | 10 days    | $100,000   |
| Living Quarters   | 12 days    | $300,000   |
| Laboratory        | 15 days    | $400,000   |
| Power Generator   | 18 days    | $250,000   |
| Workshop          | 20 days    | $500,000   |
| Radar System      | 20 days    | $600,000   |
| Hangar            | 25 days    | $800,000   |
| Alien Containment | 18 days    | $500,000   |
| Psi Lab           | 25 days    | $750,000   |
| Defense Turret    | 15 days    | $350,000   |

### Facility Maintenance Costs

| Facility          | Monthly Cost |
|-------------------|--------------|
| Access Lift       | $0           |
| Stores            | $5,000       |
| Living Quarters   | $10,000      |
| Power Generator   | $20,000      |
| Hangar            | $25,000      |
| Laboratory        | $30,000      |
| Workshop          | $35,000      |
| Defense Turret    | $15,000      |
| Radar System      | $40,000      |
| Alien Containment | $30,000      |
| Psi Lab           | $50,000      |

---

## Next Steps

### Recommended Tutorials:
1. **[[Research_Strategy_Guide]]** - Optimize research paths
2. **[[First_Mission_Walkthrough]]** - Fund base expansion
3. **[[Intermediate_Strategies]]** - Advanced base management

### Advanced Topics:
- **[[../balance/README]]** - Economy balance and tuning
- **[[/wiki/basescape/README]]** - Base system architecture
- **[[/wiki/economy/README]]** - Resource systems deep dive

---

## Frequently Asked Questions

**Q: Can I move facilities after building?**  
A: No, facilities are permanent. Plan layout carefully!

**Q: What happens if I run out of power?**  
A: Facilities shut down randomly. Research/production halts. Build generators!

**Q: Should I build multiple bases early?**  
A: No, focus on maximizing first base. Second base after Month 6.

**Q: Can I demolish facilities?**  
A: Yes, but you lose 50% of build cost. Avoid if possible.

**Q: How many soldiers do I need?**  
A: 15-20 for rotation (missions, injuries, training)

**Q: What if I can't afford maintenance?**  
A: Sell items, reduce personnel, avoid building more facilities

---

## Conclusion

You now understand:
- ✓ Base grid system and facility connections
- ✓ Core facility functions and priorities
- ✓ Optimal build orders and placement
- ✓ Resource management and budgeting
- ✓ Expansion strategies and multi-base planning

**Your base is the foundation of success!**

Invest wisely, plan ahead, and build the infrastructure needed to defeat the alien threat. Every facility, every hire, every dollar spent brings you closer to victory.

---

*Last Updated: September 30, 2025*  
*Version: 1.0 - Initial Release*
