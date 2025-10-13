# Task: Battle Objectives System - Mission Goals & Victory Conditions

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

**Dependencies:** Battlescape ECS System (must be operational)

---

## Overview

Implement comprehensive battle objectives system where each battle has specific mission goals beyond "kill all enemies". Objectives include: Kill All, Domination (control sectors), Capture The Flag, Assassination (kill specific unit), Escort (bring unit to location), Survive (N turns), Rescue (save neutral unit), and others. Each team (player/AI) earns progress percentage (0-100%) toward victory. First team to reach 100% wins the battle automatically. Multiple objectives can be combined (e.g., kill 50% enemies + capture 50% sectors = 100%).

---

## Purpose

Current battlescape only supports "kill all enemies" victory condition, which becomes repetitive. This system adds:
- **Variety:** Different mission types with unique tactical challenges
- **Strategy:** Players must prioritize objectives vs. combat
- **Dynamic Victory:** Battles end when objectives met, not just elimination
- **Asymmetric Goals:** AI can have different objectives than player
- **Progress Tracking:** Clear feedback on victory progress (percentage-based)
- **Partial Victory:** Completing some objectives gives partial rewards

This enables rich mission design: terror missions (survive), VIP rescue (escort), assassination missions, base defense (hold sectors), etc.

---

## Requirements

### Functional Requirements
- [x] Objective types: Kill All, Domination, Capture Flag, Assassination, Escort, Survive, Rescue, Defense, Extraction, Sabotage
- [x] Progress system: Each objective contributes 0-100% toward team victory
- [x] Multiple objectives: Combine 2-3 objectives with weighted contributions
- [x] Per-team objectives: Player and AI can have different goals
- [x] Victory check: First team to reach 100% progress wins, battle ends immediately
- [x] Progress tracking: Real-time update as objectives completed
- [x] Partial completion: Some objectives (Kill All, Domination) award incremental progress
- [x] Binary objectives: Some (Capture Flag, Survive) are all-or-nothing
- [x] Objective conditions: Turn limits, unit requirements, sector control
- [x] Rewards scaling: Final rewards based on completion percentage and speed

### Technical Requirements
- [x] Data-driven objective definitions in Lua tables
- [x] Objective system integrates with ECS (checks unit states, positions)
- [x] Turn-based checking (evaluate objectives each turn end)
- [x] Event system for objective updates (e.g., "sector_captured", "unit_killed")
- [x] UI displays objectives, progress bars, completion status
- [x] Save/load support for objective state

### Acceptance Criteria
- [x] Can create battle with custom objectives
- [x] Progress updates correctly as objectives completed
- [x] Battle ends when team reaches 100% progress
- [x] Multiple objectives combine correctly (percentages sum to 100%)
- [x] Different objective types work as expected
- [x] UI shows clear progress for all objectives
- [x] AI can complete its own objectives
- [x] Rewards scale with completion percentage
- [x] No infinite loops or stuck states

---

## Plan

### Step 1: Objective Data Structure (6 hours)
**Description:** Define objective types and base objective class  
**Files to create:**
- `engine/battlescape/logic/objective.lua` - Base objective class
- `engine/battlescape/logic/objective_types.lua` - All objective type definitions

**Base Objective:**
```lua
Objective = {
    id = "obj_kill_all",
    type = "kill_all",  -- Objective type identifier
    name = "Eliminate All Enemies",
    description = "Destroy all enemy units",
    
    -- Progress
    weight = 100,  -- Percentage contribution (0-100)
    progress = 0,  -- Current progress (0-100)
    completed = false,
    
    -- Team assignment
    team = "player",  -- Which team this objective belongs to
    
    -- Conditions
    conditions = {},  -- Type-specific conditions
    
    -- State
    state = "active",  -- "active", "completed", "failed"
    startTurn = 1,
    completedTurn = nil,
}

Objective:update(battlefield)
    -- Check progress, update percentage
    -- Called each turn end
    
Objective:checkCompletion(battlefield)
    -- Return true if objective met
    
Objective:getProgress()
    -- Return 0-100 progress percentage
    
Objective:onComplete()
    -- Emit event, trigger rewards
```

**Objective Types (10 types total):**

1. **Kill All** - Eliminate all enemy units
   ```lua
   {
       type = "kill_all",
       weight = 100,
       conditions = {
           targetTeam = "enemy"  -- Which team to eliminate
       }
   }
   -- Progress: (enemiesKilled / totalEnemies) × 100
   ```

2. **Domination** - Control N sectors for M turns
   ```lua
   {
       type = "domination",
       weight = 50,
       conditions = {
           sectorsToControl = 3,  -- Number of sectors
           turnsToHold = 2,       -- Consecutive turns holding sectors
       }
   }
   -- Progress: (sectorsControlled / sectorsToControl) × 100
   ```

