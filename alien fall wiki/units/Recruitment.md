# Recruitment

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Acquisition Channels](#acquisition-channels)
  - [Unit Properties and Generation](#unit-properties-and-generation)
  - [Variants, Unlocks, and Recipes](#variants,-unlocks,-and-recipes)
  - [Cost Calculation and Constraints](#cost-calculation-and-constraints)
  - [Determinism and Provenance](#determinism-and-provenance)
  - [UI and User Experience](#ui-and-user-experience)
- [Examples](#examples)
  - [Marketplace Purchase](#marketplace-purchase)
  - [Manufacturing Recipe](#manufacturing-recipe)
  - [Cost Calculation with Modifiers](#cost-calculation-with-modifiers)
  - [Black Market Acquisition](#black-market-acquisition)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview
The Recruitment system enables acquisition of new units through market purchases, manufacturing projects, and black market offers. Units are created with fixed classes, seeded cosmetic and trait values, and arrive unequipped requiring barracks provisioning. The system supports pre-ranked variants through manufacturing recipes, maintains deterministic outcomes for reproducibility, and integrates with transfer logistics for delivery timing. All recruitment mechanics are data-driven, with clear UI feedback about costs, arrival timing, and unit requirements.

Recruitment channels include marketplace purchases that create transfer jobs, workshop manufacturing with resource consumption, and black market options with special unlocks. Units begin with zero experience and no equipment, though manufacturing can produce higher-rank specialists. The system ensures seeded randomization for cosmetic generation while providing transparent previews and provenance tracking for all recruitment events.

## Mechanics
### Acquisition Channels
Market purchases create transfer jobs delivering units after configurable delivery times. Manufacturing queues workshop projects consuming resources, man-hours, and facility capacity to produce units upon completion. Black market functions similarly to marketplace but requires unlocks and may impose reputation costs. All channels deduct credits or resources atomically and follow transfer system rules for logistics.

### Unit Properties and Generation
Recruited units instantiate with fixed classes determining base stats, promotion paths, and salary profiles. They arrive unequipped with no inventory or gear assigned. Cosmetic fields (name, sex, face, country of origin) and traits are randomized using seeded sequences for deterministic reproducibility. Experience starts at zero unless manufacturing recipes specify pre-ranked variants.

### Variants, Unlocks, and Recipes
Research progress and supplier contacts unlock additional recruitable classes, higher-rank purchasable variants, and special pool listings. Manufacturing recipes can produce pre-ranked or specialty personnel when prerequisites are met. Robotic units are produced only through manufacturing, not marketplace listings. All variants and unlocks are data-driven with clear prerequisite declarations.

### Cost Calculation and Constraints
Recruitment costs vary by race, class, and base facilities, with research providing discounts. Marketplace purchases consume credits, manufacturing requires resource inputs, and all acquisitions respect base capacity limits. Costs include facility-based reductions and research progress modifiers, with transparent breakdowns shown in UI.

### Determinism and Provenance
All random generation uses seeded sequences derived from campaign seeds and action identifiers. Recruitment events are logged with complete provenance for replay compatibility and telemetry. Pool generation and cosmetic assignment can be reproduced identically for testing and analysis.

### UI and User Experience
Interface clearly indicates units arrive unequipped and require provisioning. Pre-ranked options show research and pricing prerequisites. Deterministic previews display seeded cosmetic outcomes where applicable. Transfer timing and delivery status are prominently displayed to support planning.

## Examples
### Marketplace Purchase
Player purchases "Rookie Trooper" for 1000 credits. System creates void-to-base transfer with 3-day delivery. Upon arrival, unit has Assault class, rank 0, zero XP, seeded random name/face/trait combination, and no equipment assigned.

### Manufacturing Recipe
Player queues "Veteran Pilot" project requiring research unlock. Workshop consumes 500 credits, rare materials, and man-hours over 7 days. Completion creates unit with Pilot class, rank 2, seeded cosmetics, but unequipped requiring gear assignment.

### Cost Calculation with Modifiers
Muton heavy trooper base cost 1000 credits × 1.5 (race multiplier) × 1.3 (class multiplier) × 0.8 (recruitment center discount) × 0.9 (research reduction) = 1404 credits total, with UI showing complete cost breakdown.

### Black Market Acquisition
Player unlocks black market contact through reputation. Purchases Sectoid specialist for premium cost with 2-day delivery. Transfer follows standard logistics but acquisition logged with reputation impact for campaign consequences.

## Related Wiki Pages

- [Classes.md](../units/Classes.md) - Unit class selection and specialization
- [Races.md](../units/Races.md) - Race selection and compatibility
- [Inventory.md](../units/Inventory.md) - Equipment setup and provisioning
- [Basescape.md](../basescape/Basescape.md) - Manufacturing facilities and workshops
- [Transfers.md](../economy/Transfers.md) - Delivery logistics and timing
- [Research tree.md](../economy/Research%20tree.md) - Unlock requirements and recipes
- [Finance.md](../finance/Finance.md) - Cost calculation and payment systems
- [Economy.md](../economy/Economy.md) - Resource management and manufacturing
- [Black market.md](../economy/Black%20market.md) - Alternative recruitment channels
- [Geoscape.md](../geoscape/Geoscape.md) - Marketplace access and global recruitment

## References to Existing Games and Mechanics

- **X-COM Series**: Soldier recruitment and training programs
- **Fire Emblem Series**: Character recruitment and joining mechanics
- **Final Fantasy Tactics**: Character joining and recruitment systems
- **Advance Wars**: CO recruitment and command selection
- **Tactics Ogre**: Character recruitment and party building
- **Disgaea Series**: Character recruitment and dark assembly
- **Persona Series**: Social link recruitment and party building
- **Mass Effect Series**: Squad recruitment and companion systems
- **Dragon Age Series**: Companion recruitment and party management
- **Fallout Series**: Companion recruitment and faction systems

