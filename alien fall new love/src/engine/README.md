# Engine Directory - Core Engine Systems

## Overview

The `engine/` directory contains the core engine infrastructure that supports Alien Fall's gameplay. This includes state management, kernel services, research systems, and world simulation. The engine layer provides the foundation that game systems build upon.

## Subdirectories

### `kernel/` - Core Services
Essential services that run throughout the game lifecycle:

#### `event_bus.lua`
**Purpose**: Centralized event system for decoupled communication
- Event publishing and subscription
- Cross-system communication
- Debug event logging

**GROK**: Use event bus for system communication, never direct dependencies

#### `logger.lua`
**Purpose**: Comprehensive logging system
- Multiple log levels (debug, info, warn, error)
- File and console output
- Performance monitoring

**GROK**: All systems should use logger for debugging and monitoring

#### `save.lua`
**Purpose**: Game state serialization and persistence
- Save/load game state
- Entity serialization
- Mod-aware saving

**GROK**: Handles complex object graphs - use for all persistence

#### `turn_manager.lua`
**Purpose**: Turn-based game flow management
- Turn progression logic
- Player/AI turn switching
- Time management

**GROK**: Controls game pacing and turn structure

#### `rng.lua`
**Purpose**: Deterministic random number generation
- Seeded randomness for reproducibility
- Save/load RNG state
- Debug random event logging

**GROK**: Use for all gameplay randomness to ensure save compatibility

#### `telemetry.lua`
**Purpose**: Performance monitoring and analytics
- Frame rate tracking
- Memory usage monitoring
- System performance metrics

**GROK**: Monitor performance bottlenecks and optimization opportunities

#### `asset_cache.lua`
**Purpose**: Resource loading and caching
- Texture and sound asset management
- Memory-efficient caching
- Asynchronous loading

**GROK**: All asset loading goes through cache for performance

#### `audio_stub.lua`
**Purpose**: Audio system abstraction
- Sound effect management
- Music playback
- Audio settings

**GROK**: Audio interface - implement actual audio backend here

### `states/` - Game State Management
Game state implementations for different game modes:

#### State Types
- **`main_menu_state.lua`** - Main menu and navigation
- **`geoscape_state.lua`** - Strategic world view
- **`basescape_state.lua`** - Base management view
- **`battlescape_state.lua`** - Tactical combat
- **`interception_state.lua`** - Aircraft interception

#### State Management
- **`state_stack.lua`** - State stack management
- Push/pop states for modal dialogs
- State transitions and cleanup

**GROK**: Each state handles one game mode - keep focused and independent

### `research/` - Research System
Technology and knowledge progression:

#### `ResearchTree.lua`
**Purpose**: Technology tree management
- Research project dependencies
- Progress tracking
- Technology unlocking

**GROK**: Research drives game progression - balance carefully

### `world/` - World Simulation
Geographic and environmental systems:

#### World Components
- **`Biome.lua`** - Biome definitions and properties
- **`MapBlock.lua`** - Terrain block management
- **`MapScript.lua`** - Procedural generation scripts
- **`Terrain.lua`** - Terrain type definitions

**GROK**: World generation and terrain logic

## Architecture Patterns

### Service Locator Pattern
Core services are accessed through the service registry:
```lua
local logger = serviceRegistry:get("logger")
local eventBus = serviceRegistry:get("event_bus")
```

### State Pattern
Game states implement consistent interface:
```lua
function GeoscapeState:enter()
function GeoscapeState:update(dt)
function GeoscapeState:draw()
function GeoscapeState:exit()
```

### Observer Pattern
Event bus enables loose coupling:
```lua
eventBus:subscribe("combat:started", function(event) ... end)
eventBus:emit("combat:started", combatData)
```

## Performance Considerations

### Memory Management
- **GROK**: Asset cache prevents memory leaks from texture reloading
- **GROK**: State cleanup prevents memory accumulation during state changes
- **GROK**: Event bus uses weak references to prevent circular dependencies

### Frame Rate Optimization
- **GROK**: Kernel services run every frame - keep them lightweight
- **GROK**: Use telemetry to identify performance bottlenecks
- **GROK**: Cache expensive calculations in services

### Threading Considerations
- **GROK**: Love2D is single-threaded - avoid blocking operations
- **GROK**: Use coroutines for long-running tasks
- **GROK**: Asset loading is asynchronous where possible

## Development Guidelines

### Adding New Services
1. **GROK**: Create service class with clear interface
2. **GROK**: Register with service registry in initialization
3. **GROK**: Add comprehensive logging and error handling
4. **GROK**: Write unit tests for service functionality

### State Management
- **GROK**: States should be independent and testable
- **GROK**: Use state stack for modal UI (dialogs, menus)
- **GROK**: Clean up resources in state:exit()

### Event System Usage
- **GROK**: Use descriptive event names with namespaces
- **GROK**: Include relevant data in event payloads
- **GROK**: Document event contracts for other developers

### Research Integration
- **GROK**: Research system affects game balance significantly
- **GROK**: Coordinate with mod system for custom research trees
- **GROK**: Use telemetry to track research completion rates

## Testing Strategy

### Unit Testing
- **GROK**: Test services independently with mocks
- **GROK**: Test state transitions thoroughly
- **GROK**: Test event bus message passing

### Integration Testing
- **GROK**: Test service interactions through service registry
- **GROK**: Test state stack behavior
- **GROK**: Test save/load cycles

### Performance Testing
- **GROK**: Monitor frame rates during gameplay
- **GROK**: Test memory usage over long sessions
- **GROK**: Profile system update times