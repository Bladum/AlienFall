# Psionics

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Ability Gating and Unlocking](#ability-gating-and-unlocking)
  - [Resource Management System](#resource-management-system)
  - [Success Resolution Framework](#success-resolution-framework)
  - [Targeting and Geometry Systems](#targeting-and-geometry-systems)
  - [Effect Integration Architecture](#effect-integration-architecture)
  - [Resistance and Immunity Framework](#resistance-and-immunity-framework)
- [Examples](#examples)
  - [Psi Stun Application](#psi-stun-application)
  - [Mind Control Scenario](#mind-control-scenario)
  - [Telekinesis Objective Denial](#telekinesis-objective-denial)
  - [Telepathy Reveal Operation](#telepathy-reveal-operation)
  - [Ignite Area Denial](#ignite-area-denial)
  - [Psi Panic Induction](#psi-panic-induction)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Psionics represents a modular, data-driven family of deterministic mental abilities gated by Psi skill, research, and equipment. Abilities provide damage, control, utility, and reconnaissance effects through explicit data records with costs, scaling, ranges, and failure/backlash rules. All success calculations, partial successes, and randomness use named, mission-seeded RNG streams for reproducible outcomes across replays and multiplayer sessions. Comprehensive provenance logging enables balance analysis while extensive integration with existing engine systems ensures consistent behavior and tuning capabilities.

## Mechanics

### Ability Gating and Unlocking
- Psi Skill Requirements: Minimum Psi values for ability access
- Research Prerequisites: Psi Lab and technology requirements
- Class Restrictions: Specific unit classes with psionic capabilities
- Equipment Dependencies: Items providing psionic access or enhancement
- Training Progression: Promotion and skill advancement unlocks

### Resource Management System
- Energy Costs: Psi-specific resource consumption per ability use
- Action Point Costs: Standard AP expenditure for tactical integration
- Cooldown Mechanics: Turn-based ability recovery timers
- Charge Limits: Limited uses with regeneration or recharge mechanics
- Consumption Rules: Item destruction or degradation on use

### Success Resolution Framework
- Deterministic Formula: Base success + Psi scaling - Will resistance + modifiers
- Seeded Randomness: Mission-based seeds ensure reproducible outcomes (actionSeed = Hash(missionSeed, attackerId, actionIndex, abilityId))
- Partial Success Support: Reduced magnitude or duration effects
- Failure Consequences: Backlash, energy drain, or item degradation
- Provenance Tracking: Complete audit trail of calculations and rolls

### Targeting and Geometry Systems
- Line of Sight Requirements: Standard visibility gating with waivers
- Line of Fire Options: Projectile-like requirements for some abilities
- Area Shapes: Single target, radius, cone, and line configurations
- Range Limitations: Distance-based targeting constraints
- Unseen Entity Handling: Configurable behavior for hidden targets

### Effect Integration Architecture
- Damage Pipeline: Direct damage feeds standard POINT/AREA resolution
- Status Application: Stun, control, and duration effects with stacking rules
- Terrain Interactions: Fire propagation, knockback, and object movement
- Visibility Modifications: Temporary reveals and concealment changes
- Morale Integration: Panic triggers and sanity system connections

### Resistance and Immunity Framework
- Trait-Based Defenses: Equipment and technology providing resistance
- Type-Specific Multipliers: Different effects for various psi types
- Full Immunity Options: Complete protection against specific abilities
- Tag-Based Classification: Ability categorization for resistance lookup
- Dynamic Modifiers: Status effects altering resistance values

## Examples

### Psi Stun Application
- Ability Parameters: Base success 50%, Psi scaling 2%, range 6 tiles, energy cost 20, AP cost 1
- Targeting: Single target with LoS requirement, area radius 2 for AoE variants
- Success Calculation: Caster Psi 6 vs target Will 4 = 50% + 12% - 4% = 58% success chance
- Effect Application: 10 stun points applied, bypassing armor through psi damage type
- Integration: Feeds stun accumulation system, triggers wound/stun conversions

### Mind Control Scenario
- Ability Parameters: Base success 45%, Psi scaling 2%, range 8 tiles, energy cost 30, AP cost 2, duration 3 turns
- Targeting: Single enemy unit with LoS requirement
- Success Calculation: Caster Psi 8 vs target Will 6 = 45% + 16% - 6% = 55% success chance
- Effect Application: Target converts to caster control for 3 turns, can/cannot attack allies based on configuration
- Failure Risk: 20% chance of self-stun backlash for 1 turn

### Telekinesis Objective Denial
- Ability Parameters: Base success 55%, Psi scaling 2%, range 6 tiles, energy cost 25, AP cost 1
- Targeting: Mission-critical objective prop within range
- Success Calculation: Caster Psi 7 vs target resistance = 55% + 14% = 69% success chance
- Effect Application: Prop pushed 3 tiles out of objective zone, respecting obstruction rules
- Strategic Impact: Prevents objective completion, forces enemy repositioning

### Telepathy Reveal Operation
- Ability Parameters: Base success 95%, range 10 tiles, radius 3, energy cost 10, duration 5 turns
- Targeting: Visible tile as origin point, no LoF requirement
- Success Calculation: High base chance with minimal Psi scaling = 95% + Psi bonus
- Effect Application: Side-scoped reveal object created, showing hidden units and terrain
- Tactical Value: Provides reconnaissance without granting opponent visibility

### Ignite Area Denial
- Ability Parameters: Base success 40%, Psi scaling 1%, range 5 tiles, radius 1, energy cost 20
- Targeting: Flammable tile type with LoS requirement
- Success Calculation: Caster Psi 5 = 40% + 5% = 45% success chance
- Effect Application: Fire seeded at target location, propagates per smoke/fire rules
- Strategic Effect: Creates deterministic area-denial trap, forces pathing changes

### Psi Panic Induction
- Ability Parameters: Base success 60%, Psi scaling 1.5%, range 5 tiles, radius 2, energy cost 25
- Targeting: Enemy unit group with LoS requirement
- Success Calculation: Caster Psi 6 vs average Will 4 = 60% + 9% - 4% = 65% success chance
- Effect Application: Morale damage triggers Will checks, potential panic cascade
- Integration: Connects to morale system, panic triggers, and sanity mechanics

## Related Wiki Pages

- [Sanity.md](../battlescape/Sanity.md) - Psionics affects sanity.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Psionic actions.
- [AI Battlescape.md](../ai/Battlescape%20AI.md) - AI considers psionics.
- [Panic.md](../battlescape/Panic.md) - Psi panic induction.
- [Morale.md](../battlescape/Morale.md) - Psi affects morale.
- [Stats.md](../units/Stats.md) - Psi skill stat.
- [Research.md](../economy/Research.md) - Psionic research.
- [Equipment.md](../items/Equipment.md) - Psi equipment.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - LoS for psionics.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Psi accuracy.

## References to Existing Games and Mechanics

- X-COM series: Psionic abilities and psi combat.
- Fire Emblem series: Magic and spell systems.
- Dungeons & Dragons: Psychic spells and mind control.
- Warhammer 40k: Psychic powers.
- Mass Effect: Biotics and psionic abilities.
- Deus Ex: Psi powers.
- Silent Hill: Psychological horror with mental effects.
- Final Fantasy: Magic systems.

