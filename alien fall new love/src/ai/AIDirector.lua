--- AIDirector.lua
-- Strategic AI system for Alien Fall
-- Manages campaign pressure, mission scheduling, and resource allocation

--- AIDirector.lua
-- Strategic AI system for Alien Fall
-- Manages campaign pressure, mission scheduling, and resource allocation

local class = require 'lib.Middleclass'
local EventBus = require 'engine.event_bus'
local RngService = require 'engine.rng'
local Telemetry = require 'engine.telemetry'

local AIDirector = class("AIDirector")

--- Authority levels for decision-making hierarchy
AIDirector.AUTHORITY_LEVELS = {
    TACTICAL = 1,    -- Immediate crisis response
    OPERATIONAL = 2, -- Theater management
    STRATEGIC = 3    -- Long-term planning
}

--- Decision cadences in game days
AIDirector.CADENCES = {
    IMMEDIATE = 0,   -- Real-time responses
    DAILY = 1,       -- Daily adjustments
    WEEKLY = 7,      -- Weekly planning
    MONTHLY = 30     -- Monthly strategy
}

function AIDirector:initialize(campaignSeed)
    self.campaignSeed = campaignSeed or 12345
    self.authorityLevel = self.AUTHORITY_LEVELS.TACTICAL
    self.legitimacy = 50  -- Campaign legitimacy (0-100)

    -- Load configuration data
    self:_loadConfiguration()

    -- Strategic priorities (weighted factors)
    self.priorities = self.config.strategic_priorities

    -- Decision timing
    self.lastDecisions = {
        monthly = 0,
        weekly = 0,
        daily = 0
    }

    -- Campaign state
    self.activeCampaign = nil
    self.campaignTemplates = {}
    self.missionQueue = {}

    -- RNG scope for deterministic behavior
    self.rng = RngService:getScope("director:" .. self.campaignSeed)

    -- Event subscriptions
    self:_setupEventListeners()

    -- Telemetry for debugging
    self.telemetry = Telemetry:getLogger("AIDirector")

    self.telemetry:log("AIDirector initialized with seed " .. self.campaignSeed)
end

function AIDirector:_loadConfiguration()
    -- Load AI configuration from TOML files
    local success, TomlLoader = pcall(require, "core.util.toml_loader")

    if success and TomlLoader then
        self.config = {
            director = TomlLoader.load("data/ai/director.toml"),
            campaigns = TomlLoader.load("data/ai/campaigns.toml"),
            weights = TomlLoader.load("data/ai/weights.toml")
        }
    else
        self.logger:warn("TOML loader not available, using default AI configuration")
        self.config = {}
    end

    -- Set default values if config not loaded
    if not self.config.director then
        self.config.director = {
            tactical_threshold = 30,
            operational_threshold = 70,
            mission_success_adjustment = -2,
            mission_failure_adjustment = 1,
            unit_destroyed_adjustment = -1,
            base_destroyed_adjustment = -10
        }
    end

    if not self.config.weights then
        self.config.weights = {
            priority_evaluation = {
                funding_threshold_high = 100000,
                interceptor_count_optimal = 20,
                coverage_optimal_ratio = 0.8,
                tech_level_max = 10,
                recent_missions_count = 10
            }
        }
    end
end

function AIDirector:update(dt)
    local currentDay = self:_getCurrentDay()

    -- Process decision cadences
    if currentDay - self.lastDecisions.monthly >= self.CADENCES.MONTHLY then
        self:_processMonthlyCadence()
        self.lastDecisions.monthly = currentDay
    end

    if currentDay - self.lastDecisions.weekly >= self.CADENCES.WEEKLY then
        self:_processWeeklyCadence()
        self.lastDecisions.weekly = currentDay
    end

    if currentDay - self.lastDecisions.daily >= self.CADENCES.DAILY then
        self:_processDailyCadence()
        self.lastDecisions.daily = currentDay
    end

    -- Process immediate responses
    self:_processImmediateActions()
