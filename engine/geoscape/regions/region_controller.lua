---@class RegionController
---Manages all regions and coordinates regional updates
local RegionController = {}

local Region = require("engine.geoscape.regions.region")

---Create new region controller
---@param world table Generated world with regions
---@param location_system table Location system with regions
---@return RegionController
function RegionController.new(world, location_system)
    local self = {
        world = world,
        locations = location_system,
        regions = {},        -- Array of Region objects indexed by region_id
        region_map = {},     -- Map province to region_id for fast lookup
        turn = 0,
        total_income = 0,
        total_expenditure = 0,
    }

    -- Initialize regions from location_system
    if location_system and location_system.regions then
        for region_id, region_data in pairs(location_system.regions) do
            -- Create Region object
            local capital = world:getProvince(region_data.capital_x, region_data.capital_y)
            local region_name = capital and capital.cities[1] and capital.cities[1].name or "Region"

            local region = Region.new(
                region_id,
                region_name,
                "neutral",  -- Start neutral
                region_data.capital_x,
                region_data.capital_y
            )

            self.regions[region_id] = region

            -- Build province->region map for fast lookups
            for _, prov_data in ipairs(region_data.provinces) do
                local idx = prov_data.y * world.width + prov_data.x + 1
                self.region_map[idx] = region_id
            end
        end
    end

    print(string.format("[RegionController] Initialized %d regions", #self.regions))

    return setmetatable(self, {__index = RegionController})
end

---Get region by ID
---@param region_id number Region ID
---@return Region|nil
function RegionController:getRegion(region_id)
    return self.regions[region_id]
end

---Get all regions
---@return Region[]
function RegionController:getAllRegions()
    return self.regions
end

---Get region at province coordinates
---@param x number Province X
---@param y number Province Y
---@return Region|nil
function RegionController:getRegionAt(x, y)
    if not self.world then return nil end

    local idx = y * self.world.width + x + 1
    local region_id = self.region_map[idx]

    if region_id then
        return self.regions[region_id]
    end

    return nil
end

---Get all regions controlled by faction
---@param faction string Faction name ("player", "alien", or other)
---@return Region[]
function RegionController:getRegionsByFaction(faction)
    local result = {}

    for _, region in pairs(self.regions) do
        if region.faction == faction then
            table.insert(result, region)
        end
    end

    return result
end

---Get regions by control percentage
---@param min_control number Minimum control (0-1)
---@return Region[]
function RegionController:getRegionsByControlPercentage(min_control)
    local result = {}

    for _, region in pairs(self.regions) do
        if region.control_pct >= min_control then
            table.insert(result, region)
        end
    end

    return result
end

---Get region with highest strategic value
---@return Region|nil Most valuable region
function RegionController:getMostValuableRegion()
    local best_region = nil
    local best_value = -1

    for _, region in pairs(self.regions) do
        local value = region:getStrategicValue()
        if value > best_value then
            best_value = value
            best_region = region
        end
    end

    return best_region
end

---Update all regions (called each turn)
---@param turn number Current game turn
---@param global_stability number Global stability modifier (0-1)
function RegionController:update(turn, global_stability)
    self.turn = turn
    self.total_income = 0
    self.total_expenditure = 0

    for _, region in pairs(self.regions) do
        region:update(turn, global_stability)

        self.total_income = self.total_income + region.economy.income
        self.total_expenditure = self.total_expenditure + region.economy.expenditure
    end
end

---Transfer control of region
---@param region_id number Region to transfer
---@param from_faction string Previous faction
---@param to_faction string New faction
---@param reason string Reason for transfer (e.g., "mission_victory", "alien_invasion")
function RegionController:transferControl(region_id, from_faction, to_faction, reason)
    local region = self.regions[region_id]
    if not region then return false end

    print(string.format("[RegionController] %s → %s controls %s (%s)",
        from_faction, to_faction, region.name, reason or "unknown"))

    region:setControl(to_faction, 1.0)

    -- Record event
    if not region.event_history then
        region.event_history = {}
    end

    table.insert(region.event_history, {
        turn = self.turn,
        event = "control_transfer",
        from = from_faction,
        to = to_faction,
        reason = reason,
    })

    return true
end

---Apply damage to region
---@param region_id number Region ID
---@param damage_type string Damage type
---@param severity number 0-1
function RegionController:applyDamage(region_id, damage_type, severity)
    local region = self.regions[region_id]
    if not region then return end

    print(string.format("[RegionController] %s takes %s damage (severity: %.2f)",
        region.name, damage_type, severity))

    region:applyDamage(damage_type, severity)
end

---Add base to region
---@param region_id number Region ID
---@param base_id number Base ID
function RegionController:addBase(region_id, base_id)
    local region = self.regions[region_id]
    if region then
        region:addBase(base_id)
        print(string.format("[RegionController] Base %d added to %s", base_id, region.name))
    end
end

---Remove base from region
---@param region_id number Region ID
---@param base_id number Base ID
function RegionController:removeBase(region_id, base_id)
    local region = self.regions[region_id]
    if region then
        region:removeBase(base_id)
        print(string.format("[RegionController] Base %d removed from %s", base_id, region.name))
    end
end

---Get economic summary across all regions
---@return table Summary {total_income, total_expenditure, balance, player_income, alien_income}
function RegionController:getEconomicSummary()
    local player_income = 0
    local alien_income = 0

    for _, region in pairs(self.regions) do
        if region.faction == "player" then
            player_income = player_income + region.economy.income
        elseif region.faction == "alien" then
            alien_income = alien_income + region.economy.income
        end
    end

    return {
        total_income = self.total_income,
        total_expenditure = self.total_expenditure,
        balance = self.total_income - self.total_expenditure,
        player_income = player_income,
        alien_income = alien_income,
    }
end

---Get population across all regions
---@return table {total_population, player_controlled, alien_controlled}
function RegionController:getPopulationSummary()
    local total_pop = 0
    local player_pop = 0
    local alien_pop = 0

    for _, region in pairs(self.regions) do
        total_pop = total_pop + region.population

        if region.control_pct > 0.8 then
            if region.faction == "player" then
                player_pop = player_pop + region.population
            elseif region.faction == "alien" then
                alien_pop = alien_pop + region.population
            end
        end
    end

    return {
        total_population = total_pop,
        player_controlled = player_pop,
        alien_controlled = alien_pop,
    }
end

---Get average stability
---@return number Average stability (0-1)
function RegionController:getAverageStability()
    if #self.regions == 0 then return 0.5 end

    local total = 0
    for _, region in pairs(self.regions) do
        total = total + region.stability
    end

    return total / #self.regions
end

---Get average terror level
---@return number Average terror (0-1)
function RegionController:getAverageTerror()
    if #self.regions == 0 then return 0 end

    local total = 0
    for _, region in pairs(self.regions) do
        total = total + region.terror_level
    end

    return total / #self.regions
end

---Get threat level (for AI)
---@return number Threat level (0-100)
function RegionController:getThreatLevel()
    local threat = 0

    -- Add alien income as threat
    local econ = self:getEconomicSummary()
    threat = threat + (econ.alien_income / 10)

    -- Add average terror
    threat = threat + (self:getAverageTerror() * 50)

    -- Subtract player income advantage
    threat = threat - (econ.player_income / 20)

    return math.max(0, math.min(100, threat))
end

---Debug: Print controller information
function RegionController:debug()
    print("\n" .. string.rep("=", 60))
    print("REGION CONTROLLER DEBUG")
    print(string.rep("=", 60))
    print(string.format("Regions: %d", #self.regions))
    print(string.format("Turn: %d", self.turn))

    local econ = self:getEconomicSummary()
    print(string.format("Economy: +%d (income: %d, cost: %d)",
        econ.balance, econ.total_income, econ.total_expenditure))

    local pop = self:getPopulationSummary()
    print(string.format("Population: %d (player: %d, alien: %d)",
        pop.total_population, pop.player_controlled, pop.alien_controlled))

    print(string.format("Stability: %.2f | Terror: %.2f",
        self:getAverageStability(), self:getAverageTerror()))

    print(string.format("Threat Level: %.1f", self:getThreatLevel()))

    print("\nRegional Breakdown:")
    for _, region in pairs(self.regions) do
        print(string.format("  %s: faction=%s control=%.0f%% terror=%.2f value=%.1f",
            region.name, region.faction, region.control_pct * 100,
            region.terror_level, region:getStrategicValue()))
    end

    print(string.rep("=", 60) .. "\n")
end

return RegionController

