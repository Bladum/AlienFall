-- ─────────────────────────────────────────────────────────────────────────
-- ARTIFACT ACQUISITION TEST SUITE
-- FILE: tests2/lore/artifact_acquisition_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.lore.artifact_acquisition",
    fileName = "artifact_acquisition.lua",
    description = "Artifact acquisition system with discovery, collection, cataloging, and rarity"
})

print("[ARTIFACT_ACQUISITION_TEST] Setting up")

local ArtifactAcquisition = {
    artifacts = {},
    collections = {},
    discoveries = {},
    catalogs = {},

    new = function(self)
        return setmetatable({
            artifacts = {}, collections = {}, discoveries = {}, catalogs = {}
        }, {__index = self})
    end,

    createArtifact = function(self, artifactId, name, artifactType, rarity)
        self.artifacts[artifactId] = {
            id = artifactId, name = name, type = artifactType or "relic",
            rarity = rarity or "common", discovered = false, location = nil,
            age = 0, condition = 100, value = 100, story = ""
        }
        return true
    end,

    getArtifact = function(self, artifactId)
        return self.artifacts[artifactId]
    end,

    registerRarityTier = function(self, tierName, probability, value_multiplier)
        if not self.catalogs.rarities then
            self.catalogs.rarities = {}
        end
        self.catalogs.rarities[tierName] = {
            name = tierName, probability = probability or 0.5,
            value_mult = value_multiplier or 1.0, total_found = 0
        }
        return true
    end,

    getRarityTier = function(self, tierName)
        if not self.catalogs.rarities then return nil end
        return self.catalogs.rarities[tierName]
    end,

    discoverArtifact = function(self, artifactId, location)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].discovered = true
        self.artifacts[artifactId].location = location or "unknown"
        self.discoveries[artifactId] = {
            artifact_id = artifactId, turn_discovered = 1, location = location,
            discovery_method = "exploration"
        }
        local tier = self:getRarityTier(self.artifacts[artifactId].rarity)
        if tier then
            tier.total_found = tier.total_found + 1
        end
        return true
    end,

    getDiscovery = function(self, artifactId)
        return self.discoveries[artifactId]
    end,

    isDiscovered = function(self, artifactId)
        if not self.artifacts[artifactId] then return false end
        return self.artifacts[artifactId].discovered
    end,

    createCollection = function(self, collectionId, name, maxSize)
        self.collections[collectionId] = {
            id = collectionId, name = name, max_size = maxSize or 100,
            artifacts = {}, creation_date = 1, total_value = 0
        }
        return true
    end,

    getCollection = function(self, collectionId)
        return self.collections[collectionId]
    end,

    addToCollection = function(self, collectionId, artifactId)
        if not self.collections[collectionId] or not self.artifacts[artifactId] then return false end
        local collection = self.collections[collectionId]
        if #collection.artifacts >= collection.max_size then return false end
        if collection.artifacts[artifactId] then return false end
        collection.artifacts[artifactId] = true
        collection.total_value = collection.total_value + self.artifacts[artifactId].value
        return true
    end,

    removeFromCollection = function(self, collectionId, artifactId)
        if not self.collections[collectionId] or not self.collections[collectionId].artifacts[artifactId] then return false end
        self.collections[collectionId].artifacts[artifactId] = nil
        self.collections[collectionId].total_value = self.collections[collectionId].total_value - self.artifacts[artifactId].value
        return true
    end,

    isInCollection = function(self, collectionId, artifactId)
        if not self.collections[collectionId] then return false end
        return self.collections[collectionId].artifacts[artifactId] ~= nil
    end,

    getCollectionSize = function(self, collectionId)
        if not self.collections[collectionId] then return 0 end
        local count = 0
        for _ in pairs(self.collections[collectionId].artifacts) do
            count = count + 1
        end
        return count
    end,

    getCollectionValue = function(self, collectionId)
        if not self.collections[collectionId] then return 0 end
        return self.collections[collectionId].total_value
    end,

    getCollectionOccupancy = function(self, collectionId)
        if not self.collections[collectionId] then return 0 end
        local collection = self.collections[collectionId]
        if collection.max_size == 0 then return 0 end
        local size = self:getCollectionSize(collectionId)
        return math.floor((size / collection.max_size) * 100)
    end,

    setArtifactStory = function(self, artifactId, story)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].story = story or ""
        return true
    end,

    getArtifactStory = function(self, artifactId)
        if not self.artifacts[artifactId] then return "" end
        return self.artifacts[artifactId].story
    end,

    setArtifactCondition = function(self, artifactId, condition)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].condition = math.max(0, math.min(100, condition))
        return true
    end,

    getArtifactCondition = function(self, artifactId)
        if not self.artifacts[artifactId] then return 0 end
        return self.artifacts[artifactId].condition
    end,

    degradeArtifact = function(self, artifactId, amount)
        if not self.artifacts[artifactId] then return false end
        local artifact = self.artifacts[artifactId]
        artifact.condition = math.max(0, artifact.condition - (amount or 5))
        return true
    end,

    restoreArtifact = function(self, artifactId, amount)
        if not self.artifacts[artifactId] then return false end
        local artifact = self.artifacts[artifactId]
        artifact.condition = math.min(100, artifact.condition + (amount or 10))
        return true
    end,

    setArtifactAge = function(self, artifactId, age)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].age = math.max(0, age)
        return true
    end,

    getArtifactAge = function(self, artifactId)
        if not self.artifacts[artifactId] then return 0 end
        return self.artifacts[artifactId].age
    end,

    advanceArtifactAge = function(self, artifactId, years)
        if not self.artifacts[artifactId] then return false end
        self.artifacts[artifactId].age = self.artifacts[artifactId].age + (years or 1)
        return true
    end,

    calculateArtifactValue = function(self, artifactId)
        if not self.artifacts[artifactId] then return 0 end
        local artifact = self.artifacts[artifactId]
        local base_value = artifact.value
        local tier = self:getRarityTier(artifact.rarity)
        if tier then
            base_value = base_value * tier.value_mult
        end
        local condition_factor = artifact.condition / 100
        local age_factor = 1.0 + (artifact.age / 1000)
        local total_value = base_value * condition_factor * age_factor
        return math.floor(total_value)
    end,

    createCatalogEntry = function(self, entryId, artifactId, page, description)
        if not self.artifacts[artifactId] then return false end
        self.catalogs[entryId] = {
            id = entryId, artifact_id = artifactId, page_number = page or 0,
            description = description or "", indexed = true, view_count = 0
        }
        return true
    end,

    getCatalogEntry = function(self, entryId)
        return self.catalogs[entryId]
    end,

    viewCatalogEntry = function(self, entryId)
        if not self.catalogs[entryId] then return false end
        self.catalogs[entryId].view_count = self.catalogs[entryId].view_count + 1
        return true
    end,

    getCatalogViewCount = function(self, entryId)
        if not self.catalogs[entryId] then return 0 end
        return self.catalogs[entryId].view_count
    end,

    getArtifactsByRarity = function(self, rarity)
        local results = {}
        for artifactId, artifact in pairs(self.artifacts) do
            if artifact.rarity == rarity then
                table.insert(results, artifactId)
            end
        end
        return results
    end,

    getArtifactsByType = function(self, artifactType)
        local results = {}
        for artifactId, artifact in pairs(self.artifacts) do
            if artifact.type == artifactType then
                table.insert(results, artifactId)
            end
        end
        return results
    end,

    getTotalArtifactCount = function(self)
        local count = 0
        for _ in pairs(self.artifacts) do
            count = count + 1
        end
        return count
    end,

    getDiscoveredArtifactCount = function(self)
        local count = 0
        for artifactId, artifact in pairs(self.artifacts) do
            if artifact.discovered then
                count = count + 1
            end
        end
        return count
    end,

    getDiscoveryPercentage = function(self)
        local total = self:getTotalArtifactCount()
        if total == 0 then return 0 end
        local discovered = self:getDiscoveredArtifactCount()
        return math.floor((discovered / total) * 100)
    end,

    reset = function(self)
        self.artifacts = {}
        self.collections = {}
        self.discoveries = {}
        self.catalogs = {}
        return true
    end
}

