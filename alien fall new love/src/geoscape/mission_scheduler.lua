--- MissionScheduler.lua
-- Mission scheduler service for Alien Fall geoscape system
-- Handles mission generation, lifecycle management, and scheduling

local class = require 'lib.Middleclass'

MissionScheduler = class('MissionScheduler')

--- Initialize a new MissionScheduler instance
-- @param registry Service registry for accessing other systems
-- @return MissionScheduler instance
function MissionScheduler:initialize(registry)
    self.registry = registry

    -- Mission templates
    self.mission_templates = {}

    -- Active missions
    self.active_missions = {}  -- mission_id -> mission_data

    -- Mission counters
    self.next_mission_id = 1

    -- Scheduling state
    self.spawn_queue = {}  -- Queued mission spawns
    self.expiration_queue = {}  -- Queued mission expirations

    -- Load mission data
    self:_loadMissionTemplates()

    -- Register time hooks
    self:_registerTimeHooks()

    -- Register with service registry
    if registry then
        registry:registerService('missionScheduler', self)
    end
end

--- Load mission templates from TOML data
function MissionScheduler:_loadMissionTemplates()
    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    local mission_data = dataRegistry:getData('geoscape/missions')
    if not mission_data then return end

    self.mission_templates = mission_data
end

--- Register time-based hooks for mission scheduling
function MissionScheduler:_registerTimeHooks()
    local timeService = self.registry:getService('timeService')
    if not timeService then return end

    -- Register daily tick for mission processing
    timeService:registerHook('day_tick', 'mission_scheduler_daily', function()
        self:_processDailyMissionLogic()
    end, 100)  -- High priority

    -- Register weekly tick for cleanup
    timeService:registerHook('week_tick', 'mission_scheduler_weekly', function()
        self:_processWeeklyMissionLogic()
    end, 50)
end

--- Process daily mission logic
function MissionScheduler:_processDailyMissionLogic()
    -- Process spawn queue
    self:_processSpawnQueue()

    -- Process expiration queue
    self:_processExpirationQueue()

    -- Generate new missions
    self:_generateNewMissions()

    -- Update active missions
    self:_updateActiveMissions()
end

--- Process weekly mission logic
function MissionScheduler:_processWeeklyMissionLogic()
    -- Clean up expired missions
    self:_cleanupExpiredMissions()

    -- Update mission statistics
    self:_updateMissionStatistics()
end

--- Process the mission spawn queue
function MissionScheduler:_processSpawnQueue()
    local current_time = self:_getCurrentTime()

    for i = #self.spawn_queue, 1, -1 do
        local spawn_data = self.spawn_queue[i]

        if current_time >= spawn_data.spawn_time then
            self:_spawnMission(spawn_data)
            table.remove(self.spawn_queue, i)
        end
    end
end

--- Process the mission expiration queue
function MissionScheduler:_processExpirationQueue()
    local current_time = self:_getCurrentTime()

    for i = #self.expiration_queue, 1, -1 do
        local expiration_data = self.expiration_queue[i]

        if current_time >= expiration_data.expiration_time then
            self:_expireMission(expiration_data.mission_id)
            table.remove(self.expiration_queue, i)
        end
    end
end

--- Generate new missions based on world state
function MissionScheduler:_generateNewMissions()
    local worldModel = self.registry:getService('worldModel')
    if not worldModel then return end

    local current_world = worldModel:getCurrentWorld()
    if not current_world then return end

    -- Get eligible provinces for mission spawning
    local eligible_provinces = self:_getEligibleProvinces()

    -- Calculate spawn budget based on world settings
    local spawn_budget = self:_calculateSpawnBudget(current_world)

    -- Generate missions up to budget
    local missions_spawned = 0
    for province_id, province in pairs(eligible_provinces) do
        if missions_spawned >= spawn_budget then break end

        if self:_shouldSpawnMissionInProvince(province) then
            local mission_template = self:_selectMissionTemplate(province)
            if mission_template then
                self:_queueMissionSpawn(province, mission_template)
                missions_spawned = missions_spawned + 1
            end
        end
    end
end

--- Get provinces eligible for mission spawning
-- @return Table of province_id -> Province instance
function MissionScheduler:_getEligibleProvinces()
    local worldModel = self.registry:getService('worldModel')
    if not worldModel then return {} end

    local current_world = worldModel:getCurrentWorld()
    if not current_world then return {} end

    local provinces = worldModel:getProvincesForWorld(current_world.id)
    local eligible = {}

    for province_id, province in pairs(provinces) do
        -- Check if province can host more missions
        local active_count = 0
        for _ in pairs(province.active_missions) do
            active_count = active_count + 1
        end

        if active_count < province.max_concurrent_missions then
            eligible[province_id] = province
        end
    end

    return eligible
