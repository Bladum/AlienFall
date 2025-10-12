
# AlienFall Wiki - Game Mechanics Summary

This document provides a high-level overview of all unique game mechanics covered in the AlienFall wiki, organized by topic folder and file. Each bullet point represents a distinct mechanic or system feature.

---

## AI

### AI on Battle
- Utility-based AI decision model with weighted heuristics for action selection
- Deterministic action scoring system (self-preservation, lethality, tactical advantage, ability utility, mission context)
- Data-driven personality profiles (aggressive, cautious, tactical) with configurable weight values
- Focus fire and target prioritization mechanics
- Flank exploitation and cover seeking behaviors
- Seeded randomness for reproducible AI decisions
- Telemetry and provenance logging for debugging and balancing
- Ability cooldown and resource management in AI scoring
- Multi-step tactical planning (move + shoot combos)
- Group coordination behaviors (flanking, pincer attacks)

### AI on Globe (Alien Director)
- Strategic campaign-level AI that schedules missions and applies pressure
- Monthly sampling system for campaign template selection
- Priority-based decision making using player state signals (radar coverage, funding, research progress)
- Adaptive behavior based on theater defense strength
- Legitimate rule-following (no hidden advantages, same detection/resource rules as player)
- Escalation mechanics (more powerful UFOs, base-building campaigns)
- Regional bias and exploitation of uncovered areas
- Terror campaigns targeting high-value funding sources
- Research-driven retaliation campaigns
- Deterministic, seeded campaign generation for reproducibility

---

## Basescape

### Base Bombardment Minigame
- Standoff attack system for UFO bombardment of player bases
- Multi-salvo attack sequences with configurable patterns
- Priority-based facility targeting (command/radar/reactor > hangars > workshops)
- Facility damage and operational threshold mechanics
- Critical hit system causing secondary effects (fires, power grid collapse, cascading failures)
- Damage resolution: HitChance × (1 − FacilityArmorOnBombardment) → DamageRoll
- Reduced salvage and crew outcomes compared to crash/assault
- Emergency repair and recovery mechanics
- Deterministic, seeded bombardment for reproducibility

### Base Defence Minigame
- Fast, deterministic strategic resolution of base attacks
- Facility-based defensive fire phase (turrets, missiles, laser mounts)
- UFO hull damage percentage calculation for outcome determination
- Multi-threshold outcome system (destroyed, catastrophic crash, severe damage, forced landing, escape)
- Onboard alien casualty calculations based on damage
- Service and facility modifiers (radar/fire-control, gravity projector, shield generators)
- Spawn timing for crash/assault missions based on damage thresholds
- Deterministic resolution order for reproducible outcomes
- Facility destruction and offline status tracking

### Capacities
- Unified resource pool system using key→value pairs
- Capacity types: static slots, volume/space, throughput (man-hours/day, research points/day)
- Aggregated base-level capacity from online facilities
- Overflow handling with configurable policies (block, queue, auto-sell, auto-transfer)
- Common capacity keys: manufacturing_capacity, item_storage_capacity, prisoner_capacity, health_recovery_throughput, training_throughput, defence_capacity, research_capacity, unit_quarters, craft_hangar_slots, radar_range_power
- Service tags for enabling features without numeric capacity
- Deterministic allocation and enforcement rules
- UI diagnostics for capacity usage and blocking reasons

### Facilities
- Modular building blocks with configurable footprints (1×1, 2×2, multi-tile)
- Construction lifecycle with building state and completion time
- Connectivity requirement to HQ access lift via corridor paths
- Health, armor, and damage mechanics
- Aggregated capacity contribution to base pool
- Service tag system for feature discovery
- Tactical integration with battle map generator and map blocks
- Maintenance costs and resource consumption
- No implicit adjacency bonuses (must be declared explicitly)
- Immediate failure mode effects when facilities go offline

### Monthly Base Report
- Comprehensive monthly diagnostic and audit system
- Capacity overview with used/available percentages and color indicators
- Population and roster tracking (soldiers, staff, wounded, prisoners)
- Craft and vehicle summary with maintenance costs
- Inventory and days-of-supply calculations
- Financial breakdown (income, expenses, net, debt/interest)
- Bottleneck diagnostics with deterministic top-N constraint identification
- Suggested remedies and quick actions
- Multi-base aggregation with sortable columns
- CSV/JSON export for trend analysis
- Deterministic calculation from authoritative base state

