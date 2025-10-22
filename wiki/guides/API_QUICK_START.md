# API Quick-Start Guide

**Version:** 1.0  
**Date:** October 21, 2025  
**Audience:** Developers new to AlienFall API

---

## 5-Minute Overview

The AlienFall API documentation covers 19 game systems organized in logical layers:

### Strategic Layer (3 systems)
- **Politics** - Nations, diplomacy, funding
- **Geoscape** - World map, regions, UFO tracking
- **Interception** - Air combat mechanics

### Operational Layer (4 systems)
- **Basescape** - Base management and operations
- **Facilities** - Facility definitions and bonuses
- **Research & Manufacturing** - Tech trees and production
- **Economy** - Items, marketplace, finance

### Tactical Layer (4 systems)
- **Missions** - Mission types and deployment
- **Battlescape** - Turn-based tactical combat
- **Crafts** - Aircraft and air operations
- **Units & Classes** - Character definitions

### Meta Systems (4 systems)
- **AI Systems** - AI behaviors and pathfinding
- **Analytics** - Metrics and tracking
- **Assets** - Item and equipment management
- **Mods** - Modding support and extensions
- **Integration** - Event system and communication
- **Weapons & Armor** - Combat equipment
- **Schema Reference** - TOML definitions

---

## Getting Started: 3 Steps

### Step 1: Find Your System
Start with the API file matching your interest:
- Want to add items? → `API_ECONOMY_AND_ITEMS.md`
- Want to create missions? → `API_MISSIONS.md`
- Want to manage bases? → `API_BASESCAPE_EXTENDED.md`
- Want to understand architecture? → Start with `API_SCHEMA_REFERENCE.md`

### Step 2: Read the Overview and Architecture
Each API file starts with:
1. **Overview** - 2-3 minute read on what this system does
2. **Architecture** - Visual diagram showing how it works
3. **Core Entities** - The main data structures you'll use

### Step 3: Review Integration Examples
Each API includes 5 realistic code examples showing:
- How to load data
- How to create instances
- How to update state
- How to track progress
- How to complete operations

---

## Common Tasks

### Load Game Data
```lua
local DataLoader = require("engine.core.data_loader")

-- Get specific item
local item = DataLoader.item.get("item_medikit")

-- Get all items
local items = DataLoader.item.getAllIds()

-- Get items by category
local weapons = DataLoader.item.getByCategory("weapons")
```

### Create Game Instances
```lua
-- Create a research project
local Research = require("engine.basescape.research")
local project = Research.create("tech_plasma_rifle", base)

-- Create a manufacturing project
local Manufacturing = require("engine.basescape.manufacturing")
local production = Manufacturing.createProduct("recipe_rifle", 5, base)

-- Create a mission
local Mission = require("engine.geoscape.mission")
local mission = Mission.create(template, difficulty)
```

### Update Game State
```lua
-- Update research progress
Research.updateProgress(project, 3, 1.2)  -- 3 scientists, 20% bonus

-- Update production progress
Manufacturing.updateProgress(production, 2)  -- 2 engineers

-- Update mission objectives
Mission.checkCompletion(objective, mission)
```

### Calculate Results
```lua
-- Calculate budget
local Budget = require("engine.economy.budget")
local budget = Budget.calculate(base)

-- Get interception outcome
local Interception = require("engine.geoscape.interception")
local outcome = Interception.getOutcome(battle)

-- Calculate facility efficiency
local Facility = require("engine.basescape.facility")
local efficiency = Facility.getEfficiency(facility, specialization)
```

---

## Where to Go From Here

### For Modders
→ See `MOD_DEVELOPER_GUIDE.md` for complete modding tutorial

### For System Integration
→ Read `API_INTEGRATION.md` for event system and communication

### For Understanding Game Design
→ Read `wiki/FAQ.md` for game mechanics overview

### For Reference
→ See `API_SCHEMA_REFERENCE.md` for TOML definitions

---

## API Navigation Map

```
Entry Point: API_SCHEMA_REFERENCE.md (understand data format)
      ↓
Choose Your Layer:
├─ Strategic: API_POLITICS.md → API_GEOSCAPE_EXTENDED.md → API_INTERCEPTION.md
├─ Operational: API_BASESCAPE_EXTENDED.md → API_FACILITIES.md → API_RESEARCH_AND_MANUFACTURING.md
├─ Tactical: API_MISSIONS.md → API_BATTLESCAPE_EXTENDED.md → API_CRAFTS.md
└─ Meta: API_INTEGRATION.md → API_ANALYTICS.md → API_MODS.md
      ↓
Deep Dive: Read full API file with all examples
      ↓
Implement: Use examples as templates for your code
```

---

## Quick Reference

| Task | API File | Function |
|------|----------|----------|
| Get item data | API_ECONOMY_AND_ITEMS.md | `DataLoader.item.get()` |
| Create mission | API_MISSIONS.md | `Mission.create()` |
| Start research | API_RESEARCH_AND_MANUFACTURING.md | `Research.create()` |
| Manage base | API_BASESCAPE_EXTENDED.md | `Base.updateStatus()` |
| Deploy squad | API_GEOSCAPE_EXTENDED.md | `Mission.deploySquad()` |
| Initiate intercept | API_INTERCEPTION.md | `Interception.begin()` |
| Calculate budget | API_ECONOMY_AND_ITEMS.md | `Budget.calculate()` |
| Check relations | API_POLITICS.md | `Nation.getReputation()` |

---

## Key Concepts

### Data Loading Pattern
1. Load data using `DataLoader`
2. Cache results in memory
3. Reference by ID when needed
4. Never reload same data twice

### State Management Pattern
1. Create instance from template
2. Modify instance properties
3. Call update functions
4. Query results

### Performance Pattern
1. Load/parse once at startup
2. Update once per turn
3. Cache calculations
4. Use indexed lookups

---

## Common Errors and Solutions

**Error: "Function not found"**
- Check if you're requiring the correct module
- Verify function name matches API documentation
- Check parameters match expected types

**Error: "Table is nil"**
- Ensure you've loaded data via DataLoader first
- Verify ID you're using actually exists
- Check data load path and error messages

**Error: Slow performance**
- Don't reload data every frame
- Cache function results
- Use batching for updates
- See "Performance Considerations" in API files

---

## Next Steps

1. Read the **Overview** of your target API
2. Study the **Architecture** diagram
3. Copy one of the **Integration Examples**
4. Modify for your use case
5. Test in Love2D with console enabled
6. Iterate and refine

---

**Happy coding!** 🚀

For questions, see the full API documentation or FAQ.
