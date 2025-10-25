---AI Coordinator - Master Orchestrator for AI Systems
---
---Coordinates strategic, tactical, and diplomatic AI systems. Manages decision-making
---hierarchy, threat assessment, resource awareness, and squad coordination.
---
---@module ai_coordinator
---@author AlienFall Development Team
---@license Open Source

local AICoordinator = {}
AICoordinator.__index = AICoordinator

---Initialize the AI Coordinator
---
---@return table self Reference to the AI coordinator singleton
function AICoordinator.new()
    local self = setmetatable({}, AICoordinator)

    print("[AICoordinator] Initializing AI systems...")

    self.strategic = require("ai.strategic.strategic_system")
    self.tactical = require("ai.tactical.tactical_system")
    self.diplomatic = require("ai.diplomacy.diplomatic_system")
    self.threatAssessment = require("ai.threat_assessment")
    self.resourceAwareness = require("ai.resource_awareness")
    self.squadCoordination = require("ai.squad_coordination")

    self.squads = {}
    self.threats = {}
    self.decisions = {}

    print("[AICoordinator] AI systems initialized")

    return self
end

---Update all AI systems
---
---@param dt number Delta time in seconds
function AICoordinator:update(dt)
    -- Update threat assessment
    if self.threatAssessment and self.threatAssessment.update then
        self.threatAssessment:update(dt)
    end

    -- Update resource awareness
    if self.resourceAwareness and self.resourceAwareness.update then
        self.resourceAwareness:update(dt)
    end

    -- Update tactical AI for each squad
    for _, squad in ipairs(self.squads) do
        if self.tactical and self.tactical.update then
            self.tactical:update(dt, squad)
        end
    end

    -- Update strategic AI
    if self.strategic and self.strategic.update then
        self.strategic:update(dt)
    end

    -- Update squad coordination
    if self.squadCoordination and self.squadCoordination.update then
        self.squadCoordination:update(dt, self.squads)
    end
end

---Request a tactical decision for a unit
---
---@param unit table The unit requesting a decision
---@param context table Decision context (threat level, position, objectives, etc.)
---@return table|nil The AI decision (action, target, path, etc.)
function AICoordinator:requestTacticalDecision(unit, context)
    if self.tactical and self.tactical.decide then
        return self.tactical:decide(unit, context)
    end
    return nil
end

---Request a strategic decision
---
---@param context table Strategic context (resources, threats, objectives)
---@return table|nil The strategic decision
function AICoordinator:requestStrategicDecision(context)
    if self.strategic and self.strategic.decide then
        return self.strategic:decide(context)
    end
    return nil
end

---Register a squad with the coordinator
---
---@param squad table The squad to register
function AICoordinator:registerSquad(squad)
    table.insert(self.squads, squad)
    print("[AICoordinator] Registered squad with " .. #squad.members .. " members")
end

---Get threat assessment
---
---@return table Current threat data
function AICoordinator:getThreatAssessment()
    if self.threatAssessment and self.threatAssessment.assess then
        return self.threatAssessment:assess()
    end
    return {}
end

return AICoordinator