### New Base Building
- Base construction in any land province with configurable restrictions
- Grid-based layout (default 5×5 for Earth, customizable per world)
- Dynamic cost calculation: BaseCost × RegionCostModifier × CountryFundingFactor × WorldMultiplier
- Country funding level impact on construction cost (0-100 range, with steep multipliers)
- Pre-built HQ tile with connectivity requirements
- Excavation system with configurable costs and time
- Cross-world base building with portal transit rules
- Political restrictions based on country cooperation levels
- Mission blockage in provinces with active missions
- World-specific variants (surface bases, encampments, micro-bases)

### Services
- Named service registry with provided and required services
- Daily accounting and supply/demand resolution
- Deterministic priority ordering: critical systems → operations → throughput → optional services
- Throttling and fallback policies for service shortfalls
- Cascading failure and recovery mechanics
- Cross-base service provisioning via transfers
- Service endpoints for automated logistics
- UI diagnostics showing capacity, demand, and blocking reasons
- Common services: power_supply, research, manufacture, craft_repair, radar_service, psi_training, fuel_storage

---

## Battlescape

### Accuracy at Range
- Banded falloff model with discrete range multipliers
- Range ratio calculation: distance / maxRange
- Five accuracy bands: Close (1.00), Near-edge (0.75), Slightly over (0.50), Far over (0.25), Out of range (0.00)
- Data-driven threshold and multiplier configuration
- Deterministic calculation order: base aim × weapon accuracy × range multiplier × other modifiers
- Transparent UI display of range ratio and multipliers

### Action - Cover & Crouch
- Geometry-first occlusion system using LoF/LoS ray tracing
- Fractional occlusion values (not tiered large/small cover)
- Object material, thickness, and approach angle affecting cover
- Crouch action: 1 AP cost, grants 20% incoming accuracy reduction
- Weapon-specific crouch modifiers for firing from crouched position
- Smoke, fire, and obscurant effects on LoS and hit probability
- Equipment and trait modifiers (armor, stealth rigs, shields)
- Integration with sneak and reaction fire systems
- Data-driven occlusion values and cover contributions

### Action - Movement
- Deterministic AP-to-distance conversion system
- Per-step cost model: base orthogonal (2 pts), diagonal multiplier (1.5x), rotation (1 pt per 90°)
- Terrain multipliers applied to step costs
- Fractional AP consumption: APConsumed = TotalMoveCost ÷ Speed
- Continuous AP budget with no forced rounding
- Deterministic path trimming when exceeding available AP
- Transparent per-step cost breakdown for designers and players

### Action - Overwatch (Reaction Fire)
- Reactive fire state with configurable AP enter cost (default 1 AP)
- Reserved AP for reaction execution (consumed only on trigger)
- Trigger conditions based on enemy movement within LoF/LoS
- Deterministic resolution using mission-seeded RNG
- Movement and stance penalties applied to reaction shots
- Multiple trigger ordering with per-turn limits (default 1 reaction)
- Cancellation mechanics and implicit state clearing
- Full integration with LoF and damage pipelines

### Action - Running
- Enhanced movement speed with trade-offs
- AP cost modifiers for run action
- Detection and stealth penalties while running
- Energy consumption mechanics

### Action - Sneaking
- Reduced detection and movement modifiers
- AP cost adjustments for sneaking
- Concealment mechanics and LoS interactions
- Reaction fire trigger reduction

### Action - Suppressive Fire
- Area denial and morale impact mechanics
- AP and ammunition cost for sustained fire
- Accuracy penalties and threshold calculations
- Decay rates for suppression effects
- Integration with overwatch and reaction fire

### Battle Day & Night
- Time-of-day visibility modifiers
- Sight and sense range adjustments
- Lighting impact on tactical gameplay
- Mission prep preview of day/night conditions

### Battle Map Generator
- Deterministic block-grid assembly from mission seed
- Prefab expansion into tile arrays
- Spawn point and AI node placement
- Reachability validation checks
- Provenance-rich map object generation

