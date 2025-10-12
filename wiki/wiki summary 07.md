# AlienFall Love2D - Game Mechanics Summary

## Document Purpose
High-level summary of unique game mechanics implemented in the AlienFall Love2D codebase. This document extracts the core gameplay systems and mechanics from each file/folder for reference when migrating or reusing this design wiki.

**Last Updated:** October 9, 2025
**Source Directory:** `src/`

---

## AI Systems (`ai/`)

### AIDirector.lua
- **Strategic AI Management**
  - Campaign pressure system with authority levels (tactical, operational, strategic)
  - Decision cadences (immediate, daily, weekly, monthly)
  - Legitimacy system (0-100) affecting AI behavior
  - Mission scheduling and resource allocation
  - Dynamic priority weighting based on campaign state
  - RNG-scoped deterministic behavior using campaign seed
  - Event-driven AI responses to player actions
  - Mission success/failure adjustments to pressure
  - Unit and base destruction impact on AI planning
  - Funding threshold monitoring for strategic decisions
  - Interceptor count optimization
  - Coverage ratio analysis
  - Tech level progression tracking
  - Recent mission history evaluation
  - TOML-driven configuration loading (director.toml, campaigns.toml, weights.toml)
  - Telemetry logging for AI debugging
  - Campaign template system for narrative arcs

---

## Base Management (`basescape/`)

### BaseBuilder.lua
- **Satellite Base Construction**
  - Phased development system: planning → foundation → development → operational
  - Risk management with three risk levels (low, medium, high)
  - Base size templates (small/medium/large):
    - Small: 3x3 grid, reconnaissance focus, 14 days, $150K
    - Medium: 5x5 grid, interception hub, 28 days, $450K
    - Large: 7x7 grid, regional command, 42 days, $900K
  - Province control validation before construction
  - Initial facility planning and costing
  - Total construction time and cost calculation
  - Risk modifiers based on base size
  - Construction project tracking with unique IDs
  - Integration with financial system for cost management
  - Construction queue per base
  - Event bus notifications for construction milestones

### BaseManager.lua
- **Base Operations and Layout**
  - Grid-based base layout (default 20x20 logical tiles)
  - Base lifecycle states: planning, constructing, operational, destroyed
  - Facility placement and management system
  - Power grid connectivity tracking
  - Corridor/access network management
  - Construction progress tracking (0-100)
  - Personnel assignment and staffing requirements
  - Monthly operational costs calculation
  - Capacity aggregation from facilities
  - Service management through ServiceManager
  - 2D grid cell tracking with properties:
    - Terrain type
    - Facility assignment
    - Power connection status
    - Access connection status
    - Blocked/available status
  - Integration with tactical battlescape for base defense missions

### CapacityManager.lua
- **Resource Constraints and Limits**
  - Four capacity types:
    - Storage: volume-based (items, resources, fuel)
    - Slots: integer-based (personnel, craft berths, prisoners)
    - Throughput: rate-based (research points/day, man-hours)
    - Service: boolean capabilities (power, comms, medical, radar)
  - Five overflow policies:
    - Block: prevent operations exceeding capacity
    - Queue: queue excess requests
    - Auto-sell: automatically sell excess at market rate
    - Auto-transfer: transfer to other bases
    - Discard: remove excess with penalties
  - Capacity reservation system for planned operations
  - Facility contribution tracking
  - Dynamic capacity recalculation when facilities change
  - Capacity types managed:
    - Item storage
    - Resource storage (elerium, alloys, etc.)
    - Fuel storage
    - Personnel quarters (standard and officer)
    - Craft berths and transport slots
    - Prisoner cells
    - Manufacturing hours
    - Research points
    - Training XP
    - Power generation (boolean)
    - Communications (boolean)
    - Medical facility (boolean)
    - Radar coverage (boolean)
  - Usage tracking and availability queries
  - Event notifications for capacity overflow situations

### Facility.lua
- **Facility Base Class**
  - Five facility states: constructing, operational, damaged, destroyed, offline
  - Health and armor damage system (0-100 HP)
  - Grid position tracking (x, y, width, height)
  - Connectivity requirements (power, access)
  - Construction progress tracking
  - Capacity contributions to base totals
  - Service tags for capability provision
  - Operational properties:
    - Power consumption
    - Monthly maintenance cost
    - Staffing requirements by role
  - Tactical integration with map blocks for battlescape
  - Damage logging for repair prioritization
  - Construction cost and time requirements
  - Construction prerequisites validation

### FacilityConstructionService.lua
- **Construction Management**
  - Facility construction lifecycle management
  - Construction queue processing
  - Resource allocation and validation
  - Construction time estimation
  - Daily construction progress updates
  - Construction completion handling
  - Integration with base grid placement
  - Cost validation and deduction
  - Event emission for construction milestones
  - Multi-base construction coordination

### FacilityGrid.lua
- **Grid Placement System**
  - 2D grid-based facility placement
  - Collision detection for facility placement
  - Adjacency validation for facility connections
  - Grid serialization for save/load
  - Visual representation helpers
  - Facility removal and replacement handling
  - Underground vs surface level tracking

### MonthlyReport.lua
- **Financial Reporting**
  - Monthly income tracking from funding nations
  - Expense categorization (salaries, maintenance, operations)
  - Base-specific cost breakdowns
  - Research and manufacturing cost tracking
  - Mission recovery income
  - Black market sales revenue
  - Net profit/loss calculation
  - Trend analysis over multiple months
  - Report generation for player review
  - Export to various formats

### ServiceManager.lua
- **Base Services Coordination**
  - Service availability tracking
  - Service dependencies management
  - Power distribution system
  - Communications network
  - Medical services coordination
  - Radar coverage calculation
  - Service interruption handling
  - Priority-based service allocation
  - Emergency service protocols

### facilities/ (Specific Facilities)
#### AccessLift.lua
- Entry point facility
- Mandatory for all bases
- Provides access to underground levels
- Cannot be destroyed without base loss
- Tactical significance as spawn point

---

## Tactical Combat (`battlescape/`)

### ActionMenu.lua
- **Unit Action Interface**
  - Context-sensitive action menus
  - Action availability checking based on unit state
  - AP cost preview for actions
  - Equipment-based action options
  - Stance change controls (crouch, prone, stand)
  - Reload and inventory management
  - Special ability triggers
  - End turn confirmation

### ActionSystem.lua
- **Action Point Economy**
  - Action validation pipeline
  - AP cost calculation with modifiers:
    - Base costs per action type
    - Distance-based costs for movement
    - Terrain modifiers (normal, difficult, etc.)
    - Stance penalties (crouch 1.5x, prone 2.0x)
    - Suppression penalties
    - Range modifiers for attacks
  - Energy cost system for special abilities:
    - Psionic attack (3 energy)
    - Psionic defense (2 energy)
    - Berserk (5 energy)
    - Mind control (4 energy)
  - Action execution pipeline
  - Action history tracking for replay/debugging
  - Pending action queue for complex sequences
  - Turn management integration
  - Action-specific validation:
    - Movement path validation
    - Destination accessibility checks
    - Unit collision detection
    - Line of sight verification for attacks
    - Range checking for weapons
    - Ammunition availability
  - Deterministic action resolution

