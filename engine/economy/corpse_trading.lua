---Corpse Trading System
---
---Handles the dark economy of trading dead unit bodies for profit through the Black Market.
---Players can sell corpses collected from battlefields, with moral consequences (karma penalties)
---and discovery risks. Alternative ethical uses include research, burial, or ransom.
---
---Key Features:
---  - Corpse creation from dead units (battlefield salvage)
---  - Value calculation based on type, condition, freshness
---  - Karma penalties per corpse type (human -10, alien -15 to -25, VIP -30)
---  - Discovery risk (5% per sale, cumulative)
---  - Alternative uses (research, burial, ransom) with 0 karma
---
---Corpse Types & Values:
---  - Human Soldier: 5,000 credits, -10 karma
---  - Alien Common: 15,000 credits, -15 karma
---  - Alien Rare: 50,000 credits, -25 karma
---  - VIP/Hero: 100,000 credits, -30 karma
---  - Mechanical: 8,000 credits, -5 karma
---
---Value Modifiers:
---  - Fresh (<7 days): +50% value
---  - Preserved (cryogenic): +100% value
---  - Damaged (explosion): -50% value
---
---Key Exports:
---  - CorpseTrading.createCorpse(deadUnit): Convert unit to corpse item
---  - CorpseTrading.getCorpseValue(corpseItem): Calculate sale value
---  - CorpseTrading.sellCorpse(corpseItem, blackMarket): Trade for credits
---  - CorpseTrading.getAlternativeUses(corpseItem): Get ethical options
---
---Dependencies:
---  - economy.marketplace.black_market_system: Sales channel
---  - politics.karma_system: Karma penalties
---
---@module economy.corpse_trading
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local CorpseTrading = {}

-- Configuration
CorpseTrading.CONFIG = {
    -- Base values by corpse type
    VALUES = {
        human_soldier = 5000,
        alien_common = 15000,
        alien_rare = 50000,
        vip_hero = 100000,
        mechanical = 8000,
    },

    -- Karma penalties by type
    KARMA_PENALTIES = {
        human_soldier = -10,
        alien_common = -15,
        alien_rare = -25,
        vip_hero = -30,
        mechanical = -5,
    },

    -- Value modifiers
    FRESH_BONUS = 0.50,  -- +50% if < 7 days old
    PRESERVED_BONUS = 1.00,  -- +100% if cryogenically preserved
    DAMAGED_PENALTY = -0.50,  -- -50% if damaged by explosion

    -- Discovery
    DISCOVERY_CHANCE = 0.05,  -- 5% per sale
    DISCOVERY_CHANCE_HUMAN = 0.03,  -- +3% additional for human corpses

    -- Freshness threshold
    FRESH_DAYS = 7,
}

---@class CorpseItem
---@field id string Corpse item ID
---@field type string Corpse type (human_soldier, alien_common, etc.)
---@field unit_id string Original unit ID
---@field unit_name string Original unit name
---@field death_date number Timestamp of death
---@field condition string fresh|normal|damaged
---@field preserved boolean Whether cryogenically preserved
---@field is_human boolean Whether human corpse (affects discovery)

---Create corpse item from dead unit
---@param deadUnit table Dead unit entity
---@param deathCause string Cause of death (for damage assessment)
---@return CorpseItem corpse
function CorpseTrading.createCorpse(deadUnit, deathCause)
    if not deadUnit then
        print("[CorpseTrading] ERROR: No unit provided")
        return nil
    end

    -- Determine corpse type
    local corpseType = CorpseTrading._determineCorpseType(deadUnit)

    -- Determine condition
    local condition = "normal"
    if deathCause and (deathCause == "explosion" or deathCause == "grenade") then
        condition = "damaged"
    end

    local corpse = {
        id = "corpse_" .. deadUnit.id,
        type = corpseType,
        unit_id = deadUnit.id,
        unit_name = deadUnit.name or "Unknown",
        death_date = os.time(),
        condition = condition,
        preserved = false,
        is_human = (corpseType == "human_soldier" or corpseType == "vip_hero"),
    }

    print(string.format("[CorpseTrading] Corpse created: %s (%s, %s condition)",
        corpse.unit_name, corpse.type, corpse.condition))

    return corpse
end

