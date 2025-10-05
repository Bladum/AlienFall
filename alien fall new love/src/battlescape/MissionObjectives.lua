--- Mission Objectives
-- Manages mission objectives, completion tracking, and salvage calculation
--
-- @classmod battlescape.MissionObjectives

-- GROK: MissionObjectives tracks primary/secondary objectives with completion states
-- GROK: Manages salvage calculation based on objectives, casualties, and terrain
-- GROK: Key methods: checkObjectiveCompletion(), calculateSalvage(), getMissionStatus()
-- GROK: Integrates with mission system for victory/defeat conditions

local class = require 'lib.Middleclass'

--- MissionObjectives class
-- @type MissionObjectives
MissionObjectives = class('MissionObjectives')

--- Objective types
-- @field PRIMARY Primary mission objective
-- @field SECONDARY Secondary mission objective
-- @field BONUS Bonus objective
MissionObjectives.static.OBJECTIVE_TYPES = {
    PRIMARY = "primary",
    SECONDARY = "secondary",
    BONUS = "bonus"
}

--- Objective states
-- @field INCOMPLETE Objective not completed
-- @field COMPLETED Objective completed
-- @field FAILED Objective failed
MissionObjectives.static.OBJECTIVE_STATES = {
    INCOMPLETE = "incomplete",
    COMPLETED = "completed",
    FAILED = "failed"
}

--- Mission states
-- @field ACTIVE Mission in progress
-- @field VICTORY Mission completed successfully
-- @field DEFEAT Mission failed
-- @field WITHDRAWN Mission withdrawn/aborted
MissionObjectives.static.MISSION_STATES = {
    ACTIVE = "active",
    VICTORY = "victory",
    DEFEAT = "defeat",
    WITHDRAWN = "withdrawn"
}

--- Create a new MissionObjectives instance
-- @param missionData Mission configuration data
-- @return MissionObjectives instance
function MissionObjectives:initialize(missionData)
    self.missionData = missionData
    self.objectives = {}
    self.missionState = self.MISSION_STATES.ACTIVE
    self.startTime = love.timer.getTime()
    self.turnCount = 0

    -- Initialize objectives
    self:initializeObjectives(missionData.objectives or {})

    -- Mission parameters
    self.timeLimit = missionData.timeLimit -- In turns
    self.casualtyLimit = missionData.casualtyLimit -- Max friendly casualties
    self.difficulty = missionData.difficulty or "normal"
end

--- Initialize objectives from mission data
-- @param objectivesData Objectives configuration
function MissionObjectives:initializeObjectives(objectivesData)
    for i, objData in ipairs(objectivesData) do
        local objective = {
            id = objData.id or i,
            type = objData.type or self.OBJECTIVE_TYPES.PRIMARY,
            title = objData.title or ("Objective " .. i),
            description = objData.description or "",
            state = self.OBJECTIVE_STATES.INCOMPLETE,
            conditions = objData.conditions or {},
            rewards = objData.rewards or {},
            completionTime = nil,
            progress = 0,
            maxProgress = objData.maxProgress or 1
        }

        table.insert(self.objectives, objective)
    end
end

--- Update objectives based on game state
-- @param battleState Current battle state
function MissionObjectives:updateObjectives(battleState)
    self.turnCount = battleState:getCurrentTurn()

    -- Check time limit
    if self.timeLimit and self.turnCount > self.timeLimit then
        self.missionState = self.MISSION_STATES.DEFEAT
        return
    end

    -- Check casualty limit
    if self.casualtyLimit then
        local friendlyCasualties = self:getFriendlyCasualtyCount(battleState)
        if friendlyCasualties >= self.casualtyLimit then
            self.missionState = self.MISSION_STATES.DEFEAT
            return
        end
    end

    -- Update individual objectives
    for _, objective in ipairs(self.objectives) do
        if objective.state == self.OBJECTIVE_STATES.INCOMPLETE then
            self:updateObjective(objective, battleState)
        end
    end

    -- Check mission completion
    self:checkMissionCompletion(battleState)
