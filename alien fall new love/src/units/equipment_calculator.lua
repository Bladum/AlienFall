--- Equipment Calculator
-- Calculates stat modifiers from equipped items
--
-- @module units.equipment_calculator

-- GROK: EquipmentCalculator aggregates stat modifiers from all equipped items
-- GROK: Supports additive and multiplicative modifiers with proper stacking rules
-- GROK: Key methods: calculateModifiers(), applyToStats(), validateEquipment()
-- GROK: Integrates with Unit class for stat calculation and equipment management

local EquipmentCalculator = {}

--- Modifier types
EquipmentCalculator.MODIFIER_ADDITIVE = "additive"
EquipmentCalculator.MODIFIER_MULTIPLICATIVE = "multiplicative"

--- Calculate stat modifiers from equipment
-- @param equipment table: Map of slot -> item
-- @param itemRegistry table: Item data registry (optional, for lookups)
-- @return table: Aggregated modifiers {stat -> {additive, multiplicative}}
function EquipmentCalculator.calculateModifiers(equipment, itemRegistry)
    local modifiers = {}
    
    if not equipment then
        return modifiers
    end
    
    -- Aggregate modifiers from all equipped items
    for slot, itemData in pairs(equipment) do
        if itemData then
            -- Handle item reference vs item data
            local item = itemData
            if type(itemData) == "string" and itemRegistry then
                item = itemRegistry[itemData]
            end
            
            if item then
                -- Process stat bonuses
                if item.stats then
                    for stat, value in pairs(item.stats) do
                        if not modifiers[stat] then
                            modifiers[stat] = {additive = 0, multiplicative = 1.0}
                        end
                        -- Assume stats are additive by default
                        modifiers[stat].additive = modifiers[stat].additive + (value or 0)
                    end
                end
                
                -- Process explicit bonuses
                if item.bonuses then
                    for stat, value in pairs(item.bonuses) do
                        if not modifiers[stat] then
                            modifiers[stat] = {additive = 0, multiplicative = 1.0}
                        end
                        modifiers[stat].additive = modifiers[stat].additive + (value or 0)
                    end
                end
                
                -- Process explicit penalties (negative bonuses)
                if item.penalties then
                    for stat, value in pairs(item.penalties) do
                        if not modifiers[stat] then
                            modifiers[stat] = {additive = 0, multiplicative = 1.0}
                        end
                        modifiers[stat].additive = modifiers[stat].additive - (value or 0)
                    end
                end
                
                -- Process multiplicative modifiers (if item supports them)
                if item.multipliers then
                    for stat, value in pairs(item.multipliers) do
                        if not modifiers[stat] then
                            modifiers[stat] = {additive = 0, multiplicative = 1.0}
                        end
                        modifiers[stat].multiplicative = modifiers[stat].multiplicative * (value or 1.0)
                    end
                end
            end
        end
    end
    
    return modifiers
end

--- Apply modifiers to base stats
-- @param baseStats table: Original stat values
-- @param modifiers table: Modifiers from calculateModifiers()
-- @return table: Modified stats
function EquipmentCalculator.applyToStats(baseStats, modifiers)
    local effectiveStats = {}
    
    -- Copy base stats
    for stat, value in pairs(baseStats) do
        effectiveStats[stat] = value
    end
    
    -- Apply modifiers
    for stat, modifier in pairs(modifiers) do
        local baseValue = baseStats[stat] or 0
        
        -- Apply additive first
        local withAdditive = baseValue + modifier.additive
        
        -- Then apply multiplicative
        effectiveStats[stat] = withAdditive * modifier.multiplicative
        
        -- Clamp to reasonable bounds (0 minimum)
        if effectiveStats[stat] < 0 then
            effectiveStats[stat] = 0
        end
    end
    
    return effectiveStats
end

--- Calculate total equipment weight (encumbrance)
-- @param equipment table: Map of slot -> item
-- @param itemRegistry table: Item data registry (optional)
-- @return number: Total weight
function EquipmentCalculator.calculateWeight(equipment, itemRegistry)
    local totalWeight = 0
    
    if not equipment then
        return totalWeight
    end
    
    for slot, itemData in pairs(equipment) do
        if itemData then
            local item = itemData
            if type(itemData) == "string" and itemRegistry then
                item = itemRegistry[itemData]
            end
            
            if item and item.weight then
                totalWeight = totalWeight + item.weight
            end
        end
    end
    
    return totalWeight
