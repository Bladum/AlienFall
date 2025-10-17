# Task: Basescape Facility System - Complete Base Management

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

**Dependencies:** TASK-025 (Geoscape Calendar System for daily build progression)

---

## Overview

Implement complete basescape facility management system with 5×5 grid, mandatory HQ building, facility construction, capacity system, service management, maintenance costs, inter-base transfers, and base defense integration. Each facility provides capacities (items, units, crafts, research, manufacturing, defense, prisoners, healing, sanity recovery, craft repair, training, radar) and services (power, fuel, etc.).

---

## Purpose

Basescape is a core strategic layer where players construct and manage their operational bases. Facilities are the building blocks that provide capacity for all game systems (storage, personnel, research, manufacturing, defense). The service system creates interdependencies between facilities (power, fuel, etc.). This system must support:
- 5×5 grid layout with mandatory HQ as anchor
- Construction queue with daily progression (requires calendar system)
- Capacity aggregation from all facilities
- Service provision and requirement validation
- Maintenance costs deducted monthly
- Inter-base transfers with distance and size-based delays
- Base defense missions with facility health/armor

---

## Requirements

### Functional Requirements
- [x] 5×5 facility grid with coordinate validation
- [x] Mandatory HQ facility at center (always present, cannot be destroyed)
- [x] Facility construction with cost (money, resources, tech), build time (days)
- [x] Capacity system: items, units, crafts, research projects, manufacturing projects, defense, prisoners, healing, sanity, craft repair, training, radar
- [x] Service system: facilities provide/require services (tags like "power", "fuel")
- [x] Maintenance costs: monthly upkeep for each facility
- [x] Inter-base transfers: items/units move between bases (days = distance × size modifier)
- [x] Base defense: facilities have health/armor, provide defensive units in battlescape
- [x] Facility prerequisites: tech requirements, other facility dependencies
- [x] Construction queue: multiple facilities building simultaneously

### Technical Requirements
- [x] Data-driven facility definitions in TOML/Lua tables
- [x] Integration with calendar system for daily build progression
- [x] Integration with finance system for costs/maintenance
- [x] Integration with geoscape for base locations and distance calculations
- [x] Integration with battlescape for defense missions (map blocks)
- [x] Event system for construction completion, facility damage
- [x] Save/load support for all facility state

### Acceptance Criteria
- [x] Can create 5×5 base with HQ in center
- [x] Can build facilities with construction time, costs validated
- [x] Capacities aggregate correctly from all operational facilities
- [x] Service requirements validated (e.g., manufacturing needs "power" service)
- [x] Maintenance costs deducted monthly
- [x] Transfers between bases take appropriate time based on distance/size
- [x] Base defense missions use facility map blocks and provide defenders
- [x] Cannot build facilities without tech/prerequisites
- [x] Construction progresses daily via calendar system
- [x] Damaged facilities lose capacity until repaired

---

## Plan

### Step 1: Facility Data Structure & Types (10 hours)
**Description:** Define facility type definitions and facility instance classes  
**Files to create:**
- `engine/basescape/logic/facility_type.lua` - Facility type definitions
- `engine/basescape/logic/facility.lua` - Facility instance class
- `engine/data/facilities.lua` - Facility type data

**FacilityType:**
```lua
FacilityType = {
    id = "living_quarters",
    name = "Living Quarters",
    description = "Housing for personnel",
    
    -- Construction
    buildTime = 14,  -- Days
    buildCost = {credits = 100000},
    buildResources = {},  -- {item_id = quantity}
    
    -- Prerequisites
    requiredTech = {},  -- Tech IDs
    requiredFacilities = {},  -- Facility type IDs
    
    -- Grid properties
    size = {width = 1, height = 1},  -- 1×1 to 2×2 typical
    
    -- Capacity contributions
    capacities = {
        unit_quarters = 20,
        item_storage = 50,
    },
    
    -- Services
    servicesProvided = {"housing"},
    servicesRequired = {"power"},
    
    -- Operations
    maintenanceCost = 5000,  -- Monthly credits
    powerConsumption = 10,
    staffingRequired = {engineer = 2},
    
    -- Defense
    health = 100,
    armor = 10,
    mapBlock = "facility_quarters",  -- Map block ID for battlescape
    defenseUnits = {},  -- Units spawned in defense missions
    
    -- Special
    maxPerBase = nil,  -- Limit quantity per base (nil = unlimited)
    specialFlags = {},  -- Tags like "underwater_only", "space_only"
}
```

