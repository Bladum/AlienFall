# Unit Actions

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
  - [Unit Action Components](#unit-action-components)
- [Mechanics](#mechanics)
  - [Action Point and Energy Management](#action-point-and-energy-management)
  - [Action Execution Pipeline](#action-execution-pipeline)
  - [Movement and Positioning Actions](#movement-and-positioning-actions)
  - [Combat and Offensive Actions](#combat-and-offensive-actions)
  - [Defensive and Reactive Actions](#defensive-and-reactive-actions)
  - [Reaction and Interrupt Systems](#reaction-and-interrupt-systems)
- [Examples](#examples)
  - [Weapon Use and Movement Sequencing](#weapon-use-and-movement-sequencing)
  - [Overwatch Scaling Investment](#overwatch-scaling-investment)
  - [Rotation Cost Calculation](#rotation-cost-calculation)
  - [Rest and Energy Gating](#rest-and-energy-gating)
  - [Cover/Crouch Usage](#cover/crouch-usage)
  - [Complex Tactical Sequencing](#complex-tactical-sequencing)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Unit Actions are the core set of commands a unit may perform in battle, consuming AP and sometimes Energy to define tactical budgets each turn. Actions include movement, shooting, defensive stances, abilities (grenades, medkits), psionics and reaction modes like Overwatch; their costs and effects are authored in data. The system supports fractional AP, deterministic resolution and explicit gating so players can plan and sequence strategies precisely. Designers tune action costs, energy interactions and ordering rules to create distinct playstyles and balance risk versus reward.

### Key Design Principles
- Action Point Economy: Resource-based system limiting unit capabilities per turn
- Energy Management: Secondary resource for special abilities and sustained actions
- Deterministic Resolution: Predictable outcomes using seeded random number generation
- Flexible Sequencing: Any order execution with resource validation
- Data-Driven Design: Configurable costs and effects through external data files
- Provenance Tracking: Comprehensive logging for debugging and balance analysis

### Unit Action Components
- Action Point System: Primary resource for most unit actions
- Energy System: Secondary resource for special abilities and sustained activities
- Movement Actions: Position changes with terrain and mode modifiers
- Combat Actions: Weapon usage, throwing, and special attacks
- Defensive Actions: Stance changes, overwatch, and cover usage
- Utility Actions: Rest, reload, and ability activation

## Mechanics

### Action Point and Energy Management
- Action Points (AP): Primary resource restored fully each turn, consumed immediately on action execution
- Energy: Secondary resource with slower regeneration, required for special abilities
- Fractional Costs: Support for partial AP usage and precise resource budgeting
- Resource Validation: Pre-action checking ensuring sufficient resources available
- Turn End Conditions: AP depletion or explicit rest action terminates unit turn
- Modifier Application: Wounds, morale, sanity, and status effects alter resource availability

### Action Execution Pipeline
- Resource Checking: Validation of AP and energy requirements before execution
- Requirement Validation: Unit state, equipment, and situational prerequisites
- Action Performance: Core logic execution with deterministic outcomes
- Cost Deduction: Immediate resource consumption on successful execution
- State Updates: Unit status modifications and effect application
- History Recording: Action logging for provenance and replay capabilities

### Movement and Positioning Actions
- Basic Movement: Position changes with distance-based AP costs
- Movement Modes: Walk, run, and sneak with different speed/cost tradeoffs
- Rotation: Facing changes consuming movement points
- Terrain Integration: Environmental modifiers affecting movement costs
- Path Validation: Collision detection and obstacle avoidance
- Mode Effects: Accuracy penalties, stealth bonuses, and energy costs

### Combat and Offensive Actions
- Weapon Fire: Primary combat action with AP costs and ammo consumption
- Throwing: Grenade and equipment deployment with arc calculations
- Special Abilities: Unique unit skills with energy requirements
- Reload: Weapon ammunition replenishment action
- Suppressive Fire: Area denial through sustained shooting
- Psionic Actions: Mental abilities with energy drain

### Defensive and Reactive Actions
- Overwatch: AP investment for reaction fire during enemy turns
- Crouch/Stance: Posture changes affecting defense and mobility
- Cover Usage: Environmental positioning for protection
- Rest: AP consumption for energy and morale recovery
- Reload: Weapon preparation for continued combat
- Ability Activation: Defensive special skills and enhancements

### Reaction and Interrupt Systems
- Overwatch Scaling: Reaction strength proportional to AP investment
- Trigger Detection: Enemy actions prompting reactive responses
- Reaction Resolution: Deterministic hit calculation with seeded RNG
- Resource Consumption: AP and ammo costs for reaction execution
- State Changes: Overwatch clearance after reaction or turn end
- Penalty Application: Accuracy modifiers for reactive fire

## Examples

### Weapon Use and Movement Sequencing
A player moves, then fires a weapon, then deploys a medkit as long as AP and Energy allow; AP is deducted immediately for each action in sequence.

### Overwatch Scaling Investment
If a unit has 4 AP and spends all 4 AP into Overwatch, it invests maximum reaction strength. If it spends 2 AP, reaction strength is proportionally reduced (for instance 50%), per configured scaling rules.

### Rotation Cost Calculation
Rotation represented as 1 movement-point. With Speed = 8 movement-points per AP, one 90° rotation costs 1 ÷ 8 = 0.125 AP.

### Rest and Energy Gating
If an ability requires 20 Energy and the unit has 15 CurrentEnergy, the ability is blocked or shown with a penalised variant until the unit rests or receives a supply action.

### Cover/Crouch Usage
Player spends 1 AP to crouch before an enemy turn; incoming shots apply the configured crouch accuracy modifier.

### Complex Tactical Sequencing
- Flanking Maneuver: Move to position, crouch for defense, overwatch for reaction fire
- Suppression and Advance: Suppressive fire to pin enemy, movement to new position
- Medical Support: Move to wounded ally, use medkit ability, overwatch for protection
- Grenade Setup: Move to position, throw grenade, immediate movement to safety
- Sustained Defense: Crouch in cover, overwatch investment, rest for energy recovery

## Related Wiki Pages

- [Movement.md](../battlescape/Movement.md) - Movement actions.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Accuracy for actions.
- [Grenades.md](../battlescape/Grenades.md) - Grenade actions.
- [Overwatch.md](../battlescape/Overwatch.md) - Overwatch actions.
- [Cover.md](../battlescape/Cover.md) - Cover actions.
- [Psionics.md](../battlescape/Psionics.md) - Psionic actions.
- [Medical.md](../battlescape/Medical.md) - Medical actions.
- [Throwing.md](../battlescape/Throwing.md) - Throwing actions.
- [Sneaking.md](../battlescape/Sneaking.md) - Sneaking actions.
- [Squad Autopromotion.md](../battlescape/Squad%20Autopromotion.md) - Actions for promoted units.

## References to Existing Games and Mechanics

- X-COM series: Action points and turn-based actions.
- Civilization series: Unit actions and movement.
- Fire Emblem: Action economy and sequencing.
- Advance Wars: Action points for units.
- Dungeons & Dragons: Action system in combat.
- Warhammer 40k: Action phases.
- Final Fantasy Tactics: Action points.
- Tactics Ogre: Turn-based actions.

