# Morale

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Morale Bounds and Defaults](#morale-bounds-and-defaults)
  - [Will Test System](#will-test-system)
  - [AP Modifiers](#ap-modifiers)
  - [Panic State](#panic-state)
  - [Recovery Mechanisms](#recovery-mechanisms)
  - [Stress Triggers](#stress-triggers)
  - [Tuning and Configuration](#tuning-and-configuration)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [Will Test Examples](#will-test-examples)
  - [Morale Progression](#morale-progression)
  - [Stress Trigger Examples](#stress-trigger-examples)
  - [Recovery Examples](#recovery-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Morale represents a unit's short-term combat composure and psychological resilience during tactical missions. It serves as a mission-scoped resource that influences action economy and behavior under stress, creating meaningful tactical consequences for prolonged engagements. The system uses deterministic, seeded Will tests and configurable stress triggers to ensure reproducible outcomes while allowing designers to tune morale dynamics. Low morale creates cascading tactical penalties through AP reduction and can trigger panic states that severely limit unit capabilities. All morale changes and panic events are provenance-logged for debugging, telemetry, and replay functionality.

## Mechanics

### Morale Bounds and Defaults
Morale operates within configurable bounds that define unit psychological state and effectiveness thresholds.

- Starting Morale: Configurable per mission (default 10), can be overridden for ambush scenarios
- Maximum Morale: Upper bound for recovery and bonuses (default 10)
- No Lower Bound: Morale can drop below zero, triggering panic at zero or below
- Mission Scoped: Resets between missions unless campaign settings allow carryover

### Will Test System
Will tests determine whether stressful events reduce unit morale, using deterministic seeded randomization.

- Trigger Events: Specific combat situations that require Will tests
- Success Calculation: SuccessChance = clamp(unit.Will + testModifier, MinChance, MaxChance)
- Deterministic Resolution: Uses mission-seeded random generation for reproducible results (r = RandomIntSeeded(1..100, seed) where seed = Hash(missionSeed, unitId, eventIndex))
- Sequential Processing: Multiple simultaneous triggers resolve one test per trigger
- Failure Consequence: Morale decreases by 1 on failed tests

### AP Modifiers
Morale levels directly modify unit action point budgets, creating tactical urgency and recovery incentives.

- High Morale Bonus: Morale ≥ 10 provides optional +1 AP modifier
- Normal Range: Morale 4-9 maintains baseline AP efficiency
- Progressive Penalties: Morale 3 (-1 AP), 2 (-2 AP), 1 (-3 AP)
- Panic Threshold: Morale ≤ 0 applies -4 AP modifier
- Dynamic Recalculation: AP modifiers update immediately after morale changes

### Panic State
Panic represents complete psychological breakdown, severely restricting unit capabilities while providing recovery opportunities.

- Trigger Condition: Morale drops to 0 or below
- Action Restrictions: Limited to recovery behaviors (REST) or morale-recovery abilities
- Recovery Requirements: REST actions, successful rallies, leader auras, or time-based recovery
- UI Feedback: Clear panic state indicators and restricted action highlighting
- Logging Requirements: All panic events recorded in provenance system

### Recovery Mechanisms
Multiple recovery pathways allow units to restore morale and return to effective combat status.

- REST Action: Configurable morale restoration (+1 per use by default)
- Rally Abilities: Leader auras and special abilities providing morale boosts or Will test bonuses
- Will Test Bonuses: Temporary modifiers improving recovery success chances
- Item Effects: Equipment providing morale recovery or Will test bonuses
- Post-Mission Reset: Morale returns to maximum unless carryover enabled

### Stress Triggers
Comprehensive trigger system covers all major combat stress sources with configurable test generation.

- Casualty Events: Friendly unit deaths within sight or hearing range
- Damage Events: Being hit, receiving wounds, or large damage hits (every N HP triggers extra test, default N=3)
- Tactical Events: Reaction fire hits, surprise attacks, suppression, sustained incoming fire
- Psychological Events: Nearby ally panic, horror effects, gruesome scripted events
- Environmental Events: Explosions, structural collapse, fire in deployment zone
- Mission Events: Major objective failures, VIP casualties

### Tuning and Configuration
Extensive configuration options allow designers to balance morale difficulty and player experience.

- Base Values: Starting morale, maximum morale, success chance bounds (MinChance=10, MaxChance=90)
- Test Parameters: HP thresholds for extra tests, REST recovery amounts
- Facility Links: Recreation facilities, Psi clinics providing morale bonuses
- Ability Integration: Leader auras and special abilities affecting morale
- Campaign Settings: Inter-mission carryover and difficulty scaling

### Determinism and Provenance
All morale mechanics use seeded randomization with complete audit trails for debugging and analysis.

- Mission Seeding: All random elements seeded by mission/world seed for reproducible outcomes
- Provenance Logging: Complete record of Will test inputs, outcomes, morale changes, and panic events
- Event Tracking: Panic events, recovery actions, and modifier applications
- Debug Support: Deterministic replay capability for testing and balancing
- Telemetry Data: Comprehensive morale event data for player behavior analysis

## Examples

### Will Test Examples

Basic Combat Stress
- Unit with Will 40 takes reaction fire hit
- Test modifier: -30 (reaction fire penalty)
- Success chance: clamp(40-30, 10, 90) = 10%
- Likely failure results in morale -1

Large Damage Hit
- Unit takes 7 HP damage in single hit
- HP threshold: 3 HP per extra test
- Extra tests: floor(7/3) = 2 additional Will tests
- Each test can reduce morale by 1

Leader Aura Support
- Unit with Will 35 under leader aura
- Test modifier: +20 (aura bonus)
- Success chance: clamp(35+20, 10, 90) = 55%
- Improved success chance preserves morale

### Morale Progression

Standard Mission Flow
- Starting morale: 10 (normal mission)
- Early skirmish: 2 failed Will tests → morale 8
- Sustained combat: Additional failures → morale 5 (-1 AP)
- Critical moment: Further stress → morale 2 (-2 AP)
- Recovery phase: REST action → morale 3 (-1 AP restored)

Ambush Scenario
- Starting morale: 7 (ambush penalty)
- Immediate contact: Early failures → morale 5
- Prolonged fighting: Drops to 3 (-1 AP) then 1 (-3 AP)
- Breaking point: Morale 0 triggers panic state

### Stress Trigger Examples

Casualty Chain Reaction
- Friendly unit dies in sight: Triggers Will test
- Nearby ally fails test: Morale -1
- Adjacent unit sees ally panic: Triggers additional test
- Chain reaction potentially affects multiple units

Suppression Effects
- Unit under sustained fire: Suppression trigger
- Failed Will test: Morale reduction
- AP penalty: Reduced tactical effectiveness
- Recovery opportunity: Move to cover, use REST action

Environmental Horror
- Large explosion near deployment zone: Environmental trigger
- Multiple units affected: Simultaneous Will tests
- Morale drops: Potential panic cascade
- Recovery challenge: Limited safe zones for REST

### Recovery Examples

REST Recovery
- Panicked unit (morale 0) uses REST action
- Morale restoration: +1 morale (configurable)
- State change: Exits panic if morale > 0
- AP restoration: Regains tactical capability

Leader Rally
- Leader ability activates aura: +20 Will test bonus
- Affected units gain recovery advantage
- Failed tests become successful: Morale preserved
- Tactical impact: Maintains unit effectiveness in crisis

## Related Wiki Pages

- [Panic.md](../battlescape/Panic.md) - Low morale causes panic.
- [Sanity.md](../battlescape/Sanity.md) - Morale affects sanity.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Morale affects actions.
- [Psionics.md](../battlescape/Psionics.md) - Psi affects morale.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Fire affects morale.
- [Wounds.md](../battlescape/Wounds.md) - Wounds affect morale.
- [Surrender.md](../battlescape/Surrender.md) - Low morale leads to surrender.
- [Squad Autopromotion.md](../battlescape/Squad%20Autopromotion.md) - Leadership boosts morale.
- [AI Battlescape.md](../ai/Battlescape%20AI.md) - AI morale.
- [Stats.md](../units/Stats.md) - Will stat for morale.

## References to Existing Games and Mechanics

- X-COM series: Morale system and will tests.
- Fire Emblem series: Support system and morale boosts.
- Warhammer 40k: Leadership and morale.
- Advance Wars: CO powers affecting morale.
- Civilization series: Happiness and morale.
- Dungeons & Dragons: Morale rules.
- Total War series: Army morale.
- Commandos series: Stealth and morale.

