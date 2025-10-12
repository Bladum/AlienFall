# AlienFall Wiki - Game Mechanics Summary

**Purpose**: High-level extraction of unique game mechanics from the AlienFall wiki for reference when adapting to new formats.

**Last Updated**: October 9, 2025

---

## AI SYSTEMS

### ai-overview.md
- Utility-based decision framework with personality system
- Tactical awareness and threat assessment scoring
- Combat action selection via utility scoring
- Group coordination and formation tactics
- Deterministic processing with seeded randomization
- Strategic objectives, campaign orchestration, resource allocation
- Adaptive intelligence with pattern recognition
- Faction coordination mechanics
- Hierarchical AI architecture (strategic, squad, individual levels)
- Behavior trees and state machines
- Energy pool management for AI actions
- Action point system integration
- Telemetry logging for moddability

### alien-strategy.md
- Strategic objectives hierarchy (territorial control, resource acquisition, tech advancement, player disruption, escalation management)
- Campaign orchestration (activation triggers, priority assignment, conflict resolution, termination logic, success metrics)
- Resource allocation (UFO fleet, unit deployment, technology distribution, energy budgeting, recovery routing)
- Adaptive intelligence (pattern recognition, risk assessment, tactical adjustment, contingency planning, long-term learning)
- Faction coordination (specialization respect, cooperative objectives, resource sharing, conflict mediation, unified escalation)
- Campaign phases (early game scouting, mid-game escalation, late-game crisis)
- Data-driven and seeded behavior

### battle-team-level-ai.md
- Behavior tree structure (combat phase selector: assault, defense, recon, retreat)
- State machine (idle, assess, plan, execute, adapt, recover states)
- Assault phase mechanics (strength assessment, terrain evaluation, flanking detection, formation types: wedge/pincer/fire-and-maneuver, suppression and flanking execution, breaching tactics)
- Defense phase mechanics (defensive position assessment, perimeter establishment, overwatch/sentries, reserve positioning, active defense, morale maintenance, withdrawal triggers)
- Squad formation maintenance
- Coordinated attack patterns
- Unit role specialization (point man, flankers, support, sentries)
- Communication and signaling between units
- Adaptive strategy adjustment based on casualties
- Formation effectiveness modifiers
- Team size effects on tactics

### battlescape-ai.md
- Utility-based decision framework with survival/lethality/positioning/objectives scoring
- AI personality system (aggressive, cautious, balanced, specialized traits)
- Tactical awareness (enemy tracking, opportunity recognition, cover evaluation, group dynamics)
- Combat action selection (movement, targeting, ability usage, defensive actions)
- Group coordination (formation maintenance, focus fire, area control, supporting actions)
- Deterministic processing with seeded randomization
- Telemetry logging
- Performance optimization strategies

### Behaviors.md
- Behavior priority hierarchy (squad survival > squad objectives > personal survival > battle-side goals > exploration/positioning)
- Energy pool and action point system (movement pool, combat pool, special pool, reserve pool)
- Weapon and equipment management (range optimization, damage potential, cover penetration, ammo efficiency)
- Enemy unit behavior types: Hunter, Sniper, Healer, Commander, Scout, Suicide, Long Range, Assault, Heavy
- Allied unit behavior types: Allied Sniper, Allied Healer, Allied Commander
- Neutral unit behavior types: Civilian/Refugee, Wild Animal, Robotic Drone
- Armor and damage management (facing optimization, cover integration, damage type adaptation)
- Energy pool allocation matrix per behavior type
- Behavior flow diagrams

### faction-behavior.md
- Faction strategic goals unique to each faction
- Faction tactical preferences
- Faction unit compositions
- Faction technology trees
- Faction resource priorities
- Faction campaign types
- Inter-faction cooperation and conflict resolution
- Faction escalation patterns
- Faction adaptation to player actions
- Faction specialization
- Faction response to threats
- Faction territory control strategies
- Faction diplomacy
- Data-driven faction configuration

### geoscape-ai.md
- Director authority hierarchy (tactical, operational, strategic)
- Authority escalation based on campaign legitimacy
- Strategic priority evaluation (economic pressure, military strength, geographic coverage, research progress, performance metrics)
- Decision cadence (monthly, weekly, daily, immediate)
- Adaptive campaign management (campaign templates, wave scheduling, resource allocation, target selection)
- Deterministic processing with seeded sampling
- Telemetry logging
- Performance optimization

### map-ai-nodes.md
- Node architecture (root nodes, branch nodes, leaf nodes, composite nodes)
- Hierarchical decision tree system
- Decision evaluation (context assessment, priority scoring, cooldown management, fallback logic)
- Node types (decision, action, composite)
- Combat engagement nodes (direct assault, flanking, suppressive fire)
- Positioning nodes (seek cover, high ground, flank positions)
- Target selection nodes
- Tactical maneuvering nodes
- Adaptive learning (pattern detection, counter development, effectiveness tracking)
- Performance optimization (node caching, priority queuing, batch processing, spatial indexing)
- Moddable node structures via TOML

### map-exploration.md
- Fog of war integration
- Individual unit knowledge vs squad intelligence sharing
- Adaptive patrol patterns
- Exploration patterns (systematic sweep, random patrol, objective-driven, reactive search)
- Discovery system (enemy units, environmental hazards, resources/items, intelligence gathering)
- Progressive revelation mechanics
- Shared intelligence between units
- Temporary concealment
- Visibility tracking per unit
- Performance optimization (spatial partitioning via quad trees, fog compression with bit-packed data, route caching, event-driven updates)
- Coverage efficiency metrics
- Threat detection probabilities
- Enhanced detection for scouts
- Elevation advantage in discovery
- Area modifiers (dangerous zones, objective areas)

### movement-ai.md
- Pathfinding engine (A* algorithm with tactical cost modifiers)
- Terrain difficulty evaluation
- Cover value assessment in pathfinding
- Proximity to enemies cost adjustment
- Formation requirements in movement
- Dynamic recalculation when conditions change
- Multi-unit coordination (collision prevention, squad cohesion)
- Tactical assessment (cover protection value 0-100, flanking opportunities, threat levels, objective prioritization)
- Movement patterns (direct assault, flanking maneuver, cover bounding, retreat patterns)
- Cover seeking algorithm
- Flanking detection (angle analysis, risk vs opportunity assessment, multi-unit coordination for timed flanking)
- Formation maintenance (optimal spacing, role-based positioning, formation adaptation for offense/defense/retreat)
- Computational efficiency (spatial partitioning, path caching, incremental updates, multi-resolution planning)
- Memory management (path object pooling, state compression, lazy evaluation)
- Performance monitoring

---

## BASE MANAGEMENT

### base-defense.md
- Automatic base defense (defense tower strength, coverage area, attack deterrence, infiltration prevention)
- Facility armor contribution (base defense armor calculation, individual facility armor ratings, damage mitigation system)
- Defensive facilities (defensive emplacements, laser defense towers, security stations, turret systems)
- Tactical base defense missions (battlescape generation from base layout, defender deployment, map block linking, special tactical tiles)
- Mission objectives and consequences
- Facility destruction mechanics
- Personnel casualties and equipment loss
- Detection and early warning (security service, infiltration detection, security breach handling)
- Defensive positioning strategy (chokepoint design, killzone creation, fallback positions, core facility protection)
- Base guard units with defensive loadouts
- Alien attack patterns (frequency, strength scaling, faction-specific behavior)
- Base vulnerability assessment

