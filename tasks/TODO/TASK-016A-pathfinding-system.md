# Task: Enhanced Pathfinding System with Movement Costs

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent  
**Part Of:** TASK-016 HEX Grid Tactical Combat System (Phase 1)

---

## Overview

Implement A* pathfinding algorithm for hexagonal grid with terrain-based movement costs, Time Unit (TU) consumption calculation, and multi-turn movement planning. This is the foundation for all unit movement in tactical combat.

---

## Purpose

**Why Critical:**
- Units need intelligent navigation around obstacles
- Terrain affects movement speed (rough terrain costs more TUs)
- Players need to see path costs before committing to movement
- AI needs pathfinding for tactical positioning

**Enables:**
- Tactical unit positioning
- AI movement decisions
- Multi-turn movement planning
- Cover-to-cover movement
- Flanking maneuvers

---

## Requirements

### Functional Requirements
- [ ] Find shortest path from point A to B on hex grid
- [ ] Account for terrain movement costs (1x, 2x, 4x, infinite)
- [ ] Avoid blocked hexes (walls, units, obstacles)
- [ ] Calculate total TU cost for path
- [ ] Support multi-turn paths (when TUs insufficient)
- [ ] Show path preview to player before movement
- [ ] Recalculate path when terrain changes
- [ ] Handle unreachable destinations gracefully

### Technical Requirements
- [ ] Use A* algorithm with hex distance heuristic
- [ ] Implement priority queue (binary heap) for performance
- [ ] Cache pathfinding results when possible
- [ ] Complete pathfinding in < 5ms for 30 hex paths
- [ ] Support up to 100 hex paths in < 20ms
- [ ] No memory leaks (reuse node objects)
- [ ] Clean separation from rendering code

### Acceptance Criteria
- [ ] Unit can find path through open terrain
- [ ] Unit navigates around obstacles correctly
- [ ] Rough terrain costs 2x normal TUs
- [ ] Very rough terrain costs 4x normal TUs
- [ ] Blocked terrain is avoided
- [ ] Path preview shows exact route
- [ ] TU cost matches actual movement consumption
- [ ] Multi-turn movement splits path at TU limit
- [ ] No pathfinding when destination unreachable
- [ ] Performance targets met (< 5ms for normal paths)

---

## Plan

### Step 1: Create Pathfinding Utility Module
**Description:** Pure functional pathfinding algorithm with no game state dependencies

**Files to create:**
- `engine/battle/utils/pathfinding.lua` (new)

**Implementation:**
- A* algorithm implementation
- Binary heap priority queue
- Hex distance heuristic function
- Node pool for memory efficiency
- Path reconstruction from goal to start

**Estimated time:** 6 hours

### Step 2: Integrate with Movement System
**Description:** Connect pathfinding to existing movement system

**Files to modify:**
- `engine/battle/systems/movement_system.lua`
- `engine/battle/systems/hex_system.lua`

**Implementation:**
- Add terrain cost property to hex tiles
- Implement `findPath(startQ, startR, goalQ, goalR)` method
- Calculate TU cost along path
- Handle multi-turn movement
- Cache current path for unit

**Estimated time:** 4 hours

### Step 3: Add Terrain Cost Data
**Description:** Define movement costs for all terrain types

**Files to create:**
- `engine/data/terrain_movement_costs.lua` (new)

**Data structure:**
```lua
{
    floor = 1.0,        -- Normal speed
    grass = 1.0,        -- Normal
    dirt = 1.0,         -- Normal
    road = 0.75,        -- Faster (bonus)
    rough = 2.0,        -- Slow
    very_rough = 4.0,   -- Very slow
    water = 4.0,        -- Very slow
    wall = math.huge,   -- Impassable
    door_closed = 2.0,  -- Slow to open
    door_open = 1.0     -- Normal
}
```

**Estimated time:** 2 hours

### Step 4: Path Visualization
**Description:** Show path preview to player during movement planning

**Files to modify:**
- `engine/modules/battlescape.lua`
- `engine/battle/renderer.lua`

**Implementation:**
- Render path as line overlay on hex grid
- Show TU cost per segment
- Highlight endpoint
- Color code: green (can reach), yellow (multi-turn), red (unreachable)

**Estimated time:** 2 hours

### Step 5: Unit Testing
**Description:** Comprehensive test suite for pathfinding

