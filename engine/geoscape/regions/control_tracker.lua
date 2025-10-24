---@class ControlTracker
---Manages control transitions and tracks control history
local ControlTracker = {}

---Create new control tracker
---@param region_controller table RegionController instance
---@return ControlTracker
function ControlTracker.new(region_controller)
    return setmetatable({
        regions = region_controller,
        control_history = {},    -- Array of {turn, region_id, from, to, reason}
        region_control_pcts = {}, -- Track control % per region over time
    }, {__index = ControlTracker})
end

---Set region control (full transfer)
---@param region_id number Region ID
---@param faction string New controlling faction
---@param reason string Reason for change
function ControlTracker:setControl(region_id, faction, reason)
    local region = self.regions:getRegion(region_id)
    if not region then return false end

    local from_faction = region.faction
    region:setControl(faction, 1.0)

    -- Record history
    local entry = {
        turn = self.regions.turn,
        region_id = region_id,
        region_name = region.name,
        from = from_faction,
        to = faction,
        reason = reason or "unknown",
    }

    table.insert(self.control_history, entry)

    print(string.format("[ControlTracker] %s: %s → %s (%s)",
        region.name, from_faction, faction, reason))

    return true
end

---Get current control of region
---@param region_id number Region ID
---@return string|nil Current controlling faction or nil
function ControlTracker:getControl(region_id)
    local region = self.regions:getRegion(region_id)
    if region then
        return region.faction
    end
    return nil
end

---Get control percentage for faction
---@param region_id number Region ID
---@param faction string Faction to check
---@return number Control percentage (0-1)
function ControlTracker:getControlPercentage(region_id, faction)
    local region = self.regions:getRegion(region_id)
    if not region then return 0 end

    if region.faction == faction then
        return region.control_pct
    end

    return 0
end

---Update control percentage (gradual transfer)
---@param region_id number Region ID
---@param faction string Faction
---@param delta number Change amount (-1 to 1)
---@return number New control percentage
function ControlTracker:updateControlPercentage(region_id, faction, delta)
    local region = self.regions:getRegion(region_id)
    if not region then return 0 end

    local old_pct = region.control_pct

    -- If changing faction
    if region.faction ~= faction and delta > 0 then
        region:modifyControl(delta)

        -- Check if control flipped
        if old_pct > 0.5 and region.control_pct <= 0.5 then
            self:setControl(region_id, faction, "control_lost")
        end
    else
        region:modifyControl(delta)
    end

    return region.control_pct
end

---Get control history for region
---@param region_id number Region ID
---@param max_turns number Maximum turns to retrieve (default: 100)
---@return table[] Array of history entries
function ControlTracker:getRegionHistory(region_id, max_turns)
    max_turns = max_turns or 100
    local result = {}

    for i = #self.control_history, math.max(1, #self.control_history - max_turns + 1), -1 do
        local entry = self.control_history[i]
        if entry.region_id == region_id then
            table.insert(result, 1, entry)  -- Prepend to maintain order
        end
    end

    return result
end

---Get all control history
---@return table[] Array of all history entries
function ControlTracker:getFullHistory()
    return self.control_history
end

---Get control changes in specific turn
---@param turn number Turn number
---@return table[] Changes that occurred in that turn
function ControlTracker:getChangesAtTurn(turn)
    local result = {}

    for _, entry in ipairs(self.control_history) do
        if entry.turn == turn then
            table.insert(result, entry)
        end
    end

    return result
end

---Get regions lost by faction
---@param faction string Faction
---@param max_entries number Maximum entries (default: 50)
---@return table[] Regions lost by faction
function ControlTracker:getRegionsLostByFaction(faction, max_entries)
    max_entries = max_entries or 50
    local result = {}

    for i = #self.control_history, math.max(1, #self.control_history - max_entries + 1), -1 do
        local entry = self.control_history[i]
        if entry.from == faction then
            table.insert(result, entry)
        end
    end

    return result
end

