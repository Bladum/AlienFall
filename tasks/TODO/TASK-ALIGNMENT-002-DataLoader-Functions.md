# Task: Implement Missing DataLoader Functions

**Status:** TODO  
**Priority:** CRITICAL  
**Created:** October 16, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent / Development Team

---

## Overview

Extend `engine/core/data_loader.lua` to load all content types from mod TOML files. Currently only loads terrain, weapons, armors, skills, and unit classes. Need to add loaders for facilities, missions, campaigns, factions, technology, narrative events, geoscape data, and economy data.

---

## Purpose

**Current Problem:**
- `DataLoader` only has 5 loader functions
- Missing loaders for 8+ content types
- Cannot load comprehensive game content from mods
- Content exists in TOML files (from TASK-ALIGNMENT-001) but no way to access it

**Solution:**
Add comprehensive loader functions following existing pattern, integrated with ModManager for path resolution.

---

## Requirements

### Functional Requirements
- [ ] Add loadFacilities() function
- [ ] Add loadMissions() function
- [ ] Add loadCampaigns() function
- [ ] Add loadFactions() function
- [ ] Add loadTechTree() function
- [ ] Add loadNarrativeEvents() function
- [ ] Add loadGeoscape() function (countries, regions, funding)
- [ ] Add loadEconomy() function
- [ ] Update load() to call all new loaders
- [ ] Provide utility functions for each content type (get(), getAll(), etc.)

### Technical Requirements
- [ ] Follow existing DataLoader pattern
- [ ] Use ModManager.getContentPath() for file resolution
- [ ] Return tables with utility functions
- [ ] Handle missing files gracefully
- [ ] Print debug messages during loading
- [ ] Compatible with TOML.load()

### Acceptance Criteria
- [ ] All new loader functions implemented
- [ ] DataLoader.load() successfully loads all content types
- [ ] Content accessible via DataLoader.facilities, DataLoader.missions, etc.
- [ ] Utility functions work correctly
- [ ] No errors when loading valid TOML files
- [ ] Graceful handling of missing/invalid files

---

## Plan

### Step 1: Add loadFacilities() (2 hours)
**Description:** Load base facility definitions  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.loadFacilities()
    local path = ModManager.getContentPath("rules", "facilities/base_facilities.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get facilities path")
        return {}
    end
    
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load facilities")
        return {}
    end
    
    local facilities = { list = data.facility or {} }
    
    function facilities.get(id)
        for _, facility in ipairs(facilities.list) do
            if facility.id == id then return facility end
        end
        return nil
    end
    
    function facilities.getAll()
        return facilities.list
    end
    
    return facilities
end
```

**Estimated time:** 2 hours

### Step 2: Add loadMissions() (2 hours)
**Description:** Load mission type definitions  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.loadMissions()
    local path = ModManager.getContentPath("rules", "missions/mission_types.toml")
    -- Follow same pattern as loadFacilities()
    
    local missions = { types = data.mission or {} }
    
    function missions.get(id) ... end
    function missions.getByType(type) ... end
    function missions.getAll() ... end
    
    return missions
end
```

**Estimated time:** 2 hours

### Step 3: Add loadCampaigns() (3 hours)
**Description:** Load campaign phase definitions  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.loadCampaigns()
    -- Load all phase files
    local phases = {}
    for i = 0, 3 do
        local path = ModManager.getContentPath("campaigns", 
            string.format("phase%d_*.toml", i))
        -- Load and merge
    end
    
    -- Load timeline
    local timelinePath = ModManager.getContentPath("campaigns", "campaign_timeline.toml")
    
    local campaigns = {
        phases = phases,
        timeline = timeline
    }
    
    function campaigns.getPhase(id) ... end
    function campaigns.getCurrentPhase(date) ... end
    
    return campaigns
end
```

**Estimated time:** 3 hours

### Step 4: Add loadFactions() (3 hours)
**Description:** Load faction definitions  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.loadFactions()
    local factionsPath = ModManager.getContentPath("factions")
    local factions = {}
    
    -- Load all .toml files in factions directory
    local items = love.filesystem.getDirectoryItems(factionsPath)
    for _, filename in ipairs(items) do
        if filename:match("%.toml$") then
            local path = factionsPath .. "/" .. filename
            local data = TOML.load(path)
            if data and data.faction then
                table.insert(factions, data.faction)
            end
        end
    end
    
    local factionsTable = { list = factions }
    
    function factionsTable.get(id) ... end
    function factionsTable.getByType(type) ... end
    function factionsTable.getAll() ... end
    
    return factionsTable
end
```

**Estimated time:** 3 hours

