# ECS Battle System API Reference

**Version:** 1.0  
**Last Updated:** 2025-01-XX  
**Status:** Core API Complete

---

## Overview

The Entity-Component-System (ECS) architecture is the foundation of the XCOM Simple tactical combat system. This document provides complete API reference for the ECS framework, components, systems, and utilities.

**Core Concept:** Battle entities (units, objects, effects) are collections of components. Systems process entities based on their component composition. This decouples game logic from entity types and enables flexible composition.

---

## Architecture Overview

```
Battle Battle System
    ├── Entity Manager
    │   ├── Create units (spawn in battle)
    │   ├── Create objects (terrain destructibles)
    │   └── Create effects (explosions, smoke)
    │
    ├── Component Registry
    │   ├── Position, Rotation
    │   ├── Damage, Health, Armor
    │   ├── Action, Movement
    │   ├── Visual, Effects
    │   └── Custom components
    │
    ├── System Pipeline
    │   ├── Input system (player commands)
    │   ├── Movement system (apply movement)
    │   ├── Action system (resolve attacks)
    │   ├── Damage system (apply damage)
    │   ├── Effect system (render effects)
    │   └── State system (turn management)
    │
    └── Query Engine
        ├── Find entities with components
        ├── Spatial queries (3D position)
        └── State queries (alive, acting, etc)
```

---

## Entity System

### Entity Creation

**Create Unit Entity**
```lua
function EntityManager.createUnit(unitData)
  -- Parameters:
  --   unitData: {
  --     id: string,              -- Unique ID
  --     classType: string,       -- "ranger", "specialist", etc
  --     team: string,            -- "player", "enemy"
  --     position: {x, y, z},     -- Hex coordinates + elevation
  --     health: number,          -- Current HP
  --     maxHealth: number,       -- Max HP
  --     armor: {type, value},    -- Armor class and points
  --     abilities: table,        -- Available actions
  --     inventory: table,        -- Items/weapons
  --     stats: table             -- Aim, will, mobility, etc
  --   }
  -- Returns: entity (table with all components)
  
  local entity = {
    id = unitData.id,
    type = "unit",
    components = {
      -- Position component
      position = {
        x = unitData.position[1],
        y = unitData.position[2],
        z = unitData.position[3]
      },
      -- Health component
      health = {
        current = unitData.health,
        max = unitData.maxHealth,
        armor = unitData.armor
      },
      -- Unit component
      unit = {
        class = unitData.classType,
        team = unitData.team,
        stats = unitData.stats,
        abilities = unitData.abilities,
        inventory = unitData.inventory
      },
      -- State component
      state = {
        status = "idle",           -- idle, acting, dead
        actionPoints = 20,
        energyPoints = 10,
        isControlled = false
      }
    }
  }
  
  EntityManager:register(entity)
  return entity
end
```

**Create Object Entity**
```lua
function EntityManager.createObject(objectData)
  -- Parameters:
  --   objectData: {
  --     id: string,                -- Unique ID
  --     objectType: string,        -- "crate", "terrain", "door"
  --     position: {x, y, z},       -- Hex coordinates
  --     destructible: boolean,     -- Can be destroyed
  --     health: number,            -- Current HP (if destructible)
  --     maxHealth: number,         -- Max HP (if destructible)
  --     blocksMovement: boolean,   -- Blocks unit movement
  --     blocksSight: boolean,      -- Blocks line of sight
  --     properties: table          -- Custom properties
  --   }
  -- Returns: entity (table with components)
  
  local entity = {
    id = objectData.id,
    type = "object",
    components = {
      position = {
        x = objectData.position[1],
        y = objectData.position[2],
        z = objectData.position[3]
      },
      object = {
        objectType = objectData.objectType,
        blocksMovement = objectData.blocksMovement,
        blocksSight = objectData.blocksSight,
        properties = objectData.properties or {}
      }
    }
  }
  
  if objectData.destructible then
    entity.components.health = {
      current = objectData.health,
      max = objectData.maxHealth
    }
  end
  
  EntityManager:register(entity)
  return entity
end
```

