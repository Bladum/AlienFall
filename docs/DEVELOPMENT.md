# Development Guide

## Getting Started with Development

### Prerequisites
- **Love2D 12.0+** installed and added to system PATH
- **VS Code** (recommended IDE)
- **Git** for version control
- **Basic Lua knowledge** (5.1+ syntax)

### Project Structure

```
c:\Users\tombl\Documents\Projects\
├── engine/                          -- Main game engine (Alien Fall)
│   ├── main.lua                    -- Entry point
│   ├── conf.lua                    -- Love2D configuration
│   ├── systems/                    -- Core game systems
│   ├── modules/                    -- Game states/modules
│   ├── utils/                      -- Utility functions
│   ├── data/                       -- Game data files
│   └── assets/                     -- Images, sounds, fonts
├── docs/                           -- Documentation
│   ├── API.md                      -- API reference
│   ├── FAQ.md                      -- Frequently asked questions
│   ├── DEVELOPMENT.md              -- This file
│   └── ...                         -- Additional documentation
├── mods/                           -- Mod content
│   └── core/                       -- Core mod data
├── tasks/                          -- Task management
│   ├── tasks.md                    -- Task list
│   ├── TASK_TEMPLATE.md           -- Template for new tasks
│   ├── TODO/                       -- Active tasks
│   └── DONE/                       -- Completed tasks
├── tests/                          -- Test suites
│   └── ...                         -- Test files
├── .vscode/                        -- VS Code settings
│   └── tasks.json                  -- Build/run tasks
├── icon.png                        -- Game icon
└── run_xcom.bat                   -- Quick launch script
```

---

## Running the Game

### Method 1: Using Love2D Directly (Recommended)
```bash
# From project root (with console output)
lovec "engine"
```

### Method 2: Using Batch File
```bash
# From project root
.\run_xcom.bat
```

### Method 3: Using VS Code Task
1. Press `Ctrl+Shift+P`
2. Type "Run Task"
3. Select "Run Alien Fall Game"

**Note:** All methods automatically enable the Love2D console for debugging output.

---

## Debugging

### Console Output
The game runs with `t.console = true` enabled in `conf.lua`, providing a console window for debug output.

**Use print statements liberally:**
```lua
print("[ModuleName] Debug message: " .. tostring(value))
```

**Common debug patterns:**
```lua
-- Log function entry
print("[Module:function] Entering with params:", param1, param2)

-- Log state changes
print("[StateManager] Switching from " .. oldState .. " to " .. newState)

-- Log errors
print("[ERROR] " .. errorMessage)
```

### On-Screen Debug Info
Display debug info directly on screen:
```lua
function love.draw()
    -- Your normal rendering
    
    -- Debug overlay
    love.graphics.setColor(1, 1, 0) -- Yellow text
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Memory: " .. collectgarbage("count") .. " KB", 10, 30)
end
```

### Error Handling
Always use `pcall` for risky operations:
```lua
local success, result = pcall(function()
    -- Risky code here
    return someValue
end)

if not success then
    print("[ERROR] Operation failed: " .. result)
    -- Handle error gracefully
end
```

---

## Temporary Files - MANDATORY RULES

**CRITICAL:** All temporary files MUST be created in the system TEMP directory.

### Getting the TEMP Directory

**Option 1: System TEMP (Windows)**
```lua
local tempDir = os.getenv("TEMP") or os.getenv("TMP")
local tempFile = tempDir .. "\\myfile.tmp"
```

**Option 2: Love2D Save Directory**
```lua
local saveDir = love.filesystem.getSaveDirectory()
-- This is typically: C:\Users\<username>\AppData\Roaming\LOVE\<identity>
```

### Never Create Temp Files In:
- ❌ Project directories
- ❌ Engine folder
- ❌ Current working directory
- ❌ Relative paths without checking

