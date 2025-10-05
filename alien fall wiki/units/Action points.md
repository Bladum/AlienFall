# Action Points

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [AP Defaults and Modifiers](#ap-defaults-and-modifiers)
  - [Floating Point Accounting](#floating-point-accounting)
  - [AP Refresh and Resource Interaction](#ap-refresh-and-resource-interaction)
  - [Movement and Movement Modes](#movement-and-movement-modes)
  - [Overwatch, Rest, and Scaled Effects](#overwatch,-rest,-and-scaled-effects)
  - [UI and Determinism](#ui-and-determinism)
  - [Edge Behaviors](#edge-behaviors)
- [Examples](#examples)
  - [Action Cost Table](#action-cost-table)
  - [Movement and Fire Scenario](#movement-and-fire-scenario)
  - [Overwatch Investment Scenario](#overwatch-investment-scenario)
  - [Movement Trimming Scenario](#movement-trimming-scenario)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Action Points (AP) serve as the per-turn budget system in Alien Fall's tactical combat, determining what actions a unit can perform including movement, attacks, and special abilities. The AP system enables meaningful sequencing choices and tempo control while maintaining deterministic behavior through data-driven costs and fractional accounting.

AP works in conjunction with the Energy system, where AP controls action eligibility and Energy governs action strength and sustainability. All AP mechanics are designed to be moddable and tunable without code changes.

## Mechanics

### AP Defaults and Modifiers

Each unit receives a base AP allotment at the start of their turn, modified by various factors.

Base AP Values:
- Default AP: Data-driven per unit (typically 4 AP)
- Class Variations: Mobile units may receive higher base AP
- Trait Modifiers: Certain traits can increase or decrease base AP
- Morale Effects: Low morale reduces available AP
- Wound Penalties: Injuries decrease AP allotment
- Buff/Debuff Effects: Temporary modifiers from abilities or equipment

Modifier Sources:
- Sanity Effects: Mental state impacts AP efficiency
- Equipment Bonuses: Certain gear provides AP modifiers
- Environmental Factors: Terrain or weather effects
- Status Effects: Poison, stun, or other conditions

### Floating Point Accounting

AP uses precise fractional accounting to enable fine-grained tactical control.

Fractional Costs:
- Exact Summation: All costs are summed precisely without rounding
- Small Actions: Fine movements and rotations use fractional AP costs
- Partial Actions: Units can perform actions costing less than 1 AP
- Accumulation: Fractional costs accumulate exactly across multiple actions

Accounting Rules:
- No Rounding: All calculations maintain full precision
- Minimum Costs: Some actions have minimum fractional AP requirements
- Cost Scaling: Certain effects scale with invested AP amounts
- Resource Tracking: Precise AP accounting enables complex action combinations

### AP Refresh and Resource Interaction

AP refreshes predictably while interacting with other resource systems.

Turn Refresh:
- Full Restoration: AP returns to maximum at the start of each unit's turn
- Timing: Refresh occurs before any actions on the unit's turn
- Consistency: Refresh amount is always the modified maximum
- No Carryover: AP cannot be saved between turns

Resource Interactions:
- Energy Costs: Many actions consume both AP and Energy
- Dual Display: UI shows both AP and Energy costs before action confirmation
- Independent Systems: AP and Energy have separate refresh mechanics
- Combined Actions: Some actions require both resources simultaneously

### Movement and Movement Modes

Movement consumes AP with different efficiency based on movement mode.

Base Movement:
- AP to Distance: Data-driven conversion rate (AP per movement point)
- Path Planning: Movement paths calculated against available AP
- Deterministic Trimming: Excess movement automatically trimmed to fit AP
- Cost Display: UI shows exact AP cost for planned movement

Movement Modes:
- Standard Movement: Baseline AP efficiency and Energy cost
- Sneak Mode: Higher AP cost per distance, reduced Energy usage, lower detection
- Run Mode: Lower AP cost per distance, higher Energy usage, increased detection
- Special Modes: Class-specific movement options with unique AP/Energy trade-offs

### Overwatch, Rest, and Scaled Effects

Certain actions consume remaining AP or scale with AP investment.

Overwatch Mechanics:
- AP Investment: Consumes remaining AP to establish overwatch
- Strength Scaling: Overwatch effectiveness proportional to AP invested
- Energy Trigger: Energy consumed only when overwatch activates
- Turn Consumption: Overwatch ends the unit's turn

Rest Mechanics:
- AP Consumption: Uses remaining AP for the turn
- Energy Restoration: Data-driven Energy recovery based on AP invested
- Turn End: Rest always ends the unit's turn
- Strategic Choice: Balance between immediate Energy recovery and lost actions

Scaled Effects:
- Proportional Scaling: Effect strength varies with AP investment
- Minimum Thresholds: Some effects require minimum AP commitment
- Cost Efficiency: Higher AP investment may provide diminishing returns
- Predictable Scaling: All scaling formulas are deterministic and data-driven

### UI and Determinism

The user interface provides clear AP information with deterministic behavior.

Pre-Action Display:
- Cost Preview: Shows AP and Energy costs before action confirmation
- Balance Projection: Displays resulting AP/Energy after action
- Movement Preview: Shows achievable distance with current AP
- Effect Preview: Displays scaled effect strength for invested AP

Deterministic Behavior:
- Predictable Costs: All AP costs are data-driven and consistent
- No Hidden Rounding: All calculations maintain full precision
- Reproducible Results: Same inputs always produce same AP consumption
- Clear Feedback: UI explains all AP transactions and limitations

### Edge Behaviors

Special cases and fine-grained AP interactions.

Fractional Actions:
- Rotation Costs: Small AP costs for unit facing changes (e.g., 0.125 AP per 90°)
- Fine Adjustments: Precise positioning using fractional AP
- Micro-Actions: Very small actions enabled by fractional accounting
- Accumulative Precision: Multiple small actions sum exactly

Complex Actions:
- Stance Changes: Crouching, standing, or special stances have AP costs
- Item Usage: Medical items, grenades, and equipment have AP costs
- Interactive Elements: Opening doors, using terminals, etc.
- Combined Actions: Movement + attack sequences with precise AP tracking

## Examples

### Action Cost Table

| Action | AP Cost | Energy Cost | Notes |
|--------|---------|-------------|-------|
| Fire Pistol | 1.0 | 6 | Basic firearm action |
| Fire Rifle | 2.0 | 12 | Standard assault weapon |
| Throw Grenade | 2.0 | 0 | No Energy cost for explosives |
| Fire Sniper Rifle | 3.0 | 25 | High precision, high Energy |
| Fire Heavy Machine Gun | 4.0 | 30 | Full turn action |
| Use Medikit | 2.0 | 0-10 | Variable Energy based on item |
| Enter/Exit Crouch | 1.0 | 0 | Stance change |
| 90° Rotation | 0.125 | 0 | Fine positioning |
| Full AP Overwatch | Remaining AP | Weapon Energy on trigger | Reserves full remaining AP |
| Rest with Remaining AP | Remaining AP | Restores Energy | Energy amount data-driven |

### Movement and Fire Scenario

A soldier with 4 AP and standard movement conversion (2 movement points per AP) plans to move 10 points and fire:

- Movement Planning: 10 movement points would cost 5 AP (10 ÷ 2)
- AP Limitation: Only 4 AP available, so movement trimmed to 8 points
- AP Consumption: 4 AP used for movement, 0 AP remaining
- Fire Action: Cannot fire due to insufficient AP
- Alternative: Move 4 points (2 AP), fire pistol (1 AP), 1 AP remaining for rotation

### Overwatch Investment Scenario

A soldier with 3.5 AP remaining considers overwatch options:

- Full Investment: Use all 3.5 AP for overwatch (maximum strength)
- Partial Investment: Use 1.75 AP for overwatch (half strength)
- Strategic Choice: Full investment provides stronger reactions but ends turn immediately
- Energy Trigger: Energy consumed only if overwatch activates during enemy turn
- Effect Scaling: Overwatch accuracy and damage scale with AP investment

### Movement Trimming Scenario

Planning a complex movement path exceeding available AP:

- Path Planning: 30 movement point path planned through difficult terrain
- AP Conversion: Unit converts AP to movement at 2:1 ratio (2 points per AP)
- Available Movement: 4 AP × 2 = 8 movement points available
- Deterministic Trimming: Engine trims path to first 8 movement points
- Exact Consumption: 4 AP consumed, path reaches 8 points exactly
- UI Feedback: Clear indication of trimmed path and exact AP usage

## Related Wiki Pages

- [Unit actions.md](../battlescape/Unit%20actions.md) - Action costs in AP.
- [Energy.md](../units/Energy.md) - Energy system interaction.
- [Stats.md](../units/Stats.md) - Stat modifiers for AP.
- [Movement.md](../battlescape/Movement.md) - Movement AP costs.
- [Overwatch.md](../battlescape/Overwatch.md) - Overwatch AP investment.
- [Classes.md](../units/Classes.md) - Class-specific AP.
- [Traits.md](../units/Traits.md) - Trait AP modifiers.
- [Morale.md](../battlescape/Morale.md) - Morale AP effects.
- [Wounds.md](../battlescape/Wounds.md) - Wound AP penalties.

## Master References

📖 **For comprehensive Action Economy documentation, see:**
- **[Action Economy Master Document](../core/Action_Economy.md)** - Complete AP system across all game layers (Tactical, Operational, Strategic)
- **[Time Systems](../core/Time_Systems.md)** - Time scale conversions and turn structure

This document focuses on unit-level tactical Action Points. For the broader context including:
- Operational action points (Air Combat 4 AP per 30-second round)
- Strategic time-based actions (Geoscape 5-minute ticks)
- AP equivalence and conversion formulas
- Complete action economy design philosophy

Please refer to the master Action Economy document linked above.

## References to Existing Games and Mechanics

- X-COM series: Time units and action points.
- Fire Emblem: Turn-based action economy.
- Advance Wars: Action points for unit commands.
- Final Fantasy Tactics: Job action system.
- Disgaea: Turn-based action points.
- Into the Breach: Mech action points.
- XCOM 2: Action point management.
- Civilization series: Movement point system.