### base-layout.md
- Grid system (3×3, 5×5, 7×7 base sizes)
- Tile-based placement
- Multi-tile facility footprints
- Connectivity requirements (HQ anchor point/central access lift, contiguous path requirements, corridor tiles, network topology)
- Offline/online facility states
- Placement strategies (core facilities positioning, defensive perimeter design, specialized facility clustering, expansion planning)
- Layout templates (forward recon post, interception hub, research outpost, defensive stronghold, industrial complex)
- Tactical implications (map generation from base layout, facility block mapping, corridor network mapping, defensive positioning, chokepoint creation)
- Facility health and damage
- Critical facility protection
- Redundancy planning
- Single point of failure avoidance
- Layout modification (demolition, reconstruction, expansion phases, modular growth)
- Visualization and UI (top-down grid view, facility icons and status, connectivity indicators, construction progress)

### base-locations.md
- Geographic advantages
- Coverage optimization
- Multi-base coordination
- Strategic positioning

### base-management-overview.md
- Facility construction and placement
- Connectivity requirements (HQ anchor system)
- Base expansion strategies
- Territory control requirements
- Construction phases and timing
- Resource requirements and allocation
- Risk and interruption systems
- Operational activation process
- Strategic benefits and advantages
- Capacity management (storage, personnel, crafts)
- Service tag system
- Base defense mechanics
- Monthly base reports
- Base transfers and logistics
- Inter-base coordination
- Strategic positioning benefits (economic generation, detection expansion, research acceleration, operational efficiency)
- Base templates
- Multi-base operations

### construction-queue.md
- Construction queue management
- Build time requirements
- Resource scheduling
- Priority system

### facility-requirements.md
- Dependency management
- Prerequisite technologies
- Power requirements
- Connection requirements

### facility-stats.md
- Facility statistics and performance metrics
- Capacity contributions
- Maintenance costs
- Operational efficiency

### facility-system.md
- Size and footprint system (standard 1×1 units, multi-tile structures 2×1, 2×2, 3×2, etc.)
- Placement metadata (width and height parameters)
- Construction lifecycle management (building state, time requirements, cost structure, maintenance during build, service activation)
- Connectivity requirements (HQ anchor connection to central access lift, contiguous paths via corridor tiles, offline state for unconnected facilities, network dependencies)
- Health and damage system (HP values, armor ratings, armor mechanics for damage mitigation, facility armor contribution, damage pipeline, operational impact, repair requirements, destruction consequences)
- Capacity contribution framework (aggregated storage, capacity types: volume/throughput/slots, overflow handling, dynamic updates, resource assignment)
- Service tag system (capability advertising, system discovery, feature enablement, modular design, dependency management)
- Tactical integration framework (map block linking, special tiles: turrets/doors/consoles/fuel caches, objective generation, defensive participation)
- Geoscape effects
- Operations and maintenance (monthly costs, resource consumption, staffing requirements, efficiency throttling, maintenance scheduling, failure mode handling)
- Facility types (research lab, manufacturing workshop, craft hangar, living quarters, radar array, defensive emplacement, academy)
- TOML configuration (no hardcoded facilities, data-driven definitions)

### facility-types.md
- Detailed list of facility categories
- Specialized facilities
- Unique facility abilities

### personnel-management.md
- Unit housing and capacity (barracks facilities, capacity limits, unit size categories, base expansion for personnel)
- Unit types (soldiers, scientists, engineers, support staff)
- Unit assignments and activities (available, training, mission deployment, facility duty, recovery)
- Health and recovery (health tracking 0-100, daily healing rates, medical facilities, critical care, injury management)
- Training and development (XP system, level progression, skill development, specialization paths, training programs)
- Unit transfers (inter-base transfers, capacity checks, transfer costs, strategic deployment)
- Equipment and loadouts (weapon assignment, armor and accessories, loadout management, maintenance requirements)
- Personnel recruitment (hiring systems, cost per unit type, starting stats and abilities)
- Morale and motivation
- Efficiency factors
- Salary and compensation
- Housing service
- Training service
- Experience gain systems (combat skill improvement, specialization unlocks)

### storage-management.md
- Storage capacity systems
- Item management
- Resource allocation
- Overflow handling

---

## BATTLE COMBAT

### accuracy-at-range.md
- Range bands (point blank optimal, short range minimal penalty, medium range moderate penalty, long range heavy penalty, extreme range maximum penalty)
- Distance penalty calculation (linear penalty, exponential penalty)
- Weapon-specific range characteristics (sniper rifles excellent long-range, shotguns excellent close/terrible long, assault rifles balanced, pistols short-medium, energy weapons consistent)
- Optimal range concept
- Range modifiers by weapon type
- Range indicator UI (visual feedback, color-coded distance indicators, range prediction before moving)
- Environmental factors affecting range (smoke/fog reducing range, darkness limiting vision, elevation advantages)
- Tactical decisions based on range

### battle-at-night-or-day.md
- Day/night cycle effects
- Visibility modifiers
- Tactical advantages/disadvantages
- Equipment requirements for night combat

### battlefield-sight-and-sense.md
- Multi-sensory detection system
- Sound-based detection
- Smell/chemical detection
- Electronic detection

### core-combat-math.md
- Hit chance formula (base accuracy stat, range modifiers, cover modifiers, stance modifiers, target size modifiers, environmental modifiers, final hit probability)
- Damage calculation formula (base weapon damage, damage roll random range, armor reduction, armor penetration, final damage applied)
- Critical hit mechanics (critical hit chance calculation, critical damage multiplier, critical hit effects)
- Armor penetration formula (armor value vs penetration, effective armor after penetration, damage type interactions)
- Random number generation (deterministic vs true random, seeded RNG for save/load consistency, D100 rolls vs other dice, statistical distributions)
- Expected damage calculations
- Probability curves for hit chance
- Balance testing with simulations

### cover-system.md
- Cover types (no cover/exposed, half cover medium defense, full cover large defense, destructible cover)
- Cover mechanics (cover direction, flanking negates cover, cover hugging, cover peeking)
- Cover defense bonus (flat bonus or percentage-based reduction)
- Cover and movement (moving between cover, cover-to-cover movement UI, sprint to cover)
- Cover indicators and UI (visual indicators, cover preview before moving, enemy cover visibility)
- Cover destruction (explosives and grenades, environmental damage, partial cover degradation)
- AI cover behavior (seeking cover, prioritizing flanking, cover-based decisions)
- Advanced cover mechanics (partial flanking with reduced bonus, height advantage ignoring low cover, prone stance interaction)

### damage-types.md
- Primary damage types: kinetic (bullets/conventional), energy (laser/plasma), explosive (grenades/rockets with AOE), fire (damage over time/spreads/terror), poison (DOT/bypasses armor), melee (high risk/armor penetrating), psionic (ignores physical armor), stun (non-lethal capture)
- Damage type interactions (armor resistances, vulnerabilities, environmental interactions)
- Tactical weapon selection based on enemy type
- Mixed squad loadouts
- Visual and audio feedback per damage type

