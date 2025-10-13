# Task: Mission Salvage & Victory/Defeat Resolution

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a complete post-battle salvage system that processes mission outcomes based on victory or defeat. On victory, collect all enemy corpses, items, weapons, and special salvage (UFO components, elerium). On defeat, lose all units outside landing zones and forfeit all loot. Track mission scoring including penalties for civilian/neutral casualties and property destruction.

---

## Purpose

**Why is this needed?**
- Provides tangible rewards for successful missions (resources, corpses, technology)
- Creates meaningful consequences for defeat (unit/equipment loss)
- Implements risk/reward balance (retreat to landing zone vs. push for victory)
- Adds depth through salvage management and base inventory
- Penalizes careless tactics (civilian casualties, excessive destruction)
- Mirrors X-COM's post-mission salvage and scoring system

**What problem does it solve?**
- Currently no post-battle rewards or consequences
- No resource/corpse collection system
- No mission scoring or performance evaluation
- No penalty system for collateral damage
- Missing critical gameplay loop: Battle → Salvage → Research → Manufacturing

---

## Requirements

### Functional Requirements - Victory Salvage
- [ ] All killed enemy units converted to race-specific corpse items (e.g., "Dead Sectoid")
- [ ] All items from killed enemies collected (weapons, grenades, equipment)
- [ ] All items from alive enemies collected (if captured/stunned)
- [ ] All objects/items on battlefield collected (dropped weapons, mission objects)
- [ ] Ally units not touched if alive
- [ ] Ally units collected if dead (corpse + equipment)
- [ ] Neutral units ignored (not collected even if dead)
- [ ] Special salvage from destroyable objects (UFO walls → alloys, elerium engines)
- [ ] All salvage transferred to player base inventory
- [ ] Mission medals/achievements awarded for objectives
- [ ] Experience points awarded to surviving units
- [ ] Mission score calculated (objectives, efficiency, time)

### Functional Requirements - Defeat Salvage
- [ ] All units outside landing zones lost permanently
- [ ] Units inside landing zones survive and return to base
- [ ] No items/resources collected from battlefield
- [ ] No corpses collected
- [ ] No special salvage obtained
- [ ] No medals awarded
- [ ] Experience points still awarded (reduced/standard rate)
- [ ] Negative mission score applied

### Functional Requirements - Scoring System
- [ ] Base score for mission completion
- [ ] Bonus for objectives completed
- [ ] Bonus for speed (turn count)
- [ ] Bonus for low casualties
- [ ] Penalty for civilian/neutral deaths
- [ ] Penalty for property destruction (in public areas)
- [ ] Penalty for mission failure
- [ ] Score affects country relations and funding

### Technical Requirements
- [ ] Post-battle salvage state/screen
- [ ] Item collection system from battlefield
- [ ] Corpse generation from killed units
- [ ] Base inventory integration
- [ ] Special salvage rules for objects (UFO components)
- [ ] Landing zone boundary checking for unit survival
- [ ] Mission scoring algorithm
- [ ] Civilian casualty tracking
- [ ] Property damage tracking
- [ ] State transition: Battlescape → Salvage Screen → Geoscape

### Acceptance Criteria
- [ ] Victory shows salvage screen with collected items/corpses
- [ ] Defeat shows loss report with surviving/lost units
- [ ] All enemy corpses converted to appropriate items
- [ ] All enemy equipment collected
- [ ] Dead ally units become corpses + equipment
- [ ] Neutral units never collected
- [ ] Special objects convert to salvage items
- [ ] Landing zones correctly determine unit survival on defeat
- [ ] Mission score displayed with breakdown
- [ ] Civilian casualties increase score penalty
- [ ] All salvage appears in base inventory
- [ ] Experience gained by surviving units
- [ ] Smooth transition back to geoscape

---

## Plan

### Step 1: Salvage Data Structures (4 hours)
**Description:** Define data structures for salvage items, corpses, and mission results