### Example: Creating Temp Files
```lua
local function createTempFile(filename, content)
    local tempDir = os.getenv("TEMP")
    if not tempDir then
        print("[ERROR] Cannot find TEMP directory")
        return nil
    end
    
    local filepath = tempDir .. "\\" .. filename
    local file = io.open(filepath, "w")
    if not file then
        print("[ERROR] Cannot create temp file: " .. filepath)
        return nil
    end
    
    file:write(content)
    file:close()
    
    print("[DEBUG] Created temp file: " .. filepath)
    return filepath
end
```

---

## Task Management System

### Creating a New Task

When you or the AI agent plans new work, follow this process:

1. **Copy the template:**
   ```bash
   copy tasks\TASK_TEMPLATE.md tasks\TODO\TASK-001-feature-name.md
   ```

2. **Fill in ALL sections:**
   - Overview and purpose
   - Requirements and acceptance criteria
   - Detailed implementation plan
   - Testing strategy
   - Documentation updates needed

3. **Update tasks.md:**
   - Add entry to appropriate priority section
   - Include task ID, name, status, files affected

4. **Begin work:**
   - Move task from TODO to IN_PROGRESS
   - Update status in tasks.md
   - Commit changes

5. **Complete task:**
   - Run all tests
   - Update documentation
   - Move to DONE folder
   - Update tasks.md with completion date

### Task Template Sections

Every task must include:
- ✅ **Overview** - What and why
- ✅ **Purpose** - Problem being solved
- ✅ **Requirements** - Functional, technical, acceptance criteria
- ✅ **Plan** - Step-by-step implementation with file list
- ✅ **Testing Strategy** - How to verify it works
- ✅ **How to Run/Debug** - Love2D console instructions
- ✅ **Documentation Updates** - What docs need updating
- ✅ **Review Checklist** - Quality assurance

### Agent Responsibilities

**When planning work:**
1. Create comprehensive task document using template
2. Break down into clear steps with file paths
3. Estimate time for each step
4. Add to tasks.md tracking file
5. Update task status as work progresses

**When completing work:**
1. Verify all acceptance criteria met
2. Run tests and verify in Love2D console
3. Update all affected documentation
4. Move task to DONE folder
5. Update tasks.md with completion info
6. Fill in "What Worked Well" and "Lessons Learned"

---

## Code Standards

### Lua Best Practices

**Always use local variables:**
```lua
-- ✅ Good
local myVariable = "value"

-- ❌ Bad
myVariable = "value"  -- Creates global
```

**Naming conventions:**
```lua
-- Variables and functions: camelCase
local playerHealth = 100
function calculateDamage(attacker, defender)

-- Constants: UPPER_CASE
local MAX_HEALTH = 100
local DEFAULT_SPEED = 5

-- Modules: PascalCase
local StateManager = require("systems.state_manager")
```

**Module structure:**
```lua
-- ModuleName
-- Brief description

local ModuleName = {}

-- Module implementation

return ModuleName
```

### Love2D Specific

**Callbacks:**
```lua
function love.load()
    -- Initialize resources
end

function love.update(dt)
    -- Update game logic
end

function love.draw()
    -- Render graphics
end

function love.keypressed(key)
    -- Handle keyboard input
end

function love.mousepressed(x, y, button)
    -- Handle mouse input
end
```

**Performance optimization:**
```lua
-- Reuse objects instead of creating new ones
local tempVector = {x = 0, y = 0}

function updatePosition(entity, dx, dy)
    tempVector.x = entity.x + dx
    tempVector.y = entity.y + dy
    -- Use tempVector instead of creating {x = ..., y = ...}
end

-- Use ipairs for arrays, pairs for hash tables
for i, item in ipairs(array) do
    -- Process indexed array
end

for key, value in pairs(hashTable) do
    -- Process hash table
end
```

---

## Architecture

### ECS (Entity Component System) Pattern

AlienFall uses ECS architecture for the battle system to provide modularity, performance, and maintainability.

