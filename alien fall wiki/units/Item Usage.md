# Item Usage

## Table of Contents
- [Overview](#overview)
  - [Core Design Principles](#core-design-principles)
  - [System Integration Points](#system-integration-points)
- [Mechanics](#mechanics)
  - [Item Usage Types](#item-usage-types)
    - [Consumable Items](#consumable-items)
    - [Throwable Items](#throwable-items)
    - [Deployable Items](#deployable-items)
    - [Equipment Items](#equipment-items)
  - [Target Validation Mechanics](#target-validation-mechanics)
    - [Target Type Categories](#target-type-categories)
    - [Validation Rules](#validation-rules)
    - [Distance Calculation](#distance-calculation)
  - [Usage Prerequisites](#usage-prerequisites)
    - [Health-Based Prerequisites](#health-based-prerequisites)
    - [Experience-Based Prerequisites](#experience-based-prerequisites)
    - [Trait-Based Prerequisites](#trait-based-prerequisites)
    - [Equipment Prerequisites](#equipment-prerequisites)
  - [Effect Application](#effect-application)
    - [Effect Types](#effect-types)
    - [Effect Targeting](#effect-targeting)
    - [Effect Stacking](#effect-stacking)
  - [Area Effects](#area-effects)
    - [Area Shape Definitions](#area-shape-definitions)
    - [Coverage Rules](#coverage-rules)
    - [Effect Falloff](#effect-falloff)
  - [Cooldown and Charge System](#cooldown-and-charge-system)
    - [Cooldown Mechanics](#cooldown-mechanics)
    - [Charge System](#charge-system)
    - [Resource Integration](#resource-integration)
  - [Throwable Item Mechanics](#throwable-item-mechanics)
    - [Trajectory Calculation](#trajectory-calculation)
    - [Interception Mechanics](#interception-mechanics)
    - [Landing Effects](#landing-effects)
  - [Deployable Item Mechanics](#deployable-item-mechanics)
    - [Deployment Rules](#deployment-rules)
    - [Duration Management](#duration-management)
    - [Ongoing Effects](#ongoing-effects)
  - [Trajectory and Interception](#trajectory-and-interception)
    - [Projectile Physics](#projectile-physics)
    - [Interception System](#interception-system)
    - [Environmental Effects](#environmental-effects)
  - [Usage History and Provenance](#usage-history-and-provenance)
    - [Event Logging](#event-logging)
    - [Analytics Integration](#analytics-integration)
    - [Replay Support](#replay-support)
  - [Modding Integration](#modding-integration)
    - [Item Definition Extension](#item-definition-extension)
    - [System Override Capabilities](#system-override-capabilities)
    - [API Integration Points](#api-integration-points)
- [Examples](#examples)
  - [Basic Consumable Usage](#basic-consumable-usage)
  - [Throwable Area Effect](#throwable-area-effect)
  - [Deployable Surveillance](#deployable-surveillance)
  - [Cooldown-Restricted Item](#cooldown-restricted-item)
  - [Complex Targeting Validation](#complex-targeting-validation)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Item Usage System defines how units interact with inventory items during gameplay, enabling tactical item deployment, healing, damage, and battlefield control. This system transforms static inventory items into active gameplay mechanics with validation, effects, and strategic timing considerations.

### Core Design Principles
- Tactical Item Integration: Items provide meaningful combat choices without trivializing core mechanics
- Deterministic Usage: All item usage follows predictable rules with full provenance tracking
- Flexible Targeting: Support for self, ally, enemy, and positional targeting with range limitations
- Resource Management: Items consume inventory slots, charges, or energy with appropriate restrictions
- Effect Diversity: Support for immediate, area, and duration-based effects

### System Integration Points
- Inventory System: Item availability and consumption tracking
- Stats System: Effect application and prerequisite validation
- Battle Map System: Range calculation, line-of-sight, and positioning
- Status Effect System: Temporary condition application and removal
- Energy System: Energy-based item consumption
- Morale System: Psychological effect application

## Mechanics

### Item Usage Types

#### Consumable Items
Single-use items that provide immediate effects and are removed from inventory after use.

Mechanics:
- Consumption Type: Items are permanently removed after single use
- Effect Timing: Effects apply immediately upon usage
- Inventory Impact: Reduces item quantity by one
- No Persistence: Effects end when duration expires (if applicable)

Design Considerations:
- Consumables provide reliable but limited tactical options
- Players must manage limited supplies strategically
- Effects can be healing, stat boosts, or status applications

#### Throwable Items
Items that can be thrown at targets or positions with trajectory mechanics.

Mechanics:
- Range Limitation: Maximum throw distance based on unit strength and item properties
- Trajectory Calculation: Arcing projectile path with interception possibilities
- Impact Effects: Effects apply at landing position
- Area Coverage: Can affect multiple units within radius

Design Considerations:
- Throwable items add positioning strategy to combat
- Trajectory adds skill element to usage
- Area effects provide crowd control options

#### Deployable Items
Items that create persistent battlefield objects with ongoing effects.

Mechanics:
- Placement Rules: Can be deployed at valid positions within range
- Duration Tracking: Effects persist for specified time periods
- Ongoing Effects: Continuous area effects while active
- Expiration Handling: Automatic removal when duration ends

Design Considerations:
- Deployables create semi-permanent tactical advantages
- Duration management adds timing strategy
- Multiple deployables can create complex battlefield states

#### Equipment Items
Items that modify unit capabilities while equipped.

Mechanics:
- Activation State: Items provide passive bonuses while equipped
- Toggle Options: Can be activated/deactivated during combat
- Resource Costs: May consume energy or have cooldowns
- Compatibility Rules: Equipment restrictions based on class/traits

Design Considerations:
- Equipment items provide persistent tactical advantages
- Activation costs prevent spamming
- Compatibility rules enforce class specialization

### Target Validation Mechanics

#### Target Type Categories
- Self: Items usable only on the owning unit
- Ally: Items usable on friendly units
- Enemy: Items usable on hostile units
- Position: Items usable at map locations
- Area: Items affecting regions around targets

#### Validation Rules
- Range Checking: Distance limitations between user and target
- Line-of-Sight: Visibility requirements for targeting
- Team Affiliation: Ally/enemy status verification
- Unit State: Target must be alive and active
- Position Validity: Deployment locations must be accessible

#### Distance Calculation
- Grid-Based Measurement: Distance measured in map tiles
- Diagonal Movement: Optional diagonal distance consideration
- Elevation Effects: Height differences may affect range
- Terrain Modifiers: Some terrain may block or extend range

### Usage Prerequisites

#### Health-Based Prerequisites
- Minimum Health Percentage: Items requiring units to be below certain health thresholds
- Maximum Health Percentage: Items restricted to healthy units
- Status Requirements: Items requiring or prohibiting specific status effects

#### Experience-Based Prerequisites
- Experience Thresholds: Items requiring minimum experience levels
- Skill Requirements: Items needing specific abilities or training
- Rank Restrictions: Items limited to certain unit ranks

#### Trait-Based Prerequisites
- Required Traits: Items needing specific racial or class traits
- Trait Combinations: Items requiring multiple trait prerequisites
- Trait Exclusions: Items incompatible with certain traits

#### Equipment Prerequisites
- Required Equipment: Items needing specific gear to function
- Equipment Restrictions: Items incompatible with certain equipment
- Loadout Requirements: Items needing specific equipment combinations

### Effect Application

#### Effect Types
- Stat Modification: Direct changes to unit statistics
- Percentage Boosts: Proportional stat increases/decreases
- Status Application: Temporary condition infliction
- Status Removal: Condition curing or prevention
- Ability Granting: Temporary capability addition
- Energy Modification: Energy pool changes
- Morale Changes: Psychological effect application

#### Effect Targeting
- Primary Target: Main effect recipient
- Area Effects: Multiple units affected in radius
- Chain Effects: Effects spreading to adjacent units
- Conditional Effects: Effects based on target state

#### Effect Stacking
- Stacking Rules: How multiple effects of same type combine
- Override Behavior: How newer effects replace older ones
- Duration Extension: How repeated applications extend effects
- Maximum Stacks: Limits on concurrent effect instances

### Area Effects

#### Area Shape Definitions
- Circular Areas: Standard radius-based coverage
- Rectangular Areas: Width/depth coverage patterns
- Cone Areas: Directional area projections
- Line Areas: Linear effect paths

#### Coverage Rules
- Unit Inclusion: Which units are affected by area
- Partial Coverage: Effects on units near area edges
- Line-of-Sight Blocking: Terrain blocking area effects
- Friendly Fire: Whether area effects damage allies

#### Effect Falloff
- Distance Scaling: Reduced effects at range edges
- Center Intensity: Maximum effects at center point
- Minimum Threshold: Effects below certain thresholds ignored
- Terrain Absorption: Environmental effect reduction

### Cooldown and Charge System

#### Cooldown Mechanics
- Usage Tracking: Time since last item usage
- Cooldown Duration: Fixed or variable reset times
- Remaining Time: Current cooldown progress
- Ready Status: Whether item can be used again

#### Charge System
- Charge Tracking: Available usage count per item
- Charge Consumption: Usage cost per activation
- Charge Regeneration: Automatic or manual charge recovery
- Charge Limits: Maximum charge capacity

#### Resource Integration
- Energy Costs: Energy consumption for usage
- Ammo Pools: Shared ammunition resources
- Battery Systems: Depletable power sources
- Fuel Requirements: Consumable fuel resources

### Throwable Item Mechanics

#### Trajectory Calculation
- Launch Physics: Initial velocity and angle determination
- Arc Path: Curved projectile flight path
- Gravity Effects: Projectile drop over distance
- Wind Influence: Environmental trajectory modification

#### Interception Mechanics
- Interception Detection: Units that can block projectiles
- Timing Windows: When interception is possible
- Success Chances: Probability of successful interception
- Interception Effects: Consequences of blocked throws

#### Landing Effects
- Impact Position: Final projectile resting location
- Bounce Mechanics: Projectile scattering on impact
- Terrain Interaction: Environmental effect modification
- Secondary Effects: Additional consequences of landing

### Deployable Item Mechanics

#### Deployment Rules
- Placement Validation: Valid deployment locations
- Proximity Restrictions: Distance limits from other objects
- Terrain Requirements: Surface type restrictions
- Overlap Prevention: Preventing deployment conflicts

#### Duration Management
- Fixed Duration: Set lifetime for deployed items
- Conditional Duration: Effects ending on trigger conditions
- Infinite Duration: Permanent battlefield objects
- Extension Options: Ways to prolong deployment

#### Ongoing Effects
- Periodic Effects: Regular effect application
- Aura Effects: Continuous area influence
- Trigger Effects: Effects activating on conditions
- Interaction Effects: Effects on nearby units/objects

### Trajectory and Interception

#### Projectile Physics
- Initial Velocity: Launch speed determination
- Angle Calculation: Optimal throw angle for distance
- Air Resistance: Speed reduction over distance
- Terminal Velocity: Maximum projectile speed

#### Interception System
- Detection Range: How far interceptors can detect projectiles
- Reaction Time: Time available for interception attempts
- Success Factors: Accuracy, speed, and positioning effects
- Counterplay: Ways to avoid or prevent interception

#### Environmental Effects
- Wind Patterns: Directional air current influence
- Terrain Blocking: Obstacles stopping projectiles
- Weather Impact: Precipitation and visibility effects
- Elevation Changes: Height difference trajectory modification

### Usage History and Provenance

#### Event Logging
- Usage Records: Complete history of item usage
- Effect Tracking: All applied effects and outcomes
- Context Preservation: Usage circumstances and conditions
- Seed Recording: Random seed for deterministic replay

#### Analytics Integration
- Usage Statistics: Frequency and success rate tracking
- Effectiveness Metrics: Impact measurement and analysis
- Pattern Recognition: Usage behavior identification
- Balance Assessment: Item performance evaluation

#### Replay Support
- Deterministic Recreation: Exact usage recreation from logs
- State Verification: Confirming logged outcomes
- Debug Information: Detailed usage context for troubleshooting
- Balance Testing: Historical usage analysis

### Modding Integration

#### Item Definition Extension
- Custom Usage Types: New categories of item usage
- Effect Type Addition: New effect categories
- Prerequisite Types: New requirement categories
- Targeting Rules: Custom target validation logic

#### System Override Capabilities
- Validation Modification: Custom prerequisite checking
- Effect Application: Alternative effect resolution
- Cooldown Systems: Custom timing mechanics
- Resource Integration: Alternative resource consumption

#### API Integration Points
- Usage Registration: Adding new item usage definitions
- Effect Registration: Adding new effect types
- Validation Hooks: Custom validation logic insertion
- Event Callbacks: Usage event interception and modification

## Examples

### Basic Consumable Usage
A soldier with 60 health uses a medikit requiring health below 75%. The system validates the prerequisite, applies 25 healing (raising health to 85), removes one medikit from inventory, and records the usage with timestamp and effects.

### Throwable Area Effect
A grenadier throws a grenade at an enemy cluster. The system calculates trajectory, checks for interception (none detected), applies 50 damage to all units within 3 tiles of impact, plays explosion effects, and logs the area damage event with affected unit IDs.

### Deployable Surveillance
An engineer deploys a motion scanner at a strategic position. The system validates placement, creates a persistent entity revealing 15-tile radius for 10 minutes, applies immediate reveal effect, schedules expiration, and tracks deployment in provenance logs.

### Cooldown-Restricted Item
A psi operative uses a psi amplifier requiring psi sensitivity trait. The system validates trait prerequisite, applies 50% psi boost and mind shield ability, sets 30-minute cooldown preventing reuse, and displays remaining cooldown time.

### Complex Targeting Validation
A medic attempts medigel use on a bleeding ally. The system validates ally status, 2-tile range limit, medical training prerequisite, applies 40 healing plus bleeding/poisoned status removal, and logs the targeted healing event.

## Related Wiki Pages

- [Items.md](../items/Items.md) - Item definitions and properties
- [Inventory.md](../units/Inventory.md) - Item storage and management
- [Unit actions.md](../battlescape/Unit%20actions.md) - Action integration for item usage
- [Throwing.md](../battlescape/Throwing.md) - Throwable item mechanics
- [Mission salvage.md](../battlescape/Mission%20salvage.md) - Item recovery and salvage
- [Transfers.md](../economy/Transfers.md) - Item logistics and transfers
- [Encumbrance.md](../units/Encumbrance.md) - Weight and capacity restrictions
- [Classes.md](../units/Classes.md) - Class-specific item usage abilities
- [Research tree.md](../economy/Research%20tree.md) - Item technology and development
- [Modding.md](../technical/Modding.md) - Custom item creation and usage

## References to Existing Games and Mechanics

- **X-COM Series**: Item usage and equipment management in combat
- **Fire Emblem Series**: Item usage, healing, and consumable mechanics
- **Final Fantasy Tactics**: Item command system and battle usage
- **Advance Wars**: Item deployment and terrain modification
- **Tactics Ogre**: Item management and usage in tactical combat
- **Disgaea Series**: Item usage and special abilities in battle
- **Persona Series**: Item usage and support abilities
- **Mass Effect Series**: Item usage and biotic/tech powers
- **Dragon Age Series**: Item usage and tactical abilities
- **Fallout Series**: Item consumption and equipment usage

