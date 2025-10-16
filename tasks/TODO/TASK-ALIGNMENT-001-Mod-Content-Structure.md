# Task: Create Comprehensive Mod Content Structure

**Status:** TODO  
**Priority:** CRITICAL  
**Created:** October 16, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent / Development Team

---

## Overview

Create complete mod content directory structure with TOML template files for all game systems. This establishes the foundation for content configuration, enabling the game to load units, weapons, facilities, campaigns, and other content from mod files rather than hardcoded data.

---

## Purpose

**Current Problem:**
- `mods/core/` has minimal structure (only tilesets, mapblocks, mapscripts)
- No content definitions for units, weapons, armors, facilities, missions, campaigns, factions
- Engine has loaders but no content to load
- Cannot create playable game without content

**Solution:**
Create comprehensive TOML-based content structure following OpenXCOM mod format principles, adapted for AlienFall's design.

---

## Requirements

### Functional Requirements
- [ ] Create all missing mod content directories
- [ ] Provide template TOML files for each content type
- [ ] Include example data in templates
- [ ] Follow consistent naming conventions
- [ ] Match design documented in `docs/` folder

### Technical Requirements
- [ ] TOML format compatible with `engine/core/data_loader.lua`
- [ ] File structure compatible with `engine/mods/mod_manager.lua`
- [ ] Schema compatible with game engine expectations
- [ ] Loadable through `ModManager.getContentPath()`
- [ ] Validated against existing code

### Acceptance Criteria
- [ ] All content directories exist with README files
- [ ] At least one example TOML file per content type
- [ ] Templates include comments explaining each field
- [ ] Structure documented in `mods/core/README.md`
- [ ] Compatible with existing ModManager and DataLoader

---

## Plan

### Step 1: Create Directory Structure (2 hours)
**Description:** Create all missing directories in `mods/core/`  
**Directories to create:**
```
mods/core/
├── rules/
│   ├── units/
│   ├── items/
│   ├── facilities/
│   └── missions/
├── campaigns/
├── factions/
├── technology/
├── narrative/
├── geoscape/
└── economy/
```

**Files to create:**
- `mods/core/README.md` - Updated structure documentation
- `mods/core/rules/README.md` - Rules directory overview
- `mods/core/campaigns/README.md` - Campaign structure
- `mods/core/factions/README.md` - Faction system overview

**Estimated time:** 2 hours

### Step 2: Create Unit Content Templates (4 hours)
**Description:** Create TOML templates for soldier, alien, and civilian units  
**Files to create:**
- `mods/core/rules/units/soldiers.toml` - Human soldier types
- `mods/core/rules/units/aliens.toml` - Alien unit types
- `mods/core/rules/units/civilians.toml` - Civilian types

**Template structure:**
```toml
# soldiers.toml example
[[unit]]
id = "soldier_rookie"
name = "Rookie Soldier"
type = "soldier"
image = "units/soldier.png"

[unit.stats]
health = 30
time_units = 50
stamina = 40
reactions = 30
firing_accuracy = 50
throwing_accuracy = 50
strength = 20
psionic_strength = 20
psionic_skill = 0

[unit.armor]
default = "personal_armor"

[unit.inventory]
slots = ["right_hand", "left_hand", "belt", "back_pack"]
```

**Estimated time:** 4 hours

### Step 3: Create Item Content Templates (4 hours)
**Description:** Create TOML templates for weapons, armors, equipment  
**Files to create:**
- `mods/core/rules/items/weapons.toml`
- `mods/core/rules/items/armors.toml`
- `mods/core/rules/items/equipment.toml`

**Template structure:**
```toml
# weapons.toml example
[[weapon]]
id = "rifle_conventional"
name = "Conventional Rifle"
type = "firearm"
image = "items/rifle.png"

[weapon.stats]
damage = 30
accuracy = 60
range = 20
ammo_capacity = 30
fire_modes = ["snap", "auto", "aimed"]

[weapon.costs]
time_units = { snap = 20, auto = 35, aimed = 60 }
accuracy_modifier = { snap = 0, auto = -20, aimed = 20 }
```

**Estimated time:** 4 hours

### Step 4: Create Facility Templates (3 hours)
**Description:** Base facility definitions  
**Files to create:**
- `mods/core/rules/facilities/base_facilities.toml`

**Template includes:**
- Living quarters
- Research labs
- Manufacturing workshops
- Storage areas
- Hangars
- Defense systems

**Estimated time:** 3 hours

### Step 5: Create Mission Templates (3 hours)
**Description:** Mission type definitions  
**Files to create:**
- `mods/core/rules/missions/mission_types.toml`

