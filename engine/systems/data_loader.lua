-- Data Loader
-- Loads game data from TOML files through the ModManager

local TOML = require("libs.toml")
local ModManager = require("systems.mod_manager")

local DataLoader = {}

-- Load all game data from TOML files
function DataLoader.load()
    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    DataLoader.armours = DataLoader.loadArmours()
    DataLoader.unitClasses = DataLoader.loadUnitClasses()

    print("[DataLoader] Loaded all game data from TOML files")
    return true
end

-- Load terrain types from TOML
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

-- Load weapons from TOML
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

-- Load armours from TOML
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

-- Load unit classes from TOML
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