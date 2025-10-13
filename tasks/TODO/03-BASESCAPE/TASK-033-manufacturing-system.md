# Task: Manufacturing System - Local Production & Workshop Management

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement a comprehensive manufacturing system similar to XCOM with manufacturing entries (blueprints), manufacturing projects (active production), workshop capacity per base, local production (not shared between bases), regional dependencies, and ability to produce items, units, and crafts.

---

## Purpose

The manufacturing system enables players to produce equipment, units, and crafts at their bases. Unlike research (which is global), manufacturing is local to each base and consumes workshop capacity. Manufacturing depends on research unlocks, regional resources, and can produce multiple outputs per project.

---

## Requirements

### Functional Requirements
- [ ] Manufacturing Entry: Blueprints for producible items/units/crafts
- [ ] Manufacturing Project: Active production with progress tracking
- [ ] Workshop Capacity: Local per base, provided by workshop facilities
- [ ] Daily Progression: Production advances based on allocated engineers
- [ ] Random Baseline: Each project has cost variance (75%-125%)
- [ ] Resource Consumption: Items consumed when project starts
- [ ] Multiple Outputs: Can produce more than 1 item per project
- [ ] Production Types: Items (equipment), Units (soldiers/aliens), Crafts (interceptors)
- [ ] Regional Dependencies: Some manufacturing requires specific regions
- [ ] Research Prerequisites: Must research before manufacturing
- [ ] Facility Requirements: Must have workshop facilities
- [ ] Service Requirements: Power, resources, etc.
- [ ] Automatic Pricing: Calculate sell price from input costs + labor

### Technical Requirements
- [ ] Data-driven manufacturing definitions (TOML files)
- [ ] Manufacturing state persistence (save/load)
- [ ] Event system for production completion
- [ ] Integration with base facility system (workshop capacity)
- [ ] Integration with calendar system (daily progression)
- [ ] Integration with inventory system (consume/produce items)
- [ ] Per-base capacity tracking

### Acceptance Criteria
- [ ] Can start manufacturing project if prerequisites met
- [ ] Production progresses daily by (engineers assigned / man-days needed)
- [ ] Resources consumed at project start
- [ ] Production completes when progress >= 1.0
- [ ] Outputs added to base inventory
- [ ] Workshop capacity limits concurrent projects
- [ ] Manufacturing is local per base (not shared)
- [ ] Regional requirements enforced
- [ ] Sell price calculated automatically

---

## Plan

### Step 1: Manufacturing Entry Data Structure (8 hours)
**Description:** Define manufacturing entry schema and data loader  
**Files to create:**
- `engine/data/manufacturing_entries.lua` - Manufacturing entry data
- `engine/basescape/logic/manufacturing_entry.lua` - ManufacturingEntry class
- `engine/mods/core/manufacturing/items.toml` - Item production
- `engine/mods/core/manufacturing/units.toml` - Unit production
- `engine/mods/core/manufacturing/crafts.toml` - Craft production

**ManufacturingEntry Schema:**
```lua
ManufacturingEntry = {
    id = "laser_rifle",
    name = "Laser Rifle",
    description = "Advanced energy weapon",
    
    -- Cost
    baselineManDays = 50,  -- Base cost, actual is 75%-125% per game
    credits = 5000,        -- Money cost per unit
    
    -- Inputs (consumed at start)
    inputItems = {
        {id = "alien_alloys", quantity = 2},
        {id = "power_cell", quantity = 1},
    },
    
    -- Outputs (produced at completion)
    outputs = {
        {id = "laser_rifle", quantity = 1, type = "item"},
    },
    outputQuantity = 1,  -- Can produce multiple per project
    
    -- Production type
    productionType = "item",  -- item | unit | craft
    
    -- Prerequisites
    requiredResearch = {"laser_weapons"},  -- Must complete research
    requiredFacilities = {"workshop"},     -- Facility types needed
    requiredServices = {"power", "workshop"}, -- Services needed
    requiredRegions = {},  -- Optional: specific regions only
    
    -- Metadata
    category = "weapons",  -- weapons, armor, equipment, vehicles, crafts
    icon = "laser_rifle.png",
    
    -- Auto-calculated
    autoSellPrice = nil,  -- Calculated from inputs + labor cost
}
```

