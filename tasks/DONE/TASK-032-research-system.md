# Task: Research System - Global Technology Tree & Research Projects

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a comprehensive research system similar to XCOM with research entries (available technologies), research projects (active research), tech tree with dependencies, global research capacity across all bases, daily progression, and special research for items/prisoners.

---

## Purpose

The research system is a core pillar of the strategic layer, enabling players to unlock new capabilities, understand alien technology, interrogate prisoners, and progress through the technology tree. Research is global (shared across all bases) and progresses daily based on allocated scientists.

---

## Requirements

### Functional Requirements
- [ ] Research Entry: Definitions for all researchable technologies
- [ ] Research Project: Active research with progress tracking
- [ ] Tech Tree: DAG (directed acyclic graph) with prerequisites and unlocks
- [ ] Global Research: All bases contribute scientists to shared research pool
- [ ] Daily Progression: Research advances each day based on allocated scientists
- [ ] Random Baseline: Each project has 50% variance from baseline (75%-125%)
- [ ] Item Research: Analyze items/artifacts ONCE, then complete
- [ ] Prisoner Interrogation: Can interrogate prisoners multiple times until "knows everything"
- [ ] Research Dependencies: depends_on, gives_free, blocks, unlocks
- [ ] Service Integration: Research depends on facility services (laboratories)
- [ ] One-time vs Repeatable: Technologies vs interrogations

### Technical Requirements
- [ ] Data-driven research definitions (TOML files)
- [ ] Research state persistence (save/load)
- [ ] Event system for research completion
- [ ] Integration with base facility system (lab capacity)
- [ ] Integration with calendar system (daily progression)
- [ ] Tech tree validation (no circular dependencies)

### Acceptance Criteria
- [ ] Can start research project if prerequisites met
- [ ] Research progresses daily by (scientists assigned / man-days needed)
- [ ] Research completes when progress >= 1.0 (man-days consumed)
- [ ] Tech tree visualizes dependencies correctly
- [ ] Item research can only be done once per item type
- [ ] Prisoner interrogation can be repeated until success
- [ ] Global research works across multiple bases
- [ ] Research unlocks are applied (tech, items, facilities, manufacturing)

---

## Plan

### Step 1: Research Entry Data Structure (8 hours)
**Description:** Define research entry schema and data loader  
**Files to create:**
- `engine/data/research_entries.lua` - Research entry data
- `engine/geoscape/logic/research_entry.lua` - ResearchEntry class
- `engine/mods/core/research/technologies.toml` - Tech definitions
- `engine/mods/core/research/items.toml` - Item research definitions
- `engine/mods/core/research/prisoners.toml` - Prisoner interrogation

**ResearchEntry Schema:**
```lua
ResearchEntry = {
    id = "laser_weapons",
    name = "Laser Weapons",
    description = "Harness alien energy weapons for human use",
    
    -- Cost
    baselineManDays = 150,  -- Base cost, actual is 75%-125% (random per game)
    
    -- Type
    type = "technology",  -- technology | item_analysis | prisoner_interrogation
    repeatable = false,   -- Can research multiple times?
    
    -- Prerequisites
    requiredTech = {"alien_alloys"},  -- Tech IDs needed
    requiredItems = {},               -- Items needed to start (consumed)
    requiredPrisoners = {},           -- Prisoner types needed
    requiredServices = {"laboratory"}, -- Facility services needed
    
    -- Dependencies (tech tree)
    dependsOn = {"alien_alloys"},     -- Must complete these first
    givesFree = {"laser_pistol"},     -- Auto-unlocks these
    blocks = {},                      -- Prevents researching these
    
    -- Unlocks
    unlocksResearch = {"plasma_weapons"},  -- New research options
    unlocksManufacturing = {"laser_rifle"}, -- Can manufacture these
    unlocksFacilities = {},                -- Can build these facilities
    unlocksItems = {"laser_rifle"},        -- Items become available
    
    -- Special (for interrogations)
    interrogationChance = 0.3,  -- 30% chance to complete per attempt
    maxInterrogations = 5,      -- Max attempts before auto-complete
    
    -- Metadata
    category = "weapons",  -- weapons, armor, crafts, aliens, facilities, strategic
    icon = "laser_weapons.png",
    loreText = "Long description for research report...",
}
```

