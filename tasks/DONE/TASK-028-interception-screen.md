# Task: Interception Screen - Turn-Based Card Battle System

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement the Interception Screen, a turn-based tactical mini-game where player crafts/bases engage alien missions (UFOs, sites, bases). Resembles a battle card game with units positioned in altitude layers (AIR, LAND/WATER, UNDERGROUND/UNDERWATER) and using action points for attacks and abilities.

---

## Purpose

The Interception Screen bridges Geoscape strategy and Battlescape tactics. It allows:
1. Air-to-air combat (intercept UFOs before they land)
2. Air-to-ground support (soften targets before ground assault)
3. Base defense (use base facilities to defend)
4. Strategic resource commitment (risk crafts to weaken missions)

This creates meaningful tactical decisions about when to engage and what resources to commit.

---

## Requirements

### Functional Requirements
- [ ] Launch interception from Geoscape when craft(s) in mission province
- [ ] Interception screen with 3 altitude layers (vertical positioning)
- [ ] Left side: Player forces (crafts + bases)
- [ ] Right side: Enemy forces (UFOs, sites, bases)
- [ ] Turn-based gameplay: 1 turn = 5 minutes game time
- [ ] All units have 4 AP (Action Points) per turn
- [ ] All units have energy system (like Battlescape)
- [ ] Weapon system with range, AP cost, energy cost, cooldown
- [ ] No movement: units stay in their altitude layer
- [ ] Win conditions: destroy/damage enemy to proceed to Battlescape or retreat
- [ ] Base defense integration: base facilities act as defensive units
- [ ] Multiple crafts can participate
- [ ] Retreat/disengage option

### Technical Requirements
- [ ] Interception screen state in `engine/interception/`
- [ ] Unit system compatible with crafts, bases, and missions
- [ ] Weapon targeting with altitude restrictions (AIR-to-AIR, AIR-to-LAND, etc.)
- [ ] AP and energy management per unit
- [ ] Cooldown tracking per weapon
- [ ] Damage calculation and unit health
- [ ] Turn processing with AI for enemy units
- [ ] Transition to Battlescape or back to Geoscape
- [ ] UI with 3-layer visual layout
- [ ] Biome background graphics

### Acceptance Criteria
- [ ] Player can initiate interception from Geoscape
- [ ] Interception screen displays all participants correctly
- [ ] Units positioned by altitude (AIR, LAND, UNDERGROUND/UNDERWATER)
- [ ] Turn-based combat works with AP/energy systems
- [ ] Weapons fire based on range and altitude restrictions
- [ ] Base defense facilities participate when base in province
- [ ] Win/retreat conditions work correctly
- [ ] Performance: <2ms per turn update
- [ ] Console shows combat log
- [ ] Transitions to/from Geoscape smooth

---

## Plan

### Step 1: Interception Unit System (6 hours)
**Description:** Create unified unit system for crafts, bases, and missions in interception  
**Files to create:**
- `engine/interception/logic/interception_unit.lua` - Base unit class

