# Core Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Action Economy Framework](#action-economy-framework)
  - [Capacity Management System](#capacity-management-system)
  - [Energy Resource System](#energy-resource-system)
  - [Time Progression Framework](#time-progression-framework)
  - [Cross-System Integration](#cross-system-integration)
  - [Deterministic Processing](#deterministic-processing)
- [Examples](#examples)
  - [Action Point Allocation](#action-point-allocation)
  - [Capacity Validation](#capacity-validation)
  - [Energy Management](#energy-management)
  - [Time Scale Transitions](#time-scale-transitions)
  - [Multi-System Coordination](#multi-system-coordination)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Core Systems define the fundamental mechanical frameworks that operate consistently across all game contexts in AlienFall, providing unified rules for action budgets, resource constraints, energy management, and temporal progression. These foundational systems establish common patterns that appear throughout tactical combat, strategic operations, and geoscape management, creating coherent player expectations and predictable interactions. By consolidating shared mechanics into centralized definitions, core systems enable modular design where battlescape units, interception craft, and strategic operations utilize identical underlying principles adapted to their specific contexts.

The core systems architecture emphasizes clarity through consistent terminology, deterministic behavior through seeded randomization, and extensibility through data-driven configuration. Action Economy governs turn-based action budgets across tactical and operational scales. Capacity Systems enforce binary constraints on carrying capacity and cargo limits. Energy Systems provide resource pools for special abilities and advanced capabilities. Time Systems coordinate temporal progression across strategic, operational, and tactical layers. Together, these frameworks create a unified mechanical foundation supporting all AlienFall gameplay.

## Mechanics

### Action Economy Framework
Action Points provide unified turn-based action budgets across different gameplay contexts:
- Tactical AP: Individual soldier actions during battlescape combat (4 AP per turn, ~6 second narrative time)
- Operational AP: Craft maneuvers during interception combat (4 AP per round, ~30 second narrative time)
- Strategic Time: Continuous time progression on geoscape (5-minute increments with variable speed multipliers)
- Consistent Budgets: Deliberate 4 AP standard across contexts for player familiarity and expectation management
- Action Costs: Data-driven costs for movement, combat, and utility actions defined in TOML configuration files
- Fractional Handling: Round-down for movement distance, round-up for action costs, no AP banking between turns

### Capacity Management System
Binary capacity constraints enforce hard limits without graduated penalties:
- Unit Encumbrance: Individual soldier carrying capacity based on Strength stat (Max_Weight = Strength × Multiplier)
- Craft Cargo: Dual-capacity system tracking weight (items/loot) and unit slots (personnel) independently
- Binary Validation: Configuration either acceptable or rejected without partial penalties or slowdown effects
- Pre-Mission Validation: Equipment screens prevent launching missions with invalid loadouts
- Runtime Validation: Pickup and swap actions checked against current capacity in real-time
- Design Philosophy: Clear can/cannot decisions force meaningful loadout planning and equipment progression

### Energy Resource System
Energy pools enable special abilities and advanced capabilities beyond basic operations:
- Tactical Energy: Per-unit resource (0-100) for abilities, heavy equipment, and movement modes during battlescape
- Operational Energy: Per-craft resource (0-100) for weapon systems, maneuvers, and special systems during interception
- Regeneration Mechanics: Automatic end-of-turn/round restoration with modifiers from equipment and status effects
- Energy Costs: Ability activation, heavy weapon firing, powered armor, and special movement modes consume energy
- Strategic Management: Players balance burst capabilities against sustained operations through energy allocation
- Equipment Integration: Energy clips restore pools, power generators increase regeneration, charging stations provide mid-mission recharge

### Time Progression Framework
Multiple temporal layers coordinate game progression across different contexts:
- Strategic Layer: Continuous 5-minute tick increments with 1×/5×/30× speed multipliers on geoscape
- Operational Layer: ~30 second simulated combat rounds during interception battles
- Tactical Layer: ~6 second abstracted combat turns during battlescape missions
- Time Conversions: 288 ticks per day, 360-day year (12 months × 30 days) for simplified calendar mathematics
- Event Scheduling: Duration-based actions (research, construction, travel) tracked in tick increments
- Pause System: Auto-pause on critical events (interceptions, missions, reports) with unpausable background processes

### Cross-System Integration
Core mechanics integrate seamlessly across all gameplay contexts:
- Shared Terminology: Identical concepts use consistent naming across tactical, operational, and strategic scales
- Unified Validation: Capacity checks, energy costs, and time calculations follow identical logical patterns
- Data-Driven Configuration: All costs, limits, and multipliers defined in TOML files enabling mod customization
- State Consistency: Core system values persist correctly across save/load and context transitions
- Modular Design: Systems operate independently while providing clear integration points for dependent features

### Deterministic Processing
All core mechanics incorporate seeded randomization for reproducible behavior:
- Action Resolution: Combat outcomes and ability effects use campaign-seeded RNG for replay consistency
- Capacity Calculations: Deterministic weight summation and validation preventing floating-point inconsistencies
- Energy Regeneration: Fixed restoration amounts avoid accumulation errors across extended sessions
- Time Advancement: Precise tick-based progression ensures event scheduling accuracy and replay validity
- Testing Support: Deterministic core systems enable comprehensive QA validation and balance analysis

## Examples

### Action Point Allocation
Battlescape soldier with 4 AP evaluates action options: aimed shot (3 AP) leaves 1 AP for short movement or door opening, snap shot (1 AP) preserves 3 AP for extended repositioning, burst fire (2 AP) enables follow-up grenade throw (2 AP) consuming full budget. Fast soldier (Speed 12) converts 2 AP into 24 tiles flat ground movement or 12 tiles rough terrain movement, demonstrating Speed stat impact on movement efficiency.

### Capacity Validation
Soldier with Strength 10 has 20 weight capacity. Assault rifle (4 weight) + armor (6 weight) + medkit (2 weight) + 3 grenades (3 weight) totals 15 weight (valid). Attempting to add heavy plasma (8 weight) increases total to 23 weight, triggering rejection with red indicator preventing mission launch. Equipment screen displays current 15/20 capacity with visual feedback guiding player loadout optimization.

### Energy Management
Unit begins mission with 100 energy, uses psi ability (40 energy cost) leaving 60 energy. Running 8 tiles costs 16 energy (2 energy per tile) reducing pool to 44 energy. End-of-turn regeneration restores 20 energy bringing total to 64 energy. Subsequent powered armor activation (30 energy) leaves 34 energy available for next turn. Strategic energy conservation enables sustained special ability usage across extended missions.

### Time Scale Transitions
Geoscape craft detects UFO at Day 5, 14:00 (tick 41,760), triggering auto-pause and interception interface. Interception combat resolves over 8 rounds (~4 minutes simulated time). Upon victory, geoscape resumes at Day 5, 14:04 (tick 41,809). Crash site mission initiated at Day 5, 16:00 generates tactical battlescape. Completing 30-turn tactical engagement (3 minutes abstracted time) returns to geoscape at Day 5, 16:03. Time systems coordinate seamlessly across context transitions.

### Multi-System Coordination
Heavy weapon platform soldier demonstrates cross-system interaction: High Strength (15) provides 30 weight capacity enabling heavy plasma (8) + powered armor (10) + support equipment (8) within capacity limits. Powered armor grants +10 maximum energy (110 total) and +5 energy regeneration. Heavy plasma costs 25 energy per shot, with armor regeneration (+25 per turn) enabling sustainable firing. Action economy allocates 2 AP per shot, 2 AP for repositioning. Four systems (action, capacity, energy, time) integrate producing coherent tactical unit behavior.

## Related Wiki Pages

- [Action_Economy.md](Action_Economy.md) - Detailed action point mechanics across contexts
- [Capacity_Systems.md](Capacity_Systems.md) - Unit and craft capacity frameworks
- [Energy_Systems.md](Energy_Systems.md) - Tactical and operational energy mechanics
- [Time_Systems.md](Time_Systems.md) - Temporal progression and event scheduling
- [Units](../units/README.md) - Unit-level system applications
- [Crafts](../crafts/README.md) - Craft-level system applications
- [Battlescape](../battlescape/README.md) - Tactical combat integration
- [Interception](../interception/README.md) - Operational combat integration
- [Geoscape](../geoscape/README.md) - Strategic layer integration

## References to Existing Games and Mechanics

- **XCOM Series**: Action point economy and turn-based tactical systems
- **Jagged Alliance**: Energy and action point management mechanics
- **Fallout Tactics**: Action point allocation and combat systems
- **Divinity Original Sin**: Turn-based action economy and resource management
- **Into the Breach**: Deterministic tactical combat mechanics
- **Darkest Dungeon**: Stress and resource management systems
- **FTL**: Operational-level energy and system management
- **Master of Orion**: Strategic time progression and event scheduling
- **Civilization**: Multi-scale time systems and resource management
- **Phoenix Point**: Action point and resource management integration