### Battle Map
- Tile-based tactical grid representation
- Multi-layer structure (ground, objects, units)
- Elevation and height mechanics

### Battle Side
- Team/faction ownership tracking
- Shared visibility and fog of war per side
- Victory condition checking

### Battle Size
- Configurable mission dimensions and unit counts
- Scaling mechanics for different mission types

### Battle Tile
- Individual tile properties (terrain type, elevation, cover values)
- Destructibility and damage states
- Object placement and interaction

### Concealment
- Stealth mechanics separate from cover
- Detection radius and reveal conditions
- Integration with fog of war

### Enemy Deployments
- Experience budget system for enemy force composition
- Autopromotion and equipment selection rules
- Faction-specific unit pools and role assignments
- Deterministic squad generation from mission parameters

### Lighting & Fog of War
- Numeric sight/sense modifiers by mission time
- Owner-scoped reveal devices (flares, flashlights)
- Personal sight vs side union visibility
- Facing-based vision mechanics
- Seeded determinism for multiplayer parity

### Line of Fire
- Ray tracing for shot validity
- Obstacle interception mechanics
- Cover and occlusion calculation

### Line of Sight
- Vision cone and facing mechanics
- Sense-based detection (sound, motion)
- Blocked and partial visibility states

### Map Blocks
- Prefabricated building blocks for map assembly
- Seam and connection point system
- Reusable content across mission types

### Map Nodes for AI
- Pathfinding and tactical positioning waypoints
- Cover evaluation points
- Objective and interest markers

### Map Scripts
- Mission-specific assembly rules and variations
- Objective placement logic
- Environmental hazard spawning

### Mission Objectives
- Win/loss condition system
- Primary and secondary objective tracking
- Time-limited and rescue objectives

### Mission Preparation
- Loadout and squad selection interface
- Equipment assignment and validation
- Mission briefing and intel preview

### Mission Salvage
- Post-mission loot and resource collection
- Prisoner capture and interrogation unlocks
- XP, Fame, and Karma rewards
- Faction-specific salvage tables

### Morale
- Mission-scoped combat composure resource
- Will test system for stress events
- AP modifiers based on morale level (-4 to +1)
- Panic mechanics when morale ≤ 0
- Recovery actions (REST, Rally, leader auras)
- Stress triggers: friendly deaths, hits, near misses, fire exposure
- Seeded deterministic resolution

### Panic
- Triggered when morale ≤ 0
- Limited action set (recovery behaviors only)
- Clear conditions and recovery mechanics

### Psionics
- Mental attack and defense mechanics
- Psi strength and resistance stats
- Line of sight requirements for psi attacks
- Morale and sanity interaction

### Sanity
- Long-term mental health tracking
- Trauma accumulation and recovery
- Mission availability impact
- Treatment and rehabilitation mechanics

### Smoke & Fire
- Area effect hazards with duration
- Vision obstruction and damage over time
- Spread mechanics and extinguishing

### Squad Autopromotion
- Automated experience-based rank advancement
- Skill and stat increases on promotion
- Class-specific promotion trees

### Surrender
- Conditional enemy surrender mechanics
- Morale and force ratio thresholds
- Prisoner capture without combat

### Terrain Damage
- Destructible environment system
- Material-based damage resistance
- Structural integrity and collapse mechanics
- Data-driven tile type and material stats

### Terrain Elevation
- Multi-level height system
- Height advantage modifiers for accuracy
- Line of sight blocking by elevation

### Throwing
- Grenade and throwable item mechanics
- Arc calculation and range limits
- Scatter and accuracy system

### Unconscious
- Incapacitation state and recovery
- Bleeding out mechanics
- Revival and stabilization actions

### Unit Actions
- Turn-based action system with AP costs
- Action type categories (move, attack, ability, item use)
- Action validation and preview

### Wounds
- Damage location and severity tracking
- Bleeding and ongoing damage effects
- Recovery time and medical treatment

---

## Crafts

### Classes
- Chassis definitions with base stats (speed, range, hull)
- Role archetypes (interceptor, bomber, transport)
- Slot counts and cargo limits
- Cost and research prerequisites
- Progression gating and availability

