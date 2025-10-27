# How to Switch Back to Main Menu (or Change Startup Scene)

## Current Setup

The game currently starts with:
```
MIDI Test Screen (for testing MIDI playback)
```

## Switch to Main Menu

### Option 1: Edit main.lua (Permanent)

Open: `engine/main.lua`

Find this line (around line 190):
```lua
    -- Start with MIDI test screen
    StateManager.switch("midi_test")
```

Change to:
```lua
    -- Start with menu
    StateManager.switch("menu")
```

Save and run:
```bash
lovec engine
```

### Option 2: Quick Toggle (Temporary)

Comment out the MIDI test line temporarily:

```lua
    -- Start with MIDI test screen
    -- StateManager.switch("midi_test")
    
    -- Start with menu
    StateManager.switch("menu")
```

## Other Starting Scenes

You can start with any registered scene:

```lua
-- Main menu (default)
StateManager.switch("menu")

-- Geoscape (strategic map)
StateManager.switch("geoscape")

-- Battlescape (combat)
StateManager.switch("battlescape")

-- Base management
StateManager.switch("basescape")

-- Test menu
StateManager.switch("tests_menu")

-- Widget showcase
StateManager.switch("widget_showcase")

-- Map editor
StateManager.switch("map_editor")

-- New campaign wizard
StateManager.switch("new_campaign_wizard")

-- Load game screen
StateManager.switch("load_game")

-- Campaign stats
StateManager.switch("campaign_stats")

-- Settings
StateManager.switch("settings")

-- MIDI test (our new scene)
StateManager.switch("midi_test")
```

## Still Access MIDI Test

After switching back to menu, you can still access MIDI Test through:

1. **Add button to main menu** linking to MIDI test
2. **Add menu option** "Audio Test" → MIDI Test Screen
3. **Create hidden hotkey** (e.g., Ctrl+M) to toggle to MIDI test

### Example: Add to Main Menu

In `engine/gui/scenes/main_menu.lua`, add to options:

```lua
self.options = {
    "New Game",
    "Load Game", 
    "Audio Test",    -- ← New option
    "Settings",
    "Quit"
}

-- Then in selection handler:
if self.options[self.selected_option] == "Audio Test" then
    StateManager.switch("midi_test")
end
```

## After Setup

Once SF2 samples are extracted, you can:

1. **Keep MIDI test as startup** for quick audio testing
2. **Switch back to menu** for normal gameplay
3. **Add MIDI music** to menu, battles, cutscenes
4. **Create audio settings screen** for volume control

## Summary

- **To play MIDI test**: Start game (currently set to MIDI test)
- **To play main game**: Edit line 190 in `engine/main.lua`
- **To access both**: Add menu option linking to MIDI test

---

**Next**: Extract SF2 samples and enjoy professional-quality MIDI! 🎵
