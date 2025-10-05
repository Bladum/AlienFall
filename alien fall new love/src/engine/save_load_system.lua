--- Enhanced Save/Load System with Versioning and Migration
-- Comprehensive save/load for all game state with version migration support

local class = require('lib.middleclass')
local SafeIO = require('utils.safe_io')

---@class SaveLoadSystem
---@field private _version string Current save format version
---@field private _mountPoint string Save directory
---@field private _telemetry table Telemetry service
---@field private _logger table Logger service
---@field private _migrations table Version migration functions
local SaveLoadSystem = class('SaveLoadSystem')

-- Constants
local CURRENT_VERSION = "1.0.0"
local SAVE_DIRECTORY = "saves"
local AUTOSAVE_SLOT = "autosave"
local MAX_AUTOSAVES = 3

---Initialize save/load system
---@param config table Configuration
function SaveLoadSystem:initialize(config)
    config = config or {}
    self._version = CURRENT_VERSION
    self._mountPoint = config.mountPoint or SAVE_DIRECTORY
    self._telemetry = config.telemetry
    self._logger = config.logger
    self._migrations = {}
    
    -- Register migration functions
    self:_registerMigrations()
    
    -- Ensure save directory exists
    self:_ensureDirectory()
end

---Ensure save directory exists
function SaveLoadSystem:_ensureDirectory()
    if not love.filesystem.getInfo(self._mountPoint, "directory") then
        local success = love.filesystem.createDirectory(self._mountPoint)
        if not success and self._logger then
            self._logger:error("Failed to create save directory: " .. self._mountPoint)
        end
    end
end

---Register version migration functions
function SaveLoadSystem:_registerMigrations()
    -- Example: Migrate from 0.9.0 to 1.0.0
    self._migrations["0.9.0"] = function(data)
        if self._logger then
            self._logger:info("Migrating save from 0.9.0 to 1.0.0")
        end
        
        -- Add new fields that didn't exist in 0.9.0
        data.version = "1.0.0"
        data.world = data.world or {}
        data.world.illumination = data.world.illumination or {}
        
        return data
    end
    
    -- Add more migrations as needed
end

---Save complete game state
---@param slot string Save slot name
---@param gameState table Complete game state
---@return boolean success
---@return string error Error message if failed
function SaveLoadSystem:save(slot, gameState)
    if not slot or slot == "" then
        return false, "Invalid save slot name"
    end
    
    if not gameState then
        return false, "No game state provided"
    end
    
    -- Build save data structure
    local saveData = {
        version = CURRENT_VERSION,
        timestamp = os.time(),
        metadata = self:_gatherMetadata(gameState),
        world = self:_serializeWorld(gameState.world),
        bases = self:_serializeBases(gameState.bases),
        units = self:_serializeUnits(gameState.units),
        economy = self:_serializeEconomy(gameState.economy),
        research = self:_serializeResearch(gameState.research),
        missions = self:_serializeMissions(gameState.missions),
        rng = self:_serializeRNG(gameState.rng),
        turnManager = self:_serializeTurnManager(gameState.turnManager)
    }
    
    -- Serialize to Lua format
    local success, content = pcall(function()
        return "return " .. self:_serialize(saveData, 0)
    end)
    
    if not success then
        if self._logger then
            self._logger:error("Failed to serialize save data: " .. tostring(content))
        end
        return false, "Serialization failed: " .. tostring(content)
    end
    
    -- Write to file
    local filename = string.format("%s/%s.lua", self._mountPoint, slot)
    local writeSuccess, writeError = love.filesystem.write(filename, content)
    
    if not writeSuccess then
        if self._logger then
            self._logger:error("Failed to write save file: " .. tostring(writeError))
        end
        return false, "Write failed: " .. tostring(writeError)
    end
    
    -- Record telemetry
    if self._telemetry then
        self._telemetry:recordEvent({
            type = "save",
            slot = slot,
            success = true,
            dataSize = #content
        })
    end
    
    if self._logger then
        self._logger:info("Game saved to slot: " .. slot)
    end
    
    return true, nil
