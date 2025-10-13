# Economy Systems Master Plan - Implementation Summary

**Created:** October 13, 2025  
**Status:** Planning Complete  
**Total Time Estimate:** 490 hours (61 days, ~12 weeks)

---

## Overview

This document summarizes the comprehensive economy and strategy systems implementation plan for AlienFall, including Research, Manufacturing, Marketplace, Black Market, and Fame/Karma/Reputation systems. All systems are interconnected and modeled after XCOM with enhancements.

---

## Task Breakdown

### TASK-032: Research System (96 hours - 12 days) ⚡ CRITICAL
**Global Technology Tree & Research Projects**

- **Type:** Global (shared across all bases)
- **Progression:** Daily (1 scientist = 1 man-day/day)
- **Variance:** 75%-125% random baseline per game
- **Special Features:**
  - Item Analysis: One-time research per item type
  - Prisoner Interrogation: Repeatable with success chance
  - Tech Tree: DAG with dependencies, unlocks research/manufacturing/facilities
  - Service Integration: Requires laboratory facilities

**Key Files:**
- `engine/geoscape/logic/research_entry.lua`
- `engine/geoscape/logic/research_project.lua`
- `engine/geoscape/systems/research_manager.lua`
- `engine/geoscape/logic/tech_tree.lua`
- 89 research entries total (weapons, armor, aliens, items, prisoners)

---

### TASK-033: Manufacturing System (108 hours - 13-14 days) ⚡ CRITICAL
**Local Production & Workshop Management**

- **Type:** Local per base (NOT shared)
- **Progression:** Daily (1 engineer = 1 man-day/day)
- **Variance:** 75%-125% random baseline per game
- **Special Features:**
  - Resource Consumption: At project START (not during)
  - Multi-Output: Can produce multiple items per project
  - Production Types: Items, Units, Crafts
  - Regional Dependencies: Some items require specific regions
  - Automatic Pricing: Sell price calculated from costs + labor

**Key Files:**
- `engine/basescape/logic/manufacturing_entry.lua`
- `engine/basescape/logic/manufacturing_project.lua`
- `engine/basescape/systems/manufacturing_manager.lua`
- `engine/basescape/logic/manufacturing_pricing.lua`
- Data files: weapons, armor, equipment, ammo, vehicles, crafts, units

---

### TASK-034: Marketplace & Supplier System (120 hours - 15 days) 🔥 HIGH
**Trade, Suppliers, and Relationships**

- **Suppliers:** Multiple (Military, Advanced Defense, Regional, Aerospace)
- **Pricing:** Dynamic based on relationships + bulk + reputation + fame
- **Regional:** Some suppliers/items only in certain regions
- **Special Features:**
  - Supplier Relationships: -50% (excellent) to +100% (hostile)
  - Bulk Discounts: 5% per 10 items, max 30%
  - Monthly Stock Refresh: Supplier inventories update
  - Transfer Integration: Orders delivered via transfer system
  - Selling: 70% of base purchase price

**Pricing Formula:**
```
Final Price = Base × Relationship × Bulk × Reputation × Fame
- Relationship: -50% to +100%
- Bulk: -5% to -30%
- Reputation: -20% to +30%
- Fame: -10% to +10%
```

**Key Files:**
- `engine/geoscape/logic/purchase_entry.lua`
- `engine/geoscape/logic/supplier.lua`
- `engine/geoscape/systems/marketplace_manager.lua`
- `engine/geoscape/logic/marketplace_pricing.lua`
- Data files: general, weapons, armor, vehicles, crafts

---

### TASK-035: Black Market System (72 hours - 9 days) 🔷 MEDIUM
**Illegal Trade with Karma/Fame Impact**

- **Access:** Low karma unlocks, discovered via missions
- **Pricing:** 33% markup over normal marketplace
- **Discovery:** 15-50% chance per transaction
- **Consequences:** Karma doubled, fame -20, funding cuts -20%, relation damage
- **Special Features:**
  - Karma Loss: Automatic on purchase (even if not discovered)
  - Trust Levels: Unlock more items (1-3) via purchases/missions
  - Regional: Different regions have unique black market items
  - Limited Stock: No restocking, very limited (3-10 per item)

