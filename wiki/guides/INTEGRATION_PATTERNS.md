# Integration Patterns Guide

**Version:** 1.0  
**Date:** October 21, 2025  
**Goal:** Common patterns for using multiple APIs together

---

## System Dependency Map

### Complete Hierarchy

```
┌─────────────────────────────────────────┐
│                GEOSCAPE                 │
│         (Strategic Global Layer)        │
│                                         │
│  • World Map & Provinces                │
│  • Mission Generation & Detection       │
│  • Craft Deployment & Travel            │
│  • Faction & Country Relations          │
│  • Economic Funding & Relations         │
└───────────────────┬─────────────────────┘
                    │
        (generates missions & context)
                    │
┌───────────────────▼─────────────────────┐
│              INTERCEPTION                │
│          (Aerial Combat Layer)          │
│                                         │
│  • UFO vs. Craft Combat Resolution     │
│  • Damage Application & Escape Logic   │
│  • Mission Outcome Determination       │
└───────────────────┬─────────────────────┘
                    │
        (passes mission context to battlescape)
                    │
┌───────────────────▼─────────────────────┐
│              BATTLESCAPE                 │
│           (Tactical Combat Layer)       │
│                                         │
│  • Hex-Grid Tactical Maps               │
│  • Unit Combat & Actions                │
│  • Procedurally Generated Map Blocks    │
│  • Line-of-Sight & Accuracy Calculation│
│  • Salvage & XP Generation              │
└───────────────────┬─────────────────────┘
                    │
        (produces salvage, XP, casualties)
                    │
┌───────────────────▼─────────────────────┐
│              BASESCAPE                   │
│        (Operational Management Layer)   │
│                                         │
│  • Salvage Processing & Storage         │
│  • Research & Manufacturing             │
│  • Facility Management & Maintenance    │
│  • Unit Recruitment & Training          │
│  • Base Economy & Resource Production   │
└───────────────────┬─────────────────────┘
                    │
        (produces equipped units & crafts)
                    │
                    └──────────> Back to GEOSCAPE
```

### Core Integration Points

1. **Geoscape → Interception**: Mission context (UFO location, type, equipment)
2. **Interception → Battlescape**: Combat outcome (success/failure/partial)
3. **Battlescape → Basescape**: Salvage (items, resources, XP)
4. **Basescape → Geoscape**: Capabilities (equipped units, available crafts, research unlocks)
5. **Basescape ↔ Geoscape**: Feedback loop (mission success → funding → more research → better missions)

### Horizontal System Integration

**Economy ↔ Suppliers**: Pricing affected by relations  
**Politics ↔ Diplomacy**: Fame affects country interactions  
**AI ↔ Mission Generation**: Faction behavior creates threats  
**Analytics ↔ All Systems**: Event tracking and telemetry  

---

## Pattern 1: Complete Mission Workflow

Integrate: Missions → Geoscape → Battlescape → Economy

```lua
-- 1. Get available missions
local Missions = require("engine.geoscape.mission")
local missions = Missions.getByType("rescue")

-- 2. Create mission instance
local mission = Missions.create(missions[1], 2)  -- Difficulty 2

-- 3. Deploy squad (from Basescape)
local Basescape = require("engine.basescape.basescape")
local squad = {base.units[1], base.units[3], base.units[5]}
local success = Missions.deploySquad(mission, squad)

-- 4. Execute battle (in Battlescape)
local BattleRunner = require("engine.battlescape.battle_runner")
local battleResults = BattleRunner.execute(mission, squad)

-- 5. Complete mission and get rewards (Economy)
local reward = Missions.complete(mission, battleResults)
base.credits = base.credits + reward
print("[MISSION] Completed! Reward: $" .. reward)
```

---

## Pattern 2: Research & Manufacturing Pipeline

Integrate: Research → Manufacturing → Inventory → Economy

```lua
-- 1. Check available technologies
local DataLoader = require("engine.core.data_loader")
local tech = DataLoader.technology.get("tech_plasma_rifle")

-- 2. Start research
local Research = require("engine.basescape.research")
local project = Research.create("tech_plasma_rifle", base)

-- 3. Simulate research completion
project.progress = project.total_cost

-- 4. When research complete, start manufacturing
if Research.complete(project, base) then
    -- Check if recipe exists
    local recipe = DataLoader.recipe.get("recipe_plasma_rifle")
    
    -- 5. Create manufacturing project
    local Manufacturing = require("engine.basescape.manufacturing")
    local production = Manufacturing.createProduct("recipe_plasma_rifle", 5, base)
    
    -- 6. When production complete, add to inventory
    local units, cost = Manufacturing.complete(production, base)
    print("[PRODUCTION] Made " .. units .. " rifles, cost: $" .. cost)
end
```