**Facility Instance:**
```lua
Facility = {
    id = "unique_id",
    typeId = "living_quarters",
    baseId = "base_alpha",
    
    -- Grid position
    gridX = 2,
    gridY = 2,
    
    -- State
    state = "operational",  -- "constructing", "operational", "damaged", "destroyed"
    constructionProgress = 0,  -- 0-100 or days remaining
    daysBuilt = 0,
    
    -- Health
    health = 100,
    maxHealth = 100,
    armor = 10,
    
    -- Operations
    isConnected = true,  -- Connected to HQ via corridors
    isPowered = true,    -- Has power service
    efficiency = 1.0,    -- 0.0-1.0 multiplier for capacities
    
    -- Metadata
    builtDate = nil,  -- Calendar day when completed
}
```

**Estimated time:** 10 hours

---

### Step 2: Base Grid & Placement System (8 hours)
**Description:** 5×5 grid management with HQ anchor and placement validation  
**Files to create:**
- `engine/basescape/logic/base_grid.lua` - Grid management
- `engine/basescape/logic/facility_placement.lua` - Placement validation

**BaseGrid:**
```lua
BaseGrid = {
    baseId = "base_alpha",
    size = 5,  -- 5×5 grid
    grid = {},  -- [x][y] = facility or nil
    hqPosition = {x = 2, y = 2},  -- HQ always at center
}

BaseGrid:canPlaceFacility(facilityType, x, y)
    -- Check bounds
    -- Check overlap
    -- Check connectivity to HQ (must connect via corridors)
    -- Check prerequisites (tech, other facilities)
    return canPlace, reason

BaseGrid:placeFacility(facility, x, y)
    -- Add to grid
    -- Update connectivity
    -- Emit event

BaseGrid:removeFacility(x, y)
    -- Remove from grid
    -- Update connectivity
    -- Check if other facilities disconnected

BaseGrid:updateConnectivity()
    -- BFS/flood fill from HQ
    -- Mark all reachable facilities as connected
    -- Offline facilities lose efficiency

BaseGrid:getFacilityAt(x, y)
BaseGrid:getAllFacilities()
BaseGrid:getFacilitiesByType(typeId)
```

**Estimated time:** 8 hours

---

### Step 3: Construction System (12 hours)
**Description:** Construction queue, cost validation, daily progression  
**Files to create:**
- `engine/basescape/logic/construction_manager.lua` - Construction management
- `engine/basescape/systems/construction_system.lua` - Daily progression

**ConstructionManager:**
```lua
ConstructionManager = {
    constructions = {},  -- Active construction projects
}

ConstructionManager:startConstruction(baseId, facilityTypeId, x, y)
    -- Validate prerequisites
    -- Validate resources/money
    -- Deduct costs
    -- Create facility in "constructing" state
    -- Add to construction queue
    return constructionId or nil, errorReason

ConstructionManager:progressConstruction(facilityId)
    -- Increment daysBuilt
    -- Check if complete
    -- If complete: activate facility, emit event
    
ConstructionManager:cancelConstruction(facilityId)
    -- Remove from grid
    -- Refund 50% of costs
    
ConstructionManager:getConstructionProgress(facilityId)
    return daysBuilt, totalDays, percentage
```

**Daily Progression (called by calendar system):**
```lua
function ConstructionSystem:onDayPassed()
    for _, construction in ipairs(ConstructionManager.constructions) do
        ConstructionManager:progressConstruction(construction.id)
    end
end
```

**Estimated time:** 12 hours

---

