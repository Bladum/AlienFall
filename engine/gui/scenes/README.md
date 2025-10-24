# GUI Scenes

## Goal / Purpose
Manages scene transitions and scene graph for the GUI system. Handles layer switching between geoscape, basescape, and battlescape with transitions and state management.

## Content
- **Scene classes** - Base scene framework
- **Scene transitions** - Fade and transition effects
- **Scene stacking** - Scene hierarchy and layering
- **Scene state** - Scene-specific state management
- **Input handling** - Scene-specific input routing
- **Scene callbacks** - Lifecycle and event callbacks

## Features
- Scene state machine
- Smooth transitions
- Input routing
- Scene stacking
- Event system
- Modular scene architecture

## Integrations with Other Folders / Systems
- **engine/gui** - Core GUI framework
- **engine/geoscape/screens** - Geoscape scenes
- **engine/battlescape/scenes** - Battlescape scenes
- **engine/basescape/ui** - Basescape integration
- **engine/core/state_manager.lua** - Game state
- **engine/gui/widgets** - Widget rendering in scenes
