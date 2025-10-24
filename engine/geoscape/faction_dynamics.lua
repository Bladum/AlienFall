--[[
    Faction Dynamics System

    Manages international relations and council politics. Faction relationships shift
    based on mission outcomes, funding decisions, and strategic choices. Council pressure
    increases with threat level, and factions may abandon the player if dissatisfaction
    grows too severe.

    The system tracks:
    - Individual faction relationships (-100 to +100)
    - Mission impact on standing
    - Funding and support pressure
    - Council demands and strategic priority
    - Potential faction abandonment mechanics
]]

local FactionDynamicsSystem = {}
FactionDynamicsSystem.__index = FactionDynamicsSystem

---
-- Initialize faction dynamics system
-- @param campaign_data: Campaign data table
-- @return: New FactionDynamicsSystem instance
function FactionDynamicsSystem.new(campaign_data)
    local self = setmetatable({}, FactionDynamicsSystem)
    self.campaignData = campaign_data
    self.factions = self:_initializeFactions()
    self.global_standing = 0
    self.council_pressure = 0
    self.pressure_events = {}
    self.faction_demands = {}
    return self
end

---
-- Initialize faction data with all nations/councils
-- @return: Faction table
function FactionDynamicsSystem:_initializeFactions()
    return {
        -- Major powers
        united_nations = {
            name = "United Nations Command",
            type = "government",
            standing = 50,
            influence = 1.0,
            funding_multiplier = 1.0,
            pressure = 0,
            demands = {},
            status = "active"
        },

        nato = {
            name = "NATO Alliance",
            type = "military",
            standing = 50,
            influence = 0.9,
            funding_multiplier = 0.9,
            pressure = 0,
            demands = {},
            status = "active"
        },

        united_states = {
            name = "United States",
            type = "nation",
            standing = 50,
            influence = 1.2,
            funding_multiplier = 1.2,
            pressure = 0,
            demands = {},
            status = "active"
        },

        europe = {
            name = "European Union",
            type = "coalition",
            standing = 50,
            influence = 0.8,
            funding_multiplier = 0.8,
            pressure = 0,
            demands = {},
            status = "active"
        },

        -- Asian powers
        russia = {
            name = "Russian Federation",
            type = "nation",
            standing = 40,
            influence = 0.9,
            funding_multiplier = 0.7,
            pressure = 0,
            demands = {},
            status = "active"
        },

        china = {
            name = "People's Republic of China",
            type = "nation",
            standing = 40,
            influence = 0.9,
            funding_multiplier = 0.7,
            pressure = 0,
            demands = {},
            status = "active"
        },

        -- Emerging powers
        india = {
            name = "India",
            type = "nation",
            standing = 45,
            influence = 0.6,
            funding_multiplier = 0.6,
            pressure = 0,
            demands = {},
            status = "active"
        },

        brazil = {
            name = "Brazil",
            type = "nation",
            standing = 45,
            influence = 0.6,
            funding_multiplier = 0.5,
            pressure = 0,
            demands = {},
            status = "active"
        },

        -- Global council
        security_council = {
            name = "Global Security Council",
            type = "council",
            standing = 50,
            influence = 2.0,
            funding_multiplier = 1.5,
            pressure = 0,
            demands = {},
            status = "active"
        }
    }
end

