# Interception System

Turn-based card battle system for craft-vs-UFO air combat.

## Overview

The Interception system handles tactical combat between player craft and UFOs. Unlike the tactical battlescape, interceptions use a turn-based card game-style system with altitude layers, positioning, and simplified combat mechanics. Think of it as a strategic mini-game before crash site missions.

## Architecture

### Core Components

```
engine/interception/
├── logic/                      -- Combat logic
│   ├── combat_system.lua       -- Damage calculation
│   ├── initiative_system.lua   -- Turn order
│   └── ai_controller.lua       -- UFO behavior
└── README.md                   -- This file

engine/scenes/
└── interception_screen.lua     -- Main screen & UI
```

### Related Systems

- **Geoscape**: Launches interceptions when craft reaches UFO
- **Battlescape**: Crash sites from successful interceptions
- **Crafts**: Player craft definitions and equipment
- **Missions**: UFO types and behavior patterns

## Altitude System

### Three Layers

1. **AIR**
   - High-speed aerial combat
   - Missiles most effective
   - Fast movement, low stealth
   - Default starting layer

2. **LAND/WATER**
   - Surface-level engagements
   - Cannons and guns effective
   - Medium speed, medium stealth
   - Forced layer for grounded UFOs

3. **UNDERGROUND/UNDERWATER**
   - Stealthy approach
   - Limited weapons work
   - Slow movement, high stealth
   - Special tech required

### Layer Effects

```lua
-- Altitude modifiers
ALTITUDE_EFFECTS = {
    air = {
        missileAccuracy = 1.0,    -- 100% accuracy
        cannonAccuracy = 0.5,     -- 50% accuracy
        detectionRange = 100,     -- Full radar
        stealthBonus = 0          -- No stealth
    },
    land = {
        missileAccuracy = 0.7,    -- 70% accuracy
        cannonAccuracy = 1.0,     -- 100% accuracy
        detectionRange = 75,      -- Reduced radar
        stealthBonus = 0.2        -- +20% stealth
    },
    underground = {
        missileAccuracy = 0.3,    -- 30% accuracy
        cannonAccuracy = 0.5,     -- 50% accuracy
        detectionRange = 25,      -- Very limited
        stealthBonus = 0.5        -- +50% stealth
    }
}
```

## Combat Mechanics

### Turn Structure

1. **Initiative Phase** - Determine turn order based on craft speed
2. **Player Phase** - Player chooses actions for craft
3. **Enemy Phase** - AI executes UFO actions
4. **Resolution Phase** - Damage applied, status checked
5. **Next Turn** - Repeat until victory/defeat/retreat

### Actions (Cost AP)

- **Attack** (2 AP): Fire weapons at target
- **Evade** (1 AP): +50% defense until next turn
- **Change Altitude** (3 AP): Move between layers
- **Scan** (1 AP): Reveal enemy info/position
- **Retreat** (4 AP): Attempt to flee (requires full AP)

### Action Points

Each unit gets **4 AP per turn**. Unused AP carries over (max 6 AP).

```lua
-- Example turn
playerCraft.ap = 4

-- Attack UFO (costs 2 AP)
attack(playerCraft, ufo)  -- AP = 2

-- Evade (costs 1 AP)
evade(playerCraft)        -- AP = 1

-- Next turn starts with 1 + 4 = 5 AP
```

## Weapons

### Weapon Types

| Type | Damage | Range | Accuracy | Best Altitude |
|------|--------|-------|----------|---------------|
| **Missiles** | High | Long | 70% | Air |
| **Cannons** | Medium | Medium | 80% | Land/Water |
| **Lasers** | Low | Long | 95% | Any |
| **Plasma** | High | Short | 85% | Any |

### Damage Formula

```lua
damage = weaponDamage * accuracyRoll * altitudeModifier - targetArmor
```

## Combat Flow

### Starting Interception

```lua
-- From Geoscape when craft reaches UFO
local InterceptionScreen = require("scenes.interception_screen")

local battle = InterceptionScreen.new({
    id = "interception_001",
    location = {x = 150, y = 200},
    ufoType = "scout"
})

battle:addPlayerUnit({
    id = "interceptor_01",
    name = "Skyranger-1",
    type = "craft",
    altitude = "air",
    health = 100,
    maxHealth = 100,
    armor = 10,
    weapons = {
        {type = "missiles", damage = 40, ammo = 6},
        {type = "cannon", damage = 20, ammo = 100}
    }
})

battle:addEnemyUnit({
    id = "ufo_scout_01",
    name = "Scout UFO",
    type = "ufo",
    altitude = "air",
    health = 80,
    maxHealth = 80,
    armor = 15,
    weapons = {
        {type = "plasma", damage = 35, ammo = 999}
    }
})

StateManager.switch("interception", battle)
```

### Player Turn

