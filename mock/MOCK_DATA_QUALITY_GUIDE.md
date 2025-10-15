# Mock Data Quality Guide

## 🎯 Purpose

This guide ensures all mock data generators produce **production-quality test data** that accurately represents real game scenarios.

## 📊 Quality Standards

### 1. Realistic Values
✅ Use values from actual game design documents  
✅ Ensure balance between different unit types  
✅ Include edge cases (min/max values)  
✅ Reflect game progression (early/mid/late game)  

### 2. Complete Data Structures
✅ All required fields present  
✅ Proper data types for each field  
✅ Nested structures fully populated  
✅ Optional fields with sensible defaults  

### 3. Variety & Diversity
✅ Multiple variations of each type  
✅ Different difficulty levels  
✅ Various tactical scenarios  
✅ Edge cases and corner cases  

### 4. Consistency
✅ Related values make logical sense  
✅ Cross-references are valid  
✅ Progression is realistic  
✅ Balance is maintained  

## 🎭 Mock Data Categories

### Units (mock/units.lua)

**Quality Checklist:**
- [ ] Realistic stat distributions (30-80 range)
- [ ] Class-specific loadouts
- [ ] Rank progression (Rookie → Colonel)
- [ ] Wound severity levels
- [ ] Enemy type variations
- [ ] Civilian variations

**Example: High-Quality Soldier**
```lua
{
    id = "SOLDIER_001",
    name = "John Smith",
    rank = "SERGEANT",
    class = "ASSAULT",
    level = 5,
    xp = 2400,
    
    -- Balanced stats for Sergeant
    stats = {
        health = {current = 80, max = 80},
        aim = 75,        -- Good accuracy
        will = 65,       -- Above average
        defense = 45,    -- Moderate
        hack = 30,       -- Low for assault
        mobility = 14,   -- High for assault
        psionic = 0      -- Not a psion
    },
    
    -- Class-appropriate loadout
    equipment = {
        weapon = "ASSAULT_RIFLE_T2",
        armor = "CARAPACE_ARMOR",
        grenade = "FRAG_GRENADE",
        utility = "MEDKIT"
    },
    
    -- Realistic status
    status = {
        wounded = false,
        fatigued = false,
        shaken = false,
        bleeding = false
    },
    
    -- Progression tracking
    kills = 23,
    missions = 18,
    promotionReady = false
}
```

### Items (mock/items.lua)

**Quality Checklist:**
- [ ] Balanced weapon stats
- [ ] Tier progression (T1 → T3)
- [ ] Ammo capacity realistic
- [ ] Armor provides meaningful protection
- [ ] Grenades have area effects
- [ ] Research requirements accurate

**Example: High-Quality Weapon**
```lua
{
    id = "ASSAULT_RIFLE_T2",
    name = "Magnetic Rifle",
    type = "RIFLE",
    tier = 2,
    
    -- Balanced damage
    damage = {min = 6, max = 8},
    critChance = 0.10,
    critDamage = 2.0,
    
    -- Realistic accuracy
    baseAccuracy = 75,
    accuracyFalloff = 0.03,  -- 3% per tile
    
    -- Ammo and range
    ammo = {current = 30, max = 30},
    range = 27,
    
    -- TU costs (balanced)
    tuCost = {
        snap = 25,    -- Quick shot
        aimed = 40,   -- Accurate shot
        auto = 35,    -- Burst fire
        reload = 25
    },
    
    -- Requirements
    requiredResearch = "MAGNETIC_WEAPONS",
    requiredTech = 2,
    
    -- Manufacturing
    buildCost = {
        supplies = 75,
        alloys = 15,
        elerium = 0,
        time = 10  -- days
    }
}
```

### Battlescape (mock/battlescape.lua)

**Quality Checklist:**
- [ ] Realistic map sizes (20x20 to 60x60)
- [ ] Proper spawn zone separation
- [ ] Varied cover placement
- [ ] Elevation differences
- [ ] Line of sight obstacles
- [ ] Balanced scenarios

**Example: High-Quality Battlefield**
```lua
{
    id = "URBAN_MEDIUM",
    width = 40,
    height = 40,
    terrain = "urban",
    
    -- Strategic spawn zones
    spawnZones = {
        xcom = {
            {x = 2, y = 20, z = 0},
            {x = 4, y = 20, z = 0},
            {x = 2, y = 22, z = 0},
            {x = 4, y = 22, z = 0},
            {x = 3, y = 21, z = 1}  -- Elevated position
        },
        alien = {
            {x = 36, y = 20, z = 0},
            {x = 38, y = 20, z = 0},
            {x = 36, y = 22, z = 0},
            {x = 38, y = 22, z = 0},
            {x = 37, y = 21, z = 1}
        }
    },
    
    -- Tactical cover
    cover = {
        {x = 10, y = 15, type = "FULL", height = 2, destructible = true},
        {x = 15, y = 15, type = "HALF", height = 1, destructible = true},
        {x = 20, y = 20, type = "FULL", height = 2, destructible = false},  -- Building
        {x = 25, y = 15, type = "HALF", height = 1, destructible = true},
        {x = 30, y = 15, type = "FULL", height = 2, destructible = true}
    },
    
    -- Elevation for tactics
    elevation = {
        {x = 15, y = 10, z = 2},  -- Rooftop
        {x = 25, y = 10, z = 2},  -- Rooftop
        {x = 20, y = 20, z = 3}   -- Tall building
    },
    
    -- Environmental
    lighting = "DAY",
    weather = "CLEAR",
    visibility = 30,  -- tiles
    
    -- Mission params
    turnLimit = 20,
    reinforcementTurn = 10,
    extractionZone = {x = 2, y = 2, radius = 3}
}
```

