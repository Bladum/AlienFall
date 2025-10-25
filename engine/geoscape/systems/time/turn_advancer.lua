--- Turn advancement and system orchestration
-- Manages turn progression and calls system updates in sequence
-- Coordinates all Phase 5 and earlier systems for each campaign turn
--
-- @module TurnAdvancer
-- @author AI Agent
-- @license MIT

local TurnAdvancer = {}
TurnAdvancer.__index = TurnAdvancer

--- Turn phase constants
TurnAdvancer.PHASES = {
  CALENDAR_ADVANCE = 1,
  EVENT_FIRE = 2,
  SEASONAL_EFFECTS = 3,
  FACTION_UPDATES = 4,
  MISSION_UPDATES = 5,
  TERROR_UPDATES = 6,
  REGION_UPDATES = 7,
  PLAYER_ACTIONS = 8,
  COMPLETE = 9,
}

--- Create new turn advancer
-- @return TurnAdvancer - New turn advancer instance
function TurnAdvancer.new()
  local self = setmetatable({}, TurnAdvancer)

  self.current_turn = 0
  self.turn_history = {}
  self.phase_callbacks = {}  -- Callbacks per phase
  self.global_callbacks = {} -- Post-turn callbacks
  self.performance_metrics = {}

  -- Initialize phase callback arrays
  for _, phase in pairs(self.PHASES) do
    self.phase_callbacks[phase] = {}
  end

  return self
end

--- Register callback for specific phase
-- Callbacks are called in registration order
-- Signature: callback(turn, advancer) -> void
--
-- @param phase number - Phase constant (CALENDAR_ADVANCE, etc)
-- @param callback function - Callback function(turn, advancer)
-- @param system_name string|nil - Name for debugging
-- @return number - Callback ID
function TurnAdvancer:registerPhaseCallback(phase, callback, system_name)
  if not self.phase_callbacks[phase] then
    return -1  -- Invalid phase
  end

  local callback_id = #self.phase_callbacks[phase] + 1

  table.insert(self.phase_callbacks[phase], {
    id = callback_id,
    func = callback,
    name = system_name or "unnamed",
  })

  return callback_id
end

--- Register global post-turn callback
-- Called after all phases complete
-- Signature: callback(turn, advancer) -> void
--
-- @param callback function - Callback function(turn, advancer)
-- @param system_name string|nil - Name for debugging
-- @return number - Callback ID
function TurnAdvancer:registerGlobalCallback(callback, system_name)
  local callback_id = #self.global_callbacks + 1

  table.insert(self.global_callbacks, {
    id = callback_id,
    func = callback,
    name = system_name or "unnamed",
  })

  return callback_id
end

--- Unregister phase callback
-- @param phase number - Phase constant
-- @param callback_id number - Callback ID from registration
-- @return boolean - True if unregistered
function TurnAdvancer:unregisterPhaseCallback(phase, callback_id)
  if not self.phase_callbacks[phase] then
    return false
  end

  for i, cb in ipairs(self.phase_callbacks[phase]) do
    if cb.id == callback_id then
      table.remove(self.phase_callbacks[phase], i)
      return true
    end
  end

  return false
end

--- Unregister global callback
-- @param callback_id number - Callback ID from registration
-- @return boolean - True if unregistered
function TurnAdvancer:unregisterGlobalCallback(callback_id)
  for i, cb in ipairs(self.global_callbacks) do
    if cb.id == callback_id then
      table.remove(self.global_callbacks, i)
      return true
    end
  end

  return false
end

