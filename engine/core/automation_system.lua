--- Automation System
--- Handles automated task execution for base management, manufacturing, and optional combat
---
--- Allows players to delegate routine tasks to AI:
--- - Base facility construction and management
--- - Personnel assignment and training
--- - Manufacturing queue management
--- - Simple combat simulation for non-player bases
---
--- @class AutomationSystem
local AutomationSystem = {}

--- Initialize automation system
function AutomationSystem:new()
    local self = setmetatable({}, { __index = AutomationSystem })
    
    self.automationRules = {}  -- automation_id -> rule definition
    self.activeAutomation = {}  -- base_id -> {enabled automations}
    self.executedTasks = {}  -- task_id -> result
    
    -- Default automation priorities
    self.priorities = {
        ["base_defense"] = 100,
        ["facility_maintenance"] = 90,
        ["personnel_healing"] = 80,
        ["manufacturing"] = 70,
        ["research"] = 60,
        ["facility_expansion"] = 50,
    }
    
    print("[AutomationSystem] Initialized")
    return self
end

--- Load automation rules from mod configuration
--- @param ruleId string Unique rule identifier
--- @param ruleData table Automation rule from TOML
function AutomationSystem:loadRule(ruleId, ruleData)
    if not ruleData then
        print("[AutomationSystem] Warning: No data for rule " .. ruleId)
        return nil
    end
    
    local rule = {
        id = ruleId,
        name = ruleData.name or "Unknown Rule",
        description = ruleData.description or "",
        condition = ruleData.condition or "",
        action = ruleData.action or "",
        priority = ruleData.priority or 50,
        enabled = ruleData.enabled ~= false,
    }
    
    self.automationRules[ruleId] = rule
    print("[AutomationSystem] Loaded automation rule: " .. ruleId)
    return rule
end

--- Enable automation for a base
--- @param baseId string Base to automate
--- @param automationType string Type of automation ("base_management", "manufacturing", "combat")
function AutomationSystem:enableAutomation(baseId, automationType)
    if not self.activeAutomation[baseId] then
        self.activeAutomation[baseId] = {}
    end
    
    self.activeAutomation[baseId][automationType] = true
    print("[AutomationSystem] Enabled " .. automationType .. " for base " .. baseId)
    return true
end

--- Disable automation for a base
--- @param baseId string Base to disable automation
--- @param automationType string Type of automation
function AutomationSystem:disableAutomation(baseId, automationType)
    if self.activeAutomation[baseId] then
        self.activeAutomation[baseId][automationType] = nil
    end
    
    print("[AutomationSystem] Disabled " .. automationType .. " for base " .. baseId)
    return true
end

--- Check if automation is enabled for base
--- @param baseId string
--- @param automationType string
--- @return boolean
function AutomationSystem:isAutomationEnabled(baseId, automationType)
    return self.activeAutomation[baseId] and self.activeAutomation[baseId][automationType] or false
end

--- Execute base management automation
--- Handles facility construction, personnel assignment, etc.
--- @param baseId string Base to automate
--- @param baseState table Current base state
--- @return table List of tasks executed
function AutomationSystem:executeBaseManagement(baseId, baseState)
    local tasks = {}
    
    if not self:isAutomationEnabled(baseId, "base_management") then
        return tasks
    end
    
    -- Task 1: Heal wounded personnel
    if baseState.personnel and baseState.personnel.wounded > 0 then
        table.insert(tasks, {
            id = "heal_" .. baseId,
            type = "heal_personnel",
            personnel_count = baseState.personnel.wounded,
            status = "executed",
        })
    end
    
    -- Task 2: Assign idle personnel to research
    if baseState.personnel and baseState.personnel.idle > 0 then
        table.insert(tasks, {
            id = "assign_idle_" .. baseId,
            type = "assign_personnel",
            count = baseState.personnel.idle,
            target = "research",
            status = "executed",
        })
    end
    
    -- Task 3: Maintain facilities
    if baseState.facilities then
        for facilityId, facility in pairs(baseState.facilities) do
            if facility.maintenance_needed then
                table.insert(tasks, {
                    id = "maintain_" .. facilityId,
                    type = "maintain_facility",
                    facility_id = facilityId,
                    status = "executed",
                })
            end
        end
    end
    
    print("[AutomationSystem] Executed " .. #tasks .. " base management tasks for base " .. baseId)
    return tasks
end

--- Execute manufacturing automation
--- Manages production queues and resource allocation
--- @param baseId string Base to automate
--- @param baseState table Current base state
--- @return table List of manufacturing tasks
function AutomationSystem:executeManufacturing(baseId, baseState)
    local tasks = {}
    
    if not self:isAutomationEnabled(baseId, "manufacturing") then
        return tasks
    end
    
    -- Task 1: Queue priority manufacturing items
    if baseState.manufacturing then
        local priorityItems = {
            "ammo",
            "medkits",
            "grenades",
        }
        
        for _, item in ipairs(priorityItems) do
            if baseState.manufacturing.available[item] then
                table.insert(tasks, {
                    id = "manufacture_" .. item .. "_" .. baseId,
                    type = "manufacture",
                    item = item,
                    quantity = 10,
                    status = "queued",
                })
            end
        end
    end
    
    print("[AutomationSystem] Queued " .. #tasks .. " manufacturing tasks for base " .. baseId)
    return tasks
end

--- Execute combat automation for non-player battles
--- Simplified tactical AI for quick resolution
--- @param battleState table Current battle state
--- @param unitList table Units to command
--- @return table Combat actions executed
function AutomationSystem:executeCombatAutomation(battleState, unitList)
    if not self:isAutomationEnabled(battleState.base_id, "combat") then
        return {}
    end
    
    local actions = {}
    
    -- Simple AI: Move to objectives, suppress enemies
    for _, unit in ipairs(unitList) do
        local action = {
            unit_id = unit.id,
            type = "move",
            target = battleState.objective,
            status = "executed",
        }
        table.insert(actions, action)
    end
    
    print("[AutomationSystem] Executed combat automation with " .. #actions .. " actions")
    return actions
end

--- Get automation statistics
--- @param baseId string
--- @return table Statistics about automation
function AutomationSystem:getStatistics(baseId)
    return {
        tasks_executed = 0,
        tasks_failed = 0,
        time_saved_minutes = 0,
        automation_enabled_count = 0,
    }
end

--- Check if automation can be used (player level requirement)
--- @param progressionLevel number Player organization level
--- @return boolean Whether automation is available
function AutomationSystem:isAvailable(progressionLevel)
    return progressionLevel >= 2  -- Available from level 2+
end

return AutomationSystem



