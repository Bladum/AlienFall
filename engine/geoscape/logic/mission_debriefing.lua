---Mission Debriefing System
---
---Processes post-battle results, calculates casualties, salvage collection,
---mission scoring, rewards/penalties, and updates player progression.
---
---Handles: Victory/defeat conditions, XP/promotion, salvage (items/corpses),
---mission scoring (objectives/kills/losses/efficiency), rewards (credits/items/research),
---and database updates.
---
---@module geoscape.logic.mission_debriefing
---@author AlienFall Development Team

local MissionDebriefing = {}
MissionDebriefing.__index = MissionDebriefing

---Create new mission debriefing session
---@param config table Debriefing configuration
---@return table debriefing New debriefing session
function MissionDebriefing.new(config)
    local self = setmetatable({}, MissionDebriefing)

    -- Mission info
    self.missionId = config.missionId or error("Debriefing requires missionId")
    self.missionType = config.missionType or "UNKNOWN"
    self.objectives = config.objectives or {}
    self.baseId = config.baseId or nil

    -- Battle results
    self.victory = config.victory or false
    self.allyUnits = config.allyUnits or {}      -- Alive units
    self.allyDeaths = config.allyDeaths or {}    -- Killed/captured units
    self.enemyDeaths = config.enemyDeaths or {}  -- Enemies killed
    self.enemyEscaped = config.enemyEscaped or 0 -- Enemies that escaped

    -- Battle stats
    self.turnsSpent = config.turnsSpent or 0
    self.alliesWounded = config.alliesWounded or 0
    self.civiliansKilled = config.civiliansKilled or 0
    self.propertiesDamaged = config.propertiesDamaged or 0

    -- Salvage collected
    self.salvage = {
        corpses = {},      -- Alien corpses with condition (1-3 intact)
        items = {},        -- Equipment, weapons, ammo
        materials = {},    -- Raw materials, alloys, electronics
        research = {},     -- Alien tech for research
        artifacts = {}     -- Special/artifact items
    }

    -- Scoring
    self.objectives_completed = 0
    self.objectives_partial = 0
    self.score = 0

    -- Rewards
    self.credits_earned = 0
    self.xp_per_unit = {}
    self.promotions = {}
    self.research_unlocked = {}
    self.items_unlocked = {}

    -- Penalties
    self.credits_penalty = 0
    self.reputation_penalty = 0
    self.relations_penalty = {}

    return self
end

---Process victory conditions
---@return boolean victory True if mission objectives met
function MissionDebriefing:processVictory()
    if not self.victory then
        print("[MissionDebriefing] Mission failed")
        return false
    end

    print("[MissionDebriefing] Processing victory")

    -- Calculate objective completion
    local objectives_completed = 0
    for _, obj in ipairs(self.objectives) do
        if obj.status == "complete" then
            objectives_completed = objectives_completed + 1
        elseif obj.status == "partial" then
            self.objectives_partial = self.objectives_partial + 1
        end
    end
    self.objectives_completed = objectives_completed

    return true
end

