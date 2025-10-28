# AlienFall - Gap Analysis with Actionable Items

**Date:** October 27, 2025  
**Purpose:** Concrete action items derived from comprehensive quality analysis  
**Organization:** By priority and dependency chains

---

## Critical Path Items (Block MVP)

### 1. Test Infrastructure Repair 🔴
**Status:** BLOCKING  
**Effort:** 2-4 hours  
**Owner:** Technical Lead

**Problem:**
```
[ERROR] Smoke test runner failed: main.lua:84: module 'tests2.smoke' not found
```

**Root Cause:** Love2D doesn't automatically add parent directory as module root.

**Solution Options:**
1. ✅ **RECOMMENDED: Use love.filesystem** (most Love2D-native)
   ```lua
   -- In tests2/main.lua, replace require() with:
   local testFiles = love.filesystem.getDirectoryItems("tests2/smoke")
   for _, file in ipairs(testFiles) do
       if file:match("_test%.lua$") then
           local chunk = love.filesystem.load("tests2/smoke/" .. file)
           chunk()
       end
   end
   ```

2. ⚠️ **Alternative: Modify package.path**
   ```lua
   -- In tests2/conf.lua
   function love.conf(t)
       t.console = true
       package.path = package.path .. ";./?/init.lua;./?.lua"
   end
   ```

