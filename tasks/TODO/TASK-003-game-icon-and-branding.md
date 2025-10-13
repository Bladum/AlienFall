# Task: Add Game Icon and Rename to Alien Fall

**Status:** TODO  
**Priority:** Medium  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Use icon.png from root folder as the game icon and rename the project from "XCOM Simple" to "Alien Fall" throughout the entire codebase.

---

## Purpose

Establish unique branding for the game and ensure proper icon display in the operating system. Remove all references to XCOM to avoid trademark issues.

---

## Requirements

### Functional Requirements
- [ ] icon.png used as game icon
- [ ] Icon displays correctly in Windows
- [ ] All references to "XCOM" removed from code
- [ ] All references to "XCOM Simple" removed from code
- [ ] All references to "XCOM" removed from documentation
- [ ] Project consistently called "Alien Fall"

### Technical Requirements
- [ ] Icon configured in conf.lua
- [ ] Icon file in correct format and location
- [ ] Multiple icon sizes if needed by OS
- [ ] All string literals updated
- [ ] All comments updated
- [ ] All file paths updated

### Acceptance Criteria
- [ ] Game shows correct icon in taskbar
- [ ] Game shows correct icon in window title bar
- [ ] Game shows correct icon in Alt+Tab
- [ ] No "XCOM" or "XCOM Simple" text anywhere in project
- [ ] All documentation updated
- [ ] Git history preserved

---

## Plan

### Step 1: Configure Game Icon
**Description:** Set up icon.png as game icon in Love2D  
**Files to modify:**
- `engine/conf.lua` - Add window.icon setting

**Files to verify:**
- `icon.png` - Check exists at root

**Estimated time:** 1 hour

### Step 2: Find All XCOM References
**Description:** Search entire codebase for XCOM mentions  
**Commands:**
```bash
# Search all files
grep -r "XCOM" .
grep -r "xcom" .
grep -r "X-COM" .
```

**Estimated time:** 1 hour

### Step 3: Update Code Files
**Description:** Replace all XCOM references in .lua files  
**Files to modify:** (determined by grep)
- All .lua files with XCOM references
- All .bat files
- All configuration files

**Search and replace:**
- "XCOM Simple" → "Alien Fall"
- "XCOM" → "Alien Fall" (context dependent)
- "xcom" → "alienfall" (in file paths, variables)

**Estimated time:** 3 hours

### Step 4: Update Documentation
**Description:** Replace all XCOM references in documentation  
**Files to modify:**
- `README.md`
- `wiki/API.md`
- `wiki/FAQ.md`
- `wiki/DEVELOPMENT.md`
- `wiki/QUICK_REFERENCE.md`
- All other wiki files
- `tasks/TASK_TEMPLATE.md`
- All task files

**Estimated time:** 2 hours

### Step 5: Update Task Files
**Description:** Update existing and template task files  
**Files to modify:**
- `tasks/TASK_TEMPLATE.md`
- All files in `tasks/TODO/`
- All files in `tasks/DONE/`
- `tasks/tasks.md`

**Estimated time:** 1 hour

### Step 6: Update Comments and Strings
**Description:** Update in-code comments and UI strings  
**Files to modify:**
- All .lua files with "XCOM" in comments
- All .lua files with "XCOM" in string literals
- Menu text
- Window titles
- Debug messages

**Estimated time:** 2 hours

### Step 7: Update Paths and File References
**Description:** Update any file paths or references  
**Check:**
- Script names (run_xcom.bat → run_alienfall.bat?)
- Directory references
- Asset paths
- Save file paths

**Estimated time:** 1 hour

### Step 8: Testing
**Description:** Verify icon works and no XCOM references remain  
**Test:**
- Launch game and verify icon
- Check taskbar icon
- Check Alt+Tab icon
- Search for remaining XCOM references
- Test all major game features still work

**Estimated time:** 2 hours

