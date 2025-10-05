# Traits

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Trait Assignment and Persistence](#trait-assignment-and-persistence)
  - [Trait Categories and Effects](#trait-categories-and-effects)
  - [Compatibility and Restrictions](#compatibility-and-restrictions)
  - [Conditional and Dynamic Traits](#conditional-and-dynamic-traits)
  - [Trait Synergies and Stacking](#trait-synergies-and-stacking)
  - [Data-Driven Design and Modding](#data-driven-design-and-modding)
- [Examples](#examples)
  - [Basic Trait Assignment](#basic-trait-assignment)
  - [Conditional Trait Activation](#conditional-trait-activation)
  - [Trait Synergy Application](#trait-synergy-application)
  - [Mutually Exclusive Prevention](#mutually-exclusive-prevention)
  - [Specialization Development](#specialization-development)
  - [Environmental Adaptation](#environmental-adaptation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Traits system provides persistent, seeded modifiers that give individual units personality and gameplay variance beyond their core class and stats. Traits create memorable characters by adding quirks, specializations, and behavioral tendencies that affect performance across different scenarios. They are immutable once assigned, ensuring consistent character identity throughout campaigns.

Traits are assigned during unit creation using deterministic seeding, with one trait as default though campaigns can allow up to two. They modify stats, grant abilities, affect morale, and provide resistances while maintaining data-driven balance through rarity controls and compatibility rules. All trait effects are configurable without code changes, supporting extensive modding and campaign customization.

## Mechanics
### Trait Assignment and Persistence
Traits are assigned during recruitment using campaign seeds for reproducible outcomes, with default single trait assignment expandable to two. Once assigned, traits persist permanently throughout the unit's career, maintaining character identity across class changes and missions. Assignment considers compatibility rules, rarity flags, and prerequisite conditions.

### Trait Categories and Effects
Traits span multiple categories including personality (brave, disciplined), combat (deadshot, brawler), condition (wounded, adrenal), adaptation (night owl, pathfinder), specialization (mechanic, medic), psi (psychic sensitivity), and fortune (lucky, survivor). Effects include stat modifiers, ability grants, resistance changes, and behavioral tendencies, with balanced positive/negative combinations.

### Compatibility and Restrictions
Traits may have race restrictions, class compatibility requirements, and mutually exclusive relationships. High-power traits use rarity flags to control frequency, while prerequisites ensure appropriate trait access. Compatibility prevents contradictory combinations while maintaining design flexibility.

### Conditional and Dynamic Traits
Some traits activate based on situational conditions like health thresholds, morale states, time of day, or environmental factors. Dynamic evaluation continuously assesses activation requirements, applying effects immediately when conditions are met. This creates responsive gameplay that rewards situational awareness.

### Trait Synergies and Stacking
Specific trait combinations provide enhanced synergy bonuses beyond individual effects. Multiple instances of the same trait can stack with diminishing returns, though stack limits prevent extreme specialization. Synergy detection is automatic, with clear UI indicators for active combinations.

### Data-Driven Design and Modding
All traits are defined in external configuration files with complete metadata including effects, compatibility, rarity, and balance flags. This enables comprehensive modding support for custom traits, modified effects, and extended compatibility rules without code changes.

## Examples
### Basic Trait Assignment
Recruit gains "Brave" trait during hiring, providing +25 fear resistance and +15 morale modifier. Trait becomes permanent character identity, displayed in unit card with full effect breakdown and synergy potential indicators.

### Conditional Trait Activation
Unit with "Adrenal" trait drops below 25% health, automatically activating +1 AP bonus and +20% damage output. System updates tactical display to show active conditional effects with clear duration and deactivation conditions.

### Trait Synergy Application
Unit with "Disciplined" and "Brave" traits forms synergy, gaining additional +15 morale bonus for squad leadership. UI highlights synergy with descriptive text explaining inspirational effect on nearby allies.

### Mutually Exclusive Prevention
Attempting "Cowardly" trait on unit with "Brave" fails validation, displaying error message explaining personality conflict. System prevents contradictory character concepts while suggesting compatible alternatives.

### Specialization Development
Medic unit gains "Field Surgeon" trait, unlocking +1 medkit efficiency and +10% revive chance. Trait enhances medical role while maintaining class identity and enabling specialized healing capabilities.

### Environmental Adaptation
Unit with "Night Owl" trait receives +15% accuracy bonus during nighttime operations. Conditional activation responds to mission time, rewarding preparation for low-visibility scenarios.

## Related Wiki Pages

- [Classes.md](../units/Classes.md) - Trait compatibility and class synergies
- [Stats.md](../units/Stats.md) - Stat modifiers and trait effects
- [Inventory.md](../units/Inventory.md) - Equipment trait interactions
- [Morale.md](../battlescape/Morale.md) - Psychological trait effects
- [Psionics.md](../battlescape/Psionics.md) - Mental and psionic traits
- [Sanity.md](../battlescape/Sanity.md) - Sanity and mental health traits
- [Wounds.md](../battlescape/Wounds.md) - Resistance and durability traits
- [Experience.md](../units/Experience.md) - Progression and growth traits
- [Promotion.md](../units/Promotion.md) - Advancement and specialization traits
- [Modding.md](../technical/Modding.md) - Custom trait creation and modding

## References to Existing Games and Mechanics

- **X-COM Series**: Character trait system and specializations
- **Fire Emblem Series**: Character personality traits and abilities
- **Final Fantasy Tactics**: Ability trait system and specializations
- **Advance Wars**: CO trait system and command abilities
- **Tactics Ogre**: Character trait development and growth
- **Disgaea Series**: Character trait system and special abilities
- **Persona Series**: Personality trait system and social mechanics
- **Mass Effect Series**: Character trait system and background effects
- **Dragon Age Series**: Character trait system and personality
- **Fallout Series**: Perk system and character trait mechanics