3. **Capture The Flag** - Take item to specific location
   ```lua
   {
       type = "capture_flag",
       weight = 100,
       conditions = {
           flagItemId = "flag_001",  -- Item to capture
           targetZone = {x = 50, y = 50, radius = 5}  -- Delivery zone
       }
   }
   -- Progress: 0% (not delivered) or 100% (delivered)
   ```

4. **Assassination** - Kill specific unit
   ```lua
   {
       type = "assassination",
       weight = 100,
       conditions = {
           targetUnitId = "unit_vip_001",  -- Specific unit to kill
       }
   }
   -- Progress: 0% (alive) or 100% (dead)
   ```

5. **Escort** - Bring unit to location alive
   ```lua
   {
       type = "escort",
       weight = 100,
       conditions = {
           escortUnitId = "unit_vip_002",
           destinationZone = {x = 10, y = 10, radius = 3}
       }
   }
   -- Progress: 0% (not arrived or dead) or 100% (arrived alive)
   ```

6. **Survive** - Survive N turns
   ```lua
   {
       type = "survive",
       weight = 100,
       conditions = {
           turnsToSurvive = 10,
           minUnitsAlive = 1  -- At least 1 unit must survive
       }
   }
   -- Progress: (turnsSurvived / turnsToSurvive) × 100
   ```

7. **Rescue** - Save neutral units
   ```lua
   {
       type = "rescue",
       weight = 100,
       conditions = {
           neutralUnitsToRescue = 3,  -- Count of civilians/neutrals
           rescueZone = {x = 5, y = 5, radius = 10}  -- Safe zone
       }
   }
   -- Progress: (unitsRescued / neutralUnitsToRescue) × 100
   ```

8. **Defense** - Prevent enemies from reaching zone
   ```lua
   {
       type = "defense",
       weight = 100,
       conditions = {
           protectedZone = {x = 25, y = 25, radius = 5},
           maxEnemyBreaches = 0,  -- Fail if enemy enters zone
           turnsToDefend = 15
       }
   }
   -- Progress: (turnsDefended / turnsToDefend) × 100
   ```

9. **Extraction** - Reach extraction point with units
   ```lua
   {
       type = "extraction",
       weight = 100,
       conditions = {
           extractionZone = {x = 80, y = 80, radius = 5},
           minUnitsToExtract = 4,  -- Minimum units that must extract
       }
   }
   -- Progress: (unitsExtracted / minUnitsToExtract) × 100
   ```

10. **Sabotage** - Destroy specific map objects
    ```lua
    {
        type = "sabotage",
        weight = 100,
        conditions = {
            targetsToDestroy = {"fuel_tank_1", "power_gen_1", "antenna_1"},
        }
    }
    -- Progress: (targetsDestroyed / totalTargets) × 100
    ```

**Estimated time:** 6 hours

---

### Step 2: Objective Manager (8 hours)
**Description:** Central manager for battle objectives, progress tracking  
**Files to create:**
- `engine/battlescape/logic/objective_manager.lua` - Manages all objectives

**ObjectiveManager:**
```lua
ObjectiveManager = {
    battle = nil,  -- Reference to Battlefield
    
    objectives = {
        player = {},  -- Objectives for player team
        enemy = {},   -- Objectives for enemy team
    },
    
    progress = {
        player = 0,  -- 0-100%
        enemy = 0,   -- 0-100%
    },
    
    victoryTeam = nil,  -- "player", "enemy", or nil
}

ObjectiveManager:new(battle, objectiveConfigs)
    -- Create objectives from configs
    -- Assign to teams
    -- Validate total weights = 100 per team
    
ObjectiveManager:updateProgress(team)
    -- Recalculate total progress for team
    local totalProgress = 0
    for _, objective in ipairs(self.objectives[team]) do
        totalProgress = totalProgress + (objective.progress * objective.weight / 100)
    end
    self.progress[team] = totalProgress
    
    -- Check victory
    if totalProgress >= 100 then
        self:declareVictory(team)
    end
    
ObjectiveManager:onTurnEnd(team)
    -- Update all objectives for team
    for _, objective in ipairs(self.objectives[team]) do
        objective:update(self.battle)
    end
    self:updateProgress(team)
    
ObjectiveManager:declareVictory(team)
    self.victoryTeam = team
    Events:emit("battle_victory", {team = team, turn = battle.currentTurn})
    -- End battle
    
ObjectiveManager:getObjectivesForTeam(team)
    return self.objectives[team]
    
ObjectiveManager:getProgressForTeam(team)
    return self.progress[team]
```

**Integration with TurnManager:**
```lua
-- In TurnManager:endTurn()
function TurnManager:endTurn()
    -- ... existing turn logic ...
    
    -- Update objectives
    ObjectiveManager:onTurnEnd(self.currentTeam)
    
    -- Check if battle ended
    if ObjectiveManager.victoryTeam then
        self:endBattle(ObjectiveManager.victoryTeam)
        return
    end
    
    -- Continue to next turn
    self:nextTurn()
end
```

**Estimated time:** 8 hours

---