**Discovery Chance Formula:**
```
Chance = Base × Quantity × Fame × Regional
- Base: 15%
- Quantity: +10% per item
- Fame: +1% per fame point
- Regional: 0.8x in specific regions
- Max: 50%
```

**Key Files:**
- `engine/geoscape/logic/black_market_entry.lua`
- `engine/geoscape/logic/black_market_dealer.lua`
- `engine/geoscape/systems/black_market_manager.lua`
- `engine/geoscape/logic/black_market_risk.lua`
- Data files: illegal weapons, alien tech, restricted items

---

### TASK-036: Fame, Karma & Reputation System (94 hours - 12 days) 🔥 HIGH
**Integrated Meta-Progression**

- **Fame:** Public recognition (0-100) - Unknown, Known, Famous, Legendary
- **Karma:** Moral alignment (-100 to +100) - Saint, Good, Neutral, Dark, Evil
- **Reputation:** Aggregate from fame, karma, relations
- **Score:** Monthly performance rating

**Effects:**
```
Fame Effects:
- Funding: 0.5x to 2x multiplier
- Recruitment: Better quality at high fame
- Supplier Access: Minimum fame requirements
- Black Market Risk: Higher fame = more scrutiny

Karma Effects:
- Black Market: Low karma unlocks access
- Missions: High karma = humanitarian, Low karma = black ops
- Morale: High karma improves unit morale
- Suppliers: Ethical suppliers prefer high karma

Reputation Effects:
- Prices: -30% to +50% modifier
- Availability: Minimum reputation for items/suppliers
- Funding: +/- 30% modifier

Score Effects:
- Achievements: End-game rewards
- Advisors: High score attracts advisors
- Leaderboard: Optional global ranking
```

**Key Files:**
- `engine/geoscape/systems/fame_system.lua`
- `engine/geoscape/systems/karma_system.lua`
- `engine/geoscape/systems/reputation_system.lua`
- `engine/geoscape/systems/score_system.lua`
- UI: meters, panels, organization screen

---

## System Dependencies

```
TASK-036 (Fame/Karma/Reputation)
  ├─> TASK-034 (Marketplace) - Pricing/availability affected
  ├─> TASK-035 (Black Market) - Access/risk affected
  └─> TASK-027 (Relations) - Reputation calculation

TASK-034 (Marketplace)
  ├─> TASK-029 (Transfer System) - Delivery mechanism
  ├─> TASK-032 (Research) - Unlocks items
  └─> TASK-036 (Fame/Karma) - Pricing modifiers

TASK-035 (Black Market)
  ├─> TASK-034 (Marketplace) - Separate but related
  ├─> TASK-036 (Fame/Karma) - Karma loss, discovery
  └─> TASK-027 (Relations) - Consequence penalties

TASK-033 (Manufacturing)
  ├─> TASK-029 (Basescape) - Workshop capacity
  ├─> TASK-032 (Research) - Unlocks manufacturing
  └─> TASK-025 Phase 2 (Calendar) - Daily progression

TASK-032 (Research)
  ├─> TASK-029 (Basescape) - Lab capacity
  └─> TASK-025 Phase 2 (Calendar) - Daily progression
```

---

## Implementation Timeline

### Phase 1: Foundation (Weeks 1-4) - 204 hours
**Core Systems:**
1. **Research System** (96h) - Tech tree, projects, progression
2. **Manufacturing System** (108h) - Production, workshops, resources

**Why First:**
- Foundation for all other economy systems
- Research unlocks manufacturing
- Manufacturing enables self-sufficiency
- Both integrate with calendar/facilities

---

### Phase 2: Commerce (Weeks 5-9) - 192 hours
**Trading Systems:**
3. **Marketplace & Suppliers** (120h) - Normal trade, suppliers, relationships
4. **Black Market** (72h) - Illegal trade, karma/fame impact