**Create Effect Entity**
```lua
function EntityManager.createEffect(effectData)
  -- Parameters:
  --   effectData: {
  --     id: string,              -- Unique ID
  --     effectType: string,      -- "explosion", "smoke", "fire", "lightning"
  --     position: {x, y, z},     -- Hex center
  --     duration: number,        -- Turns remaining
  --     radius: number,          -- Area effect radius in hexes
  --     intensity: number,      -- 1-10 (visual intensity)
  --     properties: table        -- Custom properties
  --   }
  -- Returns: entity (table with components)
  
  local entity = {
    id = effectData.id,
    type = "effect",
    components = {
      position = {
        x = effectData.position[1],
        y = effectData.position[2],
        z = effectData.position[3]
      },
      effect = {
        effectType = effectData.effectType,
        duration = effectData.duration,
        radius = effectData.radius,
        intensity = effectData.intensity,
        properties = effectData.properties or {}
      }
    }
  }
  
  EntityManager:register(entity)
  return entity
end
```

### Entity Lifecycle

**Register Entity**
```lua
function EntityManager:register(entity)
  -- Add entity to active entity list
  self.entities[entity.id] = entity
  self.entityCount = self.entityCount + 1
  print("[ECS] Registered entity: " .. entity.id .. " (type: " .. entity.type .. ")")
end
```

**Unregister Entity**
```lua
function EntityManager:unregister(entityId)
  -- Remove entity from active entity list
  if self.entities[entityId] then
    self.entities[entityId] = nil
    self.entityCount = self.entityCount - 1
    print("[ECS] Unregistered entity: " .. entityId)
    return true
  end
  return false
end
```

**Get Entity**
```lua
function EntityManager:getEntity(entityId)
  -- Returns: entity or nil if not found
  return self.entities[entityId]
end
```

**Get All Entities**
```lua
function EntityManager:getAllEntities()
  -- Returns: table of all active entities
  local entities = {}
  for id, entity in pairs(self.entities) do
    table.insert(entities, entity)
  end
  return entities
end
```

---

## Component System

### Core Components

**Position Component**
```lua
{
  x = 5,                  -- Hex X coordinate
  y = 7,                  -- Hex Y coordinate
  z = 1,                  -- Elevation level (0 = ground, 1+ = above)
  -- Methods:
  distance(otherPos) -> number,  -- Distance to other position
  direction(otherPos) -> number, -- Direction (0-5 for hex directions)
  neighbors() -> table           -- All 6 adjacent hex positions
}
```

**Health Component**
```lua
{
  current = 50,           -- Current HP
  max = 80,               -- Maximum HP
  armor = {
    type = "heavy",       -- light/medium/heavy/powered
    value = 20            -- Armor points
  },
  -- Methods:
  getPercent() -> number,        -- 0-100 health percentage
  takeDamage(amount) -> number,  -- Returns actual damage taken
  heal(amount) -> number         -- Returns actual healing done
}
```

**Unit Component**
```lua
{
  class = "ranger",       -- Unit class type
  team = "player",        -- player/enemy/civilian
  stats = {
    aim = 65,             -- Weapon accuracy (0-100)
    will = 50,            -- Psionic resistance
    mobility = 10,        -- Movement range
    strength = 8          -- Carry capacity
  },
  abilities = {...},      -- Available abilities/actions
  inventory = {...},      -- Weapons/items carried
  -- Methods:
  canAffordAction(actionId) -> boolean,
  executeAction(actionId, target) -> boolean
}
```

**State Component**
```lua
{
  status = "idle",        -- idle/acting/dead/unconscious
  actionPoints = 20,      -- Actions per turn (typical 20)
  energyPoints = 10,      -- Psi/special resource (typical 10)
  wounds = {...},         -- Active wounds
  statusEffects = {...},  -- Buffs/debuffs
  -- Methods:
  isDead() -> boolean,
  canAct() -> boolean,
  consumeActionPoints(cost) -> boolean
}
```

**Object Component**
```lua
{
  objectType = "crate",   -- Type of object
  blocksMovement = true,  -- Movement blocking
  blocksSight = false,    -- LoS blocking
  properties = {...}      -- Custom properties
  -- Methods:
  getProperty(key) -> value,
  setProperty(key, value) -> void
}
```