### BattleMap.lua
- **Tactical Map Management**
  - Tile-based map representation
  - Map dimensions and boundaries
  - Tile properties (terrain, cover, elevation)
  - Unit position tracking
  - Object placement (furniture, props)
  - Destructible environment support
  - Map generation integration
  - Fog of war state management
  - Save/load serialization

### BattlescapeAI.lua
- **Tactical AI Behavior**
  - Utility-based AI decision making
  - Cover evaluation and seeking
  - Target prioritization:
    - Threat assessment
    - Opportunity targeting
    - Focus fire coordination
  - Movement planning with pathfinding
  - Grenade throw calculations
  - Overwatch positioning
  - Flanking maneuvers
  - Retreat conditions
  - Panic behavior simulation
  - Patrol patterns for unalerted aliens
  - Alert status propagation
  - AI cheating prevention (no omniscience)

### BattleTile.lua
- **Tile System**
  - Tile properties (terrain type, elevation, cover value)
  - Visibility state (visible, explored, unseen)
  - Occupancy tracking (units, objects)
  - Destructible tile support
  - Fire and smoke effects
  - Line of sight blocking
  - Movement cost calculation
  - Cover direction tracking (north, south, east, west)
  - Tile damage states

### CombatSystem.lua
- **Deterministic Combat Resolution**
  - Four damage types: kinetic, energy, explosive, incendiary
  - Hit confirmation with accuracy tables
  - Accuracy calculation factors:
    - Base weapon accuracy
    - Distance/range modifiers
    - Stance modifiers (shooter and target)
    - Movement penalties (-20% if moved)
    - Suppression effects (-30%)
    - Cover modifiers
    - Environmental modifiers (smoke, darkness)
    - Unit skill bonuses
    - Status effects (panic -25%, berserk +10%)
  - Accuracy clamped to 5-95% range
  - Damage calculation pipeline:
    - Base weapon damage
    - Damage roll with variance
    - Armor mitigation
    - Critical hit system
    - Overkill handling
  - Combat effects application:
    - Suppression
    - Status effects
    - Environmental damage (fire spread)
  - Combat history logging for debugging
  - Overwatch/reaction fire system
  - Event emission for combat resolution

### EnvironmentSystem.lua
- **Environmental Effects**
  - Smoke propagation and dissipation
  - Fire spread mechanics
  - Explosive destruction
  - Light level management (day/night/indoor)
  - Weather effects (rain, fog)
  - Visibility modifiers from environment
  - Tile destruction cascades
  - Environmental damage to units
  - Gas/poison cloud mechanics

### LineOfFire.lua
- **Targeting System**
  - Projectile path calculation
  - Obstruction detection
  - Cover detection along path
  - Friendly fire checking
  - Collateral damage prediction
  - Targeting assistance (highlight valid targets)
  - Shot accuracy preview

### LineOfSight.lua
- **Visibility Calculation**
  - Deterministic LOS using mission seed
  - Personal unit sight vs team union visibility separation
  - Sight budget system with occlusion costs:
    - Base sight stat per unit
    - Night multiplier (0.5x)
    - Equipment bonuses (night vision, etc.)
    - Trait bonuses
  - Occlusion cost by tile type:
    - Open: 1
    - Semi-transparent: 2
    - Smoke: 3
    - Fire: 5
    - Solid: 999 (blocking)
  - Environmental effect modifiers
  - Flood fill visibility calculation
  - Performance caching by turn
  - Team visibility aggregation for fog of war
  - Tile visibility states (visible, explored, unseen)

### map_generator.lua
- **Procedural Map Generation**
  - Map block assembly system
  - Terrain type placement
  - Cover object generation
  - Entry/exit point placement
  - Mission-specific layouts
  - Randomized with deterministic seed
  - Biome-appropriate theming

### MapTileset.lua
- **Tileset Management**
  - Tile graphics loading
  - Tile animation support
  - Terrain type to sprite mapping
  - Cover visualization
  - Multi-layer rendering support

### MissionObjectives.lua
- **Mission Goal System**
  - Multiple objective types:
    - Eliminate all enemies
    - Secure location
    - Rescue VIP
    - Retrieve item
    - Survive duration
    - Prevent destruction
  - Objective completion tracking
  - Failure condition checking
  - Time limits
  - Optional vs required objectives
  - Scoring based on objective completion

### MoraleSystem.lua
- **Psychological Combat Mechanics**
  - Morale meter (0-100) per unit
  - Four morale states:
    - Normal (above 20)
    - Panicked (below 20)
    - Berserk (below 10)
    - Surrendered (below 5)
  - Morale damage sources:
    - Ally deaths (especially nearby)
    - Taking damage
    - Seeing aliens
    - Being outnumbered
    - Low health
  - Morale recovery sources:
    - Killing enemies
    - Completing objectives
    - Officer presence
    - Successful actions
  - State transition handling:
    - Panic: lose control, random actions
    - Berserk: aggressive but reckless
    - Surrender: drops weapon, immobilized
  - Morale modifiers by unit traits
  - Commander morale leadership bonuses
  - Morale history tracking for analysis

### MoraleManager.lua
- **Morale Event Processing**
  - Event subscription for morale-affecting actions
  - Batch morale updates for efficiency
  - Morale contagion (panic spreading)
  - Recovery rate management
  - Morale status UI updates

### Pathfinding.lua
- **A* Pathfinding**
  - Tile-based pathfinding with A* algorithm
  - Movement cost calculation:
    - Terrain type costs (open 1, road 0.5, rough 2, difficult 3, impassable 999)
    - Unit movement type modifiers (flying 0.5x)
    - Large unit narrow passage restrictions
    - Smoke modifier (1.5x)
    - Fire modifier (2.0x)
  - Manhattan distance heuristic
  - 8-directional movement with diagonal costs (1.414)
  - Tile walkability validation
  - Unit collision avoidance
  - Performance caching for repeated queries
  - Path smoothing for display

### pools.lua
- **Object Pooling**
  - Combat entity recycling (projectiles, effects)
  - Memory optimization
  - Reduced garbage collection
  - Pre-allocated object pools

### SanityManager.lua
- **Sanity System (Lovecraftian mechanics)**
  - Sanity meter separate from morale
  - Alien encounter sanity damage
  - Psionic attack sanity effects
  - Insanity thresholds and effects
  - Long-term sanity recovery

