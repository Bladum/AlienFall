---Karma System - Moral Alignment and Ethical Choices
---
---Tracks the moral/ethical alignment of the player's organization, affecting access
---to black market, mission types, recruit morale, and story branches. Karma decreases
---from civilian casualties, torture, and black market activities. Karma increases
---from humanitarian missions and peaceful resolutions.
---
---Karma Values:
---  - Range: -100 (evil) to +100 (saint)
---  - Alignments: Evil (-100 to -75), Dark (-74 to -25), Neutral (-24 to +24),
---              Good (+25 to +74), Saint (+75 to +100)
---
---Karma Effects:
---  - Black Market: Low karma unlocks black market access
---  - Mission Types: High karma = humanitarian, Low karma = covert ops
---  - Recruit Morale: +/-10% morale based on alignment
---  - Supplier Attitudes: Ethical suppliers prefer high karma
---  - Story Branches: Karma affects campaign choices and endings
---  - Research: Some tech only available at extreme karma values
---
---Karma Sources (Examples):
---  - Civilian saved: +2 karma
---  - Civilian killed: -5 karma
---  - Prisoner executed: -10 karma
---  - Prisoner interrogated (torture): -3 karma
---  - Humanitarian mission: +10 karma
---  - Black market purchase: -5 to -20 karma
---  - War crime: -30 karma
---  - Peaceful resolution: +15 karma
---
---Key Exports:
---  - KarmaSystem.new(): Create system
---  - modifyKarma(delta, reason): Change karma
---  - getKarma(): Get current karma
---  - getAlignment(karma): Get descriptive alignment
---  - canAccessBlackMarket(): Check if black market available
---
---@module geoscape.systems.karma_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local KarmaSystem = require("geoscape.systems.karma_system")
---  local karma = KarmaSystem.new()
---  karma:modifyKarma(10, "Humanitarian mission")
---  print("Alignment: " .. karma:getAlignment(karma:getKarma()))

local KarmaSystem = {}
KarmaSystem.__index = KarmaSystem

--- Create new karma system
---@return table New karma system instance
function KarmaSystem.new()
    local self = setmetatable({}, KarmaSystem)
    
    -- Core state
    self.karma = 0  -- Start neutral
    self.history = {}  -- Change history
    self.trend = "stable"  -- "improving", "declining", "stable"
    
    -- Alignment thresholds
    self.alignments = {
        {min = 75,   max = 100,  label = "Saint",    color = {100, 255, 100}, blackMarketAccess = false},
        {min = 25,   max = 74,   label = "Good",     color = {100, 200, 100}, blackMarketAccess = false},
        {min = -24,  max = 24,   label = "Neutral",  color = {150, 150, 150}, blackMarketAccess = true},
        {min = -74,  max = -25,  label = "Dark",     color = {200, 100, 100}, blackMarketAccess = true},
        {min = -100, max = -75,  label = "Evil",     color = {255, 0, 0},     blackMarketAccess = true}
    }
    
    -- Configuration
    self.config = {
        maxKarma = 100,
        minKarma = -100,
        maxHistorySize = 20,
        blackMarketThreshold = 24,  -- Neutral or worse to access
    }
    
    print("[KarmaSystem] Initialized with karma = 0 (Neutral)")
    
    return self
end

---Modify karma by delta
---@param delta number Amount to change (-30 to +30 typical)
---@param reason string Reason for change
---@return number New karma value
function KarmaSystem:modifyKarma(delta, reason)
    local oldKarma = self.karma
    self.karma = math.max(self.config.minKarma, math.min(self.config.maxKarma, self.karma + delta))
    
    -- Record change
    self:recordChange(delta, reason)
    
    -- Check for alignment changes
    local oldAlignment = self:getAlignment(oldKarma)
    local newAlignment = self:getAlignment(self.karma)
    
    if oldAlignment ~= newAlignment then
        print(string.format("[KarmaSystem] ALIGNMENT SHIFT: %s → %s (Karma: %d → %d)",
              oldAlignment, newAlignment, oldKarma, self.karma))
    else
        print(string.format("[KarmaSystem] Karma: %d %c %d = %d (%s)",
              oldKarma, delta >= 0 and '+' or ' ', delta, self.karma, reason))
    end
    
    -- Update trend
    self:updateTrend()
    
    return self.karma
end

---Record karma change in history
---@param delta number Change amount
---@param reason string Reason for change
function KarmaSystem:recordChange(delta, reason)
    table.insert(self.history, 1, {
        delta = delta,
        reason = reason,
        timestamp = os.time()
    })
    
    -- Keep only recent history
    if #self.history > self.config.maxHistorySize then
        table.remove(self.history, self.config.maxHistorySize + 1)
    end
end

