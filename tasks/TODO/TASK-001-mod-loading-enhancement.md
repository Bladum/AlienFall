# Task: Mod Loading System Enhancement

**Status:** TODO  
**Priority:** Critical  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Ensure the mod "new" (xcom_simple) loads automatically on game startup and is globally accessible via ModManager throughout the application.

---

## Purpose

To establish a reliable content loading system where all game data comes from the mod system. This ensures consistency, moddability, and eliminates hardcoded content dependencies.

---

## Requirements

### Functional Requirements
- [x] Mod "new" loads automatically during `love.load()`
- [ ] ModManager sets "new" as active mod by default
- [ ] All content accessible globally via `ModManager.getContent()` APIs
- [ ] Console logging confirms mod loading success

### Technical Requirements
- [ ] `ModManager.init()` properly initializes and loads mods
- [ ] Active mod is set before DataLoader runs
- [ ] No hardcoded content paths in game code
- [ ] All content access goes through ModManager API

### Acceptance Criteria
- [ ] Game starts with mod loaded (console shows "[ModManager] Found mod: XCOM Simple")
- [ ] `ModManager.getActiveMod()` returns xcom_simple mod
- [ ] All terrain, weapons, units load from mod successfully
- [ ] No errors in Love2D console related to mod loading

---

## Plan

### Step 1: Review Current ModManager Implementation
**Description:** Analyze `systems/mod_manager.lua` to understand current loading logic  
**Files to review:**
- `engine/systems/mod_manager.lua`
- `engine/main.lua`

**Estimated time:** 15 minutes

### Step 2: Implement Auto-Loading
**Description:** Ensure init() loads mods and sets active mod automatically  
**Files to modify:**
- `engine/systems/mod_manager.lua` (init function)
- `engine/main.lua` (verify init call happens early)

**Estimated time:** 30 minutes

### Step 3: Add Global Content Access
**Description:** Verify and test content access methods  
**Files to review/modify:**
- `engine/systems/mod_manager.lua` (getContent, getContentPath methods)
- `engine/systems/data_loader.lua` (verify usage)

**Estimated time:** 15 minutes

### Step 4: Testing
**Description:** Run game and verify mod loads correctly  
**Test cases:**
- Mod loads on startup
- Active mod is set
- Content paths resolve correctly
- All TOML files load

**Estimated time:** 15 minutes

---

## Implementation Details

### Architecture
ModManager acts as central content registry. On init:
1. Scan mods directory for mod.toml files
2. Load and parse each valid mod
3. Sort by load_order
4. Set first enabled mod as active
5. Cache content paths

### Key Components
- **ModManager.init():** Main initialization entry point
- **ModManager.scanMods():** Discovers available mods
- **ModManager.loadMods():** Loads discovered mods
- **ModManager.setActiveMod():** Sets the primary content source
- **ModManager.getContentPath():** Resolves content file paths

### Dependencies
- TOML parser library (libs.toml)
- love.filesystem for directory scanning
- DataLoader system relies on ModManager being initialized

---

## Testing Strategy

### Unit Tests
- Test scanMods() finds "new" folder
- Test TOML parsing succeeds
- Test active mod is set correctly

### Integration Tests
- Test full init sequence in main.lua
- Test DataLoader can access mod content
- Test battlescape loads terrain from mod

### Manual Testing Steps
1. Run `lovec "engine"` from project root
2. Check console for "[ModManager] Found mod: XCOM Simple"
3. Check console for "[ModManager] Active mod set to: xcom_simple"
4. Enter battlescape and verify terrain loads
5. Check no errors about missing content

### Expected Results
- Console shows mod loading messages
- Game starts without errors
- Battlescape displays properly with mod content

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console enabled in `conf.lua`
- Check for ModManager initialization messages
- Look for any "[ERROR]" messages in console
- Use `print(ModManager.getActiveMod())` to verify active mod

### Console Output to Look For
```
[ModManager] Scanning X items in mods directory
[ModManager] Found mod: XCOM Simple (v0.1.0)
[ModManager] Registered mod: XCOM Simple (xcom_simple)
[ModManager] Active mod set to: xcom_simple
```

---

## Documentation Updates

### Files to Update
- [x] `tasks/tasks.md` - Add task entry
- [ ] `wiki/API.md` - Document ModManager.init() behavior
- [ ] `wiki/DEVELOPMENT.md` - Note mod loading as prerequisite

---

## Notes

Current implementation already has most functionality. Main focus is ensuring init() is called correctly and active mod is set automatically.

---

## Blockers

None identified. ModManager and TOML system already implemented.

---

## Review Checklist

- [ ] Mod loads automatically on startup
- [ ] Active mod is set before DataLoader runs
- [ ] No global variables introduced
- [ ] Proper error handling with console messages
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