### environmental-effects.md
- Weather effects (rain reduces visibility/accuracy, fog heavy visibility reduction, snow movement penalties/cold hazards, wind affects projectiles/smoke dispersal, clear weather baseline)
- Rain mechanics (reduced ballistic accuracy, fire extinguishing, slippery terrain, visual effects)
- Fog mechanics (severe visibility reduction, concealment opportunities, fog density variation, time-limited dissipation)
- Wind mechanics (grenade deviation, smoke dispersal direction/speed, sound propagation)
- Temperature hazards (extreme heat exhaustion/fire spread, extreme cold fatigue/freezing, toxic atmosphere requiring masks, radiation damage/protection)
- Terrain hazards (water movement penalty/electrical hazard, lava/acid damage, ice slippery/falling, quicksand/mud immobilizing)
- Environmental destruction (explosives creating craters, fire spreading, collapsing structures)
- Tactical use of weather
- Environmental effect duration (persistent vs dynamic vs event-triggered)
- Environmental UI indicators

### hit-chance-calculation.md
- Detailed hit chance formulas
- Modifier stacking rules
- Edge cases and special conditions

### light-vs-fog-of-war.md
- Lighting system vs fog of war distinction
- Dynamic lighting
- Shadow mechanics
- Visibility zones

### line-of-fire.md
- Line of fire calculation
- Obstruction checking
- Friendly fire mechanics
- Shot trajectory

### line-of-sight.md
- LOS calculation algorithm (raycasting, tile-by-tile obstruction, partial vs full obstruction, height and elevation)
- LOS blocking terrain (walls full block, windows/fences partial block, smoke/fog temporary block, destructible obstacles)
- LOS range limits (maximum sight radius per unit, unit vision stat, day vs night range, equipment modifiers)
- LOS and fog of war (unexplored black fog, previously explored grey fog, currently visible clear, dynamic updates)
- LOS symmetry (asymmetric LOS with stealth/camouflage)
- LOS and shooting (must have LOS to target, partial LOS reduced accuracy, blind fire very low accuracy)
- LOS indicators and UI (visibility cones, highlighted tiles, enemy LOS indicators, LOS preview before moving)
- AI LOS behavior (only reacts to visible threats, reveals units when entering LOS, sound-based detection optional)
- Advanced LOS features (peeking around corners, height advantage improving LOS, destructible terrain revealing LOS)
- Performance optimization for LOS calculations

### objects-on-battle-field.md
- Interactive objects
- Destructible objects
- Environmental objects
- Objective objects

### smoke-fire.md
- Smoke mechanics (smoke grenades, smoke generation, smoke dispersal by wind, smoke blocking LOS, smoke area of effect)
- Fire mechanics (fire damage, fire spreading to flammable terrain, fire duration, fire extinguishing by rain/water)
- Tactical use of smoke (concealment, area denial, covering movement)
- Tactical use of fire (area denial, flushing enemies, destroying cover)

### Suppression.md
- Suppression mechanics (applying suppression via area fire/auto fire, near misses and hits build up, suppression value accumulation, decay over time)
- Suppression effects (morale penalty, accuracy penalty, reduced reactions, movement penalty, panic check trigger)
- Suppression sources (auto fire/burst weapons high suppression, machine guns/heavy weapons, explosives/area attacks, near misses vs hits)
- Suppression area of effect (nearby units also suppressed, cone of fire suppression zone, friendly units immune)
- Tactical use (pinning down enemies, covering ally movement, suppression + flanking)
- AI suppression behavior (less aggressive when suppressed, seeks better cover, may panic)
- Suppression indicators and UI (visual markers, suppression meter, audio feedback)
- Weapons specialized for suppression (machine guns, sustained fire abilities)
- Suppression duration and recovery (fades after few turns, better cover reduces suppression, rally/commander abilities)
- Morale system integration

---

## BATTLE GENERATION

### battle-field.md
- Complete battlefield structure
- Map assembly
- Mission-specific generation

### battle-grid.md
- Grid coordinate system
- Tile addressing
- Grid traversal

### battle-tile.md
- Individual tile properties
- Tile types
- Tile flags and metadata

### battlefield-generation.md
- Map generation system (block-based assembly, map blocks/prefabs/scripts, grid system)
- Terrain generation (terrain types: urban/rural/industrial/natural, elevation system, cover placement, destructible objects, environmental hazards)
- Mission-specific generation (UFO crash site, UFO landing site, base defense from base layout, terror site urban, alien base)
- Tileset system (tileset definition, tile variants, visual consistency, tactical tile properties)
- Map size determination (small 20x20, medium 40x40, large 60x60, dynamic sizing)
- Map block linking (connectivity rules, transition tiles, doorways/passages, multi-level maps)
- Special tiles (entry/exit points, objective markers, interactive elements, spawn points)
- Environmental conditions (time of day, weather effects, lighting conditions, fog/smoke placement)
- Validation and quality assurance (playability checks, balance validation, performance optimization)
- TOML configuration for generation rules
- Procedural generation algorithms

### map-block.md
- Map block definition
- Block categories
- Connection points
- Block rotation and mirroring
- Block compatibility rules

### map-blocks.md
- Block library management
- Block selection rules
- Block combinations

### map-generator-overview.md
- Map generation architecture (block-based generation, procedural assembly, deterministic/seeded generation, validation)
- Map components (battle field, battle grid, battle tile, map block, map prefab, map script, map grid, tileset)
- Tileset system (definition, variants, terrain types, visual consistency, tactical properties)
- Map block system (definition, categories, connection points, rotation/mirroring, compatibility)
- Map prefab system (complete pre-built maps, prefab categories, mission-specific prefabs, prefab modification)
- Map script system (generation rules, procedural algorithms, mission-specific scripts, environmental conditions)
- Generation phases (layout, block assembly, terrain decoration, object placement, validation)
- Terrain generation (elevation, cover, destructible elements, interactive objects, hazards)
- Mission-specific generation details
- Map size and complexity (small/medium/large, dynamic sizing)
- Multi-level maps (vertical gameplay, floors/levels, stairs/elevators, z-axis navigation)
- Special tiles and features (entry/exit, objectives, spawn points, interactive terminals)
- Performance optimization (efficient algorithms, memory management, caching)
- TOML configuration
- Moddable generation rules

### map-grid.md
- Grid management system
- Coordinate conversion
- Grid utilities

### map-prefab.md
- Prefab structure
- Prefab categories
- Prefab modification

### map-prefabs.md
- Prefab library
- Prefab selection logic
- Mission-prefab mapping

### map-script.md
- Scripting system for generation
- Generation rules language
- Script execution

### map-tile.md
- Tile definition system
- Tile properties
- Tile metadata

---

## BATTLESCAPE

### battlescape-overview.md
- Turn-based combat system
- Action point economy (AP system)
- Time unit integration (TU system)
- Unit actions (movement, combat, special abilities)
- Combat actions (ranged, melee, grenades)
- Movement actions (basic, tactical, climbing, swimming)
- Special actions (overwatch, reload, medical, equipment)
- Unit attributes (health, strength, agility, endurance, willpower, perception, intelligence)
- Derived values (movement points, accuracy, damage, carry capacity)
- Line of sight (LOS) system
- Line of fire (LOF) system
- Cover system
- Fog of war
- Light and darkness effects
- Accuracy at range
- Suppression mechanics
- Smoke and fire
- Objects on battlefield
- Unit equipment system
- Unit experience and progression
- Unit morale and panic
- Unit fatigue system
- Unit injuries and health
- Unit status effects
- Unit psionics
- Unit reactions
- Unit sanity
- Battle at night or day
- Environmental interactions
- Tactical positioning
- Combined arms tactics
- Flanking mechanics
- Defense in depth
- Resource management
- Unit-specific action sets
- Battlefield generation
- Mission integration
- AI coordination