---

## Pattern 3: Supply Chain Management

Integrate: Geoscape → Economy → Transfer System

```lua
-- 1. Get bases
local Geoscape = require("engine.geoscape.geoscape")
local baseA = Geoscape.Base.get("base_main")
local baseB = Geoscape.Base.get("base_secondary")

-- 2. Check inventory at both bases
local itemToTransfer = "item_medikit"
local quantity = 20

-- 3. Check if baseA has enough
if (baseA.inventory[itemToTransfer] or 0) >= quantity then
    -- 4. Create transfer
    local Transfer = require("engine.geoscape.transfer")
    local transfer = Transfer.create(baseA, baseB, itemToTransfer, quantity)
    
    -- 5. Calculate cost
    local cost = Transfer.calculateCost(transfer)
    print("[TRANSFER] Cost: $" .. cost)
    
    -- 6. Execute transfer
    if base.credits >= cost then
        local success = Transfer.execute(transfer)
        print("[SUCCESS] Items transferred after " .. transfer.estimated_time .. " days")
    end
end
```

---

## Pattern 4: Diplomatic Reputation Management

Integrate: Politics → Geoscape → Economy

```lua
-- 1. Track reputation with nations
local Politics = require("engine.geoscape.politics")
local nations = Politics.Nation.getAll()

-- 2. Check funding based on reputation
local totalFunding = 0
for _, nation in ipairs(nations) do
    local rep = Politics.Nation.getReputation(nation.id)
    
    -- 3. Reputation affects funding
    local funding = nation.initial_funding
    if rep > 75 then
        funding = funding * 1.25  -- Bonus for high rep
    elseif rep < 25 then
        funding = funding * 0.75  -- Penalty for low rep
    end
    
    totalFunding = totalFunding + funding
end

-- 4. Update base budget
base.monthly_funding = totalFunding

-- 5. Perform diplomatic action if needed
if reputation < 50 then
    print("[ALERT] Low reputation! Consider diplomatic action")
    local action = Politics.Diplomacy.performAction("trade_agreement", nation.id)
    print("[DIPLOMACY] Action outcome: " .. action.outcome)
end
```

---

## Pattern 5: Intercept & Defense

Integrate: Crafts → Interception → Geoscape

```lua
-- 1. Detect UFO threat
local Geoscape = require("engine.geoscape.geoscape")
local activeUFOs = Geoscape.UFO.getActive()

for _, ufo in ipairs(activeUFOs) do
    print("[ALERT] UFO detected: " .. ufo.type)
    
    -- 2. Get available crafts in region
    local Base = require("engine.basescape.basescape")
    local nearbyBase = Base.getClosestBase(ufo.position)
    local crafts = nearbyBase.hangar
    
    if #crafts > 0 then
        -- 3. Select craft for intercept
        local craft = crafts[1]
        
        -- 4. Check fuel
        if craft.fuel_current > 100 then
            -- 5. Initiate interception
            local Interception = require("engine.geoscape.interception")
            local battle = Interception.begin(craft, ufo)
            print("[INTERCEPT] Battle started: " .. battle.id)
            
            -- 6. Run battle
            while battle.status == "active" do
                Interception.resolveTurn(battle)
            end
            
            -- 7. Process results
            local outcome = Interception.getOutcome(battle)
            print("[RESULT] " .. outcome.winner)
        end
    end
end
```

---

## Pattern 6: Personnel Management

Integrate: Units → Basescape → Facilities

```lua
-- 1. Get available personnel
local Basescape = require("engine.basescape.basescape")
local base = Basescape.Base.get("base_main")
local availableUnits = base.available_units

-- 2. Get facilities
local lab = base.facilities.laboratory

-- 3. Check facility capacity
if #lab.assigned_personnel < lab.capacity then
    -- 4. Assign unit to facility
    local unit = availableUnits[1]
    local success = Basescape.Personnel.assignToFacility(unit, lab, "research")
    
    -- 5. Check efficiency
    if success then
        local efficiency = Basescape.Facility.getEfficiency(lab, "research")
        print("[ASSIGNMENT] " .. unit.name .. " assigned")
        print("[EFFICIENCY] " .. string.format("%.1f", efficiency) .. "x modifier")
        
        -- 6. Calculate contribution
        local dailyProgress = 3 * efficiency  -- 3 base progress
        print("[PROGRESS] Daily contribution: " .. dailyProgress .. " man-days")
    end
end
```

