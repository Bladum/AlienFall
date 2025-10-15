# Strategic Layer Implementation Plan - Summary

**Created:** October 13, 2025  
**Tasks Created:** 3 (TASK-026, TASK-027, TASK-028)  
**Total Estimated Time:** 118 hours (approximately 15 days)

---

## Overview

This document summarizes the comprehensive implementation plan for three interconnected strategic game systems. The systems work together to create a dynamic, strategic gameplay experience.

---

## System 1: Relations System (TASK-026)

**Time Estimate:** 42 hours (5-6 days)  
**Priority:** High

### What It Does
Tracks player relationships (-100 to +100) with three entity types:
- **Countries:** Relations affect funding (can increase/decrease by up to 75-100%)
- **Suppliers:** Relations affect marketplace prices (-50% to +100%) and item availability
- **Factions:** Relations control mission spawning (0-7 missions/week) and difficulty (0.5x to 2.0x power)

### Key Features
- **Dynamic Relations:** Change based on mission results, purchases, diplomatic actions
- **Time Decay:** Relations naturally drift toward neutral (0) over time
- **Thresholds:** 7 descriptive levels (War, Hostile, Negative, Neutral, Positive, Friendly, Allied)
- **Strategic Consequences:**
  - Very good relations (75+) can stop faction missions entirely
  - Very bad relations (-75 or worse) trigger more/stronger missions
  - Allied suppliers offer special items and discounts
  - Hostile suppliers may refuse to sell advanced equipment

### Implementation Steps
1. Core Relations Manager (central tracking system)
2. Country Relations → Funding Integration
3. Supplier Relations → Marketplace Pricing
4. Faction Relations → Mission Generation
5. UI Components (relation bars, panels)
6. Diplomacy Actions (gifts, alliances, war declarations)
7. Time-based decay system
8. Testing and balancing

---

## System 2: Mission Detection & Campaign Loop (TASK-027)

**Time Estimate:** 34 hours (4-5 days)  
**Priority:** High

### What It Does
Creates the core campaign gameplay loop:
- **Weekly Mission Generation:** New missions spawn every Monday (Day 1 of week)
- **Cover Mechanics:** Missions are hidden with cover value (0-100)
- **Radar Detection:** Bases and crafts scan for missions, reducing cover
- **Mission Lifecycle:** spawn → hidden → detected → active → expired/completed

### Key Features
- **Turn-Based Time:** 1 turn = 1 day, with calendar system
- **Cover System:**
  - Missions spawn with 100 cover
  - Cover regenerates daily (5-10 points depending on mission type)
  - Radar scans reduce cover based on power and range
  - Mission becomes visible when cover reaches 0
  
- **Radar System:**
  - **Bases:** Range 5-20 provinces, Power 20-100 (facility dependent)
  - **Crafts:** Range 3-7 provinces, Power 10-25 (equipment dependent)
  - Multiple scanners combine coverage
  
- **Mission Types:**
  - **Site:** Land-based, 14 days duration, moderate cover regen
  - **UFO:** Air or landed, 7 days duration, low cover regen if flying
  - **Base:** Underground/underwater, 30 days duration, high cover regen

### Implementation Steps
1. Mission data structure with cover mechanics
2. Campaign Manager (weekly generation, turn processing)
3. Detection Manager (radar scanning algorithm)
4. Geoscape mission display (icons, tooltips)
5. Turn processing and calendar integration
6. Mission configuration data files
7. Testing and balance tuning

### Strategic Gameplay
- **Radar Coverage:** Players must build bases strategically for detection
- **Mobile Detection:** Crafts provide flexible radar coverage
- **Time Pressure:** Missions expire if not found quickly
- **Cover Balance:** Too much = frustrating, too little = no challenge

---

## System 3: Interception Screen (TASK-028)

**Time Estimate:** 42 hours (5-6 days)  
**Priority:** Critical

### What It Does
Turn-based tactical mini-game bridging Geoscape strategy and Battlescape tactics:
- Crafts and bases fight missions (UFOs, sites, bases)
- Card battle game style with no movement
- 3 altitude layers: AIR, LAND/WATER, UNDERGROUND/UNDERWATER
- Win: damage enemy enough to proceed to Battlescape
- Lose/Retreat: return to Geoscape

### Key Features
- **Turn System:**
  - 1 turn = 5 minutes game time
  - All units have 4 AP per turn
  - All units have energy system (regenerates per turn)
  