**Files to create:**
- `engine/battlescape/logic/salvage_config.lua` - Salvage rules and conversion
- `engine/battlescape/logic/mission_result.lua` - Mission outcome data

**Data Structures:**
```lua
-- MissionResult
{
    missionId = "mission_001",
    victory = true,  -- true/false
    
    -- Units
    unitsDeployed = 6,
    unitsKilled = 1,
    unitsSurvived = 5,
    unitsLost = 0,  -- Lost on defeat (outside landing zones)
    
    -- Enemies
    enemiesKilled = 12,
    enemiesCaptured = 2,
    enemiesEscaped = 1,
    
    -- Civilians/Neutrals
    civiliansKilled = 3,
    civiliansRescued = 8,
    neutralsKilled = 1,
    
    -- Objectives
    objectivesTotal = 3,
    objectivesCompleted = 2,
    
    -- Performance
    turnsElapsed = 24,
    accuracyPercent = 67.5,
    damageDealt = 1450,
    damageTaken = 320,
    
    -- Scoring
    baseScore = 1000,
    objectiveBonus = 500,
    speedBonus = 100,
    civilianPenalty = -300,
    propertyPenalty = -100,
    totalScore = 1200,
    
    -- Salvage (only on victory)
    salvage = {
        corpses = {
            {itemId = "corpse_sectoid", quantity = 8},
            {itemId = "corpse_floater", quantity = 4}
        },
        items = {
            {itemId = "plasma_rifle", quantity = 5},
            {itemId = "alien_grenade", quantity = 3}
        },
        special = {
            {itemId = "ufo_alloys", quantity = 50},
            {itemId = "elerium_115", quantity = 20}
        },
        allyCasualties = {
            {unitId = "soldier_003", corpseId = "corpse_human", equipment = {...}}
        }
    }
}
```

**SalvageConfig:**
```lua
-- Rules for converting units/objects to salvage
SalvageConfig = {
    corpsesPerRace = {
        sectoid = "corpse_sectoid",
        floater = "corpse_floater",
        muton = "corpse_muton",
        human = "corpse_human",
        -- etc.
    },
    
    specialSalvageObjects = {
        -- Object type → salvage items
        ufo_wall_section = {
            {itemId = "ufo_alloys", quantity = {min = 5, max = 10}}
        },
        elerium_engine = {
            {itemId = "elerium_115", quantity = {min = 10, max = 20}},
            {itemId = "ufo_power_source", quantity = 1}
        },
        alien_computer = {
            {itemId = "alien_data_core", quantity = 1}
        }
    },
    
    scoringRules = {
        baseScore = 1000,
        objectiveBonus = 250,  -- Per objective
        speedBonusThreshold = 20,  -- Turns
        speedBonusPoints = 10,  -- Per turn under threshold
        civilianDeathPenalty = 100,  -- Per civilian
        neutralDeathPenalty = 50,  -- Per neutral
        propertyDestructionPenalty = 10,  -- Per destroyed valuable object
        publicMissionMultiplier = 2.0  -- 2× penalties for public missions
    }
}
```

**Estimated time:** 4 hours

---

### Step 2: Salvage Collection System (8 hours)
**Description:** System to scan battlefield and collect all salvageable items and corpses

**Files to create:**
- `engine/battlescape/logic/salvage_collector.lua`

