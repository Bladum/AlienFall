# Wounds

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Wound Triggering System](#wound-triggering-system)
  - [Wound Probability Tables](#wound-probability-tables)
  - [Wound Effects and Impact Tags](#wound-effects-and-impact-tags)
  - [Health Ratio Global Penalties](#health-ratio-global-penalties)
  - [Healing and Treatment System](#healing-and-treatment-system)
  - [Post-Mission Conversion](#post-mission-conversion)
  - [Stacking and Persistence Rules](#stacking-and-persistence-rules)
  - [Determinism and Provenance](#determinism-and-provenance)
- [Examples](#examples)
  - [Single Hit Wound and Treatment](#single-hit-wound-and-treatment)
  - [Multiple Wounds and Conversion](#multiple-wounds-and-conversion)
  - [Stacking and Health Ratio Interaction](#stacking-and-health-ratio-interaction)
  - [Wound Conversion Scenarios](#wound-conversion-scenarios)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Wounds are mission-scoped, deterministic penalties representing acute, non-lethal trauma that immediately reduce battlefield effectiveness. Distinct from raw HP loss and persistent strategic Injuries, unresolved wounds may convert to long-term Injuries during seeded post-mission processing. Designers tune wound probabilities, impact tags (Move, Aim, Melee, React, General), bleed rates, and heal-point costs via data for balance without code changes. Full provenance for wound rolls, treatments, and conversions ensures reproducible playtests and reliable telemetry.

## Mechanics

### Wound Triggering System
- Damage Type Restriction: Only HURT (physical/HP) damage triggers wound checks
- Lethal Hit Exclusion: No wound rolls for immediately fatal damage
- Damage Fraction Calculation: finalDamage / unit.maxHP determines wound probability
- Seeded RNG: Deterministic wound rolls using mission-seed-derived streams
- Probability Brackets: Configurable chance tables based on damage severity

### Wound Probability Tables
- Recommended Baseline:
  - < 0.25 damage fraction → 20% chance
  - 0.25-0.50 → 40% chance
  - 0.50-0.75 → 60% chance
  - 0.75-1.00 → 80% chance
- Legacy Alternative:
  - < 0.25 → no roll
  - 0.25-0.50 → 25% chance
  - 0.50-0.75 → 50% chance
  - 0.75-1.00 → 75% chance
- Data-Driven Configuration: Probability tables authorable without code changes
- Modder Accessibility: Easy tuning for different difficulty or realism levels

### Wound Effects and Impact Tags
- Impact Tag Assignment: Move, Aim, Melee, React, or General focus areas
- Immediate Effects: Bleeding (-1 HP/turn), morale drain (-1/turn), focused penalties
- Tag-Specific Penalties: Tactical penalties based on wound location/type
- Stacking Mechanics: Multiple wounds additively combine effects
- Mission Persistence: Effects last until treated or mission end

### Health Ratio Global Penalties
- Ratio Calculation: currentHP / maxHP determines penalty bands
- Penalty Bands:
  - Critical (< 25%): -2 AP, -20% Aim, -2 Move, -2 React
  - Major (25-50%): -1 AP, -10% Aim, -1 Move, -1 React
  - Minor (50-75%): -5% Aim, minor Move penalty
  - Unhurt (75-100%): no penalties
- Stacking with Wounds: Global penalties add to per-wound focused effects
- Dynamic Updates: Penalties change as HP fluctuates from bleeding/healing

### Healing and Treatment System
- Heal Point Requirements: 3 points per wound (configurable baseline)
- Medikit Semantics: Points remove wounds before restoring HP
- Treatment Priority: Configurable ordering (oldest, most severe, etc.)
- Partial Healing: Remaining points restore HP after wound removal
- In-Mission Restoration: HP healing alone doesn't remove wound penalties

### Post-Mission Conversion
- Injury Conversion: Unresolved wounds evaluated for long-term effects
- Seeded Evaluation: Deterministic 50% base chance per wound (configurable)
- Recovery Tracking: 7-day baseline recovery modified by facilities/traits
- Strategic Impact: Converted units become non-deployable during recovery
- Mission Summary: Lists converted wounds and recovery durations

### Stacking and Persistence Rules
- Additive Effects: Bleeding, morale drain, and penalties stack across wounds
- Focused Penalty Doubling: Multiple wounds of same type compound effects
- Bleeding HP Reduction: May trigger health ratio band changes
- Mission Scope: Wounds don't persist into strategic layer
- Cleanup Resolution: All wounds healed, treated, or converted at mission end

### Determinism and Provenance
- Seeded Rolls: Named RNG streams for wound rolls and conversions
- Complete Logging: Damage fraction, roll results, impact tags, treatments
- Conversion Tracking: Which wounds converted and recovery requirements
- Replay Support: Full reconstruction from logged provenance
- Balance Analysis: Telemetry for tuning wound probabilities and effects

## Examples

### Single Hit Wound and Treatment
- Unit State: maxHP = 12, receives 9 damage (0.75 fraction)
- Wound Roll: 60% bracket triggers seeded roll, Aim tag applied
- Immediate Effects: -1 HP/turn bleeding, -1 morale/turn, -10% Aim penalty
- Health Ratio: 3/12 = 25% → Major band (-1 AP, -10% Aim additional)
- Medikit Treatment: 6 heal points remove wound (3 points), restore 3 HP (6/12 = 50%)

### Multiple Wounds and Conversion
- Accumulated Trauma: Two wounds (Move and Melee tags) over mission
- Stacked Effects: -2 HP/turn bleeding, doubled focused penalties
- No Treatment: Wounds persist to mission cleanup
- Conversion Rolls: Seeded evaluation (50% base chance each)
- Strategic Impact: One converts to 7-day injury, unit unavailable for recovery period

### Stacking and Health Ratio Interaction
- Multiple Trauma: Two successful wound rolls from separate hits
- Combined Penalties: -2 HP/turn, -2 morale/turn, stacked tactical penalties
- Bleeding Cascade: HP drops may push into Critical health ratio band
- Compounded Effects: Per-wound + global penalties create severe debuffs
- Treatment Priority: Medics must allocate limited heal points strategically

### Wound Conversion Scenarios
- High Damage Fraction: 0.90 fraction hit → 80% wound chance
- Tag Assignment: Seeded selection from available impact tags
- Post-Mission: 50% chance converts to strategic injury
- Recovery Calculation: 7 days ± modifiers from facilities/traits
- Campaign Effects: Unit unavailable, replacement costs, morale impact

## Related Wiki Pages

- [Unconscious.md](../battlescape/Unconscious.md) - Wounds can lead to unconsciousness.
- [Sanity.md](../battlescape/Sanity.md) - Wounds affect sanity.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Wounds affect actions.
- [Morale.md](../battlescape/Morale.md) - Wounds affect morale.
- [Medical.md](../battlescape/Medical.md) - Treatment of wounds.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Fire causes wounds.
- [Stats.md](../units/Stats.md) - Wounds affect stats.
- [Injuries.md](../units/Injuries.md) - Wounds convert to injuries.
- [Bleeding.md](../battlescape/Bleeding.md) - Wound bleeding.
- [Healing.md](../battlescape/Healing.md) - Wound healing.

## References to Existing Games and Mechanics

- X-COM series: Wound system and injuries.
- Warhammer 40k: Wound pools and critical damage.
- Dungeons & Dragons: Hit points and wounds.
- Fire Emblem: Critical hits and wounds.
- Fallout: Injury system.
- Deus Ex: Wound penalties.
- Mass Effect: Injury mechanics.
- Dragon Age: Wound effects.

