# 3D Tactical Combat Game

A modular, class-based 3D tactical combat game built with Love2D 12 and G3D. Features team-based visibility, Box2D physics, and extensible architecture.

## Project Status

**Phase 3 Complete**: Visibility system with ray-casting and fog of war

### Completed
- ✅ Project directory structure
- ✅ Love2D configuration (conf.lua)
- ✅ Constants and configuration system
- ✅ Color definitions and utilities
- ✅ Tile class (floor/wall/door with visibility tracking)
- ✅ Team class (team management and unit organization)
- ✅ Unit base class (position, stats, behavior)
- ✅ Main.lua with full initialization
- ✅ G3D library integration
- ✅ MapLoader system (PNG loading, spawn detection)
- ✅ Test map generation fallback
- ✅ VisibilitySystem (ray-casting, team vision, fog of war)

### In Progress
- 🔄 3D rendering system
- 🔄 Minimap display

### Planned
- ⏳ Box2D physics integration
- ⏳ Bullet system
- ⏳ Mouse interaction
- ⏳ Tile effects (smoke, fire)
- ⏳ Weather effects
- ⏳ Full documentation

## Architecture

### Directory Structure
```
3d_tactical_game/
├── main.lua              # Entry point
├── conf.lua              # Love2D configuration
├── classes/              # Core game classes
│   ├── Tile.lua         # Tile with terrain and visibility
│   ├── Team.lua         # Team/faction management
│   └── Unit.lua         # Base unit class
├── config/               # Configuration files
│   ├── constants.lua    # Game constants
│   └── colors.lua       # Color definitions
├── systems/              # Game systems (to be implemented)
├── utils/                # Utility functions (to be implemented)
└── assets/               # Game assets
    ├── maps/            # PNG map files
    ├── textures/        # Terrain textures
    └── sprites/         # Unit sprites
```

### Key Classes

#### Tile
Represents a single grid tile with:
- Terrain type (floor/wall/door)
- Per-team visibility state
- Occupant tracking
- Tile effects (smoke, fire)

#### Team
Manages a team/faction with:
- Unit collection
- Selected unit tracking
- Team colors and identity
- Alliance/hostility checks

#### Unit
Base class for all units with:
- Position and movement
- Health and stats
- Line of sight and sense range
- Attack capabilities
- Team affiliation

## Configuration

### Constants (config/constants.lua)
- Grid size: 60x60 tiles
- Team definitions (Player/Ally/Enemy/Neutral)
- Terrain types (Floor/Wall/Door)
- Visibility states (Hidden/Explored/Visible)
- Unit stats (LOS range, sense range, etc.)
- Camera settings
- Physics parameters

### Colors (config/colors.lua)
- Team colors (Blue/Green/Red/Gray)
- Terrain map colors for PNG loading
- UI colors (selection, hover, text)
- Effect colors (fire, smoke, explosions)
- Minimap colors

## Controls (Planned)

- **WASD** - Move selected unit
- **SPACE** - Switch to next unit
- **Q/E** - Rotate camera
- **Mouse Click** - Select unit / target position
- **ESC** - Quit

## Requirements

- Love2D 12.0 or higher
- G3D library (included)
- Windows/Mac/Linux

## Running the Game

1. Copy G3D library from old project to `g3d/` folder
2. Run: `love .` or drag folder to love.exe
3. Console window shows initialization progress

## Next Steps (Phase 2)

1. **Copy G3D library** from 3d_maze_demo
2. **Implement MapLoader** to read PNG files
3. **Create 2D grid** of Tile objects from PNG
4. **Test map loading** with existing maze_map.png
5. **Begin visibility system** implementation

## Development Notes

- Using Love2D 12 modern API (no deprecated functions)
- Object-oriented design with clear separation of concerns
- Documentation inline with LuaDoc annotations
- Modular architecture for easy extension
- Performance target: 60 FPS with 100+ units

## License

Open source - same as original 3d_maze_demo project

---

**Last Updated**: Phase 1 Complete - Foundation classes implemented