### Step 4: Capacity System (10 hours)
**Description:** Aggregate capacities from facilities, enforce limits  
**Files to create:**
- `engine/basescape/logic/capacity_manager.lua` - Capacity aggregation
- `engine/basescape/systems/capacity_system.lua` - Usage tracking

**CapacityManager:**
```lua
CapacityManager = {
    baseId = "base_alpha",
    capacities = {
        -- Aggregated from all operational facilities
        item_storage = 0,
        unit_quarters = 0,
        craft_hangars = 0,
        research_capacity = 0,
        manufacturing_capacity = 0,
        defense_capacity = 0,
        prisoner_capacity = 0,
        healing_throughput = 0,
        sanity_recovery_throughput = 0,
        craft_repair_throughput = 0,
        training_throughput = 0,
        radar_range = 0,
    },
    usage = {
        -- Current usage
        item_storage_used = 0,
        unit_quarters_used = 0,
        -- ...
    }
}

CapacityManager:recalculate()
    -- Sum capacities from all operational, connected facilities
    -- Apply efficiency multipliers
    
CapacityManager:getAvailableCapacity(capacityType)
    return capacities[capacityType] - usage[capacityType]
    
CapacityManager:canAllocate(capacityType, amount)
    return getAvailableCapacity(capacityType) >= amount
    
CapacityManager:allocate(capacityType, amount)
    -- Increase usage
    
CapacityManager:deallocate(capacityType, amount)
    -- Decrease usage
```

**Integration points:**
- Inventory system checks `item_storage` capacity
- Personnel system checks `unit_quarters` capacity
- Research system checks `research_capacity`
- Manufacturing system checks `manufacturing_capacity`

**Estimated time:** 10 hours

---

### Step 5: Service System (8 hours)
**Description:** Service tags for facility dependencies  
**Files to create:**
- `engine/basescape/logic/service_manager.lua` - Service provision/requirements

**ServiceManager:**
```lua
ServiceManager = {
    baseId = "base_alpha",
    servicesProvided = {},  -- Set of service tags: {"power", "fuel", "medical"}
    servicesRequired = {},  -- Map of facility -> required services
}

ServiceManager:recalculate()
    -- Collect all services from operational facilities
    servicesProvided = {}
    for facility in base.facilities do
        if facility.state == "operational" and facility.isConnected then
            for _, service in ipairs(facility.type.servicesProvided) do
                servicesProvided[service] = true
            end
        end
    end
    
    -- Check each facility's requirements
    for facility in base.facilities do
        for _, requiredService in ipairs(facility.type.servicesRequired) do
            if not servicesProvided[requiredService] then
                facility:setOffline("Missing service: " .. requiredService)
            end
        end
    end

ServiceManager:hasService(serviceTag)
    return servicesProvided[serviceTag] == true
    
ServiceManager:getFacilitiesProvidingService(serviceTag)
    -- Return list of facilities
```

**Common Services:**
- `power` - Provided by generators, required by most facilities
- `fuel` - Provided by fuel storage, required by hangars/manufacturing
- `medical` - Provided by hospital, enables healing
- `training` - Provided by academy, enables training
- `research` - Provided by labs, enables research projects
- `manufacturing` - Provided by workshops, enables production

**Estimated time:** 8 hours

---

### Step 6: Maintenance & Finance Integration (6 hours)
**Description:** Monthly maintenance costs, integration with finance system  
**Files to modify:**
- `engine/basescape/systems/maintenance_system.lua` - Calculate monthly costs
- `engine/geoscape/systems/finance_system.lua` - Deduct maintenance

**MaintenanceSystem:**
```lua
function MaintenanceSystem:calculateMonthlyMaintenance(base)
    local total = 0
    for _, facility in ipairs(base:getAllFacilities()) do
        if facility.state == "operational" then
            local facilityType = FacilityRegistry:get(facility.typeId)
            total = total + facilityType.maintenanceCost
        end
    end
    return total
end

-- Called by calendar system on month end
function MaintenanceSystem:onMonthEnded()
    for _, base in ipairs(BaseManager:getAllBases()) do
        local cost = self:calculateMonthlyMaintenance(base)
        FinanceSystem:deduct(cost, "base_maintenance", base.id)
    end
end
```