### Deployment.md
- Unit deployment mechanics
- Deployment zones
- Deployment restrictions
- Strategic deployment planning

### loot-and-recovery.md
- Post-battle loot system
- Item recovery mechanics
- Corpse recovery
- Equipment salvage
- Alien artifact recovery

### mission-types.md
- UFO crash site missions
- UFO landing site missions
- Base defense missions
- Terror missions
- Supply raid missions
- Retaliation strikes
- Alien base assault missions
- Scout missions
- Research missions
- VIP extraction missions
- VIP protection missions
- Sabotage missions
- Interception missions
- Ambush missions
- Mission objectives (primary, secondary, bonus)
- Victory/defeat conditions per mission type
- Mission generation parameters
- Enemy composition rules
- Map type selection
- Deployment zones
- Time limits
- Environmental conditions
- Mission difficulty scaling
- Threat level calculation
- Enemy reinforcement rules
- Loot and recovery systems
- Mission rewards
- Experience gains
- Strategic consequences
- Campaign integration
- Random mission events
- Special mission modifiers
- Night/day variation
- Weather effects on missions

### terrain-types.md
- Terrain type definitions
- Terrain effects on gameplay
- Terrain and movement costs

### tileset-design.md
- Tileset design principles
- Visual consistency
- Tactical considerations in design

### Tileset.md
- Tileset structure
- Tile categories
- Tileset configuration

### turn-flow.md
- Turn structure
- Initiative system (initiative calculation, initiative order determination)
- Turn phases (start of turn, player action, enemy action, environmental, end of turn)
- Action point allocation (AP refresh, AP expenditure, AP carryover rules)
- Time unit management (TU allocation, TU consumption, TU and reaction system)
- Action execution (action queuing, action resolution, interrupted actions, conditional actions)
- Reaction system (overwatch triggers, opportunity fire, counter-attack reactions, defensive reactions)
- Turn order modifiers (agility-based initiative, equipment speed modifiers, status effect modifications)
- Environmental effects on turn flow (smoke/obscurement, fire damage per turn, time-limited effects)
- Multi-unit coordination (squad activation, simultaneous actions)
- Turn timers
- Phase transitions (event triggers, state validation)
- Turn counter and round tracking
- Victory/defeat condition checks
- Integration with AI systems
- UI turn indicators

### victory-conditions.md
- Mission-specific victory conditions
- Defeat conditions
- Bonus objectives

---

## CRAFTS

### craft-combat.md
- Interception initiation (detecting UFO via radar, launching interceptor, pursuit and interception range)
- Combat engagement mechanics (turn-based vs real-time resolution, range and positioning, weapon firing and cooldowns, evasion and maneuvers)
- Craft weapons systems (cannons/autocannons, missiles: standard/advanced/alien, laser/plasma weapons, weapon accuracy/damage, ammo limits and reload)
- Craft defense and evasion (armor and hit points, dodge/evasion chance, speed and maneuverability, countermeasures: ECM/flares)
- Combat damage and consequences (craft HP tracking, critical hits and system damage, craft/UFO destruction, craft retreat and disengagement)
- Combat outcomes (UFO destroyed/escaped, player craft destroyed/damaged, UFO damaged and retreated)
- Multiple craft interception (squadron tactics)
- Combat UI and visualization
- Craft combat AI (UFO behavior: aggressive/evasive, auto-combat vs manual control, difficulty scaling)
- Combat resolution (initiative based on speed/pilot skills, attack resolution with range/damage/armor, damage effects on performance)
- Victory conditions (craft/UFO)
- Post-combat (salvage recovery, craft repair, pilot experience)

### craft-damage-and-repair.md
- Damage tracking system
- Repair mechanics
- System damage effects
- Repair costs and time

### craft-equipment.md
- Craft equipment types
- Equipment installation
- Equipment upgrades
- Equipment compatibility

### craft-fuel-and-range.md
- Fuel consumption mechanics
- Range calculations
- Refueling system
- Strategic fuel management

### craft-movement.md
- Movement on geoscape
- Speed calculations
- Intercept vectors
- Patrol routes

### craft-stats.md
- Craft attribute system
- Speed, armor, capacity
- Performance metrics
- Stat progression

### craft-types.md
- Interceptor craft
- Transport craft
- Specialized craft
- Craft tech tree

### craft-weapons.md
- Weapon categories for craft
- Weapon stats and effectiveness
- Ammunition systems
- Weapon research/unlock

---

## ECONOMY

### black-market.md
- Illegal trading system
- Black market prices (typically higher or lower than normal)
- Risk and rewards
- Contraband items
- Black market access conditions

### budget-system.md
- Monthly income and expenses
- Revenue sources
- Cost categories
- Budget allocation
- Financial planning tools

### Debt.md
- Debt accumulation mechanics
- Interest rates
- Debt management strategies
- Bankruptcy conditions
- Debt consequences (funding cuts, game over conditions)

### economy-overview.md
- Budget system (monthly income/expenses, revenue sources, cost categories, budget allocation, financial planning)
- Funding system (funding council/nations, monthly allocations, score-based funding, funding penalties, funding withdrawal)
- Debt system (accumulation, interest rates, management, bankruptcy, consequences)
- Salaries and wages (personnel costs, scientist/engineer/soldier pay, salary scaling)
- Pricing system (equipment costs, facility construction, research projects, manufacturing costs, dynamic pricing)
- Black market (illegal trading, prices, risk/rewards, contraband)
- Resource trading (inter-base, external, resource conversion, market fluctuations)
- Manufacturing economy (production costs, material requirements, manufacturing queue economics, bulk production discounts)
- Research economy (project funding, scientist allocation costs, facility maintenance)
- Score system (performance metrics, mission success ratings, funding impact, global scoring)
- Monthly reports (financial statements, income/expense breakdown, net position)
- Win-loss conditions (economic)
- Resource flow management
- Suppliers and supply chain
- Marketplace systems
- Item crafting economics
- Transfer costs

### funding-system.md
- Funding integration with geoscape
- Regional funding sources
- Territory-based funding
- Performance impact on funding
- Score-based funding adjustments
- National funding by country (country-specific contributions, wealthy vs developing nations, strategic importance modifiers, nation-specific funding levels)
- Regional funding variations (continental patterns, regional wealth distribution, regional threat levels)
- Funding council reactions (meeting outcomes, increase/decrease conditions, emergency funding requests)
- Funding and territory control (lost territory impact, liberated territory bonuses, control state multipliers)
- Funding and mission performance (success bonuses, failure penalties, terror attack impact, UFO activity penalties)
- Funding stability (long-term trends, volatility management, funding forecasting)
- Nation withdrawal (triggers, process, post-withdrawal recovery)
- Regional funding system (Asia-Pacific, European, North American, other regions)
- Funding visualization on map (level indicators, trend visualization, threat-to-funding correlation)
- Integration with score/territory/economy systems

### Funding.md
- Funding sources detailed
- Funding calculation
- Funding modifiers

### manufacturing-system.md
- Manufacturing queue management
- Production time calculation
- Resource requirements
- Engineer allocation
- Batch production
- Manufacturing priorities

### Pricing.md
- Item pricing system
- Dynamic pricing mechanics
- Market value calculation
- Sale prices