end

--- Update individual objective
-- @param objective Objective to update
-- @param battleState Current battle state
function MissionObjectives:updateObjective(objective, battleState)
    local completed = true

    for _, condition in ipairs(objective.conditions) do
        if not self:checkCondition(condition, battleState) then
            completed = false
            break
        end
    end

    if completed then
        objective.state = self.OBJECTIVE_STATES.COMPLETED
        objective.completionTime = self.turnCount

        -- Trigger completion event
        battleState:triggerEvent('battlescape:objective_completed', {
            objective = objective,
            completionTime = objective.completionTime
        })
    end
end

--- Check objective condition
-- @param condition Condition to check
-- @param battleState Current battle state
-- @return boolean Whether condition is met
function MissionObjectives:checkCondition(condition, battleState)
    local conditionType = condition.type

    if conditionType == "kill_units" then
        local killed = self:getUnitsKilled(battleState, condition.faction)
        return killed >= condition.count

    elseif conditionType == "protect_units" then
        local alive = self:getUnitsAlive(battleState, condition.faction)
        return alive >= condition.count

    elseif conditionType == "reach_location" then
        return self:checkLocationReached(condition.location, battleState)

    elseif conditionType == "destroy_objective" then
        return self:checkObjectiveDestroyed(condition.objectiveId, battleState)

    elseif conditionType == "survive_turns" then
        return self.turnCount >= condition.turns

    elseif conditionType == "collect_items" then
        local collected = self:getItemsCollected(battleState, condition.itemType)
        return collected >= condition.count

    elseif conditionType == "prevent_casualties" then
        local casualties = self:getFriendlyCasualtyCount(battleState)
        return casualties <= condition.maxCasualties

    elseif conditionType == "time_limit" then
        return self.turnCount <= condition.maxTurns
    end

    return false
end

--- Get units killed of specific faction
-- @param battleState Battle state
-- @param faction Faction name
-- @return number Units killed
function MissionObjectives:getUnitsKilled(battleState, faction)
    local killed = 0
    for _, unit in ipairs(battleState:getAllUnits()) do
        if unit:getFaction() == faction and not unit:isAlive() then
            killed = killed + 1
        end
    end
    return killed
end

--- Get units alive of specific faction
-- @param battleState Battle state
-- @param faction Faction name
-- @return number Units alive
function MissionObjectives:getUnitsAlive(battleState, faction)
    local alive = 0
    for _, unit in ipairs(battleState:getAllUnits()) do
        if unit:getFaction() == faction and unit:isAlive() then
            alive = alive + 1
        end
    end
    return alive
end

--- Check if location has been reached
-- @param location Location data
-- @param battleState Battle state
-- @return boolean Whether location reached
function MissionObjectives:checkLocationReached(location, battleState)
    local units = battleState:getUnitsAt(location.x, location.y)
    for _, unit in ipairs(units) do
        if unit:getFaction() == "player" and unit:isAlive() then
            return true
        end
    end
    return false
end

--- Check if objective has been destroyed
-- @param objectiveId Objective ID
-- @param battleState Battle state
-- @return boolean Whether objective destroyed
function MissionObjectives:checkObjectiveDestroyed(objectiveId, battleState)
    -- Check for destroyed objectives in battle state
    local objectives = battleState:getMissionObjectives()
    for _, obj in ipairs(objectives) do
        if obj.id == objectiveId and obj.destroyed then
            return true
        end
    end
    return false
end

--- Get items collected
-- @param battleState Battle state
-- @param itemType Item type
-- @return number Items collected
function MissionObjectives:getItemsCollected(battleState, itemType)
    -- Sum items collected by player units
    local collected = 0
    for _, unit in ipairs(battleState:getAllUnits()) do
        if unit:getFaction() == "player" then
            collected = collected + unit:getItemCount(itemType)
        end
    end
    return collected
end

