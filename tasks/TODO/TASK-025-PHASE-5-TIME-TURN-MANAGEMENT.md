# TASK-025 Phase 5: Time & Turn Management

**Status:** IN_PROGRESS | **Priority:** CRITICAL | **Duration:** 15 hours | **Created:** October 24, 2025

---

## Overview

Phase 5 implements the complete time management system for Geoscape, enabling turn-based progression with calendar tracking, seasonal effects, and event scheduling. This phase provides the temporal backbone for all campaign mechanics.

**Previous Phases:**
- Phase 1: ✅ Design & Planning (2,500L design doc, 2,800L API)
- Phase 2: ✅ World Generation (970L, 22/22 tests)
- Phase 3: ✅ Regional Management (450L, 22/22 tests)
- Phase 4: ✅ Faction & Mission (500L, 22/22 tests)

**This Phase:**
- 4 systems: Calendar, SeasonSystem, EventScheduler, TurnAdvancer
- 400+ lines of production code
- Day/month/year tracking with real calendar progression
- Seasonal effects on gameplay (resources, missions, alien activity)
- Event scheduling with turn-based triggers
- Turn advancement with cascading updates

**Deliverables:**
1. Calendar class (100 lines) - Date tracking and querying
2. SeasonSystem class (80 lines) - Seasonal effects on regions
3. EventScheduler class (120 lines) - Event scheduling and firing
4. TurnAdvancer class (100 lines) - Turn progression orchestrator
5. Integration (50 lines) - Campaign manager updates
6. Tests (250+ lines) - 20+ comprehensive tests

---

## Architecture

### Calendar System

**Purpose:** Track game time with day/month/year progression, support for leap years and seasonal dates.

**Key Properties:**
- `year` (number) - Campaign year (1996+)
- `month` (1-12) - Current month
- `day` (1-31) - Current day of month
- `turn` (number) - Absolute turn counter since game start
- `season` (string) - Current season (spring, summer, autumn, winter)

**Key Methods:**
- `new(start_year, start_month, start_day)`
- `advance(num_turns)` - Advance calendar by N turns (1 turn = 1 day)
- `getDaysInMonth()` - Days in current month
- `getMonthName()` - Human-readable month
- `getSeasonName()` - Current season
- `getDayOfYear()` - 1-365 day counter
- `getDateString()` - Formatted date ("Jan 15, 1996")
- `getQuarter()` - Quarter of year (Q1-Q4)
- `getDayOfWeek()` - Day of week (Mon-Sun)
- `isLeapYear()` - Check if current year is leap year
- `daysUntil(month, day)` - Days until specific date
- `serialize()` / `deserialize()`

**Calendar Mechanics:**
- Start: January 1, 1996
- End game possible at: December 31, 2004 (9 years)
- Leap years: 1996, 2000, 2004
- 365 days/year (366 leap years)
- Each turn = 1 day

**Seasons:**
- Winter: Dec 21 - Mar 20
- Spring: Mar 21 - Jun 20
- Summer: Jun 21 - Sep 20
- Autumn: Sep 21 - Dec 20

---

### SeasonSystem

**Purpose:** Calculate seasonal effects on regions, missions, and alien activity.

**Key Properties:**
- `region_seasonal_modifiers` (table) - Per-region seasonal effects
- `global_mission_modifier` (number) - Affects mission frequency
- `global_alien_activity_modifier` (number) - Affects alien faction activity

**Key Methods:**
- `new()`
- `getSeasonalModifier(season, effect_type)` - Get modifier for season
- `applySeasonalEffects(turn, calendar, regions)` - Apply effects to regions
- `getRegionResourcesThisSeason(region_id, season)` - Resource availability
- `getMissionFrequencyModifier(season)` - How season affects missions
- `getAlienActivityModifier(season)` - How season affects aliens
- `serialize()` / `deserialize()`

**Seasonal Effects:**
- **Winter (Dec-Mar)**
  - Resources: -30% (harsh conditions)
  - Mission frequency: -20% (fewer operations)
  - Alien activity: -10% (less aggressive)
  - Unit morale: -5% (cold/dark)
  - Research speed: +10% (indoor work)

- **Spring (Mar-Jun)**
  - Resources: +10% (revival)
  - Mission frequency: Normal (100%)
  - Alien activity: +20% (awakening)
  - Unit morale: +10% (improving)
  - Research speed: Normal

- **Summer (Jun-Sep)**
  - Resources: +30% (peak productivity)
  - Mission frequency: +30% (more UFO sightings)
  - Alien activity: +30% (aggressive phase)
  - Unit morale: +20% (good conditions)
  - Research speed: -10% (heat slows work)