**Implementation:**
```lua
local SalvageCollector = {}

function SalvageCollector:collectSalvage(battlefield, missionResult)
    local salvage = {
        corpses = {},
        items = {},
        special = {},
        allyCasualties = {}
    }
    
    if not missionResult.victory then
        -- No salvage on defeat
        return salvage
    end
    
    -- Collect enemy corpses and equipment
    self:collectEnemyUnits(battlefield, salvage)
    
    -- Collect ally casualties
    self:collectAllyCasualties(battlefield, salvage)
    
    -- Collect dropped items
    self:collectDroppedItems(battlefield, salvage)
    
    -- Collect special salvage from objects
    self:collectSpecialSalvage(battlefield, salvage)
    
    return salvage
end

function SalvageCollector:collectEnemyUnits(battlefield, salvage)
    for _, unit in ipairs(battlefield.units) do
        if unit.team.side == "enemy" and unit.dead then
            -- Add corpse
            local corpseType = SalvageConfig.corpsesPerRace[unit.race]
            self:addSalvageItem(salvage.corpses, corpseType, 1)
            
            -- Collect equipment
            for _, item in ipairs(unit.inventory) do
                self:addSalvageItem(salvage.items, item.id, 1)
            end
        end
        
        -- Captured enemies (stunned)
        if unit.team.side == "enemy" and unit.stunned then
            -- Capture whole unit (different from corpse)
            -- Collect equipment
            for _, item in ipairs(unit.inventory) do
                self:addSalvageItem(salvage.items, item.id, 1)
            end
        end
    end
end

function SalvageCollector:collectAllyCasualties(battlefield, salvage)
    for _, unit in ipairs(battlefield.units) do
        if unit.team.side == "player" and unit.dead then
            -- Add to casualties list
            local casualty = {
                unitId = unit.id,
                name = unit.name,
                corpseId = SalvageConfig.corpsesPerRace[unit.race],
                equipment = {}
            }
            
            for _, item in ipairs(unit.inventory) do
                table.insert(casualty.equipment, {
                    id = item.id,
                    quantity = 1
                })
            end
            
            table.insert(salvage.allyCasualties, casualty)
        end
    end
end

function SalvageCollector:collectDroppedItems(battlefield, salvage)
    -- Scan battlefield for dropped items (grenades, weapons, etc.)
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local tile = battlefield:getTile(x, y)
            if tile and tile.items then
                for _, item in ipairs(tile.items) do
                    self:addSalvageItem(salvage.items, item.id, 1)
                end
            end
        end
    end
end

function SalvageCollector:collectSpecialSalvage(battlefield, salvage)
    -- Scan for special objects that convert to salvage
    for _, obj in ipairs(battlefield.specialObjects or {}) do
        if obj.destroyed and SalvageConfig.specialSalvageObjects[obj.type] then
            local salvageRules = SalvageConfig.specialSalvageObjects[obj.type]
            
            for _, rule in ipairs(salvageRules) do
                local quantity = math.random(rule.quantity.min, rule.quantity.max)
                self:addSalvageItem(salvage.special, rule.itemId, quantity)
            end
        end
    end
end

function SalvageCollector:addSalvageItem(collection, itemId, quantity)
    -- Add to collection, stacking if already present
    for _, item in ipairs(collection) do
        if item.itemId == itemId then
            item.quantity = item.quantity + quantity
            return
        end
    end
    
    table.insert(collection, {
        itemId = itemId,
        quantity = quantity
    })
end

function SalvageCollector:processDef eat(battlefield, deploymentConfig, missionResult)
    -- On defeat, determine which units are lost
    local lostUnits = {}
    local survivedUnits = {}
    
    for _, unit in ipairs(battlefield.units) do
        if unit.team.side == "player" then
            if self:isInLandingZone(unit, deploymentConfig) then
                table.insert(survivedUnits, unit)
            else
                table.insert(lostUnits, unit)
            end
        end
    end
    
    missionResult.unitsLost = #lostUnits
    missionResult.unitsSurvived = #survivedUnits
    missionResult.lostUnitDetails = lostUnits
    
    return lostUnits, survivedUnits
end

function SalvageCollector:isInLandingZone(unit, deploymentConfig)
    -- Check if unit position is within any landing zone MapBlock
    local unitMapBlock = self:getMapBlockIndex(unit.x, unit.y, deploymentConfig)
    
    for _, zone in ipairs(deploymentConfig.landingZones) do
        if unitMapBlock == zone.mapBlockIndex then
            return true
        end
    end
    
    return false
end

function SalvageCollector:getMapBlockIndex(worldX, worldY, deploymentConfig)
    local tileX = math.floor(worldX / TILE_SIZE)
    local tileY = math.floor(worldY / TILE_SIZE)
    
    local blockX = math.floor(tileX / 15)
    local blockY = math.floor(tileY / 15)
    
    return blockY * deploymentConfig.mapBlockGrid + blockX
end
```

