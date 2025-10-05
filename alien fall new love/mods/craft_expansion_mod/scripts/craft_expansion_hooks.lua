-- Craft Expansion Mod - Hook Implementation
-- Demonstrates advanced modding capabilities for the craft system

local craft_expansion_hooks = {}

--- Called when a new craft is created
-- Adds mod-specific initialization for advanced craft types
function craft_expansion_hooks.on_craft_created(craft, craft_class)
    -- Add stealth capabilities for stealth bombers
    if craft_class.id == "stealth_bomber" then
        craft.stealth_rating = craft_class.stats.stealth_rating or 10
        craft.stealth_active = false
        print("Stealth Bomber created with stealth rating: " .. craft.stealth_rating)
    end

    -- Add shield system for advanced fighters
    if craft_class.id == "advanced_fighter" then
        craft.shield_capacity = 100
        craft.shield_current = 100
        craft.shield_recharge_rate = 10
        print("Advanced Fighter created with shield system")
    end

    -- Add EMP capability for heavy gunships
    if craft_class.id == "heavy_gunship" then
        craft.emp_charges = 3
        craft.emp_cooldown = 0
        print("Heavy Gunship created with EMP capability")
    end

    -- Add cargo scanning for tactical transports
    if craft_class.id == "tactical_transport" then
        craft.scanner_active = true
        craft.scan_range = 25
        print("Tactical Transport created with cargo scanner")
    end
end

--- Called when craft equipment is changed
-- Validates advanced equipment compatibility
function craft_expansion_hooks.on_equipment_changed(craft, slot, item_id, item_data)
    -- Validate plasma weapon requirements
    if item_data.category == "energy" then
        if not craft.energy_pool or craft.energy_pool.capacity < item_data.stats.energy_consumption then
            print("Warning: Craft lacks sufficient energy capacity for " .. item_data.name)
            return false -- Prevent equipping
        end
    end

    -- Check stealth system compatibility
    if item_id == "stealth_system" and craft.class.type ~= "bomber" then
        print("Warning: Stealth system is only compatible with bomber craft")
        return false
    end

    -- Validate EMP generator requirements
    if item_id == "emp_generator" and not craft.emp_capable then
        print("Warning: Craft is not EMP-capable")
        return false
    end

    print("Equipment change validated: " .. item_data.name .. " equipped on " .. craft.name)
    return true
end

--- Called when a craft completes a mission
-- Awards bonus experience for advanced craft features
function craft_expansion_hooks.on_mission_completed(craft, mission_data, success)
    if not success then return end

    local bonus_exp = 0

    -- Stealth mission bonus
    if craft.stealth_rating and craft.stealth_active then
        bonus_exp = bonus_exp + 25
        print("Stealth bonus experience awarded: +25")
    end

    -- Shield usage bonus
    if craft.shield_capacity and craft.shield_current < craft.shield_capacity then
        local shield_usage = (craft.shield_capacity - craft.shield_current) / craft.shield_capacity
        bonus_exp = bonus_exp + math.floor(shield_usage * 30)
        print("Shield usage bonus experience awarded: +" .. math.floor(shield_usage * 30))
    end

    -- EMP usage bonus
    if craft.emp_charges and craft.emp_charges < 3 then
        local emp_used = 3 - craft.emp_charges
        bonus_exp = bonus_exp + (emp_used * 20)
        print("EMP usage bonus experience awarded: +" .. (emp_used * 20))
    end

    -- Scanner usage bonus for transports
    if craft.scanner_active and mission_data.type == "transport" then
        bonus_exp = bonus_exp + 15
        print("Scanner usage bonus experience awarded: +15")
    end

    if bonus_exp > 0 then
        craft:addExperience(bonus_exp)
        print("Total mission bonus experience: +" .. bonus_exp)
    end
end

--- Called when a craft levels up
-- Handles elite progression features
function craft_expansion_hooks.on_craft_leveled_up(craft, new_level)
    -- Legendary level unlocks
    if new_level == 8 then
        craft.legendary_status = true
        craft.command_capability = true
        print(craft.name .. " has achieved Legendary status!")
    end

    -- Mythical level unlocks
    if new_level == 9 then
        craft.mythical_status = true
        craft.elite_modifications = true
        print(craft.name .. " has achieved Mythical status!")
    end

    -- Transcendent level unlocks
    if new_level == 10 then
        craft.transcendent_status = true
        craft.transcendent_abilities = true
        print(craft.name .. " has achieved Transcendent status!")
    end
end

--- Called when craft specialization changes
function craft_expansion_hooks.on_specialization_changed(craft, specialization)
    print(craft.name .. " specialized as: " .. specialization)

    -- Apply specialization bonuses
    if specialization == "stealth" then
        craft.stealth_rating = (craft.stealth_rating or 0) + 5
    elseif specialization == "assault" then
        craft.damage_modifier = (craft.damage_modifier or 1) + 0.15
    elseif specialization == "transport" then
        craft.cargo_capacity = craft.cargo_capacity * 1.25
    end
end

--- Called when elite modifications are applied
function craft_expansion_hooks.on_elite_modification_applied(craft, modification)
    print("Elite modification applied to " .. craft.name .. ": " .. modification)

    -- Apply modification effects
    if modification == "overclocked_engine" then
        craft.speed_modifier = (craft.speed_modifier or 1) + 0.20
        craft.fuel_consumption_modifier = (craft.fuel_consumption_modifier or 1) + 0.30
    elseif modification == "reinforced_armor" then
        craft.armor_modifier = (craft.armor_modifier or 1) + 0.25
        craft.speed_modifier = (craft.speed_modifier or 1) - 0.10
    elseif modification == "precision_systems" then
        craft.accuracy_modifier = (craft.accuracy_modifier or 1) + 0.30
    end
end

--- Called when transcendent abilities are activated
function craft_expansion_hooks.on_transcendent_ability_activated(craft, ability)
    print("Transcendent ability activated on " .. craft.name .. ": " .. ability)

    -- Apply transcendent effects
    if ability == "phase_shift" then
        craft.intangible = true
        craft.damage_reduction = 0.75
        -- Effect lasts for 30 seconds
    elseif ability == "energy_burst" then
        craft.energy_burst_active = true
        craft.damage_modifier = (craft.damage_modifier or 1) + 0.50
        -- Effect lasts for 60 seconds
    elseif ability == "predictive_algorithms" then
        craft.predictive_active = true
        craft.evasion_modifier = (craft.evasion_modifier or 1) + 0.40
        -- Effect lasts for mission duration
    end
end

return craft_expansion_hooks