-- balance_validator.lua
-- Sanity checks for suspicious/unbalanced values
-- Checks: zero health, zero damage, extreme values, etc.

local BalanceValidator = {}

-- Add warning
local function addWarning(warnings, entityId, file, field, value, message)
  table.insert(warnings, {
    entity = entityId,
    file = file,
    field = field,
    value = value,
    message = message,
    severity = "warning",
  })
end

-- Validate all entities for balance issues
function BalanceValidator.validate(mod)
  local warnings = {}
  
  -- Check units
  if mod.units then
    local unitWarnings = BalanceValidator.validateUnits(mod.units)
    for _, warning in ipairs(unitWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  -- Check items
  if mod.items then
    local itemWarnings = BalanceValidator.validateItems(mod.items)
    for _, warning in ipairs(itemWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  -- Check weapons (if separate category)
  if mod.weapons then
    local weaponWarnings = BalanceValidator.validateWeapons(mod.weapons)
    for _, warning in ipairs(weaponWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  -- Check research
  if mod.research then
    local researchWarnings = BalanceValidator.validateResearch(mod.research)
    for _, warning in ipairs(researchWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  -- Check manufacturing
  if mod.manufacturing then
    local manufWarnings = BalanceValidator.validateManufacturing(mod.manufacturing)
    for _, warning in ipairs(manufWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  -- Check facilities
  if mod.facilities then
    local facilityWarnings = BalanceValidator.validateFacilities(mod.facilities)
    for _, warning in ipairs(facilityWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  -- Check crafts
  if mod.crafts then
    local craftWarnings = BalanceValidator.validateCrafts(mod.crafts)
    for _, warning in ipairs(craftWarnings) do
      table.insert(warnings, warning)
    end
  end
  
  return warnings
end

-- Validate units
function BalanceValidator.validateUnits(units)
  local warnings = {}
  
  for unitId, unit in pairs(units) do
    local data = unit.data
    if not data then goto continue end
    
    -- Check health
    if data.health then
      if data.health <= 0 then
        addWarning(warnings, unitId, unit.file, "health", data.health,
          "Unit has zero or negative health - will always die instantly")
      elseif data.health > 999 then
        addWarning(warnings, unitId, unit.file, "health", data.health,
          "Unit health suspiciously high (>999)")
      end
    end
    
    -- Check stats object
    if data.stats then
      local stats = data.stats
      
      -- Health in stats
      if stats.health and stats.health <= 0 then
        addWarning(warnings, unitId, unit.file, "stats.health", stats.health,
          "Unit has zero or negative health")
      end
      
      -- Time units
      if stats.time_units and stats.time_units <= 0 then
        addWarning(warnings, unitId, unit.file, "stats.time_units", stats.time_units,
          "Unit has zero or negative time units")
      elseif stats.time_units and stats.time_units > 200 then
        addWarning(warnings, unitId, unit.file, "stats.time_units", stats.time_units,
          "Unit time units suspiciously high (>200)")
      end
      
      -- Accuracy
      if stats.accuracy and (stats.accuracy < 0 or stats.accuracy > 100) then
        addWarning(warnings, unitId, unit.file, "stats.accuracy", stats.accuracy,
          "Unit accuracy out of typical range (0-100)")
      end
      
      -- Armor/defense
      if stats.armor and stats.armor < 0 then
        addWarning(warnings, unitId, unit.file, "stats.armor", stats.armor,
          "Unit armor is negative")
      end
    end
    
    -- Check cost
    if data.cost and data.cost < 0 then
      addWarning(warnings, unitId, unit.file, "cost", data.cost,
        "Unit cost is negative")
    end
    
    ::continue::
  end
  
  return warnings
end

-- Validate items
function BalanceValidator.validateItems(items)
  local warnings = {}
  
  for itemId, item in pairs(items) do
    local data = item.data
    if not data then goto continue end
    
    -- Cost checks
    if data.cost == 0 then
      addWarning(warnings, itemId, item.file, "cost", 0,
        "Item has zero cost (free - intentional?)")
    elseif data.cost and data.cost < 0 then
      addWarning(warnings, itemId, item.file, "cost", data.cost,
        "Item has negative cost")
    end
    
    -- Weight checks
    if data.weight and data.weight < 0 then
      addWarning(warnings, itemId, item.file, "weight", data.weight,
        "Item has negative weight")
    elseif data.weight == 0 then
      addWarning(warnings, itemId, item.file, "weight", 0,
        "Item has zero weight (weightless)")
    end
    
    -- Damage checks (for weapons)
    if data.type == "weapon" or data.damage then
      if data.damage == 0 then
        addWarning(warnings, itemId, item.file, "damage", 0,
          "Weapon has zero damage - useless")
      elseif data.damage and data.damage < 0 then
        addWarning(warnings, itemId, item.file, "damage", data.damage,
          "Weapon has negative damage")
      elseif data.damage and data.damage > 999 then
        addWarning(warnings, itemId, item.file, "damage", data.damage,
          "Weapon damage suspiciously high (>999)")
      end
    end
    
    -- Ammunition checks
    if data.ammo_capacity == 0 then
      addWarning(warnings, itemId, item.file, "ammo_capacity", 0,
        "Item has zero ammo capacity")
    elseif data.ammo_capacity and data.ammo_capacity < 0 then
      addWarning(warnings, itemId, item.file, "ammo_capacity", data.ammo_capacity,
        "Item has negative ammo capacity")
    end
    
    -- Fire rate
    if data.fire_rate == 0 then
      addWarning(warnings, itemId, item.file, "fire_rate", 0,
        "Weapon has zero fire rate (can't shoot)")
    elseif data.fire_rate and data.fire_rate < 0 then
      addWarning(warnings, itemId, item.file, "fire_rate", data.fire_rate,
        "Weapon has negative fire rate")
    end
    
    ::continue::
  end
  
  return warnings
end

-- Validate weapons
function BalanceValidator.validateWeapons(weapons)
  local warnings = {}
  
  for weaponId, weapon in pairs(weapons) do
    local data = weapon.data
    if not data then goto continue end
    
    -- Damage
    if data.damage == 0 then
      addWarning(warnings, weaponId, weapon.file, "damage", 0,
        "Weapon has zero damage")
    elseif data.damage and data.damage < 0 then
      addWarning(warnings, weaponId, weapon.file, "damage", data.damage,
        "Weapon has negative damage")
    end
    
    -- Fire rate
    if data.fire_rate == 0 then
      addWarning(warnings, weaponId, weapon.file, "fire_rate", 0,
        "Weapon has zero fire rate (can't shoot)")
    elseif data.fire_rate and data.fire_rate < 0 then
      addWarning(warnings, weaponId, weapon.file, "fire_rate", data.fire_rate,
        "Weapon has negative fire rate")
    end
    
    -- Cost
    if data.cost and data.cost < 0 then
      addWarning(warnings, weaponId, weapon.file, "cost", data.cost,
        "Weapon cost is negative")
    end
    
    -- Ammo capacity
    if data.ammo_capacity == 0 then
      addWarning(warnings, weaponId, weapon.file, "ammo_capacity", 0,
        "Weapon has zero ammo capacity")
    end
    
    -- Accuracy range
    if data.accuracy and (data.accuracy < 0 or data.accuracy > 100) then
      addWarning(warnings, weaponId, weapon.file, "accuracy", data.accuracy,
        "Weapon accuracy out of typical range (0-100)")
    end
    
    ::continue::
  end
  
  return warnings
end

-- Validate research
function BalanceValidator.validateResearch(research)
  local warnings = {}
  
  for researchId, researchData in pairs(research) do
    local data = researchData.data
    if not data then goto continue end
    
    -- Time
    if data.time == 0 then
      addWarning(warnings, researchId, researchData.file, "time", 0,
        "Research has zero time (instant research)")
    elseif data.time and data.time < 0 then
      addWarning(warnings, researchId, researchData.file, "time", data.time,
        "Research time is negative")
    end
    
    -- Cost
    if data.cost == 0 then
      addWarning(warnings, researchId, researchData.file, "cost", 0,
        "Research has zero cost (free research)")
    elseif data.cost and data.cost < 0 then
      addWarning(warnings, researchId, researchData.file, "cost", data.cost,
        "Research cost is negative")
    end
    
    ::continue::
  end
  
  return warnings
end

-- Validate manufacturing
function BalanceValidator.validateManufacturing(manufacturing)
  local warnings = {}
  
  for manufId, manufData in pairs(manufacturing) do
    local data = manufData.data
    if not data then goto continue end
    
    -- Time
    if data.time == 0 then
      addWarning(warnings, manufId, manufData.file, "time", 0,
        "Manufacturing has zero time (instant production)")
    elseif data.time and data.time < 0 then
      addWarning(warnings, manufId, manufData.file, "time", data.time,
        "Manufacturing time is negative")
    end
    
    -- Cost
    if data.cost and data.cost < 0 then
      addWarning(warnings, manufId, manufData.file, "cost", data.cost,
        "Manufacturing cost is negative")
    end
    
    ::continue::
  end
  
  return warnings
end

-- Validate facilities
function BalanceValidator.validateFacilities(facilities)
  local warnings = {}
  
  for facilityId, facilityData in pairs(facilities) do
    local data = facilityData.data
    if not data then goto continue end
    
    -- Build time
    if data.build_time and data.build_time < 0 then
      addWarning(warnings, facilityId, facilityData.file, "build_time", data.build_time,
        "Facility build time is negative")
    end
    
    -- Build cost
    if data.build_cost and data.build_cost < 0 then
      addWarning(warnings, facilityId, facilityData.file, "build_cost", data.build_cost,
        "Facility build cost is negative")
    end
    
    -- Maintenance
    if data.maintenance_cost and data.maintenance_cost < 0 then
      addWarning(warnings, facilityId, facilityData.file, "maintenance_cost", data.maintenance_cost,
        "Facility maintenance cost is negative")
    end
    
    ::continue::
  end
  
  return warnings
end

-- Validate crafts
function BalanceValidator.validateCrafts(crafts)
  local warnings = {}
  
  for craftId, craftData in pairs(crafts) do
    local data = craftData.data
    if not data then goto continue end
    
    -- Fuel capacity
    if data.fuel_capacity and data.fuel_capacity <= 0 then
      addWarning(warnings, craftId, craftData.file, "fuel_capacity", data.fuel_capacity,
        "Craft fuel capacity is zero or negative")
    end
    
    -- Weapons capacity
    if data.weapons_capacity and data.weapons_capacity <= 0 then
      addWarning(warnings, craftId, craftData.file, "weapons_capacity", data.weapons_capacity,
        "Craft weapons capacity is zero or negative")
    end
    
    -- Cargo capacity
    if data.cargo_capacity and data.cargo_capacity < 0 then
      addWarning(warnings, craftId, craftData.file, "cargo_capacity", data.cargo_capacity,
        "Craft cargo capacity is negative")
    end
    
    -- Crew capacity
    if data.crew_capacity and data.crew_capacity <= 0 then
      addWarning(warnings, craftId, craftData.file, "crew_capacity", data.crew_capacity,
        "Craft crew capacity is zero or negative")
    end
    
    ::continue::
  end
  
  return warnings
end

return BalanceValidator
