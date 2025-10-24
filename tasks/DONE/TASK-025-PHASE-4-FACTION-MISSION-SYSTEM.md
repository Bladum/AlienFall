# TASK-025 Phase 4: Faction & Mission System

**Status:** ✅ COMPLETE | **Priority:** CRITICAL | **Duration:** 20 hours | **Created:** October 24, 2025 | **Completed:** October 24, 2025

---

## Overview

Phase 4 implements the complete Alien Faction system with dynamic UFO generation, Mission system for procedural mission creation, and Terror system for alien psychological warfare. This phase builds on Phase 3's regional control system to create dynamic alien activity that threatens player bases and controlled regions.

**Previous Phases:**
- Phase 1: ✅ Design & Planning (2,500L design doc, 2,800L API contracts)
- Phase 2: ✅ World Generation (970L, 22/22 tests, <100ms generation)
- Phase 3: ✅ Regional Management (450L, 22/22 tests, 15-20ms per-turn)

**This Phase:**
- 4 systems: AlienFaction, MissionSystem, TerrorSystem, EventSystem
- 450-550 lines of production code
- Dynamic faction activity levels
- Mission generation from regional threats
- Terror attacks on controlled regions

**Deliverables:**
1. AlienFaction class (150 lines) - Faction state, activity tracking
2. MissionSystem class (150 lines) - Mission generation pipeline
3. TerrorSystem class (100 lines) - Terror attack scheduling
4. EventSystem class (100 lines) - Game event broadcasting
5. Integration (50 lines) - Geoscape manager updates
6. Tests (250+ lines) - 22 comprehensive tests

---

## Architecture

### AlienFaction System

**Purpose:** Track individual alien faction state, activity levels, UFO counts, and mission scheduling.

**Key Properties:**
- `name` (string) - Faction identifier
- `control` (0-1) - Territory control percentage
- `activity` (0-10) - Activity level (0=dormant, 10=invasion)
- `threat` (0-100) - Threat level to player (affects AI behavior)
- `ufos` (table) - Active UFOs count by type
- `mission_queue` (table) - Upcoming missions
- `last_mission_time` (number) - Turn of last mission spawned

**Key Methods:**
- `new(name, initial_control, initial_threat)`
- `update(turn)` - Per-turn updates (activity changes, mission generation)
- `getActivityLevel()` - 0-10 scale
- `getThreatLevel()` - 0-100 scale
- `generateUFO()` - Create UFO with type/count/equipment
- `scheduleMission(turn, region_ids)` - Queue mission for generation
- `activateMission()` - Process queued mission
- `incrementActivity(amount)` - Increase faction activity (1-3 per mission)
- `serialize()` / `deserialize()` - Save/load support

**Activity Mechanics:**
- Base: 0 (dormant)
- After first mission: 1
- Per region controlled: +0.5 (max 8)
- After terror attack: +1
- Per player research threat: +1 (max 2)
- Decay: -0.1 per 5 turns without activity

**UFO Mechanics:**
- Generate UFO for each +2 activity (1 UFO per 2 activity levels)
- UFO types: Scout (4 unit), Fighter (6 units), Harvester (8 units)
- UFO attributes: speed, capacity, damage, detection radius

**Mission Scheduling:**
- Generate mission every N turns (N = 10 - activity, min 3)
- Mission types: infiltration, terror, research, supply
- Target: player-controlled regions (high priority) or bases

---

### MissionSystem

**Purpose:** Generate procedural missions based on faction activity, regional threat, and current campaign.

**Key Properties:**
- `active_missions` (table) - Current active missions
- `mission_id_counter` (number) - Unique mission IDs
- `mission_templates` (table) - Mission type configurations

**Key Methods:**
- `new()`
- `generateMission(faction, region_id, mission_type)` - Create mission
- `getMissionById(id)` - Retrieve active mission
- `completeMission(id, status)` - Mark mission done
- `getActiveMissions(faction)` - Get faction's active missions
- `update(turn)` - Process mission timers and escalation
- `serialize()` / `deserialize()` - Save/load support

