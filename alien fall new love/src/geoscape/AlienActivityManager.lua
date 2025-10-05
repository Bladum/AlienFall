--- AlienActivityManager.lua
-- Strategic AI and alien activity management system
-- Tracks alien presence, escalates threat, and coordinates UFO missions

-- GROK: AlienActivityManager orchestrates alien strategic behavior and escalation
-- GROK: Tracks infiltration, manages threat levels, and coordinates mission generation
-- GROK: Key methods: update(), escalateThreat(), generateMission(), trackInfiltration()
-- GROK: Integrates with UFOSpawner, MissionSiteGenerator, and world state

local class = require 'lib.Middleclass'

AlienActivityManager = class('AlienActivityManager')

--- Alien activity phases
AlienActivityManager.Phase = {
    RECONNAISSANCE = "reconnaissance",  -- Initial scouting
    INFILTRATION = "infiltration",     -- Building presence
    ESCALATION = "escalation",         -- Increased aggression
    INVASION = "invasion",             -- Full assault
    DOMINATION = "domination"          -- Final phase
}

--- Initialize alien activity manager
-- @param config Manager configuration
function AlienActivityManager:initialize(config)
    self.config = config or {}
    
    -- Current activity state
    self.current_phase = AlienActivityManager.Phase.RECONNAISSANCE
    self.threat_level = self.config.initial_threat or 1.0
    self.escalation_rate = self.config.escalation_rate or 0.01  -- Per day
    
    -- Infiltration tracking
    self.infiltration_by_country = {}  -- country_id -> infiltration_level (0-100)
    self.infiltration_by_region = {}   -- region_id -> infiltration_level (0-100)
    
    -- Mission history and planning
    self.mission_history = {}
    self.planned_missions = {}
    self.mission_cooldowns = {}  -- mission_type -> cooldown_time
    
    -- Strategic goals
    self.strategic_goals = {
        research_priority = {},  -- What tech aliens are researching
        target_countries = {},   -- Countries to infiltrate/attack
        target_regions = {}      -- Regions to focus on
    }
    
    -- Activity statistics
    self.stats = {
        total_missions = 0,
        successful_missions = 0,
        failed_missions = 0,
        terror_attacks = 0,
        infiltrations = 0,
        bases_established = 0
    }
    
    -- Update timer
    self.update_timer = 0
    self.daily_update_interval = 86400  -- seconds in a day
    
    -- Event bus
    self.event_bus = nil
    
    -- World reference
    self.world = nil
    
    -- Telemetry
    self.telemetry = nil
    
    -- RNG
    self.rng = nil
end

--- Set world reference
-- @param world The World instance
function AlienActivityManager:setWorld(world)
    self.world = world
    self.event_bus = world.event_bus
end

--- Set event bus
-- @param event_bus The event bus instance
function AlienActivityManager:setEventBus(event_bus)
    self.event_bus = event_bus
    
    -- Subscribe to relevant events
    if self.event_bus then
        self.event_bus:subscribe("ufo:destroyed", function(payload)
            self:onUFODestroyed(payload)
        end)
        
        self.event_bus:subscribe("mission:completed", function(payload)
            self:onMissionCompleted(payload)
        end)
        
        self.event_bus:subscribe("mission:failed", function(payload)
            self:onMissionFailed(payload)
        end)
    end
end

--- Set telemetry
-- @param telemetry The telemetry service
function AlienActivityManager:setTelemetry(telemetry)
    self.telemetry = telemetry
end

--- Set RNG
-- @param rng Random number generator
function AlienActivityManager:setRNG(rng)
    self.rng = rng
end

--- Update alien activity
-- @param deltaTime Time elapsed in seconds
function AlienActivityManager:update(deltaTime)
    self.update_timer = self.update_timer + deltaTime
    
    -- Daily update
    if self.update_timer >= self.daily_update_interval then
        self:_processDailyUpdate()
        self.update_timer = 0
    end
    
    -- Reduce mission cooldowns
    self:_updateCooldowns(deltaTime)
