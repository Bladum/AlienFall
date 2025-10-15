---Tests Menu Screen
---
---Developer menu for accessing test utilities, system validators, and development
---tools. Provides navigation to unit tests, integration tests, performance tests,
---widget showcases, and system validation tools.
---
---Available Tests:
---  - Widget Showcase: Interactive UI component demonstration
---  - Unit Tests: Run individual system tests
---  - Integration Tests: Test system interactions
---  - Performance Tests: Benchmark critical systems
---  - Mapblock Validator: Validate map data integrity
---  - Asset Verification: Check asset loading
---
---Key Exports:
---  - TestsMenu:enter(): Initializes test menu with buttons
---  - TestsMenu:draw(): Renders menu interface
---  - TestsMenu:keypressed(key): Handles navigation (Escape to return)
---  - TestsMenu:update(dt): Updates button states
---
---Dependencies:
---  - core.state_manager: For switching to test screens
---  - widgets.init: For menu buttons and UI
---  - core.mapblock_validator: For mapblock validation
---  - utils.verify_assets: For asset verification
---
---@module scenes.tests_menu
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Registered automatically in main.lua
---  StateManager.register("tests_menu", TestsMenu)
---  StateManager.switch("tests_menu")
---
---@see scenes.widget_showcase For UI component demos
---@see core.mapblock_validator For map validation
---@see scenes.main_menu For returning to main menu

local StateManager = require("core.state_manager")
local Widgets = require("widgets.init")

local TestsMenu = {}

function TestsMenu:enter()
    print("[TestsMenu] Entering tests menu state")
    
    -- Window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Title
    self.title = "TESTS & UTILITIES"
    self.subtitle = "Development Tools"
    
    -- Create buttons
    local buttonWidth = 288
    local buttonHeight = 48
    local buttonX = (windowWidth - buttonWidth) / 2
    local startY = windowHeight / 2 - 144
    local spacing = 72
    
    self.buttons = {}
    
    -- Widget Showcase button
    local button = Widgets.Button.new(
        buttonX,
        startY,
        buttonWidth,
        buttonHeight,
        "WIDGET SHOWCASE"
    )
    button.onClick = function()
        StateManager.switch("widget_showcase")
    end
    table.insert(self.buttons, button)
    
    -- Run All Tests button
    local button2 = Widgets.Button.new(
        buttonX,
        startY + spacing,
        buttonWidth,
        buttonHeight,
        "RUN ALL TESTS"
    )
    button2.onClick = function()
        self:runAllTests()
    end
    table.insert(self.buttons, button2)
    
    -- Performance Tests button
    local button3 = Widgets.Button.new(
        buttonX,
        startY + spacing * 2,
        buttonWidth,
        buttonHeight,
        "PERFORMANCE TESTS"
    )
    button3.onClick = function()
        local TestRunner = require("tests.test_runner")
        TestRunner.runAllTests()
    end
    table.insert(self.buttons, button3)
    
    -- Asset Verification button
    local button4 = Widgets.Button.new(
        buttonX,
        startY + spacing * 3,
        buttonWidth,
        buttonHeight,
        "VERIFY ASSETS"
    )
    button4.onClick = function()
        self:runAssetVerification()
    end
    table.insert(self.buttons, button4)
    
    -- Mapblock Validation button
    local button5 = Widgets.Button.new(
        buttonX,
        startY + spacing * 4,
        buttonWidth,
        buttonHeight,
        "VALIDATE MAPBLOCKS"
    )
    button5.onClick = function()
        self:runMapblockValidation()
    end
    table.insert(self.buttons, button5)
    
    -- Toggle Map Generation button
    local MapGenerator = require("battlescape.maps.map_generator")
    local currentMethod = MapGenerator.getMethod()
    local button6 = Widgets.Button.new(
        buttonX,
        startY + spacing * 5,
        buttonWidth,
        buttonHeight,
        "MAP GEN: " .. currentMethod:upper()
    )
    button6.onClick = function()
        local newMethod = (MapGenerator.getMethod() == "mapblock") and "procedural" or "mapblock"
        MapGenerator.setMethod(newMethod)
        button6.text = "MAP GEN: " .. newMethod:upper()
        print("[TestsMenu] Map generation method: " .. newMethod)
    end
    table.insert(self.buttons, button6)
    
    -- Back to Main Menu button
    local button7 = Widgets.Button.new(
        buttonX,
        startY + spacing * 6,
        buttonWidth,
        buttonHeight,
        "BACK TO MAIN MENU"
    )
    button7.onClick = function()
        StateManager.switch("menu")
    end
    table.insert(self.buttons, button7)
    
    -- Test output area
    self.testOutput = ""
    self.outputY = startY + spacing * 6 + 24
end

function TestsMenu:exit()
    print("[TestsMenu] Exiting tests menu state")
end

