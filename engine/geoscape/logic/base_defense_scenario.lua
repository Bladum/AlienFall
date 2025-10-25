---Base Defense Scenario System
---
---Generates and manages base assault scenarios where aliens attack player bases.
---Includes: defender positioning, UFO/alien deployment, mission generation,
---base facility integration, and outcome tracking.
---
---Features:
---  - Multiple assault types: SMALL_RAID, MEDIUM_ATTACK, MAJOR_ASSAULT, SIEGE
---  - Defender wave system (initial + reinforcements)
---  - UFO deployment as aerial support
---  - Facility defensive bonuses (radar, defense, walls)
---  - Mission success = repel assault, failure = base captured/destroyed
---
---@module geoscape.logic.base_defense_scenario
---@author AlienFall Development Team

local BaseDefenseScenario = {}
BaseDefenseScenario.__index = BaseDefenseScenario

---Create new base defense scenario
---@param config table Scenario configuration
---@return table scenario Base defense scenario instance
function BaseDefenseScenario.new(config)
    local self = setmetatable({}, BaseDefenseScenario)

    -- Base info
    self.baseId = config.baseId or error("Scenario requires baseId")
    self.base = config.base or nil  -- Reference to base object

    -- Assault info
    self.assault_type = config.assault_type or "SMALL_RAID"
    self.attacking_faction = config.attacking_faction or "aliens"
    self.difficulty = config.difficulty or 1.0  -- 0.5 to 2.0 multiplier

    -- Defender configuration
    self.defender_units = config.defender_units or {}     -- Unit roster
    self.base_facilities = config.base_facilities or {}   -- Defensive facilities

    -- Attacker configuration
    self.attacker_units = {}  -- Generated based on assault type
    self.attacker_waves = {}  -- Wave definitions {turn, units}
    self.supporting_ufo = nil

    -- Mission state
    self.scenario_id = "defense_" .. config.baseId .. "_" .. os.time()
    self.status = "preparing"  -- preparing, active, succeeded, failed
    self.current_turn = 0
    self.max_turns = 30

    -- Battle tracking
    self.casualties = {
        attackers_killed = 0,
        defenders_killed = 0,
        attackers_routed = 0,
        base_damage = 0
    }

    return self
end

