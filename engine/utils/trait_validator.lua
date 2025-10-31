---@class TraitValidator
---@field traitSystem TraitSystem
local TraitValidator = {}

--- Validation result structure
---@class ValidationResult
---@field valid boolean Whether validation passed
---@field error string Error message if invalid
---@field conflicts table Conflicting trait IDs found

-- Initialize validator
function TraitValidator:init(traitSystem)
    self.traitSystem = traitSystem
end

-- Validate adding a trait to a unit
function TraitValidator:validateTraitAddition(unit, traitId)
    local trait = self.traitSystem:getTrait(traitId)
    if not trait then
        return {valid = false, error = "Trait not found: " .. traitId}
    end

    -- Check if unit meets requirements
    if not self.traitSystem:meetsRequirements(unit, traitId) then
        return {valid = false, error = "Unit does not meet trait requirements"}
    end

    -- Check for conflicts
    local conflicts = self:checkTraitConflicts(unit, traitId)
    if #conflicts > 0 then
        local conflictNames = {}
        for _, conflictId in ipairs(conflicts) do
            local conflictTrait = self.traitSystem:getTrait(conflictId)
            if conflictTrait then
                table.insert(conflictNames, conflictTrait.name)
            end
        end
        return {
            valid = false,
            error = "Trait conflicts with: " .. table.concat(conflictNames, ", "),
            conflicts = conflicts
        }
    end

    -- Check balance limits
    local balanceResult = self:validateBalanceAfterAddition(unit, traitId)
    if not balanceResult.valid then
        return balanceResult
    end

    -- Check trait slot availability
    local slotsResult = self:validateTraitSlots(unit, traitId)
    if not slotsResult.valid then
        return slotsResult
    end

    return {valid = true}
end

-- Check for trait conflicts
function TraitValidator:checkTraitConflicts(unit, traitId)
    local trait = self.traitSystem:getTrait(traitId)
    if not trait then return {} end

    local conflicts = {}

    -- Check direct conflicts
    for _, conflictId in ipairs(trait.conflicts) do
        if self.traitSystem:hasTrait(unit, conflictId) then
            table.insert(conflicts, conflictId)
        end
    end

    -- Check reverse conflicts (traits that conflict with this one)
    for _, existingTrait in ipairs(unit.traits or {}) do
        local existingTraitDef = self.traitSystem:getTrait(existingTrait.id)
        if existingTraitDef then
            for _, conflictId in ipairs(existingTraitDef.conflicts) do
                if conflictId == traitId then
                    table.insert(conflicts, existingTrait.id)
                end
            end
        end
    end

    return conflicts
end

-- Validate balance after adding trait
function TraitValidator:validateBalanceAfterAddition(unit, traitId)
    local trait = self.traitSystem:getTrait(traitId)
    if not trait then return {valid = false, error = "Trait not found"} end

    local currentCost = self.traitSystem:getTotalBalanceCost(unit)
    local newCost = currentCost + trait.balance_cost

    -- Check maximum positive balance
    if newCost > 3 then
        return {
            valid = false,
            error = string.format("Trait would exceed balance limit (+3). Current: %d, Adding: %d, Total: %d",
                currentCost, trait.balance_cost, newCost)
        }
    end

    -- Check minimum negative balance (must have some penalty)
    if newCost < -1 then
        return {
            valid = false,
            error = string.format("Too many negative traits. Current: %d, Adding: %d, Total: %d",
                currentCost, trait.balance_cost, newCost)
        }
    end

    return {valid = true}
end

-- Validate trait slot availability
function TraitValidator:validateTraitSlots(unit, traitId)
    local trait = self.traitSystem:getTrait(traitId)
    if not trait then return {valid = false, error = "Trait not found"} end

    local maxSlots = self.traitSystem:getTraitSlotsForRank(unit.rank or 0)
    local currentSlots = #(unit.traits or {})

    -- For achievement/perk traits, check if we have available slots
    if trait.acquisition == "achievement" or trait.acquisition == "perk" then
        if currentSlots >= maxSlots then
            return {
                valid = false,
                error = string.format("No trait slots available. Current: %d/%d slots used",
                    currentSlots, maxSlots)
            }
        end
    end

    return {valid = true}
end

-- Validate entire trait set for a unit
function TraitValidator:validateUnitTraits(unit)
    if not unit.traits then
        return {valid = true}
    end

    -- Check for any conflicts within the trait set
    for i, trait1 in ipairs(unit.traits) do
        for j, trait2 in ipairs(unit.traits) do
            if i ~= j then
                local conflicts = self:checkTraitConflicts({traits = {trait2}}, trait1.id)
                if #conflicts > 0 then
                    local trait1Def = self.traitSystem:getTrait(trait1.id)
                    local trait2Def = self.traitSystem:getTrait(trait2.id)
                    return {
                        valid = false,
                        error = string.format("Trait conflict: %s conflicts with %s",
                            trait1Def and trait1Def.name or trait1.id,
                            trait2Def and trait2Def.name or trait2.id)
                    }
                end
            end
        end
    end

    -- Check balance
    local totalCost = self.traitSystem:getTotalBalanceCost(unit)
    if totalCost > 3 then
        return {
            valid = false,
            error = string.format("Unit exceeds balance limit (+3). Total cost: %d", totalCost)
        }
    end

    if totalCost < -1 then
        return {
            valid = false,
            error = string.format("Unit has too many negative traits. Total cost: %d", totalCost)
        }
    end

    -- Check slot limits
    local maxSlots = self.traitSystem:getTraitSlotsForRank(unit.rank or 0)
    local currentSlots = #unit.traits
    if currentSlots > maxSlots then
        return {
            valid = false,
            error = string.format("Unit exceeds trait slot limit. Current: %d/%d slots",
                currentSlots, maxSlots)
        }
    end

    return {valid = true}
