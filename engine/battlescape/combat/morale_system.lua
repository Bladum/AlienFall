-- Morale System
-- Handles morale loss, bravery checks, panic, and berserk states

local MoraleSystem = {}
MoraleSystem.__index = MoraleSystem

--- Morale states
MoraleSystem.STATES = {
    NORMAL = "normal",
    PANICKED = "panicked",
    BERSERK = "berserk",
    UNCONSCIOUS = "unconscious"
}

--- Morale thresholds
MoraleSystem.PANIC_THRESHOLD = 40      -- Below this = panic risk
MoraleSystem.BERSERK_THRESHOLD = 20    -- Below this = berserk risk
MoraleSystem.UNCONSCIOUS_THRESHOLD = 0 -- At or below = unconscious

--- Create a new morale system instance
-- @return table New MoraleSystem instance
function MoraleSystem.new()
    print("[MoraleSystem] Initializing morale system")
    
    local self = setmetatable({}, MoraleSystem)
    return self
end

--- Calculate morale loss from taking damage
-- @param unit table Unit taking damage
-- @param damageAmount number Amount of damage taken
-- @return number Morale loss amount
function MoraleSystem:calculateDamageMoraleLoss(unit, damageAmount)
    -- Base morale loss = 10% of damage taken
    local baseLoss = damageAmount * 0.1
    
    -- Bravery reduces morale loss
    local bravery = unit.bravery or 50
    local braveryModifier = 1.0 - (bravery / 200)  -- 50 bravery = 0.75x, 100 bravery = 0.5x
    
    local totalLoss = baseLoss * braveryModifier
    
    print("[MoraleSystem] Unit " .. (unit.name or "Unknown") .. " loses " .. 
          math.floor(totalLoss) .. " morale from damage")
    
    return math.floor(totalLoss)
end

--- Calculate morale loss from witnessing death
-- @param witness table Unit witnessing the death
-- @param deceased table Unit that died
-- @param distance number Distance between witness and deceased
-- @return number Morale loss amount
function MoraleSystem:calculateDeathWitnessMoraleLoss(witness, deceased, distance)
    -- Base loss depends on relationship
    local baseLoss = 20
    
    -- Same team = higher loss
    if witness.team == deceased.team then
        baseLoss = 30
    end
    
    -- Distance matters (further = less impact)
    local distanceModifier = 1.0 / (1.0 + distance * 0.1)
    
    -- Bravery reduces morale loss
    local bravery = witness.bravery or 50
    local braveryModifier = 1.0 - (bravery / 200)
    
    local totalLoss = baseLoss * distanceModifier * braveryModifier
    
    print("[MoraleSystem] Unit " .. (witness.name or "Unknown") .. " loses " .. 
          math.floor(totalLoss) .. " morale from witnessing death")
    
    return math.floor(totalLoss)
end

--- Apply morale loss to unit
-- @param unit table Unit to lose morale
-- @param amount number Morale loss amount
function MoraleSystem:applyMoraleLoss(unit, amount)
    if not unit.morale then
        unit.morale = 100  -- Initialize if not set
    end
    
    unit.morale = unit.morale - amount
    
    -- Morale can't go below 0
    if unit.morale < 0 then
        unit.morale = 0
    end
    
    print("[MoraleSystem] Unit " .. (unit.name or "Unknown") .. " morale now: " .. unit.morale)
    
    -- Check for state changes
    self:updateMoraleState(unit)
end

--- Apply morale gain to unit
-- @param unit table Unit to gain morale
-- @param amount number Morale gain amount
function MoraleSystem:applyMoraleGain(unit, amount)
    if not unit.morale then
        unit.morale = 100
    end
    
    unit.morale = unit.morale + amount
    
    -- Morale can't exceed 100
    if unit.morale > 100 then
        unit.morale = 100
    end
    
    print("[MoraleSystem] Unit " .. (unit.name or "Unknown") .. " morale now: " .. unit.morale)
    
    -- Check for state changes
    self:updateMoraleState(unit)
end

--- Update unit morale state based on current morale
-- @param unit table Unit to update
function MoraleSystem:updateMoraleState(unit)
    local previousState = unit.moraleState or MoraleSystem.STATES.NORMAL
    
    if unit.morale <= MoraleSystem.UNCONSCIOUS_THRESHOLD then
        unit.moraleState = MoraleSystem.STATES.UNCONSCIOUS
    elseif unit.morale <= MoraleSystem.BERSERK_THRESHOLD then
        -- 50% chance to go berserk instead of panic
        if math.random() < 0.5 then
            unit.moraleState = MoraleSystem.STATES.BERSERK
        else
            unit.moraleState = MoraleSystem.STATES.PANICKED
        end
    elseif unit.morale <= MoraleSystem.PANIC_THRESHOLD then
        unit.moraleState = MoraleSystem.STATES.PANICKED
    else
        unit.moraleState = MoraleSystem.STATES.NORMAL
    end
    
    -- Log state changes
    if previousState ~= unit.moraleState then
        print("[MoraleSystem] Unit " .. (unit.name or "Unknown") .. " state changed: " .. 
              previousState .. " -> " .. unit.moraleState)
    end
end

--- Perform bravery check (resist panic/morale loss)
-- @param unit table Unit performing check
-- @param difficulty number Difficulty of check (default 50)
-- @return boolean True if check passed
function MoraleSystem:braveryCheck(unit, difficulty)
    difficulty = difficulty or 50
    local bravery = unit.bravery or 50
    
    -- Roll 1d100, must be <= bravery to pass
    local roll = math.random(1, 100)
    local passed = roll <= bravery
    
    print("[MoraleSystem] Unit " .. (unit.name or "Unknown") .. " bravery check: " .. 
          roll .. " vs " .. bravery .. " = " .. (passed and "PASS" or "FAIL"))
    
    return passed
end

--- Check if unit is panicked
-- @param unit table Unit to check
-- @return boolean True if panicked
function MoraleSystem:isPanicked(unit)
    return unit.moraleState == MoraleSystem.STATES.PANICKED
end

--- Check if unit is berserk
-- @param unit table Unit to check
-- @return boolean True if berserk
function MoraleSystem:isBerserk(unit)
    return unit.moraleState == MoraleSystem.STATES.BERSERK
end

--- Check if unit is unconscious from morale
-- @param unit table Unit to check
-- @return boolean True if unconscious
function MoraleSystem:isUnconscious(unit)
    return unit.moraleState == MoraleSystem.STATES.UNCONSCIOUS
end

--- Initialize unit morale stats
-- @param unit table Unit to initialize
-- @param initialMorale number Initial morale value (default 100)
-- @param bravery number Bravery stat (default 50)
function MoraleSystem:initializeUnit(unit, initialMorale, bravery)
    unit.morale = initialMorale or 100
    unit.bravery = bravery or 50
    unit.moraleState = MoraleSystem.STATES.NORMAL
    
    print("[MoraleSystem] Initialized unit " .. (unit.name or "Unknown") .. 
          " with morale=" .. unit.morale .. ", bravery=" .. unit.bravery)
end

--- Get morale state color for UI
-- @param state string Morale state
-- @return table RGB color {r, g, b}
function MoraleSystem:getStateColor(state)
    local colors = {
        normal = {100, 255, 100},      -- Green
        panicked = {255, 255, 100},    -- Yellow
        berserk = {255, 100, 100},     -- Red
        unconscious = {100, 100, 100}  -- Gray
    }
    
    return colors[state] or {255, 255, 255}
end

return MoraleSystem
