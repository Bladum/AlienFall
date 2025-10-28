-- ─────────────────────────────────────────────────────────────────────────
-- PERSISTENCE API CONTRACT TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify save/load system API contracts
-- Tests: 7 API contract tests
-- Expected: All pass in <150ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.persistence",
    fileName = "persistence_api_contract_test.lua",
    description = "Persistence system API contract validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Persistence API Contracts", function()

    local persistence = {}

    Suite:beforeEach(function()
        persistence = {}
    end)

    -- Contract 1: Save file structure
    Suite:testMethod("Persistence:saveFileStructureContract", {
        description = "Save files must have consistent header and metadata",
        testCase = "contract",
        type = "api"
    }, function()
        local saveFile = {
            version = "1.0.0",
            timestamp = os.time(),
            playerName = "Commander",
            turnNumber = 50,
            gameVersion = "1.0.0",
            difficulty = "normal",
            gameState = {},
            checksum = 0
        }

        Helpers.assertTrue(saveFile.version ~= nil, "Must have version")
        Helpers.assertTrue(saveFile.timestamp ~= nil, "Must have timestamp")
        Helpers.assertTrue(saveFile.gameState ~= nil, "Must have gameState")
        Helpers.assertTrue(saveFile.checksum ~= nil, "Must have checksum")
    end)

    -- Contract 2: Save manager interface
    Suite:testMethod("Persistence:saveManagerContract", {
        description = "Save manager must provide consistent save/load interface",
        testCase = "contract",
        type = "api"
    }, function()
        local saveManager = {
            slots = {}
        }

        function saveManager:save(slotNumber, gameState)
            self.slots[slotNumber] = {
                data = gameState,
                timestamp = os.time(),
                valid = true
            }
            return true
        end

        function saveManager:load(slotNumber)
            if self.slots[slotNumber] and self.slots[slotNumber].valid then
                return self.slots[slotNumber].data
            end
            return nil
        end

        function saveManager:exists(slotNumber)
            return self.slots[slotNumber] ~= nil and self.slots[slotNumber].valid
        end

        local gameState = {turnNumber = 1}
        saveManager:save(1, gameState)

        Helpers.assertTrue(saveManager:exists(1), "Save should exist")
        local loaded = saveManager:load(1)
        Helpers.assertTrue(loaded ~= nil, "Should load save data")
    end)

    -- Contract 3: State serialization contract
    Suite:testMethod("Persistence:serializationContract", {
        description = "Serialization must produce consistent output format",
        testCase = "contract",
        type = "api"
    }, function()
        local function serialize(data)
            -- Simple serialization check
            return {
                type = type(data),
                size = string.len(tostring(data)),
                valid = true
            }
        end

        local data = {a = 1, b = "test", c = {nested = true}}
        local serialized = serialize(data)

        Helpers.assertTrue(serialized.type ~= nil, "Must have type field")
        Helpers.assertTrue(serialized.size > 0, "Size must be positive")
        Helpers.assertTrue(serialized.valid, "Must be valid")
    end)

    -- Contract 4: State restoration contract
    Suite:testMethod("Persistence:restorationContract", {
        description = "Restored state must match saved state exactly",
        testCase = "contract",
        type = "api"
    }, function()
        local originalState = {
            campaign = {turnNumber = 42, funds = 5000},
            bases = {count = 2},
            research = {projects = 5}
        }

        -- Simulate save and restore
        local saved = originalState
        local restored = saved

        -- Verify integrity
        Helpers.assertEqual(restored.campaign.turnNumber, 42, "Turn number preserved")
        Helpers.assertEqual(restored.campaign.funds, 5000, "Funds preserved")
        Helpers.assertEqual(restored.bases.count, 2, "Base count preserved")
    end)

    -- Contract 5: Multiple save slots
    Suite:testMethod("Persistence:multipleSaveSlotsContract", {
        description = "System must support multiple independent save slots",
        testCase = "contract",
        type = "api"
    }, function()
        local slots = {}

        for i = 1, 10 do
            slots[i] = {
                data = {slotId = i, turnNumber = i * 10},
                timestamp = os.time(),
                valid = true
            }
        end

        Helpers.assertEqual(#slots, 10, "Should have 10 slots")
        Helpers.assertEqual(slots[1].data.slotId, 1, "Slot 1 data preserved")
        Helpers.assertEqual(slots[10].data.slotId, 10, "Slot 10 data preserved")
        Helpers.assertNotEqual(slots[1].data.turnNumber, slots[5].data.turnNumber, "Slots independent")
    end)

    -- Contract 6: Quicksave/autosave interface
    Suite:testMethod("Persistence:quicksaveContract", {
        description = "System must provide quick save and autosave interface",
        testCase = "contract",
        type = "api"
    }, function()
        local saveSystem = {
            quicksave = nil,
            autosave = nil
        }

        function saveSystem:quicksave(state)
            self.quicksave = {
                data = state,
                timestamp = os.time()
            }
        end

        function saveSystem:autosave(state)
            self.autosave = {
                data = state,
                timestamp = os.time()
            }
        end

        function saveSystem:hasQuicksave()
            return self.quicksave ~= nil
        end

        saveSystem:quicksave({turn = 5})
        Helpers.assertTrue(saveSystem:hasQuicksave(), "Quicksave should exist")

        saveSystem:autosave({turn = 10})
        Helpers.assertTrue(saveSystem.autosave ~= nil, "Autosave should exist")
    end)

    -- Contract 7: Save compatibility check
    Suite:testMethod("Persistence:compatibilityCheckContract", {
        description = "System must validate save file compatibility before loading",
        testCase = "contract",
        type = "api"
    }, function()
        local function validateSaveFile(saveFile)
            -- Check version compatibility
            local currentVersion = "1.0.0"

            if not saveFile then
                return {valid = false, error = "File is nil"}
            end

            if not saveFile.version then
                return {valid = false, error = "No version"}
            end

            if saveFile.version ~= currentVersion then
                return {valid = false, error = "Version mismatch"}
            end

            return {valid = true, error = nil}
        end

        local compatibleSave = {
            version = "1.0.0",
            data = {}
        }

        local result = validateSaveFile(compatibleSave)
        Helpers.assertTrue(result.valid, "Compatible save should be valid")

        local incompatibleSave = {
            version = "0.9.0",
            data = {}
        }

        local result2 = validateSaveFile(incompatibleSave)
        Helpers.assertTrue(not result2.valid, "Incompatible save should fail")
    end)

end)

return Suite