**Production Types:**
1. **Items:** Equipment, weapons, armor, consumables
2. **Units:** Recruit soldiers, clone aliens (advanced tech)
3. **Crafts:** Interceptors, transports, UFO reproductions

**Estimated time:** 8 hours

---

### Step 2: Manufacturing Project System (10 hours)
**Description:** Active production tracking with progress, engineer allocation  
**Files to create:**
- `engine/basescape/logic/manufacturing_project.lua` - ManufacturingProject class
- `engine/basescape/systems/manufacturing_manager.lua` - Per-base manufacturing

**ManufacturingProject:**
```lua
ManufacturingProject = {
    id = "proj_mfg_001",
    baseId = "base_001",
    entryId = "laser_rifle",
    
    -- Progress
    manDaysRequired = 65,  -- Random 75%-125% of baseline (50)
    manDaysCompleted = 20,  -- Current progress
    progress = 0.31,        -- manDaysCompleted / manDaysRequired
    
    -- Engineers
    engineersAssigned = 5,  -- Current allocation
    
    -- Quantity
    quantityTotal = 10,      -- Total units to produce
    quantityCompleted = 0,   -- Units completed so far
    
    -- Status
    status = "active",  -- active | paused | completed | cancelled
    
    -- Resources
    resourcesConsumed = true,  -- Inputs consumed at start
    
    -- Dates
    startDate = {year = 1, month = 3, day = 15},
    estimatedCompletion = {year = 1, month = 4, day = 2},
    completedDate = nil,
    
    -- Base reference
    baseId = "base_001",  -- Manufacturing is local per base
}
```

**ManufacturingManager (per base):**
```lua
ManufacturingManager = {
    baseId = "base_001",
    entries = {},          -- Available manufacturing entries
    projects = {},         -- Active projects in this base
    workshopCapacity = 0,  -- Total capacity from facilities
    engineersUsed = 0,     -- Currently allocated engineers
}

ManufacturingManager:loadEntries()  -- Load from TOML
ManufacturingManager:canManufacture(entryId)  -- Check prerequisites
ManufacturingManager:startProduction(entryId, quantity, engineers)
ManufacturingManager:pauseProduction(projectId)
ManufacturingManager:resumeProduction(projectId)
ManufacturingManager:cancelProduction(projectId)  -- Refund 50% inputs
ManufacturingManager:assignEngineers(projectId, count)
ManufacturingManager:dailyProgress()  -- Advance all projects
ManufacturingManager:completeProduction(projectId)  -- Add outputs to inventory
ManufacturingManager:getAvailableManufacturing()
ManufacturingManager:getActiveProjects()
ManufacturingManager:getWorkshopCapacity()
ManufacturingManager:getAvailableCapacity()
```

**Estimated time:** 10 hours

---

### Step 3: Workshop Capacity System (8 hours)
**Description:** Per-base workshop capacity from facilities  
**Dependencies:** TASK-029 (Basescape Facility System)
**Files to modify:**
- `engine/basescape/logic/facility.lua` - Add manufacturing_capacity
- `engine/basescape/systems/capacity_manager.lua` - Track workshop capacity

**Workshop Capacity:**
```lua
-- Facility provides manufacturing_capacity
FacilityType = {
    id = "workshop",
    name = "Workshop",
    capacities = {
        manufacturing_capacity = 20,  -- Support 20 engineers
    }
}

-- Advanced workshop (late game)
FacilityType = {
    id = "advanced_workshop",
    capacities = {
        manufacturing_capacity = 50,  -- More efficient
    }
}

-- ManufacturingManager uses base-local capacity
ManufacturingManager:getWorkshopCapacity()
    return self.base:getCapacity("manufacturing_capacity")

ManufacturingManager:getAvailableCapacity()
    local total = self:getWorkshopCapacity()
    local used = 0
    for project in self.projects do
        if project.status == "active" then
            used += project.engineersAssigned
        end
    end
    return total - used
```

**Estimated time:** 8 hours

---