### SmokeFireLayer.lua
- **Environmental Layer Management**
  - Smoke tile tracking and rendering
  - Fire tile tracking and spread
  - Layer opacity calculation
  - Dissipation over time
  - Visual effect rendering

### SpatialIndex.lua
- **Spatial Query Optimization**
  - Fast nearest unit queries
  - Area-of-effect target finding
  - Grid-based spatial hashing
  - Performance optimization for large maps

### Terrain.lua
- **Terrain Definition System**
  - Terrain type properties
  - Movement cost definitions
  - Cover value assignments
  - Destructibility settings
  - Visual theme associations

### TilemapRenderer.lua
- **Battlefield Rendering**
  - Isometric or orthogonal rendering
  - Multi-layer tile rendering
  - Unit sprite rendering
  - Effect overlay rendering
  - Fog of war visualization
  - Camera controls

### TurnIndicator.lua
- **Turn Order Display**
  - Initiative order visualization
  - Current unit highlight
  - Upcoming turn preview
  - Turn phase indication

### UnitAction.lua
- **Action Definitions**
  - Action data structures
  - Action validation helpers
  - Action cost lookups
  - Action effect descriptions

### gui/squad_panel.lua
- **Squad Management UI**
  - Unit roster display
  - Health/morale indicators
  - Unit selection
  - AP/Energy display
  - Status effect icons

### map/MapBlock.lua
- **Modular Map Components**
  - Reusable map block definitions
  - Block connection points
  - Block rotation support
  - Themed block sets

### map/MapGenerator.lua
- **Advanced Map Generation**
  - Multi-block assembly
  - Connection validation
  - Spawn point placement
  - Objective location selection

### map/MapNode.lua
- **Map Graph Nodes**
  - Node-based map representation
  - Connection tracking
  - Pathfinding graph support

### map/MapScript.lua
- **Scripted Map Events**
  - Turn-based triggers
  - Conditional events
  - Reinforcement spawning
  - Environmental changes

### map/TileSet.lua
- **Tile Set Definitions**
  - Tile graphics organization
  - Tile property databases
  - Theme definitions

---

## Core Systems (`core/`)

### error_manager.lua
- **Error Handling**
  - Centralized error catching
  - Error logging and reporting
  - Graceful degradation
  - Error recovery strategies
  - User-friendly error messages

### gamepad_manager.lua
- **Controller Support**
  - Gamepad input mapping
  - Controller detection
  - Button/stick configuration
  - Vibration/rumble support
  - Multiple controller support

### input_buffer.lua
- **Input Buffering**
  - Input event queuing
  - Frame-perfect input timing
  - Input history for replay
  - Input conflict resolution

### input_validation.lua
- **Input Sanitization**
  - Input bounds checking
  - Invalid input rejection
  - Input normalization
  - Security validation

### main.lua
- **Application Entry Point**
  - Love2D callback setup
  - Module initialization
  - Main game loop
  - System bootstrapping

### StatRanges.lua
- **Stat Validation**
  - Minimum/maximum stat values
  - Stat clamping functions
  - Stat normalization
  - Data validation helpers

### config/ (Configuration)
- Game configuration management
- Settings persistence
- User preferences
- Mod configuration

### services/ (Core Services)
- Service registry pattern
- Dependency injection
- Service lifecycle management

### util/ (Utilities)
- Helper functions
- Common algorithms
- Data structure utilities

---

## Aircraft Systems (`crafts/`)

### Craft.lua
- **Craft Instance**
  - Craft state management (hangar, transit, combat, downed)
  - Position and velocity tracking
  - Fuel consumption
  - Weapon loadouts (up to 4 weapon slots)
  - Equipment slots
  - Crew assignment
  - Damage and repair system
  - Mission assignment tracking
  - Flight time and range calculation

### CraftClass.lua
- **Craft Type Definitions**
  - Craft archetypes (interceptor, transport, heavy fighter)
  - Base stats (speed, armor, fuel capacity)
  - Weapon compatibility
  - Crew capacity
  - Manufacturing requirements
  - Research prerequisites

### CraftEnergyPool.lua
- **Energy Management**
  - Energy capacity and regeneration
  - Weapon energy costs
  - Special ability energy requirements
  - Energy distribution priorities

### CraftLevel.lua
- **Craft Experience System**
  - Level progression (1-10+)
  - Experience from missions
  - Level-up bonuses (accuracy, evasion)
  - Pilot skill integration

### CraftManager.lua
- **Fleet Management**
  - Craft roster tracking
  - Assignment to bases
  - Maintenance scheduling
  - Repair queue management
  - Fuel restocking
  - Craft availability queries

### CraftService.lua
- **Craft Operations Service**
  - High-level craft management API
  - Craft creation and deletion
  - Mission assignment
  - Daily update processing
  - Integration with other systems
  - Craft status queries
  - Data loading from TOML

### EnergyPool.lua
- **Generic Energy System**
  - Energy pool data structure
  - Recharge rate calculation
  - Energy reservation system
  - Pool capacity upgrades

### ItemCraft.lua
- **Craft Items**
  - Craft weapons as items
  - Craft equipment as items
  - Installation costs
  - Compatibility checking

---

## Development Tools (`dev/`)

### Console.lua
- **In-Game Console**
  - Command-line interface
  - Cheat codes
  - Debug commands
  - System inspection
  - Real-time game state modification

### ConsoleCommands.lua
- **Console Command Library**
  - Add resources
  - Spawn units
  - Complete research instantly
  - Teleport to locations
  - Toggle god mode
  - Time acceleration
  - Reveal map

### DebugDraw.lua
- **Visual Debugging**
  - Collision box rendering
  - Pathfinding visualization
  - LOS ray display
  - Grid overlay
  - Performance metrics overlay

### Profiler.lua
- **Performance Profiling**
  - Function timing
  - Frame time analysis
  - Memory usage tracking
  - Bottleneck identification

### ProfilerUI.lua
- **Profiler Visualization**
  - Real-time performance graphs
  - Function call trees
  - Memory allocation display
  - Frame rate monitoring

---

## Economic Systems (`economy/`)

### BlackMarket.lua
- **Underground Trading**
  - Illegal item sales
  - Price fluctuations
  - Reputation system with black market
  - Risk of funding cuts if discovered
  - Unique items availability

### BlackMarketService.lua
- **Black Market Management**
  - Transaction processing
  - Price calculation
  - Item availability refresh
  - Discovery risk calculation

### EconomyService.lua
- **Economic Coordination**
  - Income from funding nations
  - Expense tracking
  - Budget forecasting
  - Financial reports
  - Multi-base financial consolidation

### ManufacturingEntry.lua
- **Manufacturing Recipe**
  - Item production requirements (resources, time, engineers)
  - Production cost
  - Workshop requirements
  - Prerequisites (research, facilities)
  - Production yield