### Step 3: Objective Type Implementations (20 hours)
**Description:** Implement each objective type's update logic  
**Files to create:**
- `engine/battlescape/logic/objectives/kill_all_objective.lua`
- `engine/battlescape/logic/objectives/domination_objective.lua`
- `engine/battlescape/logic/objectives/capture_flag_objective.lua`
- `engine/battlescape/logic/objectives/assassination_objective.lua`
- `engine/battlescape/logic/objectives/escort_objective.lua`
- `engine/battlescape/logic/objectives/survive_objective.lua`
- `engine/battlescape/logic/objectives/rescue_objective.lua`
- `engine/battlescape/logic/objectives/defense_objective.lua`
- `engine/battlescape/logic/objectives/extraction_objective.lua`
- `engine/battlescape/logic/objectives/sabotage_objective.lua`

**Example: KillAllObjective**
```lua
KillAllObjective = setmetatable({}, {__index = Objective})

function KillAllObjective:new(config)
    local self = setmetatable(Objective:new(config), {__index = KillAllObjective})
    self.type = "kill_all"
    self.targetTeam = config.conditions.targetTeam
    self.initialEnemyCount = 0
    return self
end

function KillAllObjective:update(battlefield)
    -- Count living enemies
    local livingEnemies = 0
    for _, unit in ipairs(battlefield:getUnitsForTeam(self.targetTeam)) do
        if unit.health > 0 then
            livingEnemies = livingEnemies + 1
        end
    end
    
    -- First update: record initial count
    if self.initialEnemyCount == 0 then
        self.initialEnemyCount = livingEnemies
    end
    
    -- Calculate progress
    local killed = self.initialEnemyCount - livingEnemies
    self.progress = (killed / self.initialEnemyCount) * 100
    
    -- Check completion
    if livingEnemies == 0 then
        self.completed = true
        self.progress = 100
        self.state = "completed"
    end
end
```

**Example: DominationObjective**
```lua
DominationObjective = setmetatable({}, {__index = Objective})

function DominationObjective:new(config)
    local self = setmetatable(Objective:new(config), {__index = DominationObjective})
    self.type = "domination"
    self.sectorsToControl = config.conditions.sectorsToControl
    self.turnsToHold = config.conditions.turnsToHold or 1
    self.controlledSectors = {}  -- Sector IDs
    self.turnsHeld = 0
    return self
end

function DominationObjective:update(battlefield)
    -- Check which sectors team controls
    self.controlledSectors = battlefield:getSectorsControlledBy(self.team)
    
    -- Check if controlling enough sectors
    if #self.controlledSectors >= self.sectorsToControl then
        self.turnsHeld = self.turnsHeld + 1
    else
        self.turnsHeld = 0  -- Reset if lost control
    end
    
    -- Calculate progress (based on turns held)
    self.progress = math.min(100, (self.turnsHeld / self.turnsToHold) * 100)
    
    -- Check completion
    if self.turnsHeld >= self.turnsToHold then
        self.completed = true
        self.progress = 100
        self.state = "completed"
    end
end
```

**Example: SurviveObjective**
```lua
SurviveObjective = setmetatable({}, {__index = Objective})

function SurviveObjective:new(config)
    local self = setmetatable(Objective:new(config), {__index = SurviveObjective})
    self.type = "survive"
    self.turnsToSurvive = config.conditions.turnsToSurvive
    self.minUnitsAlive = config.conditions.minUnitsAlive or 1
    self.turnsSurvived = 0
    return self
end

function SurviveObjective:update(battlefield)
    -- Count living team units
    local livingUnits = 0
    for _, unit in ipairs(battlefield:getUnitsForTeam(self.team)) do
        if unit.health > 0 then
            livingUnits = livingUnits + 1
        end
    end
    
    -- Check if enough units alive
    if livingUnits >= self.minUnitsAlive then
        self.turnsSurvived = battlefield.currentTurn - self.startTurn
    else
        -- Failed: not enough units alive
        self.state = "failed"
        self.progress = 0
        return
    end
    
    -- Calculate progress
    self.progress = math.min(100, (self.turnsSurvived / self.turnsToSurvive) * 100)
    
    -- Check completion
    if self.turnsSurvived >= self.turnsToSurvive then
        self.completed = true
        self.progress = 100
        self.state = "completed"
    end
end
```

**Estimated time:** 20 hours (2 hours per objective type)

---

### Step 4: Sector Control System (8 hours)
**Description:** Divide map into sectors, track control for Domination/Defense objectives  
**Files to create:**
- `engine/battlescape/logic/sector_control.lua` - Sector management

