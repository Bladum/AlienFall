--- Strategic Planner - Mission evaluation and resource-aware planning
---
--- Evaluates missions based on reward, risk, relations, and strategic value.
--- Provides multi-turn planning for tech development and facility goals.
--- Considers resource impact and budget constraints.
---
--- Key Features:
--- - Mission scoring (0-100 scale)
--- - Resource impact analysis
--- - Multi-turn strategic planning (3-6 months)
--- - Tech tree analysis and targeting
--- - Facility needs identification
---
--- Usage:
---   local Planner = require("engine.ai.strategic_planner")
---   local planner = Planner:new()
---   local score, details = planner:scoreMission(mission, game_state, base)
---   local ranked = planner:rankMissions(missions, game_state, base)
---
--- @module engine.ai.strategic_planner
--- @author AlienFall Development Team

local StrategicPlanner = {}
StrategicPlanner.__index = StrategicPlanner

--- Initialize Strategic Planner
---@return table StrategicPlanner instance
function StrategicPlanner:new()
    local self = setmetatable({}, StrategicPlanner)
    print("[StrategicPlanner] Initialized")
    return self
end

--- Score a mission based on multiple factors (0-100 scale)
---
---@param mission table Mission data
---@param gameState table Current game state
---@param base table Base object
---@return number Score (0-100), higher is better
---@return table Scoring details breakdown
function StrategicPlanner:scoreMission(mission, gameState, base)
    local score = 0
    local details = {}
    
    -- Validate inputs
    mission = mission or {}
    gameState = gameState or {current_tech_level = 1}
    base = base or {credits = 100000}
    
    -- FACTOR 1: Reward Value (0-40 points, 40% weight)
    -- Higher reward = higher score
    local reward_points = math.min((mission.reward or 0) / 250, 40)
    score = score + reward_points
    details.reward = {
        points = reward_points,
        weight = 0.40,
        value = mission.reward or 0
    }
    
    -- FACTOR 2: Risk Assessment (0-30 points, 30% weight)
    -- Inverted: higher difficulty = lower score
    local mission_difficulty = mission.difficulty or 1
    local tech_level = gameState.current_tech_level or 1
    
    local risk_modifier = 1.0
    if mission_difficulty > tech_level + 1 then
        risk_modifier = 0.5  -- High risk: significant penalty
    elseif mission_difficulty <= tech_level - 2 then
        risk_modifier = 1.2  -- Easy: bonus for morale/confidence
    end
    
    local risk_points = math.max(0, (30 - (mission_difficulty * 3)) * risk_modifier)
    score = score + risk_points
    details.risk = {
        points = risk_points,
        weight = 0.30,
        difficulty = mission_difficulty,
        tech_level = tech_level
    }
    
    -- FACTOR 3: Relations Impact (0-20 points, 20% weight)
    -- Missions that improve relations with useful factions get bonus
    local relations_bonus = 0
    if mission.faction_requester then
        -- Assume high relations value for key factions
        relations_bonus = 20
    else
        relations_bonus = 10  -- Neutral mission
    end
    
    local relations_points = relations_bonus
    score = score + relations_points
    details.relations = {
        points = relations_points,
        weight = 0.20,
        faction = mission.faction_requester or "Unknown"
    }
    
    -- FACTOR 4: Strategic Value (0-10 points, 10% weight)
    -- Tech unlocks, region opening, etc worth more
    local strategic_bonus = 0
    if mission.unlocks_tech then
        strategic_bonus = 10
    elseif mission.opens_region then
        strategic_bonus = 7
    elseif mission.increases_influence then
        strategic_bonus = 5
    else
        strategic_bonus = 0
    end
    
    score = score + strategic_bonus
    details.strategic = {
        points = strategic_bonus,
        weight = 0.10,
        unlocks_tech = mission.unlocks_tech or false
    }
    
    -- Time pressure multiplier
    local time_urgency = 1.0
    if mission.turns_until_deadline then
        if mission.turns_until_deadline < 3 then
            time_urgency = 1.3  -- 30% bonus for urgent missions
        elseif mission.turns_until_deadline < 6 then
            time_urgency = 1.15  -- 15% bonus for moderately urgent
        end
    end
    
    score = score * time_urgency
    details.urgency_multiplier = time_urgency
    
    -- Clamp to 0-100
    score = math.max(0, math.min(100, score))
    
    -- Generate recommendation
    if score >= 75 then
        details.recommendation = "★★★ CRITICAL - Accept immediately"
    elseif score >= 60 then
        details.recommendation = "★★ IMPORTANT - Should accept"
    elseif score >= 40 then
        details.recommendation = "★ MINOR - Optional"
    else
        details.recommendation = "○ TRIVIAL - Low priority"
    end
    
    details.final_score = score
    
    print(string.format("[StrategicPlanner] Scored mission '%s': %d (%s)",
        mission.name or "Unknown", score, details.recommendation))
    
    return score, details
end