### ManufacturingManager.lua
- **Manufacturing Coordination**
  - Active project tracking
  - Resource allocation
  - Engineer assignment
  - Production queue management
  - Completion handling

### ManufacturingProject.lua
- **Production Instance**
  - Project progress tracking
  - Resource consumption
  - Time estimation
  - Completion calculation

### ManufacturingService.lua
- **Manufacturing API**
  - Start/cancel projects
  - Query available items to manufacture
  - Check available capacity
  - Update production progress (daily)
  - Project completion events
  - Multi-base coordination
  - Queue processing
  - Engineer efficiency modifiers
  - Workshop efficiency bonuses

### MarketManager.lua
- **Market Operations**
  - Item buying and selling
  - Market price calculation
  - Supply and demand simulation
  - Transaction history

### MarketplaceService.lua
- **Market Service**
  - Purchase processing
  - Price queries
  - Market updates
  - Transaction logging

### PurchaseEntry.lua
- **Purchase Order**
  - Order details
  - Delivery time
  - Payment processing
  - Order status tracking

### ResearchEntry.lua
- **Research Project Definition**
  - Research requirements (scientists, lab space, prerequisites)
  - Research time
  - Research cost
  - Unlocks (items, facilities, missions)
  - Research dependencies

### ResearchProject.lua
- **Active Research**
  - Progress tracking
  - Scientist assignment
  - Breakthrough chances
  - Completion effects

### ResearchService.lua
- **Research Management**
  - Research tree management
  - Prerequisite checking
  - Start/cancel research projects
  - Available research queries
  - Completed research tracking
  - Daily research progress updates
  - Research completion handling:
    - Unlocking new manufacturing
    - Unlocking new facilities
    - Unlocking new missions
    - Story progression triggers
  - Multi-base research coordination
  - Scientist efficiency modifiers
  - Lab facility integration
  - Event emission for research milestones

### ResearchTree.lua
- **Technology Tree**
  - Research node relationships
  - Prerequisite graph
  - Unlock tree visualization
  - Available research calculation
  - Tree serialization

### Supplier.lua
- **External Supplier**
  - Supplier inventory
  - Delivery times
  - Pricing tiers
  - Supplier relationships

### SupplierService.lua
- **Supplier Management**
  - Multiple supplier coordination
  - Price comparison
  - Order placement
  - Delivery tracking

### TransferManager.lua
- **Inter-Base Transfers**
  - Item transfer requests
  - Transfer time calculation
  - Transfer progress tracking
  - Transfer completion

### TransferOrder.lua
- **Transfer Instance**
  - Transfer details (item, quantity, origin, destination)
  - Estimated arrival time
  - Transfer cost
  - Status tracking

### TransferService.lua
- **Transfer Coordination**
  - Initiate transfers
  - Track in-transit items
  - Process arrivals
  - Handle transfer interruptions (UFO interception)

---

## Engine Systems (`engine/`)

### asset_cache.lua
- **Asset Loading and Caching**
  - Image loading and caching
  - Font loading and caching
  - Sound effect caching
  - Music streaming
  - Cache invalidation
  - Memory management

### audio_stub.lua
- **Audio Fallback**
  - No-op audio implementation
  - Used when audio system unavailable
  - Silent playback for testing

### AudioSystem.lua
- **Sound and Music**
  - Sound effect playback
  - Music management with crossfading
  - Volume control (master, music, sfx)
  - 3D positional audio for battlescape
  - Audio channel management
  - Audio source pooling

### data_catalog.lua
- **Data Registry**
  - Centralized data storage
  - TOML data loading
  - Data access API
  - Mod data merging
  - Schema validation integration

### data_loader.lua
- **TOML Data Loading**
  - File reading
  - TOML parsing
  - Error handling
  - Hot reloading support

### event_bus.lua
- **Event System**
  - Publish-subscribe pattern
  - Event emission
  - Listener registration
  - Event priorities
  - Event queuing
  - Synchronous and asynchronous events

### logger.lua
- **Logging System**
  - Multiple log levels (trace, debug, info, warn, error, fatal)
  - File logging
  - Console logging
  - Log rotation
  - Timestamping
  - Module-specific loggers

### rng.lua
- **Random Number Generation**
  - Seeded RNG for determinism
  - RNG scopes for different systems
  - Save/load RNG state
  - Gaussian distribution support
  - Weighted random selection
  - Shuffle algorithms

### save_load_system.lua
- **Save/Load**
  - Game state serialization
  - Incremental saves
  - Save file compression
  - Save file versioning
  - Backward compatibility
  - Autosave functionality
  - Save file validation

### save.lua
- **Save File Format**
  - JSON-based save structure
  - Save metadata
  - Compression utilities
  - Checksum validation

### schema_validator.lua
- **Data Validation**
  - Schema definitions
  - Type checking
  - Required field validation
  - Range validation
  - Custom validators

### telemetry.lua
- **Analytics and Metrics**
  - Performance metrics collection
  - Gameplay statistics
  - Error reporting
  - Session tracking
  - Privacy-friendly telemetry

### turn_manager.lua
- **Turn-Based System**
  - Turn order calculation
  - Initiative system
  - Turn phase management
  - Turn history
  - Time unit allocation per turn

---

## Example Code (`examples/`)

### object_pool_usage.lua
- Demonstrates object pooling patterns
- Projectile system example
- Particle system example
- Performance comparison

### raycaster_demo.lua
- 3D raycasting visualization
- LOS demonstration
- Perspective rendering example

### tactical_battle_demo.lua
- Sample tactical battle setup
- AI behavior demonstration
- Combat system showcase

---

## Financial System (`finance/`)

### FinanceService.lua
- **Financial Management**
  - Monthly income from funding nations
  - Funding council satisfaction tracking
  - Expense categorization:
    - Base maintenance
    - Personnel salaries
    - Research costs
    - Manufacturing costs
    - Mission expenses
    - Interception costs
  - Budget forecasting
  - Financial reports
  - Loan system (optional)
  - Bankruptcy conditions
  - Income trends
  - Expense trends
  - Profit/loss tracking

---

## Strategic Layer (`geoscape/`)

### AlienActivityManager.lua
- **Alien Mission Management**
  - Mission type generation (scout, abduction, terror, etc.)
  - Activity level scaling over time
  - Region-specific activity
  - Mission scheduling
  - UFO spawning coordination
  - Alien resource tracking
  - Invasion progress mechanics
  - Activity pressure modifiers

### Biome.lua
- **Planetary Biomes**
  - Biome type definitions (desert, tundra, forest, urban, etc.)
  - Environment properties
  - Tactical map generation parameters
  - Flora and fauna
  - Weather patterns

### Country.lua
- **Nation States**
  - Country identification
  - Population
  - Funding contribution
  - Satisfaction level (0-100)
  - Alien infiltration level
  - Panic level
  - Special events
  - Withdrawal conditions

