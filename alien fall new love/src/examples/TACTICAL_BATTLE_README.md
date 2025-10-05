# Tactical Battle Demo - XCOM-Style Combat

A complete tactical combat demonstration inspired by UFO: Enemy Unknown (X-COM: UFO Defense), featuring turn-based grid combat with advanced tactical mechanics.

## Features Implemented

### Core Systems
- **30x25 Tile Grid System** - Large tactical map with random generation
- **Procedural Map Generation** - Randomized walls, obstacles, and cover positions
- **Turn-Based Combat** - Alternating player/enemy turns with Time Unit (TU) system
- **Two Sides** - 4 Player soldiers vs 4 Alien enemies

### Tactical Mechanics
- **Line of Sight (LOS)** - Bresenham's line algorithm for accurate visibility
- **Fog of War** - Three states: unexplored (black), explored (darkened), visible (full color)
- **Line of Fire** - Combat requires clear LOS between attacker and target
- **A* Pathfinding** - Intelligent unit movement with TU-constrained pathing
- **Cover System** - Low cover obstacles provide tactical positioning

### Combat System
- **Time Units (TU)** - Each unit has limited actions per turn
  - Movement: 1 TU per tile
  - Attack: 6 TU per shot
- **Accuracy System** - Distance-based hit calculation
  - Base accuracy per unit
  - -3% accuracy per tile of distance
  - Min 10% / Max 95% hit chance
- **Unit Stats**
  - Health/Max Health
  - TU/Max TU
  - Accuracy rating
  - Damage per hit
  - Sight range

### AI System
- **Basic Enemy AI** - Simple but functional tactical behavior
  - Identifies closest visible player unit
  - Attacks if within range (8 tiles)
  - Moves closer if out of range
  - Uses pathfinding to navigate obstacles

### Visual System (Primitive Graphics)
- **Grid Rendering** - Clear tile-based display
- **Unit Representation** - Colored circles (Blue = Player, Red = Enemy)
- **Health Bars** - Visual health indicator above each unit
- **Selection Highlight** - Yellow circle around selected unit
- **Fog of War Overlay** - Black unexplored, darkened explored areas
- **Tile Types**
  - Dark gray = Floor
  - Light gray = Wall (blocks movement/LOS)
  - Brown = Low cover
- **UI Display**
  - Turn indicator (Player/Enemy)
  - Selected unit stats panel
  - Control instructions

## Controls

| Input | Action |
|-------|--------|
| **Left Mouse Button** | Select friendly unit |
| **Right Mouse Button** | Move selected unit OR attack enemy unit |
| **SPACE** | End turn (passes to enemy) |
| **ESC** | Deselect current unit |
| **F11** | Toggle fullscreen |

## Gameplay Instructions

1. **Select a Unit** - Left-click on one of your blue soldier units
2. **Move** - Right-click on an empty walkable tile to move there
   - Movement costs 1 TU per tile
   - You can only move as far as your remaining TU allows
3. **Attack** - Right-click on an enemy (red) unit to shoot
   - Requires 6 TU minimum
   - Must have line of fire (no walls blocking)
   - Hit chance depends on distance
4. **End Turn** - Press SPACE when done with your units
   - Enemy AI takes its turn automatically
   - All units on the new turn's side get full TU restored

## Technical Implementation

### Map Generation
- Procedurally generated each game
- Border walls around entire map
- 15-30 random obstacle clusters (1-3 tiles each)
- 10-20 low cover positions
- Ensures varied tactical scenarios

### Fog of War System
- Three-state system:
  - `0` = Unexplored (hidden)
  - `1` = Previously visible (darkened)
  - `2` = Currently visible (full brightness)
- Updates each time a unit moves
- Only player units reveal fog
- Enemy units only visible if in player's line of sight

### Pathfinding Algorithm
- A* implementation with Manhattan heuristic
- Considers:
  - Wall collision
  - Unit blocking
  - TU constraints (won't path beyond available movement)
- Returns nil if no valid path exists

### Line of Sight Algorithm
- Bresenham's line algorithm for efficient raycasting
- Checks each tile along the line
- Blocked by walls (not by low cover)
- Used for both visibility and line of fire

### Combat Resolution
1. Check if attacker has 6+ TU
2. Verify line of fire to target
3. Calculate distance to target
4. Apply distance penalty to accuracy
5. Roll d100 against hit chance
6. Apply damage if hit, subtract TU regardless

## Unit Stats

### Player Soldiers
- Health: 50
- Max TU: 14
- Accuracy: 70%
- Damage: 15
- Sight Range: 10 tiles

### Alien Enemies
- Health: 40
- Max TU: 12
- Accuracy: 60%
- Damage: 12
- Sight Range: 9 tiles

## Camera System
- Smooth camera following selected unit
- Lerped movement for polish
- Centers view on active unit

## File Structure
```
main.lua                           # Entry point, Love2D callbacks
src/examples/tactical_battle_demo.lua  # Complete demo implementation
```

## Future Enhancement Ideas
- Multiple weapon types with different stats
- Action points for different actions (crouch, reaction fire)
- Reaction fire system
- Grenades and area-of-effect weapons
- Multiple unit types with different stats
- Experience and unit progression
- Mission objectives beyond "kill all enemies"
- Destructible terrain
- Multi-level maps
- More sophisticated AI with flanking tactics
- Sound effects and visual effects
- Animation system for movement and combat

## XCOM Inspirations Used
- Time Units (TU) action point system
- Turn-based tactical combat
- Fog of war with persistent vision
- Line of sight mechanics
- Grid-based movement and combat
- Two-sided tactical engagement
- Distance-based accuracy penalties
- Simple but effective AI behavior

## Running the Demo
```bash
# Windows
"C:\Program Files\LOVE\lovec.exe" .

# Or use the VS Code task
# Run Task -> Run Love2D Game (Console Debug)
```

## Performance
- Efficient A* pathfinding with early termination
- Optimized line-of-sight raycasting
- Minimal memory allocation during gameplay
- Runs at 60 FPS on any modern hardware

---

**Note**: This is a complete, playable tactical combat demo showcasing all core XCOM-style mechanics in a single file for easy understanding and modification.
