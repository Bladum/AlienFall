# Mission Salvage

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Salvage Processing Pipeline](#salvage-processing-pipeline)
  - [Unit Conversion System](#unit-conversion-system)
  - [Side-Specific Salvage Rules](#side-specific-salvage-rules)
  - [Tile and Environmental Salvage](#tile-and-environmental-salvage)
  - [Item and Equipment Handling](#item-and-equipment-handling)
  - [XP and Medal System](#xp-and-medal-system)
  - [Reputation and Strategic Effects](#reputation-and-strategic-effects)
  - [Loot Delivery and Storage](#loot-delivery-and-storage)
- [Examples](#examples)
  - [Successful UFO Crash Recovery](#successful-ufo-crash-recovery)
  - [Terror Mission with Civilian Casualties](#terror-mission-with-civilian-casualties)
  - [Partial Success Scenario](#partial-success-scenario)
  - [Base Defense with Allied Casualties](#base-defense-with-allied-casualties)
  - [Research Mission with Artifacts](#research-mission-with-artifacts)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Mission Salvage is the deterministic post-mission cleanup that converts tactical outcomes into strategic rewards and consequences. The system processes dead units, equipment, prisoners, and environmental salvage into recoverable resources with data-driven conversion rules. All transformations use seeded randomness for reproducible results across playtests and multiplayer sessions. Comprehensive provenance logging enables balance analysis and campaign progression tracking, with loot delivery to base storage and strategic effects applied through monthly reports.

## Mechanics

### Salvage Processing Pipeline
- Trigger Timing: Executes after mission end, objective evaluation, and cleanup (wounds applied, unconscious states set)
- Outcome-Based Rewards: Full, partial, or zero salvage based on mission success level and configuration
- Deterministic Conversion: Seeded rules ensure identical results for identical inputs and seeds
- Provenance Tracking: Complete audit trail of all salvage generation, processing, and strategic effects
- Data-Driven Rules: TOML/YAML-configured conversion rates, eligibility criteria, and outcome scaling

### Unit Conversion System
- Dead Units: Convert to corpse items with equipment salvage eligibility unless destroy_on_death flagged
- Unconscious Units: Transform to live_prisoner items with gear handling rules
- Panicked Survivors: Treated as unconscious for salvage purposes (live_prisoner conversion)
- Player Units: Special handling - no corpse salvage, equipment processed per item flags and destroy_on_death rules
- Destroy-on-Death Items: Removed from salvage pool regardless of unit status or side

### Side-Specific Salvage Rules
- Player Side: Dead units not salvageable; equipment handled by item-specific rules (salvage/return/ruin)
- Enemy Side: Bodies and equipment salvaged by default unless prohibited by item/mission flags
- Neutral Side: Only dead units produce salvage/corpses; panicked/stunned/unconscious neutrals not converted unless mission allows
- Allied Side: Follows neutral rules with mission-specific overrides for diplomatic considerations
- Faction Variations: Data-driven modifications per enemy faction and mission configuration

### Tile and Environmental Salvage
- Map Tile Resources: UFO components, fuel caches, embedded objects collected during cleanup pass
- Block Metadata: Salvage defined in Map Block tile configurations with deterministic processing
- Environmental Objects: Terrain-specific recoverable materials (alien alloys, elerium, scrap)
- Mission Integration: Salvage quantities tied to map generation seeds and tile metadata
- Deterministic Collection: Seeded processing ensures reproducible recovery across play sessions

### Item and Equipment Handling
- Inventory Salvage: Weapons, ammunition, addons, and unique loot eligibility based on salvageable flags
- Transient Objects: Spawned explosives, flares, deployables not salvageable (removed during cleanup)
- Item Flags: Salvageable, destroy-on-death, and return-to-base properties control processing
- Equipment Categories: Different handling rules for weapons, armor, consumables, and unique items
- Quality Preservation: Item condition affects salvage value, research potential, and strategic worth

### XP and Medal System
- Action Tracking: Kills, assists, objective contributions recorded during mission execution
- Medal Evaluation: Achievement checks run after cleanup but before XP calculation
- Base XP Awards: Data-driven values for tracked mission actions with provenance logging
- Medal Bonuses: Additional XP for achievement unlocks and exceptional performance
- Provenance Logging: Complete audit trail of XP sources, calculations, and medal triggers

### Reputation and Strategic Effects
- Fame Awards: Mission success and visible actions increase reputation with strategic consequences
- Score Changes: Economic and civilian impact affects strategic metrics and monthly reports
- Karma Adjustments: Moral choices and civilian casualty consequences for campaign morality
- Campaign Integration: Reputation deltas feed monthly reports and long-term progression
- Deterministic Application: Seeded calculations for reproducible strategic outcomes

### Loot Delivery and Storage
- Cargo Collection: Loot, corpses, prisoners, and craft collected by returning transports
- Base Delivery: All recovered objects delivered to selected base with immediate storage addition
- No Cargo Cap: Mission loot bypasses capacity limits for guaranteed delivery
- Overflow Handling: Base capacity issues resolved through auto-queue, transfer, sell, or fail policies
- Craft Integration: Returning craft added to base rosters with any carried salvage

## Examples

### Successful UFO Crash Recovery
- Enemy Crew: Killed or unconscious units converted to corpses and live_prisoner items
- UFO Hull Tiles: Alien alloys and elerium collected based on tile metadata and seeded processing
- Equipment Salvage: Enemy weapons and technology recovered per salvageable flags
- Prisoner Processing: Live aliens added to base holding cells with equipment handling
- Full Salvage: Complete recovery with all strategic effects and provenance tracking

### Terror Mission with Civilian Casualties
- Neutral Civilians: Dead civilians produce corpse items only; stunned civilians not converted
- Score Impact: Civilian deaths trigger negative score adjustments in strategic metrics
- Karma Effects: Mission outcome affects moral reputation and campaign progression
- Partial Salvage: Reduced recovery based on mission performance and civilian impact
- Strategic Consequences: Reputation penalties for incomplete objectives and collateral damage

### Partial Success Scenario
- Mission Configuration: Reduced salvage for objective failure with configurable scaling
- Item Recovery: Only debris yields scrap materials; prisoners excluded from capture
- Equipment Salvage: Limited to recoverable gear only with destroy_on_death enforcement
- Strategic Consequences: Reputation penalties and reduced strategic benefits
- Provenance Tracking: Full audit trail of reduced salvage for balance analysis

### Base Defense with Allied Casualties
- Allied Units: Dead allies produce salvage per neutral rules with diplomatic considerations
- Equipment Recovery: Allied weapons and gear returned to inventory or marked for return
- Reputation Impact: Allied losses affect diplomatic relations and faction relationships
- Karma Considerations: Treatment of allied forces influences morality and strategic standing
- Salvage Delivery: Recovered items returned to originating base with provenance logging

### Research Mission with Artifacts
- Specialized Salvage: Unique alien technology and research materials with enhanced value
- Provenance Tracking: Origin and recovery conditions logged for research integration
- Research Integration: Salvaged items unlock new research opportunities and tech trees
- Value Assessment: Rarity and condition affect strategic value and campaign progression
- Campaign Advancement: Artifacts advance technological development and strategic capabilities

## Related Wiki Pages

- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Salvage from objectives.
- [Items.md](../items/Items.md) - Salvaged items.
- [Economy.md](../economy/Economy.md) - Salvage value.
- [Research.md](../economy/Research.md) - Research from salvage.
- [Craft.md](../crafts/Craft.md) - Craft salvage.
- [UFO.md](../interception/UFO.md) - UFO salvage.
- [Units.md](../units/Units.md) - Unit recovery.
- [Base management.md](../basescape/Base%20management.md) - Base salvage.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic salvage.
- [Inventory.md](../items/Inventory.md) - Inventory salvage.

## References to Existing Games and Mechanics

- X-COM series: Salvage and recovery mechanics.
- Fallout series: Scavenging and loot.
- Fire Emblem series: Item recovery.
- Advance Wars: Property capture.
- Civilization series: Resource acquisition.
- Dungeons & Dragons: Treasure recovery.
- Total War series: Loot from battles.
- Commandos series: Objective recovery.

