# Battlescape Layer

Tactical turn-based combat layer featuring squad-based gameplay on procedurally generated maps with line-of-sight, cover, and positioning mechanics.

## Overview

The Battlescape layer provides the tactical combat interface where players:
- Command squads of units in turn-based combat
- Navigate procedurally generated maps with terrain hazards
- Use cover and positioning for tactical advantage
- Manage action points and resource consumption
- Engage in both player-controlled and AI-controlled combat
- Complete mission objectives under time pressure

Inspired by X-COM: UFO Defense and XCOM 2 with modern tactical RTS elements.

## Features

### Mission System
- **Mission Types**: UFO crash sites, terror sites, base defense, research outposts
- **Squad Deployment**: 4-8 unit squads with equipment selection
- **Objectives**: Diverse win/loss conditions (eliminate aliens, rescue civilians, secure technology)
- **Time Pressure**: Turn limits and reinforcement waves
- **Dynamic Generation**: Procedurally generated map and enemy placement

### Map System
- **Mapblocks**: 10×10 tile modular building blocks
- **Mapscripts**: Generation rules for mission types and biome variations
- **Biome System**: Urban, rural, desert, arctic, underwater themes
- **Terrain Types**: Grass, concrete, metal, dirt with varied movement costs
- **Elevation**: Height-based positioning affecting line-of-sight and targeting
- **Destructible Environment**: Walls and objects that can be destroyed during combat

### Combat Mechanics
- **Turn Structure**: Individual unit activation with action point economy
- **Action Points (AP)**: Currency for movement, attacks, and item usage
- **Accuracy System**: Hit chance modified by range, cover, stance, and morale
- **Damage & Armor**: Armor protection reduces incoming damage, wound system tracks injuries
- **Suppression**: Enemy fire creates temporary penalties to accuracy and movement
- **Reaction Fire**: Overwatch system for opportunity attacks

### Unit Systems
- **Core Attributes**: Health, morale, experience, fatigue
- **Skills**: Combat abilities that improve with experience
- **Equipment**: Weapons, armor, grenades, and utility items
- **Stance System**: Standing, crouching, prone positions with tactical tradeoffs
- **Status Effects**: Wounds, panic, suppression, burning, stunned

### Cover System
- **Cover Types**: Full cover (blocks LOS), partial cover (damage reduction), no cover
- **Positioning**: Units gain bonuses when in cover vs. exposed
- **Cover Adjacency**: Cover provides benefits to nearby allies
- **Destruction**: Explosions and concentrated fire can destroy cover

### AI Systems
- **Behavior Trees**: Decision-making framework for unit actions
- **Tactical Positioning**: AI seeks cover and uses terrain advantage
- **Group Coordination**: Squad-level tactics and target prioritization
- **Difficulty Scaling**: Rookie, Veteran, Commander, Legend difficulty levels
- **Patrol Routes**: Pre-defined movement patterns for guards and patrols

### Environmental Systems
- **Fire Mechanics**: Fire spreads to adjacent tiles and damages units
- **Smoke**: Reduces visibility and creates movement penalties
- **Lighting**: Day/night cycles and artificial light sources
- **Destruction**: Environmental objects can be destroyed for tactical advantage

## Architecture