**Estimated time:** 6 hours

---

### Step 7: Inter-Base Transfer System (12 hours)
**Description:** Transfer items/units between bases with time delays  
**Files to create:**
- `engine/basescape/logic/transfer.lua` - Transfer entity
- `engine/basescape/systems/transfer_system.lua` - Transfer management

**Transfer:**
```lua
Transfer = {
    id = "transfer_001",
    type = "item",  -- "item", "unit", "craft"
    itemId = nil,  -- If type == "item"
    quantity = 1,
    
    -- Route
    fromBaseId = "base_alpha",
    toBaseId = "base_beta",
    
    -- Timing
    startDay = 45,
    arrivalDay = 52,  -- Based on distance and size
    daysRemaining = 7,
    
    -- Size (affects travel time)
    size = 10,  -- Volume units
    
    state = "in_transit",  -- "scheduled", "in_transit", "arrived", "cancelled"
}

TransferSystem:startTransfer(type, itemId, quantity, fromBaseId, toBaseId)
    -- Calculate distance between bases
    -- Calculate size of transfer
    -- Calculate travel time: days = distance × sizeModifier
    -- Create transfer entity
    -- Deduct from source base capacity
    
TransferSystem:onDayPassed()
    for transfer in transfers do
        transfer.daysRemaining = transfer.daysRemaining - 1
        if transfer.daysRemaining <= 0 then
            self:completeTransfer(transfer)
        end
    end
    
TransferSystem:completeTransfer(transfer)
    -- Add items/units to destination base
    -- Emit event
    -- Remove transfer
    
TransferSystem:cancelTransfer(transferId)
    -- Return items to source base
```

**Distance Calculation:**
```lua
function calculateTransferTime(fromBase, toBase, size)
    local distance = getProvinceDistance(fromBase.provinceId, toBase.provinceId)
    local sizeModifier = 1 + (size / 100)  -- Larger transfers take longer
    local baseDays = math.ceil(distance / 100)  -- 1 day per 100km
    return baseDays * sizeModifier
end
```

**Estimated time:** 12 hours

---

### Step 8: Base Defense Integration (10 hours)
**Description:** Facility health/armor, map blocks for battlescape, defense units  
**Files to create:**
- `engine/basescape/logic/base_defense.lua` - Defense mission setup
- `engine/battlescape/map/facility_mapblock_loader.lua` - Load facility map blocks

**BaseDefense:**
```lua
BaseDefense = {
    baseId = "base_alpha",
    defenseStrength = 0,  -- Aggregated from facilities
    defenseUnits = {},    -- Units provided by facilities
}

BaseDefense:calculateDefenseStrength()
    local total = 0
    for _, facility in ipairs(base:getAllFacilities()) do
        if facility.state == "operational" then
            total = total + (facility.type.armor or 0)
        end
    end
    return total
    
BaseDefense:generateDefenseMap()
    -- Load map blocks for each facility
    local mapBlocks = {}
    for _, facility in ipairs(base:getAllFacilities()) do
        local mapBlock = MapBlockRegistry:get(facility.type.mapBlock)
        table.insert(mapBlocks, {
            mapBlock = mapBlock,
            position = {x = facility.gridX, y = facility.gridY}
        })
    end
    return MapGenerator:assembleBaseDefenseMap(mapBlocks)
    
BaseDefense:getDefenderUnits()
    -- Collect units from facilities
    local units = {}
    for _, facility in ipairs(base:getAllFacilities()) do
        for _, unitTypeId in ipairs(facility.type.defenseUnits) do
            table.insert(units, UnitFactory:create(unitTypeId))
        end
    end
    return units
```

**Facility Damage:**
```lua
function Facility:takeDamage(damage)
    local actualDamage = math.max(0, damage - self.armor)
    self.health = self.health - actualDamage
    
    if self.health <= 0 then
        self.state = "destroyed"
        self:setOffline("Destroyed")
    elseif self.health < self.maxHealth * 0.5 then
        self.state = "damaged"
        self.efficiency = 0.5
    end
    
    -- Recalculate base capacities/services
    base:recalculateCapacities()
end
```

