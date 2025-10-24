--- Event scheduler for turn-based event triggering
-- Schedules events by turn or date, fires them at appropriate times
-- Enables narrative progression and campaign milestones
--
-- @module EventScheduler
-- @author AI Agent
-- @license MIT

local EventScheduler = {}
EventScheduler.__index = EventScheduler

--- Event type constants
EventScheduler.EVENT_TYPES = {
  RESEARCH_MILESTONE = "research_milestone",
  ALIEN_INVASION = "alien_invasion",
  UFO_SIGHTING = "ufo_sighting",
  DIPLOMATIC_INCIDENT = "diplomatic_incident",
  TERROR_ATTACK = "terror_attack",
  ALIEN_BASE_DISCOVERED = "alien_base_discovered",
  WORLD_EVENT = "world_event",
  MILESTONE_REACHED = "milestone_reached",
  SEASON_CHANGE = "season_change",
  QUARTER_CHANGE = "quarter_change",
}

--- Create new event scheduler
-- @return EventScheduler - New event scheduler instance
function EventScheduler.new()
  local self = setmetatable({}, EventScheduler)

  self.scheduled_events = {}     -- Queue of scheduled events
  self.triggered_events = {}     -- History of triggered events
  self.event_id_counter = 1

  return self
end

--- Schedule event for specific turn
-- @param turn number - Turn to fire event
-- @param event_type string - Event type
-- @param event_data table - Event-specific data
-- @param priority number|nil - Priority (1=lowest, 5=highest, default 3)
-- @param repeating boolean|nil - If true, repeats annually
-- @return number - Event ID
function EventScheduler:scheduleEvent(turn, event_type, event_data, priority, repeating)
  local event_id = self.event_id_counter
  self.event_id_counter = self.event_id_counter + 1

  local event = {
    id = event_id,
    type = event_type,
    turn_scheduled = turn,
    turn_fired = nil,
    priority = priority or 3,
    repeating = repeating or false,
    data = event_data or {},
    status = "scheduled",
  }

  table.insert(self.scheduled_events, event)
  return event_id
end

--- Schedule event for specific calendar date
-- Requires calendar object to convert date to turn
-- @param month number - Month (1-12)
-- @param day number - Day of month
-- @param event_type string - Event type
-- @param event_data table - Event data
-- @param calendar table - Calendar object for date conversion
-- @param priority number|nil - Event priority
-- @param repeating boolean|nil - If true, repeats yearly
-- @return number - Event ID
function EventScheduler:scheduleDateEvent(month, day, event_type, event_data, calendar, priority, repeating)
  if not calendar then
    return -1  -- Invalid without calendar
  end

  -- Calculate turn when this date occurs
  local days_until = calendar:daysUntil(month, day)
  local target_turn = calendar.turn + days_until

  return self:scheduleEvent(target_turn, event_type, event_data, priority, repeating)
end

--- Cancel scheduled event
-- @param event_id number - Event ID to cancel
-- @return boolean - True if cancelled
function EventScheduler:cancelEvent(event_id)
  for i, event in ipairs(self.scheduled_events) do
    if event.id == event_id then
      table.remove(self.scheduled_events, i)
      return true
    end
  end
  return false
end

