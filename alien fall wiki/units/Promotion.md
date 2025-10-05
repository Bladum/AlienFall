# Promotion

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Experience Requirements](#experience-requirements)
  - [Prerequisite Conditions](#prerequisite-conditions)
  - [Promotion Process](#promotion-process)
  - [Stat and Rank Progression](#stat-and-rank-progression)
  - [Upkeep Cost Increases](#upkeep-cost-increases)
  - [Equipment Compatibility](#equipment-compatibility)
  - [Identity Preservation](#identity-preservation)
  - [Promotion Trees](#promotion-trees)
  - [UI Preview System](#ui-preview-system)
  - [Deterministic Processing](#deterministic-processing)
  - [Reversible Promotions](#reversible-promotions)
  - [Modding Integration](#modding-integration)
- [Examples](#examples)
  - [Basic Promotion Flow](#basic-promotion-flow)
  - [Trait Modifier Application](#trait-modifier-application)
  - [Equipment Compatibility Resolution](#equipment-compatibility-resolution)
  - [Facility Prerequisite Enforcement](#facility-prerequisite-enforcement)
  - [Special Prerequisite Example](#special-prerequisite-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Promotion system enables deliberate player-triggered specialization, permanently replacing a unit's class with a chosen successor and applying enhanced stats, abilities, and increased upkeep costs. This creates meaningful branch choices in unit development while maintaining deterministic outcomes and comprehensive prerequisite validation. Promotions are irreversible by default, gated by experience point thresholds, facility requirements, research unlocks, and unit health conditions.

The system emphasizes strategic planning over random upgrades, with all promotion trees, costs, and prerequisites defined in external data files. Players must meet multiple requirement types before promotion becomes available, including sufficient XP (modified by intelligence traits), appropriate base facilities, completed research, and unit health status. Upon confirmation, units immediately gain new capabilities but may lose incompatible equipment, with clear previews showing all consequences before commitment.

## Mechanics
### Experience Requirements
Units must accumulate sufficient XP to unlock promotions, with progressive thresholds and trait-based modifiers. Base requirements increase with each rank level (100 XP for rank 1, 300 for rank 2, etc.), reduced by 25% for units with Smart traits or increased by 25% for Stupid traits. These thresholds create natural advancement pacing while rewarding consistent performance.

### Prerequisite Conditions
Multiple requirement types prevent premature advancement. Base facilities must provide necessary buildings and services, research prerequisites require completed technologies, and units must be healthy without blocking injuries. Special prerequisites can include resource costs, lore items, karma thresholds, or minimum time since recruitment, adding narrative depth and strategic complexity.

### Promotion Process
Promotions become visible when all requirements are met, requiring manual player confirmation. Effects apply instantly upon approval, with no real-time delays. The process includes final validation of prerequisites, immediate class replacement with stat and ability changes, XP deduction, and equipment compatibility resolution.

### Stat and Rank Progression
Promoted units gain proportional stat increases (120% of base at rank 1, scaling to 200% maximum) and advance through six rank levels. Higher ranks unlock additional capabilities and command authority, with visual indicators showing advancement. Stats cannot drop below viable thresholds or exceed hard caps to maintain balance.

### Upkeep Cost Increases
Promotion significantly raises unit salaries to reflect enhanced value and training. Base costs start at 20,000 credits with 10,000 credit increases per rank, reaching 80,000 credits at maximum rank. This creates meaningful economic trade-offs in unit specialization decisions.

### Equipment Compatibility
Equipment must match the promoted class's tags and requirements. Incompatible items are automatically unequipped during promotion, with UI previews showing affected gear. Designers can preserve backward compatibility through explicit flags, allowing legacy equipment to remain usable when appropriate.

### Identity Preservation
Core unit identity remains intact through promotion. Names, traits, medals, and remaining XP are retained, while payroll, transfer, and deployment rules continue normally. This maintains unit personality and achievement history while enabling specialization.

### Promotion Trees
Hierarchical advancement paths offer multiple specialization branches. Players choose from available successors at branch points, with some paths mutually exclusive. Trees are visualized in UI, showing current position and future options to support long-term planning.

### UI Preview System
Comprehensive previews display all promotion consequences before confirmation, including XP costs (with trait modifiers), exact stat deltas, upkeep changes, and dropped equipment lists. This transparency reduces decision surprises and supports strategic loadout planning.

### Deterministic Processing
All promotion logic uses seeded operations for reproducible outcomes. Prerequisite validation is cached for performance but invalidated when relevant state changes. Complete provenance tracking records promotion events, seeds, and state changes for debugging and analysis.

### Reversible Promotions
While promotions are irreversible by default, special cases can be marked as reversible through explicit designer flags. Reversal is handled by the transformation system with additional resource costs, providing flexibility for specific campaign scenarios without undermining the default permanence.

### Modding Integration
Promotion trees and requirements are fully data-driven, enabling community modifications. APIs support custom prerequisites, effects, validation overrides, and UI previews, allowing extensive customization without code changes.

## Examples
### Basic Promotion Flow
A unit with 150 XP and Smart trait promotes to rank 2. The Smart trait reduces the 300 XP threshold to 225, making promotion available. Stats increase from base values to 140% (8.4 effective), upkeep rises to 40,000 credits, and incompatible heavy armor is unequipped.

### Trait Modifier Application
Smart units reach rank 1 at 75 XP (25% reduction from 100 base), while Stupid units require 125 XP (25% increase). These proportional modifiers apply to all advancement thresholds, rewarding character background choices.

### Equipment Compatibility Resolution
A promoted sniper retains legacy compatibility flags for Psi Amp usage despite class changes, but heavy armor requiring specific tags becomes unusable and is automatically unequipped during promotion.

### Facility Prerequisite Enforcement
Advanced class promotions remain unavailable until the base constructs required training facilities. Research prerequisites block access until relevant technology trees are completed.

### Special Prerequisite Example
Neural implant promotion requires both a rare lore item at base and completed psionic research. Even with sufficient XP and health, promotion is blocked until all narrative and technological conditions are satisfied.

## Related Wiki Pages

- [Experience.md](../units/Experience.md) - Experience requirements for promotion
- [Ranks.md](../units/Ranks.md) - Rank advancement and progression
- [Classes.md](../units/Classes.md) - Class specialization and promotion trees
- [Medals.md](../units/Medals.md) - Achievement prerequisites for promotion
- [Basescape.md](../basescape/Basescape.md) - Facility requirements for advancement
- [Research tree.md](../economy/Research%20tree.md) - Technology unlocks for promotion
- [Wounds.md](../battlescape/Wounds.md) - Health and status considerations
- [Inventory.md](../units/Inventory.md) - Equipment compatibility and upgrades
- [Finance.md](../finance/Finance.md) - Salary increases and costs
- [Modding.md](../technical/Modding.md) - Custom promotion system modding

## References to Existing Games and Mechanics

- **X-COM Series**: Rank progression and stat increases
- **Fire Emblem Series**: Class promotion and advancement system
- **Final Fantasy Tactics**: Job system and character advancement
- **Advance Wars**: CO level progression and power unlocks
- **Tactics Ogre**: Class advancement and specialization
- **Disgaea Series**: Character promotion and stat growth
- **Persona Series**: Social link progression and growth
- **Mass Effect Series**: Level progression and ability unlocks
- **Dragon Age Series**: Level advancement and talent trees
- **Fallout Series**: Level progression and perk system

