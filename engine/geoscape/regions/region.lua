---@class Region
---Represents a single country/region with control, economy, and infrastructure
local Region = {}

---Create new region
---@param id number Unique region ID
---@param name string Region name
---@param faction string Initial faction ("player", "alien", or faction name)
---@param capital_x number Capital province X
---@param capital_y number Capital province Y
---@return Region
function Region.new(id, name, faction, capital_x, capital_y)
    return setmetatable({
        -- Identification
        id = id,
        name = name,
        faction = faction,
        capital_x = capital_x,
        capital_y = capital_y,

        -- Control & stability
        control = faction,
        control_pct = faction == "player" and 1.0 or 0.0,  -- 0-1, percentage of region controlled
        stability = 0.5 + (math.random() * 0.3),           -- 0-1, affects economy
        terror_level = faction == "alien" and 0.3 or 0.0,  -- 0-1, rises with attacks

        -- Population & morale
        population = 5000000 + math.floor(math.random() * 20000000),
        population_morale = 0.6,  -- 0-1, affects stability

        -- Infrastructure
        infrastructure = {
            development = 0.4 + (math.random() * 0.3),    -- 0-1, affects income
            military_strength = 0.3,                        -- 0-1, alien defense
            tech_level = 0.2 + (math.random() * 0.2),      -- 0-1, research capability
        },

        -- Economy (per turn)
        economy = {
            income = 500 + math.floor(math.random() * 500),
            expenditure = 300 + math.floor(math.random() * 300),
            balance = 0,
        },

        -- Bases & facilities
        bases = {},    -- List of base IDs located in this region
        facilities = 0,  -- Count of facilities

        -- Relations with other regions
        relations = {},  -- {region_id -> relation_value}

        -- Events
        last_event = nil,
        event_history = {},

        -- Statistics
        turn_created = 0,
    }, {__index = Region})
end

---Update region state for one turn
---@param turn number Current game turn
---@param global_stability number Global stability modifier (0-1)
function Region:update(turn, global_stability)
    global_stability = global_stability or 0.5

    -- Update stability from various factors
    local stability_delta = 0

    -- Alien terror reduces stability
    stability_delta = stability_delta - (self.terror_level * 0.1)

    -- Population morale affects stability
    stability_delta = stability_delta + ((self.population_morale - 0.5) * 0.05)

    -- Infrastructure investment increases stability
    stability_delta = stability_delta + (self.infrastructure.development * 0.05)

    -- Apply delta with damping
    self.stability = math.max(0, math.min(1, self.stability + stability_delta * 0.5))

    -- Terror level degrades over time without attacks
    if self.terror_level > 0 then
        self.terror_level = self.terror_level * 0.95  -- 5% decay per turn
    end

    -- Calculate income based on infrastructure and stability
    local income_multiplier = self.infrastructure.development * self.stability
    self.economy.income = math.floor(
        (500 + math.random() * 300) * (0.5 + income_multiplier * 0.5)
    )

    -- Calculate expenditure based on population and maintenance
    self.economy.expenditure = math.floor(
        (300 + self.infrastructure.development * 200) +
        (self.population / 10000000) * 100
    )

    -- Calculate balance
    self.economy.balance = self.economy.income - self.economy.expenditure

    -- Population changes
    local pop_growth = (self.stability - 0.5) * 0.02  -- ±2% based on stability
    pop_growth = pop_growth + (self.terror_level * -0.03)  -- Terror reduces growth
    self.population = math.floor(self.population * (1 + pop_growth))

    -- Infrastructure degradation without investment
    if self.faction ~= "player" then
        -- Neutral/alien regions degrade slowly
        self.infrastructure.development = self.infrastructure.development * 0.98
    end
end

---Apply damage to region from event
---@param damage_type string "bombardment", "terror_attack", "infestation", "occupation"
---@param severity number 0-1 severity scale
function Region:applyDamage(damage_type, severity)
    severity = math.max(0, math.min(1, severity))

    if damage_type == "bombardment" then
        -- Heavy infrastructure damage
        self.infrastructure.development = self.infrastructure.development * (1 - severity * 0.3)
        self.population = math.floor(self.population * (1 - severity * 0.1))
        self.stability = self.stability * (1 - severity * 0.2)

    elseif damage_type == "terror_attack" then
        -- Increases terror, reduces morale
        self.terror_level = math.min(1, self.terror_level + severity * 0.3)
        self.population_morale = self.population_morale * (1 - severity * 0.2)
        self.population = math.floor(self.population * (1 - severity * 0.05))

    elseif damage_type == "infestation" then
        -- Alien infestation
        self.terror_level = math.min(1, self.terror_level + severity * 0.4)
        self.control_pct = math.max(0, self.control_pct - severity * 0.2)
        self.infrastructure.military_strength = self.infrastructure.military_strength * (1 - severity * 0.15)

    elseif damage_type == "occupation" then
        -- Military occupation
        self.control_pct = math.max(0, self.control_pct - severity * 0.5)
        self.population_morale = self.population_morale * (1 - severity * 0.4)
        self.stability = self.stability * (1 - severity * 0.3)
    end

    -- Clamp all values
    self.infrastructure.development = math.max(0, self.infrastructure.development)
    self.population = math.max(0, self.population)
