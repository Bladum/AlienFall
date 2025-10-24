-- reference_validator.lua
-- Validates that all entity references point to existing entities
-- Checks: units -> items, research -> techs, etc.

local ReferenceValidator = {}

-- Utility to check if entity exists
local function entityExists(index, entityId, category)
  if not entityId then
    return false
  end
  
  local entry = index.byId[entityId]
  if not entry then
    return false
  end
  
  if category and entry.category ~= category then
    return false
  end
  
  return true
end

-- Utility to add error
local function addError(errors, entityId, file, field, reference, message)
  table.insert(errors, {
    entity = entityId,
    file = file,
    field = field,
    reference = reference,
    message = message,
    severity = "error",
  })
end

-- Validate all references
function ReferenceValidator.validate(mod, index)
  local errors = {}
  
  -- Validate each category
  local refErrors = ReferenceValidator.validateUnits(mod.units, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateItems(mod.items, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateResearch(mod.research, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateManufacturing(mod.manufacturing, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateFacilities(mod.facilities, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateMissions(mod.missions, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateCrafts(mod.crafts, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  refErrors = ReferenceValidator.validateAliens(mod.aliens, index)
  for _, err in ipairs(refErrors) do
    table.insert(errors, err)
  end
  
  return errors
end

-- Validate unit references
function ReferenceValidator.validateUnits(units, index)
  local errors = {}
  
  for unitId, unit in pairs(units) do
    local data = unit.data
    
    if not data then
      goto continue
    end
    
    -- Check race reference
    if data.race and not entityExists(index, data.race) then
      addError(errors, unitId, unit.file, "race", data.race,
        "Unit references non-existent race: " .. tostring(data.race))
    end
    
    -- Check armor reference
    if data.armor and not entityExists(index, data.armor) then
      addError(errors, unitId, unit.file, "armor", data.armor,
        "Unit references non-existent armor: " .. tostring(data.armor))
    end
    
    -- Check required techs
    if data.requires then
      local requires = type(data.requires) == "table" and data.requires or {data.requires}
      for _, techId in ipairs(requires) do
        if techId and not entityExists(index, techId) then
          addError(errors, unitId, unit.file, "requires", techId,
            "Unit requires non-existent tech: " .. tostring(techId))
        end
      end
    end
    
    -- Check starting equipment
    if data.starting_equipment then
      local equipment = type(data.starting_equipment) == "table" and data.starting_equipment or {data.starting_equipment}
      for _, itemId in ipairs(equipment) do
        if itemId and not entityExists(index, itemId) then
          addError(errors, unitId, unit.file, "starting_equipment", itemId,
            "Unit references non-existent item: " .. tostring(itemId))
        end
      end
    end
    
    -- Check default weapon
    if data.default_weapon and not entityExists(index, data.default_weapon) then
      addError(errors, unitId, unit.file, "default_weapon", data.default_weapon,
        "Unit references non-existent weapon: " .. tostring(data.default_weapon))
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate item references
function ReferenceValidator.validateItems(items, index)
  local errors = {}
  
  for itemId, item in pairs(items) do
    local data = item.data
    
    if not data then
      goto continue
    end
    
    -- Check required tech
    if data.requires then
      local requires = type(data.requires) == "table" and data.requires or {data.requires}
      for _, techId in ipairs(requires) do
        if techId and not entityExists(index, techId) then
          addError(errors, itemId, item.file, "requires", techId,
            "Item requires non-existent tech: " .. tostring(techId))
        end
      end
    end
    
    -- Check ammo reference (for weapons)
    if data.ammo and not entityExists(index, data.ammo) then
      addError(errors, itemId, item.file, "ammo", data.ammo,
        "Weapon references non-existent ammo: " .. tostring(data.ammo))
    end
    
    -- Check craft reference (for equipment)
    if data.craft and not entityExists(index, data.craft) then
      addError(errors, itemId, item.file, "craft", data.craft,
        "Item references non-existent craft: " .. tostring(data.craft))
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate research references
function ReferenceValidator.validateResearch(research, index)
  local errors = {}
  
  for researchId, researchData in pairs(research) do
    local data = researchData.data
    
    if not data then
      goto continue
    end
    
    -- Check prerequisites
    if data.requires then
      local requires = type(data.requires) == "table" and data.requires or {data.requires}
      for _, prerequisiteId in ipairs(requires) do
        if prerequisiteId and not entityExists(index, prerequisiteId) then
          addError(errors, researchId, researchData.file, "requires", prerequisiteId,
            "Research requires non-existent tech: " .. tostring(prerequisiteId))
        end
      end
    end
    
    -- Check unlocked items
    if data.unlocks_items then
      local items = type(data.unlocks_items) == "table" and data.unlocks_items or {data.unlocks_items}
      for _, itemId in ipairs(items) do
        if itemId and not entityExists(index, itemId) then
          addError(errors, researchId, researchData.file, "unlocks_items", itemId,
            "Research unlocks non-existent item: " .. tostring(itemId))
        end
      end
    end
    
    -- Check unlocked units
    if data.unlocks_units then
      local units = type(data.unlocks_units) == "table" and data.unlocks_units or {data.unlocks_units}
      for _, unitId in ipairs(units) do
        if unitId and not entityExists(index, unitId) then
          addError(errors, researchId, researchData.file, "unlocks_units", unitId,
            "Research unlocks non-existent unit: " .. tostring(unitId))
        end
      end
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate manufacturing references
function ReferenceValidator.validateManufacturing(manufacturing, index)
  local errors = {}
  
  for manufactureId, manufactureData in pairs(manufacturing) do
    local data = manufactureData.data
    
    if not data then
      goto continue
    end
    
    -- Check produced item
    if data.produces and not entityExists(index, data.produces) then
      addError(errors, manufactureId, manufactureData.file, "produces", data.produces,
        "Manufacturing produces non-existent item: " .. tostring(data.produces))
    end
    
    -- Check required items
    if data.requires_items then
      local items = data.requires_items
      if type(items) == "table" then
        for itemId, quantity in pairs(items) do
          if itemId and not entityExists(index, itemId) then
            addError(errors, manufactureId, manufactureData.file, "requires_items", itemId,
              "Manufacturing requires non-existent item: " .. tostring(itemId))
          end
        end
      end
    end
    
    -- Check required tech
    if data.requires_tech then
      local techs = type(data.requires_tech) == "table" and data.requires_tech or {data.requires_tech}
      for _, techId in ipairs(techs) do
        if techId and not entityExists(index, techId) then
          addError(errors, manufactureId, manufactureData.file, "requires_tech", techId,
            "Manufacturing requires non-existent tech: " .. tostring(techId))
        end
      end
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate facility references
function ReferenceValidator.validateFacilities(facilities, index)
  local errors = {}
  
  for facilityId, facilityData in pairs(facilities) do
    local data = facilityData.data
    
    if not data then
      goto continue
    end
    
    -- Check required tech
    if data.requires_tech then
      local techs = type(data.requires_tech) == "table" and data.requires_tech or {data.requires_tech}
      for _, techId in ipairs(techs) do
        if techId and not entityExists(index, techId) then
          addError(errors, facilityId, facilityData.file, "requires_tech", techId,
            "Facility requires non-existent tech: " .. tostring(techId))
        end
      end
    end
    
    -- Check required items (building materials)
    if data.requires_items then
      local items = data.requires_items
      if type(items) == "table" then
        for itemId, quantity in pairs(items) do
          if itemId and not entityExists(index, itemId) then
            addError(errors, facilityId, facilityData.file, "requires_items", itemId,
              "Facility requires non-existent item: " .. tostring(itemId))
          end
        end
      end
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate mission references
function ReferenceValidator.validateMissions(missions, index)
  local errors = {}
  
  for missionId, missionData in pairs(missions) do
    local data = missionData.data
    
    if not data then
      goto continue
    end
    
    -- Check map reference
    if data.map and not entityExists(index, data.map) then
      addError(errors, missionId, missionData.file, "map", data.map,
        "Mission references non-existent map: " .. tostring(data.map))
    end
    
    -- Check alien units
    if data.alien_units then
      local units = type(data.alien_units) == "table" and data.alien_units or {data.alien_units}
      for _, unitId in ipairs(units) do
        if unitId and not entityExists(index, unitId) then
          addError(errors, missionId, missionData.file, "alien_units", unitId,
            "Mission references non-existent alien unit: " .. tostring(unitId))
        end
      end
    end
    
    -- Check loot items
    if data.loot_items then
      local items = type(data.loot_items) == "table" and data.loot_items or {data.loot_items}
      for _, itemId in ipairs(items) do
        if itemId and not entityExists(index, itemId) then
          addError(errors, missionId, missionData.file, "loot_items", itemId,
            "Mission loot references non-existent item: " .. tostring(itemId))
        end
      end
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate craft references
function ReferenceValidator.validateCrafts(crafts, index)
  local errors = {}
  
  for craftId, craftData in pairs(crafts) do
    local data = craftData.data
    
    if not data then
      goto continue
    end
    
    -- Check weapons
    if data.weapons then
      local weapons = type(data.weapons) == "table" and data.weapons or {data.weapons}
      for _, weaponId in ipairs(weapons) do
        if weaponId and not entityExists(index, weaponId) then
          addError(errors, craftId, craftData.file, "weapons", weaponId,
            "Craft references non-existent weapon: " .. tostring(weaponId))
        end
      end
    end
    
    -- Check equipment
    if data.equipment then
      local items = type(data.equipment) == "table" and data.equipment or {data.equipment}
      for _, itemId in ipairs(items) do
        if itemId and not entityExists(index, itemId) then
          addError(errors, craftId, craftData.file, "equipment", itemId,
            "Craft references non-existent equipment: " .. tostring(itemId))
        end
      end
    end
    
    ::continue::
  end
  
  return errors
end

-- Validate alien references
function ReferenceValidator.validateAliens(aliens, index)
  local errors = {}
  
  for alienId, alienData in pairs(aliens) do
    local data = alienData.data
    
    if not data then
      goto continue
    end
    
    -- Check weapon
    if data.weapon and not entityExists(index, data.weapon) then
      addError(errors, alienId, alienData.file, "weapon", data.weapon,
        "Alien references non-existent weapon: " .. tostring(data.weapon))
    end
    
    -- Check armor
    if data.armor and not entityExists(index, data.armor) then
      addError(errors, alienId, alienData.file, "armor", data.armor,
        "Alien references non-existent armor: " .. tostring(data.armor))
    end
    
    ::continue::
  end
  
  return errors
end

return ReferenceValidator
