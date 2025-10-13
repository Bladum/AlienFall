--- Data Loader
--- Loads game data from TOML files through the ModManager.
---
--- This module provides access to all game configuration data including
--- terrain types, weapons, armours, and unit classes. Data is loaded from
--- TOML files in the active mod's content directory and wrapped with
--- utility functions for easy access.
---
--- Example usage:
---   local DataLoader = require("core.data_loader")
---   DataLoader.load()
---   local weapon = DataLoader.weapons.get("rifle")
---   local terrain = DataLoader.terrainTypes.get("grass")
---
--- Loaded Data Tables:
---   - terrainTypes: Terrain definitions (grass, wall, door, etc.)
---   - weapons: Weapon definitions with stats and damage
---   - armours: Armour definitions with protection values
---   - unitClasses: Unit class definitions (soldier, alien, etc.)

local TOML = require("libs.toml")
local ModManager = require("core.mod_manager")

--- @class DataLoader
--- @field terrainTypes table Terrain type definitions and utility functions
--- @field weapons table Weapon definitions and utility functions
--- @field armours table Armour definitions and utility functions
--- @field unitClasses table Unit class definitions and utility functions
local DataLoader = {}

--- Load all game data from TOML files.
---
--- Calls individual loader functions for terrain, weapons, armours, and
--- unit classes. Should be called once during game initialization.
--- Returns true on success.
---
--- @return boolean True if all data loaded successfully
function DataLoader.load()
    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    DataLoader.armours = DataLoader.loadArmours()
    DataLoader.skills = DataLoader.loadSkills()
    DataLoader.unitClasses = DataLoader.loadUnitClasses()

    print("[DataLoader] Loaded all game data from TOML files")
    return true
end

