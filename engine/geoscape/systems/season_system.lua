--- Season system for applying seasonal effects to gameplay
-- Modifies mission frequency, alien activity, resources, morale based on season
--
-- @module SeasonSystem
-- @author AI Agent
-- @license MIT

local SeasonSystem = {}
SeasonSystem.__index = SeasonSystem

--- Seasonal modifiers by season and effect type
local SEASONAL_MODIFIERS = {
  Winter = {
    resources = 0.70,           -- -30% resources
    mission_frequency = 0.80,   -- -20% missions
    alien_activity = 0.90,      -- -10% alien aggression
    morale = 0.95,              -- -5% morale
    research_speed = 1.10,      -- +10% research
  },
  Spring = {
    resources = 1.10,           -- +10% resources
    mission_frequency = 1.00,   -- Normal missions
    alien_activity = 1.20,      -- +20% alien aggression (awakening)
    morale = 1.10,              -- +10% morale
    research_speed = 1.00,      -- Normal research
  },
  Summer = {
    resources = 1.30,           -- +30% resources (peak)
    mission_frequency = 1.30,   -- +30% missions
    alien_activity = 1.30,      -- +30% alien aggression
    morale = 1.20,              -- +20% morale
    research_speed = 0.90,      -- -10% research (heat)
  },
  Autumn = {
    resources = 1.15,           -- +15% resources (harvest)
    mission_frequency = 1.10,   -- +10% missions
    alien_activity = 1.05,      -- +5% alien activity
    morale = 1.00,              -- Normal morale
    research_speed = 1.00,      -- Normal research
  },
}

--- Create new season system
-- @return SeasonSystem - New season system instance
function SeasonSystem.new()
  local self = setmetatable({}, SeasonSystem)

  self.region_seasonal_modifiers = {}
  self.global_mission_modifier = 1.0
  self.global_alien_activity_modifier = 1.0

  return self
end

--- Get seasonal modifier for effect type
-- @param season string - Season name ("Winter", "Spring", "Summer", "Autumn")
-- @param effect_type string - Effect type (resources, mission_frequency, etc.)
-- @return number - Modifier (0.5-1.5 typical range)
function SeasonSystem:getSeasonalModifier(season, effect_type)
  season = season or "Spring"
  effect_type = effect_type or "resources"

  if SEASONAL_MODIFIERS[season] then
    return SEASONAL_MODIFIERS[season][effect_type] or 1.0
  end

  return 1.0
end

--- Apply seasonal effects to regions
-- Updates regional properties based on current season
-- @param turn number - Current turn
-- @param calendar table - Calendar object
-- @param regions table - RegionController or array of regions
function SeasonSystem:applySeasonalEffects(turn, calendar, regions)
  if not calendar then
    return
  end

  local season = calendar:getSeasonName()

  -- Update global modifiers
  self.global_mission_modifier = self:getSeasonalModifier(season, "mission_frequency")
  self.global_alien_activity_modifier = self:getSeasonalModifier(season, "alien_activity")

  -- Apply regional effects if regions provided
  if regions and regions.regions then
    -- Assuming RegionController structure with regions array
    for region_id, region in pairs(regions.regions) do
      if region then
        -- Apply resource modifier
        local resource_mod = self:getSeasonalModifier(season, "resources")
        region.seasonal_resource_modifier = resource_mod

        -- Apply morale modifier
        local morale_mod = self:getSeasonalModifier(season, "morale")
        region.seasonal_morale_modifier = morale_mod
      end
    end
  end
end

--- Get mission frequency modifier for season
-- @param season string - Season name
-- @return number - Frequency multiplier
function SeasonSystem:getMissionFrequencyModifier(season)
  return self:getSeasonalModifier(season, "mission_frequency")
end

--- Get alien activity modifier for season
-- @param season string - Season name
-- @return number - Activity multiplier
function SeasonSystem:getAlienActivityModifier(season)
  return self:getSeasonalModifier(season, "alien_activity")
end

--- Get resources modifier for season
-- @param season string - Season name
-- @return number - Resource multiplier
function SeasonSystem:getResourcesModifier(season)
  return self:getSeasonalModifier(season, "resources")
end

--- Get morale modifier for season
-- @param season string - Season name
-- @return number - Morale multiplier
function SeasonSystem:getMoraleModifier(season)
  return self:getSeasonalModifier(season, "morale")
end

--- Get research speed modifier for season
-- @param season string - Season name
-- @return number - Research speed multiplier
function SeasonSystem:getResearchSpeedModifier(season)
  return self:getSeasonalModifier(season, "research_speed")
end

--- Get seasonal description for player feedback
-- @param season string - Season name
-- @return string - Description of season
function SeasonSystem:getSeasonalDescription(season)
  local descriptions = {
    Winter = "Winter (Cold, Dark) - Resources depleted, research accelerated",
    Spring = "Spring (Awakening) - Moderate resources, aliens becoming active",
    Summer = "Summer (Peak) - Resources abundant, intense alien activity",
    Autumn = "Autumn (Harvest) - Strong resources, increasing alien pressure",
  }

  return descriptions[season] or "Unknown season"
end

--- Get all seasonal modifiers for a season
-- @param season string - Season name
-- @return table - All modifiers for season
function SeasonSystem:getAllModifiers(season)
  return SEASONAL_MODIFIERS[season] or SEASONAL_MODIFIERS.Spring
end

--- Calculate effective modifier after season ends
-- Smooths transitions between seasons
-- @param season string - Current season
-- @param days_until_change number - Days until season changes (0-90)
-- @param next_season string - Next season name
-- @param effect_type string - Effect type
-- @return number - Blended modifier
function SeasonSystem:getTransitionModifier(season, days_until_change, next_season, effect_type)
  days_until_change = math.max(0, math.min(90, days_until_change or 0))

  local transition_factor = days_until_change / 90  -- 0 = now, 1 = 90 days
  local current_mod = self:getSeasonalModifier(season, effect_type)
  local next_mod = self:getSeasonalModifier(next_season, effect_type)

  return current_mod + (next_mod - current_mod) * (1 - transition_factor)
end

--- Get quarter-based scaling for longer-term trends
-- Multiplies with seasonal effects for campaign arc
-- @param quarter number - Quarter (1-4)
-- @return number - Quarter multiplier
function SeasonSystem:getQuarterEscalation(quarter)
  -- Year 1 Q1 = 1.0, escalates to Q4 Year 2 = 2.0
  -- Simulates gradually increasing alien threat
  local escalation = {
    [1] = 1.0,    -- Q1
    [2] = 1.15,   -- Q2
    [3] = 1.3,    -- Q3
    [4] = 1.45,   -- Q4
  }

  return escalation[quarter] or 1.0
end

--- Serialize season system for save/load
-- @return table - Serialized state
function SeasonSystem:serialize()
  return {
    region_seasonal_modifiers = self.region_seasonal_modifiers,
    global_mission_modifier = self.global_mission_modifier,
    global_alien_activity_modifier = self.global_alien_activity_modifier,
  }
end

--- Deserialize season system from save data
-- @param data table - Serialized state
-- @return SeasonSystem - Restored system
function SeasonSystem.deserialize(data)
  local self = setmetatable({}, SeasonSystem)

  self.region_seasonal_modifiers = data.region_seasonal_modifiers or {}
  self.global_mission_modifier = data.global_mission_modifier or 1.0
  self.global_alien_activity_modifier = data.global_alien_activity_modifier or 1.0

  return self
end

return SeasonSystem