```
battlescape/
├── ai/                          # AI decision systems
│   ├── behavior_tree.lua        # Behavior tree implementation
│   ├── pathfinding_ai.lua       # AI movement and pathfinding
│   └── tactics.lua              # Tactical decision making
├── battle/                      # Core battle system
│   ├── battle_manager.lua       # Main battle coordinator
│   ├── turn_manager.lua         # Turn structure and unit activation
│   ├── action_system.lua        # Action validation and execution
│   └── combat_resolver.lua      # Hit/damage resolution
├── battlefield/                 # Battlefield state and entities
│   ├── battlefield.lua          # Main battlefield data structure
│   ├── unit.lua                 # Unit entity definition
│   ├── tile.lua                 # Tile definition with terrain data
│   └── position.lua             # Position and grid utilities
├── combat/                      # Combat calculations
│   ├── accuracy.lua             # Hit chance calculations
│   ├── damage.lua               # Damage calculation
│   ├── los.lua                  # Line-of-sight calculations
│   └── cover.lua                # Cover mechanics
├── effects/                     # Environmental effects
│   ├── fire.lua                 # Fire spread and damage
│   ├── smoke.lua                # Smoke effects
│   └── hazard.lua               # General hazard system
├── entities/                    # Game entity definitions
│   ├── unit.lua                 # Unit entity
│   ├── item.lua                 # Item entity
│   └── obstacle.lua             # Static obstacles
├── logic/                       # Game logic and rules
│   ├── movement.lua             # Movement validation and pathfinding
│   ├── aiming.lua               # Aiming and targeting logic
│   └── status_effects.lua       # Status effect management
├── map/                         # Map system
│   ├── map_manager.lua          # Map state and access
│   ├── tile_manager.lua         # Tile management
│   └── obstacle_manager.lua     # Obstacle tracking
├── maps/                        # Map data and mapblocks
│   ├── mapblock_loader.lua      # Load 10x10 mapblocks
│   └── mapblock_data/           # Mapblock definitions
├── mapscripts/                  # Map generation scripts
│   ├── urban_generation.lua     # Urban mapscript
│   ├── desert_generation.lua    # Desert mapscript
│   └── mission_template.lua     # Mission-specific templates
├── mission_map_generator.lua    # Main map generation
├── rendering/                   # Rendering systems
│   ├── map_renderer.lua         # Map tile rendering
│   ├── entity_renderer.lua      # Unit and entity rendering
│   ├── effect_renderer.lua      # Effect visualization
│   └── ui_renderer.lua          # Battle UI overlay
├── systems/                     # Game systems
│   ├── initiative.lua           # Turn order calculation
│   ├── morale_system.lua        # Morale management
│   └── experience_system.lua    # Experience and leveling
├── ui/                          # Battle UI components
│   ├── hud.lua                  # Main HUD display
│   ├── unit_panel.lua           # Selected unit info
│   ├── weapon_panel.lua         # Weapon/action selection
│   └── mission_status.lua       # Objective and status display
└── utils/                       # Utility functions
    ├── range.lua                # Range and distance calculations
    └── grid.lua                 # Grid-based utilities
```

## Key Systems

### Turn Manager
Orchestrates turn order and unit activation:
- Calculates initiative based on unit stats and status
- Manages action points per unit
- Handles end-of-turn effects and cleanup
- Transitions between unit actions

### Battle Manager
Coordinates overall battle state and progression:
- Loads map and places units
- Manages victory/defeat conditions
- Coordinates AI actions and player actions
- Handles reinforcements and turn limits

### Combat Resolver
Calculates hit/miss and damage:
- Accuracy modifier calculations
- Armor and damage reduction
- Critical hit determination
- Wound and status effect application

### Map Manager
Maintains battlefield state:
- Tile data (terrain, elevation, passability)
- Unit positions and visibility
- Obstacle tracking
- Environmental effects (fire, smoke)

### AI System
Controls non-player units:
- Evaluates tactical positions
- Selects targets and weapons
- Executes movement and attacks
- Reacts to player actions

## Subsystems

### Line-of-Sight (LOS)
- **Visibility Calculation**: Determines what units can see
- **Obstacle Blocking**: Line breaks at walls and solid objects
- **Elevation Factors**: Height affects visibility
- **Caching**: Optimization for repeated checks

### Cover System
- **Cover Types**: Full, partial, and no cover designations
- **Position Evaluation**: Determines cover status for unit positions
- **Damage Reduction**: Partial cover reduces incoming damage
- **Line of Sight**: Full cover blocks shots

### Movement System
- **Pathfinding**: A* algorithm for optimal routes
- **Terrain Cost**: Different terrains consume different AP
- **Obstacle Avoidance**: Routes around static and dynamic obstacles
- **Validation**: Checks for valid movement destinations

### Status Effects
- **Wounds**: Permanent health reduction
- **Panic**: Loss of unit control at low morale
- **Suppression**: Temporary accuracy and movement penalties
- **Burning/Stunned**: Environmental and combat effects

## Configuration

Map generation and mission configuration is handled through TOML files in `mods/core/`:

- `mods/core/mapscripts/` - Map generation templates
- `mods/core/generation/` - Generation parameters
- `mods/core/missions/` - Mission definitions

## Testing

Unit tests for battlescape systems are located in `tests/battlescape/`:

- `test_combat_resolution.lua` - Hit/damage calculations
- `test_movement.lua` - Pathfinding and movement
- `test_los.lua` - Line-of-sight calculations
- `test_map_generation.lua` - Map generation validation

## Performance Considerations

- **LOS Caching**: Line-of-sight calculations are cached per turn
- **Pathfinding**: A* with heuristic optimization
- **Spatial Hash**: Quick collision and proximity checks
- **Lazy Rendering**: Only redraw changed areas

## Integration Points

- **Geoscape**: Mission deployment and crafts
- **Basescape**: Unit equipment and inventory
- **Economy**: Ammo consumption and damage repair
- **UI**: Weapon panels and targeting interface