--- Update and fire events for current turn
-- Called once per campaign turn
-- @param turn number - Current turn
-- @param calendar table|nil - Calendar for date queries
-- @return table - Events that fired this turn
function EventScheduler:updateAndFire(turn, calendar)
  local fired_events = {}
  local events_to_remove = {}

  -- Sort by priority (highest first)
  table.sort(self.scheduled_events, function(a, b)
    return a.priority > b.priority
  end)

  -- Check all scheduled events
  for i, event in ipairs(self.scheduled_events) do
    if event.turn_scheduled <= turn and event.status == "scheduled" then
      -- Fire event
      event.turn_fired = turn
      event.status = "fired"

      table.insert(fired_events, event)

      -- Handle repeating events
      if event.repeating then
        -- Reschedule for next year (365 days later)
        local repeat_event = {
          id = self.event_id_counter,
          type = event.type,
          turn_scheduled = turn + 365,  -- Approximately 1 year
          turn_fired = nil,
          priority = event.priority,
          repeating = event.repeating,
          data = event.data,
          status = "scheduled",
        }
        self.event_id_counter = self.event_id_counter + 1
        table.insert(self.scheduled_events, repeat_event)

        -- Mark original for removal (after repeat is added)
        table.insert(events_to_remove, i)
      else
        table.insert(events_to_remove, i)
      end
    end
  end

  -- Remove fired events (in reverse to maintain indices)
  for i = #events_to_remove, 1, -1 do
    if not self.scheduled_events[events_to_remove[i]].repeating then
      table.remove(self.scheduled_events, events_to_remove[i])
    end
  end

  -- Record in history
  for _, event in ipairs(fired_events) do
    table.insert(self.triggered_events, {
      id = event.id,
      type = event.type,
      turn_fired = turn,
      data = event.data,
    })

    -- Keep only last 100 triggered events
    if #self.triggered_events > 100 then
      table.remove(self.triggered_events, 1)
    end
  end

  return fired_events
end

--- Get all scheduled events (upcoming)
-- @return table - Array of scheduled events
function EventScheduler:getScheduledEvents()
  local events = {}
  for _, event in ipairs(self.scheduled_events) do
    if event.status == "scheduled" then
      table.insert(events, event)
    end
  end
  return events
end

--- Get triggered events (history)
-- @return table - Array of triggered events
function EventScheduler:getTriggeredEvents()
  return self.triggered_events
end

--- Get triggered events of specific type
-- @param event_type string - Event type filter
-- @return table - Events matching type
function EventScheduler:getTriggeredEventsByType(event_type)
  local events = {}
  for _, event in ipairs(self.triggered_events) do
    if event.type == event_type then
      table.insert(events, event)
    end
  end
  return events
end

--- Get next scheduled event
-- @return table|nil - Next event or nil
function EventScheduler:getNextEvent()
  if #self.scheduled_events == 0 then
    return nil
  end

  -- Find earliest scheduled event
  local earliest = self.scheduled_events[1]
  for _, event in ipairs(self.scheduled_events) do
    if event.status == "scheduled" and event.turn_scheduled < earliest.turn_scheduled then
      earliest = event
    end
  end

  return earliest.status == "scheduled" and earliest or nil
end

--- Get events scheduled for specific turn range
-- @param turn_start number - Start turn
-- @param turn_end number - End turn
-- @return table - Events in range
function EventScheduler:getEventsInRange(turn_start, turn_end)
  local events = {}
  for _, event in ipairs(self.scheduled_events) do
    if event.status == "scheduled" and event.turn_scheduled >= turn_start and event.turn_scheduled <= turn_end then
      table.insert(events, event)
    end
  end
  return events
end

--- Get scheduled event count
-- @return number - Count of pending events
function EventScheduler:getScheduledEventCount()
  local count = 0
  for _, event in ipairs(self.scheduled_events) do
    if event.status == "scheduled" then
      count = count + 1
    end
  end
  return count
end

--- Get triggered event count
-- @return number - Count of fired events
function EventScheduler:getTriggeredEventCount()
  return #self.triggered_events
end

--- Serialize event scheduler for save/load
-- @return table - Serialized state
function EventScheduler:serialize()
  return {
    scheduled_events = self.scheduled_events,
    triggered_events = self.triggered_events,
    event_id_counter = self.event_id_counter,
  }
end

--- Deserialize event scheduler from save data
-- @param data table - Serialized state
-- @return EventScheduler - Restored scheduler
function EventScheduler.deserialize(data)
  local self = setmetatable({}, EventScheduler)

  self.scheduled_events = data.scheduled_events or {}
  self.triggered_events = data.triggered_events or {}
  self.event_id_counter = data.event_id_counter or 1

  return self
end

return EventScheduler
