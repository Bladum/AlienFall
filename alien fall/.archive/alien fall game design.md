# Alien Fall Game Design

## Overview
Alien Fall is a comprehensive turn-based strategy game inspired by XCOM, featuring geoscape strategic management, interception combat, and battlescape tactical combat. The game integrates multiple interconnected systems including resource management, research trees, diplomacy, and moddable content generation. Players command an anti-alien organization across multiple timescales, from strategic months to tactical seconds, managing bases, units, crafts, and global operations against alien threats.

## Mechanics
- **Turn Systems**: Multiple time scales (Geo: 1 day, Interception: 60 seconds, Battle: 10 seconds)
- **Resource Management**: Action Points (AP), Energy Pools, Movement Points (MP) across all systems
- **Progression**: Research trees, organization levels, unit/craft promotion, facility construction
- **Economy**: Manufacturing, research, marketplace with suppliers and transfer systems
- **Diplomacy**: Relationships with countries, suppliers, factions affecting funding and availability
- **Combat**: Turn-based battlescape, interception dogfights, base defense/assault scenarios
- **Content Generation**: Procedural missions, campaigns, factions, items, and maps
- **Modding**: Extensive Lua scripting and TOML configuration support

## Examples
| System | Components | Integration |
|--------|------------|-------------|
| Core Systems | AP (4 budget), Energy (6-120 pool), MP (speed × AP) | Linked across battlescape, interception, geoscape |
| Units | 18 classes, 6 stats (Health, Energy, Strength, Will, Psionics, Bravery, React, Aim, Speed, Sight, Sense, Cover, Armour), promotion tree | Energy/AP costs, inventory limits, transformation |
| Crafts | 10 classes, stats (Speed, Health, Fuel, Range), 2 weapon + 1 addon slots | Interception combat, fuel consumption, promotion |
| Economy | Manufacturing projects, research trees, marketplace suppliers | Base capacities, transfer orders, monthly budgets |
| Missions | UFO/Site/Base types, concealment system, salvage mechanics | Geoscape detection, interception transitions, battlescape combat |

## References
- XCOM series: Core inspiration for turn-based combat, base management, research trees
- Civilization: Strategic resource management, diplomacy, technology progression
- Battle systems with fog-of-war, cover mechanics, and unit positioning
- Procedural generation for missions and content creation
- Extensive modding communities supporting data-driven design
- missions that supposed to detected from start might have cover = 0

### Battlefield Sight and Sense system
- battle field units have sight / sense / cover system
- sight is ability to see tiles in direction of face of unit (90 deg angle, N tiles), impacted by night / day cycle
- sense is ability to see tiles omnidirectional but usually small amount, 2-3 tiles, not impacted by night / day cycle
- cover is ability of unit to reduce enemy sight / sense ability, either naturally or via items / armor

## Mod Loading (Basic)

### Mod Loader
- System for loading and managing mods to extend game content and functionality.
- Supports data-driven design with TOML files for content definition and Lua scripting for complex behaviors.
- Provides dependency resolution, conflict detection, and hot reload support for development.

### Mod Validator
- Validation system to ensure mods are compatible and do not break game functionality.
- Checks mod structure, dependencies, and content integrity before loading.
- Provides feedback and error reporting for mod developers and users.

## GUI Widgets

### Basic Widgets Buttons
- Fundamental interactive UI components like buttons, text inputs, and list boxes.
- Snaps to 20×20 logical grid units for consistent alignment and pixel-perfect rendering.
- Supports keyboard, mouse, and controller input with accessibility features.
- Provides deterministic feedback consistent with game simulation.
- Supports input abstraction for cross-platform compatibility.

### Complex Multiwidgets Scenes
- Advanced composite widgets combining multiple basic widgets for complex interfaces.
- Includes panels, tabs, scroll containers, and specialized game widgets like minimaps and action bars.
- Enables modular UI construction and mod-extensible widget registration.
- Supports theme integration and mod extensibility.

## Game API

### List of All API Used in Game for Mods in Single Place
- Comprehensive API reference providing all functions and hooks available for modding.
- Organized sandboxed Lua API with documentation for safe and powerful scripting.
- Enables mods to extend, modify, or create new game mechanics and content.
- Supports sandboxed scripting for safety.

## Save/Load

### Save System
- Persistent storage system for game state, progress, and user data.
- Supports saving and loading campaigns, bases, units, and strategic progress.
- Uses deterministic serialization for reproducible saves and replay validation.
- Enables campaign continuity and replay validation.

## Graphics

### Tileset Loader
- System for loading and managing tile-based graphics assets.
- Supports pixel art scaling and animation for consistent visual style.
- Handles terrain, unit, and UI graphics with efficient rendering.

### Animations
- Animation system for dynamic visual effects and character movements.
- Provides frame-based animations with timing controls and state management.
- Integrates with turn-based mechanics for synchronized visual feedback.

### Shaders
- Graphics effects system using shaders for visual enhancements.
- Supports lighting, fog, and special effects for atmospheric rendering.
- Optimizes performance while maintaining pixel art aesthetic.

## Audio

### Sound System
- Audio management for sound effects, music, and ambient audio.
- Provides spatial audio, volume controls, and resource management.
- Enhances immersion with contextual audio cues for game events.

## Lore

### Calendar
- Control all mechanics which are time driven on geoscape
    - per day -> research progress, manufacturing progress, run ufo scripts, craft repair
    - per week -> heal units, create missions, run base scripts
    - per month -> trigger campaigns, monthly reports, replenish stock
    - per quarter -> increase number of campaign per month by 1
    - per year
- each month it has number of new campaigns to be created, it increase over time
- each month there is weighted change which faction to be selected for next campaign
- once it's all processed campaign is created

### Campaign
- campaign is main narrative and generator of missions
- campaign is per faction and trigger creation of missions through longer period
- they are always triggered on 1 day of each month
- campaign triggers its mission on week interval
    - week 1 -> 1 mission
    - week 2 -> no missions
    - week 3 -> 2 missions
- has list of missions to spawn, with delay between them 
- campaign per faction might be focus on specific region only (weighted)
- number of campaigns per month increase over time, they are always per faction
- when campaign is completed, there might be penelty or reward

### Mission
- Individual mission definitions with objectives, battle maps, and enemy deployments.
- Generates tactical battlefields with varying difficulty and strategic impact.
- Integrates with geoscape for interception scape.
- Mission can be either: site, ufo, base
- mission must be limited by research progress (disable or enable a mission)
- mission is core way how enemy score points and player interact with enemy
- missions are always created within a province and within a campaign
- many missions might be in single province, all are intercepted
- missions must be first detected to allow interaction (cover system)
- interception of cover mission results in ambush (player lose 1-3 turns)

### Faction
- Enemy faction system with unique missions, technologies, units and objectives.
- Each faction is enemy towards player, there is no relationship.
- Faction missions can be impacted by research progress until final deactivation of faction.
- all missions are always for single faction, thou custom mixed factions can be created

### Quest
- Player-driven objectives and achievements within the campaign.
- Provides optional goals and rewards for additional gameplay depth.
- Tracks progress and unlocks content based on completion.
- Works in simular way like medals on unit / mission level, but on geoscape level