### craft_operations.lua
- **Craft Movement**
  - Craft waypoint navigation
  - Fuel consumption during flight
  - Return to base automation
  - UFO pursuit mechanics
  - Interception engagement

### detection_system.lua
- **UFO Detection**
  - Radar coverage calculation
  - Detection range by facility type
  - Detection accumulation over time
  - Stealth mechanics
  - Detection alerts

### GeoscapeService.lua
- **Strategic Layer Coordination**
  - Time management
  - Craft operations
  - Mission generation
  - UFO tracking
  - Country relations
  - Event handling

### mission_scheduler.lua
- **Mission Timing**
  - Mission spawn timing
  - Mission expiration
  - Mission priority calculation
  - Mission type selection

### MissionSiteGenerator.lua
- **Mission Locations**
  - Site placement on map
  - Site types (crash, landing, terror, base, etc.)
  - Site duration
  - Site cleanup

### Portal.lua
- **Inter-world Portals**
  - Portal locations
  - Portal activation conditions
  - Travel time between worlds
  - Portal defense mechanics

### Province.lua
- **Provincial Management**
  - Province boundaries
  - Province control (player, alien, neutral)
  - Resource generation
  - Population centers
  - Strategic value

### Region.lua
- **Regional Organization**
  - Multi-province regions
  - Regional bonuses
  - Regional threats
  - Regional missions

### UFO.lua
- **UFO Entities**
  - UFO mission types: scout, abduction, terror, infiltration, supply, battleship
  - UFO states: flying, landed, crashed, destroyed, retreating
  - UFO sizes: small (scout), medium (fighter), large (abductor), very large (battleship)
  - Position and heading tracking
  - Speed and altitude
  - Destination waypoints
  - Mission timer and duration
  - Detection and tracking status
  - Combat stats (health, armor, weapon power, evasion)
  - Stealth rating for detection resistance
  - Interception tracking
  - Recovery value and crew count
  - Movement updates
  - Destination reaching logic
  - Event bus integration

### UFOSpawner.lua
- **UFO Generation**
  - UFO type selection
  - Spawn timing
  - Spawn locations
  - Mission assignment
  - Wave spawning

### Universe.lua
- **Multi-World System**
  - Multiple worlds management
  - Inter-world travel
  - Universe-wide events
  - Portal network

### World.lua
- **World Management**
  - Single planetary system
  - Province/country/region hierarchy
  - Local time and rotation (24-hour cycle)
  - Globe tile map for pathfinding
  - Mission and campaign tracking
  - Detection system integration
  - Event bus coordination
  - Province addition and management
  - World configuration and scaling
  - Visual assets (background, etc.)
  - Statistics tracking

### WorldGenerator.lua
- **Procedural World Generation**
  - Province generation
  - Country placement
  - Resource distribution
  - Strategic point selection

### map_renderer.lua
- **Geoscape Rendering**
  - World map display
  - UFO visualization
  - Craft visualization
  - Mission site icons
  - Radar coverage overlay
  - Country boundaries

### pathfinding.lua
- **Global Navigation**
  - Air route calculation
  - Fuel-efficient paths
  - Obstacle avoidance (mountains, storms)
  - Multi-waypoint routes

### world_model.lua
- **World Data Model**
  - World state representation
  - Serialization support
  - Validation

---

## Graphics Utilities (`gfx/`)

### canvas_cache.lua
- **Render Target Caching**
  - Canvas creation and reuse
  - Render-to-texture optimization
  - Cache invalidation

### viewport_culling.lua
- **Visibility Culling**
  - Frustum culling
  - Off-screen object exclusion
  - Performance optimization

---

## Interception System (`interception/`)

### InterceptionAI.lua
- **Aerial Combat AI**
  - UFO tactical behavior
  - Position selection on 3x3 grid
  - Attack target selection
  - Retreat decision making
  - Formation tactics

### InterceptionService.lua
- **Aerial Combat System**
  - 3x3 grid-based interception:
    - Player positions: X, Y, Z (left column)
    - Alien positions: A, B, C (right column)
  - Combat outcomes: victory, stalemate, defeat
  - Round-based combat (max 10 rounds, timeout after 5)
  - Surprise round for undetected missions
  - Craft positioning (air layer preference)
  - AI system initialization
  - Turn processing (player then alien)
  - Combat resolution
  - Damage application
  - Craft destruction handling
  - Mission context tracking
  - Event bus integration for combat events

### gui/GridDisplay.lua
- **Interception UI**
  - 3x3 grid visualization
  - Craft health bars
  - Weapon status
  - Combat log
  - Action buttons

---

## Item System (`items/`)

### Item.lua
- **Base Item Class**
  - Item identification
  - Item name and description
  - Item weight and size
  - Stack size
  - Value/cost
  - Research requirements
  - Manufacturing requirements

### ItemCraft.lua
- **Craft Equipment**
  - Craft weapons
  - Craft addons (armor, sensors, etc.)
  - Installation requirements
  - Compatibility restrictions

### ItemCraftAddon.lua
- **Craft Modification Items**
  - Armor upgrades
  - Sensor upgrades
  - Engine upgrades
  - Special system modules

### ItemCraftWeapon.lua
- **Craft Armament**
  - Weapon stats (damage, rate of fire, range)
  - Ammunition types
  - Energy requirements
  - Fire modes

### ItemLore.lua
- **Story Items**
  - Alien artifacts
  - Research materials
  - No direct gameplay effect
  - Unlock lore entries

### ItemPrisoner.lua
- **Captured Aliens**
  - Species information
  - Research value
  - Interrogation options
  - Containment requirements

### ItemResource.lua
- **Raw Materials**
  - Elerium-115
  - Alien alloys
  - Weapon fragments
  - Corpses for research

### ItemUnit.lua
- **Personnel Equipment**
  - Weapons
  - Armor
  - Utility items
  - Ammunition

### ItemUnitArmour.lua
- **Soldier Armor**
  - Armor value by type
  - Weight
  - Mobility modifiers
  - Special abilities (flying, underwater)

### ItemUnitWeapon.lua
- **Soldier Weapons**
  - Damage type and amount
  - Accuracy table by range
  - Fire modes (snap, aimed, auto)
  - AP costs per shot
  - Ammunition capacity
  - Two-handed requirement

---

## Library Code (`lib/`)

### Middleclass.lua
- Lua OOP library
- Class definition
- Inheritance
- Mixins

### lume.lua
- Lua utility functions
- Functional programming helpers
- Math utilities

### inspect.lua
- Table serialization
- Debugging helper
- Pretty printing

---

## Lore System (`lore/`)

### Calendar.lua
- **In-Game Calendar**
  - Month/year tracking
  - Special dates
  - Seasonal events
  - Mission timing