end

-- Validate trait removal (respec)
function TraitValidator:validateTraitRemoval(unit, traitId)
    -- Check if unit has the trait
    if not self.traitSystem:hasTrait(unit, traitId) then
        return {valid = false, error = "Unit does not have this trait"}
    end

    local trait = self.traitSystem:getTrait(traitId)
    if not trait then
        return {valid = false, error = "Trait not found"}
    end

    -- Check if trait can be removed
    if trait.acquisition == "birth" then
        return {valid = false, error = "Birth traits cannot be removed"}
    end

    if trait.acquisition == "injury" then
        return {valid = false, error = "Injury traits cannot be removed"}
    end

    -- Check rank requirements for respec
    if unit.rank < 5 then
        return {valid = false, error = "Rank 5+ required for trait respec"}
    end

    -- Check XP cost
    local respecCost = 100000
    if (unit.xp or 0) < respecCost then
        return {valid = false, error = string.format("Insufficient XP for respec. Need: %d, Have: %d",
            respecCost, unit.xp or 0)}
    end

    return {valid = true}
end

-- Validate perk swapping
function TraitValidator:validatePerkSwap(unit, oldPerkId, newPerkId)
    -- Check if unit has the old perk
    if oldPerkId and not self.traitSystem:hasTrait(unit, oldPerkId) then
        return {valid = false, error = "Unit does not have the perk to swap"}
    end

    -- Check rank requirement
    if unit.rank < 8 then
        return {valid = false, error = "Rank 8+ required for perk swapping"}
    end

    -- Validate new perk addition
    local additionResult = self:validateTraitAddition(unit, newPerkId)
    if not additionResult.valid then
        return additionResult
    end

    -- Check if new perk is actually a perk
    local newTrait = self.traitSystem:getTrait(newPerkId)
    if not newTrait or newTrait.acquisition ~= "perk" then
        return {valid = false, error = "Invalid perk selection"}
    end

    return {valid = true}
end

-- Get suggestions for fixing validation errors
function TraitValidator:getSuggestions(unit, errorType, errorData)
    local suggestions = {}

    if errorType == "conflict" then
        -- Suggest removing conflicting trait
        table.insert(suggestions, "Remove the conflicting trait")
        table.insert(suggestions, "Choose a different trait that doesn't conflict")

    elseif errorType == "balance" then
        local currentCost = self.traitSystem:getTotalBalanceCost(unit)
        if currentCost > 3 then
            table.insert(suggestions, "Remove a positive trait to reduce balance cost")
            table.insert(suggestions, "Add a negative trait to balance the positives")
        elseif currentCost < -1 then
            table.insert(suggestions, "Remove a negative trait")
            table.insert(suggestions, "Add a positive trait to offset the negatives")
        end

    elseif errorType == "slots" then
        table.insert(suggestions, "Increase unit rank to unlock more trait slots")
        table.insert(suggestions, "Remove an existing trait to free up a slot")
        table.insert(suggestions, "Wait for rank advancement")

    elseif errorType == "requirements" then
        table.insert(suggestions, "Complete more missions to meet requirements")
        table.insert(suggestions, "Gain more experience in specific areas")
        table.insert(suggestions, "Advance to higher rank")
    end

    return suggestions
end

-- Validate birth trait generation
function TraitValidator:validateBirthTraits(traits, unitClass)
    -- Check for conflicts
    for i, trait1 in ipairs(traits) do
        for j, trait2 in ipairs(traits) do
            if i ~= j then
                local conflicts = self:checkTraitConflicts({traits = {trait2}}, trait1.id)
                if #conflicts > 0 then
                    return {valid = false, error = "Birth trait conflict detected"}
                end
            end
        end
    end

    -- Check balance
    local totalCost = 0
    for _, trait in ipairs(traits) do
        local traitDef = self.traitSystem:getTrait(trait.id)
        if traitDef then
            totalCost = totalCost + traitDef.balance_cost
        end
    end

    if totalCost > 3 then
        return {valid = false, error = "Birth traits exceed balance limit"}
    end

    if totalCost < -1 then
        return {valid = false, error = "Too many negative birth traits"}
    end

    return {valid = true}
end

-- Get available traits for unit
function TraitValidator:getAvailableTraits(unit)
    local available = {}

    for traitId, trait in pairs(self.traitSystem:getAllTraits()) do
        -- Skip if unit already has this trait
        if not self.traitSystem:hasTrait(unit, traitId) then
            -- Check if unit meets requirements
            if self.traitSystem:meetsRequirements(unit, traitId) then
                -- Check if it would cause conflicts
                local conflicts = self:checkTraitConflicts(unit, traitId)
                if #conflicts == 0 then
                    -- Check if it would exceed balance
                    local balanceResult = self:validateBalanceAfterAddition(unit, traitId)
                    if balanceResult.valid then
                        -- Check slot availability
                        local slotsResult = self:validateTraitSlots(unit, traitId)
                        if slotsResult.valid then
                            table.insert(available, trait)
                        end
                    end
                end
            end
        end
    end

    return available
end

return TraitValidator
