# Sanity

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Sanity Storage and Bounds](#sanity-storage-and-bounds)
  - [Mission Resolution Changes](#mission-resolution-changes)
  - [Weekly Recovery System](#weekly-recovery-system)
  - [Tactical Effect Integration](#tactical-effect-integration)
  - [Provenance and Determinism](#provenance-and-determinism)
- [Examples](#examples)
  - [Low Intensity Mission Completion](#low-intensity-mission-completion)
  - [High Intensity Survival with Penalties](#high-intensity-survival-with-penalties)
  - [Facility-Based Recovery](#facility-based-recovery)
  - [Roster Rotation Pressure](#roster-rotation-pressure)
  - [Psionic Exposure Scenario](#psionic-exposure-scenario)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Sanity represents a persistent, campaign-scoped resilience stat measuring long-term psychological health and susceptibility to hallucinations or reduced effectiveness. Immutable during missions, sanity changes occur deterministically at mission resolution or weekly recovery ticks, ensuring reproducible in-mission behavior. The system provides clear recovery paths through facilities and racial traits, integrates with psionics and narrative moments, and maintains complete provenance logging for telemetry and balance analysis. Data-driven intensity mappings, facility bonuses, and trait modifiers enable extensive tuning while enforcing roster rotation through slow recovery mechanics.

## Mechanics

### Sanity Storage and Bounds
- Integer Range: Sanity stored as integer from 0 to 10 per unit
- Default Values: Starting sanity 10, maximum sanity 10
- Immutability: No changes during mission execution
- Update Timing: Changes applied post-mission or on weekly recovery ticks
- Bound Enforcement: Automatic clamping to valid ranges

### Mission Resolution Changes
- Deterministic Deltas: Single sanity delta calculated per unit at mission end
- Intensity Mapping: Low (-1), medium (-2), high (-3) base losses
- Additive Penalties: Heavy wounds (-1), witnessed ally deaths (-1)
- Scripted Events: Data-driven horror penalties per narrative event
- Psionic Exposure: Intensity-scaled penalties for mental strain

### Weekly Recovery System
- Base Recovery: +1 sanity per weekly tick
- Facility Bonuses: Psi Clinic (+1), Hospital (+2), Recreation Center (×1.5 multiplier)
- Trait Modifiers: Racial and individual trait adjustments (additive/multiplicative)
- Maximum Clamping: Recovery cannot exceed unit maximum sanity
- Facility Integration: Active base facilities provide ongoing benefits

### Tactical Effect Integration
- Action Point Modifiers: Sanity sampled at mission start only
- AP Scale: ≥10 (+1), ≤3 (-1), ≤2 (-2), ≤1 (-3), ≤0 (-4)
- Decoupled Design: Sanity effects separate from in-mission morale/panic
- Optional Extensions: Accuracy penalties and deployment refusal available
- Mission Start Application: Modifiers applied before mission execution

### Provenance and Determinism
- Complete Logging: All changes tracked with timestamps and context
- Mission Correlation: Links to specific missions and performance data
- Seed Tracking: Deterministic seeds ensure reproducible calculations
- Telemetry Integration: Statistical data collection for balance analysis
- History Preservation: Full audit trail per unit for debugging

## Examples

### Low Intensity Mission Completion
- Mission Parameters: Low intensity classification
- Unit Performance: No wounds, no witnessed deaths, no scripted horror
- Sanity Calculation: Base loss -1, total delta -1
- Starting Sanity: 10 → Ending sanity 9
- Next Mission Impact: AP modifier 0 (no penalty at sanity 9)

### High Intensity Survival with Penalties
- Mission Parameters: High intensity classification
- Unit Performance: Heavy wound suffered, ally death witnessed
- Sanity Calculation: Base loss -3, wound penalty -1, death penalty -1, total delta -5
- Starting Sanity: 10 → Ending sanity 5
- Next Mission Impact: AP modifier 0 (penalty threshold not reached)

### Facility-Based Recovery
- Current Sanity: 6 after multiple deployments
- Active Facilities: Hospital (treating injuries)
- Recovery Calculation: Base +1, hospital bonus +2, total recovery +3
- Ending Sanity: 6 → 9 (within maximum bounds)
- Continued Treatment: Additional weeks can reach full recovery

### Roster Rotation Pressure
- Deployment Pattern: Veteran unit on 4 consecutive high-intensity missions
- Cumulative Losses: Mission 1 (-3) → 7, Mission 2 (-3) → 4, Mission 3 (-3) → 1, Mission 4 (-3) → -2 (clamped to 0)
- Recovery Attempts: Weekly +1 recovery between missions
- Strategic Dilemma: Sanity 0 triggers severe penalties, forces rest or facility investment
- Long-term Impact: Demonstrates need for squad rotation and recovery planning

### Psionic Exposure Scenario
- Mission Context: Heavy psionic activity with mind control attempts
- Exposure Intensity: Level 3 psionic encounters
- Sanity Calculation: Base psionic penalty -2 × intensity multiplier 3 = -6
- Combined Effects: High intensity -3 + psionic exposure -6 = -9 total
- Recovery Requirements: Multiple weeks of facility treatment needed

## Related Wiki Pages

The Sanity system affects unit performance and recovery:

- **Morale.md**: Sanity influencing morale states.
- **Panic.md**: Low sanity triggering panic.
- **Psionics.md**: Psionic exposure affecting sanity.
- **Wounds.md**: Injuries impacting sanity.
- **Mission objectives.md**: Mission intensity affecting sanity loss.
- **Facilities** (basescape/): Recovery facilities for sanity.
- **Traits.md** (units/): Racial traits affecting sanity.
- **Stats.md** (units/): Unit stats related to sanity.
- **Geoscape AI.md** (ai/): AI considering sanity in decisions.
- **Battlescape AI.md** (ai/): In-mission sanity effects.

## References to Existing Games and Mechanics

The Sanity system draws from psychological mechanics in games:

- **X-COM series (1994-2016)**: Morale and panic systems.
- **Silent Hill series (1999-2012)**: Sanity and mental health effects.
- **Call of Cthulhu (1981-2023)**: Sanity loss from horror elements.
- **Darkest Dungeon (2016)**: Stress and sanity mechanics.
- **Bloodborne (2015)**: Madness and sanity loss.
- **Amnesia series (2010-2021)**: Sanity and psychological horror.
- **Outlast series (2013-2023)**: Mental strain and sanity.
- **SOMA (2015)**: Psychological effects on characters.

