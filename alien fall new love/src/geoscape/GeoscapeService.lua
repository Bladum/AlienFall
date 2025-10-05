--- Geoscape Service
-- Orchestrates all strategic layer systems including world model, detection, missions, and crafts
-- Central coordinator for geoscape gameplay loop
--
-- @classmod geoscape.GeoscapeService

local class = require 'lib.Middleclass'

--- GeoscapeService class
-- @type GeoscapeService
GeoscapeService = class('GeoscapeService')

--- Create a new GeoscapeService instance
-- @param registry Service registry for accessing other systems
-- @param world World instance (optional, will be created if not provided)
-- @return GeoscapeService instance
function GeoscapeService:initialize(registry, world)
    self.registry = registry
    self.logger = registry and registry:getService('logger') or nil
    self.eventBus = registry and registry:getService('eventBus') or nil
    self.telemetry = registry and registry:getService('telemetry') or nil
    
    -- Core geoscape systems (lazy loaded)
    self.world = world or nil
    self.detectionSystem = nil
    self.missionScheduler = nil
    self.craftOperations = nil
    self.ufoSpawner = nil
    self.alienActivityManager = nil
    
    -- Geoscape state
    self.activeMissions = {}
    self.activeCrafts = {}
    self.activeUFOs = {}
    self.alertLevel = 0  -- Global alien alert level (0-100)
    
    -- Statistics
    self.stats = {
        missionsCompleted = 0,
        missionsFailed = 0,
        ufosDetected = 0,
        ufosShotDown = 0,
        craftsLost = 0
    }
    
    -- Subscribe to time events
    if self.eventBus then
        self.eventBus:subscribe("time:day_passed", function(payload)
            self:onDayPassed(payload)
        end)
        
        self.eventBus:subscribe("time:week_passed", function(payload)
            self:onWeekPassed(payload)
        end)
        
        self.eventBus:subscribe("time:month_passed", function(payload)
            self:onMonthPassed(payload)
        end)
    end
    
    if self.logger then
        self.logger:info("GeoscapeService initialized")
    end
    
    -- Register with service registry
    if registry then
        registry:registerService('geoscapeService', self)
    end
end

--- Get or lazy-load world model
-- @return World instance
function GeoscapeService:getWorld()
    if not self.world then
        -- Create world if not provided
        local World = require 'src.geoscape.World'
        self.world = World:new()
        
        if self.logger then
            self.logger:info("World created by GeoscapeService")
        end
    end
    return self.world
end

--- Get or lazy-load detection system
-- @return DetectionSystem instance
function GeoscapeService:getDetectionSystem()
    if not self.detectionSystem then
        local detection_system = require 'src.geoscape.detection_system'
        self.detectionSystem = detection_system
    end
    return self.detectionSystem
end

--- Get or lazy-load mission scheduler
-- @return MissionScheduler instance
function GeoscapeService:getMissionScheduler()
    if not self.missionScheduler then
        local mission_scheduler = require 'src.geoscape.mission_scheduler'
        self.missionScheduler = mission_scheduler
    end
    return self.missionScheduler
end

--- Get or lazy-load craft operations
-- @return CraftOperations instance
function GeoscapeService:getCraftOperations()
    if not self.craftOperations then
        local craft_operations = require 'src.geoscape.craft_operations'
        self.craftOperations = craft_operations
    end
    return self.craftOperations
end

--- Update geoscape state (called every frame)
-- @param dt Delta time in seconds
function GeoscapeService:update(dt)
    -- Update craft positions and movement
    self:updateCrafts(dt)
    
    -- Update UFO positions and behavior
    self:updateUFOs(dt)
    
    -- Check for detections and interceptions
    self:updateDetections()
    
    -- Update mission timers
    self:updateMissions(dt)
end