**Estimated time:** 8 hours

---

### Step 2: Research Project System (10 hours)
**Description:** Active research tracking with progress, scientist allocation, completion  
**Files to create:**
- `engine/geoscape/logic/research_project.lua` - ResearchProject class
- `engine/geoscape/systems/research_manager.lua` - Global research management

**ResearchProject:**
```lua
ResearchProject = {
    id = "proj_001",
    entryId = "laser_weapons",
    
    -- Progress
    manDaysRequired = 180,  -- Random 75%-125% of baseline (150)
    manDaysCompleted = 45,  -- Current progress
    progress = 0.25,        -- manDaysCompleted / manDaysRequired
    
    -- Scientists
    scientistsAssigned = 12,  -- Current allocation
    
    -- Status
    status = "active",  -- active | paused | completed | cancelled
    
    -- Dates
    startDate = {year = 1, month = 3, day = 15},
    estimatedCompletion = {year = 1, month = 5, day = 10},
    completedDate = nil,
    
    -- Special (for interrogations)
    attempts = 0,  -- Number of interrogation attempts
    succeeded = false,
}
```

**ResearchManager:**
```lua
ResearchManager = {
    entries = {},          -- All available research entries
    projects = {},         -- Active research projects
    completedTech = {},    -- Set of completed tech IDs
    globalScientists = 0,  -- Total scientists across all bases
}

ResearchManager:loadEntries()  -- Load from TOML
ResearchManager:canResearch(entryId)  -- Check prerequisites
ResearchManager:startResearch(entryId, scientists)  -- Start new project
ResearchManager:pauseResearch(projectId)
ResearchManager:resumeResearch(projectId)
ResearchManager:cancelResearch(projectId)
ResearchManager:assignScientists(projectId, count)
ResearchManager:dailyProgress()  -- Advance all projects
ResearchManager:completeResearch(projectId)  -- Apply unlocks
ResearchManager:getAvailableResearch()  -- List researchable entries
ResearchManager:getCompletedResearch()  -- List completed tech
ResearchManager:getTechTree()  -- Get dependency graph
```

**Estimated time:** 10 hours

---

### Step 3: Tech Tree & Dependencies (8 hours)
**Description:** DAG validation, dependency resolution, tech tree traversal  
**Files to create:**
- `engine/geoscape/logic/tech_tree.lua` - Tech tree graph
- `engine/geoscape/utils/tech_tree_validator.lua` - Validate DAG

**TechTree:**
```lua
TechTree = {
    nodes = {},  -- entryId → ResearchEntry
    edges = {},  -- entryId → {dependencies}
}

TechTree:addEntry(entry)  -- Add research entry to tree
TechTree:validate()  -- Check for circular dependencies
TechTree:getPrerequisites(entryId)  -- Get all required tech
TechTree:getDependents(entryId)  -- Get tech that depends on this
TechTree:isResearchable(entryId, completedTech)  -- Check if can research
TechTree:getUnlocks(entryId)  -- Get what this tech unlocks
TechTree:topologicalSort()  -- Sort tech in dependency order
TechTree:getCategories()  -- Get all research categories
TechTree:getCategoryEntries(category)  -- Get entries in category
```

**Validation:**
- No circular dependencies (A → B → A)
- All prerequisites exist
- All unlocks reference valid entries
- Tech tree is a valid DAG

**Estimated time:** 8 hours

---

### Step 4: Daily Progression System (6 hours)
**Description:** Integrate with calendar for daily research progress  
**Files to modify:**
- `engine/geoscape/systems/calendar.lua` - Add research progression hook
**Files to create:**
- `engine/geoscape/systems/research_progression.lua` - Daily updates