### Event
- Spawn few events per month that may modify gameplay
- Modifies resources, spawns missions, or creates temporary effects.
- Not managed by campaign system, pure random events per month.
- not limited by technology or other elementss

### Mission - UFO
- Mission create moving ufo (land, water, air)
- can move between provinces via ufo script, must be intercepted, temporary
- Includes air battles, land battles, water battles
- When crash it may create another mission -> crash site
- when ufo will destroy player craft it may create another mission -> recovery site
- mission ufo usually have strong armament for interception 

### Mission - Base
- Mission created alien base in province
- stationary, has its own base script for growth and creation of new missions, 
- pernament, must be intercepted and destroy by player to resolve
- Usually have some base defences system for interception scape to defend itself from crafts
- Usually features large-scale land battle potentially 2 level battles. 
- Impacts global threat levels and faction relations.
- Base might be underground or underwater (but not underground underwater)
- usually score a lot of points negative in province just for exist per day

### Mission - Site
- Mission creates an generic enemy site
- stay in place until got picked by player, temporary
- thou site is temporary and does not have script, it may by itself be heavily defended

### UFO Script
- Manage how ufo mission behave during this turn / day
- This include fly, land, move, attack base, score points etc
- Ufo script last for several days with max one step per day
- when intercepted ufo script does nothing, it only control mission ufo behaviour on geoscape

### Base Script
- Manage static base mission behave every month
- control how base is growing (max 4 levels)
- control what missions it may generate for this month
 
## Organization

### Player Organization
- in general player organization growth and progress
- in game there might be several levels of growth
- this is considered like a milestone in game
- next level is unlocked by research
- level allows further options to be used, so research facility and everything else might need orgnization level of N
- this also include campgain, missions, events, might be linked to which organization level player has
- basic game has 4-5 levels
- every time player improve its organization level it got one point to spent on policies

### Internal Policies Sliders
- Adjustable policy settings affecting gameplay mechanics.
- Includes sliders for aggression, research focus, and operational priorities.
- Impacts funding, morale, and strategic outcomes.
- policies can be change once per month up and down
- policy points are got from upgrading organization level
- policy impact e.g
    - cost of research 10% per level
    - cost of manufacturing 10% per level
    - cost of unit / craft promption 10% per level
    - cost of relationship improvement 10% per level
    - cost of facilities in bases 10% of level
    - cost of marketplace price 10% of level (so at 5 its the same as sold price which is 50% of buy)

### Karma System
- Moral and ethical tracking based on player actions.
- Affects reputation, funding, and available options.
- Provides consequences for controversial decisions.

### Fame System
- Public recognition and media influence mechanics.
- Unlocks diplomatic options and special events.
- Rewards successful missions and strategic achievements.

### Score System
- Performance tracking across missions and strategic decisions.
- Influences funding adjustments and victory conditions.
- Provides feedback on player effectiveness.

### Diplomacy
- Relationship management with human countries, suppliers (corporations) and enemy factions.
- Affects mission availability, funding and marketplace.
- Relation with country defines his funding level towards player. 
- Relation with faction may cause some missions / campaigns be active / deactive
- Relation with suppliers defines what is available on the market place

### Relationship
- player can have relation ship with 
    suppliers for marketplace options
    countries for funding level
    factions for missions options
- relationship can be either
    very good
    good
    neutral
    bad
    very bad
- with supplier relation impact price from 200% to 50% of price
- with countries relation impact funding level change from -2 to +2 per month
- with factions relation impact number of missions from 200% if bad to 0% if good

## Finance

### Monthly Budget Control
- Financial management system tracking income and expenses.
- Provides visibility into funding changes and debt obligations.
- Enables strategic planning for resource allocation.
- Tracks income sources and expenses.
- Enables strategic resource planning.

### Report for Score and Budget per Region
- Regional performance reports showing score and budget impacts.
- Summarizes mission outcomes and economic effects by province.
- Supports strategic decision-making for base placement and operations.
- Summarizes provincial performance.
- Supports base placement decisions.

### Country Funding
- International funding model based on country satisfaction and security.
- Recalculates monthly contributions with modifiers for performance.
- Triggers panic events and funding reviews.
- Modifies contributions based on satisfaction.
- each country has a funding level from 0 to 10
- each country has a total economy which it sum of its economies from provinces they own
- every month based on score per country we check what would be relation
- for very good / bad score relation would increase or decrease
- high relation will increase funding and bad relation will decrease funding
- with hostile country they may even create missions against player organization

### Win Lose Game Conditions
- game is open ended, there is no clear win lose condition
- you can lose last base, be in debt, lose all countries as funding
- you lose when you stop playing
- to win game you need to fight with all factions and keep world free

### Debt Management
- Loan and credit system with interest rates and repayment schedules.
- Escalates to sanctions and loss conditions for missed payments.
- Supports emergency aid and bailout mechanics.
- Includes interest compounding and sanctions.
- Supports bailout mechanics.

### Income Sources
- Diverse revenue streams from missions, research, and countries funding.
- Tracks base operations, manufacturing, and diplomatic relations.
- Player can be bad one and get income from raids and pillage.

## GUI

### Menu
- Main menu system for game navigation and setup.
- Includes new game creation, loading, testing, and options.
- Provides access to different game modes and configurations.

#### New Game
- Game initialization with difficulty and mod selection.
- Sets up campaign parameters and starting conditions.
- Supports custom scenarios and mod integrations.

#### Start Battle
- Direct battle testing and setup interface.
- Allows configuration of units, maps, and objectives.
- Enables quick testing of tactical scenarios.

#### Load Game
- Save file management and loading system.
- Displays campaign progress and metadata.
- Supports multiple save slots and backup recovery.

#### Test GUI
- Interface testing tools for UI validation.
- Allows inspection and interaction with widget components.
- Supports development and debugging workflows.

#### Options
- Game settings and configuration menu.
- Includes audio, video, controls, and accessibility options.
- Persists user preferences across sessions.

### Geo Scape
- Strategic world map interface for global operations.
- Displays provinces, missions, crafts, and geopolitical information.
- Supports time progression and strategic decision-making.

#### Go to Base
- Base selection and navigation from geoscape.
- Shows base status, facilities, and available actions.
- Enables quick access to base management.

#### Missions
- Mission overview and assignment interface.
- Displays available missions with objectives and rewards.
- Supports craft allocation and mission planning.

#### Research Global
- Global research progress and project management.
- Shows research queue, completion times, and benefits.
- Allows prioritization and resource allocation.

#### Production Global
- Manufacturing and production oversight.
- Displays facility utilization and project status.
- Supports resource management and production planning.

#### Diplomacy
- International relations and negotiation interface.
- Shows country satisfaction, funding, and diplomatic options.
- Enables treaty management and alliance building.

#### Politics
- Political event and policy management.
- Displays current policies, events, and their impacts.
- Supports policy adjustments and event responses.

#### Reports
- Comprehensive reporting system for game statistics.
- Includes financial, mission, and performance summaries.
- Provides trend analysis and strategic insights.