### Craft Item
- Modular equipment system with mount validation
- Shared action economy (AP, energy, cooldowns) for geoscape and dogfights
- Cargo budget and slot count constraints
- Weapon, sensor, ECM, and support module types
- Data-driven item specifications

### Encumbrance
- Cargo capacity system for craft
- Weight and volume calculations
- Performance penalties for overloading

### Fuel & Range
- Operational reach mechanics tied to fuel consumption
- Pixel-to-km conversion for map geometry
- Refueling and range planning
- Strategic footprint per world

### Inventory
- Equipment slot system for crafts
- Loadout validation and compatibility checks
- Persistent gear between missions

### Promotion
- Crew experience and rank advancement
- Stat bonuses and ability unlocks
- XP sources from missions and training

### Salaries
- Monthly crew pay based on rank and role
- Veteran premiums and hazard pay
- Budget impact and crew retention

### Stats
- Speed, Range, FuelUsage, Hull
- Detection power and sensor capabilities
- Armor and defensive ratings

---

## Economy

### Black Market
- Illicit commerce with reputation penalties
- Faster access to restricted items
- Unique restock rules and pricing
- Legal and diplomatic consequences

### Manufacturing
- Queued production system with man-hour costs
- Workshop capacity and throughput
- Material consumption and time requirements
- Priority and cancellation mechanics

### Marketplace
- Standard commerce interface for equipment and resources
- Data-driven listings, stock, and prerequisites
- Regional availability and pricing
- Deterministic inventory refresh

### Research Entry
- Atomic unit of technological progression
- Cost, time, and prerequisite structure
- Completion effects and unlock chains
- Seeded for reproducible playtests

### Research Tree
- Directed acyclic graph (DAG) of research progression
- Branch points and meaningful choices
- Multi-tree support for different playstyles
- Deterministic, modular entry system

### Suppliers
- Vendor layer controlling market availability
- Contact unlocks gated by research, events, reputation
- Per-supplier stock and delivery rules
- Curated flavor and pacing control

### Transfers
- Inter-base resource and personnel movement
- Transit time and cost calculations
- Capacity reservation system
- Automated and manual transfer requests

---

## Finance

### Debt
- Loan system for cash shortfall management
- Minimum payments and interest rates
- Overdraft conversion mechanics
- Repayment schedules and penalties
- Reputation consequences for fiscal behavior

### Funding
- Recurring income from supporting countries
- Performance-based funding adjustments
- Country funding level (0-100) impact on cooperation
- Withdrawal conditions and recovery paths

### Income Sources
- Multiple revenue streams (country funding, contracts, sales, salvage)
- Black market and smuggling income
- Risk vs reward trade-offs
- Predictable vs high-yield options

### Monthly Reports
- Financial audit snapshots at monthly intervals
- Income, expenses, and net calculations
- Resource flow tracking
- Public metrics and score impact
- Seeded for deterministic exports

### Score
- Province-level performance metric
- Link between player actions and political support
- Visible event-based scoring
- Funding outcome determination

### Win-Loss Conditions
- Optional achievement-style victory conditions
- Open-ended sandbox gameplay support
- Recovery paths from setbacks
- Multiple win/loss scenarios

---

## Geoscape

### Biome
- High-level regional descriptor for provinces
- Tactical flavor and map generation bias
- Terrain and map block selection influence

### Country
- Political and economic region aggregation
- Province population and economy tracking
- Funding potential and diplomatic stance
- Score aggregation for national relations

### Portals
- Inter-world travel gating mechanism
- Activation requirements and costs
- Progression milestones
- Campaign scope expansion

### Province
- Atomic spatial anchor on geoscape
- Single-point representation for bases, missions, events
- Region and country membership

### Region
- Geographic grouping of provinces
- Regional modifiers and spawn weights
- Economic and terrain characteristics

### Terrain
- Map generation palette and rule set
- Biome-consistent map assembly
- Reusable building blocks across mission types

### Universe
- Multi-world campaign structure
- Cross-world rules and interactions

### World Time
- Fixed turn length time progression (day, week, month, quarter, year)
- Named scheduler hooks for subsystems
- Deterministic time advancement
- Temporal rhythm for planning (monthly payroll, quarterly funding)

### World
- Individual planet/dimension with unique properties
- Grid size and base building rules
- Environmental modifiers and challenges

---