**SectorControl:**
```lua
SectorControl = {
    battlefield = nil,
    sectors = {},  -- Array of sectors
}

Sector = {
    id = "sector_01",
    name = "North Plaza",
    bounds = {x = 0, y = 0, width = 30, height = 30},  -- Map coordinates
    controllingTeam = nil,  -- "player", "enemy", "neutral", or nil
    contestedBy = {},  -- Teams with units in sector
}

SectorControl:new(battlefield, sectorCount)
    -- Divide map into N sectors (e.g., 4 or 9 sectors)
    -- Create sector grid
    
SectorControl:updateControl()
    for _, sector in ipairs(self.sectors) do
        -- Count units in sector by team
        local teamCounts = {player = 0, enemy = 0, neutral = 0}
        for _, unit in ipairs(self.battlefield.units) do
            if self:isUnitInSector(unit, sector) then
                teamCounts[unit.team] = teamCounts[unit.team] + 1
            end
        end
        
        -- Determine controlling team (most units)
        local maxCount = 0
        local controllingTeam = nil
        for team, count in pairs(teamCounts) do
            if count > maxCount then
                maxCount = count
                controllingTeam = team
            end
        end
        
        -- Check if contested (multiple teams)
        local teamsPresent = 0
        for team, count in pairs(teamCounts) do
            if count > 0 then teamsPresent = teamsPresent + 1 end
        end
        
        if teamsPresent > 1 then
            sector.controllingTeam = "contested"
        else
            sector.controllingTeam = controllingTeam
        end
    end
    
SectorControl:isUnitInSector(unit, sector)
    return unit.x >= sector.bounds.x and
           unit.x < sector.bounds.x + sector.bounds.width and
           unit.y >= sector.bounds.y and
           unit.y < sector.bounds.y + sector.bounds.height
           
SectorControl:getSectorsControlledBy(team)
    local controlled = {}
    for _, sector in ipairs(self.sectors) do
        if sector.controllingTeam == team then
            table.insert(controlled, sector.id)
        end
    end
    return controlled
```

**Integration with Battlefield:**
```lua
-- In Battlefield:init()
Battlefield.sectorControl = SectorControl:new(self, 4)  -- 4 sectors

-- In TurnManager:endTurn()
Battlefield.sectorControl:updateControl()
```

**Estimated time:** 8 hours

---

### Step 5: Mission Templates (6 hours)
**Description:** Predefined mission templates with objectives  
**Files to create:**
- `engine/data/mission_templates.lua` - Mission templates

**Mission Templates:**
```lua
missionTemplates = {
    standard_combat = {
        name = "Standard Combat",
        description = "Eliminate all enemy forces",
        objectives = {
            player = {
                {type = "kill_all", weight = 100, conditions = {targetTeam = "enemy"}},
            },
            enemy = {
                {type = "kill_all", weight = 100, conditions = {targetTeam = "player"}},
            }
        }
    },
    
    terror_mission = {
        name = "Terror Mission",
        description = "Survive and rescue civilians",
        objectives = {
            player = {
                {type = "survive", weight = 50, conditions = {turnsToSurvive = 15, minUnitsAlive = 1}},
                {type = "rescue", weight = 50, conditions = {neutralUnitsToRescue = 5}},
            },
            enemy = {
                {type = "kill_all", weight = 100, conditions = {targetTeam = "player"}},
            }
        }
    },
    
    assassination = {
        name = "Assassination Mission",
        description = "Eliminate the target VIP",
        objectives = {
            player = {
                {type = "assassination", weight = 80, conditions = {targetUnitId = "enemy_vip"}},
                {type = "extraction", weight = 20, conditions = {minUnitsToExtract = 2}},
            },
            enemy = {
                {type = "escort", weight = 100, conditions = {escortUnitId = "enemy_vip", destinationZone = {x = 80, y = 80, radius = 5}}},
            }
        }
    },
    
    domination = {
        name = "Domination",
        description = "Control key sectors",
        objectives = {
            player = {
                {type = "domination", weight = 100, conditions = {sectorsToControl = 3, turnsToHold = 3}},
            },
            enemy = {
                {type = "domination", weight = 100, conditions = {sectorsToControl = 3, turnsToHold = 3}},
            }
        }
    },
    
    base_defense = {
        name = "Base Defense",
        description = "Defend the base from assault",
        objectives = {
            player = {
                {type = "defense", weight = 60, conditions = {protectedZone = {x = 45, y = 45, radius = 10}, turnsToDefend = 20}},
                {type = "kill_all", weight = 40, conditions = {targetTeam = "enemy"}},
            },
            enemy = {
                {type = "sabotage", weight = 100, conditions = {targetsToDestroy = {"power_gen", "comms_tower"}}},
            }
        }
    },
    
    vip_rescue = {
        name = "VIP Rescue",
        description = "Extract the VIP safely",
        objectives = {
            player = {
                {type = "escort", weight = 100, conditions = {escortUnitId = "vip_001", destinationZone = {x = 5, y = 5, radius = 3}}},
            },
            enemy = {
                {type = "assassination", weight = 100, conditions = {targetUnitId = "vip_001"}},
            }
        }
    },
    
    capture_the_flag = {
        name = "Capture The Flag",
        description = "Capture the objective and extract",
        objectives = {
            player = {
                {type = "capture_flag", weight = 100, conditions = {flagItemId = "intel_package", targetZone = {x = 5, y = 5, radius = 5}}},
            },
            enemy = {
                {type = "defense", weight = 100, conditions = {protectedZone = {x = 80, y = 80, radius = 10}, turnsToDefend = 30}},
            }
        }
    },
    
    mixed_objectives = {
        name = "Mixed Objectives",
        description = "Complete multiple goals",
        objectives = {
            player = {
                {type = "kill_all", weight = 50, conditions = {targetTeam = "enemy"}},
                {type = "domination", weight = 50, conditions = {sectorsToControl = 2, turnsToHold = 2}},
            },
            enemy = {
                {type = "kill_all", weight = 100, conditions = {targetTeam = "player"}},
            }
        }
    },
}
```

