# Integration Testing Implementation Guide

**Document**: Integration Testing Framework  
**Task**: TASK-5  
**Purpose**: Comprehensive manual testing of complete game loop  
**Date**: October 21, 2025  

---

## Quick Start Testing

### Test Setup

1. **Terminal 1 - Game Instance**:
   ```bash
   cd c:\Users\tombl\Documents\Projects
   lovec "engine"
   ```
   - Game launches with console visible
   - Monitor console for errors
   - Record any [ERROR], [WARN], or unexpected messages

2. **Recording Method**:
   - Copy console output into test results document
   - Note timestamps of major state transitions
   - Screenshot key UI elements if needed
   - Document any glitches or unexpected behavior

---

## Testing Procedures

### TEST SEQUENCE 1: Startup & Menu (Est. 5 min)

**Objective**: Verify game initializes and menu displays correctly

**Procedure**:
1. Launch game with `lovec "engine"`
2. Wait for window to open (target: 2-3 seconds)
3. **Console Check**:
   - Look for [ERROR] messages → Flag if found
   - Look for module loading messages → Should see all load confirmations
   - Look for [Main] Game initialized successfully → Should appear
4. **Window Check**:
   - Resolution is 960×720 ✓
   - Title bar says "Alien Fall" ✓
   - No visual artifacts or glitches ✓
5. **Menu Check**:
   - Title "ALIEN FALL" visible ✓
   - Subtitle "A Tactical Strategy Game" visible ✓
   - Buttons visible:
     - [ ] GEOSCAPE
     - [ ] BATTLESCAPE DEMO
     - [ ] BASESCAPE
     - [ ] Additional options (if present)
   - Button text readable ✓
   - All UI aligned to grid ✓

**Success Criteria**:
- ✅ Window opens in < 3 seconds
- ✅ Console shows clean initialization
- ✅ Menu renders without artifacts
- ✅ All buttons visible and positioned correctly
- ✅ Frame rate: 60 FPS (check in console)

**Result**: __ PASS __ FAIL (Details below)

**Issues Found**:
```
[Document any issues here]
```

**Console Output** (Copy relevant portions):
```
[Startup console output]
```

---

### TEST SEQUENCE 2: Geoscape - Strategic Map (Est. 10 min)

**Objective**: Verify Geoscape layer displays and functions correctly

**Procedure**:

1. **Navigate to Geoscape**:
   - From menu, click "GEOSCAPE" button
   - **Console**: Should show `[StateManager] Switched to state: geoscape`
   - **Window**: Should display strategic map

2. **Visual Verification**:
   - World map visible ✓
   - Mission markers visible on map ✓
   - UI elements present:
     - [ ] Resource display (funds, research, etc.)
     - [ ] Squad status
     - [ ] Base location
     - [ ] Navigation options
   - Text readable ✓
   - Grid alignment correct ✓

3. **Interaction Check**:
   - Hover over mission marker
   - Click on mission marker
   - Verify mission details appear:
     - [ ] Mission location
     - [ ] Difficulty level
     - [ ] Enemy composition
     - [ ] Rewards offered
     - [ ] "Start Mission" option

4. **Console Check**:
   - No ERROR messages ✓
   - Appropriate state transition messages ✓
   - No nil reference errors ✓

**Success Criteria**:
- ✅ Geoscape renders completely
- ✅ Mission markers visible and interactive
- ✅ Resource displays show correct values
- ✅ No console errors
- ✅ State transition successful

**Result**: __ PASS __ FAIL (Details below)

**Issues Found**:
```
[Document any issues here]
```

**Console Output** (Copy relevant portions):
```
[Geoscape state transition and initialization]
```

**Resource Values Observed**:
- Starting Funds: ________
- Starting Scientists: ________
- Starting Engineers: ________
- Base Power: ________/________

---

### TEST SEQUENCE 3: Mission Launch to Battlescape (Est. 20 min)

**Objective**: Verify mission launches and battlescape loads correctly

**Procedure**:

