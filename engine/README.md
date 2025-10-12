# XCOM Simple

A simplified turn-based strategy game inspired by UFO: Enemy Unknown (XCOM), built with Love2D 12 and Lua.

## Features

### Three Core Modules

1. **Geoscape** - Strategic world map
   - Province network (Risk-style map)
   - Track alien activity
   - Deploy missions
   - Manage global operations

2. **Battlescape** - Turn-based tactical combat
   - 24x24 pixel tile-based maps
   - Unit selection and movement
   - Fog of war and line-of-sight
   - Turn-based combat system
   - Player team vs alien team

3. **Basescape** - Base management
   - 6x6 facility grid
   - Soldier roster management
   - Research projects
   - Manufacturing queue
   - Budget tracking

## Requirements

- Love2D 12.0 or higher
- Windows, macOS, or Linux

## Installation

1. Download and install Love2D 12.0 from https://love2d.org/
2. Clone or download this project
3. Run the game:
   - **Windows**: Drag the `engine` folder onto `love.exe`
   - **Windows (alternative)**: Run `"C:\Program Files\LOVE\love.exe" "engine"`
   - **macOS**: Run `love engine` in terminal
   - **Linux**: Run `love engine` in terminal

## Controls

### Menu
- **Mouse**: Click buttons to navigate
- **ESC**: Quit game

### Geoscape
- **Mouse**: Click provinces to select
- **Space**: Pause/Resume
- **ESC**: Return to menu

### Battlescape
- **Mouse**: Select units and move them
- **Click Unit**: Select unit (shows movement range)
- **Click Tile**: Move selected unit to tile
- **WASD/Arrow Keys**: Pan camera
- **Space**: End turn
- **ESC**: Return to menu

### Basescape
- **Mouse**: Navigate interface
- **1-4 Keys**: Switch between views
  - 1: Facilities
  - 2: Soldiers
  - 3: Research
  - 4: Manufacturing
- **ESC**: Return to menu

## Project Structure

```
xcom_simple/
├── main.lua                 # Entry point and game loop
├── conf.lua                 # Love2D configuration
├── GAME_DESIGN_DOCUMENT.md  # Complete GDD
├── README.md                # This file
├── modules/                 # Game state modules
│   ├── menu.lua            # Main menu
│   ├── geoscape.lua        # World map
│   ├── battlescape.lua     # Tactical combat
│   └── basescape.lua       # Base management
├── systems/                 # Core game systems
│   ├── state_manager.lua   # State machine
│   ├── ui.lua              # UI widgets
│   ├── pathfinding.lua     # A* pathfinding (TODO)
│   ├── line_of_sight.lua   # Vision calculations (TODO)
│   └── combat.lua          # Combat resolution (TODO)
├── data/                    # Game data
│   ├── provinces.lua       # Province definitions (TODO)
│   ├── units.lua           # Unit types (TODO)
│   ├── weapons.lua         # Weapon definitions (TODO)
│   ├── facilities.lua      # Facility definitions (TODO)
│   └── research.lua        # Research tree (TODO)
├── utils/                   # Utility functions
│   ├── math_helpers.lua    # Vector math (TODO)
│   └── draw_helpers.lua    # Rendering utilities (TODO)
└── assets/                  # Game assets
    ├── fonts/              # Font files (TODO)
    ├── images/             # Sprites and textures (TODO)
    └── sounds/             # Sound effects and music (TODO)
```

## Development Status

### Completed (MVP)
- ✅ Project setup and structure
- ✅ State management system
- ✅ Basic UI widgets (Button, Label, Panel)
- ✅ Main menu with navigation
- ✅ Geoscape with province network
- ✅ Battlescape with tile-based map
- ✅ Unit movement system
- ✅ Turn system (player/enemy phases)
- ✅ Basic fog of war
- ✅ Basescape with facility grid
- ✅ Multiple view modes (facilities, soldiers, research, manufacturing)

### In Progress
- 🔨 Combat system
- 🔨 Pathfinding (A* algorithm)
- 🔨 Advanced line-of-sight
- 🔨 AI behaviors

### Planned
- 📋 Mission generation
- 📋 Craft system
- 📋 Research progression
- 📋 Manufacturing system
- 📋 Save/load functionality
- 📋 Sound effects and music
- 📋 Additional unit types
- 📋 More map types
- 📋 Balance tuning

## Game Design

For detailed game design information, see [GAME_DESIGN_DOCUMENT.md](GAME_DESIGN_DOCUMENT.md).

Key features:
- **Province Network**: 7 interconnected regions (like Risk)
- **Turn-Based Combat**: Action points, fog of war, tactical positioning
- **Base Management**: Build facilities, hire personnel, research technology
- **Economy**: Manage funds, monthly income/expenses, province satisfaction
- **Open-Ended**: No fixed win/loss conditions, sandbox gameplay

## Development

### Adding New Features

1. **New State**: Create a module in `modules/` and register it in `main.lua`
2. **New System**: Add utility code to `systems/`
3. **Game Data**: Define data structures in `data/`
4. **Assets**: Place images, sounds, fonts in `assets/`

### Code Style

- Use `local` for all variables
- CamelCase for functions: `calculateDamage()`
- UPPER_CASE for constants: `MAX_HEALTH`
- PascalCase for modules: `StateManager`
- 4-space indentation
- Meaningful comments for complex logic

### Testing

Run the game with console enabled (set in `conf.lua`) to see debug output:
- State transitions
- User actions
- Error messages

## License

This is a learning/demonstration project. Feel free to use, modify, and extend it.

## Credits

- Inspired by UFO: Enemy Unknown (1994) by MicroProse
- Built with Love2D framework
- Created as a game development exercise

## Contributing

This is a personal project, but suggestions and feedback are welcome!

## Troubleshooting

**Game won't start:**
- Ensure Love2D 12.0 is installed
- Check that all required files are present
- Look for error messages in the console

**Performance issues:**
- Lower the map size in battlescape
- Reduce the number of units
- Check for excessive logging

**Controls not working:**
- Make sure the game window has focus
- Check for conflicting keyboard shortcuts
- Try clicking on different areas

## Future Enhancements

- Multiple bases
- Interception mini-game
- More alien types
- Campaign mode
- Modding support
- Multiplayer (hot-seat)
- Procedural map generation
- Advanced AI

---

**Version**: 0.1.0  
**Date**: October 10, 2025  
**Engine**: Love2D 12.0