--- Get friendly casualty count
-- @param battleState Battle state
-- @return number Friendly casualties
function MissionObjectives:getFriendlyCasualtyCount(battleState)
    local casualties = 0
    for _, unit in ipairs(battleState:getAllUnits()) do
        if unit:getFaction() == "player" and not unit:isAlive() then
            casualties = casualties + 1
        end
    end
    return casualties
end

--- Check mission completion status
-- @param battleState Battle state
function MissionObjectives:checkMissionCompletion(battleState)
    if self.missionState ~= self.MISSION_STATES.ACTIVE then
        return
    end

    -- Check if all primary objectives are completed
    local primaryCompleted = true
    local anyPrimaryFailed = false

    for _, objective in ipairs(self.objectives) do
        if objective.type == self.OBJECTIVE_TYPES.PRIMARY then
            if objective.state == self.OBJECTIVE_STATES.FAILED then
                anyPrimaryFailed = true
            elseif objective.state ~= self.OBJECTIVE_STATES.COMPLETED then
                primaryCompleted = false
            end
        end
    end

    -- Mission victory if all primaries completed
    if primaryCompleted and not anyPrimaryFailed then
        self.missionState = self.MISSION_STATES.VICTORY
    elseif anyPrimaryFailed then
        self.missionState = self.MISSION_STATES.DEFEAT
    end
end

--- Force mission end
-- @param endState Mission end state
function MissionObjectives:forceMissionEnd(endState)
    self.missionState = endState
end

--- Calculate salvage rewards
-- @param battleState Battle state
-- @return table Salvage data
function MissionObjectives:calculateSalvage(battleState)
    local salvage = {
        credits = 0,
        items = {},
        experience = 0,
        tags = {}
    }

    -- Base salvage from mission type
    salvage.credits = self.missionData.baseSalvage or 1000

    -- Objective completion bonuses
    for _, objective in ipairs(self.objectives) do
        if objective.state == self.OBJECTIVE_STATES.COMPLETED then
            local multiplier = 1.0
            if objective.type == self.OBJECTIVE_TYPES.PRIMARY then
                multiplier = 2.0
            elseif objective.type == self.OBJECTIVE_TYPES.SECONDARY then
                multiplier = 1.5
            elseif objective.type == self.OBJECTIVE_TYPES.BONUS then
                multiplier = 1.2
            end

            salvage.credits = salvage.credits + (objective.rewards.credits or 0) * multiplier
            salvage.experience = salvage.experience + (objective.rewards.experience or 0) * multiplier
        end
    end

    -- Casualty penalties
    local friendlyCasualties = self:getFriendlyCasualtyCount(battleState)
    local casualtyPenalty = friendlyCasualties * 200 -- 200 credits per casualty
    salvage.credits = math.max(0, salvage.credits - casualtyPenalty)

    -- Time bonus/penalty
    if self.timeLimit then
        local timeRatio = self.turnCount / self.timeLimit
        if timeRatio < 0.8 then
            salvage.credits = salvage.credits * 1.2 -- Speed bonus
        elseif timeRatio > 1.2 then
            salvage.credits = salvage.credits * 0.8 -- Time penalty
        end
    end

    -- Terrain-based salvage
    local terrainTags = self:getTerrainTags(battleState)
    for _, tag in ipairs(terrainTags) do
        if tag == "urban" then
            salvage.credits = salvage.credits * 1.3
            table.insert(salvage.tags, "urban_combat")
        elseif tag == "alien" then
            salvage.credits = salvage.credits * 1.5
            table.insert(salvage.tags, "alien_technology")
        elseif tag == "military" then
            salvage.credits = salvage.credits * 1.4
            table.insert(salvage.tags, "military_hardware")
        end
    end

    -- Item salvage
    salvage.items = self:calculateItemSalvage(battleState)

    -- Difficulty multiplier
    local difficultyMultipliers = {
        easy = 0.8,
        normal = 1.0,
        hard = 1.3,
        very_hard = 1.6
    }
    local multiplier = difficultyMultipliers[self.difficulty] or 1.0
    salvage.credits = salvage.credits * multiplier
    salvage.experience = salvage.experience * multiplier

    return salvage
end

