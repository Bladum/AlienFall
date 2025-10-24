--- Terror attack system for Geoscape
-- Manages terror attacks on controlled regions with civilian casualty mechanics
-- Coordinates with MissionSystem and RegionController for regional effects
--
-- @module TerrorSystem
-- @author AI Agent
-- @license MIT

local TerrorSystem = {}
TerrorSystem.__index = TerrorSystem

--- Create new terror system
-- @return TerrorSystem - New terror system instance
function TerrorSystem.new()
  local self = setmetatable({}, TerrorSystem)

  self.active_terror_attacks = {}
  self.terror_id_counter = 1
  self.regional_terror_levels = {}  -- region_id -> terror level (0-100)

  return self
end

--- Start terror attack on region
-- Creates 3-7 terror locations within region for players to investigate
-- @param faction string - Attacking faction
-- @param region_id number - Target region
-- @param intensity number - Attack intensity (1-10)
-- @return table - Terror attack data
function TerrorSystem:startTerrorAttack(faction, region_id, intensity)
  local attack_id = self.terror_id_counter
  self.terror_id_counter = self.terror_id_counter + 1

  intensity = math.max(1, math.min(10, intensity))

  -- Generate 3-7 terror locations
  local location_count = math.random(3, 7)
  local locations = {}

  for i = 1, location_count do
    table.insert(locations, {
      id = i,
      x = math.random(1, 100),  -- Placeholder coordinates
      y = math.random(1, 100),
      intensity = math.random(1, intensity),
      active = true,
      civilians_affected = math.random(10, 50),
      civilian_losses = 0,
    })
  end

  -- Create terror attack object
  local attack = {
    id = attack_id,
    faction = faction,
    region_id = region_id,
    locations = locations,
    intensity = intensity,
    morale_impact = 0,
    civilian_losses = 0,
    days_active = 0,
    status = "active",
    created_turn = 0,  -- Will be set by caller
  }

  self.active_terror_attacks[attack_id] = attack

  -- Initialize or update regional terror level
  self.regional_terror_levels[region_id] = (self.regional_terror_levels[region_id] or 0) + (intensity * 5)

  return attack
end

--- Update all active terror attacks (per turn processing)
-- Processes terror effects, escalation, civilian losses
-- @param turn number - Current campaign turn
-- @return table - Terror attacks that escalated/changed this turn
function TerrorSystem:update(turn)
  local escalations = {}
  local attacks_to_remove = {}

  for attack_id, attack in pairs(self.active_terror_attacks) do
    attack.days_active = attack.days_active + 1

    -- Process terror effects per turn
    local morale_loss = attack.intensity * 1  -- -1 to -10 morale per turn
    local civilian_loss_rate = attack.intensity * 5  -- 5-50 civilians per turn

    attack.morale_impact = attack.morale_impact + morale_loss
    attack.civilian_losses = attack.civilian_losses + civilian_loss_rate

    -- Update location civilian losses
    for _, location in ipairs(attack.locations) do
      if location.active then
        local loss = math.floor(location.intensity * civilian_loss_rate / attack.intensity)
        location.civilian_losses = location.civilian_losses + loss
        location.civilians_affected = math.max(0, location.civilians_affected - loss)
      end
    end

    -- Escalation check: +1 intensity per 5 turns if not opposed
    local turns_since_escalation = attack.days_active % 5
    if turns_since_escalation == 0 and attack.intensity < 10 then
      attack.intensity = attack.intensity + 1
      table.insert(escalations, attack)
    end

    -- Update regional terror level
    self.regional_terror_levels[attack.region_id] = (self.regional_terror_levels[attack.region_id] or 0) + (attack.intensity * 2)

    -- Cap at 100
    self.regional_terror_levels[attack.region_id] = math.min(100, self.regional_terror_levels[attack.region_id])
  end

  return escalations
end

--- Complete terror attack
-- Called when player stops all locations in an attack
-- @param attack_id number - Terror attack ID
-- @param status string - "stopped" or "expired"
function TerrorSystem:completeTerrorAttack(attack_id, status)
  local attack = self.active_terror_attacks[attack_id]

  if not attack then
    return nil
  end

  attack.status = status or "stopped"
  attack.completion_turn = 0  -- Will be set by caller

  -- Remove from active
  self.active_terror_attacks[attack_id] = nil

  -- Reduce regional terror level
  if attack.region_id then
    self.regional_terror_levels[attack.region_id] = math.max(0, (self.regional_terror_levels[attack.region_id] or 0) - 20)
  end

  return attack
end

