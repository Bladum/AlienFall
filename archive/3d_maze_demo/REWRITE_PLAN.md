# 3D Tactical Combat Game - Complete Rewrite Plan

## Project Overview
A modular, class-based 3D tactical combat game using Love2D 12 and G3D, featuring team-based visibility, physics-based combat, and advanced visual effects.

## Architecture Principles
- **Object-Oriented Design**: Classes for all game entities
- **Separation of Concerns**: Clear boundaries between systems
- **Modular Structure**: Easy to extend with new features
- **2D Logic + 3D Rendering**: Core game logic on 2D grid, rendered in 3D
- **Team-Based Gameplay**: Shared visibility and tactical cooperation

## Directory Structure
```
3d_tactical_game/
├── main.lua                    # Entry point
├── conf.lua                    # Love2D configuration
├── config/
│   ├── constants.lua           # Game constants and settings
│   └── colors.lua              # Team colors and palette
├── classes/
│   ├── Tile.lua               # Tile class (floor/wall/door)
│   ├── Unit.lua               # Base unit class
│   ├── Bullet.lua             # Projectile class
│   ├── Team.lua               # Team management
│   └── TileEffect.lua         # Per-tile effects (smoke, fire)
├── systems/
│   ├── MapLoader.lua          # PNG map loading
│   ├── VisibilitySystem.lua   # Team-based LOS calculation
│   ├── PhysicsSystem.lua      # Box2D integration
│   ├── Renderer3D.lua         # 3D scene rendering
│   ├── Minimap.lua            # 2D minimap display
│   ├── InputManager.lua       # Input handling
│   ├── WeatherSystem.lua      # Global effects
│   └── SelectionSystem.lua    # Mouse picking
├── utils/
│   ├── Math.lua               # Math utilities
│   ├── AssetLoader.lua        # Resource management
│   └── Logger.lua             # Debug logging
├── assets/
│   ├── textures/              # PNG textures
│   ├── maps/                  # Map PNG files
│   └── sprites/               # Unit sprites
└── g3d/                       # G3D library
```

## Implementation Phases

### Phase 1: Foundation (Core Architecture)
**Goal**: Set up project structure and basic classes
- Create directory structure
- Implement Tile class with terrain types
- Implement Team class with color/faction system
- Create Unit base class with position/team
- Set up configuration system

### Phase 2: Map & Data
**Goal**: Load and represent game world
- Implement MapLoader for PNG parsing
- Create 2D grid of Tile objects
- Test map loading with color-to-terrain conversion
- Initialize unit placement on map

### Phase 3: Visibility System
**Goal**: Team-based line-of-sight calculation
- Implement ray-casting for LOS on 2D grid
- Calculate combined team visibility from all units
- Store per-tile visibility state per team
- Handle LOS blocking (walls, smoke effects)
- Implement "sense" range (3 tiles) for detection

### Phase 4: 2D Systems
**Goal**: Minimap and overhead view
- Create Minimap class rendering 2D grid
- Display only visible tiles to current team
- Show units as colored dots by team
- Add fog-of-war for unexplored areas
- Implement minimap camera controls

### Phase 5: 3D Rendering Core
**Goal**: Basic 3D scene with G3D
- Set up Camera class with G3D
- Create Renderer3D for scene management
- Implement frustum culling
- Render floors as single polygons per tile
- Render walls as vertical quads
- Apply team-based lighting (visible/explored/hidden)

### Phase 6: 3D Unit Rendering
**Goal**: Units in 3D space
- Render units as billboards
- Implement facing towards selected unit
- Apply visibility-based lighting
- Ensure depth sorting and culling
- Test unit movement blocking

### Phase 7: Physics System
**Goal**: Box2D integration for projectiles
- Set up Box2D world (2D physics)
- Create physics bodies for static obstacles
- Create kinematic bodies for units
- Prepare bullet physics (fast-moving projectiles)

### Phase 8: Combat System
**Goal**: Bullets and damage
- Implement Bullet class with physics
- Add firing mechanics (trajectory calculation)
- Implement collision detection and damage
- Render bullet tracers in 3D
- Test ballistics and hit detection

### Phase 9: Mouse Interaction
**Goal**: Selection and targeting
- Implement 3D ray-casting for mouse picking
- Select units, floors, walls (not roofs)
- Add hover highlighting
- Implement targeting cursor
- Test click-to-move and click-to-attack

