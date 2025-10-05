# Experience

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Repeatable XP Sources](#repeatable-xp-sources)
  - [One-Time Awards](#one-time-awards)
  - [Promotion Model](#promotion-model)
  - [Trait Interactions](#trait-interactions)
  - [Determinism and Logging](#determinism-and-logging)
  - [UI Design](#ui-design)
- [Examples](#examples)
  - [Training Progression](#training-progression)
  - [Mission XP Breakdown](#mission-xp-breakdown)
  - [Medal Rewards](#medal-rewards)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Experience (XP) serves as Alien Fall's long-term progression currency, tracking unit battlefield learning and driving promotions, stat increases, and specialization unlocks. The system rewards meaningful tactical contributions while supporting both predictable advancement and branching career paths.

XP sources are data-driven and deterministic, ensuring reproducible progression and reliable testing. The system emphasizes sustained engagement over trivial actions, with clear rewards for survival, objective completion, and creative tactics.

## Mechanics

### Repeatable XP Sources

Units earn XP through various mission and base activities.

Training Activities:
- Base Training: +1 XP per day assigned to active Training Center
- Facility Operation: Training Centers must be functional for XP gain
- Consistent Progression: Steady XP accumulation during down time
- Strategic Assignment: Players choose which units to focus on training

Mission Deployment:
- Participation Award: +3 XP for joining any mission
- One-Time Per Mission: XP granted once at mission launch
- Incentive for Involvement: Rewards mission participation
- Base Level Reward: Applies to all mission types and difficulties

Combat Contributions:
- Enemy Spotting: +1 XP for first sighting of enemy units
- Damage Dealing: +1 XP per successful damaging action
- Kill Credit: +5 XP for eliminating enemy units
- Assist Bonus: +2 XP for contributing to enemy elimination
- Healing Actions: +1 XP for restoring ally health
- Damage Received: +1 XP per hit taken (survivability reward)

Objective Completion:
- Primary Objectives: +4 XP for completing mission goals
- Secondary Contributions: Small XP for supporting actions
- Team Support: XP for reviving teammates, disabling devices
- Environmental Actions: XP for destroying cover, achieving milestones

### One-Time Awards

Medals provide significant XP bonuses for exceptional achievements.

Medal System:
- Non-Repeatable: Each medal earned once per unit
- Substantial Rewards: +25 to +50 XP per medal
- Achievement-Based: Tied to specific accomplishments
- Permanent Record: Medals become part of unit history

Typical Medals:
- First Blood: First kill against a new alien race
- Sharpshooter: Multiple precision long-range kills
- Rescue Hero: Successful civilian evacuation
- Veteran: Surviving numerous high-intensity missions
- Specialist: Exceptional performance in specific roles

### Promotion Model

XP drives advancement through the class progression system.

Accumulation Mechanics:
- XP Pool: Experience accumulates across all activities
- Consumption for Promotion: XP spent to advance ranks
- Fixed Thresholds: Data-driven XP costs per rank
- Progressive Difficulty: Higher ranks require more XP

Advancement Process:
- Eligibility Check: Unit must meet all promotion prerequisites
- XP Deduction: Required experience consumed on promotion
- Stat Improvements: Base stats increase with rank advancement
- Ability Unlocks: New skills become available at higher ranks

### Trait Interactions

Individual traits modify promotion requirements and XP efficiency.

Trait Effects:
- XP Cost Modifiers: Traits adjust promotion XP thresholds
- No Earning Changes: Traits don't affect XP gained from actions
- Predictable Adjustments: Fixed percentage modifiers
- Balance Tool: Traits create different advancement paces

Example Traits:
- Smart: -10% XP required for promotions (faster advancement)
- Dumb: +10% XP required for promotions (slower advancement)
- Hardy: May modify survivability XP or training efficiency
- Specialized: Could affect specific XP sources or promotion paths

### Determinism and Logging

All XP mechanics are predictable with comprehensive tracking.

Data-Driven Design:
- YAML Configuration: All XP sources and costs in external data
- Seeded Behavior: Deterministic outcomes for testing
- Reproducible Results: Same actions always yield same XP
- Modding Support: Community can adjust XP values

Provenance System:
- Event Logging: Every XP gain recorded with context
- Timestamps: When XP was earned during gameplay
- Event IDs: Links to specific missions, actions, and seeds
- Telemetry Support: Data for balancing and player analytics

### UI Design

Clear XP information supports player understanding and planning.

Display Elements:
- Current XP: Unit's current experience total
- Progress Bars: Visual indication toward next promotion
- XP Sources: Breakdown of recent XP gains
- Projected Values: XP needed for next rank advancement

Trait Integration:
- Modified Thresholds: Shows trait-adjusted promotion costs
- Comparison Views: Displays standard vs. modified requirements
- Planning Tools: Helps players understand advancement pacing
- Transparency: No hidden modifiers or surprise requirements

## Examples

### Training Progression

Base training provides steady, predictable XP growth:

- Training Assignment: Unit assigned to active Training Center
- Daily XP: +1 XP per day of training
- Week Progression: 7 days = +7 XP total
- Strategic Choice: Players prioritize which units receive training
- Facility Dependency: Training Centers must be operational
- Long-Term Planning: Training fills gaps between missions

### Mission XP Breakdown

A single mission can provide significant XP through multiple sources:

- Mission Start: +3 XP for deployment
- Enemy Contact: +1 XP for spotting first enemy, +1 XP for spotting second
- Combat Actions: +5 XP for enemy kill, +1 XP for damaging another enemy
- Support Role: +1 XP for healing wounded ally
- Objective Success: +4 XP for completing primary mission objective
- Total Mission XP: 3 + 2 + 5 + 1 + 1 + 4 = 16 XP earned
- Accumulation: XP adds to unit's total for eventual promotion

### Medal Rewards

Exceptional achievements provide substantial one-time XP bonuses:

- Sharpshooter Medal: +50 XP for precision long-range combat excellence
- First Blood: +25 XP for first kill against new alien species
- Rescue Hero: +40 XP for successful civilian evacuation operations
- Veteran Status: +35 XP for surviving 10 high-intensity missions
- Specialist Recognition: +30 XP for exceptional performance in specific roles
- Non-Repeatable: Each medal earned only once per unit
- Career Milestones: Medals become part of unit's permanent record

## Related Wiki Pages

- [Promotion.md](../units/Promotion.md) - XP-based advancement and stat growth
- [Ranks.md](../units/Ranks.md) - Rank progression and unlocks
- [Classes.md](../units/Classes.md) - Class specialization and XP requirements
- [Medals.md](../units/Medals.md) - Achievement and medal reward system
- [Units.md](../units/Units.md) - Unit statistics and growth mechanics
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Objective completion experience rewards
- [Mission salvage.md](../battlescape/Mission%20salvage.md) - Salvage and recovery experience
- [Basescape.md](../basescape/Basescape.md) - Training and development facilities
- [Research tree.md](../economy/Research%20tree.md) - Technology unlock progression
- [Geoscape.md](../geoscape/Geoscape.md) - Campaign and strategic progression

## References to Existing Games and Mechanics

- **X-COM Series**: Experience system with stat increases and promotions
- **Fire Emblem Series**: Level-up system with stat growth and classes
- **Final Fantasy Tactics**: Job system with experience and specialization
- **Advance Wars**: CO power system with campaign progression
- **Tactics Ogre**: Character growth and stat development system
- **Disgaea Series**: Level grinding and reincarnation mechanics
- **Persona Series**: Social links and character development
- **Mass Effect Series**: Paragon/renegade morality system
- **Dragon Age Series**: Level progression and talent trees
- **Fallout Series**: SPECIAL attribute system and leveling

