# Unit System Examples and Advanced Features

## Basic Usage Examples

### Example 1: Creating and Managing Units

```lua
local UnitSystem = require "unit_system"
local UnitManager = UnitSystem.UnitManager
local UnitFactory = UnitSystem.UnitFactory
local UnitRenderer = UnitSystem.UnitRenderer

-- Initialize systems
UnitManager:init()
UnitRenderer:init(g3d)

-- Load textures
UnitRenderer:loadTexture("player", "tiles/player.png")
UnitRenderer:loadTexture("enemy", "tiles/enemy.png")

-- Create player squad
local squad = {
    UnitFactory.createPlayerSoldier(10, 10),
    UnitFactory.createPlayerSniper(12, 10),
    UnitFactory.createPlayerHeavy(14, 10)
}

for _, unit in ipairs(squad) do
    UnitManager:addUnit(unit)
end

-- Create enemy patrol
for i = 1, 5 do
    local enemy = UnitFactory.createEnemy(50 + i * 2, 50)
    UnitManager:addUnit(enemy)
end
```

### Example 2: Turn-Based Combat

```lua
-- Combat system
local function performAttack(attacker, target)
    if not attacker:hasActionPoints(1) then
        print("Not enough action points!")
        return false
    end
    
    -- Calculate distance
    local dx = target.x - attacker.x
    local dz = target.z - attacker.z
    local distance = math.sqrt(dx * dx + dz * dz)
    
    -- Check range (weapon range could be a unit property)
    local maxRange = 10
    if distance > maxRange then
        print("Target out of range!")
        return false
    end
    
    -- Check line of sight
    if not hasLineOfSight(attacker.x, attacker.z, target.x, target.z) then
        print("No line of sight!")
        return false
    end
    
    -- Perform attack
    attacker:useActionPoint(1)
    
    -- Calculate hit chance (basic example)
    local hitChance = 0.7 - (distance / maxRange) * 0.3
    if math.random() < hitChance then
        local damage = attacker.damage
        local actualDamage, stillAlive = target:takeDamage(damage)
        
        print(attacker.name .. " hit " .. target.name .. " for " .. actualDamage .. " damage!")
        
        if not stillAlive then
            print(target.name .. " was eliminated!")
        end
        
        return true
    else
        print(attacker.name .. " missed!")
        return false
    end
end

-- Example usage in game loop
function handleCombatInput()
    if love.mouse.isDown(1) and selectedEnemy then
        local attacker = UnitManager.activeUnit
        local target = selectedEnemy
        
        if attacker and target and attacker.faction == "player" then
            performAttack(attacker, target)
        end
    end
end
```

### Example 3: Unit Movement with Action Points

```lua
-- Movement system
local function moveUnit(unit, targetGridX, targetGridY)
    if not unit:hasActionPoints(1) then
        print("Not enough action points to move!")
        return false
    end
    
    -- Check if target is walkable
    if not isWalkable(maze[targetGridY][targetGridX].terrain) then
        print("Cannot move to that location!")
        return false
    end
    
    -- Check if another unit is there
    if UnitManager:getUnitAt(targetGridX, targetGridY) then
        print("Another unit is blocking that position!")
        return false
    end
    
    -- Calculate path distance (simple Manhattan distance for now)
    local dx = math.abs(targetGridX - unit.gridX)
    local dz = math.abs(targetGridY - unit.gridY)
    local distance = dx + dz
    
    -- Check if within movement range (could be a unit property)
    local maxMoveDistance = 5
    if distance > maxMoveDistance then
        print("Target too far away!")
        return false
    end
    
    -- Perform movement
    unit:useActionPoint(1)
    unit:setPosition(targetGridX, 0.25, targetGridY)
    
    print(unit.name .. " moved to (" .. targetGridX .. ", " .. targetGridY .. ")")
    return true
end

-- Click to move active unit
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and selectedTile and selectedTile.type == "floor" then
        local activeUnit = UnitManager.activeUnit
        if activeUnit and activeUnit.faction == "player" then
            moveUnit(activeUnit, selectedTile.x, selectedTile.y)
        end
    end
end
```

### Example 4: Unit Abilities System

