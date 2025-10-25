---Research Unlock System
---
---Manages what items, facilities, and technologies become available through research.
---Defines unlock requirements and integrates with research, manufacturing, and marketplace.
---
---Unlocks:
---  - Weapons (access to manufacturing)
---  - Armor (manufacturing + equipping)
---  - Facilities (base construction)
---  - Crafts (construction + deployment)
---  - Items (marketplace availability)
---  - Abilities/Techs (unit training)
---
---@module basescape.logic.research_unlock_system
---@author AlienFall Development Team

local ResearchUnlocks = {}
ResearchUnlocks.__index = ResearchUnlocks

---Unlock categories
ResearchUnlocks.CATEGORIES = {
    WEAPON = "weapon",
    ARMOR = "armor",
    FACILITY = "facility",
    CRAFT = "craft",
    ITEM = "item",
    ABILITY = "ability",
    TECHNOLOGY = "technology"
}

---Create research unlock manager
---@return table manager Unlock manager instance
function ResearchUnlocks.new()
    local self = setmetatable({}, ResearchUnlocks)

    -- Unlock definitions
    self.unlocks = {}  -- itemId -> {category, requirements, unlock_date}

    -- Unlock status tracking
    self.unlocked_items = {}  -- itemId -> true if unlocked

    -- Initialize default unlocks
    self:initializeDefaultUnlocks()

    return self
end

---Initialize default unlock definitions
function ResearchUnlocks:initializeDefaultUnlocks()
    print("[ResearchUnlocks] Initializing default unlock definitions")

    -- Weapons
    self:defineUnlock("laser_pistol", {
        category = self.CATEGORIES.WEAPON,
        name = "Laser Pistol",
        description = "Handheld laser weapon",
        research_required = {"laser_weapons"},
        cost = 0,
        unlock_date = nil
    })

    self:defineUnlock("laser_rifle", {
        category = self.CATEGORIES.WEAPON,
        name = "Laser Rifle",
        description = "Standard laser rifle",
        research_required = {"laser_weapons"},
        cost = 0,
        unlock_date = nil
    })

    self:defineUnlock("plasma_rifle", {
        category = self.CATEGORIES.WEAPON,
        name = "Plasma Rifle",
        description = "Advanced plasma weapon",
        research_required = {"plasma_weapons", "plasma_technology"},
        cost = 0,
        unlock_date = nil
    })

    self:defineUnlock("plasma_cannon", {
        category = self.CATEGORIES.WEAPON,
        name = "Plasma Cannon",
        description = "Heavy plasma weapon",
        research_required = {"plasma_weapons", "plasma_technology", "heavy_weapons"},
        cost = 0,
        unlock_date = nil
    })

    -- Armor
    self:defineUnlock("light_armor", {
        category = self.CATEGORIES.ARMOR,
        name = "Light Armor",
        description = "Basic protective armor",
        research_required = {"armor_research"},
        cost = 0,
        unlock_date = nil
    })

    self:defineUnlock("medium_armor", {
        category = self.CATEGORIES.ARMOR,
        name = "Medium Armor",
        description = "Standard combat armor",
        research_required = {"armor_research", "advanced_materials"},
        cost = 0,
        unlock_date = nil
    })

    self:defineUnlock("plasma_armor", {
        category = self.CATEGORIES.ARMOR,
        name = "Plasma Armor",
        description = "Plasma-resistant armor",
        research_required = {"plasma_technology", "advanced_materials", "plasma_armor_tech"},
        cost = 0,
        unlock_date = nil
    })

    -- Facilities
    self:defineUnlock("medical_bay", {
        category = self.CATEGORIES.FACILITY,
        name = "Medical Bay",
        description = "Unit healing facility",
        research_required = {"medical_research"},
        cost = 5000,
        unlock_date = nil
    })

    self:defineUnlock("psi_lab", {
        category = self.CATEGORIES.FACILITY,
        name = "Psi Lab",
        description = "Psionic training facility",
        research_required = {"psionics_research", "advanced_psionics"},
        cost = 10000,
        unlock_date = nil
    })

    self:defineUnlock("radar", {
        category = self.CATEGORIES.FACILITY,
        name = "Radar Facility",
        description = "Detection system",
        research_required = {"radar_technology"},
        cost = 3000,
        unlock_date = nil
    })

    -- Crafts
    self:defineUnlock("interceptor", {
        category = self.CATEGORIES.CRAFT,
        name = "Interceptor",
        description = "Fighter craft",
        research_required = {"craft_technology", "laser_weapons"},
        cost = 15000,
        unlock_date = nil
    })

    self:defineUnlock("transport", {
        category = self.CATEGORIES.CRAFT,
        name = "Transport",
        description = "Cargo and troop transport",
        research_required = {"craft_technology"},
        cost = 20000,
        unlock_date = nil
    })

    -- Items
    self:defineUnlock("medkit", {
        category = self.CATEGORIES.ITEM,
        name = "Medkit",
        description = "Medical supplies",
        research_required = {"medical_research"},
        cost = 100,
        unlock_date = nil
    })

    self:defineUnlock("alien_corpse_study", {
        category = self.CATEGORIES.ITEM,
        name = "Alien Corpse Study",
        description = "Research alien remains",
        research_required = {},  -- Available from start
        cost = 0,
        unlock_date = nil
    })

    print(string.format("[ResearchUnlocks] Defined %d unlocks",
          self:countUnlocks()))
end

---Define new unlock
---@param itemId string Unique item identifier
---@param unlock_def table Unlock definition
function ResearchUnlocks:defineUnlock(itemId, unlock_def)
    self.unlocks[itemId] = unlock_def

    -- Pre-unlock if no requirements
    if not unlock_def.research_required or #unlock_def.research_required == 0 then
        self.unlocked_items[itemId] = true
    end
