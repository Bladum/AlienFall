--[[
    Alien Research System

    Manages alien technology progression based on player performance and threat level.
    Aliens develop and upgrade their technology tree as the campaign progresses,
    creating competitive pressure on the player to research alien tech.

    The system tracks:
    - Alien tech nodes and completion status
    - Research progression tied to threat level
    - Alien unit type availability based on research
    - Player technology discovery from alien engagement
    - Competitive balance between player and alien advancement
]]

local AlienResearchSystem = {}
AlienResearchSystem.__index = AlienResearchSystem

---
-- Initialize alien research system
-- @param campaignData: Campaign data table
-- @return: New AlienResearchSystem instance
function AlienResearchSystem.new(campaignData)
    local self = setmetatable({}, AlienResearchSystem)
    self.campaignData = campaignData
    self.threatLevel = 0
    self.alienTechTree = self:_initializeAlienTechTree()
    self.playerDiscoveredTechs = {}
    self.alienUnitUpgrades = {}
    return self
end

---
-- Initialize the alien technology tree with all nodes
-- @return: Table containing all alien tech nodes
function AlienResearchSystem:_initializeAlienTechTree()
    return {
        -- Tier 1: Starting alien tech (available from threat 0)
        sectoid_basics = {
            name = "Sectoid Combat Doctrine",
            tier = 1,
            threat_unlock = 0,
            completion = 0,
            duration = 30,
            effects = {
                sectoid_health = 1.1,
                sectoid_accuracy = 1.05,
                sectoid_damage = 1.0
            }
        },

        -- Tier 2: Mid-game enhancement (threat 20+)
        muton_enhancement = {
            name = "Muton Physical Enhancement",
            tier = 2,
            threat_unlock = 20,
            completion = 0,
            duration = 40,
            effects = {
                muton_health = 1.2,
                muton_armor = 1.15,
                muton_strength = 1.3
            }
        },

        -- Tier 2: Psionic development (threat 25+)
        psi_development = {
            name = "Psionic Enhancement Program",
            tier = 2,
            threat_unlock = 25,
            completion = 0,
            duration = 45,
            effects = {
                psi_power = 1.2,
                psi_range = 1.15,
                psi_accuracy = 1.25
            }
        },

        -- Tier 3: Advanced armor (threat 35+)
        advanced_armor = {
            name = "Advanced Combat Armor",
            tier = 3,
            threat_unlock = 35,
            completion = 0,
            duration = 50,
            effects = {
                armor_rating = 1.3,
                armor_weight = 0.9
            }
        },

        -- Tier 3: Weapon systems (threat 40+)
        plasma_weapons = {
            name = "Plasma Weapon System",
            tier = 3,
            threat_unlock = 40,
            completion = 0,
            duration = 50,
            effects = {
                plasma_damage = 1.4,
                plasma_accuracy = 1.1
            }
        },

        -- Tier 3: UFO propulsion (threat 45+)
        ufo_propulsion = {
            name = "Advanced UFO Propulsion",
            tier = 3,
            threat_unlock = 45,
            completion = 0,
            duration = 55,
            effects = {
                ufo_speed = 1.25,
                ufo_maneuverability = 1.2
            }
        },

        -- Tier 4: Elite unit training (threat 60+)
        elite_training = {
            name = "Elite Unit Training Program",
            tier = 4,
            threat_unlock = 60,
            completion = 0,
            duration = 60,
            effects = {
                elite_accuracy = 1.35,
                elite_health = 1.25,
                elite_ai = 1.4
            }
        },

        -- Tier 4: Sectoid commander emergence (threat 65+)
        sectoid_commander = {
            name = "Sectoid Commander Evolution",
            tier = 4,
            threat_unlock = 65,
            completion = 0,
            duration = 65,
            effects = {
                commander_health = 2.0,
                commander_psi = 1.8,
                commander_control_range = 1.5
            }
        },

        -- Tier 5: Ethereal contact (threat 80+)
        ethereal_contact = {
            name = "Ethereal Contact Protocol",
            tier = 5,
            threat_unlock = 80,
            completion = 0,
            duration = 75,
            effects = {
                ethereal_psi = 2.0,
                ethereal_awareness = 1.8,
                ethereal_coordination = 2.0
            }
        }
    }
end

---
-- Update alien research based on time passage and threat level
-- @param days_passed: Number of days that have passed
-- @param current_threat: Current campaign threat level (0-100)
function AlienResearchSystem:updateAlienResearch(days_passed, current_threat)
    if not days_passed or not current_threat then
        print("[AlienResearchSystem] Invalid parameters for research update")
        return
    end

    self.threatLevel = current_threat

    for tech_id, tech_data in pairs(self.alienTechTree) do
        if tech_data then
            -- Only research if threat threshold is met
            if current_threat >= (tech_data.threat_unlock or 0) then
                -- Research progresses daily
                local research_rate = 1.0 + ((current_threat - (tech_data.threat_unlock or 0)) / 100)
                tech_data.completion = (tech_data.completion or 0) + (days_passed * research_rate)

                -- Cap at 100%
                if tech_data.completion > 100 then
                    tech_data.completion = 100
                end
            end
        end
    end
end

