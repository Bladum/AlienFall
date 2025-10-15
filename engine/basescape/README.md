# Basescape Layer

Base management view where commanders build facilities, manage personnel, conduct research, and manufacture equipment.

## Overview

The Basescape layer provides the base construction and management interface where players:
- Build and upgrade base facilities in a 2D grid
- Hire and manage soldiers, scientists, engineers
- Conduct research to unlock new technologies
- Manufacture weapons, armor, and equipment
- Buy and sell items in the marketplace
- Manage base defenses and power generation
- Repair damaged crafts and heal wounded soldiers

Inspired by X-COM base management with grid-based facility placement.

## Features

### Base Construction
- **2D Grid Layout**: 6×6 or 8×8 grid of facility slots
- **Excavation**: Must dig out tiles before building
- **Facility Types**: Hangars, labs, workshops, living quarters, power plants
- **Adjacency Bonuses**: Some facilities boost neighbors
- **Construction Time**: Buildings take days/weeks to complete
- **Multi-tile Structures**: Hangars span 2×2 tiles

### Personnel Management
- **Soldiers**: Combat troops for missions (skills, equipment, status)
- **Scientists**: Conduct research projects
- **Engineers**: Build items and maintain base
- **Recruitment**: Hire from global pool (limited availability)
- **Salaries**: Monthly upkeep costs
- **Training**: Improve soldier skills over time

### Research & Development
- **Tech Tree**: Unlock technologies by researching
- **Projects**: Each requires scientists and time
- **Autopsy**: Study alien corpses for intel
- **Equipment**: Research captured alien weapons
- **Dependencies**: Some techs require others first

### Manufacturing
- **Production Queue**: Build multiple items simultaneously
- **Resource Cost**: Requires materials and engineer-hours
- **Time**: Items take days to manufacture
- **Batch Production**: Build multiple identical items

### Storage & Inventory
- **General Stores**: Weapons, armor, equipment
- **Alien Containment**: Live alien prisoners
- **Item Limits**: Each base has storage capacity
- **Transfer**: Move items between bases (takes time)

## Architecture

```
basescape/
├── screens/
│   └── basescape_screen.lua    # Main base UI and state
├── facilities/
│   ├── facility_system.lua     # Facility construction logic
│   ├── facility_types.lua      # Facility definitions
│   └── grid_manager.lua        # Grid layout management
├── logic/
│   ├── construction_queue.lua  # Building queue management
│   ├── research_queue.lua      # Research project queue
│   ├── production_queue.lua    # Manufacturing queue
│   └── personnel_manager.lua   # Hiring/firing staff
├── services/
│   ├── research_service.lua    # Research system
│   ├── production_service.lua  # Manufacturing system
│   ├── storage_service.lua     # Inventory management
│   └── marketplace_service.lua # Buy/sell interface
├── ui/
│   ├── base_view.lua           # Isometric/top-down base view
│   ├── facility_menu.lua       # Build facility dialog
│   ├── personnel_panel.lua     # Soldier/staff list
│   ├── research_panel.lua      # Research projects UI
│   ├── production_panel.lua    # Manufacturing UI
│   └── storage_panel.lua       # Inventory UI
├── data/
│   └── base_data.lua           # Base definitions and costs
└── base/
    └── base_entity.lua          # Base data structure
```

## Key Systems

### Facility System (`facilities/facility_system.lua`)

Handles facility construction and management:

```lua
local FacilitySystem = require("basescape.facilities.facility_system")

-- Get facility type definition
local hangar = FacilitySystem.getFacilityType("HANGAR")

-- Start construction
FacilitySystem.startConstruction(base, "HANGAR", gridX, gridY)

-- Check if construction complete
if FacilitySystem.isConstructionComplete(facilityId) then
    FacilitySystem.finishConstruction(facilityId)
end

-- Calculate total power
local power = FacilitySystem.calculateTotalPower(base)
```

