-- HookManager - Comprehensive hook system for gameplay modification
-- Allows mods to intercept and modify game behavior at key points

local class = require('lib.middleclass')
local Logger = require('engine.logger')

local HookManager = class('HookManager')

-- Hook types with descriptions
HookManager.static.HOOK_TYPES = {
    -- Unit hooks
    UNIT_CREATE = "unit_create",
    UNIT_MODIFY = "unit_modify",
    UNIT_LEVEL_UP = "unit_level_up",
    UNIT_DAMAGE = "unit_damage",
    UNIT_HEAL = "unit_heal",
    UNIT_DEATH = "unit_death",
    
    -- Combat hooks
    COMBAT_START = "combat_start",
    COMBAT_END = "combat_end",
    COMBAT_DAMAGE_CALCULATE = "combat_damage_calculate",
    COMBAT_HIT_CHANCE = "combat_hit_chance",
    COMBAT_CRITICAL = "combat_critical",
    COMBAT_MISS = "combat_miss",
    
    -- Mission hooks
    MISSION_GENERATE = "mission_generate",
    MISSION_START = "mission_start",
    MISSION_END = "mission_end",
    MISSION_OBJECTIVE_CHECK = "mission_objective_check",
    
    -- Economy hooks
    ECONOMY_INCOME = "economy_income",
    ECONOMY_EXPENSE = "economy_expense",
    ECONOMY_PRODUCTION_START = "economy_production_start",
    ECONOMY_PRODUCTION_COMPLETE = "economy_production_complete",
    
    -- Research hooks
    RESEARCH_START = "research_start",
    RESEARCH_COMPLETE = "research_complete",
    RESEARCH_UNLOCK = "research_unlock",
    
    -- Base hooks
    BASE_BUILD_FACILITY = "base_build_facility",
    BASE_REMOVE_FACILITY = "base_remove_facility",
    BASE_HIRE_SOLDIER = "base_hire_soldier",
    BASE_FIRE_SOLDIER = "base_fire_soldier",
    
    -- Craft hooks
    CRAFT_CREATE = "craft_create",
    CRAFT_LAUNCH = "craft_launch",
    CRAFT_RETURN = "craft_return",
    CRAFT_DAMAGED = "craft_damaged",
    
    -- Item hooks
    ITEM_CREATE = "item_create",
    ITEM_EQUIP = "item_equip",
    ITEM_UNEQUIP = "item_unequip",
    ITEM_USE = "item_use",
    
    -- Save/Load hooks
    GAME_SAVE = "game_save",
    GAME_LOAD = "game_load",
    
    -- Generic hooks
    INIT = "init",
    UPDATE = "update",
    DRAW = "draw"
}

function HookManager:initialize()
    self.logger = Logger.new("HookManager")
    
    -- Hook registry: hook_type -> array of { mod_id, callback, priority }
    self.hooks = {}
    
    -- Initialize all hook types
    for _, hook_type in pairs(HookManager.static.HOOK_TYPES) do
        self.hooks[hook_type] = {}
    end
    
    -- Hook execution statistics
    self.stats = {
        total_calls = 0,
        total_time = 0,
        by_hook = {}
    }
    
    self.logger:info("HookManager initialized")
end

function HookManager:register(hook_type, mod_id, callback, priority)
    if not self.hooks[hook_type] then
        self.logger:warn(string.format("Unknown hook type: %s", hook_type))
        self.hooks[hook_type] = {}
    end
    
    priority = priority or 100
    
    table.insert(self.hooks[hook_type], {
        mod_id = mod_id,
        callback = callback,
        priority = priority
    })
    
    -- Sort hooks by priority (lower priority runs first)
    table.sort(self.hooks[hook_type], function(a, b)
        return a.priority < b.priority
    end)
    
    self.logger:debug(string.format("Registered hook: %s from mod %s (priority: %d)", 
        hook_type, mod_id, priority))
end

function HookManager:unregister(hook_type, mod_id)
    if not self.hooks[hook_type] then
        return false
    end
    
    local removed = 0
    for i = #self.hooks[hook_type], 1, -1 do
        if self.hooks[hook_type][i].mod_id == mod_id then
            table.remove(self.hooks[hook_type], i)
            removed = removed + 1
        end
    end
    
    if removed > 0 then
        self.logger:debug(string.format("Unregistered %d hooks of type %s from mod %s", 
            removed, hook_type, mod_id))
    end
    
    return removed > 0
end

function HookManager:unregisterAll(mod_id)
    local total_removed = 0
    
    for hook_type, _ in pairs(self.hooks) do
        total_removed = total_removed + (self:unregister(hook_type, mod_id) and 1 or 0)
    end
    
    self.logger:info(string.format("Unregistered all hooks from mod %s", mod_id))
    return total_removed