### research-system.md
- Research project system
- Research tree structure
- Scientist allocation
- Research time calculation
- Research dependencies
- Research breakthroughs
- Research priorities

### resource-trading.md
- Inter-base trading
- External trading markets
- Resource conversion mechanics
- Market fluctuations
- Trading strategies

---

## GEOSCAPE

### geoscape-overview.md
- World map system (globe visualization, region and territory system, province management, country borders, territory control mechanics)
- Time management (time acceleration, pause system, real-time events, time-based triggers)
- UFO detection system (radar coverage, detection ranges, UFO tracking, detection probability, false positives)
- Interception system (craft scrambling, interception mechanics, air combat, UFO escape and landing, crash site generation)
- Mission generation (dynamic mission creation, mission types on geoscape, threat assessment, mission timing, geographic distribution)
- Base locations (base placement strategy, geographic advantages, coverage optimization, multi-base coordination)
- Funding system integration (national funding, regional support, score-based funding, funding withdrawal)
- Territory control (control mechanics, regional influence, alien expansion, liberation campaigns)
- Alien director system (strategic AI, campaign orchestration, adaptive pressure, resource allocation)
- World events (terror attacks, alien bases, retaliation strikes, special events)
- Strategic resources (global resource distribution, resource nodes)
- Strategic planning (long-term goals, base expansion planning, defensive networks, offensive campaigns)
- Integration with battlescape, economy, research
- UI and map interface

### mission-generation.md
- Dynamic mission creation system
- Mission triggers
- Mission parameters
- Mission location selection
- Mission difficulty calculation
- Mission variety mechanics

### territory-control.md
- Territory control mechanics
- Control states (player controlled, contested, alien controlled)
- Regional influence calculation
- Control benefits and penalties
- Alien expansion mechanics
- Liberation campaigns
- Territory visualization

### time-management.md
- Time acceleration system (1x, 5x, 30x, etc.)
- Pause mechanics
- Time-based event scheduling
- Real-time vs accelerated time
- Time-critical decisions

### ufo-detection.md
- Radar coverage mechanics
- Detection ranges by radar type
- UFO detection probability
- Detection window and timing
- False positive mechanics
- Tracking vs detection
- Multi-radar coverage

### world-map.md
- Globe visualization system
- Region definitions
- Country boundaries
- Province system
- Map projection
- Map interaction (zooming, panning, selection)
- Map overlays (radar coverage, funding levels, threat levels, territory control)

---

## INTERCEPTION

### interception-system.md
- Craft scrambling (alert and launch procedures, craft selection, fuel considerations, launch timing)
- Pursuit mechanics (speed chase, intercept vector calculation, UFO escape conditions, catch-up mechanics)
- Engagement phase (engagement initiation, combat range, weapon systems, attack patterns)
- Air combat resolution (auto-resolution, damage calculation, hit probability, critical hits)
- Craft damage system (UFO damage tracking, craft destruction, bail out mechanics, pilot survival)
- UFO destruction and crash sites (crash site generation, crash location determination, crash site mission creation)
- UFO landing sites (landing site detection, landing site mission generation)
- UFO escape (escape conditions, failed interception consequences, UFO retreat mechanics)
- Craft loadouts (weapon selection, ammunition management, equipment upgrades)
- Craft performance (speed/maneuverability, armor/durability, weapon effectiveness, fuel capacity)
- Multi-craft interception (coordinated attacks, squadron tactics, wing formation benefits)
- Interception strategy (craft positioning, engagement decision-making, risk assessment)
- Integration with UFO detection and mission generation

---

## ITEMS

### Armor.md
- Armor categories (personal armor/conventional, power armor/advanced exoskeleton, alien armor/recovered or researched)
- Armor stats (armor value damage reduction, armor coverage full/partial, weight and mobility impact, special resistances: fire/explosive/energy)
- Armor mechanics (damage reduction calculation, armor penetration interactions, armor degradation optional)
- Armor types and progression (no armor starting, tactical vest basic, carapace armor mid-game, titan armor heavy, power suit end-game, ghost armor stealth)
- Special armor properties (mobility bonuses/penalties, environmental protection: gas/fire, integrated equipment: medkit/grappling hook, visual customization)
- Armor and encumbrance system
- TOML definition for armor
- Balancing armor effectiveness
- Research and manufacturing requirements

### Consumables.md
- Consumable item types (medkits, grenades, stimulants, antidotes)
- Usage mechanics
- Effects and duration
- Strategic item selection

### craft-components.md
- Craft-specific equipment
- Component types
- Installation and upgrades
- Component effects on craft performance

### Equipment.md
- Equipment categories (utility items, special gear, tech equipment)
- Equipment effects
- Equipment weight and encumbrance
- Equipment research/unlock

### Weapons.md
- Weapon categories (ballistic/conventional firearms, energy: laser/plasma, explosive: grenades/rockets, melee)
- Weapon stats (damage base value, accuracy base hit chance, range effective and maximum, AP/TU cost to fire, ammo capacity and reload)
- Firing modes (single shot, burst fire, auto fire/full auto, aimed shot: accuracy bonus/higher AP, snap shot: quick fire/lower AP)
- Damage types (kinetic, energy, explosive, etc. - see damage-types.md)
- Weapon special properties (armor piercing, area of effect for explosives, suppression capability, two-handed vs one-handed)
- Weapon progression and tech tree (starting ballistic, mid-game laser/advanced ballistics, end-game plasma/alien tech)
- TOML definition for weapons
- Weapon balance considerations
- Weapon customization and attachments (if applicable)

---

## LORE

### alien-artifacts.md
- Alien artifact types
- Artifact recovery
- Artifact research
- Artifact uses and effects

### campaign-structure.md
- Campaign progression
- Campaign phases
- Story beats
- Campaign objectives

### events.md
- Event system
- Event types
- Event triggers
- Event consequences
- Random events vs scripted events

### factions.md
- Alien faction definitions
- Faction motivations
- Faction relationships
- Faction special abilities
- Faction-specific units and tech

### lore-and-setting.md
- Game world setting
- Alien invasion background
- Organization lore
- Technology lore
- Historical context

### missions.md
- Mission narrative integration
- Mission briefings
- Mission lore implications

### quests.md
- Quest system
- Quest chains
- Quest rewards
- Quest narrative

### ufopedia.md
- In-game encyclopedia
- Research entries
- Unit entries
- Equipment entries
- Lore entries
- UFOpedia unlock system

---

## ORGANIZATION

### Company.md
- Organization structure
- Organization reputation
- Organization goals
- Organization management

### Fame.md
- Fame system mechanics
- Fame accumulation
- Fame benefits
- Fame decay

### Karma.md
- Karma system (moral choices)
- Karma tracking
- Karma effects on gameplay
- Karma and story branches

### Policies.md
- Organizational policies
- Policy selection system
- Policy effects
- Policy costs and benefits
- Policy conflicts

