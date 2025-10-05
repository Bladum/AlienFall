# Special Items

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Item Categories and Types](#item-categories-and-types)
  - [Action Costs and Gating](#action-costs-and-gating)
  - [Motion Scanner](#motion-scanner)
  - [Medikit](#medikit)
  - [Flare](#flare)
  - [Flashlight](#flashlight)
  - [Camouflage](#camouflage)
  - [Deterministic Behavior](#deterministic-behavior)
- [Examples](#examples)
  - [Motion Scanner Usage](#motion-scanner-usage)
  - [Medikit Healing](#medikit-healing)
  - [Flare Deployment](#flare-deployment)
  - [Flashlight Operation](#flashlight-operation)
  - [Camouflage Tactics](#camouflage-tactics)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Special items represent unique, high-impact equipment that provides tactical advantages and narrative moments in Alien Fall. These rare artifacts create windows of player power through detection capabilities, healing support, illumination tools, and stealth enhancements. Each item balances clear tactical benefits with resource costs, cooldowns, and usage restrictions to maintain balance while enabling emergent gameplay possibilities.

The system emphasizes deterministic behavior for testing and reproducibility, with comprehensive provenance tracking for all item usage. Items are designed as data-driven templates allowing extensive customization while maintaining consistent interaction patterns with core game systems.

## Mechanics

### Item Categories and Types

Special items are organized by function and usage patterns to ensure clear player expectations and balanced design:

- Weapon Items: Offensive capabilities with damage or disruption effects
- Equipment Items: Passive or activatable gear providing ongoing benefits
- Armor Items: Protective enhancements with specialized defensive properties
- Deployable Items: Environmental objects that create lasting tactical effects

Item types determine usage mechanics:
- Passive Items: Always active benefits with no action cost
- Activatable Items: Toggleable effects requiring action points
- Consumable Items: Single-use items that deplete after activation
- Deployable Items: Items that create persistent battlefield objects

### Action Costs and Gating

All special items integrate with core resource systems to prevent overuse and create meaningful tactical choices:

- AP Costs: Action point expenditure for item activation
- Energy Costs: Energy pool consumption for powered items
- Cooldowns: Turns required between uses to prevent spamming
- Charges: Limited uses before item depletion or recharging
- Prerequisites: Required conditions like time of day or unit state

### Motion Scanner

Motion scanners detect moving units within a radius, creating temporary visibility windows for reconnaissance:

- Detection Radius: Configurable scan area around target position
- Duration: Turns that revealed units remain visible
- Side Scoping: Whether detection benefits all allies or only the user
- Movement Detection: Identifies units that have moved recently
- Reveal Tokens: Temporary visibility effects on detected units

### Medikit

Medikits provide battlefield healing capabilities, removing wounds and restoring health through medical intervention:

- Healing Range: Self or adjacent ally targeting
- Wound Removal: Direct elimination of injury effects
- HP Restoration: Health point recovery based on wounds healed
- Resource Costs: AP and energy investment for medical procedures
- Deterministic Healing: Predictable recovery amounts for balancing

### Flare

Flares create temporary illumination zones, revealing hidden areas and providing tactical illumination:

- Deployment Method: Grenade-style placement with scatter mechanics
- Illumination Radius: Area of effect for visibility enhancement
- Duration: Turns the flare remains active
- Side Benefits: Visibility improvements for owning faction
- Placement Accuracy: Deterministic scatter based on throwing skill

### Flashlight

Flashlights provide directional illumination during nighttime operations, creating focused visibility cones:

- Directional Cone: Limited-angle beam extending from unit position
- Night Activation: Only functional during darkness periods
- Battery Drain: Per-turn charge consumption while active
- Range Limits: Maximum effective illumination distance
- Toggle Mechanics: On/off control with resource management

### Camouflage

Camouflage systems reduce unit visibility through environmental blending and stealth techniques:

- Sight Reduction: Decreased detection range for enemy units
- Cover Multipliers: Enhanced concealment when using terrain
- Energy Drain: Continuous resource consumption while active
- Aggressive Action Breaking: Stealth loss when attacking or moving aggressively
- Terrain Integration: Effectiveness varies by environment type

### Deterministic Behavior

All special item effects use seeded randomization for consistent, testable outcomes across play sessions:

- Mission Seeding: Deterministic seeds derived from mission parameters
- Provenance Tracking: Complete audit trail of all item usage and effects
- Predictable Scatter: Grenade placement and detection areas use seeded calculations
- Reproducible Testing: Consistent behavior for balance verification and debugging

## Examples

### Motion Scanner Usage

Reconnaissance Scan
- Unit activates motion scanner targeting suspected enemy position
- 6-tile radius scan detects 3 moving units in nearby cover
- Creates 2-turn reveal tokens showing enemy positions to entire allied team
- Consumes 1 AP and enters 4-turn cooldown
- Provides tactical intelligence for flanking maneuver planning

Ambush Detection
- Scanner reveals enemy patrol movement patterns
- Side-scoped visibility allows coordinated allied response
- Detection prevents surprise attack on friendly units
- Multiple scans required to track patrol routes over large areas

### Medikit Healing

Field Treatment
- Medic uses medikit on wounded ally with 2 serious injuries
- Removes both wounds, restoring 50 total HP
- Consumes 1 AP and 10 energy from medic's pools
- 2-turn cooldown prevents immediate reuse
- Allows treated unit to continue fighting effectively

Self-Healing
- Soldier stabilizes own wound before it becomes critical
- Single wound removal restores 25 HP
- Energy cost prevents overuse during extended missions
- Maintains unit combat effectiveness in prolonged engagements

### Flare Deployment

Area Illumination
- Unit throws flare into suspected ambush zone
- Creates 4-turn illumination in 3-tile radius
- Reveals hidden enemy positions to all allied units
- Consumes 1 AP with 3-turn cooldown
- Enables coordinated assault on previously concealed positions

Nighttime Reconnaissance
- Flare deployment during darkness operations
- Temporary visibility allows safe movement through unknown areas
- Side-scoped illumination benefits entire team
- Strategic placement covers multiple approach routes

### Flashlight Operation

Focused Illumination
- Unit activates flashlight during nighttime patrol
- Creates directional cone extending 5 tiles ahead
- Reveals hidden units and terrain within beam
- Consumes 1 energy per turn while active
- Allows precise navigation without alerting distant enemies

Stealth Movement
- Narrow beam prevents wide-area detection
- Directional control maintains operational security
- Battery management creates resource trade-offs
- Effective for close-range reconnaissance

### Camouflage Tactics

Terrain Integration
- Unit activates camouflage in forested area
- Reduces detection range by 50% for enemy units
- Enhanced concealment when using available cover
- Continuous 2 energy per turn drain
- Effective for ambush positioning

Aggressive Actions
- Camouflage breaks when unit attacks or moves aggressively
- Creates tactical decision between stealth and action
- Energy cost prevents indefinite use
- Requires careful resource management

## Related Wiki Pages

- [Unit items.md](../items/Unit%20items.md) - Unit equipment and special gear
- [Lore items.md](../items/Lore%20items.md) - Lore-related special items
- [Item Action Economy.md](../items/Item%20Action%20Economy.md) - Item usage costs and limitations
- [Resources.md](../items/Resources.md) - Resource costs for special items
- [Battlescape.md](../battlescape/Battlescape.md) - Combat special item usage
- [Units.md](../units/Units.md) - Unit special abilities and equipment
- [AI.md](../ai/AI.md) - AI usage of special items
- [Economy.md](../economy/Economy.md) - Acquisition costs and trading

## References to Existing Games and Mechanics

- **XCOM Series**: Special equipment and tactical gadgets
- **Metal Gear Solid Series**: Stealth items and specialized equipment
- **Deus Ex Series**: Augmentations and special cybernetic items
- **Half-Life Series**: HEV suit and scientific equipment
- **System Shock Series**: Neural implants and special items
- **Fallout Series**: Special weapons and utility items
- **Mass Effect Series**: Special abilities and equipment items
- **Thief Series**: Stealth tools and special equipment
- **Splinter Cell Series**: Stealth gadgets and surveillance tools
- **Ghost Recon Series**: Special operations equipment