**Implementation:**
```lua
local InterceptionUnit = {}
InterceptionUnit.__index = InterceptionUnit

function InterceptionUnit:new(config)
    local self = setmetatable({}, InterceptionUnit)
    
    -- Identity
    self.id = config.id
    self.name = config.name
    self.type = config.type  -- "craft", "base", "ufo", "site", "alien_base"
    self.side = config.side  -- "player", "enemy"
    
    -- Position
    self.altitude = config.altitude  -- "air", "land", "underground", "underwater"
    self.position = config.position  -- For visual positioning within layer
    
    -- Combat stats
    self.health = config.health or 100
    self.maxHealth = config.maxHealth or 100
    self.armor = config.armor or 0
    self.shields = config.shields or 0
    self.maxShields = config.maxShields or 0
    
    -- Action system (like Battlescape units)
    self.ap = 4  -- All units have 4 AP per turn
    self.maxAP = 4
    self.energy = config.energy or 100
    self.maxEnergy = config.maxEnergy or 100
    self.energyRegen = config.energyRegen or 10  -- Per turn
    
    -- Equipment
    self.weapons = config.weapons or {}  -- List of weapon objects
    self.equipment = config.equipment or {}
    self.inventory = config.inventory or {}
    
    -- Cooldowns (per weapon)
    self.cooldowns = {}  -- [weaponId] = turnsRemaining
    
    -- State
    self.isDestroyed = false
    self.canAct = true
    
    -- Reference to original entity (craft/base/mission)
    self.sourceEntity = config.sourceEntity
    
    return self
end

function InterceptionUnit:startTurn()
    self.ap = self.maxAP
    self.energy = math.min(self.maxEnergy, self.energy + self.energyRegen)
    
    -- Reduce all cooldowns
    for weaponId, turns in pairs(self.cooldowns) do
        self.cooldowns[weaponId] = math.max(0, turns - 1)
    end
    
    print(string.format("[Interception] %s: AP=%d, Energy=%d", 
        self.name, self.ap, self.energy))
end

function InterceptionUnit:canUseWeapon(weapon)
    -- Check AP cost
    if self.ap < weapon.apCost then
        return false, "Not enough AP"
    end
    
    -- Check energy cost
    if self.energy < weapon.energyCost then
        return false, "Not enough energy"
    end
    
    -- Check cooldown
    if self.cooldowns[weapon.id] and self.cooldowns[weapon.id] > 0 then
        return false, string.format("Cooling down (%d turns)", self.cooldowns[weapon.id])
    end
    
    return true, ""
end

function InterceptionUnit:useWeapon(weapon, target)
    local canUse, reason = self:canUseWeapon(weapon)
    if not canUse then
        return false, reason
    end
    
    -- Check range and altitude compatibility
    local canTarget, targetReason = self:canTarget(weapon, target)
    if not canTarget then
        return false, targetReason
    end
    
    -- Consume resources
    self.ap = self.ap - weapon.apCost
    self.energy = self.energy - weapon.energyCost
    
    -- Set cooldown
    if weapon.cooldown > 0 then
        self.cooldowns[weapon.id] = weapon.cooldown
    end
    
    -- Apply damage
    local damage = self:calculateDamage(weapon, target)
    target:takeDamage(damage, weapon.damageType)
    
    print(string.format("[Interception] %s used %s on %s for %d damage", 
        self.name, weapon.name, target.name, damage))
    
    return true, damage
end

function InterceptionUnit:canTarget(weapon, target)
    -- Check altitude compatibility
    if not self:checkAltitudeCompatibility(weapon, target) then
        return false, "Target altitude incompatible with weapon"
    end
    
    -- Check range (for future expansion)
    -- For now, all targets in interception are in range
    
    return true, ""
end

function InterceptionUnit:checkAltitudeCompatibility(weapon, target)
    local myAlt = self.altitude
    local targetAlt = target.altitude
    
    -- AIR-to-AIR weapons
    if weapon.targetAltitude == "air-to-air" then
        return myAlt == "air" and targetAlt == "air"
    end
    
    -- AIR-to-LAND weapons
    if weapon.targetAltitude == "air-to-land" then
        return myAlt == "air" and (targetAlt == "land" or targetAlt == "water")
    end
    
    -- LAND-to-AIR weapons (anti-aircraft)
    if weapon.targetAltitude == "land-to-air" then
        return (myAlt == "land" or myAlt == "water") and targetAlt == "air"
    end
    
    -- LAND-to-LAND weapons
    if weapon.targetAltitude == "land-to-land" then
        return (myAlt == "land" or myAlt == "water") and 
               (targetAlt == "land" or targetAlt == "water")
    end
    
    -- UNDERGROUND/UNDERWATER special weapons
    if weapon.targetAltitude == "underground" then
        return targetAlt == "underground" or targetAlt == "underwater"
    end
    
    -- Default: same altitude
    return myAlt == targetAlt
end

function InterceptionUnit:calculateDamage(weapon, target)
    local baseDamage = weapon.damage
    
    -- Random variation (±20%)
    local variation = math.random(80, 120) / 100
    local damage = baseDamage * variation
    
    -- Armor reduction
    local armorReduction = target.armor * 0.5  -- Armor reduces damage by 50% of armor value
    damage = math.max(1, damage - armorReduction)
    
    -- Damage type bonuses/penalties
    if weapon.damageType == "explosive" and target.type == "base" then
        damage = damage * 0.7  -- Bases resist explosives
    elseif weapon.damageType == "energy" and target.shields > 0 then
        damage = damage * 1.5  -- Energy weapons extra effective vs shields
    end
    
    return math.floor(damage)
end

function InterceptionUnit:takeDamage(damage, damageType)
    -- Shields absorb damage first
    if self.shields > 0 then
        local shieldDamage = math.min(self.shields, damage)
        self.shields = self.shields - shieldDamage
        damage = damage - shieldDamage
        
        print(string.format("[Interception] %s shields: %d (-%d)", 
            self.name, self.shields, shieldDamage))
    end
    
    -- Apply remaining damage to health
    if damage > 0 then
        self.health = self.health - damage
        
        print(string.format("[Interception] %s health: %d (-%d)", 
            self.name, self.health, damage))
        
        if self.health <= 0 then
            self:onDestroyed()
        end
    end
end

function InterceptionUnit:onDestroyed()
    self.isDestroyed = true
    self.canAct = false
    print(string.format("[Interception] %s destroyed!", self.name))
end

function InterceptionUnit:getAvailableActions()
    local actions = {}
    
    -- Weapon actions
    for _, weapon in ipairs(self.weapons) do
        local canUse, reason = self:canUseWeapon(weapon)
        table.insert(actions, {
            type = "weapon",
            weapon = weapon,
            available = canUse,
            reason = reason
        })
    end
    
    -- Item actions
    for _, item in ipairs(self.inventory) do
        if item.usableInInterception then
            table.insert(actions, {
                type = "item",
                item = item,
                available = true
            })
        end
    end
    
    -- Special abilities (base defense, craft evasion, etc.)
    -- TODO: Implement special abilities
    
    return actions
end

return InterceptionUnit
```