---
-- Update faction standing based on mission outcome
-- @param mission_result: Table with outcome data {success, casualties, objectives_completed, threat_reduction}
-- @param favored_faction: Optional faction ID that benefits most from this mission
function FactionDynamicsSystem:processMissionOutcome(mission_result, favored_faction)
    if not mission_result then
        print("[FactionDynamicsSystem] Invalid mission result")
        return
    end

    local success = mission_result.success or false
    local casualties = mission_result.casualties or 0
    local objectives = mission_result.objectives_completed or 0

    -- Base standing change
    local base_change = success and 15 or -20

    -- Objectives help reputation
    base_change = base_change + (objectives * 5)

    -- Casualties hurt reputation (but less if mission successful)
    local casualty_penalty = success and (casualties * 0.5) or (casualties * 2)
    base_change = base_change - casualty_penalty

    -- Apply changes to all factions
    for faction_id, faction_data in pairs(self.factions) do
        if faction_data then
            local change = base_change

            -- Favored faction gets extra boost
            if faction_id == favored_faction then
                change = change + 10
            end

            -- All factions affected by security council pressure
            if faction_id ~= "security_council" then
                change = change * (1.0 - (self.council_pressure / 200))
            end

            faction_data.standing = math.max(-100, math.min(100, faction_data.standing + change))
        end
    end
end

---
-- Update council pressure based on threat and time
-- @param threat_level: Current threat level (0-100)
-- @param standing_average: Average faction standing
function FactionDynamicsSystem:updateCouncilPressure(threat_level, standing_average)
    threat_level = threat_level or 0
    standing_average = standing_average or self:getAverageFactionStanding()

    -- Pressure increases with threat
    self.council_pressure = threat_level * 0.8

    -- Pressure moderated by average standing
    if standing_average > 50 then
        self.council_pressure = self.council_pressure * (1 - ((standing_average - 50) / 150))
    else
        self.council_pressure = self.council_pressure * (1 + ((50 - standing_average) / 150))
    end

    self.council_pressure = math.max(0, math.min(100, self.council_pressure))

    -- Generate council demands based on pressure
    self:_generateCouncilDemands(threat_level)
end

---
-- Generate council demands based on threat and pressure
-- @param threat_level: Current threat level
function FactionDynamicsSystem:_generateCouncilDemands(threat_level)
    self.faction_demands = {}

    if threat_level < 25 then
        table.insert(self.faction_demands, {
            type = "research",
            priority = "medium",
            description = "Accelerate alien technology research",
            funding_bonus = 0.1
        })
    elseif threat_level < 50 then
        table.insert(self.faction_demands, {
            type = "intercept",
            priority = "high",
            description = "Increase UFO interception rate to 80%",
            funding_bonus = 0.15
        })
        table.insert(self.faction_demands, {
            type = "research",
            priority = "high",
            description = "Develop advanced defensive technologies",
            funding_bonus = 0.1
        })
    elseif threat_level < 75 then
        table.insert(self.faction_demands, {
            type = "combat",
            priority = "critical",
            description = "Launch offensive campaigns against alien forces",
            funding_bonus = 0.2
        })
        table.insert(self.faction_demands, {
            type = "defense",
            priority = "high",
            description = "Establish base defense network",
            funding_bonus = 0.15
        })
    else
        table.insert(self.faction_demands, {
            type = "final_assault",
            priority = "critical",
            description = "Prepare for final confrontation with alien leadership",
            funding_bonus = 0.25
        })
    end
end

---
-- Check if any faction is on verge of abandonment
-- @return: Table of factions at risk with their status
function FactionDynamicsSystem:checkFactionStability()
    local at_risk = {}
    local abandonments = {}

    for faction_id, faction_data in pairs(self.factions) do
        if faction_data then
            -- Faction abandons if standing drops below -75
            if faction_data.standing < -75 then
                faction_data.status = "abandoned"
                table.insert(abandonments, {
                    faction = faction_id,
                    name = faction_data.name,
                    standing = faction_data.standing,
                    funding_loss = faction_data.funding_multiplier
                })

            -- Faction at risk if standing below -40
            elseif faction_data.standing < -40 then
                table.insert(at_risk, {
                    faction = faction_id,
                    name = faction_data.name,
                    standing = faction_data.standing,
                    risk_level = ((-40 - faction_data.standing) / 35)  -- 0-1 scale
                })
            end
        end
    end

    return {
        at_risk = at_risk,
        abandonments = abandonments,
        total_funding_lost = self:_calculateFundingLoss(abandonments)
    }
end