end

--- Process daily alien activity update
function AlienActivityManager:_processDailyUpdate()
    -- Escalate threat
    self:escalateThreat(self.escalation_rate)
    
    -- Update phase based on threat level
    self:_updatePhase()
    
    -- Process infiltration
    self:_processInfiltration()
    
    -- Plan new missions
    self:_planMissions()
    
    -- Update strategic goals
    self:_updateStrategicGoals()
    
    if self.telemetry then
        self.telemetry:record("alien_activity_daily_update", {
            phase = self.current_phase,
            threat_level = self.threat_level,
            planned_missions = #self.planned_missions
        })
    end
end

--- Escalate threat level
-- @param amount Amount to increase threat
function AlienActivityManager:escalateThreat(amount)
    local old_threat = self.threat_level
    self.threat_level = math.min(10.0, self.threat_level + amount)
    
    if self.event_bus then
        self.event_bus:publish("alien:threat_escalated", {
            old_threat = old_threat,
            new_threat = self.threat_level,
            amount = amount
        })
    end
    
    -- Check for phase transition
    self:_updatePhase()
end

--- Update activity phase based on threat level
function AlienActivityManager:_updatePhase()
    local old_phase = self.current_phase
    local new_phase = old_phase
    
    if self.threat_level >= 8.0 then
        new_phase = AlienActivityManager.Phase.DOMINATION
    elseif self.threat_level >= 6.0 then
        new_phase = AlienActivityManager.Phase.INVASION
    elseif self.threat_level >= 4.0 then
        new_phase = AlienActivityManager.Phase.ESCALATION
    elseif self.threat_level >= 2.0 then
        new_phase = AlienActivityManager.Phase.INFILTRATION
    else
        new_phase = AlienActivityManager.Phase.RECONNAISSANCE
    end
    
    if new_phase ~= old_phase then
        self.current_phase = new_phase
        
        if self.event_bus then
            self.event_bus:publish("alien:phase_changed", {
                old_phase = old_phase,
                new_phase = new_phase,
                threat_level = self.threat_level
            })
        end
    end
end

--- Process infiltration in countries and regions
function AlienActivityManager:_processInfiltration()
    if not self.world then
        return
    end
    
    -- Infiltrate random countries
    local infiltration_attempts = math.floor(self.threat_level / 2)
    
    for i = 1, infiltration_attempts do
        local target_country = self:_selectInfiltrationTarget()
        
        if target_country then
            self:infiltrateCountry(target_country, 1 + self.threat_level * 0.5)
        end
    end
end

--- Infiltrate a country
-- @param country_id Country ID
-- @param amount Infiltration amount
function AlienActivityManager:infiltrateCountry(country_id, amount)
    local current = self.infiltration_by_country[country_id] or 0
    local new_infiltration = math.min(100, current + amount)
    
    self.infiltration_by_country[country_id] = new_infiltration
    
    if self.event_bus then
        self.event_bus:publish("alien:country_infiltrated", {
            country_id = country_id,
            infiltration_level = new_infiltration,
            amount = amount
        })
    end
    
    -- Check if country is fully infiltrated
    if new_infiltration >= 100 and current < 100 then
        self:_countryFullyInfiltrated(country_id)
    end
end

--- Handle fully infiltrated country
-- @param country_id Country ID
function AlienActivityManager:_countryFullyInfiltrated(country_id)
    self.stats.infiltrations = self.stats.infiltrations + 1
    
    if self.event_bus then
        self.event_bus:publish("alien:country_controlled", {
            country_id = country_id
        })
    end
end

