--- Supplier Pricing System - Dynamic pricing based on relations
---
--- Manages marketplace pricing with dynamic multipliers based on:
--- - Supplier faction relations (hostile/neutral/friendly/allied)
--- - Regional market variations (±10%)
--- - Black market options (2x price, no traceability)
---
--- Key Features:
--- - Relations-based pricing multipliers (0.8x to 1.5x)
--- - Regional market variance simulation
--- - Black market pricing
--- - Price description helpers for UI
---
--- Usage:
---   local PricingSystem = require("engine.economy.finance.supplier_pricing_system")
---   local system = PricingSystem:new()
---   local final_price = system:calculatePrice(base_price, supplier, relations)
---   local description = system:getPriceDescription(final_price, base_price)
---
--- @module engine.economy.finance.supplier_pricing_system
--- @author AlienFall Development Team

local SupplierPricingSystem = {}
SupplierPricingSystem.__index = SupplierPricingSystem

--- Relations thresholds and corresponding price multipliers
SupplierPricingSystem.RELATIONS_LEVELS = {
    hostile = {min = -100, max = -50, multiplier = 1.5},      -- Premium: 1.5x
    unfriendly = {min = -50, max = -1, multiplier = 1.0},   -- Neutral: 1.0x
    neutral = {min = -1, max = 1, multiplier = 1.0},         -- Neutral: 1.0x
    friendly = {min = 1, max = 50, multiplier = 0.9},        -- Discount: 0.9x
    allied = {min = 50, max = 100, multiplier = 0.8}         -- Bulk discount: 0.8x
}

--- Black market price multiplier
SupplierPricingSystem.BLACK_MARKET_MULTIPLIER = 2.0

--- Regional price variance range (±10%)
SupplierPricingSystem.REGIONAL_VARIANCE = 0.1

--- Initialize Supplier Pricing System
---@return table SupplierPricingSystem instance
function SupplierPricingSystem:new()
    local self = setmetatable({}, SupplierPricingSystem)
    print("[SupplierPricingSystem] Initialized")
    return self
end

--- Get price multiplier based on relations value
---
--- Relations values typically range from -100 (hostile) to +100 (allied).
--- Multiplier ranges from 1.5x (hostile, premium) to 0.8x (allied, discount).
---
---@param relationsValue number Relations rating (-100 to +100)
---@return number Price multiplier (0.8 to 1.5)
function SupplierPricingSystem:getRelationsMultiplier(relationsValue)
    -- Clamp to valid range
    relationsValue = math.max(-100, math.min(100, relationsValue))
    
    if relationsValue < -50 then
        -- Hostile: Premium pricing 1.5x
        return self.RELATIONS_LEVELS.hostile.multiplier
    elseif relationsValue < 0 then
        -- Unfriendly: Interpolate from 1.0 to 1.5 based on negativity
        local ratio = math.abs(relationsValue) / 50
        local mult = 1.0 + (ratio * 0.5)
        return math.min(1.5, mult)
    elseif relationsValue < 50 then
        -- Friendly: Interpolate from 1.0 to 0.9 based on friendliness
        local ratio = relationsValue / 50
        local mult = 1.0 - (ratio * 0.1)
        return math.max(0.9, mult)
    else
        -- Allied: Maximum discount 0.8x
        return self.RELATIONS_LEVELS.allied.multiplier
    end
end

--- Get regional price variance (±10%)
---
--- Uses a pseudo-random generator seeded by region and time
--- to ensure consistency within a game month but variation over time.
---
---@param regionId number Region identifier (0-255)
---@param seed number Random seed (typically os.time() / 2592000 for monthly variation)
---@return number Regional variance multiplier (0.9 to 1.1)
function SupplierPricingSystem:getRegionalVariance(regionId, seed)
    regionId = regionId or 0
    seed = seed or 0
    
    -- Pseudo-random using region and seed
    local random_value = ((regionId * 7 + seed * 13) % 100) / 100
    
    -- Map to range: -10% to +10% (0.9 to 1.1)
    local variance = 0.9 + (random_value * 0.2)
    
    return variance
end

--- Calculate final item price with all multipliers
---
--- Combines base price with:
--- 1. Relations multiplier (0.8x to 1.5x)
--- 2. Regional variance (0.9x to 1.1x)
--- 3. Rounding to nearest credit
---
---@param basePrice number Base item price
---@param supplierId number Supplier faction ID (for regional variance)
---@param relationsValue number Relations with supplier (-100 to +100)
---@param seed number Random seed for monthly variation
---@return number Final calculated price in credits
function SupplierPricingSystem:calculatePrice(basePrice, supplierId, relationsValue, seed)
    basePrice = math.max(1, basePrice or 100)
    supplierId = supplierId or 0
    relationsValue = relationsValue or 0
    seed = seed or 0
    
    -- Get multipliers
    local relationsMult = self:getRelationsMultiplier(relationsValue)
    local regionalMult = self:getRegionalVariance(supplierId, seed)
    
    -- Calculate final price
    local finalPrice = basePrice * relationsMult * regionalMult
    
    -- Round to nearest credit
    finalPrice = math.floor(finalPrice + 0.5)
    
    print(string.format("[SupplierPricingSystem] Base: %d × Relations %.2f × Regional %.2f = %d",
        basePrice, relationsMult, regionalMult, finalPrice))
    
    return finalPrice