1. **Select Mission**:
   - From Geoscape, click on a visible mission marker
   - Mission details should display
   - Click "Start Mission" or equivalent button
   - **Console**: Should show state transition messages

2. **State Transition Monitor**:
   ```
   Expected console messages:
   [StateManager] Attempting to switch to: battlescape
   [Geoscape] Exiting geoscape...
   [StateManager] Switched to state: battlescape
   [Battlescape] Entering battlescape...
   [MapGen] Generating map...
   [MapGen] Generated X tiles
   [Units] Spawning player squad...
   [Units] Spawning enemy squad...
   [Combat] Combat system ready
   ```

3. **Map Verification**:
   - Map displayed completely ✓
   - Tileset appropriate for biome ✓
   - No inaccessible areas (verify with pathfinding later) ✓
   - Fog of war present ✓
   - Player units visible at spawn zone ✓
   - Enemy units visible at their spawn zone ✓

4. **Unit Verification**:
   - Count player squad:
     - Expected: 4-6 units
     - Actual: ________
   - Each unit has:
     - [ ] Health bar
     - [ ] Name/ID
     - [ ] Equipment visible
     - [ ] Action points
   - Count enemy squad:
     - Expected: 3-5 units (based on difficulty)
     - Actual: ________
   - Enemy types appropriate for mission ✓

5. **Combat UI Verification**:
   - Action points display for current unit ✓
   - End Turn button visible ✓
   - Combat log visible (if present) ✓
   - Turn counter shows "Turn 1" ✓
   - Selected unit highlighted ✓
   - Movement range preview (if available) ✓

6. **Console Check**:
   - No ERROR messages ✓
   - Map generation completed ✓
   - Unit spawning successful ✓
   - No missing asset errors ✓

**Success Criteria**:
- ✅ State transition successful (geoscape → battlescape)
- ✅ Map generated and rendered
- ✅ All units deployed correctly
- ✅ Combat UI fully functional
- ✅ No console errors
- ✅ Frame rate maintained (≥ 30 FPS)

**Result**: __ PASS __ FAIL (Details below)

**Mission Details Observed**:
- Mission Type: ________
- Map Dimensions: ________x________
- Biome: ________
- Player Squad Size: ________
- Enemy Squad Size: ________

**Issues Found**:
```
[Document any issues here]
```

**Console Output** (Copy relevant portions):
```
[Map generation and unit spawning]
```

---

### TEST SEQUENCE 4: Combat Loop - Multiple Turns (Est. 30 min)

**Objective**: Verify turn-based combat functions correctly through 5+ turns

**Procedure**:

1. **Turn 1 - Player Phase**:
   - **Unit Selection**: Click on first unit (should highlight)
   - **Movement**: 
     - Click on valid destination (within movement range)
     - Unit should move (animation or instant)
     - Console should show movement executed
     - Action points should decrease (e.g., 20 → 5)
   - **Action**:
     - Click on attack button or enemy unit
     - Verify hit chance displayed (e.g., "75% chance to hit")
     - Confirm action
     - Animation plays or damage shows
     - Console shows: `[Combat] Hit: X% → HIT/MISS`
   - **End Unit**: Click "End Turn" when done with squad

2. **Turn 1 - AI Phase**:
   - **Observation**: AI units take actions
   - **Verify**:
     - [ ] Each enemy unit moves
     - [ ] Enemies attack if target in range
     - [ ] Combat log updates
     - [ ] Damage applied to player units
     - [ ] Turn advances automatically
   - **Console**:
     - Should show AI decisions
     - Should show damage calculations
     - Should show turn advancement

3. **Repeat for Turns 2-5**:
   - Continue combat for 5 full turns
   - Monitor for:
     - [ ] Consistent behavior
     - [ ] No duplicate actions
     - [ ] Initiative order maintained
     - [ ] Status effects applied (if any)
     - [ ] Health tracking accurate