#### Pedia
- In-game encyclopedia for game information.
- Contains entries on units, items, technologies, and lore.
- Supports search and bookmarking features.

#### Menu
- Quick access to main menu functions.
- Allows saving, loading, and game options during play.
- Provides exit and pause functionality.

#### Budget / Date
- Current financial status and date display.
- Shows funding, expenses, and time progression.
- Provides quick access to financial management.

#### Next Turn
- Turn advancement and time control interface.
- Allows pausing, speeding up, or advancing strategic time.
- Displays upcoming events and mission timers.

### Base Scape
- Base management interface for facility and resource control.
- Displays base layout, personnel, and operational status.
- Supports construction, research, and logistics.

#### Facilities
- Facility construction and management system.
- Shows available facilities, costs, and benefits.
- Allows building placement and upgrade planning.

#### Barrack with Units
- Personnel management for soldiers and staff.
- Displays unit roster, stats, and assignments.
- Supports recruitment, training, and equipment.

#### Hangar with Crafts
- Craft inventory and maintenance interface.
- Shows available crafts, status, and equipment.
- Enables repairs, refueling, and mission preparation.

#### Marketplace
- Resource trading and procurement system.
- Displays available items, prices, and suppliers.
- Supports buying, selling, and inventory management.

#### Storage
- Inventory management for equipment and resources.
- Shows stored items, quantities, and organization.
- Enables transfer and organization functions.

#### Transfer
- Inter-base and external transfer system.
- Manages movement of units, items, and resources.
- Supports logistics planning and execution.

#### Manufacturing
- Production facility management interface.
- Displays manufacturing projects and progress.
- Allows queue management and resource allocation.

#### Research
- Research lab interface for technology development.
- Shows research projects, requirements, and timelines.
- Supports project prioritization and completion tracking.

#### Prison
- Prisoner management and interrogation system.
- Displays captured aliens and interrogation progress.
- Enables intelligence gathering and alien research.

#### Hospital
- Medical facility for unit recovery and treatment.
- Shows injured units, recovery times, and medical staff.
- Supports healing mechanics and medical research.

#### Base Info
- Overview of base statistics and performance.
- Displays capacity, services, and operational metrics.
- Provides base management summary.

#### Budget / Date
- Base-specific financial and time display.
- Shows local expenses, income, and date.
- Integrates with global financial systems.

#### Next Turn
- Base turn advancement for monthly operations.
- Processes construction, research, and maintenance.
- Advances time and triggers monthly events.

### Battle Scape
- Tactical combat interface for turn-based battles.
- Displays unit positions, actions, and battlefield status.
- Supports real-time tactical decision-making.

#### 4 Actions Buttons
- Primary action selection interface.
- Displays available actions like move, shoot, and special abilities.
- Integrates with action point and energy systems.

#### Unit Info + Stats
- Detailed unit information display.
- Shows health, stats, equipment, and status effects.
- Provides tactical planning information.

#### Use Weapon
- Weapon selection and targeting interface.
- Displays available weapons with stats and ammo.
- Supports aiming and firing mechanics.

#### Use Weapon (duplicate)
- Additional weapon management option.
- Allows switching between primary and secondary weapons.
- Supports weapon-specific actions and modes.

#### Use Armour
- Armor and equipment management interface.
- Shows equipped items and their effects.
- Enables equipment changes during battle.

#### Menu
- Battle menu for options and controls.
- Includes save, load, options, and exit functions.
- Provides access to game systems during combat.

#### Next Turn
- Turn advancement in tactical combat.
- Ends current unit's turn and begins next phase.
- Processes AI actions and resolves pending effects.

### Interception
- Air combat interface for craft vs UFO battles.
- Displays craft positions, weapons, and tactical information.
- Supports simultaneous craft actions and targeting.

#### Player AIR x3
- Player air unit control interfaces (3 slots).
- Shows craft status, weapons, and available actions.
- Enables targeting and maneuver selection.

#### Player LAND x3
- Player ground unit control interfaces (3 slots).
- Supports land-based interception scenarios.
- Integrates with terrain and environmental factors.

#### Player UNDER water or land x3
- Underwater or land interception controls (3 slots).
- Handles submarine or ground-based engagements.
- Adapts to different combat environments.

#### Enemy AIR x3
- Enemy air unit tracking and display (3 slots).
- Shows enemy craft positions and capabilities.
- Provides threat assessment and targeting data.

#### Enemy LAND x3
- Enemy ground unit monitoring (3 slots).
- Tracks enemy land forces and movements.
- Supports defensive and offensive planning.

#### Enemy UNDER water or land x3
- Enemy underwater or land unit tracking (3 slots).
- Monitors submerged or terrestrial threats.
- Enables appropriate response strategies.

#### Some Other Buttons to Agreed
- Additional control buttons for interception mechanics.
- Includes agreed-upon interface elements.
- Supports specialized interception actions.

## Terrain

### Biome to Terrain Relation
- System linking biomes to terrain generation and characteristics.
- Defines environmental effects on gameplay and visuals.
- Supports diverse mission settings and strategic variety.

### Fixed Terrain (Base)
- Fixed terrain maps for special missions like base defense

### List of Tiles
- List of map tiles used for this terrain durring map generation

### List of Map Blocks
- Which map blocks could be used for this terrain during map generation

### List of Map Scripts
- Which map scripts could be used with this terrain during map generation

### List of Prefabs for Map Blocks
- Pre-built small map blocks for quick assembly e.g. house, car etc.
- Includes common structures and terrain features.
- Accelerates map creation and ensures consistency.

### Tactical Features
- Terrain elements affecting tactical gameplay.
- Includes cover, elevation, and movement modifiers.
- Influences combat positioning and strategy.

### Environmental Features
- Raining, snowing
- Special visual effect other then day / night
- impact on sanity 
- random terrain descruption at start or during game

## Content Generator

### Map Block Generator
- Create new map block 

### Map Script Generator
- Create new map script

### UFO Script Generator
- Create new ufo script

### Base Script Generator
- Create new base script

### Campaign Generator
- Create new campaign

### Mission Generator
- Create new mission type

### Faction Generator
- Create new faction

### Event Generator
- create new event

### Technology Entry Generator
- create new technology entry

### Facility Generator
- create new facility

### Item Generator
- create new item

### Unit Class Generator
- create new unit class

### Craft Class Generator
- Create new craft class



## Units

### Unit Management System
- Comprehensive unit tracking and management.
- Handles stats, equipment, and progression.
- Supports recruitment, training, and deployment, healing etc

### Unit Class
- Unit classification system with roles and specializations.
- Defines base stats, abilities, and equipment options.
- Each class has a race
- Class can be either mechanical, biological or mixed

### Unit Promotion
- Units get experience via mission, medals and training in base
- with experience they can be promoted to other class (class tree like Wesnoth Battle)
- Higher class -> higher rank -> higher salary
- Unit levels are 0 100 300 600 1000 1500 2100 of exp per level
- Some classes might require technology or facility or service
- units can be demoted to get 50% expeirience back and choose another path

### Unit Stats
- Core unit attributes  for basic human all are in range of 6 to max 12

