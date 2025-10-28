--[[
    Difficulty Refinements System

    Advanced difficulty mechanics for late-game escalation. Includes alien leader
    emergence at high threat levels, strategic alien deployment patterns,
    psychological warfare elements, and elite enemy squads. Creates dynamic late-game
    difficulty scaling beyond simple stat multipliers.

    The system tracks:
    - Alien leader emergence and abilities
    - Strategic alien unit deployment patterns
    - Psychological warfare effects on player units
    - Elite squad composition and tactics
    - Late-game escalation mechanics
]]

local DifficultyRefinementsSystem = {}
DifficultyRefinementsSystem.__index = DifficultyRefinementsSystem

---
-- Initialize difficulty refinements system
-- @param campaign_data: Campaign data table
-- @return: New DifficultyRefinementsSystem instance
function DifficultyRefinementsSystem.new(campaign_data)
    local self = setmetatable({}, DifficultyRefinementsSystem)
    self.campaignData = campaign_data
    self.threatLevel = 0
    self.alienLeader = nil
    self.eliteSquads = {}
    self.psychological_pressure = 0
    self.morale_effects = {}
    self.tactical_depth = 0
    return self
end

---
-- Define alien leader types by threat level
-- @return: Leader template table
function DifficultyRefinementsSystem:_getAlienLeaderTemplates()
    return {
        sectoid_commander = {
            name = "Sectoid Commander",
            threat_min = 65,
            threat_max = 85,
            emergence_threshold = 70,
            health_multiplier = 2.0,
            psi_power = 1.8,
            control_range = 50,
            abilities = {
                "mind_control",
                "psionic_lance",
                "unit_coordination",
                "tactical_awareness"
            },
            tactics = "supportive",  -- Buffs allies, controls player units
            morale_penalty = 20
        },

        ethereal_supreme = {
            name = "Ethereal Supreme Being",
            threat_min = 80,
            threat_max = 100,
            emergence_threshold = 85,
            health_multiplier = 3.0,
            psi_power = 2.5,
            control_range = 80,
            abilities = {
                "mass_mind_control",
                "psionic_storm",
                "dimensional_rift",
                "unit_resurrection",
                "reality_distortion"
            },
            tactics = "omnipotent",  -- Dominates battlefield
            morale_penalty = 50
        }
    }
end

---
-- Update difficulty refinements based on threat level
-- @param threat_level: Current threat (0-100)
-- @param campaign_performance: Player performance data
function DifficultyRefinementsSystem:updateDifficultyRefinements(threat_level, campaign_performance)
    if not threat_level then
        print("[DifficultyRefinementsSystem] Invalid threat level")
        return
    end

    self.threatLevel = threat_level

    -- Check for alien leader emergence
    self:_checkAlienLeaderEmergence(threat_level)

    -- Update elite squad deployment
    self:_updateEliteSquadComposition(threat_level)

    -- Calculate psychological pressure
    self:_calculatePsychologicalPressure(threat_level, campaign_performance)

    -- Update tactical depth
    self:_updateTacticalDepth(threat_level)
end

---
-- Check if alien leader should emerge
-- @param threat_level: Current threat level
function DifficultyRefinementsSystem:_checkAlienLeaderEmergence(threat_level)
    local leader_templates = self:_getAlienLeaderTemplates()

    -- Sectoid Commander emerges at threat 70
    if threat_level >= 70 and threat_level < 85 then
        if not self.alienLeader or self.alienLeader.name ~= "Sectoid Commander" then
            self.alienLeader = {
                template = "sectoid_commander",
                name = "Sectoid Commander",
                threat_emerged = threat_level,
                health = 100,
                psi_power = leader_templates.sectoid_commander.psi_power,
                control_range = leader_templates.sectoid_commander.control_range,
                abilities = leader_templates.sectoid_commander.abilities,
                active = true
            }
        end

    -- Ethereal Supreme emerges at threat 85
    elseif threat_level >= 85 then
        if not self.alienLeader or self.alienLeader.name ~= "Ethereal Supreme Being" then
            self.alienLeader = {
                template = "ethereal_supreme",
                name = "Ethereal Supreme Being",
                threat_emerged = threat_level,
                health = 200,
                psi_power = leader_templates.ethereal_supreme.psi_power,
                control_range = leader_templates.ethereal_supreme.control_range,
                abilities = leader_templates.ethereal_supreme.abilities,
                active = true
            }
        end
    else
        self.alienLeader = nil
    end
