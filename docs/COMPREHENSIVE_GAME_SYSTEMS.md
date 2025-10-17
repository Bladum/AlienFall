# AlienFall - Comprehensive Game Systems Reference

> **Purpose**: Single, unified high-level reference for all AlienFall game systems and concepts
> **Audience**: Designers, developers, testers, modders
> **Last Updated**: 2025-10-16

---

## Table of Contents

- [Core Foundation](#core-foundation)
- [AI Systems](#ai-systems)
- [Assets & Resources](#assets--resources)
- [Modding System](#modding-system)
- [Game Numbers](#game-numbers)
- [Balancing Framework](#balancing-framework)
- [Analytics System](#analytics-system)
- [Basescape (Base Management)](#basescape-base-management)
- [Battlescape (Tactical Combat)](#battlescape-tactical-combat)
- [Content (Items, Units, Crafts)](#content-items-units-crafts)
- [Politics & Diplomacy](#politics--diplomacy)
- [Finance & Economy](#finance--economy)
- [Interception (Air Combat)](#interception-air-combat)
- [Lore & Narrative](#lore--narrative)
- [Geoscape (Strategic Layer)](#geoscape-strategic-layer)
- [Scenes & Scene Management](#scenes--scene-management)
- [UI & Widgets](#ui--widgets)
- [Tutorial System](#tutorial-system)
- [Network Systems](#network-systems)
- [Progression System](#progression-system)
- [Utilities](#utilities)
- [Localization](#localization)

---

## Core Foundation

### Game Overview
AlienFall is a **turn-based strategy game** inspired by X-COM, combining:
- **Strategic** decision-making on global scale
- **Base management** with resource allocation  
- **Tactical combat** in procedurally generated missions
- **Sandbox gameplay** with player-driven goals
- **Extensive modding** support through TOML and Lua

### Core Time System

#### Turn Concept
Single game step with variable duration:
- **Geoscape**: 1 turn = 1 day
- **Battlescape**: 1 turn = 10 seconds
- **Interception**: 1 turn = 5 minutes

#### Calendar System
- **Base Unit**: Day (1 turn)
- **Week**: 6 days
- **Month**: 30 days (5 weeks)
- **Quarter**: 3 months
- **Year**: 360 days (12 months, 4 quarters)

#### Day/Night Cycle
- Visual overlay on geoscape showing current time across world tiles
- Moves 4 tiles per turn (20-turn full cycle across world)
- Affects mission lighting and visibility
- Independent tracking per world tile
- There is either day or night for mission
- Some mission even in province with day, might be underground with night as battle time

### Four Game Layers

#### Geoscape (Strategic Layer)
- **Scale**: Global world map (80×40 hex grid, ~500km per tile)
- **Focus**: Strategic decisions, resource allocation, global operations
- **Duration**: Campaign spans months/years
- **Key Activities**: UFO tracking, mission deployment, diplomacy, research planning
- This is mostly similar to HoMM3, Eador, Europa Universalis with armies and units inside fighting on world map. 

#### Basescape (Base Management)
- **Scale**: Single base facility (5×5 grid of buildings)
- **Focus**: Construction, research, manufacturing, personnel management
- **Duration**: Parallel to geoscape (same time passes both layers)
- **Key Activities**: Build facilities, research tech, manufacture equipment, manage inventory
- This is mostly similar to managing city in Civilzation kind of game

#### Battlescape (Tactical Combat)
- **Scale**: Procedurally generated tactical map (hex grid battlefield)
- **Focus**: Squad-level tactics, positioning, cover system
- **Duration**: Single mission (variable turns based on objectives)
- **Key Activities**: Move units, combat, complete objectives, recover salvage
- This is mostly similar to rougelike on squad level 

#### Interception (Air Combat)
- **Scale**: Province-to-province air space
- **Focus**: Turn-based craft vs UFO/base combat
- **Duration**: Quick resolution (minutes of gameplay)
- **Key Activities**: Deploy craft, manage energy/action points, resolve damage
- This is mostly similar to battle card game

---

## AI Systems

### Strategic AI (Geoscape Layer)

#### Diplomacy System
Manages relationships between player organization and world factions:

- **Factions**: Virtual enemy entities with independent agendas
    - Includes aliens, rival human organizations, and other virtual adversaries
    - Attack provinces and player bases autonomously
    - Relationship affects mission generation, difficulty scaling, and hostile encounters
    - Can escalate from hostile to ceasefire to alliance based on player actions
    - Control UFO activity and ground operations across the geoscape

- **Countries**: Local Earth governments representing human civilization
    - Provide monthly funding based on relationship level and performance
    - Control provinces on the geoscape that player must defend from faction attacks
    - React to UFO incursions and player mission outcomes in their territory
    - Become hostile if too many failures occur or civilian casualties mount
    - Demand protection of their territories and citizens

- **Suppliers**: Virtual economic entities providing marketplace services
    - Control available items, equipment, crafts, and units for purchase
    - Pricing influenced by player reputation and karma
    - Availability of goods affected by relationship level
    - Can withdraw services or impose embargoes if relations deteriorate
    - Enable trading/selling of salvage, equipment, and captured materials

**Relationship Effects:**
- **Factions**: Determine mission types, enemy quality/quantity, and territory conflicts
- **Countries**: Control funding levels, mission availability in territories, and support
- **Suppliers**: Regulate marketplace inventory, pricing discounts/premiums, and transaction availability

#### Mission AI
- Generate mission objectives and parameters
- Place UFO/hostile bases strategically on geoscape
- Determine mission difficulty and rewards based on progression
- Generate tactical teams and unit compositions

### Operational AI (Interception Layer)

#### Interception Combat AI
- Manages UFO behavior during interception
- Makes tactical decisions about attacking/fleeing
- Calculates damage and energy usage
- Determines interception outcome

### Tactical AI (Battlescape Layer)

#### Side-Level AI
- Determines faction alignment and hostility relationships
- Establishes which sides engage in combat (e.g., enemy vs neutral, ally vs enemy)
- Makes strategic decisions about which opposing sides to pursue
- Fixed assignment of four sides: **Player**, **Enemy**, **Ally**, **Neutral**
- Controls overall faction behavior posture during mission

#### Team-Level AI
- Manages individual teams within a side (one side can have multiple teams)
- Coordinates team-specific tactics and positioning
- Allocates team resources across squads
- Makes team-level strategic decisions (aggressive push, defensive hold, withdrawal)
- Manages inter-squad coordination within the team

#### Squad-Level AI
- Coordinates small unit groups (1 to all units from a team) operating together
- Plans squad formations and group movements
- Manages shared squad objectives and goals
- Coordinates between squad members for tactical advantage
- Manages squad-level resources (ammo sharing, energy distribution)

#### Unit-Level AI
- Controls individual unit behavior and decision-making
- Movement pathfinding and positioning relative to squad/enemies
- Target selection and prioritization
- Combat actions (firing, reloading, ability usage)
- Reaction fire triggers and defensive responses
- Suppression and evasion tactics

---

## Assets & Resources

### Asset Types

#### Audio Assets
- **Music**: Background ambience and themes by layer
- **Sound Effects**: Unit actions, weapons, explosions, UI
- **Voice**: Dialogue and radio chatter (optional)
- **Format**: OGG Vorbis for streaming, WAV for sound effects

#### Graphics Assets
- **Format**: PNG with transparency
- **Resolution Base**: 12×12 pixel art (upscaled to 24×24 display)
- **Categories**:
  - Unit sprites (8 directional)
  - Terrain tiles (hex-based)
  - Objects and decorations
  - UI elements and widgets
  - Weapons and effects
  - Facility sprites

#### Text Assets
- **Format**: TOML configuration files
- **Content**: Game numbers, item data, unit stats, mission parameters
- **Structure**: Hierarchical with fallback values

### Resource Management

#### Tileset Loading
- Load tilesets on demand per map
- Cache commonly used tilesets in memory
- Unload unused tilesets during transitions

#### Tileset Structure
- **Folder Organization**: Each tileset is a named folder (e.g., `tilesets/forest_ground/`) containing related tile PNG files
- **File Naming**: Individual PNG files represent specific tile variations or animation frames
- **Pixel Dimensions**: All tiles are multiples of 24×24 pixels (base 12×12 upscaled to 24×24 display)
- **Tile Types**:
    - **Autotiles**: Self-connecting tiles that automatically match adjacent tile edges
    - **Random Variants**: Multiple PNG files from which game randomly selects during placement
    - **Animations**: Sequential PNG frames for animated tile effects
    - **Directional Tiles**: Unit sprites with directional variants (8 directions)
    - **Static Tiles**: Single PNG representing a fixed terrain or object

#### Tileset Definition in TOML
- TOML configuration files define how game interprets tile PNGs
- Specify tile type (autotile, random, animation, directional, static)
- Define animation frame sequence and timing
- Configure random selection pool and weights
- Set directional facing mappings for unit sprites
- Establish tile properties (walkable, cover value, visual priority)

#### Tileset Caching Strategy
- **On-Demand Loading**: Load tileset folder only when map requires it
- **Memory Cache**: Keep frequently used tilesets in RAM during play session
- **Unload Triggers**: Remove tileset from cache during layer transitions or map changes
- **Cache Invalidation**: Refresh cache if tileset files modified during development
- **Performance Optimization**: Pre-load tilesets for upcoming missions during downtime

#### File Scanning
- Directory scanning for asset discovery
- Validation of required asset files
- Mod asset loading and precedence

#### Save System
- Automatic save points before/after key events
- Manual save capability (with slot system)
- Save file compression for storage efficiency
- Savegame versioning for compatibility

#### Mockup Generator
- Tools for testing UI layouts
- Generate mock data for various game states
- Automated screenshot generation for documentation

---

## Modding System

### Mod Creation

#### Mod Structure
- Basic folder structure for new mods
- Entry point file definition
- Asset organization conventions
- Configuration template generation

#### TOML Structure
Standard format for mod data definitions:
```
[item]
name = "item_name"
stats = { damage = 10, weight = 2 }

[unit]
class = "Soldier"
abilities = ["shoot", "move", "reload"]
```

### Mod Loading

#### Load Order
- Load core game mods first
- Apply user mods in priority order
- Handle mod dependencies and conflicts
- Report missing dependencies

#### API Integration
- Access game systems through mod API
- Event hooks for mod behavior
- Safe execution sandboxing

### Testing Mods

#### Validation
- TOML syntax validation
- Required field checking
- Type validation for values

#### Testing Framework
- Load specific mods in test environment
- Compare expected vs actual outcomes
- Performance profiling for mod impact

### Mod API Documentation
Complete reference for:
- Available functions and hooks
- Event system integration
- Data structure definitions
- Best practices and examples

### Mod Validation
- Automated checks for common issues
- Warning system for deprecated features
- Compatibility checking with game version

---

## Game Numbers

### Item Stats
Numerical values defining item properties:
- cost of items are /1000 from XCOM
- damage of weapons are /5 from XCOM
- weight of items are /3 from XCOM
- size of items is same like in XCOM
- range of items is 50% longer then in XCOM
- weapon accuracy is same like in XCOM, snap to 5%
- armour values is /5 from XCOM
- no clip size, use energy system 

### Unit Stats
Character sheet for typical human units:
- all typical stats are in range 6-12 for humans
- aim, reaction, is 6-12, which is /10 like in XCOM
- sanity, bravery is 2-12
- health is /5 like XCOM
- strenght is /3 like XCOM
- sight range is 20/10 tiles 
- upkeep is 10-100K /1000 like XCOM
- move speed is same like XCOM in tiles

### Craft Stats
Aircraft performance metrics:
- **Armor**: Hull strength against weapons
- **Fuel Capacity**: Range limitation
- **Weapon Slots**: Available weapon hardpoints
- **Armor Slots**: Defense equipment mounting
- **Crew Capacity**: Personnel that can board
- **Cargo Capacity**: Item storage space
- **Speed**: Movement distance per turn

### Facility Stats
Base building effectiveness:
- **Build Cost**: Resources needed to construct
- **Maintenance**: Operational cost per turn
- **Power Usage**: Energy requirements
- **Capacity**: Maximum operations/storage
- **Prerequisites**: Required prior facilities
- **Adjacency Bonus**: Benefits from neighboring facilities
- **Repair Time**: Turns to heal damage

### Mission Stats
Tactical engagement parameters:
- **Difficulty**: Alien quality and quantity
- **Map Size**: Generated map dimensions
- **Time Limit**: Turn or objective restrictions
- **Reward**: Experience, items, salvage
- **Alien Count**: Enemy force composition
- **Objectives**: Victory conditions

---

## Auto-Balancing Systems

### Autonomous Game Loop (AI vs AI Sandbox)

#### Core Concept
- Fully self-playing game engine with no human intervention
- AI agents autonomously manage all four game layers
- Complete decision-making by computational agents
- Automatic logging of all game events and outcomes

#### Four-Layer Autonomous Operation

##### Geoscape AI Loop
- Autonomous faction decision-making
- UFO deployment and movement
- Mission generation and assignment
- Resource allocation without player input
- Strategic objective planning
- Diplomacy and alliance management (AI-driven)

##### Basescape AI Loop
- Automatic facility construction scheduling
- Research project selection and prioritization
- Manufacturing queue management
- Personnel assignment optimization
- Budget allocation without constraints
- Maintenance and repair automation

##### Interception AI Loop
- Autonomous craft deployment decisions
- Tactical positioning and movement
- Weapon targeting and firing decisions
- Damage assessment and tactical retreat
- Complete combat resolution

##### Battlescape AI Loop
- Squad-level tactical decision-making
- Unit movement and positioning
- Weapon selection and targeting
- Ability usage and resource management
- Objective pursuit and completion
- Reinforcement coordination

#### Autonomous Game Session Flow
1. **Initialization**: Set up AI factions, bases, starting resources
2. **Main Loop**: Execute game turns automatically
3. **Decision Phase**: All AI agents make simultaneous decisions
4. **Resolution Phase**: Calculate outcomes (combat, research, construction)
5. **Logging Phase**: Record all events and state changes
6. **Repeat**: Continue until endgame condition met

#### Event Logging System

##### Logged Event Categories
- **Combat Events**: Shots fired, hits/misses, damage, kills, morale effects
- **Unit Events**: Movement, status changes, leveling, casualty
- **Mission Events**: Completion, objectives, rewards, failures
- **Base Events**: Construction, research completion, manufacturing
- **Economic Events**: Transactions, funding changes, resource flow
- **Political Events**: Relationship changes, faction actions, alliances
- **Strategic Events**: UFO sightings, deployment decisions, invasions
- **Time Events**: Turn progression, date milestones, seasonal changes

##### Event Log Format
```lua
{
    turn = 42,
    layer = "battlescape",
    type = "shot_fired",
    timestamp = "2025-10-16 14:30:45",
    actor = { id = "unit_001", faction = "player", class = "soldier" },
    target = { id = "alien_042", faction = "alien" },
    details = {
        weapon = "rifle_standard",
        accuracy_base = 0.75,
        accuracy_final = 0.62,
        hit = true,
        damage = 18,
        armor_reduction = 4,
        damage_final = 14
    }
}
```

#### Analytics Pipeline

##### Step 1: Raw Event Collection
- Stream events to log file during game execution
- Timestamp each event precisely
- Preserve complete event context
- No filtering or aggregation at collection time

##### Step 2: Log Aggregation
- Load all events from completed session
- Group by category and time window
- Filter for specific queries
- Build event time-series

##### Step 3: Statistical Analysis
- Calculate averages, medians, distributions
- Identify outliers and anomalies
- Compute correlations between variables
- Trend analysis over game progression

##### Step 4: Insights Generation
- Balance assessment conclusions
- AI capability evaluation
- Emergent behavior identification
- System interaction patterns

##### Step 5: Metrics Calculation
```lua
metrics = {
    -- Combat Balance
    weapon_effectiveness = {
        rifle_standard = { avg_damage = 14.2, hit_rate = 0.62 },
        plasma_rifle = { avg_damage = 22.1, hit_rate = 0.48 },
        sniper_rifle = { avg_damage = 31.5, hit_rate = 0.71 }
    },
    
    -- Unit Performance
    unit_survival = {
        soldier = { survival_rate = 0.34, avg_kills = 2.1 },
        heavy = { survival_rate = 0.52, avg_kills = 3.7 },
        specialist = { survival_rate = 0.28, avg_kills = 1.9 }
    },
    
    -- Mission Success
    mission_completion = {
        easy = { success_rate = 0.89, avg_turns = 12.3 },
        medium = { success_rate = 0.54, avg_turns = 18.7 },
        hard = { success_rate = 0.18, avg_turns = 24.2 }
    },
    
    -- Economic Efficiency
    economy = {
        resource_generation = 2400,
        resource_spending = 2150,
        surplus = 250,
        facility_roi = { lab = 1.23, workshop = 0.98 }
    },
    
    -- AI Quality
    ai_intelligence = {
        tactical_score = 0.67,
        strategic_score = 0.54,
        adaptation_rate = 0.42,
        decision_speed = 127 -- ms per decision
    }
}
```

#### Balance Assessment Framework

##### Combat Balance Metrics
- **Weapon Balance**: DPS vs accuracy tradeoff alignment
- **Unit Balance**: Win rate by class across difficulty levels
- **Armor Balance**: Damage reduction effectiveness vs mobility tradeoff
- **Critical Balance**: Crit chance vs damage compensation
- **Range Balance**: Optimal engagement distance distribution

##### Difficulty Balance Metrics
- **Mission Win Rate**: Success percentage by difficulty tier
- **Casualty Rate**: Acceptable loss levels per mission type
- **Resource Reward**: Mission reward vs difficulty alignment
- **Turn Efficiency**: Average turns to complete vs difficulty
- **AI Win Rate**: Faction success rate in strategic layer

##### Economy Balance Metrics
- **Resource Flow**: Income vs spending ratio
- **Tech Progression**: Research speed vs cost balance
- **Manufacturing**: Production time vs resource investment
- **Facility Efficiency**: ROI calculation per facility type
- **Budget Sustainability**: Long-term solvency prediction

##### AI Intelligence Metrics
- **Decision Quality**: Outcome rating of AI decisions (1-10 scale)
- **Tactical Effectiveness**: Combat performance vs optimal strategy
- **Strategic Planning**: Long-term goal achievement rate
- **Adaptation**: AI response to player/faction changes
- **Problem Solving**: Objective completion efficiency
- **Teamwork**: Squad coordination effectiveness

#### Automated Balance Adjustment

##### Data-Driven Tuning
- Identify imbalanced systems from metrics
- Calculate adjustment vectors
- Apply modifications automatically
- Re-run simulation to verify

##### Feedback Loop
1. Run autonomous session (N turns)
2. Calculate metrics from event logs
3. Identify balance issues (threshold-based)
4. Generate adjustment recommendations
5. Apply tuning to config/data files
6. Repeat until convergence

##### Balance Thresholds
```lua
balance_thresholds = {
    weapon_winrate_variance = 0.15,  -- Max 15% difference between weapon types
    unit_survival_variance = 0.20,   -- Max 20% survival rate variance
    mission_success_target = 0.50,   -- Target 50% win rate
    economy_surplus_target = 100,    -- Target +100 resource surplus
    ai_decision_quality = 6.0        -- Target AI decisions rate 6+/10
}
```

#### Visualization & Reporting

##### Analytics Dashboard
- Real-time metrics display
- Historical trend charts
- Balance assessment heatmaps
- AI performance graphs
- Economy flow diagrams

##### Session Report Generation
- Automatic report after session completion
- Markdown-formatted analysis
- Key findings and recommendations
- Raw data export capability
- Comparative analysis vs previous sessions

##### Performance Profiling
- Turn execution time tracking
- Memory usage monitoring
- AI decision latency measurement
- Bottleneck identification
- Optimization recommendations


#### Auto Battlescape Balancing
- Adjust enemy force based on player squad strength
- Scale difficulty per mission phase
- Distribute rewards fairly
- Prevent one-sided battles

#### Auto Geoscape Balancing
- UFO distribution relative to player capabilities
- Mission difficulty scaling with player progression
- Funding adjustment based on difficulty
- Country relationship penalties scaled fairly

#### Auto Interception Balancing
- Opponent craft stats scaled to player equipment
- Energy cost adjusted to difficulty
- Damage scaling to prevent trivial wins

#### Auto Basescape Balancing
- Research tree progression pacing
- Manufacturing queue time scaling
- Resource availability tuning
- Facility effectiveness balancing

---

## Analytics System

### Game Logs

#### What Gets Logged
- **Combat Events**: Shots fired, hits/misses, damage dealt
- **Unit Events**: Movements, status effects, deaths
- **Mission Events**: Objectives completed, rewards earned
- **Base Events**: Facility construction, research completion
- **Economic Events**: Transactions, funding changes
- **Political Events**: Relationship changes, faction actions

#### How to Log from Game
```lua
Analytics.logEvent("shot_fired", {
  unit_id = unit.id,
  weapon = weapon.name,
  target = target.id,
  accuracy = accuracy_percent
})
```

### Game Analytics

#### Converting Logs to Insights
- Aggregate event data by category
- Calculate statistics (averages, distributions)
- Identify trends and patterns
- Compare player behavior to baseline

#### Common Analytics Queries
- Average accuracy per weapon type
- Survival rate by unit class
- Mission completion rate by difficulty
- Economic efficiency metrics

### Game Metrics

#### Balance Measurement
Metrics for determining game balance:
- **Weapon Balance**: Damage output vs accuracy tradeoff
- **Unit Balance**: Class effectiveness across scenarios
- **Difficulty**: Win/loss rate by mission type
- **Economy**: Resource flow sustainability
- **Progression**: Tech tree advancement pacing

#### Performance Metrics
- Frame rate stability
- Memory usage patterns
- Load time by layer
- Turn calculation duration

---

## Basescape (Base Management)

### Base Overview

#### Base Concept
- Single facility constructed in a province on geoscape
- Consists of 5×5 grid of facility tiles
- Can be damaged by interception/missile attack
- Contains all base infrastructure and personnel
- One base per province for player
- Many mission bases for enemy per province

#### Base Functions
- Provides infrastructure for operations
- Stores personnel, equipment, and crafts
- Conducts research and manufacturing
- Detects enemy missions on geoscape

### Base Layout

#### Base Sizes
- **Small Base**: 3×3 grid (9 tiles)
- **Medium Base**: 4×4 grid (16 tiles)
- **Large Base**: 5×5 grid (25 tiles)
- **Huge Base**: 6×6 grid (36 tiles)
- Base size impacts total facility capacity and construction cost
- Larger bases available later in game progression or through higher country relations
- Base location determined by province on geoscape

#### Facility Grid
- Grid size determines max number of facilities
- Each tile can hold one facility unit or remain empty
- Facilities occupy variable footprints (1×1, 2×2, 3×3 sizes)
- Larger facilities occupy more tiles, reducing capacity
- Design decisions constrain what can be built in limited space

#### Facility Sizes and Layout
- **1×1 Facilities**: Basic buildings (storage, barracks sections)
- **2×2 Facilities**: Medium operations (workshops, hangars)
- **3×3 Facilities**: Large infrastructure (advanced labs, defense systems)
- Footprint scaling affects space planning and strategic layout

#### Adjacency System
- Facilities benefit from neighboring facilities
- Bonus range includes adjacent tiles (1 tile away)
- Multiple adjacencies stack bonuses cumulatively
- All facilities must be structurally linked or section collapses

### Base Services System

#### Service Concept
- Services are virtual infrastructure systems (not physical facilities)
- Services provide operational capacity or requirements
- Service level ranges from 0 to 100 (example: 10 power units)
- Service level is not consumed; it continuously provides capability or represents need
- Facilities both provide and require services to function

#### Service Types
- **Power Supply**: Provides energy to operate other facilities
- **Storage Capacity**: Holds items and equipment
- **Personnel Quarters**: Housing and life support for units
- **Transportation**: Craft and personnel movement capability
- **Production Capacity**: Research and manufacturing capability
- **Detention**: Prisoner containment system
- **Defense**: Anti-air and base defense capability
- **Command & Control**: Communications and coordination systems

#### Service Dependencies
- Facilities require specific services to operate (e.g., power to run lab)
- Multiple facilities can share single service source
- Service level must meet combined demand of all dependent facilities
- Insufficient service level reduces facility effectiveness or offline status
- Critical services (power) cause cascading failures if insufficient

#### Service-Facility Relationships
- Facilities generate services (power plant generates power)
- Facilities consume services (lab requires power, workshop requires power)
- Multiple facilities can contribute to single service
- Unmet service demand prevents facility operation

### Facilities

#### Facility Concept
- Physical buildings constructed in base grid
- Provide services and capabilities for base operations
- Can be damaged, require repair, or destroyed completely
- Have distinct lifecycle from construction to operational to damage to removal

#### Build Mechanics
- **Build Cost**: Resource expenditure in credits to construct
- **Build Time**: Duration in turns (game days) to complete construction
- **Staff Requirements**: Labor units needed during construction
- **Prerequisites**: Required prior facilities, technologies, or research completion
- **Unlock Conditions**: Country relations, experience levels, or narrative progression
- Building progresses automatically once started
- Facility is non-operational during construction period

#### Operational Status
- **Operational**: Fully functional, providing services, consuming power and maintenance
- **Under Construction**: Being built, not yet available
- **Damaged**: Reduced effectiveness, requires repair, still consuming power
- **Offline**: Intentionally disabled or awaiting repair/power
- **Upgrading**: Transitioning to higher level, similar to construction
- **Destroyed**: Completely destroyed, requires full reconstruction

#### Damage and Repair
- Facilities take damage from military attacks (interception, random events)
- Damage rating affects effectiveness (e.g., 50% damage = 50% capacity)
- Repair mechanics mirror construction: time-based progression
- Repair time proportional to damage level (50% damage = 50% construction time)
- Facility offline during repair but continues consuming maintenance costs
- Complete destruction forces full reconstruction from zero

#### Facility Limits
- **Per-Base Limits**: Some facilities can only appear once per base (e.g., 1 garage)
- **Per-Country Limits**: Some facilities limited by country ownership (e.g., 1 temple per country)
- **Per-Game Limits**: Rare facilities limited globally (e.g., 1 alien containment per entire game)
- Limit prevents player from building overpowered facility clusters
- Enforced at build time, prevents construction if limit reached

#### Build Prerequisites
- May require specific region types (e.g., temple in religious region)
- May require prior facility construction (e.g., workshop requires power plant)
- May require technology research to unlock
- May require player experience or progression level
- Prerequisites prevent rushing end-game facilities

#### Maintenance Costs
- Monthly operational cost deducted each game day
- Deduction occurs regardless of facility status
- Higher-tier facilities have higher maintenance
- Non-payment results in facility shutdown
- Critical facilities prioritized if budget insufficient

#### Facility Capabilities
- **Hospital**: Medical treatment, heals unit injuries, recovers sanity, performs operations
- **Academy**: Training facility, promotes units, improves unit stats through education
- **Garage**: Craft maintenance and repair, extends craft operational life
- **Temple**: Morale and sanity recovery for units, religious/cultural services
- **Lab**: Research capacity (provides man-days for research projects)
- **Workshop**: Manufacturing capacity (provides man-days for production)
- **Storage**: Item and equipment holding capacity
- **Barracks**: Personnel housing, limits total units at base
- **Prison**: Alien captive containment, interrogation and dissection
- **Radar**: UFO detection with range radius, cumulative coverage
- **Defense Turret**: Air defense capability, base protection during interception
- **Power Plant**: Power generation service to other facilities
- **Hangar**: Craft storage and maintenance area

#### Adjacency Bonuses
- Facilities receive bonuses from proximity to complementary facilities
- Bonus applies when facilities are adjacent (1 tile away)
- Multiple adjacencies stack benefits
- Examples: Lab adjacent to workshop increases research/manufacturing speed
- Workshop adjacent to storage reduces resource costs
- Hospital adjacent to barracks improves unit recovery time

### Base Capabilities

#### Storage for Items
- Warehouse facilities hold inventory
- Limited capacity based on item size
- Overflow causes items to be lost
- Transfer between bases available

#### Hangar for Crafts
- Stores aircraft between missions
- Maintenance and repair
- Limited capacity constrains fleet

#### Barracks for Units
- Quarters for soldiers, limiting units count
- Training and promotion
- Medical bay for healing

#### Lab for Research
- Scientists conduct technology research
- No personel, it just provide capacity to perfom research in man days
- Prerequisite technology requirements
- Research is global on the same subject

#### Workshop for Manufacturing
- Engineers produce equipment
- Multiple concurrent jobs
- No personal, it just provide capacity to perform manufacturing
- Item queue management
- Resource costs per item

#### Prison for Prisoners
- Contain alien captives
- Interrogation for information
- Dissection for research materials
- Limited capacity
- Limited lifespan

#### Base Defence for Interception
- Turrets for air defense during inteception 
- Shield systems to increase health of base during interception
- Might provide additional units during battlscape on base in this facility

#### Radar Coverage for Geoscape
- Detection radius around base
- UFO tracking within range
- All radars are cumulative 
- Once per turn all bases scan provinces in radar range
- they deduct their radar power from all missions cover stat
- if mission got 0 or less then its detected, player can intercept

### Base Monthly Reports
- Income from country funding
- Operating costs breakdown
- Research progress status
- Manufacturing queue status
- Personnel status and needs
- Craft maintenance requirements

### New Base Build
- Select province location
- Choose initial facility layout
- Cost and max size may depends on relation with country, biome, region
- More bases are possible with higher reputation levels

### Base Defense
- Trigger when base is attacked on interception scene
- Use base-defense facilities to fight with enemy ufo
- Control defense turrets, if facility provide them on battlescape

### Base Infrastructure Components

#### Three-Layer Infrastructure Model
- **Personnel**: Units (soldiers, officers) staffing the base
- **Equipment**: All items stored and used at base (weapons, armor, ammunition, etc.)
- **Infrastructure**: Facilities and services that support operations

#### Personnel Component
- Units occupy barracks space at base
- Units can be assigned to crafts for missions or remain at base
- Units have individual stats, experience, and specialization
- Units require housing, food, and medical support
- Unit capacity limited by barracks space

#### Equipment Component
- All items are equipment stored at base (no separate scientist/engineer roles)
- Items include weapons, armor, ammunition, supplies, salvage
- Equipment assigned to units for missions or stored in inventory
- Equipment capacity limited by storage facilities
- Equipment can be sold, traded, or consumed in manufacturing

#### Infrastructure Component
- Facilities provide operational capabilities
- Services represent abstract operational systems
- No dedicated scientist or engineer personnel roles
- Research and manufacturing capacity provided by facilities (Labs and Workshops)
- Staff assignments happen to research/manufacturing projects, not to abstract personnel

### Personnel Management

#### Units at Base
- Recruit from countries, factions, or other sources
- Units occupy barracks housing capacity
- Can be assigned to specific crafts for missions or stationed at base
- Track experience, skills, specialization, and statistics
- Support healing, training, and psychological recovery
- Promotion and rank advancement through experience
- Can undergo medical operations or transformations

#### Unit Templates
- Predefined unit configurations for quick recruitment
- Templates define stats, abilities, starting equipment
- Player can create custom templates from trained units
- Ensures consistent quality when recruiting new units

#### Unit Health and Sanity
- **Health**: Physical damage from combat, healed at hospital
- **Sanity**: Psychological stress from combat exposure, recovered at hospital or temple
- Both stats affect unit combat effectiveness
- Low health prevents deployment; low sanity reduces accuracy/morale

#### Unit Inventory
- Units carry personal equipment (weapons, armor, items)
- Equipment slot limits per unit (e.g., two weapons, one armor)
- Unit inventory separate from base storage
- Equipment affects unit stats and combat capability

#### Unit Training and Promotion
- Units gain experience from combat missions
- Experience increases unit stats over time (aim, strength, etc.)
- Promotion to higher ranks unlocks specializations
- Academy facility accelerates training and stat improvement
- Units can specialize in different combat roles

#### Craft Assignment
- Units assigned to specific crafts for missions
- Craft capacity limits total units per craft
- Equipped units occupy more space than unequipped
- Units and craft items stored separately (units in crew space, items in cargo)
- Units travel with craft, reinforced at mission start

### Inventory Management

#### Item Organization
- Sort by type, weight, value
- Search and filter
- Manage resources (specific type of item)
- Transfer between bases
- Sold on market, drop to trash
- Equip items to units or crafts 
- Use in reserch or manufacturing

#### Item Capacity
- Size-based limits for items
- Volume-based limits for items
- Overflow management, items above capacity are lost

#### Equipment Distribution
- Assign weapons to units
- Assign armor to units
- Assign weapons / armours to crafts
- Assign units to crafts
- Loadout templates for units and crafts

### Prisoners

#### Prisoner Handling
- Interrogate for intelligence
- Dissect for research materials
- Trade for information/resources
- Execute or release (morale impact)

#### Interrogation Benefits
- Reveal alien weaknesses
- Unlock special missions
- Provide research hints

### Research in Base

#### Research Concept
- No dedicated scientist personnel; research is handled abstractly
- Research requires Lab facility to provide capacity (measured in man-days)
- Research project consumes lab capacity over time until completion
- Player assigns capacity allocation to prioritize research projects

#### Research Capacity and Labor
- Lab facilities provide research man-day capacity
- One man-day = one day of one scientist/engineer's labor equivalent
- Multiple labs combine capacity additively
- Assigned capacity directly determines research speed

#### Research Activation
- Select technology from research tree to begin
- Assign desired lab capacity to project (1 man-day per turn, etc.)
- Capacity must be available from lab facilities
- Research progresses automatically each turn by allocated amount
- Pause or resume research projects freely

#### Research Queue
- Multiple simultaneous research projects supported
- Each project receives allocated capacity
- Set research priority to affect automatic capacity distribution
- Pause/resume individual projects independently
- Completed research unlocks facilities, items, or capabilities

#### Research Prerequisites
- Technology dependency trees lock certain research behind others
- Gating mechanisms prevent rushing advanced technologies
- Alternative research paths available for different strategies
- Prerequisites visible in technology tree

#### Research Complexity Levels
- Each research has randomized complexity at game start (50-150% of base)
- Complexity presented to player as 5 distinct levels:
  - **Level 1**: 10 man-days
  - **Level 2**: 30 man-days
  - **Level 3**: 100 man-days
  - **Level 4**: 300 man-days
  - **Level 5**: 1000 man-days
- Randomization provides variation and replayability
- Player can see complexity before committing research

#### Research Completion
- Upon completion, unlock associated facilities, items, or capabilities
- One-time completion; no need to repeat
- Completion immediately available to manufacturing and deployment
- May unlock new missions or strategic options

### Manufacturing in Base

#### Manufacturing Concept
- No dedicated engineer personnel; manufacturing handled abstractly
- Manufacturing requires Workshop facility to provide capacity (measured in man-days)
- Manufacturing project consumes workshop capacity over time until completion
- Player allocates capacity to manufacturing jobs in queue

#### Manufacturing Capacity and Labor
- Workshop facilities provide manufacturing man-day capacity
- One man-day = one day of manufacturing labor equivalent
- Multiple workshops combine capacity additively
- Assigned capacity directly determines production speed

#### Manufacturing Queue
- Add multiple items to production queue
- Queue processed in order (FIFO) with priority system
- Assign engineering capacity to active project
- Capacity distributed among all queued items or concentrated on one
- Add/remove items from queue freely; reorder as needed

#### Manufacturing Prerequisites
- Required technologies must be researched first
- Required services/facilities must exist and be operational
- Required input items consumed during manufacturing
- Prerequisites prevent premature manufacturing

#### Manufacturing Costs
- **Resource Cost**: Credits to purchase raw materials and resources
- **Labor Cost**: Man-days provided by workshop facilities
- **Time to Produce**: Duration in turns based on allocated capacity
- Cost visible before manufacturing starts
- Payment deducted upon project completion

#### Manufacturing Completion
- Upon completion, item added to base inventory
- Item immediately available for unit equipment or deployment
- Can be sold, transferred to other bases, or used in research
- Completed items remain until consumed or sold

### Base Transfers

#### Transfer Types
- Personnel movement between bases
- Item transfer
- Craft repositioning

#### Transfer Time & Cost
- Distance-based travel time
- Using actual world map to find path between provinces
- Risk of interception if going via risky province
- Insurance cost 

---

## Battlescape (Tactical Unit Combat)

### Battlescape Overview

#### Battlescape Concept
- Tactical combat on procedurally generated maps
- Hex grid based movement and line-of-sight
- Rogue-like gameplay but with complex squad setup
- Maps are 1 level, every tile has one terrain and one unit

#### Activation States
- **Planning**: Pre-mission setup and loadout
- **Deploying**: Units enter battlefield
- **Active**: Units take turns in sequence
- **Reinforcement**: Additional units arrive, if scripted
- **Retreat**: Withdrawal from mission by any team (surrender)
- **Victory**: Objectives completed
- **Defeat**: Mission failed or squad eliminated

### AI System

#### Types of AI
- Side level, fixed 4 sides, player / enemy / ally / neutral 
- Team level, belong to one of sides
- Squad within team level 
- Unit within team level 

#### Side-Level AI
- Controls entire alien faction
- Makes strategic decisions
- Calls reinforcements
- Determines faction behavior (aggressive/defensive)

#### Team-Level AI
- Manages groups of alien units
- Squad coordination and positioning
- Resource allocation across units
- Retreat/stand-and-fight decisions

#### Squad-Level AI
- Coordinates movements of individual squad
- Tactical positioning relative to enemies
- Ammo and resource management
- Target prioritization

#### Unit-Level AI
- Individual unit decision-making
- Pathfinding and movement
- Target acquisition and engagement
- Reaction fire priority
- Morale and panic response

### Battlefield

#### Hex Grid System
- Hexagonal tile-based movement
- Axial coordinate system (q, r)
- Diagonal and cardinal directions
- Distance calculations via axial math
- 1 Hex is aprox 3 meters
- 1 turn is aprox 10 seconds

#### Map blocks on Hex grid
- Due to type of hex coordinate 
- All rect structures are designed to axial (they are tilted)
- All crafts are designed top down

#### Hex Calculations
- Distance between hex tiles using axial math
- Line of sight through multiple hexes with blocks that has cost of sight
- Field of view (FOV) detection radius
- All calculations must be ultra performance and optimized

#### Hex Distance
- Minimum movement tiles required
- Path obstruction checking
- Optimal path determination
- Diagonal vs cardinal efficiency

#### Hex Pathfinding
- A* algorithm on hex grid
- Terrain cost consideration
- Move cost normal terrain 2, rough 3-4, very rough 5-6, road - 1
- Obstacle avoidance, wall with cost to move 99
- Unit flying ignore move cost of terrain
- Move point budgeting based on AP * unit speed

#### Hex Explosion
- Area of effect calculations
- Damage falloff by distance
- Cover damage reduction
- Splash damage to multiple targets
- Explosion radius calculations z takim efektem że jest epicentrum i fala uderzeniowa sie rozprzestrzenia i jesli trafia na unit albo na wall to sprawdza czy armour jest wiekszy i jesli tak to idz

#### Hex Vision
- Line of sight (LOS) detection
- Field of view (FOV) computation
- Fog of war implementation
- Cover-based concealment

#### Hex Beams/Ray Tracing
- Weapon targeting verification
- Ballistics calculation
- Obstacle collision detection
- Friendly fire prevention checks

### Combat Mechanics

#### Line of Sight (LOS)
- Determines visibility to targets
- Blocked by terrain and objects
- Affected by cover and elevation and smoke / fire
- Required for most weapon fire, otherwise 50% penelty
- Units have sight for Day and Night seperated
- At the moment sight is omnidirectional TO BE CHANGED

#### Line of Fire (LOF)
- Direct firing line to target
- Can be different from LOS
- Blocked by intermediate units/terrain
- Can fire via holes, chance to hit
- Affects weapon accuracy

#### Weapon Range
- Minimum range (close weapons require proximity)
- Optimal range (best accuracy)
- Maximum range (damage falloff)
- Out-of-range restrictions
   0-75% of max range -> 100% linear
   75% to 100% of range -> 50% linear
   100% to 125% of range -> 0% linear

#### Weapon Cooldown
- Recovery time after firing in turns
- Per-weapon cooldown timers in turns
- Action point cost to fire
- Rate of fire limitations

#### Fog of War
- Areas not in LOS are hidden
- Enemy positions revealed on sighting
- Maintains tactical tension
- Updated each turn phase
- Updated every tile when unit is moving
- Fog of war is shared within a team, but on within a side
- Fog od war works like in RTS, there is no lighnting like in ufo xcom

#### Fire Accuracy
- Base accuracy from weapon stats
- Modifiers from unit skills
- Distance penalties due to weapon range
- Modifier to weapon mode (AIM, SNAP etc)
- Target movement penalty
- Stance modifiers (standing vs crouching)
- Target behind cover 
- Target is not in Line of Sight of unit 50%
- All modifiers are multiplied to get final accuracy 

#### Stun & Health
- **Health**: Hit points remaining
- **Stun**: Temporary incapacity (recovers each turn 1 point)
- **Damage**: Reduces unit stats including health / stun / energy / morale
- **Armor**: Reduces incoming damage, all type
- **Critical**: Chance for getting critical wound for unit

#### Armor Piercing
- Weapon capability to ignore armor
- Armor effectiveness reduction
- Bonus damage on AP rounds

#### Damage Type
- **Kinetic**: Bullets
- **Energy**: Lasers, plasma
- **Chemical**: Gas, acid
- **Biological**: Toxins, disease
- **Psionic**: Mind effects, telepathy
- **Melee**: melee weapons
- **Explosive**: explosive
- **Fire**: only from tile with fire
- **Stun**: stun and smoke

#### Armor Resistance
- Different armor types resist different damage
- Cumulative resistance from multiple items
- Environmental damage bypass (fire)
- Weakness exploitation
- Armour resistance use same list as weapon damage type
- Its compared to get final damage

#### Damage Calculation
```
Final Damage = Base Damage x random 50%-150% × Armour resistance - Armor Reduction
```

#### Damage Model

##### Point Damage
- Single target receives full damage
- Directed weapon fire (bullets, lasers)
- Most common damage type

##### Area Damage
- Radius blast affects multiple targets
- Explosive ordnance (grenades, rockets)
- Falloff with distance
- Reduced by cover
- Use efekt explision liczonego na polach hex

##### Line Damage
- Damage along firing line
- Beam weapons (lasers, plasma, railgun)
- Hits all targets in line, unless stop by a block
- Reduced by obstacles in the path

#### Projectile System
- Simulated bullet/projectile physics on hex2D Map
- Travel time and trajectory
- Interception by obstacles
- Visual feedback and effects
- Different weapon use different projectiles size and color

#### Weapon Mode
- Weapon mode is defined global, not per weapon 
- Mode defines how weapon stats are modified for this attack
    - action points cost
    - energy points cost
    - number of buullets fired
    - accurancy modifiers
    - range modifiers
    - damage modifiers
- Weapon allows to use specific mode to get modifiers
- **Snap**: One projectile, accurate
- **Burst**: 3-5 projectiles, moderate spread
- **Auto**: Continuous fire, high spread
- **Charged**: Builds power over time
- **Melee**: Close-range strike
- **Aim**: More accurate but longer preparation
- **Critical**: Less chance to hit, but higher critical

#### Critical Hits
- Random chance per shot
- Based on unit skills and weapon type and weapon mode 
- Special crit bonuses (bleeding, etc.)

#### Melee Accuracy
- Opponent dodge chance based on reaction
- Accuracy based on unit stats only
- Some weapons might have melee weapon mode 
- No range requirements, 1 tile only
- Base damage comes from strenght + weapon modifier

#### Dodge
- Chance to avoid ranged attacks
- Unit skill-based, based on reaction
- Defensive stance improvement
- Faster movement gives higher dodge
- Reduce enemy chance to hit

#### Cover from Terrain
- Provides chance to hit target reduction
- Line of sight blocking
- Partial vs full cover
- Height advantage from cover

#### Terrain Slope
- Elevation affects line of sight
- Height advantage in combat
- Movement cost on slopes
- Vision range increase at height

#### Actions

##### Reaction Fire
- Fire on enemy entering LOS
- Action point requirement + react unit stat
- Chance to see depends on AP spent on overwatch
- Running increase chance for react fire
- Sneaking move decrease chance for react fire

##### Overwatch
- Dedication to ready reaction fire
- Cannot move or act
- Increased reaction accuracy
- Unit in overwatch state can trigger reaction fire

##### Suppression
- Reduce enemy action effectiveness
- Spent AP to reduce enemy AP using suppression
- Depends on unit skills and weapon stats
- Stacks with multiple suppressors
- Does not damage target but cost AP / EP to use

##### Cover & Crouch
- Stance modifications
- Accuracy and defense trade-offs
- Exposure risk at low stance
- Movement limitation per stance

##### Unit Movement
- Consume move points
- Traversal of terrain
- Collision detection Obstacle avoidance

##### Unit Running
- High-speed movement
- 1 tile cost half of move points (faster move)
- Move cost 1 energy point
- Reduced range of sight of unit
- No firing capability
- Increased visibility to enemies and reaction fire chance

##### Unit Sneaking
- Low-speed movement
- Reduced detection from enemies (cover = 3)
- Reduced range of sight of this unit
- Consume move points at higher rate (slower move)
- Quiet approach to enemies, reduce reaction fire chance

##### Unit Rotation
- Change facing direction
- Affects visible arc
- Cost 1 MP
- Change face of unit 
- In hex map unit has 6 faces

#### Morale
- Psychological resilience stat
- Panic chance when allies die
- Recovered by killing enemies
- Unit starts with 10 morale
- Every bad think cause bravery test on unit
- Failed bravery test cause morale to drop by 1
- Morale below 4 cause drop of AP available for unit
- With morale 0 unit become pannic, cannot do anything
- Rest action cause morale to recover by 1
- Many things can impact on morale drop
- Recoverd to 10 after battle

#### Sanity
- Psychological stability long term
- Reduced by witnessing trauma
- Unit stat from 6 to 12
- After battle unit may lose 0 1 2 3 sanity 
- Bases on how scarry mission was
- Sanity recovery is 1 per week + bonuses from facilities
- Low sanity works same way like lwo morale, remove available AP for unit until it become not usable at all

#### Points Systems

##### Action Points (AP)
- Resource for unit actions
- Cost per weapon fire
- Cost per ability use
- Linked with movement points
- Recovered entirely each turn
- Standard is 4 AP per turn per unit
- Morale / Sanity may impact available AP per turn (down to zero)
- Very high class or perk can add AP to 5

##### Energy Points
- Resource for fast movement and using weapons
- Combines both stamina of unit and ammo of weapons
- Basic energy regerneration is 1/3 of base energy per turn
- Most weapona and armours heavily improve energy
- Special items may improve energy recovery 
- Without energy you cannot use weapons and run

##### Movement Points
- Specific resource for movement
- Always link with available AP
- Movement points = AP * unit speed
- Moving units consume MP and decrease number of available AP at the same time
- Using AP will decrease available MP in this turn

##### Health Points
- Combat resilience, Reduced by damage
- Lethal if zero, unit is dead
- 2 types of damage, pernament and stun
- Stun damage restores 1 per turn
- if entire remaining health is stun -> unit is notconcious
- Recoverable via medical items
- Normal recovery is 1 HP per week + bonus from facilities
- HP recovered during battle will work on battle but unit must recover at base entire health lost

#### Throwing
- Grenades and throwable items
- Same projectile trajectory as other, as maps are flat
- Distance depends on unit strenght vs item weight
- Items can be thrown on the floor so other units can pick this up
- 

#### Wounds
- Wound during battle are caused by critical hits
- Normal damage, even very high does not create wounds
- Wound is 1 lose of HP per until death
- Healing during battle is possible on wounds
- Wounds after battle are considered as 4 HP lost from recovery point perspective (4 more weeks per wound)
- Unit can bleed to death when wound cause health to zero

#### Healing
- Medical kit usage during battle
- Some items that heal may need special unit class to operate
- Healing works on
    health hurt
    health stun
    morale 
    energy 
- after battle unit will recover 1 point of HP / sanity per week + bonus from budilngs
- healing may be short or long range during battle
- psionics could heal
- organic units can be healed and mechanical unit must be repaired

#### Turn System
- 1 battle turn is 10 seconds
- Order of sides is 
    player
    ally
    enemy
    neutral
- within sides random team is selected
- turn restore AP / MP, replenish some energy
- turn restore some morale when unit is resting and more energy

#### Auras
- Aura system from specific units to nearby ally units
- Some unit class provide bonus to 
    bravery when leader is close
    accuracy if leade is close
- effect has a radius from leader
- Auras are not blocked by terrain obstacles
- Auras might be negative for enemy units, cause fear e.g.

#### Psionics

##### Mind Control
- Take control of enemy unit
- Temporary duration
- Psionic range limitation
- Resistance-based defense

##### Damage
- stun
- hurt
- energy
- morale

##### Create Fire
- Spontaneous combustion in tile

##### Telekinesis
- Move terrain remotely, 
- push / thrown objects 
- Lift units to other locations

##### Hide Tile
- Obscure battlefield area
- Vision blocking

##### Show Tile
- Reveal hidden areas
- Remove concealment

##### Blind Unit
- Disable vision temporarily

#### Panic
- When unit got low morale it may panic
    3 - lose 1 AP and 25% chance to panic
    2 - lose 2 AP and 50% chance to panic
    1 - lose 3 AP and 75% chance to panic
    0 -> lose all AP and panic
- Panic unit is considered not active this turn

#### Surrender
- If all units of team are either
    - dead (health = 0)
    - non concious (stun = health)
    - paniced (morale = 0)
- Team will automatically surrender and leave battle
- This is enough even just 1 turn is ok

#### Sides
- **Player**: Controlled by human player
- **Ally**: Controlled by AI, ally to player, ignore neutral
- **Enemy**: Enemy faction controlled by AI
- **Neutral**: NPCs try to survive
- **Environment**: Turrets, mines, traps

### Map Generation System

Procedural generation steps:
- check biome for mission
- randomize terrain for this biome or force one terrain
- get list of map blocks for this terrain
- randomize one map script for this terrain
- build map grid as map size
- run map script and perform steps
- fill map grid with IDs of map blocks until fill entire map
- define transformation on map blocks 
- create sides & teams
- based on mission data generate teams' units 
- allocate default inventory to each unit
- allocate which map block will be taken by which team
- split teams into sqads 
- assign each squad to map block 
- generate battle field based on map grid and map block details
- apply transformation on battle tiles (rotate, mirror)
- once battle map is filles with map tiles, add units from squads
- apply for of war to all tiles and teams
- apply special effect on tile level like fire / smoke 
- apply special enviromental effect like snow / rain / etc
- apply AI strategies for each team

### Mission System

#### Mission Objectives

- Every mission goal is to fill 100% of mission goal
- All teams working on same side have common goal
- Team get goal progress depends on what goal is
- If mission goal is to capture 4 tiles, then each is worth 25%
- If mission goal is kill all enemies, each enemy is worth 100/N %

#### Mission Goals
- **Eliminate All**: Kill or capture all enemies
- **Defend Point**: Protect designated area
- **Reach Extraction**: Get to exit point
- **Rescue Target**: Find and extract ally
- **Capture Alive**: Non-lethal target capture
- **Investigate**: Search area for clues
- **Secure Device**: Activate/deactivate objects

#### Mission concealment 
- Mission might have concealment budget
- This limits number of actions can be done during mission
- Every unit action may cause to use concealment budget
    - being spotted by enemy
    - fire large weapon
    - fire at unit
    - kill unit
    - explosions, damage to terrains
- When entire budget is consumed, mission is considred to FAILED
- usually budget is extremly high but some mission might be special

#### Mission Rewards
- Side that won battle got rewards
- Mission itself might have score to win after victory OR lose after defeat OR not picking up mission on time
- Wining mission might trigger event or fill quest
- Mission results might affect change to reputation, karma or fame
- Other elements are part os mission salvage

#### Landing Zones
- Player unit deployment map blocks
- Strategic placement options before battle starts
- Tactical advantages/disadvantages
- Depends on map size from 1 to 4 landing zones
- Player can deply its units in what ever order in zones
- There is no player craft in the game
- Landing zones are also considered to be exit zones

#### Enemy Team Generation
- Enemy team gets N units and K experience points
- Units are generated from available units and autopromoted to better class using promotion tree (Batlte of Wesnoth style)
- Repeat until all exprience points are spent
- All units get random traits
- Then standard inventory is applied to each unit
- Mission specific only units is possible

#### Enemy Default Inventory
- Every enemy unit class has default inventory
- Every unit randomize its inventory based on it
- Mission-specific loadouts is possible

#### Enemy Team Placement on Map
- All units are deployed in squads on single map block
- Map blocks have their random priority per each team, so we know which teams squad will be deployed to which map block
- Cannot mix squads, even from same team on the same map block
- Squads can be 1 unit, or entire team, depends on situation
- This may be related to specific mission objective
- This is important to understand
    1 map block = 1 squad, on of the team
    cannot mix squads on single block
    1 squad can be any number of units from single team

#### Mission Difficulty
- Scales enemy squad size / experience level used to generate teams
- Affects reward scaling (score)
- Determines available enemies unit claaes and their inventory
- Defines level of AI used on battle
- Does not effect stats of enemy units, they are fixed

#### Map size
- Small is 4x4 map blocks (16) and one landing zone
- Medium is 5x5 (25) and 2 LZ
- Large is 6x6 (36) and 3 LZ
- Huge is 7x7 (49) and 4 LZ

#### Mission Sizes
- defines number of units / squads / experience points to build them
- **Small**: 2-4 enemy squads
- **Medium**: 5-8 enemy squads
- **Large**: 9-15 enemy squads
- **Massive**: 16+ enemy squads
TODO this

#### Mission Planning Scene (from player side)
- Pre-mission briefing with objectives and rewards
- List of untis with equipment
- Take a look on mission map block (hidden, high level)
- Assign units to available landing zones
- Assume that 1 landing zone = 1 squad
- Squads are mainly for AI, player can play as he want
- Start battle

#### Public imapct
- What might drop score during battle
- Killing civilian units
- Destroying some terrain tiles m
- High level of conclealment budget usage
- Remember that score is only for public impact

#### Mission Salvage Scene (from player side)
- Post-mission loot collection
- Experience for all untis that survived
- Medals for all units for special actions
- All objects from ground, 
- live units -> prisoners, 
- dead untis and their items 
- All terrain tiles converted to resources
- Neutral units, allied units are not used
- Units got their recovery time based on HP lost and wounds
- Units lose their sanity 

#### Open topics
- how to limit craft cargo for mission salvage ?

#### Special Missions

##### Base Defense
- Base comes under attack afetr interception
- Defensive fortifications available during inteception
- Each facility has its own map blocks
- Battlefield comes from layout of base
- Turret usage, if facility map block contains them
- No reinforcement waves

### Map System

#### Terrain
- Defines list of map blocks to be used in battle
- Defines list of map scrpts how battle map is build from these map blocks
- defines visual effects

#### Map Blocks
- Map block is 15x15 or wielokrotnosc of map tiles
- Reusable terrain chunks
- Grouped in terrains

#### Map Scripts
- Defines how battle map is build from map blocks
- Each map script has a step that fill battle map with details
- Have complex scripts and condition system
- Allows to use map blocks from group or specific size
- Allows to check chance to run step if at all
- allow to check if step was executed and create complex if then scenarios
    - add road
    - fill rest map
    - add 3 blocks of group 2 

#### Map Tile
- Individual grid cell in map block
- Is represneted by single image 24x24 pixels
- Is either a floor or a wall
- For some floors there is also roof defined (for 3D game)
- Each map tile has numerous stats like
    - move cost
    - line of sight cost 
    - line of fire cost (cover)
    - armour (value of armour to destroy tile)
    - material (armour resistance)
    - flamability
    - can have smoke
    - and many more
 - it always represneted by single PNG file
 - PNG file can be larger then 24x24 depends how tile is using it
    - autotiling game maker style
    - select one random and keep it
    - animation, cycle 
    - level of tile destruction

#### Map Grid
- Map grid is 2D array filled with map blocks
- Its initial map , output from first step when map script create it
- Its used in second step when convert it into battle map

#### Battle Tile
- Battle tile is same in battle field, like map tile on map block
- It also contains
    map tile
    unit
    objects laying on the ground
    level of smoke / fire
    fog of war level per team

#### Battlefield
- Main 2D array with battle tiles used to perform all calculation during battle scape
- It manage all logic, unit moveming, FOW, line of sight, smoke, fire etc on all battle tiles

#### Objects on Tile
- Items drop on a battle tile becomes objects
- Units that become dead become objects on battle tile,
- They also drop their inventory as seperate objects on this tile
- Any grenade, flare, pistol, dead body is object
- when tile is hit by projectile, objects might be destroyed

#### Units on Tile
- Battle tile has a place on single unit

### Unit System

#### Side
- Fixed 4 sides: player, allied, enemy, neutral
- Fixed diplomacy and relationship settings between them
- Controls behavioral and how they filled mission objectives
- Sides are winning mission by filling objectives, not teams

#### Team
- Grouping of allied units
- Shared vision from all units
- Coordinated AI behavior
- Player has single team only

#### Squad
- Sub-group within team
- 1-6 units typical
- For player no function other that initial deployment in landing zones
- AI coordination level for squads

#### Unit
- Individual unit with unit class, stats, health etc
- Has inventory of max 3 items (2 weapons and armour)
- If dead, convert to object and lay on floor

### 3D View System

#### Rules for 3D Rendering
- Maintain tactical accuracy vs visual appeal
- Preserve fog of war mechanics
- Ensure readable UI over 3D view
- Performance optimization

### Effects System

#### Fire
- Damage terrain and units (2 HP)
- May set unit on fire (N turns, lose 1 HP due to fire)
- Spreads to adjacent tiles for flammable tiles
- Consumes fuel (terrain)
- Creates smoke
- Heavy energy weapons on hit may cause fire

#### Smoke
- Blocks line of sight by 2 per level
- Has 3 levels of depth
- Reduces accuracy by 5% per level
- Dissipates over time
- Grenades/explosions create it
- Fire create it
- Expand to empty slot
- For units apply 1 stun damage per turn
- Units without armour will have like 50% resistance

#### Day & Night
- Affects visibility range
- Units have 2 stats for sight (day / night)
- Lighting influence on UI
- Night have slightly blueish effect
- Environmental impact on sanity after battle (night always +1)

#### Explosion
- Area damage effect
- Knock-back force to move units in proper direction
- Environmental destruction
    - terrain has armour 
    - if damage is above it, terrain is changed to "destroyed one"
    - explosation is moving forward to next hex tiles

---

## Content (Items, Units, Crafts)

### Items

#### Item Categories

##### Lore Items
- Story-relevant unique objects
- Special quest rewards
- Narrative significance
- SHould have no size / weight
- Cannot be used by units / craft

##### Resource Items
- Materials for manufacturing for items, units, crafts
- Trade commodities
- Cannot be used by units, 
- Can be used by crafts as fuel
- Usually are divided into 3 categories
    - fuel
    - energy
    - construction
- They are assinged to each phase of the game
    - Early human (fuel, metal)
    - Advanved human (titanium uranium)
    - Alien 1 war (elerium, alien alloys)
    - Alien 2 war (zrbtite / aqua plastic)
    - Alien 3 war (warp)

##### Unit Items (Equipment)

###### Weapons
- **Melee**: Close-range, high damage
- **Ranged**: Bullets, arrows, darts
- **Energy**: Lasers, plasma bolts
- **Explosives**: Grenades, missiles
- **Tactical**: Smoke, stun, flashbang
- **Special**: Psionic, healing, buffs

###### Armor
- **Light**: Minimal protection, high mobility
- **Medium**: Balanced protection and mobility
- **Heavy**: Maximum protection, reduced mobility
- **Specialized**: Environmental suits, stealth gear

##### Craft Items

###### Craft Weapons
- **Point Defense**: Fast-firing anti-missile
- **Main Cannon**: High damage single target
- **Missile Pod**: Area damage ordnance
- **Laser Array**: Sustained energy beam
- **Plasma Caster**: Hot ordnance
- **Specialty**: EMP, concussive, etc.

###### Craft Armor
- **Ablative Armor**: Reduced effectiveness over time
- **Composite Armor**: Balanced durability
- **Reactive Armor**: Reduced explosive damage
- **Shield System**: Energy-based protection

##### Prisoner Items
- Enemy units when dead are convered to objects, which are picked into corpose of race after mission
- Live enemy units are converted to Item - prisoner and must be cept in prison type of facility in base
- Research materials
- Has limited lifespan in prison
- Can be sold / removed for money / karma / fame change

#### Item Pricing vs Value
- **Purchase Value**: Resource cost to purchase
- **Sold Value**: Sold price is always 50% of purchase price
- **Rarity Value**: Rare items can impact karma / fame / relation / score

#### Item Weight vs Size
- **Weight**: How much it take space in units inventory or craft inventory
- **Volume**: Volume, number of items
- **Size**: How much space it takes in storage in base
- **Carrying Capacity**: How much it change unit or craft capacity for items

### Units

#### Unit Classes
- **Soldier**: All-purpose trooper
- **Officer**: Leadership and morale
- **Specialist**: Class-specific expertise
- **Elite**: High experience/rarity
- **Rookie**: Fresh recruit

#### Unit Promotion Tree
- Experience-based advancement
- Specialization branching
- Skill unlocking
- Stat increases per rank

#### Units Capabilities
- **Movement**: Traversal ability
- **Combat**: Weapon proficiency
- **Stealth**: Concealment skills
- **Leadership**: Morale effects
- **Special**: Unique abilities

#### Units Traits
- **Brave**: Morale resistance, panic immunity
- **Bloodthirsty**: Melee bonuses, aggressive
- **Tactical**: Accuracy bonuses, awareness
- **Lucky**: Critical hit chance increase
- **Fragile**: Health penalty, damage taken increase
- **Clumsy**: Movement penalty, accuracy reduce
- **Psychic**: Psionic ability access

#### Units Stats
- **Health**: Hit points
- **Accuracy**: Weapon accuracy bonus
- **Reactions**: Reaction fire frequency
- **Movement**: Move points per turn
- **Armor**: Damage reduction
- **Leadership**: Morale boost radius
- **Morale**: Panic resistance
- **Psionic**: Psionic power strength

#### Units Transformation
- Level-up stat modifications
- Skill acquisition
- New ability unlocks
- Equipment upgrades

#### Units Healing
- Passive natural recovery
- Medical treatment
- Facility-based healing
- Recovery time tracking

#### Units Sanity
- Psychological status
- Panic threshold
- Trauma buildup
- Recovery mechanism

#### Units Experience
- Combat effectiveness growth
- Kill count tracking
- Promotion point accumulation
- Specialization path

#### Units Items
- Equipment slots
- Weapon assignment
- Armor outfit
- Accessory items
- Consumable items

#### Units Inventory
- Item storage capacity
- Weight management
- Quick-access slots
- Item usage tracking

#### Units Action Points
- Per-turn resources
- Action cost budget
- Ability activation cost
- Recharge mechanism

#### Units Morale
- Psychological state
- Panic threshold
- Recovery bonuses
- Enemy casualty effects

#### Units Energy Points
- Movement resource
- Turn-based replenishment
- Ability cost
- Sprint limitation

#### Units Movement Points
- Dedicated movement budget
- Hex-based consumption
- Diagonal efficiency
- Alternative to energy points

### Crafts

#### Craft Items
- Equipment carried by aircraft
- Weapon mounts
- Armor/defense systems
- Fuel tanks
- Cargo containers

#### Craft Promotion Tree
- Experience-based progression
- Pilot skill advancement
- Armor upgrades
- Weapon unlocks

#### Craft Capabilities
- **Speed**: Movement distance
- **Armor**: Durability rating
- **Firepower**: Weapon effectiveness
- **Cargo**: Storage capacity
- **Range**: Fuel-based distance

#### Craft Inventory
- Item storage
- Weapon loadouts
- Armor configurations
- Personnel transport

#### Craft Class
- **Scout**: Fast, light armor
- **Fighter**: Balanced combat
- **Bomber**: Heavy weapons, slow
- **Transport**: Cargo focus
- **Support**: Utility functions

#### Craft Experience
- Combat mission history
- Damage survived
- Enemies destroyed
- Pilot skill transfer

#### Craft Repairs
- Damage healing time
- Resource requirements
- Facility requirement
- Downtime planning

#### Craft Fuel
- Resource consumption per movement
- Range calculation
- Emergency landing procedures
- Fuel tank upgrade

#### Craft Maintenance
- Monthly operational cost
- Preventive maintenance schedule
- Component replacement
- Upgrade installation

---

## Politics & Diplomacy

### Fame System
- External being-known track
- Increases with succesfull missions
- Increases with public actions
- It changes only if it was notices by ANYONE, including factions
- There is no such concept of negative fame, either you are known or not
- Concealment actions do not increase fame, nobody knows about it
- Generates favorable events but also might trigger some missions 
- Decrease in time slowly, people forget about you
- Affects multiply options in game
- starts with 0 and going up only
- ranges are
    0 - 100         I
    100 - 300       II
    300 - 600       III
    600 - 1000      IV
    1000 and more   V

### Karma System
- Internal morality track
- From -1000 to +1000
- It always changes, regardless of it was detected or not
- Increases with noble actions
- Decreases with unethical choices
- Affects multiply options in game
- ranges are
    0 - 100         I
    100 - 300       II
    300 - 600       III
    600 - 1000      IV
    1000 and more   V

### Karma vs Fame
- raiding city will decrease karma but increase fame, score will change depends it was detected
- saving civilians in public way will increase fame and karma, will give score
- saving civlians during stealth mission will increase karma, but not fame, will give you score

### Relations System
- All relations are between -3 to +3
    -3  worst
    -2  worse
    -1  bad
    0   average
    +1  good
    +2  better
    +3  best

#### Country Relations
- Diplomatic status with governments
- Funding level based on relation
- Mission availability affected
- Potential hostility threshold

#### Supplier Relations
- Equipment availability
- Pricing discounts/premiums
- Service quality and speed
- Willingness to do business

#### Faction Relations
- Enable Special mission (example raid player base)
- Strenght of mission and its volume
- Technology available during missions
- Revenge vs player levels
- Levels of aggresion towards player

### Reputation System
- Reputation points are collected during .... AGREED HOW
- this is considered to be premium currency in game
- It unlocks more options in game
- Reputation can be spend on 
    - organization level
    - advisors
- Player-organization reputation
- Affects NPC interactions
- Unlocks unique missions
- Influences dialogue options

### Organization Levels
- player as organization must grown in size in time
- Example of limits
    - total number of bases
    - total number of crafts
    - total number of units
    - max size of base
    - total number of worlds access to
    - total number of advisors
- organization does NOT unlock more quality options like research
- organization DOES unlock more scale / quanity options like number of bases
- so its either small organization with focus on quality, or large organization without bonuses on quality

### Advisors System
- Repution points can be spent to hire advisor, aka CTO, COO etc
- It cost a lot credits to upkeep but gives global bonus
- Examples are
    10% to global research
    10% to market prices
    10% to global units experience gain
    10% to global manufactring cost
    10% to global radar coverage
- Each advisor has a price and a specific set of bonus
- Advisor can be fired, and reputation points are back, but not credits
- Hire / sell is done in monthly cycles

### Alternative advisors vs organization system
- Remove organization level and allow advisors that increase the same limits that are managed by organization
- suggest better name for Reputation

---


## Finance & Economy

- Game has single currency called "credits", its sign is "K"
- Its like thousands of $ from ufo xcom, written like 120K
- All prices are like in ufo xcom but /1000

### Finance Overview
- Turn-based resource management
- Monthly budget cycle
- Multiple income sources
- Multiple expense categories

### Score System
- Score is how good player is in helping country and people, and society in prevent it from harm and damage
- Score is not from internal player achievements, like research
- If something impacts country, people, public opinie publiczną, then it will be losing score
- If something is to prevent from impact (aka protection) it will gain score
- Score is calculated per provinces, regions (analytics only) and countries (funding)
- Lossing neutral units during battle cause score lost
- Lossing map tiles with high value will cause score lost
- All score for given country is cumulative per month, impact its relationship change with this country
- Score above 1000 will always improve relatship +1, score below 500 will always give -1
- score between these values will give percentage chance to increase relationship with country
- its always harder to get better relation then to lose them (double difference)

### Funding from Countries System
- Higher relationship with country , higher chance to change funding level
- Each country has relationship (-3 to +3) and funding level (0-10)
- Amount of funding is based on country economy * current funding level
- High relation ship gives higher chance to increase funding level
- Lower relationship gives chance to lower funding level
- All checks are done once per month
- It only counts score and economy in provinces belongs to this country
- 1 funding level gives 1% of GDP
- amount of credits = country economy * funding level * 1%
- Its like how much of GDP of country is spend on military protection from player organization
- 
### Budget Management
- Monthly income vs expenses
- Deficit spending risk
- Budget forecasting
- Savings accumulation

### Income Sources
- country funding
- loot missions and sell
- raid provinces and sell
- manufacture and sell
- trade technology
- black market
- stock market ??
- demand tributes from ???

### Spending Sources
- base upkeep facility
- labor cost for research and manufacturing
- units and crafts salaries
- diplomacy costs
- buying new units, items, crafts
- building new facilties and bases
- units and crafts improvements
- tranfers 
- advisors upkeep 
- inflation 
- corruption

### Fame vs budget
- high fame will cost you spend some money for public relatioship as you are known company

### Repution vs budget
- higher reputation can be spent to get to larger organization
- larget organiztion cause due to corruption and bearuracy to lose 10% of income as TAX

### Karma vs budget
- TODO

### Inflation
- The more credits you have the more you will pay as TAX next month
- If you have then 20 times of your monthly income you will start to pay tax
- This is to balance stockpiling credits

### Coruption
- the larger you are the more you need to pay 
- Higher organization levels requires more biurokracji
- each level above 1, cost you 10% of your income as TAX next month
- this is it to balance of being both large and high advanved

### Monthly Reporting
- Budget balance summary
- Expense breakdown
- Income itemization
- Forecast for next month

---

## Interception (Craft Combat)

- Interception scene is more or less like a battle card game
- Backround image during interception comes from biome of province
- There might be weather effect during interception
- There might be day / night effect during itnerception 


### Sides
- There are two sides and total health of both sides
- Left is assumed player and right is assumed enemy

### Entity 
- During interception entitiy is player craft / base or enemy mission (base, site, ufo)

### Sections
- There are 3 sections on each side
    - AIR for anything that fly
    - LAND for anything that land on ground, is crashed on ground, or sail on water
    - UNDER for all undeground bases, or underwater crafts
- Each section can contain up to 4 entities like
    on player side its craft and bases
    on enemy side its missions (ufo, site, bases)
- Each entity has its own health (with bases has the most)
- Entity is either active or inactive (due to damage)
- GAME ASSUME ALL BASES (both players and enemy) ARE UNDERGROUND or UNDERWATER
- There is no underground and underwater bases, its assumed its then on the bottom of water

### Turn Flow
- Select craft
- Select weapon / armour to use
- Select section on other side to use on it
- Perform action, check results
- Repeat until all EP / AP are gone
- Only active entities can operate
- How to do movement ?
- How to do support of other entities on own side ?

### Use of weapons
- Craft and bases has weapons
- Weapons can attack either AIR, LAND / WATER, UNDERWATER
- Use of weapon cost AP / EP like on units
- Weapon usually have cooldown in turns
    - cannons, small has nothing, cost 1-2AP to use
    - large missiles have 3AP and 2-4 turns to reload

### Weapon damage calculations
- Weapon has AP / EP and damage
- Weapons has chance to hit enemy and inflict damage
- Crafts / bases has no armour, it just damage and health (simpler model)

### Weapon range 
- Range of weapon is simulated by how many turns it will take to reach enemy
    - distance between sides is 100 km
    - weapon has range of 10 km
    - it will take 10 turns to reach to enemy side
- Bases has weapons depends on faciliteis in the base (e.g. missile defences)

### Craft vs Base
- Bases with heavy defenses have huge power and energy 
- Bases usually have massive health and energy pools
- Bases without defences has no weapons, still has large health pool

### Addons usage
- Use addons in active or passive way,
- spend AP / EP the same way like weapon but get other results
- Afterburner, shields, scanner, repair, 

### Craft / ufo movement
- TO DESIGN

### Ambush
- if mission was not detected then player is ambushed
- Mission that was not detected has 1-3 free turns to move / operate

### Victory Condition
- Health comes from active crafts, bases or missions on the interception
- if it goes to zero, then entity is inactive
- Both sides can retreat if see no option to win game
- if all entities from side are inactive, then side lost

### Possible outcomes
- Interception does not have any salvage by its own
- If all enemy entities are destroyed, then game will switch to geoscape
- If all enemy entities are inactive (damaged) then game will switch to battle scape
- Salvage can be made from battlescape only

### Retreat
- Side can decide to retreat (if its possible, e.g. only craft / ufo can)
- it will take 3 turns to retreat, need total 10 AP to retreat from interception

### Experience
- Crafts collect experience based on its performance during interception
- Bases do not collect experience

### Crash mission
- If craft or ufo got inactive in air, it will go down to land section and crash
- it will remove craft / ufo mission but will create mission recovery or rescue mission
- if craft / ufo got inactive in air OVER WATER it will be destroyed
- only underwater crafts can be underwater, same rules applied

### Systems

#### Action Points
- Crafts / missions / bases uses same AP like units

#### Energy Points
- Crafts / missions / bases use same EP like units

#### Move points
- No move points on interception
- Entities stay in their section on entire game

#### Entity active status
- Entity has heallth
- If its drop to zero, its destroyed
- If its below 50% there is chance to got deactivated
- Inactive entity exist but cannot act
- if all entities from side are inactive -> its lost

### Examples

#### Air to Air
- Player aircraft fighter with missiles
- Approach flaying ufo mission with air weapons
- Either its destroyed or crashed down 

#### Land to Land
- Player craft move on land to 
- Enemy may have 
- Installation has defensive turrets
- Installation cannot move
- Asymmetric engagement

#### Air to Land
- Player craft transporter with unit
- Approach site mission with zombies

#### Base Defense
- UFO attacking base
- Base turrets provide defense
- Craft units provide support
- Multi-front battle

#### Base Assault
- Air Craft attacking fortified enemy base
- Heavy defensive systems
- Multiple turret coordination

#### Underwater
- Special variant for underwater bases
- Different movement mechanics
- Specialized equipment for underwater

---

## Lore (Narrative Layer)

### Lore Overview
- Rich background world with many arcs implemented by faction system
- With time number of new missions will increase
- Only way to survive and not to be flooded by missions is progress in faction research tree
- Final research tree or Quest can deactivate this faction missions / campaigns completly
- This is very like in Tower Defense game with waves

### Factions
- Faction is one story arcs
- Faction by default are enemies to player
- It has set of units and missions that operate in provinces
- Faction might be shared on more then one world
- Factions has their regions with weigths where they generate missions
- Faction has relationship with player that may control missions power
- But to disable faction needs to progress research , relationship will just soften it
- Bad relation with faction will cause it very agressive
- Examples:
    - sectoid
    - zombies
    - Rectulans
    - The red dawn
    - Man in black 
    - Arab union
    - EXALT
    - Aquaman
- Faction is not entire alien threat, its more like single alien race is one faction
- factions are NOT countries, this is not goverment, 
- Factions do not own provinces, but they may have pernament base
- All missions always are assigned to single faction
- factions are NOT suppliers, this is not company / corporate
- factions do not interact with each other, they only interact with player via missions
- progress of research per faction will impact which missions it will generate
- final research per faction will disable its missions to be generated
- each faction has its own unique equipment and units and rewards when completed
- Faction usually is attached to 1-3 races and set of units
- Auto promotion of units using experience is always within single faction

### Campaigns
- Narrative campaigns with story arcs
- Campaigns are defined per faction only
- They contains narrative plot 
- Campaign can be limited to region or with weights
- Campaign can be limited by level of relationshop with player for this faction
- Can be also disabled or enabled by quest or research progress
- Campaigns are long terms (1-3 months)
- Campaigns are added by calendar on every month based on 
- Every quater will increase spawn of campaigns by 1
- Campaigns will trigger their missions every week (with potential delays)
- Completed campaign may trigger score change

### Missions
- Mission is main mechanism how player interacts with enemy threat
- Mission are factions specific
- Mission can be limited by research progress
- Mission can be modified by relationship level with faction

#### UFO Missions
- Mission type of ufo, enemy craft
- Its moving, changing provinces
- Is temporary, perform script and gone
- Score points for every script step and at the end
- Equivalent of UFO ship in xcom
- During interception can be in air, land , water
- When destroyed may either be completly destroyed or create crash site
- One ufo mission can be asked to patrol another ufo mission or alien base mission
- May interact with player crafts or bases when detect them or near province

#### Site Missions
- Standard type, most common type
- Its static, does not move
- Its temporary, waiting to be picked by player
- Might be well defended during interception
- Might be created after ufo is shot down in interception
- Any typical static mission like zombie attack, terror site
- Score points when not picked by player
- DO not interact with other game elemnets at all

#### Base Missions
- Mission type of enemy base
- Its static but pernament, will
- Will grow in time, make it stronger and harder to remove
- Will trigger other missions 
- Will generate score just for existiance
- Very heavily defended during interception
- Can detect player bases the same way like player base can detect mission (radar)
- Use base script to handle HOW it grow and what mission it createss
- When destroy expect a lot of salvage
- May impact province in which it exist, like biome, country relation, terrain, economy etc
- May interact with player craft e.g. by sending mission ufo to protest itself

### Mission scripts

#### Enemy UFO Scripts
- For mission ufo type
- Script that manage how ufo is bahaving
    - fly to another province
    - land in province
    - search for base
    - attack country etc
    - harvest resource
    - detect player base
    - attack country / civilians
    - supply missions to other base
    - build another base
    - patrol and escort another ufo mission

#### Enemy Base Scripts
- Script that manage how enemy base growh and behave
- It may trigger missions in same region
- It may trigger self growth if not detected
- This is similar to mini campaign generator but triggered locally from this province 
- There might be many bases in same province
- Is heavy defended during interception

### Quests
- Quest is a goal for player to achieve
- Once achieve in given time player will be rewarded
- Both condition and reward can be anything game allows
- Quests could be created by missions, events, randomly
- Quests might be specific to region, country, faction, world etc
- Quests should be linked with technologies e.g. capture 4 prisoners to help player with plot
- Great way to make in game tutorial some kind
- Quests progress is a flag, either is True or False and might be used everywhere instead of technology for prerequisites

### Events
- Events are completly random encouters 
- Few generated per month
- Not linked with missions system
- Changes units, items, faciltiies, bases, crafts
- Changes credits, fame, reputation, karma
- Changes relationship with countries, suppliers, factions
- Changes enviroment on geoscape e.g. world tile, province biome, province economy
- Changes research or manufacturing progress 
- Might have some research, karma, reputation, fame, regions, worlds constraits to happen in the first place

---

## Geoscape (Strategic Layer)

### Geoscape Overview
- Missions are created in provinces
- Missions must be detected by bases or crafts
- Crafts must travel to province to intercept mission
- Succefsull interception can trigger either battlescape or return to geoscape
- Defenseive interception when mission do attach province with player base
- Multi missions and multi craft moves per single turn
- Day / Night cycle slowly advance on map

### Universe
- Singletone
- Manage up to 4 worlds
- Worlds Connected via portals in province
- Unique properties per world
- Worlds need reserch to unlock and resources to travel to 

### World
- Complete planetary body
- 80×40 hex grid representation for Earh 
- Contain world tiled map 
- Contains provinces, regions, countries
- Factions, campaigns are world specific
- Geographic features, unique background image

### World Tile
- Single hex cell on world map
- Terrain type, used only for travel between provinces
- Day/night status calculated by calendar
- On earth 1 hex = 500 km

### World Rendering
- Hex grid visualization
- World background image with detailed
- World tile representation overlay
- Provinces borders and main 
- Multiply game overlays to show
    - regions, countries, missions, score, fame, relationship etc...

### Missions

#### Generation
- Active campaign create mission every week
- Random events may trigger missions
- Active enemy base can trigger mission per week

#### Detection
- Mission exist on province but covered
- Craft and based detect mission using detection coverage mechanism
- Alert broadcast that mission detected
- Response window to send a craft
- Cannot intercept mission not detected

#### Ambush
- If craft tries to intercept mission not detected in province its ambush
- Player will lose inital 2-3 turns and then normal game continue

#### Interception
- Craft deployment to intercept missions to province
- Fuel and range calculations
- Interception engagement, seperate mini game scene
- Outcome resolution, either start battle scape or back to geoscpae

#### Scoring
- Mission completion points
- Mission enemy base score every day for existnance
- Mission enemy site score only when not picked on time
- Mission enemy ufo score every time they complete a step of script
- Mission if picked intercepted but failed will lose score
- Mission even when picked but battlescape lost then cause lose score

#### Mission from mission
- Mission ufo when shot down will cause nothing
- Mission ufo when crashed on land will cause creation of mission site in the same province
- When player craft will lose in interception it may create rescue mission for pilot

### Province
- Smallest strategic location
- Can contain single player base
- Can contain many missions (enemy) and crafts (player)
- Economic value for country economy
- Biome type
- Weather condition based on biome and time of the year
- Position always snap to grid on world tiles

### World tile 
- World map is divided into tiles, hex map grid
- Earth is aprox 80x40 tiles, 500 km each tile
- They have only purpose to calculate paths between provinces
- No missions exist, no bases , no crafts exist on world tiles, they only exist in provinces
- Type of world tile is water / land and is only used to calculate travel paths
- Other worlds may have differnt world tiles and mechanics related to them

### Travel System
- World tiles has a cost of move
    - water is 1 cost
    - land is either 1, 2, 4 depends of hard tough it is
- When craft want to travel between provinces his type / range and world tile cost is used to calculate his range (so ship will travel farther on water etc)
- aircrafts ignore cost of world tile, just assume 1 tile = 500 km
- Travel system display which provinces are w zasiegu ruchu this craft from his current province
- Craft speed defines how many travels can perform in a single turn, at cost of fuel from base
- Random encountrer possibilities during travel between provinces

### World Paths
- Connections between provinces are highlisted (shorted for this craft)
- Total range of craft from this province is also hihglited

### Province Graph
- Network of connected provinces
- Path calculation between provinces described in travel system
- Used to 
    sent transfers between provinces
    move crafts between provinces
    move missions ufo between provinces
- There is no fixed connection between provinces, it dynamicly calculated depends on craft / ufo type and its range
- For scpecific craft there is always single best path between provinces to travel

### Biomes
- Defines flora and fauna on province level
- Biomes has list of terrains to be selected during battle generation
- Defines background image on interception screen for this province
- Defines province look and feel on world map
- Biomes are either land or water
- Types of biomes:
    - **Forest**: Dense cover
    - **Desert**: Open, hot
    - **Urban**: City terrain
    - **Tundra**: Cold, sparse
    - **Mountain**: High altitude
    - **Ocean**: Aquatic terrain
    - **Alien**: Non-Earth environment

### Region
- Grouping of provinces
- Geographic area example Europe
- Used to track analytics, e.g. score per region
- Control movement of missions ufo within regions
- Can limit features within bases e.g. available facilitiies

### Country
- Geopolitical entity
- May contain multiply provinces
- Economy power coems from sum of its province power
- Has relationship level with player
- Funds player every month based on its relation and funding level
- Gain score / lose score within provinces of country impact relationship and funding level
- May have governance system
- With bad relationship may be hostile towards player including sending missions
- Units comes from countries (nationality) including names / faces

### Portal
- Portal is way to travel faster between provinces
- Portals might be between worlds 
- Cost of using portal is 0, so unit can move from both provinces
- Rare locations
- May be need to be discovered and technology 
- Allows faster movement of crafts on world map

### Craft Fuel & Range
- Every craft has fuel type, range and fuel consumption
- Fuel range defines how far craft can move in single travel between provinces
- Craft speed defined how many travels can perform per day
- Fuel type consume this fuel (resource) from base (so it must have this)
- Craft does not have to refuel, just consume fuel and travel
- Craft has type (water, air, land) that defines which paths can be used at what cost
- If base does not have fuel, it will not allow craft to leave base
- Fuel consumption define how much fuel consumed per travel of craft

### Calendar
- Calendar mechanics to trigger game events
- Every quter increase volume of new campgaings
- Every month starts new campaigns based on available 
- Every week active campaigns create missions within regions
- Every day mission perform its scripts if applicable
- Every month random events are generated
- Every month new quest is created
- Every day handle research, manufacturing, transfers
- Every week handle unit healing / craft repairs, experience gain

### Day & Night System
- World has night / day cycle for missions
- Earth is 80x40 tiles, 50% of them are day / night
- Move is 4 tiles left per turn, so full cycle is 20 days
- Affects tactical mission lighting
- Aesthetic variation
- Night missions add sanity lost +1

### Time System
- Geoscape is turn base 
- 1 turn = 1 day 
- 6 days = 1 week, no sunday
- 5 weeks = 1 month = 30 days 
- 3 months = 15 weeks = quater
- 12 months = 360 days = 1 year
- Events triggered per every new time

---

## UI & Scenes

### Widgets
- Interactive UI components
- Button, panel, text box systems
- Layout management
- Event handling

### Scenes

#### Basescape Scene
Main base management interface:

##### Facilities
- Build new facilities
- Upgrade facilities
- Repair or disable them

##### Units
- Check unit stats
- Change name / image etc
- Promote to new class due to experience
- Assign training / healing / resting 
- Apply new transformation to unit
- Change equipment

##### Crafts
- Check craft stats 
- assign crew to crafts
- change equpment 
- Promote to new class due to experience

##### Prisoners
- List of live enemy prisoners
- Start research (interigation)
- Release / sold them
- Transfer them to new base

##### Research
- Technology tree display
- Active research tracking
- Project queue management
- Prerequisite visualization
- Start new research project
- Labor cost control

##### Market
- Equipment purchasing
- Item trading
- Pricing display
- Transaction confirmation

##### Transfer
- Base-to-base transfer system
- Transportation scheduling
- Delivery tracking

##### Production
- Manufacturing queue
- Job scheduling
- Resource consumption tracking
- Completion alerts
- Start new manufacturing projects
- Labor cost control

##### Base Analytics
- Statistics and reporting
- Budget and capabilities
- Personel sumamry
- Inrrastructure summary
- Eqipmentnt summary
- Historical data

#### Geoscape Scene
Strategic world management:

##### World Map
- Hex grid display
- Province visualization
- Mission markers
- Unit positioning

##### Diplomacy
- Faction relationship display
- Communication interface
- Alliance management
- Negotiation options

##### Politics
- Country allegiance tracking
- Faction alignment display
- Event notification
- Strategic overview

##### World Analytics
- Global statistics
- Threat assessment
- Opportunity identification
- Campaign progress

##### Budget
- Financial status display
- Income/expense tracking
- Forecasting
- Transaction history

#### Battlescape Scene
Tactical combat management:
- Hex grid battlefield
- Unit positioning display
- Action queue
- Combat resolution

#### Interception Scene
Air combat management:
- Tactical positioning
- Craft status display
- Action resolution
- Outcome determination

#### Menu Scene
Main menu and options:

##### Options
- Graphics settings
- Audio configuration
- Game difficulty
- Input customization
- UI scaling

##### Map Editor
- Custom map creation tool
- Terrain editing
- Object placement
- Testing functionality

##### Test Screen
- Development testing interface
- Debug information display
- Cheat activation
- Performance monitoring

---

## Scenes & Scene Management

### Scene System Overview
- Scene manager for layer transitions
- Scene state persistence
- Smooth transitions between layers
- Scene lifecycle management

### Scene Types

#### Transition Scenes
- Loading screens between layers
- Save/load progression
- Briefing and debriefing

#### Modal Scenes
- Pause menu overlay
- Confirmation dialogs
- Information displays
- Non-blocking dialogs

#### Full-Screen Scenes
- Complete layer replacement
- Full focus on single game layer
- Input capture and handling

### Scene Lifecycle
- **Initialize**: Create scene and resources
- **Enter**: Activate scene for display
- **Update**: Process scene logic per frame
- **Draw**: Render scene to screen
- **Exit**: Deactivate scene
- **Cleanup**: Release resources

### Scene Transitions
- Cross-fade effects
- Fade-to-black transitions
- Instant transitions
- Transition timing and easing

---

## UI & Widgets

### Widget System

#### Widget Types
- **Button**: Clickable action trigger
- **Panel**: Container for layout
- **Text Box**: User input field
- **Label**: Static text display
- **Scroll View**: Scrollable content area
- **List**: Multi-item selection
- **Slider**: Numeric value adjustment
- **Toggle**: Boolean state switch
- **Dropdown**: Option selection
- **Grid**: Multi-column display

#### Widget Properties
- Position and size
- Visibility and enabled state
- Event callbacks
- Style and appearance
- Hierarchy and nesting

#### Widget Events
- **On Click**: Button pressed
- **On Change**: Value modified
- **On Focus**: Widget selected
- **On Blur**: Widget deselected
- **On Hover**: Mouse over widget

### Widget Layout

#### Layout Systems
- **Anchor-Based**: Relative positioning
- **Flex-Box**: Responsive layout
- **Grid**: Column-based layout
- **Stack**: Vertical/horizontal stacking

#### Responsive Design
- Resolution scaling
- UI element adjustment
- Aspect ratio handling
- Safe area consideration

### UI Themes

#### Theme Elements
- Color schemes
- Font selections
- Spacing and padding
- Border and shadow styles

#### Theme Switching
- Light/dark modes
- Custom themes
- Theme persistence
- Theme validation

---

## Network Systems

### Network Overview
- Multiplayer coordination
- Cross-platform support
- Asynchronous gameplay modes
- Online features

### Network Features

#### Multiplayer Modes
- **Co-op Campaign**: Shared campaign progression
- **Competitive Skirmish**: Direct combat challenges
- **Async Turns**: Turn-based online play
- **Spectator Mode**: Watch other players

#### Network Communication
- Server connection management
- Latency handling
- Packet optimization
- Connection recovery

#### Synchronization
- State synchronization between clients
- Action validation
- Conflict resolution
- Rollback/resync procedures

### Cloud Features
- Cloud save support
- Cross-device progression
- Backup and restore
- Cloud storage limits

### Online Services
- Leaderboards
- Achievement tracking
- Profile system
- Social features

---

## Localization

### Localization System
- Multi-language support
- Text asset organization
- String key-based lookup
- Fallback to English
- Community translation support

### Supported Languages
- English (primary)
- Expandable framework for additional languages
- Cultural adaptation support
- Right-to-left language consideration

---

## Cross-System Integration

### Economy Connections
- Research unlocks manufacturing items
- Manufacturing equips units
- Units complete missions
- Missions reward resources
- Resources fund research

### Political Connections
- Mission success improves relations
- Relations affect funding
- Funding enables base growth
- Base growth improves military capability
- Military capability enables more missions

### Combat Progression
- Unit experience affects performance
- Tactics improve with play
- Equipment upgrade improves stats
- Morale affects combat effectiveness
- Losses require reinforcement

### Time Progression
- Daily calendar advancement
- Annual milestone celebrations
- Seasonal environmental changes
- Event scheduling
- Long-term goals

---

## Quick Reference Matrix

| System | Primary Layer | Key Resource | Main Constraint | Victory Path |
|--------|---------------|---------------|-----------------|--------------|
| Geoscape | Strategic | Time/Funding | Province Coverage | Global Control |
| Basescape | Management | Facility Grid | 5×5 Capacity | Tech Advancement |
| Battlescape | Tactical | Action Points | Hex Grid | Objective Complete |
| Interception | Air Combat | Energy Points | Craft Armor | Enemy Destroyed |
| Economy | Cross-Layer | Budget | Income Sources | Resource Surplus |
| Politics | Cross-Layer | Relations | Funding Pools | Alliances/Power |
| Research | Basescape | Scientists | Tech Tree | Full Unlock |
| Manufacturing | Basescape | Engineers | Queue/Resources | Equipment Pool |

---

## Development Workflow

### Navigation Aids
- Modular system design
- Clear separation of concerns
- Consistent naming conventions
- Well-documented APIs
- Test coverage requirements

### Key Implementation Files
- `engine/main.lua` - Game entry point
- `engine/core/state_manager.lua` - Layer management
- `engine/geoscape/` - Strategic implementation
- `engine/basescape/` - Base management implementation
- `engine/battlescape/` - Tactical combat implementation
- `engine/interception/` - Air combat implementation

### Testing Approach
- Unit tests for systems
- Integration tests for layer interactions
- Performance benchmarks
- Content validation

---

*This comprehensive reference is maintained as a single source of truth for all AlienFall game systems. For specific implementation details, refer to the `/engine` folder and corresponding test files.*