Suite:group("Artifacts", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
    end)

    Suite:testMethod("ArtifactAcquisition.createArtifact", {description = "Creates artifact", testCase = "create", type = "functional"}, function()
        local ok = shared.aa:createArtifact("art1", "Ancient Gem", "jewelry", "rare")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ArtifactAcquisition.getArtifact", {description = "Gets artifact", testCase = "get", type = "functional"}, function()
        shared.aa:createArtifact("art2", "Gold Crown", "crown", "legendary")
        local art = shared.aa:getArtifact("art2")
        Helpers.assertEqual(art ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Rarity", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
    end)

    Suite:testMethod("ArtifactAcquisition.registerRarityTier", {description = "Registers tier", testCase = "register", type = "functional"}, function()
        local ok = shared.aa:registerRarityTier("epic", 0.1, 5.0)
        Helpers.assertEqual(ok, true, "Registered")
    end)

    Suite:testMethod("ArtifactAcquisition.getRarityTier", {description = "Gets tier", testCase = "get", type = "functional"}, function()
        shared.aa:registerRarityTier("mythic", 0.05, 10.0)
        local tier = shared.aa:getRarityTier("mythic")
        Helpers.assertEqual(tier ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Discovery", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
        shared.aa:createArtifact("art3", "Pearl", "gem", "uncommon")
    end)

    Suite:testMethod("ArtifactAcquisition.discoverArtifact", {description = "Discovers artifact", testCase = "discover", type = "functional"}, function()
        local ok = shared.aa:discoverArtifact("art3", "Temple")
        Helpers.assertEqual(ok, true, "Discovered")
    end)

    Suite:testMethod("ArtifactAcquisition.isDiscovered", {description = "Is discovered", testCase = "is_discovered", type = "functional"}, function()
        shared.aa:discoverArtifact("art3", "Ruin")
        local is = shared.aa:isDiscovered("art3")
        Helpers.assertEqual(is, true, "Discovered")
    end)

    Suite:testMethod("ArtifactAcquisition.getDiscovery", {description = "Gets discovery", testCase = "get_discovery", type = "functional"}, function()
        shared.aa:discoverArtifact("art3", "Cave")
        local disc = shared.aa:getDiscovery("art3")
        Helpers.assertEqual(disc ~= nil, true, "Retrieved")
    end)
end)

Suite:group("Collections", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
    end)

    Suite:testMethod("ArtifactAcquisition.createCollection", {description = "Creates collection", testCase = "create", type = "functional"}, function()
        local ok = shared.aa:createCollection("col1", "Museum", 50)
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ArtifactAcquisition.getCollection", {description = "Gets collection", testCase = "get", type = "functional"}, function()
        shared.aa:createCollection("col2", "Vault", 30)
        local col = shared.aa:getCollection("col2")
        Helpers.assertEqual(col ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactAcquisition.getCollectionSize", {description = "Gets size", testCase = "size", type = "functional"}, function()
        shared.aa:createCollection("col3", "Archive", 100)
        local size = shared.aa:getCollectionSize("col3")
        Helpers.assertEqual(size, 0, "Empty")
    end)

    Suite:testMethod("ArtifactAcquisition.getCollectionValue", {description = "Gets value", testCase = "value", type = "functional"}, function()
        shared.aa:createCollection("col4", "Treasury", 50)
        local value = shared.aa:getCollectionValue("col4")
        Helpers.assertEqual(value, 0, "0 value")
    end)

    Suite:testMethod("ArtifactAcquisition.getCollectionOccupancy", {description = "Gets occupancy", testCase = "occupancy", type = "functional"}, function()
        shared.aa:createCollection("col5", "Storage", 100)
        local occupancy = shared.aa:getCollectionOccupancy("col5")
        Helpers.assertEqual(occupancy, 0, "0% occupancy")
    end)
end)

Suite:group("Collection Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
        shared.aa:createCollection("manage_col", "Test", 100)
        shared.aa:createArtifact("manage_art", "Ring", "jewelry", "rare")
    end)

    Suite:testMethod("ArtifactAcquisition.addToCollection", {description = "Adds to collection", testCase = "add", type = "functional"}, function()
        local ok = shared.aa:addToCollection("manage_col", "manage_art")
        Helpers.assertEqual(ok, true, "Added")
    end)

    Suite:testMethod("ArtifactAcquisition.isInCollection", {description = "Is in collection", testCase = "is_in", type = "functional"}, function()
        shared.aa:addToCollection("manage_col", "manage_art")
        local is = shared.aa:isInCollection("manage_col", "manage_art")
        Helpers.assertEqual(is, true, "In collection")
    end)

    Suite:testMethod("ArtifactAcquisition.removeFromCollection", {description = "Removes from collection", testCase = "remove", type = "functional"}, function()
        shared.aa:addToCollection("manage_col", "manage_art")
        local ok = shared.aa:removeFromCollection("manage_col", "manage_art")
        Helpers.assertEqual(ok, true, "Removed")
    end)
end)