end

---
-- Update elite squad composition based on threat
-- @param threat_level: Current threat level
function DifficultyRefinementsSystem:_updateEliteSquadComposition(threat_level)
    self.eliteSquads = {}

    -- Tier 1 Elite Squads (threat 40+)
    if threat_level >= 40 then
        table.insert(self.eliteSquads, {
            squad_id = "elite_1",
            tier = "veteran",
            composition = {
                { unit_type = "muton", count = 3, veterancy = 2 },
                { unit_type = "sectoid", count = 2, veterancy = 1 }
            },
            tactics = "aggressive_formation",
            deployment_weight = 0.3 + (threat_level - 40) / 60
        })
    end

    -- Tier 2 Elite Squads (threat 55+)
    if threat_level >= 55 then
        table.insert(self.eliteSquads, {
            squad_id = "elite_2",
            tier = "expert",
            composition = {
                { unit_type = "ethereal", count = 1, veterancy = 3 },
                { unit_type = "muton", count = 2, veterancy = 2 },
                { unit_type = "sectoid", count = 2, veterancy = 2 }
            },
            tactics = "psionic_support",
            deployment_weight = 0.2 + (threat_level - 55) / 45
        })
    end

    -- Tier 3 Elite Squads (threat 70+)
    if threat_level >= 70 then
        table.insert(self.eliteSquads, {
            squad_id = "elite_3",
            tier = "commander",
            composition = {
                { unit_type = "ethereal", count = 2, veterancy = 3 },
                { unit_type = "muton_elite", count = 2, veterancy = 3 },
                { unit_type = "sectoid", count = 1, veterancy = 2 }
            },
            tactics = "overwhelming_force",
            deployment_weight = 0.1 + (threat_level - 70) / 30
        })
    end

    -- Tier 4 Elite Squads (threat 85+)
    if threat_level >= 85 then
        table.insert(self.eliteSquads, {
            squad_id = "elite_4",
            tier = "supreme",
            composition = {
                { unit_type = "alien_leader", count = 1, veterancy = 5 },
                { unit_type = "ethereal", count = 2, veterancy = 4 },
                { unit_type = "muton_elite", count = 2, veterancy = 4 }
            },
            tactics = "dimensional_warfare",
            deployment_weight = 0.05 + (threat_level - 85) / 15
        })
    end
end

---
-- Calculate psychological pressure effects
-- @param threat_level: Current threat level
-- @param campaign_performance: Performance data {wins, losses, casualties}
function DifficultyRefinementsSystem:_calculatePsychologicalPressure(threat_level, campaign_performance)
    self.psychological_pressure = threat_level * 0.7

    if campaign_performance then
        local win_rate = campaign_performance.wins /
                        math.max(1, campaign_performance.wins + campaign_performance.losses)

        -- Losing streaks increase pressure
        if win_rate < 0.4 then
            self.psychological_pressure = self.psychological_pressure * 1.5
        elseif win_rate < 0.5 then
            self.psychological_pressure = self.psychological_pressure * 1.2
        end

        -- High casualties increase pressure
        local recent_casualties = campaign_performance.recent_casualties or 0
        if recent_casualties > 10 then
            self.psychological_pressure = self.psychological_pressure + (recent_casualties * 0.5)
        end
    end

    self.psychological_pressure = math.min(self.psychological_pressure, 100)
end

---
-- Update tactical depth of alien AI
-- @param threat_level: Current threat level
function DifficultyRefinementsSystem:_updateTacticalDepth(threat_level)
    if threat_level < 30 then
        self.tactical_depth = 1  -- Basic: direct engagement
    elseif threat_level < 50 then
        self.tactical_depth = 2  -- Intermediate: flanking, focus fire
    elseif threat_level < 70 then
        self.tactical_depth = 3  -- Advanced: cover usage, unit coordination
    elseif threat_level < 85 then
        self.tactical_depth = 4  -- Expert: psychological warfare, ambushes
    else
        self.tactical_depth = 5  -- Supreme: perfect coordination, adaptive tactics
    end
end