### Campaign.lua
- **Story Campaigns**
  - Campaign phases
  - Narrative events
  - Victory conditions
  - Defeat conditions

### Faction.lua
- **Alien Factions**
  - Faction identification
  - Faction relations
  - Faction resources
  - Faction goals

### Mission.lua
- **Mission Definitions**
  - Mission types
  - Mission parameters
  - Mission rewards
  - Mission consequences

### Race.lua
- **Alien Species**
  - Species stats
  - Special abilities
  - Behavior patterns
  - Appearance data

### mission/ (Mission Types)
#### AlienBaseMission.lua
- Base assault missions
- Multiple stages
- Base destruction objectives

#### SiteMission.lua
- Ground mission sites
- Time-limited missions
- Various objectives

#### UFOMission.lua
- UFO crash/landing sites
- Recovery missions
- Alien crew composition

---

## Modding System (`mods/`)

### CatalogMerger.lua
- **Mod Data Merging**
  - Merge multiple mod catalogs
  - Conflict resolution
  - Priority handling
  - Override mechanics

### ContentDetector.lua
- **Mod Content Discovery**
  - Scan for mod files
  - Detect mod types
  - Validate mod structure

### DebugTools.lua
- **Mod Debugging**
  - Schema validation
  - Data inspection
  - Error reporting

### dependency_resolver.lua
- **Mod Dependencies**
  - Dependency graph building
  - Load order calculation
  - Circular dependency detection
  - Version compatibility

### DirectoryScanner.lua
- **File System Scanning**
  - Mod folder detection
  - File listing
  - Directory structure analysis

### HookManager.lua
- **Mod Hook System**
  - Pre/post function hooks
  - Event hooks
  - Code injection points
  - Hook priority system

### HookRunner.lua
- **Hook Execution**
  - Hook invocation
  - Hook chaining
  - Error isolation

### Loader.lua
- **Mod Loading**
  - Mod initialization
  - Asset loading
  - Code execution
  - Load order enforcement

### Validator.lua
- **Mod Validation**
  - Schema checking
  - Data integrity verification
  - Compatibility checks
  - Error reporting

---

## Organization Management (`organization/`)

### FameSystem.lua
- **Reputation Tracking**
  - Fame level calculation
  - Public opinion
  - Media coverage
  - Reputation effects on funding

### KarmaSystem.lua
- **Moral Choice Tracking**
  - Karma meter
  - Ethical decisions tracking
  - Consequences of actions
  - Story branching based on karma

### ScoreSystem.lua
- **Player Scoring**
  - Mission performance scores
  - Monthly ratings
  - Cumulative score
  - Ranking system
  - Achievements

---

## Encyclopedia (`pedia/`)

### PediaCategory.lua
- **Encyclopedia Categories**
  - Category hierarchy
  - Category descriptions
  - Entry organization

### PediaEntry.lua
- **Encyclopedia Entries**
  - Entry text
  - Images/diagrams
  - Research unlock conditions
  - Related entries

### PediaManager.lua
- **Encyclopedia Management**
  - Entry unlocking
  - Search functionality
  - Category browsing
  - Entry viewing history

---

## Procedural Generation (`procedure/`)

### EventGenerator.lua
- **Random Event Generation**
  - Event type selection
  - Event timing
  - Event parameters
  - Event consequences
  - Weighted probability tables

### ItemGenerator.lua
- **Procedural Items**
  - Random item stat generation
  - Unique item creation
  - Loot table rolling
  - Item quality/rarity system

### MapGenerator.lua
- **Map Generation**
  - Tile placement algorithms
  - Room generation
  - Corridor creation
  - Objective placement
  - Spawn point selection

### MissionGenerator.lua
- **Mission Creation**
  - Mission type selection
  - Difficulty calculation
  - Reward generation
  - Enemy composition
  - Map selection

### ProcGen.lua
- **Procedural Generation Framework**
  - Seeded generation
  - Generation pipelines
  - Generator coordination

### UnitGenerator.lua
- **Unit Creation**
  - Stat rolling with ranges
  - Trait assignment
  - Equipment selection
  - Name generation
  - Appearance randomization

---

## Screen Management (`screens/`)

### base_state.lua
- Base view screen
- Facility placement UI
- Construction management

### basescape_state.lua
- Base operations hub
- Screen navigation

### battlescape_state.lua
- Tactical combat screen
- Camera controls
- Unit selection
- Action execution

### briefing_state.lua
- Pre-mission briefing
- Squad selection
- Loadout assignment

### credits_state.lua
- Game credits
- Developer information

### debriefing_state.lua
- Post-mission results
- Statistics display
- Rewards/penalties

### geoscape_state.lua
- Strategic world view
- Time controls
- Craft management
- Mission selection

### HangarScreen.lua
- **Craft Management UI**
  - Craft roster display
  - Craft stats display
  - Weapon/equipment installation
  - Pilot assignment
  - Repair/refuel controls
  - Purchase new craft

### interception_state.lua
- Aerial combat screen
- Weapon selection
- Combat controls

### load_state.lua
- Load game screen
- Save file browser

### main_menu_state.lua
- Main menu
- New game, continue, options, exit

### manufacturing_state.lua
- Manufacturing management UI
- Project selection
- Engineer assignment
- Queue management

### new_game_state.lua
- New game setup
- Difficulty selection
- Starting location

### options_state.lua
- Settings menu
- Graphics, audio, controls, gameplay options

### research_state.lua
- Research management UI
- Available projects
- Scientist assignment
- Research tree visualization

### RosterScreen.lua
- **Personnel Management UI**
  - Soldier roster
  - Soldier stats display
  - Equipment assignment
  - Training assignment
  - Dismissal/promotion

### SaveLoadScreen.lua
- **Save/Load UI**
  - Save file list
  - Save/load operations
  - Save file information
  - Delete saves

### state_stack.lua
- Screen state management
- State transitions
- State stack manipulation

---

## Service Layer (`services/`)

### BaseManager.lua
- **Base Management Service**
  - Base creation and deletion
  - Base operations coordination
  - Multi-base management
  - Base status queries

### FinanceService.lua
- (Duplicate entry - see finance/ folder)

### InventoryService.lua
- **Global Inventory Management**
  - Item storage across all bases
  - Item transfers
  - Item availability queries
  - Capacity checking
  - Item reservation system

### ItemService.lua
- **Item Management Service**
  - Item creation and deletion
  - Item data loading
  - Item queries (by type, tag, etc.)
  - Item validation

### OrganizationService.lua
- **Organization Management**
  - Organization data (player faction)
  - Leadership tracking
  - Policy decisions
  - Organization reputation

### PediaService.lua
- **Encyclopedia Service**
  - Entry management
  - Unlock tracking
  - Search API
  - Entry retrieval