### Step 4: Daily Progression System (6 hours)
**Description:** Integrate with calendar for daily production progress  
**Files to modify:**
- `engine/geoscape/systems/calendar.lua` - Add manufacturing progression hook
**Files to create:**
- `engine/basescape/systems/manufacturing_progression.lua` - Daily updates

**Daily Progression Logic:**
```lua
ManufacturingProgression:advanceDay()
    -- For each base:
    for base in allBases do
        local manager = base.manufacturingManager
        
        -- For each active project:
        for project in manager.projects do
            if project.status == "active" then
                -- Calculate daily progress
                local dailyProgress = project.engineersAssigned
                project.manDaysCompleted += dailyProgress
                project.progress = project.manDaysCompleted / project.manDaysRequired
                
                -- Check if unit completed
                if project.progress >= 1.0 then
                    -- Produce one unit
                    manager:produceUnit(project)
                    project.quantityCompleted += 1
                    
                    -- Reset for next unit
                    if project.quantityCompleted < project.quantityTotal then
                        project.manDaysCompleted = 0
                        project.progress = 0
                    else
                        -- All units completed
                        manager:completeProduction(project.id)
                    end
                end
            end
        end
    end
```

**Estimated time:** 6 hours

---

### Step 5: Resource Consumption & Production (10 hours)
**Description:** Consume inputs at start, produce outputs at completion  
**Files to create:**
- `engine/basescape/logic/manufacturing_resources.lua` - Resource handling

**Resource Consumption (at project start):**
```lua
ManufacturingManager:startProduction(entryId, quantity, engineers)
    local entry = self.entries[entryId]
    
    -- Validate resources available
    for _, input in ipairs(entry.inputItems) do
        local totalNeeded = input.quantity * quantity
        local available = self.base.inventory:getItemCount(input.id)
        if available < totalNeeded then
            return nil, "Insufficient " .. input.id
        end
    end
    
    -- Validate money
    local totalCost = entry.credits * quantity
    if GameState.credits < totalCost then
        return nil, "Insufficient credits"
    end
    
    -- Consume resources
    for _, input in ipairs(entry.inputItems) do
        local totalNeeded = input.quantity * quantity
        self.base.inventory:removeItem(input.id, totalNeeded)
    end
    
    -- Deduct credits
    GameState.credits -= totalCost
    
    -- Create project
    local project = ManufacturingProject:new(entry, quantity, engineers)
    table.insert(self.projects, project)
    return project
```

**Production (at completion):**
```lua
ManufacturingManager:produceUnit(project)
    local entry = project.entry
    
    -- Add outputs to inventory
    for _, output in ipairs(entry.outputs) do
        if output.type == "item" then
            self.base.inventory:addItem(output.id, output.quantity)
        elseif output.type == "unit" then
            self.base.personnel:addUnit(output.id)
        elseif output.type == "craft" then
            self.base.hangar:addCraft(output.id)
        end
    end
    
    -- Emit event
    EventManager:emit("manufacturing_unit_completed", {
        projectId = project.id,
        entryId = project.entryId,
        baseId = self.baseId,
    })
```

**Estimated time:** 10 hours

---

### Step 6: Regional Dependencies (6 hours)
**Description:** Some manufacturing requires specific regions or resources  
**Files to create:**
- `engine/basescape/logic/manufacturing_regions.lua` - Regional validation

**Regional Manufacturing:**
```lua
ManufacturingEntry = {
    id = "alien_alloy_plate",
    requiredRegions = {"north_america", "europe"},  -- Only in these regions
    -- OR
    requiredBiomes = {"industrial"},  -- Only in industrial provinces
}

ManufacturingManager:canManufacture(entryId)
    local entry = self.entries[entryId]
    
    -- Check region requirement
    if #entry.requiredRegions > 0 then
        local baseRegion = self.base.provinceId.regionId
        if not contains(entry.requiredRegions, baseRegion) then
            return false, "Not available in this region"
        end
    end
    
    -- Check biome requirement
    if #entry.requiredBiomes > 0 then
        local baseBiome = self.base.provinceId.biome
        if not contains(entry.requiredBiomes, baseBiome) then
            return false, "Requires " .. entry.requiredBiomes[1] .. " biome"
        end
    end
    
    return true
```

**Use Cases:**
- Alien tech requires alien materials (found in UFO crash sites)
- Advanced crafts require industrial regions
- Biological units require labs in specific biomes