**Estimated time:** 6 hours

### Step 2: Interception Screen State (7 hours)
**Description:** Create main interception screen state with turn management  
**Files to create:**
- `engine/interception/systems/interception_manager.lua` - Main interception state

**Implementation:**
```lua
local InterceptionManager = {}

function InterceptionManager:init(mission, playerForces)
    self.mission = mission
    self.playerUnits = {}
    self.enemyUnits = {}
    
    self.currentTurn = 1
    self.currentPhase = "player"  -- "player", "enemy", "resolution"
    self.selectedUnit = nil
    self.selectedWeapon = nil
    
    self.gameTime = 0  -- Game minutes (1 turn = 5 minutes)
    self.biome = mission.biome or "desert"
    
    self.combatLog = {}
    
    -- Setup units
    self:setupPlayerUnits(playerForces)
    self:setupEnemyUnits(mission)
    
    print(string.format("[Interception] Starting interception: %s", mission.name))
    print(string.format("[Interception] Player units: %d, Enemy units: %d", 
        #self.playerUnits, #self.enemyUnits))
end

function InterceptionManager:setupPlayerUnits(playerForces)
    -- Add crafts
    for _, craft in ipairs(playerForces.crafts or {}) do
        local unit = InterceptionUnit:new({
            id = "craft_" .. craft.id,
            name = craft.name,
            type = "craft",
            side = "player",
            altitude = craft.altitude or "air",
            health = craft.health,
            maxHealth = craft.maxHealth,
            armor = craft.armor,
            shields = craft.shields,
            maxShields = craft.maxShields,
            weapons = craft.weapons,
            equipment = craft.equipment,
            inventory = craft.inventory,
            sourceEntity = craft
        })
        table.insert(self.playerUnits, unit)
    end
    
    -- Add base if in same province
    if playerForces.base then
        local base = playerForces.base
        local unit = InterceptionUnit:new({
            id = "base_" .. base.id,
            name = base.name,
            type = "base",
            side = "player",
            altitude = "land",
            health = base.defenseHealth or 1000,
            maxHealth = base.defenseMaxHealth or 1000,
            armor = base.defenseArmor or 50,
            weapons = self:getBaseDefenseWeapons(base),
            sourceEntity = base
        })
        table.insert(self.playerUnits, unit)
    end
end

function InterceptionManager:getBaseDefenseWeapons(base)
    local weapons = {}
    
    -- Extract weapons from defense facilities
    for _, facility in ipairs(base.facilities) do
        if facility.type == "defense_laser" then
            table.insert(weapons, {
                id = "laser_" .. facility.id,
                name = "Base Laser Cannon",
                damage = 50,
                damageType = "energy",
                apCost = 2,
                energyCost = 20,
                cooldown = 0,
                targetAltitude = "land-to-air"
            })
        elseif facility.type == "defense_missile" then
            table.insert(weapons, {
                id = "missile_" .. facility.id,
                name = "Base Missile Battery",
                damage = 100,
                damageType = "explosive",
                apCost = 3,
                energyCost = 30,
                cooldown = 2,
                targetAltitude = "land-to-air"
            })
        end
        -- Add more defense facility types
    end
    
    return weapons
end

function InterceptionManager:setupEnemyUnits(mission)
    -- Create enemy unit from mission
    local unit = InterceptionUnit:new({
        id = "mission_" .. mission.id,
        name = mission.name,
        type = mission.type,
        side = "enemy",
        altitude = mission.altitude,
        health = mission.health,
        maxHealth = mission.maxHealth,
        armor = mission.armor or 0,
        shields = mission.shields or 0,
        maxShields = mission.maxShields or 0,
        weapons = mission.weapons,
        equipment = mission.equipment,
        inventory = mission.inventory,
        sourceEntity = mission
    })
    table.insert(self.enemyUnits, unit)
    
    -- Mission might have escorts or support units
    if mission.escorts then
        for _, escort in ipairs(mission.escorts) do
            local escortUnit = InterceptionUnit:new({
                id = "escort_" .. escort.id,
                name = escort.name,
                type = "ufo",
                side = "enemy",
                altitude = escort.altitude or "air",
                health = escort.health,
                maxHealth = escort.maxHealth,
                weapons = escort.weapons,
                sourceEntity = escort
            })
            table.insert(self.enemyUnits, escortUnit)
        end
    end
end

function InterceptionManager:startTurn()
    self.currentTurn = self.currentTurn + 1
    self.gameTime = self.gameTime + 5  -- 5 minutes per turn
    self.currentPhase = "player"
    
    print(string.format("[Interception] Turn %d (Time: %d minutes)", 
        self.currentTurn, self.gameTime))
    
    -- Reset all units for new turn
    for _, unit in ipairs(self.playerUnits) do
        if not unit.isDestroyed then
            unit:startTurn()
        end
    end
    
    for _, unit in ipairs(self.enemyUnits) do
        if not unit.isDestroyed then
            unit:startTurn()
        end
    end
end

function InterceptionManager:playerPhase()
    -- Wait for player input
    -- Player selects unit, weapon, target
    -- When player ends turn, switch to enemy phase
end

function InterceptionManager:endPlayerPhase()
    self.currentPhase = "enemy"
    self:enemyPhase()
end

function InterceptionManager:enemyPhase()
    print("[Interception] Enemy phase starting...")
    
    -- AI controls enemy units
    for _, unit in ipairs(self.enemyUnits) do
        if not unit.isDestroyed and unit.canAct then
            self:executeEnemyAI(unit)
        end
    end
    
    -- End enemy phase
    self:endEnemyPhase()
end

function InterceptionManager:executeEnemyAI(unit)
    -- Simple AI: attack random player unit with highest damage weapon
    local availableActions = unit:getAvailableActions()
    local weaponActions = {}
    
    for _, action in ipairs(availableActions) do
        if action.type == "weapon" and action.available then
            table.insert(weaponActions, action)
        end
    end
    
    if #weaponActions == 0 then
        print(string.format("[Interception] %s has no available weapons", unit.name))
        return
    end
    
    -- Sort by damage
    table.sort(weaponActions, function(a, b)
        return a.weapon.damage > b.weapon.damage
    end)
    
    -- Try to use best weapon on random target
    for _, action in ipairs(weaponActions) do
        local targets = self:getValidTargets(unit, action.weapon)
        if #targets > 0 then
            local target = targets[math.random(1, #targets)]
            unit:useWeapon(action.weapon, target)
            break
        end
    end
end

function InterceptionManager:getValidTargets(unit, weapon)
    local targets = {}
    local targetList = unit.side == "player" and self.enemyUnits or self.playerUnits
    
    for _, target in ipairs(targetList) do
        if not target.isDestroyed then
            local canTarget, _ = unit:canTarget(weapon, target)
            if canTarget then
                table.insert(targets, target)
            end
        end
    end
    
    return targets
end

function InterceptionManager:endEnemyPhase()
    self.currentPhase = "resolution"
    self:resolutionPhase()
end

function InterceptionManager:resolutionPhase()
    -- Check win/loss conditions
    local playerAlive = self:hasAliveUnits(self.playerUnits)
    local enemyAlive = self:hasAliveUnits(self.enemyUnits)
    
    if not playerAlive then
        self:onPlayerDefeated()
        return
    end
    
    if not enemyAlive then
        self:onEnemyDefeated()
        return
    end
    
    -- Continue to next turn
    self:startTurn()
end

function InterceptionManager:hasAliveUnits(units)
    for _, unit in ipairs(units) do
        if not unit.isDestroyed then
            return true
        end
    end
    return false
end

function InterceptionManager:onEnemyDefeated()
    print("[Interception] Enemy defeated! Proceeding to ground assault...")
    
    -- Update mission state
    self.mission.health = 0
    self.mission.state = "vulnerable"
    
    -- Offer choice: ground assault (Battlescape) or return
    self:showVictoryDialog()
end

function InterceptionManager:onPlayerDefeated()
    print("[Interception] Player forces destroyed! Retreating...")
    
    -- Update craft states (damaged/destroyed)
    for _, unit in ipairs(self.playerUnits) do
        if unit.type == "craft" and unit.sourceEntity then
            unit.sourceEntity.health = unit.health
            if unit.isDestroyed then
                unit.sourceEntity.state = "destroyed"
            end
        end
    end
    
    -- Return to Geoscape
    self:returnToGeoscape()
end

function InterceptionManager:playerRetreat()
    print("[Interception] Player retreating from interception...")
    
    -- Apply damage to crafts/base from retreat
    for _, unit in ipairs(self.playerUnits) do
        if unit.sourceEntity then
            unit.sourceEntity.health = unit.health
        end
    end
    
    -- Return to Geoscape
    self:returnToGeoscape()
end

function InterceptionManager:proceedToBattlescape()
    print("[Interception] Proceeding to Battlescape...")
    
    -- Transition to Battlescape state
    StateManager:setState("battlescape", {
        mission = self.mission,
        playerUnits = self:getAvailableSquad(),
        difficulty = self.mission.difficulty
    })
end

function InterceptionManager:returnToGeoscape()
    print("[Interception] Returning to Geoscape...")
    StateManager:setState("geoscape")
end

return InterceptionManager
```