**Daily Progression Logic:**
```lua
ResearchProgression:advanceDay()
    -- For each active project:
    for project in activeProjects do
        -- Calculate daily progress
        local dailyProgress = project.scientistsAssigned
        project.manDaysCompleted += dailyProgress
        project.progress = project.manDaysCompleted / project.manDaysRequired
        
        -- Check completion
        if project.progress >= 1.0 then
            ResearchManager:completeResearch(project.id)
        end
        
        -- Special: Interrogations
        if project.entry.type == "prisoner_interrogation" then
            local roll = math.random()
            if roll <= project.entry.interrogationChance then
                project.succeeded = true
                ResearchManager:completeResearch(project.id)
            else
                project.attempts += 1
                if project.attempts >= project.entry.maxInterrogations then
                    project.succeeded = true  -- Auto-complete after max attempts
                    ResearchManager:completeResearch(project.id)
                end
            end
        end
    end
```

**Estimated time:** 6 hours

---

### Step 5: Item & Prisoner Research (8 hours)
**Description:** Special handling for item analysis and prisoner interrogation  
**Files to create:**
- `engine/geoscape/logic/item_research.lua` - Item analysis
- `engine/geoscape/logic/prisoner_research.lua` - Interrogation

**Item Research:**
- Can only research each item type ONCE
- Requires item in inventory
- Item is NOT consumed (unless specified)
- Completes normally via man-days
- Cannot re-research same item type

**Prisoner Interrogation:**
- Can interrogate same prisoner type multiple times
- Requires live prisoner in containment
- Each interrogation has chance to succeed
- If fails, can try again next day
- After max attempts, auto-completes
- Message: "We've learned everything from this subject"

**Estimated time:** 8 hours

---

### Step 6: Facility Integration (6 hours)
**Description:** Link research to laboratory facilities and capacity  
**Dependencies:** TASK-029 (Basescape Facility System)
**Files to modify:**
- `engine/basescape/logic/facility.lua` - Add research_capacity
- `engine/basescape/systems/capacity_manager.lua` - Track lab capacity

**Laboratory Capacity:**
```lua
-- Facility provides research_capacity
Facility = {
    typeId = "laboratory",
    capacities = {
        research_capacity = 10,  -- Can support 10 scientists
    }
}

-- ResearchManager uses global capacity
ResearchManager:getGlobalCapacity()
    local total = 0
    for base in allBases do
        total += base:getCapacity("research_capacity")
    end
    return total

ResearchManager:getAvailableCapacity()
    local total = self:getGlobalCapacity()
    local used = 0
    for project in activeProjects do
        used += project.scientistsAssigned
    end
    return total - used
```

**Estimated time:** 6 hours

---

### Step 7: Research Completion & Unlocks (8 hours)
**Description:** Apply unlocks when research completes  
**Files to create:**
- `engine/geoscape/systems/research_unlocks.lua` - Handle unlocks

**Unlock Logic:**
```lua
ResearchUnlocks:applyUnlocks(project)
    local entry = project.entry
    
    -- Mark as completed
    ResearchManager.completedTech[entry.id] = true
    
    -- Unlock research
    for _, techId in ipairs(entry.unlocksResearch) do
        -- Tech becomes available
    end
    
    -- Unlock manufacturing
    for _, itemId in ipairs(entry.unlocksManufacturing) do
        ManufacturingManager:unlockEntry(itemId)
    end
    
    -- Unlock facilities
    for _, facilityId in ipairs(entry.unlocksFacilities) do
        FacilityManager:unlockType(facilityId)
    end
    
    -- Unlock items (for marketplace/loot)
    for _, itemId in ipairs(entry.unlocksItems) do
        ItemManager:unlockItem(itemId)
    end
    
    -- Free research (auto-complete)
    for _, techId in ipairs(entry.givesFree) do
        ResearchManager:completeResearch(techId)
    end
    
    -- Emit event
    EventManager:emit("research_completed", {
        entryId = entry.id,
        projectId = project.id,
        unlocks = entry.unlocksResearch,
    })
```

**Estimated time:** 8 hours

---

### Step 8: UI Implementation (16 hours)
**Description:** Research screen with tech tree, project management, scientist allocation  
**Files to create:**
- `engine/geoscape/ui/research_screen.lua` - Main research UI
- `engine/geoscape/ui/tech_tree_view.lua` - Interactive tech tree
- `engine/geoscape/ui/research_project_panel.lua` - Active projects
- `engine/geoscape/ui/research_entry_panel.lua` - Research details