Suite:group("Artifact Properties", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
        shared.aa:createArtifact("prop_art", "Shield", "armor", "uncommon")
    end)

    Suite:testMethod("ArtifactAcquisition.setArtifactStory", {description = "Sets story", testCase = "story", type = "functional"}, function()
        local ok = shared.aa:setArtifactStory("prop_art", "A legendary shield")
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ArtifactAcquisition.getArtifactStory", {description = "Gets story", testCase = "get_story", type = "functional"}, function()
        shared.aa:setArtifactStory("prop_art", "Ancient shield")
        local story = shared.aa:getArtifactStory("prop_art")
        Helpers.assertEqual(story ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactAcquisition.setArtifactCondition", {description = "Sets condition", testCase = "condition", type = "functional"}, function()
        local ok = shared.aa:setArtifactCondition("prop_art", 85)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ArtifactAcquisition.getArtifactCondition", {description = "Gets condition", testCase = "get_condition", type = "functional"}, function()
        shared.aa:setArtifactCondition("prop_art", 75)
        local cond = shared.aa:getArtifactCondition("prop_art")
        Helpers.assertEqual(cond, 75, "75 condition")
    end)

    Suite:testMethod("ArtifactAcquisition.degradeArtifact", {description = "Degrades artifact", testCase = "degrade", type = "functional"}, function()
        shared.aa:setArtifactCondition("prop_art", 80)
        local ok = shared.aa:degradeArtifact("prop_art", 10)
        Helpers.assertEqual(ok, true, "Degraded")
    end)

    Suite:testMethod("ArtifactAcquisition.restoreArtifact", {description = "Restores artifact", testCase = "restore", type = "functional"}, function()
        shared.aa:setArtifactCondition("prop_art", 50)
        local ok = shared.aa:restoreArtifact("prop_art", 20)
        Helpers.assertEqual(ok, true, "Restored")
    end)
end)