4. **Combat Statistics Tracking**:

   | Turn | Player Units | Enemy Units | Actions Taken | Damage Dealt | Console Errors |
   |------|-------------|------------|---------------|--------------|-----------------|
   | 1    | __ 6       | __ 4      | ________      | ________     | ________        |
   | 2    | __ 6       | __ 4      | ________      | ________     | ________        |
   | 3    | __ 6       | __ 4      | ________      | ________     | ________        |
   | 4    | __ 6       | __ 3      | ________      | ________     | ________        |
   | 5    | __ 5       | __ 3      | ________      | ________     | ________        |

5. **Console Monitoring**:
   - Copy relevant combat messages:
   ```
   [Paste combat resolution messages]
   ```

**Success Criteria**:
- ✅ Movement works with valid pathfinding
- ✅ Actions resolve with hit/miss calculations
- ✅ Damage calculated and applied correctly
- ✅ AI takes reasonable actions
- ✅ Combat log shows all actions
- ✅ Turn advancement automatic
- ✅ No combat calculation errors
- ✅ No console errors
- ✅ Frame rate maintained during combat

**Result**: __ PASS __ FAIL (Details below)

**Combat Observations**:
- Movement behavior: ________
- Combat calculations appear: ________
- AI decision-making quality: ________
- Any balance issues: ________

**Issues Found**:
```
[Document any issues here]
```

---

### TEST SEQUENCE 5: Mission Completion (Est. 15 min)

**Objective**: Complete mission and verify resolution and rewards

**Procedure**:

1. **Play to Mission End** (choose fastest path):
   - **Option A**: Defeat all enemies (estimated: 20-30 min)
   - **Option B**: Trigger mission abort/failure
   - **Option C**: Reach mission objective (if applicable)
   
   Note: For this test, play 2-3 more turns until a clear winner emerges

2. **Mission Complete Screen**:
   - Screen displays after battle ends:
     - [ ] "MISSION COMPLETE" or "MISSION FAILED" message
     - [ ] Battle summary visible:
       - Enemies killed: ________
       - Units lost: ________
       - Turns taken: ________
       - Loot: ________
     - [ ] XP awarded display
     - [ ] "Continue" button or equivalent

3. **Reward Verification**:
   - XP values for each survivor:
     ```
     Unit 1: ________ XP
     Unit 2: ________ XP
     Unit 3: ________ XP
     (etc.)
     ```
   - Equipment/loot listed: ________
   - Any ranking/evaluation shown: ________

4. **Console Check**:
   - Should show: `[Mission] Mission complete: SUCCESS` (or FAILURE)
   - Should show: Reward distribution messages
   - No ERROR messages ✓

5. **Return to Geoscape**:
   - Click "Continue" button
   - **Console**: Should show `[StateManager] Switched to state: geoscape`
   - **Window**: Should display updated Geoscape with mission removed/completed

**Success Criteria**:
- ✅ Mission completion triggered correctly
- ✅ Summary screen displays accurate data
- ✅ Rewards calculated and displayed
- ✅ State transition back to geoscape
- ✅ No console errors
- ✅ Squad status updated correctly

**Result**: __ PASS __ FAIL (Details below)

**Mission Result**: __ VICTORY __ DEFEAT __ ABORT

**Console Output** (Copy relevant portions):
```
[Mission completion and reward messages]
```

**Issues Found**:
```
[Document any issues here]
```

---

### TEST SEQUENCE 6: Basescape - Base Management (Est. 15 min)

**Objective**: Verify Basescape renders and functions

**Procedure**:

1. **Access Basescape**:
   - From Geoscape, click "Basescape" button or navigate to basescape screen
   - **Console**: Should show state transition to basescape
   - Wait for display to render

2. **Base Grid Verification**:
   - Base grid displays (40×60):
     - [ ] Grid visible and correct dimensions
     - [ ] Facilities shown at correct positions
     - [ ] Grid alignment to 24×24 ✓
     - [ ] Coordinate system visible (if applicable)

