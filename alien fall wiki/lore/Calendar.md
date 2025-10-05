# Calendar

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Time Units](#time-units)
  - [Daily Processing Order](#daily-processing-order)
  - [Periodic Triggers](#periodic-triggers)
  - [Deterministic Behavior](#deterministic-behavior)
  - [Provenance Tracking](#provenance-tracking)
- [Examples](#examples)
  - [Daily Processing Flow](#daily-processing-flow)
  - [Monthly Processing Flow](#monthly-processing-flow)
  - [Failure Scenarios](#failure-scenarios)
  - [Deterministic Replay](#deterministic-replay)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Calendar system serves as the master scheduler for all time-based game mechanics in Alien Fall, advancing global time and deterministically driving missions, campaigns, events, and resource systems. Time progresses in discrete ticks with clear ordering and boundaries, ensuring predictable interactions between all time-dependent systems. The calendar uses seeded randomization to guarantee reproducible outcomes across playthroughs, making it the authoritative time reference for the entire game world. This system creates the foundation for strategic pacing, ensuring that all time-dependent mechanics advance consistently and predictably.

### Key Design Principles

- Master Scheduling: Central coordination of all time-based game mechanics
- Deterministic Progression: Seeded randomization ensures reproducible campaign outcomes
- Discrete Time Units: Clear temporal boundaries for different scales of gameplay
- Predictable Interactions: Explicit ordering prevents system conflicts and race conditions
- Data-Driven Configuration: All calendar parameters defined in external configuration files

## Mechanics

### Time Units

Custom time system optimized for strategic gameplay pacing:

- Turn: 1 Day (atomic unit of player action and decision-making)
- Week: 6 Days (short-term operational cycles and maintenance periods)
- Month: 30 Days / 5 Weeks (major scheduling boundary for campaigns and economics)
- Quarter: 90 Days / 3 Months (strategic planning cycles and major world updates)
- Year: 360 Days / 4 Quarters (long-term campaign arcs and global changes)

### Daily Processing Order

Each day follows a deterministic sequence ensuring predictable system interactions:

- Advance Day Counter: Update calendar state and run maintenance hooks
- Pre-Processing Hooks: Execute upkeep systems (wound timers, loan interest, recovery)
- Campaign Scripts: Run enemy behavior and mission progression logic
- Detection Updates: Process radar/sensor systems for mission visibility changes
- Player Input Phase: Allow base management, mission assignments, and strategic decisions
- End-of-Day Resolution: Apply mission expirations, score changes, and penalties
- Post-Processing Hooks: Execute cleanup, reporting, and state persistence

### Periodic Triggers

Different time scales trigger appropriate scopes of world updates:

- Weekly: Staff payroll, maintenance cycles, recovery ticks, small recurring reports
- Monthly: Campaign sampling, event activation, funding payouts, supplier restocks, comprehensive reports
- Quarterly: Major world updates, trend adjustments, special events, strategic recalculations
- Yearly: Long-term strategic changes, campaign conclusions, global trend resets

### Deterministic Behavior

All random elements use seeded generation for reproducible outcomes:

- World Seeding: Campaign seed ensures consistent results across sessions and platforms
- Named RNG Streams: Separate random streams for different subsystems prevent cross-contamination
- Tick-Based Seeds: Deterministic seeds derived from time and domain for stable generation
- Provenance Logging: Complete audit trail of all random decisions for debugging and analysis

### Provenance Tracking

Comprehensive logging enables debugging, replay, and balance analysis:

- Event Logging: All calendar events recorded with full context and timing
- Seed Tracking: RNG seeds and states preserved for exact reproduction
- Decision Audit: Sampling outcomes logged with input parameters and weights
- Error Recording: System failures and edge cases documented for troubleshooting

## Examples

### Daily Processing Flow

Standard Day Progression
- Day advances from 15 to 16 with calendar state update
- Pre-processing: Wound timers decrement, loan interest accrues, maintenance costs applied
- Campaign scripts: Enemy UFO moves toward target city following scripted behavior
- Detection updates: UFO becomes visible on radar systems
- Player phase: Assign interceptors, manage base construction, issue strategic orders
- End-of-day: Mission expiration penalties applied for unresolved timed missions
- Post-processing: Daily reports generated, state persisted for next session

High-Pressure Day
- Multiple campaigns active with overlapping mission scripts
- Detection reveals three simultaneous UFO incursions requiring prioritization
- Player must allocate limited resources across multiple threats
- Mission assignments affect next day's campaign progression and difficulty
- Score impacts from unresolved threats accumulate over time

### Monthly Processing Flow

Month Boundary Activation
- Day resets to 1, month advances with comprehensive state update
- Campaign sampling: New alien faction campaign instantiated based on weights
- Event pool activation: Random events triggered using seeded selection
- Funding cycle: Monthly payouts processed, supplier inventories refreshed
- Report generation: Comprehensive monthly summary created with all key metrics

Resource Management Month
- Insufficient funds trigger payroll failure with operational consequences
- Unpaid staff become non-operational, reducing base efficiency
- Supplier restocks delayed due to payment issues
- Monthly report highlights funding problems and suggests remedies
- Player must resolve financial issues before next monthly boundary

### Failure Scenarios

Mission Expiration
- Timed mission reaches deadline without player resolution
- Score penalty applied for failure to respond to strategic threats
- Mission site may be lost or escalate in difficulty for future encounters
- Deterministic consequences based on mission type and strategic importance

Payroll Failure
- Insufficient account balance at monthly boundary triggers failure
- Affected staff marked as unpaid and non-operational until resolved
- Base efficiency reduced across all operations and research
- Clear logging of financial state provides player awareness and debugging data

Campaign Overload
- Too many simultaneous active campaigns stress system resources
- Priority-based campaign processing prevents deadlocks and maintains stability
- Warning indicators alert players to approaching system limits
- Graceful degradation ensures game remains playable under high load

### Deterministic Replay

Bug Reproduction
- Player reports inconsistent campaign behavior or unexpected outcomes
- Development team uses logged seeds to reproduce exact conditions
- Same world seed + same player actions = identical outcomes every time
- Provenance logs enable step-by-step debugging and issue isolation

Balance Testing
- Designers iterate campaign weights and event frequencies with fixed seeds
- Consistent event sampling enables reliable statistical analysis
- Performance metrics gathered across multiple seeded runs
- Tuning decisions based on reproducible data and player feedback

## Related Wiki Pages

- [Campaign.md](Campaign.md) - Campaign progression and timing
- [Event.md](Event.md) - Time-based event scheduling
- [Mission.md](Mission.md) - Mission generation and timing
- [Geoscape.md](../geoscape/Geoscape.md) - Geoscape time-based events
- [Economy.md](../economy/Economy.md) - Economic cycles and deadlines
- [Faction.md](Faction.md) - Faction calendar and activities
- [Quest.md](Quest.md) - Quest timing and progression
- [UFO Script.md](UFO%20Script.md) - UFO activity cycles

## References to Existing Games and Mechanics

- **Civilization Series**: Turn-based calendar and historical progression
- **Crusader Kings Series**: Date-based event scheduling and character lifespans
- **Europa Universalis Series**: Historical calendar and event timing
- **Total War Series**: Campaign calendar and seasonal effects
- **XCOM Series**: Monthly progression and alien activity cycles
- **Fire Emblem Series**: Chapter-based progression and time limits
- **Final Fantasy Tactics**: Story progression and time-based events
- **Disgaea Series**: Turn-based calendar and character aging
- **BattleTech**: Campaign calendar and mission scheduling
- **MechWarrior Series**: Mission calendar and contract deadlines

