# Lighting & Fog of War

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Visibility State Model](#visibility-state-model)
  - [Reveal and Detection Systems](#reveal-and-detection-systems)
  - [Day/Night Integration](#day/night-integration)
  - [Environmental Effects](#environmental-effects)
  - [Deterministic Framework](#deterministic-framework)
- [Examples](#examples)
  - [Night Mission Reconnaissance](#night-mission-reconnaissance)
  - [Flare Illumination Tactics](#flare-illumination-tactics)
  - [Smoke and Visibility Interaction](#smoke-and-visibility-interaction)
  - [Day/Night Equipment Comparison](#day/night-equipment-comparison)
  - [Sense-Only Detection](#sense-only-detection)
  - [Fire vs Visibility Scenario](#fire-vs-visibility-scenario)
  - [Tactical Corridor Opening](#tactical-corridor-opening)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Lighting and Fog of War form a deterministic visibility framework that manages unexplored tile concealment and applies numeric sight/sense modifiers based on mission time-of-day and owner-scoped reveal devices. The system uses three visibility states (unexplored, explored-dark, visible) with line-of-sight transitions and omnidirectional sense detection. Designers tune reveal radii, durations, and night penalties in data for predictable, auditable illumination behavior. All visibility calculations are seeded for reproducible outcomes and comprehensive provenance tracking enables debugging and multiplayer synchronization.

## Mechanics

### Visibility State Model
- Unexplored: Completely hidden tiles with no prior player information about terrain or occupants
- Explored-Dark: Previously seen terrain known but currently outside line-of-sight; enemy units and dynamic objects hidden while terrain remains visible
- Visible: Currently within friendly unit's line-of-sight; all units and objects fully revealed
- State Transitions: Movement and line-of-sight changes drive automatic state progression from unexplored to explored-dark to visible

### Reveal and Detection Systems
- Line-of-Sight Reveals: Friendly unit movement automatically reveals tiles within sight radius, transitioning states appropriately
- Sense Radius: Omnidirectional detection range for nearby enemies without direct line-of-sight, providing alerts without full position information
- Reveal Combination: Sight and sense radii combine according to configurable rules for comprehensive detection coverage
- Owner-Scoped Illumination: Flares, flashlights, and other items modify visibility for owning player only, creating tactical illumination corridors

### Day/Night Integration
- Mission Flag: Binary Day/Night flag determines base sight/sense modifiers through configurable multipliers
- Numeric Modifiers: Day increases sight radius; Night reduces it through data-driven penalty multipliers
- No Visual Effects: Day/Night affects only gameplay calculations, not rendering or global visual presentation
- Equipment Integration: Night-vision, thermal goggles, and countermeasures modify base modifiers for specialized capabilities

### Environmental Effects
- Smoke Occlusion: Increases effective occlusion costs, reducing sight calculations and creating concealment opportunities
- Fire Hazards: Damage and morale effects without visibility modifications; fire does not reveal tiles or clear fog of war
- No Cross-Team Illumination: Reveal sources affect only owning side; opposing teams maintain their own visibility states
- Hazard Independence: Environmental effects remain separate from visibility state management to avoid unintended reveals

### Deterministic Framework
- Seeded Calculations: All visibility modifiers and reveal events use mission seeds for reproducible outcomes
- Provenance Logging: Complete tracking of reveal events, modifier applications, and state changes for debugging and analysis
- Preview Capability: Mission preparation shows effective sight/sense values and illumination effects for strategic planning
- Multiplayer Synchronization: Identical seeds produce identical visibility outcomes across all players

## Examples

### Night Mission Reconnaissance
- Unit Sight Radius: 10 tiles (after 0.7x night modifier)
- Sense Radius: 3 tiles omnidirectional
- Flashlight Deployment: +5 tile illumination radius for 4 turns
- Tactical Effect: Temporary corridor of visibility for player while maintaining enemy concealment in surrounding areas

### Flare Illumination Tactics
- Flare Radius: 8 tiles around deployment point
- Duration: 3 turns before burnout
- Scope: Affects only deploying player's visibility
- Strategic Use: Opening visibility corridors for squad advancement without alerting enemies or granting them visibility

### Smoke and Visibility Interaction
- Smoke Cloud: 4-tile radius with 2.0x occlusion multiplier
- Sight Reduction: Effective sight radius reduced by 50% through smoke-affected areas
- Counterplay: Flashlights or flares can partially mitigate smoke effects by providing alternative illumination
- Combined Tactics: Smoke for concealment plus selective illumination for key positions requiring careful resource management

### Day/Night Equipment Comparison
- Day Mission: Base sight 12 tiles, no modifiers needed for standard operations
- Night Mission: Base sight 8 tiles (0.67x modifier) requiring illumination support
- Night Vision Goggles: +4 tile bonus, effective sight 12 tiles matching day conditions
- Thermal Goggles: +6 tiles, ignores smoke occlusion entirely for superior low-visibility performance

### Sense-Only Detection
- Unexplored Building: Outside sight range but within 3-tile sense radius
- Detection Result: Enemy presence revealed without specific positions or unit identification
- Alert Trigger: Causes enemy patrol adjustments and increased vigilance without full map reveal
- Investigation Required: Player must advance to gain line-of-sight for complete visibility and targeting information

### Fire vs Visibility Scenario
- Burning Building: Spreading fire inflicts damage and morale penalties on nearby units
- Visibility Impact: No tile revelation or fog of war clearing; fire remains a hazard without illumination benefits
- Smoke Generation: Associated smoke increases occlusion, further reducing visibility in affected areas
- Tactical Consideration: Fire creates damage zones but doesn't compromise concealment or reveal hidden positions

### Tactical Corridor Opening
- Night Advancement: Squad advances toward objective using flares to temporarily open visibility corridors
- Enemy Awareness: Illuminated areas remain hidden from enemy teams unless they have their own detection methods
- Resource Management: Flares provide temporary windows of opportunity requiring careful timing and positioning
- Stealth Balance: Illumination tools create tactical opportunities while maintaining overall mission concealment

## Related Wiki Pages

Lighting and fog of war affect visibility and tactical decisions across multiple systems:

- **Battle Day & Night.md**: Time of day that sets base lighting conditions.
- **Line of sight.md**: Visibility calculations that lighting modifies.
- **Concealment.md**: Stealth mechanics affected by lighting levels.
- **Action - Sneaking.md**: Sneaking effectiveness that depends on lighting.
- **Accuracy at Range.md**: Accuracy penalties from poor lighting conditions.
- **Smoke & Fire.md**: Environmental effects that create fog and obscurants.
- **Action - Overwatch.md**: Detection ranges affected by lighting.
- **Battle map.md**: Map illumination and shadow casting.

## References to Existing Games and Mechanics

The Lighting & Fog of War system draws from visibility mechanics in tactical and strategy games:

- **X-COM series (1994-2016)**: Fog of war and lighting effects on detection and movement.
- **XCOM 2 (2016)**: Advanced fog of war with concealment and lighting mechanics.
- **Jagged Alliance series (1994-2014)**: Line of sight and lighting affecting combat.
- **Fire Emblem series (1990-2023)**: Fog of war and visibility in tactical battles.
- **Advance Wars series (2001-2018)**: Fog of war mechanics and unit visibility.
- **Civilization series (1991-2021)**: Fog of war revealing explored areas.
- **Total War series (2000-2022)**: Line of sight and lighting in battles.

