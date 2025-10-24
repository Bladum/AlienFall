# Battlescape Logic

## Goal / Purpose
Contains operational logic for battlescape systems including turn management, action validation, movement calculations, and tactical decision support.

## Content
- **Turn logic** - Turn order and phase transitions
- **Action validation** - Checking action legality
- **Movement logic** - Path validation and movement calculations
- **Action point system** - AP consumption and management
- **Range calculations** - Distance and weapon range checking
- **Tactical helpers** - Positioning and cover calculations
- **State transitions** - Battle state changes and events

## Features
- Turn-based action system
- Action validation and constraints
- Movement pathfinding
- Range calculations
- Tactical calculations
- Efficient state management

## Integrations with Other Folders / Systems
- **engine/battlescape/battle** - Turn and action management
- **engine/battlescape/battlefield** - Positioning and range
- **engine/battlescape/entities** - Unit state
- **engine/battlescape/ai** - AI action selection
- **engine/battlescape/combat** - Combat resolution
- **engine/core/pathfinding.lua** - Path calculation
- **engine/battlescape/logic/mapscript_commands** - Mapscript logic