**Estimated time:** 10 hours

---

### Step 9: UI Implementation (18 hours)
**Description:** Grid-based UI for base management, facility construction, transfers  
**Files to create:**
- `engine/basescape/ui/base_grid_view.lua` - Visual grid with facilities
- `engine/basescape/ui/facility_info_panel.lua` - Facility details
- `engine/basescape/ui/construction_panel.lua` - Build new facilities
- `engine/basescape/ui/transfer_panel.lua` - Manage transfers
- `engine/basescape/ui/capacity_panel.lua` - Capacity overview

**BaseGridView (grid-aligned, 24×24 pixel grid):**
```lua
BaseGridView = {
    position = {x = 24*5, y = 24*5},  -- Center of screen
    cellSize = 24*4,  -- 96 pixels per grid cell
    gridSize = 5,     -- 5×5 grid
    
    selectedCell = nil,
    hoveredCell = nil,
}

BaseGridView:draw()
    -- Draw grid outline
    -- Draw facilities
    -- Draw HQ (always center)
    -- Highlight selected/hovered cells
    -- Show construction progress bars
    
BaseGridView:onClick(x, y)
    -- Convert screen coords to grid coords
    -- Select facility or show build menu
```

**ConstructionPanel:**
```lua
ConstructionPanel = {
    position = {x = 24*1, y = 24*10},
    size = {width = 24*8, height = 24*15},
    
    availableFacilities = {},  -- Filtered by tech/prerequisites
    selectedFacilityType = nil,
}

ConstructionPanel:draw()
    -- List available facility types
    -- Show costs, build time, requirements
    -- Show capacity contributions
    -- "Build" button
```

**CapacityPanel:**
```lua
CapacityPanel = {
    position = {x = 24*32, y = 24*1},
    size = {width = 24*8, height = 24*10},
}

CapacityPanel:draw()
    -- Show capacity bars for each type
    -- "25/50 Item Storage"
    -- "10/20 Unit Quarters"
    -- Color-coded: green (OK), yellow (75%+), red (100%)
```

**Estimated time:** 18 hours

---

### Step 10: Data Files (8 hours)
**Description:** Create facility type definitions for core facilities  
**Files to create:**
- `engine/data/facilities.lua` - All facility definitions

**Core Facilities:**
1. **HQ** - Command center (mandatory, cannot destroy, provides power/command services)
2. **Living Quarters** - Unit housing (20 capacity)
3. **Storage** - Item storage (100 capacity)
4. **Hangar** - Craft storage (2 crafts)
5. **Laboratory** - Research capacity (20 points/day)
6. **Workshop** - Manufacturing capacity (50 man-hours/day)
7. **Medical Bay** - Healing throughput (10 HP/day per unit)
8. **Training Room** - Training throughput (5 XP/day per unit)
9. **Prison** - Prisoner capacity (5 prisoners)
10. **Power Generator** - Provides "power" service
11. **Radar Station** - Radar range (500km)
12. **Defense Turret** - Defense capacity, armor, defense units

**Example Definition:**
```lua
facilities = {
    hq = {
        id = "hq",
        name = "Headquarters",
        buildTime = 0,  -- Pre-built
        buildCost = {credits = 0},
        size = {width = 2, height = 2},
        capacities = {
            command_capacity = 1,
            item_storage = 20,
        },
        servicesProvided = {"power", "command"},
        servicesRequired = {},
        maintenanceCost = 10000,
        health = 200,
        armor = 20,
        mapBlock = "facility_hq",
        maxPerBase = 1,
        specialFlags = {"indestructible"},
    },
    
    living_quarters = {
        id = "living_quarters",
        name = "Living Quarters",
        buildTime = 14,
        buildCost = {credits = 100000},
        size = {width = 1, height = 1},
        capacities = {
            unit_quarters = 20,
        },
        servicesProvided = {"housing"},
        servicesRequired = {"power"},
        maintenanceCost = 5000,
        health = 100,
        armor = 5,
        mapBlock = "facility_quarters",
    },
    
    -- ... more facilities
}
```

