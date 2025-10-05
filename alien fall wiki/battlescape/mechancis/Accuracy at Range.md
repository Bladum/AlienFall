# Accuracy at Range System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Range Band Framework](#range-band-framework)
  - [Distance Calculation Methods](#distance-calculation-methods)
  - [Weapon Range Profiles](#weapon-range-profiles)
  - [Situational Modifier System](#situational-modifier-system)
  - [Calculation Sequence](#calculation-sequence)
  - [Provenance Tracking](#provenance-tracking)
- [Examples](#examples)
  - [Standard Range Bands](#standard-range-bands)
  - [Weapon Range Examples](#weapon-range-examples)
  - [Situational Modifier Examples](#situational-modifier-examples)
  - [Complete Calculation Example](#complete-calculation-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Accuracy at Range system implements a deterministic, data-driven banded falloff model that applies predictable accuracy multipliers based on engagement distance. Weapons define maximum effective ranges, with discrete accuracy bands providing transparent, tunable falloff characteristics. The banded approach ensures reproducible outcomes for testing and modding while maintaining clear player communication through UI previews and tooltips.

The system emphasizes design clarity through explicit range bands, complete provenance tracking for balance analysis, and seamless integration with environmental and tactical modifiers. All calculations preserve floating-point precision until final hit chance determination, ensuring consistent results across different hardware and play sessions.

## Mechanics

### Range Band Framework
Core system using discrete distance bands with associated accuracy multipliers:
- Band Definition: Each band specifies range ratio thresholds and accuracy multipliers
- Range Ratio Calculation: `rangeRatio = actualDistance / weaponMaxRange`
- Band Selection: Deterministic lookup based on calculated range ratio
- Multiplier Application: Selected band's multiplier applied to base accuracy
- Precision Preservation: Full floating-point arithmetic maintained throughout calculations

### Distance Calculation Methods
Multiple distance metrics supporting different tactical contexts:
- Euclidean Distance: Straight-line measurement using Pythagorean theorem
- Tile Step Distance: Pathfinding-aware distance accounting for obstacles
- Manhattan Distance: Grid-based calculation using horizontal/vertical movement only
- Metric Consistency: Same distance calculation used across line-of-sight and accuracy systems

### Weapon Range Profiles
Individual weapon characteristics defining engagement capabilities:
- Maximum Range: Furthest effective engagement distance in tiles
- Base Accuracy: Fundamental weapon accuracy rating (0.0-1.0 scale)
- Range Modifiers: Weapon-specific band adjustments or overrides
- Special Traits: Unique characteristics affecting range performance
- Equipment Integration: Gear-based range extensions and accuracy improvements

### Situational Modifier System
Environmental and tactical factors affecting accuracy:
- Stance Effects: Crouching/prone positions providing stability bonuses
- Movement Penalties: Reduced accuracy when firing while moving
- Environmental Conditions: Weather, lighting, and visibility impacts
- Tactical Modifiers: Cover, smoke, and positioning effects
- Trait Bonuses: Special abilities extending effective range or improving accuracy

### Calculation Sequence
Deterministic multi-step process ensuring reproducible results:
- Base Accuracy: Unit aim skill multiplied by weapon base accuracy
- Range Application: Range band multiplier applied to base accuracy
- Situational Modifiers: Environmental and tactical factors applied
- Final Hit Chance: Result clamped to valid probability range (0.0-1.0)
- Provenance Logging: Complete audit trail recorded for analysis

### Provenance Tracking
Comprehensive logging system for balance and debugging:
- Calculation ID: Unique identifier for each accuracy calculation
- Input Parameters: Complete set of inputs (positions, weapon, modifiers)
- Intermediate Values: Step-by-step calculation results
- Final Result: Complete output with all applied modifiers
- Audit Trail: Sequential record of all calculation steps

## Examples

### Standard Range Bands
| Range Band | Range Ratio | Multiplier | Description |
|------------|-------------|------------|-------------|
| Optimal | 0.00 - 0.75 | 1.00 | Full accuracy within optimal engagement range |
| Near-Edge | 0.75 < r ≤ 1.00 | 0.75 | Minor penalty at edge of effective range |
| Slightly Over | 1.00 < r ≤ 1.25 | 0.50 | Significant penalty beyond maximum range |
| Far Over | 1.25 < r ≤ 1.50 | 0.25 | Severe penalty at extended range |
| Out of Range | r > 1.50 | 0.00 | No chance to hit beyond 150% of maximum range |

### Weapon Range Examples
Pistol (maxRange = 15 tiles, baseAccuracy = 0.85):
- Target at 11 tiles: ratio = 0.73 → multiplier = 1.00 → effective = 85%
- Target at 17 tiles: ratio = 1.13 → multiplier = 0.50 → effective = 42.5%
- Target at 23 tiles: ratio = 1.53 → multiplier = 0.00 → effective = 0%

Assault Rifle (maxRange = 30 tiles, baseAccuracy = 0.75):
- Target at 22 tiles: ratio = 0.73 → multiplier = 1.00 → effective = 75%
- Target at 35 tiles: ratio = 1.17 → multiplier = 0.50 → effective = 37.5%
- Target at 46 tiles: ratio = 1.53 → multiplier = 0.00 → effective = 0%

Sniper Rifle (maxRange = 50 tiles, baseAccuracy = 0.90):
- Target at 37 tiles: ratio = 0.74 → multiplier = 1.00 → effective = 90%
- Target at 55 tiles: ratio = 1.10 → multiplier = 0.50 → effective = 45%
- Target at 76 tiles: ratio = 1.52 → multiplier = 0.00 → effective = 0%

### Situational Modifier Examples
- Crouched Position: +5% accuracy bonus for stability
- Moving Fire: -20% accuracy penalty for weapon instability
- Rain Conditions: -10% accuracy penalty for long-range shots
- Fog Conditions: -30% accuracy penalty for obscured targets
- Long Range Specialist: +10% bonus within effective range, -10% penalty beyond

### Complete Calculation Example
Soldier with 80% aim using assault rifle at 35 tiles in rain while moving:
- Base hit chance: 0.80 × 0.75 = 0.60 (60%)
- Range ratio: 35/30 = 1.17 → "slightly over" band → multiplier = 0.50
- After range: 0.60 × 0.50 = 0.30 (30%)
- Weather penalty (rain): 0.30 × 0.90 = 0.27 (27%)
- Movement penalty: 0.27 × 0.80 = 0.216 (21.6%)
- Final hit chance: 21.6%

## Related Wiki Pages

- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Visibility calculations that determine if targets are detectable at various ranges.
- [Line of Fire.md](../battlescape/Line%20of%20Fire.md) - Requirements for clear firing lines, interacting with range and environmental blocking.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Combat actions like shooting that utilize accuracy calculations.
- [Wounds.md](../battlescape/Wounds.md) - Injury mechanics that follow successful hits determined by accuracy.
- [Battle tile.md](../battlescape/Battle%20tile.md) - Terrain properties affecting movement and positioning for range management.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height differences impacting line-of-sight and effective range.
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Environmental conditions reducing visibility and accuracy at distance.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Temporary effects obscuring vision and penalizing long-range shots.
- [Damage calculations.md](../items/Damage%20calculations.md) - Damage computation after successful accuracy rolls.
- [Items.md](../items/Items.md) - Weapon definitions including range profiles and accuracy stats.
- [Stats.md](../units/Stats.md) - Unit attributes like aim skill that form the base for accuracy calculations.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI decision-making incorporating range and accuracy assessments.

## References to Existing Games and Mechanics

The Accuracy at Range system draws from range-based combat mechanics in tactical and strategy games:

- **X-COM series (1994-2016)**: Progressive accuracy penalties beyond optimal weapon ranges, with environmental modifiers.
- **Fire Emblem series (1990-2023)**: Weapon triangle and range-based hit calculations with terrain bonuses.
- **Advance Wars series (2001-2018)**: Unit-specific range brackets affecting attack effectiveness and movement.
- **Jagged Alliance series (1994-2014)**: Detailed stance and positioning modifiers on long-range accuracy.
- **BattleTech (1984-2024)**: Range bands (short/medium/long) determining weapon damage and hit probability.
- **Fallout series (1997-2023)**: Realistic ballistics with distance falloff and weapon-specific range profiles.
- **Deus Ex series (2000-2017)**: Stealth mechanics where range affects detection probability and combat accuracy.
- **S.T.A.L.K.E.R. series (2007-2024)**: Environmental factors like weather and cover impacting long-range shots.