**Estimated time:** 7 hours

### Step 3: Interception UI Layout (8 hours)
**Description:** Create UI for interception screen with 3-layer layout  
**Files to create:**
- `engine/interception/ui/interception_view.lua` - Main UI view

**Implementation:**
```lua
local InterceptionView = {}

function InterceptionView:init(interceptionManager)
    self.manager = interceptionManager
    
    -- Screen layout (960×720)
    self.layerHeight = 240  -- Each layer is 240 pixels tall (10 grid cells)
    
    -- Altitude layers (top to bottom)
    self.layers = {
        { name = "AIR",         y = 0,   color = {100, 180, 255} },
        { name = "LAND/WATER",  y = 240, color = {100, 150, 50} },
        { name = "UNDERGROUND", y = 480, color = {80, 60, 40} }
    }
    
    -- Unit display areas
    self.playerZone = { x = 48, width = 384 }   -- Left side
    self.enemyZone = { x = 528, width = 384 }   -- Right side
    
    -- UI elements
    self.selectedUnit = nil
    self.hoveredUnit = nil
    self.hoveredWeapon = nil
    
    -- Buttons
    self.endTurnButton = Button:new(816, 672, 120, 48, "End Turn")
    self.retreatButton = Button:new(672, 672, 120, 48, "Retreat")
    
    -- Combat log panel
    self.combatLogPanel = Panel:new(24, 576, 624, 120)
    
    -- Load biome background
    self.background = Assets:getImage("biomes/" .. self.manager.biome)
end

function InterceptionView:draw()
    -- Draw background
    love.graphics.setColor(255, 255, 255)
    if self.background then
        love.graphics.draw(self.background, 0, 0)
    end
    
    -- Draw altitude layers
    self:drawLayers()
    
    -- Draw units
    self:drawUnits()
    
    -- Draw UI elements
    self:drawTopBar()
    self:drawCombatLog()
    self:drawButtons()
    
    -- Draw selected unit info
    if self.selectedUnit then
        self:drawUnitInfo(self.selectedUnit)
    end
    
    -- Draw weapon targeting
    if self.selectedUnit and self.selectedWeapon then
        self:drawTargetingOverlay()
    end
end

function InterceptionView:drawLayers()
    for i, layer in ipairs(self.layers) do
        -- Layer background
        love.graphics.setColor(layer.color[1], layer.color[2], layer.color[3], 100)
        love.graphics.rectangle("fill", 0, layer.y, 960, self.layerHeight)
        
        -- Layer border
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("line", 0, layer.y, 960, self.layerHeight)
        
        -- Layer label
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(layer.name, 12, layer.y + 12)
    end
    
    -- Divider between player and enemy zones
    love.graphics.setColor(255, 255, 255)
    love.graphics.line(480, 0, 480, 720)
end

function InterceptionView:drawUnits()
    -- Draw player units
    for i, unit in ipairs(self.manager.playerUnits) do
        if not unit.isDestroyed then
            self:drawUnit(unit, "player", i)
        end
    end
    
    -- Draw enemy units
    for i, unit in ipairs(self.manager.enemyUnits) do
        if not unit.isDestroyed then
            self:drawUnit(unit, "enemy", i)
        end
    end
end

function InterceptionView:drawUnit(unit, side, index)
    local layerY = self:getLayerY(unit.altitude)
    
    -- Position within layer
    local zone = side == "player" and self.playerZone or self.enemyZone
    local x = zone.x + (index - 1) * 120
    local y = layerY + 60
    
    -- Unit card (96×144 pixels = 4×6 grid cells)
    local cardWidth = 96
    local cardHeight = 144
    
    -- Card background
    local bgColor = side == "player" and {50, 100, 200} or {200, 50, 50}
    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3])
    love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)
    
    -- Card border
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", x, y, cardWidth, cardHeight)
    
    -- Unit icon/sprite
    local iconName = self:getUnitIcon(unit)
    local icon = Assets:getImage("interception/" .. iconName)
    if icon then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(icon, x + 16, y + 12, 0, 2, 2)  -- 32×32 icon scaled 2x
    end
    
    -- Unit name
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(unit.name, x + 4, y + 56, 0, 0.6, 0.6)
    
    -- Health bar
    self:drawHealthBar(unit, x + 4, y + 72, cardWidth - 8)
    
    -- AP indicator
    love.graphics.setColor(255, 255, 100)
    love.graphics.print(string.format("AP: %d/%d", unit.ap, unit.maxAP), x + 4, y + 90)
    
    -- Energy indicator
    love.graphics.setColor(100, 200, 255)
    love.graphics.print(string.format("EN: %d", unit.energy), x + 4, y + 105)
    
    -- Shield indicator (if any)
    if unit.shields > 0 then
        love.graphics.setColor(150, 150, 255)
        love.graphics.print(string.format("SH: %d", unit.shields), x + 4, y + 120)
    end
    
    -- Selection highlight
    if self.selectedUnit == unit then
        love.graphics.setColor(255, 255, 0)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 2, y - 2, cardWidth + 4, cardHeight + 4)
        love.graphics.setLineWidth(1)
    end
    
    -- Hover highlight
    if self.hoveredUnit == unit then
        love.graphics.setColor(255, 255, 255, 128)
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)
    end
end

function InterceptionView:drawHealthBar(unit, x, y, width)
    local healthPercent = unit.health / unit.maxHealth
    
    -- Background
    love.graphics.setColor(50, 50, 50)
    love.graphics.rectangle("fill", x, y, width, 12)
    
    -- Health fill
    local healthColor = healthPercent > 0.5 and {0, 255, 0} or 
                       healthPercent > 0.25 and {255, 255, 0} or {255, 0, 0}
    love.graphics.setColor(healthColor[1], healthColor[2], healthColor[3])
    love.graphics.rectangle("fill", x, y, width * healthPercent, 12)
    
    -- Border
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", x, y, width, 12)
    
    -- Text
    love.graphics.print(string.format("%d/%d", unit.health, unit.maxHealth), x + 2, y + 1, 0, 0.6, 0.6)
end

function InterceptionView:getLayerY(altitude)
    if altitude == "air" then
        return self.layers[1].y
    elseif altitude == "land" or altitude == "water" then
        return self.layers[2].y
    else  -- underground, underwater
        return self.layers[3].y
    end
end

function InterceptionView:drawTopBar()
    -- Turn counter
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(string.format("Turn: %d", self.manager.currentTurn), 24, 12)
    love.graphics.print(string.format("Time: %d minutes", self.manager.gameTime), 24, 36)
    
    -- Phase indicator
    local phase = self.manager.currentPhase
    local phaseText = phase:upper() .. " PHASE"
    love.graphics.print(phaseText, 432, 12, 0, 1.2, 1.2)
end

function InterceptionView:drawCombatLog()
    self.combatLogPanel:draw()
    
    -- Show last 4 combat log entries
    love.graphics.setColor(255, 255, 255)
    local logEntries = self.manager.combatLog
    local startIndex = math.max(1, #logEntries - 3)
    
    for i = startIndex, #logEntries do
        local entry = logEntries[i]
        local y = 576 + (i - startIndex) * 24 + 12
        love.graphics.print(entry, 36, y, 0, 0.7, 0.7)
    end
end

function InterceptionView:drawButtons()
    self.endTurnButton:draw()
    self.retreatButton:draw()
end

function InterceptionView:drawUnitInfo(unit)
    -- Detailed unit info panel (right side)
    local panelX = 672
    local panelY = 24
    local panelWidth = 264
    local panelHeight = 360
    
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)
    
    local textX = panelX + 12
    local textY = panelY + 12
    
    -- Unit name
    love.graphics.print(unit.name, textX, textY, 0, 1.2, 1.2)
    textY = textY + 36
    
    -- Stats
    love.graphics.print(string.format("Health: %d/%d", unit.health, unit.maxHealth), textX, textY)
    textY = textY + 24
    love.graphics.print(string.format("Armor: %d", unit.armor), textX, textY)
    textY = textY + 24
    love.graphics.print(string.format("AP: %d/%d", unit.ap, unit.maxAP), textX, textY)
    textY = textY + 24
    love.graphics.print(string.format("Energy: %d/%d", unit.energy, unit.maxEnergy), textX, textY)
    textY = textY + 36
    
    -- Weapons
    love.graphics.print("Weapons:", textX, textY)
    textY = textY + 24
    
    for i, weapon in ipairs(unit.weapons) do
        local canUse, reason = unit:canUseWeapon(weapon)
        local color = canUse and {0, 255, 0} or {255, 100, 100}
        love.graphics.setColor(color[1], color[2], color[3])
        
        local weaponText = string.format("%d. %s (DMG:%d, AP:%d)", 
            i, weapon.name, weapon.damage, weapon.apCost)
        love.graphics.print(weaponText, textX + 12, textY, 0, 0.7, 0.7)
        textY = textY + 20
        
        if not canUse then
            love.graphics.setColor(255, 100, 100)
            love.graphics.print(reason, textX + 24, textY, 0, 0.6, 0.6)
            textY = textY + 18
        end
    end
end

function InterceptionView:drawTargetingOverlay()
    -- Highlight valid targets for selected weapon
    local validTargets = self.manager:getValidTargets(self.selectedUnit, self.selectedWeapon)
    
    for _, target in ipairs(validTargets) do
        -- Draw target indicator on enemy unit
        -- (Position calculation similar to drawUnit)
        -- Show damage prediction
    end
end

function InterceptionView:update(dt)
    -- Update UI elements
    self.endTurnButton:update(dt)
    self.retreatButton:update(dt)
    
    -- Update hover state
    local mouseX, mouseY = love.mouse.getPosition()
    self.hoveredUnit = self:getUnitAtPosition(mouseX, mouseY)
end

function InterceptionView:mousepressed(x, y, button)
    if button == 1 then
        -- Check button clicks
        if self.endTurnButton:isMouseOver(x, y) then
            self.manager:endPlayerPhase()
            return
        end
        
        if self.retreatButton:isMouseOver(x, y) then
            self.manager:playerRetreat()
            return
        end
        
        -- Check unit selection
        local unit = self:getUnitAtPosition(x, y)
        if unit and unit.side == "player" then
            self.selectedUnit = unit
            self.selectedWeapon = nil
            return
        end
        
        -- Check targeting (if weapon selected)
        if self.selectedUnit and self.selectedWeapon and unit and unit.side == "enemy" then
            self.selectedUnit:useWeapon(self.selectedWeapon, unit)
            self.selectedWeapon = nil
            return
        end
    end
end

function InterceptionView:keypressed(key)
    -- Number keys select weapons
    if self.selectedUnit then
        local weaponIndex = tonumber(key)
        if weaponIndex and weaponIndex >= 1 and weaponIndex <= #self.selectedUnit.weapons then
            self.selectedWeapon = self.selectedUnit.weapons[weaponIndex]
        end
    end
    
    -- Space bar ends turn
    if key == "space" then
        self.manager:endPlayerPhase()
    end
    
    -- Escape retreats
    if key == "escape" then
        self.manager:playerRetreat()
    end
end

function InterceptionView:getUnitAtPosition(x, y)
    -- Check all units for mouse collision
    -- (Iterate through both player and enemy units, check bounds)
    -- Return unit if found, nil otherwise
end

return InterceptionView
```