**Mission types:**
- UFO crash site
- UFO landing site
- Terror mission
- Base defense
- Alien base assault

**Estimated time:** 3 hours

### Step 6: Create Campaign Templates (4 hours)
**Description:** Campaign phase definitions  
**Files to create:**
- `mods/core/campaigns/phase0_shadow_war.toml`
- `mods/core/campaigns/phase1_sky_war.toml`
- `mods/core/campaigns/phase2_deep_war.toml`
- `mods/core/campaigns/phase3_dimensional_war.toml`
- `mods/core/campaigns/campaign_timeline.toml`

**Template structure:**
```toml
# phase0_shadow_war.toml
[campaign]
id = "phase0"
name = "Shadow War"
start_date = "1996-01-01"
end_date = "1999-12-31"

[campaign.progression]
starting_funds = 1000000
difficulty_curve = "gradual"

[[campaign.milestones]]
id = "first_contact"
trigger = "mission_complete:ufo_crash_01"
```

**Estimated time:** 4 hours

### Step 7: Create Faction Templates (5 hours)
**Description:** Alien and human faction definitions  
**Files to create:**
- `mods/core/factions/sectoids.toml`
- `mods/core/factions/mutons.toml`
- `mods/core/factions/ethereals.toml`
- `mods/core/factions/snakemen.toml`
- `mods/core/factions/floaters.toml`
- (10+ more faction files)

**Template structure:**
```toml
[faction]
id = "sectoids"
name = "Sectoid Alliance"
type = "alien"
threat_level = 1

[faction.units]
soldiers = ["sectoid_soldier", "sectoid_leader"]
commanders = ["sectoid_commander"]

[faction.technology]
weapons = ["plasma_pistol", "plasma_rifle"]
```

**Estimated time:** 5 hours

### Step 8: Create Technology Templates (4 hours)
**Description:** Research tree and technology progression  
**Files to create:**
- `mods/core/technology/research_tree.toml`
- `mods/core/technology/phase0_tech.toml`
- `mods/core/technology/phase1_tech.toml`
- `mods/core/technology/phase2_tech.toml`
- `mods/core/technology/phase3_tech.toml`

**Estimated time:** 4 hours

### Step 9: Create Geoscape Templates (3 hours)
**Description:** Countries, regions, funding  
**Files to create:**
- `mods/core/geoscape/countries.toml`
- `mods/core/geoscape/regions.toml`
- `mods/core/geoscape/funding.toml`

**Estimated time:** 3 hours

### Step 10: Documentation and Validation (3 hours)
**Description:** Document structure and validate files  
**Tasks:**
- Update `mods/core/README.md` with complete structure
- Add comments to all TOML files
- Validate TOML syntax
- Create quick reference guide

**Files to update:**
- `mods/core/README.md`
- `docs/mods/system.md` - Update with actual structure

**Estimated time:** 3 hours

---

## Implementation Details

### Directory Structure
```
mods/core/
├── mod.toml                            # Existing
├── README.md                           # UPDATE
├── mapblocks/                          # Existing
├── mapscripts/                         # Existing
├── tilesets/                           # Existing
├── rules/                              # NEW
│   ├── README.md                       # NEW
│   ├── battle/
│   │   └── terrain.toml                # Existing (referenced in code)
│   ├── units/                          # NEW
│   │   ├── soldiers.toml               # NEW
│   │   ├── aliens.toml                 # NEW
│   │   └── civilians.toml              # NEW
│   ├── items/                          # NEW
│   │   ├── weapons.toml                # NEW
│   │   ├── armors.toml                 # NEW
│   │   └── equipment.toml              # NEW
│   ├── facilities/                     # NEW
│   │   └── base_facilities.toml        # NEW
│   └── missions/                       # NEW
│       └── mission_types.toml          # NEW
├── campaigns/                          # NEW
│   ├── README.md                       # NEW
│   ├── phase0_shadow_war.toml          # NEW
│   ├── phase1_sky_war.toml             # NEW
│   ├── phase2_deep_war.toml            # NEW
│   ├── phase3_dimensional_war.toml     # NEW
│   └── campaign_timeline.toml          # NEW
├── factions/                           # NEW
│   ├── README.md                       # NEW
│   ├── sectoids.toml                   # NEW
│   ├── mutons.toml                     # NEW
│   ├── ethereals.toml                  # NEW
│   └── [10+ more faction files]        # NEW
├── technology/                         # NEW
│   ├── README.md                       # NEW
│   ├── research_tree.toml              # NEW
│   └── phase[0-3]_tech.toml            # NEW (4 files)
├── narrative/                          # NEW
│   ├── README.md                       # NEW
│   └── story_events.toml               # NEW
├── geoscape/                           # NEW
│   ├── README.md                       # NEW
│   ├── countries.toml                  # NEW
│   ├── regions.toml                    # NEW
│   └── funding.toml                    # NEW
└── economy/                            # NEW
    ├── README.md                       # NEW
    └── marketplace.toml                # NEW
```

