# Migration Guide: Old Pilot System → New Crew System

**Version:** 1.0  
**Date:** 2025-10-28  
**For:** AlienFall v0.1.0+ (Pilot-Craft Redesign)

---

## Overview

This guide explains how to migrate from the old pilot system (deprecated) to the new crew-based pilot system where **pilots are Units with assigned roles**.

**What Changed:**
- ❌ **OLD**: Separate `Pilot` entity with its own properties
- ✅ **NEW**: `Unit` with `pilot_role` assignment and `piloting` stat

---

## For Players (Save Compatibility)

### ⚠️ Save File Compatibility

**Current saves MAY NOT be fully compatible** with the new system.

**Status by Save Version:**

| Save Version | Status | Action Required |
|--------------|--------|-----------------|
| **Pre-redesign** | ⚠️ Partial | Run migration script (see below) |
| **Post-redesign** | ✅ Compatible | No action needed |

### How to Migrate Your Save

**Option 1: Automatic Migration (Recommended)**
```lua
-- Run from game console (if available):
local Migrator = require("tools.migration.pilot_system_migrator")
Migrator.migrateSaveFile("path/to/your/save.json")
```

**Option 2: Manual Migration**

If automatic migration fails:

1. **Backup your save** (copy `saves/your_game.json` to safe location)

2. **Start new campaign** with redesigned system

3. **Sorry**: Old pilot data cannot be easily transferred manually

**What You'll Lose:**
- Old pilot ranks/XP (reset to 0)
- Pilot assignments (need to reassign)

**What You'll Keep:**
- Units/soldiers (converted to new system)
- Crafts (crew array empty, needs pilots assigned)
- Base facilities, items, research

---

## For Modders (Content Migration)

### Old TOML Format → New TOML Format

**OLD `mods/your_mod/pilots.toml`:**
```toml
[pilots.fighter_ace]
type = "FIGHTER"
name = "Fighter Ace"
rank = 2
speed = 10
aim = 12
reaction = 10
```

**NEW `mods/your_mod/rules/unit/classes.toml`:**
```toml
[[unit_classes]]
id = "fighter_pilot"
name = "Fighter Pilot"
type = "soldier"
tier = 3

# Base stats
health = 55
piloting = 10  # NEW: Craft operation skill
dexterity = 9  # OLD: "speed" → NEW: dexterity
accuracy_base = 85  # OLD: "aim" → NEW: accuracy_base
reaction_base = 85  # OLD: "reaction" → NEW: reaction_base
```

**Migration Steps:**

1. **Rename pilot files:**
   ```
   OLD: mods/your_mod/pilots.toml
   NEW: mods/your_mod/rules/unit/pilot_classes.toml
   ```

2. **Convert pilot properties:**
   - `speed` → `dexterity` (NEW stat in unit system)
   - `aim` → `accuracy_base`
   - `reaction` → `reaction_base`
   - Add `piloting` stat (6-12 range, affects craft bonuses)

3. **Update craft definitions:**
   ```toml
   # OLD
   [crafts.interceptor]
   pilots_required = 1
   
   # NEW
   [[craft_types]]
   id = "interceptor"
   required_pilots = 1  # Minimum pilots
   max_crew = 2  # Maximum crew size
   required_pilot_class = "fighter_pilot"  # NEW: Class requirement
   required_pilot_rank = 2  # NEW: Rank requirement
   ```

4. **Remove old pilot rank systems:**
   - Delete `rank_bonuses` tables (ranks now in unit progression)
   - Delete `xp_per_rank` (XP now in `pilot_xp` field)

---

## For Developers (Code Migration)

### API Changes

**OLD API (Deprecated):**
```lua
local PilotProgression = require("basescape.logic.pilot_progression")

-- Create pilot
local pilot = PilotProgression.createPilot("fighter_ace", "Alice")

-- Gain XP
PilotProgression.gainXP(pilotId, 50, "interception")

-- Get rank
local rank = PilotProgression.getRank(pilotId)
```