--- Get terrain tags for salvage calculation
-- @param battleState Battle state
-- @return table Terrain tags
function MissionObjectives:getTerrainTags(battleState)
    local tags = {}
    local map = battleState:getMap()

    -- Sample tiles to determine terrain type
    local sampleSize = math.min(20, map:getWidth() * map:getHeight())
    local sampledTiles = {}

    for i = 1, sampleSize do
        local x = math.random(1, map:getWidth())
        local y = math.random(1, map:getHeight())
        local tile = map:getTile(x, y)
        if tile then
            table.insert(sampledTiles, tile)
        end
    end

    -- Count material types
    local materialCounts = {}
    for _, tile in ipairs(sampledTiles) do
        local material = tile:getMaterial()
        materialCounts[material] = (materialCounts[material] or 0) + 1
    end

    -- Determine dominant terrain types
    for material, count in pairs(materialCounts) do
        if count > sampleSize * 0.3 then -- More than 30% of terrain
            if material == "concrete" or material == "metal" then
                table.insert(tags, "urban")
            elseif material == "stone" or material == "rubble" then
                table.insert(tags, "ruins")
            elseif material == "grass" or material == "dirt" then
                table.insert(tags, "outdoor")
            end
        end
    end

    -- Check for special mission tags
    if self.missionData.tags then
        for _, tag in ipairs(self.missionData.tags) do
            table.insert(tags, tag)
        end
    end

    return tags
end

--- Calculate item salvage
-- @param battleState Battle state
-- @return table Salvaged items
function MissionObjectives:calculateItemSalvage(battleState)
    local items = {}

    -- Collect items from dead enemies
    for _, unit in ipairs(battleState:getAllUnits()) do
        if not unit:isAlive() and unit:getFaction() ~= "player" then
            for _, item in ipairs(unit:getInventory()) do
                -- Chance to salvage based on item condition
                if math.random() < 0.7 then -- 70% salvage chance
                    table.insert(items, {
                        type = item:getType(),
                        condition = item:getCondition(),
                        value = item:getValue()
                    })
                end
            end
        end
    end

    -- Mission-specific salvage
    if self.missionData.salvageItems then
        for _, itemData in ipairs(self.missionData.salvageItems) do
            if math.random() < (itemData.chance or 1.0) then
                table.insert(items, itemData)
            end
        end
    end

    return items
end

--- Get mission status summary
-- @return table Mission status
function MissionObjectives:getMissionStatus()
    local completedObjectives = 0
    local totalObjectives = #self.objectives

    for _, objective in ipairs(self.objectives) do
        if objective.state == self.OBJECTIVE_STATES.COMPLETED then
            completedObjectives = completedObjectives + 1
        end
    end

    return {
        state = self.missionState,
        turnCount = self.turnCount,
        timeLimit = self.timeLimit,
        completedObjectives = completedObjectives,
        totalObjectives = totalObjectives,
        completionRatio = completedObjectives / totalObjectives
    }
end

--- Get objectives list
-- @return table Objectives
function MissionObjectives:getObjectives()
    return self.objectives
end

--- Get mission state
-- @return string Mission state
function MissionObjectives:getMissionState()
    return self.missionState
end

--- Check if mission is completed
-- @return boolean Whether mission is completed
function MissionObjectives:isMissionCompleted()
    return self.missionState == self.MISSION_STATES.VICTORY or
           self.missionState == self.MISSION_STATES.DEFEAT or
           self.missionState == self.MISSION_STATES.WITHDRAWN
end

--- Get mission duration
-- @return number Mission duration in seconds
function MissionObjectives:getMissionDuration()
    return love.timer.getTime() - self.startTime
end

--- Get mission data for serialization
-- @return table Mission data
function MissionObjectives:getData()
    return {
        missionData = self.missionData,
        objectives = self.objectives,
        missionState = self.missionState,
        startTime = self.startTime,
        turnCount = self.turnCount,
        timeLimit = self.timeLimit,
        casualtyLimit = self.casualtyLimit,
        difficulty = self.difficulty
    }
end

return MissionObjectives