**Estimated time:** 6 hours

---

### Step 6: UI Implementation (12 hours)
**Description:** Objective panels, progress bars, victory screen  
**Files to create:**
- `engine/battlescape/ui/objective_panel.lua` - Objective display
- `engine/battlescape/ui/victory_screen.lua` - End-of-battle screen

**ObjectivePanel (grid-aligned, 24×24 pixel grid):**
```lua
ObjectivePanel = {
    position = {x = 24*32, y = 24*1},  -- Top-right corner
    size = {width = 24*8, height = 24*12},
    
    objectiveManager = nil,
    team = "player",  -- Which team's objectives to show
}

ObjectivePanel:draw()
    -- Title: "MISSION OBJECTIVES"
    love.graphics.print("OBJECTIVES", self.position.x + 10, self.position.y + 10)
    
    -- List objectives
    local y = self.position.y + 40
    for i, objective in ipairs(self.objectiveManager:getObjectivesForTeam(self.team)) do
        -- Objective name
        love.graphics.print(objective.name, self.position.x + 10, y)
        y = y + 20
        
        -- Progress bar
        local barWidth = self.size.width - 20
        local barHeight = 8
        local fillWidth = barWidth * (objective.progress / 100)
        
        -- Background (gray)
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", self.position.x + 10, y, barWidth, barHeight)
        
        -- Fill (green if completed, yellow if in progress)
        if objective.completed then
            love.graphics.setColor(0, 1, 0)
        else
            love.graphics.setColor(1, 1, 0)
        end
        love.graphics.rectangle("fill", self.position.x + 10, y, fillWidth, barHeight)
        
        -- Progress text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("%d%%", objective.progress), self.position.x + 10 + barWidth + 5, y)
        
        y = y + 30
    end
    
    -- Total progress
    y = y + 10
    love.graphics.print("TOTAL PROGRESS:", self.position.x + 10, y)
    local totalProgress = self.objectiveManager:getProgressForTeam(self.team)
    love.graphics.print(string.format("%d%%", totalProgress), self.position.x + 150, y)
end
```

**VictoryScreen:**
```lua
VictoryScreen = {
    visible = false,
    victoryTeam = nil,
    turn = 0,
    objectives = {},
}

VictoryScreen:show(victoryTeam, turn, objectives)
    self.visible = true
    self.victoryTeam = victoryTeam
    self.turn = turn
    self.objectives = objectives
    
VictoryScreen:draw()
    if not self.visible then return end
    
    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 960, 720)
    
    -- Victory message (centered)
    love.graphics.setColor(1, 1, 1)
    local message = self.victoryTeam == "player" and "MISSION SUCCESS" or "MISSION FAILED"
    love.graphics.print(message, 400, 200)
    
    -- Turn count
    love.graphics.print("Turns: " .. self.turn, 400, 250)
    
    -- Objective completion
    local y = 300
    love.graphics.print("Objectives Completed:", 300, y)
    y = y + 30
    for _, objective in ipairs(self.objectives) do
        local status = objective.completed and "[✓]" or "[✗]"
        love.graphics.print(status .. " " .. objective.name .. " - " .. objective.progress .. "%", 320, y)
        y = y + 25
    end
    
    -- Continue button
    love.graphics.print("Press ENTER to continue", 350, 600)
end
```

**Sector Visualization:**
```lua
-- In BattlescapeRenderer:drawSectorOverlay()
function BattlescapeRenderer:drawSectorOverlay(sectorControl)
    for _, sector in ipairs(sectorControl.sectors) do
        -- Draw sector boundaries
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("line", 
            sector.bounds.x * TILE_SIZE, 
            sector.bounds.y * TILE_SIZE,
            sector.bounds.width * TILE_SIZE,
            sector.bounds.height * TILE_SIZE)
        
        -- Color based on control
        if sector.controllingTeam == "player" then
            love.graphics.setColor(0, 0, 1, 0.2)  -- Blue
        elseif sector.controllingTeam == "enemy" then
            love.graphics.setColor(1, 0, 0, 0.2)  -- Red
        elseif sector.controllingTeam == "contested" then
            love.graphics.setColor(1, 1, 0, 0.2)  -- Yellow
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.1)  -- Gray (neutral)
        end
        
        love.graphics.rectangle("fill", 
            sector.bounds.x * TILE_SIZE, 
            sector.bounds.y * TILE_SIZE,
            sector.bounds.width * TILE_SIZE,
            sector.bounds.height * TILE_SIZE)
        
        -- Sector name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(sector.name, 
            sector.bounds.x * TILE_SIZE + 10, 
            sector.bounds.y * TILE_SIZE + 10)
    end
end
```