### Research Service (`services/research_service.lua`)

Manages research projects:

```lua
local ResearchService = require("basescape.services.research_service")

-- Start research project
ResearchService.startProject(base, "LASER_WEAPONS")

-- Get available projects
local available = ResearchService.getAvailableProjects(base)

-- Update daily progress
ResearchService.updateAllProjects(base)

-- Check if project complete
if ResearchService.isProjectComplete(projectId) then
    ResearchService.completeProject(projectId)
end
```

### Production Service (`services/production_service.lua`)

Handles manufacturing:

```lua
local ProductionService = require("basescape.services.production_service")

-- Start production
ProductionService.startProduction(base, "LASER_RIFLE", quantity)

-- Get production queue
local queue = ProductionService.getProductionQueue(base)

-- Update daily progress
ProductionService.updateProduction(base)

-- Cancel production
ProductionService.cancelProduction(base, itemId)
```

### Personnel Manager (`logic/personnel_manager.lua`)

Manages staff:

```lua
local PersonnelManager = require("basescape.logic.personnel_manager")

-- Hire soldier
local soldier = PersonnelManager.hireSoldier(base)

-- Hire scientists
PersonnelManager.hireScientists(base, count)

-- Fire engineer
PersonnelManager.fireEngineer(base, engineerId)

-- Get available soldiers
local soldiers = PersonnelManager.getAvailableSoldiers(base)

-- Get monthly salaries
local cost = PersonnelManager.getMonthlyPayroll(base)
```

## Data Flow

### Facility Construction

1. Player selects facility type from menu
2. Clicks empty/excavated grid tile
3. **Construction Queue** adds entry (cost, time, location)
4. **Daily Update** progresses construction (engineers help)
5. When complete, facility becomes operational
6. Facility provides bonuses (power, capacity, etc.)

### Research Flow

1. Player selects available research project
2. **Research Queue** allocates scientists
3. **Daily Update** adds progress (based on scientist count)
4. When complete, technology unlocked
5. New projects/items become available

### Production Flow

1. Player selects item to manufacture
2. Checks materials available in storage
3. **Production Queue** deducts materials, starts production
4. **Daily Update** progresses (based on engineer count)
5. When complete, item added to storage

## Usage Examples

### Creating a Base

```lua
local Base = require("basescape.base.base_entity")

-- Create new base
local base = Base.new({
    id = "BASE_01",
    name = "Main Base",
    location = {province = "NORTH_AMERICA_1"},
    gridSize = {width = 6, height = 6}
})

-- Start with basic facilities
FacilitySystem.addFacility(base, "ACCESS_LIFT", 2, 2) -- Center
FacilitySystem.addFacility(base, "POWER_GENERATOR", 1, 1)
FacilitySystem.addFacility(base, "LIVING_QUARTERS", 3, 1)
```

### Building a Facility

```lua
-- Check if player can afford
local hangarType = FacilitySystem.getFacilityType("HANGAR")
if economy:canAfford(hangarType.cost) then
    -- Check if tile available
    if FacilitySystem.canBuildAt(base, "HANGAR", 0, 0) then
        -- Start construction
        economy:deduct(hangarType.cost)
        FacilitySystem.startConstruction(base, "HANGAR", 0, 0)
        
        print("Hangar construction started - " .. hangarType.buildTime .. " days")
    end
end
```

### Starting Research

```lua
local ResearchService = require("basescape.services.research_service")

-- Get available projects
local projects = ResearchService.getAvailableProjects(base)

-- Start laser weapons research
if projects["LASER_WEAPONS"] then
    local project = projects["LASER_WEAPONS"]
    
    -- Check requirements
    if base.scientists >= project.scientistsRequired then
        ResearchService.startProject(base, "LASER_WEAPONS")
        print("Research started: " .. project.name)
        print("ETA: " .. project.timeRequired .. " days")
    else
        print("Need " .. project.scientistsRequired .. " scientists")
    end
end
```