---
-- Get available alien unit types based on research completion
-- @return: Table of available unit types with their stat multipliers
function AlienResearchSystem:getAlienUnitComposition()
    local available_units = {}
    local unit_multipliers = {
        sectoid = { health = 1.0, accuracy = 1.0, damage = 1.0 },
        muton = { health = 1.0, armor = 1.0, strength = 1.0 },
        ethereal = { psi_power = 1.0, awareness = 1.0 },
        floater = { health = 1.0, mobility = 1.0, aim = 1.0 }
    }

    -- Apply all completed research bonuses
    for tech_id, tech_data in pairs(self.alienTechTree) do
        if tech_data and tech_data.completion and tech_data.completion >= 100 then
            if tech_data.effects then
                for effect, multiplier in pairs(tech_data.effects) do
                    if effect:find("sectoid") then
                        unit_multipliers.sectoid[effect:gsub("sectoid_", "")] =
                            (unit_multipliers.sectoid[effect:gsub("sectoid_", "")] or 1.0) * multiplier
                    elseif effect:find("muton") then
                        unit_multipliers.muton[effect:gsub("muton_", "")] =
                            (unit_multipliers.muton[effect:gsub("muton_", "")] or 1.0) * multiplier
                    elseif effect:find("psi") then
                        unit_multipliers.ethereal[effect:gsub("psi_", "")] =
                            (unit_multipliers.ethereal[effect:gsub("psi_", "")] or 1.0) * multiplier
                    end
                end
            end
        end
    end

    -- Determine which units are available based on threat
    available_units.sectoid = true  -- Always available

    if self.threatLevel >= 20 then
        available_units.muton = true
    end

    if self.threatLevel >= 25 then
        available_units.ethereal = true
    end

    if self.threatLevel >= 30 then
        available_units.floater = true
    end

    return {
        units = available_units,
        multipliers = unit_multipliers
    }
end

---
-- Record player discovery of alien technology from combat
-- @param tech_name: Name of discovered technology
-- @param source_unit: Type of alien that was carrying/using the tech
-- @param research_value: Research points gained (10-50)
function AlienResearchSystem:recordTechDiscovery(tech_name, source_unit, research_value)
    if not tech_name or not source_unit then
        print("[AlienResearchSystem] Invalid tech discovery parameters")
        return
    end

    research_value = research_value or 25

    -- Record discovered tech
    if not self.playerDiscoveredTechs[tech_name] then
        self.playerDiscoveredTechs[tech_name] = {
            first_discovered = os.time(),
            discovery_count = 1,
            total_research_gained = research_value,
            source_units = { [source_unit] = 1 }
        }
    else
        self.playerDiscoveredTechs[tech_name].discovery_count =
            (self.playerDiscoveredTechs[tech_name].discovery_count or 0) + 1
        self.playerDiscoveredTechs[tech_name].total_research_gained =
            (self.playerDiscoveredTechs[tech_name].total_research_gained or 0) + research_value

        if self.playerDiscoveredTechs[tech_name].source_units then
            self.playerDiscoveredTechs[tech_name].source_units[source_unit] =
                (self.playerDiscoveredTechs[tech_name].source_units[source_unit] or 0) + 1
        end
    end

    -- Add research points to player campaign
    if self.campaignData then
        self.campaignData.research_points = (self.campaignData.research_points or 0) + research_value
    end
end

---
-- Check if aliens have completed a major research milestone
-- @return: Table of completed milestones
function AlienResearchSystem:getCompletedResearchMilestones()
    local milestones = {}

    for tech_id, tech_data in pairs(self.alienTechTree) do
        if tech_data and tech_data.completion and tech_data.completion >= 100 then
            table.insert(milestones, {
                tech_id = tech_id,
                name = tech_data.name,
                tier = tech_data.tier,
                completed_at_threat = self.threatLevel
            })
        end
    end

    return milestones
end

---
-- Get alien research progress for UI/diagnostics
-- @return: Table with research completion percentages
function AlienResearchSystem:getResearchProgress()
    local progress = {}

    for tech_id, tech_data in pairs(self.alienTechTree) do
        if tech_data then
            progress[tech_id] = {
                name = tech_data.name,
                completion = math.min(tech_data.completion or 0, 100),
                threat_unlock = tech_data.threat_unlock or 0,
                available = (self.threatLevel or 0) >= (tech_data.threat_unlock or 0),
                tier = tech_data.tier
            }
        end
    end

    return progress
end

---
-- Calculate alien research advantage vs player
-- @param player_tech_level: Player's average technology tier (1-5)
-- @return: Advantage multiplier (>1.0 = aliens ahead, <1.0 = player ahead)
function AlienResearchSystem:calculateResearchAdvantage(player_tech_level)
    player_tech_level = player_tech_level or 1

    local completed_techs = 0
    local max_possible = 0

    for tech_id, tech_data in pairs(self.alienTechTree) do
        if tech_data then
            max_possible = max_possible + 1
            if tech_data.completion and tech_data.completion >= 100 then
                completed_techs = completed_techs + 1
            end
        end
    end

    local alien_tech_level = (completed_techs / max_possible) * 5
    local advantage = alien_tech_level / math.max(player_tech_level, 0.1)

    return math.max(0.5, math.min(advantage, 3.0))
end

---
-- Serialize research state for save game
-- @return: Serializable table
function AlienResearchSystem:serialize()
    local serialized = {
        threatLevel = self.threatLevel,
        alienTechTree = {},
        playerDiscoveredTechs = self.playerDiscoveredTechs
    }

    for tech_id, tech_data in pairs(self.alienTechTree) do
        if tech_data then
            serialized.alienTechTree[tech_id] = {
                completion = tech_data.completion or 0,
                name = tech_data.name,
                tier = tech_data.tier
            }
        end
    end

    return serialized
end

---
-- Deserialize research state from save game
-- @param data: Serialized data table
function AlienResearchSystem:deserialize(data)
    if not data then return end

    self.threatLevel = data.threatLevel or 0
    self.playerDiscoveredTechs = data.playerDiscoveredTechs or {}

    if data.alienTechTree then
        for tech_id, saved_data in pairs(data.alienTechTree) do
            if self.alienTechTree[tech_id] and saved_data then
                self.alienTechTree[tech_id].completion = saved_data.completion or 0
            end
        end
    end
end

return AlienResearchSystem