**Estimated time:** 12 hours

---

### Step 7: Rewards System Integration (4 hours)
**Description:** Scale rewards based on objective completion and speed  
**Files to modify:**
- `engine/battlescape/logic/battle_rewards.lua` - Reward calculation

**BattleRewards:**
```lua
BattleRewards = {
    baseRewards = {
        credits = 10000,
        items = {},
        experience = 100,
    },
}

BattleRewards:calculate(objectiveManager, turn)
    local rewards = {credits = 0, items = {}, experience = 0}
    
    -- Base rewards
    rewards.credits = self.baseRewards.credits
    rewards.experience = self.baseRewards.experience
    
    -- Objective completion bonus
    local completionPercentage = objectiveManager:getProgressForTeam("player") / 100
    rewards.credits = rewards.credits * completionPercentage
    rewards.experience = rewards.experience * completionPercentage
    
    -- Speed bonus (completed in fewer turns = bonus)
    local speedBonus = 1.0
    if turn <= 10 then
        speedBonus = 1.5
    elseif turn <= 20 then
        speedBonus = 1.2
    end
    rewards.credits = rewards.credits * speedBonus
    rewards.experience = rewards.experience * speedBonus
    
    -- Perfect completion bonus (100% objectives, all units alive)
    if completionPercentage >= 1.0 then
        local livingUnits = 0
        for _, unit in ipairs(battlefield:getUnitsForTeam("player")) do
            if unit.health > 0 then livingUnits = livingUnits + 1 end
        end
        if livingUnits == #battlefield:getUnitsForTeam("player") then
            rewards.credits = rewards.credits * 1.3
            rewards.experience = rewards.experience * 1.3
        end
    end
    
    return rewards
end
```

**Estimated time:** 4 hours

---

### Step 8: AI Objective Completion (10 hours)
**Description:** AI logic to complete its assigned objectives  
**Files to modify:**
- `engine/battlescape/logic/ai/objective_ai.lua` - AI objective prioritization

**ObjectiveAI:**
```lua
ObjectiveAI = {
    objectiveManager = nil,
    team = "enemy",
}

ObjectiveAI:evaluateAction(unit, battlefield)
    -- Get AI team's objectives
    local objectives = self.objectiveManager:getObjectivesForTeam(self.team)
    
    -- Prioritize objectives by weight and progress
    local prioritizedObjectives = self:prioritizeObjectives(objectives)
    
    -- Choose action based on top priority objective
    local topObjective = prioritizedObjectives[1]
    
    if topObjective.type == "kill_all" then
        return self:chooseAttackAction(unit, battlefield)
    elseif topObjective.type == "domination" then
        return self:chooseMoveToDominationSector(unit, battlefield, topObjective)
    elseif topObjective.type == "escort" then
        return self:chooseEscortAction(unit, battlefield, topObjective)
    elseif topObjective.type == "assassination" then
        return self:chooseAssassinationAction(unit, battlefield, topObjective)
    -- ... more objective types
    end
    
    -- Fallback: default combat AI
    return self:chooseDefaultAction(unit, battlefield)
end

ObjectiveAI:prioritizeObjectives(objectives)
    -- Sort by: incomplete first, then by weight
    table.sort(objectives, function(a, b)
        if a.completed ~= b.completed then
            return not a.completed  -- Incomplete first
        end
        return a.weight > b.weight
    end)
    return objectives
end

ObjectiveAI:chooseMoveToDominationSector(unit, battlefield, objective)
    -- Find nearest uncaptured sector
    local targetSector = self:findNearestUncontrolledSector(unit, objective)
    if targetSector then
        -- Move toward sector center
        local path = Pathfinding:findPath(
            {x = unit.x, y = unit.y},
            {x = targetSector.bounds.x + targetSector.bounds.width / 2,
             y = targetSector.bounds.y + targetSector.bounds.height / 2}
        )
        return {type = "move", path = path}
    end
    return nil
end

ObjectiveAI:chooseEscortAction(unit, battlefield, objective)
    -- Find VIP unit
    local vip = battlefield:getUnitById(objective.conditions.escortUnitId)
    if not vip then return nil end
    
    -- Stay near VIP and defend
    local distanceToVIP = math.abs(unit.x - vip.x) + math.abs(unit.y - vip.y)
    if distanceToVIP > 5 then
        -- Move closer to VIP
        local path = Pathfinding:findPath({x = unit.x, y = unit.y}, {x = vip.x, y = vip.y})
        return {type = "move", path = path}
    else
        -- Defend VIP: attack nearby threats
        return self:chooseAttackAction(unit, battlefield)
    end
end
```

