# Unit System Quick Reference Card

## Installation

```lua
-- In main.lua, at the top:
local UnitSystem = require "unit_system"
local Unit = UnitSystem.Unit
local UnitManager = UnitSystem.UnitManager
local UnitRenderer = UnitSystem.UnitRenderer
local UnitFactory = UnitSystem.UnitFactory
```

## Initialization (in love.load)

```lua
-- Initialize systems
UnitManager:init()
UnitRenderer:init(g3d)

-- Load textures
UnitRenderer:loadTexture("player", "tiles/player.png")
UnitRenderer:loadTexture("enemy", "tiles/enemy.png")
UnitRenderer:loadTexture("default", "tiles/player.png")
```

## Creating Units

```lua
-- Player units
local soldier = UnitFactory.createPlayerSoldier(x, z)
local sniper = UnitFactory.createPlayerSniper(x, z)
local heavy = UnitFactory.createPlayerHeavy(x, z)

-- Enemy units
local alien = UnitFactory.createEnemy(x, z)
local elite = UnitFactory.createEnemyElite(x, z)

-- Neutral units
local civilian = UnitFactory.createCivilian(x, z)

-- Add to manager
UnitManager:addUnit(unit)
```

## Unit Properties

```lua
-- Position
unit.x, unit.y, unit.z         -- 3D coordinates
unit.gridX, unit.gridY          -- Grid coordinates
unit.angle                      -- Facing direction (radians)

-- Stats
unit.health                     -- Current HP
unit.maxHealth                  -- Maximum HP
unit.armor                      -- Damage reduction
unit.damage                     -- Attack damage
unit.actionPoints               -- Current AP
unit.maxActionPoints            -- Max AP per turn

-- Identification
unit.faction                    -- "player", "enemy", "neutral"
unit.unitType                   -- "soldier", "alien", etc.
unit.name                       -- Display name

-- Rendering
unit.model                      -- G3D model
unit.visible                    -- Render flag
unit.texture                    -- Sprite texture
unit.scaleX, scaleY, scaleZ     -- Model scale
```

## Unit Methods

```lua
-- Position management
unit:setPosition(x, y, z)
unit:updateGridPosition()

-- Combat
local damage, alive = unit:takeDamage(amount)
unit:heal(amount)
local percentage = unit:getHealthPercentage()  -- 0.0 to 1.0
local alive = unit:isAlive()

-- Turn-based
local canAct = unit:hasActionPoints(cost)
local success = unit:useActionPoint(cost)
unit:resetActionPoints()

-- Visual
local color = unit:getFactionColor()  -- {r, g, b}
```

## Unit Manager Methods

```lua
-- Initialization
UnitManager:init()

-- Unit management
UnitManager:addUnit(unit)
UnitManager:removeUnit(unit)

-- Queries
local unit = UnitManager:getUnitAt(gridX, gridY)
local units = UnitManager:getUnitsInRadius(x, z, radius, excludeUnit)
local visible = UnitManager:getVisibleUnits(x, z, range, losFunc)

-- Selection
UnitManager:selectUnit(unit)
UnitManager:setActiveUnit(unit)

-- Player unit switching
UnitManager:nextPlayerUnit()
UnitManager:previousPlayerUnit()

-- Turn management
UnitManager:startNewTurn()
UnitManager:updateAll(dt)

-- Access
UnitManager.units               -- All units
UnitManager.playerUnits         -- Player faction
UnitManager.enemyUnits          -- Enemy faction
UnitManager.neutralUnits        -- Neutral faction
UnitManager.activeUnit          -- Active player unit
UnitManager.selectedUnit        -- Selected unit (mouse)
```

## Unit Renderer Methods

```lua
-- Initialization
UnitRenderer:init(g3d)

-- Texture management
local texture = UnitRenderer:loadTexture(name, path)

-- Model creation
local model = UnitRenderer:createUnitModel(unit, cameraUnit, isNight)
UnitRenderer:updateAllModels(cameraUnit, isNight)

-- Rendering
UnitRenderer:drawUnits(cameraUnit, hasLineOfSightFunc)

-- Utility
local brightness = UnitRenderer:calculateBrightness(distance, isNight)
```

## Game Loop Integration

```lua
function love.load()
    -- Initialize unit system
    UnitManager:init()
    UnitRenderer:init(g3d)
    UnitRenderer:loadTexture("player", "tiles/player.png")
    UnitRenderer:loadTexture("enemy", "tiles/enemy.png")
    
    -- Create units
    for i = 1, 5 do
        local unit = UnitFactory.createPlayerSoldier(10 + i*2, 10)
        UnitManager:addUnit(unit)
    end
    
    -- Update unit models
    UnitRenderer:updateAllModels(UnitManager.activeUnit, isNight)
end

function love.update(dt)
    -- Update all units
    UnitManager:updateAll(dt)
    
    -- ... rest of game logic
end

function love.draw()
    -- ... draw terrain, walls, etc.
    
    -- Draw all units
    UnitRenderer:drawUnits(UnitManager.activeUnit, hasLineOfSight)
    
    -- ... draw UI
end
```

## Common Patterns

### Combat System
```lua
function attackUnit(attacker, target)
    if not attacker:hasActionPoints(1) then return false end
    if not attacker:isAlive() or not target:isAlive() then return false end
    
    attacker:useActionPoint(1)
    local damage, stillAlive = target:takeDamage(attacker.damage)
    
    print(attacker.name .. " dealt " .. damage .. " to " .. target.name)
    return true
end
```

