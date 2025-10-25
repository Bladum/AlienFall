--- Diplomatic AI System - Country faction decision-making
---
--- Handles AI decisions for country factions based on relations, player power,
--- country status, and strategic objectives. Makes decisions about offers,
--- demands, alliances, and missions.
---
--- Key Features:
--- - Country status evaluation (strong/stable/weak)
--- - Player power assessment
--- - Relations-based decision making
--- - Demand and offer generation
--- - Strategic diplomatic responses
---
--- Usage:
---   local Diplomat = require("engine.ai.diplomatic_ai")
---   local dipl = Diplomat:new()
---   local decision = dipl:makeDecision(country, game_state)
---   local action = dipl:respondToPlayerAction(country, action)
---
--- @module engine.ai.diplomatic_ai
--- @author AlienFall Development Team

local DiplomaticAI = {}
DiplomaticAI.__index = DiplomaticAI

--- Decision types
DiplomaticAI.DECISIONS = {
    OFFER_ALLIANCE = "offer_alliance",
    INCREASE_DEMANDS = "increase_demands",
    REDUCE_FUNDING = "reduce_funding",
    REQUEST_HELP = "request_help",
    TRADE_OFFER = "trade_offer",
    MAINTAIN_STATUS_QUO = "maintain_status_quo",
    DIPLOMATIC_WARNING = "diplomatic_warning"
}

--- Initialize Diplomatic AI
---@return table DiplomaticAI instance
function DiplomaticAI:new()
    local self = setmetatable({}, DiplomaticAI)
    print("[DiplomaticAI] Initialized")
    return self
end

--- Make diplomatic decision for country
---
---@param country table Country faction object
---@param gameState table Current game state
---@return table Decision with type, reason, and impact
function DiplomaticAI:makeDecision(country, gameState)
    country = country or {}
    gameState = gameState or {}
    
    local decision = {
        type = nil,
        reason = nil,
        impact = {},
        urgency = "normal"
    }
    
    -- Evaluate factors
    local relations = country.relations_with_player or 0
    local player_power = self:evaluatePlayerPower(gameState)
    local country_status = self:evaluateCountryStatus(country, gameState)
    local country_power = country.military_power or 50
    
    print(string.format("[DiplomaticAI] %s - Relations: %d, Player Power: %d, Status: %s",
        country.name or "Country", relations, player_power, country_status))
    
    -- Decision logic based on combined factors
    if relations > 60 and country_status == "strong" then
        decision.type = self.DECISIONS.OFFER_ALLIANCE
        decision.reason = "Relations excellent and we are in strong position"
        decision.impact = {relations = 10, funding = 200, monthly_bonus = 500}
        
    elseif relations < -40 or player_power > (country_power * 1.5) then
        decision.type = self.DECISIONS.INCREASE_DEMANDS
        decision.reason = "Relations poor or player too strong"
        decision.impact = {relations = -10, funding_cut = 300, urgency_bonus = 100}
        
    elseif country_status == "weak" and player_power > 0 then
        decision.type = self.DECISIONS.REQUEST_HELP
        decision.reason = "We need player assistance, they are strong"
        decision.impact = {relations = 5, mission_priority = "high", reward_bonus = 1000}
        
    elseif relations < 0 and player_power < country_power then
        decision.type = self.DECISIONS.DIPLOMATIC_WARNING
        decision.reason = "Relations deteriorating and we are stronger"
        decision.impact = {relations = -15, formal_complaint = true}
        
    elseif country_status == "stable" and relations > 20 then
        decision.type = self.DECISIONS.TRADE_OFFER
        decision.reason = "Standard relations, propose trade"
        decision.impact = {relations = 2, trade_value = 100}
        
    else
        decision.type = self.DECISIONS.MAINTAIN_STATUS_QUO
        decision.reason = "Maintain current relationship"
        decision.impact = {relations = 0}
    end
    
    decision.urgency = (relations < -30 or country_status == "weak") and "high" or "normal"
    
    print(string.format("[DiplomaticAI] Decision: %s (%s) - %s",
        decision.type, decision.urgency, decision.reason))
    
    return decision
end