end

function AIDirector:_getCurrentDay()
    -- Get current game day from turn manager
    local turnManager = require 'engine.turn_manager'
    return turnManager:getCurrentDay()
end

function AIDirector:_setupEventListeners()
    EventBus:subscribe("geoscape:mission_completed", function(event)
        self:_onMissionCompleted(event)
    end)

    EventBus:subscribe("battlescape:unit_destroyed", function(event)
        self:_onUnitDestroyed(event)
    end)

    EventBus:subscribe("finance:funding_adjusted", function(event)
        self:_onFundingAdjusted(event)
    end)

    EventBus:subscribe("geoscape:base_destroyed", function(event)
        self:_onBaseDestroyed(event)
    end)
end

function AIDirector:_evaluateStrategicPriorities()
    local priorities = {}

    -- Economic pressure evaluation
    priorities.economic = self:_evaluateEconomicPressure()

    -- Military strength assessment
    priorities.military = self:_evaluateMilitaryStrength()

    -- Geographic coverage analysis
    priorities.geographic = self:_evaluateGeographicCoverage()

    -- Research progress tracking
    priorities.research = self:_evaluateResearchProgress()

    -- Recent performance metrics
    priorities.performance = self:_evaluateRecentPerformance()

    -- Update authority level based on legitimacy
    self:_updateAuthorityLevel()

    return priorities
end

function AIDirector:_evaluateEconomicPressure()
    -- Get current funding levels and trends
    local financeService = require 'finance.FinanceService'
    local currentFunding = financeService:getMonthlyFunding()
    local debtRatio = financeService:getDebtRatio()

    -- Higher pressure when player has strong economy
    local highThreshold = self.config.weights.priority_evaluation.funding_threshold_high
    local pressure = math.min(1.0, (currentFunding / highThreshold) + (debtRatio * 0.5))
    return pressure
end

function AIDirector:_evaluateMilitaryStrength()
    -- Assess player interceptor count, base defenses, tech level
    local craftService = require 'crafts.CraftService'
    local interceptorCount = craftService:getInterceptorCount()
    local optimalCount = self.config.weights.priority_evaluation.interceptor_count_optimal

    -- Higher pressure when player is militarily weak
    local pressure = math.max(0.1, 1.0 - (interceptorCount / optimalCount))
    return pressure
end

function AIDirector:_evaluateGeographicCoverage()
    -- Analyze radar network coverage gaps
    local geoscapeService = require 'geoscape.world_model'
    local coverageRatio = geoscapeService:getGlobalCoverageRatio()
    local optimalRatio = self.config.weights.priority_evaluation.coverage_optimal_ratio

    -- Higher pressure in poorly covered areas
    local pressure = math.max(0, 1.0 - (coverageRatio / optimalRatio))
    return pressure
end

function AIDirector:_evaluateResearchProgress()
    -- Track player technological advancement
    local researchService = require 'economy.ResearchService'
    local techLevel = researchService:getOverallTechLevel()
    local maxLevel = self.config.weights.priority_evaluation.tech_level_max

    -- Higher pressure when player advances technologically
    local pressure = math.min(1.0, techLevel / maxLevel)
    return pressure
end

function AIDirector:_evaluateRecentPerformance()
    -- Analyze recent mission outcomes
    local recentMissions = self:_getRecentMissionOutcomes()
    local successRate = self:_calculatePlayerSuccessRate(recentMissions)
    local optimalRate = 0.5
    local adjustmentRange = 0.5

    -- Adjust pressure based on player performance
    local pressure = optimalRate + (optimalRate - successRate) * adjustmentRange
    return math.max(0, math.min(1.0, pressure))
end