---Determine corpse type from unit
---@param unit table Unit entity
---@return string corpseType
function CorpseTrading._determineCorpseType(unit)
    if not unit.type then
        return "human_soldier"  -- Default
    end

    -- Check if mechanical
    if unit.type == "robot" or unit.type == "drone" or unit.type == "mechanical" then
        return "mechanical"
    end

    -- Check if VIP
    if unit.is_vip or unit.rank >= 6 or unit.is_hero then
        return "vip_hero"
    end

    -- Check if alien
    if unit.faction == "alien" or unit.type:match("alien") then
        -- Determine rarity
        if unit.rarity == "rare" or unit.rarity == "epic" then
            return "alien_rare"
        else
            return "alien_common"
        end
    end

    -- Default: human soldier
    return "human_soldier"
end

---Get corpse sale value with all modifiers
---@param corpseItem CorpseItem Corpse to value
---@return number value Final sale value in credits
function CorpseTrading.getCorpseValue(corpseItem)
    if not corpseItem or not corpseItem.type then
        return 0
    end

    local cfg = CorpseTrading.CONFIG

    -- Base value
    local baseValue = cfg.VALUES[corpseItem.type] or 0
    local value = baseValue

    -- Apply condition modifiers
    if corpseItem.preserved then
        value = value * (1 + cfg.PRESERVED_BONUS)
        print(string.format("[CorpseTrading] Preserved corpse: +100%% value (%d → %d)",
            baseValue, value))
    elseif corpseItem.condition == "damaged" then
        value = value * (1 + cfg.DAMAGED_PENALTY)
        print(string.format("[CorpseTrading] Damaged corpse: -50%% value (%d → %d)",
            baseValue, value))
    end

    -- Check freshness
    local daysSinceDeath = (os.time() - corpseItem.death_date) / 86400  -- seconds to days
    if daysSinceDeath < cfg.FRESH_DAYS and not corpseItem.preserved then
        value = value * (1 + cfg.FRESH_BONUS)
        print(string.format("[CorpseTrading] Fresh corpse (<7 days): +50%% value (%d → %d)",
            baseValue, value))
    end

    return math.floor(value)
end

---Sell corpse through Black Market
---@param corpseItem CorpseItem Corpse to sell
---@param blackMarket table Black Market system
---@param karmaSystem table Karma system
---@param treasury table Treasury system
---@return boolean success
---@return string|nil reason
---@return table|nil result {credits, karma_loss, discovered}
function CorpseTrading.sellCorpse(corpseItem, blackMarket, karmaSystem, treasury)
    if not corpseItem then
        return false, "No corpse provided"
    end

    local cfg = CorpseTrading.CONFIG

    -- Calculate value
    local value = CorpseTrading.getCorpseValue(corpseItem)

    -- Get karma penalty
    local karmaPenalty = cfg.KARMA_PENALTIES[corpseItem.type] or -10

    -- Calculate discovery chance
    local discoveryChance = cfg.DISCOVERY_CHANCE
    if corpseItem.is_human then
        discoveryChance = discoveryChance + cfg.DISCOVERY_CHANCE_HUMAN
    end

    -- Roll for discovery
    local discovered = (math.random() < discoveryChance)

    -- Apply karma penalty
    if karmaSystem then
        karmaSystem:modify(karmaPenalty, "Corpse trading: " .. corpseItem.type)
    end

    -- Add credits
    if treasury then
        treasury:add(value, "Corpse sale: " .. corpseItem.unit_name)
    end

    -- Log transaction
    print(string.format("[CorpseTrading] Corpse sold: %s (%s)", corpseItem.unit_name, corpseItem.type))
    print(string.format("  Value: %d credits", value))
    print(string.format("  Karma: %d", karmaPenalty))
    print(string.format("  Discovery: %s (%.1f%% chance)", tostring(discovered), discoveryChance * 100))

    -- Handle discovery
    if discovered then
        CorpseTrading._handleDiscovery(corpseItem, blackMarket, karmaSystem)
    end

    return true, nil, {
        credits = value,
        karma_loss = karmaPenalty,
        discovered = discovered,
        discovery_chance = discoveryChance
    }
end

