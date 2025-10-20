# AlienFall Geoscape API

**Audience**: Developers | **Status**: Active | **Last Updated**: October 2025

API reference for the Geoscape strategic layer systems.

---

## Overview

The Geoscape manages global strategic operations including:
- World map and provinces
- Craft movement and travel
- Mission generation and detection
- UFO interception mechanics
- Country relationships and funding
- Escalation meter and threat levels

**Key Modules**:
- `engine/geoscape/` - Main Geoscape subsystem
- Mission generation and management
- Craft control and pathfinding

---

## Core Systems

### GeoManager

Main Geoscape coordinator.

```lua
-- Initialize Geoscape
Geoscape.init()

-- Get current world
local world = Geoscape.getWorld()

-- Get all provinces
local provinces = world:getProvinces()

-- Get specific province
local province = world:getProvince(x, y)

-- Update Geoscape (called each turn)
Geoscape.update()
```

### Craft Management

```lua
-- Deploy craft to destination
Geoscape.deployCraft(craft, targetProvince)

-- Get craft position
local province = craft:getLocation()

-- Set craft destination (pathfinding auto-calculated)
craft:setDestination(targetProvince)

-- Get movement points available
local mp = craft:getMovementPoints()

-- Travel to next province (consumes movement points)
craft:travel()

-- Get all player crafts
local crafts = Geoscape.getCrafts()

-- Get crafts in province
local localCrafts = province:getCrafts()
```

### Mission Management

```lua
-- Get all active missions
local missions = Geoscape.getMissions()

-- Get missions in province
local provinceMissions = province:getMissions()

-- Get mission details
print(mission.type)  -- UFO, AlienBase, Site, etc.
print(mission.threat)  -- Difficulty level

-- Detect mission (removes cover)
Geoscape.detectMission(mission)

-- Intercept UFO with craft
Geoscape.interceptMission(craft, mission)

-- Deploy to ground battle
Geoscape.deployBattle(craft, mission)
```

### Country & Funding

```lua
-- Get all countries
local countries = Geoscape.getCountries()

-- Get country relations
local relations = country:getRelations()

-- Get monthly funding
local funding = country:getFunding()

-- Update relations
country:modifyRelations(delta)  -- delta: -100 to +100

-- Get country satisfaction
local satisfaction = country:getSatisfaction()
```

### Escalation & Threat

```lua
-- Get escalation meter (0-100)
local escalation = Geoscape.getEscalation()

-- Increase escalation
Geoscape.addEscalation(10)

-- Get threat level by faction
local threat = Geoscape.getThreatLevel(faction)

-- Check if armada event triggered
if Geoscape.getEscalation() > 75 then
    -- Generate UFO armada
end
```

---

## Detailed APIs

### World

```lua
-- Get world dimensions
local width = world:getWidth()
local height = world:getHeight()

-- Get province
local province = world:getProvince(x, y)
world:setProvince(x, y, province)

-- Pathfinding
local path = world:findPath(start, goal, craft)

-- Get adjacent provinces
local neighbors = world:getNeighbors(province)

-- Get biome at location
local biome = world:getBiome(x, y)
```

### Province

```lua
-- Province properties
print(province.name)
print(province.country)
print(province.biome)
print(province.economy)

-- Get crafts in province
local crafts = province:getCrafts()

-- Get missions in province
local missions = province:getMissions()

-- Get base in province (if player has one)
local base = province:getBase()

-- Detect coverage
local coverage = province:getDetectionCoverage()
```

### Craft

```lua
-- Properties
print(craft.id)
print(craft.type)  -- Fighter, Bomber, etc.
print(craft.hp)
print(craft.maxHP)
print(craft.fuel)
print(craft.maxFuel)
print(craft.speed)

-- Movement
craft:setDestination(province)
local destination = craft:getDestination()
local location = craft:getLocation()

-- Combat
craft:addWeapon(weaponData)
craft:removeDamage(damageAmount)
craft:repair(amount)

-- Status
craft:isDamaged()
craft:hasFuel()
```

### Mission

```lua
-- Mission properties
print(mission.type)  -- "UFO", "AlienBase", "Site"
print(mission.threat)  -- Difficulty (1-10)
print(mission.province)
print(mission.cover)  -- Stealth (0-100)

-- Update mission
mission:reduceCover(amount)  -- Detected gradually
mission:updateLocation()  -- For UFOs

-- Convert to battle
local battleData = mission:toBattle()

-- Remove mission
mission:destroy()
```

---

## Common Patterns

### Turn-Based Updates

```lua
function love.update(dt)
    -- Process Geoscape turn
    if StateManager.is("geoscape") then
        if turnActive then
            Geoscape.update()
            processPlayerInput()
        end
    end
end
```

### Craft Interception

```lua
function Geoscape.handleInterception(craft, mission)
    -- Calculate success probability
    local success = calculateInterceptSuccess(craft, mission)
    
    if math.random() < success then
        print("[Geoscape] Interception successful!")
        mission:destroy()
    else
        print("[Geoscape] UFO escaped, engaging ground forces...")
        triggerBattlescape(craft, mission)
    end
end
```

### Mission Generation

```lua
function Geoscape.generateMissions()
    for country in pairs(countries) do
        -- Generate based on escalation
        local count = country:calculateMissionCount(escalation)
        
        for i = 1, count do
            local province = country:selectRandomProvince()
            local mission = createMission(province)
            province:addMission(mission)
        end
    end
end
```

---

## Examples

### Example 1: Deploy Craft

```lua
-- Player clicks on province to deploy craft
function handleCraftDeploy(craft, targetProvince)
    -- Check if craft can reach (fuel, movement points)
    if not craft:canReach(targetProvince) then
        print("[Geoscape] Insufficient fuel or movement")
        return false
    end
    
    -- Set destination
    craft:setDestination(targetProvince)
    print("[Geoscape] Craft en route to " .. targetProvince.name)
    
    return true
end

-- Next turn: craft travels
function Geoscape.update()
    for _, craft in ipairs(activeCrafts) do
        if craft:hasDestination() then
            craft:travel()
            
            -- Check for interception
            checkForMissions(craft)
        end
    end
end
```

### Example 2: Intercept UFO

```lua
function Geoscape.attemptInterception(craft, ufo)
    print("[Geoscape] Intercepting UFO with " .. craft.id)
    
    -- Roll for success
    local craftSkill = craft:getInterceptionSkill()
    local ufoDefense = ufo:getDefenseRating()
    
    local successChance = (craftSkill - ufoDefense) / 100
    local roll = math.random()
    
    if roll < successChance then
        print("[Geoscape] Interception successful!")
        ufo:destroy()
    else
        print("[Geoscape] UFO evaded, engaging in ground battle...")
        StateManager.switchTo("battlescape")
    end
end
```

---

## Related Documentation

- **[Geoscape Mechanics](../Geoscape.md)** - Design and mechanics
- **[Core API](CORE.md)** - Core systems reference
- **[Battlescape API](BATTLESCAPE.md)** - Tactical combat integration

---

**Last Updated**: October 2025 | **Status**: Active