end

--- Calculate mission spawn budget for current world
-- @param world World instance
-- @return Number of missions to spawn
function MissionScheduler:_calculateSpawnBudget(world)
    local base_budget = world.missions.max_concurrent_missions or 10

    -- Adjust based on current active missions
    local active_count = 0
    for _ in pairs(self.active_missions) do
        active_count = active_count + 1
    end

    -- Spawn to maintain target level
    local target_level = math.floor(base_budget * 0.7)  -- Keep at 70% capacity
    local spawn_count = math.max(0, target_level - active_count)

    return math.min(spawn_count, 5)  -- Max 5 per day
end

--- Check if a mission should spawn in a province
-- @param province Province instance
-- @return True if mission should spawn
function MissionScheduler:_shouldSpawnMissionInProvince(province)
    -- Base probability from alien activity
    local base_probability = province.alien_activity * 0.1  -- 10% base chance per activity level

    -- Adjust for existing missions (reduce chance if province is busy)
    local active_count = 0
    for _ in pairs(province.active_missions) do
        active_count = active_count + 1
    end
    local congestion_factor = 1.0 - (active_count / province.max_concurrent_missions)

    -- Adjust for time of day (higher chance at night)
    local time_factor = self:_getTimeOfDayFactor()

    local final_probability = base_probability * congestion_factor * time_factor

    return math.random() < final_probability
end

--- Get time of day factor for mission spawning
-- @return Multiplier for spawn probability
function MissionScheduler:_getTimeOfDayFactor()
    -- Simplified: higher chance at "night"
    -- In full implementation, this would check actual illumination
    return math.random() < 0.5 and 1.5 or 1.0
end

--- Select appropriate mission template for province
-- @param province Province instance
-- @return Mission template or nil
function MissionScheduler:_selectMissionTemplate(province)
    local candidates = {}

    for template_id, template in pairs(self.mission_templates) do
        if self:_isTemplateEligibleForProvince(template, province) then
            -- Calculate weight based on province tags and template requirements
            local weight = self:_calculateTemplateWeight(template, province)
            if weight > 0 then
                table.insert(candidates, {
                    template = template,
                    weight = weight,
                    id = template_id
                })
            end
        end
    end

    -- Select weighted random
    if #candidates == 0 then return nil end

    local total_weight = 0
    for _, candidate in ipairs(candidates) do
        total_weight = total_weight + candidate.weight
    end

    local selection = math.random() * total_weight
    local current_weight = 0

    for _, candidate in ipairs(candidates) do
        current_weight = current_weight + candidate.weight
        if selection <= current_weight then
            return candidate.template
        end
    end

    return candidates[1].template  -- Fallback
end

--- Check if mission template is eligible for province
-- @param template Mission template
-- @param province Province instance
-- @return True if eligible
function MissionScheduler:_isTemplateEligibleForProvince(template, province)
    -- Check province tags
    if template.province_tags then
        local has_matching_tag = false
        for _, required_tag in ipairs(template.province_tags) do
            if required_tag == "any" then
                has_matching_tag = true
                break
            end
            -- Check province tags (would need to be implemented in Province class)
            if province.tags then
                for _, province_tag in ipairs(province.tags) do
                    if province_tag == required_tag then
                        has_matching_tag = true
                        break
                    end
                end
                if has_matching_tag then break end
            end
        end
        if not has_matching_tag then return false end
    end

    -- Check alien activity requirement
    if template.alien_activity_min and province.alien_activity < template.alien_activity_min then
        return false
    end

    return true
end

--- Calculate weight for mission template in province
-- @param template Mission template
-- @param province Province instance
-- @return Weight value
function MissionScheduler:_calculateTemplateWeight(template, province)
    local base_weight = template.spawn_weight or 1.0

    -- Adjust based on province biome
    if template.difficulty == "easy" and province.biome_id == "urban" then
        base_weight = base_weight * 1.2  -- Easier missions in cities
    elseif template.difficulty == "hard" and province.is_water then
        base_weight = base_weight * 0.5  -- Harder missions over water
    end

    -- Adjust based on alien activity
    local activity_multiplier = 1.0 + (province.alien_activity - 0.5) * 0.5
    base_weight = base_weight * activity_multiplier

    return math.max(0, base_weight)