**Estimated time:** 8 hours

---

### Step 3: Mission Scoring System (6 hours)
**Description:** Calculate mission score based on performance, casualties, and objectives

**Files to create:**
- `engine/battlescape/logic/mission_scorer.lua`

**Implementation:**
```lua
local MissionScorer = {}

function MissionScorer:calculateScore(battlefield, missionResult, missionData)
    local score = {
        base = 0,
        objectiveBonus = 0,
        speedBonus = 0,
        efficiencyBonus = 0,
        civilianPenalty = 0,
        neutralPenalty = 0,
        propertyPenalty = 0,
        total = 0
    }
    
    local config = SalvageConfig.scoringRules
    local publicMission = missionData.location == "urban" or missionData.public
    local penaltyMultiplier = publicMission and config.publicMissionMultiplier or 1.0
    
    -- Base score (always awarded)
    score.base = config.baseScore
    
    -- Objective bonus (only on victory)
    if missionResult.victory then
        score.objectiveBonus = missionResult.objectivesCompleted * config.objectiveBonus
    end
    
    -- Speed bonus (if completed quickly)
    if missionResult.turnsElapsed < config.speedBonusThreshold then
        local turnsUnder = config.speedBonusThreshold - missionResult.turnsElapsed
        score.speedBonus = turnsUnder * config.speedBonusPoints
    end
    
    -- Efficiency bonus (low casualties, high accuracy)
    if missionResult.unitsKilled == 0 then
        score.efficiencyBonus = score.efficiencyBonus + 200
    end
    if missionResult.accuracyPercent > 75 then
        score.efficiencyBonus = score.efficiencyBonus + 100
    end
    
    -- Civilian casualties penalty
    score.civilianPenalty = -missionResult.civiliansKilled * config.civilianDeathPenalty * penaltyMultiplier
    
    -- Neutral casualties penalty
    score.neutralPenalty = -missionResult.neutralsKilled * config.neutralDeathPenalty * penaltyMultiplier
    
    -- Property destruction penalty (in public areas)
    if publicMission then
        local destructionCount = self:countPropertyDestruction(battlefield)
        score.propertyPenalty = -destructionCount * config.propertyDestructionPenalty * penaltyMultiplier
    end
    
    -- Calculate total
    score.total = score.base +
                  score.objectiveBonus +
                  score.speedBonus +
                  score.efficiencyBonus +
                  score.civilianPenalty +
                  score.neutralPenalty +
                  score.propertyPenalty
    
    return score
end

function MissionScorer:countPropertyDestruction(battlefield)
    local count = 0
    
    -- Count destroyed tiles marked as valuable property
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local tile = battlefield:getTile(x, y)
            if tile and tile.destroyed and tile.valuableProperty then
                count = count + 1
            end
        end
    end
    
    return count
end

function MissionScorer:trackCasualties(battlefield, missionResult)
    missionResult.civiliansKilled = 0
    missionResult.civiliansRescued = 0
    missionResult.neutralsKilled = 0
    
    for _, unit in ipairs(battlefield.units) do
        if unit.team.side == "civilian" then
            if unit.dead then
                missionResult.civiliansKilled = missionResult.civiliansKilled + 1
            else
                missionResult.civiliansRescued = missionResult.civiliansRescued + 1
            end
        elseif unit.team.side == "neutral" then
            if unit.dead then
                missionResult.neutralsKilled = missionResult.neutralsKilled + 1
            end
        end
    end
end
```

**Estimated time:** 6 hours

---

### Step 4: Salvage Screen UI (10 hours)
**Description:** Post-battle screen showing salvage, casualties, and mission score