- **Altitude Layers (Vertical Positioning):**
  - **TOP:** AIR - Flying UFOs, interceptor crafts
  - **MIDDLE:** LAND/WATER - Landed UFOs, sites, bases
  - **BOTTOM:** UNDERGROUND/UNDERWATER - Alien bases
  
- **No Movement:** Units stay in assigned altitude layer
  
- **Weapon System:**
  - **Altitude Restrictions:**
    - AIR-to-AIR (aerial dogfights)
    - AIR-to-LAND (bombing runs)
    - LAND-to-AIR (anti-aircraft defense)
    - LAND-to-LAND (ground-to-ground)
    - Special weapons for underground/underwater
  - **Resource Costs:** AP cost, Energy cost, Cooldown (turns)
  - **Range:** Currently all targets in layer are in range (future: range mechanic)
  
- **Base Defense Integration:**
  - If player base in same province, it participates
  - Defense facilities become weapons (lasers, missiles)
  - Base acts as defensive unit with high health/armor
  
- **Multiple Crafts:** Player can deploy multiple crafts to gang up on target

### Visual Layout (960×720 resolution)
```
┌─────────────────────────────────────────────┐
│ AIR LAYER (240px)                           │
│ [Player Crafts]      │      [Enemy UFOs]    │
├─────────────────────────────────────────────┤
│ LAND/WATER LAYER (240px)                    │
│ [Player Base]        │      [Sites/Landed]  │
├─────────────────────────────────────────────┤
│ UNDERGROUND/WATER LAYER (240px)             │
│ [Nothing]            │      [Alien Bases]   │
├─────────────────────────────────────────────┤
│ UI: Combat Log, Buttons                     │
└─────────────────────────────────────────────┘
```

### Implementation Steps
1. Interception Unit system (unified combat entity)
2. Interception Manager (turn management, AI)
3. Interception UI Layout (3-layer display)
4. Weapon system and data definitions
5. Integration with Geoscape (launch interception)
6. Victory/defeat conditions and transitions
7. Testing and balancing (weapon damage, AP costs)

### Example Gameplay Flow
1. Player detects UFO on Geoscape (TASK-027)
2. Deploy interceptor craft to UFO's province
3. Click "Start Interception"
4. **Interception Screen Opens:**
   - Player craft in AIR layer (left)
   - Enemy UFO in AIR layer (right)
   - Player base in LAND layer (left) if present
5. **Turn 1 - Player Phase:**
   - Select craft
   - Use "Cannon" (2 AP, 10 Energy) on UFO → 30 damage
   - Use "Missile" (3 AP, 25 Energy) on UFO → 80 damage
   - End turn (no AP left)
6. **Turn 1 - Enemy Phase:**
   - UFO uses "Plasma" on craft → 45 damage
7. **Turn 2 - Player Phase:**
   - Continue attacking...
8. **Victory:** UFO health reaches 0
9. **Choice:** 
   - Proceed to Battlescape (ground assault)
   - Return to Geoscape (mission completed)

---

## System Dependencies

### TASK-026 (Relations) depends on:
- Funding system (for country relations)
- Marketplace system (for supplier relations)
- Mission generation system (for faction relations)

### TASK-027 (Mission Detection) depends on:
- World/Province system (TASK-025)
- Base system with facilities
- Craft system with equipment
- **Relations system (TASK-026)** for mission generation

### TASK-028 (Interception) depends on:
- Geoscape mission system
- **Mission Detection (TASK-027)** for mission entities
- Craft system with weapons
- Base system with defense facilities

---

## Recommended Implementation Order

### Phase 1: Relations System (5-6 days)
Start with TASK-026 because:
- Relatively independent (fewer dependencies)
- Required by mission generation (TASK-027)
- Establishes strategic consequences for player actions

### Phase 2: Mission Detection & Campaign Loop (4-5 days)
Follow with TASK-027 because:
- Requires relations system (completed in Phase 1)
- Generates missions for interception screen
- Creates core gameplay loop

### Phase 3: Interception Screen (5-6 days)
Finish with TASK-028 because:
- Requires missions from detection system
- Completes the Geoscape → Interception → Battlescape flow
- Most complex UI implementation

**Total Timeline:** 14-17 days (approximately 3 weeks)

---

## Integration with Existing Systems