**Mission Properties:**
- `id` (number) - Unique identifier
- `faction` (string) - Owner faction
- `type` (string) - infiltration/terror/research/supply
- `region_id` (number) - Target region
- `turns_remaining` (number) - Countdown to completion
- `status` (string) - active/discovered/completed/failed
- `reward` (number) - Player reward for stopping mission
- `threat_level` (0-100) - Mission difficulty

**Mission Generation:**
- Infiltration: 5-10 turns, 10% completion → loss of control
- Terror: 2-4 turns, completes → kills civilians, region morale -20
- Research: 10-15 turns, 5% completion → aliens learn tech
- Supply: 3-7 turns, completes → faction gets resources

**Mission Types:**

1. **Infiltration (40% weight)**
   - Target: Alien base setup in region
   - Effect: -5% region control per turn until stopped
   - Reward: +5 control + alien tech salvage
   - Detection: Radar-based, requires scan to discover

2. **Terror (30% weight)**
   - Target: Civilian population terrorization
   - Effect: -10 morale, 10% population loss if completes
   - Reward: +10 control + international response bonus
   - Detection: Automatic when mission activates

3. **Research (20% weight)**
   - Target: Tech data acquisition
   - Effect: Aliens gain 5% research progress if completes
   - Reward: +10 research if stopped
   - Detection: Only visible in discovery phase

4. **Supply (10% weight)**
   - Target: Resource gathering from region
   - Effect: -5% economy if completes
   - Reward: +3 control + economy recovery
   - Detection: Visible on regional scouts

---

### TerrorSystem

**Purpose:** Manage terror attacks on controlled regions with random location generation and civilian casualty mechanics.

**Key Properties:**
- `active_terror_attacks` (table) - Current terror campaigns
- `terror_locations` (table) - Locations under terror

**Key Methods:**
- `new()`
- `startTerrorAttack(faction, region_id, intensity)` - Begin terror
- `getTerrorLocations(region_id)` - Get terror sites in region
- `completeTerrorAttack(id)` - Terror attack finishes
- `getRegionalTerrorLevel(region_id)` - 0-100 terror index
- `update(turn)` - Process terror effects
- `serialize()` / `deserialize()` - Save/load support

**Terror Attack Properties:**
- `id` (number) - Unique ID
- `faction` (string) - Attacking faction
- `region_id` (number) - Target region
- `locations` (table) - 3-7 locations under attack
- `intensity` (1-10) - Attack severity
- `morale_impact` (number) - Cumulative morale damage
- `civilian_losses` (number) - Deaths per turn
- `days_active` (number) - Turn counter

**Terror Location Generation:**
- 3-7 random locations per region
- Properties: x, y (coordinates), intensity (1-5), active (bool)
- Each location: 10-50 civilians, generates mission

**Terror Effects Per Turn:**
- Morale loss: -1 × intensity per turn
- Civilian losses: 5 × intensity per location per turn
- Economy: -2% per turn if undefended
- Control: -0.1 per turn (regions lose stability)

**Terror Escalation:**
- Starts at intensity 1
- +1 intensity per 5 turns if not opposed
- Capped at intensity 10
- Can be reduced by player missions (stop locations)

---

### EventSystem

**Purpose:** Broadcast game events to systems interested in faction/mission activity, enabling cross-system reactions.

**Key Properties:**
- `event_listeners` (table) - Registered event handlers
- `event_history` (table) - Last 100 events

**Key Methods:**
- `new()`
- `register(event_type, callback)` - Subscribe to events
- `unregister(event_type, callback)` - Unsubscribe
- `broadcast(event_type, event_data)` - Fire event
- `getHistory(type)` - Get recent events of type

