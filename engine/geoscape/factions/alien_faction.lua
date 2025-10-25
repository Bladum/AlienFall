--- Alien Faction tracking system for Geoscape layer
-- Tracks individual faction state, activity levels, UFO counts, and mission scheduling
-- Coordinates with MissionSystem and TerrorSystem for dynamic alien activity
--
-- @module AlienFaction
-- @author AI Agent
-- @license MIT

local AlienFaction = {}
AlienFaction.__index = AlienFaction

--- UFO type definitions with unit counts and capabilities
local UFO_TYPES = {
  SCOUT = { name = "Scout", units = 4, speed = 3, capacity = 4, detection = 5 },
  FIGHTER = { name = "Fighter", units = 6, speed = 2, capacity = 6, detection = 4 },
  HARVESTER = { name = "Harvester", units = 8, speed = 1, capacity = 10, detection = 3 },
}

--- Activity level descriptions
local ACTIVITY_LEVELS = {
  [0] = "Dormant",
  [1] = "Awakening",
  [2] = "Active",
  [3] = "Aggressive",
  [4] = "Escalating",
  [5] = "Invasion",
  [6] = "Overwhelming",
  [7] = "Critical",
  [8] = "Catastrophic",
  [9] = "Apocalyptic",
  [10] = "Unstoppable",
}

--- Create new alien faction
-- @param name string - Faction identifier (e.g., "Sectoids", "Mutons")
-- @param initial_control number - Initial territory control (0-1)
-- @param initial_threat number - Initial threat level (0-100)
-- @return AlienFaction - New faction instance
function AlienFaction.new(name, initial_control, initial_threat)
  local self = setmetatable({}, AlienFaction)

  self.name = name
  self.control = math.max(0, math.min(1, initial_control))
  self.threat = math.max(0, math.min(100, initial_threat))

  -- Activity tracking
  self.base_activity = 0
  self.activity_from_regions = 0
  self.activity_decay = 0
  self.last_mission_turn = 0
  self.last_activity_turn = 0

  -- UFO tracking (counts by type)
  self.ufos = {
    scout = 0,
    fighter = 0,
    harvester = 0,
  }

  -- Mission scheduling
  self.mission_queue = {}
  self.mission_id_counter = 1000

  -- Terror tracking
  self.terror_campaigns = {}
  self.terror_intensity = 0

  -- Research progress tracking (aliens learning player tech)
  self.research_progress = 0

  return self
end

--- Update faction per turn
-- Handles activity changes, UFO generation, mission scheduling, and decay
-- @param turn number - Current campaign turn
-- @param regions_controlled number - Number of regions controlled (for activity bonus)
-- @param player_threat number - Player capability threat (0-10 scale)
function AlienFaction:update(turn, regions_controlled, player_threat)
  -- Activity calculation from multiple sources
  self.activity_from_regions = math.min(8, (regions_controlled or 0) * 0.5)

  -- Player threat increases activity (learning opponent)
  local threat_activity = math.min(2, (player_threat or 0) * 0.2)

  -- Decay if no recent activity
  local turns_since_activity = turn - self.last_activity_turn
  if turns_since_activity > 5 then
    self.activity_decay = math.max(0, self.activity_decay - (turns_since_activity / 5) * 0.1)
  end

  -- Calculate total activity (0-10 scale)
  local total = self.base_activity + self.activity_from_regions + threat_activity + self.activity_decay
  self.current_activity = math.max(0, math.min(10, total))

  -- Generate UFOs based on activity (1 UFO per 2 activity levels)
  local ufos_to_generate = math.floor(self.current_activity / 2) - (self.ufos.scout + self.ufos.fighter + self.ufos.harvester)
  for i = 1, ufos_to_generate do
    self:generateUFO()
  end

  -- Schedule missions periodically (lower activity = more frequent)
  local mission_interval = math.max(3, 10 - self.current_activity)
  if turn - self.last_mission_turn >= mission_interval then
    self:scheduleMission(turn, regions_controlled)
    self.last_mission_turn = turn
  end

  -- Update threat level based on activity and research progress
  self:updateThreatLevel()
end

--- Calculate current activity level (0-10 scale)
-- @return number - Activity level
function AlienFaction:getActivityLevel()
  return self.current_activity or self.base_activity
end

--- Calculate threat level (0-100 scale)
-- @return number - Threat level
function AlienFaction:getThreatLevel()
  return self.threat
end

--- Get activity level description
-- @return string - Human-readable activity description
function AlienFaction:getActivityDescription()
  local level = math.floor(self:getActivityLevel())
  return ACTIVITY_LEVELS[level] or "Unknown"
end

--- Generate a UFO and add to active fleet
-- Uses weighted random selection favoring lower-tier UFOs
-- @return table - Generated UFO data
function AlienFaction:generateUFO()
  -- Weighted random selection (60% scouts, 30% fighters, 10% harvesters)
  local roll = math.random(100)
  local ufo_type = "scout"

  if roll <= 60 then
    ufo_type = "scout"
    self.ufos.scout = self.ufos.scout + 1
  elseif roll <= 90 then
    ufo_type = "fighter"
    self.ufos.fighter = self.ufos.fighter + 1
  else
    ufo_type = "harvester"
    self.ufos.harvester = self.ufos.harvester + 1
  end

  local ufo_data = UFO_TYPES[ufo_type:upper()]
  return {
    type = ufo_type,
    name = ufo_data.name,
    units = ufo_data.units,
    speed = ufo_data.speed,
    capacity = ufo_data.capacity,
    detection_radius = ufo_data.detection,
    hp = ufo_data.units * 20,
    max_hp = ufo_data.units * 20,
  }