**Estimated time:** 8 hours

### Step 4: Weapon System & Data (5 hours)
**Description:** Define weapon properties and create weapon data files  
**Files to create:**
- `engine/data/interception_weapons.lua` - Weapon definitions
- `engine/interception/logic/weapon.lua` - Weapon class

**Implementation:**
```lua
-- Weapon data examples
return {
    -- Craft weapons (AIR)
    {
        id = "craft_cannon_basic",
        name = "Cannon",
        damage = 30,
        damageType = "kinetic",
        apCost = 2,
        energyCost = 10,
        cooldown = 0,
        targetAltitude = "air-to-air",
        description = "Basic projectile weapon"
    },
    {
        id = "craft_missile_aa",
        name = "Air-to-Air Missile",
        damage = 80,
        damageType = "explosive",
        apCost = 3,
        energyCost = 25,
        cooldown = 2,
        targetAltitude = "air-to-air",
        description = "Heavy anti-aircraft missile"
    },
    {
        id = "craft_bomb",
        name = "Bomb",
        damage = 100,
        damageType = "explosive",
        apCost = 3,
        energyCost = 20,
        cooldown = 1,
        targetAltitude = "air-to-land",
        description = "Ground attack bomb"
    },
    
    -- Base defense weapons (LAND)
    {
        id = "base_laser_cannon",
        name = "Laser Defense",
        damage = 50,
        damageType = "energy",
        apCost = 2,
        energyCost = 20,
        cooldown = 0,
        targetAltitude = "land-to-air",
        description = "Laser anti-aircraft defense"
    },
    {
        id = "base_missile_battery",
        name = "Missile Battery",
        damage = 100,
        damageType = "explosive",
        apCost = 3,
        energyCost = 30,
        cooldown = 2,
        targetAltitude = "land-to-air",
        description = "Surface-to-air missiles"
    },
    
    -- UFO weapons
    {
        id = "ufo_plasma",
        name = "Plasma Cannon",
        damage = 60,
        damageType = "energy",
        apCost = 2,
        energyCost = 15,
        cooldown = 0,
        targetAltitude = "air-to-air",
        description = "Alien plasma weapon"
    },
    {
        id = "ufo_beam",
        name = "Tractor Beam",
        damage = 40,
        damageType = "energy",
        apCost = 2,
        energyCost = 20,
        cooldown = 1,
        targetAltitude = "air-to-land",
        description = "Disabling beam weapon"
    }
}
```