- Health - obvious
- Energy - used for all actions including as ammo for item
- Energy reg - regeneration of energy per turn, default is Energy / 6
- Strenght - defines melee battle, capacity for inventory, throwing

- Will - defense vs psionics
- Psionics - offensive in psionics
- Bravery - to perform fear test and lose morale during battle if failed

- React - reaction fire chance during overwatch and overall dodge chance
- Aim - defines accuracy at fire or throwing
- Speed - defines number of Move Point per Action point per turn

- Sight - range of sight to see battle tiles, directional 90 deg
- Sense - same as sight by close omni directional
- Cover - inbuild ability to reduce enemy sight / sense

- Armour - in build armour, usualy by wearing armour

### Unit for Enemy
- a template for enemy to used when building enemy squads during battle
- it contains unit class with specific stats + standard inventory + trait + AI behaviour system

### Unit Transformation
- Unit metamorphosis and evolution mechanics.
- Unit might have ONLY ONE permanent transformation, cannot be undone
- this is not related to experience and promotion but rather to surgery
- usually required technology, facility, service or specific unit class
- provide pernament boost to unit stats
- might allow use of specific uniti items
- might be limited to specific race

### Unit Inventory
- Equipment and item management per unit.
- Unit may carry 2 weapons and armour. 
- Tracks weapons, armor, and consumables.
- Supports inventory limits and weight systems.

### Unit Medals
- for specific missions unit might got a medal
- gives high boost of experience, much higher then mission
- other that this does not give any bonuses by itself
- specific medal can be aquired only once 
- might be some prerequisites to get the medal e.g. 10 kills during mission 

### Unit Traits
- special ability or personality that is randomly selected at start of game
- give boost to stats 

### Unit Sizes
- Unit is either small, medium or large
- small medium takes 1 slot on battle
- large unit takes 2x2 slots on battle

### Unit Salary
- unit salary is fixed per class
- might be modified thanks to trait e.g. loyal -50%
- higher rank = higher salary, unless some classes might overwrite this

### Unit Recruitment
- units can be purchased on market OR manufactured OR captured during mission
- unit starts with specific class with predefines stats and no equipment

### Unit Ranks
- unit rank is tier of unit in unit promotion tree
- rank means how many times unit got promoted 
- used mainly to compare teams strenght (unit of rank 3 and more)
- Unlocks advanced equipment and missions.

### Unit Race
- its used only for grouping classes like alien, human, elf

### Unit Faces
- player units has faces, 2 sex, 4 races, 8 variants
- more races for player units will provide more variety

### Unit Energy & AP
- Action point and energy resource management.
- Limits unit actions and special abilities.
- All units have 4 AP, unless morale / sanity / wounds will change it
- Energy is based on many factors
- AP are replenish to max every turn
- Energy is regerated per energy regen, basic is 1/3 of base energy

### Unit movement
- Each unit has MP = unit speed * AP
- using AP on actions will reduce MP left
- using MP on move will reduce AP left proportionally
- move system is described here

### Unit Encumbrance
- unit has strenght that define its max cargo for items / armour
- unit either has space or not, its zero one system
- Does not affect movemenet or skills as either you can take it or not

### Unit Healing
- unit recover 1 health per week
- unit recover 1 sanity per week
- its faster with hospital / leasuire system (e.g. 150%)

## Items

### Item for Units - Weapons
- Weapon system for unit equipment.
- Defines damage, range, and special effects.
- Supports various weapon types and ammo.
- Weapons does not have clips, they provide and consume energy instead
- have cooldown, AP cost, EP cost, range, damage, accuracy etc
- many special items like medikit, grenade, flare are also unit items weapons

### Item for Units - Armours
- Armor protection and modification system.
- may be limited to specific class
- may boost stats like strengh
- may cripple some stats when use due to heavy
- cannot be change during battle
- most unit clases have 1 slot, but some might have in build so zero slot for armour

### Item for Craft - Weapons
- Craft-mounted weapon systems.
- might be air to air, air to land, land to land, etc also works underwater
- have AP cost to use and Energy Points to use
- have chance to hit, damage, range, 
- Takes space in craft cargo, may not fit
- may come in different sizes (small laser, large laser)

### Item for Craft - Addons
- craft mounted non weapon systems
- impact crafts stats or abilities like afterburn or shield, sensors

### Item Lore
- special item that does not take place in storage, has no size
- its usually used in research
- has no other value, cannot be used

### Item Resource
- items which are mainly used as consumable during research, manufacting process
- items are saved in storage and takes space
- cannot be used by units / crafts
- has seperate category on market
- are usually divided into human / aliens and cover 5 tiers of progress
- usually are divided into construction / energy / fuel

### Item Prisoner
- Items are not stored in Storage but in prison
- Each item prisoner is 1 size
- Are consumed in research and manufacturing
- Have chance to die in captivity

### Item Weapon Mode
- Weapon firing mode and configuration system.
- Includes burst, auto, snap, and special modes.
- Defines
    - cost to use AP
    - cost to use EP
    - modifier to range, chance to hit, number of bullets, damage, range
- modifiers are global not per weapon, weapon has active some modes

### Item Special per Class
- some unit classes might have item restriction like psionic
- if unit has a class (including all classes parents used before to get to this class)
- its binary system, either it can be used or not

### Item durability
- in general items are not consumable, even grenades for simplicity 
- items do not use consume ammo, there is energy system
- items when thrown even mine, are not used, they have long cooldown during battle
- items are not desctuctable due to normal use but might got destroyed due to explosion on terrain 


## Crafts

### Craft Management System
- Craft tracking and control.
- Handles maintenance, fuel, repairs, rearms (energy) per day.
- Handles position on provinces between worlds

### Craft Class
- Craft classification with roles and capabilities.
- Defines all stats and item mounts
- Defines roles, interception, transport, bombard effectivness
- defines is it water, air, land

### Craft Promotion
- Craft collect experience similar way like unit
- craft get level on 100 - 300 - 600 - 1000 - 1500 - 2100 EXP
- they might get promoted to higher class like Interception I -> Interception II
- they stats are somehow improved
- best way to get higher crafts is to invent them and build

### Craft Inventory
- craft has up to 2 slots for weapons and up to 1 slots for addons
- large have will use heavy weapons rather then many smaller items
- Craft has cargo capacity to install 2 weapons + 1 slot
- NO encumbrance system, either it will fit or not
- items does not have ammo, they use energy system
- energy on craft is replenish per action

### Craft Energy & AP
- craft has Action Points system like Units has
- craft has energy points like units to use during interception 
- energy are considered as ammo / fuel on interception level 
- Limits maneuvers and weapon usage.

### Craft Stats
- Speed - number of actions per turn 
- health
- bonus to accuracy, bonus to damage, bonus to dodge
- fuel used, fuel consumption, range
- number of weapon slots ( 0 1 2 )
- number of addons slots ( 0 1 2)
- number of passangers 
- total cargo for items (weapons and addons)
- range to perform action 

### Craft Salary
- Operating cost system for craft maintenance.
- Craft cost might slightly change when upgrading class
- Fuel is paid on usage seperatly 
- Craft weapons does not consume anything to operate
- 
### Craft Recruitment
- Craft can be build in workshop or buy in market
- base must hase free craft capacity to store new craft
- crafts always starts with 0 experience