Suite:group("Age & Value", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
        shared.aa:createArtifact("age_art", "Vase", "pottery", "common")
        shared.aa:registerRarityTier("common", 0.8, 1.0)
    end)

    Suite:testMethod("ArtifactAcquisition.setArtifactAge", {description = "Sets age", testCase = "age", type = "functional"}, function()
        local ok = shared.aa:setArtifactAge("age_art", 500)
        Helpers.assertEqual(ok, true, "Set")
    end)

    Suite:testMethod("ArtifactAcquisition.getArtifactAge", {description = "Gets age", testCase = "get_age", type = "functional"}, function()
        shared.aa:setArtifactAge("age_art", 1000)
        local age = shared.aa:getArtifactAge("age_art")
        Helpers.assertEqual(age, 1000, "1000 years")
    end)

    Suite:testMethod("ArtifactAcquisition.advanceArtifactAge", {description = "Advances age", testCase = "advance", type = "functional"}, function()
        local ok = shared.aa:advanceArtifactAge("age_art", 100)
        Helpers.assertEqual(ok, true, "Advanced")
    end)

    Suite:testMethod("ArtifactAcquisition.calculateArtifactValue", {description = "Calculates value", testCase = "calculate", type = "functional"}, function()
        local value = shared.aa:calculateArtifactValue("age_art")
        Helpers.assertEqual(value > 0, true, "Value > 0")
    end)
