# Visibility System - Visual Guide

## How It Works

### Ray-Casting Basics

```
Unit (U) trying to see Target (T):

    U . . . . T
    
Step 1: Calculate line using Bresenham
    U→→→→→T
    
Step 2: Check each tile along path
    U ✓ ✓ ✓ ✓ T  (all clear = CAN SEE)
    
Step 3: Stop at walls
    U ✓ ✓ W X X  (hit wall = CANNOT SEE)
```

## Visibility States

### Hidden (0) - Never Seen
```
████████████████
████████████████
████████████████
████████████████
```
Completely black, no information.

### Explored (1) - Fog of War
```
░░░░░░░░░░░░░░░░
░░.....░░░░░░░░░
░░.....░░░░░░░░░
░░░░░░░░░░░░░░░░
```
Darkened (30% brightness), shows layout but not current state.
- Can see walls and floors
- Cannot see units or changes
- "Memory" of what was there

### Visible (2) - Currently Seen
```
                
  .....         
  .....         
                
```
Full brightness (100%), live information.
- See everything: terrain, units, effects
- Real-time updates
- "What you see now"

## Team Vision Examples

### Single Unit Vision

```
Map (60x60 tiles):
████████████████████
█                  █
█      U           █  U = Unit at (7,3)
█                  █  LOS range = 10 tiles
█                  █
█                  █
████████████████████

Visibility (circle of radius 10):
████████████████████
█░░░░░░░░░░░░░░░░░░█
█░░··········░░░░░░█
█░·          ·░░░░░█
█░·    U     ·░░░░░█
█░·          ·░░░░░█
█░··········░░░░░░░█
█░░░░░░░░░░░░░░░░░░█
████████████████████

█ = Hidden (walls)
░ = Explored (seen before, now dim)
· = Visible (currently in LOS)
```

### Wall Blocking LOS

```
Unit trying to see through wall:

Before ray-cast:
    U . . W . . T

After ray-cast:
    U ✓ ✓ W ✗ ✗ T
    
Can see: U, tiles before W
Cannot see: Tiles after W, target T

Visibility result:
    U ✓ ✓ W █ █ █
    
✓ = Visible
█ = Hidden (blocked by wall)
```

### Multiple Units - Shared Vision

```
Team with 2 units:

Unit 1 vision:          Unit 2 vision:
████████████            ████████████
█░░░░░░░░░█            █████░░░░░██
█░······░░█            ████░·····██
█░·U1   ·░█            ████░·   U2█
█░·     ·░█            ████░·····██
█░······░░█            ████░░░░░███
████████████            ████████████

Combined team vision:
████████████
█░░░░░░░░░█
█░······░·█
█░·U1   ·U2█
█░·     ··█
█░······░·█
████████████

Any tile seen by ANY unit = visible to ENTIRE team!
```

## Distance Calculation

### Why Squared Distance?

```
Distance formula:
    d = √(dx² + dy²)
    
Comparison: d ≤ range
    √(dx² + dy²) ≤ range
    
Squared both sides:
    dx² + dy² ≤ range²
    
Same result, no sqrt needed!
```

**Performance**:
- Standard: ~100 cycles (sqrt is slow)
- Squared: ~10 cycles (just multiplication)
- **10x faster!**

### Range Check Before Ray-Cast

```
Optimization:
1. Check distance (fast): O(1)
2. If in range, ray-cast (slow): O(distance)
3. Skip out-of-range tiles

Example (range = 10):
    Unit at (30, 30)
    Target at (50, 50)
    
    Distance: √((50-30)² + (50-30)²) = √(400+400) = √800 ≈ 28
    Range: 10
    
    28 > 10, so SKIP ray-cast!
    
Saves: 28 tile checks per out-of-range tile!
```

## Bresenham's Line Algorithm

### Step-by-Step Example

```
Draw line from (2,2) to (7,5):

Grid:
  0 1 2 3 4 5 6 7
0 . . . . . . . .
1 . . . . . . . .
2 . . S . . . . .
3 . . . * . . . .
4 . . . . * * . .
5 . . . . . . * E

S = Start (2,2)
E = End (7,5)
* = Line tiles

Algorithm:
dx = |7-2| = 5
dy = |5-2| = 3
err = 5 - 3 = 2

Steps:
1. (2,2) err=2, move X, (3,2)
2. (3,2) err=-1, move Y, (3,3)
3. (3,3) err=4, move X, (4,3)
4. (4,3) err=1, move X, (5,3)
5. (5,3) err=-2, move Y, (5,4)
6. (5,4) err=3, move X, (6,4)
7. (6,4) err=0, move X&Y, (7,5)

Result: Perfect line with no gaps!
```

