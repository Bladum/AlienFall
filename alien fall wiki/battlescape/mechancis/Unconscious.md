# Unconscious

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Incapacitation Conditions](#incapacitation-conditions)
  - [In-Mission Behavior](#in-mission-behavior)
  - [Post-Mission Resolution](#post-mission-resolution)
  - [Revive Mechanics](#revive-mechanics)
  - [Capture and Salvage Integration](#capture-and-salvage-integration)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [HP Depletion Incapacitation](#hp-depletion-incapacitation)
  - [Stun-Based Capture](#stun-based-capture)
  - [Medical Revival Attempt](#medical-revival-attempt)
  - [Post-Mission Disposition](#post-mission-disposition)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Unconscious manages units that are incapacitated but not dead, providing an auditable mission state for non-lethal takedowns, revive mechanics, and post-mission disposition. Units become unconscious through HP depletion or stun accumulation, removed from active combat while retaining provenance for deterministic capture, salvage, and revive resolution. Designers can tune incapacitation conditions, revive rules, and post-mission conversion probabilities to support capture-focused playstyles and non-lethal strategies. All unconscious events are seed-linked and provenance-logged for reproducible outcomes in testing and multiplayer.

## Mechanics

### Incapacitation Conditions
- HP Depletion: Units with HP reduced to 0 or below become unconscious
- Stun Accumulation: Stun damage meeting or exceeding unit's stun capacity
- Damage Source Tracking: Different causes (HP damage, stun damage) affect recovery
- Immediate Removal: Unconscious units removed from active battlefield participation
- State Preservation: Units maintained in simulation for provenance and post-mission logic

### In-Mission Behavior
- Action Prevention: Unconscious units cannot perform any actions
- Simulation Continuity: Units remain as state objects for capture and salvage logic
- Dragging Mechanics: Explicit actions required to move unconscious units
- Treatment Actions: Medical interventions can attempt revival during mission
- Security Actions: Units can be secured or stabilized by allied actions

### Post-Mission Resolution
- HP-Based Incapacitation: May convert to corpses, severe wounds, or long-term injuries
- Stun-Based Incapacitation: Typically recover without permanent effects
- Disposition Determination: Prisoner, corpse, medical treatment, or salvage
- Campaign Integration: Outcomes affect research, resources, and narrative
- Probabilistic Conversion: Data-driven probabilities for different outcomes

### Revive Mechanics
- Medical Intervention: Medics can attempt in-mission stabilization
- Success Requirements: Medical skill, equipment, and time constraints
- Partial Recovery: Revived units may have reduced effectiveness
- Attempt Limits: Maximum revive attempts to prevent exploitation
- Provenance Tracking: All revive attempts logged for balance analysis

### Capture and Salvage Integration
- Live Capture: Stun-incapacitated units become prisoners for interrogation
- Corpse Recovery: HP-depleted units may provide salvage or research opportunities
- Equipment Salvage: Weapons and gear recovered from incapacitated units
- Medical Treatment: Campaign-level recovery for revived or captured units
- Resource Conversion: Different outcomes provide different campaign benefits

### Determinism and Provenance
- Seed-Linked Events: All unconsciousness triggers reproducible from mission seed
- Complete Audit Trail: TickId, seed offsets, cause, and all interventions logged
- Revive Tracking: Success/failure of medical interventions recorded
- Disposition Logging: Final outcomes documented for campaign integration
- Multiplayer Parity: Identical outcomes across network play

## Examples

### HP Depletion Incapacitation
- Combat Damage: Soldier HP reduced to 0 from gunfire
- Immediate Incapacitation: Unit removed from active combat
- Post-Mission Evaluation: 40% chance corpse, 35% severe wounds, 25% recovery
- Campaign Impact: Potential research from recovered equipment or autopsy
- Disposition Tracking: Final state affects monthly casualty reports

### Stun-Based Capture
- Non-Lethal Takedown: Alien incapacitated by stun weapon (stun = 100/100 capacity)
- Live Recovery: Unit remains viable for capture and interrogation
- No Permanent Injury: Expected full recovery without long-term effects
- Intelligence Value: Provides research opportunities and mission intelligence
- Strategic Choice: Enables capture objectives over lethal elimination

### Medical Revival Attempt
- In-Mission Treatment: Medic uses revive action on unconscious ally
- Success Probability: 70% base chance modified by medical skill and equipment
- Partial Recovery: Revived unit returns with 50% HP and action penalty
- Attempt Tracking: Logged revive attempt (1/3 maximum attempts)
- Tactical Decision: Weigh immediate combat contribution vs resource expenditure

### Post-Mission Disposition
- Prisoner Processing: Captured stun victims enter holding cells
- Medical Treatment: Revived units receive campaign-level recovery
- Corpse Salvage: Dead units provide equipment and research opportunities
- Injury Conversion: Severe wounds create long-term unit limitations
- Resource Allocation: Different outcomes provide different campaign benefits

## Related Wiki Pages

- [Wounds.md](../battlescape/Wounds.md) - Wounds can lead to unconsciousness.
- [Morale.md](../battlescape/Morale.md) - Morale affects recovery.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Actions on unconscious units.
- [Revive.md](../battlescape/Revive.md) - Revival mechanics.
- [Capture.md](../battlescape/Capture.md) - Capturing unconscious units.
- [Stun.md](../battlescape/Stun.md) - Stun damage causes unconsciousness.
- [Medical.md](../battlescape/Medical.md) - Medical treatment.
- [Panic.md](../battlescape/Panic.md) - Panic can incapacitate.
- [Surrender.md](../battlescape/Surrender.md) - Related to incapacitation.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Stun from smoke.

## References to Existing Games and Mechanics

- X-COM series: Unconscious aliens for capture.
- Fallout series: Injury and unconsciousness system.
- Fire Emblem: Critical hits causing unconsciousness.
- Advance Wars: Unit elimination vs capture.
- Dungeons & Dragons: Unconscious from damage.
- Warhammer 40k: Stunned and incapacitated units.
- Rainbow Six Siege: Non-lethal takedowns.
- Deus Ex: Knockout mechanics.