3. ⚠️ **Alternative: Console runner from engine/**
   ```bash
   # Create engine/test_runner.lua that properly loads tests
   lovec engine/test_runner smoke
   ```

**Deliverables:**
- [ ] Fix test runner module loading
- [ ] Verify all 6 test phases run successfully
- [ ] Update tests2/README.md with verified instructions
- [ ] Run full test suite and document results

**Dependencies:** None (can start immediately)

---

### 2. M3 Basescape UI Completion 🔴
**Status:** 70% COMPLETE  
**Effort:** 40-60 hours  
**Owner:** UI Developer  
**Deadline:** January 31, 2026

**Remaining Work:**
- [ ] Research UI panel integration (12-16 hours)
- [ ] Manufacturing UI panel integration (12-16 hours)
- [ ] Personnel management UI (8-12 hours)
- [ ] Base facility placement UI polish (4-6 hours)
- [ ] Integration testing (4-8 hours)

**Technical Tasks:**
```lua
-- Create: engine/gui/scenes/basescape_research_panel.lua
-- Create: engine/gui/scenes/basescape_manufacturing_panel.lua
-- Create: engine/gui/scenes/basescape_personnel_panel.lua
-- Update: engine/gui/scenes/basescape_screen.lua (integrate panels)
```

**Validation Criteria:**
- [ ] Player can view research queue and progress
- [ ] Player can add/remove manufacturing orders
- [ ] Player can recruit and assign personnel
- [ ] All panels accessible from basescape screen
- [ ] No UI crashes or blocking bugs

**Dependencies:** None (can work in parallel with other M3 tasks)

---

### 3. Campaign System Integration 🔴
**Status:** 50% COMPLETE  
**Effort:** 32-48 hours  
**Owner:** Campaign Developer  
**Deadline:** January 31, 2026

**Remaining Work:**

**Phase 1: Campaign Data Structure (8-12 hours)**
- [ ] Create `engine/campaign/campaign_state.lua`
  ```lua
  CampaignState = {
      current_phase = number,      -- 0-5
      phase_progress = number,     -- 0-100 per phase
      milestones = string[],       -- Completed milestones
      active_events = Event[],     -- Triggered narrative events
      faction_states = table,      -- Per-faction escalation
  }
  ```
- [ ] Create phase transition logic
- [ ] Create milestone tracking system
- [ ] Save/load campaign state

**Phase 2: Event System (12-16 hours)**
- [ ] Create `engine/campaign/event_manager.lua`
- [ ] Wire events to gameplay triggers
- [ ] Implement event UI (dialog boxes, notifications)
- [ ] Test event flow for Phase 0-1

**Phase 3: Faction Progression (8-12 hours)**
- [ ] Implement faction escalation meter
- [ ] Connect escalation to mission generation
- [ ] Test armada events and reinforcements

**Phase 4: Integration Testing (4-8 hours)**
- [ ] Test full Phase 0 playthrough
- [ ] Verify phase transitions
- [ ] Test save/load with campaign state

**Deliverables:**
- [ ] Campaign state persists across saves
- [ ] Phase progression triggers correctly
- [ ] Events fire based on gameplay conditions
- [ ] Faction escalation affects mission difficulty

**Dependencies:** 
- Requires narrative event content (see Lore Gaps #4)

---

### 4. Critical Lore Gaps Resolution 🔴
**Status:** 35 gaps identified, 5 critical  
**Effort:** 20-25 hours (critical only), 60-80 hours (all gaps)  
**Owner:** Narrative Designer  
**Deadline:** January 31, 2026 (critical), March 31, 2026 (all)

**TIER 1: Critical Gaps (20-25 hours)**

**Gap 1: Portal Mechanics (8-10 hours)**
- **File:** `lore/story/phase_3.md`, `lore/story/phase_5.md`
- **Problem:** Phase III climax and Phase V evacuation depend on undefined portal physics
- **Required:**
  - [ ] Define portal activation mechanism
  - [ ] Explain energy requirements
  - [ ] Describe visual appearance and effects
  - [ ] Specify destination determination (how does portal "know" where to go?)
  - [ ] Document portal stability and failure conditions
  - [ ] Explain why portals enable dimensional travel
  - [ ] Define portal vs. wormhole vs. gate terminology

**Gap 2: Syndicate Leadership (4-6 hours)**
- **File:** `lore/story/factions.md`, `lore/story/phase_1.md`, `lore/story/phase_2.md`
- **Problem:** Villain is faceless throughout entire story
- **Required:**
  - [ ] Create 2-3 named Syndicate leaders with distinct personalities
  - [ ] Define leadership hierarchy and power dynamics
  - [ ] Assign specific decisions to specific leaders (who orders what)
  - [ ] Create character backgrounds and motivations
  - [ ] Define relationships between leaders (allies/rivals)
  - [ ] Specify how player encounters/learns about them

**Gap 3: X-Agency Leader Names (9-12 hours)**
- **File:** All phase files (`phase_0.md` through `phase_5.md`)
- **Problem:** Player organization has unnamed leadership
- **Required:**
  - [ ] Name the Director (strategic leader, appears in cutscenes)
  - [ ] Name the Field Commander (tactical leader, mission briefings)
  - [ ] Create personality traits and voice for each
  - [ ] Define character arcs across 5 phases
  - [ ] Specify key dialog moments for each phase
  - [ ] Create backstories (how they founded X-Agency)
  - [ ] Define relationship dynamics with player

**Gap 4: Syndicate Escape Fate (1-2 hours)**
- **File:** `lore/story/phase_5.md`
- **Problem:** Conflicting options need resolution
- **Decision Required:**
  - [ ] Choose ONE option:
    - **Option A:** Syndicate leaders killed/captured (definitive ending)
    - **Option B:** Some escape, setting up potential sequel
    - **Option C:** Fate mysterious/ambiguous (player interpretation)
  - [ ] Document chosen option in phase_5.md
  - [ ] Ensure consistency with rest of narrative
  - [ ] Update gap_analysis.md to mark resolved

**Gap 5: Minor Details (1-2 hours)**
- **File:** Various
- **Required:**
  - [ ] Resolve minor timeline inconsistencies
  - [ ] Finalize faction color schemes and symbols
  - [ ] Clarify Hybrid rebellion motivation

**TIER 2: High Priority Gaps (25-35 hours)**
- Character personalities and backstories (14-20 hours)
- Faction tactical details and unit types (8-12 hours)
- NPC dialog and characterization (3-5 hours)

**TIER 3: Medium Priority Gaps (15-20 hours)**
- Location descriptions and atmosphere (10-15 hours)
- Environmental storytelling details (3-5 hours)
- Miscellaneous world-building (2-3 hours)

**Deliverables:**
- [ ] Update all affected story files with resolved content
- [ ] Update `lore/story/gap_analysis.md` with completion status
- [ ] Create character profiles in `lore/story/characters.md` (new file)
- [ ] Review for narrative consistency

**Dependencies:** 
- Critical gaps block campaign event system (#3)
- High/Medium gaps can wait until M4

---

## High Priority Items (Impact MVP Quality)

### 5. Balance Values Spreadsheet 🟡
**Status:** NOT STARTED  
**Effort:** 8-12 hours  
**Owner:** Game Designer  
**Deadline:** February 15, 2026

**Problem:** Many design docs have placeholder costs ("TBD", "6-12", "varies")

**Deliverable:** `design/mechanics/Balance_Values.xlsx`

**Required Sheets:**

**Sheet 1: Unit Stats**
| Unit Class | HP | Accuracy | Strength | Reaction | Fire Rate | Recruit Cost | Monthly Salary |
|------------|----|---------:|----------|---------:|----------:|-------------:|---------------:|
| Rifleman   | ?  | ?        | ?        | ?        | ?         | ?            | ?              |
| Medic      | ?  | ?        | ?        | ?        | ?         | ?            | ?              |
| Assault    | ?  | ?        | ?        | ?        | ?         | ?            | ?              |
| ... (all classes) |

**Sheet 2: Facility Costs**
| Facility | Build Cost | Build Time | Maintenance/Month | Power Consumption | Service Provided |
|----------|------------|------------|-------------------|-------------------|------------------|
| Barracks | ?          | ?          | ?                 | ?                 | +8 housing       |
| Lab      | ?          | ?          | ?                 | ?                 | +5 research      |
| ... (all facilities) |

**Sheet 3: Equipment Costs**
| Item | Purchase Cost | Manufacturing Cost | Manufacturing Time | Ammo Cost | Weight |
|------|---------------|--------------------|--------------------|-----------|--------|
| Rifle | ?            | ?                  | ?                  | ?         | ?      |
| ... (all equipment) |

**Sheet 4: Research Costs**
| Tech | Research Time | Prerequisite Techs | Unlocks |
|------|---------------|-----------------------|---------|
| Laser Weapons | ? days | Alien Alloys | Laser Rifle manufacturing |
| ... (all techs) |

**Sheet 5: Mission Rewards**
| Mission Type | Difficulty | Credits | Salvage | XP per Unit |
|--------------|------------|---------|---------|-------------|
| UFO Crash    | Easy       | ?       | ?       | ?           |
| ... (all mission types × difficulties) |

**Tasks:**
- [ ] Extract all cost values from design docs
- [ ] Create initial estimates for missing values
- [ ] Create formulas for derived values (e.g., maintenance = 10% of build cost)
- [ ] Balance pass: ensure economic viability
- [ ] Playtest validation session
- [ ] Finalize values for engine implementation

**Dependencies:** None (can start immediately)

---

### 6. Content-Engine Integration Testing 🟡
**Status:** PARTIAL  
**Effort:** 16-24 hours  
**Owner:** Integration Engineer  
**Deadline:** February 15, 2026

**Problem:** Mod content exists in `mods/core/rules/` but loading/usage unclear

**Audit Tasks:**

**Phase 1: Asset Audit (4-6 hours)**
- [ ] Generate list of all asset references in TOML files
  ```bash
  # Script to extract sprite = "..." from all TOML files
  grep -r "sprite = " mods/core/rules/ > temp/asset_references.txt
  ```
- [ ] Check existence of each referenced asset
- [ ] Create missing placeholder assets
- [ ] Document asset coverage in `mods/core/ASSET_COVERAGE.md`

**Phase 2: TOML Loading Test (4-6 hours)**
- [ ] Create test that loads ALL TOML files from mods/core/
- [ ] Verify ModManager successfully parses each file
- [ ] Log any parse errors or validation failures
- [ ] Fix broken TOML files

**Phase 3: Engine Integration Test (4-6 hours)**
- [ ] Test unit spawning from TOML definitions
- [ ] Test facility construction from TOML definitions
- [ ] Test item usage from TOML definitions
- [ ] Test mission generation from TOML definitions
- [ ] Document any missing engine → TOML integration

**Phase 4: Runtime Validation (4-6 hours)**
- [ ] Start game with mods/core/ active
- [ ] Test full gameplay loop (recruit → equip → deploy → battle)
- [ ] Verify all TOML data loaded correctly
- [ ] Fix any runtime issues

**Deliverables:**
- [ ] All TOML files parse without errors
- [ ] All asset references resolve (or have placeholders)
- [ ] Engine successfully loads and uses mod content
- [ ] Integration test suite passes

**Dependencies:** Requires #1 (test runner fix)

---

### 7. Generate Test Coverage Report 🟡
**Status:** TOOL EXISTS  
**Effort:** 2-3 hours  
**Owner:** QA Engineer  
**Deadline:** February 1, 2026

**Tool Available:** `tests2/framework/coverage_calculator.lua`

**Tasks:**
- [ ] Fix test runner (prerequisite: #1)
- [ ] Run coverage calculator across all engine modules
  ```bash
  lovec tests2/runners run_coverage_analysis
  ```
- [ ] Generate coverage report
  ```
  tests2/reports/coverage_report_2026_02_01.md
  ```
- [ ] Identify modules with <50% coverage
- [ ] Create improvement plan for low-coverage modules
- [ ] Add to quality dashboard

**Report Format:**
```markdown
# Test Coverage Report - February 1, 2026

## Summary
- Total Modules: 87
- Total Functions: 2,341
- Total Tests: 2,493
- Overall Coverage: ?%

## By Module
| Module | Functions | Tested | Coverage | Status |
|--------|-----------|--------|----------|--------|
| core/state_manager | 15 | 12 | 80% | ✅ Good |
| battlescape/combat | 42 | 18 | 43% | ⚠️ Needs work |
...
```

**Dependencies:** Requires #1 (test runner fix)

---

## Medium Priority Items (Polish & UX)

### 8. Notification System Implementation 🟡
**Status:** MENTIONED IN DESIGN  
**Effort:** 12-16 hours  
**Owner:** UI Developer  
**Deadline:** March 1, 2026

**Design Source:** `README.md` mentions "Notification system instead of excessive popups"

**Requirements:**
- [ ] Create `engine/gui/notification_manager.lua`
- [ ] Design notification UI (toast-style, non-blocking)
- [ ] Implement notification queue and stacking
- [ ] Add notification types (info, warning, success, error)
- [ ] Add click-to-dismiss and auto-fade
- [ ] Integrate with event system

**Notification Categories:**
- Research completed
- Manufacturing completed
- Unit promoted
- Mission available
- UFO detected
- Base under attack
- Financial report
- Diplomatic status change

**Deliverables:**
- [ ] Notification system operational
- [ ] All game events trigger appropriate notifications
- [ ] UI polished and non-intrusive
- [ ] Settings to configure notification behavior

**Dependencies:** None

---

### 9. Tutorial System UI Integration 🟡
**Status:** CODE EXISTS, UI INCOMPLETE  
**Effort:** 16-24 hours  
**Owner:** Tutorial Designer + UI Developer  
**Deadline:** March 15, 2026

**Files Exist:**
- `engine/tutorial/` (directory exists)
- Tutorial system mentioned in main.lua

**Tasks:**

**Phase 1: Design Tutorial Flow (4-6 hours)**
- [ ] Create `design/mechanics/Tutorial.md` document
- [ ] Define tutorial stages:
  1. Main menu introduction
  2. Geoscape basics (world map, bases, crafts)
  3. First mission deployment
  4. Battlescape basics (movement, combat)
  5. Post-mission (salvage, research)
  6. Basescape basics (facilities, personnel)
- [ ] Design tutorial UI (step counter, skip button, help tooltips)

**Phase 2: Implement Tutorial System (8-12 hours)**
- [ ] Create `engine/tutorial/tutorial_manager.lua`
- [ ] Implement step progression logic
- [ ] Create tutorial overlay UI
- [ ] Add contextual help tooltips
- [ ] Implement tutorial skip/restart

**Phase 3: Content Creation (4-6 hours)**
- [ ] Write tutorial dialog and instructions
- [ ] Create tutorial mission TOML (simple, controlled scenario)
- [ ] Add tutorial hints to UI elements

**Deliverables:**
- [ ] New players can complete tutorial successfully
- [ ] Tutorial covers all core mechanics
- [ ] Tutorial is skippable
- [ ] Help system accessible from all screens

**Dependencies:** Requires #2 (Basescape UI completion)

---

### 10. Keybind Customization System 🟡
**Status:** HARDCODED  
**Effort:** 8-12 hours  
**Owner:** Input Developer  
**Deadline:** March 15, 2026

**Problem:** Keybinds hardcoded in main.lua (Esc, F9, F12)

**Requirements:**
- [ ] Create `engine/core/input_manager.lua`
- [ ] Create keybind configuration system
- [ ] Add settings screen for keybind customization
- [ ] Implement keybind conflict detection
- [ ] Save keybinds to config file
- [ ] Support keyboard + mouse bindings

**Default Keybinds to Make Configurable:**
| Action | Default | Category |
|--------|---------|----------|
| Quit | Esc | Global |
| Toggle Grid | F9 | Debug |
| Toggle Fullscreen | F12 | Display |
| End Turn | Space | Battlescape |
| Open Inventory | I | Battlescape |
| Next Unit | Tab | Battlescape |
| Open Geoscape | G | Navigation |
| Open Basescape | B | Navigation |

**Deliverables:**
- [ ] All keybinds customizable
- [ ] Settings saved and restored
- [ ] No keybind conflicts
- [ ] Default keybinds sensible

**Dependencies:** None

---

## Low Priority Items (Post-MVP)

### 11. Performance Profiling Suite 🟢
**Status:** NOT STARTED  
**Effort:** 12-16 hours  
**Owner:** Performance Engineer  
**Deadline:** Post-MVP

**Deliverable:** `tests2/performance/profiling_suite.lua`

**Test Scenarios:**
- [ ] Large map generation (7×7 grid, 49 map blocks)
- [ ] 50+ units on battlefield (stress test)
- [ ] 1-hour continuous gameplay session (memory leak test)
- [ ] Save/load with large save files
- [ ] Mod loading with 10+ active mods

**Metrics to Track:**
- FPS (target: 60 FPS minimum)
- Memory usage (target: <500 MB)
- Load times (target: <5 seconds)
- Save file size (target: <10 MB)

---

### 12. Accessibility Features 🟢
**Status:** NOT STARTED  
**Effort:** 40-60 hours  
**Owner:** Accessibility Specialist  
**Deadline:** Post-MVP

**Features:**
- [ ] Colorblind mode (deuteranopia, protanopia, tritanopia)
- [ ] High contrast mode
- [ ] Adjustable text size
- [ ] Screen reader support (NVDA/JAWS)
- [ ] Keyboard-only navigation
- [ ] Reduced motion option

---

### 13. Localization System 🟢
**Status:** ENGINE FOLDER EXISTS, NOT IMPLEMENTED  
**Effort:** 80-120 hours  
**Owner:** Localization Engineer  
**Deadline:** Post-MVP

**Files Exist:**
- `engine/localization/` (empty directory)

**Tasks:**
- [ ] Design i18n system architecture
- [ ] Extract all hardcoded strings
- [ ] Create translation key system
- [ ] Implement language selection UI
- [ ] Support for RTL languages (Arabic, Hebrew)
- [ ] Font support for CJK characters

**Target Languages:**
- English (default)
- Polish (developer language)
- Spanish, French, German (high priority)
- Chinese, Japanese, Russian (medium priority)

---

## M4-Specific Items (Campaign & Polish)

### 14. Audio System Implementation 🔴
**Status:** COMPLETELY MISSING  
**Effort:** 60-80 hours  
**Owner:** Audio Engineer  
**Deadline:** March 15, 2026 (M4)

**Critical Gap:** Game is playable but silent.

**Phase 1: Audio Architecture (8-12 hours)**
- [ ] Create `engine/audio/audio_manager.lua`
- [ ] Implement audio mixer (music, SFX, ambient, UI)
- [ ] Create volume controls per channel
- [ ] Implement audio pooling for performance
- [ ] Add audio settings UI

**Phase 2: Asset Sourcing (16-24 hours)**
- [ ] Research royalty-free sound libraries
  - Recommended: OpenGameArt.org, freesound.org, Incompetech (music)
- [ ] Source combat SFX (gunfire, explosions, impacts)
- [ ] Source UI SFX (button clicks, notifications)
- [ ] Source ambient sounds (wind, rain, alien atmosphere)
- [ ] Source music tracks (menu, geoscape, battlescape, victory/defeat)
- [ ] License verification and attribution

**Phase 3: Integration (16-24 hours)**
- [ ] Wire SFX to game events
- [ ] Implement dynamic music system (combat/exploration transitions)
- [ ] Add positional audio for battlescape
- [ ] Implement audio ducking (reduce music during dialog)
- [ ] Test audio mixing and levels

**Phase 4: Polish (8-12 hours)**
- [ ] Balance audio levels
- [ ] Add crossfading between tracks
- [ ] Implement audio visualization (optional)
- [ ] Playtest audio experience
- [ ] Fix audio bugs

**Audio Events to Implement:**
| Event | SFX | Music |
|-------|-----|-------|
| Main menu | Ambient hum | Main theme |
| Geoscape | UI clicks, alerts | Strategic theme |
| Mission deployment | Craft engine | Tension theme |
| Battlescape | Gunfire, footsteps, explosions | Combat theme |
| Victory | Cheers | Victory fanfare |
| Defeat | Alarm | Defeat theme |
| Research complete | Success chime | - |

**Deliverables:**
- [ ] Audio system fully operational
- [ ] All major game events have SFX
- [ ] Dynamic music system working
- [ ] Volume controls functional
- [ ] No audio bugs or glitches

**Dependencies:** None (can start in parallel with M3)

---

### 15. Mission Content Generation 🟡
**Status:** ~20% COMPLETE  
**Effort:** 40-60 hours  
**Owner:** Content Designer  
**Deadline:** March 20, 2026 (M4)

**Goal:** 50+ mission templates for variety

**Current State:**
- `mods/core/missions/` has some examples
- Mission generation system exists in engine
- Need diverse mission types and scenarios

**Mission Types to Create:**

**Tier 1: Core Missions (20 templates, 20-30 hours)**
- [ ] UFO Crash Site (5 variants: small/medium/large scout/fighter/transport)
- [ ] Terror Mission (5 variants: urban/rural/industrial/residential/government)
- [ ] Alien Base Assault (3 variants: small/medium/large)
- [ ] Base Defense (3 variants: early/mid/late game)
- [ ] Supply Raid (4 variants: warehouse/shipyard/airport/train)

**Tier 2: Specialized Missions (15 templates, 12-18 hours)**
- [ ] VIP Extraction (3 variants)
- [ ] Bomb Disposal (2 variants)
- [ ] Retaliation Strike (2 variants)
- [ ] Research Facility (3 variants)
- [ ] Council Mission (5 variants)

**Tier 3: Story Missions (15 templates, 8-12 hours)**
- [ ] Phase 0 introductory missions (3)
- [ ] Phase 1 faction encounter missions (3)
- [ ] Phase 2 first alien contact (3)
- [ ] Phase 3 portal missions (3)
- [ ] Phase 4-5 endgame missions (3)

**For Each Mission Template:**
- [ ] Create TOML definition in `mods/core/missions/`
- [ ] Define map script or map block selection
- [ ] Define enemy composition (units, equipment)
- [ ] Define objectives (primary, secondary, bonus)
- [ ] Define rewards (credits, salvage, research)
- [ ] Define time limits and turn counts
- [ ] Define reinforcement rules
- [ ] Playtest and balance

**Deliverables:**
- [ ] 50+ mission templates in TOML format
- [ ] Diverse mission objectives and scenarios
- [ ] Balanced difficulty progression
- [ ] Integration with campaign system
- [ ] Playtested and polished

**Dependencies:** Requires #3 (campaign system integration)

---

### 16. Balance Tuning & Playtesting 🟡
**Status:** NOT STARTED  
**Effort:** 40-60 hours  
**Owner:** Game Designer + QA Team  
**Deadline:** March 25, 2026 (M4)

**Prerequisites:** 
- Balance spreadsheet (#5)
- Mission content (#15)
- Audio system (#14)

**Playtesting Plan:**

**Phase 1: Alpha Playtest (16-24 hours)**
- [ ] Recruit 5-10 alpha testers
- [ ] Conduct guided playtest sessions (2-4 hours each)
- [ ] Focus areas:
  - Tutorial clarity
  - Early game difficulty
  - Economic balance (can player afford progression?)
  - UI/UX pain points
- [ ] Collect feedback via surveys
- [ ] Document bugs and balance issues

**Phase 2: Balance Adjustments (12-18 hours)**
- [ ] Analyze playtest data
- [ ] Adjust unit stats based on feedback
- [ ] Adjust economic costs/rewards
- [ ] Adjust mission difficulty scaling
- [ ] Update balance spreadsheet

**Phase 3: Beta Playtest (12-18 hours)**
- [ ] Recruit 10-20 beta testers
- [ ] Conduct longer playtest sessions (4-8 hours)
- [ ] Focus on mid/late game balance
- [ ] Test all campaign phases
- [ ] Stress test edge cases

**Metrics to Track:**
- [ ] Mission success rate (target: 60-70% on Normal)
- [ ] Player credit balance over time (positive but not excessive)
- [ ] Unit survival rate (target: 70-80% per mission)
- [ ] Research progression pace (unlock all tech by Phase 4)
- [ ] Time to complete campaign (target: 20-40 hours)

**Deliverables:**
- [ ] Balanced gameplay experience
- [ ] No game-breaking exploits
- [ ] Smooth difficulty curve
- [ ] Economic viability across campaign
- [ ] Updated balance spreadsheet with final values

**Dependencies:** Requires #5, #14, #15

---

## Summary: Actionable Item Tracker

### Critical Path (MVP Blockers)
| # | Item | Effort | Status | Deadline |
|---|------|--------|--------|----------|
| 1 | Test Infrastructure Repair | 2-4h | 🔴 BLOCKING | This week |
| 2 | M3 Basescape UI | 40-60h | 🟡 70% done | Jan 31 |
| 3 | Campaign Integration | 32-48h | 🟡 50% done | Jan 31 |
| 4 | Critical Lore Gaps | 20-25h | 🔴 Blocking | Jan 31 |

### High Priority (Quality Impact)
| # | Item | Effort | Status | Deadline |
|---|------|--------|--------|----------|
| 5 | Balance Spreadsheet | 8-12h | 🟢 Not started | Feb 15 |
| 6 | Content Integration Test | 16-24h | 🟡 Partial | Feb 15 |
| 7 | Coverage Report | 2-3h | 🟢 Tool exists | Feb 1 |

### Medium Priority (Polish)
| # | Item | Effort | Status | Deadline |
|---|------|--------|--------|----------|
| 8 | Notification System | 12-16h | 🟢 Not started | Mar 1 |
| 9 | Tutorial UI | 16-24h | 🟡 Partial | Mar 15 |
| 10 | Keybind Customization | 8-12h | 🟢 Not started | Mar 15 |

### M4 Critical (Campaign & Polish)
| # | Item | Effort | Status | Deadline |
|---|------|--------|--------|----------|
| 14 | Audio System | 60-80h | 🔴 Missing | Mar 15 |
| 15 | Mission Content | 40-60h | 🟡 20% done | Mar 20 |
| 16 | Balance & Playtest | 40-60h | 🟢 Not started | Mar 25 |

### Post-MVP (Future)
| # | Item | Effort | Status | Deadline |
|---|------|--------|--------|----------|
| 11 | Performance Profiling | 12-16h | 🟢 Not started | Post-MVP |
| 12 | Accessibility | 40-60h | 🟢 Not started | Post-MVP |
| 13 | Localization | 80-120h | 🟢 Not started | Post-MVP |

---

**Total Critical Path Effort:** 94-137 hours  
**Total High Priority Effort:** 26-39 hours  
**Total Medium Priority Effort:** 36-52 hours  
**Total M4 Critical Effort:** 140-200 hours  
**Total Post-MVP Effort:** 132-196 hours

**Grand Total Remaining Work:** 428-624 hours

**Team Size Estimate:**
- 2-3 developers working full-time: **10-15 weeks**
- MVP Target (March 31, 2026): **18 weeks remaining** ✅ ACHIEVABLE

---

**Next Review:** January 15, 2026 (M3 mid-point check)  
**Owner:** Project Manager  
**Distribution:** All team members