--- Select infiltration target
-- @return Country ID or nil
function AlienActivityManager:_selectInfiltrationTarget()
    if not self.world or not self.rng then
        return nil
    end
    
    -- Get all countries
    local countries = {}
    for country_id, _ in pairs(self.world.countries) do
        -- Prefer countries with low infiltration
        local infiltration = self.infiltration_by_country[country_id] or 0
        if infiltration < 90 then
            table.insert(countries, country_id)
        end
    end
    
    if #countries == 0 then
        return nil
    end
    
    return countries[self.rng:random(1, #countries)]
end

--- Plan missions based on current phase and strategic goals
function AlienActivityManager:_planMissions()
    -- Clear old plans
    self.planned_missions = {}
    
    -- Mission frequency based on phase
    local mission_count = self:_calculateMissionFrequency()
    
    for i = 1, mission_count do
        local mission_type = self:_selectMissionType()
        
        if mission_type and not self:_isOnCooldown(mission_type) then
            local mission_plan = {
                type = mission_type,
                priority = self:_calculateMissionPriority(mission_type),
                target = self:_selectMissionTarget(mission_type),
                planned_time = os.time() + self.rng:random(3600, 86400)  -- 1-24 hours
            }
            
            table.insert(self.planned_missions, mission_plan)
            self:_setCooldown(mission_type, self:_getMissionCooldown(mission_type))
        end
    end
    
    -- Sort by priority
    table.sort(self.planned_missions, function(a, b)
        return a.priority > b.priority
    end)
end

--- Calculate mission frequency based on phase
-- @return Number of missions to plan
function AlienActivityManager:_calculateMissionFrequency()
    local frequencies = {
        reconnaissance = 2,
        infiltration = 4,
        escalation = 6,
        invasion = 10,
        domination = 15
    }
    
    return frequencies[self.current_phase] or 2
end

--- Select mission type based on phase and strategy
-- @return Mission type string
function AlienActivityManager:_selectMissionType()
    if not self.rng then
        return "scout"
    end
    
    local phase_weights = {
        reconnaissance = {
            scout = 70,
            abduction = 20,
            infiltration = 10
        },
        infiltration = {
            scout = 30,
            abduction = 35,
            infiltration = 25,
            supply = 10
        },
        escalation = {
            scout = 20,
            abduction = 30,
            terror = 25,
            infiltration = 15,
            supply = 10
        },
        invasion = {
            abduction = 20,
            terror = 40,
            supply = 20,
            battleship = 20
        },
        domination = {
            terror = 50,
            battleship = 30,
            supply = 20
        }
    }
    
    local weights = phase_weights[self.current_phase] or phase_weights.reconnaissance
    
    -- Weighted random selection
    local total_weight = 0
    for _, weight in pairs(weights) do
        total_weight = total_weight + weight
    end
    
    local random_value = self.rng:random() * total_weight
    local cumulative = 0
    
    for mission_type, weight in pairs(weights) do
        cumulative = cumulative + weight
        if random_value <= cumulative then
            return mission_type
        end
    end
    
    return "scout"
end

--- Calculate mission priority
-- @param mission_type Mission type
-- @return Priority value (0-100)
function AlienActivityManager:_calculateMissionPriority(mission_type)
    local base_priorities = {
        scout = 30,
        abduction = 50,
        terror = 80,
        infiltration = 60,
        supply = 40,
        battleship = 90
    }
    
    local base = base_priorities[mission_type] or 50
    
    -- Add randomness
    local variance = self.rng and (self.rng:random() * 20 - 10) or 0
    
    return math.max(0, math.min(100, base + variance))
end

--- Select mission target
-- @param mission_type Mission type
-- @return Target data (province_id, country_id, etc.)
function AlienActivityManager:_selectMissionTarget(mission_type)
    if not self.world or not self.rng then
        return nil
    end
    
    -- For terror missions, target high-value countries
    if mission_type == "terror" then
        return self:_selectHighValueTarget()
    end
    
    -- For infiltration, target low-infiltration countries
    if mission_type == "infiltration" then
        return self:_selectInfiltrationTarget()
    end
    
    -- Default: random target
    return self:_selectRandomTarget()
end

--- Select high-value target for terror missions
-- @return Country ID or nil
function AlienActivityManager:_selectHighValueTarget()
    -- This would check country economic value, population, etc.
    -- For now, just return random
    return self:_selectRandomTarget()
end

--- Select random target
-- @return Target ID or nil
function AlienActivityManager:_selectRandomTarget()
    if not self.world or not self.rng then
        return nil
    end
    
    local provinces = {}
    for province_id, _ in pairs(self.world.provinces) do
        table.insert(provinces, province_id)
    end
    
    if #provinces == 0 then
        return nil
    end
    
    return provinces[self.rng:random(1, #provinces)]
end

--- Update strategic goals
function AlienActivityManager:_updateStrategicGoals()
    -- This would analyze player research, bases, activities
    -- and adjust alien strategy accordingly
    -- For now, placeholder
end

--- Update mission cooldowns
-- @param deltaTime Time elapsed in seconds
function AlienActivityManager:_updateCooldowns(deltaTime)
    for mission_type, cooldown in pairs(self.mission_cooldowns) do
        self.mission_cooldowns[mission_type] = math.max(0, cooldown - deltaTime)
    end
end

--- Check if mission type is on cooldown
-- @param mission_type Mission type
-- @return true if on cooldown
function AlienActivityManager:_isOnCooldown(mission_type)
    local cooldown = self.mission_cooldowns[mission_type] or 0
    return cooldown > 0
end

--- Set cooldown for mission type
-- @param mission_type Mission type
-- @param cooldown Cooldown time in seconds
function AlienActivityManager:_setCooldown(mission_type, cooldown)
    self.mission_cooldowns[mission_type] = cooldown
end

--- Get mission cooldown duration
-- @param mission_type Mission type
-- @return Cooldown duration in seconds
function AlienActivityManager:_getMissionCooldown(mission_type)
    local cooldowns = {
        scout = 3600,      -- 1 hour
        abduction = 7200,  -- 2 hours
        terror = 14400,    -- 4 hours
        infiltration = 10800, -- 3 hours
        supply = 21600,    -- 6 hours
        battleship = 43200 -- 12 hours
    }
    
    return cooldowns[mission_type] or 3600
end

--- Handle UFO destroyed event
-- @param payload Event payload
function AlienActivityManager:onUFODestroyed(payload)
    -- Record mission failure
    self.stats.failed_missions = self.stats.failed_missions + 1
    
    -- Reduce threat slightly (player is fighting back)
    self:escalateThreat(-0.05)
end

--- Handle mission completed event
-- @param payload Event payload
function AlienActivityManager:onMissionCompleted(payload)
    -- Record player success
    if payload.success then
        -- Player won - reduce threat
        self:escalateThreat(-0.1)
        self.stats.failed_missions = self.stats.failed_missions + 1
    else
        -- Aliens won - increase threat
        self:escalateThreat(0.15)
        self.stats.successful_missions = self.stats.successful_missions + 1
    end
end

--- Handle mission failed event
-- @param payload Event payload
function AlienActivityManager:onMissionFailed(payload)
    -- Mission expired or player refused - aliens succeed
    self:escalateThreat(0.2)
    self.stats.successful_missions = self.stats.successful_missions + 1
end

--- Get current activity state
-- @return Table with activity state
function AlienActivityManager:getState()
    return {
        phase = self.current_phase,
        threat_level = self.threat_level,
        planned_missions = #self.planned_missions,
        infiltrated_countries = self:_countInfiltratedCountries(),
        stats = self.stats
    }
end

--- Count infiltrated countries
-- @return Number of countries with infiltration > 50%
function AlienActivityManager:_countInfiltratedCountries()
    local count = 0
    for _, infiltration in pairs(self.infiltration_by_country) do
        if infiltration >= 50 then
            count = count + 1
        end
    end
    return count
end

--- Get infiltration level for country
-- @param country_id Country ID
-- @return Infiltration level (0-100)
function AlienActivityManager:getCountryInfiltration(country_id)
    return self.infiltration_by_country[country_id] or 0
end

--- Get planned missions
-- @return Array of planned missions
function AlienActivityManager:getPlannedMissions()
    return self.planned_missions
end

return AlienActivityManager