**Estimated time:** 6 hours

---

### Step 7: Automatic Sell Price Calculation (4 hours)
**Description:** Calculate item sell price from input costs + labor  
**Files to create:**
- `engine/basescape/logic/manufacturing_pricing.lua` - Price calculation

**Sell Price Formula:**
```lua
ManufacturingPricing:calculateSellPrice(entry)
    -- Calculate input costs
    local inputCost = 0
    for _, input in ipairs(entry.inputItems) do
        local itemPrice = ItemDatabase:getBasePrice(input.id)
        inputCost += itemPrice * input.quantity
    end
    
    -- Calculate labor cost
    local laborRate = 100  -- $100 per man-day (configurable)
    local laborCost = entry.baselineManDays * laborRate
    
    -- Total cost
    local totalCost = inputCost + laborCost + entry.credits
    
    -- Markup (e.g., 150% for profit)
    local markup = 1.5
    local sellPrice = totalCost * markup
    
    return sellPrice
end
```

**Applied automatically when:**
- Selling manufactured items in marketplace
- Calculating base value for loot
- Determining black market prices

**Estimated time:** 4 hours

---

### Step 8: Multi-Output Manufacturing (6 hours)
**Description:** Support producing multiple items per project  
**Files to modify:**
- `engine/basescape/logic/manufacturing_entry.lua` - Multiple outputs

**Multi-Output Example:**
```toml
[alien_alloy_processing]
id = "alien_alloy_processing"
name = "Alien Alloy Processing"
baseline_man_days = 30
credits = 2000

[[input_items]]
id = "ufo_wreckage"
quantity = 5

[[outputs]]
id = "alien_alloys"
quantity = 3
type = "item"

[[outputs]]
id = "elerium_115"
quantity = 1
type = "item"

[[outputs]]
id = "scrap_metal"
quantity = 2
type = "item"
```

**Implementation:**
```lua
ManufacturingManager:produceUnit(project)
    -- Produce ALL outputs
    for _, output in ipairs(project.entry.outputs) do
        if output.type == "item" then
            self.base.inventory:addItem(output.id, output.quantity)
            print("[Manufacturing] Produced: " .. output.quantity .. "x " .. output.id)
        end
    end
```

**Estimated time:** 6 hours

---

### Step 9: UI Implementation (16 hours)
**Description:** Manufacturing screen with project management, engineer allocation  
**Files to create:**
- `engine/basescape/ui/manufacturing_screen.lua` - Main manufacturing UI
- `engine/basescape/ui/manufacturing_entry_list.lua` - Available items
- `engine/basescape/ui/manufacturing_project_panel.lua` - Active projects
- `engine/basescape/ui/manufacturing_entry_detail.lua` - Recipe details

**Manufacturing Screen Layout (960×720, 24px grid):**
```
┌─────────────────────────────────────────┐
│ Workshop                  Engineers: 20 │ (Top bar)
├──────────────┬──────────────────────────┤
│ Available    │  Recipe Details          │
│ ┌──────────┐│  ┌────────────────────┐  │
│ │Laser Rifle││  │ Laser Rifle        │  │
│ │50 man-days││  │ Cost: 5000 credits │  │
│ └──────────┘│  │ Inputs:            │  │
│ ┌──────────┐│  │  - Alien Alloy x2  │  │
│ │Plasma Gun││  │  - Power Cell x1   │  │
│ └──────────┘│  │ Outputs:           │  │
│              │  │  - Laser Rifle x1  │  │
│              │  │ [Start Production] │  │
│              │  └────────────────────┘  │
├──────────────┴──────────────────────────┤
│ Active Projects                         │
│ ┌────────────────────────────────────┐ │
│ │ Laser Rifle x10: [████░░] 40%      │ │
│ │ Engineers: 5  Units: 4/10  Est:6d  │ │
│ │ [Pause] [Cancel] [+/-] Engineers   │ │
│ └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Widgets (all grid-aligned 24px):**
- ManufacturingScreen (full screen)
- ManufacturingEntryList (scrollable, filtered by category)
- ManufacturingEntryCard (4×3 grid cells)
- ManufacturingProjectPanel (progress bars, controls)
- EngineerAllocationSlider (assign engineers)
- QuantitySelector (select how many to produce)

**Estimated time:** 16 hours

---

### Step 10: Data Files (12 hours)
**Description:** Create comprehensive manufacturing data for core mod  
**Files to create:**
- `engine/mods/core/manufacturing/weapons.toml` - Weapon production
- `engine/mods/core/manufacturing/armor.toml` - Armor production
- `engine/mods/core/manufacturing/equipment.toml` - Equipment production
- `engine/mods/core/manufacturing/ammo.toml` - Ammunition production
- `engine/mods/core/manufacturing/vehicles.toml` - Vehicle production
- `engine/mods/core/manufacturing/crafts.toml` - Craft production
- `engine/mods/core/manufacturing/units.toml` - Unit production

**Example: Weapon Manufacturing**
```toml
[laser_rifle]
id = "laser_rifle"
name = "Laser Rifle"
description = "Standard laser weapon"
baseline_man_days = 50
credits = 5000
production_type = "item"
required_research = ["laser_weapons"]
required_facilities = ["workshop"]
required_services = ["power", "workshop"]
category = "weapons"

