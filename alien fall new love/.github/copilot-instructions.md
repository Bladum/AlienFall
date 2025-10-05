# Alien Fall - AI Coding Agent Instructions

## 🚨 CRITICAL DEVELOPMENT GUIDELINES

### Core Game Design Principles
- **Pixel Art Game**: This is an old-school pixel art game, NOT a mobile game
- **Fixed Resolution**: Core resolution is 800x600 - ALL UI elements must be designed for this resolution
- **Grid System**: Use 20x20 pixel grid system - ALL widgets and UI elements MUST align to this grid
- **No Scaling**: UI is fixed at 800x600, scaling is only for display (window resizing/fullscreen)

### Development Workflow Requirements
- **Always Check Love2D API**: Reference [Love API Reference](https://love2d-community.github.io/love-api/) for accurate function signatures and parameters
- **Console Testing**: Always run the app with console enabled (`t.console = true` in conf.lua) to catch errors and debug output
- **Grid Alignment**: Every UI element position and size must be multiples of 20 pixels (grid units)
- **Instant Scene Switching**: No fancy transitions - use instant scene switches for desktop gaming

### Technical Specifications
- **Resolution**: 800x600 internal resolution (40x30 grid units)
- **Antialiasing**: Disabled (MSAA = 0) for crisp pixel art
- **Filtering**: Nearest-neighbor filtering for pixel-perfect scaling
- **Window**: Resizable with fullscreen support (F11 toggle)
- **Input**: Mouse coordinates automatically converted from window space to 800x600 internal space

## Project Overview

### What is Alien Fall?
Alien Fall is an XCOM-inspired turn-based strategy game built with Love2D and Lua. The project is currently in the design phase with comprehensive documentation - **no implementation code exists yet**. The goal is to create a modern, moddable strategy game that combines strategic world management with tactical combat, featuring deterministic AI systems and extensive customization capabilities.

### Project Goal
The primary objective is to develop a complete, playable strategy game that serves as both an engaging player experience and a technical showcase for Love2D game development. The game aims to demonstrate advanced AI systems, modding infrastructure, and scalable architecture while maintaining performance and extensibility.

### Key Modules
- **ECS Framework**: Entity Component System for game object management
- **World System**: Multi-world geoscape with interconnected regions
- **Mission System**: Dynamic mission generation and management
- **Unit System**: Character progression and equipment management
- **Combat Engine**: Tactical battlescape resolution
- **Economy System**: Resource management and production
- **Mod System**: Comprehensive modding with dependency resolution
- **AI Systems**: Deterministic AI for strategic and tactical gameplay

## Technology Stack

### Love2D Game Framework
**Love2D** is a free, open-source 2D game framework written in C++ that provides Lua scripting capabilities. It handles graphics, audio, input, and window management while allowing developers to focus on game logic.

**Where to Find Love2D:**
- **Official Website**: [love2d.org](https://love2d.org/)
- **Download Page**: [love2d.org/download](https://love2d.org/download)
- **GitHub Repository**: [github.com/love2d/love](https://github.com/love2d/love)
- **Current Version**: Love2D 12.0 (included in project as `love-12.0-win64/`)

**Key Love2D Resources:**
- [Love2D Wiki](https://love2d.org/wiki/Main_Page) - Complete documentation
- [Getting Started Guide](https://love2d.org/wiki/Getting_Started) - Quick setup tutorial
- [Love2D Forums](https://love2d.org/forums/) - Community support
- [Awesome Love2D](https://github.com/love2d-community/awesome-love2d) - Curated resource list
- [Love API Reference](https://love2d-community.github.io/love-api/) - Complete API documentation

### Lua Programming Language
**Lua** is a lightweight, high-performance scripting language designed for embedded use. It's the primary programming language for Love2D game development.

**Key Lua Characteristics:**
- **Dynamic Typing**: Flexible variable types without explicit declarations
- **First-Class Functions**: Functions can be stored in variables and passed as arguments
- **Coroutines**: Cooperative multitasking for complex game logic
- **Metatables**: Object-oriented programming through table manipulation
- **C API**: Extensible through C/C++ integration

**Learning Lua Resources:**
- [Official Lua Website](https://www.lua.org/)
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/) (Love2D uses Lua 5.1)
- [Programming in Lua](https://www.lua.org/pil/) - Comprehensive tutorial book
- [Lua Users Wiki](http://lua-users.org/wiki/) - Community knowledge base

## Architecture Fundamentals

### Core Design Philosophy
- **Deterministic Simulation**: Seeded randomness for reproducible gameplay outcomes
- **Data-Driven Design**: Configuration files separate from executable logic
- **Modular Architecture**: ECS pattern with clear system separation
- **Performance Optimization**: Efficient algorithms for real-time gameplay
- **Extensibility**: Comprehensive modding system with dependency management

### Development Workflow

#### File Organization
- `design/` - Complete design documentation and specifications
- `src/` - Implementation code (to be created)
- `data/` - TOML configuration files
- `assets/` - Game assets (images, sounds, fonts)
- `mods/` - Mod content and custom content structure

#### Implementation Priority
1. **Core ECS Framework** - Foundation for all game entities
2. **World/Province System** - Geographic and strategic world structure
3. **Mission Generation** - Dynamic content creation system
4. **Unit/Craft Systems** - Character and vehicle management
5. **Combat Resolution** - Tactical gameplay mechanics

## Key Reference Files

### Project Foundation
- `design/README.md` - High-level project overview and technical foundation
- `implementation_plan.md` - Detailed development roadmap and milestones
- `design_gap_analysis.md` - Current implementation gaps and priorities

### Architecture Documentation
- `design/technical/Modding.md` - Comprehensive modding system architecture
- `design/technical/README.md` - Technical specifications and constraints
- `LINKS.md` - External resources and references

### System Design References
- `design/geoscape/World.md` - World structure and geographic systems
- `design/battlescape/README.md` - Tactical combat system overview
- `design/economy/README.md` - Resource and production systems
- `design/ai/README.md` - AI system architecture and behavior patterns

## Development Environment

### Running the Game
```bash
# From project root directory (Windows)
"C:\Program Files\LOVE\love.exe" .

# With debug console (Windows)
"C:\Program Files\LOVE\lovec.exe" .
```

### Project Dependencies
- **Love2D 12.0**: Game framework (included in repository)
- **Lua 5.1**: Scripting language (bundled with Love2D)
- **TOML Library**: For configuration file parsing
- **Middleclass**: OOP framework for Lua (to be added)

## Related Projects and Inspiration

### XCOM Series
The original inspiration for Alien Fall's gameplay structure and strategic depth:
- **XCOM: Enemy Unknown (2012)** - Modern XCOM reboot
- **XCOM 2 (2016)** - Sequel with expanded mechanics
- **XCOM: Chimera Squad (2020)** - Tactical focus with new mechanics

### Love2D Game Examples
- **Mari0**: Mario platformer with portal mechanics
- **Hedgewars**: Turn-based artillery game
- **Stepmania**: Rhythm game engine
- **LÖVE Games Directory**: [love2d.org/games](https://love2d.org/games)

### Technical References
- **Entity Component System**: Popular in modern game engines
- **Deterministic Randomness**: Used in strategy games for replayability
- **Modding Communities**: Comprehensive mod support patterns

## Development Guidelines

### UI and Grid System Requirements
- **20x20 Grid System**: ALL UI elements must align to 20x20 pixel grid units
- **Grid Constants**: Use `GRID_SIZE = 20` and calculate positions as `grid_unit * GRID_SIZE`
- **Fixed UI Resolution**: Design all UI for 800x600 (40x30 grid units) - no dynamic UI scaling
- **Pixel Perfect**: Disable antialiasing, use nearest-neighbor filtering for pixel art
- **Window Scaling**: Only the display scales up - UI coordinates remain in 800x600 space

### Naming Conventions
- **snake_case**: Variables and functions (`calculate_damage`, `unit_stats`)
- **PascalCase**: Classes and modules (`MissionSystem`, `UnitEntity`)
- **UPPER_CASE**: Constants (`MAX_HEALTH`, `TILE_SIZE`)

### File Structure Standards
```
src/
├── ecs/           # Entity Component System implementation
├── systems/       # Game systems (missions, combat, economy)
├── screens/       # UI screen management
├── data/          # Runtime data handling
└── utils/         # Helper functions and utilities
```

### Quality Assurance
- **Unit Testing**: Core system validation
- **Deterministic Testing**: Seeded random event verification
- **Performance Monitoring**: Frame rate and memory usage tracking
- **Mod Compatibility**: Testing with custom content

## Development Workflow

### Love2D Development Requirements
- **API Reference**: Always check [Love API Reference](https://love2d-community.github.io/love-api/) for accurate function signatures and parameters
- **Console Debugging**: Always run the app with console enabled (`t.console = true` in conf.lua) to catch errors and debug output
- **Error Monitoring**: Use console output for real-time debugging and error detection
- **Version Compatibility**: Ensure code works with Love2D 11.5 specifications

## Common Development Patterns

### Error Handling
- Assertions for critical system invariants
- Contextual error logging for debugging
- Graceful degradation for non-critical failures
- User-friendly error messages

### Performance Considerations
- Efficient rendering for large game worlds
- Memory management for extensive game state
- Optimized algorithms for AI decision making
- Resource loading and caching strategies

### Integration Requirements
- ECS framework integration across all systems
- Consistent API design for modding support
- Coordinate system consistency for multi-world mechanics
- Deterministic behavior for reproducible outcomes