3. **Facilities Verification**:
   - Identify visible facilities:
     ```
     Facility: ________ at grid position (__, __)
     Facility: ________ at grid position (__, __)
     Facility: ________ at grid position (__, __)
     ```
   - Each facility shows:
     - [ ] Name/type
     - [ ] Status (operational/damaged/offline)
     - [ ] Power connection indicator
     - [ ] Current level/upgrade if applicable

4. **Resource Display Verification**:
   - Display shows:
     - [ ] Current funds: ________
     - [ ] Scientists available: ________
     - [ ] Engineers available: ________
     - [ ] Power current/max: ________/__________
     - [ ] Manufacturing queue position: ________
     - [ ] Research project name: ________

5. **Research & Manufacturing**:
   - Current research project shown: ________
   - Progress displayed: ________%
   - Manufacturing queue visible:
     ```
     Item 1: ________ (Progress: ________%)
     Item 2: ________ (Progress: ________%)
     ```

6. **Console Check**:
   - No ERROR messages ✓
   - Base data loaded correctly ✓
   - Facility information accessible ✓

**Success Criteria**:
- ✅ Basescape renders completely
- ✅ Facility grid displays correctly (40×60)
- ✅ All resources show accurate values
- ✅ Manufacturing/research queues visible
- ✅ No console errors
- ✅ UI properly grid-aligned

**Result**: __ PASS __ FAIL (Details below)

**Base Status Observed**:
- Total Facilities: ________
- Operational: ________
- Powered: ________
- Power Balance: __________ excess/shortage

**Issues Found**:
```
[Document any issues here]
```

**Console Output** (Copy relevant portions):
```
[Basescape state and base data initialization]
```

---

### TEST SEQUENCE 7: Save & Load (Est. 20 min)

**Objective**: Verify save/load functionality preserves game state

**Procedure**:

1. **Current Game State Documentation**:
   From current geoscape position, record:
   ```
   Pre-save State:
   - Funds: ________
   - Research: ________ at __________% progress
   - Squad Status: ________ units, ________ injured
   - Completed Missions: ________
   - Current Military Base Level: ________
   ```

2. **Save Game**:
   - Trigger save game (through menu or hotkey)
   - **Console** should show: `[Save] Saving game...`
   - Monitor for: `[Save] Save complete`
   - Note save file location: ________
   - Note file size: __________ bytes

3. **Verify Save File**:
   - File exists in expected location ✓
   - File size is reasonable (not 0, not > 50MB) ✓
   - File is readable ✓

4. **Quit and Restart**:
   - Quit game (ESC or menu)
   - Game closes cleanly
   - Relaunch game: `lovec "engine"`
   - Wait for menu to appear

5. **Load Game**:
   - From main menu, click "Load Game"
   - Previous save should appear in list
   - Click on save file to load
   - **Console** should show: `[Load] Loading save...`
   - Monitor for: `[Load] Game restored`
   - Wait for geoscape to display

6. **Verify Restored State**:
   ```
   Post-load State:
   - Funds: ________ (should match pre-save: ________)
   - Research: ________ at __________% (should match)
   - Squad Status: ________ units (should match)
   - Completed Missions: ________ (should match)
   - Base Level: ________ (should match)
   ```

7. **Game Playability**:
   - Game playable after load ✓
   - Can start new mission ✓
   - Can navigate to basescape ✓
   - No corrupted data ✓

8. **Console Check**:
   - No ERROR messages during save ✓
   - No ERROR messages during load ✓
   - Save/load completed successfully ✓

**Success Criteria**:
- ✅ Save file created successfully
- ✅ Load restores all game state
- ✅ Pre-save and post-load values match exactly
- ✅ Game fully playable after load
- ✅ No console errors
- ✅ No data loss

**Result**: __ PASS __ FAIL (Details below)

**Data Integrity Check**:
- Match: __ YES __ NO __ PARTIAL
- Discrepancies: ________

**Console Output** (Copy relevant portions):
```
[Save/Load messages]
```

**Issues Found**:
```
[Document any issues here]
```

