---Metrics Collector - Collect gameplay metrics
---
---Aggregates gameplay statistics including mission success rates,
---unit performance, resource efficiency, and other key metrics.
---
---@module metrics_collector
---@author AlienFall Development Team
---@license Open Source

local MetricsCollector = {}
MetricsCollector.__index = MetricsCollector

function MetricsCollector.new()
    local self = setmetatable({}, MetricsCollector)

    self.metrics = {
        missions = {
            total = 0,
            won = 0,
            lost = 0,
            retreated = 0,
        },
        combat = {
            totalUnits = 0,
            unitKills = 0,
            unitDeaths = 0,
            friendlyFire = 0,
        },
        economy = {
            totalCost = 0,
            resourcesGenerated = 0,
            resourcesSpent = 0,
        },
        research = {
            projectsCompleted = 0,
            totalResearchTime = 0,
        },
    }

    print("[MetricsCollector] Metrics collector initialized")
    return self
end

---Record a metric value
---
---@param category string Metric category (missions, combat, economy, research)
---@param metric string Specific metric name
---@param value number The value to add
function MetricsCollector:recordMetric(category, metric, value)
    if self.metrics[category] then
        if self.metrics[category][metric] then
            self.metrics[category][metric] = self.metrics[category][metric] + value
        else
            print("[MetricsCollector] WARNING: Unknown metric: " .. category .. "." .. metric)
        end
    else
        print("[MetricsCollector] WARNING: Unknown category: " .. category)
    end
end

---Get all metrics
---
---@return table Current metrics data
function MetricsCollector:getMetrics()
    return self.metrics
end

---Get aggregated statistics
---
---@return table Summary statistics
function MetricsCollector:getStatistics()
    return {
        missionsTotal = self.metrics.missions.total,
        missionSuccessRate = self.metrics.missions.total > 0 and
            (self.metrics.missions.won / self.metrics.missions.total) or 0,
        combatKillDeathRatio = self.metrics.combat.unitDeaths > 0 and
            (self.metrics.combat.unitKills / self.metrics.combat.unitDeaths) or 0,
        resourceEfficiency = self.metrics.economy.resourcesSpent > 0 and
            (self.metrics.economy.resourcesGenerated / self.metrics.economy.resourcesSpent) or 0,
    }
end

return MetricsCollector

