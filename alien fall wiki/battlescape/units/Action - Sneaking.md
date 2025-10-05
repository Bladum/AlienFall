# Action - Sneaking

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Sneak State Management](#core-sneak-state-management)
  - [Movement and AP System](#movement-and-ap-system)
  - [Energy Management](#energy-management)
  - [Detection and Reaction System](#detection-and-reaction-system)
  - [Integration with Overwatch System](#integration-with-overwatch-system)
  - [UI and Preview System](#ui-and-preview-system)
  - [Equipment and Trait Integration](#equipment-and-trait-integration)
- [Examples](#examples)
  - [Scout Flanking Maneuver](#scout-flanking-maneuver)
  - [Building Infiltration](#building-infiltration)
  - [Sniper Positioning](#sniper-positioning)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Sneaking system provides a low-profile movement and stance mode that trades raw mobility and AP efficiency for substantially reduced detectability and lower chance of provoking reactions. This feature is data-driven with configurable AP conversion, movement scaling, and detection multipliers. All detection and trigger checks are mission-seeded for reproducible, debuggable outcomes. Sneak ties into cover, overwatch and concealment systems to reward deliberate positioning, pacing and ambush tactics while providing clear counters to avoid player frustration.

## Mechanics

### Core Sneak State Management
- Toggle System: Sneak is an on/off mode that players may enable for a unit before moving; it may be disabled mid-turn
- State Persistence: Disabling Sneak immediately restores normal movement, energy use and detection behavior for subsequent actions
- Unit Requirements: Units may require specific traits or abilities to enter sneak mode

### Movement and AP System
- AP Conversion: Each sneak move action costs 1 AP; while sneaking, 1 AP yields Speed ÷ 2 movement points (half normal movement per AP)
- Partial Moves: Engine deterministically trims planned path to longest prefix that fits available sneak movement
- Movement Modifiers: Sneak does not change terrain multipliers, diagonal modifiers, rotation costs, or other movement modifiers; those remain in effect and combine with the half-speed conversion

### Energy Management
- Energy Cost: Sneak movement has Energy cost = 0; other actions that normally consume Energy are unchanged while sneak is active
- Energy Efficiency: Provides clear energy savings for movement while maintaining normal energy costs for other actions

### Detection and Reaction System
- Detection Multipliers: Apply 0.5 multiplier to detection roll inputs and reaction-fire trigger checks for sneaking unit (50% reduced chance to be detected or provoke Overwatch)
- Multiplicative Effects: Multipliers are applied deterministically before any seeded RNG used by detection/reaction resolution
- Equipment Integration: Any active equipment or actions that independently modify detectability still apply and combine multiplicatively with the sneak multiplier

### Integration with Overwatch System
- Trigger Reduction: Reduces chance of triggering overwatch reactions by 50%
- Movement-Specific Modifiers: Even lower trigger chance (additional 20% reduction) for movement actions while sneaking
- Deterministic Resolution: All overwatch interactions maintain seeded randomness for reproducible outcomes

### UI and Preview System
- Sneak Preview: Shows expected movement per AP, projected Energy impact, and effective detection probability while sneaking
- Movement Preview: Displays path costs, AP requirements, and detection modifiers for planned sneak movements
- Toggle Feedback: Clear visual indicators of sneak state and immediate effects

### Equipment and Trait Integration
- Stealth Equipment: Specialized gear that provides additional detection reductions, movement penalties, and energy bonuses
- Trait Requirements: Units may require specific stealth traits to access sneak capabilities
- Modular Effects: Equipment effects stack multiplicatively with base sneak effects

## Examples

### Scout Flanking Maneuver
- Unit: Scout with Speed 8, 10 AP available
- Action Sequence: Enable sneak, execute 3 separate 1-AP moves
- Movement Results: Each move covers 4 tiles (8 Speed ÷ 2), total 12 tiles moved
- Energy Cost: 0 energy consumed for all movement
- Detection Chance: Base 80% detection chance reduced to 40% per move
- Overwatch Risk: 50% reduction in reaction trigger probability

### Building Infiltration
- Unit: Assault soldier with Speed 6, 8 AP available
- Scenario: Approach building entrance undetected
- Sneak Movement: 4 tiles per AP (6 Speed ÷ 2), using 2 AP to reach breach point
- Detection Modifier: 0.5 multiplier applied to all detection rolls during approach
- Transition: Disable sneak at breach point, restore normal movement for immediate combat actions
- Energy Savings: 6 energy points saved compared to normal movement

### Sniper Positioning
- Unit: Sniper with Speed 7, enhanced stealth trait (+30% detection reduction)
- Objective: Reach rooftop vantage point
- Movement Profile: 3.5 tiles per AP (7 Speed ÷ 2), using 3 AP for positioning
- Combined Modifiers: Base 0.5 × trait 0.7 = 0.35 effective detection multiplier
- Post-Positioning: Exit sneak mode to maintain full mobility for repositioning after shots
- Risk Assessment: 65% reduction in detection chance during movement phase

## Related Wiki Pages

- [Concealment.md](../battlescape/Concealment.md) - Stealth mechanics that combine with sneaking for reduced detection.
- [Action - Movement.md](../battlescape/Action%20-%20Movement.md) - Base movement system modified by sneaking for stealth.
- [Action - Overwatch.md](../battlescape/Action%20-%20Overwatch.md) - Sneaking reducing overwatch trigger chances.
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Environmental conditions affecting detection while sneaking.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Visibility requirements interacting with sneak detection.
- [Morale.md](../battlescape/Morale.md) - Morale effects on stealth behavior and panic.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Sneaking as an action mode with AP costs.
- [Traits.md](../units/Traits.md) - Stealth traits enhancing sneak capabilities.
- [Equipment.md](../items/Equipment.md) - Gear providing detection bonuses for sneaking.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI using sneaking for ambush tactics.

## References to Existing Games and Mechanics

The Sneaking system draws from stealth mechanics in tactical games:

- **X-COM series (1994-2016)**: Crouched movement reducing detection and overwatch risk.
- **Metal Gear Solid series (1987-2015)**: Stealth movement with noise and visibility management.
- **Thief series (1998-2014)**: Light and shadow-based stealth with movement penalties.
- **Deus Ex series (2000-2017)**: Crouched sneaking with detection meters and environmental interaction.
- **Splinter Cell series (2002-2013)**: Advanced stealth with light management and movement modes.
- **Hitman series (2000-2023)**: Disguise and sneaking mechanics with detection systems.
- **Dishonored series (2012-2017)**: Stealth movement with supernatural elements and detection.
- **Assassin's Creed series (2007-2023)**: High-profile/low-profile modes with detection cones.