**Estimated time:** 5 hours

### Step 5: Integration with Geoscape (4 hours)
**Description:** Connect interception screen to Geoscape mission system  
**Files to modify:**
- `engine/geoscape/ui/geoscape_view.lua` - Add interception button
- `engine/geoscape/systems/mission_manager.lua` - Interception initiation

**Implementation:**
```lua
-- In GeoscapeView:onMissionClick(mission)
function GeoscapeView:onMissionClick(mission)
    -- Check if player has crafts in same province
    local craftsInProvince = CraftManager:getCraftsInProvince(mission.province)
    
    if #craftsInProvince > 0 then
        -- Show interception dialog
        self:showInterceptionDialog(mission, craftsInProvince)
    else
        -- Show mission details, prompt to send craft
        self:showMissionDetailsPanel(mission)
    end
end

function GeoscapeView:showInterceptionDialog(mission, crafts)
    -- Dialog showing available crafts
    -- "Start Interception" button
    -- "View Details" button
    -- "Cancel" button
end

function GeoscapeView:startInterception(mission, selectedCrafts)
    -- Gather player forces
    local playerForces = {
        crafts = selectedCrafts,
        base = self:getBaseInProvince(mission.province)
    }
    
    -- Transition to interception screen
    StateManager:setState("interception", {
        mission = mission,
        playerForces = playerForces
    })
end
```