### Craft Fuel & Range
- craft has a type of fuel and fuel consumption per action
- craft has number of actions per turn (speed)
- craft has range in km to perform actions on geoscape
- when action is started it just consume fuel and allow to perform it
- there is no refuel phase after action
- no fuel at base = no option to perform action

### Craft Encumbrance
- Craft has cargo limit
- craft can either take items or not, its a fit or not fit scenario
- if craft has capacity for units then it does not impact its performance, either it will fit or not

### Craft Repairs
- Crafts are being repair in hangars with daily update
- Craft reparis are automated and at no cost
- craft cannot be sent on mission when damaged


## Economy


### Marketplace Management System
- handle availability of all good in the market
- based on fame, karma, score, region, contact with supplier
- track monthly consumption of goods, and reset it at start of the month
- manage impact on karma, fame, score when using black market

### Black Market Management System
- illegal market place
- it works the same way like normal but its usually for items with higher value and harder to get
- player to switch from market place to black market

### Supplier
- defines vendor who provide goods to market
- Purchase entry may need supplier
- Suppliers are unlocked with technology
- may operate only in specific region / world
- supplier relation ship may impact if its available, stock price and stock quantity

### Purchase Entry
- single offer in the market play to buy item / unit / craft
- include price, supplier, availablity and delivery time
- may require technology or supplier contant

### Purchase Order
- player select purchase entry, select which base, quantity and click buy
- all items from purchase order are grouped by delivery date and destination
- and transfer order are made
- some orders are on black market that may impact fame / karma
- when bought then monthly limited for these goods are deducted

### Goods
- common name for items / units / crafts in base capacity

### Transfer Order
- when buiing something on market it will create transfer order
- goods (items, crafts, units) will be deliered in this base in N days
- also used to transfer between bases
- can b also used for manufacting projects when are over and goods are delivered with delay 0 days




### Manufacturing entry 
- Single entry what can be build from what
- usually it required technology, facility or service, 
- may be limited by region of base
- defines what is cost in man days, in items and what items it produce
- outomes are units, items, crafts

### Manufacturing Management System
- manage all manafucturing projects in all bases
- these projects are seperated in base, they do not work together
- production can be queeded. 

### Manufacturing Project
 - player select manufacturing entry , assing people, define quantity and start it
 - mfg project tracks progress per day, use assigned capacity to progress work
 - can be run in pararel in many bases 
 - once done, then items / units / crafts are added to base 
 - when canceled then capacity is freed and no longer resources are consumed





### Research Entry 
- single research with description, cost, potential image
- may need another research, facility, item in store, base service
- may be blocked by another research
- may be limited by region of base
- player may select it to start a project, assign people and progress it

### Research Project
- player select research entry and starts a project
- it has assigned research capacity and track progress
- can have many proejcts on same research in many bases

### Research Tree
- visualization how technologies entries are connected to each other
- support many different types od dependencies
- does not track progrss, this is on manager

### Research Management System
 - manage all research projects in all bases (they are cumulative)
 - based on information in each research entry manage unlocking / locking them when research is completed
 - manage progress of research projects per day
 - checks which research entries can be started
 - manage actual cost of research entry (50% - 150% of base, randomized at start)



## Pedia

### Pedia Category
 - pedia category helps to organize pedia entries into logical groups.

### Pedia Entry
 - single pedia entry with image, table data, and text 
 - must be unlocked by techhnology 
 - 



## Geoscape

### Universe
- Handle list of worlds.
- Handle travel between worlds via portal,
- Handle time differences between different worlds.
- Handle overall game progress

### World
- Single planet with background image, provinces connected, regions, countries and portals
- Manage handling all components per turn on geo

### World tile
- not used at the momemnt
- world is divided into tiles that has a type (water, land) and cost to move (1, 2, 4)
- this is used to calculate distance from provinces as a path instead of straight line
- different crafts like land / air / water / underwater crafts may use different paths to travel to provinces
- there might be or might be not tiles visible on the world map, or just background image
- provinces are always snap to world tile grid
- other then for paths and movement, there is no other uses, missions are done on province level anyway

### Province
- Location on world, is technically speaking node in graph connected to other provinces
- Has popoulation level and economy power
- has assigned biome
- might have many missions inside, many crafts but single base
- distance and path between provinces define range and available options for crafts from base from this province 

### Region
- Geographic and cultural groupings.
- Every province must belong to single region. 
- Regions accumulate score from mission, fame, karma too
- may limit some options e.g. market place

### Biome
- every province has a biome assigned that define enviroment, fauna, flora in this province
- Is either land or water. 
- Defines terrain used in battle scape and mission types available.
- Provides visual variety on geo scape map and interception background image
- may impact interception gameplay to some extend

### Calendar
- Time progression and event scheduling.
- Tracks days, weeks, months, qurter, years.
- Supports campaign timeline management, create campaigns per month, and new missions per week. 

### Portal
- Dimensional gateway mechanic, links to provinces and allow instant travel. 
- Enables alien invasion and travel between worlds
- might be discovered or disabled by technology

### Country
- National entities with funding and relations.
- Country own a province, and it economy and population comes from provinces
- All score, fame, karma earned in provices is also accumulated on country level
- good score increase relation ship with countr per month (range 0 - 10)
- good relationship with country increase funding level from country to player

### Game Turn
- Strategic turn advancement system.
- Processes events, construction, and AI actions.
- Manages campaign progression and timing.
- Processes actions.
- Manages progression.

## Geoscape AI

This section is concept

### Enemy Strategy
- Alien strategic planning and decision-making.
- Defines invasion patterns and objectives.
- Adapts to player actions and progress.
### Faction Behaviour
- Faction-specific AI behaviors and motivations.
- Influences diplomacy, missions, and technology.
- Provides varied strategic challenges.

## Basescape

### Build New Base
- Base construction is within a province
- price of new base depends on province, regions, biome
- max number of bases is 12
- typical base layout is 5x5
- only one base of player can be inside province

### Facilities
- Base building and upgrade mechanics.
- Defines facility types, costs, and benefits.
- Enables specialized base capacitie
-
### Facility Placement in Base
- central place in base is HQ
- all faciltiies must be connected
- facility has time to build in days (20)
- facility has health when damaged must be repair (are not funcitonal)
- facility may be disabled, is not maintained but does not bring benefits
- game assume base is undeground or underwater (but not undeground underwater)

### Base Services
- Facility can provide a service which is as simple as tag on a list
- other facilitires , research, purchasing, manufacturing etc may be depend on it
- this is all, entire TAG system

### Base Capacities from Facilities
- capacity for items (storage)
- capacity for units (barracks)
- capacity for crafts (hangar)
- capacity for prisoners (prison)
- capacity for research projects (lab)
- capacity for manufacturing projects (workshop)
- capacity for unit health recovery
- capacity for unit sanity recovery
- capacity for unit training
- radar power and radar range
- base externel defences for interception
- base cover power
- base internal defences for battlescape