---Handle discovery consequences
---@param corpseItem CorpseItem Corpse that was discovered
---@param blackMarket table Black Market system
---@param karmaSystem table Karma system
function CorpseTrading._handleDiscovery(corpseItem, blackMarket, karmaSystem)
    print("[CorpseTrading] WARNING: Corpse trading discovered!")

    -- Apply discovery penalties
    local famePenalty = -30
    local relationPenalty = -20

    -- Human corpses have worse consequences
    if corpseItem.is_human then
        famePenalty = -40
        relationPenalty = -30
        print("[CorpseTrading] Human corpse trading scandal!")
    end

    -- TODO: Apply fame penalty
    -- fameSystem:modify(famePenalty, "Corpse trading discovered")

    -- TODO: Apply relations penalty to all countries
    -- relationSystem:modifyAll(relationPenalty, "Body trade scandal")

    -- Additional karma penalty
    if karmaSystem then
        karmaSystem:modify(-10, "Corpse trading discovered")
    end

    print(string.format("  Fame: %d", famePenalty))
    print(string.format("  Relations: %d (all countries)", relationPenalty))
    print(string.format("  Additional karma: -10"))
end

---Get alternative uses for corpse (ethical options)
---@param corpseItem CorpseItem Corpse to check
---@return table alternatives Array of {action, description, karma, benefit}
function CorpseTrading.getAlternativeUses(corpseItem)
    if not corpseItem then return {} end

    local alternatives = {}

    -- Research (biological study)
    table.insert(alternatives, {
        action = "research",
        name = "Research Corpse",
        description = "Study corpse for biological data and technology",
        karma = 0,
        cost = 0,
        benefit = "Unlock biology tech or research bonus",
        available = true
    })

    -- Burial (proper disposal)
    table.insert(alternatives, {
        action = "burial",
        name = "Proper Burial",
        description = "Give corpse proper burial or cremation",
        karma = 0,
        cost = 500,  -- Burial costs
        benefit = "+5 morale to squad (honor the fallen)",
        available = true
    })

    -- Ransom (return to faction)
    if not corpseItem.is_human then
        table.insert(alternatives, {
            action = "ransom",
            name = "Return to Faction",
            description = "Return corpse to original faction for goodwill",
            karma = 0,
            cost = 0,
            benefit = "+10 relations with faction",
            available = true
        })
    else
        table.insert(alternatives, {
            action = "return_family",
            name = "Return to Family",
            description = "Return corpse to family for closure",
            karma = 0,
            cost = 1000,
            benefit = "+15 fame, +5 relations with country",
            available = true
        })
    end

    return alternatives
end

---Apply alternative use (research, burial, ransom)
---@param corpseItem CorpseItem Corpse to use
---@param action string Alternative action (research|burial|ransom|return_family)
---@param systems table Systems table with required systems
---@return boolean success
---@return string|nil message
function CorpseTrading.applyAlternativeUse(corpseItem, action, systems)
    if not corpseItem or not action then
        return false, "Missing corpse or action"
    end

    if action == "research" then
        -- TODO: Unlock research or provide research bonus
        print(string.format("[CorpseTrading] %s sent to research (0 karma)", corpseItem.unit_name))
        return true, "Corpse sent to research department"

    elseif action == "burial" then
        -- TODO: Apply morale bonus to squad
        print(string.format("[CorpseTrading] %s given proper burial (+5 morale, 0 karma)", corpseItem.unit_name))
        return true, "Corpse given proper burial"

    elseif action == "ransom" then
        -- TODO: Apply relations bonus with faction
        print(string.format("[CorpseTrading] %s returned to faction (+10 relations, 0 karma)", corpseItem.unit_name))
        return true, "Corpse returned to faction"

    elseif action == "return_family" then
        -- TODO: Apply fame and relations bonus
        print(string.format("[CorpseTrading] %s returned to family (+15 fame, +5 relations, 0 karma)", corpseItem.unit_name))
        return true, "Corpse returned to family"

    else
        return false, "Unknown alternative action: " .. action
    end
end

---Mark corpse as preserved (cryogenic storage)
---Requires cryogenic storage facility at base
---@param corpseItem CorpseItem Corpse to preserve
---@return boolean success
function CorpseTrading.preserveCorpse(corpseItem)
    if not corpseItem then
        return false
    end

    corpseItem.preserved = true
    print(string.format("[CorpseTrading] %s preserved in cryogenic storage (+100%% value)", corpseItem.unit_name))
    return true
end

return CorpseTrading

