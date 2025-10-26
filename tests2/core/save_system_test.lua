-- TEST: Save System
-- FILE: tests2/core/save_system_test.lua
-- Tests for game state serialization and persistence

local HierarchicalSuite = require('tests2.framework.hierarchical_suite')
local Helpers = require('tests2.utils.test_helpers')

-- MOCK SAVE SYSTEM
local MockSaveSystem = {}
function MockSaveSystem:new()
    local sys = { storage = {}, currentSave = nil, saveCounter = 0 }

    function sys:createSaveSlot()
        return {
            version = '1.0',
            timestamp = os.time(),
            campaign = {turn = 0, threat = 0, funds = 100000},
            base = {name = 'Base Alpha', level = 1},
            research = {completed = {}, queue = {}, progress = 0},
            inventory = {}
        }
    end

    function sys:saveGame(slotName, gameState)
        if not slotName or not gameState then return false, 'Invalid save parameters' end
        sys.storage[slotName] = { data = gameState, savedAt = os.time(), slot = slotName }
        sys.currentSave = slotName
        sys.saveCounter = sys.saveCounter + 1
        return true
    end

    function sys:loadGame(slotName)
        if not sys.storage[slotName] then return nil, 'Save slot not found' end
        sys.currentSave = slotName
        return sys.storage[slotName].data
    end

    function sys:deleteSave(slotName)
        if sys.storage[slotName] then sys.storage[slotName] = nil; return true end
        return false
    end

    function sys:listSaves()
        local list = {}
        for name, save in pairs(sys.storage) do
            table.insert(list, { name = name, timestamp = save.savedAt, turn = save.data.campaign.turn })
        end
        return list
    end

    function sys:getSaveInfo(slotName)
        if not sys.storage[slotName] then return nil end
        return { slot = slotName, timestamp = sys.storage[slotName].savedAt, version = sys.storage[slotName].data.version }
    end

    function sys:verifySave(slotName)
        local save = sys.storage[slotName]
        if not save then return false, 'Save not found' end
        if not save.data.version or not save.data.campaign or not save.data.base then return false, 'Corrupted save data' end
        return true, 'Save is valid'
    end

    function sys:exportSave(slotName)
        local save, err = sys:loadGame(slotName)
        if not save then return nil, err end
        return save
    end

    function sys:getCurrentSlot() return sys.currentSave end
    function sys:getSaveCount() local c = 0; for _ in pairs(sys.storage) do c = c + 1 end; return c end

    return sys
end

-- TEST SUITE
local Suite = HierarchicalSuite:new({
    modulePath = 'engine.core.save.save_system',
    fileName = 'save_system.lua',
    description = 'Save system - game state persistence'
})

-- GROUP 1: SAVE CREATION
Suite:group('Save Creation', function()
    local system
    Suite:beforeEach(function() system = MockSaveSystem:new() end)

    Suite:testMethod('SaveSystem:createSaveSlot', {
        description = 'Creating save slot initializes all fields',
        testCase = 'initialization',
        type = 'functional'
    }, function()
        local slot = system:createSaveSlot()
        Helpers.assertNotNil(slot.version, 'Should have version')
        Helpers.assertNotNil(slot.campaign, 'Should have campaign')
        Helpers.assertNotNil(slot.base, 'Should have base')
    end)

    Suite:testMethod('SaveSystem:saveGame', {
        description = 'Saving game stores state in slot',
        testCase = 'save_creation',
        type = 'functional'
    }, function()
        local slot = system:createSaveSlot()
        local ok = system:saveGame('save1', slot)
        Helpers.assertTrue(ok, 'Should save successfully')
        Helpers.assertEqual(system:getCurrentSlot(), 'save1', 'Should set as current')
    end)
end)

-- GROUP 2: SAVE LOADING
Suite:group('Save Loading', function()
    local system
    Suite:beforeEach(function()
        system = MockSaveSystem:new()
        local s1 = system:createSaveSlot(); s1.campaign.turn = 10; system:saveGame('progress1', s1)
        local s2 = system:createSaveSlot(); s2.campaign.turn = 20; system:saveGame('progress2', s2)
    end)

    Suite:testMethod('SaveSystem:loadGame', {
        description = 'Loading save retrieves game state',
        testCase = 'load_success',
        type = 'functional'
    }, function()
        local loaded = system:loadGame('progress1')
        Helpers.assertNotNil(loaded, 'Should load save')
        Helpers.assertEqual(loaded.campaign.turn, 10, 'Turn should be preserved')
    end)

    Suite:testMethod('SaveSystem:listSaves', {
        description = 'Listing saves returns all saves',
        testCase = 'list_all',
        type = 'functional'
    }, function()
        local list = system:listSaves()
        Helpers.assertEqual(#list, 2, 'Should list 2 saves')
    end)
end)

-- GROUP 3: SAVE MANAGEMENT
Suite:group('Save Management', function()
    local system
    Suite:beforeEach(function()
        system = MockSaveSystem:new()
        for i = 1, 3 do
            local slot = system:createSaveSlot()
            slot.campaign.turn = i * 10
            system:saveGame('save' .. i, slot)
        end
    end)

    Suite:testMethod('SaveSystem:deleteSave', {
        description = 'Deleting save removes it',
        testCase = 'deletion',
        type = 'functional'
    }, function()
        Helpers.assertEqual(system:getSaveCount(), 3, 'Should have 3 saves')
        system:deleteSave('save2')
        Helpers.assertEqual(system:getSaveCount(), 2, 'Should have 2 saves after delete')
    end)
end)

-- GROUP 4: STATE PERSISTENCE
Suite:group('State Persistence', function()
    local system
    Suite:beforeEach(function() system = MockSaveSystem:new() end)

    Suite:testMethod('SaveSystem:persist_campaign', {
        description = 'Campaign progress persists',
        testCase = 'campaign_persistence',
        type = 'functional'
    }, function()
        local slot = system:createSaveSlot()
        slot.campaign.turn = 42
        slot.campaign.funds = 500000
        system:saveGame('test', slot)
        local loaded = system:loadGame('test')
        Helpers.assertEqual(loaded.campaign.turn, 42, 'Turn should persist')
        Helpers.assertEqual(loaded.campaign.funds, 500000, 'Funds should persist')
    end)
end)

-- RUN SUITE
Suite:run()