**Research Screen Layout (960×720, 24px grid):**
```
┌─────────────────────────────────────────┐
│ Research Laboratory        Scientists: 45│ (Top bar)
├──────────────┬──────────────────────────┤
│              │  Available Research      │
│  Tech Tree   │  ┌────────────────────┐  │
│  View        │  │ Laser Weapons      │  │
│  (Interactive│  │ Cost: 150 man-days │  │
│   Zoom/Pan)  │  │ Unlocks: ...       │  │
│              │  └────────────────────┘  │
│              │  ┌────────────────────┐  │
│              │  │ Alien Alloys       │  │
│              │  └────────────────────┘  │
├──────────────┴──────────────────────────┤
│ Active Projects                         │
│ ┌────────────────────────────────────┐ │
│ │ Laser Weapons: [████░░░░] 45%      │ │
│ │ Scientists: 12  Est: 15 days       │ │
│ └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Widgets (all grid-aligned 24px):**
- ResearchScreen (full screen)
- TechTreeView (widget from `widgets/advanced/researchtree.lua`)
- ResearchEntryList (scrollable list)
- ResearchEntryCard (4×3 grid cells, 96×72 pixels)
- ResearchProjectPanel (progress bars)
- ScientistAllocationSlider (assign scientists)

**Estimated time:** 16 hours

---

### Step 9: Data Files (10 hours)
**Description:** Create comprehensive research data for core mod  
**Files to create:**
- `engine/mods/core/research/alien_tech.toml` - Alien technologies
- `engine/mods/core/research/weapons.toml` - Weapon research
- `engine/mods/core/research/armor.toml` - Armor research
- `engine/mods/core/research/crafts.toml` - Craft research
- `engine/mods/core/research/facilities.toml` - Facility research
- `engine/mods/core/research/items.toml` - Item analysis
- `engine/mods/core/research/prisoners.toml` - Interrogations

**Example: Weapon Research Tree**
```toml
[laser_weapons]
id = "laser_weapons"
name = "Laser Weapons"
description = "Harness alien energy weapons"
baseline_man_days = 150
type = "technology"
repeatable = false
required_tech = ["alien_alloys"]
required_services = ["laboratory"]
unlocks_research = ["plasma_weapons"]
unlocks_manufacturing = ["laser_rifle", "laser_pistol"]
unlocks_items = ["laser_rifle", "laser_pistol"]
category = "weapons"
icon = "laser_weapons.png"