function AIDirector:_updateAuthorityLevel()
    -- Authority escalates with legitimacy
    local tacticalMax = self.config.director.tactical_threshold
    local operationalMin = self.config.director.tactical_threshold
    local operationalMax = self.config.director.operational_threshold
    local strategicMin = self.config.director.operational_threshold

    if self.legitimacy < tacticalMax then
        self.authorityLevel = self.AUTHORITY_LEVELS.TACTICAL
    elseif self.legitimacy < operationalMax then
        self.authorityLevel = self.AUTHORITY_LEVELS.OPERATIONAL
    else
        self.authorityLevel = self.AUTHORITY_LEVELS.STRATEGIC
    end
end

function AIDirector:_processMonthlyCadence()
    self.telemetry:log("Processing monthly cadence")

    local priorities = self:_evaluateStrategicPriorities()

    -- Select or adjust campaign template
    self:_selectCampaignTemplate(priorities)

    -- Redistribute strategic resources
    self:_redistributeResources(priorities)

    -- Reassess global strategy
    self:_reassessGlobalStrategy()
end

function AIDirector:_processWeeklyCadence()
    self.telemetry:log("Processing weekly cadence")

    -- Adjust mission scheduling
    self:_adjustMissionScheduling()

    -- Update theater focus
    self:_updateTheaterFocus()
end

function AIDirector:_processDailyCadence()
    self.telemetry:log("Processing daily cadence")

    -- Schedule mission deployment timing
    self:_scheduleMissionDeployments()

    -- Respond to player developments
    self:_respondToPlayerDevelopments()
end

function AIDirector:_processImmediateActions()
    -- Handle crisis interventions and priority overrides
    self:_handleCrisisInterventions()
end

function AIDirector:_selectCampaignTemplate(priorities)
    -- Sample from weighted campaign templates based on priorities
    local templates = self:_loadCampaignTemplates()
    local selectedTemplate = self:_weightedSample(templates, priorities)

    if selectedTemplate ~= self.activeCampaign then
        self.activeCampaign = selectedTemplate
        self.telemetry:log("Selected campaign template: " .. selectedTemplate.name)

        EventBus:publish("ai:campaign_changed", {
            oldCampaign = self.activeCampaign,
            newCampaign = selectedTemplate,
            priorities = priorities
        })
    end
end

function AIDirector:_weightedSample(templates, priorities)
    -- Simple weighted sampling based on priority matching
    local totalWeight = 0
    local weights = {}

    for _, template in ipairs(templates) do
        local weight = self:_calculateTemplateWeight(template, priorities)
        weights[template] = weight
        totalWeight = totalWeight + weight
    end

    local randomValue = self.rng:random() * totalWeight
    local cumulativeWeight = 0

    for template, weight in pairs(weights) do
        cumulativeWeight = cumulativeWeight + weight
        if randomValue <= cumulativeWeight then
            return template
        end
    end

    return templates[1] -- Fallback
end

function AIDirector:_calculateTemplateWeight(template, priorities)
    -- Calculate how well template matches current priorities
    local weight = 1.0

    for priority, value in pairs(priorities) do
        if template.tags[priority] then
            weight = weight * (1 + value)
        end
    end

    return weight
end

function AIDirector:_loadCampaignTemplates()
    -- Load campaign templates from data files
    if #self.campaignTemplates == 0 then
        -- Default templates if data not loaded
        self.campaignTemplates = {
            {
                name = "invasion",
                tags = {military = true, geographic = true},
                intensity = 0.8
            },
            {
                name = "harassment",
                tags = {economic = true},
                intensity = 0.6
            },
            {
                name = "technology_focus",
                tags = {research = true},
                intensity = 0.7
            },
            {
                name = "terror",
                tags = {economic = true, performance = true},
                intensity = 0.9
            }
        }
    end

    return self.campaignTemplates
end

function AIDirector:_redistributeResources(priorities)
    -- Allocate resources across research, production, operations
    local totalResources = 100

    local researchAlloc = priorities.research * 40
    local productionAlloc = priorities.military * 35
    local operationsAlloc = priorities.geographic * 25

    self.resourceAllocation = {
        research = researchAlloc,
        production = productionAlloc,
        operations = operationsAlloc
    }

    self.telemetry:log("Resource allocation - Research: " .. researchAlloc ..
                      ", Production: " .. productionAlloc ..
                      ", Operations: " .. operationsAlloc)