## Interception

### Air Battle AP and Energy
- Dual resource system for dogfight action economy
- AP controls sequencing and action count per turn
- Energy gates action availability and potency
- Recharge mechanics for sustained combat
- Tempo vs resource trade-offs

### Air Battle
- Abstract tactical minigame for craft combat
- Range control and positioning mechanics
- Mission objectives (intercept, escort, escape)
- Deterministic and data-driven outcomes

### Craft Weapon Usage
- Mount-specific AP, energy, and cooldown costs
- Firing cadence and rate-of-fire balance
- Role expression through weapon loadouts
- Data-driven weapon specifications

### Land Battle
- Ground mission initiation from interception
- Transition from geoscape to battlescape
- Crew and equipment carryover

### Mission Detection
- Daily detection attempts against hidden missions
- Cover value representing concealment
- Detection power from radar and airborne scans
- Range-based detection radius
- Additive stacking of detection sources
- Cover reduction leading to detection (Cover ≤ 0)

### Mission Interception
- Craft dispatch to engage detected missions
- Transit time and fuel cost
- Engagement decision points
- Dogfight or landing resolution

---

## Items

### Armour Piercing
- Penetration vs armor thickness mechanics
- Damage reduction calculation
- Critical hit bonus for exceeding armor

### Craft Items
- See Crafts/Craft Item section above

### Damage Calculations
- Multi-stage damage pipeline (raw generation → type multipliers → armor → channels)
- Deterministic arithmetic for auditable outcomes

### Damage Methods
- POINT: Single-tile direct damage with seeded variability
- AREA: Radial falloff with ray-based attenuation and deterministic spread
- Per-tile raw damage map generation

### Damage Model
- Residual damage distribution to stat channels (Health, Stun, Morale, Energy, AP)
- Percent-based splits and per-target multipliers
- Configurable routing and caps

### Damage Types
- Type → multiplier mapping for targets
- Elemental and physical damage categories
- Type advantage/weakness system

### Item Action Economy
- Action-cost framework for item usage
- Cooldowns, use-cases, and interaction rules
- AP, stamina, and energy integration
- Synergy and refund mechanics

### Lore Items
- Narrative-driven collectibles and quest items
- Discovery windows and one-off modifiers
- Late-game tactical upgrades

### Resources
- Crafting materials and consumables
- Storage and transfer mechanics
- Production input requirements

### Special Items
- Unique equipment with bespoke effects
- Quest rewards and milestones

### Unit Items
- Personal equipment for tactical units
- Inventory management and encumbrance

### Weapon Modes
- Multiple firing behaviors per weapon (auto, burst, aimed)
- Multiplicative modifiers to base stats (AP, energy, range, accuracy, damage)
- Data-driven mode definitions
- Seeded for deterministic outcomes

---

## Lore

### Calendar
- Global time advancement system
- Discrete tick intervals (day, week, month, quarter, year)
- Seeded for reproducible time-based events
- Scheduler hooks for subsystems

### Campaign
- High-level mission sequencing structure
- Victory and failure condition framework
- Faction-driven narrative arcs
- Wave-based mission spawning
- Seeded instance IDs for determinism

### Enemy Base Script
- Persistent alien base behavior templates
- Mission generation from established bases
- Strategic penalties and regional threats
- Salvage and reward concentrations

### Event
- One-time or recurring game events
- Trigger conditions and consequences
- Narrative beats and emergent storytelling

### Faction
- Persistent adversary actors
- Spawn pools and reward tables
- Long-term story arcs
- Deterministic mission generation

### Mission
- Tactical encounter instances
- Script-driven movement, detection, spawns
- Deterministic state transitions

### Quest
- Multi-stage narrative objectives
- Branching choices and consequences
- Unlocks and progression gates

### UFO Script
- Mobile UFO mission behavior profiles
- Movement patterns and scanning logic
- State transitions (Flying, Landed, Crashed, Base)
- Data-driven branching and decision trees

---

## Organization

### Company
- Player organization level and growth system
- Milestone-based progression (capabilities, unlocks, access)
- Quest and research prerequisites
- Persistent state across subsystems
- Provenance for deterministic previews