end

--- Queue a mission for spawning
-- @param province Province instance
-- @param template Mission template
function MissionScheduler:_queueMissionSpawn(province, template)
    local spawn_time = self:_getCurrentTime() + math.random(1, 6)  -- 1-6 hours delay

    table.insert(self.spawn_queue, {
        province = province,
        template = template,
        spawn_time = spawn_time
    })
end

--- Spawn a mission from queue data
-- @param spawn_data Spawn queue entry
function MissionScheduler:_spawnMission(spawn_data)
    local province = spawn_data.province
    local template = spawn_data.template

    -- Create mission instance
    local mission_id = self:_generateMissionId()
    local mission = {
        id = mission_id,
        template_id = template.id or "unknown",
        province_id = province.id,
        name = template.name,
        description = template.description,
        type = template.type,
        difficulty = template.difficulty,
        reward_credits = template.reward_credits,
        reward_xp = template.reward_xp,
        objectives = template.objectives or {},
        tags = template.tags or {},
        spawn_time = self:_getCurrentTime(),
        duration_hours = template.duration_hours,
        expiration_time = self:_getCurrentTime() + (template.duration_hours * 3600),  -- Convert to seconds
        status = "active"
    }

    -- Add to active missions
    self.active_missions[mission_id] = mission

    -- Add to province
    province.active_missions[mission_id] = mission

    -- Queue expiration
    table.insert(self.expiration_queue, {
        mission_id = mission_id,
        expiration_time = mission.expiration_time
    })

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:mission_spawned', {
            mission = mission,
            province = province
        })
    end
end

--- Expire a mission
-- @param mission_id Mission to expire
function MissionScheduler:_expireMission(mission_id)
    local mission = self.active_missions[mission_id]
    if not mission then return end

    -- Update status
    mission.status = "expired"

    -- Remove from province
    local worldModel = self.registry:getService('worldModel')
    if worldModel then
        local province = worldModel:getProvince(mission.province_id)
        if province then
            province.active_missions[mission_id] = nil
        end
    end

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:mission_expired', {
            mission = mission
        })
    end
end

--- Update active missions
function MissionScheduler:_updateActiveMissions()
    -- Could implement mission progression logic here
    -- For now, just check for completed objectives
end

--- Clean up expired missions from active list
function MissionScheduler:_cleanupExpiredMissions()
    local to_remove = {}

    for mission_id, mission in pairs(self.active_missions) do
        if mission.status == "expired" or mission.status == "completed" then
            table.insert(to_remove, mission_id)
        end
    end

    for _, mission_id in ipairs(to_remove) do
        self.active_missions[mission_id] = nil
    end
end

--- Update mission statistics
function MissionScheduler:_updateMissionStatistics()
    -- Could track mission completion rates, spawn success, etc.
end

--- Generate unique mission ID
-- @return Mission ID string
function MissionScheduler:_generateMissionId()
    local id = string.format("mission_%04d", self.next_mission_id)
    self.next_mission_id = self.next_mission_id + 1
    return id
end

--- Get current time in seconds
-- @return Current time
function MissionScheduler:_getCurrentTime()
    -- Simplified: return turn count as time
    local timeService = self.registry:getService('timeService')
    if timeService then
        return timeService:getCurrentTime().turn * 86400  -- Convert days to seconds
    end
    return 0
end

--- Get all active missions
-- @return Table of mission_id -> mission data
function MissionScheduler:getActiveMissions()
    return self.active_missions
end

--- Get mission by ID
-- @param mission_id Mission identifier
-- @return Mission data or nil
function MissionScheduler:getMission(mission_id)
    return self.active_missions[mission_id]
end

--- Complete a mission
-- @param mission_id Mission to complete
-- @param success True if mission was successful
function MissionScheduler:completeMission(mission_id, success)
    local mission = self.active_missions[mission_id]
    if not mission then return end

    mission.status = success and "completed" or "failed"
    mission.completion_time = self:_getCurrentTime()

    -- Remove from province
    local worldModel = self.registry:getService('worldModel')
    if worldModel then
        local province = worldModel:getProvince(mission.province_id)
        if province then
            province.active_missions[mission_id] = nil
        end
    end

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:mission_completed', {
            mission = mission,
            success = success
        })
    end
end

return MissionScheduler