**Estimated time:** 8 hours

---

### Step 11: Testing & Validation (12 hours)
**Description:** Unit tests, integration tests, manual testing  
**Files to create:**
- `engine/basescape/tests/test_base_grid.lua`
- `engine/basescape/tests/test_construction.lua`
- `engine/basescape/tests/test_capacity.lua`
- `engine/basescape/tests/test_transfers.lua`

**Test Cases:**
1. Base Grid:
   - HQ placement at center
   - Facility placement validation
   - Connectivity checks
   - Cannot remove HQ
   
2. Construction:
   - Build facility with valid tech/resources
   - Cannot build without prerequisites
   - Construction progresses daily
   - Construction completion event
   - Cancel construction (50% refund)
   
3. Capacity:
   - Aggregate capacities from facilities
   - Capacity changes when facility built/destroyed
   - Cannot exceed capacity limits
   - Disconnected facilities don't contribute
   
4. Services:
   - Facilities provide services
   - Facilities require services go offline without them
   - Power grid simulation
   
5. Transfers:
   - Transfer between bases
   - Travel time based on distance/size
   - Items arrive at destination
   - Cancel transfer returns items
   
6. Maintenance:
   - Monthly costs calculated correctly
   - Costs deducted from finance
   
7. Defense:
   - Facility damage reduces health
   - Destroyed facilities lose capacity
   - Defense map generated from facility map blocks

**Manual Testing:**
1. Run game with Love2D console enabled
2. Create new base
3. Build multiple facilities
4. Wait for construction to complete (advance days)
5. Check capacity panel updates
6. Transfer items between bases
7. Trigger base defense mission
8. Damage facilities, verify capacity loss
9. Save/load game, verify state persists

**Estimated time:** 12 hours

---

### Step 12: Documentation (6 hours)
**Description:** Update wiki and API documentation  
**Files to modify:**
- `wiki/API.md` - Facility API, Base Grid API, Capacity API
- `wiki/FAQ.md` - Base management guide
- `wiki/DEVELOPMENT.md` - Basescape system overview

**Documentation Sections:**
1. Facility System Architecture
2. Capacity Management Guide
3. Service System Explanation
4. Construction System Workflow
5. Transfer System Mechanics
6. Base Defense Integration
7. Data Definitions Guide
8. Modding Guide for Custom Facilities

**Estimated time:** 6 hours

---

## Total Time Estimate

**120 hours** (15 days at 8 hours/day)

**Phase Breakdown:**
- Phase 1: Core Data & Logic (10h + 8h + 12h + 10h + 8h = 48h)
- Phase 2: Operations & Integration (6h + 12h + 10h = 28h)
- Phase 3: UI & Polish (18h + 8h = 26h)
- Phase 4: Testing & Docs (12h + 6h = 18h)

---

## Implementation Details

### Architecture

**Layered Architecture:**
```
UI Layer (basescape/ui/)
    ↓
Logic Layer (basescape/logic/)
    ↓
Systems Layer (basescape/systems/)
    ↓
Data Layer (data/facilities.lua)
```

**Key Classes:**
- `FacilityType` - Immutable blueprint
- `Facility` - Instance with state
- `BaseGrid` - 5×5 grid management
- `CapacityManager` - Capacity aggregation
- `ServiceManager` - Service validation
- `ConstructionManager` - Build queue
- `TransferSystem` - Inter-base transfers
- `MaintenanceSystem` - Monthly costs

**Event System:**
```lua
Events:
- "facility_construction_started"
- "facility_construction_completed"
- "facility_destroyed"
- "facility_damaged"
- "capacity_exceeded"
- "service_missing"
- "transfer_started"
- "transfer_completed"
- "maintenance_deducted"
```

### Key Components