- **Autumn (Sep-Dec)**
  - Resources: +15% (harvest)
  - Mission frequency: +10%
  - Alien activity: +5% (final push)
  - Unit morale: Normal
  - Research speed: Normal

---

### EventScheduler

**Purpose:** Schedule and trigger events at specific dates/turns, enabling narrative progression.

**Key Properties:**
- `scheduled_events` (table) - Events by turn
- `event_id_counter` (number) - Unique event IDs
- `triggered_events` (table) - Record of fired events

**Key Methods:**
- `new()`
- `scheduleEvent(turn, event_type, event_data)` - Queue event for future
- `scheduleDateEvent(month, day, event_type, event_data)` - Schedule for specific date
- `cancelEvent(event_id)` - Remove scheduled event
- `updateAndFire(turn)` - Check and fire events for current turn
- `getScheduledEvents()` - List upcoming events
- `getTriggeredEvents()` - History of fired events
- `serialize()` / `deserialize()`

**Event Types:**
- `research_milestone` - Research tech unlocked
- `alien_invasion` - Major alien activity spike
- `ufo_sighting` - UFO appears
- `diplomatic_incident` - Country relations change
- `terror_attack` - Terror attack starts
- `alien_base_discovered` - Base found
- `world_event` - Generic world event
- `milestone_reached` - Campaign milestone
- `season_change` - Season changes (auto-fired)
- `quarter_change` - Quarter changes (auto-fired)

**Event Properties:**
- `id` (number) - Unique ID
- `type` (string) - Event type
- `turn_scheduled` (number) - Turn scheduled
- `turn_fired` (number) - Turn actually fired
- `priority` (1-5) - Processing priority
- `repeating` (bool) - Repeats annually if true
- `data` (table) - Event-specific data

---

### TurnAdvancer

**Purpose:** Orchestrate turn progression, updating all systems in correct order.

**Key Properties:**
- `current_turn` (number) - Absolute turn counter
- `turn_callbacks` (table) - Systems registered for updates
- `turn_history` (table) - Last 20 turns of events

**Key Methods:**
- `new()`
- `registerSystem(system_name, callback)` - Register for turn updates
- `unregisterSystem(system_name)` - Remove system
- `advanceTurn()` - Execute one full turn progression
- `advanceTurns(num_turns)` - Skip N turns
- `getCurrentTurn()` - Get turn number
- `getTurnHistory()` - Last 20 turns
- `serialize()` / `deserialize()`

**Turn Sequence:**
1. Calendar advances (day++)
2. EventScheduler fires triggered events
3. SeasonSystem applies seasonal effects
4. AlienFactions update (Phase 4)
5. MissionSystem updates (Phase 4)
6. TerrorSystem updates (Phase 4)
7. RegionController updates (Phase 3)
8. Post-turn callbacks fire
9. Turn logging/history

**Performance Targets:**
- Turn advancement: <50ms
- Calendar calculations: <1ms
- Season effects: <5ms
- Event firing: <10ms
- System callbacks: <30ms

---

## Implementation Plan

### Step 1: Create Calendar Class (2.5 hours)

**Files to create:**
- `engine/geoscape/systems/calendar.lua` (100 lines)

**Implementation:**
1. Define calendar properties (year, month, day, turn)
2. Implement month/year validation
3. Implement leap year calculation
4. Implement season calculation from date
5. Implement date arithmetic (days until date, etc.)
6. Implement day of week calculation
7. Implement serialization

**Key Functions:**
```lua
Calendar.new(start_year, start_month, start_day)
Calendar:advance(num_turns)
Calendar:getSeasonName()
Calendar:getDateString()
Calendar:daysUntil(month, day)
```

---

### Step 2: Create SeasonSystem Class (2 hours)

**Files to create:**
- `engine/geoscape/systems/season_system.lua` (80 lines)

**Implementation:**
1. Define seasonal modifier tables
2. Implement season lookup from calendar
3. Implement seasonal effect calculation
4. Implement regional effect application
5. Implement global modifier calculation
6. Implement serialization

**Key Functions:**
```lua
SeasonSystem.new()
SeasonSystem:getSeasonalModifier(season, effect_type)
SeasonSystem:applySeasonalEffects(turn, calendar, regions)
SeasonSystem:getMissionFrequencyModifier(season)
```

---

### Step 3: Create EventScheduler Class (3 hours)

**Files to create:**
- `engine/geoscape/systems/event_scheduler.lua` (120 lines)

**Implementation:**
1. Define event type constants
2. Implement event scheduling
3. Implement date-based scheduling
4. Implement event firing logic
5. Implement repeating event handling
6. Implement priority sorting
7. Implement serialization