### Reputation.md
- Reputation system overview
- Reputation with countries/regions (individual country scores, regional aggregation, reputation range e.g. -100 to +100, starting reputation)
- Reputation gain and loss (mission success in territory gain, mission failure/ignoring loss, civilian casualties loss, alien activity unchecked gradual loss, positive events: research/captured aliens)
- Reputation effects (funding levels tied to reputation, high reputation increased funding, low reputation reduced funding/threats, country withdrawal at extreme low, access to country resources: bases/personnel, diplomatic bonuses: trade/cooperation)
- Reputation with funding council (overall council satisfaction, council review cycles monthly/quarterly, council ultimatums)
- Reputation with other factions (ally factions positive relations, rival factions negative relations, neutral factions negotiable)
- Reputation management strategies (prioritizing missions in low-rep regions, balancing global vs regional focus, recovering from poor reputation, deliberate sacrifices)
- Reputation thresholds and events (critical reputation triggering special missions, milestones unlocking content)
- Reputation tracking and UI (meters/bars, color-coded levels: red/yellow/green, change notifications, council satisfaction reports)
- Reputation decay and maintenance (gradual loss without activity, maintaining relationships requires effort)
- TOML configuration
- Reputation and narrative events

### Score.md
- Score calculation (mission success ratings, regional score components, global score aggregation)
- Performance metrics (mission outcomes: successful/failed/perfect bonuses/civilian casualties, UFO activity impact: detected/intercepted/escaped/landed, terror attack impact: prevented/casualties/civilian protection ratings)
- Regional score system (per-region scoring, regional satisfaction levels, regional funding impact, regional withdrawal thresholds)
- Global score system (world-wide performance, aggregate metrics, global trends, international reputation)
- Score-based consequences (funding increases/decreases, nation withdrawal, council support levels, public opinion)
- Score decay (time-based score reduction, sustained performance requirements, score recovery mechanics)
- Performance tracking (monthly score reports, score history, trend analysis, comparative performance)
- Score thresholds (minimum acceptable score, excellence thresholds, critical failure levels, victory condition scores)
- Integration with funding/mission/campaign systems

---

## SYSTEM (CORE MECHANICS)

### core-action-point-system.md
- Action points (AP) definition (each unit has pool per turn, AP spent on movement and actions, AP refreshes at turn start)
- Relationship to time units (see Time Units.md)
- AP costs for actions (movement per tile variable by terrain, weapon firing: snap/aimed/auto, reload, item use: medkit/grenade, stance change: crouch/prone, interaction: door/objective)
- AP pool and unit stats (base AP value per unit stat-based, encumbrance reducing AP weight penalty, buffs/debuffs affecting AP: stims/fatigue)
- AP reservation (reserving AP for reaction fire, reserved vs active AP pool, trade-off between actions and reactions)
- AP visualization and UI (AP bar/meter, action cost preview on hover, movement range visualization, AP forecasting for multiple actions)
- AP efficiency and tactics (maximizing AP usage per turn, when to reserve for reactions, partial action planning)
- AP and difficulty balance (higher AP allows more actions easier, lower AP forces hard choices harder, AP scaling by unit type)
- TOML configuration for AP costs
- AP vs pure time unit systems (design choice)

### core-capacity-systems.md
- Capacity types (storage volume, personnel capacity, craft capacity, workshop throughput)
- Capacity aggregation across facilities
- Overflow handling
- Dynamic capacity updates

### core-energy-pool-system.md
- Energy pool definition (separate resource from AP/TU, used for special abilities and powers, regenerates over time or through actions)
- Energy pool mechanics (energy cost for abilities: psionics/tech skills, energy regeneration rate per turn or gradual, maximum energy capacity per unit, energy buffs and debuffs)
- Energy pool vs cooldown systems (energy allows flexible usage, cooldowns enforce timing, hybrid energy + cooldown systems)
- Energy management strategies (saving energy for critical abilities, energy-efficient combos, forced expenditure use-it-or-lose-it)
- Energy and unit specialization (psionic units large pools, tech specialists moderate pools, standard soldiers minimal energy)
- Energy-based abilities (psionic attacks: mind control/panic, tech hacks and overrides, special weapon modes: overcharge, healing and support abilities)
- Energy indicators and UI (energy bar display, ability cost tooltips, energy forecast for planned actions)
- Energy and difficulty balance (higher energy more abilities easier, lower energy ability rationing harder)
- Energy pool in AI behavior (AI managing energy, AI prioritizing high-value spending)
- TOML configuration for energy pools
- Integration with other mechanics

### core-resource-management.md
- Resource types
- Resource acquisition
- Resource consumption
- Resource storage
- Resource transfers

### core-save-system.md
- Save game mechanics
- Save file structure
- Auto-save system
- Save integrity and validation
- Save compatibility

### core-time-units.md
- Time unit (TU) system (alternative or complement to AP)
- TU allocation per turn
- TU costs for actions
- TU and reaction fire
- Relationship to AP system

### core-turn-system.md
- Turn structure and flow
- Turn phases
- Initiative system
- Multi-unit turn management
- Turn transitions

---

## UNITS

### alien-species.md
- Alien species definitions
- Species-specific abilities
- Species stats and weaknesses
- Species progression through campaign

### civilian-types.md
- Civilian unit types
- Civilian behavior
- Civilian AI
- Civilian casualties and score impact

### player-soldiers.md
- Soldier types and classes
- Soldier recruitment
- Soldier stats and growth
- Soldier specialization paths

### robot-mechanical-units.md
- Robotic unit types
- Mechanical unit stats
- Robot vulnerabilities and resistances
- Robot behavior patterns

### Salaries.md
- Salary system for personnel
- Salary tiers by unit type
- Salary scaling with rank/experience
- Monthly salary costs

### unit-actions.md
- Available unit actions
- Action categories
- Action costs
- Action restrictions and requirements

### unit-attributes.md
- Primary attributes (health/HP survivability, strength carrying capacity/melee damage, accuracy ranged attack hit chance, reactions reaction fire speed and chance, bravery morale and panic resistance, time units/action points actions per turn)
- Secondary attributes (armor value damage reduction, mobility movement speed and cost, sight radius vision range, throwing accuracy grenade precision, psionic strength ability power, psionic skill attack/defense)
- Derived stats (encumbrance weight vs strength, initiative turn order, critical hit chance, dodge/evasion)
- Stat ranges and scaling (rookie vs veteran differences, alien stat distributions)
- Stat growth and progression
- Stat impact on gameplay
- TOML definition for unit attributes
- Stat balance and tuning
- Hidden stats vs visible stats

### unit-equipment.md
- Equipment slots (primary weapon, secondary weapon, armor, accessories, utility items)
- Equipment weight and encumbrance
- Equipment restrictions by unit type
- Loadout management

### unit-experience.md
- Experience gain system
- Experience from combat actions
- Level progression
- Stat increases on level up
- Ability unlocks

### unit-fatigue.md
- Fatigue accumulation (mission duration, stress, injuries)
- Fatigue effects (stat penalties, increased injury risk)
- Fatigue recovery (rest between missions, medical facilities)
- Fatigue management strategies

### unit-injuries.md
- Injury system
- Injury types (light wounds, severe wounds, critical injuries)
- Injury effects on stats
- Recovery time
- Medical treatment
- Permanent injuries

### unit-morale.md
- Morale system overview
- Morale states (high morale confident/bonuses, normal morale baseline, low morale shaken/penalties, panicked loss of control/flee/cower, berserk rare/uncontrolled aggression)
- Morale value and thresholds (morale range 0-100, panic threshold based on bravery stat)
- Morale modifiers and factors (seeing allies killed morale loss, seeing enemies killed morale gain, taking damage/wounded, being under fire or suppressed, witnessing psionics or terror units, commander presence morale boost, mission success/failure)
- Panic checks and rolls (when panic checks occur, panic chance calculation: morale + bravery, panic effects see Unit Panic.md)
- Morale recovery (natural recovery over turns, successful actions: kills/healing allies, commander abilities or items)
- Morale impact on performance (accuracy penalties when low, reduced reactions)
- Morale and alien units
- TOML configuration for morale system