### time.lua (TimeService)
- **Game Time Management**
  - Time tracking (in-game date/time)
  - Time acceleration (pause, 5 min, 30 min, 1 hour, 1 day)
  - Turn-based time in tactical mode
  - Real-time in strategic mode
  - Time event triggering
  - Save/load time state

---

## Game Systems (`systems/`)

### DetectionSystem.lua
- **Mission Detection Mechanics**
  - Daily detection updates for all missions
  - Radar facility integration
  - Detection power calculation per mission
  - Distance-based detection falloff
  - Terrain/biome detection modifiers
  - Mission cover value reduction over time
  - Detection threshold system (missions become visible when cover depleted)
  - Multi-base radar cooperation
  - Performance caching for detection calculations
  - Logging and telemetry for detection events

---

## Unit Management (`units/`)

### equipment_calculator.lua
- **Equipment Stats Calculation**
  - Aggregate stats from equipped items
  - Weight calculation
  - Encumbrance effects
  - Equipped ability bonuses

### Medal.lua
- **Commendations**
  - Medal types
  - Award conditions
  - Medal effects (morale bonus, etc.)
  - Medal ceremonies

### Size.lua
- **Unit Size Categories**
  - Size definitions (tiny, small, medium, large, huge)
  - Tile occupation
  - Targeting modifiers
  - Equipment restrictions

### Trait.lua
- **Unit Traits**
  - Positive and negative traits
  - Stat modifiers from traits
  - Special abilities from traits
  - Trait requirements and restrictions

### Transformation.lua
- **Unit Transformations**
  - Psionic transformation
  - Cybernetic enhancement
  - Gene modding
  - Transformation requirements
  - Stat changes from transformation
  - Compatibility with unit classes

### Unit.lua
- **Unit Entity**
  - Base unit data structure
  - Stats (health, accuracy, reactions, etc.)
  - Equipment slots
  - Status effects
  - Experience and level
  - Morale and sanity
  - Actions per turn

### UnitClass.lua
- **Unit Classes**
  - Class definitions (soldier, scout, heavy, medic, engineer, psionic, etc.)
  - Base stat templates
  - Class-specific abilities
  - Equipment restrictions
  - Progression paths
  - Combat class identification
  - Specialist class identification

### UnitLevel.lua
- **Level Progression**
  - Experience thresholds
  - Stat gains per level
  - Ability unlocks
  - Max level cap

### UnitManager.lua
- **Unit Roster Management**
  - Unit creation and deletion
  - Unit assignment to squads/bases
  - Unit status tracking
  - Injury and recovery
  - Death and memorial

### UnitService.lua
- **Unit Operations Service**
  - High-level unit API
  - Unit queries
  - Unit operations
  - Integration with unit system

### UnitStats.lua
- **Stat Definitions**
  - Stat types and ranges
  - Stat calculations
  - Derived stats
  - Stat modifiers

### UnitSystem.lua
- **Unit System Core**
  - Unit data loading (classes, traits, levels, medals, sizes, transformations)
  - Unit creation with class-based defaults
  - Trait application to units
  - Ability updates based on class and rank
  - Unit storage and retrieval
  - Integration with data registry
  - Unit validation

### races/Race.lua
- **Unit Races**
  - Race definitions (human, alien species)
  - Racial stat modifiers
  - Special racial abilities
  - Appearance templates

---

## Utility Functions (`utils/`)

### object_pool.lua
- **Object Pooling Implementation**
  - Generic object pool class
  - Acquire/release pattern
  - Automatic reset function
  - Initial size and max size limits
  - Memory optimization

### ObjectPool.lua
- **Alternative Object Pool**
  - Different implementation
  - May have additional features

### performance_cache.lua
- **Performance Caching**
  - LRU cache implementation
  - Maximum cache size configuration
  - Cache invalidation by turn/frame
  - Specialized caching for:
    - Line of sight calculations
    - Pathfinding results
    - Combat calculations
    - Detection queries
  - Cache statistics tracking

---

## UI Widgets (`widgets/`)

### BaseWidget.lua
- **Widget Base Class**
  - Position and dimensions
  - Visibility state
  - Input handling (mouse, keyboard)
  - Focus management
  - Parent/child hierarchy
  - Update and render methods

### Button.lua
- **Button Widget**
  - Click detection
  - Hover state
  - Disabled state
  - Callback function
  - Visual states (normal, hover, pressed, disabled)

### Checkbox.lua
- **Checkbox Widget**
  - Checked/unchecked state
  - Toggle callback
  - Label text
  - Disabled state

### ComboBox.lua
- **Dropdown Menu**
  - Option list
  - Selection callback
  - Scrollable options
  - Search/filter

### Dialog.lua
- **Dialog Box**
  - Modal dialogs
  - Message display
  - Button options (OK, Cancel, Yes/No, etc.)
  - Custom button configuration
  - Dialog results

### ErrorNotification.lua
- **Error Display**
  - Error message display
  - Error severity levels
  - Dismissible notifications
  - Auto-dismiss timers

### GameButton.lua
- **Styled Game Button**
  - Game-specific styling
  - Icon support
  - Tooltip integration

### GameComboBox.lua
- **Styled Combo Box**
  - Game-specific styling
  - Custom rendering

### GameTooltip.lua
- **Tooltip System**
  - Hover tooltips
  - Delayed appearance
  - Multi-line support
  - Follow mouse or fixed position

### MultiSelectListBox.lua
- **Multi-Selection List**
  - Multiple item selection
  - Checkboxes per item
  - Select all/none
  - Selection callbacks

### ProgressBar.lua
- **Progress Bar Widget**
  - Current value and max value
  - Percentage display
  - Color customization
  - Vertical or horizontal orientation
  - Label text overlay

### RadioBox.lua
- **Radio Button Group**
  - Mutually exclusive selection
  - Option list
  - Selection callback
  - Vertical or horizontal layout

### ScrollableListBox.lua
- **Scrollable List**
  - Item list display
  - Scrollbar
  - Item selection
  - Tooltips per item
  - Dynamic item addition/removal

### Table.lua
- **Data Table Widget**
  - Column definitions
  - Row data
  - Sorting by column
  - Cell selection
  - Pagination
  - Custom cell renderers

### TextInput.lua
- **Text Input Field**
  - Single-line or multi-line
  - Input validation
  - Character limits
  - Placeholder text
  - Password mode (masked input)
  - Clipboard support

### TimeControls.lua
- **Time Control Widget**
  - Pause/play button
  - Speed selection buttons (1x, 5x, 30x, etc.)
  - Current time display
  - Integration with TimeService

### Tooltip.lua
- **Tooltip Widget**
  - Delayed display
  - Position calculation
  - Multi-line text support
  - Custom formatting