**Files to create:**
- `engine/battle/tests/test_pathfinding.lua` (new)

**Test cases:**
- Path through open terrain
- Path around single obstacle
- Path through maze
- Path with varied terrain costs
- Unreachable destination handling
- TU cost calculation accuracy
- Multi-turn movement split
- Performance test (100 paths)

**Estimated time:** 2 hours

---

## Implementation Details

### Architecture

**Pathfinding Module (Pure Algorithm):**
```
pathfinding.lua
├── findPath(grid, start, goal, costFunc) → path or nil
├── reconstructPath(cameFrom, start, goal) → path
├── heuristic(a, b) → number
└── BinaryHeap class
```

**Movement System Integration:**
```
movement_system.lua
├── planPath(unitId, goalQ, goalR) → path
├── executeMovement(unitId, path) → success
├── getMovementCost(path) → tuCost
└── canReachInOneTurn(unitId, goalQ, goalR) → boolean
```

### A* Algorithm Pseudocode
```
function findPath(start, goal):
    openSet = BinaryHeap()
    openSet.push(start, 0)
    
    cameFrom = {}
    gScore = {[start] = 0}
    fScore = {[start] = heuristic(start, goal)}
    
    while not openSet.isEmpty():
        current = openSet.pop()
        
        if current == goal:
            return reconstructPath(cameFrom, start, goal)
        
        for neighbor in getNeighbors(current):
            tentativeG = gScore[current] + movementCost(current, neighbor)
            
            if tentativeG < gScore[neighbor]:
                cameFrom[neighbor] = current
                gScore[neighbor] = tentativeG
                fScore[neighbor] = tentativeG + heuristic(neighbor, goal)
                openSet.push(neighbor, fScore[neighbor])
    
    return nil  -- No path found
```

### Heuristic Function
Use hex distance (already implemented in HexMath):
```lua
function heuristic(q1, r1, q2, r2)
    return HexMath.distance(q1, r1, q2, r2)
end
```

### Movement Cost Function
```lua
function getMovementCost(fromQ, fromR, toQ, toR)
    local toTile = hexSystem:getTile(toQ, toR)
    if not toTile then return math.huge end
    
    local terrainType = toTile.terrain
    local baseCost = TerrainCosts[terrainType] or 1.0
    
    -- Check for units blocking the tile
    if toTile.occupied then
        return math.huge
    end
    
    return baseCost
end
```

### Binary Heap (Priority Queue)
```lua
BinaryHeap = {}
function BinaryHeap.new()
    return {
        items = {},      -- [index] = {element, priority}
        elementToIndex = {}  -- [element] = index
    }
end

function BinaryHeap.push(self, element, priority)
    -- Insert at end and bubble up
end

function BinaryHeap.pop(self)
    -- Remove min element and bubble down
end

function BinaryHeap.isEmpty(self)
    return #self.items == 0
end
```

### Multi-Turn Movement
```lua
function splitPathByTU(path, availableTU)
    local segments = {}
    local currentSegment = {}
    local tuUsed = 0
    
    for i, node in ipairs(path) do
        local stepCost = node.terrainCost
        
        if tuUsed + stepCost <= availableTU then
            table.insert(currentSegment, node)
            tuUsed = tuUsed + stepCost
        else
            -- Start new segment (next turn)
            table.insert(segments, {path = currentSegment, tuCost = tuUsed})
            currentSegment = {node}
            tuUsed = stepCost
        end
    end
    
    if #currentSegment > 0 then
        table.insert(segments, {path = currentSegment, tuCost = tuUsed})
    end
    
    return segments
end
```

---

## Testing Strategy

### Unit Tests

#### Test 1: Path Through Open Terrain
```lua
function test_open_terrain_path()
    local grid = createTestGrid(10, 10, "floor")
    local path = Pathfinding.findPath(grid, {q=0, r=0}, {q=5, r=5})
    
    assert(path ~= nil, "Path should be found")
    assert(#path == 6, "Path length should be 6 hexes") -- including start
    assert(path[1].q == 0 and path[1].r == 0, "Path starts at origin")
    assert(path[#path].q == 5 and path[#path].r == 5, "Path ends at goal")
end
```