[plasma_weapons]
id = "plasma_weapons"
name = "Plasma Weapons"
baseline_man_days = 300
depends_on = ["laser_weapons", "alien_plasma"]
unlocks_manufacturing = ["plasma_rifle", "heavy_plasma"]
category = "weapons"
```

**Research Categories:**
1. **Alien Technology** (10 entries) - UFO power, alien materials
2. **Weapons** (15 entries) - Laser, plasma, fusion weapons
3. **Armor** (10 entries) - Body armor, power suits
4. **Crafts** (8 entries) - Interceptors, transports
5. **Facilities** (6 entries) - Advanced labs, psi labs
6. **Strategic** (8 entries) - Hyperwave decoder, mind shield
7. **Items** (20 entries) - Alien artifacts, equipment
8. **Prisoners** (12 entries) - Alien interrogations

**Estimated time:** 10 hours

---

### Step 10: Testing & Validation (10 hours)
**Description:** Unit tests, integration tests, manual testing  
**Files to create:**
- `engine/geoscape/tests/test_research_entry.lua`
- `engine/geoscape/tests/test_research_project.lua`
- `engine/geoscape/tests/test_tech_tree.lua`
- `engine/geoscape/tests/test_research_manager.lua`

**Test Cases:**
1. **ResearchEntry:**
   - Load from TOML correctly
   - Validate required fields
   - Calculate random baseline (75%-125%)
   
2. **ResearchProject:**
   - Create project with scientists
   - Progress calculation correct
   - Completion detection works
   
3. **TechTree:**
   - No circular dependencies
   - Prerequisites resolved correctly
   - Available research list accurate
   - Unlocks applied correctly
   
4. **Daily Progression:**
   - Projects advance by scientist count
   - Completion triggers at 100%
   - Interrogations have chance to succeed
   - Item research only once
   
5. **Integration:**
   - Lab capacity limits scientists
   - Research unlocks manufacturing
   - Tech tree visualizes correctly
   - Save/load preserves state

**Manual Testing:**
```bash
lovec "engine"
```
1. Start new game
2. Open research screen
3. Verify tech tree displays
4. Start laser weapons research
5. Assign 10 scientists
6. Advance calendar 15 days
7. Verify progress bar updates
8. Complete research
9. Verify unlocks applied
10. Check plasma weapons now available

**Estimated time:** 10 hours

---

### Step 11: Documentation (6 hours)
**Description:** Update API docs, FAQ, wiki  
**Files to update:**
- `wiki/API.md` - ResearchManager, TechTree APIs
- `wiki/FAQ.md` - How to research technologies
- `wiki/DEVELOPMENT.md` - Research system architecture
- `wiki/wiki/research.md` - Complete research guide

**Documentation Sections:**
- Research entry schema reference
- Tech tree structure and dependencies
- Daily progression mechanics
- Item vs prisoner research differences
- Global research capacity calculation
- Unlock system explanation
- Modding guide for adding research

**Estimated time:** 6 hours

---

## Implementation Details

### Architecture

**Data Layer:**
- TOML files define research entries
- Random baseline per entry (one-time, game start)
- Tech tree built from dependencies

**Logic Layer:**
- ResearchManager: Global research coordination
- ResearchProject: Active research tracking
- TechTree: Dependency graph and validation
- ResearchProgression: Daily updates

**System Layer:**
- Calendar integration for daily progression
- Event system for research completion
- Facility integration for lab capacity

**UI Layer:**
- Tech tree visualization (zoom, pan, click)
- Research entry browser (filter by category)
- Project management (start, pause, assign scientists)
- Progress tracking (bars, estimates)

### Key Components

1. **ResearchEntry:** Research definition loaded from TOML
2. **ResearchProject:** Active research with progress tracking
3. **TechTree:** DAG of research dependencies
4. **ResearchManager:** Global research state and operations
5. **ResearchProgression:** Daily advancement system
6. **TechTreeView:** Interactive tech tree UI widget

### Dependencies

- **TASK-025 Phase 2:** Calendar system for daily progression
- **TASK-029:** Basescape facility system for lab capacity
- **Widget System:** TechTreeView widget from `widgets/advanced/`
- **Event System:** Research completion events
- **Mod System:** Load research entries from TOML

---

## Testing Strategy

### Unit Tests

**ResearchEntry Tests:**
```lua
function test_load_from_toml()
    local entry = ResearchEntry:fromTOML(data)
    assert(entry.id == "laser_weapons")
    assert(entry.baselineManDays == 150)
end

function test_random_baseline()
    local entry = ResearchEntry:new("test", 100)
    local actual = entry:getActualManDays()
    assert(actual >= 75 and actual <= 125)
end
```

**TechTree Tests:**
```lua
function test_no_circular_dependencies()
    local tree = TechTree:new()
    tree:addEntry(entryA)
    tree:addEntry(entryB)
    assert(tree:validate() == true)
end

function test_prerequisites()
    local tree = TechTree:new()
    local available = tree:getAvailableResearch({})
    -- Should only return entries with no prerequisites
end
```

### Integration Tests

**Research Flow:**
```lua
function test_complete_research_flow()
    -- Start research
    local project = ResearchManager:startResearch("laser_weapons", 10)
    
    -- Advance time
    for i = 1, 15 do
        ResearchProgression:advanceDay()
    end
    
    -- Check completion
    assert(project.status == "completed")
    assert(ResearchManager.completedTech["laser_weapons"] == true)
    
    -- Check unlocks
    local available = ResearchManager:getAvailableResearch()
    assert(contains(available, "plasma_weapons"))