**Base Entity:**
```lua
Base = {
    id = "base_alpha",
    name = "Alpha Base",
    provinceId = "province_001",
    
    grid = BaseGrid:new(5),
    capacityManager = CapacityManager:new(),
    serviceManager = ServiceManager:new(),
    constructionQueue = {},
    transfers = {},
    
    -- State
    state = "operational",  -- "constructing", "operational", "damaged"
    foundedDate = 1,        -- Calendar day
}
```

**Facility Lifecycle:**
```
Created → Constructing → Operational → Damaged → Destroyed
                              ↓
                          Offline (missing services)
```

**Capacity Types:**
- **Slots:** Integer-based (unit_quarters, craft_hangars, prisoners)
- **Volume:** Float-based (item_storage in cubic meters)
- **Throughput:** Rate-based (research_points/day, manufacturing_hours/day, healing_hp/day)
- **Boolean:** Service tags (power, medical, training)

### Dependencies

**Required Systems:**
- Calendar System (TASK-025) - Daily build progression
- Finance System - Cost deduction
- Province Graph - Distance calculations for transfers
- MapBlock System - Facility map blocks for defense missions
- Event Bus - Construction/damage events
- Save/Load System - Persist base state

**Integration Points:**
- Inventory System → checks item_storage capacity
- Personnel System → checks unit_quarters capacity
- Research System → checks research_capacity
- Manufacturing System → checks manufacturing_capacity
- Craft System → checks craft_hangar capacity

---

## Testing Strategy

### Unit Tests

**Test File:** `engine/basescape/tests/test_base_grid.lua`
```lua
function test_hq_placement()
    local grid = BaseGrid:new(5)
    assert(grid:getFacilityAt(2, 2).typeId == "hq")
end

function test_facility_placement()
    local grid = BaseGrid:new(5)
    local facility = Facility:new("living_quarters")
    assert(grid:canPlaceFacility(facility, 1, 1) == true)
    grid:placeFacility(facility, 1, 1)
    assert(grid:getFacilityAt(1, 1) == facility)
end

function test_connectivity()
    local grid = BaseGrid:new(5)
    local facility = Facility:new("storage")
    grid:placeFacility(facility, 4, 4)  -- Far from HQ
    grid:updateConnectivity()
    assert(facility.isConnected == false)  -- Not connected
end
```

**Test File:** `engine/basescape/tests/test_capacity.lua`
```lua
function test_capacity_aggregation()
    local base = Base:new("test_base")
    base:addFacility("living_quarters", 1, 1)
    base:addFacility("storage", 1, 2)
    
    base.capacityManager:recalculate()
    assert(base.capacityManager.capacities.unit_quarters == 20)
    assert(base.capacityManager.capacities.item_storage >= 100)
end

function test_capacity_allocation()
    local manager = CapacityManager:new()
    manager.capacities.unit_quarters = 20
    
    assert(manager:canAllocate("unit_quarters", 10) == true)
    manager:allocate("unit_quarters", 10)
    assert(manager:canAllocate("unit_quarters", 15) == false)
end
```

### Integration Tests

**Test File:** `engine/basescape/tests/test_construction_integration.lua`
```lua
function test_construction_with_calendar()
    local base = Base:new("test_base")
    local calendar = Calendar:new()
    
    -- Start construction (14 days)
    local facilityId = base:startConstruction("living_quarters", 1, 1)
    assert(facilityId ~= nil)
    
    -- Advance 14 days
    for i = 1, 14 do
        calendar:advanceDay()
        ConstructionSystem:onDayPassed()
    end
    
    -- Facility should be operational
    local facility = base:getFacility(facilityId)
    assert(facility.state == "operational")
end
```

### Manual Testing Steps

1. **Run game:**
   ```bash
   lovec "engine"
   ```

2. **Create new base:**
   - Navigate to Geoscape
   - Select province
   - Click "Build Base"
   - Verify HQ appears at center (2, 2)

3. **Build facilities:**
   - Select empty grid cell
   - Choose facility type (e.g., Living Quarters)
   - Verify cost deducted
   - Verify construction starts

