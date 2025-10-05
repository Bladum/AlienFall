--- Procedural Generation System
-- Main module for coordinating all procedural content generation
--
-- @module procedure.ProcGen

local class = require 'lib.Middleclass'

--- Procedural Generation System
-- @type ProcGen
ProcGen = class('ProcGen')

--- Initialize the procedural generation system
-- @param seed Random seed for reproducible generation
function ProcGen:initialize(seed)
    self.seed = seed or os.time()
    self.rng = love.math.newRandomGenerator(self.seed)

    -- Initialize sub-generators
    self.missionGen = require('procedure.MissionGenerator')(self.rng)
    self.mapGen = require('procedure.MapGenerator')(self.rng)
    self.unitGen = require('procedure.UnitGenerator')(self.rng)
    self.itemGen = require('procedure.ItemGenerator')(self.rng)
    self.eventGen = require('procedure.EventGenerator')(self.rng)
end

--- Generate a complete mission with map, units, and events
-- @param missionType Type of mission to generate
-- @param difficulty Difficulty level (1-5)
-- @return Generated mission data
function ProcGen:generateMission(missionType, difficulty)
    local mission = self.missionGen:generate(missionType, difficulty)
    mission.map = self.mapGen:generate(mission.mapType, mission.size)
    mission.units = self.unitGen:generateUnits(mission.unitRequirements)
    mission.items = self.itemGen:generateItems(mission.itemRequirements)
    mission.events = self.eventGen:generateEvents(mission.eventTriggers)

    return mission
end

--- Generate random encounter
-- @param context Current game context
-- @return Encounter data
function ProcGen:generateEncounter(context)
    return {
        units = self.unitGen:generateEncounterUnits(context),
        events = self.eventGen:generateEncounterEvents(context),
        rewards = self.itemGen:generateRewards(context.difficulty)
    }
end

--- Set new random seed
-- @param seed New seed value
function ProcGen:setSeed(seed)
    self.seed = seed
    self.rng:setSeed(seed)
end

return ProcGen