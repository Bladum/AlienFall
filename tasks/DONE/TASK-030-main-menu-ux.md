# Task: Main Menu & UX - Campaign Start/Load Interface

**Status:** TODO
**Priority:** High
**Created:** October 24, 2025
**Completed:** N/A
**Assigned To:** AI Agent

---

## Overview

Create the main menu system that allows players to:
1. Start a new campaign with difficulty/faction selection
2. Load existing campaigns from save files
3. Configure campaign settings (speed, difficulty presets)
4. View campaign progression & stats
5. Access game settings and documentation

This is the **player entry point** to the completed campaign system.

---

## Purpose

The campaign system (TASK-025) is complete and playable, but players have no way to access it. Without a main menu:
- Players cannot start new campaigns
- Existing saves cannot be loaded
- Game settings cannot be configured
- Campaign progression is invisible

This task makes the campaign system accessible and user-friendly.

---

## Requirements

### Functional Requirements
- [ ] Main menu displays campaign start/load/settings buttons
- [ ] New game creates campaign with selected difficulty & faction
- [ ] Load game displays list of save files with metadata
- [ ] Save file metadata shows: date, campaign day, units alive, threat level
- [ ] Difficulty presets affect campaign parameters (3 levels: Easy/Normal/Hard)
- [ ] Game returns to main menu after campaign end/quit
- [ ] Settings menu configures: difficulty, speed, volume, resolution
- [ ] Campaign progression visible in main menu (days played, threats defeated)

### Technical Requirements
- [ ] Create MainMenuState in state manager
- [ ] Integrate SaveGameManager (TASK-025 Phase 10)
- [ ] Save file browser with filtering
- [ ] New game wizard with faction/difficulty selection
- [ ] Campaign stats display
- [ ] State transitions: MainMenu ↔ Campaign ↔ Battlescape

### Acceptance Criteria
- [ ] Main menu displays without errors (Exit Code 0)
- [ ] New game creates valid campaign with correct difficulty
- [ ] Save file list shows at least 1 loadable file
- [ ] Loading save restores campaign state correctly
- [ ] Difficulty presets affect generated missions appropriately
- [ ] All UI buttons functional (no null reference errors)
- [ ] Settings persist across game sessions

---

## Plan

### Step 1: Main Menu UI Layout (5 hours)
**Description:** Create main menu interface with campaign navigation
**Files to modify/create:**
- `engine/gui/scenes/main_menu_screen.lua` (NEW - 400 lines)
- `engine/gui/widgets/main_menu_buttons.lua` (NEW - 200 lines)
- `engine/gui/styles/main_menu_theme.lua` (NEW - 150 lines)

**Layout (960x720):**
```
╔═══════════════════════════════════════════════════╗
║                  ALIEN FALL CAMPAIGN              ║
║                                                   ║
║  [🎮 NEW CAMPAIGN]    [📁 LOAD GAME]             ║
║                                                   ║
║  [⚙️  SETTINGS]       [📊 STATISTICS]            ║
║                                                   ║
║  [📖 ABOUT]          [❌ EXIT GAME]              ║
║                                                   ║
║  Campaign Progress: Day 156 | Threat Lvl 3       ║
╚═══════════════════════════════════════════════════╝
```

**Estimated time:** 5 hours

### Step 2: New Campaign Wizard (8 hours)
**Description:** Multi-step wizard for starting new campaign
**Files to modify/create:**
- `engine/gui/scenes/new_campaign_wizard.lua` (NEW - 500 lines)
- `engine/gui/widgets/difficulty_selector.lua` (NEW - 150 lines)
- `engine/gui/widgets/faction_selector.lua` (NEW - 200 lines)

**Wizard steps:**
1. **Campaign Name:** Text input for campaign name
2. **Difficulty:** Radio buttons (Easy/Normal/Hard/Ironman)
   - Easy: 0.5x enemy damage, +50% player resources
   - Normal: 1.0x all (baseline)
   - Hard: 1.5x enemy damage, -50% resources
   - Ironman: Hard + permadeath

3. **Starting Faction:** Selection of starting opposition
   - Sectoid Empire (standard)
   - Muton Coalition (aggressive)
   - Ethereal Collective (unpredictable)
   - Hybrid Invasion (all species mixed)

4. **Game Speed:** Selection (1x/2x/4x)

5. **Confirmation:** Review settings before creation

