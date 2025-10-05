# Craft Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Chassis Class Framework](#chassis-class-framework)
  - [Loadout and Energy System](#loadout-and-energy-system)
  - [Fuel and Range Management](#fuel-and-range-management)
  - [Equipment Slot System](#equipment-slot-system)
  - [Crew and Promotion System](#crew-and-promotion-system)
  - [Operational Economics](#operational-economics)
  - [Mission Integration](#mission-integration)
  - [Deterministic Processing](#deterministic-processing)
- [Examples](#examples)
  - [Chassis Progression](#chassis-progression)
  - [Energy Pool Calculations](#energy-pool-calculations)
  - [Range and Fuel Operations](#range-and-fuel-operations)
  - [Loadout Configurations](#loadout-configurations)
  - [Crew Promotion Benefits](#crew-promotion-benefits)
  - [Economic Impact Analysis](#economic-impact-analysis)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Craft Systems bridge strategic geoscape operations, tactical interception combat, and battlescape deployment mechanics through unified vehicle management framework. Crafts serve as primary strategic mobility assets delivering squads to missions, contesting UFOs through aerial engagements, and protecting bases via interception capabilities while consuming finite resources including fuel, maintenance, and pilot salaries. The system emphasizes clear role distinction between interceptors, transports, bombers, and hybrid configurations through chassis progression, loadout customization, and operational economics creating meaningful strategic trade-offs throughout campaign progression.

The framework establishes comprehensive management spanning chassis classes with baseline statistics, equipment loadout systems with energy pool mechanics, fuel-based range limitations, crew experience tracking through promotion tiers, and economic integration with construction costs and monthly operating expenses. Crafts interface seamlessly with interception combat grid positioning, basescape hangar management, unit drop capacity calculations, and economy manufacturing pipelines. All mechanics operate through data-driven configuration enabling extensive modding while maintaining deterministic reproducibility for testing and gameplay consistency.

## Mechanics

### Chassis Class Framework
Craft vehicle types defined through comprehensive baseline specifications:
- Statistical Definitions: Speed, range, armor, hull HP, hardpoints, crew seats, cargo capacity per chassis
- Research Gating: Technology milestones and economic investment requirements unlock advanced chassis
- Capability Tags: Air, naval, underwater, stealth classifications drive mission type availability
- Data Configuration: All chassis parameters stored in `data/crafts/chassis.toml` for mod customization
- Progression Paths: Clear upgrade sequences from basic interceptors through advanced multi-role platforms

### Loadout and Energy System
Equipment slot management with energy pool resource mechanics:
- Slot Configuration: EXACTLY up to 2 weapon slots plus 1 addon slot per craft with craft-specific items only
- No Ammunition System: Crafts utilize energy pool plus regeneration identical to unit mechanics replacing ammo consumption
- Energy Pool Calculation: Total EP equals craft base EP plus weapon 1 EP plus weapon 2 EP plus addon EP
- Regeneration System: Total regen per turn equals craft base regen plus equipment regen bonuses
- Action Point Costs: Weapons consume both AP per interception round and energy from shared pool per `data/crafts/items.toml`
- Always Ready: No rearming requirements as energy costs included in item purchase prices for immediate post-mission readiness

### Fuel and Range Management
Resource-constrained strategic mobility with deterministic calculations:
- Range Measurement: Province hop units with default craft traversing 3 hops per day at speed tier 3
- Fuel Deduction: Resource items consumed from launching base on dispatch with explicit accounting
- Refuel Timing: Deterministic duration calculations for returned craft refueling at base facilities
- Daily Action Limits: Speed stat constrains sorties per day (speed 3 enables three daily sorties maximum)
- Mission Timestamps: Launch and return times captured with mission seeds ensuring reproducible operations

### Equipment Slot System
Hardpoint mounting and cargo capacity with validation enforcement:
- Weapon Hardpoints: 0-2 mounting slots for offensive armament installation with compatibility checking
- Addon Mounting: 0-1 auxiliary slot for support equipment and system modifications
- Item Cargo System: Unified capacity tracking weapons, addons, and equipment with size-based limitations
- Pre-Deployment Validation: Configuration checks preventing over-capacity or incompatible loadouts before launch
- Interception Grid Mapping: Hardpoints convert to UI slots on 3×3 tactical grid with cooldown tracking

### Crew and Promotion System
Experience-based progression mechanics rewarding operational performance:
- Mission History Tracking: Per-craft sortie counts and outcome recording for promotion threshold calculation
- Reliability Perks: Faster turnaround times, accuracy bonuses, reduced crash probability through experience tiers
- Deterministic Progression: Promotion table keyed to sorties survived with reproducible advancement triggers
- Modest Effects: Capped bonuses preventing runaway power creep while rewarding veteran craft investment
- Salary Scaling: Experience-based crew compensation forwarded to monthly finance calculations

### Operational Economics
Resource consumption and maintenance cost integration:
- Construction Costs: Initial chassis build expenses drawing from manufacturing economy system
- Monthly Maintenance: Recurring operating expenses computed per craft and forwarded to finance tracking
- Crew Salaries: Experience-scaled pilot compensation contributing to monthly basescape expenses
- Fuel Consumption: Per-mission resource depletion from base stockpiles requiring supply chain management
- Cost-Benefit Analysis: Strategic decisions balancing capability enhancement against economic sustainability

### Mission Integration
Comprehensive connectivity across all gameplay systems:
- Geoscape Validation: Craft registry service enables mission assignment checks and range verification
- Interception State: Loadout data drives 3×3 grid weapon placement with frame-accurate cooldown updates
- Battlescape Deployment: Unit capacity calculations determine squad size and equipment availability
- Hangar Management: Base facility integration tracks repair status, refueling progress, and availability
- Event Broadcasting: State changes publish `craft:dispatched`, `craft:returned`, `craft:loadout_changed`, `craft:promoted`, `craft:maintenance_due`

### Deterministic Processing
Reproducible gameplay through seeded randomization and state consistency:
- Combat Resolution: Interception outcomes use mission-seeded RNG for replay validation
- Fuel Calculations: Fixed formulas prevent floating-point accumulation errors across campaign duration
- Promotion Triggers: Deterministic threshold checks ensure identical progression across sessions
- Event Scheduling: Maintenance requirements and refueling durations follow precise timing rules
- Save/Load Integrity: Complete craft state persistence with validation on restoration

## Examples

### Chassis Progression
Early campaign basic interceptor (speed 800 km/h, range 2000 km, 1 weapon slot, 50 HP hull) provides initial UFO response capability at $500K construction cost. Mid-campaign advanced interceptor upgrades to speed 1200 km/h, range 3000 km, 2 weapon slots, 80 HP hull at $1.5M investment enabling multi-weapon loadouts. Late-campaign stealth interceptor achieves speed 1500 km/h, range 4000 km, 2 weapon slots plus 1 addon, 100 HP hull, 50% stealth modifier at $3M cost representing peak aerial combat platform.

### Energy Pool Calculations
Standard interceptor base energy: 100 EP, base regeneration: 20 EP/turn. Equipped with plasma cannon (30 EP contribution, 3 EP regen) and missile launcher (20 EP contribution, 2 EP regen). Total energy pool: 100 + 30 + 20 = 150 EP maximum. Total regeneration: 20 + 3 + 2 = 25 EP per turn. Plasma cannon costs 40 EP per shot, missile launcher costs 30 EP per shot. Full energy enables 3 plasma shots or 5 missile shots or mixed loadout combinations before requiring regeneration turns.

### Range and Fuel Operations
Medium transport (range 6 provinces, speed 2, fuel 10 units per province) dispatched on 5-province mission. Fuel cost: 5 × 2 × 10 = 100 fuel units deducted from base stockpile. Mission duration: 5 provinces at speed 2 = 2.5 days travel time. Return requires 100 additional fuel units. Post-mission refueling: 12-hour deterministic duration before craft availability restored. Daily sortie limit: Speed 2 enables two missions per day maximum.

### Loadout Configurations
Fighter craft (2 weapon slots, 1 addon slot, 200 cargo capacity) configured with autocannon (4 weight, 1 weapon slot), plasma beam (8 weight, 1 weapon slot), and shield generator (6 weight, 1 addon slot). Total loadout: 18 weight against 200 capacity (valid). Total slots: 3/3 used (valid). Configuration approved for deployment. Attempting to add third weapon triggers validation error: maximum 2 weapon slots enforced regardless of cargo capacity.

### Crew Promotion Benefits
Rookie crew (0 sorties) operates at baseline: 100% turnaround time, 100% accuracy, 5% crash probability. Veteran crew (50 sorties survived) achieves promotion tier 3: 85% turnaround time, 110% accuracy bonus, 2% crash probability. Elite crew (150 sorties) reaches promotion tier 5: 70% turnaround time, 125% accuracy bonus, 1% crash probability. Salary scaling: Rookie $5K monthly, Veteran $8K monthly, Elite $12K monthly reflecting experience value.

### Economic Impact Analysis
Base operating 4 interceptors (2 rookies, 1 veteran, 1 elite) incurs monthly costs: Construction amortization $200K, crew salaries $33K total, maintenance $40K, fuel consumption $80K average. Total monthly operating cost: $353K for interception capability. Compare against funding impact: successful interceptions provide $100K bounties, failed UFOs cost $200K panic penalties. Break-even requires 3.5 successful interceptions monthly demonstrating economic pressure driving strategic efficiency optimization.

## Related Wiki Pages

- [Classes.md](Classes.md) - Chassis types and vehicle classifications
- [Stats.md](Stats.md) - Performance statistics and attribute systems
- [Energy.md](Energy.md) - Energy pool and regeneration mechanics
- [Fuel & range.md](Fuel%20&%20range.md) - Range limitations and fuel consumption
- [Encumbrance.md](Encumbrance.md) - Cargo capacity and weight systems
- [Items.md](Items.md) - Craft equipment and weapon specifications
- [Inventory.md](Inventory.md) - Equipment management and loadout systems
- [Promotion.md](Promotion.md) - Crew experience and advancement
- [Salaries.md](Salaries.md) - Economic costs and compensation
- [Craft item.md](Craft%20item.md) - Item specifications and compatibility
- [Interception](../interception/README.md) - Combat mechanics integration
- [Geoscape](../geoscape/README.md) - Strategic operations and deployment
- [Economy](../economy/README.md) - Manufacturing and resource management
- [Finance](../finance/README.md) - Cost tracking and budget management

## References to Existing Games and Mechanics

- **XCOM Series**: Interceptor management and aerial combat systems
- **UFO: Enemy Unknown**: Craft procurement and interception mechanics
- **XCom: Apocalypse**: Multi-role craft and equipment customization
- **Phoenix Point**: Aircraft management and fuel consumption
- **Xenonauts**: Craft progression and loadout systems
- **Battletech**: Vehicle customization and hardpoint management
- **FTL**: Ship systems and energy management mechanics
- **Into the Breach**: Grid-based tactical positioning systems
- **Homeworld**: Fleet management and resource economics
- **Master of Orion**: Ship design and equipment slots
### Chassis Classes
- Baseline stats defined for each chassis: speed, range, armour, hull HP, hardpoints, crew seats, cargo capacity.
- Unlocks gated by research milestones and economy investment; stored in `data/crafts/chassis.toml`.
- Chassis tags (e.g., `air`, `naval`, `underwater`, `stealth`) drive availability in specific mission types.

### Loadouts & Energy System
- **CRITICAL**: Each craft has EXACTLY **up to 2 weapon slots + 1 addon slot**. All items must be craft item type.
- **NO AMMUNITION OR CLIPS**: Crafts use an energy pool + regeneration system identical to units.
- **Energy Pool Calculation**: Total EP = Craft Base EP + Weapon 1 EP + Weapon 2 EP + Addon EP
- **Energy Regeneration**: Total regen per turn = Craft Base Regen + equipment regen bonuses
- **Weapon Costs**: Weapons consume AP (per interception round) and Energy (from shared pool) defined in `data/crafts/items.toml`.
- **No Rearming**: Energy costs are included in item purchase prices - crafts are always ready for combat after returning to base.

### Fuel, Range, and Turn Economy
- Range measured in province hops—default craft can traverse 3 hops per day at speed tier 3.
- Fuel is deducted from the launching base on dispatch; returning craft refuel over deterministic durations.
- Craft actions per day limited by speed stat (e.g., speed 3 = three sorties). Mission seeds capture launch/return timestamps for reproducibility.

### Crew & Promotions
- Crafts track mission history for reliability perks (faster turnaround, accuracy bonuses, reduced crash chance).
- Promotions follow a deterministic table keyed to sorties survived. Effects are modest and capped to prevent runaway power.
- Crew salaries and maintenance costs are computed monthly and forwarded to the finance system.

## Implementation Hooks
- **Geoscape Integration:** Craft data exposed via `CraftRegistry` service; geoscape uses it to validate mission assignments and range checks.
- **Interception State:** Hardpoints convert to UI slots on the 3×3 grid. Weapon cooldowns update every Love2D frame while the interception state is active.
- **Data Tables:** `data/crafts/chassis.toml`, `data/crafts/items.toml`, `data/crafts/promotions.toml`, `data/crafts/fuel.toml`.
- **Events:** `craft:dispatched`, `craft:returned`, `craft:loadout_changed`, `craft:promoted`, `craft:maintenance_due`.

## Grid & Visual Standards
- Hangar UI uses the same 20×20 logical grid; craft silhouettes are 10×10 sprites scaled ×2 and centred on their slots.
- Interception icons align to the 3×3 grid; each grid cell equates to a 60×60 logical area (3 tiles) for readability.

## Data & Tags
- Chassis tags: `interceptor`, `dropship`, `bomber`, `support`, `naval`, `underwater`.
- Weapon tags: `air_to_air`, `air_to_ground`, `naval`, `support`, `utility`.
- Maintenance tags: `low`, `standard`, `high` cost tiers for finance balancing.

## Related Reading
- [Interception README](../interception/README.md)
- [Geoscape README](../geoscape/README.md)
- [Economy README](../economy/README.md)
- [Units README](../units/README.md)
- [Finance README](../finance/README.md)

## Tags
`#crafts` `#interception` `#geoscape` `#economy` `#love2d`