**Files to create:**
- `engine/modules/salvage_screen.lua`
- `engine/modules/salvage_screen/init.lua`
- `engine/modules/salvage_screen/ui.lua`

**UI Layout (960×720, 24px grid):**
```
┌─────────────────────────────────────────┐
│  MISSION COMPLETE - [Victory/Defeat]    │ Header
├─────────────────────────────────────────┤
│                                          │
│  Mission Score: 1200                     │ Score
│  [Base: 1000] [Objectives: +500]        │ Breakdown
│  [Speed: +100] [Civilians: -300]        │
│                                          │
│  ┌─────────────┐  ┌─────────────┐       │
│  │  Salvage    │  │ Casualties  │       │ Two-column
│  │  - Corpses  │  │ - KIA: 1    │       │ layout
│  │  - Items    │  │ - Survived: 5│       │
│  │  - Special  │  │             │       │
│  └─────────────┘  └─────────────┘       │
│                                          │
│  [Continue to Base]                      │ Footer
└─────────────────────────────────────────┘
```

**Victory Screen:**
- Shows mission score with breakdown
- Lists all salvaged items with icons and quantities
- Shows corpses collected by race
- Lists casualties (ally units KIA)
- Shows medals/achievements earned
- Experience gained by surviving units
- Continue button returns to geoscape

**Defeat Screen:**
- Shows negative score penalty
- Lists units lost (outside landing zones)
- Lists units survived (in landing zones)
- No salvage section
- Experience still awarded (reduced)
- Continue button returns to geoscape

**Implementation:**
```lua
local SalvageScreen = {}

function SalvageScreen.enter(missionResult)
    SalvageScreen.result = missionResult
    SalvageScreen.scrollOffset = 0
    SalvageScreen:createUI()
end

function SalvageScreen:createUI()
    self.widgets = {}
    
    -- Header
    local headerText = self.result.victory and "MISSION COMPLETE" or "MISSION FAILED"
    local headerColor = self.result.victory and theme.colors.success or theme.colors.danger
    
    -- Score display
    self:addScorePanel()
    
    if self.result.victory then
        self:addSalvagePanel()
    else
        self:addDefeatPanel()
    end
    
    self:addCasualtyPanel()
    self:addContinueButton()
end

function SalvageScreen:addSalvagePanel()
    -- List all salvaged items
    -- Corpses, items, special salvage
end

function SalvageScreen:addDefeatPanel()
    -- List lost units
    -- List survived units
end

function SalvageScreen.draw()
    -- Render background
    -- Render all UI widgets
    -- Render score breakdown
    -- Render salvage lists
end

function SalvageScreen:continueToBase()
    -- Transfer salvage to base inventory
    -- Update unit roster (remove casualties, mark lost)
    -- Apply experience to survivors
    -- Return to geoscape
    StateManager.setState("geoscape")
end
```

**Estimated time:** 10 hours

---

### Step 5: Base Inventory Integration (6 hours)
**Description:** Transfer salvaged items to player's base inventory system

**Files to modify/create:**
- `engine/basescape/logic/inventory.lua` - Base inventory system
- `engine/basescape/logic/storage.lua` - Storage management

**Implementation:**
```lua
-- In Basescape Inventory system
local BaseInventory = {}

function BaseInventory:addSalvage(salvage)
    -- Add corpses
    for _, item in ipairs(salvage.corpses) do
        self:addItem(item.itemId, item.quantity)
    end
    
    -- Add items
    for _, item in ipairs(salvage.items) do
        self:addItem(item.itemId, item.quantity)
    end
    
    -- Add special salvage
    for _, item in ipairs(salvage.special) do
        self:addItem(item.itemId, item.quantity)
    end
    
    -- Process ally casualties
    for _, casualty in ipairs(salvage.allyCasualties) do
        self:addItem(casualty.corpseId, 1)
        for _, item in ipairs(casualty.equipment) do
            self:addItem(item.id, item.quantity)
        end
    end
    
    self:save()
end

function BaseInventory:addItem(itemId, quantity)
    if not self.items[itemId] then
        self.items[itemId] = {
            id = itemId,
            quantity = 0,
            addedDate = os.date()
        }
    end
    
    self.items[itemId].quantity = self.items[itemId].quantity + quantity
    print(string.format("[Inventory] Added %d × %s", quantity, itemId))
end
```