function TestsMenu:runAllTests()
    print("[TestsMenu] Running all test suites...")
    self.testOutput = "Running tests...\n"
    
    -- Run test runner
    local success, result = pcall(function()
        local TestRunner = require("tests.test_runner")
        return TestRunner.runAllTests()
    end)
    
    if not success then
        self.testOutput = self.testOutput .. "ERROR: " .. tostring(result) .. "\n"
        print("[TestsMenu] Test runner failed: " .. tostring(result))
    else
        self.testOutput = self.testOutput .. "Test runner completed\n"
    end
    
    -- Run phase 2 tests
    success, result = pcall(function()
        local Phase2Tests = require("tests.test_phase2")
        return Phase2Tests.runAll()
    end)
    
    if not success then
        self.testOutput = self.testOutput .. "ERROR: " .. tostring(result) .. "\n"
        print("[TestsMenu] Phase 2 tests failed: " .. tostring(result))
    else
        self.testOutput = self.testOutput .. "Phase 2 tests completed\n"
    end
    
    -- Run battle systems tests
    success, result = pcall(function()
        local BattleTests = require("tests.test_battle_systems")
        return BattleTests.runAll()
    end)
    
    if not success then
        self.testOutput = self.testOutput .. "ERROR: " .. tostring(result) .. "\n"
        print("[TestsMenu] Battle systems tests failed: " .. tostring(result))
    else
        self.testOutput = self.testOutput .. "Battle systems tests completed\n"
    end
    
    self.testOutput = self.testOutput .. "\nAll test suites completed!\nCheck console for details."
    print("[TestsMenu] All test suites completed")
end

function TestsMenu:runAssetVerification()
    print("[TestsMenu] Running asset verification...")
    self.testOutput = "Running asset verification...\n"
    
    local success, result = pcall(function()
        local AssetVerifier = require("utils.verify_assets")
        return AssetVerifier.run(true)  -- true = create placeholders
    end)
    
    if not success then
        self.testOutput = self.testOutput .. "ERROR: " .. tostring(result) .. "\n"
        print("[TestsMenu] Asset verification failed: " .. tostring(result))
    else
        self.testOutput = self.testOutput .. string.format(
            "Verification complete!\n" ..
            "Terrain types: %d\n" ..
            "Unit classes: %d\n" ..
            "Assets found: %d\n" ..
            "Assets missing: %d\n" ..
            "Placeholders created: %d\n" ..
            "\nCheck console and temp folder for full report.",
            #result.terrainTypes,
            #result.unitClasses,
            #result.verifiedAssets,
            #result.missingAssets,
            #result.placeholdersCreated
        )
    end
    
    print("[TestsMenu] Asset verification completed")
end

function TestsMenu:runMapblockValidation()
    print("[TestsMenu] Running mapblock validation...")
    self.testOutput = "Running mapblock validation...\n"
    
    local success, result = pcall(function()
        local MapblockValidator = require("core.mapblock_validator")
        return MapblockValidator.run()
    end)
    
    if not success then
        self.testOutput = self.testOutput .. "ERROR: " .. tostring(result) .. "\n"
        print("[TestsMenu] Mapblock validation failed: " .. tostring(result))
    else
        self.testOutput = self.testOutput .. string.format(
            "Validation complete!\n" ..
            "Total mapblocks: %d\n" ..
            "Valid: %d\n" ..
            "Invalid: %d\n" ..
            "Total tiles checked: %d\n" ..
            "Invalid tiles: %d\n" ..
            "Total issues: %d\n" ..
            "\nCheck console and temp folder for full report.",
            #result.mapblocks,
            #result.validMapblocks,
            #result.invalidMapblocks,
            result.totalTiles,
            result.invalidTiles,
            #result.issues
        )
    end
    
    print("[TestsMenu] Mapblock validation completed")
end

function TestsMenu:update(dt)
    local mx, my = love.mouse.getPosition()
    
    -- Update all buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end
end

function TestsMenu:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Clear background
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf(self.title, 0, 100, windowWidth, "center")
    
    -- Draw subtitle
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf(self.subtitle, 0, 145, windowWidth, "center")
    
    -- Draw all buttons
    love.graphics.setFont(love.graphics.newFont(14))
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
    
    -- Draw test output if available
    if self.testOutput ~= "" then
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.printf(self.testOutput, 50, self.outputY, windowWidth - 100, "left")
    end
end

function TestsMenu:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("menu")
    end
end

function TestsMenu:mousepressed(x, y, button, istouch, presses)
    -- Handle button presses through widget system
    for _, btn in ipairs(self.buttons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end
    return false
end

function TestsMenu:mousereleased(x, y, button, istouch, presses)
    -- Handle button clicks through widget system
    for _, btn in ipairs(self.buttons) do
        if btn:mousereleased(x, y, button) then
            return true
        end
    end
    return false
end

return TestsMenu






