### Step 9: Update External References
**Description:** Update any external documentation  
**Files to modify:**
- GitHub repository name (if applicable)
- GitHub description
- Any external wiki links
- Any external documentation

**Estimated time:** 1 hour

---

## Implementation Details

### Architecture

**Icon Configuration:**
```lua
-- engine/conf.lua
function love.conf(t)
    t.identity = "AlienFall"
    t.window.title = "Alien Fall"
    t.window.icon = "icon.png"  -- Path relative to game root
    -- ... rest of config
end
```

**Icon Requirements:**
- Format: PNG
- Recommended sizes: 16x16, 32x32, 48x48, 64x64, 128x128, 256x256
- Love2D will scale if only one size provided
- Transparency supported

### Key Components
- **Icon File:** `icon.png` at root
- **Config:** `engine/conf.lua` window.icon setting
- **Branding:** All UI text shows "Alien Fall"

### Search and Replace Strategy
1. Use grep to find all occurrences
2. Review each occurrence for context
3. Replace manually to ensure accuracy
4. Some references may need different replacements:
   - "XCOM Simple" → "Alien Fall"
   - "XCOM mechanics" → "XCOM-inspired mechanics" (when referring to inspiration)
   - "run_xcom.bat" → "run_alienfall.bat" or "run_game.bat"

---

## Testing Strategy

### Manual Testing Steps
1. Run `grep -r "XCOM" .` and verify no unwanted matches
2. Run `grep -r "xcom" .` and verify no unwanted matches
3. Launch game with `lovec "engine"`
4. Check window shows icon
5. Check taskbar shows icon
6. Check Alt+Tab shows icon
7. Check main menu shows "Alien Fall"
8. Check window title shows "Alien Fall"
9. Check any save files use new name
10. Check Love2D console for any errors

### Expected Results
- Icon displays correctly in all OS contexts
- No "XCOM" or "XCOM Simple" visible anywhere
- Game functions normally
- All references updated consistently

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Checking Icon
- Windows: Check taskbar and title bar
- Alt+Tab to see icon in task switcher
- Check game window properties

### Finding Remaining References
```bash
# Case sensitive
grep -r "XCOM" . --exclude-dir=.git

# Case insensitive
grep -ri "xcom" . --exclude-dir=.git

# Check specific file types
grep -r "XCOM" . --include="*.lua" --include="*.md"
```

---

## Documentation Updates

### Files to Update
- [x] `README.md` - Update project name
- [x] `wiki/API.md` - Update references
- [x] `wiki/FAQ.md` - Update game name
- [x] `wiki/DEVELOPMENT.md` - Update references
- [x] `wiki/QUICK_REFERENCE.md` - Update references
- [x] All other wiki files
- [x] `tasks/TASK_TEMPLATE.md` - Update example
- [x] All task files in TODO/DONE folders
- [x] `engine/conf.lua` - Add icon and update title

---

## Notes

- Keep references to "XCOM-inspired" or "X-COM style" when describing game design inspiration
- UFO Defense references can stay (that's the actual game we're inspired by)
- Be careful with case sensitivity (XCOM vs xcom vs Xcom)
- Some references in git history will remain - that's OK
- May want to update repository name on GitHub separately

---

## Blockers

Need to verify icon.png exists and is suitable format.

---

## Review Checklist

- [ ] icon.png verified as valid PNG
- [ ] Icon configured in conf.lua
- [ ] Icon displays in game window
- [ ] Icon displays in taskbar
- [ ] Icon displays in Alt+Tab
- [ ] All code references updated
- [ ] All documentation updated
- [ ] All comments updated
- [ ] All task files updated
- [ ] No grep matches for "XCOM" (except git history)
- [ ] Game launches without errors
- [ ] All features still work
- [ ] Branding is consistent

---

## Post-Completion

### What Worked Well
- To be filled after completion

### What Could Be Improved
- To be filled after completion

### Lessons Learned
- To be filled after completion