**Estimated time:** 6 hours

---

### Step 6: Concealment Budget System (8 hours)
**Description:** Implement stealth/concealment budget for covert missions

**Files to create:**
- `engine/battlescape/logic/concealment_tracker.lua`

**Concealment Budget:**
- Missions have concealment budget (0-100000)
- Normal missions: 100000 (effectively unlimited)
- Covert missions: 50-500 (must stay quiet)
- Public missions: Lower budget (1000-5000)

**Budget Consumption:**
- Firearm shot: 1 point
- Grenade explosion: 10 points
- Rocket/explosive: 25 points
- Large explosion: 50 points
- Mass destruction: 100 points

**Public Mission Penalties:**
- Urban missions have lower concealment budget
- Exceeding budget = mission failure
- Additional score penalty for publicity
- Civilian casualties in public = 2× penalty

**Implementation:**
```lua
local ConcealmentTracker = {}

function ConcealmentTracker:new(mission)
    local self = setmetatable({}, {__index = ConcealmentTracker})
    
    self.budget = mission.concealmentBudget or 100000
    self.budgetRemaining = self.budget
    self.publicMission = mission.location == "urban" or mission.public
    self.missionType = mission.type  -- "covert", "public", "normal"
    
    self.events = {}  -- Track all concealment-breaking events
    
    return self
end

function ConcealmentTracker:consumeBudget(action, amount)
    self.budgetRemaining = self.budgetRemaining - amount
    
    table.insert(self.events, {
        action = action,
        amount = amount,
        turn = self.currentTurn,
        remaining = self.budgetRemaining
    })
    
    print(string.format("[Concealment] %s consumed %d budget (remaining: %d)", 
          action, amount, self.budgetRemaining))
    
    if self.budgetRemaining <= 0 then
        self:handleBudgetExceeded()
    end
end

function ConcealmentTracker:handleBudgetExceeded()
    print("[Concealment] BUDGET EXCEEDED - Mission compromised!")
    
    -- Trigger mission failure or major penalty
    if self.missionType == "covert" then
        -- Immediate mission failure
        MissionManager:failMission("Concealment blown - mission compromised")
    else
        -- Heavy score penalty
        MissionScorer:applyPenalty("concealment_blown", -1000)
    end
end

function ConcealmentTracker:getPublicityMultiplier()
    return self.publicMission and 2.0 or 1.0
end

-- Action costs
ConcealmentTracker.ACTION_COSTS = {
    firearm_shot = 1,
    grenade = 10,
    explosive = 25,
    rocket = 25,
    large_explosion = 50,
    mass_destruction = 100,
    civilian_death = 20,  -- Extra cost for civilian casualties
}

function ConcealmentTracker:onWeaponFired(weapon, target)
    local cost = self.ACTION_COSTS[weapon.type] or 1
    local multiplier = self:getPublicityMultiplier()
    
    self:consumeBudget("weapon_fired", cost * multiplier)
end

function ConcealmentTracker:onExplosion(explosionType, radius)
    local cost = self.ACTION_COSTS[explosionType] or 10
    local multiplier = self:getPublicityMultiplier()
    
    self:consumeBudget("explosion", cost * multiplier)
end

function ConcealmentTracker:onCivilianDeath()
    local cost = self.ACTION_COSTS.civilian_death
    local multiplier = self:getPublicityMultiplier()
    
    self:consumeBudget("civilian_death", cost * multiplier * 2)  -- 2× for public
end
```

**Estimated time:** 8 hours

---