**Estimated time:** 10 hours

---

### Step 9: Testing & Validation (10 hours)
**Description:** Unit tests, integration tests, manual testing  
**Files to create:**
- `engine/battlescape/tests/test_objectives.lua`
- `engine/battlescape/tests/test_objective_manager.lua`
- `engine/battlescape/tests/test_sector_control.lua`

**Test Cases:**

1. **Objective Progress:**
   - Kill All: Progress updates as enemies killed
   - Domination: Progress updates as sectors controlled
   - Survive: Progress updates each turn
   - Assassination: 0% until target dead, then 100%

2. **Victory Conditions:**
   - Battle ends when team reaches 100% progress
   - Multiple objectives combine correctly
   - Partial completion awards partial rewards

3. **Sector Control:**
   - Sectors update control based on unit positions
   - Contested sectors marked correctly
   - Domination objective tracks sector control

4. **AI Behavior:**
   - AI prioritizes objectives
   - AI moves toward objectives
   - AI completes objectives when possible

5. **Edge Cases:**
   - All units dead (no progress possible)
   - Objectives conflict (kill all vs. escort)
   - Objective failed mid-battle

**Manual Testing:**
1. Run game with Love2D console
2. Start battle with different mission templates
3. Complete objectives, verify progress updates
4. Check victory screen shows correct results
5. Test AI completing its objectives
6. Verify rewards scale with completion percentage

**Estimated time:** 10 hours

---

### Step 10: Documentation (4 hours)
**Description:** Update wiki and API documentation  
**Files to modify:**
- `wiki/API.md` - Objective API
- `wiki/FAQ.md` - Mission objectives guide
- `wiki/DEVELOPMENT.md` - Objective system architecture

**Documentation Sections:**
1. Objective System Overview
2. Creating Custom Objectives
3. Mission Template Guide
4. Sector Control System
5. AI Objective Behavior
6. Reward Scaling Formula

**Estimated time:** 4 hours

---

## Total Time Estimate

**98 hours** (12-13 days at 8 hours/day)

**Phase Breakdown:**
- Phase 1: Core Data & Logic (6h + 8h + 20h + 8h = 42h)
- Phase 2: Mission Design & AI (6h + 10h = 16h)
- Phase 3: UI & Rewards (12h + 4h = 16h)
- Phase 4: Testing & Docs (10h + 4h = 14h)

---

## Implementation Details

### Architecture

**Objective System Layers:**
```
UI Layer (objective_panel, victory_screen)
    ↓
Manager Layer (objective_manager)
    ↓
Logic Layer (objective types: kill_all, domination, etc.)
    ↓
Data Layer (mission_templates.lua)
```

**Objective Lifecycle:**
```
Created → Active → Updating → Completed/Failed
```

### Key Components

**Objective Base Class:**
- Properties: type, name, weight, progress, team, conditions, state
- Methods: update(), checkCompletion(), getProgress()

**ObjectiveManager:**
- Manages all objectives for all teams
- Calculates total progress per team
- Checks victory conditions
- Emits events

**SectorControl:**
- Divides map into sectors
- Tracks which team controls each sector
- Updates control each turn

**ObjectiveAI:**
- AI prioritizes objectives by weight/completion
- AI chooses actions to complete objectives
- Fallback to default combat behavior

### Dependencies

**Required Systems:**
- Battlescape ECS System - Unit tracking, turn management
- TurnManager - Turn end hooks for objective updates
- Pathfinding - AI movement toward objectives
- Event System - Objective completion events
- UI Widgets - Objective panel, progress bars

**Integration Points:**
- TurnManager:endTurn() → ObjectiveManager:onTurnEnd()
- Battlefield:getUnitsForTeam() → Objective:update()
- AI:chooseAction() → ObjectiveAI:evaluateAction()
- BattleRewards:calculate() → ObjectiveManager:getProgress()

---

## Testing Strategy

### Unit Tests

**test_objectives.lua:**
```lua
function test_kill_all_objective()
    local battlefield = createMockBattlefield(10, 0)  -- 10 enemies, 0 killed
    local objective = KillAllObjective:new({
        conditions = {targetTeam = "enemy"}
    })
    
    objective:update(battlefield)
    assert(objective.progress == 0)
    
    -- Kill 5 enemies
    battlefield = createMockBattlefield(10, 5)
    objective:update(battlefield)
    assert(objective.progress == 50)
    
    -- Kill all
    battlefield = createMockBattlefield(10, 10)
    objective:update(battlefield)
    assert(objective.progress == 100)
    assert(objective.completed == true)
end

function test_survive_objective()
    local battlefield = createMockBattlefield()
    local objective = SurviveObjective:new({
        conditions = {turnsToSurvive = 10, minUnitsAlive = 1}
    })
    
    -- Turn 1
    battlefield.currentTurn = 1
    objective:update(battlefield)
    assert(objective.progress == 10)
    
    -- Turn 10
    battlefield.currentTurn = 10
    objective:update(battlefield)
    assert(objective.progress == 100)
    assert(objective.completed == true)
end
```