---

## Pattern 7: Combat Preparation

Integrate: Units → Equipment → Squad Composition

```lua
-- 1. Get available units
local base = require("engine.basescape.basescape").Base.get("base_main")
local units = base.units

-- 2. Get equipment data
local DataLoader = require("engine.core.data_loader")

-- 3. Prepare squad with balanced composition
local squad = {}

-- Add assault unit with rifle
local assault = units[1]
assault.equipment = DataLoader.weapon.get("weapon_rifle_conventional")
table.insert(squad, assault)

-- Add sniper with sniper rifle
local sniper = units[2]
sniper.equipment = DataLoader.weapon.get("weapon_sniper_rifle")
table.insert(squad, sniper)

-- Add support with heavy weapon
local support = units[3]
support.equipment = DataLoader.weapon.get("weapon_heavy_cannon")
table.insert(squad, support)

-- 4. Add consumables to squad inventory
for _, unit in ipairs(squad) do
    unit.inventory = {
        item_medikit = 2,
        item_grenade = 4,
        item_ammo = 200
    }
end

-- 5. Deploy squad
print("[SQUAD] Composition prepared: " .. #squad .. " units")
for i, unit in ipairs(squad) do
    print("[UNIT " .. i .. "] " .. unit.name .. " - " .. unit.class)
end
```

---

## Pattern 8: Analytics & Metrics

Integrate: Analytics → All Systems

```lua
-- 1. Get analytics module
local Analytics = require("engine.analytics.analytics")

-- 2. Track mission success rate
local missionStats = Analytics.getMissionStats()
print("[STATS] Missions: " .. missionStats.total .. " total")
print("[STATS] Success rate: " .. missionStats.success_rate .. "%")

-- 3. Track research progress
local researchStats = Analytics.getResearchStats()
print("[STATS] Techs researched: " .. researchStats.technologies_researched)

-- 4. Track economy
local economyStats = Analytics.getEconomyStats()
print("[STATS] Total credits earned: $" .. economyStats.total_credits_earned)
print("[STATS] Total spent: $" .. economyStats.total_spent)

-- 5. Track combat
local combatStats = Analytics.getCombatStats()
print("[STATS] Battles: " .. combatStats.total_battles)
print("[STATS] Win rate: " .. combatStats.win_rate .. "%")

-- 6. Generate report
local report = Analytics.generateReport()
print("[REPORT] Campaign summary:")
print(report)
```

---

## Common Pitfalls

### ❌ Loading data multiple times
```lua
-- BAD - Reloading every frame
for i = 1, 100 do
    local item = DataLoader.item.get("item_medikit")
end

-- GOOD - Load once, reuse
local item = DataLoader.item.get("item_medikit")
for i = 1, 100 do
    useItem(item)
end
```

### ❌ Not checking prerequisites
```lua
-- BAD - Assuming tech is unlocked
local recipe = DataLoader.recipe.get("recipe_plasma_rifle")

-- GOOD - Check technology first
local tech = DataLoader.technology.get("tech_plasma_rifle")
if base.technologies[tech.id] then
    local recipe = DataLoader.recipe.get("recipe_plasma_rifle")
end
```

### ❌ Ignoring capacity limits
```lua
-- BAD - No storage check
base.inventory[item] = (base.inventory[item] or 0) + 100

-- GOOD - Check storage first
if hasStorageSpace(base, 100) then
    base.inventory[item] = (base.inventory[item] or 0) + 100
end
```

### ❌ Not handling failures
```lua
-- BAD - Assuming success
local success, msg = Marketplace.buyItem(base, item, quantity)

-- GOOD - Check success
if success then
    print("[SUCCESS] " .. msg)
else
    print("[ERROR] " .. msg)
end
```

---

## Best Practices

1. **Load once, use many times** - Cache data at startup
2. **Check prerequisites** - Verify conditions before operations
3. **Validate input** - Check parameters exist
4. **Handle errors** - Don't assume success
5. **Use consistent names** - Match API naming conventions
6. **Batch operations** - Update multiple items together
7. **Log decisions** - Use print for debugging
8. **Test edge cases** - Verify with zero/max values

---

## Next Steps

- Study individual API files for detailed documentation
- Create small test mods to learn patterns
- Review existing code for real examples
- Join community for help and feedback

Happy integrating! 🚀
