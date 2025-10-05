--- ItemLore Class
-- Represents lore items that provide narrative depth and research gating
--
-- @classmod domain.items.ItemLore

local class = require 'lib.Middleclass'
local Item = require 'items.Item'

ItemLore = class('ItemLore', Item)

--- Item states
ItemLore.STATE_STORED = "stored"
ItemLore.STATE_RESERVED = "reserved"
ItemLore.STATE_CONSUMED = "consumed"
ItemLore.STATE_TRANSFERRED = "transferred"

--- Create a new lore item instance
-- @param data Lore item data from TOML configuration
-- @return ItemLore instance
function ItemLore:initialize(data)
    -- Initialize parent class
    Item.initialize(self, data)

    -- Set category
    self.category = Item.CATEGORY_LORE

    -- Lore and narrative properties
    self.lore = data.lore or {}
    self.background = self.lore.background or ""
    self.significance = self.lore.significance or ""
    self.faction_contexts = self.lore.faction_contexts or {}

    -- Research integration
    self.research = data.research or {}
    self.unlocks_research = self.research.unlocks_research or {}
    self.required_for_research = self.research.required_for_research or {}
    self.consumed_by_research = self.research.consumed_by_research or false

    -- Acquisition and storage (override parent defaults)
    self.acquisition = data.acquisition or {}
    self.rarity = self.acquisition.rarity or self.rarity
    self.value = self.acquisition.value or 0  -- Usually 0 since not sellable

    -- State management (override parent default)
    self.state = ItemLore.STATE_STORED
    self.reserved_for = nil  -- Research or event reserving the item

    -- Provenance tracking
    self.provenance = {
        acquired_from = nil,  -- Mission, location, or source
        acquisition_method = nil,  -- salvage, purchase, quest, etc.
        acquisition_time = nil,
        campaign_seed = nil,
        usage_history = {}
    }

    -- Narrative integration
    self.narrative = data.narrative or {}
    self.triggers_events = self.narrative.triggers_events or {}
    self.related_items = self.narrative.related_items or {}
    self.related_characters = self.narrative.related_characters or {}

    return self
end

--- Acquire the item with provenance tracking
-- @param source Acquisition source (mission, location, etc.)
-- @param method Acquisition method (salvage, purchase, quest)
-- @param campaign_seed Current campaign seed
function ItemLore:acquire(source, method, campaign_seed)
    self.state = ItemLore.STATE_STORED
    self.provenance.acquired_from = source
    self.provenance.acquisition_method = method
    self.provenance.acquisition_time = os.time()
    self.provenance.campaign_seed = campaign_seed

    table.insert(self.provenance.usage_history, {
        action = "acquired",
        timestamp = self.provenance.acquisition_time,
        source = source,
        method = method
    })
end

--- Reserve the item for research or events
-- @param purpose Purpose of reservation (research_id or event_id)
-- @return boolean Success status
function ItemLore:reserve(purpose)
    if self.state ~= ItemLore.STATE_STORED then
        return false, "Item not available for reservation"
    end

    self.state = ItemLore.STATE_RESERVED
    self.reserved_for = purpose

    table.insert(self.provenance.usage_history, {
        action = "reserved",
        timestamp = os.time(),
        purpose = purpose
    })

    return true
end

--- Release reservation
-- @return boolean Success status
function ItemLore:release()
    if self.state ~= ItemLore.STATE_RESERVED then
        return false, "Item not reserved"
    end

    self.state = ItemLore.STATE_STORED
    self.reserved_for = nil

    table.insert(self.provenance.usage_history, {
        action = "released",
        timestamp = os.time()
    })

    return true
end

--- Consume the item for research or narrative purposes
-- @param purpose Consumption purpose
-- @return boolean Success status
function ItemLore:consume(purpose)
    if self.state == ItemLore.STATE_CONSUMED then
        return false, "Item already consumed"
    end

    self.state = ItemLore.STATE_CONSUMED

    table.insert(self.provenance.usage_history, {
        action = "consumed",
        timestamp = os.time(),
        purpose = purpose
    })

    return true
end

--- Check if this item can unlock specific research
-- @param research_id Research project ID
-- @return boolean True if can unlock
function ItemLore:canUnlockResearch(research_id)
    for _, unlock_id in ipairs(self.unlocks_research) do
        if unlock_id == research_id then
            return true
        end
    end
    return false
end

--- Check if this item is required for specific research
-- @param research_id Research project ID
-- @return boolean True if required
function ItemLore:isRequiredForResearch(research_id)
    for _, required_id in ipairs(self.required_for_research) do
        if required_id == research_id then
            return true
        end
    end
    return false
end

--- Get context-aware description based on player faction
-- @param player_faction Current player faction
-- @param campaign_state Current campaign state
-- @return string Context-aware description
function ItemLore:getContextDescription(player_faction, campaign_state)
    local base_description = self.description

    -- Add faction-specific context
    if self.faction_contexts[player_faction] then
        base_description = base_description .. "\n\n" .. self.faction_contexts[player_faction]
    end

    -- Add campaign-specific context
    if campaign_state and self.narrative.campaign_contexts then
        local campaign_context = self.narrative.campaign_contexts[campaign_state.phase]
        if campaign_context then
            base_description = base_description .. "\n\n" .. campaign_context
        end
    end

    return base_description
end

--- Get research unlock information
-- @return table Research unlock data
function ItemLore:getResearchInfo()
    return {
        unlocks_research = self.unlocks_research,
        required_for_research = self.required_for_research,
        consumed_by_research = self.consumed_by_research
    }
end

--- Get narrative integration information
-- @return table Narrative data
function ItemLore:getNarrativeInfo()
    return {
        triggers_events = self.triggers_events,
        related_items = self.related_items,
        related_characters = self.related_characters,
        background = self.background,
        significance = self.significance
    }
end

--- Get complete provenance information
-- @return table Provenance data
function ItemLore:getProvenanceInfo()
    return {
        acquired_from = self.provenance.acquired_from,
        acquisition_method = self.provenance.acquisition_method,
        acquisition_time = self.provenance.acquisition_time,
        campaign_seed = self.provenance.campaign_seed,
        usage_history = self.provenance.usage_history
    }
end

--- Get display information for UI
-- @param player_faction Current player faction
-- @param campaign_state Current campaign state
-- @return table Display data
function ItemLore:getDisplayInfo(player_faction, campaign_state)
    return {
        id = self.id,
        name = self.name,
        description = self:getContextDescription(player_faction, campaign_state),
        category = self.category,
        rarity = self.rarity,
        state = self.state,
        reserved_for = self.reserved_for,
        background = self.background,
        significance = self.significance,
        can_be_sold = false,  -- Lore items typically cannot be sold
        research_unlocks = self.unlocks_research,
        provenance = self:getProvenanceInfo()
    }
end

--- Check if item can be transferred or traded
-- @return boolean True if transferable
function ItemLore:canTransfer()
    -- Most lore items cannot be transferred normally
    -- Special events may override this
    return false
end

--- Get warning information for UI
-- @return table Warning data
function ItemLore:getWarnings()
    local warnings = {}

    if self.consumed_by_research then
        table.insert(warnings, "This item will be consumed by research projects")
    end

    if #self.unlocks_research > 0 then
        table.insert(warnings, "Required for advanced research projects")
    end

    if #self.triggers_events > 0 then
        table.insert(warnings, "May trigger important narrative events")
    end

    return warnings
end

--- Check if item has mass (physical presence)
-- @return boolean Whether item has physical mass (false for lore items)
function ItemLore:hasMass()
    return false
end

return ItemLore
