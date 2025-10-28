---Equipment Loadout Management System
---
---Provides preset equipment configurations for units with save/load functionality,
---loadout templates, quick-swap during deployment, and validation. Enables efficient
---squad preparation without manual equipment assignment each mission.
---
---Loadout Features:
---  - Save/load presets (up to 5 per unit)
---  - Pre-defined templates (Heavy Assault, Sniper Support, Medic, etc.)
---  - Quick-swap during deployment phase
---  - Weight and slot validation
---  - Named loadout organization
---  - Loadout recommendations based on mission type
---
---Loadout Structure:
---  - Name, description, category
---  - Weapon slots (primary, secondary)
---  - Armor slot
---  - Belt slots (4 items)
---  - Backpack slots (configurable)
---  - Total weight calculation
---
---Key Exports:
---  - LoadoutSystem.new(): Creates system
---  - createLoadout(name, items): Creates loadout
---  - saveLoadout(unitId, slot, loadout): Saves loadout
---  - loadLoadout(unitId, slot): Loads loadout
---  - getTemplateLoadout(template): Gets predefined template
---  - validateLoadout(loadout, unit): Checks weight/slots
---
---Dependencies:
---  - battlescape.systems.inventory_system: Item slots and weight
---  - battlescape.entities.items: Item definitions
---
---@module battlescape.systems.loadout_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local LoadoutSystem = require("engine.battlescape.systems.loadout_system")
---  local system = LoadoutSystem.new()
---  local medic = system:getTemplateLoadout("MEDIC")
---  system:saveLoadout(unitId, 1, medic)
---  system:loadLoadout(unitId, 1)

local LoadoutSystem = {}
LoadoutSystem.__index = LoadoutSystem

--- Create new loadout system
-- @return table New LoadoutSystem instance
function LoadoutSystem.new()
    local self = setmetatable({}, LoadoutSystem)

    self.loadouts = {}         -- All saved loadouts: unitId -> {slot -> loadout}
    self.templates = {}        -- Predefined templates

    -- Initialize templates
    self:_initializeTemplates()

    print("[LoadoutSystem] Initialized equipment loadout system")

    return self
end

