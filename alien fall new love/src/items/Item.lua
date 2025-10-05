--- Base Item Class
-- Parent class for all item types in the game
--
-- @classmod domain.items.Item

local class = require 'lib.Middleclass'

Item = class('Item')

--- Item states
Item.STATE_STORED = "stored"
Item.STATE_RESERVED = "reserved"
Item.STATE_EQUIPPED = "equipped"
Item.STATE_CONSUMED = "consumed"
Item.STATE_TRANSFERRED = "transferred"

--- Item categories
Item.CATEGORY_LORE = "lore"
Item.CATEGORY_RESOURCE = "resource"
Item.CATEGORY_UNIT = "unit"
Item.CATEGORY_CRAFT = "craft"
Item.CATEGORY_PRISONER = "prisoner"

--- Create a new item instance
-- @param data Item data from TOML configuration
-- @return Item instance
function Item:initialize(data)
    -- Basic item properties
    self.id = data.id
    self.name = data.name or "Unknown Item"
    self.description = data.description or ""
    self.category = data.category or Item.CATEGORY_RESOURCE

    -- Physical properties
    self.weight = data.weight or 0
    self.volume = data.volume or 0

    -- Economic properties
    self.value = data.value or 0
    self.rarity = data.rarity or "common"
    self.tier = data.tier or 1

    -- State management
    self.state = Item.STATE_STORED
    self.quantity = data.quantity or 1

    -- Metadata
    self.tags = data.tags or {}
    self.flags = data.flags or {}

    -- Provenance tracking
    self.provenance = data.provenance or {}
    self.created_at = data.created_at or os.time()
    self.source = data.source or "unknown"
end

--- Get the item's display name
-- @return string Display name
function Item:getDisplayName()
    return self.name
end

--- Get the item's full description
-- @return string Full description
function Item:getDescription()
    return self.description
end

--- Get the item's category
-- @return string Category
function Item:getCategory()
    return self.category
end

--- Get the item's weight
-- @return number Weight in kg
function Item:getWeight()
    return self.weight
end

--- Get the item's volume
-- @return number Volume in cubic meters
function Item:getVolume()
    return self.volume
end

--- Get the item's value
-- @return number Monetary value
function Item:getValue()
    return self.value
end

--- Get the item's rarity
-- @return string Rarity level
function Item:getRarity()
    return self.rarity
end

--- Get the item's tier
-- @return number Technology/complexity tier
function Item:getTier()
    return self.tier
end

--- Get the item's current state
-- @return string Current state
function Item:getState()
    return self.state
end

--- Set the item's state
-- @param state New state
function Item:setState(state)
    self.state = state
end

--- Get the item's quantity
-- @return number Quantity
function Item:getQuantity()
    return self.quantity
end

--- Set the item's quantity
-- @param quantity New quantity
function Item:setQuantity(quantity)
    self.quantity = quantity
end

--- Check if item has a specific tag
-- @param tag Tag to check
-- @return boolean Whether item has the tag
function Item:hasTag(tag)
    for _, item_tag in ipairs(self.tags) do
        if item_tag == tag then
            return true
        end
    end
    return false
end

--- Add a tag to the item
-- @param tag Tag to add
function Item:addTag(tag)
    if not self:hasTag(tag) then
        table.insert(self.tags, tag)
    end
end

--- Remove a tag from the item
-- @param tag Tag to remove
function Item:removeTag(tag)
    for i, item_tag in ipairs(self.tags) do
        if item_tag == tag then
            table.remove(self.tags, i)
            return
        end
    end
end

--- Check if item has a specific flag
-- @param flag Flag to check
-- @return boolean Whether item has the flag
function Item:hasFlag(flag)
    return self.flags[flag] == true
end

--- Set a flag on the item
-- @param flag Flag to set
-- @param value Boolean value
function Item:setFlag(flag, value)
    self.flags[flag] = value
end

--- Get item provenance information
-- @return table Provenance data
function Item:getProvenance()
    return self.provenance
end

--- Check if item can be stacked with another item
-- @param other_item Item to check against
-- @return boolean Whether items can stack
function Item:canStackWith(other_item)
    return self.id == other_item.id and
           self.state == other_item.state and
           self:getStackCategory() == other_item:getStackCategory()
end

--- Get stack category for stacking logic
-- @return string Stack category identifier
function Item:getStackCategory()
    return self.id .. "_" .. self.state
end

--- Check if item is consumable
-- @return boolean Whether item can be consumed
function Item:isConsumable()
    return false
end

--- Check if item is equippable
-- @return boolean Whether item can be equipped
function Item:isEquippable()
    return false
end

--- Check if item has mass (physical presence)
-- @return boolean Whether item has physical mass
function Item:hasMass()
    return true
end

--- Get item data for serialization
-- @return table Item data
function Item:getData()
    return {
        id = self.id,
        name = self.name,
        description = self.description,
        category = self.category,
        weight = self.weight,
        volume = self.volume,
        value = self.value,
        rarity = self.rarity,
        tier = self.tier,
        state = self.state,
        quantity = self.quantity,
        tags = self.tags,
        flags = self.flags,
        provenance = self.provenance,
        created_at = self.created_at,
        source = self.source
    }
end

--- Create item from serialized data
-- @param data Serialized item data
-- @return Item instance
function Item.fromData(data)
    return Item:new(data)
end

return Item