### Step 5: Add loadTechTree() (3 hours)
**Description:** Load research tree and technology definitions  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.loadTechTree()
    local treePath = ModManager.getContentPath("technology", "research_tree.toml")
    local tree = TOML.load(treePath)
    
    -- Load phase-specific tech
    local phaseTech = {}
    for i = 0, 3 do
        local path = ModManager.getContentPath("technology", 
            string.format("phase%d_tech.toml", i))
        phaseTech[i] = TOML.load(path)
    end
    
    local techTree = {
        tree = tree,
        phaseTech = phaseTech
    }
    
    function techTree.getTech(id) ... end
    function techTree.getPrerequisites(id) ... end
    function techTree.getUnlocks(id) ... end
    
    return techTree
end
```

**Estimated time:** 3 hours

### Step 6: Add loadNarrativeEvents() (2 hours)
**Description:** Load narrative story events  
**Files to modify:**
- `engine/core/data_loader.lua`

**Estimated time:** 2 hours

### Step 7: Add loadGeoscape() (3 hours)
**Description:** Load countries, regions, funding data  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.loadGeoscape()
    local countriesPath = ModManager.getContentPath("geoscape", "countries.toml")
    local regionsPath = ModManager.getContentPath("geoscape", "regions.toml")
    local fundingPath = ModManager.getContentPath("geoscape", "funding.toml")
    
    local geoscape = {
        countries = TOML.load(countriesPath).country or {},
        regions = TOML.load(regionsPath).region or {},
        funding = TOML.load(fundingPath).funding or {}
    }
    
    function geoscape.getCountry(id) ... end
    function geoscape.getRegion(id) ... end
    function geoscape.getCountriesInRegion(regionId) ... end
    
    return geoscape
end
```

**Estimated time:** 3 hours

### Step 8: Add loadEconomy() (2 hours)
**Description:** Load economy/marketplace data  
**Files to modify:**
- `engine/core/data_loader.lua`

**Estimated time:** 2 hours

### Step 9: Update load() Function (1 hour)
**Description:** Call all new loaders  
**Files to modify:**
- `engine/core/data_loader.lua`

**Implementation:**
```lua
function DataLoader.load()
    -- Existing loaders
    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    DataLoader.armours = DataLoader.loadArmours()
    DataLoader.skills = DataLoader.loadSkills()
    DataLoader.unitClasses = DataLoader.loadUnitClasses()
    
    -- NEW loaders
    DataLoader.facilities = DataLoader.loadFacilities()
    DataLoader.missions = DataLoader.loadMissions()
    DataLoader.campaigns = DataLoader.loadCampaigns()
    DataLoader.factions = DataLoader.loadFactions()
    DataLoader.techTree = DataLoader.loadTechTree()
    DataLoader.narrativeEvents = DataLoader.loadNarrativeEvents()
    DataLoader.geoscape = DataLoader.loadGeoscape()
    DataLoader.economy = DataLoader.loadEconomy()
    
    print("[DataLoader] Loaded all game content from mods")
    return true
end
```

**Estimated time:** 1 hour

### Step 10: Testing and Documentation (3 hours)
**Description:** Test all loaders, update documentation  
**Tasks:**
- Test each loader function
- Verify utility functions work
- Update API documentation
- Add usage examples

**Files to update:**
- `docs/API.md` - Add DataLoader API reference
- `engine/core/data_loader.lua` - Add docstrings

**Estimated time:** 3 hours

---

## Implementation Details

### File Structure
```lua
-- engine/core/data_loader.lua (427 lines currently)
-- Will expand to ~1000+ lines

DataLoader.load()                       -- UPDATE: Call new loaders
DataLoader.loadTerrainTypes()           -- EXISTING
DataLoader.loadWeapons()                -- EXISTING
DataLoader.loadArmours()                -- EXISTING
DataLoader.loadSkills()                 -- EXISTING
DataLoader.loadUnitClasses()            -- EXISTING
DataLoader.loadFacilities()             -- NEW
DataLoader.loadMissions()               -- NEW
DataLoader.loadCampaigns()              -- NEW
DataLoader.loadFactions()               -- NEW
DataLoader.loadTechTree()               -- NEW
DataLoader.loadNarrativeEvents()        -- NEW
DataLoader.loadGeoscape()               -- NEW
DataLoader.loadEconomy()                -- NEW
```

### Pattern to Follow
All loaders follow this pattern:
1. Get content path from ModManager
2. Load TOML file(s)
3. Create table with data
4. Add utility functions (get, getAll, getBy*, etc.)
5. Return table
6. Print success/error messages