### unit-movement.md
- Movement mechanics
- Movement costs by terrain
- Movement modes (walk, run, crouch-walk, crawl)
- Climbing and swimming
- Movement and action points

### unit-panic.md
- Panic triggers (low morale, witnessing deaths, psionic attacks, terror units)
- Panic effects (berserk uncontrolled shooting, cower hiding and no actions, flee running away from danger, surrender dropping weapon)
- Panic recovery (morale recovery, rally abilities, successful actions)
- Panic and mission failure

### unit-psionics.md
- Psionic system overview
- Psionic strength and potential (PSI attribute range 0-100, rarity 5-10% of humans, training requirement minimum PSI 20, growth through training and experience)
- Psionic energy pool (maximum energy: PSI × 10 points, recovery rate: 5 points per turn + PSI bonus, overuse penalty: sanity loss, faster regeneration out of combat)
- Psionic stability (stability range 0-100, base stability: 50 + PSI÷2, training bonus: +10 per level, low stability increases backlash chance)
- Psionic abilities offensive: mind blast (20 energy, 15 tiles, PSI÷2 psychic damage + -10 sanity, 10% backlash if stability <50), panic broadcast (30 energy, 10 tile radius, forces panic check, 3 turn duration), mind control (50 energy, 8 tiles, take control 2-4 turns, requires caster PSI > target PSI, severe sanity loss if resisted)
- Psionic abilities defensive: mind shield (15 energy sustained, +30% psionic resistance, +10% sanity protection), telekinetic barrier (25 energy, blocks projectiles 3×3 area, 3 turns, blocks damage up to PSI×2), psi drain (10 energy, drains target psionic energy)
- Psionic abilities support (not fully detailed in excerpt)
- Psionic training and development (training requirements, experience and growth, psionic research)
- Psionic combat (psionic initiative, counter-psionics, psionic warfare tactics)
- Dangers and side effects (sanity degradation, physical effects, control loss)
- Psionic units and classes (psionic operatives, alien psionics)
- Psionic research tree
- TOML configuration
- Balance considerations

### unit-reactions.md
- Reaction fire system
- Reaction triggers (enemy movement in sight, enemy actions in sight)
- Reaction chance calculation (reactions stat, reserved TU/AP)
- Reaction shots (snapshot using reserved AP/TU)
- Overwatch mode
- Opportunity fire

### unit-sanity.md
- Sanity system (mental health tracking)
- Sanity loss triggers (psionic attacks, witnessing horrors, prolonged stress)
- Sanity effects (hallucinations, impaired judgment, panic susceptibility)
- Sanity recovery (rest, therapy, medication)
- Permanent sanity damage

### unit-status-effects.md
- Status effect types (buffs, debuffs, conditions, damage over time)
- Status effect duration
- Status effect stacking
- Status effect removal
- Common status effects (stunned, bleeding, poisoned, burning, frozen, inspired, suppressed, panicked, mind controlled)

---

## USER INTERFACE

### Accessibility.md
- Accessibility features
- Colorblind modes
- Text scaling
- Input alternatives
- Difficulty accessibility options

### basescape-ui.md
- Base management UI
- Facility placement interface
- Construction queue display
- Personnel roster interface
- Base statistics display

### battlescape-ui.md
- Tactical combat UI
- Unit selection interface
- Action buttons and hotkeys
- AP/TU display
- Enemy information display
- Cover indicators
- LOS visualization
- Targeting reticule
- Action confirmation

### geoscape-ui.md
- World map interface
- Time controls
- UFO detection alerts
- Mission notifications
- Base selection
- Craft management interface
- Funding and score display
- Territory control visualization

### menus-and-navigation.md
- Main menu structure
- Save/load interface
- Options menu
- In-game pause menu
- Navigation between game layers

### Notifications.md
- Notification system (events, alerts, warnings, information)
- Notification priority levels
- Notification display (pop-ups, message log, status bar)
- Notification filtering
- Sound and visual alerts

### Tooltips.md
- Tooltip system
- Contextual information display
- Stat explanations
- Action cost previews
- Equipment information tooltips

### ui-design-guidelines.md
- UI design principles
- Visual consistency
- Color schemes
- Icon design
- Font usage
- Layout standards
- Responsive design

### widgets/ (folder)
- Custom UI widget library
- Button widgets
- Panel widgets
- List widgets
- Input widgets
- Display widgets

---

## DESIGN

### balancing-framework.md
- Balancing philosophy
- Balancing methodology
- Testing procedures
- Iterative balance tuning
- Community feedback integration

### difficulty-settings.md
- Difficulty levels (easy, normal, hard, brutal)
- Difficulty modifiers (enemy stats, resource availability, mission frequency, tactical options)
- Custom difficulty settings
- Dynamic difficulty adjustment

### game-design-document.md
- Design vision and goals
- Core gameplay pillars (strategic layer geoscape, tactical layer battlescape, base management layer, economy and resource management)
- Player experience goals (tension and challenge, strategic depth, tactical mastery, progression and growth, narrative and setting)
- Game loop overview (strategic phase, tactical phase, management phase, feedback loop)
- Core mechanics summary (turn-based combat, action point economy, base building, research and manufacturing, interception and detection, AI and opponent behavior)
- System integration philosophy (deterministic design, moddability first, data-driven systems, TOML configuration)
- Balancing framework
- Difficulty settings
- Accessibility features
- Victory and defeat conditions
- Campaign structure
- Mission variety
- Lore and setting
- MVP scope definition
- Development priorities
- Technical architecture overview (Love2D implementation)
- References and inspirations (XCOM, X-COM)

### game-loop-overview.md
- Core gameplay loop structure (geoscape loop: UFO detection/interception/mission generation, basescape loop: research/manufacturing/base expansion, battlescape loop: tactical missions/loot recovery/unit progression)
- Time progression and pacing (short-term goals: complete mission/research tech, medium-term goals: expand base/field new equipment, long-term goals: defeat alien invasion/unlock endgame)
- Positive feedback loops (better tech → easier missions → more resources)
- Negative feedback loops (high score attracts tougher aliens)
- Player agency and meaningful choices
- Risk vs reward decision points
- Emergent gameplay from system interactions
- Progression gates and unlocks
- Failure recovery and setback mitigation
- Endgame content and replayability
- Sandbox mode and open-ended play
- Victory and defeat conditions
- Player retention mechanics
- Engagement hooks and variety

### mvp-scope-definition.md
- Minimum viable product scope
- Core features for MVP
- Feature prioritization
- MVP milestones
- Post-MVP roadmap

### victory-defeat-conditions.md
- Victory conditions (defeat alien invasion, achieve strategic objectives, narrative completion)
- Defeat conditions (funding withdrawal, base loss, total personnel loss, economic collapse)
- Alternate endings
- Sandbox mode (no victory/defeat conditions)

---

## DEVELOPMENT

### anti-patterns.md
- Common development anti-patterns to avoid
- Code smell examples
- Architectural pitfalls
- Performance anti-patterns

### api-quick-reference.md
- Quick API reference for common functions
- Frequently used APIs
- Code snippets

### architecture-component-system.md
- Component-based architecture
- Entity-component system (ECS)
- Component definitions
- System interactions