### Phase 10: Tile Effects
**Goal**: Per-tile environmental effects
- Create TileEffect base class
- Implement Smoke effect (blocks LOS, animated)
- Implement Fire effect (damages units, animated)
- Render effects with 3D particles
- Integrate effects with visibility system

### Phase 11: Weather & Atmosphere
**Goal**: Global visual effects
- Enhance snow and rain systems
- Add fog effect (reduces visibility range)
- Add storm effect (lighting flashes)
- Implement dust storms
- Test performance with multiple effects

### Phase 12: Sky Improvements
**Goal**: Better atmosphere
- Lighten night sky (navy instead of black)
- Make day sky more navy blue
- Implement gradient sky rendering
- Add atmospheric scattering effects
- Create smooth day/night transitions

### Phase 13: Input & Controls
**Goal**: Complete player interaction
- Create InputManager for all inputs
- Implement unit selection and commands
- Add team switching (player units)
- Implement camera controls
- Add keyboard shortcuts

### Phase 14: Configuration & Data
**Goal**: Flexible game settings
- Create config system for constants
- Implement save/load for game state
- Add asset loading with caching
- Create data-driven unit definitions
- Test moddability

### Phase 15: Documentation
**Goal**: Complete project documentation
- Document all classes (purpose, API)
- Create architecture diagram
- Write extension guide (new units, effects, terrain)
- Add code comments
- Create README with setup instructions

### Phase 16: Testing & Integration
**Goal**: Verify all systems work together
- Test team visibility with multiple units
- Verify 3D/2D rendering consistency
- Test physics simulation accuracy
- Validate Love2D 12 compatibility
- Check for memory leaks

### Phase 17: Optimization
**Goal**: Performance and polish
- Profile rendering bottlenecks
- Batch draw calls where possible
- Optimize visibility calculations
- Add loading screens for assets
- Polish visual effects timing

### Phase 18: Final Features
**Goal**: Remaining game mechanics
- Implement turn system (if turn-based)
- Add unit abilities
- Create AI for enemy teams
- Add sound effects
- Implement victory/defeat conditions

## Key Technical Decisions

### 1. Team Visibility
- **Shared Vision**: All units in a team share visibility
- **Three States**: Hidden (black), Explored (dim), Visible (bright)
- **Update Frequency**: Recalculate on unit movement or environment change
- **LOS Algorithm**: Bresenham's line algorithm on 2D grid

### 2. Rendering Pipeline
- **2D → 3D**: Game logic on 2D grid, render in 3D
- **Lighting**: Based on visibility state (not physical lighting)
- **Culling**: Frustum + visibility-based culling
- **Billboards**: Units always face camera

### 3. Physics
- **2D Physics Only**: Box2D for projectiles and collisions
- **Position Sync**: Physics bodies sync with logical grid positions
- **Bullets**: Kinematic bodies with ray-cast prediction

### 4. Modularity
- **Class Inheritance**: Unit → PlayerUnit, EnemyUnit, NeutralUnit
- **System Interfaces**: Clear update() and draw() methods
- **Event System**: Consider event-driven architecture for actions
- **Config Files**: Lua tables for unit stats, terrain properties

## Love2D 12 Features to Use
- `love.graphics.readbackTexture()` for canvas operations
- Proper mesh vertex formats with named fields
- Updated depth mode API
- Modern shader syntax
- Efficient batch rendering

## Performance Targets
- 60 FPS with 100+ units
- Sub-100ms visibility calculations
- Minimal garbage collection
- < 200 draw calls per frame

## Testing Strategy
- Unit tests for math utilities
- Integration tests for systems
- Visual tests for rendering
- Performance profiling
- Memory leak detection

## Extensibility Points
- New terrain types via Tile subclasses
- New unit types via Unit subclasses
- New effects via TileEffect subclasses
- New weapons via Bullet subclasses
- Data-driven configuration for easy modding

---

## Implementation Notes
- Start with minimal working version of each phase
- Test thoroughly before moving to next phase
- Keep old version as reference but don't mix code
- Document as you go, not at the end
- Profile early and often

## Next Steps
1. Create directory structure
2. Set up conf.lua for Love2D 12
3. Implement Phase 1: Foundation classes
4. Begin Phase 2: Map loading system

Let's begin! 🚀