**Event Types:**
- `faction_activity_increased` - Faction activity rose
- `mission_generated` - Mission created
- `mission_completed` - Mission success/failure
- `terror_attack_started` - Terror campaign began
- `terror_attack_escalated` - Terror intensity increased
- `control_lost` - Region control transferred
- `alien_threat_escalation` - Overall threat changed
- `player_research_progress` - Research completed (counters aliens)

**Event Data Structure:**
```lua
{
  type = "mission_generated",
  faction = "Sectoids",
  mission_id = 42,
  region_id = 5,
  mission_type = "infiltration",
  threat_level = 60,
  turns_to_completion = 7,
  timestamp = 1234
}
```

---

## Implementation Plan

### Step 1: Create AlienFaction Class (3 hours)

**Files to create:**
- `engine/geoscape/factions/alien_faction.lua` (150 lines)

**Implementation:**
1. Define faction properties (name, control, activity, threat, UFOs)
2. Implement per-turn update logic
3. Implement activity level calculation
4. Implement threat level calculation
5. Implement UFO generation mechanics
6. Implement mission scheduling
7. Implement serialization

**Key Functions:**
```lua
AlienFaction.new(name, initial_control, initial_threat)
AlienFaction:update(turn)
AlienFaction:getActivityLevel()
AlienFaction:getThreatLevel()
AlienFaction:generateUFO()
AlienFaction:scheduleMission(turn, region_ids)
AlienFaction:incrementActivity(amount)
```

---

### Step 2: Create MissionSystem Class (3 hours)

**Files to create:**
- `engine/geoscape/missions/mission_system.lua` (150 lines)

**Implementation:**
1. Define mission structure and templates
2. Implement mission generation pipeline
3. Implement mission type probability distribution
4. Implement regional targeting logic
5. Implement mission completion mechanics
6. Implement mission tracking/retrieval
7. Implement serialization

**Key Functions:**
```lua
MissionSystem.new()
MissionSystem:generateMission(faction, region_id, mission_type)
MissionSystem:update(turn)
MissionSystem:completeMission(id, status)
MissionSystem:getActiveMissions(faction)
```

---

### Step 3: Create TerrorSystem Class (2.5 hours)

**Files to create:**
- `engine/geoscape/terror/terror_system.lua` (100 lines)

**Implementation:**
1. Define terror attack structure
2. Implement terror attack initialization
3. Implement terror location generation
4. Implement terror effects calculation
5. Implement terror escalation mechanics
6. Implement regional terror level
7. Implement serialization

**Key Functions:**
```lua
TerrorSystem.new()
TerrorSystem:startTerrorAttack(faction, region_id, intensity)
TerrorSystem:update(turn)
TerrorSystem:getRegionalTerrorLevel(region_id)
TerrorSystem:completeTerrorAttack(id)
```

---

### Step 4: Create EventSystem Class (2 hours)

**Files to create:**
- `engine/core/event_system.lua` (100 lines)

**Implementation:**
1. Define event structure
2. Implement listener registration
3. Implement event broadcasting
4. Implement history tracking
5. Implement event filtering
6. Add event type constants

**Key Functions:**
```lua
EventSystem.new()
EventSystem:register(event_type, callback)
EventSystem:broadcast(event_type, event_data)
EventSystem:getHistory(type)
```

---

### Step 5: Integrate with Geoscape (2.5 hours)

**Files to modify:**
- `engine/geoscape/campaign_manager.lua` (50 lines added)

**Implementation:**
1. Initialize AlienFaction instances for each faction
2. Initialize MissionSystem and TerrorSystem
3. Initialize EventSystem
4. Add faction updates to campaign turn processing
5. Add mission generation to turn loop
6. Add terror updates to turn loop
7. Wire event system callbacks

**Integration Points:**
- Campaign manager: Orchestrates all systems
- Region controller: Receives control/economy events
- Mission system: Generates deployable missions
- Threat manager: Receives threat escalation events