**Estimated time:** 4 hours

### Step 6: Victory/Defeat Conditions (3 hours)
**Description:** Implement win/loss conditions and transitions  
**Files to modify:**
- `engine/interception/systems/interception_manager.lua` - Add transition dialogs

**Estimated time:** 3 hours

### Step 7: Testing & Balancing (5 hours)
**Description:** Test interception gameplay and balance weapons/AP costs  
**Files to create:**
- `engine/interception/tests/test_interception.lua` - Test suite

**Test cases:**
- Start interception with 1 craft vs 1 UFO
- Start interception with multiple crafts
- Base defense participation
- Altitude restrictions work correctly
- AP/energy systems function
- Weapon cooldowns
- Win/loss conditions
- Retreat functionality
- Transition to Battlescape

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture
Interception screen is a self-contained mini-game state. Uses same AP/energy system as Battlescape for consistency. Units are temporary wrappers around crafts/bases/missions.

### Key Components
- **InterceptionManager:** State controller, turn management, AI
- **InterceptionUnit:** Unified combat unit for crafts/bases/missions
- **InterceptionView:** UI rendering with 3-layer layout
- **Weapon System:** Range, altitude restrictions, cooldowns
- **Turn System:** 1 turn = 5 minutes, all units 4 AP

### Dependencies
- Geoscape mission system
- Craft system
- Base system (defense facilities)
- Mission entities
- State manager
- Widget library (buttons, panels)

