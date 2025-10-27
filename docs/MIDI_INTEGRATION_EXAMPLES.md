-- MIDI Integration Guide - Examples for Your Game Scenes
-- Copy-paste examples for adding MIDI playback to your game

-- ============================================
-- EXAMPLE 1: Main Menu with Background Music
-- ============================================

-- In: engine/gui/scenes/main_menu.lua

local AudioManager = require("core.audio_manager")

local MainMenu = {
    background_music = nil,
    selected_option = 1,
    options = {"New Game", "Load Game", "Settings", "Quit"}
}

function MainMenu:load()
    print("[MainMenu] Initializing")
    -- Play menu background music
    AudioManager:playMIDI("MIDI TEST/Queen - Bohemian Rhapsody.mid")
    AudioManager:setMIDIVolume(0.5)  -- Lower volume for background
end

function MainMenu:update(dt)
    -- Update logic
end

function MainMenu:draw()
    love.graphics.clear(0.1, 0.1, 0.15)

    -- Draw menu UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("ALIEN FALL", 0, 100, love.graphics.getWidth(), "center")

    for i, option in ipairs(self.options) do
        if i == self.selected_option then
            love.graphics.setColor(1, 1, 0)  -- Highlight selected
        else
            love.graphics.setColor(0.7, 0.7, 0.7)
        end
        love.graphics.printf(option, 0, 200 + i * 50, love.graphics.getWidth(), "center")
    end
end