end

--- Validate equipment loadout
-- @param equipment table: Map of slot -> item
-- @param unitClass string: Unit class ID
-- @param restrictions table: Equipment restrictions {allowed_weapons, forbidden_armor, etc}
-- @return boolean: Whether loadout is valid
-- @return string: Error message if invalid
function EquipmentCalculator.validateEquipment(equipment, unitClass, restrictions)
    if not equipment then
        return true, nil
    end
    
    restrictions = restrictions or {}
    
    for slot, itemData in pairs(equipment) do
        if itemData then
            local item = itemData
            
            -- Check slot compatibility
            if item.slot and item.slot ~= slot then
                return false, string.format("Item %s cannot be equipped in slot %s", item.id or "unknown", slot)
            end
            
            -- Check class restrictions
            if restrictions.allowed_weapons and slot == "primary" or slot == "secondary" then
                if item.weapon_category then
                    local allowed = false
                    for _, allowedType in ipairs(restrictions.allowed_weapons) do
                        if item.weapon_category == allowedType then
                            allowed = true
                            break
                        end
                    end
                    if not allowed then
                        return false, string.format("Weapon type %s not allowed for class %s", item.weapon_category, unitClass)
                    end
                end
            end
            
            -- Check forbidden armor
            if restrictions.forbidden_armor and (slot == "armor" or slot == "torso") then
                if item.armor_category then
                    for _, forbiddenType in ipairs(restrictions.forbidden_armor) do
                        if item.armor_category == forbiddenType then
                            return false, string.format("Armor type %s forbidden for class %s", item.armor_category, unitClass)
                        end
                    end
                end
            end
            
            -- Check level requirements
            if item.required_level then
                -- This would need unit level passed in
                -- Placeholder for now
            end
        end
    end
    
    return true, nil
end

--- Get equipment stat summary
-- @param equipment table: Map of slot -> item
-- @param itemRegistry table: Item data registry (optional)
-- @return table: Summary {totalWeight, totalBonuses, totalPenalties}
function EquipmentCalculator.getSummary(equipment, itemRegistry)
    local modifiers = EquipmentCalculator.calculateModifiers(equipment, itemRegistry)
    local weight = EquipmentCalculator.calculateWeight(equipment, itemRegistry)
    
    local totalBonuses = 0
    local totalPenalties = 0
    
    for stat, modifier in pairs(modifiers) do
        if modifier.additive > 0 then
            totalBonuses = totalBonuses + modifier.additive
        elseif modifier.additive < 0 then
            totalPenalties = totalPenalties + math.abs(modifier.additive)
        end
    end
    
    return {
        totalWeight = weight,
        totalBonuses = totalBonuses,
        totalPenalties = totalPenalties,
        modifiers = modifiers
    }
end

--- Calculate equipment maintenance penalty
-- @param equipment table: Map of slot -> item
-- @param itemRegistry table: Item data registry (optional)
-- @return number: Maintenance cost penalty
function EquipmentCalculator.calculateMaintenancePenalty(equipment, itemRegistry)
    local penalty = 0
    
    if not equipment then
        return penalty
    end
    
    for slot, itemData in pairs(equipment) do
        if itemData then
            local item = itemData
            if type(itemData) == "string" and itemRegistry then
                item = itemRegistry[itemData]
            end
            
            if item then
                -- Use item maintenance cost if available
                if item.maintenance_cost then
                    penalty = penalty + item.maintenance_cost
                elseif item.quality then
                    -- Higher quality = higher maintenance
                    penalty = penalty + (item.quality * 2)
                else
                    -- Default maintenance based on slot
                    if slot == "armor" then
                        penalty = penalty + 5
                    elseif slot == "primary" or slot == "secondary" then
                        penalty = penalty + 3
                    elseif slot == "accessory" then
                        penalty = penalty + 1
                    end
                end
            end
        end
    end
    
    return penalty
end

return EquipmentCalculator
