# Medals

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Award Timing and Evaluation](#award-timing-and-evaluation)
  - [Single-Award and Tiered Systems](#single-award-and-tiered-systems)
  - [Experience Point Rewards](#experience-point-rewards)
  - [Eligibility Filtering](#eligibility-filtering)
  - [Unique Global Medals](#unique-global-medals)
  - [Deterministic Evaluation Criteria](#deterministic-evaluation-criteria)
  - [Provenance and Telemetry](#provenance-and-telemetry)
  - [User Interface Integration](#user-interface-integration)
  - [Data-Driven Design and Modding](#data-driven-design-and-modding)
- [Examples](#examples)
  - [Kill Achievement Tiers](#kill-achievement-tiers)
  - [Precision Specialist Medals](#precision-specialist-medals)
  - [Objective and Performance Medals](#objective-and-performance-medals)
  - [Protection and Rescue Medals](#protection-and-rescue-medals)
  - [Support Role Medals](#support-role-medals)
  - [Class-Specific Medals](#class-specific-medals)
  - [Unique Campaign Medals](#unique-campaign-medals)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Medals system provides persistent, one-time awards that recognize mission achievements and provide narrative recognition with modest experience point rewards. Medals highlight memorable tactical moments without introducing permanent power creep, maintaining deterministic evaluation and complete provenance tracking for all awarding events. Each medal can be earned only once per unit, with tiered versions allowing progression from bronze to gold levels for escalating accomplishments.

Medals are evaluated deterministically from mission logs during post-mission cleanup, ensuring reproducible outcomes across play sessions. They serve as episodic boosts to unit progression while preserving long-term balance, with all criteria and rewards defined in external data files for easy modding and balance tuning. The system supports filtering by race and class, unique global medals awarded only once per campaign, and comprehensive telemetry integration for analysis and debugging.

## Mechanics
### Award Timing and Evaluation
Medals are evaluated and awarded during mission completion processing, using complete mission logs and final unit states. This post-mission timing ensures all events are captured and prevents mid-mission interruptions. Evaluation follows a deterministic sequence based on mission seeds, processing units in consistent order to guarantee reproducible results across replays and testing scenarios.

### Single-Award and Tiered Systems
Standard medals are earned once per unit with permanent records in their history. Tiered medals (bronze, silver, gold) are exclusive, with higher tiers replacing lower ones as units achieve greater accomplishments. This prevents redundant displays while encouraging continued excellence and progressive challenges.

### Experience Point Rewards
Each medal provides a one-time XP bonus equivalent to several mission completions, contributing to rank advancement without creating stacking bonuses. Bronze tiers offer 20-30 XP, silver tiers 40-60 XP, gold tiers 80-120 XP, and unique medals 60-100 XP. Rewards are calibrated to provide meaningful progression boosts while avoiding power creep.

### Eligibility Filtering
Medals can be restricted by race or class to maintain faction specialization and balance. Race filters limit awards to specific alien species or human factions, while class filters require particular unit specializations. This ensures achievements feel appropriate to unit capabilities and campaign lore.

### Unique Global Medals
Certain medals are awarded only once per entire campaign, creating competition between units for pioneering accomplishments. These represent campaign-defining moments like first contact with new alien races or historic mission successes, with global flags preventing duplicate awards.

### Deterministic Evaluation Criteria
Medal requirements are verified against mission data including kill counts, precision shots, objective completion, stealth preservation, protection of civilians, support actions, and class-specific accomplishments. All evaluation uses seeded randomness where needed, with complete provenance logging for reproducibility.

### Provenance and Telemetry
Every medal award includes full documentation of evaluation process, mission context, seeds used, and timing. This enables bug reproduction, balance analysis, and player behavior tracking through exportable medal histories integrated with broader campaign telemetry.

### User Interface Integration
Medals appear in unit dossiers with visual galleries, achievement timelines, and detailed tooltips showing criteria and rewards. Global medals are visible across campaign interfaces, with mission links providing context for each award.

### Data-Driven Design and Modding
All medal definitions, criteria, and rewards are configured through external files, enabling designer creativity and community modifications without code changes. The system provides hooks for custom evaluation logic, display options, and telemetry extensions.

## Examples
### Kill Achievement Tiers
Bronze Kill Medal requires 3 enemy kills in a single mission, Silver requires 10 kills, and Gold requires 30 kills. Each tier provides escalating XP rewards while limiting scope to individual missions to prevent accumulation.

### Precision Specialist Medals
Long Shot medal awards killing an enemy beyond a weapon's effective range, requiring tactical positioning and marksmanship. Headshot King recognizes 3 high-difficulty precision kills in one mission, demonstrating weapon mastery.

### Objective and Performance Medals
Objective Specialist medal credits units for completing primary mission objectives. Silent Operator requires finishing a mission without breaking concealment, rewarding stealth proficiency.

### Protection and Rescue Medals
Civilian Guardian combines zero civilian casualties with rescuing at least one civilian. Last Stand recognizes surviving missions with critically low health while achieving success.

### Support Role Medals
Medic Lifesaver tiers reward reviving or healing teammates, from bronze (3 healings) to gold (10+). Engineer Under Fire requires repairing equipment while under enemy fire, recognizing high-risk technical operations.

### Class-Specific Medals
Psi Master limits to psi-class units performing 5 successful psionic actions. Pilot Ace awards exceptional craft dogfighting performance with multiple shootdowns and no allied losses.

### Unique Campaign Medals
First Blood awards the first unit to kill a new alien race, globally unique per campaign. Vanguard recognizes the first craft to intercept a UFO, marking significant campaign milestones.

## Related Wiki Pages

- [Experience.md](../units/Experience.md) - Experience point rewards from medals
- [Promotion.md](../units/Promotion.md) - Advancement and promotion mechanics
- [Ranks.md](../units/Ranks.md) - Rank progression and unlocks
- [Classes.md](../units/Classes.md) - Class-specific achievement requirements
- [Races.md](../units/Races.md) - Race-specific medal categories
- [Unit actions.md](../battlescape/Unit%20actions.md) - Action-based medal criteria
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Objective completion achievements
- [Geoscape.md](../geoscape/Geoscape.md) - Campaign and strategic achievements
- [SaveSystem.md](../technical/SaveSystem.md) - Medal persistence and tracking
- [Modding.md](../technical/Modding.md) - Custom medal creation and modding

## References to Existing Games and Mechanics

- **X-COM Series**: Achievement and medal system for missions
- **Fire Emblem Series**: Achievement medals and battle records
- **Advance Wars**: Campaign medal and ranking system
- **Final Fantasy Tactics**: Achievement system and battle records
- **Tactics Ogre**: Medal system for character achievements
- **Disgaea Series**: Achievement system and battle records
- **Persona Series**: Trophy and achievement system
- **Mass Effect Series**: Achievement and medal system
- **Dragon Age Series**: Achievement and codex system
- **Fallout Series**: Achievement and perk system

