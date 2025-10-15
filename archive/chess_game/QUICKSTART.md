# Quick Start Guide - Tactical Chess

## Installation

1. **Install Love2D**
   - Download from: https://love2d.org/
   - Install Love2D 11.5 or 12.0
   - Add to PATH (optional)

2. **Run the Game**
   ```bash
   # From chess_game directory
   love .
   
   # Or on Windows with console
   "C:\Program Files\LOVE\lovec.exe" .
   ```

## First Game

### Starting Position
- Player 1 (Blue) starts at top-left corner
- Player 2 (Red) starts at bottom-right corner
- Each player has: 1 King, 2 Pawns, 1 Rook, 1 Knight

### Your First Turn (Player 1)

1. **Select a Piece**
   - Click on any blue piece
   - Valid moves appear in GREEN
   - Attack moves (enemy pieces) appear in RED

2. **Move the Piece**
   - Click on a highlighted tile to move
   - The piece moves and uses Time Units (TU)
   - You start with 5 TU per turn

3. **Continue Moving**
   - Select another piece
   - Move it if you have TU remaining
   - Each piece costs different TU (shown in bottom right when selected)

4. **End Your Turn**
   - Press SPACE when done
   - Player 2's turn begins

### Camera Controls
- **Middle Mouse + Drag**: Pan around the board
- **Mouse Wheel Up**: Zoom in
- **Mouse Wheel Down**: Zoom out

### Understanding the UI

**Top Left Panel:**
- Current turn number
- Active player (with color indicator)
- Resources (for buying units)
- TU remaining this turn

**Top Right Panel (when piece selected):**
- Piece type
- HP (current/max)
- Attack power
- TU cost to move
- Vision range

### Piece Movement Rules

| Piece | Movement | Range | TU Cost | HP | Attack | Vision |
|-------|----------|-------|---------|----|----|--------|
| Pawn | Any direction (8-way) | 1 tile | 1 | 1 | 1 | 2 |
| Rook | Straight lines | 3 tiles | 2 | 1 | 1 | 3 |
| Bishop | Diagonals | 3 tiles | 2 | 1 | 1 | 3 |
| Knight | L-shape (like chess) | Jump | 2 | 1 | 1 | 3 |
| Queen | Any direction | 3 tiles | 3 | 1 | 1 | 3 |
| King | Any direction | 1 tile | 1 | 3 | 0* | 4 |

*King cannot attack!

### Combat Basics

1. **Attacking**
   - Move onto an enemy piece to attack
   - You deal damage equal to your Attack stat
   - Enemy takes damage and loses HP

2. **Destruction**
   - When HP reaches 0, the piece is destroyed
   - Destroyed pieces are removed from the board

3. **King Safety**
   - Kings have 3 HP but cannot attack
   - Kings are valuable - protect them!

### Fog of War

- You can only see within your pieces' vision range
- Dark tiles are unexplored (fog)
- Dimmed tiles are explored but not currently visible
- You can't see enemy pieces in fog

### Control Points

- Yellow tiles are control points
- Capture them by moving onto them
- They generate +1 resource per turn
- Use resources to buy new pieces (future feature)

## Strategy Tips

1. **Manage Your TU**
   - Don't waste TU on unnecessary moves
   - Save TU for important actions
   - Plan your turn before moving

2. **Vision Control**
   - Keep pieces spread out for better vision
   - Use King's 4-tile vision for scouting
   - Don't let enemies hide in fog

3. **Protect Your King**
   - Kings have 3 HP but can't attack
   - Keep them behind your lines
   - Use other pieces to defend

4. **Capture Control Points**
   - More control points = more resources
   - Resources let you buy more units
   - Control the map to win

5. **Use Range Wisely**
   - Rooks/Bishops have 3-tile range
   - Position them for maximum coverage
   - Don't overextend into enemy territory

## Common Issues

**Can't move a piece:**
- Is it your turn?
- Do you have enough TU?
- Is the destination in fog?
- Is the path blocked?

**Can't see enemy pieces:**
- They're in fog of war
- Move closer to reveal them
- Use high-vision pieces to scout

**Game feels slow:**
- Use mouse wheel to zoom out
- Middle-mouse drag to pan quickly
- Plan moves before clicking

## Next Steps

Once you're comfortable with basics:
- Experiment with different piece combinations
- Try aggressive vs defensive strategies
- Learn to manage resources
- Master fog of war vision control

## Have Fun!

This is a deep tactical game. Don't worry if you lose at first - learning the mechanics takes time. Experiment and find your playstyle!