### Dependencies
- `engine/mods/mod_manager.lua` - Path resolution
- `utils/toml.lua` - TOML parsing
- `mods/core/*` - Content files (TASK-ALIGNMENT-001)
- `love.filesystem` - Directory scanning

---

## Testing Strategy

### Unit Tests
Create `tests/unit/test_data_loader_extended.lua`:
```lua
function TestDataLoader.testLoadFacilities()
    DataLoader.load()
    assert(DataLoader.facilities ~= nil)
    assert(#DataLoader.facilities.getAll() > 0)
    local lab = DataLoader.facilities.get("research_lab")
    assert(lab ~= nil)
end

function TestDataLoader.testLoadCampaigns()
    DataLoader.load()
    assert(DataLoader.campaigns ~= nil)
    local phase0 = DataLoader.campaigns.getPhase("phase0")
    assert(phase0 ~= nil)
end

-- Similar tests for all loaders
```

### Integration Tests
Test in Love2D console:
```lua
DataLoader.load()

-- Test facilities
print("Facilities loaded:", #DataLoader.facilities.getAll())
local lab = DataLoader.facilities.get("research_lab")
print("Research lab:", lab and lab.name or "NOT FOUND")

-- Test campaigns
print("Campaigns loaded:", DataLoader.campaigns)
local phase0 = DataLoader.campaigns.getPhase("phase0")
print("Phase 0:", phase0 and phase0.name or "NOT FOUND")

-- Test factions
print("Factions loaded:", #DataLoader.factions.getAll())
```

### Expected Results
- All loaders return non-nil tables
- Utility functions work correctly
- Content accessible via DataLoader.* properties
- No errors printed to console
- All TOML files successfully parsed

---

## How to Run/Debug

1. **Run game with console:**
   ```bash
   lovec "engine"
   ```

2. **Test in Lua console:**
   ```lua
   local DataLoader = require("core.data_loader")
   DataLoader.load()
   
   -- Check what's loaded
   print("Terrain types:", #DataLoader.terrainTypes.getAllIds())
   print("Weapons:", DataLoader.weapons)
   print("Facilities:", DataLoader.facilities)
   print("Campaigns:", DataLoader.campaigns)
   ```

3. **Check console output:**
   - Look for "[DataLoader]" messages
   - Verify no ERROR messages
   - Confirm all content types loaded

4. **Debug individual loader:**
   ```lua
   local facilities = DataLoader.loadFacilities()
   print("Facilities:", facilities)
   for _, f in ipairs(facilities.getAll()) do
       print("  -", f.id, f.name)
   end
   ```

---

## Documentation Updates

### Files to Update
- `docs/API.md` - Add DataLoader API reference section
- `engine/core/data_loader.lua` - Update module docstring
- `tasks/tasks.md` - Mark task complete

### API Documentation to Add
```markdown
## DataLoader API

### DataLoader.facilities
- `facilities.get(id)` - Get facility by ID
- `facilities.getAll()` - Get all facilities
- `facilities.getByType(type)` - Get facilities by type

### DataLoader.campaigns
- `campaigns.getPhase(id)` - Get campaign phase
- `campaigns.getCurrentPhase(date)` - Get phase for date
- `campaigns.getAll()` - Get all phases

(etc. for all loaders)
```

---

## Review Checklist

- [ ] All 8 new loader functions implemented
- [ ] DataLoader.load() updated to call new loaders
- [ ] All loaders follow existing pattern
- [ ] Utility functions implemented for each content type
- [ ] Error handling for missing files
- [ ] Debug messages printed during load
- [ ] TOML files successfully parsed
- [ ] Content accessible via DataLoader properties
- [ ] Tests created and passing
- [ ] Documentation updated
- [ ] No console errors
- [ ] Code follows project standards

---

## Notes

**Dependencies:**
- TASK-ALIGNMENT-001 must be complete (TOML files must exist)
- ModManager must support new content paths

**Integration:**
- Once complete, game systems can access content via DataLoader
- Example: `local lab = DataLoader.facilities.get("research_lab")`
- Decouples game logic from content files

**Future:**
- TASK-ALIGNMENT-005 will add validation to loaders
- TASK-ALIGNMENT-003 will document TOML schemas these loaders expect

---

## What Worked Well
(To be filled in after completion)

---

## Lessons Learned
(To be filled in after completion)

---

## Follow-up Tasks
- TASK-ALIGNMENT-003: Define TOML Schemas (document what loaders expect)
- TASK-ALIGNMENT-005: Implement Content Validation
- TASK-ALIGNMENT-007: Add Asset Verification for new content types