--- Update all crafts
-- @param dt Delta time in seconds
function GeoscapeService:updateCrafts(dt)
    for craftId, craft in pairs(self.activeCrafts) do
        -- Update craft position based on movement
        if craft.destination then
            -- Move craft toward destination
            local arrived = self:moveCraft(craft, dt)
            
            if arrived then
                -- Craft arrived at destination
                self:onCraftArrived(craft)
            end
        end
    end
end

--- Update all UFOs
-- @param dt Delta time in seconds
function GeoscapeService:updateUFOs(dt)
    for ufoId, ufo in pairs(self.activeUFOs) do
        -- Update UFO behavior
        if ufo.update then
            ufo:update(dt)
        end
    end
end

--- Update detection system
function GeoscapeService:updateDetections()
    local detectionSystem = self:getDetectionSystem()
    if not detectionSystem then return end
    
    -- Check for UFO detections from bases/radars
    for ufoId, ufo in pairs(self.activeUFOs) do
        if ufo.position then
            local detected = detectionSystem.checkDetection(ufo.position, ufo.size or 1)
            
            if detected and not ufo.detected then
                ufo.detected = true
                self:onUFODetected(ufo)
            end
        end
    end
end

--- Update mission timers and expiration
-- @param dt Delta time in seconds
function GeoscapeService:updateMissions(dt)
    local toRemove = {}
    
    for missionId, mission in pairs(self.activeMissions) do
        -- Update mission timer
        if mission.expiresAt then
            local timeService = self.registry:getService('timeService')
            if timeService then
                local currentTime = timeService:getCurrentTime()
                local currentHours = currentTime.day * 24
                
                if currentHours >= mission.expiresAt then
                    -- Mission expired
                    table.insert(toRemove, missionId)
                    self:onMissionExpired(mission)
                end
            end
        end
    end
    
    -- Remove expired missions
    for _, missionId in ipairs(toRemove) do
        self.activeMissions[missionId] = nil
    end
end

--- Move craft toward destination
-- @param craft Craft instance
-- @param dt Delta time
-- @return boolean: True if arrived at destination
function GeoscapeService:moveCraft(craft, dt)
    if not craft.destination or not craft.position then
        return false
    end
    
    local craftOps = self:getCraftOperations()
    if craftOps and craftOps.moveCraft then
        return craftOps.moveCraft(craft, craft.destination, dt)
    end
    
    -- Fallback: simple movement
    local dx = craft.destination.x - craft.position.x
    local dy = craft.destination.y - craft.position.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance < 0.1 then
        craft.position = craft.destination
        return true
    end
    
    local speed = craft.speed or 10
    local movement = speed * dt
    
    if movement >= distance then
        craft.position = craft.destination
        return true
    end
    
    local ratio = movement / distance
    craft.position.x = craft.position.x + dx * ratio
    craft.position.y = craft.position.y + dy * ratio
    
    return false
end

--- Handle craft arrival at destination
-- @param craft Craft instance
function GeoscapeService:onCraftArrived(craft)
    if self.logger then
        self.logger:info("Craft arrived at destination: " .. (craft.id or "unknown"))
    end
    
    craft.destination = nil
    
    -- Check if craft arrived at a mission site
    if craft.assignedMission then
        local mission = self.activeMissions[craft.assignedMission]
        if mission then
            -- Trigger mission start
            self:startMission(mission, craft)
        end
    end
    
    -- Emit event
    if self.eventBus then
        self.eventBus:emit('geoscape:craft_arrived', {
            craft_id = craft.id,
            position = craft.position
        })
    end
end

--- Start a tactical mission
-- @param mission Mission data
-- @param craft Craft with squad
function GeoscapeService:startMission(mission, craft)
    if self.logger then
        self.logger:info("Starting mission: " .. (mission.id or "unknown"))
    end
    
    -- Emit mission start event
    if self.eventBus then
        self.eventBus:emit('geoscape:mission_start', {
            mission_id = mission.id,
            craft_id = craft.id,
            mission_type = mission.type,
            location = mission.location
        })
    end
    
    -- This would transition to briefing/battlescape
end