#### Components (Pure Data)
Components are pure data structures with no logic:

```lua
-- components/transform.lua
local Transform = {
    q = 0, r = 0,        -- Hex coordinates
    facing = 0           -- Direction (0-5)
}
return Transform

-- components/movement.lua
local Movement = {
    currentAP = 10,      -- Current action points
    maxAP = 10,          -- Maximum action points
    moveCost = 2,        -- AP cost per hex
    rotateCost = 1       -- AP cost per rotation
}
return Movement
```

#### Systems (Pure Logic)
Systems contain all the logic and operate on components:

```lua
-- systems/movement_system.lua
local MovementSystem = {}

function MovementSystem.tryMove(unit, hexSystem, targetQ, targetR)
    local movement = unit:getComponent("movement")
    local transform = unit:getComponent("transform")

    if not movement:canAfford(2) then
        return false
    end

    -- Movement logic here
    transform.q, transform.r = targetQ, targetR
    movement:spendAP(2)

    return true
end

return MovementSystem
```

#### Entities (Composition)
Entities are created by composing components:

```lua
local UnitEntity = require("systems.battle.entities.unit_entity")

local soldier = UnitEntity.new({
    q = 10, r = 10,        -- Position
    facing = 0,            -- Direction
    teamId = 1,            -- Team
    maxHP = 100,           -- Health
    maxAP = 10,            -- Action points
    visionRange = 8        -- Vision
})
```

#### Benefits of ECS
- **Modularity**: Easy to add/remove features
- **Performance**: Cache-friendly data layout
- **Testability**: Pure functions are easy to test
- **Flexibility**: Dynamic component composition

### Hexagonal Grid System

#### Coordinate Systems
- **Offset**: (col, row) - Screen coordinates
- **Axial**: (q, r) - Hex grid coordinates
- **Cube**: (x, y, z) - 3D cube coordinates for calculations

#### Even-Q Vertical Offset Layout
```
   / \     / \
  |0,0|   |2,0|
   \ / \ / \ /
    |1,0|   |3,0|
   / \ / \ / \ /
  |0,1|   |2,1|
   \ /     \ /
```

#### Key Functions
```lua
-- Convert coordinates
local q, r = HexMath.offsetToAxial(col, row)
local col, row = HexMath.axialToOffset(q, r)

-- Get neighbors
local neighbors = HexMath.getNeighbors(q, r)

-- Calculate distance
local distance = HexMath.distance(q1, r1, q2, r2)

-- Convert to pixels
local x, y = HexMath.hexToPixel(q, r, 24)
```

### Battle System Integration

#### Debug Controls
- **F8**: Toggle fog of war
- **F9**: Toggle hex grid overlay
- **F10**: Toggle debug mode

#### System Initialization
```lua
-- In battlescape.lua
function Battlescape:enter()
    self.hexSystem = HexSystem.new(60, 60, 24)
    Debug.setEnabled(false)
    Debug.setHexGridEnabled(false)
    Debug.setFOWEnabled(true)
end
```

#### Key Handlers
```lua
function Battlescape:keypressed(key)
    if key == "f8" then
        Debug.toggleFOW()
    elseif key == "f9" then
        Debug.toggleHexGrid()
    elseif key == "f10" then
        Debug.toggle()
    end
end
```

#### Rendering
```lua
function Battlescape:draw()
    -- Draw existing game
    -- ...

    -- Draw hex overlay if enabled
    if Debug.isHexGridEnabled() then
        HexSystem.drawHexGrid(self.hexSystem, self.camera)
    end

    -- Draw vision cones if debug enabled
    if Debug.isDebugEnabled() then
        VisionSystem.drawVisionCones(self.hexSystem, self.camera)
    end
end
```

### File Organization

#### Battle System Structure
```
engine/systems/battle/
├── components/          # Pure data (5 files)
├── systems/            # Pure logic (3 files)
├── entities/           # Composition (1 file)
├── utils/              # Utilities (2 files)
└── tests/              # Test suites (2 files)
```