--- Evaluate player power level (0-200+)
---
---@param gameState table Game state
---@return number Player power assessment
function DiplomaticAI:evaluatePlayerPower(gameState)
    gameState = gameState or {}
    
    local score = 0
    
    -- Tech level (weight 25%)
    local tech_level = gameState.tech_level or 1
    score = score + (tech_level * 10)
    
    -- Budget/resources (weight 25%)
    local budget = gameState.total_budget or 100000
    score = score + math.floor((budget / 50000) * 25)
    
    -- Military strength (weight 25%)
    local total_units = 0
    local total_bases = 0
    if gameState.bases then
        for _, base in ipairs(gameState.bases) do
            total_units = total_units + (#(base.units or {}) or 0)
            total_bases = total_bases + 1
        end
    end
    score = score + (total_units * 2) + (total_bases * 10)
    
    -- Missions completed (weight 25%)
    local missions = gameState.missions_completed or 0
    score = score + (missions * 1)
    
    print(string.format("[DiplomaticAI] Player power eval: tech=%d budget=%d units=%d missions=%d → %d",
        tech_level, budget, total_units, missions, score))
    
    return score
end

--- Evaluate country's own status (weak/stable/strong)
---
---@param country table Country faction
---@param gameState table Game state
---@return string Status string
function DiplomaticAI:evaluateCountryStatus(country, gameState)
    country = country or {}
    gameState = gameState or {}
    
    local military = country.military_power or 50
    local economy = country.economic_power or 50
    local territory = country.territory_control or 50
    
    local avg_power = (military + economy + territory) / 3
    
    if avg_power > 75 then
        return "strong"
    elseif avg_power > 35 then
        return "stable"
    else
        return "weak"
    end
end

--- Respond to player diplomatic action
---
---@param country table Country faction
---@param player_action table Action from player
---@return table Response decision
function DiplomaticAI:respondToPlayerAction(country, player_action)
    country = country or {}
    player_action = player_action or {}
    
    local response = {
        action = "acknowledge",
        relations_change = 0,
        message = ""
    }
    
    if player_action.type == "request_alliance" then
        local relations = country.relations_with_player or 0
        
        if relations > 50 then
            response.action = "accept_alliance"
            response.relations_change = 20
            response.message = "We accept your proposal for alliance"
        elseif relations > 20 then
            response.action = "consider_alliance"
            response.relations_change = 5
            response.message = "We will consider your proposal"
        else
            response.action = "reject_alliance"
            response.relations_change = -10
            response.message = "We are not interested"
        end
        
    elseif player_action.type == "funding_request" then
        response.action = "partial_grant"
        response.funding_amount = math.floor((player_action.requested or 10000) * 0.7)
        response.relations_change = 2
        response.message = "We can provide partial support"
        
    elseif player_action.type == "mission_refusal" then
        response.action = "issue_warning"
        response.relations_change = -20
        response.message = "Your refusal is noted and disappointing"
        
    elseif player_action.type == "mission_success" then
        response.action = "reward_bonus"
        response.relations_change = 15
        response.reward_bonus = 1000
        response.message = "Excellent work! This exceeds our expectations"
        
    elseif player_action.type == "trade_proposal" then
        response.action = "accept_trade"
        response.relations_change = 3
        response.trade_value = player_action.value or 1000
        response.message = "This trade is acceptable"
    end
    
    print(string.format("[DiplomaticAI] Response to %s: %s (relations %+d)",
        player_action.type or "unknown", response.action, response.relations_change))
    
    return response
end

--- Generate diplomatic message
---
---@param country table Country faction
---@param message_type string Type of message
---@return string Message text
function DiplomaticAI:generateMessage(country, message_type)
    country = country or {}
    message_type = message_type or "standard"
    
    local templates = {
        standard = "We seek continued cooperation with %s.",
        threat = "Our patience grows thin with %s's actions.",
        offer = "%s, we propose a mutually beneficial trade.",
        request = "%s, we require your assistance urgently.",
        warning = "%s must comply with our demands.",
        friendly = "Our relations with %s are excellent."
    }
    
    local template = templates[message_type] or templates.standard
    local message = string.format(template, "Commander")
    
    return message
end

--- Calculate relations change from action
---
---@param action string Action type
---@param country table Country faction
---@return number Relations change (+/-)
function DiplomaticAI:calculateRelationsChange(action, country)
    country = country or {}
    
    local changes = {
        mission_success = 15,
        mission_failure = -20,
        mission_refusal = -25,
        diplomatic_contact = 5,
        trade_agreement = 10,
        funding_increase = 5,
        funding_cut = -15,
        base_attack = -50,
        alliance_offer = 20,
        threat = -30
    }
    
    local change = changes[action] or 0
    
    -- Multiply by current relations (better relations = less change)
    local relations = country.relations_with_player or 0
    if relations > 80 then
        change = change * 0.5  -- Already allied, changes are muted
    elseif relations < -80 then
        change = change * 0.5  -- Already hostile, changes are muted
    end
    
    return change
end

--- Get diplomatic status summary
---
---@param country table Country faction
---@return string Status text
function DiplomaticAI:getStatus(country)
    country = country or {}
    
    local relations = country.relations_with_player or 0
    local status_text = "NEUTRAL"
    
    if relations >= 60 then
        status_text = "ALLIED"
    elseif relations >= 30 then
        status_text = "FRIENDLY"
    elseif relations >= -30 then
        status_text = "NEUTRAL"
    elseif relations >= -60 then
        status_text = "HOSTILE"
    else
        status_text = "ENEMY"
    end
    
    return string.format("%s (%+d relations)", status_text, relations)
end

--- Predict future relations trend
---
---@param country table Country faction
---@param gameState table Game state
---@param months_ahead number Months to predict
---@return string Trend prediction
function DiplomaticAI:predictTrend(country, gameState, months_ahead)
    country = country or {}
    gameState = gameState or {}
    months_ahead = months_ahead or 3
    
    local relations = country.relations_with_player or 0
    local trend = 0
    
    -- Assess trajectory
    if country.last_relations then
        trend = relations - (country.last_relations or relations)
    end
    
    -- Project forward
    local projected = relations + (trend * months_ahead)
    projected = math.max(-100, math.min(100, projected))
    
    local trend_text = ""
    if trend > 5 then
        trend_text = "IMPROVING - Relations getting better"
    elseif trend < -5 then
        trend_text = "DETERIORATING - Relations getting worse"
    else
        trend_text = "STABLE - Relations unchanged"
    end
    
    return string.format("%s (Projected: %+d in %d months)", trend_text, projected - relations, months_ahead)
end

return DiplomaticAI