**Effect Component**
```lua
{
  effectType = "smoke",   -- explosion/smoke/fire/lightning
  duration = 3,           -- Turns remaining
  radius = 2,             -- Area radius in hexes
  intensity = 7,          -- Visual intensity 1-10
  properties = {...}      -- Custom properties
  -- Methods:
  affectsPosition(x, y, z) -> boolean,
  step() -> void          -- Advance one turn
}
```

### Component Access

**Add Component**
```lua
function Entity:addComponent(name, data)
  -- Add new component to entity
  self.components[name] = data
end
```

**Get Component**
```lua
function Entity:getComponent(name)
  -- Get component by name, returns nil if not present
  return self.components[name]
end
```

**Has Component**
```lua
function Entity:hasComponent(name)
  -- Check if entity has component
  return self.components[name] ~= nil
end
```

**Update Component**
```lua
function Entity:updateComponent(name, updates)
  -- Merge updates into existing component
  if self.components[name] then
    for key, value in pairs(updates) do
      self.components[name][key] = value
    end
  end
end
```

---

## System Pipeline

### System Execution Order

**Per-Turn Cycle:**
```
1. InputSystem        - Player selects action
2. MovementSystem     - Units move to new positions
3. ActionSystem       - Resolve attacks/abilities
4. DamageSystem       - Apply damage/wounds
5. EffectSystem       - Update effects (fire, smoke)
6. StateSystem        - Recovery, status, end-turn
```

### Base System Class

```lua
class System
  function System:init()
    self.enabled = true
    self.priority = 0
  end
  
  function System:execute(entities, deltaTime)
    -- Override in subclasses
    for id, entity in pairs(entities) do
      if self:qualifies(entity) then
        self:processEntity(entity, deltaTime)
      end
    end
  end
  
  function System:qualifies(entity)
    -- Override to check required components
    return true
  end
  
  function System:processEntity(entity, deltaTime)
    -- Override with actual logic
  end
end
```

### Movement System

**API**
```lua
function MovementSystem:moveEntity(entity, targetPos, path)
  -- Parameters:
  --   entity: The unit entity to move
  --   targetPos: {x, y, z} destination hex
  --   path: Array of hex positions from current to target
  -- Returns: success (boolean)
  
  if not self:isPathValid(path) then
    return false
  end
  
  -- Consume action points based on path length
  local apCost = #path
  if not entity:getComponent("state"):consumeActionPoints(apCost) then
    return false
  end
  
  -- Update position component
  local pos = entity:getComponent("position")
  pos.x = targetPos[1]
  pos.y = targetPos[2]
  pos.z = targetPos[3]
  
  -- Log movement
  BattleLog.add("Unit " .. entity.id .. " moved to " .. tostring(targetPos))
  return true
end

function MovementSystem:isPathValid(path)
  -- Check path doesn't cross obstacles
  for _, pos in ipairs(path) do
    if not self:isHexWalkable(pos) then
      return false
    end
  end
  return true
end

function MovementSystem:isHexWalkable(pos)
  -- Check if hex is traversable
  -- Consider: terrain, units, obstacles
  return true  -- Placeholder
end
```

### Action System

**API**
```lua
function ActionSystem:executeAction(actor, actionId, target)
  -- Parameters:
  --   actor: Entity performing action
  --   actionId: Action identifier (e.g., "shoot", "move")
  --   target: Target entity or position
  -- Returns: success (boolean)
  
  local action = self:getAction(actionId)
  if not action then return false end
  
  -- Check action is affordable
  local state = actor:getComponent("state")
  if state.actionPoints < action.apCost then
    return false
  end
  
  -- Consume AP
  state:consumeActionPoints(action.apCost)
  
  -- Execute action logic
  return action:execute(actor, target)
end
```

### Damage System