#### Key Files
- `systems/battle/utils/hex_math.lua` - Coordinate math
- `systems/battle/systems/hex_system.lua` - Grid management
- `systems/battle/systems/movement_system.lua` - Movement logic
- `systems/battle/systems/vision_system.lua` - LOS and vision
- `systems/battle/entities/unit_entity.lua` - Unit creation
- `systems/battle/utils/debug.lua` - Debug tools

### Performance Considerations

#### Memory Management
- Reuse objects instead of creating new ones
- Use object pools for frequently created objects
- Avoid global state pollution

#### Rendering Optimization
- Only render visible hexes
- Use batch rendering for multiple hexes
- Cache calculated positions

#### Pathfinding Optimization
- Use A* with admissible heuristics
- Cache paths for repeated calculations
- Limit search space for performance

---

## Testing

### Manual Testing
1. Run game with `love engine`
2. Check console for errors/warnings
3. Test all affected features
4. Verify no crashes or freezes
5. Check memory usage doesn't grow excessively

### Test Cases
Document test cases in task files:
```markdown
### Test Case 1: Button Click
**Steps:**
1. Launch game
2. Click "Start Game" button
3. Verify transition to geoscape

**Expected:** Game transitions smoothly with no errors in console
**Actual:** [Fill in during testing]
**Status:** PASS/FAIL
```

### Debugging Tips
- Use `print()` liberally during development
- Check Love2D console for errors and warnings
- Use `love.graphics.print()` for on-screen debug display
- Monitor FPS and memory usage
- Test on clean save files

---

## Documentation Requirements

### When to Update Documentation

Update documentation when:
- Adding new features
- Modifying existing APIs
- Fixing bugs that affect usage
- Changing project structure
- Adding new modules or systems

### Files to Update

**For API changes:**
- `docs/API.md` - Add/update function documentation

**For features:**
- `docs/FAQ.md` - Add common questions
- `README.md` - Update if user-facing

**For development:**
- `docs/DEVELOPMENT.md` - Update workflow changes
- Task files - Document decisions and lessons

**For code:**
- Inline comments for complex logic
- Module headers describing purpose
- Function comments with parameters and returns

---

## Git Workflow

### Commit Messages
```
[Component] Brief description

Detailed explanation if needed

- Change 1
- Change 2

Closes: TASK-001
```

### Branch Strategy
- `main` - Stable releases
- `develop` - Active development
- `feature/name` - New features
- `bugfix/name` - Bug fixes

---

## Common Issues

### Game Won't Start
1. Verify Love2D is installed: `love --version`
2. Check console for error messages
3. Verify `main.lua` exists in engine folder
4. Check `conf.lua` is properly formatted

### Module Not Found
```
Error: module 'systems.state_manager' not found
```
- Verify file exists: `engine/systems/state_manager.lua`
- Check require path uses dots not slashes
- Ensure file returns module table

### Console Not Showing
- Verify `conf.lua` has `t.console = true`
- On Windows, console should appear automatically
- Check Love2D version (12.0+ required)

---

## Resources

- **Love2D Documentation:** https://love2d.org/wiki/
- **Lua 5.1 Manual:** https://www.lua.org/manual/5.1/
- **Project Docs:** `docs/` folder
- **Task System:** `tasks/tasks.md`
- **API Reference:** `docs/API.md`

---

## Quick Reference

### Run Game
```bash
lovec "engine"
```

### Create Task
```bash
copy tasks\TASK_TEMPLATE.md tasks\TODO\TASK-XXX-name.md
```

### Get Temp Dir
```lua
local temp = os.getenv("TEMP")
```

### Debug Print
```lua
print("[Module] Message: " .. tostring(value))
```

### Error Handling
```lua
local ok, err = pcall(riskyFunction)
if not ok then print("[ERROR] " .. err) end
```
