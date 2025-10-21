--- Personnel Cost System - Personnel Salary Management
---
--- Manages personnel salaries based on role, experience level, and
--- casualty replacement costs. Provides integration with financial system
--- to calculate total personnel expenses for base operations.
---
--- Key Features:
--- - Role-based salary system (soldier, scientist, engineer, commander)
--- - Experience/rank multipliers (10-30% variation)
--- - Casualty replacement costs
--- - Personnel breakdown by type
---
--- Usage:
---   local PersonnelSystem = require("engine.economy.finance.personnel_system")
---   local salary = PersonnelSystem:calculateSalary("soldier", 3)  -- Level 3 soldier
---   local totalCosts = PersonnelSystem:calculateTotalPersonnelCosts(base)
---
--- @module engine.economy.finance.personnel_system
--- @author AlienFall Development Team

local PersonnelSystem = {}
PersonnelSystem.__index = PersonnelSystem

--- Personnel role types
PersonnelSystem.ROLES = {
    SOLDIER = "soldier",
    SCIENTIST = "scientist",
    ENGINEER = "engineer",
    COMMANDER = "commander"
}

--- Base salary by role (credits per month)
PersonnelSystem.BASE_SALARY = {
    soldier = 100,
    scientist = 150,
    engineer = 150,
    commander = 300
}

--- Experience multiplier table
--- Each experience level adds 10% to base salary (max 30%)
PersonnelSystem.EXPERIENCE_MULTIPLIER = {
    [0] = 1.0,   -- Rookie: 100%
    [1] = 1.1,   -- Level 1: 110%
    [2] = 1.2,   -- Level 2: 120%
    [3] = 1.3    -- Level 3+: 130% (capped)
}

--- Casualty replacement cost (one-time)
PersonnelSystem.CASUALTY_REPLACEMENT_COST = 500

--- Initialize Personnel System
---@return table PersonnelSystem instance
function PersonnelSystem:new()
    local self = setmetatable({}, PersonnelSystem)
    print("[PersonnelSystem] Initialized")
    return self
end

--- Calculate individual salary with experience multiplier
---
---@param role string Personnel role (soldier, scientist, engineer, commander)
---@param experienceLevel number Experience level (0-3, will be clamped)
---@return number Salary in credits per month
function PersonnelSystem:calculateSalary(role, experienceLevel)
    -- Validate role
    if not self.BASE_SALARY[role] then
        print("[PersonnelSystem] WARNING: Unknown role '" .. role .. "', using soldier")
        role = "soldier"
    end
    
    -- Get base salary
    local base = self.BASE_SALARY[role]
    
    -- Get experience multiplier (clamp to 0-3)
    experienceLevel = math.min(math.max(experienceLevel or 0, 0), 3)
    local multiplier = self.EXPERIENCE_MULTIPLIER[experienceLevel] or 1.0
    
    -- Calculate final salary
    local salary = math.floor(base * multiplier)
    
    print(string.format("[PersonnelSystem] Salary: %s (level %d) = %d",
        role, experienceLevel, salary))
    
    return salary
end

--- Calculate total monthly personnel costs for a base
---
---@param base table Base object containing personnel lists
---@return number Total personnel costs in credits
---@return table Breakdown by role
function PersonnelSystem:calculateTotalPersonnelCosts(base)
    local total = 0
    local breakdown = {
        soldiers = 0,
        scientists = 0,
        engineers = 0,
        commanders = 0,
        other = 0
    }
    
    -- Calculate soldier salaries
    if base.soldiers and #base.soldiers > 0 then
        for _, soldier in ipairs(base.soldiers) do
            local salary = self:calculateSalary("soldier", soldier.experience_level or 0)
            breakdown.soldiers = breakdown.soldiers + salary
            total = total + salary
        end
    end
    
    -- Calculate scientist salaries
    if base.scientists and #base.scientists > 0 then
        for _, scientist in ipairs(base.scientists) do
            local salary = self:calculateSalary("scientist", scientist.experience_level or 0)
            breakdown.scientists = breakdown.scientists + salary
            total = total + salary
        end
    end
    
    -- Calculate engineer salaries
    if base.engineers and #base.engineers > 0 then
        for _, engineer in ipairs(base.engineers) do
            local salary = self:calculateSalary("engineer", engineer.experience_level or 0)
            breakdown.engineers = breakdown.engineers + salary
            total = total + salary
        end
    end
    
    -- Calculate commander salaries (if any)
    if base.staff and #base.staff > 0 then
        for _, staff in ipairs(base.staff) do
            if staff.role == "commander" then
                local salary = self:calculateSalary("commander", staff.experience_level or 0)
                breakdown.commanders = breakdown.commanders + salary
                total = total + salary
            end
        end
    end
    
    print(string.format("[PersonnelSystem] Total personnel costs: %d " ..
        "(Soldiers: %d, Scientists: %d, Engineers: %d, Commanders: %d)",
        total, breakdown.soldiers, breakdown.scientists, 
        breakdown.engineers, breakdown.commanders))
    
    return total, breakdown
end