### Key Components
- **TOML Templates:** All files include example data and comments
- **README Files:** Each directory explains its purpose and structure
- **Naming Conventions:** Consistent snake_case for IDs, kebab-case for files
- **Validation:** All TOML files syntactically valid

### Dependencies
- `engine/mods/mod_manager.lua` - Must support new content paths
- `engine/core/data_loader.lua` - Will need new loader functions (TASK-ALIGNMENT-002)
- `docs/mods/system.md` - Design reference
- `.github/instructions/🔌 API & Modding.instructions.md` - Guidelines

---

## Testing Strategy

### Manual Testing Steps
1. Create directory structure
2. Add one TOML template file
3. Validate TOML syntax: `lua -e "require('utils.toml').load('file.toml')"`
4. Verify ModManager can resolve paths
5. Check file readability

### Validation Tests
```lua
-- Test in Love2D console
ModManager.init()
ModManager.setActiveMod("core")

-- Test path resolution
local unitsPath = ModManager.getContentPath("rules", "units/soldiers.toml")
print(unitsPath)  -- Should return valid path

-- Validate TOML
local TOML = require("utils.toml")
local data = TOML.load(unitsPath)
print(data)  -- Should parse without errors
```

### Expected Results
- All directories created successfully
- All TOML files parse without syntax errors
- ModManager can resolve all content paths
- Files contain example data with comments

---

## How to Run/Debug

1. **Create directories:**
   ```powershell
   cd c:\Users\tombl\Documents\Projects\mods\core
   mkdir rules\units, rules\items, rules\facilities, rules\missions
   mkdir campaigns, factions, technology, narrative, geoscape, economy
   ```

2. **Create template file:**
   ```powershell
   # Example: Create soldiers.toml
   New-Item -Path "rules\units\soldiers.toml" -ItemType File
   ```

3. **Add content to file:**
   - Follow TOML template structure shown in Step 2
   - Add comments explaining each field
   - Include at least one complete example

4. **Validate TOML syntax:**
   ```bash
   lovec "engine" -e "local TOML = require('utils.toml'); print(TOML.load('mods/core/rules/units/soldiers.toml'))"
   ```

5. **Test path resolution:**
   - Run game with Love2D console enabled
   - In Lua console:
     ```lua
     local path = ModManager.getContentPath("rules", "units/soldiers.toml")
     print("Path:", path)
     ```

---

## Documentation Updates

### Files to Update
- `mods/core/README.md` - Add complete structure documentation
- `docs/mods/system.md` - Update with actual implementation details
- `tasks/tasks.md` - Mark task complete, add completion notes

### Content to Add
1. **Directory structure diagram** (in mods/core/README.md)
2. **File naming conventions** (in mods/core/README.md)
3. **TOML template usage guide** (in docs/mods/system.md)
4. **Content path resolution examples** (in docs/mods/system.md)

---

## Review Checklist

- [ ] All directories created with correct names
- [ ] README.md exists in each major directory
- [ ] At least one template TOML file per content type
- [ ] All TOML files syntactically valid
- [ ] Comments explain purpose of each field
- [ ] Example data included in templates
- [ ] ModManager can resolve all paths
- [ ] Documentation updated
- [ ] No console errors when loading files
- [ ] Consistent naming conventions used

---

## Notes

**Design References:**
- `docs/content/units/` - Unit design specs
- `docs/content/equipment/` - Weapon and armor specs
- `docs/basescape/facilities/` - Facility design
- `docs/lore/narrative.md` - Campaign and narrative design
- `engine/lore/lore_ideas.md` - Detailed content ideas

**Integration Points:**
- This task provides TOML files
- TASK-ALIGNMENT-002 will implement loaders to read these files
- TASK-ALIGNMENT-003 will document TOML schemas
- TASK-ALIGNMENT-005 will add validation

**Content Priority:**
1. Units, weapons, armors (immediate gameplay)
2. Campaigns and missions (strategic depth)
3. Factions and technology (progression)
4. Narrative and economy (polish)

---

## What Worked Well
(To be filled in after completion)

---

## Lessons Learned
(To be filled in after completion)

---

## Follow-up Tasks
- TASK-ALIGNMENT-002: Implement Missing DataLoader Functions
- TASK-ALIGNMENT-003: Define TOML Schemas
- TASK-LORE-001: Populate campaign content
- TASK-LORE-002: Populate faction content
