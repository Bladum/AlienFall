# Cover and Crouch System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Occlusion-Based Cover Evaluation](#occlusion-based-cover-evaluation)
  - [Crouch Action Mechanics](#crouch-action-mechanics)
  - [Material Properties System](#material-properties-system)
  - [Flanking and Positioning Mechanics](#flanking-and-positioning-mechanics)
  - [Obscurant and Environmental Effects](#obscurant-and-environmental-effects)
  - [Equipment and Ability Integration](#equipment-and-ability-integration)
- [Examples](#examples)
  - [Basic Cover Scenarios](#basic-cover-scenarios)
  - [Crouch Effectiveness Examples](#crouch-effectiveness-examples)
  - [Flanking Mechanics Examples](#flanking-mechanics-examples)
  - [Material Interaction Examples](#material-interaction-examples)
  - [Complex Tactical Scenarios](#complex-tactical-scenarios)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Cover and Crouch system implements geometry-driven defensive mechanics that translate map occlusion, object materials, and approach angles into predictable accuracy modifiers. The system creates tactical depth through environmental interaction, enabling players to use terrain and positioning for strategic advantage in combat scenarios. Cover effectiveness is determined by actual map geometry rather than discrete tiers, providing continuous accuracy modifiers that reward precise positioning and tactical awareness.

The system integrates seamlessly with line-of-sight and line-of-fire calculations, maintaining deterministic outcomes through seeded random number generation. All cover interactions are data-driven, supporting extensive modding while ensuring reproducible results for testing and multiplayer synchronization.

## Mechanics

### Occlusion-Based Cover Evaluation
Geometry-first defensive calculations using raycasting analysis:
- Line-of-Fire Tracing: Utilizes same raycasting system as line-of-sight calculations
- Cumulative Occlusion: Each intervening object contributes to total accuracy reduction
- Object Interception: Shots may hit cover objects instead of intended targets
- Material Absorption: Different materials provide varying projectile resistance
- Approach Angle Effects: Attack direction influences cover effectiveness

### Crouch Action Mechanics
Posture-based defensive system with tactical trade-offs:
- Action Cost: 1 Action Point to enter crouched posture
- Defensive Bonus: 20% accuracy reduction for all incoming attacks
- Weapon Integration: Some weapons provide additional bonuses when fired from crouch
- Mobility Tradeoff: Reduced movement capabilities while crouched
- State Persistence: Crouch state maintained until unit moves or explicitly stands

### Material Properties System
Object characteristics affecting cover effectiveness:
- Wood: Moderate occlusion with flammable properties and ricochet potential
- Metal: High occlusion with superior projectile resistance
- Stone/Concrete: Maximum occlusion with blast resistance and durability
- Glass: Low occlusion with shattering mechanics and visibility penalties
- Vegetation: Variable occlusion based on density and environmental conditions

### Flanking and Positioning Mechanics
Angle-based attack modifiers for tactical positioning:
- Frontal Attacks: Full cover effectiveness against direct approaches
- Side Attacks: Reduced cover effectiveness with flanking accuracy bonuses
- Rear Attacks: Maximum flanking bonuses for surprise and tactical advantage
- Elevation Effects: Height differences affecting cover calculations and flanking
- Multi-Object Scenarios: Complex cover interactions with multiple occluding elements

### Obscurant and Environmental Effects
Visibility-reducing elements modifying cover calculations:
- Smoke Clouds: Progressive accuracy reduction based on density and thickness
- Fire Effects: Heat distortion and visibility impairment from flames
- Environmental Hazards: Fog, dust, and other natural visibility reducers
- Temporary Effects: Time-limited obscurants from equipment or abilities
- Stacking Modifiers: Combined effects from multiple environmental sources

### Equipment and Ability Integration
Gear and character abilities enhancing defensive capabilities:
- Armor Modifications: Personal armor affecting crouch effectiveness and durability
- Weapon Accessories: Scopes and attachments modifying crouch firing bonuses
- Utility Items: Smoke grenades and concealment devices creating obscurants
- Trait Bonuses: Character abilities enhancing cover usage and effectiveness
- Active Abilities: Temporary defensive enhancements and protective bursts

## Examples

### Basic Cover Scenarios
- Low Wall: 40% occlusion from frontal approach, 20% from flanking angle
- Solid Wall: 80% occlusion regardless of approach angle with high interception chance
- Window: 30% occlusion with 25% chance to hit glass instead of target
- Vehicle: 60% occlusion with material-based damage absorption and ricochet potential
- Crate: 50% occlusion with destructible properties and moderate interception

### Crouch Effectiveness Examples
- Standard Crouch: -20% incoming accuracy for all attacks while maintaining position
- Sniper Rifle Bonus: +50% accuracy when firing from crouched position for stability
- SMG Penalty: -10% accuracy when firing from crouched position due to weapon characteristics
- Combined Effects: Defender crouch bonus vs. attacker crouch penalties in engagements
- Mobility Impact: Reduced movement range while maintaining defensive posture

### Flanking Mechanics Examples
- 90-degree Flank: +25% accuracy bonus for attacks from side approaches
- 180-degree Rear: +50% accuracy bonus for surprise rear attacks
- Partial Exposure: -15% cover effectiveness for oblique approach angles
- Multiple Angles: Complex calculations for attacks through compound cover scenarios
- Elevation Flanking: Height-based flanking opportunities and defensive disadvantages

### Material Interaction Examples
- Wooden Crate: 45% occlusion, flammable, 30% interception chance, moderate durability
- Metal Barrel: 65% occlusion, ricochet potential, 20% interception chance, high durability
- Concrete Wall: 85% occlusion, blast resistant, 80% interception chance, maximum durability
- Glass Window: 25% occlusion, shattering mechanics, 60% interception chance, low durability
- Dense Bush: 35% occlusion, flammable, variable interception based on thickness

### Complex Tactical Scenarios
- Urban Firefight: Buildings, vehicles, and rubble creating interlocking fields of fire with multiple cover opportunities
- Forest Combat: Trees and underbrush providing variable cover with flanking possibilities through vegetation
- Indoor Battles: Doors, furniture, and architectural features serving as tactical cover elements
- Destructible Environments: Cover that can be destroyed or modified during combat, changing tactical situations
- Multi-Level Combat: Elevation changes affecting cover effectiveness and creating flanking opportunities

## Related Wiki Pages

- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Visibility calculations affected by cover and crouching posture.
- [Line of Fire.md](../battlescape/Line%20of%20Fire.md) - Firing path requirements interacting with cover objects and materials.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Defensive bonuses from cover and crouch reducing incoming accuracy.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height differences impacting cover effectiveness and flanking angles.
- [Smoke & Fire.md](../battlescape/Smoke%20&%20Fire.md) - Environmental effects modifying cover and visibility.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Actions for crouching and positioning behind cover.
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Environmental conditions influencing cover evaluation.
- [Terrain damage.md](../battlescape/Terrain%20damage.md) - Destructible cover that changes tactical situations.
- [Battle tile.md](../battlescape/Battle%20tile.md) - Terrain features providing natural cover opportunities.
- [Concealment.md](../battlescape/Concealment.md) - Stealth mechanics interacting with cover and positioning.
- [Sizes.md](../units/Sizes.md) - Unit dimensions affecting crouch effectiveness and cover usage.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI pathfinding and positioning around cover elements.

## References to Existing Games and Mechanics

The Cover and Crouch system draws from cover-based tactics in action and strategy games:

- **X-COM series (1994-2016)**: Half and full cover bonuses with flanking penalties for exposed units.
- **Gears of War series (2006-2019)**: Destructible cover and active reload mechanics with positioning.
- **Halo series (2001-2022)**: Shield regeneration behind cover and angle-based damage modifiers.
- **Rainbow Six Siege (2015)**: Destructible environments with material-based cover destruction.
- **Battlefield series (2002-2021)**: Leaning and blind-firing from cover positions.
- **Call of Duty series (2003-2023)**: Crouch and prone stances affecting hitboxes and accuracy.
- **Tom Clancy's Ghost Recon (2001-2017)**: Squad-based cover tactics with suppression and flanking.
- **Insurgency (2014)**: Realistic bullet penetration through different cover materials.