end

---Load complete game state
---@param slot string Save slot name
---@return table gameState Restored game state or nil
---@return string error Error message if failed
function SaveLoadSystem:load(slot)
    if not slot or slot == "" then
        return nil, "Invalid save slot name"
    end
    
    local filename = string.format("%s/%s.lua", self._mountPoint, slot)
    
    -- Check if file exists
    if not love.filesystem.getInfo(filename, "file") then
        return nil, "Save file not found"
    end
    
    -- Load and execute file
    local chunk, loadError = love.filesystem.load(filename)
    if not chunk then
        if self._logger then
            self._logger:error("Failed to load save file: " .. tostring(loadError))
        end
        return nil, "Load failed: " .. tostring(loadError)
    end
    
    local success, saveData = pcall(chunk)
    if not success then
        if self._logger then
            self._logger:error("Failed to execute save file: " .. tostring(saveData))
        end
        return nil, "Execution failed: " .. tostring(saveData)
    end
    
    -- Validate save data
    if not saveData or type(saveData) ~= "table" then
        return nil, "Invalid save data structure"
    end
    
    -- Check version and migrate if needed
    local currentVersion = saveData.version or "0.0.0"
    if currentVersion ~= CURRENT_VERSION then
        if self._logger then
            self._logger:info(string.format("Save version mismatch: %s (current: %s)", 
                currentVersion, CURRENT_VERSION))
        end
        
        saveData = self:_migrateSave(saveData, currentVersion)
        if not saveData then
            return nil, "Migration failed"
        end
    end
    
    -- Deserialize game state
    local gameState = {
        world = self:_deserializeWorld(saveData.world),
        bases = self:_deserializeBases(saveData.bases),
        units = self:_deserializeUnits(saveData.units),
        economy = self:_deserializeEconomy(saveData.economy),
        research = self:_deserializeResearch(saveData.research),
        missions = self:_deserializeMissions(saveData.missions),
        rng = self:_deserializeRNG(saveData.rng),
        turnManager = self:_deserializeTurnManager(saveData.turnManager),
        metadata = saveData.metadata
    }
    
    -- Record telemetry
    if self._telemetry then
        self._telemetry:recordEvent({
            type = "load",
            slot = slot,
            success = true,
            version = currentVersion
        })
    end
    
    if self._logger then
        self._logger:info("Game loaded from slot: " .. slot)
    end
    
    return gameState, nil
end

---Autosave game state
---@param gameState table Game state to save
---@return boolean success
function SaveLoadSystem:autosave(gameState)
    -- Rotate autosaves
    for i = MAX_AUTOSAVES - 1, 1, -1 do
        local oldSlot = AUTOSAVE_SLOT .. i
        local newSlot = AUTOSAVE_SLOT .. (i + 1)
        local oldPath = string.format("%s/%s.lua", self._mountPoint, oldSlot)
        
        if love.filesystem.getInfo(oldPath, "file") then
            local newPath = string.format("%s/%s.lua", self._mountPoint, newSlot)
            local contents = love.filesystem.read(oldPath)
            love.filesystem.write(newPath, contents)
        end
    end
    
    -- Save to autosave1
    return self:save(AUTOSAVE_SLOT .. "1", gameState)
end

---Migrate save data from old version to current
---@param saveData table Save data to migrate
---@param fromVersion string Source version
---@return table migratedData Migrated save data or nil
function SaveLoadSystem:_migrateSave(saveData, fromVersion)
    local migrationPath = self:_getMigrationPath(fromVersion, CURRENT_VERSION)
    
    if not migrationPath then
        if self._logger then
            self._logger:error(string.format("No migration path from %s to %s", 
                fromVersion, CURRENT_VERSION))
        end
        return nil
    end
    
    local currentData = saveData
    for _, version in ipairs(migrationPath) do
        local migrationFunc = self._migrations[version]
        if migrationFunc then
            local success, result = pcall(migrationFunc, currentData)
            if not success then
                if self._logger then
                    self._logger:error("Migration failed at version " .. version .. ": " .. tostring(result))
                end
                return nil
            end
            currentData = result
        end
    end
    
    return currentData