```lua
-- Extend Unit class with abilities
local function addAbilitiesToUnit(unit)
    unit.abilities = {}
    
    -- Heal ability (medic class)
    unit.abilities.heal = {
        name = "First Aid",
        cost = 1,  -- Action points
        range = 3,
        execute = function(caster, target)
            if target.faction ~= caster.faction then
                return false, "Cannot heal enemy units!"
            end
            
            local healAmount = 30
            target:heal(healAmount)
            print(caster.name .. " healed " .. target.name .. " for " .. healAmount)
            return true
        end
    }
    
    -- Grenade ability (explosive AoE)
    unit.abilities.grenade = {
        name = "Frag Grenade",
        cost = 1,
        range = 8,
        execute = function(caster, targetX, targetZ)
            local unitsInRange = UnitManager:getUnitsInRadius(targetX, targetZ, 3, caster)
            
            for _, unitData in ipairs(unitsInRange) do
                local target = unitData.unit
                local distance = unitData.distance
                
                -- Damage falls off with distance
                local damage = math.floor(50 * (1 - distance / 3))
                target:takeDamage(damage)
                
                print(target.name .. " took " .. damage .. " grenade damage!")
            end
            
            return true
        end
    }
    
    -- Overwatch ability (shoot at first moving enemy)
    unit.abilities.overwatch = {
        name = "Overwatch",
        cost = 1,
        range = 15,
        execute = function(caster)
            caster.isOverwatching = true
            print(caster.name .. " is now on overwatch!")
            return true
        end
    }
end

-- Use ability
function useAbility(unit, abilityName, target)
    local ability = unit.abilities[abilityName]
    
    if not ability then
        print("Unit doesn't have that ability!")
        return false
    end
    
    if not unit:hasActionPoints(ability.cost) then
        print("Not enough action points!")
        return false
    end
    
    -- Check range if target is a unit
    if type(target) == "table" and target.x then
        local dx = target.x - unit.x
        local dz = target.z - unit.z
        local distance = math.sqrt(dx * dx + dz * dz)
        
        if distance > ability.range then
            print("Target out of range!")
            return false
        end
    end
    
    -- Execute ability
    local success, message = ability.execute(unit, target)
    
    if success then
        unit:useActionPoint(ability.cost)
        print(ability.name .. " used successfully!")
    else
        print("Failed to use " .. ability.name .. ": " .. (message or "unknown error"))
    end
    
    return success
end
```

### Example 5: Enemy AI

```lua
-- Simple enemy AI
local function enemyAI(enemy)
    if not enemy:hasActionPoints(1) then
        return  -- No actions available
    end
    
    -- Find visible player units
    local visiblePlayers = {}
    for _, player in ipairs(UnitManager.playerUnits) do
        if hasLineOfSight(enemy.x, enemy.z, player.x, player.z) then
            local dx = player.x - enemy.x
            local dz = player.z - enemy.z
            local distance = math.sqrt(dx * dx + dz * dz)
            
            if distance <= 20 then  -- Visual range
                table.insert(visiblePlayers, {unit = player, distance = distance})
            end
        end
    end
    
    -- No players visible - patrol randomly
    if #visiblePlayers == 0 then
        if math.random() < 0.3 then  -- 30% chance to move
            local directions = {{1,0}, {-1,0}, {0,1}, {0,-1}}
            local dir = directions[math.random(#directions)]
            local newX = enemy.gridX + dir[1]
            local newZ = enemy.gridY + dir[2]
            
            if newX >= 1 and newX <= mazeSize and newZ >= 1 and newZ <= mazeSize then
                if isWalkable(maze[newZ][newX].terrain) and not UnitManager:getUnitAt(newX, newZ) then
                    enemy:useActionPoint(1)
                    enemy:setPosition(newX, 0.25, newZ)
                end
            end
        end
        return
    end
    
    -- Sort by distance (closest first)
    table.sort(visiblePlayers, function(a, b) return a.distance < b.distance end)
    
    local target = visiblePlayers[1].unit
    local distance = visiblePlayers[1].distance
    
    -- If in range, attack
    if distance <= 10 then
        performAttack(enemy, target)
    else
        -- Move towards target
        local dx = target.x - enemy.x
        local dz = target.z - enemy.z
        
        -- Normalize direction
        local length = math.sqrt(dx * dx + dz * dz)
        dx = dx / length
        dz = dz / length
        
        -- Try to move one step closer
        local moveX = enemy.gridX + math.floor(dx + 0.5)
        local moveZ = enemy.gridY + math.floor(dz + 0.5)
        
        -- Ensure within bounds
        moveX = math.max(1, math.min(mazeSize, moveX))
        moveZ = math.max(1, math.min(mazeSize, moveZ))
        
        if isWalkable(maze[moveZ][moveX].terrain) and not UnitManager:getUnitAt(moveX, moveZ) then
            enemy:useActionPoint(1)
            enemy:setPosition(moveX, 0.25, moveZ)
        end
    end
end

-- Run AI for all enemies (called in enemy turn phase)
function runEnemyTurn()
    print("=== Enemy Turn Starting ===")
    
    for _, enemy in ipairs(UnitManager.enemyUnits) do
        if enemy:isAlive() and enemy.actionPoints > 0 then
            enemyAI(enemy)
        end
    end
    
    print("=== Enemy Turn Complete ===")
end
```

