---Sensor System - Base & Craft Radar/Sensor Management
---
---Manages all radar and sensor equipment on bases and crafts. Calculates detection power,
---range, and effectiveness based on facility/equipment configuration. Provides unified
---interface for detection system to query sensor capabilities.
---
---Core Responsibilities:
---  - Track sensor capabilities of all bases
---  - Track sensor capabilities of all crafts
---  - Calculate effective radar power from multiple facilities
---  - Calculate effective detection range
---  - Provide sensor data to detection manager
---  - Handle sensor upgrades and improvements
---
---Sensor Types:
---  Base Radar:
---    - Basic Radar: Power 20, Range 5 provinces
---    - Large Radar: Power 50, Range 10 provinces
---    - Hyperwave Decoder: Power 100, Range 20 provinces
---
---  Craft Radar:
---    - Navigation Radar: Power 10, Range 3 provinces
---    - Advanced Radar: Power 25, Range 7 provinces
---    - Alien Hyperwave: Power 50, Range 15 provinces
---
---Key Exports:
---  - SensorSystem.new(): Create sensor system
---  - getBaseSensor(baseId): Get base sensor capabilities
---  - getCraftSensor(craftId): Get craft sensor capabilities
---  - calculateSensorPower(sensors): Calculate total power from multiple sensors
---  - calculateDetectionRange(sensorPower): Calculate range from power
---  - addBaseSensor(baseId, sensorType): Add sensor to base
---  - upgradeSensor(sensorId, newType): Upgrade sensor
---
---Integration:
---  - DetectionManager calls getBaseSensor/getCraftSensor to get capabilities
---  - FacilitySystem manages base radar facility placement
---  - CraftManager manages craft equipment
---  - RelationManager affects sensor reliability
---
---@module geoscape.systems.sensor_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local SensorSystem = {}
SensorSystem.__index = SensorSystem

--- Sensor type definitions with power and range
local SENSOR_TYPES = {
    -- Base radars
    BASIC_RADAR = {
        name = "Basic Radar",
        power = 20,
        range = 5,
        reliability = 0.8,
        type = "base",
    },
    LARGE_RADAR = {
        name = "Large Radar",
        power = 50,
        range = 10,
        reliability = 0.9,
        type = "base",
    },
    HYPERWAVE_DECODER = {
        name = "Hyperwave Decoder",
        power = 100,
        range = 20,
        reliability = 0.95,
        type = "base",
    },

    -- Craft radars
    NAVIGATION_RADAR = {
        name = "Navigation Radar",
        power = 10,
        range = 3,
        reliability = 0.85,
        type = "craft",
    },
    ADVANCED_RADAR = {
        name = "Advanced Radar",
        power = 25,
        range = 7,
        reliability = 0.9,
        type = "craft",
    },
    ALIEN_HYPERWAVE = {
        name = "Alien Hyperwave",
        power = 50,
        range = 15,
        reliability = 0.95,
        type = "craft",
    },
}

--- Create new sensor system
-- @return table New SensorSystem instance
function SensorSystem.new()
    local self = setmetatable({}, SensorSystem)

    self.baseSensors = {}      -- baseId -> {sensors array}
    self.craftSensors = {}     -- craftId -> {sensors array}
    self.sensorUpgrades = {}   -- sensorId -> upgrade level
    self.debugMode = false

    print("[SensorSystem] Initialized sensor system")

    return self
end

--- Get all sensors on a base
-- @param baseId string Base identifier
-- @return table Array of sensors, or empty array if none
function SensorSystem:getBaseSensors(baseId)
    return self.baseSensors[baseId] or {}
end

--- Get all sensors on a craft
-- @param craftId string Craft identifier
-- @return table Array of sensors, or empty array if none
function SensorSystem:getCraftSensors(craftId)
    return self.craftSensors[craftId] or {}
end