--- Handle casualty and calculate replacement cost
---
---@param base table Base object
---@param unit table Unit/personnel to remove
---@return number Cost of casualty replacement (one-time)
function PersonnelSystem:handleCasualty(base, unit)
    local cost = self.CASUALTY_REPLACEMENT_COST
    
    print(string.format("[PersonnelSystem] Casualty recorded for %s - Replacement cost: %d",
        unit.name or unit.id or "Unknown", cost))
    
    -- Remove from base personnel list
    if unit.role == "soldier" and base.soldiers then
        for i, soldier in ipairs(base.soldiers) do
            if soldier.id == unit.id then
                table.remove(base.soldiers, i)
                break
            end
        end
    elseif unit.role == "scientist" and base.scientists then
        for i, scientist in ipairs(base.scientists) do
            if scientist.id == unit.id then
                table.remove(base.scientists, i)
                break
            end
        end
    elseif unit.role == "engineer" and base.engineers then
        for i, engineer in ipairs(base.engineers) do
            if engineer.id == unit.id then
                table.remove(base.engineers, i)
                break
            end
        end
    elseif base.staff then
        for i, staff in ipairs(base.staff) do
            if staff.id == unit.id then
                table.remove(base.staff, i)
                break
            end
        end
    end
    
    return cost
end

--- Get detailed personnel breakdown including salary per person
---
---@param base table Base object
---@return table Detailed breakdown with personnel counts and costs
function PersonnelSystem:getDetailedBreakdown(base)
    local breakdown = {
        soldiers = {count = 0, total_salary = 0, by_level = {}},
        scientists = {count = 0, total_salary = 0, by_level = {}},
        engineers = {count = 0, total_salary = 0, by_level = {}},
        commanders = {count = 0, total_salary = 0, by_level = {}},
        total_personnel = 0,
        total_salary = 0
    }
    
    -- Initialize by-level counters
    for i = 0, 3 do
        breakdown.soldiers.by_level[i] = {count = 0, salary = 0}
        breakdown.scientists.by_level[i] = {count = 0, salary = 0}
        breakdown.engineers.by_level[i] = {count = 0, salary = 0}
        breakdown.commanders.by_level[i] = {count = 0, salary = 0}
    end
    
    -- Process soldiers
    if base.soldiers then
        for _, soldier in ipairs(base.soldiers) do
            local level = soldier.experience_level or 0
            local salary = self:calculateSalary("soldier", level)
            breakdown.soldiers.count = breakdown.soldiers.count + 1
            breakdown.soldiers.total_salary = breakdown.soldiers.total_salary + salary
            breakdown.soldiers.by_level[level].count = breakdown.soldiers.by_level[level].count + 1
            breakdown.soldiers.by_level[level].salary = breakdown.soldiers.by_level[level].salary + salary
        end
    end
    
    -- Process scientists
    if base.scientists then
        for _, scientist in ipairs(base.scientists) do
            local level = scientist.experience_level or 0
            local salary = self:calculateSalary("scientist", level)
            breakdown.scientists.count = breakdown.scientists.count + 1
            breakdown.scientists.total_salary = breakdown.scientists.total_salary + salary
            breakdown.scientists.by_level[level].count = breakdown.scientists.by_level[level].count + 1
            breakdown.scientists.by_level[level].salary = breakdown.scientists.by_level[level].salary + salary
        end
    end
    
    -- Process engineers
    if base.engineers then
        for _, engineer in ipairs(base.engineers) do
            local level = engineer.experience_level or 0
            local salary = self:calculateSalary("engineer", level)
            breakdown.engineers.count = breakdown.engineers.count + 1
            breakdown.engineers.total_salary = breakdown.engineers.total_salary + salary
            breakdown.engineers.by_level[level].count = breakdown.engineers.by_level[level].count + 1
            breakdown.engineers.by_level[level].salary = breakdown.engineers.by_level[level].salary + salary
        end
    end
    
    -- Process staff/commanders
    if base.staff then
        for _, staff in ipairs(base.staff) do
            if staff.role == "commander" then
                local level = staff.experience_level or 0
                local salary = self:calculateSalary("commander", level)
                breakdown.commanders.count = breakdown.commanders.count + 1
                breakdown.commanders.total_salary = breakdown.commanders.total_salary + salary
                breakdown.commanders.by_level[level].count = breakdown.commanders.by_level[level].count + 1
                breakdown.commanders.by_level[level].salary = breakdown.commanders.by_level[level].salary + salary
            end
        end
    end
    
    -- Calculate totals
    breakdown.total_personnel = breakdown.soldiers.count + breakdown.scientists.count +
                                breakdown.engineers.count + breakdown.commanders.count
    breakdown.total_salary = breakdown.soldiers.total_salary + breakdown.scientists.total_salary +
                            breakdown.engineers.total_salary + breakdown.commanders.total_salary
    
    return breakdown
end

--- Get personnel cost summary string for UI display
---
---@param base table Base object
---@return string Summary text
function PersonnelSystem:getSummary(base)
    local total, breakdown = self:calculateTotalPersonnelCosts(base)
    
    local summary = string.format(
        "Personnel Costs: %d/month\n" ..
        "  Soldiers: %d\n" ..
        "  Scientists: %d\n" ..
        "  Engineers: %d\n" ..
        "  Commanders: %d",
        total, breakdown.soldiers, breakdown.scientists,
        breakdown.engineers, breakdown.commanders
    )
    
    return summary
end

return PersonnelSystem