### Why Bresenham?

✅ **Integer-only** - No floating point math  
✅ **No division** - Only addition/subtraction  
✅ **Exact** - Pixel-perfect lines  
✅ **Fast** - ~5 operations per step  
✅ **Proven** - 60+ years of use in graphics  

## Performance Analysis

### Single Unit Calculation

```
Given:
- Map: 60×60 = 3,600 tiles
- LOS range: 10 tiles
- Unit position: (30, 30)

Tiles in range:
    Circle area = π × r²
    = 3.14 × 10²
    = 314 tiles

Ray-casts needed: 314
Average ray length: ~7 tiles
Tile checks: 314 × 7 = 2,198

Operations:
- Distance checks: 3,600 (all tiles)
- Ray-casts: 314 (only in-range)
- Tile lookups: 2,198 (along rays)

Time: ~1-2ms on modern hardware
```

### Full Team (4 Units)

```
4 units × ~2ms = ~8ms total
Still 120 FPS capable!

With optimization (only update on movement):
- Calculate once per unit move
- 99% of frames skip calculation
- Imperceptible lag
```

## Visibility Update Flow

```
1. Game Start
   └─> Calculate initial visibility
       └─> For each team
           └─> For each unit
               └─> Ray-cast in all directions
                   └─> Mark tiles VISIBLE

2. Unit Moves
   └─> Old position tiles: VISIBLE → EXPLORED
   └─> Calculate new visibility
       └─> New tiles: HIDDEN → VISIBLE
       └─> Old tiles: EXPLORED → VISIBLE (if still seen)

3. Unit Dies
   └─> Remove from visibility calculations
   └─> Team vision shrinks
   └─> Some tiles: VISIBLE → EXPLORED
```

## Fog of War Example

```
Turn 1: Unit at (5,5)
████████████
█░░░░░░░░░█
█░······░░█
█░·U    ·░█  ← Unit can see this area
█░·     ·░█
█░······░░█
████████████

Turn 2: Unit moves to (8,5)
████████████
█░░░░░░░░░█
█░░░░░······█
█░░░░░··  U·█  ← New area visible
█░░░░░······█     Old area now EXPLORED (dim)
█░░░░░░░░░░█
████████████

Turn 3: Unit moves to (5,8)
████████████
█░░░░░░░░░░█
█░░░░░░░░░░█
█░░░░░░░░░░█  ← All previous areas EXPLORED
█░░░░U······█     New area VISIBLE
█░░░········█
████████████

Memory persists!
```

## Combat Example

```
Player unit (P) sees Enemy (E):

████████████
█          █
█  P     █ █
█        █ █
█        █ █
█       E█ █
█          █
████████████

P can see:
- All open areas within range ✓
- Wall tiles ✓
- Enemy E? NO - blocked by wall! ✗

P cannot shoot E even though E is in range!
Must move to position with LOS.

Better position:
████████████
█          █
█  P       █
█        █ █
█        █ █
█       E█ █
█          █
████████████

Now P can see E! ✓
Can target for attack.
```

## Implementation Tips

### Optimizations

1. **Cache visibility between moves**
   - Don't recalculate if nothing changed
   - Only update on unit movement

2. **Dirty flag system**
   - Mark units as "dirty" when moved
   - Only recalculate dirty units' teams

3. **Spatial partitioning**
   - Divide map into chunks
   - Only check nearby chunks

4. **Level of detail**
   - Full calculation for player team
   - Simplified for AI teams

### Debugging

```lua
-- Visualize ray-casts
local hasLOS, tiles = VisibilitySystem.calculateLOS(map, x1, y1, x2, y2)
for _, tile in ipairs(tiles) do
    -- Draw debug line showing ray path
    love.graphics.circle("fill", tile.x, tile.y, 0.2)
end

-- Print visibility stats
print("Visible:", countVisible)
print("Explored:", countExplored)
print("Hidden:", countHidden)
```

---

## Summary

The visibility system provides:
- **Realistic line-of-sight** using ray-casting
- **Team-based shared vision** (any sees = all see)
- **Fog of war** (hidden/explored/visible states)
- **Performance optimized** (distance checks, squared distance)
- **Combat-ready** (can see = can shoot)

Ready to render it all in 3D! 🎮