### TopPanel.lua
- **Top UI Panel**
  - Date and time display
  - Funds display
  - Quick navigation buttons
  - Alert indicators

---

## Additional Mechanics Summary

### Deterministic Systems
- All random elements use seeded RNG
- Mission seed for tactical combat
- Campaign seed for strategic events
- Enables save scumming prevention or replay consistency
- Ensures fair gameplay without hidden rolls

### Data-Driven Design
- Extensive use of TOML files for configuration
- Mod-friendly architecture
- Easy balance adjustments without code changes
- Clear separation of data and logic

### Multi-Layer Architecture
- Clear separation: Engine → Systems → Services → UI
- Service registry for dependency injection
- Event bus for decoupled communication
- Modular design for maintainability

### Performance Optimizations
- Object pooling for frequently created/destroyed objects
- Spatial indexing for fast queries
- Performance caching with LRU eviction
- Viewport culling for rendering
- Deferred calculations

### Save/Load System
- Comprehensive game state serialization
- Version migration support
- Compressed save files
- Autosave functionality
- Cloud save support (planned)

### Modding Support
- Hook system for code modification
- Data override system
- Asset replacement
- New content addition (items, units, facilities, missions)
- Mod conflict resolution
- Dependency management

### Accessibility
- Gamepad support
- Configurable controls
- Adjustable difficulty
- Colorblind modes (planned)
- Text scaling

### Tutorial and Help
- In-game encyclopedia (Pedia)
- Contextual tooltips
- Tutorial missions
- Help dialogs

---

## Unique Gameplay Mechanics Highlights

1. **3x3 Grid Interception**: Simplified but tactical aerial combat on a 3x3 grid
2. **Morale + Sanity**: Dual psychological systems (morale for battle, sanity for eldritch threats)
3. **Sight Budget LOS**: Novel line-of-sight using budgets and occlusion costs
4. **Multi-World Geoscape**: Not just Earth, but multiple planets with portals
5. **Black Market with Risk**: Underground trading with discovery consequences
6. **Detection Accumulation**: Missions aren't instantly detected, cover depletes over time
7. **Facility Grid Base Building**: Modular base construction on a grid
8. **Craft Experience**: Aircraft gain levels and bonuses from missions
9. **Unit Transformations**: Permanent character modifications (psionic, cybernetic, genetic)
10. **Karma + Fame + Score**: Triple reputation/scoring system
11. **Province-Based Strategy**: Territory control at province level, not just countries
12. **Manufacturing + Research Synergy**: Interdependent tech and production trees
13. **Inter-Base Transfers with Interception Risk**: Transfers can be attacked by UFOs
14. **Procedural Generation with Seeds**: Deterministic randomness for consistency
15. **AI Director for Campaign**: Meta-AI managing alien invasion progression
16. **Turn-Based Tactical with AP and Energy**: Dual resource management in combat
17. **Destructible Environment**: Terrain and buildings can be destroyed
18. **Smoke/Fire Environmental Layer**: Dynamic battlefield hazards
19. **Reaction Fire/Overwatch**: Interrupt enemy movement with reaction shots
20. **Capacity Management**: Detailed resource constraint system

---

## File Organization Patterns

### Naming Conventions
- **PascalCase** for classes: `UnitManager`, `ResearchService`
- **snake_case** for utilities and systems: `object_pool`, `data_loader`
- **lowercase** for libraries: `inspect.lua`, `lume.lua`

### Module Structure
- Classes use Middleclass OOP library
- Services follow registry pattern
- Systems are singleton-like managers
- Widgets extend BaseWidget

### Dependency Flow
- Engine provides foundational systems (RNG, events, logging)
- Core provides game-agnostic utilities
- Systems provide game-specific logic
- Services coordinate systems
- Screens use services and systems
- Widgets provide UI components

---

## Integration Points

### Key Integration Patterns
1. **Event Bus**: Decoupled communication between systems
2. **Service Registry**: Centralized service access
3. **Data Catalog**: Unified data access layer
4. **RNG Scopes**: Isolated random number generation
5. **Performance Cache**: Shared caching infrastructure

### Cross-System Dependencies
- **Geoscape ↔ Battlescape**: Mission transitions
- **Economy ↔ Base**: Resource management
- **Research ↔ Manufacturing**: Tech unlocks
- **Units ↔ Items**: Equipment system
- **Detection ↔ Missions**: Discovery mechanics
- **AI Director ↔ Alien Activity**: Strategic coordination

---

## Technical Debt and Future Work

### Known Areas for Improvement
- Consolidate duplicate service implementations
- Unify object pool implementations
- Complete interception GUI
- Finish sanity system integration
- Expand mod validation
- Add more procedural generation variety

### Planned Features
- Multi-planet strategy with portal network
- More complex alien AI behaviors
- Expanded base defense missions
- Dynamic mission generation
- Improved mod tools
- Steam Workshop integration

---

## Testing and Quality Assurance

### Test Coverage Areas
- Unit tests for core systems (RNG, pathfinding, LOS)
- Integration tests for services
- Smoke tests for battlescape
- Economic balance testing
- Procedural generation validation

### Debugging Tools
- In-game console with commands
- Visual debugging overlays
- Performance profiler
- Telemetry system
- Logger with multiple levels

---

## Documentation Standards

### Code Documentation
- LDoc comments for public APIs
- GROK comments for AI assistance
- README files in major folders
- Inline comments for complex logic

### Design Documentation
- Game Design Document (GDD) in wiki
- System-specific README files
- Example usage code
- Tutorial missions

---

## Performance Characteristics

### Optimization Strategies
- Object pooling for combat entities
- Spatial indexing for unit queries
- LOS/pathfinding result caching
- Deferred rendering updates
- Batch UI updates

### Bottleneck Areas
- Large tactical maps (>50x50)
- Many simultaneous units (>50)
- Complex pathfinding queries
- Real-time interception rendering

---

## Conclusion

This codebase implements a comprehensive XCOM-inspired strategy game with:
- **Strategic Layer**: Multi-world geoscape with territory control
- **Tactical Layer**: Turn-based combat with AP/energy economy
- **Economic Layer**: Research, manufacturing, and financial management
- **Base Management**: Modular facility construction and operations
- **Personnel**: Unit progression with classes, traits, and transformations
- **Alien Threat**: Dynamic invasion with AI director
- **Interception**: 3x3 grid aerial combat
- **Moddability**: Extensive modding support with hooks and data overrides

The architecture emphasizes:
- Deterministic gameplay with seeded RNG
- Data-driven design with TOML files
- Modular, maintainable code structure
- Performance optimization through caching and pooling
- Clear separation of concerns across layers

This summary provides a reference for understanding the unique mechanics and systems when migrating or reusing this design in other formats or engines.

---

**Total Lines:** 1,800+
**Last Updated:** October 9, 2025
**Document Version:** 1.0