**API**
```lua
function DamageSystem:applyDamage(target, damage, source, damageType)
  -- Parameters:
  --   target: Entity taking damage
  --   damage: Damage amount
  --   source: Entity/object causing damage
  --   damageType: "physical", "psionic", "energy", etc
  -- Returns: actualDamage (number)
  
  local health = target:getComponent("health")
  if not health then return 0 end
  
  -- Calculate armor reduction
  local armorReduction = self:calculateArmorReduction(
    target, 
    damageType
  )
  
  -- Apply reduction
  local actualDamage = math.max(1, damage - armorReduction)
  
  -- Apply to health
  health:takeDamage(actualDamage)
  
  -- Create wound if bleeding
  if damageType == "physical" then
    self:createWound(target, source, damageType)
  end
  
  -- Log damage
  BattleLog.add(
    target.id .. " took " .. actualDamage .. " damage (reduced from " .. damage .. ")"
  )
  
  -- Check if dead
  if health.current <= 0 then
    self:killEntity(target)
  end
  
  return actualDamage
end

function DamageSystem:calculateArmorReduction(target, damageType)
  -- Calculate how much damage armor absorbs
  local armor = target:getComponent("health").armor
  if not armor then return 0 end
  
  -- Armor effectiveness varies by damage type
  local effectiveness = {
    physical = 0.8,   -- 80% effective against physical
    psionic = 0.3,    -- 30% effective against psionic
    energy = 0.5      -- 50% effective against energy
  }
  
  local effectiveness_value = effectiveness[damageType] or 0.5
  return math.floor(armor.value * effectiveness_value)
end
```

### Effect System

**API**
```lua
function EffectSystem:createEffect(effectType, centerPos, radius, duration)
  -- Parameters:
  --   effectType: "fire", "smoke", "gas", "electricity"
  --   centerPos: {x, y, z} center hex
  --   radius: Area radius in hexes
  --   duration: Turns until effect expires
  -- Returns: effect entity
  
  local effect = EntityManager.createEffect({
    id = generateEffectId(),
    effectType = effectType,
    position = centerPos,
    duration = duration,
    radius = radius,
    intensity = 5
  })
  
  -- Apply effect to units in radius
  local affectedUnits = self:getUnitsInRadius(centerPos, radius)
  for _, unit in ipairs(affectedUnits) do
    self:applyEffectToUnit(unit, effect)
  end
  
  return effect
end

function EffectSystem:getUnitsInRadius(centerPos, radius)
  -- Returns: array of units within radius hexes of center
  local units = {}
  local allEntities = EntityManager:getAllEntities()
  
  for _, entity in ipairs(allEntities) do
    if entity.type == "unit" then
      local pos = entity:getComponent("position")
      local distance = HexUtils.distance(centerPos, {pos.x, pos.y, pos.z})
      
      if distance <= radius then
        table.insert(units, entity)
      end
    end
  end
  
  return units
end

function EffectSystem:applyEffectToUnit(unit, effect)
  -- Apply effect consequences to unit
  local effectType = effect:getComponent("effect").effectType
  
  if effectType == "fire" then
    -- Apply fire damage, risk of spreading
    DamageSystem:applyDamage(unit, 5, effect, "fire")
    
  elseif effectType == "smoke" then
    -- Reduce accuracy
    unit:updateComponent("unit", {
      accuracyModifier = -0.2
    })
    
  elseif effectType == "gas" then
    -- Cause status effect (poisoned)
    StateSystem:addStatusEffect(unit, "poisoned", 3)
  end
end
```

---

## Query Engine

### Spatial Queries

**Get Units in Radius**
```lua
function QueryEngine:getUnitsInRadius(centerPos, radius)
  -- Parameters:
  --   centerPos: {x, y, z} center
  --   radius: Distance in hexes
  -- Returns: array of unit entities
  
  local units = {}
  local allEntities = EntityManager:getAllEntities()
  
  for _, entity in ipairs(allEntities) do
    if entity.type == "unit" then
      local pos = entity:getComponent("position")
      local distance = HexUtils.distance(
        {pos.x, pos.y, pos.z},
        centerPos
      )
      
      if distance <= radius then
        table.insert(units, entity)
      end
    end
  end
  
  return units
end
```

**Get Line of Sight**
```lua
function QueryEngine:getLineOfSight(fromPos, toPos)
  -- Parameters:
  --   fromPos: {x, y, z} origin
  --   toPos: {x, y, z} target
  -- Returns: array of hex positions in line, blocked (boolean)
  
  local line = HexUtils.getLine(fromPos, toPos)
  local blocked = false
  
  for _, pos in ipairs(line) do
    if not self:isHexVisible(pos) then
      blocked = true
      break
    end
  end
  
  return line, blocked
end

function QueryEngine:isHexVisible(pos)
  -- Check if position is blocked by objects/terrain
  local allEntities = EntityManager:getAllEntities()
  
  for _, entity in ipairs(allEntities) do
    if entity.type == "object" then
      local objPos = entity:getComponent("position")
      local blocksSight = entity:getComponent("object").blocksSight
      
      if blocksSight and objPos.x == pos[1] and objPos.y == pos[2] then
        return false
      end
    end
  end
  
  return true
end
```