**Key Functions:**
```lua
EventScheduler.new()
EventScheduler:scheduleEvent(turn, event_type, event_data)
EventScheduler:scheduleDateEvent(month, day, event_type, event_data)
EventScheduler:updateAndFire(turn)
```

---

### Step 4: Create TurnAdvancer Class (2.5 hours)

**Files to create:**
- `engine/geoscape/systems/turn_advancer.lua` (100 lines)

**Implementation:**
1. Define system callback registration
2. Implement turn advancement sequence
3. Implement cascade calling of systems
4. Implement turn history tracking
5. Implement turn logging
6. Implement serialization

**Key Functions:**
```lua
TurnAdvancer.new()
TurnAdvancer:registerSystem(name, callback)
TurnAdvancer:advanceTurn()
TurnAdvancer:advanceTurns(num_turns)
```

---

### Step 5: Integration with Campaign (2 hours)

**Files to modify:**
- `engine/geoscape/campaign_manager.lua` (50 lines added)

**Implementation:**
1. Initialize Calendar at game start
2. Initialize SeasonSystem
3. Initialize EventScheduler
4. Initialize TurnAdvancer
5. Register all systems with TurnAdvancer
6. Wire seasonal effects to regions
7. Wire event callbacks to systems

---

### Step 6: Create Test Suite (3 hours)

**Files to create:**
- `tests/geoscape/test_phase5_time_turn_system.lua` (250+ lines)

**Test Suites (20+ tests total):**

**Suite 1: Calendar Tests (5 tests)**
- Calendar creation and initial state
- Day advancement
- Month transitions
- Year transitions and leap years
- Season calculation

**Suite 2: SeasonSystem Tests (4 tests)**
- Seasonal modifier retrieval
- Seasonal effects application
- Mission frequency modifiers
- Alien activity modifiers

**Suite 3: EventScheduler Tests (6 tests)**
- Event scheduling by turn
- Event scheduling by date
- Event firing at correct turn
- Repeating event handling
- Event cancellation
- Event history tracking

**Suite 4: TurnAdvancer Tests (4 tests)**
- System registration
- Turn advancement sequence
- Cascade callback ordering
- Turn history tracking

**Suite 5: Integration Tests (3 tests)**
- Full turn cycle
- Seasonal transitions
- Event firing during turn

---

### Step 7: Documentation & Polish (1 hour)

**Files to create/update:**
- Inline code documentation (docstrings, comments)
- Test results summary

**Update existing docs:**
- `api/GEOSCAPE.md` - Add time management sections

---

## Success Criteria

Phase 5 is complete when:

- ✅ Calendar system fully implemented (100 lines)
- ✅ SeasonSystem fully implemented (80 lines)
- ✅ EventScheduler fully implemented (120 lines)
- ✅ TurnAdvancer fully implemented (100 lines)
- ✅ Integration with campaign manager (50 lines)
- ✅ All 20+ tests passing (100%)
- ✅ Game runs without errors (Exit Code 0)
- ✅ Per-turn performance <50ms
- ✅ Serialization working (save/load cycle)
- ✅ Documentation complete

---

## Performance Targets

- **Calendar advance**: <1ms
- **Season effect application**: <5ms
- **Event scheduler update**: <10ms
- **System cascade callbacks**: <30ms
- **Total per-turn**: <50ms (within 100ms budget)

---

## Integration Points

**With Phase 4 (Faction & Mission):**
- Seasonal modifiers affect mission frequency
- Events can trigger faction activity changes
- Calendar drives turn progression for all systems

**With Phase 3 (Regional Management):**
- Regional updates in turn sequence
- Seasonal effects modify region properties
- Turn history tracks regional changes

**With Campaign Manager:**
- TurnAdvancer integrates with main game loop
- Calendar tracks campaign progression
- Events fire player notifications

---

## Dependencies

- ✅ Phase 3: RegionController (for effect application)
- ✅ Phase 4: Factions/Missions (for modifier application)
- ✅ Core systems: Serialization, event system

---

## Notes

- Calendar starts Jan 1, 1996 (real history reference)
- Each turn = 1 day (configurable, default 1 day)
- Seasons calculated from astronomical dates
- Events support repeating annual triggers
- Turn history maintained for debugging/analysis

---

## Next Phase (Phase 6)

After Phase 5 completes:

**Phase 6: Rendering & UI (25 hours)**
- Geoscape map rendering
- UI for calendar, regions, missions
- Player interaction with geoscape layer
- Deliverables: 500+ lines, 15+ tests