---Get regions gained by faction
---@param faction string Faction
---@param max_entries number Maximum entries (default: 50)
---@return table[] Regions gained by faction
function ControlTracker:getRegionsGainedByFaction(faction, max_entries)
    max_entries = max_entries or 50
    local result = {}

    for i = #self.control_history, math.max(1, #self.control_history - max_entries + 1), -1 do
        local entry = self.control_history[i]
        if entry.to == faction then
            table.insert(result, entry)
        end
    end

    return result
end

---Get most recently changed region
---@return table|nil Most recent change entry
function ControlTracker:getMostRecentChange()
    if #self.control_history > 0 then
        return self.control_history[#self.control_history]
    end
    return nil
end

---Get control stability (how many changes recently)
---@param recent_turns number Check last N turns
---@return number Change count
function ControlTracker:getRecentControlActivity(recent_turns)
    recent_turns = recent_turns or 10
    local current_turn = self.regions.turn
    local count = 0

    for _, entry in ipairs(self.control_history) do
        if current_turn - entry.turn <= recent_turns then
            count = count + 1
        end
    end

    return count
end

---Check if faction is losing ground
---@param faction string Faction
---@param recent_turns number Check last N turns
---@return boolean True if losing regions
function ControlTracker:isFactionLosingGround(faction, recent_turns)
    recent_turns = recent_turns or 10

    local lost = 0
    local gained = 0

    local recent_changes = self:getChangesAtTurn(self.regions.turn - recent_turns)
    for _, entry in ipairs(self.control_history) do
        if self.regions.turn - entry.turn <= recent_turns then
            if entry.from == faction then
                lost = lost + 1
            elseif entry.to == faction then
                gained = gained + 1
            end
        end
    end

    return lost > gained
end

---Get faction control summary
---@param faction string Faction
---@return table Summary {regions_controlled, total_control_pct, recent_losses, recent_gains}
function ControlTracker:getFactionControlSummary(faction)
    local regions_controlled = 0
    local total_control_pct = 0
    local region_count = 0

    for _, region in pairs(self.regions:getAllRegions()) do
        region_count = region_count + 1
        if region.faction == faction then
            regions_controlled = regions_controlled + 1
            total_control_pct = total_control_pct + region.control_pct
        end
    end

    local recent_turns = 20
    local recent_changes = self:getChangesAtTurn(self.regions.turn)
    local losses = 0
    local gains = 0

    for _, entry in ipairs(self.control_history) do
        if self.regions.turn - entry.turn <= recent_turns then
            if entry.from == faction then
                losses = losses + 1
            elseif entry.to == faction then
                gains = gains + 1
            end
        end
    end

    return {
        regions_controlled = regions_controlled,
        total_regions = region_count,
        control_percentage = (total_control_pct / region_count) * 100,
        recent_losses = losses,
        recent_gains = gains,
    }
end

---Debug: Print tracking information
function ControlTracker:debug()
    print("\n" .. string.rep("=", 60))
    print("CONTROL TRACKER DEBUG")
    print(string.rep("=", 60))
    print(string.format("Total control changes recorded: %d", #self.control_history))

    if #self.control_history > 0 then
        print("\nRecent control changes (last 10):")
        for i = math.max(1, #self.control_history - 9), #self.control_history do
            local entry = self.control_history[i]
            print(string.format("  Turn %d: %s - %s → %s (%s)",
                entry.turn, entry.region_name, entry.from, entry.to, entry.reason))
        end
    end

    print("\nFaction Control Summary:")
    for _, faction in ipairs({"player", "alien", "neutral"}) do
        local summary = self:getFactionControlSummary(faction)
        print(string.format("  %s: %d/%d regions (%.1f%%) - gained: %d, lost: %d",
            faction,
            summary.regions_controlled,
            summary.total_regions,
            summary.control_percentage,
            summary.recent_gains,
            summary.recent_losses))
    end

    print(string.rep("=", 60) .. "\n")
end

return ControlTracker