--- Handle UFO detected event
-- @param ufo UFO instance
function GeoscapeService:onUFODetected(ufo)
    self.stats.ufosDetected = self.stats.ufosDetected + 1
    
    if self.logger then
        self.logger:info("UFO detected: " .. (ufo.id or "unknown"))
    end
    
    -- Emit detection event
    if self.eventBus then
        self.eventBus:emit('geoscape:ufo_detected', {
            ufo_id = ufo.id,
            position = ufo.position,
            size = ufo.size
        })
    end
end

--- Handle mission expired event
-- @param mission Mission data
function GeoscapeService:onMissionExpired(mission)
    self.stats.missionsFailed = self.stats.missionsFailed + 1
    
    if self.logger then
        self.logger:warn("Mission expired: " .. (mission.id or "unknown"))
    end
    
    -- Emit expiration event
    if self.eventBus then
        self.eventBus:emit('geoscape:mission_expired', {
            mission_id = mission.id,
            mission_type = mission.type
        })
    end
end

--- Handle day passed (called by time system)
-- @param payload Event payload
function GeoscapeService:onDayPassed(payload)
    -- Spawn new missions based on alert level
    local missionScheduler = self:getMissionScheduler()
    if missionScheduler and missionScheduler.generateMissions then
        local newMissions = missionScheduler.generateMissions(self.alertLevel)
        
        for _, mission in ipairs(newMissions or {}) do
            self:addMission(mission)
        end
    end
    
    -- Update alien activity
    if self.alienActivityManager and self.alienActivityManager.updateDaily then
        self.alienActivityManager:updateDaily()
    end
end

--- Handle week passed (called by time system)
-- @param payload Event payload
function GeoscapeService:onWeekPassed(payload)
    -- Weekly geoscape updates
    if self.logger then
        self.logger:debug("Week passed - geoscape update")
    end
end

--- Handle month passed (called by time system)
-- @param payload Event payload
function GeoscapeService:onMonthPassed(payload)
    -- Monthly geoscape updates (funding reports, etc.)
    if self.logger then
        self.logger:info("Month passed - monthly geoscape update")
    end
    
    -- Increase alert level gradually
    self.alertLevel = math.min(100, self.alertLevel + 1)
end

--- Add a new mission to the geoscape
-- @param mission Mission data
function GeoscapeService:addMission(mission)
    self.activeMissions[mission.id] = mission
    
    -- Emit mission spawned event
    if self.eventBus then
        self.eventBus:emit('geoscape:mission_spawned', {
            mission_id = mission.id,
            mission_type = mission.type,
            location = mission.location,
            expires_at = mission.expiresAt
        })
    end
    
    if self.logger then
        self.logger:info("Mission added: " .. mission.id .. " (" .. mission.type .. ")")
    end
end

--- Add a craft to the geoscape
-- @param craft Craft instance
function GeoscapeService:addCraft(craft)
    self.activeCrafts[craft.id] = craft
end

--- Add a UFO to the geoscape
-- @param ufo UFO instance
function GeoscapeService:addUFO(ufo)
    self.activeUFOs[ufo.id] = ufo
end

--- Get all active missions
-- @return table: Active missions
function GeoscapeService:getActiveMissions()
    return self.activeMissions
end

--- Get all active crafts
-- @return table: Active crafts
function GeoscapeService:getActiveCrafts()
    return self.activeCrafts
end

--- Get all active UFOs
-- @return table: Active UFOs
function GeoscapeService:getActiveUFOs()
    return self.activeUFOs
end

--- Get geoscape statistics
-- @return table: Statistics
function GeoscapeService:getStats()
    return self.stats
end

--- Get current alert level
-- @return number: Alert level (0-100)
function GeoscapeService:getAlertLevel()
    return self.alertLevel
end

--- Set alert level
-- @param level number: New alert level (0-100)
function GeoscapeService:setAlertLevel(level)
    self.alertLevel = math.max(0, math.min(100, level))
end

return GeoscapeService