### Base Unit Management
- Only units need barracks / living quaters space
- No other personal in base like scientists
- Unit can stay in base or be assigned to craft
- Regardless if they are base or craft, they still need barracks capacity
- Each unit take space in barracks like their size stat (1, 2)
- Units in base can be healed, trained, prompted, equipmed, assign to craft
- units can be grouped in squads for faster deployment
- Unit can change its equipment (2 weapons and armour)
- Unit is healed both health and sanity per week

### Base Craft Management
- Only crafts needs hangars capacity
- Crafts are refueal after every action, with cost of fuel
- Crafts are rearmed after every action for free
- They are repaired on daily basis
- Craft can equip up to 2 weapons and 1 addon
- Craft can take N units onboard
- Craft does not take any item units on board, just units
- Craft can be bought and sold in base
- craft if ready for mission can be sent to another province

### Base Items Management
- Items can be equiped to units and crafts
- Items can be used in market place or manufacturing
- Items can be transfered to another base
- Items take different space in base (prisoner, storage or none)

### Base Prisoners Management
- Dead enemy is consider dead and corpse is collected
- Live enemy is considered capture and is put to Prison in base
- Prisoners can live in prison only for specific time then they will die
- prisons can be sold from prison

### Base Transfers Management
- Units, items and crafts can be transfer between base
- cost and time in days of transfer depends on base distance
- same mechanism is used for marketplace

### Monthly Base Report
- Base performance and status summary.
- Includes finances, operations, and events.
- Provides management insights and planning data.

### Base Defences for Interception
- Base facilities can provide both Health and Damage during interception
- Health of facility contribute to health of base 
- Damage of facility is weapon used to fight enemy crafts during base defense 

### Base Radar for Geoscape
- base radar allows to detect missions on geoscape
- radar range is in km and radar power is how much cover of mission is reduced
- all facitlies works together cumulative effect once per day

### Base cover
- Base can have facility that prevent base being detected by enemy missions ufo

### Base defenses internal for Battlescape
- special facility can provide units like turrets during base defense missions

## Interception

Additional screen between geoscape and battlescape

### Interception Lifecycle
- detect mission on geoscape
- sent crafts to province
- start inteception 
- use crafts / base to figth with enemy ufo / site / base
- either win and move to geoscape
- either win and move to battlescape
- other missions might be created after like rescue site, crash site

### Mission Detection on Geoscape
- crafts and bases with radar coverage can detect missions in provices
- if craft is moved to province it may start interception 
- if mission was there but it was not detected, ambush will happen
- many crafts can be sent to single province within turn to handle many missions

### Craft Operations
- craft can be sent to province if in range
- craft might use world tile to travel different ways to provinces in range
- craft consume fuel from base to get there, no need to refuel
- craft will return same momemnt after interceptions is done
- craft can move to N missions same turn, its has speed stat

### Craft Fuel & Range
- craft use specific fuel item from base (resource) or none
- this item must be in base before flight
- craft fuel consumption define how much it consume per action, e.g. 4
- craft speed defines much many times he can act during a turn

### Core Interception Mechanics
- interception is special screen divided on left (player) and right (enemy)
- divided on 3 layers from top (air), middle (land or on water), bottom (underground or underwater)
- each section of the interception (total 6 sections) may contain up to 3 crafts, ufos, sites, bases
- each object on interception cannot switch its possition during interception unless shotdown
- each object interact with other until one side will be destroyed or retreat

### Craft Weapons Usage
- ufo, craft, bases can use their weapons same way like units
- energy, action points, cooldown, 

### Craft Movement
- air crafts / ufos are position in air section
- land crafts / bases / sites are position in land section
- underwater crafts / base / ufos are positioned in underwater section
- naval crafts / ufos are positioned in land / water section
- land underground bases are posiitions in underground section
- land or water depends on province biome

### Underwater Scenario
- Submarine combat and exploration.
- Includes depth, sonar, and underwater weapons.

### Air Battle Scenario
- Aerial dogfighting and engagement.
- Defines flight physics and weapon ranges.

### Base Defense Scenario
- Ground-based defense against attacks.
- Includes fortifications and countermeasures.

### Base Assault Scenario
- Offensive operations against enemy bases.
- Features large-scale battles and objectives.

### Land Battle Scenario
- Ground combat transitions from interception.
- Includes vehicle and infantry engagements.
- Supports combined arms tactics.

### Water Battle Scenario
- Naval and surface water combat.
- Includes ships, submarines, and amphibious operations.
- Provides coastal defense options.

### Site Landing Scenario
- Precision landing and extraction missions.
- Requires accurate positioning and timing.

### Rescue scenario
- When craft got destroyed to rescue pilot it may create rescue pilot mission

### Crash site scenario
- when enemy ufo was crashed, but not destryed, its remains can be salvaged on land

## Mission Management

### Mission Lifecycle
- Complete mission process from generation to completion.
- Includes preparation, execution, debriefing, and rewards.
- Manages campaign integration and progression.
- Includes debriefing.
- Manages integration.

### Mission Concealment
- Some mission might have Concleament budget
- it means you can take what ever you want to battle
- but if you are detected, mission is considered lost
- different actions / items usage on battlefield are considred stealth or not
- if your actions are detected by enemy or neutral units you consume Concealment budget
- default missions have no budget, and no problem with this
- this does not limit can be take to battle, but what can be used on battle

### Mission Planning
- Pre-mission planning and briefing.
- Provide basic information about terrain, map size, your team, ally etc
- Show landing zone and allow to plan which unit to start in which zone
- Explain mission objectives like kill all enemies, get to area etc
- does not show anything about enemy units or map other then landing zones

### Mission Salvage
- Post-mission recovery and extraction.
- All battle tiles are convered to resources.
- All live units are convered to item - prisoner.
- all allied unit items got refill with energy. 
- Experience and medals are given to units.
- Units got check for any potential sanity loss or wounds got. 
- All items from units is extracted as items. 
- Total mission score, fame, karma is calculated

### Landing Zone
- when battle starts first is planning
- player will see mini map with Landing Zones
- 4x4 -> 1, 5x5 -> 2, 6x6 -> 3, 7x7 -> 4 zones
- player can assign units to each landing zone to build initial tactics
- rest map must be explored during missions

### Spawn Points
- Map has randomly distrubute spawn points
- spawn points are connect in network with pathdfinding
- TODO dopisac tutaj jak dziala map blocki, battle grid etc

### Team Auto Promotion
- mission has faction, that defines which unit classes can be used
- mission also has Team power which is experience points used to promote units
- mission also has Team size which defines number of enemy units
- mission also has Team Level which defines max level of any enemy unit as output
- randomly units are created and prompted using unit class default promption system, until all experience points are used within limits of Team Power, Team Size and Team Level
- units classes has default inventory used during next step deployment
- this is how final enemy Team is build

### Mission Deployment
- Once enemy Team is build with unit classes 
- Each unit class for enemy has default inventory 
- this is not one item, this is random set of items with weights
- this is used to handle loadout of all units
- this does not take into considation technology limitations, this is done before already

