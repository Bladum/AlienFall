# Tactical Chess Game

A Love2D-based multi-player tactical chess variant with advanced gameplay mechanics.

## Current Status: Phase 1 Complete ✅

### Implemented Features

#### Core Systems
- ✅ Variable board size (default 12x12)
- ✅ 10% obstacle generation on board
- ✅ Tile system with checkerboard pattern
- ✅ Control points for resource generation

#### Piece System
All 6 chess pieces implemented with modified movement rules:
- ✅ **Pawn**: Move/attack 1 tile in any direction (8-directional)
- ✅ **Rook**: Straight lines, max range 3 tiles
- ✅ **Bishop**: Diagonals, max range 3 tiles
- ✅ **Knight**: Standard L-shape movement
- ✅ **Queen**: Any direction, max range 3 tiles
- ✅ **King**: 1 tile any direction, CANNOT attack (3 HP, 0 attack)

#### Game Mechanics
- ✅ HP/Attack system (default 1 HP / 1 Attack per piece)
- ✅ Combat resolution with damage
- ✅ Piece destruction when HP reaches 0
- ✅ Time Unit (TU) cost per piece movement
- ✅ TU pool per player turn (5 TU)
- ✅ Resource tracking (30 starting points)
- ✅ Control point system

#### Fog of War
- ✅ Vision ranges per piece type (Pawn: 2, Most: 3, King: 4)
- ✅ Explored vs Hidden fog states
- ✅ Dynamic fog updates per turn
- ✅ Manhattan distance vision calculation

#### Camera System
- ✅ Middle mouse button panning
- ✅ Mouse wheel zoom (0.5x to 2.0x)
- ✅ Smooth camera movement
- ✅ Camera bounds based on board size

#### UI
- ✅ Turn indicator with player color
- ✅ Resource and TU display
- ✅ Selected piece stats display
- ✅ Valid move highlighting (green/red for attack)
- ✅ HP bars for damaged pieces
- ✅ Control instructions overlay

#### Player System
- ✅ Up to 8 player support (2 active currently)
- ✅ Player colors with RPG scheme (Blue, Red, Green, Yellow, Purple, Orange, Cyan, Pink)
- ✅ Turn-based gameplay
- ✅ Per-player resource tracking

## Controls

- **Left Click**: Select piece / Move to destination
- **Middle Mouse**: Pan camera (drag)
- **Mouse Wheel**: Zoom in/out
- **Space**: End turn
- **Escape**: Quit game

## How to Play

1. **Setup Phase**: 
   - Each player starts with 30 resource points
   - Place pieces on the board (currently pre-placed)
   - Each piece has a cost (Pawn: 1, Rook/Bishop/Knight: 3, Queen: 5)

2. **Turn Structure**:
   - Each player gets 5 Time Units (TU) per turn
   - Moving a piece costs TU (Pawn: 1, Rook/Bishop/Knight: 2, Queen: 3, King: 1)
   - You can move multiple pieces until TU runs out
   - Press Space to end turn

3. **Movement**:
   - Click a piece to select it
   - Valid moves are highlighted in green
   - Attack moves (enemy pieces) are highlighted in red
   - Click destination to move

4. **Combat**:
   - Move onto an enemy piece to attack
   - Damage is dealt based on attack stat (default: 1)
   - Pieces are destroyed when HP reaches 0
   - King cannot attack but has 3 HP

5. **Fog of War**:
   - You can only see tiles within your pieces' vision range
   - Explored tiles remain visible but dimmed
   - Hidden tiles are completely dark

6. **Resources**:
   - Control points generate +1 resource per turn
   - Resources can be used to purchase new pieces (future feature)

## Running the Game

### Prerequisites
- Love2D 11.5 or 12.0 installed
- Windows, Mac, or Linux

### Launch
```bash
# From chess_game directory
love .

# Or with console (Windows)
lovec.exe .
```

## Project Structure

```
chess_game/
├── conf.lua                    # Love2D configuration
├── main.lua                    # Game entry point
├── src/
│   ├── core/
│   │   └── constants.lua       # Game constants
│   ├── board/
│   │   ├── board.lua           # Board management
│   │   └── tile.lua            # Individual tiles
│   ├── pieces/
│   │   ├── piece.lua           # Base piece class
│   │   ├── pawn.lua
│   │   ├── rook.lua
│   │   ├── bishop.lua
│   │   ├── knight.lua
│   │   ├── queen.lua
│   │   └── king.lua
│   └── camera/
│       └── camera.lua          # Camera with pan/zoom
├── assets/
│   └── sprites/                # (Future) Piece sprites
└── data/                       # (Future) Game data files
```

## Next Steps (Phase 2+)

### Immediate Priorities
- [ ] Player setup screen for army building
- [ ] Purchase pieces during game at control points
- [ ] Alliance system (shared vision, no friendly fire)
- [ ] Multiple game modes (Deathmatch, Capture Flag, Domination, etc.)
- [ ] Minimap

### Advanced Features
- [ ] Scenario system with random maps
- [ ] Campaign mode with mission progression
- [ ] Race system (different unit stats per race)
- [ ] AI opponents
- [ ] Save/Load game state
- [ ] Better graphics and animations
- [ ] Sound effects and music
- [ ] Network multiplayer (stretch goal)

## Game Design Goals

This is a **tactical strategy game** that combines:
- **Chess-like movement** with range limitations
- **RPG elements** (HP, Attack, multiple units)
- **RTS economy** (resources, unit purchasing)
- **Turn-based strategy** (TU system, multiple moves per turn)
- **Fog of war** (partial information gameplay)
- **Multi-player** (up to 8 players with alliances)

The goal is to create a deep tactical experience that's easy to learn but offers strategic depth through:
- Army composition choices
- Resource management
- Territorial control
- Vision control
- Alliance diplomacy

## Technical Notes

- Built with Love2D (Lua game framework)
- Object-oriented design with inheritance
- Modular architecture for easy expansion
- Data-driven design (constants separated from logic)
- Performance optimized for large boards

## Credits

Developed as a Love2D learning project inspired by:
- Chess (classic strategy)
- XCOM (tactical gameplay)
- Age of Empires (RTS economy)
- Advance Wars (turn-based tactics)

## License

This project is for educational purposes. Love2D is licensed under the zlib license.
