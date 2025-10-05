# Unit Energy System

> **📖 Master Reference:** For a comprehensive overview of energy mechanics across all game systems, see [Energy Systems](../core/Energy_Systems.md). This document focuses specifically on unit-level energy mechanics in tactical combat.

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Properties](#core-properties)
  - [Action Costs and Gating](#action-costs-and-gating)
  - [Consumption Categories](#consumption-categories)
  - [Replenishment and Resupply](#replenishment-and-resupply)
  - [Class and Equipment Interactions](#class-and-equipment-interactions)
  - [Damage and Status Effects](#damage-and-status-effects)
  - [Operational Rules](#operational-rules)
  - [UI and UX](#ui-and-ux)
- [Examples](#examples)
  - [Basic Regeneration](#basic-regeneration)
  - [Movement and Combat](#movement-and-combat)
  - [Sprint and Heavy Fire](#sprint-and-heavy-fire)
  - [Psionic Timing](#psionic-timing)
  - [Armor Tradeoffs](#armor-tradeoffs)
  - [Field Resupply](#field-resupply)
  - [Wound Consequences](#wound-consequences)
  - [Energy Buffers](#energy-buffers)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Energy serves as a per-unit resource system in Alien Fall that gates powered actions, energy-based equipment, and sustained abilities independently from Action Points. The system enables separate pricing of endurance and burst capabilities, encouraging multi-turn tactical planning and resource management.

Energy pools, regeneration rates, and consumption costs are fully data-driven and deterministic, supporting predictable gameplay, reliable testing, and comprehensive modding. The system promotes strategic decisions about when to use high-energy abilities and how to manage resource recovery.

## Mechanics

### Core Properties

Each unit has fundamental energy attributes that define their power capacity.

Energy Pool:
- MaxEnergy: Maximum energy capacity determining power ceiling
- CurrentEnergy: Current stored energy (always ≥ 0)
- Regeneration: Energy restored at end of turn (fixed amount or percentage)
- Deterministic Updates: All changes are predictable and reproducible

Regeneration Mechanics:
- End-of-Turn Restore: Automatic recovery after unit's turn completes
- Default Rate: 25% of MaxEnergy per turn (configurable)
- Seeded Randomness: Any variability uses named seeds for consistency
- Provenance Logging: All regeneration events recorded for debugging

### Action Costs and Gating

Actions consume energy with strict gating to prevent overuse.

Consumption System:
- Explicit Costs: Each action declares required energy amount
- Authoritative Check: TryConsumeEnergy() validates availability
- Consumption Timing: Energy deducted at action resolution
- Provenance Tracking: All consumption logged with context

Gating Rules:
- Hard Block: Actions blocked if CurrentEnergy < cost
- No Partial Use: Insufficient energy prevents action execution
- Penalty Options: Some actions allow reduced effects for partial energy
- UI Feedback: Clear indication of blocked actions and energy requirements

### Consumption Categories

Different action types have appropriate energy costs for balance.

Movement Energy:
- Standard Movement: Base energy cost per AP spent
- Sprint/Run Mode: Multiplied energy cost for enhanced speed
- Terrain Effects: Different surfaces may modify energy efficiency
- Mode Switching: Changing movement modes may have energy costs

Weapon Systems:
- Per Shot Costs: Fixed energy per weapon discharge
- Burst Multipliers: Additional energy for multi-shot modes
- Special Modes: Alternate firing modes have different costs
- Overheat Mechanics: Sustained fire may increase energy demands

Special Abilities:
- Psionic Powers: High single-use energy drains
- Active Skills: Sustained abilities consume energy per turn
- Ultimate Abilities: Powerful effects require significant energy
- Cooldown Management: Energy costs affect ability availability timing

Passive Systems:
- Equipment Upkeep: Powered gear consumes energy while active
- Shield Systems: Defensive fields drain energy continuously
- Stealth Devices: Concealment technology requires ongoing power
- Medical Systems: Healing devices may consume energy for operation

### Replenishment and Resupply

Multiple methods restore energy during missions.

Natural Regeneration:
- Turn-Based Recovery: Automatic restoration at turn end
- Percentage or Fixed: Configurable recovery amount
- Deterministic Timing: Recovery occurs after all actions complete
- No Carryover: Regeneration cannot exceed MaxEnergy

Active Recovery:
- Rest Action: Spend AP for immediate energy boost
- Strategic Tradeoff: Action opportunity cost for faster recovery
- Recovery Amount: Data-driven energy restoration from rest
- Turn Limitation: Rest ends the unit's turn

Field Resupply:
- Supply Units: Dedicated support soldiers provide energy transfer
- Supply Objects: Deployable generators and power sources
- Transfer Actions: Deterministic energy amounts transferred
- Capacity Limits: Suppliers have limited energy reserves

Interactive Elements:
- Power Nodes: Map features that restore energy when used
- Supply Crates: Deployable containers with energy reserves
- Generator Systems: Battlefield power sources for energy recovery
- Resupply Mechanics: All sources have deterministic output amounts

### Class and Equipment Interactions

Class roles and gear affect energy characteristics.

Class Modifications:
- Role-Based Pools: Different classes have appropriate MaxEnergy
- Regeneration Rates: Class-specific recovery speeds
- Efficiency Bonuses: Some classes use energy more efficiently
- Specialization Focus: Energy mechanics support class identities

Equipment Effects:
- Capacity Modifiers: Gear can increase or decrease MaxEnergy
- Regeneration Changes: Equipment may alter recovery rates
- Cost Reductions: Specialized gear reduces energy consumption
- Buffer Systems: Some items provide temporary energy reserves

Armor Tradeoffs:
- Heavy Armor: Increased MaxEnergy but reduced regeneration
- Light Armor: Decreased MaxEnergy but improved recovery
- Power Armor: Enhanced capacity with specialized energy systems
- Balance Design: Tradeoffs encourage different tactical approaches

### Damage and Status Effects

Combat and status effects can impact energy systems.

Direct Energy Damage:
- EMP Effects: Electromagnetic pulses drain CurrentEnergy
- Energy Weapons: Special weapons target energy reserves
- Status Suppression: Effects that prevent regeneration
- Deterministic Impact: All effects have predictable outcomes

Wound Consequences:
- Capacity Reduction: Injuries temporarily lower MaxEnergy
- Bleed Effects: Ongoing energy loss from severe wounds
- Recovery Delays: Wounds slow regeneration rates
- Stabilization Requirements: Medical attention needed to restore capacity

Stun Mechanics:
- Non-Lethal Options: Stun effects may target energy instead of HP
- Temporary Disable: Energy drain prevents action execution
- Recovery Time: Deterministic return to normal function
- Strategic Choice: Non-lethal takedown opportunities

### Operational Rules

Energy management follows strict deterministic rules.

Arithmetic Precision:
- Integer Math: Prefer whole number calculations for predictability
- Exact Accounting: No rounding errors in energy calculations
- Deterministic Updates: Same inputs always produce same results
- Provenance Tracking: All changes logged with full context

API Functions:
- TryConsumeEnergy(): Validates and deducts energy costs
- ApplyEnergyDelta(): Modifies energy with reason tracking
- SupplyEnergy(): Transfers energy between units
- Event Hooks: Notifications for energy state changes

### UI and UX

Clear energy information supports tactical decision-making.

Display Elements:
- Current/Max Values: Always visible energy pool status
- Projected Values: Energy after planned actions and regeneration
- Cost Preview: Energy requirements shown before action confirmation
- Regeneration Timing: End-of-turn recovery clearly indicated

Feedback Systems:
- Block Reasons: Clear explanation when actions are prevented
- Resupply Opportunities: Highlight available energy recovery options
- Provenance Links: Debug access to energy transaction history
- Warning Systems: Alerts for low energy states

## Examples

### Basic Regeneration

Standard energy recovery over multiple turns:

- Unit Profile: MaxEnergy 8, regeneration 25% (2 energy per turn)
- Turn 1: Spend 6 energy on actions, end with 2 energy
- End of Turn 1: Regenerate +2, total becomes 4 energy
- Turn 2: Can perform moderate actions with 4 energy base
- Planning: Player can calculate exact energy availability for next turn

### Movement and Combat

Combined AP and energy costs for tactical movement:

- Energy Rate: 1 energy per AP spent on movement
- Action Sequence: Move 2 AP (2 energy) + fire 2 pistol shots (2 × 6 = 12 energy)
- Total Cost: 14 energy consumed in one turn
- Regeneration: +2 energy at turn end (25% of 8)
- Net Result: Significant energy investment requires recovery planning

### Sprint and Heavy Fire

High-energy tactical options with recovery considerations:

- Sprint Cost: 3 energy per AP (3× normal rate)
- Action Combo: Sprint 2 AP (6 energy) + Plasma Cannon shot (25 energy)
- Total Drain: 31 energy consumed
- Recovery Rate: 25 energy per turn regeneration
- Limitation: Cannot perform another 30+ energy action next turn without resupply

### Psionic Timing

Strategic timing of powerful psionic abilities:

- Psionic Profile: MaxEnergy 120, regeneration 30 per turn
- Ability Costs: Mind control (40 energy), Psi blast (30 energy)
- Single Turn Limit: Can use one major ability per turn
- Multi-Turn Planning: Requires rest or resupply for multiple heavy psionics
- Supply Windows: Coordinated abilities enabled by field resupply

### Armor Tradeoffs

Energy characteristics of different armor types:

- Heavy Armor: +30 MaxEnergy but -25% regeneration rate
- Light Armor: -10 MaxEnergy but +50% regeneration rate
- Tactical Choice: Heavy armor sustains more shots but recovers slower
- Role Support: Different armor types support different playstyles
- Balance Design: Tradeoffs encourage specialization and team composition

### Field Resupply

Battlefield energy recovery through support units:

- Supply Unit: Carries 200 energy reserve, transfers 40 per action
- Resupply Operation: Transfer to 3 units (3 × 40 = 120 energy total)
- Tactical Enablement: Allows coordinated high-energy abilities
- Logistics Planning: Supply units must retreat for refill after depletion
- Strategic Element: Resupply positioning becomes important tactical decision

### Wound Consequences

Injury effects on energy systems:

- Major Wound: -30 MaxEnergy for 5 turns + 5 energy bleed per turn
- Immediate Impact: Reduced capacity limits heavy action capability
- Ongoing Drain: Bleed prevents effective regeneration
- Recovery Requirement: Medical stabilization needed to restore normal function
- Tactical Limitation: Wounded units become less effective in energy-intensive roles

### Energy Buffers

Temporary energy reserves from special equipment:

- Buffer Item: Provides 20 energy buffer absorbed before main pool
- Consumption Order: Buffer depleted first, then main energy pool
- UI Display: Separate indicators for buffer and main energy
- Strategic Value: Protects main energy for critical abilities
- Recharge Mechanics: Buffer regeneration follows same deterministic rules

## Related Wiki Pages

### Master References
- **[Energy Systems (Core)](../core/Energy_Systems.md)** - Complete energy system overview across all game layers

### Related Systems
- [Action points.md](../units/Action%20points.md) - Action point resource management system
- [Craft Energy](../crafts/Energy.md) - Operational-layer energy mechanics for air combat
- [Psionics.md](../battlescape/Psionics.md) - Energy-based psionic abilities
- [Classes.md](../units/Classes.md) - Class-specific energy pools and regeneration
- [Items.md](../items/Items.md) - Energy weapons and equipment requirements
- [Wounds.md](../battlescape/Wounds.md) - Energy drain from injuries and wounds
- [Morale.md](../battlescape/Morale.md) - Energy effects on unit morale and performance
- [Unit actions.md](../battlescape/Unit%20actions.md) - Energy costs for various actions
- [Mission salvage.md](../battlescape/Mission%20salvage.md) - Energy recovery and resupply mechanics
- [Transfers.md](../economy/Transfers.md) - Energy supply logistics and transfers
- [Research tree.md](../economy/Research%20tree.md) - Energy technology and enhancement research

## References to Existing Games and Mechanics

- **Dark Souls Series**: Stamina system for actions and blocking
- **The Legend of Zelda: Breath of the Wild**: Stamina wheel for climbing and combat
- **Monster Hunter Series**: Stamina management for hunting and combat
- **Sekiro: Shadows Die Twice**: Posture system as energy-based defense
- **Bloodborne**: Quicksilver bullet system for special abilities
- **Nioh Series**: Ki system for supernatural abilities
- **For Honor**: Stamina bars for attacks and blocks
- **Kingdom Hearts Series**: MP system for magic and special abilities
- **Final Fantasy Series**: MP system for spells and abilities
- **X-COM Series**: Energy systems in various mods and expansions