**Why Second:**
- Depends on research (unlocks)
- Depends on manufacturing (competition/comparison)
- Marketplace before black market (normal → illegal)

---

### Phase 3: Meta-Progression (Weeks 10-12) - 94 hours
**Integrated Systems:**
5. **Fame/Karma/Reputation** (94h) - Affects all economy systems

**Why Last:**
- Integrates with ALL previous systems
- Affects pricing, availability, access
- Ties everything together
- Polish and balance pass

---

## Key Design Decisions

### Research vs Manufacturing
```
Research (Global):
- Shared across all bases
- All scientists contribute
- Unlocks capabilities
- Knowledge is shared

Manufacturing (Local):
- Per-base only
- Each base has own queue
- Consumes resources
- Physical production
```

### Pricing Strategy
```
Normal Marketplace:
- Relationship: -50% to +100%
- Bulk: -5% to -30%
- Reputation: -20% to +30%
- Fame: -10% to +10%
- Total range: ~40% to ~140% of base

Black Market:
- Base: 133% (33% markup)
- Same modifiers as normal
- Total range: ~53% to ~186% of normal base
```

### Karma System
```
High Karma (+75 to +100):
- Unlocks humanitarian missions
- Better recruit morale
- Ethical suppliers prefer
- Black market LOCKED

Low Karma (-75 to -100):
- Unlocks black ops missions
- Black market ACCESS
- Some suppliers refuse
- Public backlash risk
```

---

## Integration Points

### With Geoscape (TASK-025)
- Calendar system: Daily research/manufacturing progression
- Province system: Regional availability for suppliers/manufacturing
- Base system: Facilities provide research/manufacturing capacity
- Transfer system: Marketplace deliveries

### With Basescape (TASK-029)
- Laboratories: Provide research_capacity
- Workshops: Provide manufacturing_capacity
- Inventory: Store items, consume/produce during manufacturing
- Construction: Facilities required for research/manufacturing

### With Relations (TASK-027)
- Country relations: Affect funding (multiplied by fame)
- Supplier relations: Affect marketplace prices
- Faction relations: Affected by karma choices

### With Black Market (TASK-035)
- Karma: Low karma unlocks black market access
- Fame: High fame increases discovery risk
- Discovery: Damages fame, karma, relations, funding

---

## Data Files Required

### Research (89 entries)
- `alien_tech.toml` (10) - UFO power, alien materials
- `weapons.toml` (15) - Laser, plasma, fusion
- `armor.toml` (10) - Body armor, power suits
- `crafts.toml` (8) - Interceptors, transports
- `facilities.toml` (6) - Advanced labs, psi labs
- `strategic.toml` (8) - Hyperwave, mind shield
- `items.toml` (20) - Alien artifacts, equipment
- `prisoners.toml` (12) - Alien interrogations

### Manufacturing (68+ entries)
- `weapons.toml` (20) - Rifles, pistols, heavy weapons
- `armor.toml` (12) - Body armor, power suits, helmets
- `equipment.toml` (15) - Medkits, grenades, tools
- `ammo.toml` (10) - Magazines, energy cells
- `vehicles.toml` (6) - Tanks, HWPs
- `crafts.toml` (8) - Interceptors, transports
- `units.toml` (5) - Clones, androids

### Marketplace (50+ entries)
- `general.toml` (15) - Basic equipment
- `weapons.toml` (15) - Standard weapons
- `armor.toml` (10) - Standard armor
- `vehicles.toml` (5) - Civilian vehicles
- `crafts.toml` (5) - Civilian crafts

### Black Market (30+ entries)
- `illegal_weapons.toml` (10) - Smuggled weapons
- `alien_tech.toml` (8) - Stolen alien tech
- `restricted_items.toml` (12) - Controlled substances

### Suppliers
- `suppliers.toml` (6-8 suppliers)
  - Global Military Surplus
  - Advanced Defense Corp
  - Regional Dealers (Asia, Europe, etc.)
  - Scientific Supply Co.
  - Aerospace Industries
  - Black Market Dealers (underground)