end

---Check if item is unlocked
---@param itemId string Item identifier
---@return boolean unlocked
function ResearchUnlocks:isUnlocked(itemId)
    return self.unlocked_items[itemId] or false
end

---Get unlock requirements for item
---@param itemId string Item identifier
---@return table requirements Array of required research projects
function ResearchUnlocks:getRequirements(itemId)
    if not self.unlocks[itemId] then
        return {}
    end
    return self.unlocks[itemId].research_required or {}
end

---Check if all requirements are met
---@param itemId string Item identifier
---@param completed_research table Array of completed research project IDs
---@return boolean complete
---@return table missing Missing research projects
function ResearchUnlocks:checkRequirements(itemId, completed_research)
    local requirements = self:getRequirements(itemId)
    local missing = {}

    for _, research_id in ipairs(requirements) do
        local found = false
        for _, completed in ipairs(completed_research) do
            if completed == research_id then
                found = true
                break
            end
        end

        if not found then
            table.insert(missing, research_id)
        end
    end

    return #missing == 0, missing
end

---Process research completion
---Marks items as unlocked when research completes
---@param research_id string Completed research project ID
function ResearchUnlocks:onResearchComplete(research_id)
    print(string.format("[ResearchUnlocks] Processing unlock for research: %s", research_id))

    local newly_unlocked = {}

    for itemId, unlock_def in pairs(self.unlocks) do
        if not self.unlocked_items[itemId] then
            -- Check if this research enables this item
            local requirements = unlock_def.research_required or {}

            for _, req in ipairs(requirements) do
                if req == research_id then
                    -- This research is relevant, check all requirements
                    local all_complete = true
                    for _, req_research in ipairs(requirements) do
                        -- In real implementation, query research system
                        -- For now, assume all others are complete
                        if req_research ~= research_id then
                            -- Placeholder: assume complete
                        end
                    end

                    -- Unlock item
                    if all_complete then
                        self.unlocked_items[itemId] = true
                        table.insert(newly_unlocked, itemId)
                    end
                    break
                end
            end
        end
    end

    if #newly_unlocked > 0 then
        print(string.format("[ResearchUnlocks] Unlocked %d items from research %s",
              #newly_unlocked, research_id))
        for _, itemId in ipairs(newly_unlocked) do
            print(string.format("  - %s", self.unlocks[itemId].name))
        end
    end

    return newly_unlocked
end

---Get all unlocked items by category
---@param category string Category to filter (optional)
---@return table items Array of unlocked items
function ResearchUnlocks:getUnlockedItems(category)
    local items = {}

    for itemId, unlock_def in pairs(self.unlocks) do
        if self.unlocked_items[itemId] then
            if not category or unlock_def.category == category then
                table.insert(items, {
                    id = itemId,
                    name = unlock_def.name,
                    description = unlock_def.description,
                    category = unlock_def.category,
                    cost = unlock_def.cost
                })
            end
        end
    end

    return items
end

---Get locked items and their requirements
---@param category string Category to filter (optional)
---@return table items Array of locked items with missing requirements
function ResearchUnlocks:getLockedItems(category)
    local items = {}

    for itemId, unlock_def in pairs(self.unlocks) do
        if not self.unlocked_items[itemId] then
            if not category or unlock_def.category == category then
                table.insert(items, {
                    id = itemId,
                    name = unlock_def.name,
                    description = unlock_def.description,
                    category = unlock_def.category,
                    requirements = unlock_def.research_required or {},
                    cost = unlock_def.cost
                })
            end
        end
    end

    return items
end

---Get unlock progress for item (0-1)
---@param itemId string Item identifier
---@param completed_research table Array of completed research IDs
---@return number progress Progress toward unlock (0 to 1)
function ResearchUnlocks:getUnlockProgress(itemId, completed_research)
    if self.unlocked_items[itemId] then
        return 1.0
    end

    local requirements = self:getRequirements(itemId)
    if #requirements == 0 then
        return 0.0
    end

    local completed_count = 0
    for _, req in ipairs(requirements) do
        for _, completed in ipairs(completed_research) do
            if req == completed then
                completed_count = completed_count + 1
                break
            end
        end
    end

    return completed_count / #requirements
end

---Get count of unlocked items
---@return number count
function ResearchUnlocks:countUnlocked()
    local count = 0
    for _, unlocked in pairs(self.unlocked_items) do
        if unlocked then
            count = count + 1
        end
    end
    return count
end

---Get total count of unlocks
---@return number count
function ResearchUnlocks:countUnlocks()
    local count = 0
    for _ in pairs(self.unlocks) do
        count = count + 1
    end
    return count
end

---Get unlock statistics
---@return table stats {total, unlocked, locked, by_category}
function ResearchUnlocks:getStatistics()
    local stats = {
        total = 0,
        unlocked = 0,
        locked = 0,
        by_category = {}
    }

    for itemId, unlock_def in pairs(self.unlocks) do
        stats.total = stats.total + 1

        if not stats.by_category[unlock_def.category] then
            stats.by_category[unlock_def.category] = {
                total = 0,
                unlocked = 0,
                locked = 0
            }
        end

        local cat_stats = stats.by_category[unlock_def.category]
        cat_stats.total = cat_stats.total + 1

        if self.unlocked_items[itemId] then
            stats.unlocked = stats.unlocked + 1
            cat_stats.unlocked = cat_stats.unlocked + 1
        else
            stats.locked = stats.locked + 1
            cat_stats.locked = cat_stats.locked + 1
        end
    end

    return stats
end

return ResearchUnlocks