### Manufacturing Items

```lua
local ProductionService = require("basescape.services.production_service")

-- Check materials
if hasItemInStorage(base, "ALIEN_ALLOYS", 10) then
    -- Start production
    ProductionService.startProduction(base, "PLASMA_RIFLE", 5)
    
    -- Materials deducted automatically
    print("Manufacturing 5 Plasma Rifles")
end
```

### Hiring Personnel

```lua
local PersonnelManager = require("basescape.logic.personnel_manager")

-- Hire 10 scientists
local cost = PersonnelManager.getScientistSalary() * 10
if economy:canAfford(cost) then
    economy:deduct(cost)
    PersonnelManager.hireScientists(base, 10)
    print("Hired 10 scientists")
end

-- Hire soldier for mission
local soldier = PersonnelManager.hireSoldier(base)
if soldier then
    addToSquad(soldier)
end
```

## Integration Points

### → Geoscape
- Click on base icon in geoscape to enter basescape
- Base provides radar coverage
- Crafts launch from base hangars

### → Battlescape
- Soldier roster comes from base personnel
- Equipment loaded from base storage
- Wounded soldiers return to base for recovery

### → Economy
- Facility construction costs money
- Monthly salaries for personnel
- Research/manufacturing consumes resources
- Marketplace for buying/selling

## Testing

Tests located in `tests/basescape/`:
- `test_facility_system.lua` - Facility construction
- `test_research_service.lua` - Research progression
- `test_production_service.lua` - Manufacturing
- `test_personnel_manager.lua` - Hiring/firing

Run with:
```bash
lovec tests/runners/run_basescape_test.lua
```

## Debug Commands

Press `~` to open console:
```lua
-- Complete construction instantly
finishConstruction()

-- Complete research instantly
finishResearch()

-- Add money
addMoney(1000000)

-- Add materials
addItem("ALIEN_ALLOYS", 100)

-- Hire staff instantly
addScientists(50)
addEngineers(50)

-- List all facilities
listFacilities()
```

## Performance Notes

- Base grid rendering is efficient (simple 2D)
- Research/production updates only daily, not per-frame
- Storage lookups use hash tables (fast)
- Facility bonus calculations cached

## Common Issues

**Issue**: Can't build facility (grayed out)  
**Solution**: Check prerequisites (e.g., need power first), check space available

**Issue**: Research not progressing  
**Solution**: Ensure scientists allocated to project, check if base has lab

**Issue**: Production stuck at 0%  
**Solution**: Check if engineers available, verify materials in storage

**Issue**: Soldiers not available for mission  
**Solution**: Check if wounded, if assigned to craft, if in recovery

## Facility Types Reference

### Essential Facilities
- **Access Lift**: Entry point (required, pre-built)
- **Power Generator**: Provides power (+50 power)
- **Living Quarters**: Houses personnel (50 capacity)

### Production Facilities
- **Laboratory**: Research projects (50 scientist capacity)
- **Workshop**: Manufacturing (50 engineer capacity)

### Military Facilities
- **Hangar**: Stores craft (1-2 crafts depending on size)
- **Alien Containment**: Holds live aliens (10 capacity)
- **Defense Station**: Protects base from attacks

### Storage Facilities
- **General Stores**: Stores items (50 item capacity)
- **Elerium Storage**: Stores alien fuel (special)

### Advanced Facilities
- **Psi Lab**: Psionic training
- **Hyper-Wave Decoder**: Advanced detection
- **Grav Shield**: Ultimate defense

## See Also

- [Geoscape Layer](../geoscape/README.md) - World map
- [Battlescape Layer](../battlescape/README.md) - Tactical combat
- [Economy System](../economy/README.md) - Finances and trading
- [Research Guide](../../wiki/RESEARCH_TREE.md)
- [Facility Reference](../../wiki/FACILITIES.md)
- [API Documentation](../../wiki/API.md#basescape)
