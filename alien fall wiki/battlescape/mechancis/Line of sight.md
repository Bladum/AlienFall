# Line of Sight

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Visibility Resources and Budgets](#visibility-resources-and-budgets)
  - [Visibility Types and Separation](#visibility-types-and-separation)
  - [Visibility Calculation Algorithm](#visibility-calculation-algorithm)
  - [Occlusion and Blocking System](#occlusion-and-blocking-system)
  - [Team vs Unit Visibility Rules](#team-vs-unit-visibility-rules)
  - [Temporary Effects and Reveals](#temporary-effects-and-reveals)
  - [Equipment and Trait Integration](#equipment-and-trait-integration)
  - [Firing and Action Constraints](#firing-and-action-constraints)
- [Examples](#examples)
  - [Scout vs Heavy Comparison](#scout-vs-heavy-comparison)
  - [Fence Chain Occlusion](#fence-chain-occlusion)
  - [Flare Reveal Tactics](#flare-reveal-tactics)
  - [Motion Scanner Detection](#motion-scanner-detection)
  - [Artillery on Explored Terrain](#artillery-on-explored-terrain)
  - [Underground Mission Adaptation](#underground-mission-adaptation)
  - [Sensor Drone Integration](#sensor-drone-integration)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Line of Sight is a deterministic visibility model that determines perceivable tiles and entities for units and sides, separating personal unit sight from team union visibility that drives Fog-of-War. The system uses sight budgets, occlusion costs, and data-driven modifiers for day/night, equipment, and environmental effects. Personal sight governs facing, reactions, and action legality while team union provides authoritative map reveal. All calculations are seeded for deterministic outcomes and comprehensive provenance logging enables reproducible testing, balance tuning, and multiplayer synchronization.

## Mechanics

### Visibility Resources and Budgets
- Sight Budget: Unit's vision range defined by base sight with day/night and equipment modifiers
- Occlusion Costs: Semi-transparent tiles and hazards consume visibility budget progressively
- Sense Range: Omnidirectional detection for nearby entities independent of line-of-sight obstacles
- Environmental Modifiers: Smoke, fire, and terrain affect visibility calculations through increased costs
- Equipment Integration: Flashlights, night vision, and sensors modify effective ranges and detection capabilities

### Visibility Types and Separation
- Personal Unit Sight: Individual unit's visible set and facing cone for fine-grained perception and action validation
- Team Union Sight: Combined visibility from all friendly units, sensors, and reveal objects driving map state
- Fog-of-War States: Unexplored → Explored-dark → Visible transitions based on team union visibility
- Action Constraints: Personal sight governs firing legality, reaction triggers, and ability requirements

### Visibility Calculation Algorithm
- Effective Budget: Base sight modified by day/night, equipment, traits, and active items for current conditions
- Ray Projection: Visibility outward from unit position with optional facing considerations for directional sight
- Occlusion Accumulation: Each tile consumes budget based on material properties and environmental factors
- Threshold Evaluation: Tiles visible if cumulative occlusion cost ≤ effective sight budget
- Sense Application: Nearby detection independent of line-of-sight obstacles for early warning capabilities

### Occlusion and Blocking System
- Base Tile Costs: Open terrain = 1, semi-transparent = 2, smoke = 3, fire = 5, solid walls = block completely
- Material Factors: Tile-specific occlusion multipliers for realistic environmental representation
- Environmental Effects: Smoke and fire increase effective occlusion costs dynamically
- Cover Integration: Partial cover reduces detectability through increased occlusion multipliers
- Dynamic Updates: Movement and environmental changes trigger immediate visibility recalculation

### Team vs Unit Visibility Rules
- Team Union: Drives Fog-of-War and authoritative mission/map reveal through combined unit contributions
- Personal Sight: Controls facing, reactions, aim previews, and ability requirements for individual units
- Firing Exceptions: Configurable penalties for firing at team-visible but personally invisible targets
- Sensor Integration: Drones and base sensors contribute to team union visibility for enhanced reconnaissance

### Temporary Effects and Reveals
- Owner-Scoped Reveals: Flares create temporary visible zones for deploying side only, creating tactical corridors
- Flashlights/Headlamps: Set minimum effective sight for active unit without expanding team visibility
- Duration Limits: Reveal effects expire after configurable time periods to maintain tactical tension
- Side Restrictions: Reveal objects don't grant visibility to opposing teams, preserving asymmetric information

### Equipment and Trait Integration
- Night Vision: Increases effective sight during night missions through enhanced low-light capabilities
- Thermal Optics: Modifies occlusion calculations for heat-based detection independent of visual conditions
- Motion Scanners: Extend sense range for early warning detection of approaching threats
- Heavy Armor: May reduce sense capabilities or impose visibility penalties due to encumbrance
- Psionic Sensing: Alternative detection methods with unique occlusion rules for supernatural awareness

### Firing and Action Constraints
- Direct Fire Requirements: Generally requires target tile in personal line-of-sight for accurate targeting
- Indirect Weapons: May target explored-dark tiles with accuracy penalties for artillery-like capabilities
- Recon Aids: Allow firing at non-visible tiles with resource or accuracy costs for special circumstances
- Data-Driven Exceptions: All penalties and allowances configurable in mission data for flexible design

## Examples

### Scout vs Heavy Comparison
- Scout Unit: Day sight 18, night sight 9, looking down ruined street with open terrain
- Heavy Unit: Day sight 12, night sight 6, same position with same environmental conditions
- Road Tiles: Occlusion cost 1.0 (open terrain) allowing maximum visibility range
- Scout Visibility: Sees 18 tiles along road vs heavy's 12 tiles due to superior base sight
- Tactical Advantage: Scout detects threats first, enables ambush positioning and early warning

### Fence Chain Occlusion
- Thin Fences: Each with occlusion cost 2.0 (semi-transparent barriers)
- Unit Sight: Base day sight 20 tiles for clear conditions
- First Fence: Consumes 2 occlusion, leaving 18 remaining budget
- Second Fence: Consumes additional 2, leaving 16 remaining budget
- Visibility Limit: Stops at tile where cumulative cost would exceed remaining sight budget

### Flare Reveal Tactics
- Flare Deployment: Radius 4 tiles, duration 3 turns of illumination
- Owner Scope: Creates visible zone for deploying player only, maintaining enemy concealment
- Enemy Exposure: Units in radius exposed to direct fire for flare owner during effect duration
- Temporary Effect: Zone disappears after duration expires, requiring careful timing
- Strategic Use: Enables corridor clearing and tactical advances without permanent map compromise

### Motion Scanner Detection
- Scanner Range: +3 tiles to base sense range of 2, extending to 5 tiles total
- Effective Sense: 5 tiles omnidirectional detection independent of visual obstacles
- Smoke Blocking: Sense penetrates smoke that blocks line-of-sight for early threat identification
- Early Warning: Reveals approaching patrols before visual contact enables preparation
- UI Feedback: Shows presence detection without precise positioning for tactical decision making

### Artillery on Explored Terrain
- Target State: Explored-dark tile (previously seen, currently out of sight due to occlusion)
- Accuracy Penalty: -50% base accuracy for indirect fire without direct line-of-sight
- Fog-of-War Rules: Can target without current line-of-sight for suppression capabilities
- Tactical Use: Suppression fire or structure destruction in known but obscured areas
- Resource Cost: May require additional AP or special ammunition for indirect targeting

### Underground Mission Adaptation
- Environmental Modifier: Night-like sight penalties (0.5x base sight) simulating darkness
- No Day/Night Cycle: Fixed darkness conditions requiring constant illumination support
- Equipment Importance: Flashlights become critical for basic visibility and tactical operations
- Sense Reliance: Increased dependence on omnidirectional detection for threat awareness
- Tactical Shift: Emphasis on sound and motion detection over visual reconnaissance

### Sensor Drone Integration
- Drone Contribution: Adds to team union visibility revealing corridors ahead
- Team Visibility: Combined unit and sensor visibility for enhanced reconnaissance
- Tactical Planning: Squad can plan ambushes while drone remains exposed to enemy detection
- Risk-Reward: Enhanced visibility comes with potential sensor loss and enemy awareness
- Mission Support: Drones extend team sight range for strategic positioning

## Related Wiki Pages

Line of sight governs what units can see and affects many tactical systems:

- **Lighting & Fog of War.md**: Environmental conditions that modify line of sight ranges.
- **Concealment.md**: Stealth mechanics that depend on avoiding line of sight.
- **Action - Overwatch.md**: Overwatch triggers that require line of sight to enemies.
- **Action - Sneaking.md**: Sneaking effectiveness affected by line of sight detection.
- **Line of Fire.md**: Related calculations for firing that often use similar geometry.
- **Battle map.md**: Map exploration and fog of war revealed by line of sight.
- **Terrain Elevation.md**: Height differences that affect line of sight over obstacles.
- **Smoke & Fire.md**: Environmental effects that block or reduce line of sight.

## References to Existing Games and Mechanics

The Line of Sight system draws from visibility and exploration mechanics in strategy games:

- **X-COM series (1994-2016)**: Fog of war and unit vision ranges for exploration and combat.
- **XCOM 2 (2016)**: Advanced fog of war with concealment and squad sight sharing.
- **Civilization series (1991-2021)**: Exploration and fog of war revealing the map.
- **Fire Emblem series (1990-2023)**: Unit vision ranges and fog of war in battles.
- **Advance Wars series (2001-2018)**: Fog of war and unit sight ranges.
- **Jagged Alliance series (1994-2014)**: Detailed line of sight for combat and exploration.
- **Total War series (2000-2022)**: Line of sight affecting unit behavior and detection.