end

---Get strategic value of region (for AI targeting)
---@return number Strategic value score (0-100)
function Region:getStrategicValue()
    local value = 0

    -- Population value
    value = value + (self.population / 1000000)  -- Up to ~80 points

    -- Infrastructure value
    value = value + (self.infrastructure.development * 20)

    -- Control penalty (less valuable if we control it)
    if self.control_pct > 0.8 then
        value = value * 0.5
    end

    -- Terror opportunity bonus (regions ripe for takeover)
    value = value + (self.terror_level * 10)

    return math.min(100, value)
end

---Get region economic power
---@return number Economic power (0-100)
function Region:getEconomicPower()
    local power = (self.infrastructure.development * 40) +
                  ((self.population / 10000000) * 40) +
                  (math.max(0, self.economy.balance) / 1000)

    return math.min(100, math.max(0, power))
end

---Get region military strength
---@return number Military strength (0-100)
function Region:getMilitaryStrength()
    return self.infrastructure.military_strength * 100
end

---Set control of region
---@param faction string New controlling faction
---@param control_pct number Control percentage (0-1)
function Region:setControl(faction, control_pct)
    self.faction = faction
    self.control = faction
    self.control_pct = math.max(0, math.min(1, control_pct))
end

---Modify control percentage
---@param delta number Change amount (-1 to 1)
function Region:modifyControl(delta)
    self.control_pct = math.max(0, math.min(1, self.control_pct + delta))
end

---Add base to region
---@param base_id number Base ID
function Region:addBase(base_id)
    if not self.bases then
        self.bases = {}
    end
    table.insert(self.bases, base_id)
end

---Remove base from region
---@param base_id number Base ID
function Region:removeBase(base_id)
    if self.bases then
        for i, id in ipairs(self.bases) do
            if id == base_id then
                table.remove(self.bases, i)
                return
            end
        end
    end
end

---Get all bases in region
---@return number[] Array of base IDs
function Region:getBases()
    return self.bases or {}
end

---Get infrastructure bonus for player bases
---@return number Bonus multiplier (1.0 + infrastructure effect)
function Region:getInfrastructureBonus()
    local base_count = #(self.bases or {})
    return 1.0 + (base_count * 0.1) + (self.infrastructure.development * 0.3)
end

---Serialize region for save
---@return string JSON representation
function Region:serialize()
    local data = {
        id = self.id,
        name = self.name,
        faction = self.faction,
        capital_x = self.capital_x,
        capital_y = self.capital_y,
        control = self.control,
        control_pct = self.control_pct,
        stability = self.stability,
        terror_level = self.terror_level,
        population = self.population,
        population_morale = self.population_morale,
        infrastructure = self.infrastructure,
        economy = self.economy,
        bases = self.bases,
        relations = self.relations,
    }

    return require("cjson").encode(data)
end

---Deserialize region from save
---@param json string JSON data
---@return Region
function Region.deserialize(json)
    local data = require("cjson").decode(json)
    local region = Region.new(data.id, data.name, data.faction,
        data.capital_x, data.capital_y)

    -- Restore saved state
    for key, value in pairs(data) do
        region[key] = value
    end

    return region
end

---Debug: Print region information
function Region:debug()
    print(string.format("\n[Region %d] %s", self.id, self.name))
    print(string.format("  Faction: %s (%.1f%% controlled)",
        self.faction, self.control_pct * 100))
    print(string.format("  Stability: %.2f | Terror: %.2f",
        self.stability, self.terror_level))
    print(string.format("  Population: %d (morale: %.2f)",
        self.population, self.population_morale))
    print(string.format("  Development: %.2f", self.infrastructure.development))
    print(string.format("  Economy: +%d (income: %d, cost: %d)",
        self.economy.balance, self.economy.income, self.economy.expenditure))
    print(string.format("  Strategic Value: %.1f", self:getStrategicValue()))
end

return Region