---Calculate mission score (0-1000 points)
---Score components:
---  - Objectives: 200 per primary, 100 per secondary
---  - Enemy kills: 5 per kill (max 300)
---  - Ally losses: -50 per death, -20 per wound (min -200)
---  - Turn efficiency: (max_turns - spent_turns) / max_turns × 100 (max 100)
---  - Property damage: -1 per damaged property (max -50)
---  - Civilian casualties: -50 per civilian killed
---@return number score Mission score (0-1000)
function MissionDebriefing:calculateScore()
    local score = 500  -- Base score

    -- Objectives (250 max)
    score = score + (self.objectives_completed * 200)
    score = score + (self.objectives_partial * 50)

    -- Kills (300 max)
    local kill_bonus = math.min(300, #self.enemyDeaths * 5)
    score = score + kill_bonus

    -- Losses (max -200 penalty)
    local death_penalty = math.min(200, #self.allyDeaths * 50)
    local wound_penalty = math.min(50, self.alliesWounded * 20)
    score = score - death_penalty - wound_penalty

    -- Turn efficiency (100 max)
    local max_turns = math.max(20, self.turnsSpent * 2)
    local turn_efficiency = math.floor((max_turns - self.turnsSpent) / max_turns * 100)
    score = score + math.max(0, turn_efficiency)

    -- Property damage (max -50)
    local property_penalty = math.min(50, self.propertiesDamaged * 5)
    score = score - property_penalty

    -- Civilian casualties (max -500)
    local civilian_penalty = self.civiliansKilled * 50
    score = score - civilian_penalty

    self.score = math.max(0, math.floor(score))

    print(string.format("[MissionDebriefing] Mission score: %d", self.score))
    return self.score
end

---Calculate base rewards (credits, research points)
---Depends on: mission score, difficulty, mission type, faction
---@return table rewards {credits, research_points}
function MissionDebriefing:calculateRewards()
    local rewards = {
        credits = 0,
        research_points = 0,
        salvage_value = 0
    }

    -- Base reward by mission type
    local mission_base = {
        DEFENSE = 5000,
        CAPTURE = 8000,
        ASSAULT = 10000,
        RESCUE = 6000,
        INVESTIGATION = 4000,
        ESCORT = 7000,
        SABOTAGE = 12000
    }

    local base = mission_base[self.missionType] or 5000

    -- Score multiplier (0.5x to 1.5x)
    local score_multiplier = 0.5 + (self.score / 1000) * 1.0

    rewards.credits = math.floor(base * score_multiplier)
    rewards.research_points = math.floor((self.score / 100) * 50)  -- 0-500 research points
    rewards.salvage_value = 0  -- Calculated from salvage items

    self.credits_earned = rewards.credits

    print(string.format("[MissionDebriefing] Rewards: $%d + %d research points",
          rewards.credits, rewards.research_points))

    return rewards
end

---Calculate unit XP and promotions
---Soldiers gain XP for kills, mission survival, objectives completed
---@return table xp_table {unitId = xp_earned}
function MissionDebriefing:calculateUnitXP()
    local xp_table = {}

    -- Base XP for mission completion
    local mission_xp = self.victory and 50 or 20

    -- XP per enemy killed
    local kill_xp = 10

    -- XP per unit
    for _, unitId in ipairs(self.allyUnits) do
        local xp = mission_xp

        -- Award kills (simplified - assume even distribution)
        local unit_kills = math.ceil(#self.enemyDeaths / math.max(1, #self.allyUnits))
        xp = xp + (unit_kills * kill_xp)

        xp_table[unitId] = xp
        self.xp_per_unit[unitId] = xp
    end

    print(string.format("[MissionDebriefing] Distributed %d total XP to %d units",
          mission_xp + (#self.enemyDeaths * kill_xp), #self.allyUnits))

    return xp_table
end

---Collect salvage from mission
---Salvage types: corpses (alien remains), items (weapons/armor), materials (alloys/electronics)
---@param items_on_ground table Array of items left on battlefield
---@param corpses_on_ground table Array of corpse locations
function MissionDebriefing:collectSalvage(items_on_ground, corpses_on_ground)
    items_on_ground = items_on_ground or {}
    corpses_on_ground = corpses_on_ground or {}

    -- Collect items
    for _, item in ipairs(items_on_ground) do
        if item.type == "weapon" then
            table.insert(self.salvage.items, item.id)
        elseif item.type == "armor" then
            table.insert(self.salvage.items, item.id)
        elseif item.type == "material" then
            table.insert(self.salvage.materials, {type = item.material_type, qty = item.quantity})
        elseif item.type == "artifact" then
            table.insert(self.salvage.artifacts, item.id)
        end
    end

    -- Collect corpses (alien remains for research)
    for _, corpse in ipairs(corpses_on_ground) do
        -- Corpse condition: 1 (destroyed), 2 (partial), 3 (intact)
        local condition = math.random(1, 3)
        if condition >= 2 then  -- Only collectable if partial/intact
            table.insert(self.salvage.corpses, {
                species = corpse.species,
                condition = condition,
                research_value = condition == 3 and 1000 or 500
            })
        end
    end

    print(string.format("[MissionDebriefing] Collected salvage: %d items, %d corpses",
          #self.salvage.items, #self.salvage.corpses))
end

---Add salvage to base inventory
---@param baseId string Base identifier
---@return boolean success
function MissionDebriefing:transferSalvageToBase(baseId)
    baseId = baseId or self.baseId
    if not baseId then
        print("[MissionDebriefing] ERROR: No base specified for salvage transfer")
        return false
    end

    -- Try to get base
    local Base = require("engine.basescape.logic.base")
    if not Base then
        print("[MissionDebriefing] Cannot load Base system")
        return false
    end

    local base = Base.getBase(baseId)
    if not base then
        print(string.format("[MissionDebriefing] Base %s not found", baseId))
        return false
    end

    -- Initialize inventory if needed
    if not base.inventory then
        base.inventory = {
            weapons = {},
            armor = {},
            materials = {},
            corpses = {}
        }
    end

    -- Transfer items
    if not base.inventory.weapons then
        base.inventory.weapons = {}
    end
    for _, item_id in ipairs(self.salvage.items) do
        base.inventory.weapons[item_id] = (base.inventory.weapons[item_id] or 0) + 1
    end

    -- Transfer materials
    if not base.inventory.materials then
        base.inventory.materials = {}
    end
    for _, mat in ipairs(self.salvage.materials) do
        base.inventory.materials[mat.type] = (base.inventory.materials[mat.type] or 0) + mat.qty
    end

    -- Transfer corpses for research
    if not base.inventory.corpses then
        base.inventory.corpses = {}
    end
    for _, corpse in ipairs(self.salvage.corpses) do
        local corpse_key = string.format("%s_%d", corpse.species, corpse.condition)
        base.inventory.corpses[corpse_key] = (base.inventory.corpses[corpse_key] or 0) + 1
    end

    print(string.format("[MissionDebriefing] Transferred salvage to base %s", baseId))
    return true
end

---Apply mission penalties (casualties, reputation, funding)
function MissionDebriefing:applyPenalties()
    -- Death penalty: -$2000 per KIA unit
    self.credits_penalty = #self.allyDeaths * 2000

    -- Reputation penalty: -10 per KIA, -5 per wounded civilian, -1 per property damaged
    self.reputation_penalty = (#self.allyDeaths * 10) +
                             (self.civiliansKilled * 5) +
                             (self.propertiesDamaged * 1)

    print(string.format("[MissionDebriefing] Penalties: $%d credit penalty, %d reputation loss",
          self.credits_penalty, self.reputation_penalty))
end

---Generate debriefing report
---@return table report {victory, score, rewards, casualties, salvage}
function MissionDebriefing:generateReport()
    -- Process results
    self:processVictory()
    self:calculateScore()
    self:calculateUnitXP()
    self:applyPenalties()

    local rewards = self:calculateRewards()

    local report = {
        -- Mission result
        victory = self.victory,
        missionId = self.missionId,
        missionType = self.missionType,

        -- Scoring
        score = self.score,
        objectives_completed = self.objectives_completed,

        -- Casualties
        allies_lost = #self.allyDeaths,
        allies_wounded = self.alliesWounded,
        enemies_killed = #self.enemyDeaths,
        civilians_killed = self.civiliansKilled,

        -- Rewards
        credits_earned = rewards.credits,
        credits_penalty = self.credits_penalty,
        net_credits = rewards.credits - self.credits_penalty,
        research_points = rewards.research_points,

        -- Salvage
        items_collected = #self.salvage.items,
        corpses_collected = #self.salvage.corpses,
        salvage_value = rewards.salvage_value,

        -- Unit progression
        xp_per_unit = self.xp_per_unit,
        promotions = self.promotions,

        -- Penalties
        reputation_penalty = self.reputation_penalty,

        -- Timestamp
        completed_at = os.time(),
        turns_spent = self.turnsSpent
    }

    print(string.format("[MissionDebriefing] Report generated: %s", self.victory and "VICTORY" or "DEFEAT"))
    return report
end

---Get debriefing summary for UI display
---@return string summary Multi-line debriefing text
function MissionDebriefing:getSummary()
    local lines = {}

    table.insert(lines, string.format("MISSION %s: %s", self.victory and "VICTORY" or "DEFEAT", self.missionId))
    table.insert(lines, "")
    table.insert(lines, string.format("Score: %d / 1000", self.score))
    table.insert(lines, string.format("Objectives: %d / %d completed", self.objectives_completed, #self.objectives))
    table.insert(lines, "")
    table.insert(lines, "--- CASUALTIES ---")
    table.insert(lines, string.format("Allied KIA: %d", #self.allyDeaths))
    table.insert(lines, string.format("Allied Wounded: %d", self.alliesWounded))
    table.insert(lines, string.format("Enemy Killed: %d", #self.enemyDeaths))
    table.insert(lines, string.format("Civilians Killed: %d", self.civiliansKilled))
    table.insert(lines, "")
    table.insert(lines, "--- REWARDS ---")
    table.insert(lines, string.format("Credits: $%d (- $%d penalties)",
          self.credits_earned, self.credits_penalty))
    table.insert(lines, string.format("Research Points: %d", self:calculateRewards().research_points))
    table.insert(lines, "")
    table.insert(lines, "--- SALVAGE ---")
    table.insert(lines, string.format("Items Collected: %d", #self.salvage.items))
    table.insert(lines, string.format("Corpses Collected: %d", #self.salvage.corpses))
    table.insert(lines, string.format("Materials Collected: %d", #self.salvage.materials))

    return table.concat(lines, "\n")
end

return MissionDebriefing