4. **Advance time:**
   - Advance calendar 14 days
   - Verify construction completes
   - Verify capacity panel updates

5. **Test services:**
   - Remove power generator
   - Verify facilities go offline
   - Verify capacity lost

6. **Test transfers:**
   - Create second base
   - Transfer items between bases
   - Advance time to arrival
   - Verify items appear at destination

7. **Test defense:**
   - Trigger base defense mission
   - Verify map uses facility map blocks
   - Damage facilities
   - Verify health/capacity loss

### Expected Results

- Construction progresses 1 day per calendar advance
- Capacities update when facilities added/removed
- Services validated correctly
- Transfers arrive after calculated time
- Maintenance deducted monthly
- No console errors or warnings
- Save/load preserves all state

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use VS Code task: "Run XCOM Simple Game" (Ctrl+Shift+P > Run Task)

### Debugging
- Love2D console enabled in `conf.lua` (t.console = true)
- Use print statements:
  ```lua
  print("[BaseGrid] Placing facility at (" .. x .. ", " .. y .. ")")
  print("[CapacityManager] Total capacity: " .. total)
  ```
- Check console for:
  - Facility construction events
  - Capacity calculations
  - Service validation warnings
  - Transfer progress

### Temporary Files
- All temp files MUST use: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [x] `wiki/API.md` - Add Facility API, BaseGrid API, CapacityManager API
- [x] `wiki/FAQ.md` - Add base management guide, facility construction guide
- [x] `wiki/DEVELOPMENT.md` - Add basescape system architecture
- [x] Add code comments to all new files

**API Documentation Sections:**
```markdown
## Basescape System

### FacilityType
- Properties: buildTime, buildCost, capacities, services
- Methods: (immutable blueprint)

### Facility
- Properties: state, health, efficiency, isConnected
- Methods: takeDamage(), setOffline(), repair()

### BaseGrid
- Methods: canPlaceFacility(), placeFacility(), removeFacility()

### CapacityManager
- Methods: recalculate(), canAllocate(), allocate()

### ConstructionManager
- Methods: startConstruction(), progressConstruction()

### TransferSystem
- Methods: startTransfer(), completeTransfer()
```

---

## Notes

**Design Decisions:**
1. **5×5 Grid:** Smaller than XCOM's 6×6 for faster gameplay, but still strategic
2. **Mandatory HQ:** Ensures base always has command center, simplifies connectivity
3. **Service System:** Flexible tag-based system for facility dependencies
4. **Daily Build Progression:** Requires calendar system (TASK-025)
5. **Transfer Delays:** Distance-based to add strategic planning layer
6. **Map Blocks:** Facility map blocks for varied base defense missions

**Balancing Considerations:**
- Construction times: 7-28 days typical
- Maintenance costs: 5-10% of build cost per month
- Capacity scaling: Early game tight, late game abundant
- Transfer times: 1-7 days typical within same region

**Future Enhancements:**
- Facility upgrades (Level 1 → Level 2)
- Adjacency bonuses (declared explicitly in data)
- Facility automation (auto-assign personnel)
- Underground/space facilities (special types)
- Facility damage repair system
- Construction rush (pay extra to halve time)

---

## Blockers

**Dependencies:**
- TASK-025 Phase 2 (Calendar System) must be complete for daily construction progression
- Finance System must exist for cost deduction
- Province Graph must exist for transfer distance calculations

**No Hard Blockers:** Can implement facility system with placeholder calendar integration

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] All variables use `local`
- [ ] Proper error handling with `pcall` where needed
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] All UI elements snap to 24×24 grid
- [ ] Tests written and passing (unit + integration)
- [ ] Documentation updated (API.md, FAQ.md)
- [ ] No warnings in Love2D console
- [ ] Save/load functionality verified
- [ ] Performance acceptable (no lag with 10 bases × 25 facilities)
- [ ] Code reviewed by team

---

## Post-Completion

### What Worked Well
- (To be filled after implementation)

### What Could Be Improved
- (To be filled after implementation)

### Lessons Learned
- (To be filled after implementation)