**Estimated time:** 8 hours

### Step 3: Load Game Interface (7 hours)
**Description:** Browse and load saved campaigns
**Files to modify/create:**
- `engine/gui/scenes/load_game_screen.lua` (NEW - 450 lines)
- `engine/gui/widgets/save_file_browser.lua` (NEW - 300 lines)
- `engine/gui/widgets/save_file_card.lua` (NEW - 150 lines)

**Features:**
- List view of all save files (10 slots shown, scrollable)
- Save file metadata card:
  ```
  Campaign: Operation Sunlight
  Date: Oct 24, 2025 14:32
  Day: 156 | Threat: 3/5 | Units: 8/12
  Status: In Progress
  ```
- Delete/Overwrite options on right-click
- Filter by status (In Progress, Won, Lost)
- Sort by date/day/threat
- Auto-load most recent on startup option

**Estimated time:** 7 hours

### Step 4: Campaign Stats Display (4 hours)
**Description:** Show campaign progression & player achievements
**Files to modify/create:**
- `engine/gui/scenes/campaign_stats_screen.lua` (NEW - 300 lines)
- `engine/gui/widgets/stats_panel.lua` (NEW - 200 lines)

**Stats displayed:**
```
Campaign Name: Operation Sunlight
Difficulty: HARD | Days Elapsed: 156

Military Stats:
- Units Recruited: 24
- Units Lost: 4
- Missions Won: 32
- Missions Lost: 3
- AVG Accuracy: 78%

Alien Stats:
- Species Encountered: 3
- Total Kills: 342
- Highest Threat: 4/5
- Research Unlocked: 12/18

Base Stats:
- Facilities Built: 8
- Research Complete: 12
- Manufacturing: 45 items
```

**Estimated time:** 4 hours

### Step 5: Settings Menu (5 hours)
**Description:** Configure game preferences
**Files to modify/create:**
- `engine/gui/scenes/settings_screen.lua` (NEW - 350 lines)
- `engine/gui/widgets/settings_sliders.lua` (NEW - 150 lines)

**Settings:**
- Difficulty: 5-level slider (Tutorial → Impossible)
- Game Speed: 1x / 2x / 4x buttons
- Volume: Master / Music / SFX sliders
- Display: Resolution, Fullscreen toggle, UI Scale
- Gameplay: Auto-save interval, Pause on notification
- Difficulty Presets: Easy/Normal/Hard/Ironman

**Persistent storage:** All settings saved to `preferences.json` in save directory

**Estimated time:** 5 hours

### Step 6: State Management Integration (6 hours)
**Description:** Connect menu system to campaign state
**Files to modify/create:**
- `engine/core/menu_campaign_bridge.lua` (NEW - 300 lines)
- `engine/core/state_manager.lua` (modify - add menu states)

**State transitions:**
```
MainMenu
  ↓ new_campaign → NewCampaignWizard
  ↓ load_game → LoadGameScreen
  ↓ settings → SettingsScreen
  ↓ stats → CampaignStatsScreen
    ↓ (create campaign)
    ↓ (load campaign)
Campaign Loop (TASK-025)
  ↓ (mission complete/return to menu)
MainMenu
```

**Estimated time:** 6 hours

### Step 7: Integration Testing (5 hours)
**Description:** Test menu flow and state persistence
**Files to create:**
- `tests/integration/test_menu_flow.lua` (NEW - 400 lines)
- `tests/integration/test_save_load.lua` (NEW - 300 lines)

**Test scenarios:**
1. Main menu loads without errors
2. New game wizard completes all steps
3. Campaign starts with correct difficulty
4. Save file created in correct location
5. Load game shows saved campaign
6. Load restores campaign state correctly
7. Return to menu after mission
8. Settings persist across game restart

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture

**State Flow:**
```
love.load()
    ↓
StateManager.init("main_menu")
    ↓
MainMenuScreen displayed
    ↓ (user interaction)
    ├→ NewCampaignWizard → CampaignOrchestrator.start()
    ├→ LoadGameScreen → SaveGameManager.load()
    ├→ SettingsScreen → PreferencesManager.save()
    └→ ExitGame → love.event.quit()
```

**Key Relationships:**
- MainMenuScreen is the hub
- All screens return to MainMenuScreen on completion/cancel
- SaveGameManager handles persistence
- CampaignOrchestrator handles campaign creation
- StateManager orchestrates transitions