---

### Step 6: Create Test Suite (4 hours)

**Files to create:**
- `tests/geoscape/test_phase4_faction_mission_system.lua` (250+ lines)

**Test Suites (22 tests total):**

**Suite 1: AlienFaction Tests (5 tests)**
- Test 1: Faction creation with initial state
- Test 2: Activity level calculation
- Test 3: Threat level calculation
- Test 4: UFO generation mechanics
- Test 5: Mission scheduling

**Suite 2: MissionSystem Tests (5 tests)**
- Test 1: Mission generation
- Test 2: Mission type distribution
- Test 3: Regional targeting
- Test 4: Mission completion
- Test 5: Mission serialization

**Suite 3: TerrorSystem Tests (5 tests)**
- Test 1: Terror attack initialization
- Test 2: Terror location generation
- Test 3: Terror effects calculation
- Test 4: Terror escalation
- Test 5: Regional terror level

**Suite 4: EventSystem Tests (4 tests)**
- Test 1: Event registration
- Test 2: Event broadcasting
- Test 3: Event history tracking
- Test 4: Event filtering

**Suite 5: Integration Tests (3 tests)**
- Test 1: Campaign turn processing
- Test 2: Faction-Mission-Terror workflow
- Test 3: Event propagation to systems

---

### Step 7: Documentation & Polish (2 hours)

**Files to create/update:**
- Inline code documentation (docstrings, comments)
- Test results summary
- Integration notes

**Update existing docs:**
- `api/GEOSCAPE.md` - Add faction/mission/terror sections
- `engine/geoscape/README.md` - Update system list

---

## Success Criteria

Phase 4 is complete when:

- ✅ AlienFaction system fully implemented (150 lines)
- ✅ MissionSystem fully implemented (150 lines)
- ✅ TerrorSystem fully implemented (100 lines)
- ✅ EventSystem fully implemented (100 lines)
- ✅ Integration with campaign manager (50 lines)
- ✅ All 22 tests passing (100%)
- ✅ Game runs without errors (Exit Code 0)
- ✅ Per-turn performance <100ms
- ✅ Serialization working (save/load cycle)
- ✅ Documentation complete

---

## Performance Targets

- **Faction update**: <5ms per faction (5 factions = 25ms)
- **Mission generation**: <10ms per generation (weekly)
- **Terror processing**: <5ms per active terror attack
- **Event broadcasting**: <2ms per event
- **Total Phase 4 per-turn**: <50ms (well within 100ms budget)

---

## Integration Points

**With Phase 3 (Regional Management):**
- Missions target regions from RegionController
- Terror attacks affect region properties (control, morale)
- Regional threat level triggers faction activity

**With Campaign Manager:**
- Factions initialized at campaign start
- Mission system integrates with geoscape turn loop
- Terror system integrates with regional updates
- Events feed back to campaign difficulty

**With Mission System (Geoscape):**
- Mission system creates deployable missions
- Player can stop missions to prevent effects
- Mission rewards (control, salvage) processed

---

## Dependencies

- ✅ Phase 3: RegionController (for regional targeting)
- ✅ Phase 2: World/Location system (for map coordinates)
- ✅ Core systems: Random number generation, serialization

---

## Notes

- Activity levels (1-10) control mission frequency (1 mission per 10-activity turns)
- Terror intensity scales from 1-10 (1 = minor incidents, 10 = invasion level)
- Mission duration varies by type (infiltration 5-10 turns, terror 2-4 turns)
- Event system is pub-sub pattern (loosely coupled, easily testable)
- All systems serialize for save/load compatibility

---

## Next Phase (Phase 5)

After Phase 4 completes:

**Phase 5: Time & Turn Management (15 hours)**
- Calendar & season system
- Event scheduling and escalation
- Turn-based progression
- Time pressure mechanics
- Deliverables: 300+ lines, 15+ tests