```lua
-- Player selects action
function InterceptionScreen:playerTurn()
    -- Show action cards
    local actions = {
        {name = "Attack", cost = 2},
        {name = "Evade", cost = 1},
        {name = "Change Altitude", cost = 3},
        {name = "Retreat", cost = 4}
    }
    
    -- Wait for player input
    showActionMenu(actions)
end

-- Execute player action
function InterceptionScreen:executeAction(unit, action)
    if action == "attack" then
        self:attack(unit, self.enemyUnits[1])
    elseif action == "evade" then
        self:evade(unit)
    elseif action == "change_altitude" then
        self:changeAltitude(unit, newLayer)
    elseif action == "retreat" then
        self:retreat(unit)
    end
end
```

### Enemy Turn (AI)

```lua
function InterceptionScreen:enemyTurn()
    for _, ufo in ipairs(self.enemyUnits) do
        local action = self:chooseAIAction(ufo)
        
        if action == "attack" then
            local target = self:selectTarget(ufo, self.playerUnits)
            self:attack(ufo, target)
        elseif action == "evade" then
            self:evade(ufo)
        elseif action == "flee" then
            self:retreat(ufo)
        end
    end
    
    self:nextTurn()
end
```

### Victory Conditions

```lua
function InterceptionScreen:checkVictory()
    -- All enemies destroyed
    local enemiesAlive = self:countAliveUnits(self.enemyUnits)
    if enemiesAlive == 0 then
        return "victory"
    end
    
    -- All player units destroyed or retreated
    local playersAlive = self:countAliveUnits(self.playerUnits)
    if playersAlive == 0 then
        return "defeat"
    end
    
    -- UFO escaped
    if ufoRetreatSuccess then
        return "ufo_escaped"
    end
    
    return nil  -- Battle continues
end
```

## Outcomes

### Victory
- UFO destroyed → Crash site mission unlocked
- Earn alien materials, research points
- Craft returns to base

### Defeat
- Player craft destroyed
- Crew KIA, craft lost
- UFO continues mission

### UFO Escaped
- UFO flees successfully
- Mission lost, UFO continues
- Craft returns to base

### Player Retreat
- Craft withdraws safely
- No rewards or losses
- UFO continues mission

## UI Elements

### Combat HUD

```
┌─────────────────────────────────────────────────────┐
│  Turn: 3           Phase: Player                    │
├─────────────────────────────────────────────────────┤
│  [Skyranger-1]             VS        [Scout UFO]    │
│   HP: 85/100                         HP: 40/80      │
│   AP: 4/4                            Altitude: AIR   │
│   Altitude: AIR                                      │
├─────────────────────────────────────────────────────┤
│  Actions:                                           │
│   [Attack] (2 AP)                                   │
│   [Evade] (1 AP)                                    │
│   [Change Alt] (3 AP)                               │
│   [Retreat] (4 AP)                                  │
└─────────────────────────────────────────────────────┘
```

### Combat Log

```lua
combatLog = {
    "Turn 1: Skyranger-1 attacks Scout UFO for 25 damage",
    "Turn 1: Scout UFO evades",
    "Turn 2: Scout UFO attacks Skyranger-1 for 15 damage",
    "Turn 2: Skyranger-1 changes altitude to LAND",
    "Turn 3: Skyranger-1 attacks Scout UFO for 35 damage",
    "Turn 3: Scout UFO DESTROYED"
}
```

## Integration Points

### From Geoscape

```lua
-- Craft intercepts UFO
function Geoscape:launchInterception(craft, ufo)
    local missionData = {
        id = generateMissionId(),
        craft = craft,
        ufo = ufo,
        location = ufo.position
    }
    StateManager.switch("interception", missionData)
end
```

### To Battlescape

```lua
-- Victory leads to crash site
function InterceptionScreen:onVictory()
    local crashSite = {
        type = "crash_site",
        ufoType = self.ufoType,
        location = self.location,
        difficulty = self.difficulty
    }
    
    -- Generate tactical mission
    StateManager.switch("deployment", crashSite)
end
```

### Return to Geoscape

```lua
-- After interception ends
function InterceptionScreen:onBattleEnd(outcome)
    if outcome == "victory" then
        -- Mark UFO as crashed
        Geoscape:createCrashSite(self.location, self.ufoType)
    end
    
    -- Return craft to base
    Geoscape:returnCraft(self.craft)
    
    StateManager.switch("geoscape")
end
```

## Future Enhancements

- [ ] Multiple crafts vs single UFO
- [ ] Formation flying bonuses
- [ ] Weather effects on combat
- [ ] Special pilot abilities
- [ ] Craft equipment loadouts
- [ ] UFO capture attempts
- [ ] Base defense from air
- [ ] Animated combat sequences

## See Also

- [Geoscape README](../geoscape/README.md) - Strategic layer
- [Battlescape README](../battlescape/README.md) - Tactical combat
- [Crafts System](../shared/crafts/craft.lua) - Craft definitions
- [Mission System](../lore/missions/mission.lua) - UFO behavior