---
-- Calculate funding loss from abandoned factions
-- @param abandonments: Table of abandoned factions
-- @return: Total monthly funding loss
function FactionDynamicsSystem:_calculateFundingLoss(abandonments)
    local loss = 0
    for _, abandonment in pairs(abandonments) do
        loss = loss + (abandonment.funding_loss or 0) * 500  -- Base monthly contribution per faction
    end
    return loss
end

---
-- Get total campaign funding from all active factions
-- @param base_funding: Base monthly funding (default 1000)
-- @return: Adjusted funding amount
function FactionDynamicsSystem:calculateTotalFunding(base_funding)
    base_funding = base_funding or 1000

    local total_multiplier = 0
    local active_count = 0

    for faction_id, faction_data in pairs(self.factions) do
        if faction_data and faction_data.status == "active" then
            -- Funding multiplier affected by standing
            local standing_multiplier = 1.0 + (faction_data.standing / 100) * 0.5
            total_multiplier = total_multiplier + (faction_data.funding_multiplier * standing_multiplier)
            active_count = active_count + 1
        end
    end

    if active_count == 0 then
        return 0
    end

    local average_multiplier = total_multiplier / active_count
    return math.floor(base_funding * average_multiplier)
end

---
-- Get average faction standing (global standing)
-- @return: Average standing (-100 to 100)
function FactionDynamicsSystem:getAverageFactionStanding()
    local total = 0
    local count = 0

    for faction_id, faction_data in pairs(self.factions) do
        if faction_data then
            total = total + faction_data.standing
            count = count + 1
        end
    end

    if count == 0 then return 0 end
    return total / count
end

---
-- Get faction standing details
-- @return: Table with all faction standings
function FactionDynamicsSystem:getFactionStandings()
    local standings = {}

    for faction_id, faction_data in pairs(self.factions) do
        if faction_data then
            standings[faction_id] = {
                name = faction_data.name,
                standing = faction_data.standing,
                status = faction_data.status,
                influence = faction_data.influence,
                pressure = faction_data.pressure,
                type = faction_data.type
            }
        end
    end

    return standings
end

---
-- Record strategic choice impact on factions
-- @param choice_type: Type of strategic choice (e.g., "defend_base", "intercept_ufo", "research_direction")
-- @param affected_factions: Table of {faction_id = standing_change}
function FactionDynamicsSystem:recordStrategicChoice(choice_type, affected_factions)
    if not choice_type or not affected_factions then
        print("[FactionDynamicsSystem] Invalid strategic choice parameters")
        return
    end

    for faction_id, change in pairs(affected_factions) do
        if self.factions[faction_id] then
            self.factions[faction_id].standing =
                math.max(-100, math.min(100, self.factions[faction_id].standing + change))
        end
    end
end

---
-- Serialize faction state for save game
-- @return: Serializable table
function FactionDynamicsSystem:serialize()
    local serialized = {
        factions = {},
        global_standing = self.global_standing,
        council_pressure = self.council_pressure,
        faction_demands = self.faction_demands
    }

    for faction_id, faction_data in pairs(self.factions) do
        if faction_data then
            serialized.factions[faction_id] = {
                standing = faction_data.standing,
                status = faction_data.status,
                pressure = faction_data.pressure
            }
        end
    end

    return serialized
end

---
-- Deserialize faction state from save game
-- @param data: Serialized data table
function FactionDynamicsSystem:deserialize(data)
    if not data then return end

    self.global_standing = data.global_standing or 0
    self.council_pressure = data.council_pressure or 0
    self.faction_demands = data.faction_demands or {}

    if data.factions then
        for faction_id, saved_data in pairs(data.factions) do
            if self.factions[faction_id] and saved_data then
                self.factions[faction_id].standing = saved_data.standing or 50
                self.factions[faction_id].status = saved_data.status or "active"
                self.factions[faction_id].pressure = saved_data.pressure or 0
            end
        end
    end
end

return FactionDynamicsSystem