### Step 7: Integration & Testing (8 hours)
**Description:** Integrate all systems and test thoroughly

**Integration Points:**
1. Battlescape victory/defeat trigger → SalvageScreen
2. SalvageCollector scan battlefield → MissionResult
3. MissionScorer calculate final score
4. SalvageScreen display results
5. BaseInventory receive salvage items
6. Geoscape update unit roster (remove casualties)
7. ConcealmentTracker monitor during battle

**Test Cases:**
- Victory salvage collects all enemy corpses
- Victory salvage collects all enemy items
- Ally casualties properly converted to corpses + equipment
- Neutral units not collected
- Special objects convert to salvage correctly
- Defeat loses units outside landing zones
- Defeat preserves units in landing zones
- Defeat prevents salvage collection
- Mission score calculated correctly
- Civilian penalties apply correctly
- Public mission penalties 2× higher
- Concealment budget tracked correctly
- Concealment exceeded triggers failure/penalty
- Experience awarded to survivors
- Base inventory receives all salvage
- State transitions work smoothly

**Estimated time:** 8 hours

---

## Implementation Details

### Architecture

**State Flow:**
```
Battlescape (combat) →
  Victory/Defeat Check →
    SalvageCollector.collect() →
    MissionScorer.calculate() →
  SalvageScreen (display) →
    BaseInventory.addSalvage() →
    UnitRoster.updateCasualties() →
  Geoscape (return)
```

**Component Interaction:**
- SalvageCollector scans battlefield, generates salvage data
- MissionScorer calculates performance score
- MissionResult holds all outcome data
- SalvageScreen displays results to player
- BaseInventory receives and stores salvage
- ConcealmentTracker runs during battle, affects scoring

### Key Components

- **SalvageCollector:** Scans battlefield for collectible items/corpses
- **MissionScorer:** Calculates mission performance score
- **MissionResult:** Central data structure for mission outcome
- **SalvageScreen:** UI state for post-battle results
- **ConcealmentTracker:** Monitors stealth budget during battle
- **BaseInventory Integration:** Transfers salvage to base

### Dependencies

- Battlescape system (already implemented)
- Base inventory system (to be implemented or mocked)
- Unit roster system (to be implemented or mocked)
- Item/corpse definition system (data files)
- Deployment system (TASK-029 for landing zones)

---

## Testing Strategy

### Unit Tests

**SalvageCollector:**
- Test corpse generation from units
- Test item collection from inventory
- Test special salvage conversion
- Test landing zone boundary checking
- Test defeat unit loss calculation

**MissionScorer:**
- Test base score calculation
- Test objective bonus
- Test speed bonus
- Test civilian penalty
- Test property destruction penalty
- Test public mission multiplier

**ConcealmentTracker:**
- Test budget consumption
- Test action cost calculation
- Test public multiplier
- Test budget exceeded trigger
- Test event logging

### Integration Tests

**Victory Flow:**
- Complete mission successfully
- Verify all enemy corpses collected
- Verify all items collected
- Verify special salvage generated
- Verify score calculated correctly
- Verify salvage appears in base inventory

**Defeat Flow:**
- Fail mission (all units die or retreat)
- Verify units outside landing zones lost
- Verify units in landing zones survive
- Verify no salvage collected
- Verify negative score applied

**Concealment:**
- Start covert mission with low budget
- Fire weapons, throw grenades
- Verify budget decreases
- Exceed budget, verify mission fails
- Test public mission 2× penalty

### Manual Testing Steps

1. **Victory Salvage:**
   - Win battle with enemy casualties
   - Check salvage screen shows corpses
   - Check all enemy weapons collected
   - Verify ally casualties listed
   - Verify salvage in base inventory

2. **Defeat Salvage:**
   - Lose battle with units spread out
   - Verify units outside landing zones lost
   - Verify units in landing zones survive
   - Check no salvage collected
   - Verify unit roster updated