### Key Components

- **MainMenuScreen:** Central hub with navigation buttons
- **NewCampaignWizard:** Multi-step campaign creation
- **LoadGameScreen:** Save file browser with metadata display
- **SettingsScreen:** Configuration UI
- **CampaignStatsScreen:** Progression viewer
- **MenuCampaignBridge:** Connects menu to campaign systems

### Dependencies

- TASK-025 (Campaign system) - COMPLETE ✅
- SaveGameManager (TASK-025 Phase 10) - COMPLETE ✅
- State Manager (existing) - verified functional
- Widget system (existing) - verified functional

---

## Testing Strategy

### Unit Tests
- Test new game wizard logic (difficulty parameters)
- Test save file parsing (metadata extraction)
- Test difficulty preset calculations
- Test state transitions (no crashes)

### Integration Tests
- Menu → New Campaign → Campaign Launch
- Menu → Load Game → Campaign Resume
- Settings → Save/Load → Verify persistence
- Menu navigation (all buttons functional)
- State cleanup on transitions

### Manual Testing Steps

1. **Start game:**
   - Verify main menu displays
   - All buttons visible and clickable
   - No console errors (check log)

2. **Create new campaign:**
   - Click "NEW CAMPAIGN"
   - Go through wizard (all steps work)
   - Select difficulty/faction/speed
   - Confirm campaign starts with correct settings

3. **Save and load:**
   - Play campaign to day 10+
   - Return to menu (save triggered automatically)
   - Click "LOAD GAME"
   - Select saved campaign
   - Verify campaign restored at correct day

4. **Difficulty validation:**
   - Create Easy game, check resource gain (+50%)
   - Create Hard game, check resource cost (1.5x)
   - Create Ironman, verify permadeath enabled

5. **Settings persistence:**
   - Change volume to 30%
   - Change speed to 2x
   - Change difficulty slider to Hard
   - Restart game
   - Verify all settings restored

### Expected Results

After new campaign:
- Campaign initialized at Day 1
- Threat level = 1
- Base has HQ + 2 starter facilities
- Player roster has 8 rookie units
- Difficulty parameters applied correctly

After load:
- Campaign state restored to exact save point
- Campaign day preserved
- Unit roster restored
- Resources match saved state
- Threat level matches saved state

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging Menu

1. **Add debug menu button:**
```lua
if love.keyboard.isDown("d") and love.keyboard.isDown("lctrl") then
  print("[Menu] Debug button pressed")
end
```

2. **Check state transitions:**
```lua
print("[StateManager] Transitioning from: " .. current_state)
print("[StateManager] Transitioning to: " .. next_state)
```

3. **Verify save file operations:**
```lua
print("[SaveManager] Saved to: " .. filepath)
print("[SaveManager] Loaded from: " .. filepath)
```

### Console Debug Output

```lua
-- Enable debug output in settings:
debug_mode = true

-- All menus print:
print("[MainMenu] Button clicked: " .. button_name)
print("[Wizard] Step: " .. step_number)
print("[LoadGame] Save selected: " .. save_name)
```

---

## Documentation Updates

### Files to Update
- [ ] `docs/USER_MANUAL.md` - Main menu guide (NEW)
- [ ] `docs/CAMPAIGN_GUIDE.md` - Campaign creation (NEW)
- [ ] `docs/DIFFICULTY_GUIDE.md` - Difficulty explanation (NEW)
- [ ] `README.md` - Update with new campaign features
- [ ] Code comments - Menu flow documentation

---

## Notes

- Main menu is first impression - must be polished
- Save file deletion should ask for confirmation
- Consider adding "Continue Campaign" button for quickest access
- Campaign stats should be motivating and visible
- Settings should validate (e.g., resolution within bounds)

---

## Blockers

None identified - all dependencies complete.

---

## Review Checklist

- [ ] Main menu loads without errors
- [ ] All buttons functional and responsive
- [ ] Wizard completes without crashes
- [ ] Save files created and loadable
- [ ] Settings persist across sessions
- [ ] State transitions smooth and reliable
- [ ] UI polished and user-friendly
- [ ] Documentation clear and complete
- [ ] No console errors
- [ ] Performance acceptable (no lag)

---

## Estimated Total Time

**5 + 8 + 7 + 4 + 5 + 6 + 5 = 40 hours (5 days)**