--- Calculate total sensor power for a base
-- Combines all radar facilities at the base
-- @param baseId string Base identifier
-- @return number Total radar power
function SensorSystem:getBaseSensorPower(baseId)
    local sensors = self:getBaseSensors(baseId)

    if #sensors == 0 then
        return 0
    end

    local totalPower = 0
    for _, sensor in ipairs(sensors) do
        local sensorType = SENSOR_TYPES[sensor.type]
        if sensorType then
            -- Apply upgrade multiplier if available
            local upgradeLevel = self.sensorUpgrades[sensor.id] or 0
            local upgradeMult = 1.0 + (upgradeLevel * 0.1)  -- +10% per upgrade

            totalPower = totalPower + (sensorType.power * upgradeMult)
        end
    end

    return totalPower
end

--- Calculate total sensor power for a craft
-- Combines all radar equipment on the craft
-- @param craftId string Craft identifier
-- @return number Total radar power
function SensorSystem:getCraftSensorPower(craftId)
    local sensors = self:getCraftSensors(craftId)

    if #sensors == 0 then
        return 0
    end

    local totalPower = 0
    for _, sensor in ipairs(sensors) do
        local sensorType = SENSOR_TYPES[sensor.type]
        if sensorType then
            -- Apply upgrade multiplier if available
            local upgradeLevel = self.sensorUpgrades[sensor.id] or 0
            local upgradeMult = 1.0 + (upgradeLevel * 0.1)

            totalPower = totalPower + (sensorType.power * upgradeMult)
        end
    end

    return totalPower
end

--- Calculate detection range from sensor power
-- Better sensors have longer effective range
-- @param sensorPower number Total sensor power
-- @return number Detection range in provinces
function SensorSystem:calculateDetectionRange(sensorPower)
    if sensorPower <= 0 then
        return 0
    end

    -- Formula: range = 2 + (power / 20)
    -- 20 power = 3 hex range
    -- 50 power = 4.5 hex range
    -- 100 power = 7 hex range
    local range = 2 + (sensorPower / 20)

    return range
end

--- Calculate sensor reliability (0-1)
-- Affects how effectively sensor detects missions
-- @param baseId string Base identifier
-- @return number Reliability factor (0-1)
function SensorSystem:getBaseSensorReliability(baseId)
    local sensors = self:getBaseSensors(baseId)

    if #sensors == 0 then
        return 0
    end

    -- Average reliability of all sensors
    local totalReliability = 0
    for _, sensor in ipairs(sensors) do
        local sensorType = SENSOR_TYPES[sensor.type]
        if sensorType then
            totalReliability = totalReliability + sensorType.reliability
        end
    end

    return totalReliability / #sensors
end

--- Calculate sensor reliability for craft
-- @param craftId string Craft identifier
-- @return number Reliability factor (0-1)
function SensorSystem:getCraftSensorReliability(craftId)
    local sensors = self:getCraftSensors(craftId)

    if #sensors == 0 then
        return 0
    end

    -- Average reliability of all sensors
    local totalReliability = 0
    for _, sensor in ipairs(sensors) do
        local sensorType = SENSOR_TYPES[sensor.type]
        if sensorType then
            totalReliability = totalReliability + sensorType.reliability
        end
    end

    return totalReliability / #sensors
end

--- Add a sensor to a base
-- @param baseId string Base identifier
-- @param sensorType string Sensor type constant (BASIC_RADAR, etc.)
-- @return table New sensor, or nil if invalid
function SensorSystem:addBaseSensor(baseId, sensorType)
    if not SENSOR_TYPES[sensorType] then
        print(string.format("[SensorSystem] Invalid sensor type: %s", sensorType))
        return nil
    end

    if not SENSOR_TYPES[sensorType].type == "base" then
        print(string.format("[SensorSystem] Sensor %s is not a base sensor", sensorType))
        return nil
    end

    -- Initialize base sensors array if needed
    if not self.baseSensors[baseId] then
        self.baseSensors[baseId] = {}
    end

    local sensorId = string.format("base_%s_%d", baseId, love.timer.getTime() * 1000)
    local sensor = {
        id = sensorId,
        baseId = baseId,
        type = sensorType,
        addedAt = love.timer.getTime(),
    }

    table.insert(self.baseSensors[baseId], sensor)
    self.sensorUpgrades[sensorId] = 0

    print(string.format("[SensorSystem] Added %s to base %s", sensorType, baseId))

    return sensor
end