end

--- Get black market price (no relations penalty, high markup)
---
--- Black market pricing bypasses relations multiplier but has
--- significant markup (2.0x base) and no traceability (hidden from allies).
---
---@param basePrice number Base item price
---@return number Black market price (2.0x base)
function SupplierPricingSystem:getBlackMarketPrice(basePrice)
    basePrice = math.max(1, basePrice or 100)
    
    local blackMarketPrice = math.floor(basePrice * self.BLACK_MARKET_MULTIPLIER)
    
    print(string.format("[SupplierPricingSystem] Black market: %d × %.1f = %d",
        basePrice, self.BLACK_MARKET_MULTIPLIER, blackMarketPrice))
    
    return blackMarketPrice
end

--- Get price description for UI display
---
--- Returns a description string and reasoning for why the price
--- is higher or lower than base (relations, market, etc).
---
---@param itemPrice number Current calculated price
---@param basePrice number Base/wiki price
---@return string Status text (e.g., "EXPENSIVE")
---@return string Reason text (e.g., "Relations penalty")
function SupplierPricingSystem:getPriceDescription(itemPrice, basePrice)
    basePrice = basePrice or itemPrice
    
    if basePrice == 0 then
        return "UNKNOWN", "Unable to determine"
    end
    
    local ratio = itemPrice / basePrice
    
    if ratio > 1.4 then
        return "VERY EXPENSIVE", "Serious relations penalty or market shortage"
    elseif ratio > 1.15 then
        return "EXPENSIVE", "Relations penalty or market rates high"
    elseif ratio > 1.05 then
        return "SLIGHTLY HIGH", "Minor market fluctuation"
    elseif ratio < 0.75 then
        return "VERY CHEAP", "Excellent supplier relations or major sale"
    elseif ratio < 0.85 then
        return "CHEAP", "Good supplier relations or sale"
    elseif ratio < 0.95 then
        return "SLIGHTLY LOW", "Minor market discount"
    else
        return "NORMAL", "Standard market price"
    end
end

--- Get relations level name from value
---
---@param relationsValue number Relations rating (-100 to +100)
---@return string Relations level name
function SupplierPricingSystem:getRelationsLevelName(relationsValue)
    relationsValue = relationsValue or 0
    
    if relationsValue < -50 then
        return "Hostile"
    elseif relationsValue < 0 then
        return "Unfriendly"
    elseif relationsValue < 50 then
        return "Friendly"
    elseif relationsValue >= 50 then
        return "Allied"
    else
        return "Neutral"
    end
end

--- Get price breakdown explanation for UI
---
--- Shows how price was calculated with each multiplier explained.
---
---@param basePrice number Base price
---@param relationsValue number Relations multiplier as 0.X format
---@param regionalVariance number Regional multiplier as 0.X format
---@param finalPrice number Final calculated price
---@return string Detailed explanation
function SupplierPricingSystem:getPriceBreakdown(basePrice, relationsValue, regionalVariance, finalPrice)
    local relationsMult = self:getRelationsMultiplier(relationsValue)
    local regionalMult = self:getRegionalVariance(0, regionalVariance)
    
    local breakdown = string.format(
        "Base Price: %d\n" ..
        "Relations (%s): %.2f×\n" ..
        "Regional Variance: %.2f×\n" ..
        "Final Price: %d",
        basePrice,
        self:getRelationsLevelName(relationsValue),
        relationsMult,
        regionalMult,
        finalPrice
    )
    
    return breakdown
end

--- Validate price calculation (for testing)
---
---@param basePrice number Base price
---@param supplierId number Supplier ID
---@param relationsValue number Relations value
---@param expectedMin number Expected minimum price
---@param expectedMax number Expected maximum price
---@return boolean Valid
---@return string? Error message
function SupplierPricingSystem:validatePrice(basePrice, supplierId, relationsValue, expectedMin, expectedMax)
    local price = self:calculatePrice(basePrice, supplierId, relationsValue, 0)
    
    if price < expectedMin or price > expectedMax then
        return false, string.format("Price %d out of range [%d,%d]", price, expectedMin, expectedMax)
    end
    
    return true, nil
end

return SupplierPricingSystem