### architecture-data-flow.md
- Data flow patterns
- State management
- Event propagation
- Data synchronization

### architecture-event-system.md
- Event system architecture
- Event types
- Event listeners and handlers
- Event propagation and bubbling

### architecture-module-organization.md
- Module structure
- Module dependencies
- Module loading order
- Namespace management

### architecture-system-dependency-graph.md
- System dependency visualization
- Dependency management
- Circular dependency prevention
- Load order optimization

### audio-system.md
- Audio engine integration
- Sound effect management
- Music system
- Audio mixing
- Volume controls

### configuration-system.md
- Configuration management
- TOML configuration files
- Configuration loading and validation
- Configuration hot-reloading

### console-commands.md
- Debug console
- Console command list
- Cheat commands
- Debug visualization commands

### data-flow-cheatsheet.md
- Data flow quick reference
- Common data patterns
- State update flows

### data-structures.md
- Core data structures used
- Custom data structures
- Performance considerations
- Memory layout

### debug-tools.md
- Debug mode features
- Debug visualization overlays
- Performance profiling tools
- Log filtering and analysis

### debugging-guide.md
- Debugging strategies
- Common issues and solutions
- Debugging tools usage
- Performance debugging

### file-system.md
- File system organization
- Asset loading
- Save file management
- Mod file handling

### input-system.md
- Input handling architecture
- Keyboard input
- Mouse input
- Controller support
- Input mapping and rebinding

### love2d-integration.md
- Love2D framework integration
- Love2D callback usage
- Love2D module usage
- Best practices for Love2D

### lua-scripts.md
- Lua scripting guide
- Lua best practices
- Performance considerations
- Common Lua patterns

### numbers-reference.md
- Game balance numbers
- Formula reference
- Statistical tables
- Balance constants

### rendering-system.md
- Rendering architecture
- Draw order and layers
- Sprite rendering
- UI rendering
- Performance optimization

### Serialization.md
- Serialization system
- Save format
- Data serialization
- State persistence
- Version compatibility

### state-management.md
- State management architecture
- Game state objects
- State transitions
- State persistence

### system-diagram.md
- System architecture diagrams
- Component relationships
- Data flow visualization

### toml-format.md
- TOML configuration format
- TOML best practices
- TOML validation
- TOML examples

---

## MODDING

### content-generator-tools.md
- Generator tool overview
- Tool usage guides
- Automated content creation

### getting-started-with-mods.md
- First mod tutorial
- Development environment setup
- Basic mod creation steps
- Testing and debugging mods

### lua-scripting.md
- Lua scripting API for mods
- Available hooks and callbacks
- Scripting examples
- Scripting best practices

### mod-api-reference.md
- Complete mod API documentation
- Available APIs by category
- Function signatures
- Usage examples

### mod-dependencies.md
- Dependency declaration
- Load order management
- Conflict resolution
- Dependency resolution

### mod-structure.md
- Mod directory layout
- Required files (mod.toml manifest)
- Optional files
- Asset organization

### mod-validation.md
- Mod validation tools
- Error checking
- Balance testing
- Integration testing

### modding-overview.md
- Modding philosophy (data-driven design, TOML configuration, Lua scripting capabilities, asset replacement)
- Mod structure (directory layout, required files, metadata and manifests, version compatibility)
- Getting started (environment setup, first mod tutorial, testing and debugging, publishing)
- TOML configuration modding (configurable systems: facilities/units/weapons/equipment/research trees/manufacturing/AI behavior/campaign settings)
- Lua scripting API (available APIs, event hooks, custom behaviors, game logic extension)
- Content generator tools (facility generator, weapon generator, mission generator, campaign generator)
- Mod API reference (core systems API, battle systems API, UI/UX API)
- Mod dependencies (dependency management, load order, conflict resolution)
- Mod validation (validation tools, error checking, balance testing, integration testing)
- Community modding (mod repository, distribution, guidelines)
- Example mods (total conversion, balance mods, content expansion, UI mods)

### toml-configuration.md
- TOML configuration system for mods
- Configuration file structure
- Available configuration options
- Configuration examples

### generators/ (folder)
#### generator-base-script-generator.md
- Base script generator tool
- Generating base templates
- Customization options

#### generator-campaign-generator.md
- Campaign generator tool
- Campaign structure generation
- Event and mission scripting

#### generator-craft-class-generator.md
- Craft class generator
- Craft stat generation
- Craft type templates

#### generator-event-generator.md
- Event generator tool
- Event scripting
- Event triggers and outcomes

#### generator-facility-generator.md
- Facility generator tool
- Facility stat generation
- Facility type templates

#### Generator-README.md
- Generator tools overview
- Tool installation and usage
- Generator workflow

---

## TUTORIALS

### code-examples.md
- Code examples for common tasks
- Pattern examples
- Implementation examples

### document-rewrite-examples.md
- Documentation examples
- Documentation standards
- Writing style guide

### tutorial-adding-a-weapon.md
- Step-by-step weapon addition
- Weapon TOML definition
- Weapon asset integration
- Weapon balancing

### tutorial-creating-a-mission-type.md
- Step-by-step mission type creation
- Mission TOML definition
- Mission logic scripting
- Mission testing

### tutorial-creating-a-mod.md
- Complete mod creation tutorial
- Mod project setup
- Mod testing and distribution

### tutorial-custom-ai-behavior.md
- Custom AI behavior creation
- Behavior scripting
- AI testing and tuning

---

## META (DOCUMENTATION AND WIKI)

### completion-summary.md
- Wiki completion status
- Completed sections
- Remaining work

### cross-reference-index.md
- Document cross-references
- Link validation
- Related document mapping

### documentation-standards.md
- Documentation writing standards
- Formatting guidelines
- Metadata requirements
- Review process

### filename-standardization-guide.md
- File naming conventions
- Directory structure standards
- Consistency guidelines

### frontmatter-template.md
- Document frontmatter format
- Required metadata fields
- Optional metadata fields
- Frontmatter examples

### quality-report.md
- Documentation quality metrics
- Quality issues tracking
- Improvement recommendations

### quick-reference.md
- Quick reference index
- Common topics quick access
- Cheat sheets

### structure-visual-guide.md
- Wiki structure visualization
- Navigation guide
- Section organization

### template-library.md
- Document templates
- Section templates
- Formatting templates

### topic-clusters.md
- Topic clustering for navigation
- Related topic grouping
- Conceptual organization

### wiki-analysis.md
- Wiki analytics
- Usage statistics
- Coverage analysis

---

## ROOT-LEVEL DOCUMENTS

### contributing.md
- Contribution guidelines
- How to contribute to wiki
- Contribution workflow

### faq.md
- Frequently asked questions
- Common issues and solutions
- Quick answers

### glossary.md
- Game terminology definitions
- Technical terms
- Acronyms and abbreviations

### navigation.md
- Wiki navigation guide
- Document organization
- How to find information

### quick-start-guide.md
- Quick start for new players
- Essential concepts
- First steps

### QUICK_REFERENCE.md
- Quick reference for game mechanics
- Cheat sheet
- Formula reference

### README.md
- Wiki introduction
- How to use the wiki
- Document structure overview

### references.md
- External references
- Inspirational sources
- Technical references
- Related games and systems

---

## END OF SUMMARY

This document captures all unique game mechanics, systems, and features documented across the AlienFall wiki. Use this as a reference when migrating content to new formats or implementing features.