### Geoscape (TASK-025)
- Relations system integrates with country/supplier/faction entities
- Mission detection adds mission icons to map display
- Interception screen launches from mission click

### Battlescape
- Interception screen transitions to Battlescape on victory
- Damage dealt in interception could affect Battlescape difficulty
- Units/equipment damaged in interception unavailable for Battlescape

### Basescape
- Base facilities provide radar coverage (detection)
- Base defense facilities participate in interception
- Relations with suppliers affect marketplace in base

---

## Key Design Principles

### 1. Turn-Based Everything
- No real-time mechanics
- 1 turn = 1 day (campaign) or 5 minutes (interception)
- Strategic planning emphasized

### 2. Resource Management
- AP (Action Points): 4 per turn for all units
- Energy: Regenerates per turn, spent on weapons
- Cover: Mission concealment mechanic
- Relations: Long-term strategic resource

### 3. Strategic Depth
- Radar coverage vs. mission concealment
- Relations affecting multiple systems
- Altitude tactics in interception
- Risk vs. reward (commit crafts to weaken mission)

### 4. Consequences Matter
- Good relations = easier campaign
- Bad relations = harder campaign
- Ignored missions expire (lost opportunities)
- Damaged crafts unavailable (resource loss)

### 5. Player Agency
- Choose which missions to pursue
- Manage relations through actions
- Decide when to fight (interception vs. direct Battlescape)
- Balance radar coverage investment

---

## Testing & Balancing Priorities

### Relations System
- Balance: Too strong effects make game too easy/hard
- Decay rates: Should trend toward neutral but not too fast
- Event frequency: Random events should feel meaningful but not overwhelming

### Mission Detection
- Cover values: Balance between hidden too long vs. instant detection
- Radar costs: Should radar be cheap (easier) or expensive (strategic choice)?
- Mission expiration: How long before players feel pressured?

### Interception Screen
- Weapon balance: Damage, AP costs, cooldowns
- Enemy AI: Challenging but not unfair
- Base defense: How powerful should base facilities be?
- Altitude restrictions: Should feel tactical, not arbitrary

---

## Success Criteria

### Relations System Success
- [ ] Relations correctly affect funding, prices, and missions
- [ ] UI clearly shows relation status and recent changes
- [ ] Diplomatic actions provide meaningful choices
- [ ] System persists across save/load

### Mission Detection Success
- [ ] Missions spawn weekly on schedule
- [ ] Radar scanning reveals missions appropriately
- [ ] Cover mechanics create strategic gameplay
- [ ] Performance: <5ms for full radar scan

### Interception Screen Success
- [ ] Turn-based combat feels tactical and fair
- [ ] Altitude restrictions add strategic depth
- [ ] UI is clear and responsive
- [ ] Transitions between states are smooth
- [ ] Performance: <2ms per turn update

---

## Next Steps

1. **Review Task Documents:**
   - Read `tasks/TODO/TASK-026-relations-system.md`
   - Read `tasks/TODO/TASK-027-mission-detection-campaign-loop.md`
   - Read `tasks/TODO/TASK-028-interception-screen.md`

2. **Prepare Dependencies:**
   - Ensure World/Province system functional (TASK-025)
   - Verify Base system has facilities
   - Verify Craft system has equipment
   - Check Funding system ready for integration

3. **Start Implementation:**
   - Begin with TASK-026 (Relations System)
   - Use task documents as step-by-step guides
   - Update `tasks/tasks.md` as you progress
   - Move tasks from TODO → IN_PROGRESS → TESTING → DONE

4. **Testing Throughout:**
   - Run with `lovec "engine"` frequently
   - Check console for errors/warnings
   - Use debug commands for rapid iteration
   - Write unit tests as you go

---

## Conclusion

These three tasks create a cohesive strategic layer for the game:

- **Relations System** provides long-term strategic consequences
- **Mission Detection** creates the core gameplay loop
- **Interception Screen** adds tactical depth before ground combat

Together, they transform the Geoscape from a simple map into a dynamic strategic management experience where player decisions matter across multiple interconnected systems.

**Estimated Total Development Time:** 118 hours (14-17 days)

**Recommended Timeline:**
- Week 1-2: Relations System (TASK-026)
- Week 2-3: Mission Detection (TASK-027)  
- Week 3-4: Interception Screen (TASK-028)

Good luck with implementation! Each task document provides step-by-step guidance with code examples, testing strategies, and debugging tips.