### State Queries

**Get Entities by Type**
```lua
function QueryEngine:getEntitiesByType(entityType)
  -- Parameters:
  --   entityType: "unit", "object", "effect"
  -- Returns: array of matching entities
  
  local results = {}
  local allEntities = EntityManager:getAllEntities()
  
  for _, entity in ipairs(allEntities) do
    if entity.type == entityType then
      table.insert(results, entity)
    end
  end
  
  return results
end
```

**Get Active Units**
```lua
function QueryEngine:getActiveUnits()
  -- Returns: array of units that can act
  
  local units = self:getEntitiesByType("unit")
  local active = {}
  
  for _, unit in ipairs(units) do
    local state = unit:getComponent("state")
    if not state:isDead() and state:canAct() then
      table.insert(active, unit)
    end
  end
  
  return active
end
```

**Get Team Units**
```lua
function QueryEngine:getTeamUnits(teamId)
  -- Parameters:
  --   teamId: "player" or "enemy"
  -- Returns: array of team units
  
  local units = self:getEntitiesByType("unit")
  local team = {}
  
  for _, unit in ipairs(units) do
    if unit:getComponent("unit").team == teamId then
      table.insert(team, unit)
    end
  end
  
  return team
end
```

---

## Hex Coordinate System

### Hex Math Utilities

**Distance Between Hexes**
```lua
function HexUtils.distance(pos1, pos2)
  -- Parameters:
  --   pos1: {x, y, z} first hex
  --   pos2: {x, y, z} second hex
  -- Returns: integer distance in hexes
  
  -- Using offset coordinates
  local dx = math.abs(pos1[1] - pos2[1])
  local dy = math.abs(pos1[2] - pos2[2])
  local dz = math.abs(pos1[3] - pos2[3])
  
  -- Hex distance formula (offset)
  return (dx + dy + (dx + dy - math.abs(dx - dy)) / 2) / 2 + dz
end
```

**Get Hex Neighbors**
```lua
function HexUtils.getNeighbors(pos)
  -- Parameters:
  --   pos: {x, y, z} hex position
  -- Returns: array of 6 adjacent hex positions
  
  local neighbors = {}
  local x, y, z = pos[1], pos[2], pos[3]
  
  -- Offset coordinate hex neighbors (flat-top orientation)
  if y % 2 == 0 then
    -- Even row
    neighbors = {
      {x + 1, y, z}, {x + 1, y - 1, z}, {x, y - 1, z},
      {x - 1, y, z}, {x, y + 1, z}, {x + 1, y + 1, z}
    }
  else
    -- Odd row
    neighbors = {
      {x + 1, y, z}, {x, y - 1, z}, {x - 1, y - 1, z},
      {x - 1, y, z}, {x - 1, y + 1, z}, {x, y + 1, z}
    }
  end
  
  return neighbors
end
```

**Get Hex Direction**
```lua
function HexUtils.getDirection(fromPos, toPos)
  -- Parameters:
  --   fromPos: {x, y, z} origin
  --   toPos: {x, y, z} target
  -- Returns: direction 0-5 (clock-wise from north)
  
  -- Map direction to neighbor index
  local dx = toPos[1] - fromPos[1]
  local dy = toPos[2] - fromPos[2]
  
  -- Direction lookup based on offset
  -- Returns 0-5: north, northeast, southeast, south, southwest, northwest
  
  if dx > 0 and dy == 0 then return 1  -- NE
  elseif dx > 0 and dy > 0 then return 2  -- SE
  elseif dx == 0 and dy > 0 then return 3  -- S
  elseif dx < 0 and dy > 0 then return 4  -- SW
  elseif dx < 0 and dy == 0 then return 5  -- NW
  else return 0  -- N
  end
end
```

