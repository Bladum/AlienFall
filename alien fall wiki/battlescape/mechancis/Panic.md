# Panic

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Panic Trigger System](#panic-trigger-system)
  - [Behavior Selection Framework](#behavior-selection-framework)
  - [Panic Cascade Mechanics](#panic-cascade-mechanics)
  - [Recovery Mechanisms](#recovery-mechanisms)
  - [Behavior-Specific Effects](#behavior-specific-effects)
  - [Integration Systems](#integration-systems)
- [Examples](#examples)
  - [Freeze Behavior Scenario](#freeze-behavior-scenario)
  - [Hunker Down Under Fire](#hunker-down-under-fire)
  - [Flee During Overrun](#flee-during-overrun)
  - [Berserk Friendly Fire Incident](#berserk-friendly-fire-incident)
  - [Cascade Chain Reaction](#cascade-chain-reaction)
  - [Recovery Through Leadership](#recovery-through-leadership)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Panic represents a severe tactical state triggered when a unit's in-mission morale reaches zero or below, causing temporary loss of player control. The panicked unit is governed by AI-controlled behaviors (freeze, hunker down, flee, berserk) selected from data-driven tables with seeded randomness for reproducible outcomes. Panic can cascade through nearby units, creating dramatic tactical moments while maintaining deterministic provenance logging for debugging and balance analysis. Recovery occurs through morale restoration or leadership abilities, with comprehensive integration across combat, morale, and UI systems.

## Mechanics

### Panic Trigger System
- Morale Threshold: Units enter panic immediately when morale ≤ 0
- Control Transfer: Player loses control while AI governs panicked units
- State Duration: Panic persists until morale exceeds recovery threshold
- Timeout Protection: Maximum panic duration prevents permanent loss of units
- Trigger Logging: Complete provenance tracking of panic initiation causes

### Behavior Selection Framework
- Data-Driven Behaviors: Configurable behavior tables with weights and conditions
- Canonical Behaviors: Freeze, hunker down, flee, and berserk with distinct tactical effects
- Situational Modifiers: Behavior weights adjusted based on cover, enemy proximity, wounds
- Deterministic Selection: Seeded random selection ensures reproducible outcomes
- Single Outcome Resolution: One behavior selected per panic turn, no mid-turn changes

### Panic Cascade Mechanics
- Proximity-Based Spread: Panic can trigger in nearby units within configurable radius
- Probability Calculation: Base cascade chance modified by distance, morale, and relationships
- Chain Reactions: Cascaded panic can trigger further cascades in adjacent units
- Relationship Modifiers: Allies more susceptible than enemies to panic spread
- Morale Influence: Units with lower morale have higher cascade susceptibility

### Recovery Mechanisms
- Morale Restoration: Raising morale above threshold ends panic state
- Leadership Abilities: Rally and similar abilities provide immediate recovery
- Will Test Success: Successful willpower tests can clear panic
- Timeout Recovery: Automatic recovery after maximum panic duration
- State Cleanup: All panic modifiers removed upon recovery

### Behavior-Specific Effects
- Freeze: Complete inaction for the turn, no movement or actions
- Hunker Down: Stationary defensive posture with accuracy penalties to attackers
- Flee: Movement toward random locations, often abandoning tactical positions
- Berserk: Aggressive attacks against nearest units, ignoring friendly fire restrictions

### Integration Systems
- Morale System: Direct triggers and recovery based on morale changes
- Combat System: Modified attack characteristics for panicked units
- Suppression System: Panic as extreme consequence of accumulated suppression
- Leadership System: Recovery abilities and aura effects on panic prevention
- UI System: Visual indicators and notifications for panic states

## Examples

### Freeze Behavior Scenario
- Situation: Trooper in doorway exposed to enemy fire
- Panic Trigger: Morale drops to -2 from sustained suppression
- Behavior Selection: Freeze selected (25% base weight, +40% surprise modifier = 35% effective)
- Tactical Effect: Unit immobile for entire turn, allowing 3 enemy units to advance 8 tiles closer
- Recovery: Nearby sergeant uses Rally ability next turn to restore morale to +1

### Hunker Down Under Fire
- Situation: Defender caught in open area during ambush
- Panic Trigger: Sudden morale drop from -1 to -3 after teammate death
- Behavior Selection: Hunker down selected (30% base weight, +50% poor cover modifier = 45% effective)
- Tactical Effect: Unit gains +20% defense bonus, reduces incoming accuracy by 15%
- Consequence: Cannot move or attack, forcing squad to compensate for defensive gap

### Flee During Overrun
- Situation: Isolated unit facing 4:1 numerical disadvantage
- Panic Trigger: Morale reaches -4 after losing 60% health
- Behavior Selection: Flee selected (25% base weight, +80% outnumbered modifier = 45% effective)
- Tactical Effect: Moves 7 tiles toward map edge, abandoning fortified position
- Squad Impact: Creates 12-tile gap in defensive line, exposing flank to enemy advance

### Berserk Friendly Fire Incident
- Situation: Wounded unit surrounded by mixed friendly/enemy forces
- Panic Trigger: Morale drops to -5 after critical injury
- Behavior Selection: Berserk selected (20% base weight, +60% wounded modifier = 32% effective)
- Tactical Effect: Attacks nearest unit (friendly soldier), +10% accuracy bonus hits for 45 damage
- Consequence: Friendly casualty forces squad withdrawal, mission objective compromised

### Cascade Chain Reaction
- Initial Trigger: Squad leader panics after base destruction
- Cascade Radius: 8-tile radius affects 3 nearby units
- Probability Calculation: Base 30% chance, distance modifiers (100%/75%/50%), morale factors (2.0x/1.5x/1.2x)
- Cascade Results: 2 of 3 units panic (65% and 78% rolls vs 60% and 45% thresholds)
- Chain Effect: Second panicking unit triggers cascade affecting 1 additional unit

### Recovery Through Leadership
- Panic Duration: Unit panicked for 3 turns, attempting flee and freeze behaviors
- Recovery Trigger: Sergeant moves adjacent and uses Rally ability
- Morale Restoration: Morale increases from -3 to +2, exceeding recovery threshold
- State Cleanup: All panic modifiers removed, defense bonuses cleared
- Turn Recovery: Unit regains player control at start of next turn

## Related Wiki Pages

- [Morale.md](../battlescape/Morale.md) - Panic triggered by low morale.
- [Sanity.md](../battlescape/Sanity.md) - Panic affects sanity.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Panic behaviors.
- [AI Battlescape.md](../ai/Battlescape%20AI.md) - AI panic behaviors.
- [Psionics.md](../battlescape/Psionics.md) - Psi panic induction.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Environmental panic.
- [Wounds.md](../battlescape/Wounds.md) - Wounds can cause panic.
- [Surrender.md](../battlescape/Surrender.md) - Panic leads to surrender.
- [Unconscious.md](../battlescape/Unconscious.md) - Panic can incapacitate.
- [Squad Autopromotion.md](../battlescape/Squad%20Autopromotion.md) - Leadership affects panic.

## References to Existing Games and Mechanics

- X-COM series: Panic mechanics and morale failure.
- Warhammer 40k: Morale tests and routing.
- Fire Emblem: Panic status and morale.
- Advance Wars: Unit breaking and retreat.
- Civilization series: City revolts and morale.
- Dungeons & Dragons: Morale checks.
- Total War series: Army morale and breaking.
- Commandos series: Stealth failure leading to panic.