--- Add a sensor to a craft
-- @param craftId string Craft identifier
-- @param sensorType string Sensor type constant
-- @return table New sensor, or nil if invalid
function SensorSystem:addCraftSensor(craftId, sensorType)
    if not SENSOR_TYPES[sensorType] then
        print(string.format("[SensorSystem] Invalid sensor type: %s", sensorType))
        return nil
    end

    if not SENSOR_TYPES[sensorType].type == "craft" then
        print(string.format("[SensorSystem] Sensor %s is not a craft sensor", sensorType))
        return nil
    end

    -- Initialize craft sensors array if needed
    if not self.craftSensors[craftId] then
        self.craftSensors[craftId] = {}
    end

    local sensorId = string.format("craft_%s_%d", craftId, love.timer.getTime() * 1000)
    local sensor = {
        id = sensorId,
        craftId = craftId,
        type = sensorType,
        addedAt = love.timer.getTime(),
    }

    table.insert(self.craftSensors[craftId], sensor)
    self.sensorUpgrades[sensorId] = 0

    print(string.format("[SensorSystem] Added %s to craft %s", sensorType, craftId))

    return sensor
end

--- Upgrade a sensor to next level
-- @param sensorId string Sensor identifier
-- @return boolean Success
function SensorSystem:upgradeSensor(sensorId)
    if not self.sensorUpgrades[sensorId] then
        print(string.format("[SensorSystem] Sensor not found: %s", sensorId))
        return false
    end

    local currentLevel = self.sensorUpgrades[sensorId]
    if currentLevel >= 5 then
        print(string.format("[SensorSystem] Sensor already at max level: %s", sensorId))
        return false
    end

    self.sensorUpgrades[sensorId] = currentLevel + 1
    print(string.format("[SensorSystem] Upgraded sensor %s to level %d", sensorId, currentLevel + 1))

    return true
end

--- Get sensor type definition
-- @param sensorType string Sensor type constant
-- @return table Sensor definition or nil
function SensorSystem:getSensorTypeData(sensorType)
    return SENSOR_TYPES[sensorType]
end

--- Get all available sensor types
-- @return table Array of sensor type names
function SensorSystem:getAvailableSensorTypes()
    local types = {}
    for sensorType, _ in pairs(SENSOR_TYPES) do
        table.insert(types, sensorType)
    end
    return types
end

--- Create default sensors for a base
-- Sets up basic starting radar configuration
-- @param baseId string Base identifier
function SensorSystem:initializeBaseWithDefaultSensors(baseId)
    -- Add basic radar as starting equipment
    self:addBaseSensor(baseId, "BASIC_RADAR")
    print(string.format("[SensorSystem] Initialized base %s with default sensors", baseId))
end

--- Create default sensors for a craft
-- @param craftId string Craft identifier
function SensorSystem:initializeCraftWithDefaultSensors(craftId)
    -- Add navigation radar as starting equipment
    self:addCraftSensor(craftId, "NAVIGATION_RADAR")
    print(string.format("[SensorSystem] Initialized craft %s with default sensors", craftId))
end

--- Get debug info for a base
-- @param baseId string Base identifier
-- @return string Debug information
function SensorSystem:getBaseDebugInfo(baseId)
    local sensors = self:getBaseSensors(baseId)
    local power = self:getBaseSensorPower(baseId)
    local range = self:calculateDetectionRange(power)
    local reliability = self:getBaseSensorReliability(baseId)

    return string.format(
        "[Base %s] Sensors: %d, Power: %.1f, Range: %.1f, Reliability: %.1f%%",
        baseId, #sensors, power, range, reliability * 100
    )
end

--- Get debug info for a craft
-- @param craftId string Craft identifier
-- @return string Debug information
function SensorSystem:getCraftDebugInfo(craftId)
    local sensors = self:getCraftSensors(craftId)
    local power = self:getCraftSensorPower(craftId)
    local range = self:calculateDetectionRange(power)
    local reliability = self:getCraftSensorReliability(craftId)

    return string.format(
        "[Craft %s] Sensors: %d, Power: %.1f, Range: %.1f, Reliability: %.1f%%",
        craftId, #sensors, power, range, reliability * 100
    )
end

return SensorSystem