**NEW API:**
```lua
local PilotManager = require("geoscape.logic.pilot_manager")

-- Create unit (pilot is a unit with role)
local unit = Unit.new("fighter_pilot", "player", 5, 5)

-- Assign to craft
PilotManager.assignToCraft(unit, craft, "pilot")

-- Gain XP (through interception or direct call)
unit:gainPilotXP(50, "interception")

-- Get rank
local rank = unit:getPilotRank()
```

### Entity Property Changes

**OLD Pilot Entity:**
```lua
{
    id = "pilot_001",
    name = "Alice",
    rank = 1,
    xp = 150,
    speed = 10,
    aim = 8,
    assigned_craft = "craft_1"
}
```

**NEW Unit Entity (with pilot role):**
```lua
{
    id = "unit_001",
    name = "Alice",
    classId = "fighter_pilot",
    
    -- Pilot-specific properties
    piloting = 10,  -- NEW: Craft operation skill
    pilot_xp = 150,  -- Separate from ground combat XP
    pilot_rank = 1,  -- Separate from ground combat rank
    pilot_fatigue = 0,
    assigned_craft_id = "craft_1",
    pilot_role = "pilot",  -- "pilot", "co-pilot", "crew"
    
    -- Standard unit properties
    dexterity = 10,  -- OLD: "speed"
    accuracy = 8,  -- OLD: "aim"
    reaction = 9,
}
```

### Craft Property Changes

**OLD Craft Entity:**
```lua
{
    id = "craft_1",
    pilots = {"pilot_001", "pilot_002"},  -- Array of pilot IDs
    experience = 500,  -- Craft XP (REMOVED)
    rank = 2,  -- Craft rank (REMOVED)
}
```

**NEW Craft Entity:**
```lua
{
    id = "craft_1",
    crew = {101, 102},  -- Array of UNIT IDs (not pilot IDs)
    required_pilots = 1,
    max_crew = 4,
    crew_bonuses = {  -- Calculated from crew
        speed_bonus = 8,
        accuracy_bonus = 12,
        dodge_bonus = 8,
        fuel_efficiency = 4,
    },
    -- NO experience or rank (pilots have XP/rank)
}
```

### Function Migrations

| Old Function | New Function | Notes |
|--------------|--------------|-------|
| `PilotProgression.gainXP(pilotId, xp)` | `unit:gainPilotXP(xp, source)` | Now a Unit method |
| `PilotProgression.getRank(pilotId)` | `unit:getPilotRank()` | Unit method |
| `PilotProgression.applyRankBonuses(pilot)` | `unit:calculatePilotBonuses()` | Returns bonus table |
| `Craft.assignPilot(pilot)` | `PilotManager.assignToCraft(unit, craft, role)` | Validates requirements |
| `Craft.getExperience()` | ❌ **REMOVED** | Crafts no longer have XP |
| `Craft.promote()` | ❌ **REMOVED** | Crafts no longer rank up |

---

## Migration Scripts

### Script 1: Convert Old Save File

```lua
-- tools/migration/pilot_system_migrator.lua
local Migrator = {}

function Migrator.migrateSaveFile(savePath)
    local saveData = loadJSON(savePath)
    
    -- 1. Convert pilots → units
    if saveData.pilots then
        saveData.units = saveData.units or {}
        
        for _, pilot in ipairs(saveData.pilots) do
            local unit = {
                id = pilot.id,
                name = pilot.name,
                classId = "pilot",  -- Default class
                piloting = pilot.speed or 8,  -- OLD speed → NEW piloting
                pilot_xp = pilot.xp or 0,
                pilot_rank = pilot.rank or 0,
                assigned_craft_id = pilot.assigned_craft,
                pilot_role = "pilot",  -- Default role
                dexterity = pilot.speed or 8,
                accuracy = pilot.aim or 70,
                reaction = pilot.reaction or 70,
            }
            table.insert(saveData.units, unit)
        end
        
        saveData.pilots = nil  -- Remove old pilots array
    end
    
    -- 2. Update crafts
    if saveData.crafts then
        for _, craft in ipairs(saveData.crafts) do
            -- Convert pilots array → crew array
            craft.crew = craft.pilots or {}
            craft.pilots = nil
            
            -- Remove craft XP/rank
            craft.experience = nil
            craft.rank = nil
            
            -- Add crew properties
            craft.required_pilots = 1
            craft.max_crew = 4
            craft.crew_bonuses = {
                speed_bonus = 0,
                accuracy_bonus = 0,
                dodge_bonus = 0,
                fuel_efficiency = 0,
            }
        end
    end
    
    -- 3. Save migrated file
    saveJSON(savePath .. ".migrated", saveData)
    print("[Migrator] Save file migrated successfully")
    
    return true
end

return Migrator
```