--- Initialize predefined loadout templates
function LoadoutSystem:_initializeTemplates()
    self.templates = {
        -- Medic: Light armor, healing items, utility focus
        MEDIC = {
            name = "Medic",
            description = "Support role with medical supplies",
            category = "SUPPORT",
            items = {
                primary = {id = "pistol", name = "Pistol"},
                secondary = nil,
                armor = {id = "light_armor", name = "Light Armor"},
                belt = {
                    {id = "medkit_standard", name = "Medical Kit"},
                    {id = "stim_pack", name = "Stimulant Pack"},
                    {id = "medkit_standard", name = "Medical Kit"},
                    {id = "ammo_pistol", name = "Pistol Ammo"},
                }
            }
        },

        -- Heavy Assault: Heavy armor, assault rifle, close range
        HEAVY_ASSAULT = {
            name = "Heavy Assault",
            description = "Frontline combat role",
            category = "ASSAULT",
            items = {
                primary = {id = "assault_rifle", name = "Assault Rifle"},
                secondary = {id = "shotgun", name = "Shotgun"},
                armor = {id = "heavy_armor", name = "Heavy Armor"},
                belt = {
                    {id = "ammo_rifle", name = "Rifle Ammo"},
                    {id = "ammo_shotgun", name = "Shotgun Ammo"},
                    {id = "frag_grenade", name = "Frag Grenade"},
                    {id = "frag_grenade", name = "Frag Grenade"},
                }
            }
        },

        -- Sniper Support: Light armor, sniper rifle, precision focus
        SNIPER_SUPPORT = {
            name = "Sniper Support",
            description = "Precision and cover fire",
            category = "SPECIALIST",
            items = {
                primary = {id = "sniper_rifle", name = "Sniper Rifle"},
                secondary = {id = "pistol", name = "Pistol"},
                armor = {id = "medium_armor", name = "Medium Armor"},
                belt = {
                    {id = "ammo_sniper", name = "Sniper Ammo"},
                    {id = "ammo_pistol", name = "Pistol Ammo"},
                    {id = "smoke_grenade", name = "Smoke Grenade"},
                    {id = "smoke_grenade", name = "Smoke Grenade"},
                }
            }
        },

        -- Scout: Very light armor, SMG, mobility focus
        SCOUT = {
            name = "Scout",
            description = "Reconnaissance and mobility",
            category = "SCOUT",
            items = {
                primary = {id = "smg", name = "Submachine Gun"},
                secondary = {id = "knife", name = "Combat Knife"},
                armor = {id = "light_armor", name = "Light Armor"},
                belt = {
                    {id = "ammo_smg", name = "SMG Ammo"},
                    {id = "flashbang", name = "Flashbang"},
                    {id = "medkit_field", name = "Field Medkit"},
                    {id = "smoke_grenade", name = "Smoke Grenade"},
                }
            }
        },

        -- Tank: Heavy armor, machine gun, defensive
        TANK = {
            name = "Tank",
            description = "Heavy defensive role",
            category = "DEFENSE",
            items = {
                primary = {id = "machine_gun", name = "Machine Gun"},
                secondary = nil,
                armor = {id = "heavy_armor", name = "Heavy Armor"},
                belt = {
                    {id = "ammo_mg", name = "Machine Gun Ammo"},
                    {id = "ammo_mg", name = "Machine Gun Ammo"},
                    {id = "repair_kit", name = "Repair Kit"},
                    {id = "shield_generator", name = "Shield Generator"},
                }
            }
        },

        -- Balanced: Medium armor, rifle, versatile
        BALANCED = {
            name = "Balanced",
            description = "Versatile all-purpose loadout",
            category = "STANDARD",
            items = {
                primary = {id = "rifle", name = "Rifle"},
                secondary = {id = "pistol", name = "Pistol"},
                armor = {id = "medium_armor", name = "Medium Armor"},
                belt = {
                    {id = "ammo_rifle", name = "Rifle Ammo"},
                    {id = "frag_grenade", name = "Frag Grenade"},
                    {id = "medkit_field", name = "Field Medkit"},
                    {id = "ammo_pistol", name = "Pistol Ammo"},
                }
            }
        },
    }
end

--- Create new loadout
-- @param name string Loadout name
-- @param description string Optional description
-- @param items table Item configuration
-- @return table New loadout
function LoadoutSystem:createLoadout(name, description, items)
    local loadout = {
        name = name,
        description = description or "",
        createdAt = os.time(),
        items = items or {
            primary = nil,
            secondary = nil,
            armor = nil,
            belt = {},
            backpack = {},
        },
        totalWeight = 0,
    }

    -- Calculate total weight
    self:_calculateLoadoutWeight(loadout)

    print(string.format("[LoadoutSystem] Created loadout '%s' (weight: %.1f kg)", name, loadout.totalWeight))

    return loadout
end

--- Calculate total weight of loadout
-- @param loadout table Loadout to calculate
function LoadoutSystem:_calculateLoadoutWeight(loadout)
    local weight = 0

    -- Item weights (placeholder values - integrate with real item system)
    local itemWeights = {
        pistol = 1.2,
        rifle = 3.5,
        assault_rifle = 4.0,
        sniper_rifle = 5.0,
        shotgun = 4.5,
        smg = 2.8,
        machine_gun = 10.0,
        knife = 0.5,

        light_armor = 5.0,
        medium_armor = 8.0,
        heavy_armor = 12.0,

        ammo_pistol = 0.5,
        ammo_rifle = 0.8,
        ammo_sniper = 1.0,
        ammo_smg = 0.6,
        ammo_mg = 2.0,
        ammo_shotgun = 0.9,

        medkit_standard = 3.0,
        medkit_field = 1.5,
        stim_pack = 0.5,
        frag_grenade = 0.6,
        smoke_grenade = 0.5,
        flashbang = 0.5,
        repair_kit = 2.0,
        shield_generator = 2.5,
    }

    -- Calculate weight from items
    if loadout.items.primary then
        weight = weight + (itemWeights[loadout.items.primary.id] or 1.0)
    end
    if loadout.items.secondary then
        weight = weight + (itemWeights[loadout.items.secondary.id] or 1.0)
    end
    if loadout.items.armor then
        weight = weight + (itemWeights[loadout.items.armor.id] or 1.0)
    end

    for _, item in ipairs(loadout.items.belt or {}) do
        weight = weight + (itemWeights[item.id] or 0.5)
    end

    for _, item in ipairs(loadout.items.backpack or {}) do
        weight = weight + (itemWeights[item.id] or 0.5)
    end

    loadout.totalWeight = weight