### Example 6: Unit Status Effects

```lua
-- Add status effects to units
local function initializeStatusEffects(unit)
    unit.statusEffects = {}
end

local StatusEffect = {}
StatusEffect.__index = StatusEffect

function StatusEffect:new(name, duration, onApply, onTick, onRemove)
    local effect = setmetatable({}, StatusEffect)
    effect.name = name
    effect.duration = duration  -- Turns remaining
    effect.onApply = onApply or function() end
    effect.onTick = onTick or function() end
    effect.onRemove = onRemove or function() end
    return effect
end

-- Apply status effect to unit
function applyStatusEffect(unit, effect)
    -- Check if effect already exists
    for i, existing in ipairs(unit.statusEffects) do
        if existing.name == effect.name then
            -- Refresh duration
            existing.duration = math.max(existing.duration, effect.duration)
            return
        end
    end
    
    -- Add new effect
    table.insert(unit.statusEffects, effect)
    effect.onApply(unit)
    print(unit.name .. " is now affected by " .. effect.name)
end

-- Update status effects (call at start of unit's turn)
function updateStatusEffects(unit)
    for i = #unit.statusEffects, 1, -1 do
        local effect = unit.statusEffects[i]
        
        -- Apply effect
        effect.onTick(unit)
        
        -- Decrease duration
        effect.duration = effect.duration - 1
        
        -- Remove if expired
        if effect.duration <= 0 then
            effect.onRemove(unit)
            table.remove(unit.statusEffects, i)
            print(effect.name .. " wore off from " .. unit.name)
        end
    end
end

-- Example status effects
local function createPoisonEffect(damage, turns)
    return StatusEffect:new(
        "Poison",
        turns,
        function(unit) 
            unit.tint.g = 0.5  -- Green tint
        end,
        function(unit)
            unit:takeDamage(damage)
            print(unit.name .. " took " .. damage .. " poison damage")
        end,
        function(unit)
            unit.tint.g = 1.0  -- Remove tint
        end
    )
end

local function createShieldEffect(absorb, turns)
    return StatusEffect:new(
        "Shield",
        turns,
        function(unit)
            unit.tempArmor = absorb
            unit.armor = unit.armor + absorb
            unit.tint.b = 1.5  -- Blue glow
        end,
        function(unit)
            -- Shield persists
        end,
        function(unit)
            unit.armor = unit.armor - unit.tempArmor
            unit.tempArmor = 0
            unit.tint.b = 1.0
        end
    )
end

local function createStunEffect(turns)
    return StatusEffect:new(
        "Stunned",
        turns,
        function(unit)
            unit.wasStunned = true
            unit.maxActionPoints = 0
        end,
        function(unit)
            -- Cannot act
        end,
        function(unit)
            unit.maxActionPoints = 2  -- Restore default
            unit.wasStunned = false
        end
    )
end

-- Usage example
function castPoisonAbility(caster, target)
    local poison = createPoisonEffect(5, 3)  -- 5 damage per turn, 3 turns
    applyStatusEffect(target, poison)
end
```

### Example 7: UI Integration - Health Bars