### Script 2: Convert Mod TOML Files

```bash
# tools/migration/convert_pilot_toml.sh
#!/bin/bash

# Convert old pilot TOML to new unit class TOML

OLD_FILE="$1"
NEW_FILE="${OLD_FILE%.toml}_migrated.toml"

echo "Converting $OLD_FILE → $NEW_FILE"

# Simple sed replacement (manual review recommended)
sed -e 's/\[pilots\./[[unit_classes]]\nid = "/' \
    -e 's/type = "FIGHTER"/type = "soldier"/' \
    -e 's/speed =/dexterity =/' \
    -e 's/aim =/accuracy_base =/' \
    -e 's/reaction =/reaction_base =/' \
    "$OLD_FILE" > "$NEW_FILE"

echo "Done! Please review $NEW_FILE manually"
```

---

## Testing After Migration

### Verification Checklist

- [ ] Game starts without errors
- [ ] Units load correctly
- [ ] Crafts have empty crew arrays
- [ ] Can assign pilots to crafts
- [ ] Crew bonuses calculate correctly
- [ ] Interception awards pilot XP
- [ ] Pilots rank up at thresholds
- [ ] No deprecated pilot system warnings

### Test Commands

```lua
-- From game console:
local testUnit = Unit.new("pilot", "player", 5, 5)
print(testUnit:getPilotingStat())  -- Should print 8 or similar

local testCraft = Craft.new({id="test", type="interceptor"})
print(#testCraft.crew)  -- Should print 0

local success = PilotManager.assignToCraft(testUnit, testCraft, "pilot")
print(success)  -- Should print true

print(#testCraft.crew)  -- Should print 1
```

---

## Common Issues & Solutions

### Issue 1: "PilotProgression module not found"
**Solution:** Update requires to use new system:
```lua
-- OLD
local PilotProgression = require("basescape.logic.pilot_progression")

-- NEW
local PilotManager = require("geoscape.logic.pilot_manager")
```

### Issue 2: "Craft.pilots is nil"
**Solution:** Crafts now use `crew` array:
```lua
-- OLD
for _, pilotId in ipairs(craft.pilots) do ... end

-- NEW
for _, unitId in ipairs(craft.crew) do ... end
```

### Issue 3: "Unit missing piloting stat"
**Solution:** Add piloting to unit creation or class definition:
```lua
-- In unit class TOML:
piloting = 8  # Add this field

-- Or in code:
unit.piloting = unit.piloting or 6
```

### Issue 4: "Crew bonuses always zero"
**Solution:** Call recalculation after assigning crew:
```lua
craft:recalculateCrewBonuses()
```

---

## Support

**Questions?** Check:
- [API Documentation](../api/UNITS.md) - Unit pilot functions
- [Design Documentation](../design/mechanics/Units.md) - Pilot mechanics
- [Engine Code](../engine/geoscape/logic/pilot_manager.lua) - Implementation

**Found a bug?** Report in tasks/TODO/

---

**Migration Status:** ✅ Guide Complete  
**Last Updated:** 2025-10-28  
**Compatible With:** AlienFall v0.1.0+