end

--- Save loadout to unit slot
-- @param unitId string Unit ID
-- @param slot number Loadout slot (1-5)
-- @param loadout table Loadout to save
-- @return boolean Success
function LoadoutSystem:saveLoadout(unitId, slot, loadout)
    if slot < 1 or slot > 5 then
        print(string.format("[LoadoutSystem] ERROR: Invalid slot %d (must be 1-5)", slot))
        return false
    end

    if not self.loadouts[unitId] then
        self.loadouts[unitId] = {}
    end

    -- Save with metadata
    self.loadouts[unitId][slot] = {
        name = loadout.name,
        description = loadout.description,
        items = loadout.items,
        totalWeight = loadout.totalWeight,
        savedAt = os.time(),
    }

    print(string.format("[LoadoutSystem] Saved loadout '%s' to unit %s slot %d",
          loadout.name, unitId, slot))

    return true
end

--- Load loadout from unit slot
-- @param unitId string Unit ID
-- @param slot number Loadout slot (1-5)
-- @return table Loadout or nil
function LoadoutSystem:loadLoadout(unitId, slot)
    if slot < 1 or slot > 5 then
        print(string.format("[LoadoutSystem] ERROR: Invalid slot %d (must be 1-5)", slot))
        return nil
    end

    local unitLoadouts = self.loadouts[unitId]
    if not unitLoadouts then
        print(string.format("[LoadoutSystem] No loadouts saved for unit %s", unitId))
        return nil
    end

    local loadout = unitLoadouts[slot]
    if not loadout then
        print(string.format("[LoadoutSystem] No loadout in slot %d for unit %s", slot, unitId))
        return nil
    end

    print(string.format("[LoadoutSystem] Loaded loadout '%s' from unit %s slot %d",
          loadout.name, unitId, slot))

    return loadout
end

--- Get predefined template loadout
-- @param template string Template name (MEDIC, HEAVY_ASSAULT, etc.)
-- @return table Template loadout or nil
function LoadoutSystem:getTemplateLoadout(template)
    local templateData = self.templates[template]

    if not templateData then
        print(string.format("[LoadoutSystem] ERROR: Unknown template: %s", template))
        return nil
    end

    -- Create new loadout from template
    local loadout = self:createLoadout(templateData.name, templateData.description, templateData.items)

    return loadout
end

--- Get all available templates
-- @return table Array of template names
function LoadoutSystem:getAvailableTemplates()
    local templates = {}
    for name, _ in pairs(self.templates) do
        table.insert(templates, name)
    end
    return templates
end