## 🎯 Best Practices

### 1. Use Named Constants
```lua
-- Bad
local damage = 15

-- Good
local ASSAULT_RIFLE_BASE_DAMAGE = 15
local SECTOID_BASE_HEALTH = 40
```

### 2. Include Edge Cases
```lua
-- Minimum values
getWeapon("PISTOL")  -- Weakest weapon

-- Maximum values
getWeapon("PLASMA_CANNON")  -- Strongest weapon

-- Edge cases
getWoundedSoldier("CRITICAL")  -- Almost dead
getVeteran()  -- Max level soldier
```

### 3. Provide Variations
```lua
-- Different difficulties
getMission("EASY")
getMission("NORMAL")
getMission("IMPOSSIBLE")

-- Different scenarios
getCombatScenario("balanced")    -- Even fight
getCombatScenario("outnumbered") -- Hard fight
getCombatScenario("ambush")      -- Surprise attack
```

### 4. Document Data Ranges
```lua
---Generate a soldier with specified rank
---@param name string Soldier name
---@param rank string Rank: "ROOKIE" (0), "SQUADDIE" (1), "CORPORAL" (2), 
---                   "SERGEANT" (3), "LIEUTENANT" (4), "CAPTAIN" (5), "COLONEL" (6)
---@return table Soldier data with stats scaled to rank (Rookie: 40-60, Colonel: 70-90)
function MockUnits.getSoldier(name, rank)
```

## 📈 Stat Balance Guidelines

### Soldier Stats (by Rank)
```lua
ROOKIE:      40-60  (Starting soldiers)
SQUADDIE:    50-65  (1-2 missions)
CORPORAL:    55-70  (3-5 missions)
SERGEANT:    60-75  (6-10 missions)
LIEUTENANT:  65-80  (11-15 missions)
CAPTAIN:     70-85  (16-20 missions)
COLONEL:     75-90  (21+ missions)
```

### Enemy Stats (by Type)
```lua
SECTOID:     Health: 40,  Aim: 55,  Defense: 10  (Early game)
THIN_MAN:    Health: 50,  Aim: 65,  Defense: 15  (Early-mid)
MUTON:       Health: 100, Aim: 70,  Defense: 25  (Mid game)
CHRYSSALID: Health: 80,  Aim: 0,   Defense: 30  (Melee)
SECTOPOD:    Health: 250, Aim: 85,  Defense: 40  (Late game)
```

### Weapon Damage (by Tier)
```lua
TIER 1 (Ballistic):  3-5 damage,  65-75% accuracy
TIER 2 (Magnetic):   6-8 damage,  70-80% accuracy
TIER 3 (Plasma):     8-12 damage, 75-85% accuracy
```

## 🔍 Validation Checklist

Before committing mock data changes:

- [ ] All required fields present
- [ ] Data types correct
- [ ] Values within realistic ranges
- [ ] Balance maintained across variations
- [ ] Edge cases included
- [ ] Documentation updated
- [ ] Test coverage for new generators
- [ ] No hardcoded magic numbers

## 🎨 Example: Complete Mock Data Flow

```lua
-- 1. Generate balanced squad
local squad = MockUnits.generateSquad(6, {
    "ASSAULT", "HEAVY", "SNIPER", "SUPPORT", "GRENADIER", "SPECIALIST"
})

-- 2. Equip with tier 2 gear
for _, soldier in ipairs(squad) do
    soldier.weapon = MockItems.getWeapon(soldier.class .. "_T2")
    soldier.armor = MockItems.getArmor("CARAPACE")
end

-- 3. Create battlefield
local battlefield = MockBattlescape.getBattlefield(40, 40, "urban")

-- 4. Generate enemies
local enemies = MockUnits.generateEnemyGroup(8, {"SECTOID", "THIN_MAN"})

-- 5. Create scenario
local scenario = {
    map = battlefield,
    xcomTeam = squad,
    alienTeam = enemies,
    objective = "ELIMINATE_ALL",
    turnLimit = 20,
    difficulty = "NORMAL"
}

-- Result: Realistic, balanced combat scenario
```

## 📚 Resources

- Game Design Doc: `wiki/numbers.md`
- Balance Sheet: `wiki/references.md`
- X-COM UFO Defense: https://www.ufopaedia.org/
- OpenXcom: https://openxcom.org/

---

**Remember:** High-quality mock data = High-quality tests = High-quality game! 🎯