**Get Line Between Hexes**
```lua
function HexUtils.getLine(fromPos, toPos)
  -- Parameters:
  --   fromPos: {x, y, z} start
  --   toPos: {x, y, z} end
  -- Returns: array of hex positions along line
  
  -- Bresenham's line algorithm adapted for hex coordinates
  local line = {}
  local distance = HexUtils.distance(fromPos, toPos)
  
  for i = 0, distance do
    local t = distance > 0 and i / distance or 0
    local pos = {
      math.round(fromPos[1] + (toPos[1] - fromPos[1]) * t),
      math.round(fromPos[2] + (toPos[2] - fromPos[2]) * t),
      math.round(fromPos[3] + (toPos[3] - fromPos[3]) * t)
    }
    table.insert(line, pos)
  end
  
  return line
end
```

---

## Debugging and Logging

### Debug Utilities

**Log Entity State**
```lua
function EntityDebug.logEntity(entity)
  print("[ECS] Entity: " .. entity.id .. " (type: " .. entity.type .. ")")
  
  for componentName, componentData in pairs(entity.components) do
    print("  - " .. componentName .. ": " .. type(componentData))
    if componentName == "position" then
      print("    Position: (" .. componentData.x .. ", " .. componentData.y .. 
            ", " .. componentData.z .. ")")
    elseif componentName == "health" then
      print("    Health: " .. componentData.current .. "/" .. componentData.max)
    end
  end
end
```

**Log All Entities**
```lua
function EntityDebug.logAllEntities()
  print("[ECS] ========== Entity Dump ==========")
  local entities = EntityManager:getAllEntities()
  print("Total entities: " .. #entities)
  
  for _, entity in ipairs(entities) do
    EntityDebug.logEntity(entity)
  end
  
  print("[ECS] ==================================")
end
```

**Validate Entity Consistency**
```lua
function EntityDebug.validateEntity(entity)
  -- Check entity has required components
  if entity.type == "unit" then
    assert(entity:hasComponent("position"), "Unit missing position component")
    assert(entity:hasComponent("health"), "Unit missing health component")
    assert(entity:hasComponent("unit"), "Unit missing unit component")
    assert(entity:hasComponent("state"), "Unit missing state component")
  end
end
```

---

## Performance Notes

- **Entity Pooling**: Pre-allocate entities for common types (units, effects)
- **Component Caching**: Cache frequently accessed components
- **Query Optimization**: Use spatial partitioning for radius queries
- **System Profiling**: Time each system phase to detect bottlenecks
- **Batch Operations**: Group entity updates for cache efficiency

---

## Example Usage

### Complete Battle Initialization

```lua
function initializeBattle()
  -- Create entity manager
  EntityManager = EntityManager:new()
  
  -- Create player unit
  local playerUnit = EntityManager.createUnit({
    id = "player_1",
    classType = "ranger",
    team = "player",
    position = {5, 5, 0},
    health = 80,
    maxHealth = 80,
    armor = {type = "heavy", value = 20},
    stats = {aim = 65, will = 50, mobility = 10}
  })
  
  -- Create enemy unit
  local enemyUnit = EntityManager.createUnit({
    id = "enemy_1",
    classType = "sectoid",
    team = "enemy",
    position = {10, 5, 0},
    health = 40,
    maxHealth = 40,
    armor = {type = "light", value = 5},
    stats = {aim = 55, will = 30, mobility = 8}
  })
  
  -- Create terrain object
  local crate = EntityManager.createObject({
    id = "obj_crate_1",
    objectType = "crate",
    position = {7, 5, 0},
    destructible = true,
    health = 20,
    maxHealth = 20,
    blocksMovement = true,
    blocksSight = true
  })
  
  print("[Battle] Initialized with " .. EntityManager.entityCount .. " entities")
end

function executeTurn()
  -- Get all active units
  local units = QueryEngine:getActiveUnits()
  
  for _, unit in ipairs(units) do
    print("[Turn] Processing " .. unit.id)
    
    -- Get available actions
    local actions = unit:getComponent("unit").abilities
    
    -- Execute AI or player input
    if unit:getComponent("unit").team == "enemy" then
      AISystem:selectAction(unit)
    else
      -- Wait for player input
      PlayerInputSystem:waitForInput(unit)
    end
  end
end
```

---

## References

- Hex coordinate system: "axial" or "offset" coordinate math
- ECS pattern: Design Patterns for Game Systems
- System architecture: Data-Oriented Design principles
- Performance: Profile-guided optimization

