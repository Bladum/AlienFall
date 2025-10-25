--- Mission generation and management system for Geoscape
-- Generates procedural missions based on faction activity and regional threats
-- Handles mission lifecycle: creation → active → completion → resolution
--
-- @module MissionSystem
-- @author AI Agent
-- @license MIT

local MissionSystem = {}
MissionSystem.__index = MissionSystem

--- Mission type configurations
local MISSION_TEMPLATES = {
  infiltration = {
    weight = 40,
    duration_min = 5,
    duration_max = 10,
    control_loss_per_turn = 0.05,
    threat_multiplier = 0.8,
    reward_control = 5,
  },
  terror = {
    weight = 30,
    duration_min = 2,
    duration_max = 4,
    morale_loss = 20,
    population_loss = 0.10,
    threat_multiplier = 1.2,
    reward_control = 10,
  },
  research = {
    weight = 20,
    duration_min = 10,
    duration_max = 15,
    tech_progress_per_turn = 0.05,
    threat_multiplier = 0.6,
    reward_tech = 10,
  },
  supply = {
    weight = 10,
    duration_min = 3,
    duration_max = 7,
    economy_loss_per_turn = 0.05,
    threat_multiplier = 0.5,
    reward_control = 3,
  },
}

--- Create new mission system
-- @return MissionSystem - New mission system instance
function MissionSystem.new()
  local self = setmetatable({}, MissionSystem)

  self.active_missions = {}
  self.completed_missions = {}
  self.mission_id_counter = 1
  self.total_mission_count = 0

  return self
end

--- Generate mission from faction activity
-- @param faction string - Faction name
-- @param region_id number - Target region ID
-- @param mission_type string|nil - Force specific mission type (random if nil)
-- @param threat_level number - Base threat level (0-100)
-- @return table - Generated mission data
function MissionSystem:generateMission(faction, region_id, mission_type, threat_level)
  local mission_id = self.mission_id_counter
  self.mission_id_counter = self.mission_id_counter + 1

  -- Determine mission type if not specified
  if not mission_type then
    mission_type = self:selectMissionType()
  end

  local template = MISSION_TEMPLATES[mission_type]
  if not template then
    mission_type = "infiltration"
    template = MISSION_TEMPLATES[mission_type]
  end

  -- Calculate mission duration (random within range)
  local duration = math.random(template.duration_min, template.duration_max)

  -- Calculate actual threat level
  threat_level = threat_level or 50
  local actual_threat = math.floor(threat_level * template.threat_multiplier)
  actual_threat = math.max(20, math.min(100, actual_threat))

  -- Create mission object
  local mission = {
    id = mission_id,
    faction = faction,
    type = mission_type,
    region_id = region_id,
    threat_level = actual_threat,
    duration = duration,
    turns_remaining = duration,
    status = "active",
    created_turn = 0,  -- Will be set by caller
    discovered = false,
    reward = self:calculateReward(mission_type),
    completion_effect = self:getCompletionEffect(mission_type),
  }

  -- Store mission
  self.active_missions[mission_id] = mission
  self.total_mission_count = self.total_mission_count + 1

  return mission
end

--- Select random mission type based on weighted distribution
-- @return string - Mission type
function MissionSystem:selectMissionType()
  local roll = math.random(100)
  local total_weight = 0

  for mission_type, template in pairs(MISSION_TEMPLATES) do
    total_weight = total_weight + template.weight
  end

  local cumulative = 0
  for mission_type, template in pairs(MISSION_TEMPLATES) do
    cumulative = cumulative + template.weight
    if roll <= (cumulative / total_weight) * 100 then
      return mission_type
    end
  end

  return "infiltration"
end

--- Calculate reward for stopping mission
-- @param mission_type string - Mission type
-- @return number - Reward points
function MissionSystem:calculateReward(mission_type)
  local template = MISSION_TEMPLATES[mission_type]
  local base_reward = {
    infiltration = 50,
    terror = 100,
    research = 75,
    supply = 40,
  }

  return base_reward[mission_type] or 50
end

--- Get completion effect data for mission type
-- @param mission_type string - Mission type
-- @return table - Effect configuration
function MissionSystem:getCompletionEffect(mission_type)
  local template = MISSION_TEMPLATES[mission_type]

  return {
    type = mission_type,
    control_loss = template.control_loss_per_turn,
    morale_loss = template.morale_loss,
    population_loss = template.population_loss,
    tech_progress = template.tech_progress_per_turn,
    economy_loss = template.economy_loss_per_turn,
  }
end