### Fame
- Public visibility and prestige metric
- Funding, recruitment, and attention trade-offs
- High Fame: boosts support but raises pressure
- Low Fame: preserves secrecy at cost of resources
- Data-driven modifiers and event rewards

### Karma
- Moral/ethical choice tracking metric
- Narrative and supplier access gating
- Deterministic threshold effects
- Provenance logging for player feedback

### Policies
- Player-selectable organizational directives
- Persistent or time-limited modifiers
- Funding, recruitment, visibility, operational rule changes
- Slot-based system with explicit costs
- Data-driven effect specifications

---

## Pedia

### Summary
- In-game encyclopedia system
- Item, system, and lore documentation
- Research, quest, and discovery-based unlocks
- Data-driven entry authoring (YAML)
- Staged reveal mechanics
- Reproducible and mod-friendly
- Canonical reference for players and designers

---

## Units

### Action Points
- Per-turn tactical budget for combat actions
- Movement, attack, and ability costs
- Fractional accounting support
- UI projection of AP balance before actions
- Deterministic trimming for exceeding budgets

### Classes
- Unit archetype definitions constraining mechanics, items, promotions
- Trade-off and power curve specifications
- Data-driven, seedable definitions
- Compatibility and promotion rule validation

### Encumbrance
- Hard cap at mission prep (default)
- Optional soft caps with AP/movement/fatigue penalties
- Data-driven thresholds and penalty tables
- Clear UI display of totals and capacity

### Energy
- Per-unit resource for powered actions
- Independent from AP budget
- Energy-based equipment and ability costs
- Endurance vs burst pricing

### Experience
- XP sources: kills, objectives, training, medals
- Data-driven and provenance-logged
- Deterministic promotion system

### Faces
- Character portrait and appearance system
- Procedural generation or asset pool
- Customization and recognition

### Inventory
- Unit equipment and item management
- Slot system and capacity limits
- Mission prep validation

### Medals
- Achievement and recognition system
- Performance-based unlocks
- Stat bonuses and morale effects

### Promotion
- Rank advancement and ability unlocks
- Class-specific progression trees
- Stat increases and perk selection

### Races
- Species definitions with unique traits and stats
- Data-driven compatibility and spawn rules
- Faction associations

### Ranks
- Hierarchical position within organization
- Salary, ability, and command structure

### Recruitment
- Hiring and onboarding mechanics
- Market and faction-based recruitment pools
- Cost and availability modifiers

### Salaries
- Monthly personnel costs based on rank
- Budget management and retention

### Sizes
- Unit size categories affecting tactical mechanics
- Encumbrance, cover, and targeting modifiers

### Stats
- Core attributes (Health, AP, Aim, Will, Speed)
- Derived values and modifiers
- Progression and equipment impact

### Traits
- Unique abilities and quirks
- Rarity and compatibility metadata
- Data-driven trait pools

### Transformations
- Permanent unit modifications (cybernetics, mutations)
- Facility and resource requirements
- Stat and ability changes

### Unit Item Usage
- How units interact with equipped items
- Encumbrance and performance impacts
- Inventory validation rules

---

## Summary of Key Design Principles

Throughout the wiki, several design principles are emphasized consistently:

1. **Determinism and Reproducibility**: All systems use seeded randomness for reproducible outcomes in playtests, multiplayer, and debugging
2. **Data-Driven Design**: Mechanics are configured via YAML/JSON rather than hardcoded, enabling easy modding and balance iteration
3. **Provenance Logging**: Systems emit detailed logs of decisions, calculations, and state changes for debugging and telemetry
4. **Transparent UI**: Players and designers can see calculations, modifiers, and decision factors
5. **Action Economy**: Consistent use of AP, Energy, and other resources across systems
6. **Modular Architecture**: Systems are designed as composable, reusable components
7. **Strategic Trade-offs**: Mechanics create meaningful choices between competing priorities
8. **Fair Challenge**: AI and difficulty systems avoid hidden advantages and follow the same rules as players
9. **Campaign Scope**: Integration between tactical (battlescape), strategic (geoscape), and economic (basescape) layers

---

**Document Purpose**: This summary is intended as a reference for extracting detailed mechanics when reformatting the wiki or implementing systems in a new engine. Each file contains extensive implementation details, formulas, and examples beyond what is summarized here.