---

## Testing Strategy

### Unit Tests
- Research tree validation (no circular dependencies)
- Pricing calculation (all modifiers)
- Resource consumption/production
- Discovery chance calculation
- Fame/karma/reputation formulas

### Integration Tests
- Research unlocks manufacturing
- Manufacturing consumes resources
- Marketplace delivers via transfer
- Black market discovery consequences
- Fame/karma affects all systems

### Manual Tests
- Play through tech tree progression
- Test all supplier relationships
- Verify black market risk/consequences
- Check fame/karma integration
- Balance pass on pricing/costs

---

## Success Criteria

### Research System
- [ ] Can research technologies with prerequisites
- [ ] Projects progress daily by scientist count
- [ ] Item research only once per type
- [ ] Prisoner interrogation repeatable
- [ ] Unlocks applied automatically
- [ ] Tech tree has no circular dependencies

### Manufacturing System
- [ ] Can manufacture items after research
- [ ] Resources consumed at project start
- [ ] Projects progress daily by engineer count
- [ ] Multi-output production works
- [ ] Regional restrictions enforced
- [ ] Automatic sell pricing calculated

### Marketplace System
- [ ] Can buy/sell from multiple suppliers
- [ ] Pricing affected by relationships
- [ ] Bulk discounts applied correctly
- [ ] Orders delivered via transfer
- [ ] Monthly stock refresh works
- [ ] Regional suppliers filtered

### Black Market System
- [ ] Access requires low karma
- [ ] Karma loss on purchase
- [ ] Discovery chance calculated
- [ ] Consequences applied on discovery
- [ ] Trust levels unlock items
- [ ] Limited stock enforced

### Fame/Karma/Reputation System
- [ ] Fame increases from missions
- [ ] Karma changes from ethical choices
- [ ] Reputation calculated from components
- [ ] All systems affected by meta-progression
- [ ] Visual meters display correctly
- [ ] Events trigger automatic updates

---

## Time & Resource Summary

**Total Implementation Time:** 490 hours (61 days, ~12 weeks)

**Task Breakdown:**
- TASK-032: Research System - 96h (12 days) ⚡
- TASK-033: Manufacturing System - 108h (14 days) ⚡
- TASK-034: Marketplace System - 120h (15 days) 🔥
- TASK-035: Black Market System - 72h (9 days) 🔷
- TASK-036: Fame/Karma/Reputation - 94h (12 days) 🔥

**Phase Breakdown:**
- Phase 1 (Foundation): 204h (4-5 weeks)
- Phase 2 (Commerce): 192h (4-5 weeks)
- Phase 3 (Meta): 94h (2-3 weeks)

**Critical Path:**
1. Research → Manufacturing (foundation)
2. Marketplace → Black Market (commerce)
3. Fame/Karma/Reputation (integration)

---

## Next Steps

1. **Review Plans:** Read all task documents thoroughly
2. **Start TASK-032:** Begin with research system (foundation)
3. **Implement Phase 1:** Complete research and manufacturing
4. **Test Integration:** Verify research unlocks manufacturing
5. **Move to Phase 2:** Implement marketplace systems
6. **Final Integration:** Add fame/karma/reputation
7. **Balance Pass:** Adjust costs, times, modifiers
8. **Polish:** UI, feedback, documentation

---

## Notes

### Why This Order?
- Research/Manufacturing are foundation (everything depends on them)
- Marketplace depends on research unlocks
- Black Market depends on marketplace + karma
- Fame/Karma ties everything together

### Key Interactions
- Research unlocks → Manufacturing options
- Manufacturing costs → Marketplace alternatives
- Marketplace prices → Black market appeal
- Karma choices → Black market access
- Fame level → All price modifiers

### Balance Considerations
- Research should feel meaningful (impactful unlocks)
- Manufacturing should be cheaper than buying (incentive)
- Marketplace should be convenient (immediate)
- Black Market should be risky but rewarding
- Fame/Karma should create meaningful choices

---

**End of Master Plan**