end

function AIDirector:_reassessGlobalStrategy()
    -- Long-term strategic adjustments
    self:_adjustLegitimacy()
    self:_updateCampaignIntensity()
end

function AIDirector:_adjustLegitimacy()
    -- Legitimacy changes based on campaign success/failure
    local recentSuccess = self:_calculateCampaignSuccess()

    if recentSuccess > 0.6 then
        self.legitimacy = math.min(100, self.legitimacy + 5)
    elseif recentSuccess < 0.4 then
        self.legitimacy = math.max(0, self.legitimacy - 5)
    end
end

function AIDirector:_updateCampaignIntensity()
    -- Adjust campaign intensity based on player performance
    if self.activeCampaign then
        local playerStrength = self:_evaluatePlayerStrength()
        self.activeCampaign.intensity = math.max(0.3, math.min(1.0, playerStrength))
    end
end

-- Event handlers
function AIDirector:_onMissionCompleted(event)
    self.telemetry:log("Mission completed: " .. event.missionId ..
                      ", Success: " .. tostring(event.success))

    -- Adjust legitimacy based on mission outcome
    local adjustment = event.success and
                      self.config.director.mission_success_adjustment or
                      self.config.director.mission_failure_adjustment

    self.legitimacy = math.max(0, math.min(100, self.legitimacy + adjustment))
end

function AIDirector:_onUnitDestroyed(event)
    if event.isAlien then
        local adjustment = self.config.director.unit_destroyed_adjustment
        self.legitimacy = math.max(0, math.min(100, self.legitimacy + adjustment))
    end
end

function AIDirector:_onFundingAdjusted(event)
    -- Respond to significant funding changes
    if math.abs(event.change) > 10000 then
        self:_processImmediateActions()
    end
end

function AIDirector:_onBaseDestroyed(event)
    -- Major legitimacy hit
    local adjustment = self.config.director.base_destroyed_adjustment
    self.legitimacy = math.max(0, math.min(100, self.legitimacy + adjustment))

    -- Trigger tactical authority escalation
    self.authorityLevel = self.AUTHORITY_LEVELS.TACTICAL
    self:_handleCrisisInterventions()
end

-- Utility methods
function AIDirector:_getRecentMissionOutcomes()
    -- Return last 10 mission outcomes
    return {} -- Placeholder
end

function AIDirector:_calculatePlayerSuccessRate(missions)
    -- Calculate player success rate from mission outcomes
    if #missions == 0 then return 0.5 end

    local successCount = 0
    for _, mission in ipairs(missions) do
        if mission.success then
            successCount = successCount + 1
        end
    end

    return successCount / #missions
end

function AIDirector:_calculateCampaignSuccess()
    -- Calculate overall campaign success rate
    return 0.5 -- Placeholder
end

function AIDirector:_evaluatePlayerStrength()
    -- Comprehensive player strength evaluation
    return 0.5 -- Placeholder
end

function AIDirector:_adjustMissionScheduling()
    -- Adjust mission timing and frequency
end

function AIDirector:_updateTheaterFocus()
    -- Update regional focus areas
end

function AIDirector:_scheduleMissionDeployments()
    -- Schedule specific mission deployments
end

function AIDirector:_respondToPlayerDevelopments()
    -- Respond to player actions and developments
end

function AIDirector:_handleCrisisInterventions()
    -- Handle immediate crisis situations
end

-- Public interface
function AIDirector:getAuthorityLevel()
    return self.authorityLevel
end

function AIDirector:getLegitimacy()
    return self.legitimacy
end

function AIDirector:getActiveCampaign()
    return self.activeCampaign
end

function AIDirector:getResourceAllocation()
    return self.resourceAllocation
end

return AIDirector