[[input_items]]
id = "alien_alloys"
quantity = 2

[[input_items]]
id = "power_cell"
quantity = 1

[[outputs]]
id = "laser_rifle"
quantity = 1
type = "item"

[plasma_rifle]
id = "plasma_rifle"
name = "Plasma Rifle"
baseline_man_days = 100
credits = 15000
required_research = ["plasma_weapons"]

[[input_items]]
id = "alien_alloys"
quantity = 3

[[input_items]]
id = "elerium_115"
quantity = 1

[[outputs]]
id = "plasma_rifle"
quantity = 1
type = "item"

[heavy_plasma]
id = "heavy_plasma"
name = "Heavy Plasma"
baseline_man_days = 150
credits = 25000
required_research = ["heavy_plasma_weapons"]
required_regions = ["north_america", "europe"]  # Advanced tech only

[[input_items]]
id = "alien_alloys"
quantity = 5

[[input_items]]
id = "elerium_115"
quantity = 2

[[outputs]]
id = "heavy_plasma"
quantity = 1
type = "item"
```

**Manufacturing Categories:**
1. **Weapons** (20 entries) - Rifles, pistols, heavy weapons
2. **Armor** (12 entries) - Body armor, power suits, helmets
3. **Equipment** (15 entries) - Medkits, grenades, tools
4. **Ammunition** (10 entries) - Magazines, energy cells
5. **Vehicles** (6 entries) - Tanks, HWPs (Heavy Weapon Platforms)
6. **Crafts** (8 entries) - Interceptors, transports
7. **Units** (5 entries) - Clones, androids (advanced tech)

**Estimated time:** 12 hours

---

### Step 11: Testing & Validation (10 hours)
**Description:** Unit tests, integration tests, manual testing  
**Files to create:**
- `engine/basescape/tests/test_manufacturing_entry.lua`
- `engine/basescape/tests/test_manufacturing_project.lua`
- `engine/basescape/tests/test_manufacturing_manager.lua`
- `engine/basescape/tests/test_manufacturing_pricing.lua`

**Test Cases:**
1. **ManufacturingEntry:**
   - Load from TOML correctly
   - Validate required fields
   - Calculate random baseline (75%-125%)
   - Multi-output entries
   
2. **ManufacturingProject:**
   - Create project with engineers
   - Progress calculation correct
   - Unit completion detection
   - Quantity tracking
   
3. **ManufacturingManager:**
   - Start production consumes resources
   - Workshop capacity limits projects
   - Daily progression works
   - Completion adds to inventory
   - Cancel refunds 50% resources
   
4. **Regional Dependencies:**
   - Cannot manufacture without region
   - Biome restrictions enforced
   
5. **Pricing:**
   - Sell price calculated correctly
   - Includes input costs + labor

**Manual Testing:**
```bash
lovec "engine"
```
1. Create base with workshop
2. Hire engineers (10)
3. Complete "laser weapons" research
4. Open manufacturing screen
5. Verify laser rifle available
6. Start production (quantity: 10)
7. Assign engineers (5)
8. Advance calendar 1 day
9. Check progress (5/50 = 10%)
10. Advance calendar 9 more days
11. Verify first unit completed
12. Continue until all 10 complete
13. Check inventory for laser rifles

**Estimated time:** 10 hours

---

### Step 12: Documentation (6 hours)
**Description:** Update API docs, FAQ, wiki  
**Files to update:**
- `wiki/API.md` - ManufacturingManager, ManufacturingEntry APIs
- `wiki/FAQ.md` - How to manufacture equipment
- `wiki/DEVELOPMENT.md` - Manufacturing system architecture
- `wiki/wiki/manufacturing.md` - Complete manufacturing guide

**Documentation Sections:**
- Manufacturing entry schema reference
- Workshop capacity calculation
- Resource consumption mechanics
- Multi-output production
- Regional dependencies
- Automatic pricing formula
- Modding guide for adding manufacturing

**Estimated time:** 6 hours

---

## Implementation Details

### Architecture

**Data Layer:**
- TOML files define manufacturing entries
- Random baseline per entry (one-time, game start)
- Multi-output support

**Logic Layer:**
- ManufacturingManager: Per-base production coordination
- ManufacturingProject: Active production tracking
- ManufacturingResources: Resource consumption/production
- ManufacturingPricing: Automatic sell price calculation

**System Layer:**
- Calendar integration for daily progression
- Event system for production completion
- Facility integration for workshop capacity
- Inventory integration for resources

**UI Layer:**
- Manufacturing entry browser (filter by category)
- Project management (start, pause, assign engineers)
- Progress tracking (bars, estimates, quantity)
- Resource visualization (inputs/outputs)

### Key Components

1. **ManufacturingEntry:** Production blueprint loaded from TOML
2. **ManufacturingProject:** Active production with progress tracking
3. **ManufacturingManager:** Per-base production state and operations
4. **ManufacturingProgression:** Daily advancement system
5. **ManufacturingPricing:** Automatic sell price calculation

### Dependencies

- **TASK-025 Phase 2:** Calendar system for daily progression
- **TASK-029:** Basescape facility system for workshop capacity
- **TASK-032:** Research system for manufacturing unlocks
- **Inventory System:** Item consumption and production
- **Event System:** Production completion events

---

## Testing Strategy

### Unit Tests

**ManufacturingEntry Tests:**
```lua
function test_load_from_toml()
    local entry = ManufacturingEntry:fromTOML(data)
    assert(entry.id == "laser_rifle")
    assert(entry.baselineManDays == 50)