end

--- Schedule mission for future generation
-- Determines mission type based on faction activity and priorities
-- @param turn number - Current turn
-- @param regions_controlled number - Number of controlled regions (for targeting)
function AlienFaction:scheduleMission(turn, regions_controlled)
  local mission_id = self.mission_id_counter
  self.mission_id_counter = self.mission_id_counter + 1

  -- Mission type distribution (weighted by activity)
  local activity = self:getActivityLevel()
  local mission_roll = math.random(100)
  local mission_type = "infiltration"

  if mission_roll <= 40 then
    mission_type = "infiltration"
  elseif mission_roll <= 70 then
    mission_type = "terror"
  elseif mission_roll <= 90 then
    mission_type = "research"
  else
    mission_type = "supply"
  end

  -- Calculate threat level based on activity
  local threat_level = math.floor((activity / 10) * 100)
  threat_level = math.max(20, math.min(100, threat_level))

  -- Queue mission for MissionSystem to process
  table.insert(self.mission_queue, {
    id = mission_id,
    type = mission_type,
    threat_level = threat_level,
    turn_scheduled = turn,
    status = "queued",
  })

  return mission_id
end

--- Pop next mission from queue
-- @return table|nil - Next queued mission or nil if empty
function AlienFaction:activateMission()
  if #self.mission_queue > 0 then
    local mission = table.remove(self.mission_queue, 1)
    mission.status = "active"
    return mission
  end
  return nil
end

--- Increment faction activity (from events like successful missions)
-- @param amount number - Activity increase (typically 1-3)
function AlienFaction:incrementActivity(amount)
  self.base_activity = math.min(10, self.base_activity + (amount or 1))
  self.last_activity_turn = self.last_activity_turn + 1  -- Update decay timer
end

--- Start terror attack on regions
-- @param intensity number - Terror attack intensity (1-10)
function AlienFaction:startTerrorCampaign(intensity)
  table.insert(self.terror_campaigns, {
    intensity = intensity,
    duration = 0,
    locations = {},
  })
  self:incrementActivity(1)
end

--- Update threat level based on activity and research progress
-- Higher activity = higher threat
-- More research progress by aliens = higher threat
function AlienFaction:updateThreatLevel()
  local activity = self:getActivityLevel()
  local activity_threat = (activity / 10) * 60  -- Max 60 from activity
  local research_threat = (self.research_progress / 100) * 40  -- Max 40 from research

  self.threat = math.max(0, math.min(100, activity_threat + research_threat))
end

--- Get UFO fleet composition
-- @return table - UFOs active (scout=N, fighter=N, harvester=N)
function AlienFaction:getFleet()
  return {
    scout = self.ufos.scout,
    fighter = self.ufos.fighter,
    harvester = self.ufos.harvester,
    total = self.ufos.scout + self.ufos.fighter + self.ufos.harvester,
  }
end

--- Lose UFO from fleet (destroyed in interception)
-- @param ufo_type string - UFO type destroyed
function AlienFaction:destroyUFO(ufo_type)
  if self.ufos[ufo_type] and self.ufos[ufo_type] > 0 then
    self.ufos[ufo_type] = self.ufos[ufo_type] - 1
    self:incrementActivity(-0.5)  -- Slight activity reduction
  end
end

--- Get pending missions count
-- @return number - Queued missions
function AlienFaction:getPendingMissions()
  return #self.mission_queue
end

--- Serialize faction for save/load
-- @return table - Serialized faction data
function AlienFaction:serialize()
  return {
    name = self.name,
    control = self.control,
    threat = self.threat,
    base_activity = self.base_activity,
    activity_from_regions = self.activity_from_regions,
    activity_decay = self.activity_decay,
    last_mission_turn = self.last_mission_turn,
    last_activity_turn = self.last_activity_turn,
    ufos = {
      scout = self.ufos.scout,
      fighter = self.ufos.fighter,
      harvester = self.ufos.harvester,
    },
    mission_queue = self.mission_queue,
    mission_id_counter = self.mission_id_counter,
    terror_campaigns = self.terror_campaigns,
    terror_intensity = self.terror_intensity,
    research_progress = self.research_progress,
  }
end

--- Deserialize faction from save data
-- @param data table - Serialized faction data
-- @return AlienFaction - Restored faction instance
function AlienFaction.deserialize(data)
  local self = setmetatable({}, AlienFaction)

  self.name = data.name
  self.control = data.control
  self.threat = data.threat
  self.base_activity = data.base_activity
  self.activity_from_regions = data.activity_from_regions
  self.activity_decay = data.activity_decay
  self.last_mission_turn = data.last_mission_turn
  self.last_activity_turn = data.last_activity_turn
  self.ufos = data.ufos or { scout = 0, fighter = 0, harvester = 0 }
  self.mission_queue = data.mission_queue or {}
  self.mission_id_counter = data.mission_id_counter or 1000
  self.terror_campaigns = data.terror_campaigns or {}
  self.terror_intensity = data.terror_intensity or 0
  self.research_progress = data.research_progress or 0

  return self
end

return AlienFaction