---

### TEST SEQUENCE 8: Error Handling Edge Cases (Est. 20 min)

**Objective**: Verify game handles errors and edge cases gracefully

**Procedure**:

1. **Resource Shortage Test**:
   - Play until funds are very low (< 1000 credits)
   - **Observation**: Can player still navigate all screens? ✓
   - **Expected**: Game continues, warning shown but no crash
   - Can research/manufacturing queue items without crashing? ✓

2. **Power Shortage Test**:
   - In Basescape, disable power generation if possible
   - **Observation**: Does game crash? __ YES __ NO
   - Facilities marked offline? __ YES __ NO
   - Can power be restored? __ YES __ NO
   - Console clean? __ YES __ NO

3. **Unit Status Edge Cases**:
   - Try to move an injured unit (if injury system exists)
   - Try to attack with low ammo
   - **Observation**: Actions still work correctly? ✓
   - Penalties applied but no crash? ✓

4. **Extreme Combat Test**:
   - Play mission where all player units could be eliminated
   - **Observation**: Does loss condition trigger cleanly? ✓
   - Game doesn't crash on total squad wipe? ✓
   - Can load save or continue to menu? ✓

5. **Navigation Edge Cases**:
   - Rapidly switch between Geoscape and Basescape
   - **Observation**: State remains consistent? ✓
   - No duplicate entities? ✓
   - UI updates correctly? ✓
   - Console shows no errors? ✓

6. **Console Error Monitoring**:
   Throughout all edge case tests, document any:
   - [ ] ERROR level messages
   - [ ] Nil reference errors
   - [ ] State machine errors
   - [ ] Missing content errors

**Success Criteria**:
- ✅ Game doesn't crash in any scenario
- ✅ Error messages are clear and helpful
- ✅ Game state never corrupts
- ✅ Recovery mechanisms work
- ✅ Console shows no ERROR messages

**Result**: __ PASS __ FAIL (Details below)

**Edge Cases Summary**:
- Resource Shortage: __ PASS __ FAIL
- Power Shortage: __ PASS __ FAIL
- Unit Edge Cases: __ PASS __ FAIL
- Loss Condition: __ PASS __ FAIL
- Rapid Navigation: __ PASS __ FAIL

**Console Errors Encountered**:
```
[List any errors found]
```

**Issues Found**:
```
[Document any issues here]
```

---

## Overall Test Summary

### Completion Status

| Test Sequence | Duration | Result | Issues | Follow-up |
|--------------|----------|--------|--------|-----------|
| 1: Startup & Menu | 5 min | __ | __ | __ |
| 2: Geoscape | 10 min | __ | __ | __ |
| 3: Battlescape Entry | 20 min | __ | __ | __ |
| 4: Combat Loop | 30 min | __ | __ | __ |
| 5: Mission Complete | 15 min | __ | __ | __ |
| 6: Basescape | 15 min | __ | __ | __ |
| 7: Save & Load | 20 min | __ | __ | __ |
| 8: Edge Cases | 20 min | __ | __ | __ |
| **TOTAL** | **~2.5 hrs** | __ | __ | __ |

### Console Health Summary

```
Total ERROR messages: ________
Total WARN messages: ________
Total unexplained crashes: ________

Clean run: __ YES __ NO
```

### Performance Summary

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Startup time | < 3s | ________ | ✓ |
| Menu FPS | 60 | ________ | ✓ |
| Map generation | < 2s | ________ | ✓ |
| Combat FPS | ≥ 30 | ________ | ✓ |
| Save time | < 1s | ________ | ✓ |
| Load time | < 1s | ________ | ✓ |

### Critical Issues Found

```
[List critical issues that must be fixed before next phase]
```

### Next Steps

1. ✓ Document all findings
2. ✓ Categorize issues by priority
3. ✓ Create bug fix tasks if needed
4. ✓ Update alignment score (currently 89.2%)
5. ✓ Proceed to Task 6: Error Recovery Documentation

