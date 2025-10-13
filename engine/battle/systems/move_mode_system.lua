--[[
    Move Mode System

    Manages different movement modes (WALK, RUN, SNEAK, FLY) with their costs, benefits, and restrictions.
    Integrates with armor system to determine available modes.
]]

local MoveModeSystem = {}

-- Move mode definitions
MoveModeSystem.MODES = {
    WALK = {
        id = "walk",
        name = "Walk",
        description = "Normal movement",
        mpCostMultiplier = 1.0,  -- Movement point cost multiplier
        apCostMultiplier = 1.0,  -- Action point cost multiplier
        epCostPerAP = 0,         -- Energy cost per AP spent
        coverBonus = 0,          -- Cover bonus when moving
        ignoresTerrain = false,  -- Can move through all terrain types
        flatCost = nil           -- Flat MP cost (overrides multiplier)
    },
    RUN = {
        id = "run",
        name = "Run",
        description = "Fast movement with energy cost",
        mpCostMultiplier = 0.5,  -- 50% of normal MP cost
        apCostMultiplier = 1.0,
        epCostPerAP = 1,         -- 1 EP per AP spent
        coverBonus = 0,
        ignoresTerrain = false,
        flatCost = nil
    },
    SNEAK = {
        id = "sneak",
        name = "Sneak",
        description = "Stealthy movement with cover bonus",
        mpCostMultiplier = 2.0,  -- 200% of normal MP cost
        apCostMultiplier = 1.0,
        epCostPerAP = 0,
        coverBonus = 3,          -- +3 cover when moving
        ignoresTerrain = false,
        flatCost = nil
    },
    FLY = {
        id = "fly",
        name = "Fly",
        description = "Flight movement ignoring terrain",
        mpCostMultiplier = 1.0,
        apCostMultiplier = 1.0,
        epCostPerAP = 1,         -- 1 EP per AP spent
        coverBonus = 0,
        ignoresTerrain = true,   -- Ignores terrain restrictions
        flatCost = 2             -- Always 2 MP per tile
    }
}

-- Default mode when no mode is specified
MoveModeSystem.DEFAULT_MODE = MoveModeSystem.MODES.WALK

--[[
    Get move mode by ID
    @param modeId string - The mode ID (walk, run, sneak, fly)
    @return table|nil - The move mode definition or nil if not found
]]
function MoveModeSystem.getMode(modeId)
    for _, mode in pairs(MoveModeSystem.MODES) do
        if mode.id == modeId then
            return mode
        end
    end
    return nil
end

--[[
    Get all available move modes for a unit
    @param unit table - The unit to check
    @return table - Array of available mode definitions
]]
function MoveModeSystem.getAvailableModes(unit)
    if not unit then return {} end

    local available = {}

    for _, mode in pairs(MoveModeSystem.MODES) do
        if MoveModeSystem.isModeAvailable(unit, mode.id) then
            table.insert(available, mode)
        end
    end

    return available
end

--[[
    Check if a move mode is available for a unit
    @param unit table - The unit to check
    @param modeId string - The mode ID to check
    @return boolean - Whether the mode is available
]]
function MoveModeSystem.isModeAvailable(unit, modeId)
    if not unit then return false end

    -- WALK is always available
    if modeId == "walk" then
        return true
    end

    -- Other modes require appropriate armor
    if not unit.armor or not unit.armor.moveModes then
        return false
    end

    return unit.armor.moveModes[modeId] == true
end

--[[
    Calculate movement cost for a tile using a specific move mode
    @param baseCost number - Base movement cost of the tile
    @param modeId string - The move mode ID
    @return number - The calculated movement cost
]]
function MoveModeSystem.calculateMovementCost(baseCost, modeId)
    local mode = MoveModeSystem.getMode(modeId)
    if not mode then
        mode = MoveModeSystem.DEFAULT_MODE
    end

    if mode.ignoresTerrain or mode.flatCost then
        return mode.flatCost or 0
    end

    return baseCost * mode.mpCostMultiplier
end

--[[
    Calculate energy cost for movement using a specific mode
    @param apSpent number - Action points spent on movement
    @param modeId string - The move mode ID
    @return number - Energy points required
]]
function MoveModeSystem.calculateEnergyCost(apSpent, modeId)
    local mode = MoveModeSystem.getMode(modeId)
    if not mode then
        mode = MoveModeSystem.DEFAULT_MODE
    end

    return apSpent * mode.epCostPerAP
end

--[[
    Check if unit has enough energy for a movement action
    @param unit table - The unit attempting to move
    @param apSpent number - Action points that will be spent
    @param modeId string - The move mode ID
    @return boolean - Whether the unit has enough energy
]]
function MoveModeSystem.hasEnoughEnergy(unit, apSpent, modeId)
    if not unit or not unit.energy then return false end

    local energyCost = MoveModeSystem.calculateEnergyCost(apSpent, modeId)
    return unit.energy.current >= energyCost
end

--[[
    Apply energy cost to unit after movement
    @param unit table - The unit that moved
    @param apSpent number - Action points spent on movement
    @param modeId string - The move mode ID used
]]
function MoveModeSystem.applyEnergyCost(unit, apSpent, modeId)
    if not unit or not unit.energy then return end

    local energyCost = MoveModeSystem.calculateEnergyCost(apSpent, modeId)
    unit.energy.current = math.max(0, unit.energy.current - energyCost)

    print(string.format("[MoveModeSystem] Applied %d EP cost to unit (mode: %s)", energyCost, modeId))
end

--[[
    Get cover bonus for a unit using a specific move mode
    @param modeId string - The move mode ID
    @return number - Cover bonus value
]]
function MoveModeSystem.getCoverBonus(modeId)
    local mode = MoveModeSystem.getMode(modeId)
    if not mode then
        mode = MoveModeSystem.DEFAULT_MODE
    end

    return mode.coverBonus
end

--[[
    Get mode description for UI display
    @param modeId string - The move mode ID
    @return string - Human-readable description
]]
function MoveModeSystem.getModeDescription(modeId)
    local mode = MoveModeSystem.getMode(modeId)
    if not mode then
        return "Unknown mode"
    end

    local desc = mode.name .. ": " .. mode.description

    if mode.mpCostMultiplier ~= 1.0 then
        local percent = mode.mpCostMultiplier * 100
        desc = desc .. string.format(" (MP: %d%%)", percent)
    end

    if mode.epCostPerAP > 0 then
        desc = desc .. string.format(" (EP: %d per AP)", mode.epCostPerAP)
    end

    if mode.coverBonus > 0 then
        desc = desc .. string.format(" (+%d cover)", mode.coverBonus)
    end

    if mode.ignoresTerrain then
        desc = desc .. " (ignores terrain)"
    end

    return desc
end

--[[
    Validate that a unit can use a specific move mode
    @param unit table - The unit to validate
    @param modeId string - The move mode ID
    @return boolean, string - Success and error message if failed
]]
function MoveModeSystem.validateMode(unit, modeId)
    if not unit then
        return false, "No unit specified"
    end

    if not MoveModeSystem.isModeAvailable(unit, modeId) then
        local mode = MoveModeSystem.getMode(modeId)
        local modeName = mode and mode.name or modeId
        return false, modeName .. " mode not available for this unit"
    end

    return true, nil
end

print("[MoveModeSystem] Move mode system loaded with 4 modes: WALK, RUN, SNEAK, FLY")

return MoveModeSystem