--- Stop individual terror location
-- Called when player completes mission at location
-- @param attack_id number - Terror attack ID
-- @param location_id number - Location within attack
function TerrorSystem:stopTerrorLocation(attack_id, location_id)
  local attack = self.active_terror_attacks[attack_id]

  if not attack then
    return false
  end

  for _, location in ipairs(attack.locations) do
    if location.id == location_id then
      location.active = false

      -- Check if all locations are stopped
      local all_stopped = true
      for _, loc in ipairs(attack.locations) do
        if loc.active then
          all_stopped = false
          break
        end
      end

      -- If all stopped, mark attack complete
      if all_stopped then
        self:completeTerrorAttack(attack_id, "stopped")
      end

      return true
    end
  end

  return false
end

--- Get all terror attacks in region
-- @param region_id number - Region identifier
-- @return table - Array of active terror attacks
function TerrorSystem:getTerrorAttacksInRegion(region_id)
  local attacks = {}

  for _, attack in pairs(self.active_terror_attacks) do
    if attack.region_id == region_id then
      table.insert(attacks, attack)
    end
  end

  return attacks
end

--- Get terror locations in region (all active locations)
-- @param region_id number - Region identifier
-- @return table - Array of locations needing investigation
function TerrorSystem:getTerrorLocations(region_id)
  local locations = {}

  for _, attack in pairs(self.active_terror_attacks) do
    if attack.region_id == region_id then
      for _, location in ipairs(attack.locations) do
        if location.active then
          table.insert(locations, {
            location_id = location.id,
            attack_id = attack.id,
            intensity = location.intensity,
            x = location.x,
            y = location.y,
            civilians_affected = location.civilians_affected,
          })
        end
      end
    end
  end

  return locations
end

--- Get regional terror level (0-100)
-- @param region_id number - Region identifier
-- @return number - Terror index (0-100)
function TerrorSystem:getRegionalTerrorLevel(region_id)
  local level = self.regional_terror_levels[region_id] or 0
  return math.max(0, math.min(100, level))
end

--- Get terror level description
-- @param region_id number - Region identifier
-- @return string - Human-readable terror description
function TerrorSystem:getTerrorDescription(region_id)
  local level = self:getRegionalTerrorLevel(region_id)

  if level == 0 then
    return "Safe"
  elseif level < 20 then
    return "Minor Incidents"
  elseif level < 40 then
    return "Active Terror"
  elseif level < 60 then
    return "Widespread Fear"
  elseif level < 80 then
    return "Critical Terror"
  else
    return "Catastrophic Invasion"
  end
end

--- Get total active terror attacks
-- @return number - Count of active attacks
function TerrorSystem:getActiveAttackCount()
  local count = 0
  for _ in pairs(self.active_terror_attacks) do
    count = count + 1
  end
  return count
end

--- Get total active terror locations
-- @return number - Count of locations needing investigation
function TerrorSystem:getActiveTerrorLocationCount()
  local count = 0
  for _, attack in pairs(self.active_terror_attacks) do
    for _, location in ipairs(attack.locations) do
      if location.active then
        count = count + 1
      end
    end
  end
  return count
end

--- Get terror statistics
-- @return table - Stats on active attacks and casualties
function TerrorSystem:getStatistics()
  local active_attacks = self:getActiveAttackCount()
  local active_locations = self:getActiveTerrorLocationCount()
  local total_casualties = 0

  for _, attack in pairs(self.active_terror_attacks) do
    total_casualties = total_casualties + attack.civilian_losses
  end

  return {
    active_attacks = active_attacks,
    active_locations = active_locations,
    total_civilian_losses = total_casualties,
  }
end

--- Serialize terror system for save/load
-- @return table - Serialized state
function TerrorSystem:serialize()
  local active_array = {}
  for _, attack in pairs(self.active_terror_attacks) do
    table.insert(active_array, attack)
  end

  return {
    active_terror_attacks = active_array,
    terror_id_counter = self.terror_id_counter,
    regional_terror_levels = self.regional_terror_levels,
  }
end

--- Deserialize terror system from save data
-- @param data table - Serialized state
-- @return TerrorSystem - Restored system
function TerrorSystem.deserialize(data)
  local self = setmetatable({}, TerrorSystem)

  self.active_terror_attacks = {}
  for _, attack in ipairs(data.active_terror_attacks or {}) do
    self.active_terror_attacks[attack.id] = attack
  end

  self.terror_id_counter = data.terror_id_counter or 1
  self.regional_terror_levels = data.regional_terror_levels or {}

  return self
end

return TerrorSystem