end

---Get migration path between versions
---@param fromVersion string Source version
---@param toVersion string Target version
---@return table path List of versions to migrate through or nil
function SaveLoadSystem:_getMigrationPath(fromVersion, toVersion)
    -- Simple implementation - assumes linear version progression
    -- TODO: Implement proper version graph traversal for complex cases
    local path = {}
    for version, _ in pairs(self._migrations) do
        if self:_isVersionBetween(version, fromVersion, toVersion) then
            table.insert(path, version)
        end
    end
    table.sort(path)
    return #path > 0 and path or nil
end

---Check if version is between two versions
---@param version string Version to check
---@param min string Minimum version
---@param max string Maximum version
---@return boolean isBetween
function SaveLoadSystem:_isVersionBetween(version, min, max)
    -- Simple string comparison (works for semantic versioning)
    return version > min and version <= max
end

---Gather metadata about save
---@param gameState table Game state
---@return table metadata
function SaveLoadSystem:_gatherMetadata(gameState)
    return {
        gameName = "Alien Fall",
        version = CURRENT_VERSION,
        playTime = gameState.playTime or 0,
        turnNumber = gameState.turnManager and gameState.turnManager.currentTurn or 0,
        currentDate = gameState.turnManager and gameState.turnManager.currentDate or {},
        difficulty = gameState.difficulty or "normal"
    }
end

---Serialize world state
---@param world table World data
---@return table serialized
function SaveLoadSystem:_serializeWorld(world)
    if not world then return {} end
    
    return {
        currentWorld = world.currentWorld,
        provinces = world.provinces,
        countries = world.countries,
        regions = world.regions,
        portals = world.portals,
        illumination = world.illumination
    }
end

---Deserialize world state
---@param data table Serialized world data
---@return table world
function SaveLoadSystem:_deserializeWorld(data)
    -- Reconstruct world objects
    -- TODO: Instantiate proper World, Province, Country objects
    return data or {}
end

---Serialize base data
---@param bases table Base data
---@return table serialized
function SaveLoadSystem:_serializeBases(bases)
    if not bases then return {} end
    
    local serialized = {}
    for baseId, base in pairs(bases) do
        serialized[baseId] = {
            id = base.id,
            name = base.name,
            location = base.location,
            facilities = base.facilities,
            personnel = base.personnel,
            storage = base.storage,
            production = base.production
        }
    end
    return serialized
end

---Deserialize base data
---@param data table Serialized base data
---@return table bases
function SaveLoadSystem:_deserializeBases(data)
    -- TODO: Reconstruct proper Base objects
    return data or {}
end

---Serialize unit data
---@param units table Unit data
---@return table serialized
function SaveLoadSystem:_serializeUnits(units)
    if not units then return {} end
    
    local serialized = {}
    for unitId, unit in pairs(units) do
        serialized[unitId] = {
            id = unit.id,
            name = unit.name,
            class = unit.class,
            stats = unit.stats,
            inventory = unit.inventory,
            experience = unit.experience,
            injuries = unit.injuries,
            location = unit.location
        }
    end
    return serialized
end

---Deserialize unit data
---@param data table Serialized unit data
---@return table units
function SaveLoadSystem:_deserializeUnits(data)
    -- TODO: Reconstruct proper Unit objects
    return data or {}
end

---Serialize economy data
---@param economy table Economy data
---@return table serialized
function SaveLoadSystem:_serializeEconomy(economy)
    if not economy then return {} end
    
    return {
        credits = economy.credits,
        income = economy.income,
        expenses = economy.expenses,
        monthlyReport = economy.monthlyReport
    }
end

---Deserialize economy data
---@param data table Serialized economy data
---@return table economy
function SaveLoadSystem:_deserializeEconomy(data)
    return data or {credits = 0, income = 0, expenses = 0}
end