---Generate attacker units based on assault type
---@return table units Array of alien unit templates
function BaseDefenseScenario:generateAttackers()
    local assault_configs = {
        SMALL_RAID = {
            base_units = 3,
            faction_multiplier = 1.0,
            waves = 1,
            ufo_support = false
        },
        MEDIUM_ATTACK = {
            base_units = 8,
            faction_multiplier = 1.2,
            waves = 2,
            ufo_support = true
        },
        MAJOR_ASSAULT = {
            base_units = 15,
            faction_multiplier = 1.5,
            waves = 3,
            ufo_support = true
        },
        SIEGE = {
            base_units = 25,
            faction_multiplier = 2.0,
            waves = 4,
            ufo_support = true
        }
    }

    local config = assault_configs[self.assault_type] or assault_configs.SMALL_RAID

    -- Apply difficulty multiplier
    local total_units = math.ceil(config.base_units * config.faction_multiplier * self.difficulty)

    -- Generate unit templates (simplified - in real game would load from faction data)
    local unit_types = {"soldier", "elite", "leader"}
    local units = {}

    for i = 1, total_units do
        local unit_type = unit_types[(i % 3) + 1]
        table.insert(units, {
            id = string.format("alien_%d", i),
            type = unit_type,
            faction = self.attacking_faction,
            hp = unit_type == "leader" and 100 or (unit_type == "elite" and 80 or 60),
            morale = 80,
            weapon = "alien_rifle"
        })
    end

    print(string.format("[BaseDefense] Generated %d attacker units for %s", #units, self.assault_type))

    return units
end

---Generate attacker waves (phased reinforcements)
---@param units table All attacker units
---@param num_waves number Number of waves
function BaseDefenseScenario:generateWaves(units, num_waves)
    self.attacker_waves = {}

    num_waves = math.min(num_waves, 4)
    local units_per_wave = math.ceil(#units / num_waves)

    for wave = 1, num_waves do
        local wave_units = {}
        local start_idx = (wave - 1) * units_per_wave + 1
        local end_idx = math.min(wave * units_per_wave, #units)

        for i = start_idx, end_idx do
            table.insert(wave_units, units[i])
        end

        -- First wave deploys immediately, subsequent waves come every 5 turns
        local deployment_turn = (wave - 1) * 5

        table.insert(self.attacker_waves, {
            wave = wave,
            turn = deployment_turn,
            units = wave_units,
            status = "pending"
        })

        print(string.format("[BaseDefense] Wave %d: %d units deploy at turn %d",
              wave, #wave_units, deployment_turn))
    end
end

---Check if base has defensive facilities
---@return table defenses {radar_level, defense_power, wall_coverage}
function BaseDefenseScenario:getBaseDefenses()
    local defenses = {
        radar_level = 0,
        defense_power = 0,
        wall_coverage = 0,
        medical_bay = false,
        psi_lab = false
    }

    if not self.base or not self.base.grid then
        return defenses
    end

    -- Scan for defensive facilities
    for _, facility in ipairs(self.base.grid:getAllFacilities()) do
        if facility.typeId == "radar" then
            defenses.radar_level = facility.upgrades and #facility.upgrades or 1
        elseif facility.typeId == "defense" then
            defenses.defense_power = defenses.defense_power + 50  -- Per defense facility
        elseif facility.typeId == "walls" then
            defenses.wall_coverage = defenses.wall_coverage + 25
        elseif facility.typeId == "medical" then
            defenses.medical_bay = true
        elseif facility.typeId == "psi_lab" then
            defenses.psi_lab = true
        end
    end

    defenses.wall_coverage = math.min(100, defenses.wall_coverage)

    print(string.format("[BaseDefense] Base defenses: Radar %d, Defense %d, Walls %d%%",
          defenses.radar_level, defenses.defense_power, defenses.wall_coverage))

    return defenses
end

---Setup complete scenario
---@return boolean success
function BaseDefenseScenario:setup()
    print(string.format("[BaseDefense] Setting up %s for base %s",
          self.assault_type, self.baseId))

    -- Generate attackers
    local attackers = self:generateAttackers()
    self.attacker_units = attackers

    -- Create waves
    local wave_config = {
        SMALL_RAID = 1,
        MEDIUM_ATTACK = 2,
        MAJOR_ASSAULT = 3,
        SIEGE = 4
    }
    self:generateWaves(attackers, wave_config[self.assault_type] or 1)

    -- Check base defenses
    local defenses = self:getBaseDefenses()

    -- Generate UFO support if configured
    if self.assault_type == "MEDIUM_ATTACK" or
       self.assault_type == "MAJOR_ASSAULT" or
       self.assault_type == "SIEGE" then
        self.supporting_ufo = self:generateSupportingUFO()
    end

    -- Calculate defense bonus
    self.defense_bonus = (defenses.defense_power / 100) + (defenses.wall_coverage / 200)

    self.status = "active"
    self.current_turn = 0

    return true
end

---Generate supporting UFO (if applicable)
---@return table ufo UFO object for aerial support
function BaseDefenseScenario:generateSupportingUFO()
    local ufo = {
        id = "support_ufo_" .. self.scenario_id,
        type = "scout",  -- Or larger based on assault type
        faction = self.attacking_faction,
        hp = 150,
        max_hp = 150,
        position = {x = 0, y = 0},  -- Will be positioned above base
        weapons = {"plasma_cannon"},
        status = "hover"  -- hover, attack, retreat
    }

    print("[BaseDefense] Generated supporting UFO: " .. ufo.id)
    return ufo
end

---Process scenario turn
---@return boolean active True if scenario still active
function BaseDefenseScenario:processTurn()
    self.current_turn = self.current_turn + 1

    print(string.format("[BaseDefense] Turn %d/%d", self.current_turn, self.max_turns))

    -- Deploy reinforcement waves
    for _, wave in ipairs(self.attacker_waves) do
        if wave.status == "pending" and wave.turn <= self.current_turn then
            wave.status = "deployed"
            print(string.format("[BaseDefense] Wave %d deployed with %d units",
                  wave.wave, #wave.units))
        end
    end

    -- Update scenario state
    local scenario_active = self:evaluateScenario()

    if not scenario_active then
        self:concludeScenario()
    end

    return scenario_active
end

---Evaluate if scenario is still active
---Scenario ends if: all attackers dead/routed, defenders defeated, time limit exceeded
---@return boolean active
function BaseDefenseScenario:evaluateScenario()
    if self.current_turn >= self.max_turns then
        print("[BaseDefense] Time limit reached - defenders hold position")
        self.status = "succeeded"
        return false
    end

    -- Check if all attack waves deployed and processed
    local all_waves_deployed = true
    for _, wave in ipairs(self.attacker_waves) do
        if wave.status == "pending" then
            all_waves_deployed = false
            break
        end
    end

    if all_waves_deployed and self.casualties.attackers_killed >= #self.attacker_units then
        print("[BaseDefense] All attackers eliminated")
        self.status = "succeeded"
        return false
    end

    -- Check if defenders defeated
    if #self.defender_units > 0 and
       self.casualties.defenders_killed >= #self.defender_units then
        print("[BaseDefense] All defenders fallen")
        self.status = "failed"
        return false
    end

    return true
end

---Conclude scenario and calculate results
function BaseDefenseScenario:concludeScenario()
    print(string.format("[BaseDefense] Scenario concluded: %s", self.status))

    -- Generate results
    self.results = {
        victory = self.status == "succeeded",
        scenario_id = self.scenario_id,
        assault_type = self.assault_type,
        turns_survived = self.current_turn,
        casualties = self.casualties,
        base_damage = self.casualties.base_damage,
        base_captured = self.status == "failed",
        facilities_damaged = math.ceil(self.casualties.base_damage / 20),
        rewards = self:calculateDefenseRewards()
    }
end

---Calculate rewards for defending base
---@return table rewards {credits, research, relations}
function BaseDefenseScenario:calculateDefenseRewards()
    if self.status ~= "succeeded" then
        return {credits = 0, research = 0, relations = 0}
    end

    -- Base reward
    local reward_base = {
        SMALL_RAID = 2000,
        MEDIUM_ATTACK = 5000,
        MAJOR_ASSAULT = 10000,
        SIEGE = 20000
    }

    local base_reward = reward_base[self.assault_type] or 2000

    -- Multiplier: survivors / expected_defenders
    local survival_bonus = 1.0
    if #self.defender_units > 0 then
        local survivors = #self.defender_units - self.casualties.defenders_killed
        survival_bonus = (survivors / #self.defender_units)
    end

    -- Speed bonus: faster victory = better reward (up to 1.5x)
    local speed_bonus = 1.0 + ((self.max_turns - self.current_turn) / self.max_turns) * 0.5

    local total_multiplier = survival_bonus * speed_bonus

    return {
        credits = math.floor(base_reward * total_multiplier),
        research = math.floor(base_reward * total_multiplier / 100),
        relations = 10  -- Positive relations with controlling faction
    }
end

---Get scenario status report
---@return string report Multi-line status report
function BaseDefenseScenario:getStatusReport()
    local lines = {}

    table.insert(lines, "=== BASE DEFENSE SCENARIO ===")
    table.insert(lines, string.format("Base: %s", self.baseId))
    table.insert(lines, string.format("Assault: %s", self.assault_type))
    table.insert(lines, string.format("Status: %s", self.status))
    table.insert(lines, "")
    table.insert(lines, string.format("Turn: %d / %d", self.current_turn, self.max_turns))
    table.insert(lines, "")
    table.insert(lines, "--- FORCES ---")
    table.insert(lines, string.format("Defenders: %d (%d active, %d KIA)",
          #self.defender_units,
          #self.defender_units - self.casualties.defenders_killed,
          self.casualties.defenders_killed))
    table.insert(lines, string.format("Attackers: %d (%d active, %d KIA)",
          #self.attacker_units,
          #self.attacker_units - self.casualties.attackers_killed,
          self.casualties.attackers_killed))
    table.insert(lines, "")
    table.insert(lines, "--- DAMAGE ---")
    table.insert(lines, string.format("Base Damage: %d%%", self.casualties.base_damage))
    table.insert(lines, string.format("Facilities Damaged: %d",
          math.ceil(self.casualties.base_damage / 20)))

    return table.concat(lines, "\n")
end

---Simulate entire scenario (for quick resolution)
---@return table results Scenario results
function BaseDefenseScenario:simulate()
    self:setup()

    -- Simulate turns
    while self:processTurn() do
        -- Simulate combat outcomes
        self:simulateTurnCombat()
    end

    return self.results
end

---Simulate combat for current turn
function BaseDefenseScenario:simulateTurnCombat()
    -- Simplified: random casualties
    local attacker_losses = math.random(1, 3)
    local defender_losses = math.random(0, 2)

    self.casualties.attackers_killed = self.casualties.attackers_killed + attacker_losses
    self.casualties.defenders_killed = self.casualties.defenders_killed + defender_losses
    self.casualties.base_damage = self.casualties.base_damage + math.random(1, 5)
    self.casualties.base_damage = math.min(100, self.casualties.base_damage)

    print(string.format("[BaseDefense] Turn %d combat: -%d attackers, -%d defenders",
          self.current_turn, attacker_losses, defender_losses))
end

return BaseDefenseScenario