--- Load terrain type definitions from TOML file.
---
--- Loads terrain data from mods/*/content/rules/battle/terrain.toml.
--- Returns table with terrain data and utility functions:
---   - get(id): Get terrain by ID
---   - getAllIds(): Get array of all terrain IDs
---   - getByProperty(prop, val): Find terrains matching property
---   - blocksMovement(id): Check if terrain blocks movement
---   - blocksSight(id): Check if terrain blocks line of sight
---   - getMoveCost(id): Get movement cost (default 2)
---   - getSightCost(id): Get sight cost (default 1)
---
--- @return table Terrain types table with utility functions
function DataLoader.loadTerrainTypes()
    local path = ModManager.getContentPath("rules", "battle/terrain.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get terrain types path from mod")
        return {}
    end
    
    print(string.format("[DataLoader] Loading terrain types from: %s", path))
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load terrain types")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    local terrainTypes = {
        terrain = data.terrain or {}
    }

    -- Add utility functions
    function terrainTypes.get(terrainId)
        return terrainTypes.terrain[terrainId]
    end

    function terrainTypes.getAllIds()
        local ids = {}
        for id, _ in pairs(terrainTypes.terrain) do
            table.insert(ids, id)
        end
        return ids
    end

    function terrainTypes.getByProperty(property, value)
        local result = {}
        for id, terrain in pairs(terrainTypes.terrain) do
            if terrain[property] == value then
                table.insert(result, id)
            end
        end
        return result
    end

    function terrainTypes.blocksMovement(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.blocksMovement
    end

    function terrainTypes.blocksSight(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.blocksSight
    end

    function terrainTypes.getMoveCost(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.moveCost or 2
    end

    function terrainTypes.getSightCost(terrainId)
        local terrain = terrainTypes.get(terrainId)
        return terrain and terrain.sightCost or 1
    end

    print(string.format("[DataLoader] Loaded %d terrain types", #terrainTypes.getAllIds()))
    return terrainTypes
end

--- Load weapon definitions from TOML file.
---
--- Loads weapon data from mods/*/content/rules/item/weapons.toml.
--- Returns table with weapon data and utility functions:
---   - get(id): Get weapon by ID
---   - getAllIds(): Get array of all weapon IDs
---   - getByType(type): Find weapons of specific type
---   - getForClass(classId): Get available weapons for unit class
---
--- @return table Weapons table with utility functions
function DataLoader.loadWeapons()
    local path = ModManager.getContentPath("rules", "item/weapons.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get weapons path from mod")
        return {}
    end
    
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load weapons")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    local weapons = {
        weapons = data.weapons or {}
    }

    -- Add utility functions
    function weapons.get(weaponId)
        return weapons.weapons[weaponId]
    end

    function weapons.getAllIds()
        local ids = {}
        for id, _ in pairs(weapons.weapons) do
            table.insert(ids, id)
        end
        return ids
    end

    function weapons.getByType(weaponType)
        local result = {}
        for id, weapon in pairs(weapons.weapons) do
            if weapon.type == weaponType then
                table.insert(result, id)
            end
        end
        return result
    end

    function weapons.getForClass(classId)
        -- This could be expanded with class-specific weapon restrictions
        return weapons.getAllIds()
    end

    print(string.format("[DataLoader] Loaded %d weapons", #weapons.getAllIds()))
    return weapons
end

--- Load armour definitions from TOML file.
---
--- Loads armour data from mods/*/content/rules/item/armours.toml.
--- Returns table with armour data and utility functions:
---   - get(id): Get armour by ID
---   - getAllIds(): Get array of all armour IDs
---   - getByType(type): Find armours of specific type
---   - getForClass(classId): Get available armours for unit class
---
--- @return table Armours table with utility functions
function DataLoader.loadArmours()
    local path = ModManager.getContentPath("rules", "item/armours.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get armours path from mod")
        return {}
    end
    
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load armours")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    local armours = {
        armours = data.armours or {}
    }

    -- Add utility functions
    function armours.get(armourId)
        return armours.armours[armourId]
    end

    function armours.getAllIds()
        local ids = {}
        for id, _ in pairs(armours.armours) do
            table.insert(ids, id)
        end
        return ids
    end

    function armours.getByType(armourType)
        local result = {}
        for id, armour in pairs(armours.armours) do
            if armour.type == armourType then
                table.insert(result, id)
            end
        end
        return result
    end

    function armours.getForClass(classId)
        -- This could be expanded with class-specific armour restrictions
        return armours.getAllIds()
    end

    print(string.format("[DataLoader] Loaded %d armours", #armours.getAllIds()))
    return armours
end

--- Load skill definitions from TOML file.
---
--- Loads skill data from mods/*/content/rules/item/skills.toml.
--- Returns table with skill data and utility functions:
---   - get(id): Get skill by ID
---   - getAllIds(): Get array of all skill IDs
---   - getByType(type): Find skills of specific type
---   - getForClass(classId): Get available skills for unit class
---
--- @return table Skills table with utility functions
function DataLoader.loadSkills()
    local path = ModManager.getContentPath("rules", "item/skills.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get skills path from mod")
        return {}
    end
    
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load skills")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    local skills = {
        skills = data.skills or {}
    }

    -- Add utility functions
    function skills.get(skillId)
        return skills.skills[skillId]
    end

    function skills.getAllIds()
        local ids = {}
        for id, _ in pairs(skills.skills) do
            table.insert(ids, id)
        end
        return ids
    end

    function skills.getByType(skillType)
        local result = {}
        for id, skill in pairs(skills.skills) do
            if skill.type == skillType then
                table.insert(result, id)
            end
        end
        return result
    end

    function skills.getForClass(classId)
        -- This could be expanded with class-specific skill restrictions
        return skills.getAllIds()
    end

    print(string.format("[DataLoader] Loaded %d skills", #skills.getAllIds()))
    return skills
end

--- Load unit class definitions from TOML file.
---
--- Loads unit class data from mods/*/content/rules/unit/classes.toml.
--- Returns table with unit class data and utility functions:
---   - get(id): Get unit class by ID
---   - getAllIds(): Get array of all class IDs
---   - getBySide(side): Get classes for side ("human", "alien", "civilian")
---
--- @return table Unit classes table with utility functions
function DataLoader.loadUnitClasses()
    local path = ModManager.getContentPath("rules", "unit/classes.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get unit classes path from mod")
        return {}
    end
    
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load unit classes")
        return {}
    end

    -- Convert TOML structure to Lua table with functions
    local unitClasses = {
        classes = data.classes or {}
    }

    -- Add utility functions
    function unitClasses.get(classId)
        return unitClasses.classes[classId]
    end

    function unitClasses.getAllIds()
        local ids = {}
        for id, _ in pairs(unitClasses.classes) do
            table.insert(ids, id)
        end
        return ids
    end

    function unitClasses.getBySide(side)
        local result = {}
        if side == "human" then
            result = {"soldier", "heavy", "sniper", "scout", "medic", "engineer", "tank"}
        elseif side == "alien" then
            result = {"sectoid", "muton", "chryssalid"}
        elseif side == "civilian" then
            result = {"civilian"}
        end
        return result
    end

    print(string.format("[DataLoader] Loaded %d unit classes", #unitClasses.getAllIds()))
    return unitClasses
end

return DataLoader