3. **Mission Scoring:**
   - Complete mission with objectives
   - Verify score breakdown shown
   - Kill civilians, verify penalty
   - Complete quickly, verify speed bonus
   - Check public mission penalties higher

4. **Concealment:**
   - Start covert mission
   - Fire weapons to consume budget
   - Watch budget counter decrease
   - Exceed budget, verify consequences
   - Test in urban vs rural location

5. **Special Salvage:**
   - Destroy UFO wall sections
   - Verify alloy salvage generated
   - Destroy elerium engine
   - Verify elerium salvage
   - Check quantities correct

### Expected Results

- Victory collects all salvage correctly
- Defeat applies appropriate consequences
- Mission scoring fair and clear
- Concealment system adds tactical depth
- Base inventory updated correctly
- No console errors or warnings
- Smooth state transitions
- Clear visual feedback

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging

**Console Output:**
```lua
print("[Salvage] Collecting enemy corpses: " .. #enemies .. " killed")
print("[Salvage] Special salvage: " .. item.id .. " × " .. qty)
print("[Scorer] Mission score: " .. score.total)
print("[Concealment] Budget remaining: " .. budget)
print("[Inventory] Added salvage to base: " .. #items .. " items")
```

**On-Screen Debug:**
```lua
-- In salvage screen
love.graphics.print("Salvage Items: " .. #salvage.items, 10, 10)
love.graphics.print("Corpses: " .. #salvage.corpses, 10, 30)
love.graphics.print("Score: " .. result.totalScore, 10, 50)
```

**Debug Visualization:**
- F7: Show concealment budget counter during battle
- F8: Show landing zone boundaries
- F9: Highlight salvageable objects

### Temporary Files

- No temp files needed for salvage system
- Mission results can be logged to temp for debugging:
  ```lua
  local tempPath = os.getenv("TEMP") .. "\\mission_result.json"
  ```

---

## Documentation Updates

### Files to Update

- [x] `tasks/tasks.md` - Add TASK-030 to active high priority tasks
- [ ] `wiki/API.md` - Document SalvageCollector, MissionScorer, ConcealmentTracker APIs
- [ ] `wiki/FAQ.md` - Add salvage system FAQ, concealment mechanics
- [ ] `wiki/DEVELOPMENT.md` - Add salvage system architecture
- [ ] `wiki/wiki/missions.md` - Document salvage and scoring mechanics
- [ ] `wiki/wiki/content.md` - Add corpse/item generation rules
- [ ] Code comments - Full documentation in all modules

---

## Notes

**Design Rationale:**
- Victory/defeat salvage mirrors X-COM's risk/reward system
- Landing zone retreat mechanics encourage tactical positioning
- Civilian casualties matter more in public missions
- Concealment budget adds stealth mission depth
- Special salvage (elerium, alloys) drives research progression

**Balance Considerations:**
- Concealment budget varies by mission type (50-100000)
- Public missions have 2× publicity penalties
- Defeat still awards experience (encourage learning)
- No salvage on defeat prevents exploit strategies
- Ally equipment recovered even on defeat (if in landing zone)

**Future Enhancements:**
- Salvage quality/condition (damaged items)
- Time-based salvage extraction (longer = more salvage)
- Enemy reinforcements if taking too long
- Salvage hauling capacity limits
- Black market for selling salvage
- Research requirements for alien tech salvage

---

## Blockers

**Dependencies:**
- Battlescape victory/defeat conditions (partially implemented)
- Base inventory system (needs implementation or mocking)
- Item definition system (data files needed)
- Landing zone system (TASK-029, can be mocked)
- Unit roster management (can be mocked)

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (large battlefield scans)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Grid-snapped UI elements
- [ ] Theme system used
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in Love2D console
- [ ] State transitions smooth
- [ ] Score calculations fair and transparent

---

## Post-Completion

### What Worked Well
- (To be filled after implementation)

### What Could Be Improved
- (To be filled after implementation)

### Lessons Learned
- (To be filled after implementation)