---Update trend (improving/declining/stable)
function KarmaSystem:updateTrend()
    if #self.history == 0 then
        self.trend = "stable"
        return
    end
    
    -- Calculate average delta from recent changes
    local recentCount = math.min(5, #self.history)
    local totalDelta = 0
    
    for i = 1, recentCount do
        totalDelta = totalDelta + self.history[i].delta
    end
    
    local avgDelta = totalDelta / recentCount
    
    if avgDelta > 2 then
        self.trend = "improving"
    elseif avgDelta < -2 then
        self.trend = "declining"
    else
        self.trend = "stable"
    end
end

---Get current karma value
---@return number Karma (-100 to +100)
function KarmaSystem:getKarma()
    return self.karma
end

---Set karma to exact value
---@param value number Target karma (-100 to +100)
---@param reason string Reason for setting
function KarmaSystem:setKarma(value, reason)
    value = math.max(self.config.minKarma, math.min(self.config.maxKarma, value))
    local delta = value - self.karma
    self:modifyKarma(delta, reason or "Direct set")
end

---Get alignment for karma value
---@param value number Karma value
---@return string Alignment name
function KarmaSystem:getAlignment(value)
    for _, alignment in ipairs(self.alignments) do
        if value >= alignment.min and value <= alignment.max then
            return alignment.label
        end
    end
    return "Neutral"
end

---Get color for alignment (for UI)
---@return table RGB color {r, g, b}
function KarmaSystem:getAlignmentColor()
    local alignment = self:getAlignment(self.karma)
    
    for _, alignDef in ipairs(self.alignments) do
        if alignDef.label == alignment then
            return alignDef.color
        end
    end
    
    return {150, 150, 150}  -- Default gray
end

---Check if player can access black market
---@return boolean True if black market available
function KarmaSystem:canAccessBlackMarket()
    return self.karma <= self.config.blackMarketThreshold
end

---Get recruit morale modifier
---@return number Morale multiplier (0.9 to 1.1)
function KarmaSystem:getRecruitMoraleModifier()
    -- High karma = good morale, Low karma = poor morale
    local modifier = 1.0
    
    if self.karma > 50 then
        modifier = 1.1  -- +10% morale
    elseif self.karma > 25 then
        modifier = 1.05  -- +5% morale
    elseif self.karma < -50 then
        modifier = 0.9  -- -10% morale (units are demoralized)
    elseif self.karma < -25 then
        modifier = 0.95  -- -5% morale
    end
    
    return modifier
end

---Get karma description for UI display
---@return string Formatted description
function KarmaSystem:getDescription()
    local alignment = self:getAlignment(self.karma)
    local trendText = self.trend == "improving" and "↑" or (self.trend == "declining" and "↓" or "→")
    local bm = self:canAccessBlackMarket() and "✓" or "✗"
    
    return string.format("%s (%d) %s | Black Market: %s", alignment, self.karma, trendText, bm)
end

---Get recent history entries
---@param maxEntries number Maximum entries to return (default 10)
---@return table Array of {delta, reason, timestamp}
function KarmaSystem:getHistory(maxEntries)
    maxEntries = maxEntries or 10
    local result = {}
    
    for i = 1, math.min(maxEntries, #self.history) do
        table.insert(result, self.history[i])
    end
    
    return result
end

---Apply civilian casualty
---@param count number Number of civilians killed
function KarmaSystem:applyCivilianCasualties(count)
    count = count or 1
    local delta = -(5 * count)
    self:modifyKarma(delta, "Civilian casualties: " .. count)
end

---Apply civilian saved
---@param count number Number of civilians saved
function KarmaSystem:applyCivilianSaved(count)
    count = count or 1
    local delta = 2 * count
    self:modifyKarma(delta, "Civilians saved: " .. count)
end

---Apply prisoner interrogation (torture)
---@param is_torture boolean Whether torture was used
function KarmaSystem:applyPrisonerInterrogation(is_torture)
    if is_torture then
        self:modifyKarma(-3, "Prisoner torture")
    else
        self:modifyKarma(0, "Prisoner interrogation (humane)")
    end
end

---Apply prisoner execution
function KarmaSystem:applyPrisonerExecution()
    self:modifyKarma(-10, "Prisoner execution")
end

---Apply humanitarian mission complete
function KarmaSystem:applyHumanitarianMission()
    self:modifyKarma(10, "Humanitarian mission completed")
end

---Apply black market purchase
---@param purchase_value number Value of purchase in credits
---@param is_illegal boolean Whether item is truly illegal
function KarmaSystem:applyBlackMarketPurchase(purchase_value, is_illegal)
    local delta = 0
    
    if is_illegal then
        -- Heavy penalty for truly illegal items
        if purchase_value > 50000 then
            delta = -20
        elseif purchase_value > 20000 then
            delta = -15
        else
            delta = -5
        end
    else
        -- Small penalty for grey-market items
        delta = -2
    end
    
    self:modifyKarma(delta, "Black market purchase (" .. purchase_value .. " credits)")
end

---Apply war crime
---@param crime_description string Description of war crime
function KarmaSystem:applyWarCrime(crime_description)
    self:modifyKarma(-30, "War crime: " .. crime_description)
end

---Apply peaceful resolution
function KarmaSystem:applyPeacefulResolution()
    self:modifyKarma(15, "Peaceful resolution")
end

---Get status summary
---@return table Status including karma, alignment, modifiers
function KarmaSystem:getStatus()
    return {
        karma = self.karma,
        alignment = self:getAlignment(self.karma),
        color = self:getAlignmentColor(),
        canAccessBlackMarket = self:canAccessBlackMarket(),
        moraleMod = self:getRecruitMoraleModifier(),
        trend = self.trend,
        description = self:getDescription()
    }
end

---Serialize for save/load
---@return table Serialized state
function KarmaSystem:serialize()
    return {
        karma = self.karma,
        history = self.history,
        trend = self.trend
    }
end

---Deserialize from save/load
---@param data table Serialized state
function KarmaSystem:deserialize(data)
    if not data then return end
    
    self.karma = data.karma or 0
    self.history = data.history or {}
    self.trend = data.trend or "stable"
    
    print(string.format("[KarmaSystem] Deserialized: karma=%d, alignment=%s, blackMarket=%s",
          self.karma, self:getAlignment(self.karma), self:canAccessBlackMarket() and "YES" or "NO"))
end

return KarmaSystem