function MainMenu:keypressed(key)
    if key == "up" then
        self.selected_option = math.max(1, self.selected_option - 1)
    elseif key == "down" then
        self.selected_option = math.min(#self.options, self.selected_option + 1)
    elseif key == "return" then
        if self.options[self.selected_option] == "Quit" then
            AudioManager:stopMIDI()  -- Stop music before quitting
            love.event.quit()
        end
    end
end

-- ============================================
-- EXAMPLE 2: Battle Scene with Dynamic Music
-- ============================================

-- In: engine/gui/scenes/battle_scene.lua

local AudioManager = require("core.audio_manager")

local BattleScene = {
    current_phase = "player_turn",
    music_playing = false
}

function BattleScene:startBattle()
    print("[BattleScene] Battle started")

    -- Play epic battle music
    AudioManager:playMIDI("battle_theme")
    AudioManager:setMIDIVolume(0.7)
    self.music_playing = true
end

function BattleScene:endBattle(victory)
    print("[BattleScene] Battle ended")

    -- Stop battle music
    AudioManager:stopMIDI()

    if victory then
        -- Play victory theme
        AudioManager:playMIDI("victory_theme")
    else
        -- Play defeat theme
        AudioManager:playMIDI("defeat_theme")
    end
end

function BattleScene:pauseBattle()
    -- Pause music during pause menu
    AudioManager:pauseMIDI()
end

function BattleScene:resumeBattle()
    -- Resume music
    AudioManager:resumeMIDI()
end

-- ============================================
-- EXAMPLE 3: Geoscape with Background Music
-- ============================================

-- In: engine/gui/scenes/geoscape_screen.lua

local AudioManager = require("core.audio_manager")

local GeoscapeScreen = {
    ambient_music = "geoscape_theme",
    is_active = true
}

function GeoscapeScreen:load()
    -- Play ambient geoscape music on loop
    AudioManager:playMIDI(self.ambient_music)
    AudioManager:setMIDIVolume(0.4)  -- Very subtle background
end

function GeoscapeScreen:unload()
    -- Stop music when leaving geoscape
    AudioManager:stopMIDI()
end

-- ============================================
-- EXAMPLE 4: Custom MIDI Player Widget
-- ============================================

-- In: engine/gui/widgets/midi_player_widget.lua
-- Simple embedded MIDI player for UI

local AudioManager = require("core.audio_manager")

local MidiPlayerWidget = {
    x = 10,
    y = 10,
    w = 200,
    h = 100,
    current_file = nil,
    is_playing = false,
    volume = 0.6,
    show_volume_bar = false
}

function MidiPlayerWidget:draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("MIDI Player", self.x + 10, self.y + 10)

    -- Draw current file
    if self.current_file then
        love.graphics.setColor(0.7, 0.7, 0.7)
        local short_name = self.current_file:sub(1, 20) .. ".."
        love.graphics.print(short_name, self.x + 10, self.y + 30)
    end

    -- Draw status
    if self.is_playing then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("▶ Playing", self.x + 10, self.y + 50)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("⏹ Stopped", self.x + 10, self.y + 50)
    end

    -- Draw volume
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print(string.format("Vol: %.0f%%", self.volume * 100), self.x + 10, self.y + 70)
end

function MidiPlayerWidget:mousepressed(mx, my, button)
    if mx >= self.x and mx <= self.x + self.w and
       my >= self.y and my <= self.y + self.h then
        if button == 1 then
            if self.is_playing then
                self:pause()
            else
                self:play()
            end
        elseif button == 2 then
            self:stop()
        end
    end
end

function MidiPlayerWidget:play()
    if not self.current_file then return end
    AudioManager:playMIDI(self.current_file)
    AudioManager:setMIDIVolume(self.volume)
    self.is_playing = true
end

function MidiPlayerWidget:pause()
    AudioManager:pauseMIDI()
end

function MidiPlayerWidget:resume()
    AudioManager:resumeMIDI()
    self.is_playing = true
end

function MidiPlayerWidget:stop()
    AudioManager:stopMIDI()
    self.is_playing = false
end

function MidiPlayerWidget:setVolume(vol)
    self.volume = math.max(0, math.min(1, vol))
    AudioManager:setMIDIVolume(self.volume)
end

function MidiPlayerWidget:loadFile(file)
    self.current_file = file
end

return MidiPlayerWidget

-- ============================================
-- EXAMPLE 5: Cutscene with Music Sync
-- ============================================

-- In: engine/gui/scenes/cutscene.lua

local AudioManager = require("core.audio_manager")

local Cutscene = {
    duration = 0,           -- Total cutscene duration in seconds
    elapsed = 0,            -- Elapsed time
    music_file = nil,
    events = {}             -- Timed events {time = t, action = func}
}

function Cutscene:new(music_file, events)
    local self = setmetatable({}, {__index = Cutscene})
    self.music_file = music_file
    self.events = events or {}
    return self
end

function Cutscene:start()
    print("[Cutscene] Starting")
    if self.music_file then
        AudioManager:playMIDI(self.music_file)
        AudioManager:setMIDIVolume(0.8)
    end
    self.elapsed = 0
end

function Cutscene:update(dt)
    self.elapsed = self.elapsed + dt

    -- Trigger timed events
    for _, event in ipairs(self.events) do
        if not event.triggered and self.elapsed >= event.time then
            event.action()
            event.triggered = true
        end
    end

    -- Check if finished
    if self.elapsed > self.duration then
        self:finish()
    end
end

function Cutscene:finish()
    print("[Cutscene] Finished")
    AudioManager:stopMIDI()
end

-- Usage:
--[[
local cutscene = Cutscene:new("cutscene_theme", {
    {time = 0, action = function() print("Fade in") end},
    {time = 2, action = function() print("Show text") end},
    {time = 5, action = function() print("Show character") end},
})
cutscene.duration = 10  -- 10 second cutscene
cutscene:start()
]]

-- ============================================
-- EXAMPLE 6: Sound Effects with MIDI Background
-- ============================================

-- In: Your game scene

local AudioManager = require("core.audio_manager")

function exampleSceneInit()
    -- Start background MIDI
    AudioManager:playMIDI("background_theme")
    AudioManager:setMIDIVolume(0.4)  -- Background volume
end

function exampleOnButtonClick()
    -- Play sound effect (doesn't interfere with MIDI)
    AudioManager:playSFX("button_click")
    AudioManager:setSFXVolume(0.7)
end

function exampleOnExplosion()
    -- Play explosion SFX
    AudioManager:playSFX("explosion")

    -- Optionally lower MIDI volume during big effects
    AudioManager:setMIDIVolume(0.3)

    -- Restore after delay
    -- (in next frame or use a timer)
    -- AudioManager:setMIDIVolume(0.4)
end

-- ============================================
-- EXAMPLE 7: Complete Scene Template
-- ============================================

--[[
-- In: engine/gui/scenes/your_scene.lua

local AudioManager = require("core.audio_manager")
local StateManager = require("core.state.state_manager")

local YourScene = {
    music_file = "your_music",
    music_volume = 0.6,
    paused = false,
    is_active = false
}

function YourScene:init()
    -- Called when scene is first created
    self.is_active = true
    AudioManager:playMIDI(self.music_file)
    AudioManager:setMIDIVolume(self.music_volume)
    print("[YourScene] Initialized with music")
end

function YourScene:update(dt)
    if not self.is_active then return end

    -- Your game logic here
    AudioManager:update(dt)  -- Important! Update audio every frame
end

function YourScene:draw()
    love.graphics.clear(0.1, 0.1, 0.15)
    -- Your drawing code here
end

function YourScene:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        self:cleanup()
        StateManager.switch("menu")
    elseif key == "p" then
        if self.paused then
            AudioManager:resumeMIDI()
            self.paused = false
        else
            AudioManager:pauseMIDI()
            self.paused = true
        end
    end
end

function YourScene:mousepressed(x, y, button, istouch, presses)
    -- Handle mouse input
end

function YourScene:cleanup()
    -- Called when leaving scene
    AudioManager:stopMIDI()
    self.is_active = false
    print("[YourScene] Cleanup complete")
end

return YourScene
]]

-- ============================================
-- QUICK REFERENCE
-- ============================================

--[[
AudioManager API:

PLAYBACK CONTROL:
  AudioManager:playMIDI(filename)     -- Start playing MIDI
  AudioManager:pauseMIDI()            -- Pause current MIDI
  AudioManager:resumeMIDI()           -- Resume from pause
  AudioManager:stopMIDI()             -- Stop completely

VOLUME:
  AudioManager:setMIDIVolume(0.5)     -- Set MIDI volume (0-1)
  AudioManager:setMasterVolume(0.8)   -- Set master volume (0-1)

EFFECTS:
  AudioManager:playSFX(name)          -- Play sound effect
  AudioManager:playMusic(name)        -- Play background music

STATUS:
  AudioManager:getMIDIStatus()        -- Returns "playing" or "stopped"

LIFECYCLE:
  AudioManager:update(dt)             -- Call in love.update()
  AudioManager:pauseAll()             -- Pause all audio
  AudioManager:resumeAll()            -- Resume all audio
  AudioManager:stopAll()              -- Stop everything

COMMON PATTERNS:

1. Menu with background music:
   AudioManager:playMIDI("menu_theme")
   AudioManager:setMIDIVolume(0.5)

2. Battle with dramatic music:
   AudioManager:playMIDI("battle_theme")
   AudioManager:setMIDIVolume(0.8)

3. Pause/Resume:
   AudioManager:pauseMIDI()
   AudioManager:resumeMIDI()

4. Scene transition:
   AudioManager:stopMIDI()
   AudioManager:playMIDI("next_scene_theme")

5. Gentle background:
   AudioManager:setMIDIVolume(0.3)

6. Fade effect (over time):
   -- Gradually lower volume frame by frame
   current_volume = math.max(0, current_volume - 0.01)
   AudioManager:setMIDIVolume(current_volume)
]]

-- ============================================
-- END OF EXAMPLES
-- ============================================
