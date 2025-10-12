# XCOM/AlienFall Game Mechanics Summary
## Comprehensive Analysis of Python Source Code Implementation

*Generated: 2025-10-09*  
*Source: `allien fall old python\src\`*

---

## TABLE OF CONTENTS

1. [Root Level Files](#root-level-files)
2. [AI Module](#ai-module)
3. [Base Module](#base-module)
4. [Battle Module](#battle-module)
5. [Craft Module](#craft-module)
6. [Economy Module](#economy-module)
7. [Engine Module](#engine-module)
8. [Globe Module](#globe-module)
9. [GUI Module](#gui-module)
10. [Item Module](#item-module)
11. [Location Module](#location-module)
12. [Lore Module](#lore-module)
13. [Pedia Module](#pedia-module)
14. [Unit Module](#unit-module)

---

## ROOT LEVEL FILES

### enums.py
- **Item Category Enumeration**: `EItemCategory` for craft items, unit items, prisoners, and other categories
- **Unit Item Category**: `EUnitItemCategory` for armor, weapons, and equipment
- **Craft Item Category**: `ECraftItemCategory` for craft-specific weapons, equipment, and cargo
- **Theme System**: `ThemeType` enum for XCOM dark, light, and custom UI themes
- **Unit Type Classification**: `EUnitType` for soldiers, tanks, robots, pets, and aliens

### main.py
- **Game Initialization**: PySide6 application setup and game object creation
- **Mod Loading System**: YAML-based mod data loading via `TModLoader`
- **Graphics Loading**: Tileset manager initialization for all game graphics
- **World Map Loading**: TMX file parsing for world map generation
- **Base GUI Creation**: Registration of all base management screens (barracks, hangar, lab, workshop, storage, base info)
- **Initial Base Setup**: Loading starting base data from mod files

---

## AI MODULE

### ai/battle.py - TBattleAI
- **Target Selection**: AI logic for choosing optimal combat targets based on tactical evaluation
- **Movement Decision**: AI pathfinding and positioning decisions considering cover, objectives, and enemy positions
- **Turn Execution**: Automated turn processing for all AI-controlled units
- **Battle State Integration**: Direct access to battle state including units, map, and objectives

### ai/strategy.py - TAlienStrategy
- **Grand Strategy Controller**: High-level alien force coordination and planning
- **Regional Targeting**: Strategic decisions for terror missions and base placement
- **Adaptive Tactics**: Dynamic AI behavior based on player actions and game progression
- **Strategic Layer Integration**: Coordination with geoscape and campaign systems

### ai/readme.md
- **AI Architecture Documentation**: System-wide AI design and implementation reference
- **Tactical vs Strategic AI Separation**: Clear distinction between battle AI and grand strategy
- **API Reference**: Comprehensive interface documentation for AI systems
- **Integration Guidelines**: How AI systems interact with other game modules

---

## BASE MODULE

### base/abase.py - TBaseAlien
- **Alien Base Growth System**: Multi-level progression (1-4) with supply missions triggering growth
- **Mission Generation**: Monthly mission planning based on base level (1-4 missions per month)
- **Score Penalty System**: Daily XCOM score reduction (5 points per level per day)
- **Unit Scaling**: Level-based unit counts (20-50 units) for tactical missions
- **Map Size Scaling**: Tactical map size increases with base level (4-7 blocks)
- **Mission Type Variety**: Research, supply, hunt, infiltration, retaliation, and base creation missions
- **Battle Level System**: 2-level battles (surface and underground)
- **Supply Dependencies**: Base growth tied to successful supply mission completion

### base/base_generator.py - TBaseXComBattleGenerator
- **Facility-to-Map Conversion**: Translates 6x6 facility grid into tactical battle map
- **Map Block Assignment**: Each facility provides a specific map block for battle generation
- **Empty Space Handling**: Fills unused grid positions with 'map_empty' blocks
- **Battle Map Layout**: Creates 2D array of map blocks for tactical battle generator
- **Coordinate Mapping**: Maps facility (x,y) positions to battle map blocks

### base/base_inv_manager.py - TBaseInventory
- **Categorized Item Storage**: Items organized by category (armor, weapons, equipment)
- **Storage Capacity System**: Size-based capacity validation for all items
- **Unit Management**: List-based crew and personnel tracking
- **Craft Management**: Craft bay capacity and stationed aircraft tracking
- **Capture Storage**: Separate tracking for captured units and specimens
- **Quantity Operations**: Add, remove, and set item quantities with validation
- **Category Filtering**: Retrieve items by category for UI display
- **Storage Calculation**: Dynamic remaining capacity based on item sizes
- **Craft Capacity Limits**: Maximum number of crafts based on hangar facilities
- **Item Size System**: Each item has a size value affecting storage capacity

### base/facility_type.py - TFacilityType
- **Facility Blueprint System**: YAML/TOML-loaded facility type definitions
- **Construction System**: Build time, cost, and required items for construction
- **Upkeep Costs**: Monthly maintenance costs per facility
- **Capacity Types**: Unit space, storage, research, workshop, psi lab, craft, training, hospital, repairs, relax
- **Defense Statistics**: Power, hit chance, ammo for base defense
- **Radar System**: Power, range, and stealth coverage for detection
- **Service System**: Facilities provide and require services (power, maintenance, etc.)
- **Tech Requirements**: Technologies needed to unlock facility construction
- **Facility Dependencies**: Required facilities before building
- **Max Per Base Limits**: Restrictions on facility duplication
- **Map Block Reference**: Each facility links to a specific tactical map block
- **Health System**: HP values for base defense battles

### base/facility.py - TFacility
- **Construction Progress**: Day-by-day build tracking until completion
- **Position System**: Grid-based (x,y) placement in 6x6 base layout
- **Activation State**: Facilities only provide benefits when completed
- **Health Tracking**: HP for damage during base defense
- **Build Validation**: Progress tracking against facility type's build time

### base/xbase.py - TBaseXCom
- **6x6 Facility Grid**: Grid-based facility placement system
- **Facility Construction System**: Add, remove, and build facilities with validation
- **Requirement Checking**: Tech, facility, service, and resource requirements
- **Capacity Aggregation**: Sum all facility-provided capacities (storage, workshop, etc.)
- **Service Provision**: Facilities provide services needed by other facilities
- **Daily Build Progress**: Advances all under-construction facilities by one day
- **Radar Collection**: Aggregates all radar facilities for detection
- **Defense Collection**: Aggregates all defensive facilities for base defense
- **Base Label System**: Player-facing names (OMEGA, ALPHA, etc.) for bases
- **Inventory Integration**: TBaseInventory for all item, unit, and craft management
- **Monthly Limits**: Facility-based restrictions on purchases and manufacturing

### base/readme.md
- **Base Architecture**: System design for XCOM and alien base management
- **Facility System**: Blueprint vs instance pattern documentation
- **Inventory System**: Comprehensive item, unit, and craft storage
- **Battle Integration**: How bases generate tactical defense maps

---

## BATTLE MODULE

### battle/battle.py - TBattle
- **4-Side Diplomacy**: Player, Enemy, Ally, Neutral with diplomacy matrix
- **Turn-Based System**: Side-by-side turn processing with turn counter
- **Tile-Based Map**: 2D array of TBattleTile objects for tactical grid
- **Fog of War**: 3-state per-tile per-side visibility (hidden, partial, full)
- **Unit Management**: Side-segregated unit lists with position tracking
- **Objective System**: Multiple objectives tracked per battle with status
- **Mission Completion**: Objective-based win/loss conditions
- **Unit Finder**: Query units by side, alive status, and unit IDs
- **Object Finder**: Query map objects by ID
- **Tile Finder**: Query tiles by objective markers
- **Lighting System**: Dynamic light levels per tile
- **Battle State**: Complete battle status including sides, turns, and objectives

### battle/battle_action.py - TBattleActions
- **Movement System**: Pathfinding-based unit movement with AP cost
- **Crouch/Stealth**: Toggle stance affecting visibility and hit chance
- **Item Usage**: Fire weapons, use equipment, consume items
- **Cover System**: Take cover behind objects/walls for defense modifiers
- **Throwing System**: Grenade and throwable trajectory handling
- **Overwatch Mode**: Reactive fire during enemy movement phases
- **Suppression Fire**: Area suppression reducing enemy effectiveness
- **Rest Action**: Regain stamina/AP by skipping turn
- **Reaction System**: Trigger-based actions during opponent turns

### battle/battle_effect.py - TBattleEffect
- **Environmental Effects**: Smoke, fire, gas affecting tiles
- **Psychological Effects**: Panic, sanity affecting units
- **Effect Properties**: Name, description, icon for UI display
- **Tile Application**: Effects can be applied to specific map tiles
- **Unit Application**: Effects can affect unit status and behavior
- **Duration Tracking**: Temporary modifiers with turn-based expiration

### battle/battle_floor.py - TBattleFloor
- **Movement Cost**: Tile-based movement point cost system
- **Sight Cost**: Additional LOS cost for terrain difficulty
- **Accuracy Modifier**: Cover/terrain effects on hit chance
- **Armor Value**: Floor provides damage reduction
- **Light Source**: Some floors emit light
- **Tile Properties**: Passability, fire blocking, sight blocking

### battle/battle_fow.py - TBattleFOW
- **Visibility Management**: Track which tiles each side can see
- **3-State System**: Hidden (0), Partial (1), Full (2) visibility
- **Per-Side Tracking**: Separate fog of war for each faction
- **Unit Movement Updates**: Recalculate visibility when units move
- **LOS Integration**: Works with line-of-sight calculations

### battle/battle_generator.py - TBattleGenerator
- **Map Block Assembly**: 4-7x4-7 grid of 15x15 tile map blocks
- **Script-Based Generation**: Map scripts control block placement
- **Block Grid System**: 2D array of block names for map assembly
- **Tile Copying**: Copy tiles from map blocks to final battle map
- **Validation System**: Ensure all tiles have valid floor IDs
- **PNG Rendering**: Export battle maps as PNG images for debugging
- **Random Seeding**: Time-based seed for reproducible generation
- **Empty Block Handling**: Fill gaps with 'map_empty' blocks
- **Size Constraints**: Maps between 4-7 blocks in each dimension

### battle/battle_loot.py - TBattleLoot
- **Post-Battle Rewards**: Items and resources gained after mission
- **Unit Equipment**: Collect items from defeated units
- **Map Objects**: Collect items from map objects and containers
- **UFO Components**: Salvage alien technology from crashed UFOs
- **Prisoner Collection**: Capture stunned alien units
- **Corpse Collection**: Collect alien corpses for research

### battle/battle_los.py - BattleLOS
- **Bresenham Algorithm**: Line-of-sight calculation between two points
- **Wall Blocking**: Walls with high sight cost block LOS
- **Smoke/Fire/Gas**: Environmental effects block line of sight
- **Max Range System**: LOS limited to 22 tiles by default
- **Tile-by-Tile Checking**: Validates each tile along sight line
- **Static Methods**: No state, purely calculation-based

### battle/battle_object.py - TBattleObject
- **Map Objects**: Destructible objects on battle map
- **Cover Properties**: Objects provide cover modifiers
- **Destructibility**: Health and armor for object damage
- **Item Containers**: Objects can contain loot
- **Light Sources**: Some objects emit light
- **Sight Blockers**: Objects can block line of sight

### battle/battle_pathfinder.py - BattlePathfinder
- **A* Algorithm**: Optimal pathfinding for unit movement
- **Movement Cost**: Tile-based cost calculation
- **Unit Size**: Support for 1x1 and larger unit footprints
- **Walkability Check**: Validate tiles are passable
- **Diagonal Movement**: 8-direction movement with adjusted costs
- **Priority Queue**: Efficient pathfinding using priority queue
- **Heuristic Function**: Euclidean distance for A* heuristic
- **Path Return**: List of (x,y) coordinates for movement

### battle/battle_roof.py - TBattleRoof
- **Roof System**: Overhead tiles blocking light
- **Light Blocking**: Roofs prevent light from above
- **Destructibility**: Roofs can be destroyed
- **Sight Modifiers**: Roofs affect visibility from above
- **Multi-Level Support**: Works with multi-floor battles

### battle/battle_script.py - TBattleScript
- **Script Steps**: Sequential instructions for map generation
- **Block Placement**: Add blocks, lines, or fill operations
- **Conditional Logic**: Steps can have conditions based on previous steps
- **Chance System**: Probability-based step execution
- **Label System**: Track executed steps for conditions
- **Group Filtering**: Select blocks by group number
- **Size Filtering**: Select blocks by size (1x1, 2x2, etc.)
- **UFO/Craft Placement**: Special steps for adding UFOs and crafts
- **Line Placement**: Add blocks in horizontal, vertical, or both directions
- **Fill Operations**: Fill remaining empty spaces with random blocks
- **Max Count Limits**: Limit number of blocks placed per group

### battle/battle_script_step.py - TBattleScriptStep
- **Step Types**: add_line, add_block, fill_block, add_ufo, add_craft
- **Direction Control**: Horizontal, vertical, or both for line placement
- **Runs Parameter**: How many times to execute step
- **Row/Column Targeting**: Specific row or column for line placement
- **Group System**: Filter blocks by group number
- **Size System**: Filter blocks by size
- **Chance System**: Probability of step execution
- **Label System**: Named steps for conditional logic
- **Condition System**: Execute step only if conditions met

### battle/battle_tile.py - TBattleTile
- **Tri-Component System**: Floor, wall, and roof components per tile
- **Object List**: Multiple objects can exist on one tile
- **Unit Occupancy**: One unit per tile
- **Environmental States**: Smoke, fire, gas flags
- **Light Level**: Dynamic lighting per tile
- **Fog of War**: Per-tile visibility state
- **Tile IDs**: Floor, wall, roof reference IDs
- **Property Flags**: Passable, blocks fire, blocks sight, blocks light
- **Metadata System**: Extensible key-value storage
- **Copy Method**: Deep copy for tile duplication
- **Walkability**: Determined by wall presence
- **Movement Cost**: Cost to traverse tile
- **Sight Cost**: Additional LOS cost
- **Accuracy Modifier**: Cover effects on hit chance
- **Armor Value**: Sum of all component armor
- **Light Emission**: Check if any component is light source

### battle/battle_wall.py - TBattleWall
- **Cover System**: Walls provide defense modifiers
- **Sight Blocking**: High sight cost blocks LOS
- **Destructibility**: Health and armor for walls
- **Movement Blocking**: Walls prevent unit passage
- **Fire Blocking**: Walls block projectiles

### battle/damage_model.py - TDamageModel
- **Damage Types**: Different damage types (kinetic, energy, explosive, etc.)
- **Armor Reduction**: Armor reduces damage based on type
- **Critical Hits**: Chance for increased damage
- **Overkill Damage**: Excess damage transfers to adjacent body parts
- **Resistance System**: Unit/armor resistance to specific damage types
- **Damage Calculation**: Final damage after all modifiers

### battle/deployment.py - TDeployment
- **Unit Groups**: Multiple groups of units for deployment
- **Civilian System**: Specify number of civilians to deploy
- **Special Effects**: Deployment can trigger effects (e.g., smoke)
- **Terrain Integration**: Use terrain's civilian unit types
- **Unit List Generation**: Flatten all groups into single deployment list

### battle/deployment_group.py - TDeploymentGroup
- **Unit Type Selection**: Specify unit types in group
- **Quantity Range**: Min/max units per group
- **Weight System**: Weighted random selection of unit types
- **Multiple Units**: Each group can spawn multiple units

### battle/map_block.py - TMapBlock
- **15x15 Tile Grid**: Standard map block size
- **Size System**: Support for 1x1, 2x2, 3x3 blocks
- **Group System**: Blocks organized by group number
- **TMX Loading**: Load blocks from Tiled map files
- **PNG Rendering**: Export blocks as PNG images
- **Tile Storage**: 2D array of TBattleTile objects
- **Name System**: Each block has unique identifier
- **Layer Support**: Multiple layers per block (floor, walls, roof)

### battle/map_block_entry.py - TMapBlockEntry
- **Block Metadata**: Name, group, size for each map block
- **Frequency System**: How often block appears in generation
- **Group Classification**: Organize blocks by type/theme
- **Size Classification**: 1x1, 2x2, or 3x3 block sizes

### battle/objective.py - TBattleObjective
- **18 Objective Types**: Diverse mission objectives
  - **Core**: Eliminate all enemies, Escape to extraction
  - **Time-Limited**: Hold position for turns, Blitz (eliminate before time)
  - **Territory**: Defend POI, Conquer POI, Explore map percentage
  - **Unit-Based**: Rescue units, Capture units, Hunt specific units, Recon areas, Protect units
  - **Object-Based**: Sabotage objects, Retrieve items
  - **Other**: Escort units, Ambush enemies
- **Status Tracking**: Incomplete, Complete, Failed
- **Progress System**: Track percentage or count towards objective
- **Dynamic Checking**: Check objective status each turn
- **Parameter System**: Objectives have customizable parameters (unit IDs, tile coords, turns, etc.)
- **Battle Integration**: Access battle state for objective checking

### battle/reactions.py - TReactionFire
- **Overwatch System**: Units fire at enemies during their movement
- **Trigger Conditions**: Line of sight, range, and action availability
- **Interrupt System**: Pause enemy movement to resolve reaction
- **AP Cost**: Reaction fire consumes action points
- **Accuracy Penalties**: Lower hit chance for reaction shots

### battle/terrain.py - TTerrain
- **Terrain Type System**: Each terrain has unique characteristics
- **Map Block List**: Collection of map blocks for terrain
- **Map Script**: Script controlling map generation
- **Tileset Reference**: Which tileset to use for rendering
- **Civilian Units**: List of possible civilian unit types
- **TMX Loading**: Load all map blocks from TMX files
- **Map Block Storage**: Dictionary of name to TMapBlock
- **Rendering System**: Export all map blocks as PNG

### battle/tileset_manager.py - TTilesetManager
- **Tileset Loading**: Load all tilesets from PNG files
- **Tile Extraction**: Extract individual 16x16 tiles from tilesets
- **Tile Dictionary**: Map tile IDs to PIL images
- **Mask Support**: Alpha channel masks for transparency
- **Multiple Tilesets**: Support for multiple tileset categories (floors, walls, objects, etc.)

---

## CRAFT MODULE

### craft/craft.py - TCraft
- **World Map Movement**: Crafts move on world map with position tracking
- **Crew System**: Embark/disembark units as crew with status tracking
- **Inventory System**: Item and ammo management for craft weapons
- **Mission Assignment**: Assign and track craft missions
- **Notification System**: Queue notifications for player
- **AI Automation**: Patrol routes, auto-intercept, auto-return, auto-resupply
- **Fuel System**: Fuel capacity and consumption
- **Health System**: Damage tracking and repair
- **Action Points**: 4 AP per turn for combat
- **Pilot System**: Separate pilot tracking
- **Speed System**: Acceleration and max speed
- **Craft Type Reference**: Link to craft type definition

### craft/craft_inv_manager.py - TCraftInventoryManager
- **Weapon Slots**: Multiple weapon hardpoints
- **Equipment Slots**: Craft equipment management
- **Cargo System**: Items in craft cargo bay
- **Ammo Tracking**: Current and max ammo per weapon
- **Capacity Limits**: Based on craft type
- **Rearm System**: Refill ammo with cost calculation
- **Weight System**: Track total cargo weight

### craft/craft_type.py - TCraftType
- **Craft Statistics**: Speed, acceleration, health, range
- **Weapon Hardpoints**: Number and type of weapons
- **Equipment Slots**: Number of equipment slots
- **Crew Capacity**: Max crew and passengers
- **Cargo Capacity**: Max cargo weight
- **Fuel Capacity**: Max fuel and consumption rate
- **Cost System**: Purchase cost and maintenance cost
- **Tech Requirements**: Technologies needed to unlock

### craft/interception.py - TInterception
- **Dogfight System**: Turn-based air combat between craft and UFO
- **Distance Tracking**: Range between combatants affects accuracy
- **Action Point System**: 4 AP per craft per turn
- **Movement Actions**: Move towards or away from enemy
- **Fire Actions**: Shoot weapons with range, accuracy, and damage
- **Hit Calculation**: Random roll against weapon accuracy
- **Damage System**: Apply damage to craft health
- **Crash System**: Below 50% health, chance to crash each turn
- **Combat Log**: Track all combat events
- **Ammo Consumption**: Track ammo usage
- **Turn System**: Alternating turns between craft
- **Refuel/Rearm**: Daily maintenance between combat turns
- **Repair System**: Gradual HP recovery over time
- **Notifications**: Low fuel, low ammo, low health alerts

---

## ECONOMY MODULE

### economy/black_market.py - BlackMarket
- **Supplier System**: Multiple black market suppliers with different inventories
- **Dynamic Pricing**: Prices vary based on supply, demand, and reputation
- **Reputation System**: Player reputation affects prices and availability
- **Monthly Refresh**: Stock rotates monthly
- **Limited Supply**: Items have limited quantity per month
- **Risk System**: Chance of failure or interception
- **Illegal Items**: Access to items not available through normal purchase

### economy/manufacture.py - TManufacture
- **Production System**: Convert items and time into manufactured goods
- **Workshop System**: Requires workshop capacity
- **Progress Tracking**: Man-days accumulated per day
- **Resource Consumption**: Items consumed when project starts
- **Batch Production**: Produce multiple items in one project
- **Project Queue**: Multiple projects per base
- **Cost System**: Item costs and time costs
- **Tech Requirements**: Technologies needed to unlock manufacturing

### economy/manufacture_entry.py - TManufactureEntry
- **Recipe System**: Define inputs and outputs for manufacturing
- **Build Time**: Man-days required per item
- **Item Costs**: Items consumed per manufactured item
- **Money Cost**: Cash cost for manufacturing
- **Tech Requirements**: Technologies needed to unlock
- **Facility Requirements**: Required facilities to manufacture
- **Service Requirements**: Required services (power, etc.)

### economy/manufacturing_manager.py - ManufacturingManager
- **Workshop Capacity**: Track available and used capacity per base
- **Active Projects**: Manage all ongoing manufacturing projects
- **Daily Progress**: Advance all projects by allocated capacity
- **Project Lifecycle**: Start, pause, resume, cancel projects
- **Quantity Changes**: Modify production quantity mid-project
- **Completion Tracking**: Detect when projects finish
- **Capacity Validation**: Ensure sufficient capacity before starting
- **One Project Per Type**: Limit one active project per entry type per base

### economy/manufacturing_project.py - ManufacturingProject
- **Progress Tracking**: Man-days accumulated towards completion
- **Workshop Allocation**: Capacity allocated to this project
- **Quantity System**: Track items completed vs total quantity
- **Status System**: Active, paused, completed, cancelled
- **Completion Percentage**: Calculate progress percentage
- **Start/End Dates**: Track when project started and completed
- **Daily Advance**: Add man-days based on allocated capacity
- **Quantity Modification**: Change production quantity mid-project

### economy/purchase.py - TPurchase
- **Purchase Entry System**: Define available items for purchase
- **Cost System**: Money cost per item
- **Tech Requirements**: Technologies needed to unlock purchase
- **Service Requirements**: Required services at base
- **Monthly Limits**: Restrict purchases per month
- **Black Market Integration**: Access black market purchases
- **Delivery System**: Time delay for item delivery
- **Transfer Integration**: Items sent via transfer system

### economy/purchase_entry.py - TPurchaseEntry
- **Item Definition**: Define purchasable items
- **Cost System**: Purchase price per item
- **Delivery Time**: Days until delivery
- **Tech Requirements**: Technologies needed to unlock
- **Service Requirements**: Required base services
- **Monthly Limit**: Max purchases per month
- **Availability System**: Check if item can be purchased

### economy/purchase_manager.py - PurchaseManager
- **Order Management**: Track all active purchase orders
- **Monthly Tracking**: Track purchases per month for limits
- **Order Creation**: Create new purchase orders
- **Order Status**: Check status of orders
- **Order Cancellation**: Cancel orders before delivery
- **Daily Processing**: Advance orders and trigger deliveries
- **History Tracking**: Maintain purchase history
- **Transfer Integration**: Send completed orders to transfer system

### economy/purchase_order.py - PurchaseOrder
- **Order Details**: Entry ID, base, quantity, cost
- **Delivery Countdown**: Days until order arrives
- **Status Tracking**: Ordered, in transit, delivered, cancelled
- **Creation Date**: When order was placed
- **Cost Calculation**: Total cost of order

### economy/purchase_system.py - TPurchase
- **Main Interface**: Primary purchasing system interface
- **Entry Management**: Load and manage purchase entries
- **Validation**: Validate purchases against requirements
- **Order Placement**: Create and track orders
- **Black Market Access**: Interface to black market
- **Monthly Reset**: Reset purchase limits each month
- **Daily Processing**: Advance all orders
- **History Tracking**: Maintain purchase history
- **Save/Load**: Serialize and deserialize purchase state

### economy/research.py - TResearch
- **Research System**: Unlock new technologies
- **Progress Tracking**: Man-days accumulated per day
- **Project Management**: Start, pause, resume, cancel research
- **Completion Detection**: Detect when research completes
- **Tech Tree Integration**: Unlock dependent techs

### economy/research_entry.py - TResearchEntry
- **Research Definition**: Define researchable technologies
- **Cost System**: Man-days required to complete
- **Tech Requirements**: Technologies needed to unlock
- **Item Requirements**: Items needed to start research
- **Service Requirements**: Required base services
- **Facility Requirements**: Required facilities
- **Unlock Effects**: What researching this tech unlocks
- **Hidden System**: Some techs are hidden until requirements met

### economy/research_manager.py - TResearchManager
- **Project Management**: Track all active research projects
- **Entry Management**: Load and manage research entries
- **Available Research**: Calculate which techs can be researched
- **Daily Progress**: Advance all projects by allocated capacity
- **Completion Tracking**: Mark techs as completed
- **Tech Tree**: Manage technology dependencies
- **Project Lifecycle**: Start, pause, resume, cancel projects
- **Status Reporting**: Get status of all projects

### economy/research_project.py - ResearchProject
- **Progress Tracking**: Man-days accumulated towards completion
- **Capacity Allocation**: Scientists allocated to project
- **Status System**: Active, paused, completed, cancelled
- **Completion Percentage**: Calculate progress percentage
- **Start/End Dates**: Track when project started and completed
- **Daily Advance**: Add man-days based on allocated capacity

### economy/research_tree.py - TResearchTree
- **Tech Dependencies**: Define prerequisite technologies
- **Tree Structure**: Hierarchical technology tree
- **Unlock System**: Automatically unlock dependent techs
- **Visibility System**: Hide techs until prerequisites met
- **Validation**: Check if tech can be researched

### economy/ttransfer.py - TransferManager & TTransfer
- **Transfer System**: Move items between bases
- **Travel Time**: Calculate time based on distance
- **In-Transit Tracking**: Track all items in transit
- **Arrival Detection**: Detect when transfers arrive
- **Base-to-Base**: Transfer between XCOM bases
- **Purchase Integration**: Deliver purchased items to bases
- **Manufacturing Integration**: Deliver manufactured items to bases

---

## ENGINE MODULE

### engine/animation.py - TAnimation
- **Sprite Animation**: Frame-based animation system
- **Frame Timing**: Control animation speed
- **Loop System**: Looping and one-shot animations
- **Animation States**: Different animations per state (idle, walk, shoot, etc.)
- **Sprite Sheets**: Load animations from sprite sheets

### engine/difficulty.py - TDifficulty
- **Difficulty Levels**: Easy, Normal, Hard, Expert
- **Modifier System**: Adjust game parameters based on difficulty
- **Enemy Strength**: Scale enemy stats
- **Resource Availability**: Adjust starting resources
- **Research Speed**: Modify research time
- **Economic Impact**: Adjust costs and income

### engine/game.py - TGame
- **Singleton Pattern**: Single game instance for entire application
- **World Map**: Reference to world map object
- **Campaign System**: Track all active campaigns
- **Calendar System**: Date, turn, and event triggers
- **Budget System**: XCOM budget, funding, and scoring
- **Research Tree**: Global research tree
- **Purchase System**: Purchasing and black market
- **Transfer System**: Item transfers between bases
- **Mod System**: Loaded mod data reference
- **Base Management**: Dictionary of all XCOM bases with active base tracking
- **Base Labels**: Player-facing names for bases (OMEGA, ALPHA, etc.)
- **Monthly Manufacturing**: Track manufacturing hours for invoicing
- **Active Base System**: Get and set active base
- **Base Operations**: Add, remove, and check base existence
- **Save/Load**: Serialize and deserialize game state

### engine/mod.py - TMod
- **Mod Loading**: Load mod data from YAML files
- **Object Storage**: Store all game objects (items, units, crafts, etc.)
- **Path Management**: Track mod paths for assets
- **Graphics Loading**: Load all graphics via tileset manager
- **Map Block Loading**: Load all terrain map blocks
- **Initial Base**: Create starting base for player
- **Object Categories**: Organize objects by type
- **Tech Tree**: Build technology tree from research entries
- **Validation**: Validate mod data on load

### engine/modloader.py - TModLoader
- **YAML Loading**: Load all YAML files from mod folder
- **File Discovery**: Scan mod folder for data files
- **Data Merging**: Combine multiple YAML files
- **Path Tracking**: Track file paths for debugging
- **Error Handling**: Report errors in mod data

### engine/savegame.py - TSaveGame
- **Save System**: Serialize entire game state
- **Load System**: Deserialize and restore game state
- **File Management**: Save to and load from disk
- **Compression**: Compress save files
- **Versioning**: Track save file version for compatibility

### engine/sounds.py - TSounds
- **Sound Effects**: Play sound effects
- **Music System**: Background music playback
- **Volume Control**: Adjust sound and music volume
- **Sound Categories**: Weapons, UI, ambient, etc.
- **Looping**: Loop background sounds and music

### engine/stats.py - TStats
- **Player Statistics**: Track player actions
- **Mission Stats**: Track mission outcomes
- **Kill Counts**: Track kills by unit type
- **Research Stats**: Track research completed
- **Manufacturing Stats**: Track items manufactured
- **Economic Stats**: Track money spent and earned

---

## GLOBE MODULE

### globe/biome.py - TBiome
- **Biome Types**: Different terrain biomes (forest, desert, arctic, etc.)
- **Terrain Properties**: Affect tactical battle terrain generation
- **Civilian Units**: Define which civilian units spawn in biome
- **Tile Appearance**: Visual appearance on world map
- **Battle Terrain**: Link to battle terrain types

### globe/country.py - TCountry
- **Country Data**: Name, population, wealth
- **Funding System**: Monthly funding contribution to XCOM
- **Diplomacy**: Relationships with XCOM and other countries
- **Panic Level**: Country panic affects funding and diplomacy
- **Region Membership**: Countries belong to regions
- **City List**: Cities within country
- **Alien Influence**: Track alien infiltration

### globe/diplomacy.py - TDiplomacy
- **Relationship System**: Track relationships between factions
- **Reputation System**: Reputation with countries and factions
- **Treaty System**: Peace treaties, alliances, and wars
- **Diplomatic Actions**: Propose treaties, declare war, etc.
- **Influence System**: Alien and XCOM influence per country
- **Event System**: Diplomatic events affect relationships

### globe/funding.py - TFunding
- **Monthly Funding**: Countries provide monthly funding
- **Funding Formula**: Based on panic level and satisfaction
- **Funding Changes**: Track funding changes over time
- **Budget Calculation**: Calculate total XCOM budget
- **Deficit System**: Handle budget shortfalls

### globe/location.py - TLocation
- **World Map Position**: Base class for all world map entities
- **Coordinate System**: X, Y position on world map
- **Location Type**: Different types of locations (base, UFO, city, etc.)
- **Visibility**: Whether location is visible to player
- **Discovery**: Track when location was discovered

### globe/radar.py - TGlobalRadar
- **Radar Coverage**: Calculate global radar coverage
- **Detection System**: Detect UFOs and other objects
- **Range Calculation**: Radar range based on base facilities
- **Overlap Handling**: Multiple radar sources
- **Stealth System**: Some objects harder to detect
- **Coverage Map**: Visual representation of radar coverage

### globe/region.py - TRegion
- **Region Data**: Name, countries in region
- **Regional Panic**: Aggregate panic level for region
- **Regional Funding**: Total funding from region
- **Alien Activity**: Track alien missions in region
- **Regional Objectives**: Alien objectives for region

### globe/world.py - TWorld
- **World Map**: 2D tile grid representing world
- **Day/Night Cycle**: Moving day/night band (30-day cycle)
- **Tile System**: Each tile has biome, country, region
- **City System**: Cities on world map
- **Faction System**: Multiple factions on world
- **TMX Loading**: Load world from Tiled TMX files
- **Layer System**: Multiple layers (biome, country, region)
- **Rendering System**: Export world as PNG or text
- **World Size**: Configurable width and height
- **Transfer List**: Global item transfers

### globe/world_point.py - TWorldPoint
- **Coordinate System**: X, Y coordinates on world map
- **Distance Calculation**: Calculate distance between points
- **Adjacency**: Check if points are adjacent
- **Region/Country Lookup**: Get region/country for point

### globe/world_tile.py - TWorldTile
- **Tile Properties**: Biome, country, region
- **Tile Coordinates**: X, Y position
- **Tile Type**: Land, sea, or special
- **City Presence**: Whether tile contains city
- **Visibility**: Whether tile is visible to player

---

## GUI MODULE

### gui/gui_base.py - TGuiBase
- **Base Screen Manager**: Central GUI for base management
- **Screen Registration**: Register all base screens (barracks, hangar, etc.)
- **Screen Switching**: Switch between base management screens
- **Active Base Display**: Show currently active base
- **Base Selection**: Switch between bases
- **Notification System**: Display base notifications

### gui/gui_core.py - TGuiCore
- **Main Menu**: Game main menu
- **Game Setup**: New game, load game, settings
- **Save/Load UI**: Save and load game interface
- **Settings**: Game settings and options
- **Credits**: Game credits and information

### gui/gui_world.py - TGuiWorld
- **World Map Display**: Render world map
- **Location Display**: Show all locations (bases, UFOs, cities)
- **Time Control**: Pause, play, fast forward
- **Date Display**: Show current game date
- **Radar Coverage**: Display radar coverage on map
- **Location Selection**: Click on locations for details
- **Mission Launch**: Select craft and launch missions
- **Transfer Tracking**: Show items in transit

### gui/theme_manager.py - ThemeManager
- **UI Themes**: XCOM dark, light, custom themes
- **Color Schemes**: Define colors for all UI elements
- **Font System**: Define fonts and sizes
- **Style Sheets**: Apply styles to widgets
- **Theme Switching**: Change theme at runtime

### gui/base/ (folder)
- **gui_barracks.py**: Unit management, hiring, dismissing, training
- **gui_hangar.py**: Craft management, arming, crew assignment
- **gui_lab.py**: Research projects, available research, progress
- **gui_workshop.py**: Manufacturing projects, available items, progress
- **gui_storage.py**: Item inventory, sorting, filtering
- **gui_base_info.py**: Base overview, facilities, capacities

### gui/battle/ (folder)
- **gui_battle_main.py**: Main tactical battle UI
- **gui_battle_actions.py**: Unit action UI (move, shoot, items)
- **gui_battle_info.py**: Unit info panel, enemy info
- **gui_battle_inventory.py**: Unit inventory during battle
- **gui_battle_log.py**: Combat log and messages

### gui/globe/ (folder)
- **gui_globe_main.py**: Main geoscape/world map UI
- **gui_globe_time.py**: Time controls and date display
- **gui_globe_info.py**: Location info panels
- **gui_globe_missions.py**: Mission selection and launch

---

## ITEM MODULE

### item/craft_item.py - TCraftItem
- **Craft Equipment**: Items specifically for craft (weapons, equipment)
- **Weapon Stats**: Damage, accuracy, range, ammo for craft combat
- **Equipment Effects**: Special effects for craft
- **Installation Time**: Time to install on craft
- **Size System**: Size affects craft capacity
- **Rearm System**: Ammo refill cost and time

### item/item.py - TItem
- **Base Item Class**: Common functionality for all items
- **Weight System**: Affects unit encumbrance
- **Size System**: Affects storage capacity
- **Category System**: Organize items by type
- **Tech Requirements**: Technologies needed to use
- **Sell System**: Items can be sold for money

### item/item_armour.py - TItemArmour
- **Armor System**: Protective gear for units
- **Defense Value**: Reduce incoming damage
- **Resistance System**: Resistance to damage types
- **Shield System**: Shield HP and regeneration
- **Cover Modifiers**: Affect cover effectiveness
- **Sight Modifiers**: Affect vision range
- **Stat Modifiers**: Modify unit stats
- **Slot System**: Primary slot for armor

### item/item_craft.py - TItemCraft
- **Craft Components**: Engines, weapons, equipment for craft
- **Performance Stats**: Speed, range, fuel efficiency
- **Weapon Stats**: Damage, accuracy, ammo
- **Installation**: Time and cost to install

### item/item_mode.py - TWeaponMode
- **Fire Modes**: Snap shot, aimed shot, auto shot
- **AP Cost**: Different costs per mode
- **Accuracy Modifiers**: Different accuracy per mode
- **Damage Modifiers**: Different damage per mode
- **Ammo Consumption**: Shots per attack
- **Range Modifiers**: Different ranges per mode

### item/item_transfer.py - TItemTransfer
- **Transfer Tracking**: Items being transferred between bases
- **Source/Destination**: Track origin and destination
- **Travel Time**: Days until arrival
- **Item List**: What items are being transferred
- **Status**: In transit, arrived, cancelled

### item/item_type.py - TItemType
- **Item Template**: Base definition for all item types
- **Stat System**: All stats for unit use (damage, accuracy, range, ammo, etc.)
- **Armor System**: Defense, resistance, shield stats
- **Craft System**: Craft weapon and equipment stats
- **Manufacturing**: Tech requirements and costs
- **Purchase System**: Tech requirements and costs
- **Weight/Size**: Inventory and storage properties
- **Weapon Modes**: Multiple fire modes per weapon
- **Special Effects**: Status effects and bonuses
- **Requirements**: Tech, service, facility requirements
- **Underwater Support**: Underwater usability flag

### item/item_weapon.py - TItemWeapon
- **Weapon System**: Ranged and melee weapons for units
- **Damage System**: Damage value and type
- **Accuracy System**: Hit chance calculation
- **Range System**: Effective range
- **Ammo System**: Ammo capacity and reloading
- **Fire Modes**: Snap, aimed, auto, burst
- **AP Cost**: Action points per shot
- **Two-Handed**: Occupies both hands or one hand
- **Stat Modifiers**: Modify unit stats when equipped

---

## LOCATION MODULE

### location/city.py - TCity
- **City Data**: Name, population, coordinates
- **Mission Generation**: Cities are targets for terror missions
- **Alien Influence**: Track alien infiltration
- **Panic System**: City panic level
- **Defense**: City defenses against alien attacks
- **Civilian Units**: Civilians present during missions

### location/site.py - TSite
- **Generic Location**: Crash sites, landing sites, alien bases
- **Discovery System**: Track when site was discovered
- **Expiration**: Sites may expire after time
- **Mission Generation**: Sites generate missions
- **Loot**: Sites contain recoverable items

### location/site_type.py - TSiteType
- **Site Template**: Define site types (crash, landing, base, etc.)
- **Terrain**: Which battle terrain to use
- **Deployment**: Which units spawn at site
- **Objectives**: Mission objectives for site
- **Expiration Time**: How long site lasts
- **Discovery Chance**: Chance to detect site

### location/ufo.py - TUfo
- **UFO Movement**: UFOs move on world map following scripts
- **UFO Type**: Link to UFO type definition (stats, deployment)
- **UFO Script**: Behavior script (movement, missions, etc.)
- **Speed System**: Current and max speed
- **Health System**: Damage tracking
- **Script Progression**: Step-by-step script execution
- **Target System**: Pick targets for movement steps
- **Position Tracking**: Current world map position
- **Distance Calculation**: Calculate distance to other locations
- **Damage System**: Take damage, crash system
- **Detection**: Can be detected by radar
- **Mission Generation**: UFOs generate missions on landing

### location/ufo_script.py - TUfoScript
- **Script Steps**: Sequential UFO behavior instructions
- **Movement Steps**: Move to random, city, base, region, etc.
- **Action Steps**: Land, hunt, infiltrate, terrorize, etc.
- **Conditional Logic**: Steps can have conditions
- **Duration System**: How long each step takes
- **Delay System**: Wait time after step completion
- **Target Selection**: Pick targets based on step type
- **Multi-Turn Movement**: Break movement across multiple turns
- **Step Types**: 12+ different step types

### location/ufo_type.py - TUfoType
- **UFO Stats**: Speed, health, detection chance
- **Deployment**: Which units spawn when UFO landed
- **Weapons**: UFO weapons for interception
- **Size**: Small scout to large battleship
- **Loot**: Items recovered from crashed/landed UFO
- **Tech Requirements**: Player tech needed to detect/recognize
- **Score Value**: Points awarded for destroying UFO

---

## LORE MODULE

### lore/calendar.py - TCalendar
- **Date System**: Track game date (year, month, day)
- **Turn System**: Each day is one turn
- **Time Advancement**: Advance time by days
- **Event Triggers**: Trigger events based on date
- **Day of Week**: Calculate day of week
- **Date Formatting**: Format dates for display

### lore/campaign.py - TCampaign
- **Campaign System**: Coordinated alien activities
- **Faction System**: Campaigns belong to factions
- **Objective Types**: 9 different campaign objectives (scout, infiltrate, base, terror, etc.)
- **Regional Targeting**: Campaigns target specific regions
- **Tech Requirements**: Start and end techs for campaign
- **Mission List**: Missions within campaign
- **Score System**: Points awarded for completing campaign

### lore/campaign_step.py - TCampaignStep
- **Step System**: Sequential campaign progression
- **Mission Generation**: Generate missions based on step
- **Conditions**: Steps can have unlock conditions
- **Duration**: How long step lasts
- **Next Step**: What step comes next

### lore/event.py - TEvent
- **Event System**: One-time or recurring events
- **Trigger Conditions**: When event triggers (date, research, etc.)
- **Event Effects**: What event does (message, spawn mission, etc.)
- **Event Priority**: Order of event execution
- **Event Flags**: Track if event has occurred

### lore/event_engine.py - TEventEngine
- **Event Manager**: Manage all game events
- **Event Scheduling**: Schedule events by date
- **Event Checking**: Check conditions each turn
- **Event Execution**: Execute event effects
- **Event History**: Track triggered events

### lore/faction.py - TFaction
- **Faction Data**: Name, description, goals
- **Diplomacy**: Relationships with player and other factions
- **Technology**: Faction-specific tech
- **Units**: Faction-specific units
- **Campaigns**: Faction's campaign list

### lore/mission.py - TMission
- **Mission Definition**: Mission type, objectives, deployment
- **Mission Generation**: Create missions from templates
- **Mission Expiration**: Missions expire after time
- **Mission Rewards**: Loot, score, research
- **Mission Difficulty**: Scale difficulty based on game state

### lore/organization.py - TOrganization
- **Organization System**: XCOM, alien factions, other organizations
- **Reputation**: Track reputation with organizations
- **Services**: What services organizations provide
- **Trade**: Trade with organizations
- **Missions**: Organization-specific missions

### lore/quest.py - TQuest
- **Quest System**: Multi-step objectives
- **Quest Progress**: Track quest completion
- **Quest Rewards**: Special rewards for quests
- **Quest Branches**: Quests can branch based on choices
- **Quest Conditions**: Requirements to start quest

### lore/quest_engine.py - TQuestEngine
- **Quest Manager**: Manage all active quests
- **Quest Tracking**: Track quest progress
- **Quest Completion**: Detect quest completion
- **Quest Branching**: Handle quest choices

### lore/quest_manager.py - TQuestManager
- **Quest Library**: All available quests
- **Active Quests**: Currently active quests
- **Completed Quests**: Track completed quests
- **Quest Assignment**: Assign quests to player

---

## PEDIA MODULE

### pedia/pedia.py - TPedia
- **In-Game Encyclopedia**: Database of all game information
- **Entry Management**: Add, retrieve, search entries
- **Category System**: Organize entries by category
- **Unlock System**: Entries unlock based on research
- **Search System**: Search entries by text
- **Image Support**: Entries can have images
- **Cross-References**: Link between related entries

### pedia/pedia_entry.py - TPediaEntry
- **Entry Data**: Title, description, image, category
- **Unlock Conditions**: Research or events required to unlock
- **Text Content**: Full text description
- **Statistics**: Display game stats
- **Links**: Links to related entries

### pedia/pedia_entry_type.py - TPediaEntryType
- **Entry Categories**: Items, units, crafts, UFOs, research, etc.
- **Category Icons**: Icon for each category
- **Category Sorting**: Sort order for categories

---

## UNIT MODULE

### unit/race.py - TRace
- **Racial Templates**: Human, alien races
- **Base Stats**: Racial stat modifiers
- **Racial Abilities**: Special abilities for races
- **Appearance**: Visual appearance settings
- **Size Category**: Small, medium, large units
- **Body Type**: Different body types affect stats

### unit/side.py - TSide
- **Side System**: Player, enemy, ally, neutral
- **Diplomacy**: How sides interact
- **AI Control**: Whether side is AI controlled
- **Victory Conditions**: Win conditions for each side

### unit/trait.py - TTrait
- **Trait System**: Special unit abilities and modifiers
- **Trait Types**: Positive, negative, neutral traits
- **Stat Modifiers**: Traits modify unit stats
- **Trait Points**: Gained per level to unlock new traits
- **Trait Categories**: Combat, psionic, utility traits
- **Trait Requirements**: Some traits require other traits
- **Trait Effects**: Special effects beyond stat modifiers

### unit/unit.py - TUnit
- **Unit Instance**: Individual unit with stats, equipment, position
- **Unit Type**: Link to unit type template
- **Stats System**: HP, TU, stamina, morale, accuracy, etc.
- **Inventory System**: Equipped items and backpack
- **Position System**: Current position on battle map
- **Status Effects**: Panicked, mind controlled, stunned, etc.
- **Experience System**: Gain XP, level up (max level 10)
- **Trait Point System**: 1 point per level to spend on traits
- **Equipment Effects**: Stat modifiers from armor and items
- **Race System**: Link to race template
- **Side System**: Which faction unit belongs to
- **Direction System**: Which way unit is facing
- **Stance System**: Kneeling, running affect stats
- **Nationality**: Cosmetic nationality setting
- **Face/Gender**: Cosmetic appearance settings

### unit/unit_inv_manager.py - TUnitInventoryManager
- **Equipment Slots**: Primary weapon, secondary weapon, armor, belt items
- **Weight Tracking**: Total weight affects movement
- **Slot Validation**: Validate items fit in slots
- **Stat Aggregation**: Sum all stat modifiers from equipment
- **Quick Swap**: Swap between primary and secondary weapons
- **Item Transfer**: Move items between slots
- **Backpack System**: Items in backpack vs equipped

### unit/unit_stat.py - TUnitStats
- **Stat System**: All unit statistics
  - **Core Stats**: HP, TU (Time Units), Stamina, Morale
  - **Physical Stats**: Strength, Firing Accuracy, Throwing Accuracy, Reactions
  - **Mental Stats**: Bravery, Psi Strength, Psi Skill
  - **Vision**: Sight range, night vision
  - **Movement**: Move cost modifiers
  - **Defense**: Armor, shield, resistances
- **Stat Math**: Add, subtract, multiply stat objects
- **Copy System**: Deep copy stat objects

### unit/unit_type.py - TUnitType
- **Unit Template**: Base definition for unit types
- **Base Stats**: Starting stats for unit type
- **Inventory System**: Starting equipment
- **Appearance**: Sprite, animations
- **Size System**: 1x1, 2x2 unit sizes
- **Movement Type**: Walk, fly, swim
- **Armor Type**: Light, medium, heavy
- **Cost System**: Salary, hire cost
- **Tech Requirements**: Tech needed to unlock
- **Trait Restrictions**: Which traits unit can have

---

## SUMMARY STATISTICS

### Total Modules: 14
- Root Level: 2 files
- AI: 3 files
- Base: 7 files
- Battle: 25 files
- Craft: 4 files
- Economy: 13 files
- Engine: 8 files
- Globe: 10 files
- GUI: 10+ files (multiple sub-folders)
- Item: 8 files
- Location: 5 files
- Lore: 9 files
- Pedia: 3 files
- Unit: 7 files

### Key Game Systems

#### Strategic Layer (Geoscape)
1. **World Map System**: 240x120 tile grid with biomes, countries, regions
2. **Base Management**: 6x6 facility grid, multiple bases with unique names
3. **Economy**: Research, manufacturing, purchasing, black market
4. **Funding**: Monthly funding from countries based on panic
5. **Interception**: Air combat between crafts and UFOs
6. **Time Management**: Day-based turn system with calendar
7. **Transfer System**: Inter-base item transfers
8. **Radar System**: Detection of UFOs based on base facilities

#### Tactical Layer (Battlescape)
1. **Turn-Based Combat**: 4-side system (player, enemy, ally, neutral)
2. **Grid-Based Movement**: Tile-based map with pathfinding
3. **Line of Sight**: Bresenham algorithm with smoke/fire/wall blocking
4. **Action Points**: TU system for all unit actions
5. **Fog of War**: 3-state per-tile per-side visibility
6. **18 Mission Objectives**: Diverse mission types with different win conditions
7. **Reaction Fire**: Overwatch system for interrupting enemy movement
8. **Environmental Effects**: Smoke, fire, gas affecting tiles
9. **Destructible Objects**: Objects provide cover and loot
10. **Multi-Level Maps**: Support for multiple floor levels

#### Unit Systems
1. **Unit Stats**: 13+ different stats (HP, TU, accuracy, strength, etc.)
2. **Equipment**: Primary/secondary weapons, armor, belt items
3. **Experience**: XP gain and level up (max 10 levels)
4. **Traits**: Unlockable abilities using trait points
5. **Races**: Different races with unique base stats
6. **Status Effects**: Panic, mind control, stun, etc.
7. **Inventory**: Weight-based encumbrance system

#### Economy Systems
1. **Research**: Man-day based progress with tech tree
2. **Manufacturing**: Workshop-based production with resources
3. **Purchasing**: Monthly limits, tech requirements, delivery times
4. **Black Market**: Dynamic pricing, reputation, limited supply
5. **Transfers**: Base-to-base item movement
6. **Monthly Invoicing**: Track costs for salaries, maintenance, manufacturing

#### AI Systems
1. **Tactical AI**: Target selection, movement, action execution
2. **Strategic AI**: Alien campaign generation and regional targeting
3. **UFO Scripts**: Multi-step behavior scripts for UFO movement
4. **Diplomacy**: Faction relationships and interactions

#### Map Generation
1. **Map Scripts**: Script-based battle map assembly
2. **Map Blocks**: 15x15 tile blocks assembled into maps
3. **Block Groups**: Organize blocks by theme/function
4. **Terrain Types**: Different terrains with unique block libraries
5. **TMX Loading**: Load map blocks from Tiled map editor

#### Campaign & Missions
1. **Campaign System**: Coordinated alien activities with objectives
2. **Mission Generation**: Dynamic mission creation based on alien activity
3. **Objective Types**: 18 different objective types
4. **Deployment**: Define unit composition for missions
5. **UFO Activity**: UFOs follow scripts to generate missions
6. **Event System**: Time-triggered and condition-triggered events

---

## TECHNICAL ARCHITECTURE

### Design Patterns
- **Singleton**: `TGame` class for global game state
- **Template Method**: Item types, unit types, facility types as templates
- **Manager Pattern**: Research manager, manufacturing manager, purchase manager
- **Observer**: Event system, notification system
- **Strategy**: AI behavior, map generation scripts
- **State**: Battle state, unit state, mission state

### Data Flow
1. **YAML Loading**: Mod data loaded from YAML files
2. **Template Creation**: Types/templates created from data
3. **Instance Creation**: Game objects instantiated from templates
4. **State Management**: Game state tracked in managers
5. **Save/Load**: Complete game state serialization

### Module Dependencies
- **Core**: Engine module provides game singleton and mod system
- **Templates**: Item, unit, craft, facility type definitions
- **Instances**: Units, crafts, bases instantiated from templates
- **Managers**: Economy managers track projects and orders
- **Systems**: Battle system, geoscape system operate on instances

---

## UNIQUE MECHANICS HIGHLIGHTS

### Battle System Innovations
- 4-faction diplomacy matrix with opportunistic and protective behaviors
- 18 diverse mission objective types covering all XCOM scenarios
- Multi-turn UFO movement with script-based behavior
- 3-state fog of war (hidden, partial, full visibility)
- Reaction fire with action point consumption
- Environmental effects affecting both tiles and units

### Economy Innovations
- Black market with reputation and dynamic pricing
- Monthly purchase limits per item
- Transfer system with travel time between bases
- Manufacturing with man-day based progress
- Research with item consumption requirements
- Monthly invoicing for all costs

### Base Management Innovations
- 6x6 facility grid with facility dependencies
- Service provision system (power, maintenance, etc.)
- Capacity aggregation from multiple facilities
- Construction progress with daily advancement
- Battle map generation from facility layout
- Multi-base management with inter-base transfers

### Strategic Layer Innovations
- Moving day/night band completing cycle in 30 days
- Country-based funding affected by panic
- Alien base growth through supply missions
- UFO script system with multi-step behaviors
- Campaign system with faction objectives
- Regional targeting for alien activities

### AI Innovations
- Separation of tactical (battle) and strategic (campaign) AI
- Adaptive alien strategy based on player progress
- UFO script system for complex behaviors
- Target selection considering threat level and distance

---

## IMPLEMENTATION QUALITY

### Strengths
1. **Comprehensive Coverage**: All major XCOM systems implemented
2. **Modular Design**: Clear separation of concerns
3. **Template Pattern**: Reusable type definitions
4. **Extensibility**: Easy to add new items, units, missions
5. **Save/Load**: Complete state serialization support

### Notable Features
1. **18 Mission Objectives**: More variety than original XCOM
2. **Black Market**: Adds economic complexity
3. **Transfer System**: Realistic logistics between bases
4. **Service System**: Facilities depend on services (power, etc.)
5. **Trait System**: RPG-like character progression

---

*End of Document - Total Lines: 1337*