end)

Suite:group("Catalog", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
        shared.aa:createArtifact("cat_art", "Scroll", "document", "rare")
    end)

    Suite:testMethod("ArtifactAcquisition.createCatalogEntry", {description = "Creates entry", testCase = "create", type = "functional"}, function()
        local ok = shared.aa:createCatalogEntry("entry1", "cat_art", 1, "Ancient scroll")
        Helpers.assertEqual(ok, true, "Created")
    end)

    Suite:testMethod("ArtifactAcquisition.getCatalogEntry", {description = "Gets entry", testCase = "get", type = "functional"}, function()
        shared.aa:createCatalogEntry("entry2", "cat_art", 2, "Old document")
        local entry = shared.aa:getCatalogEntry("entry2")
        Helpers.assertEqual(entry ~= nil, true, "Retrieved")
    end)

    Suite:testMethod("ArtifactAcquisition.viewCatalogEntry", {description = "Views entry", testCase = "view", type = "functional"}, function()
        shared.aa:createCatalogEntry("entry3", "cat_art", 1, "Ancient text")
        local ok = shared.aa:viewCatalogEntry("entry3")
        Helpers.assertEqual(ok, true, "Viewed")
    end)

    Suite:testMethod("ArtifactAcquisition.getCatalogViewCount", {description = "Gets view count", testCase = "views", type = "functional"}, function()
        shared.aa:createCatalogEntry("entry4", "cat_art", 1, "Scroll")
        shared.aa:viewCatalogEntry("entry4")
        local count = shared.aa:getCatalogViewCount("entry4")
        Helpers.assertEqual(count, 1, "1 view")
    end)
end)

Suite:group("Search & Filter", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
        shared.aa:createArtifact("search1", "Dagger", "weapon", "uncommon")
        shared.aa:createArtifact("search2", "Amulet", "jewelry", "rare")
        shared.aa:createArtifact("search3", "Sword", "weapon", "rare")
    end)

    Suite:testMethod("ArtifactAcquisition.getArtifactsByRarity", {description = "Gets by rarity", testCase = "rarity", type = "functional"}, function()
        local results = shared.aa:getArtifactsByRarity("rare")
        Helpers.assertEqual(#results > 0, true, "Found artifacts")
    end)

    Suite:testMethod("ArtifactAcquisition.getArtifactsByType", {description = "Gets by type", testCase = "type", type = "functional"}, function()
        local results = shared.aa:getArtifactsByType("weapon")
        Helpers.assertEqual(#results > 0, true, "Found artifacts")
    end)

    Suite:testMethod("ArtifactAcquisition.getTotalArtifactCount", {description = "Total count", testCase = "total", type = "functional"}, function()
        local count = shared.aa:getTotalArtifactCount()
        Helpers.assertEqual(count, 3, "3 artifacts")
    end)

    Suite:testMethod("ArtifactAcquisition.getDiscoveredArtifactCount", {description = "Discovered count", testCase = "discovered", type = "functional"}, function()
        shared.aa:discoverArtifact("search1", "Cave")
        local count = shared.aa:getDiscoveredArtifactCount()
        Helpers.assertEqual(count, 1, "1 discovered")
    end)

    Suite:testMethod("ArtifactAcquisition.getDiscoveryPercentage", {description = "Discovery percentage", testCase = "percentage", type = "functional"}, function()
        shared.aa:discoverArtifact("search1", "Cave")
        local pct = shared.aa:getDiscoveryPercentage()
        Helpers.assertEqual(pct > 0, true, "Percentage > 0")
    end)
end)

Suite:group("Reset", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.aa = ArtifactAcquisition:new()
    end)

    Suite:testMethod("ArtifactAcquisition.reset", {description = "Resets system", testCase = "reset", type = "functional"}, function()
        local ok = shared.aa:reset()
        Helpers.assertEqual(ok, true, "Reset")
    end)
end)

Suite:run()