### Teams squads
- once all enemy units within a team has inventory they are grouped into squads
- squad is deployed together in single map block and supposed to have complementary 
- squad can be as small as 1 unit, or there might be single squad for entire team


## Battle Map Generator

### Map Prefab
- small 2D array of map tiles predefined
- it may have any size
- used to reuse same elements on map blocks e.g. house, car etc

### Map Block
- single map block is 15x15 or multiplayer of this of map tiles
- its core element of map block generation
- defintions of map blocks are defined in external text file
- map blocks are grouped by terrains
- map blocks contains specific gameplay features e.g. vallye
- map blocks can be 45x15
- map blocks can be rotated, mirrored during generation
- map blocks reuse map prefabs
- map blocks are single layer, no floors like in ufo xcom

### Map Tile
- individual tile on map blocks
- is either floor (can move) or wall (cannot move)
- may block line of sight, line of fire
- represent aprox 1-2 meter of terrain
- may be high or low land (elevation)
- is represented by single character on map block 
- each element might have common stats (like furniture) but might have different graphic assigned

### Map Script
- define how map blocks are used, which map blocks in which order to build map grid
- complex conditionals to control flow IF THEN ELSE
- use flood fill, add specific map blocks, roads H V and HV
- is assigned to

### Map Grid
- map grid is 2D array of map blocks created by map script
- once its created mission objectives could be used to define value of each map block within a grid
- some elements of grid would be selected as Landing zone for player

### Tileset
- list of png files loaded from png, aka sprite atlas
- each tile is 12x12 pixels or 24x24 pixels for retina
- map tile is filled with single character that represent terrain 
- but when loaded to game it may select random graphic element defined in tilesets
- in most cases single terrain has one tileset file to cover all its graphics

### Battle Grid
- once all map tiles are linked into single huge 2D map its called battle grid
- battle grid is huge (up to 105x105) 2D array of battle tiles
- battle grid is actuall map 2D table where entire battle is going on

### Battle Tile
- single entry in battle grid
- contain terrain (map tile) + objects + unit standing + smoke / fire effect + fog of war
- basic place of all pathfinding, line of sight, line of fire calcualtion

### Battle Field
- this is battle grid with list of units, sides, squads, fog of wars, smoke fire etc
- it manage everything on the battle grid including AI

### Map Generator
- large script that process everything above
- from terrain type and mission size to battle grid with everything inside

## Battle Tactical Combat

### Accuracy at Range
- Distance-based accuracy modifiers.
- Affects weapon effectiveness and tactics.
- Encourages positioning and cover use.
- Affects effectiveness.
- Encourages use.

### Battle at Night or Day
- Time-of-day combat effects.
- Influences visibility, morale, and abilities.
- Adds strategic timing considerations.
- Influences factors.
- Adds considerations.

### Line of Fire
- Direct fire path calculations.
- Determines valid shooting angles and obstructions.
- Supports realistic combat geometry.
- Determines angles.
- Supports geometry.

### Line of Sight
- Visibility and concealment mechanics.
- Affects detection, targeting, and ambushes.
- Enables fog of war and stealth tactics.
- Affects detection.
- Enables tactics.

### Unit Morale
- Psychological state affecting performance.
- Influences accuracy, movement, and surrender.
- Adds human elements to combat.
- Influences surrender.
- Adds elements.

### Light vs Fog of War
- Visibility systems and information management.
- Reveals and conceals battlefield information.
- Supports strategic information control.
- Reveals information.
- Supports control.

### Objects on Battle Field
- Interactive terrain and destructible elements.
- Includes cover, obstacles, and environmental hazards.
- Affects positioning and tactics.
- Includes hazards.
- Affects positioning.

### Unit Panic
- Fear and stress mechanics.
- Causes erratic behavior and reduced effectiveness.
- Adds tension and risk to combat.
- Causes behavior.
- Adds risk.

### Unit Psionics
- Psychic abilities and mind control.
- Includes alien special powers and defenses.
- Provides supernatural combat elements.
- Includes powers.
- Provides elements.

### Unit Sanity
- Mental health and madness mechanics.
- Affects unit reliability and abilities.
- Supports horror-themed gameplay.
- Affects reliability.
- Supports gameplay.

### Smoke & Fire
- Environmental effects from combat.
- Obscures vision and causes damage over time.
- Adds dynamic battlefield changes.
- Obscures vision.
- Adds changes.

### Team Surrender
- Capitulation mechanics for overwhelmed forces.
- Ends battles and affects campaign outcomes.
- Provides mercy and escalation options.
- Ends battles.
- Provides options.

### Damage to Terrain
- Destructible environment system.
- Creates craters, rubble, and tactical opportunities.
- Affects long-term battlefield changes.
- Creates opportunities.
- Affects changes.

### Terrain Elevation
- Height-based combat mechanics.
- Influences line of sight, cover, and movement.
- Supports 3D tactical positioning.
- Provides strategic depth.
- Affects positioning.

### Throwing
- Grenade and projectile mechanics.
- Includes arc calculations and blast effects.
- Allows indirect fire capabilities.
- Includes calculations.
- Allows capabilities.
- Adds ranged area damage options.

### Cover
- Protective terrain utilization.
- Reduces incoming damage and provides defense.
- Affects accuracy and hit chances.
- Provides defense.
- Affects chances.
- Encourages tactical positioning.

### Unit Status Effect
- Temporary condition system.
- Includes buffs, debuffs, and environmental effects.
- Modifies unit capabilities dynamically.
- Includes effects.
- Modifies capabilities.

### Unit Unconscious
- Incapacitation and recovery mechanics.
- Affects unit availability and medical requirements.
- Supports non-lethal combat options.
- Affects availability.
- Supports options.

### Unit Wounds
- Injury system with lasting effects.
- Reduces effectiveness and requires treatment.
- Impacts long-term unit performance.
- Reduces effectiveness.
- Impacts performance.
- Adds consequence to combat damage.

### Unit Heal & Repair
- Recovery systems for units and equipment.
- Includes medical facilities and repair mechanics.
- Restores unit capabilities over time.
- Includes facilities.
- Restores capabilities.
- Supports campaign sustainability.

### Action Point System for Movement
- AP cost for positioning and relocation.
- Balances mobility with other actions.
- Encourages efficient movement planning.
- Balances mobility.
- Encourages planning.

### Energy Pool System for Using Items
- Energy requirements for equipment activation.
- Limits special item usage in combat.
- Adds resource management to tactics.
- Limits usage.
- Adds management.

### Armour Piercing
- Penetration mechanics for weapons.
- Affects damage against armored targets.
- Allows bypassing defensive layers.
- Affects damage.
- Allows bypassing.
- Supports anti-vehicle and heavy weapons.

### Damage Calculation
- Hit determination and damage resolution.
- Includes accuracy, armor, and critical hits.
- Determines combat outcomes precisely.
- Includes hits.
- Determines outcomes.
- Provides fair and balanced combat results.

### Damage Type
- Elemental and special damage categories.
- Affects different armor types and resistances.
- Adds weapon variety and counterplay.
- Affects types.
- Adds variety.

### Damage Model
- Comprehensive damage application system.
- Considers multiple factors for realistic outcomes.
- Supports moddable damage mechanics.
- Considers factors.
- Supports mechanics.

