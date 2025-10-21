# Research System - Technology Tree Management

This folder contains the **global research management system** for the entire campaign. Research is a **Basescape (base management) system**, not a Geoscape (strategic) system, because:

1. Research happens in base facilities (laboratories)
2. Research progress depends on base resources and scientists
3. Research unlocks are tied to base manufacturing capacity
4. Research is managed at the individual base level (though shared globally)

## Folder Structure

```
basescape/research/
├── research_manager.lua      # Global research pool manager
├── research_entry.lua        # Individual research tech definitions
├── research_project.lua      # Active research instance
├── research_system.lua       # Research mechanics system
└── README.md                 # This file
```

## Overview

### research_system.lua
- **Purpose**: Main research system with project management
- **Manages**: Tech tree, prerequisites, scientist allocation
- **Tracks**: Available projects, in-progress research, completed techs
- **Usage**: `local ResearchSystem = require("basescape.research.research_system")`

### research_manager.lua
- **Purpose**: Global research pool coordination
- **Manages**: Cross-base research sharing, global tech tree validation
- **Tracks**: Scientist pool, research priorities
- **Usage**: `local ResearchManager = require("basescape.research.research_manager")`

### research_entry.lua
- **Purpose**: Individual research technology definitions
- **Contains**: Tech ID, name, cost, prerequisites, unlocks
- **Tracks**: Requirements and dependencies
- **Usage**: `local ResearchEntry = require("basescape.research.research_entry")`

### research_project.lua
- **Purpose**: Active research project instance
- **Tracks**: Progress, assigned scientists, completion status
- **Manages**: Pause/resume functionality
- **Usage**: `local ResearchProject = require("basescape.research.research_project")`

## Research Flow

```
1. Research is defined in TOML (mods/core/research.toml)
   ↓
2. Data loaded by core.data_loader
   ↓
3. Research entries available to player
   ↓
4. Player assigns scientists to research project
   ↓
5. ResearchSystem tracks progress per day
   ↓
6. When complete, technology is unlocked
   ↓
7. Unlocks enable: manufacturing, facilities, equipment
```

## Tech Tree Structure

Research technologies form a directed acyclic graph (DAG) of prerequisites:

```
Basic Research
├── Laser Weapons
│   └── Advanced Laser Weapons
│       └── Plasma Weapons
├── Armor (Basic)
│   └── Armor (Advanced)
└── Alien Biology
    ├── Alien Weapons Analysis
    └── Interrogation Techniques
```

## API Examples

```lua
local ResearchSystem = require("basescape.research.research_system")
local research = ResearchSystem.new()

-- Define a research project
local projectDef = {
    id = "laser_weapons",
    name = "Laser Weapons",
    costInManDays = 500,
    prerequisites = {},
    unlocks = {
        manufacturing = {"laser_rifle", "laser_cannon"},
        facilities = {"weapons_lab"}
    }
}
research:defineProject(projectDef.id, projectDef)

-- Start research with N scientists
research:startResearch("laser_weapons", 5)

-- Update progress (hours)
research:updateProgress(24)

-- Check completion
if research:isComplete("laser_weapons") then
    print("Technology unlocked!")
end

-- Get available projects
local available = research:getAvailableProjects()
for _, project in ipairs(available) do
    print(project.name)
end
```

## Scientist Allocation

Each research project can have multiple scientists assigned:

```lua
-- Assign more scientists (increases daily progress)
research:allocateScientists("laser_weapons", 10)

-- Allocation affects cost in scientist-days:
-- 5 scientists = 5 days per project day
-- 10 scientists = 10 days per project day
```

## Unlocks System

When research completes, it can unlock:

1. **Manufacturing**: New items can be produced
2. **Facilities**: New base facilities become available
3. **Equipment**: Items become available for equipment
4. **Abilities**: Units gain new abilities
5. **Research**: Prerequisite research becomes available

Example:
```lua
{
    id = "plasma_weapons",
    unlocks = {
        manufacturing = {"plasma_rifle", "plasma_cannon", "plasma_grenade"},
        facilities = {"plasma_lab"},
        research = {"advanced_plasma_weapons"}
    }
}
```

## Integration Points

- **Basescape**: Research tab shows queue and progress
- **Facilities**: Laboratories provide scientist capacity
- **Manufacturing**: Unlocked techs enable production
- **Geoscape**: Strategic decisions about research priorities
- **Economy**: Research costs in scientist time and lab resources

## See Also

- `wiki/API.md` - Full research API
- `wiki/FAQ.md` - Research mechanics questions
- `mods/core/research.toml` - Research definitions
- `engine/basescape/` - Base management system