---Serialize research data
---@param research table Research data
---@return table serialized
function SaveLoadSystem:_serializeResearch(research)
    if not research then return {} end
    
    return {
        completed = research.completed,
        inProgress = research.inProgress,
        available = research.available
    }
end

---Deserialize research data
---@param data table Serialized research data
---@return table research
function SaveLoadSystem:_deserializeResearch(data)
    return data or {completed = {}, inProgress = {}, available = {}}
end

---Serialize mission data
---@param missions table Mission data
---@return table serialized
function SaveLoadSystem:_serializeMissions(missions)
    if not missions then return {} end
    
    local serialized = {}
    for missionId, mission in pairs(missions) do
        serialized[missionId] = {
            id = mission.id,
            type = mission.type,
            location = mission.location,
            status = mission.status,
            expires = mission.expires,
            rewards = mission.rewards
        }
    end
    return serialized
end

---Deserialize mission data
---@param data table Serialized mission data
---@return table missions
function SaveLoadSystem:_deserializeMissions(data)
    -- TODO: Reconstruct proper Mission objects
    return data or {}
end

---Serialize RNG state
---@param rng table RNG service
---@return table serialized
function SaveLoadSystem:_serializeRNG(rng)
    if not rng or not rng.getState then return {} end
    
    return rng:getState()
end

---Deserialize RNG state
---@param data table Serialized RNG state
---@return table rng
function SaveLoadSystem:_deserializeRNG(data)
    -- TODO: Restore RNG state
    return data or {}
end

---Serialize turn manager data
---@param turnManager table Turn manager
---@return table serialized
function SaveLoadSystem:_serializeTurnManager(turnManager)
    if not turnManager then return {} end
    
    return {
        currentTurn = turnManager.currentTurn,
        currentDate = turnManager.currentDate,
        eventQueue = turnManager.eventQueue
    }
end

---Deserialize turn manager data
---@param data table Serialized turn manager data
---@return table turnManager
function SaveLoadSystem:_deserializeTurnManager(data)
    return data or {currentTurn = 0, currentDate = {}, eventQueue = {}}
end

---Serialize value to Lua code
---@param value any Value to serialize
---@param level number Indentation level
---@return string serialized
function SaveLoadSystem:_serialize(value, level)
    level = level or 0
    local indent = string.rep("  ", level)
    
    local valueType = type(value)
    
    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    elseif valueType == "string" then
        return string.format("%q", value)
    elseif valueType == "table" then
        local parts = {"{"}
        
        -- Sort keys for consistent output
        local keys = {}
        for k in pairs(value) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end)
        
        for _, key in ipairs(keys) do
            local keyStr
            if type(key) == "string" and key:match("^[_%a][_%w]*$") then
                keyStr = key
            else
                keyStr = "[" .. self:_serialize(key, level + 1) .. "]"
            end
            
            local valueStr = self:_serialize(value[key], level + 1)
            table.insert(parts, string.format("%s  %s = %s,", indent, keyStr, valueStr))
        end
        
        table.insert(parts, indent .. "}")
        return table.concat(parts, "\n")
    else
        error("Unsupported type for serialization: " .. valueType)
    end
end

---List available save slots
---@return table slots List of save slot names
function SaveLoadSystem:listSlots()
    self:_ensureDirectory()
    
    local items = love.filesystem.getDirectoryItems(self._mountPoint)
    local slots = {}
    
    for _, item in ipairs(items) do
        if item:match("%.lua$") then
            local slot = item:gsub("%.lua$", "")
            table.insert(slots, slot)
        end
    end
    
    table.sort(slots)
    return slots
end

---Delete a save slot
---@param slot string Save slot name
---@return boolean success
function SaveLoadSystem:deleteSave(slot)
    local filename = string.format("%s/%s.lua", self._mountPoint, slot)
    local success = love.filesystem.remove(filename)
    
    if self._logger then
        if success then
            self._logger:info("Deleted save slot: " .. slot)
        else
            self._logger:error("Failed to delete save slot: " .. slot)
        end
    end
    
    return success
end

return SaveLoadSystem