--- Update all active missions (per turn processing)
-- Decrements countdown, marks completed missions
-- @param turn number - Current campaign turn
-- @return table - Missions that completed this turn
function MissionSystem:update(turn)
  local completed_this_turn = {}
  local missions_to_remove = {}

  for mission_id, mission in pairs(self.active_missions) do
    mission.turns_remaining = mission.turns_remaining - 1

    -- Check for completion
    if mission.turns_remaining <= 0 then
      mission.status = "completed"
      table.insert(completed_this_turn, mission)
      table.insert(missions_to_remove, mission_id)
    end
  end

  -- Move completed missions out of active list
  for _, mission_id in ipairs(missions_to_remove) do
    self.active_missions[mission_id] = nil
    table.insert(self.completed_missions, self.active_missions[mission_id])
  end

  return completed_this_turn
end

--- Get mission by ID
-- @param mission_id number - Mission identifier
-- @return table|nil - Mission data or nil if not found
function MissionSystem:getMissionById(mission_id)
  return self.active_missions[mission_id]
end

--- Get all active missions for faction
-- @param faction string - Faction name
-- @return table - Array of active missions
function MissionSystem:getActiveMissions(faction)
  local missions = {}

  for _, mission in pairs(self.active_missions) do
    if mission.faction == faction then
      table.insert(missions, mission)
    end
  end

  return missions
end

--- Get all missions in region
-- @param region_id number - Region identifier
-- @return table - Array of active missions in region
function MissionSystem:getMissionsInRegion(region_id)
  local missions = {}

  for _, mission in pairs(self.active_missions) do
    if mission.region_id == region_id then
      table.insert(missions, mission)
    end
  end

  return missions
end

--- Complete mission (player stops it)
-- @param mission_id number - Mission to complete
-- @param status string - "stopped" or "failed"
-- @param reward_multiplier number|nil - Multiplier for reward (default 1.0)
function MissionSystem:completeMission(mission_id, status, reward_multiplier)
  local mission = self.active_missions[mission_id]

  if not mission then
    return nil
  end

  mission.status = status or "stopped"
  reward_multiplier = reward_multiplier or 1.0
  mission.actual_reward = math.floor(mission.reward * reward_multiplier)
  mission.completion_turn = 0  -- Will be set by caller

  -- Move to completed
  self.active_missions[mission_id] = nil
  table.insert(self.completed_missions, mission)

  return mission
end

--- Get active mission count
-- @return number - Number of active missions
function MissionSystem:getActiveMissionCount()
  local count = 0
  for _ in pairs(self.active_missions) do
    count = count + 1
  end
  return count
end

--- Get all active missions (for debugging/display)
-- @return table - Array of all active missions
function MissionSystem:getAllActiveMissions()
  local missions = {}
  for _, mission in pairs(self.active_missions) do
    table.insert(missions, mission)
  end
  return missions
end

--- Get mission statistics
-- @return table - Stats including active count, completion rate, etc.
function MissionSystem:getStatistics()
  local active_count = self:getActiveMissionCount()
  local completed_count = #self.completed_missions

  -- Calculate average completion rate
  local total_generated = active_count + completed_count
  local completion_rate = total_generated > 0 and (completed_count / total_generated) * 100 or 0

  -- Count by type
  local by_type = {
    infiltration = 0,
    terror = 0,
    research = 0,
    supply = 0,
  }

  for _, mission in pairs(self.active_missions) do
    by_type[mission.type] = (by_type[mission.type] or 0) + 1
  end

  return {
    active = active_count,
    completed = completed_count,
    total_generated = total_generated,
    completion_rate = completion_rate,
    by_type = by_type,
  }
end

--- Serialize mission system for save/load
-- @return table - Serialized state
function MissionSystem:serialize()
  local active_array = {}
  for _, mission in pairs(self.active_missions) do
    table.insert(active_array, mission)
  end

  return {
    active_missions = active_array,
    completed_missions = self.completed_missions,
    mission_id_counter = self.mission_id_counter,
    total_mission_count = self.total_mission_count,
  }
end

--- Deserialize mission system from save data
-- @param data table - Serialized state
-- @return MissionSystem - Restored system
function MissionSystem.deserialize(data)
  local self = setmetatable({}, MissionSystem)

  self.active_missions = {}
  for _, mission in ipairs(data.active_missions or {}) do
    self.active_missions[mission.id] = mission
  end

  self.completed_missions = data.completed_missions or {}
  self.mission_id_counter = data.mission_id_counter or 1
  self.total_mission_count = data.total_mission_count or 0

  return self
end

return MissionSystem

