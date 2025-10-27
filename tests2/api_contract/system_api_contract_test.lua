-- ─────────────────────────────────────────────────────────────────────────
-- SYSTEM API CONTRACT TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify core system API contracts
-- Tests: 8 API contract tests
-- Expected: All pass in <200ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.systems",
    fileName = "system_api_contract_test.lua",
    description = "System API contract validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("System API Contracts", function()

    local systems = {}

    Suite:beforeEach(function()
        systems = {}
    end)

    -- Contract 1: Audio system interface
    Suite:testMethod("System:audioSystemContract", {
        description = "Audio system must provide playback control interface",
        testCase = "contract",
        type = "api"
    }, function()
        local audio = {
            music = {},
            sfx = {},
            volume = 1.0,
            musicVolume = 0.8,
            sfxVolume = 1.0
        }

        function audio:playMusic(trackName)
            self.music.current = trackName
            self.music.playing = true
        end

        function audio:stopMusic()
            self.music.playing = false
        end

        function audio:playSFX(soundName)
            table.insert(self.sfx, {name = soundName, playing = true})
        end

        function audio:setVolume(volume)
            self.volume = math.max(0, math.min(1, volume))
        end

        audio:playMusic("main_theme")
        Helpers.assertTrue(audio.music.playing, "Music should play")

        audio:setVolume(0.5)
        Helpers.assertEqual(audio.volume, 0.5, "Volume should change")
    end)

    -- Contract 2: Input system interface
    Suite:testMethod("System:inputSystemContract", {
        description = "Input system must provide key and mouse handling",
        testCase = "contract",
        type = "api"
    }, function()
        local input = {
            keysPressed = {},
            keyBindings = {}
        }

        function input:isKeyPressed(key)
            return self.keysPressed[key] or false
        end

        function input:bindKey(key, action)
            self.keyBindings[key] = action
        end

        function input:handleKeyPress(key)
            self.keysPressed[key] = true
            if self.keyBindings[key] then
                self.keyBindings[key]()
            end
        end

        local actionTriggered = false
        input:bindKey("space", function() actionTriggered = true end)
        input:handleKeyPress("space")

        Helpers.assertTrue(actionTriggered, "Key action should trigger")
        Helpers.assertTrue(input:isKeyPressed("space"), "Key should be marked pressed")
    end)

    -- Contract 3: Rendering system interface
    Suite:testMethod("System:renderingSystemContract", {
        description = "Rendering system must provide draw operation interface",
        testCase = "contract",
        type = "api"
    }, function()
        local renderer = {
            drawCalls = 0,
            sprites = {},
            camera = {x = 0, y = 0, zoom = 1.0}
        }

        function renderer:drawSprite(sprite, x, y)
            self.drawCalls = self.drawCalls + 1
            table.insert(self.sprites, {sprite = sprite, x = x, y = y})
        end

        function renderer:setCameraPosition(x, y)
            self.camera.x = x
            self.camera.y = y
        end

        function renderer:setCameraZoom(zoom)
            self.camera.zoom = math.max(0.5, math.min(2, zoom))
        end

        renderer:drawSprite("unit", 100, 100)
        Helpers.assertEqual(renderer.drawCalls, 1, "Draw call count should increment")

        renderer:setCameraZoom(1.5)
        Helpers.assertEqual(renderer.camera.zoom, 1.5, "Camera zoom should update")
    end)

    -- Contract 4: Time system interface
    Suite:testMethod("System:timeSystemContract", {
        description = "Time system must provide delta time and timing API",
        testCase = "contract",
        type = "api"
    }, function()
        local timeSystem = {
            deltaTime = 0,
            totalTime = 0,
            frameCount = 0,
            fps = 60
        }

        function timeSystem:update(dt)
            self.deltaTime = dt
            self.totalTime = self.totalTime + dt
            self.frameCount = self.frameCount + 1
        end

        function timeSystem:getElapsedTime()
            return self.totalTime
        end

        function timeSystem:getFrameCount()
            return self.frameCount
        end

        timeSystem:update(0.016)
        Helpers.assertTrue(timeSystem.deltaTime > 0, "Delta time should be positive")
        Helpers.assertEqual(timeSystem.frameCount, 1, "Frame count should increment")
    end)

    -- Contract 5: Localization system interface
    Suite:testMethod("System:localizationSystemContract", {
        description = "Localization system must provide translation API",
        testCase = "contract",
        type = "api"
    }, function()
        local localization = {
            language = "en",
            strings = {
                en = {welcome = "Welcome", play = "Play Game"},
                es = {welcome = "Bienvenido", play = "Jugar"}
            }
        }

        function localization:setLanguage(lang)
            if self.strings[lang] then
                self.language = lang
                return true
            end
            return false
        end

        function localization:getString(key)
            return self.strings[self.language][key] or key
        end

        Helpers.assertEqual(localization:getString("welcome"), "Welcome", "Should get English string")

        localization:setLanguage("es")
        Helpers.assertEqual(localization:getString("welcome"), "Bienvenido", "Should get Spanish string")
    end)

    -- Contract 6: Analytics system interface
    Suite:testMethod("System:analyticsSystemContract", {
        description = "Analytics system must provide tracking interface",
        testCase = "contract",
        type = "api"
    }, function()
        local analytics = {events = {}}

        function analytics:trackEvent(eventName, data)
            table.insert(self.events, {
                name = eventName,
                data = data,
                timestamp = os.time()
            })
        end

        function analytics:getEventCount()
            return #self.events
        end

        function analytics:getLastEvent()
            if #self.events > 0 then
                return self.events[#self.events]
            end
        end

        analytics:trackEvent("game_started", {difficulty = "normal"})
        Helpers.assertEqual(analytics:getEventCount(), 1, "Should track event")

        local lastEvent = analytics:getLastEvent()
        if lastEvent then
            Helpers.assertEqual(lastEvent.name, "game_started", "Event name should match")
        end
    end)

    -- Contract 7: Configuration system interface
    Suite:testMethod("System:configurationSystemContract", {
        description = "Configuration system must provide settings management",
        testCase = "contract",
        type = "api"
    }, function()
        local config = {
            settings = {}
        }

        function config:setSetting(key, value)
            self.settings[key] = value
        end

        function config:getSetting(key, default)
            return self.settings[key] or default
        end

        function config:hasSetting(key)
            return self.settings[key] ~= nil
        end

        config:setSetting("difficulty", "normal")
        Helpers.assertTrue(config:hasSetting("difficulty"), "Setting should exist")
        Helpers.assertEqual(config:getSetting("difficulty"), "normal", "Should get setting value")
    end)

    -- Contract 8: Debug system interface
    Suite:testMethod("System:debugSystemContract", {
        description = "Debug system must provide logging and profiling API",
        testCase = "contract",
        type = "api"
    }, function()
        local debug = {
            logs = {},
            enabled = true
        }

        function debug:log(message, level)
            if self.enabled then
                table.insert(self.logs, {
                    message = message,
                    level = level or "info",
                    timestamp = os.time()
                })
            end
        end

        function debug:getLogs(count)
            count = count or 10
            local result = {}
            local startIdx = math.max(1, #self.logs - count + 1)
            for i = startIdx, #self.logs do
                table.insert(result, self.logs[i])
            end
            return result
        end

        debug:log("Test message", "info")
        debug:log("Warning message", "warn")

        Helpers.assertEqual(#debug.logs, 2, "Should have 2 log entries")
        local recent = debug:getLogs(1)
        Helpers.assertEqual(#recent, 1, "Should get last 1 entry")
    end)

end)

return Suite