---
-- Get morale effects on player units
-- @return: Morale modifier table
function DifficultyRefinementsSystem:getMoraleEffects()
    self.morale_effects = {
        leadership_penalty = 0,
        panic_chance = 0,
        accuracy_penalty = 0,
        damage_penalty = 0,
        armor_penalty = 0
    }

    -- Pressure from alien leader presence
    if self.alienLeader then
        local leader_template = self:_getAlienLeaderTemplates()
        local leader_data = leader_template[self.alienLeader.template]
        if leader_data then
            self.morale_effects.leadership_penalty = leader_data.morale_penalty / 100
            self.morale_effects.panic_chance = leader_data.morale_penalty / 200
        end
    end

    -- Pressure from psychological warfare
    local pressure_factor = self.psychological_pressure / 100
    self.morale_effects.accuracy_penalty = self.morale_effects.accuracy_penalty + (pressure_factor * 0.3)
    self.morale_effects.damage_penalty = self.morale_effects.damage_penalty + (pressure_factor * 0.2)
    self.morale_effects.panic_chance = self.morale_effects.panic_chance + (pressure_factor * 0.1)

    return self.morale_effects
end

---
-- Get elite squad deployment probability
-- @return: Squad deployment info
function DifficultyRefinementsSystem:getEliteSquadDeployment()
    if #self.eliteSquads == 0 then
        return nil
    end

    -- Select squad based on weights
    local total_weight = 0
    for _, squad in pairs(self.eliteSquads) do
        total_weight = total_weight + squad.deployment_weight
    end

    local roll = math.random() * total_weight
    local current = 0

    for _, squad in pairs(self.eliteSquads) do
        current = current + squad.deployment_weight
        if roll <= current then
            return squad
        end
    end

    return self.eliteSquads[1]
end

---
-- Get alien leader status
-- @return: Leader info or nil if not emerged
function DifficultyRefinementsSystem:getAlienLeaderStatus()
    if not self.alienLeader then
        return nil
    end

    return {
        name = self.alienLeader.name,
        health = self.alienLeader.health,
        max_health = 100 * self.alienLeader.health / 100,
        psi_power = self.alienLeader.psi_power,
        control_range = self.alienLeader.control_range,
        abilities = self.alienLeader.abilities,
        threat_emerged = self.alienLeader.threat_emerged,
        active = self.alienLeader.active
    }
end

---
-- Apply psychological pressure effects to unit stats
-- @param base_stats: Unit stats table
-- @return: Modified stats with morale penalties
function DifficultyRefinementsSystem:applyPsychologicalModifiers(base_stats)
    if not base_stats then
        return base_stats
    end

    local morale = self:getMoraleEffects()

    return {
        accuracy = (base_stats.accuracy or 1.0) * (1 - morale.accuracy_penalty),
        damage = (base_stats.damage or 1.0) * (1 - morale.damage_penalty),
        armor = (base_stats.armor or 1.0) * (1 - morale.armor_penalty),
        action_points = base_stats.action_points or 100,
        panic_threshold = (base_stats.panic_threshold or 100) * (1 - morale.panic_chance)
    }
end

---
-- Get tactical difficulty modifier
-- @return: Multiplier reflecting alien tactical competence
function DifficultyRefinementsSystem:getTacticalDifficultyModifier()
    local modifiers = {
        1.0,   -- Tactical Depth 1
        1.15,  -- Tactical Depth 2
        1.35,  -- Tactical Depth 3
        1.65,  -- Tactical Depth 4
        2.0    -- Tactical Depth 5
    }

    return modifiers[math.min(self.tactical_depth, 5)]
end

---
-- Serialize refinements for save game
-- @return: Serializable table
function DifficultyRefinementsSystem:serialize()
    local serialized = {
        threatLevel = self.threatLevel,
        psychological_pressure = self.psychological_pressure,
        tactical_depth = self.tactical_depth,
        morale_effects = self.morale_effects
    }

    if self.alienLeader then
        serialized.alienLeader = {
            name = self.alienLeader.name,
            template = self.alienLeader.template,
            health = self.alienLeader.health,
            threat_emerged = self.alienLeader.threat_emerged,
            active = self.alienLeader.active
        }
    end

    serialized.eliteSquads = self.eliteSquads

    return serialized
end

---
-- Deserialize refinements from save game
-- @param data: Serialized data table
function DifficultyRefinementsSystem:deserialize(data)
    if not data then return end

    self.threatLevel = data.threatLevel or 0
    self.psychological_pressure = data.psychological_pressure or 0
    self.tactical_depth = data.tactical_depth or 0
    self.morale_effects = data.morale_effects or {}
    self.alienLeader = data.alienLeader or nil
    self.eliteSquads = data.eliteSquads or {}
end

return DifficultyRefinementsSystem

