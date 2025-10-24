---
-- Base Inventory & Salvage Processing System
-- @module engine.geoscape.salvage_processor
-- @author Copilot
-- @license MIT
--
-- Processes mission salvage collection and updates base inventory.
-- Handles corpse processing, alien technology harvesting, material refinement,
-- weight/volume constraints, and crafting opportunities from alien tech.
--
-- Key exports:
-- - processMissionSalvage() - Collect and store mission salvage
-- - addToBaseInventory() - Add items to base storage
-- - processCorporealMaterial() - Extract resources from alien corpses
-- - calculateSalvageValue() - Determine item worth
-- - generateCraftingRecipes() - Unlock recipes from alien tech

local SalvageProcessor = {}

---
-- Process all salvage collected during mission
-- @param mission table Mission data with location, enemies
-- @param battleResult table Battlescape results with items_collected, enemies_killed_list
-- @param baseData table Base with inventory space
-- @return table Salvage processing results
function SalvageProcessor.processMissionSalvage(mission, battleResult, baseData)
    if not mission or not battleResult or not baseData then
        print("[SalvageProcessor] ERROR: Missing required data")
        return nil
    end

    local salvageReport = {
        mission_id = mission.id,
        processed_at = os.time(),
        items_collected = {},
        materials_gained = {},
        research_unlocked = {},
        inventory_space_used = 0,
        inventory_space_available = baseData.inventory_space or 500,
        salvage_value_total = 0,
        processing_notes = {}
    }

    print(string.format("[SalvageProcessor] Processing salvage from mission %s", mission.id))

    -- Process collected items
    for _, item in ipairs(battleResult.items_collected or {}) do
        local processed = SalvageProcessor._processCollectedItem(item, salvageReport, baseData)
        if processed then
            table.insert(salvageReport.items_collected, processed)
        end
    end

    -- Process enemy corpses for materials
    for _, enemyData in ipairs(battleResult.enemies_killed_list or {}) do
        local materials = SalvageProcessor._processCorporealMaterial(enemyData, salvageReport)
        for material, amount in pairs(materials) do
            salvageReport.materials_gained[material] =
                (salvageReport.materials_gained[material] or 0) + amount
        end
    end

    -- Check for alien technology and new research opportunities
    for _, item in ipairs(salvageReport.items_collected) do
        local research = SalvageProcessor._checkNewResearch(item)
        if research then
            table.insert(salvageReport.research_unlocked, research)
        end
    end

    print(string.format("[SalvageProcessor] Salvage collected: %d items, %d materials",
        #salvageReport.items_collected, countTable(salvageReport.materials_gained)))

    return salvageReport
end

---
-- Process a single collected item
-- @param item table Item data (type, condition, quantity)
-- @param salvageReport table Salvage report being built
-- @param baseData table Base inventory data
-- @return table|nil Processed item if space available
function SalvageProcessor._processCollectedItem(item, salvageReport, baseData)
    local processedItem = {
        type = item.type,
        quantity = item.quantity or 1,
        condition = item.condition or "good",  -- excellent, good, damaged, poor
        collected_at = os.time(),
        value = 0
    }

    -- Calculate item value and salvage components
    processedItem.value = SalvageProcessor._calculateItemValue(processedItem)
    salvageReport.salvage_value_total = salvageReport.salvage_value_total + processedItem.value

    -- Check inventory space
    local spaceNeeded = processedItem.quantity * SalvageProcessor._getItemVolume(item.type)
    if salvageReport.inventory_space_used + spaceNeeded > salvageReport.inventory_space_available then
        print(string.format("[SalvageProcessor] WARNING: Not enough inventory space for %s x%d",
            item.type, processedItem.quantity))
        table.insert(salvageReport.processing_notes,
            string.format("Dropped %s x%d (inventory full)", item.type, processedItem.quantity))
        return nil
    end

    salvageReport.inventory_space_used = salvageReport.inventory_space_used + spaceNeeded

    print(string.format("[SalvageProcessor] Collected: %s x%d (value: %d, space: %d/%d)",
        item.type, processedItem.quantity, processedItem.value,
        salvageReport.inventory_space_used, salvageReport.inventory_space_available))

    return processedItem
end

---
-- Process alien corpse to extract materials
-- @param enemyData table Killed enemy data (type, level, species)
-- @return table Materials extracted (name -> quantity)
function SalvageProcessor._processCorporealMaterial(enemyData, salvageReport)
    local materials = {}
    local species = enemyData.species or "sectoid"

    -- Material yield by species
    local speciesYield = {
        sectoid = {
            organic_matter = 5,
            chitin = 2,
            neural_tissue = 1
        },
        muton = {
            organic_matter = 8,
            chitin = 4,
            muscle_tissue = 2,
            neural_tissue = 2
        },
        ethereal = {
            organic_matter = 3,
            psi_crystal = 3,
            neural_tissue = 5,
            alien_alloy = 1
        },
        floater = {
            organic_matter = 4,
            chitin = 3,
            gas_sac = 2
        }
    }

    local yield = speciesYield[species] or {organic_matter = 5}

    for material, amount in pairs(yield) do
        materials[material] = (materials[material] or 0) + amount
        table.insert(salvageReport.processing_notes,
            string.format("Extracted %d %s from %s corpse", amount, material, species))
    end

    print(string.format("[SalvageProcessor] Corpse processed: %s → %d materials",
        species, countTable(materials)))

    return materials
end

---
-- Add item to base inventory
-- @param baseId string Base identifier
-- @param itemType string Item type name
-- @param quantity number Amount to add
-- @param baseData table Base storage data
-- @return boolean Success/failure
function SalvageProcessor.addToBaseInventory(baseId, itemType, quantity, baseData)
    baseData = baseData or {inventory = {}, storage_space = 500, used_space = 0}

    local itemVolume = SalvageProcessor._getItemVolume(itemType)
    local spaceNeeded = quantity * itemVolume

    if baseData.used_space + spaceNeeded > baseData.storage_space then
        print(string.format("[SalvageProcessor] ERROR: Not enough storage for %s x%d", itemType, quantity))
        return false
    end

    baseData.inventory[itemType] = (baseData.inventory[itemType] or 0) + quantity
    baseData.used_space = baseData.used_space + spaceNeeded

    print(string.format("[SalvageProcessor] Added %s x%d to base (space: %d/%d)",
        itemType, quantity, baseData.used_space, baseData.storage_space))

    return true
end

---
-- Process corpse material extraction
-- @param corpseType string Alien type
-- @param corpseCount number Number of corpses
-- @return table Material yields {material_name -> quantity}
function SalvageProcessor.processCorporealMaterial(corpseType, corpseCount)
    local yieldPerCorpse = {
        sectoid = {organic_matter = 5, chitin = 2, neural_tissue = 1},
        muton = {organic_matter = 8, chitin = 4, muscle_tissue = 2, neural_tissue = 2},
        ethereal = {organic_matter = 3, psi_crystal = 3, neural_tissue = 5, alien_alloy = 1},
        floater = {organic_matter = 4, chitin = 3, gas_sac = 2}
    }

    local baseYield = yieldPerCorpse[corpseType] or {organic_matter = 5}
    local totalYield = {}

    for material, amountPerCorpse in pairs(baseYield) do
        totalYield[material] = amountPerCorpse * (corpseCount or 1)
    end

    print(string.format("[SalvageProcessor] Processed %d %s corpses", corpseCount or 0, corpseType))

    return totalYield
end

---
-- Calculate salvage value of item
-- @param item table Item with type and condition
-- @return number Value in credits
function SalvageProcessor._calculateItemValue(item)
    local baseValues = {
        plasma_rifle = 500,
        plasma_pistol = 300,
        alien_grenade = 200,
        psi_armor = 1000,
        heavy_plasma = 800,
        ethereal_device = 1500,
        ufo_power_source = 2000,
        ufo_nav_computer = 1500,
        ufo_hull_alloy = 800
    }

    local baseValue = baseValues[item.type] or 100

    -- Condition multiplier
    local conditionMultiplier = {
        excellent = 1.2,
        good = 1.0,
        damaged = 0.6,
        poor = 0.3
    }

    local multiplier = conditionMultiplier[item.condition] or 1.0
    local value = math.floor(baseValue * multiplier * (item.quantity or 1))

    return value
end

---
-- Get volume/weight of item type for inventory
-- @param itemType string Item type name
-- @return number Volume units per item
function SalvageProcessor._getItemVolume(itemType)
    local volumes = {
        -- Weapons
        plasma_rifle = 2,
        plasma_pistol = 1,
        heavy_plasma = 3,
        laser_rifle = 1.5,

        -- Armor
        psi_armor = 3,
        combat_armor = 2,
        alien_armor = 4,

        -- Materials
        organic_matter = 0.5,
        chitin = 0.5,
        alien_alloy = 0.5,
        psi_crystal = 1,

        -- Equipment
        ethereal_device = 2,
        ufo_power_source = 2,
        ufo_nav_computer = 1.5,

        -- Other
        alien_grenade = 0.5,
        corpse = 5
    }

    return volumes[itemType] or 1
end

---
-- Check if item unlocks new research
-- @param item table Collected item
-- @return table|nil Research opportunity if available
function SalvageProcessor._checkNewResearch(item)
    local researchUnlocks = {
        plasma_rifle = "plasma_weapon_tech",
        psi_armor = "psi_armor_tech",
        ethereal_device = "ethereal_technology",
        ufo_power_source = "ufo_power_systems",
        heavy_plasma = "heavy_weapon_tech"
    }

    if researchUnlocks[item.type] then
        return {
            tech_name = researchUnlocks[item.type],
            prerequisite_item = item.type,
            research_points = 50,
            unlocked_at = os.time()
        }
    end

    return nil
end

---
-- Generate crafting recipes from unlocked alien tech
-- @param researchId string Research technology ID
-- @return table Recipes that become available
function SalvageProcessor.generateCraftingRecipes(researchId)
    local recipes = {
        plasma_weapon_tech = {
            {name = "plasma_rifle", cost_materials = {alien_alloy = 5, power_cell = 2}},
            {name = "plasma_pistol", cost_materials = {alien_alloy = 3, power_cell = 1}}
        },
        psi_armor_tech = {
            {name = "psi_armor", cost_materials = {psi_crystal = 3, alien_alloy = 5}}
        },
        ethereal_technology = {
            {name = "ethereal_weapon", cost_materials = {psi_crystal = 5, ethereal_alloy = 2}}
        }
    }

    return recipes[researchId] or {}
end

---
-- Helper: Count table entries
-- @param tbl table Table to count
-- @return number Entry count
function countTable(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

return SalvageProcessor
