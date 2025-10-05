# Surrender

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Timing and Evaluation Framework](#timing-and-evaluation-framework)
  - [Unit Viability Assessment](#unit-viability-assessment)
  - [Surrender Trigger Conditions](#surrender-trigger-conditions)
  - [Surrender Resolution Process](#surrender-resolution-process)
  - [Faction-Specific Configuration](#faction-specific-configuration)
  - [Capture and Processing Pipeline](#capture-and-processing-pipeline)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [Patrol Capture Scenario](#patrol-capture-scenario)
  - [Mass Panic Surrender](#mass-panic-surrender)
  - [Faction Exception Handling](#faction-exception-handling)
  - [Auto-Scuttle Implementation](#auto-scuttle-implementation)
  - [Commander-Dependent Surrender](#commander-dependent-surrender)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Surrender provides deterministic per-turn evaluation that ends tactical engagements when a side has no viable units remaining. When triggered, the surrendering side yields and surviving non-dead units are flagged for capture processing through the post-battle loot pipeline. All checks, captures, and downstream effects are data-driven, seeded, and provenance-logged for reproducible outcomes across replays, telemetry, and campaign systems. Configurable faction behaviors, auto-scuttle mechanics, and commander requirements allow designer control while maintaining core deterministic rules.

## Mechanics

### Timing and Evaluation Framework
- Per-Turn Execution: Runs once after action resolution each turn, before end-of-turn effects
- Pre-Condition Processing: Evaluates before healing, delayed damage, or reinforcements
- Deterministic Foundation: Seeded random number generation ensuring identical outcomes
- Provenance Logging: Complete audit trail of all decisions and outcomes

### Unit Viability Assessment
- Comprehensive Evaluation: Every surviving unit tested for combat capability
- Non-Viability Conditions: Dead (HP ≤ 0), incapacitated, stunned, panicked (morale ≤ 0)
- Action Capability: Units must be able to perform meaningful actions this turn
- Status Effect Integration: Active effects (stunned, unconscious) prevent viability
- Morale Integration: Panic behavior blocks unit participation

### Surrender Trigger Conditions
- Complete Non-Viability: All units on side must be non-viable to trigger surrender
- No Partial Surrender: Binary outcome - side either continues or fully surrenders
- Faction Override Support: Data flags can modify or prevent surrender checks
- Commander Requirements: Optional commander-alive conditions for surrender eligibility

### Surrender Resolution Process
- Immediate Yield: Surrendering side concedes the engagement
- Mission Outcome Assignment: Opposing side awarded victory per mission configuration
- Capture Processing: All surviving non-dead units flagged for capture pipeline
- Asset Handling: Auto-scuttle mechanics destroy/disable specified assets
- Post-Surrender Actions: Loot collection, cleanup routines, scripted consequences

### Faction-Specific Configuration
- Never Surrender Flag: Complete immunity to surrender checks
- Auto-Scuttle Behavior: Automatic asset destruction upon surrender
- Commander Dependencies: Require specific units alive for surrender eligibility
- Custom Conditions: Additional faction-specific surrender rules
- Behavioral Overrides: Scripted last-stand behaviors bypassing normal surrender

### Capture and Processing Pipeline
- Unit Flagging: Survivors marked as captured alive for downstream systems
- Holding Cell Integration: Units routed to detention facilities
- Interrogation Systems: Research and intelligence gathering opportunities
- Salvage Adjustments: Modified loot yields from captured units
- Campaign Consequences: Long-term effects on faction relationships and resources

### Determinism and Provenance
- Seeded Evaluation: Identical inputs produce identical surrender outcomes
- Complete Audit Trail: All decisions, unit states, and triggers logged
- Replay Compatibility: Full reconstruction capability from logged data
- Telemetry Integration: Statistical analysis for balance tuning
- Debug Support: Detailed logging for edge case investigation

## Examples

### Patrol Capture Scenario
- Initial Setup: Three-man enemy patrol on routine mission
- Combat Resolution: Two units killed by direct fire, third stunned by grenade
- End-of-Turn Evaluation: AI side has zero viable units remaining
- Surrender Trigger: Automatic surrender condition met
- Capture Processing: Stunned trooper flagged for capture and interrogation
- Mission Outcome: Player victory with live prisoner for research opportunities

### Mass Panic Surrender
- Psychic Attack: Area-effect ability reduces all defender morale to zero
- Panic Behavior: Entire garrison enters uncontrollable panic state
- Viability Assessment: No units capable of meaningful actions this turn
- Surrender Resolution: Immediate surrender with all survivors captured
- Capture Pipeline: Full garrison processed through holding cells and interrogation
- Campaign Impact: Significant research opportunities from captured specialists

### Faction Exception Handling
- Faction Configuration: Alien faction with never_surrender = true
- Combat Situation: All units panicked or incapacitated
- Surrender Check: Evaluation skipped due to faction override
- Continued Engagement: Scripted last-stand behavior maintains combat
- Designer Intent: Thematic representation of fanatical or robotic enemies

### Auto-Scuttle Implementation
- Mission Configuration: auto_scuttle_on_surrender enabled for enemy vehicles
- Surrender Trigger: Ground forces surrender after viability loss
- Asset Processing: All vehicles automatically destroyed or disabled
- Capture Prevention: No vehicle salvage opportunities for player
- Strategic Balance: Prevents easy technology acquisition from captured assets

### Commander-Dependent Surrender
- Faction Rules: surrender_requires_commander_alive = true
- Combat Situation: All troops incapacitated, commander survives
- Surrender Prevention: Commander presence blocks surrender trigger
- Continued Resistance: Mission continues with commander-only operations
- Thematic Representation: Command structure prevents premature capitulation

## Related Wiki Pages

- [Morale.md](../battlescape/Morale.md) - Low morale leads to panic and surrender.
- [Sanity.md](../battlescape/Sanity.md) - Sanity affects surrender decisions.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Incapacitated units can't act, leading to surrender.
- [Wounds.md](../battlescape/Wounds.md) - Severe wounds incapacitate units.
- [Unconscious.md](../battlescape/Unconscious.md) - Unconscious units are non-viable.
- [AI Battlescape.md](../ai/Battlescape%20AI.md) - AI evaluates surrender conditions.
- [Factions.md](../units/Factions.md) - Faction-specific surrender rules.
- [Capture.md](../battlescape/Capture.md) - Post-surrender capture processing.
- [Panic.md](../battlescape/Panic.md) - Panic behavior in surrender.
- [Commander.md](../units/Commander.md) - Commander presence affects surrender.

## References to Existing Games and Mechanics

- X-COM series: Alien surrender and capture mechanics.
- Civilization series: City surrender and diplomacy.
- Fire Emblem: Unit defeat and capture.
- Advance Wars: Unit elimination and surrender.
- Warhammer 40k: Last stand and no retreat rules.
- Dungeons & Dragons: Surrender in combat.
- Total War series: Army routing and surrender.
- Commandos series: Stealth and capture mechanics.

