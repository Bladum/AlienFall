# Action - Suppressive Fire

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Action Cost System](#action-cost-system)
  - [Targeting System](#targeting-system)
  - [Resolution System](#resolution-system)
  - [Suppression Meter and Thresholds](#suppression-meter-and-thresholds)
  - [System Interactions](#system-interactions)
  - [UI and Player Feedback](#ui-and-player-feedback)
- [Examples](#examples)
  - [Light Machine Gun Suppression](#light-machine-gun-suppression)
  - [Area Denial and Withdrawal](#area-denial-and-withdrawal)
  - [Morale Cascade](#morale-cascade)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Suppressive fire is a deterministic area-control action that converts spent AP into suppression points to reduce enemy mobility and accuracy or force them to seek cover without directly causing HP loss. The system is fully data-driven with configurable AP costs, area shapes, suppression thresholds, decay rates, and exposure weighting. Suppression interacts with morale, reaction fire, and movement to produce predictable cascades (Suppressed → Pinned → Broken), and seeded checks plus provenance logs enable reproducible, debuggable outcomes. Effects are temporary with clear recovery mechanics, enabling roles like support gunners and meaningful resource-allocation decisions.

## Mechanics

### Action Cost System
- AP Cost: Configurable per action (default 1 AP); actions may accept spending multiple AP in one volley
- Energy Cost: Configurable absolute value or percentage per AP (default 0)
- Cooldown/Charges: Optional per-weapon or per-ability cooldowns and charge limits
- All values authorable in data: Costs, cooldowns, and charges are fully data-driven

### Targeting System
- Targeting Modes: Single tile, cone, or area (same mode selection as weapon fire)
- Range Requirements: Must be within sight and allowed range
- Unit Targeting: When aimed at a unit, suppression applies directly to that unit
- Area Targeting: When aimed at an area, suppression apportions across units using seeded deterministic distribution weighted by exposure

### Resolution System
- Suppression Points Calculation: SuppressionPoints = baseSuppressionPerAP × APSpent × weaponSuppressionMultiplier × rangeFalloff × exposureFactor
- Meter Accumulation: Add SuppressionPoints to each affected unit's suppressionMeter (range 0..100)
- Deterministic Apportionment: Per-tile apportionment uses seeded offsets for reproducible outcomes
- Immediate Resource Consumption: AP/Energy consumed immediately; no HP changes by default
- Provenance Emission: Telemetry includes APSpent, weapon id, computed points, and seed offsets

### Suppression Meter and Thresholds
- Meter Decay: Suppression recovers by suppressionRecovery per turn (data-driven)
- Suppressed Threshold (≥25): Next turn AP -1, aim -10%
- Pinned Threshold (≥50): Next turn AP = Max(0, AP - 2), movement halved, restricted from heavy weapons
- Broken Threshold (≥75): Forced cover/mandatory retreat or automatic Will test (seeded); failure escalates to casualty/capture flow per morale rules
- All numeric knobs data-driven: Thresholds, effects, and recovery rates are configurable

### System Interactions
- Reaction Fire: Suppressed/pinned units have reduced reaction chance and accuracy
- Morale/Panic: High suppression triggers morale checks (seeded)
- Movement & Actions: Suppression blocks high-AP actions and reduces movement
- Cover & Terrain: Cover reduces incoming SuppressionPoints multiplicatively
- Decay and Recovery: suppressionRecovery and cross-system modifiers are data-driven

### UI and Player Feedback
- Preview System: Shows predicted SuppressionPoints for each affected unit and threshold crossings
- Visual Indicators: Units display suppressionMeter and current state
- Logs and Telemetry: Include provenance and fire events for monthly reports

## Examples

### Light Machine Gun Suppression
- Weapon: Light machine gun with baseSuppressionPerAP = 12
- Action: Player spends 2 AP
- Calculation: SuppressionPoints = 24 × weaponMult × rangeFactor
- Result: Crosses 25 threshold, target becomes Suppressed (-1 AP next turn, -10% aim)

### Area Denial and Withdrawal
- Scenario: Squad lays down suppressive fire into open corridor (area mode)
- Distribution: Suppression apportioned across three enemies by exposure weighting
- Effects: Two enemies reach Pinned threshold, must take cover
- Tactical Outcome: Player withdraws squad safely while enemies are suppressed

### Morale Cascade
- Scenario: Repeated suppression on defenders raises suppressionMeter toward 75
- Trigger: Broken threshold hit, seeded Will test triggers
- Cascade: Defender panics, causing neighbouring allies to suffer morale checks
- Result: Chained deterministic effects per morale system rules

## Related Wiki Pages

- [Morale.md](../battlescape/Morale.md) - Suppression impacting unit morale and triggering failures.
- [Panic.md](../battlescape/Panic.md) - High suppression causing panic responses.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Suppressive fire as an action with AP costs.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Suppression shots with accuracy calculations.
- [Action - Overwatch.md](../battlescape/Action%20-%20Overwatch.md) - Suppression interacting with overwatch.
- [Line of Fire.md](../battlescape/Line%20of%20Fire.md) - Valid suppression arcs and coverage.
- [Wounds.md](../battlescape/Wounds.md) - Suppression causing wounds or fatigue.
- [Battle side.md](../battlescape/Battle%20side.md) - Suppression effects differing by faction.
- [Action - Movement.md](../battlescape/Action%20-%20Movement.md) - Suppression reducing enemy mobility.
- [Concealment.md](../battlescape/Concealment.md) - Suppression forcing units into cover.
- [Energy.md](../units/Energy.md) - AP costs for suppression actions.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI responding to suppression threats.

## References to Existing Games and Mechanics

The Suppressive Fire Action System draws from suppression mechanics in games:

- **X-COM series (1994-2016)**: Suppression via overwatch and area denial.
- **XCOM 2 (2016)**: Advanced suppression with pod detection.
- **Jagged Alliance series (1994-2014)**: Suppression on morale in turn-based combat.
- **Fire Emblem series (1990-2023)**: Area control affecting unit effectiveness.
- **Advance Wars series (2001-2018)**: Indirect fire and area denial.
- **Civilization series (1991-2021)**: Bombardment and area effects.
- **Total War series (2000-2022)**: Suppression through missile fire.
- **Battlefield series (2002-2021)**: Suppression fire mechanics.