### Damage Method
- Weapon-specific damage delivery systems.
- Includes projectiles, energy, and melee.
- Defines how damage is inflicted.
- Includes systems.
- Defines damage.
- Affects combat feel and tactics.

### Hurt vs Stun
- Damage type differentiation.
- Provides non-lethal and incapacitation options.
- Allows varied combat approaches.
- Provides options.
- Allows approaches.
- Balances lethality with utility.

### Actions - Movement
- Positioning and relocation mechanics.
- Includes walking, running, and special movement.
- Affects turn structure and tactics.
- Includes movement.
- Affects structure.

### Actions - Overwatch
- Opportunity fire and defensive positioning.
- Allows reactive combat responses.
- Adds tension and positioning strategy.
- Allows responses.
- Adds strategy.

### Actions - Running
- High-speed movement with penalties.
- Increases mobility at accuracy cost.
- Provides speed vs precision trade-off.
- Increases mobility.
- Provides trade-off.
- Supports aggressive tactics.

### Actions - Sneaking
- Stealth movement and detection avoidance.
- Enables ambush and infiltration.
- Reduces visibility and noise.
- Enables ambush.
- Reduces visibility.
- Adds scouting and reconnaissance options.

### Actions - Suppress Fire
- Area denial and morale suppression.
- Pins down enemies and reduces effectiveness.
- Supports fire and maneuver tactics.
- Pins down.
- Supports tactics.

### Actions - Crouch
- Low-profile positioning for cover.
- Improves defense and concealment.
- Affects movement and visibility.
- Improves defense.
- Affects movement.


## Battlescape AI

### Map Exploration
- AI pathfinding and area coverage using known map nodes for navigation.
- Defending AI must explore the battlefield to gain awareness, even in defensive positions.
- Enables intelligent positioning, scouting, and threat assessment through exploration.
- Better map coverage improves unit spotting and response effectiveness.
- Affects dynamic threat assessment and adaptive responses.

### Map AI Nodes
- Invisible strategic points on the battlefield for AI decision-making.
- Dynamic path calculation between nodes every turn.
- Each node has a weight indicating its importance to AI behavior.
- Spawn points are dynamically generated at game start.
- Initially, map AI nodes and spawn points coincide, but spawn points contain units while AI nodes do not.
- Utilized by unit or squad AI for coordinated team movement.

### Battle Map Movement
- AI navigation and positioning using initial spawn points as map nodes.
- Nodes are connected and paths calculated between them every turn.
- Units navigate the map via these nodes and paths.
- Paths are recalculated every turn if terrain is destroyed or changed.
- Each map node has an AI score representing weight in scripts.
- Optimizes paths and tactical placement based on node scores.
- Responds to player actions dynamically.
- Considers terrain, threats, and objectives.
- Enables dynamic battlefield adaptation.

### Battle Team Level AI
- Provides strategic planning and overview of battlefield conditions.
- Compares mission objectives against the current situation.
- Develops high-level plans for unit actions and objectives.
- Coordinates multiple squads and adapts to player strategies and progress.

### Battle Squad Level AI
- Receives information from the strategic level.
- Coordinates efforts of multiple units to achieve strategic goals.
- Manages group coordination, tactics, and formation maintenance.
- Supports combined arms and team-based enemy behavior.

### Battle Unit Level AI
- Executes plans through individual unit actions.
- Handles targeting, movement, and ability usage.
- Provides responsive and challenging combat intelligence.
- Focuses on individual unit reactions and decision-making.


## Battlescape

### Battlefield
- Main place to firth via units with enemy units
- 2D array of Battle Tiles with units, objects etc
- Fog of war per tile, per battle side
- destrutable terrain
- map is flat, one level only

### Battle Sides
- 4 fixes battle sides
- player is blue
- allied to player is green
- enemy to player is red
- neutral to player is gray
- units of each side share same fog of war

### Battle Size
- Battle size is defined in map blocks
- small is 4x4 (1 zone / 75% deployment)
- medium is 5x5 (2 zones / 100% deployment)
- large is 6x6 (3 zones / 150% deployment)
- huge is 7x7 (4 zones / 200% deployment)
- battle size defines number of unit zones for player to deploy its units at start
- battle size impact alien deploymenet size

### Turn Management
- 1 turn in battle is 10 seconds
- first player, then ally, then enemy, then neutral, order is fixed
- if ambush then add / remove some random free turns at start
- at start of each turn reset of fog of war per side

### Team Score
- Each team has a score counter
- each lose or kill unit grants score
- each secondary way to get score (capture the flag, domination, death match, rescue etc)
- if team score 100 points per battle it wins
- if mission has 3 places to capture each will grant 33 points
- if mission has 12 units to kill each will grant 8 points
- if mission has 20 turns to defend, each turn will grant 5 points

### Win Lose Conditions
- Mission has objectives
- Fullfilling objectives for team give them score
- First team got score of 100 per battle wins
- Neutral team does not score points

### Bullet Physics
- Bullets are objects on the battlefield used to simulate all interactions between units, like firing guns.
- Bullets use Box2D physics attached to battle tiles.
- Some bullets are kinematic, some are like lasers with a beam and ray tracing.
- Explosions are made by spawning shrapnels in all directions and detecting hits.
- For physics purposes, some battle tiles have their Box2D bodies like circle, rectangle (large/small), or a line (vertical/horizontal) or a whole for windows, etc.
- Used also for melee fights, but in most cases, it hits.

### Animations
- animation to improve quality of game

### Special Effects
- Particle systems
- explosions
- day night effects

## Advanced Modding

### TOML Load for Config
- Configuration file parsing system.
- Supports structured data for game content.
- Enables moddable settings and parameters.
- Supports data.
- Enables settings.

### Lua Load for Scripts
- Script loading and execution environment.
- Provides powerful modding capabilities.
- Supports complex behavior and logic modification.
- Provides capabilities.
- Supports modification.

### Multi Mod Load
- Simultaneous mod compatibility system.
- Manages dependencies and conflicts.
- Enables rich mod ecosystems.
- Manages dependencies.
- Enables ecosystems.

### Mod Overwrite Content
- Content replacement and extension mechanics.
- Allows mods to modify existing game elements.
- Supports deep customization.
- Allows mods.
- Supports customization.
- Supports comprehensive customization.

## Engine Tests

### Engine Tests
- Core system validation and testing.
- Ensures stability and correct behavior.
- Supports development and debugging.
- Ensures stability.
- Supports development.

### API Tests
- Interface and integration testing.
- Validates modding interfaces and compatibility.
- Ensures reliable external interactions.
- Validates interfaces.
- Ensures interactions.
- Validates mod compatibility and functionality.
- Ensures consistent API behavior.

### Mod Content Tests
- Mod-specific validation and compatibility.
- Checks content integrity and balance.
- Supports mod development workflows.
- Checks integrity.
- Supports workflows.

### Performance Tests
- System performance and optimization validation.
- Monitors frame rates, memory, and efficiency.
- Ensures smooth gameplay experience.
- Monitors rates.
- Ensures experience.