end
```

### Manual Testing Steps

1. **Run game:** `lovec "engine"`
2. **Create base** with laboratory
3. **Hire scientists** (10)
4. **Open research screen**
5. **View tech tree** - verify nodes and connections
6. **Start research** on available entry
7. **Assign scientists** (10)
8. **Advance calendar** 1 day
9. **Check progress** - should be 10/150 (6.7%)
10. **Advance calendar** 14 more days
11. **Check completion** - should complete at day 15
12. **Verify unlocks** - new research available
13. **Test item research** - can only do once
14. **Test interrogation** - can repeat multiple times

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print()` statements for debugging output:
  ```lua
  print("[ResearchManager] Starting research: " .. entryId)
  print("[TechTree] Validating dependencies...")
  print("[ResearchProgression] Daily progress: " .. dailyProgress)
  ```
- Check console window for errors and debug messages
- Use F9 for grid overlay in UI development
- Use `love.graphics.print()` for on-screen debug info

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add ResearchManager, TechTree, ResearchEntry APIs
- [x] `wiki/FAQ.md` - Add "How do I research new technologies?" section
- [x] `wiki/DEVELOPMENT.md` - Add research system architecture
- [x] `wiki/wiki/research.md` - Update with complete implementation details
- [ ] Code comments - Add inline documentation for all public APIs

**API Documentation Required:**
```lua
-- ResearchManager API
ResearchManager:canResearch(entryId) -> boolean, reason
ResearchManager:startResearch(entryId, scientists) -> ResearchProject | nil, error
ResearchManager:pauseResearch(projectId)
ResearchManager:resumeResearch(projectId)
ResearchManager:cancelResearch(projectId)
ResearchManager:assignScientists(projectId, count)
ResearchManager:dailyProgress()
ResearchManager:getAvailableResearch() -> table
ResearchManager:getCompletedResearch() -> table
ResearchManager:getTechTree() -> TechTree

-- TechTree API
TechTree:addEntry(entry)
TechTree:validate() -> boolean, errors
TechTree:getPrerequisites(entryId) -> table
TechTree:getDependents(entryId) -> table
TechTree:isResearchable(entryId, completedTech) -> boolean
TechTree:topologicalSort() -> table
```

---

## Notes

### XCOM-Style Research
- **Global Research:** All bases share scientists and research progress
- **Random Baseline:** Each project's cost varies 75%-125% of baseline per game
- **Man-Day System:** Cost in "man-days" (1 scientist = 1 man-day/day)
- **Item Research:** Can only analyze each item type once
- **Interrogations:** Repeatable with chance to succeed
- **Tech Tree:** Directed acyclic graph with multiple paths
- **Unlocks:** Research opens manufacturing, facilities, more research

### Design Decisions
- Research is **global** (not per-base) for strategic simplicity
- Baseline variance adds replayability (different costs each game)
- Item research is **one-time** to prevent grinding
- Interrogations are **repeatable** to add tension and strategy
- Tech tree uses **depends_on** (hard prerequisites) and **gives_free** (auto-unlocks)

### Performance Considerations
- Cache tech tree validation results
- Use sets for completed tech (O(1) lookup)
- Pre-compute available research list
- Update UI only on changes (not every frame)

---

## Blockers

- **TASK-025 Phase 2:** Calendar system must be complete for daily progression
- **TASK-029:** Basescape facility system needed for lab capacity integration
- **Widget System:** TechTreeView widget must be functional

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Tech tree has no circular dependencies
- [ ] Random baseline applied correctly per game
- [ ] Item research only once per type
- [ ] Interrogations repeatable until success
- [ ] Global research capacity calculated correctly
- [ ] Daily progression integrated with calendar
- [ ] Research unlocks applied correctly
- [ ] UI grid-aligned (24px grid)

---

## Post-Completion

### What Worked Well
- (To be filled after implementation)

### What Could Be Improved
- (To be filled after implementation)

### Lessons Learned
- (To be filled after implementation)

---

## Time Estimate

**Total: 96 hours (12 days)**

- Step 1: Research Entry Data Structure - 8h
- Step 2: Research Project System - 10h
- Step 3: Tech Tree & Dependencies - 8h
- Step 4: Daily Progression System - 6h
- Step 5: Item & Prisoner Research - 8h
- Step 6: Facility Integration - 6h
- Step 7: Research Completion & Unlocks - 8h
- Step 8: UI Implementation - 16h
- Step 9: Data Files - 10h
- Step 10: Testing & Validation - 10h
- Step 11: Documentation - 6h