#### Test 2: Navigate Around Obstacle
```lua
function test_obstacle_avoidance()
    local grid = createTestGrid(10, 10, "floor")
    -- Create wall in middle
    for r = 0, 5 do
        grid:setTerrain(5, r, "wall")
    end
    
    local path = Pathfinding.findPath(grid, {q=0, r=2}, {q=9, r=2})
    
    assert(path ~= nil, "Path should be found around obstacle")
    -- Verify path doesn't cross wall
    for _, node in ipairs(path) do
        assert(node.q ~= 5 or node.r > 5, "Path should not cross wall")
    end
end
```

#### Test 3: Terrain Cost Calculation
```lua
function test_terrain_costs()
    local grid = createTestGrid(10, 10, "rough")  -- All rough terrain
    local path = Pathfinding.findPath(grid, {q=0, r=0}, {q=5, r=0})
    
    local totalCost = 0
    for i = 2, #path do  -- Skip first node (start)
        totalCost = totalCost + 2.0  -- Rough terrain = 2x
    end
    
    local calculatedCost = MovementSystem.getPathCost(path)
    assert(math.abs(calculatedCost - totalCost) < 0.01, "Cost should match")
end
```

#### Test 4: Unreachable Destination
```lua
function test_unreachable_goal()
    local grid = createTestGrid(10, 10, "floor")
    -- Surround goal with walls
    for i = 0, 5 do
        local nq, nr = HexMath.neighbor(5, 5, i)
        grid:setTerrain(nq, nr, "wall")
    end
    
    local path = Pathfinding.findPath(grid, {q=0, r=0}, {q=5, r=5})
    
    assert(path == nil, "Should return nil for unreachable goal")
end
```

#### Test 5: Performance Benchmark
```lua
function test_performance()
    local grid = createTestGrid(60, 60, "floor")
    -- Add some obstacles
    for i = 1, 50 do
        local q, r = math.random(0, 59), math.random(0, 59)
        grid:setTerrain(q, r, "wall")
    end
    
    local startTime = love.timer.getTime()
    local path = Pathfinding.findPath(grid, {q=0, r=0}, {q=59, r=59})
    local endTime = love.timer.getTime()
    
    local elapsed = (endTime - startTime) * 1000  -- ms
    print(string.format("Pathfinding took %.2f ms", elapsed))
    
    assert(elapsed < 20, "Should complete in < 20ms")
    assert(path ~= nil, "Should find path")
end
```

### Integration Tests

#### Test 6: Unit Movement Integration
```lua
function test_unit_movement_integration()
    -- Create battlefield with unit
    local battlefield = Battlefield.new(20, 20)
    local unit = battlefield:addUnit("soldier", 0, 0)
    unit.stats.tu = 50  -- Time units
    
    -- Plan movement
    local path = MovementSystem.planPath(unit.id, 10, 0)
    assert(path ~= nil, "Should find path")
    
    -- Execute movement
    local success = MovementSystem.executeMovement(unit.id, path)
    assert(success, "Movement should succeed")
    
    -- Verify unit position
    assert(unit.transform.q == 10, "Unit should be at goal")
    assert(unit.stats.tu < 50, "TUs should be consumed")
end
```

### Manual Testing Steps

1. **Launch Game:**
   ```bash
   lovec "engine"
   ```

2. **Enter Battlescape:**
   - Start new battle
   - Select unit

3. **Test Open Terrain:**
   - Click on distant hex
   - Verify path preview appears
   - Verify TU cost displayed
   - Execute movement
   - Confirm unit follows path

4. **Test Obstacles:**
   - Try to move past wall
   - Verify path goes around
   - Check TU cost increases

5. **Test Terrain Costs:**
   - Move through rough terrain
   - Verify slower movement (more TUs)
   - Compare with normal terrain

6. **Test Multi-Turn:**
   - Select distant goal beyond TU range
   - Verify path shows split
   - Execute first segment
   - End turn
   - Verify can continue

7. **Test Unreachable:**
   - Try to click on tile inside walls
   - Verify no path shown
   - Verify error message or indication

### Expected Results
- Path appears as green line overlay
- TU cost shown at goal hex
- Unit follows path exactly
- TU consumption matches preview
- Rough terrain takes 2x TUs
- Multi-turn paths highlighted differently
- Unreachable destinations show red X or no path

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use VS Code task: "Run XCOM Simple Game" (Ctrl+Shift+P → Run Task)

### Debugging Pathfinding

