# World Time

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Time Units Structure](#time-units-structure)
  - [Day/Night Illumination System](#day/night-illumination-system)
  - [Scheduler Determinism and Hooks](#scheduler-determinism-and-hooks)
  - [Daily Tick Processing Sequence](#daily-tick-processing-sequence)
  - [Weekly Tick Processing](#weekly-tick-processing)
  - [Monthly Tick Processing](#monthly-tick-processing)
  - [Quarterly Tick Processing](#quarterly-tick-processing)
  - [Yearly Tick Processing](#yearly-tick-processing)
  - [Inter-World Travel Mechanics](#inter-world-travel-mechanics)
- [Examples](#examples)
  - [Time Progression Scenarios](#time-progression-scenarios)
  - [Illumination Calculations](#illumination-calculations)
  - [Processing Sequence Cases](#processing-sequence-cases)
  - [Travel and Transit Examples](#travel-and-transit-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The World Time system establishes a deterministic shared clock structuring campaign pacing, event scheduling, and reproducible simulation across interconnected worlds. Using fixed turn lengths and named hooks provides predictable execution points for subsystems including research progression, funding cycles, manufacturing, and strategic updates. The system enables temporal rhythms that players can anticipate while maintaining seeded determinism for testing, modding, and replayability through data-driven hooks and phased processing.

From a design perspective, World Time provides a deterministic, shared clock that structures pacing, scheduling, and reproducible events across the campaign. Using fixed turn lengths and named hooks gives designers predictable places to run subsystems like research, funding, manufacturing, and reports. Determinism in time progression simplifies testing and modding while enabling designers to craft temporal rhythms that players can plan around. The scheduler becomes a clear integration surface for automation and director scripts.

## Mechanics

### Time Units Structure
- Turn Duration: 1 Turn = 1 Day (base temporal unit for all game progression)
- Week Cycle: 6 days per week with weekly processing for recovery and logistics
- Month Period: 5 weeks = 30 days with monthly financial and strategic updates
- Quarter Cycle: 3 months = 90 days for medium-term strategic re-evaluations
- Year Span: 12 months = 360 days for major state changes and long-term events

### Day/Night Illumination System
- Longitude Calculation: Province X coordinates converted to longitude using (X / image_width) × 360° - 180°
- Solar Angle Computation: illumination = clamp(cos(world_rotation - longitude), -1, 1)
- Day Fraction: Continuous 0-1 value for twilight effects and partial visibility transitions
- Phase Thresholds: Day when illumination ≥ configurable threshold, otherwise night
- Procedural Overlay: Sin/cos-based rendering for UI visualization and simulation queries

Local illumination for a province is computed procedurally from the world rotation and the province X coordinate (treated as longitude on the world image). illumination yields a continuous day_fraction (0..1) usable for twilight effects and partial visibility. A province is considered Day when illumination ≥ a configurable threshold; otherwise it is Night. The engine produces a procedural day/night overlay for UI rendering and deterministic simulation queries.

### Scheduler Determinism and Hooks
- Seeded Execution: All scheduled operations use campaign seed for reproducible ordering
- Named Hook System: Data-driven hooks (day_tick, week_tick, month_tick, quarter_tick, year_tick)
- Hook Management: Mods can add, reorder, or replace logic through hook registration
- Execution Ordering: Fixed phase order ensures deterministic results across replays
- Integration Surface: Clear attachment points for automation and director scripts

All scheduled checks are seeded from the campaign/world seed and execute in a fixed, deterministic order each day. Named hooks are exposed for modding: "day_tick", "week_tick", "month_tick", "quarter_tick", "year_tick". Hooks are data-driven so designers and mods can add, reorder, or replace logic.

### Daily Tick Processing Sequence
- Time Advancement: Turn counter increment and illumination calculations per province
- Geoscape Updates: Mission progression, UFO movement, detection effects, interception resolution
- Travel Processing: Transit timer decrements, arrival handling, fuel consumption checks
- Simulation Advancement: Research points, manufacturing hours, facility builds, training timers
- State Updates: Regeneration, status expiration, delivery processing, mission timeouts
- Event Dispatch: Notification queuing and immediate mission spawning

### Weekly Tick Processing
- Unit Recovery: Complete healing of unit health and sanity every Monday
- Training Completion: Weekly skill gains and scheduled rotation cycles
- Logistics Batch: Scheduled deliveries, base restocking, bulk transfer processing
- Maintenance Cycles: Equipment servicing and facility upkeep operations

### Monthly Tick Processing
- Financial Updates: Public score aggregation, funding level computation, salary deductions
- Strategic Assessment: AI campaign wave spawning, policy expiration evaluation
- Reporting Generation: Monthly base reports and economic summary production
- Calendar Events: Monthly global events and player adjustment processing

### Quarterly Tick Processing
- Strategic Re-evaluation: AI weight adjustments, spawn weight modifications, faction behavior changes
- Economic Events: Treaty negotiations, supplier contract cycles, market condition resets
- Analytics Processing: Quarterly performance metrics for director escalation decisions

### Yearly Tick Processing
- Major Milestones: Global threat escalation, anniversary events, long-term balance adjustments
- Annual Reporting: Comprehensive campaign summaries and achievement tracking
- World Events: Year-specific occurrences and planetary anniversary celebrations

### Inter-World Travel Mechanics
- Transit Consumption: Calendar days consumed with portal base transit + distance modifier
- Daily Processing: Transit timers decremented on daily ticks with arrival hook triggering
- Asset Reservation: Units and crafts unavailable during transit, state persisting across saves
- En-Route Events: Data-driven hooks for ambushes, delays, and transit complications
- Arrival Integration: Transfer hooks and local mission availability upon completion

Transit consumes calendar days. Transit time = portal base transit + distance modifier (both data-defined) and is decremented on the daily tick. Units and crafts in transit are unavailable for missions until arrival; transit state persists across saves. Transit may invoke data-driven en-route hooks (ambush, drift delay) handled by the daily travel processor.

## Examples

### Time Progression Scenarios
- Turn Sequencing: On Turn 61 (day 1 of a 30-day month) processing order is daily tick → monthly tick → any weekly/quarterly/yearly triggers
- Campaign Milestones: Day 90 triggers quarterly processing, Day 360 triggers yearly processing with major events
- Weekly Cycles: Every 6th day processes recovery systems, training completion, and logistics batch operations
- Monthly Financial: Day 1 of every 30-day month executes funding transfers, salary deductions, and base reports

### Illumination Calculations
- Equatorial Province: X coordinate halfway across image yields longitude ≈ 0°, illumination near 1.0 (day)
- Far Side Province: X coordinate on image edge yields longitude ≈ 180°, illumination near -1.0 (night)
- Twilight Effects: illumination = 0.3 provides partial visibility for dawn/dusk gameplay effects
- Solar Angle Example: world_rotation = 45°, longitude = 30° gives solar_angle = 15°, illumination ≈ 0.97 (bright day)

### Processing Sequence Cases
- Daily Geoscape: Mission scripts advance, UFO movement calculated, interception resolution triggered
- Travel Processing: Transit timers decrement, craft arrivals processed, fuel consumption validated
- Simulation Tasks: Research points accumulate, manufacturing progresses, facility builds advance
- State Updates: Unit regeneration applied, temporary effects expire, mission timeouts trigger

### Travel and Transit Examples
- Portal Transit: Craft ordered through portal with 3-day base transit + 2-day distance modifier = 5-day timer
- Inter-World Travel: Units in transit unavailable for missions, state preserved across game saves
- En-Route Events: Data-driven hooks trigger ambushes or delays during transit processing
- Arrival Integration: Transfer hooks execute, making assets available for local mission assignment

## Related Wiki Pages

- [World.md](../geoscape/World.md) - World systems and geographical time zones
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer and time-based events
- [Research tree.md](../economy/Research%20tree.md) - Research progression and time requirements
- [Economy.md](../economy/Economy.md) - Economic cycles and production timing
- [Finance.md](../finance/Finance.md) - Funding cycles and financial periods
- [Basescape.md](../basescape/Basescape.md) - Base operations and construction timing
- [AI.md](../ai/AI.md) - AI scheduling and strategic timing
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission timing and deadlines
- [Portal.md](../geoscape/Portal.md) - Travel mechanics and transit time
- [SaveSystem.md](../technical/SaveSystem.md) - Time persistence and save state management

## Master References

📖 **For comprehensive Time Systems documentation, see:**
- **[Time Systems Master Document](../core/Time_Systems.md)** - Complete time scale definitions and conversions

This document focuses on strategic-level geoscape time progression (day/night cycles, weekly/monthly ticks). For broader context including:
- Tactical time scales (6-second turns in Battlescape)
- Operational time scales (30-second rounds in Air Combat)
- Time conversion formulas between all layers
- Duration calculations and display formats

Please refer to the master Time Systems document linked above.

## References to Existing Games and Mechanics

- **Civilization Series**: Turn-based time progression and era advancement
- **X-COM Series**: Monthly cycles and time-based mission generation
- **Crusader Kings III**: Date-based progression and historical time management
- **Europa Universalis IV**: Real-time strategy with pause and time controls
- **Stellaris**: Galactic time management and empire progression
- **Total War Series**: Campaign time and seasonal battle conditions
- **Final Fantasy Tactics**: Turn-based time and action economy
- **Advance Wars**: Day/night cycles affecting unit performance
- **Fire Emblem Series**: Turn structure and time-based mechanics
- **Tactics Ogre**: Time mechanics and turn-based progression