---

## Testing Strategy

### Unit Tests
- InterceptionUnit AP/energy management
- Weapon usage validation
- Altitude compatibility checks
- Damage calculations
- Cooldown tracking

### Integration Tests
- Geoscape → Interception transition
- Interception → Battlescape transition
- Interception → Geoscape return
- Base defense integration
- Multi-craft coordination

### Manual Testing Steps
1. Detect mission on Geoscape
2. Deploy craft to mission province
3. Click mission, start interception
4. Verify correct units appear in correct layers
5. Select unit, use weapon on target
6. Verify AP/energy consumption
7. End turn, verify enemy AI acts
8. Destroy enemy, choose Battlescape or retreat
9. Test retreat mid-combat
10. Test base defense participation

### Expected Results
- Smooth transitions between states
- Clear visual feedback for actions
- AI provides meaningful challenge
- No performance issues
- Console shows clear combat log

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging
```lua
-- Enable debug modes
InterceptionManager.debugMode = true

-- Debug commands
DebugCommands.startTestInterception = function()
    local testMission = {
        name = "Test UFO",
        type = "ufo",
        altitude = "air",
        health = 100,
        maxHealth = 100,
        weapons = {
            { name = "Plasma", damage = 40, apCost = 2, energyCost = 10, targetAltitude = "air-to-air" }
        }
    }
    
    local testCraft = {
        name = "Interceptor-1",
        altitude = "air",
        health = 150,
        maxHealth = 150,
        weapons = {
            { name = "Cannon", damage = 30, apCost = 2, energyCost = 10, targetAltitude = "air-to-air" }
        }
    }
    
    StateManager:setState("interception", {
        mission = testMission,
        playerForces = { crafts = {testCraft} }
    })
end

-- Instant win
DebugCommands.interceptionWin = function()
    for _, unit in ipairs(InterceptionManager.enemyUnits) do
        unit.health = 0
        unit:onDestroyed()
    end
end
```

### Console Output
```
[Interception] Starting interception: Scout UFO Alpha
[Interception] Player units: 2, Enemy units: 1
[Interception] Turn 1 (Time: 5 minutes)
[Interception] Interceptor-1: AP=4, Energy=100
[Interception] Interceptor-1 used Cannon on Scout UFO Alpha for 28 damage
[Interception] Scout UFO Alpha health: 72 (-28)
[Interception] Enemy phase starting...
[Interception] Scout UFO Alpha used Plasma Cannon on Interceptor-1 for 37 damage
[Interception] Enemy defeated! Proceeding to ground assault...
```

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add InterceptionManager API
- [x] `wiki/FAQ.md` - Explain interception mechanics
- [ ] `engine/interception/README.md` - System overview
- [ ] Code comments - Inline documentation

---

## Notes

- Interception as "card battle game" creates distinct feel from Battlescape
- No movement keeps gameplay fast and tactical
- Altitude restrictions add strategic depth
- Base defense makes base location matter
- Consider special abilities: evasion, shields, repairs
- Future: craft formations, squadron bonuses

---

## Blockers

- Requires Geoscape mission detection system
- Requires Craft system with equipment
- Requires Base system with defense facilities
- Requires Mission entities with combat properties

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling
- [ ] Performance optimized (<2ms per turn)
- [ ] Console debugging statements
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] UI grid-aligned (24×24 pixels)
- [ ] Theme system used
- [ ] Transitions smooth

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