end

function test_multi_output()
    local entry = ManufacturingEntry:new("alloy_processing")
    assert(#entry.outputs == 3)
end
```

**ManufacturingManager Tests:**
```lua
function test_resource_consumption()
    local manager = ManufacturingManager:new(base)
    base.inventory:addItem("alien_alloys", 10)
    
    manager:startProduction("laser_rifle", 5, 5)
    
    -- Should consume 2 per rifle × 5 rifles = 10 alloys
    assert(base.inventory:getItemCount("alien_alloys") == 0)
end

function test_capacity_limit()
    local manager = ManufacturingManager:new(base)
    manager.workshopCapacity = 20
    
    manager:startProduction("laser_rifle", 10, 15)
    manager:startProduction("plasma_rifle", 5, 10)
    
    -- Should fail - only 5 capacity left
    local ok, err = manager:startProduction("armor", 1, 10)
    assert(ok == nil)
end
```

### Integration Tests

**Manufacturing Flow:**
```lua
function test_complete_manufacturing_flow()
    -- Start production
    local project = manager:startProduction("laser_rifle", 10, 5)
    assert(project ~= nil)
    
    -- Advance time
    for i = 1, 10 do
        ManufacturingProgression:advanceDay()
    end
    
    -- Check first unit completed
    assert(project.quantityCompleted == 1)
    assert(base.inventory:getItemCount("laser_rifle") == 1)
    
    -- Advance until all complete
    for i = 1, 90 do
        ManufacturingProgression:advanceDay()
    end
    
    -- Check all units completed
    assert(project.status == "completed")
    assert(base.inventory:getItemCount("laser_rifle") == 10)
end
```

### Manual Testing Steps

1. **Run game:** `lovec "engine"`
2. **Create base** with workshop facility
3. **Hire engineers** (10)
4. **Complete research** (laser weapons)
5. **Add resources** to inventory (alien alloys, power cells)
6. **Open manufacturing screen**
7. **Select laser rifle** - verify details shown
8. **Start production** (quantity: 5, engineers: 5)
9. **Check resources** - should be consumed
10. **Advance calendar** 10 days
11. **Check progress** - should show 1 unit completed
12. **Advance** until all 5 complete
13. **Check inventory** - should have 5 laser rifles
14. **Test cancel** - verify 50% refund

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
  print("[ManufacturingManager] Starting production: " .. entryId)
  print("[Manufacturing] Resources consumed: " .. resourcesConsumed)
  print("[Manufacturing] Unit completed: " .. project.quantityCompleted)
  ```
- Check console window for errors and debug messages
- Use F9 for grid overlay in UI development

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add ManufacturingManager, ManufacturingEntry APIs
- [x] `wiki/FAQ.md` - Add "How do I manufacture equipment?" section
- [x] `wiki/DEVELOPMENT.md` - Add manufacturing system architecture
- [x] `wiki/wiki/manufacturing.md` - Update with complete implementation
- [ ] Code comments - Add inline documentation

**API Documentation Required:**
```lua
-- ManufacturingManager API
ManufacturingManager:canManufacture(entryId) -> boolean, reason
ManufacturingManager:startProduction(entryId, quantity, engineers) -> ManufacturingProject | nil, error
ManufacturingManager:pauseProduction(projectId)
ManufacturingManager:resumeProduction(projectId)
ManufacturingManager:cancelProduction(projectId)  -- 50% refund
ManufacturingManager:assignEngineers(projectId, count)
ManufacturingManager:dailyProgress()
ManufacturingManager:getAvailableManufacturing() -> table
ManufacturingManager:getActiveProjects() -> table
ManufacturingManager:getWorkshopCapacity() -> number
ManufacturingManager:getAvailableCapacity() -> number
```

---

## Notes

### XCOM-Style Manufacturing
- **Local per Base:** Each base has its own manufacturing queue
- **Workshop Capacity:** Provided by workshop facilities
- **Resource Consumption:** Inputs consumed at project start
- **Batch Production:** Can produce multiple units in one project
- **Man-Day System:** Cost in "man-days" (1 engineer = 1 man-day/day)
- **Regional Dependencies:** Some items require specific regions
- **Auto-Pricing:** Sell price calculated from costs + labor

### Design Decisions
- Manufacturing is **local** (not global like research)
- Resources consumed **at start** (not during production)
- Can produce **multiple outputs** per project
- Regional restrictions add strategic base placement
- Automatic pricing ensures balance

### Performance Considerations
- Per-base manufacturing managers (not global)
- Cache workshop capacity calculations
- Update UI only on changes (not every frame)
- Efficient resource validation

---

## Blockers

- **TASK-025 Phase 2:** Calendar system for daily progression
- **TASK-029:** Basescape facility system for workshop capacity
- **TASK-032:** Research system for manufacturing unlocks
- **Inventory System:** Must be functional

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
- [ ] Manufacturing is local per base
- [ ] Resources consumed at project start
- [ ] Workshop capacity limits enforced
- [ ] Daily progression integrated with calendar
- [ ] Outputs added to inventory correctly
- [ ] Multi-output production works
- [ ] Regional dependencies enforced
- [ ] Auto-pricing calculated correctly
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

**Total: 108 hours (13-14 days)**

- Step 1: Manufacturing Entry Data Structure - 8h
- Step 2: Manufacturing Project System - 10h
- Step 3: Workshop Capacity System - 8h
- Step 4: Daily Progression System - 6h
- Step 5: Resource Consumption & Production - 10h
- Step 6: Regional Dependencies - 6h
- Step 7: Automatic Sell Price Calculation - 4h
- Step 8: Multi-Output Manufacturing - 6h
- Step 9: UI Implementation - 16h
- Step 10: Data Files - 12h
- Step 11: Testing & Validation - 10h
- Step 12: Documentation - 6h