### Movement System
```lua
function moveUnit(unit, targetX, targetZ)
    if not unit:hasActionPoints(1) then return false end
    if not isWalkable(maze[targetZ][targetX].terrain) then return false end
    if UnitManager:getUnitAt(targetX, targetZ) then return false end
    
    unit:useActionPoint(1)
    unit:setPosition(targetX, 0.25, targetZ)
    return true
end
```

### Turn Management
```lua
function startPlayerTurn()
    for _, unit in ipairs(UnitManager.playerUnits) do
        unit:resetActionPoints()
    end
end

function endPlayerTurn()
    -- Start enemy turn
    for _, enemy in ipairs(UnitManager.enemyUnits) do
        enemy:resetActionPoints()
        runEnemyAI(enemy)
    end
end
```

### Unit Selection
```lua
function love.mousepressed(x, y, button)
    if button == 1 and selectedEnemy then
        UnitManager:selectUnit(selectedEnemy)
        print("Selected:", selectedEnemy.name)
    end
end

function love.keypressed(key)
    if key == "tab" then
        UnitManager:nextPlayerUnit()
        updateCameraForActiveUnit()
    end
end
```

## Faction Colors

```lua
-- Player: Blue (0.3, 0.3, 1.0)
-- Enemy:  Red  (1.0, 0.3, 0.3)
-- Neutral: Gray (0.7, 0.7, 0.7)

local color = unit:getFactionColor()
-- Returns: {r = ..., g = ..., b = ...}
```

## Unit Stats by Type

| Unit Type      | Health | Armor | Damage | AP | Special         |
|----------------|--------|-------|--------|----|-----------------|
| Soldier        | 100    | 20    | 25     | 2  | Balanced        |
| Sniper         | 80     | 10    | 40     | 2  | High damage     |
| Heavy          | 120    | 30    | 20     | 1  | Tank, slow      |
| Alien          | 80     | 10    | 20     | 2  | Standard enemy  |
| Elite Alien    | 120    | 25    | 30     | 3  | Strong enemy    |
| Civilian       | 50     | 0     | 0      | 1  | Non-combatant   |

## Troubleshooting

### Units not visible?
```lua
-- Check texture loading
print("Textures:", UnitRenderer.sharedTextures)

-- Check unit visibility
print("Unit visible:", unit.visible)
print("Unit alive:", unit:isAlive())

-- Update models
UnitRenderer:updateAllModels(UnitManager.activeUnit, isNight)
```

### Camera not following active unit?
```lua
-- Ensure active unit is set
print("Active unit:", UnitManager.activeUnit)

-- Update camera position
local unit = UnitManager.activeUnit
if unit then
    g3d.camera.position = {unit.x, unit.y + 0.5, unit.z}
end
```

### Units all the same color?
```lua
-- Check faction assignment
for _, unit in ipairs(UnitManager.units) do
    print(unit.name, unit.faction)
end

-- Ensure textures are set
for _, unit in ipairs(UnitManager.units) do
    if unit.faction == "player" then
        unit.texture = playerTexture
    elseif unit.faction == "enemy" then
        unit.texture = enemyTexture
    end
end
```

## Performance Tips

1. **Batch Updates**: Update all unit models only when lighting changes
   ```lua
   if lightingChanged then
       UnitRenderer:updateAllModels(camera, isNight)
   end
   ```

2. **Visibility Culling**: Only draw visible units
   ```lua
   -- Done automatically in UnitRenderer:drawUnits()
   ```

3. **Texture Caching**: Load textures once, reuse for all units
   ```lua
   -- Done automatically by UnitRenderer
   ```

4. **Distance Sorting**: Sort by distance before rendering
   ```lua
   -- Done automatically in UnitRenderer:drawUnits()
   ```

## File Structure

```
3d_maze_demo/
├── main.lua                          (Game logic)
├── unit_system.lua                   (Unit system module)
├── UNIT_SYSTEM_IMPROVEMENTS.md       (Full documentation)
├── MIGRATION_GUIDE.md                (Integration steps)
├── UNIT_SYSTEM_EXAMPLES.md           (Usage examples)
├── UNIT_SYSTEM_SUMMARY.md            (Overview)
├── UNIT_SYSTEM_DIAGRAMS.md           (Visual diagrams)
└── UNIT_SYSTEM_QUICK_REFERENCE.md    (This file)
```

## Next Steps

1. ✓ Integrate `unit_system.lua` into `main.lua`
2. ✓ Replace old unit creation with `UnitFactory`
3. ✓ Update rendering to use `UnitRenderer`
4. ✓ Add combat system
5. ✓ Implement turn-based mechanics
6. Add abilities and status effects
7. Create enemy AI
8. Add health bars and UI

## Support

For detailed information, see:
- **Design**: `UNIT_SYSTEM_IMPROVEMENTS.md`
- **Migration**: `MIGRATION_GUIDE.md`
- **Examples**: `UNIT_SYSTEM_EXAMPLES.md`
- **Diagrams**: `UNIT_SYSTEM_DIAGRAMS.md`

---

**Quick Start Checklist:**
- [ ] Add `require "unit_system"` to main.lua
- [ ] Call `UnitManager:init()` in love.load()
- [ ] Call `UnitRenderer:init(g3d)` in love.load()
- [ ] Load textures with `UnitRenderer:loadTexture()`
- [ ] Create units with `UnitFactory.create...()`
- [ ] Add units with `UnitManager:addUnit()`
- [ ] Update with `UnitManager:updateAll(dt)`
- [ ] Render with `UnitRenderer:drawUnits()`
- [ ] Test and enjoy! 🚀