#### Enable Debug Output
```lua
-- In pathfinding.lua
local DEBUG = true

if DEBUG then
    print(string.format("[Pathfinding] Explored %d nodes, found path of length %d", 
          nodesExplored, pathLength))
end
```

#### Visualize Pathfinding
```lua
-- In renderer.lua
function drawDebugPathfinding(openSet, closedSet, currentPath)
    -- Draw explored nodes
    for node in closedSet do
        drawHexOutline(node.q, node.r, {100, 100, 100})
    end
    
    -- Draw open set
    for node in openSet do
        drawHexOutline(node.q, node.r, {200, 200, 0})
    end
    
    -- Draw current best path
    if currentPath then
        for node in currentPath do
            drawHexOutline(node.q, node.r, {0, 255, 0})
        end
    end
end
```

#### Console Commands
- `print(MovementSystem.debugPath(unitId))` - Print path details
- `print(Pathfinding.stats())` - Show pathfinding statistics

### Performance Profiling
```lua
-- Add to pathfinding.lua
local stats = {
    totalCalls = 0,
    totalTime = 0,
    totalNodesExplored = 0
}

function Pathfinding.findPath(...)
    local startTime = love.timer.getTime()
    stats.totalCalls = stats.totalCalls + 1
    
    -- ... pathfinding code ...
    
    local endTime = love.timer.getTime()
    stats.totalTime = stats.totalTime + (endTime - startTime)
    stats.totalNodesExplored = stats.totalNodesExplored + nodesExplored
end

function Pathfinding.getStats()
    return {
        avgTime = stats.totalTime / stats.totalCalls,
        avgNodes = stats.totalNodesExplored / stats.totalCalls,
        totalCalls = stats.totalCalls
    }
end
```

### Temporary Files
All temporary files MUST use system TEMP directory:
```lua
local tempDir = os.getenv("TEMP")
if not tempDir then
    error("Cannot access TEMP directory")
end

local pathDebugFile = tempDir .. "\\pathfinding_debug.txt"
local file = io.open(pathDebugFile, "w")
file:write("Pathfinding debug info\n")
file:close()
```

---

## Documentation Updates

### Files to Update

#### `wiki/API.md` - Add Pathfinding API Section
```markdown
### Pathfinding System

**Module:** `battle.utils.pathfinding`

#### findPath(grid, start, goal, costFunction)
Find shortest path on hex grid using A* algorithm.

**Parameters:**
- `grid` (HexSystem): The hex grid to pathfind on
- `start` (table): Starting hex coordinates {q, r}
- `goal` (table): Goal hex coordinates {q, r}
- `costFunction` (function): Optional custom cost function(fromQ, fromR, toQ, toR) → cost

**Returns:**
- `path` (table|nil): Array of hex coordinates from start to goal, or nil if unreachable

**Example:**
```lua
local Pathfinding = require("battle.utils.pathfinding")
local path = Pathfinding.findPath(hexSystem, {q=0, r=0}, {q=10, r=5})
if path then
    for i, node in ipairs(path) do
        print(string.format("Step %d: q=%d, r=%d, cost=%.1f", 
              i, node.q, node.r, node.cost))
    end
end
```
```

#### `wiki/FAQ.md` - Add Movement Section
```markdown
### How does unit movement work?

**Movement Points:**
- Each unit has Time Units (TUs) per turn
- Movement consumes TUs based on terrain type
- Normal terrain: 1 TU per hex
- Rough terrain: 2 TUs per hex
- Very rough terrain: 4 TUs per hex

**Pathfinding:**
- Game automatically finds shortest path around obstacles
- Path preview shows exact route and TU cost
- Green path: can reach this turn
- Yellow path: requires multiple turns
- Red X: unreachable destination

**Multi-Turn Movement:**
- If destination is beyond TU range, movement splits across turns
- Unit moves as far as possible first turn
- Continue movement next turn until reaching goal
```

#### Code Comments
Add comprehensive docstrings to all public functions:
```lua
--- Find shortest path on hex grid using A* algorithm.
-- Uses hex distance heuristic and terrain-based movement costs.
-- Returns nil if destination is unreachable.
--
-- @param grid HexSystem: The hex grid containing terrain data
-- @param start table: Starting hex {q=number, r=number}
-- @param goal table: Goal hex {q=number, r=number}
-- @param costFunc function|nil: Optional custom cost function
-- @return table|nil: Path as array of nodes {q, r, cost}, or nil
--
-- @usage
-- local path = Pathfinding.findPath(hexSystem, {q=0, r=0}, {q=5, r=5})
-- if path then
--     print("Path found with " .. #path .. " steps")
-- end
function Pathfinding.findPath(grid, start, goal, costFunc)
    -- Implementation
end
```