end

function HookManager:trigger(hook_type, context)
    if not self.hooks[hook_type] then
        return context
    end
    
    local hooks = self.hooks[hook_type]
    if #hooks == 0 then
        return context
    end
    
    local start_time = love.timer.getTime()
    
    -- Execute hooks in priority order
    for _, hook in ipairs(hooks) do
        local ok, result = pcall(hook.callback, context)
        
        if not ok then
            self.logger:error(string.format("Hook %s from mod %s failed: %s", 
                hook_type, hook.mod_id, tostring(result)))
        elseif result ~= nil then
            -- Hook can modify context by returning a new value
            context = result
        end
    end
    
    -- Update statistics
    local elapsed = love.timer.getTime() - start_time
    self.stats.total_calls = self.stats.total_calls + 1
    self.stats.total_time = self.stats.total_time + elapsed
    
    if not self.stats.by_hook[hook_type] then
        self.stats.by_hook[hook_type] = {
            calls = 0,
            time = 0
        }
    end
    self.stats.by_hook[hook_type].calls = self.stats.by_hook[hook_type].calls + 1
    self.stats.by_hook[hook_type].time = self.stats.by_hook[hook_type].time + elapsed
    
    return context
end

function HookManager:triggerChain(hook_type, initial_value, ...)
    if not self.hooks[hook_type] then
        return initial_value
    end
    
    local hooks = self.hooks[hook_type]
    if #hooks == 0 then
        return initial_value
    end
    
    local value = initial_value
    local args = {...}
    
    -- Execute hooks in priority order, chaining results
    for _, hook in ipairs(hooks) do
        local ok, result = pcall(hook.callback, value, unpack(args))
        
        if not ok then
            self.logger:error(string.format("Hook chain %s from mod %s failed: %s", 
                hook_type, hook.mod_id, tostring(result)))
        elseif result ~= nil then
            value = result
        end
    end
    
    return value
end

function HookManager:getHooks(hook_type)
    if not self.hooks[hook_type] then
        return {}
    end
    return self.hooks[hook_type]
end

function HookManager:getHookCount(hook_type)
    if not self.hooks[hook_type] then
        return 0
    end
    return #self.hooks[hook_type]
end

function HookManager:getAllHooks()
    local all = {}
    for hook_type, hooks in pairs(self.hooks) do
        if #hooks > 0 then
            all[hook_type] = {}
            for _, hook in ipairs(hooks) do
                table.insert(all[hook_type], {
                    mod_id = hook.mod_id,
                    priority = hook.priority
                })
            end
        end
    end
    return all
end

function HookManager:getStats()
    return self.stats
end

function HookManager:resetStats()
    self.stats = {
        total_calls = 0,
        total_time = 0,
        by_hook = {}
    }
end

function HookManager:printStatistics()
    if not self.logger then
        return
    end
    
    self.logger:info("=== Hook Statistics ===")
    self.logger:info(string.format("Total hook calls: %d", self.stats.total_calls))
    self.logger:info(string.format("Total hook time: %.2f ms", self.stats.total_time * 1000))
    
    if self.stats.total_calls > 0 then
        self.logger:info(string.format("Average time per call: %.4f ms", 
            (self.stats.total_time / self.stats.total_calls) * 1000))
    end
    
    self.logger:info("\nBy Hook Type:")
    local sorted = {}
    for hook_type, stats in pairs(self.stats.by_hook) do
        table.insert(sorted, {
            hook_type = hook_type,
            calls = stats.calls,
            time = stats.time
        })
    end
    
    table.sort(sorted, function(a, b)
        return a.time > b.time
    end)
    
    for _, entry in ipairs(sorted) do
        local avg_time = (entry.time / entry.calls) * 1000
        self.logger:info(string.format("  %s: %d calls, %.2f ms total (%.4f ms avg)", 
            entry.hook_type, entry.calls, entry.time * 1000, avg_time))
    end
    
    self.logger:info("======================")
end

-- Helper methods for common hook patterns

function HookManager:modifyValue(hook_type, base_value, context)
    -- Common pattern: allow mods to modify a numeric value
    context = context or {}
    context.value = base_value
    
    local result = self:trigger(hook_type, context)
    
    return result.value or base_value
end

function HookManager:canPerformAction(hook_type, action, context)
    -- Common pattern: check if an action is allowed
    context = context or {}
    context.action = action
    context.allowed = true
    
    local result = self:trigger(hook_type, context)
    
    return result.allowed ~= false
end

function HookManager:processData(hook_type, data, context)
    -- Common pattern: allow mods to process/modify data structures
    context = context or {}
    context.data = data
    
    local result = self:trigger(hook_type, context)
    
    return result.data or data
end

return HookManager