**test_objective_manager.lua:**
```lua
function test_multiple_objectives()
    local manager = ObjectiveManager:new(battlefield, {
        player = {
            {type = "kill_all", weight = 50, conditions = {targetTeam = "enemy"}},
            {type = "domination", weight = 50, conditions = {sectorsToControl = 2}},
        }
    })
    
    -- Complete first objective (50%)
    manager.objectives.player[1].progress = 100
    manager:updateProgress("player")
    assert(manager.progress.player == 50)
    
    -- Complete second objective (100% total)
    manager.objectives.player[2].progress = 100
    manager:updateProgress("player")
    assert(manager.progress.player == 100)
    assert(manager.victoryTeam == "player")
end
```

### Integration Tests

**test_battle_objectives_integration.lua:**
```lua
function test_full_battle_with_objectives()
    local battlefield = Battlefield:new()
    local objectiveManager = ObjectiveManager:new(battlefield, missionTemplates.standard_combat)
    
    -- Start battle
    battlefield:startBattle()
    
    -- Kill enemies each turn
    for turn = 1, 10 do
        -- Kill 1 enemy per turn
        local enemy = battlefield:getUnitsForTeam("enemy")[1]
        enemy:takeDamage(999)
        
        -- End turn
        TurnManager:endTurn()
        objectiveManager:onTurnEnd("player")
    end
    
    -- Check victory
    assert(objectiveManager.victoryTeam == "player")
end
```

### Manual Testing Steps

1. **Run game:** `lovec "engine"`
2. **Start battlescape with objectives:**
   - Select mission template (e.g., "Terror Mission")
   - Verify objectives displayed in panel
   - Verify progress bars at 0%
3. **Play through mission:**
   - Complete objectives (kill enemies, control sectors, etc.)
   - Verify progress updates each turn
   - Verify total progress increases
4. **Win battle:**
   - Reach 100% progress
   - Verify victory screen appears
   - Verify rewards displayed
   - Verify turn count shown
5. **Test different mission types:**
   - Assassination, Domination, Survive, etc.
   - Verify each objective type works correctly
6. **Test AI objectives:**
   - Observe AI behavior
   - Verify AI moves toward objectives
   - Check if AI can win by completing objectives

### Expected Results

- Objectives display in panel with correct names/descriptions
- Progress bars update in real-time
- Battle ends immediately when team reaches 100%
- Victory screen shows correct results
- Rewards scale with completion percentage
- AI attempts to complete its objectives
- No console errors or warnings

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use VS Code task: "Run XCOM Simple Game"

### Debugging
- Console enabled in `conf.lua`
- Print statements:
  ```lua
  print("[ObjectiveManager] Team progress: " .. progress)
  print("[KillAllObjective] Enemies remaining: " .. count)
  print("[SectorControl] Sector " .. sector.id .. " controlled by " .. sector.controllingTeam)
  ```
- Check console for:
  - Objective updates each turn
  - Progress calculations
  - Victory conditions
  - AI objective decisions

### Debug Hotkeys
- **F1**: Toggle objective panel
- **F2**: Show sector overlay
- **F3**: Print objective status to console

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Objective API, ObjectiveManager API
- [x] `wiki/FAQ.md` - Mission objectives guide
- [x] `wiki/DEVELOPMENT.md` - Objective system architecture
- [x] Add code comments

---

## Notes

**Design Decisions:**
1. **Percentage-based:** Clear feedback, flexible weights
2. **Multiple objectives:** Variety and strategic depth
3. **Team-specific:** Asymmetric gameplay
4. **First to 100% wins:** No ties, clear victory
5. **Partial rewards:** Encourages objective completion even if losing

**Balancing Considerations:**
- Objective weights: 50/50, 60/40, or 100 single objective
- Turn limits: 10-30 turns typical
- Sector counts: 2-4 sectors for domination
- AI difficulty: Adjustable objective prioritization

**Future Enhancements:**
- Dynamic objectives (spawn mid-battle)
- Secret objectives (bonus rewards)
- Time-limited objectives (expire after N turns)
- Objective chains (complete A to unlock B)
- Multiplayer asymmetric objectives

---

## Blockers

**Dependencies:**
- Battlescape ECS System must be operational
- TurnManager must support turn-end hooks
- Unit system must track health/position/team

**No Hard Blockers:** Can implement with existing battlescape systems

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] All variables use `local`
- [ ] Proper error handling with `pcall`
- [ ] Console debugging statements added
- [ ] UI elements snap to 24×24 grid
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in console
- [ ] Performance acceptable (no lag with 10+ objectives)
- [ ] Save/load verified

---

## Post-Completion

### What Worked Well
- (To be filled after implementation)

### What Could Be Improved
- (To be filled after implementation)

### Lessons Learned
- (To be filled after implementation)