--- Validate loadout against unit constraints
-- @param loadout table Loadout to validate
-- @param unit table Unit entity
-- @return boolean Valid, string error message or nil
function LoadoutSystem:validateLoadout(loadout, unit)
    if not loadout then
        return false, "Loadout is nil"
    end

    if not unit then
        return false, "Unit is nil"
    end

    -- Check weight capacity (base 30kg + strength × 2)
    local maxWeight = 30 + (unit.strength or 50) * 0.04  -- ~2-3 kg per strength

    if loadout.totalWeight > maxWeight * 1.5 then
        return false, string.format("Loadout too heavy: %.1f kg (max %.1f kg)",
                loadout.totalWeight, maxWeight * 1.5)
    end

    -- Check weapon slots
    if loadout.items.primary and not self:_isValidWeapon(loadout.items.primary) then
        return false, "Invalid primary weapon"
    end

    if loadout.items.secondary and not self:_isValidWeapon(loadout.items.secondary) then
        return false, "Invalid secondary weapon"
    end

    -- Check armor
    if loadout.items.armor and not self:_isValidArmor(loadout.items.armor) then
        return false, "Invalid armor"
    end

    -- Check belt capacity (max 4)
    if #(loadout.items.belt or {}) > 4 then
        return false, string.format("Too many belt items: %d (max 4)", #loadout.items.belt)
    end

    return true, nil
end

--- Check if item is valid weapon
-- @param item table Item to check
-- @return boolean Valid
function LoadoutSystem:_isValidWeapon(item)
    local validWeapons = {
        pistol = true, rifle = true, assault_rifle = true, sniper_rifle = true,
        shotgun = true, smg = true, machine_gun = true, knife = true,
    }
    return validWeapons[item.id] or false
end

--- Check if item is valid armor
-- @param item table Item to check
-- @return boolean Valid
function LoadoutSystem:_isValidArmor(item)
    local validArmor = {
        light_armor = true, medium_armor = true, heavy_armor = true,
    }
    return validArmor[item.id] or false
end

--- Get saved loadouts for unit
-- @param unitId string Unit ID
-- @return table Array of {slot, name, description, weight}
function LoadoutSystem:getSavedLoadouts(unitId)
    local saved = {}
    local unitLoadouts = self.loadouts[unitId] or {}

    for slot = 1, 5 do
        local loadout = unitLoadouts[slot]
        if loadout then
            table.insert(saved, {
                slot = slot,
                name = loadout.name,
                description = loadout.description,
                weight = loadout.totalWeight,
                savedAt = loadout.savedAt,
            })
        end
    end

    return saved
end

--- Delete saved loadout
-- @param unitId string Unit ID
-- @param slot number Loadout slot (1-5)
-- @return boolean Success
function LoadoutSystem:deleteLoadout(unitId, slot)
    if slot < 1 or slot > 5 then
        return false
    end

    if not self.loadouts[unitId] then
        return false
    end

    self.loadouts[unitId][slot] = nil

    print(string.format("[LoadoutSystem] Deleted loadout from unit %s slot %d", unitId, slot))

    return true
end

--- Get loadout recommendations based on mission type
-- @param missionType string Mission type (DEFEND, ATTACK, INFILTRATE, RESCUE)
-- @return table Array of recommended template names
function LoadoutSystem:getRecommendedLoadouts(missionType)
    local recommendations = {
        DEFEND = {"TANK", "HEAVY_ASSAULT", "MEDIC"},
        ATTACK = {"HEAVY_ASSAULT", "BALANCED", "SNIPER_SUPPORT"},
        INFILTRATE = {"SCOUT", "SNIPER_SUPPORT", "BALANCED"},
        RESCUE = {"MEDIC", "SCOUT", "BALANCED"},
    }

    return recommendations[missionType] or {"BALANCED"}
end

--- Apply loadout to unit (set inventory items)
-- @param unit table Unit entity
-- @param loadout table Loadout to apply
-- @return boolean Success
function LoadoutSystem:applyLoadout(unit, loadout)
    if not unit or not loadout then
        return false
    end

    -- Validate first
    local valid, err = self:validateLoadout(loadout, unit)
    if not valid then
        print(string.format("[LoadoutSystem] Cannot apply loadout: %s", err))
        return false
    end

    -- Clear existing inventory (placeholder - integrate with real inventory system)
    unit.inventory = unit.inventory or {}

    -- Apply items to unit
    if loadout.items.primary then
        unit.primaryWeapon = loadout.items.primary
    end
    if loadout.items.secondary then
        unit.secondaryWeapon = loadout.items.secondary
    end
    if loadout.items.armor then
        unit.armor = loadout.items.armor
    end

    unit.inventory.belt = loadout.items.belt or {}
    unit.inventory.backpack = loadout.items.backpack or {}

    print(string.format("[LoadoutSystem] Applied loadout '%s' to unit %s", loadout.name, unit.id))

    return true
end

return LoadoutSystem