--- Advance turn and cascade all system updates
-- Main entry point for turn progression
-- Returns metrics about execution performance
--
-- @return table - Metrics { total_time, phase_times, errors }
function TurnAdvancer:advanceTurn()
  local start_time = os.clock()
  local metrics = {
    turn = self.current_turn + 1,
    total_time = 0,
    phase_times = {},
    errors = {},
  }

  -- Increment turn
  self.current_turn = self.current_turn + 1
  local turn = self.current_turn

  print("[TurnAdvancer] Advancing to turn " .. turn)

  -- Execute each phase in order
  for phase_id, phase_name in pairs(self.PHASES) do
    if phase_id < self.PHASES.COMPLETE then
      local phase_start = os.clock()

      local ok, err = pcall(function()
        self:_executePhase(phase_id, turn)
      end)

      local phase_time = os.clock() - phase_start
      metrics.phase_times[phase_name] = phase_time

      if not ok then
        table.insert(metrics.errors, {
          phase = phase_name,
          error = err,
        })
        print("[TurnAdvancer] ERROR in phase " .. phase_name .. ": " .. err)
      end
    end
  end

  -- Execute global callbacks
  local callbacks_start = os.clock()

  for _, cb in ipairs(self.global_callbacks) do
    local ok, err = pcall(cb.func, turn, self)
    if not ok then
      table.insert(metrics.errors, {
        callback = cb.name,
        error = err,
      })
      print("[TurnAdvancer] ERROR in global callback " .. cb.name .. ": " .. err)
    end
  end

  metrics.phase_times["global_callbacks"] = os.clock() - callbacks_start

  -- Total time
  metrics.total_time = os.clock() - start_time

  -- Record in history
  table.insert(self.turn_history, metrics)

  -- Keep only last 1000 turns in history
  if #self.turn_history > 1000 then
    table.remove(self.turn_history, 1)
  end

  print("[TurnAdvancer] Turn " .. turn .. " complete in " .. string.format("%.2f", metrics.total_time * 1000) .. "ms")

  return metrics
end

--- Execute specific phase callbacks
-- @param phase number - Phase ID
-- @param turn number - Current turn
function TurnAdvancer:_executePhase(phase, turn)
  if not self.phase_callbacks[phase] then
    return
  end

  for _, cb in ipairs(self.phase_callbacks[phase]) do
    cb.func(turn, self)
  end
end

--- Get current turn
-- @return number - Current turn
function TurnAdvancer:getCurrentTurn()
  return self.current_turn
end

--- Get turn history
-- @return table - Array of turn metrics
function TurnAdvancer:getTurnHistory()
  return self.turn_history
end

--- Get average turn time
-- @return number - Average milliseconds per turn
function TurnAdvancer:getAverageTurnTime()
  if #self.turn_history == 0 then
    return 0
  end

  local total = 0
  for _, metrics in ipairs(self.turn_history) do
    total = total + metrics.total_time
  end

  return (total / #self.turn_history) * 1000  -- Convert to ms
end

--- Get slowest turn time
-- @return number|nil - Milliseconds or nil if no history
function TurnAdvancer:getSlowestTurnTime()
  if #self.turn_history == 0 then
    return nil
  end

  local slowest = 0
  for _, metrics in ipairs(self.turn_history) do
    if metrics.total_time > slowest then
      slowest = metrics.total_time
    end
  end

  return slowest * 1000  -- Convert to ms
end

--- Get turns with errors
-- @return table - Array of turn metrics with errors
function TurnAdvancer:getTurnsWithErrors()
  local error_turns = {}
  for _, metrics in ipairs(self.turn_history) do
    if #metrics.errors > 0 then
      table.insert(error_turns, metrics)
    end
  end
  return error_turns
end

--- Get performance summary
-- @return table - Summary with avg/max/errors
function TurnAdvancer:getPerformanceSummary()
  return {
    turns_advanced = self.current_turn,
    average_time_ms = self:getAverageTurnTime(),
    slowest_time_ms = self:getSlowestTurnTime(),
    error_turns = #self:getTurnsWithErrors(),
    total_errors = self:getErrorCount(),
  }
end

--- Get total error count
-- @return number - Count of errors across all turns
function TurnAdvancer:getErrorCount()
  local total = 0
  for _, metrics in ipairs(self.turn_history) do
    total = total + #metrics.errors
  end
  return total
end

--- Clear performance history
function TurnAdvancer:clearHistory()
  self.turn_history = {}
end

--- Serialize turn advancer for save/load
-- @return table - Serialized state
function TurnAdvancer:serialize()
  return {
    current_turn = self.current_turn,
    turn_history = self.turn_history,
    -- Note: callbacks are NOT serialized (system runtime state)
  }
end

--- Deserialize turn advancer from save data
-- @param data table - Serialized state
-- @return TurnAdvancer - Restored advancer
function TurnAdvancer.deserialize(data)
  local self = setmetatable({}, TurnAdvancer)

  self.current_turn = data.current_turn or 0
  self.turn_history = data.turn_history or {}
  self.phase_callbacks = {}
  self.global_callbacks = {}
  self.performance_metrics = {}

  -- Initialize phase callback arrays
  for _, phase in pairs(self.PHASES) do
    self.phase_callbacks[phase] = {}
  end

  return self
end

return TurnAdvancer