--- Rank multiple missions by score
---
---@param missions table Array of missions
---@param gameState table Game state
---@param base table Base object
---@return table Ranked missions with scores
function StrategicPlanner:rankMissions(missions, gameState, base)
    local ranked = {}
    
    for _, mission in ipairs(missions or {}) do
        local score, details = self:scoreMission(mission, gameState, base)
        table.insert(ranked, {
            mission = mission,
            score = score,
            details = details
        })
    end
    
    -- Sort by score descending
    table.sort(ranked, function(a, b) return a.score > b.score end)
    
    print(string.format("[StrategicPlanner] Ranked %d missions", #ranked))
    
    return ranked
end

--- Get mission recommendation
---
---@param rankedMissions table Ranked missions from scoreMissions
---@return table? Best mission or nil
---@return string Recommendation text
function StrategicPlanner:getMissionRecommendation(rankedMissions)
    if not rankedMissions or #rankedMissions == 0 then
        return nil, "No available missions"
    end
    
    local top = rankedMissions[1]
    
    if top.score < 30 then
        return nil, "All missions too trivial - wait for better options"
    elseif top.score < 50 then
        return top.mission, "Limited options, consider this mission if resources allow"
    elseif top.score < 70 then
        return top.mission, "Recommended mission: " .. (top.mission.name or "Unknown")
    else
        return top.mission, "★ CRITICAL MISSION: " .. (top.mission.name or "Unknown")
    end
end

--- Analyze resource impact of a mission
---
---@param mission table Mission details
---@param base table Base object
---@return table Impact analysis
function StrategicPlanner:analyzeResourceImpact(mission, base)
    local impact = {
        ammo_cost = 0,
        personnel_loss_risk = 0,
        energy_drain = 0,
        recovery_time = 0,
        payoff_turns = 0,
        verdict = ""
    }
    
    -- Estimate ammo consumption
    local difficulty = mission.difficulty or 1
    impact.ammo_cost = difficulty * 500  -- Rough estimate: 500 per difficulty
    
    -- Personnel loss risk (percentage)
    impact.personnel_loss_risk = math.min(difficulty * 0.1, 0.5)  -- Cap at 50%
    
    -- Energy drain for equipment
    local mission_duration = mission.duration_turns or 5
    impact.energy_drain = mission_duration * 50
    
    -- Recovery time in game days
    impact.recovery_time = difficulty * 2
    
    -- Payoff calculation: months to recoup ammo cost
    local reward = mission.reward or 1000
    impact.payoff_turns = math.ceil(impact.ammo_cost / (reward / 4))
    
    -- Generate verdict
    local current_budget = base.credits or 100000
    local budget_ratio = impact.ammo_cost / current_budget
    
    if budget_ratio > 0.3 then
        impact.verdict = "✗ EXPENSIVE - Would risk budget deficit"
    elseif impact.personnel_loss_risk > 0.3 then
        impact.verdict = "⚠ RISKY - High casualty chance (30%+)"
    elseif impact.payoff_turns > 4 then
        impact.verdict = "⚠ SLOW PAYOFF - Wait for better rewards"
    else
        impact.verdict = "✓ ACCEPTABLE - Proceed with normal caution"
    end
    
    print(string.format("[StrategicPlanner] Resource impact: Ammo %d, Risk %.1f%%, Payoff %d turns - %s",
        impact.ammo_cost, impact.personnel_loss_risk * 100, impact.payoff_turns, impact.verdict))
    
    return impact
end

--- Plan strategic objectives for N turns ahead
---
---@param gameState table Game state
---@param base table Base object
---@param turns_ahead number Number of turns to plan (1-6)
---@return table Strategic plan
function StrategicPlanner:planTurns(gameState, base, turns_ahead)
    turns_ahead = math.max(1, math.min(turns_ahead or 3, 6))
    
    local plan = {
        current_turn = gameState.current_turn or 1,
        plan_horizon = turns_ahead,
        objectives = {},
        tech_targets = {},
        facility_goals = {},
        contingencies = {}
    }
    
    -- Identify key tech targets
    plan.tech_targets = self:identifyKeyTechs(gameState, base)
    
    -- Identify facility needs
    plan.facility_goals = self:identifyFacilityNeeds(base)
    
    -- Set objectives for each turn
    for turn = 1, turns_ahead do
        local turn_obj = {
            turn = plan.current_turn + turn - 1,
            primary = nil,
            secondary = {},
            budget_available = self:estimateResourcesForTurn(base, turn)
        }
        
        -- Assign primary objective based on plan
        if turn <= 2 and plan.tech_targets[1] then
            turn_obj.primary = "Research: " .. plan.tech_targets[1].name
        elseif plan.facility_goals[1] then
            turn_obj.primary = "Build: " .. plan.facility_goals[1].name
        else
            turn_obj.primary = "Explore and prepare defenses"
        end
        
        -- Add secondary objectives
        table.insert(turn_obj.secondary, "Maintain morale and supplies")
        if turn % 2 == 0 then
            table.insert(turn_obj.secondary, "Review and upgrade equipment")
        end
        
        table.insert(plan.objectives, turn_obj)
    end
    
    -- Plan contingencies
    plan.contingencies = {
        {condition = "Budget drops below 5000", action = "Reduce research spending"},
        {condition = "Personnel loss > 3", action = "Pause offensive operations"},
        {condition = "Key facility damaged", action = "Prioritize repair over expansion"},
        {condition = "Enemy power spike", action = "Focus on defensive tech research"}
    }
    
    print(string.format("[StrategicPlanner] Planned %d turns ahead", turns_ahead))
    
    return plan
end

--- Identify key technologies to unlock
---
---@param gameState table Game state with tech tree
---@param base table Base object
---@return table Top 3 tech targets
function StrategicPlanner:identifyKeyTechs(gameState, base)
    local targets = {}
    
    -- Mock tech tree if not available
    local tech_tree = gameState.tech_tree or {
        available = {
            {name = "Advanced Armor", priority = 50, unlocks_count = 2},
            {name = "Plasma Weapons", priority = 60, unlocks_count = 3},
            {name = "Psi Research", priority = 30, unlocks_count = 1}
        }
    }
    
    for _, tech in ipairs(tech_tree.available or {}) do
        local score = tech.priority or 0
        
        -- Bonus for techs that unlock other techs
        if tech.unlocks_count and tech.unlocks_count > 2 then
            score = score + 50
        end
        
        -- Bonus for combat-related techs if facing tough enemies
        local enemy_power = gameState.enemy_power_level or 0
        if enemy_power > 50 and (tech.category == "combat" or tech.category == "weapons") then
            score = score + 30
        end
        
        table.insert(targets, {
            name = tech.name,
            score = score,
            tech = tech
        })
    end
    
    -- Sort by score descending
    table.sort(targets, function(a, b) return a.score > b.score end)
    
    -- Return top 3
    local result = {}
    for i = 1, math.min(3, #targets) do
        table.insert(result, targets[i])
    end
    
    return result
end

--- Identify facility construction needs
---
---@param base table Base object
---@return table Facility goals ranked by priority
function StrategicPlanner:identifyFacilityNeeds(base)
    local needs = {}
    
    -- Mock facility counts if not available
    local lab_count = base.lab_count or 1
    local hangar_count = base.hangar_count or 1
    local barracks_count = base.barracks_count or 1
    local soldier_count = base.soldier_count or 10
    local maintenance = base.total_maintenance or 1000
    local income = base.monthly_income or 15000
    
    -- Check for research bottleneck
    if lab_count < 2 then
        table.insert(needs, {
            name = "Laboratory",
            reason = "Research bottleneck",
            priority = 80
        })
    end
    
    -- Check for craft storage
    if hangar_count < math.ceil(soldier_count / 10) then
        table.insert(needs, {
            name = "Hangar",
            reason = "Not enough craft capacity",
            priority = 60
        })
    end
    
    -- Check for barracks
    if barracks_count < 1 then
        table.insert(needs, {
            name = "Barracks",
            reason = "Need troop quarters",
            priority = 70
        })
    end
    
    -- Check for maintenance cost burden
    local maintenance_ratio = maintenance / income
    if maintenance_ratio > 0.3 then
        table.insert(needs, {
            name = "Power Generator",
            reason = "Maintenance costs too high",
            priority = 50
        })
    end
    
    -- Sort by priority descending
    table.sort(needs, function(a, b) return a.priority > b.priority end)
    
    return needs
end

--- Estimate resources available in N turns
---
---@param base table Base object
---@param turns_ahead number Number of turns ahead
---@return number Estimated available credits
function StrategicPlanner:estimateResourcesForTurn(base, turns_ahead)
    local current_budget = base.credits or 100000
    local monthly_income = base.monthly_income or 15000
    local monthly_expenses = base.monthly_expenses or 5000
    
    local net_per_turn = monthly_income - monthly_expenses
    local estimated_budget = current_budget + (net_per_turn * turns_ahead)
    
    return math.max(0, estimated_budget)
end

--- Get strategic plan summary for UI
---
---@param plan table Strategic plan
---@return string Summary text
function StrategicPlanner:getPlanSummary(plan)
    local summary = string.format(
        "STRATEGIC PLAN (%d turns)\n\n" ..
        "Tech Targets:\n",
        plan.plan_horizon
    )
    
    for i, tech in ipairs(plan.tech_targets) do
        summary = summary .. string.format("  %d. %s\n", i, tech.name)
    end
    
    summary = summary .. "\nFacility Goals:\n"
    for i, facility in ipairs(plan.facility_goals) do
        if i <= 3 then
            summary = summary .. string.format("  %d. %s\n", i, facility.name)
        end
    end
    
    summary = summary .. "\nObjectives:\n"
    for i, obj in ipairs(plan.objectives) do
        summary = summary .. string.format("  Turn %d: %s\n", obj.turn, obj.primary)
    end
    
    return summary
end

return StrategicPlanner