```lua
-- Draw health bar above unit (in 2D overlay)
function drawUnitHealthBars()
    love.graphics.setDepthMode()  -- Disable depth for 2D overlay
    
    local currentPlayer = UnitManager.activeUnit
    if not currentPlayer then return end
    
    local visibleUnits = UnitManager:getVisibleUnits(
        currentPlayer.x,
        currentPlayer.z,
        50,
        hasLineOfSight
    )
    
    for _, unitData in ipairs(visibleUnits) do
        local unit = unitData.unit
        
        -- Skip the active player (camera unit)
        if unit == currentPlayer then
            goto continue
        end
        
        -- Project 3D position to screen
        local screenX, screenY, scale, visible = worldToScreen(unit.x, unit.y + 0.8, unit.z)
        
        if visible then
            local barWidth = 40 * scale
            local barHeight = 6 * scale
            local barX = screenX - barWidth / 2
            local barY = screenY - barHeight
            
            -- Background (black)
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", barX - 1, barY - 1, barWidth + 2, barHeight + 2)
            
            -- Health bar (faction colored)
            local factionColor = unit:getFactionColor()
            love.graphics.setColor(factionColor.r, factionColor.g, factionColor.b, 0.9)
            local healthWidth = barWidth * unit:getHealthPercentage()
            love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)
            
            -- Border
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
            
            -- Unit name (small text)
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.print(unit.name, barX, barY - 12, 0, 0.5, 0.5)
        end
        
        ::continue::
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setDepthMode("lequal", true)  -- Re-enable depth
end

-- Add to love.draw()
function love.draw()
    -- ... 3D rendering ...
    
    -- Draw 2D UI overlay
    drawUnitHealthBars()
end
```

## Advanced Patterns

### Pattern 1: Unit Classes/Archetypes

```lua
-- Define unit archetypes with default stats
local UnitArchetypes = {
    soldier = {
        health = 100,
        armor = 20,
        damage = 25,
        actionPoints = 2,
        abilities = {"shoot", "reload", "grenadeweapon"}
    },
    sniper = {
        health = 80,
        armor = 10,
        damage = 50,
        actionPoints = 2,
        abilities = {"shoot", "overwatch", "hunker"}
    },
    heavy = {
        health = 120,
        armor = 30,
        damage = 20,
        actionPoints = 1,
        abilities = {"shoot", "suppress", "rocket"}
    },
    medic = {
        health = 90,
        armor = 15,
        damage = 15,
        actionPoints = 2,
        abilities = {"shoot", "heal", "stabilize"}
    }
}

function UnitFactory.createFromArchetype(archetype, x, z, faction)
    local template = UnitArchetypes[archetype]
    if not template then
        error("Unknown archetype: " .. archetype)
    end
    
    local unit = Unit:new(x, 0.25, z, faction, archetype)
    unit.health = template.health
    unit.maxHealth = template.health
    unit.armor = template.armor
    unit.damage = template.damage
    unit.actionPoints = template.actionPoints
    unit.maxActionPoints = template.actionPoints
    
    -- Initialize abilities
    unit.abilities = {}
    for _, abilityName in ipairs(template.abilities) do
        -- Load ability from ability registry
        unit.abilities[abilityName] = AbilityRegistry[abilityName]
    end
    
    return unit
end
```

### Pattern 2: Event System

```lua
-- Event system for unit actions
local EventSystem = {
    listeners = {}
}

function EventSystem:on(eventName, callback)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    table.insert(self.listeners[eventName], callback)
end

function EventSystem:trigger(eventName, ...)
    if self.listeners[eventName] then
        for _, callback in ipairs(self.listeners[eventName]) do
            callback(...)
        end
    end
end

-- Hook into unit actions
local originalTakeDamage = Unit.takeDamage
function Unit:takeDamage(amount)
    local damage, alive = originalTakeDamage(self, amount)
    EventSystem:trigger("unitDamaged", self, damage)
    if not alive then
        EventSystem:trigger("unitKilled", self)
    end
    return damage, alive
end

-- Listen to events
EventSystem:on("unitDamaged", function(unit, damage)
    print(unit.name .. " took " .. damage .. " damage!")
    -- Play damage animation/sound
end)

EventSystem:on("unitKilled", function(unit)
    print(unit.name .. " was eliminated!")
    -- Play death animation/sound
    -- Award XP to killer
end)
```

These examples show the power and flexibility of the new unified unit system. You can mix and match these patterns to create the gameplay you envision!