---

## Notes

### Design Decisions

**Why A* over Dijkstra?**
- A* uses heuristic to explore fewer nodes
- Hex distance provides admissible heuristic
- Significantly faster for typical game paths

**Why Binary Heap?**
- O(log n) insert and pop operations
- Better than array-based priority queue
- Essential for performance at 60x60 grids

**Why Separate Utility Module?**
- Pure functional code easier to test
- No game state dependencies
- Reusable for other grid-based features
- Can be tested in isolation

### Performance Considerations

**Optimization Techniques:**
1. **Node Pooling**: Reuse node objects to reduce GC
2. **Early Exit**: Stop as soon as goal reached
3. **Caching**: Cache recent paths for same start/goal
4. **Dirty Flags**: Only recalculate when terrain changes
5. **Spatial Hashing**: Use grid sectors for faster neighbor lookup

**When to Optimize:**
- Profile first, optimize second
- Focus on hot paths (called every frame)
- Batch pathfinding requests when possible

### Alternative Approaches

**Jump Point Search (JPS):**
- Faster than A* for uniform cost grids
- More complex implementation
- Consider for future optimization

**Flow Fields:**
- Better for many units to same goal
- Good for RTS-style group movement
- Overkill for turn-based tactics

**Nav Mesh:**
- Better for 3D games with complex terrain
- Unnecessary for 2D hex grid

---

## Blockers

**Resolved:**
- ✅ HexMath module exists with distance calculation
- ✅ HexSystem exists with terrain data structure

**Current:**
- ⬜ Terrain cost data needs to be defined
- ⬜ Movement system needs TU tracking enhancement

**Future:**
- ⬜ AI movement planning (depends on pathfinding)
- ⬜ Formation movement (depends on basic pathfinding)

---

## Dependencies

**Required (Must exist):**
- ✅ `engine/battle/utils/hex_math.lua` - Distance calculations
- ✅ `engine/battle/systems/hex_system.lua` - Grid structure
- ✅ `engine/battle/systems/movement_system.lua` - Movement execution

**Required (Must create):**
- ⬜ `engine/data/terrain_movement_costs.lua` - Cost definitions

**Enables (Depends on this):**
- ⬜ AI pathfinding decisions
- ⬜ Cover-to-cover movement
- ⬜ Formation movement
- ⬜ Attack of opportunity positioning

---

## Review Checklist

### Code Quality
- [ ] All functions have Google-style docstrings
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with nil checks
- [ ] Performance profiling done
- [ ] No memory leaks (tested with long sessions)

### Functionality
- [ ] Pathfinding finds optimal routes
- [ ] Terrain costs calculated correctly
- [ ] Obstacle avoidance works
- [ ] Unreachable destinations handled gracefully
- [ ] Multi-turn movement splits correctly

### Testing
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance targets met (< 5ms)
- [ ] Edge cases tested (unreachable, blocked, etc.)

### Documentation
- [ ] API documentation added to wiki/API.md
- [ ] FAQ updated with movement mechanics
- [ ] Code comments comprehensive
- [ ] README files updated if needed

### Integration
- [ ] No console warnings
- [ ] Works with existing movement system
- [ ] No breaking changes to other systems
- [ ] Backward compatible where possible

---

## Post-Completion

### What Worked Well
- (To be filled after completion)
- Binary heap implementation performed well
- Test-driven development caught edge cases early
- Visualization helped debug pathfinding issues

### What Could Be Improved
- (To be filled after completion)
- Initial estimates were accurate/inaccurate
- Could have optimized X earlier
- Should have tested Y more thoroughly

### Lessons Learned
- (To be filled after completion)
- Always profile before optimizing
- Visual debugging tools are invaluable
- Test edge cases from the start

### Performance Results
- (To be filled after completion)
- Average pathfinding time: X ms
- Max pathfinding time: Y ms
- Nodes explored per path: Z

### Next Steps
After completion, proceed to:
1. **TASK-016B**: Distance & Area Calculations
2. **TASK-016C**: Grid Query System
3. Integration with AI system (future task)

---

**END OF TASK DOCUMENT**
