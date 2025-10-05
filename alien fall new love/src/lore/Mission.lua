--- Base Mission Class
-- Represents a mission in the geoscape
--
-- @classmod domain.missions.Mission

-- GROK: Mission is the base class for all mission types with objectives, requirements, and progress
-- GROK: Used by mission_system as the foundation for all geoscape activities
-- GROK: Key methods: start(), update(), checkRequirements(), getBriefing()
-- GROK: Handles mission lifecycle, progress tracking, and requirement validation

local Mission = {}
Mission.__index = Mission

--- Create a new mission instance
-- @param data Mission data from TOML configuration
-- @return Mission instance
function Mission.new(data)
    local self = setmetatable({}, Mission)

    -- Basic mission properties
    self.id = data.id
    self.name = data.name
    self.type = data.type
    self.difficulty = data.difficulty or "medium"
    self.duration = data.duration or 24

    -- Mission objectives and rewards
    self.objectives = data.objectives or {}
    self.rewards = data.rewards or {}

    -- Deployment constraints
    self.deployment = data.deployment or {}

    -- Mission requirements
    self.requirements = data.requirements or {}

    -- Detection mechanics (from wiki: Mission Detection and Assignment)
    self.initial_cover = data.initial_cover or 100  -- Starting cover value
    self.current_cover = self.initial_cover         -- Current cover (reduced by detection)
    self.armor = data.armor or 0                    -- Armor reduces detection effectiveness
    self.detected = false                           -- Whether mission is visible on geoscape

    -- Mission state
    self.status = "available"  -- available, active, completed, failed
    self.progress = 0
    self.start_time = nil
    self.end_time = nil

    return self
end

--- Start the mission
-- @param start_time Current game time
function Mission:start(start_time)
    self.status = "active"
    self.start_time = start_time
    self.end_time = start_time + (self.duration * 3600)  -- Convert hours to seconds
end

--- Update mission progress
-- @param current_time Current game time
function Mission:update(current_time)
    if self.status ~= "active" then return end

    local elapsed = current_time - self.start_time
    local total_duration = self.end_time - self.start_time
    self.progress = math.min(elapsed / total_duration, 1.0)

    -- Check for completion
    if self.progress >= 1.0 then
        self:complete()
    end
end

--- Complete the mission
function Mission:complete()
    self.status = "completed"
    -- Award rewards would be handled by the mission system
end

--- Fail the mission
function Mission:fail()
    self.status = "failed"
end

--- Apply detection power to reduce cover
-- @param detection_power Amount of detection power applied
-- @return boolean Whether mission was detected (cover <= 0)
function Mission:applyDetection(detection_power)
    if self.detected then return false end

    -- Wiki formula: Cover reduction = DetectionPower × (1 - Armor)
    local armor_factor = 1.0 - (self.armor / 100.0)  -- Armor is percentage
    local cover_reduction = detection_power * armor_factor

    self.current_cover = math.max(0, self.current_cover - cover_reduction)

    -- Check if mission becomes detected
    if self.current_cover <= 0 and not self.detected then
        self.detected = true
        return true
    end

    return false
end

--- Get current detection status
-- @return boolean Whether mission is detected
function Mission:isDetected()
    return self.detected
end

--- Get current cover value
-- @return number Current cover value
function Mission:getCurrentCover()
    return self.current_cover
end

--- Get initial cover value
-- @return number Initial cover value
function Mission:getInitialCover()
    return self.initial_cover
end

--- Reset cover to initial value
function Mission:resetCover()
    self.current_cover = self.initial_cover
    self.detected = false
end

--- Check if mission requirements are met
-- @param player_data Current player state
-- @return boolean Whether requirements are met
function Mission:checkRequirements(player_data)
    -- Check minimum rank
    if self.requirements.min_rank and player_data.rank < self.requirements.min_rank then
        return false
    end

    -- Check required equipment
    if self.requirements.required_equipment then
        for _, equipment in ipairs(self.requirements.required_equipment) do
            if not player_data:hasEquipment(equipment) then
                return false
            end
        end
    end

    -- Check prerequisites
    if self.requirements.prerequisites then
        for _, prereq in ipairs(self.requirements.prerequisites) do
            if not player_data:hasCompleted(prereq) then
                return false
            end
        end
    end

    return true
end

--- Get mission briefing text
-- @return string Mission briefing
function Mission:getBriefing()
    local briefing = string.format("MISSION: %s\n\n", self.name)
    briefing = briefing .. string.format("Type: %s\n", self.type)
    briefing = briefing .. string.format("Difficulty: %s\n", self.difficulty)
    briefing = briefing .. string.format("Duration: %d hours\n\n", self.duration)

    if self.objectives.primary then
        briefing = briefing .. string.format("PRIMARY OBJECTIVE:\n%s\n\n", self.objectives.primary)
    end

    if self.objectives.secondary and #self.objectives.secondary > 0 then
        briefing = briefing .. "SECONDARY OBJECTIVES:\n"
        for _, objective in ipairs(self.objectives.secondary) do
            briefing = briefing .. string.format("- %s\n", objective)
        end
        briefing = briefing .. "\n"
    end

    return briefing
end

return Mission
