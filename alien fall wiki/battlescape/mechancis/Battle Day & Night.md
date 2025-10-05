# Day and Night Battle System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Mission Time Assignment](#mission-time-assignment)
  - [Visibility and Detection Modifications](#visibility-and-detection-modifications)
  - [Equipment and Countermeasure Framework](#equipment-and-countermeasure-framework)
  - [System Integration and Interactions](#system-integration-and-interactions)
  - [User Interface and Feedback](#user-interface-and-feedback)
- [Examples](#examples)
  - [Flare Deployment Scenario](#flare-deployment-scenario)
  - [Flashlight Utilization](#flashlight-utilization)
  - [Night Vision Goggles Application](#night-vision-goggles-application)
  - [Thermal Goggles Deployment](#thermal-goggles-deployment)
  - [Night Cover Tactical Advantage](#night-cover-tactical-advantage)
  - [Coordinated Countermeasure Tactics](#coordinated-countermeasure-tactics)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Day and Night Battle System implements a binary time-of-day framework that deterministically modifies visibility and detection mechanics without introducing complex rendering or lighting systems. Missions carry a simple Day or Night flag that applies numeric modifiers to sight ranges, cover effectiveness, and detection capabilities, creating tactical asymmetry between illumination and darkness. The system emphasizes data-driven configuration and deterministic outcomes, with owner-scoped countermeasures like flares and night vision equipment providing tactical countermeasures.

This approach maintains gameplay clarity while creating meaningful strategic decisions around mission timing, equipment loadouts, and tactical positioning. All visibility modifications are numeric and auditable, supporting comprehensive provenance logging for balance analysis and reproducible testing.

## Mechanics

### Mission Time Assignment
Binary time-of-day determination for tactical context:
- Flag System: Missions assigned either Day or Night flag at generation time
- Default Rules: Player-launched missions default to Day, underground/alien interior missions default to Night
- Configurable Overrides: Mission templates can explicitly set time-of-day for specific scenarios
- No Gradations: Binary system without intermediate twilight or dusk states
- Deterministic Assignment: Time-of-day determined by mission generation parameters

### Visibility and Detection Modifications
Numeric adjustments to perception capabilities:
- Sight Range: Day/Night multipliers applied to unit vision ranges
- Cover Enhancement: Night increases effective cover values for concealment
- Sense Preservation: Omni-directional detection (hearing, motion) remains unchanged
- Fog Integration: Day/Night modifiers applied before fog calculations
- Detection Asymmetry: Different effects for attackers versus defenders

### Equipment and Countermeasure Framework
Tactical tools for overcoming time-of-day disadvantages:
- Stat Modifiers: Equipment provides numeric bonuses to sight, sense, or cover calculations
- Conditional Effects: Items can be day-only, night-only, or always active
- Reveal Objects: Flares create temporary illumination zones for deploying faction
- Personal Equipment: Flashlights, night vision, and thermal goggles provide individual bonuses
- Resource Management: Limited-use items and battery-powered equipment

### System Integration and Interactions
Coordinated effects with other tactical systems:
- Hazard Independence: Smoke, fire, and gas effects remain separate from time-of-day
- No Rendering Effects: Purely numeric gameplay differences without visual changes
- Mission Overrides: Specific missions can modify default time-of-day effects
- Deterministic Calculations: All modifiers applied with seeded random number generation
- Provenance Tracking: Complete audit trail of visibility decisions and equipment usage

### User Interface and Feedback
Player communication of time-of-day effects:
- Mission Preparation: Display effective sight, cover, and detection values during planning
- Equipment Tooltips: Show per-item modifiers and usage conditions
- Status Indicators: Visual feedback for active countermeasures and their effects
- Provenance Display: Optional debug information for visibility calculations
- Loadout Guidance: Recommendations for time-of-day appropriate equipment

## Examples

### Flare Deployment Scenario
Squad deploys flare in night mission to create temporary illumination zone:
- Equipment: Flare with 8-tile radius, 3-turn duration
- Effect: Creates reveal object restoring full sight (1.0 multiplier) within radius
- Scope: Affects deploying faction only, overrides night penalties locally
- Consumption: Single-use item removed from inventory after deployment
- Tactical Use: Clear chokepoints or secure landing zones temporarily

### Flashlight Utilization
Individual unit counters night vision penalties with personal illumination:
- Equipment: Flashlight providing 1.5× sight multiplier, night-only condition
- Effect: Increases personal sight range by 50% when activated during night missions
- Scope: Applies to line-of-sight calculations for equipped unit only
- UI Feedback: Shows effective sight range in unit status and movement previews
- Battery Consideration: Continuous drain requires tactical activation timing

### Night Vision Goggles Application
Advanced optical equipment for night operations:
- Equipment: NVG with 1.8× sight multiplier, night-only, battery-powered
- Effect: Increases personal sight range by 80% during night operations
- Scope: Unit-specific modifier with time-limited battery life
- Tactical Trade-off: Enhanced vision balanced against equipment maintenance needs
- Squad Coordination: One unit equipped for scouting while others conserve resources

### Thermal Goggles Deployment
Multi-environment optical superiority:
- Equipment: Thermal goggles with 2.0× sight multiplier, always active, smoke-piercing
- Effect: Doubles sight range and penetrates smoke-based concealment
- Scope: Functions in both day and night, reduces cover effectiveness by 10%
- Advanced Capability: Provides tactical advantage in obscured or mixed-visibility environments
- Resource Cost: Higher equipment cost balanced by versatility

### Night Cover Tactical Advantage
Environmental concealment enhancement:
- Scenario: Defender positioned behind cover during night mission
- Base Cover: 2.0 cover modifier (50% visibility reduction)
- Night Enhancement: 1.3× cover multiplier resulting in 2.6 effective cover
- Detection Impact: 65% visibility reduction instead of 50%
- Counterplay: Requires flares, night vision, or thermal equipment to neutralize
- Defensive Positioning: Night favors ambush and defensive tactics

### Coordinated Countermeasure Tactics
Multi-equipment squad approach to night operations:
- Squad Composition: Mixed equipment loadout with flares and night vision
- Flare Usage: Temporary 8-tile radius illumination to clear critical chokepoints
- NVG Usage: 1.8× sight multiplier for deeper scouting without full team exposure
- Combined Effect: Coordinated use of different countermeasures for mission success
- Resource Management: Balancing limited-use items with battery-powered equipment

## Related Wiki Pages

The Day and Night Battle System affects visibility and detection across battlescape:

- **Lighting & Fog of War.md**: Lighting mechanics modified by day/night conditions.
- **Line of sight.md**: Visibility ranges varying with time of day.
- **Action - Sneaking.md**: Sneaking enhanced at night with reduced detection.
- **Line of Fire.md**: Firing arcs affected by lighting and countermeasures.
- **Accuracy at Range.md**: Accuracy modifiers from lighting conditions.
- **Battle map.md**: Map illumination affected by time of day.
- **Mission objectives.md**: Missions specifying day/night affecting objectives.
- **World time.md** (geoscape/): Geoscape time determining battle conditions.
- **Items.md** (items/): Equipment providing countermeasures for day/night.
- **Battlescape AI.md** (ai/): AI adapting to visibility changes.

## References to Existing Games and Mechanics

The Day and Night Battle System draws from time-based tactics in games:

- **X-COM series (1994-2016)**: Night missions with flares and reduced visibility.
- **XCOM 2 (2016)**: Dynamic lighting with specialized night equipment.
- **Jagged Alliance series (1994-2014)**: Time of day affecting visibility and behavior.
- **Commandos series (1998-2006)**: Night ops with flashlights and stealth.
- **Silent Storm (2003)**: Turn-based tactics with lighting effects.
- **Descent: Freespace (1998)**: Space combat lighting and visibility.
- **Homeworld series (1999-2003)**: Strategic lighting in battles.
- **Battlefield series (2002-2021)**: Day/night cycles affecting gameplay.

