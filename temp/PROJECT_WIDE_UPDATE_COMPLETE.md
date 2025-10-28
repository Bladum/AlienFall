# Project-Wide Pilot System Update Complete

**Date**: 2025-10-28  
**Status**: ✅ ALL FILES UPDATED

---

## Files Updated Across Project

### 📁 Design Files (design/mechanics/)
- ✅ **Pilots.md** - NEW simple system specification
- ✅ **Units.md** - Added Piloting stat, removed complex pilot class
- ✅ **Crafts.md** - Simplified pilot requirements
- ✅ **README.md** - Updated references
- ❌ **PilotSystem_Technical.md** - DELETED (old complex system)

### 📁 API Files (api/)
- ✅ **PILOTS.md** - Updated deprecation notice with new simple system
- ✅ **UNITS.md** - Removed dual XP tracking, simplified to single piloting stat
- ✅ **CRAFTS.md** - Replaced complex pilot bonuses with simple formula
- ✅ **GAME_API.toml** - Updated unit fields, removed obsolete pilot fields

### 📁 File Renames (Shorter Names)
- `DiplomaticRelations_Technical.md` → **Relations.md**
- `hex_vertical_axial_system.md` → **HexSystem.md**
- `FutureOpportunities.md` → **Future.md**
- `ai_systems.md` → **AI.md**

---

## Changes Summary by File

### Design Files

#### `design/mechanics/Pilots.md` (NEW)
**Created**: Complete simple system specification

**Key Content**:
- Piloting is a stat (0-100)
- Any unit can pilot
- One unified XP pool
- Only pilot provides bonuses (crew = cargo)
- Bonus formula: Dodge/Accuracy = +(Piloting/5)%

#### `design/mechanics/Units.md`
**Removed**:
- Complex Pilot Class Branch (Fighter Pilot, Bomber Pilot, etc.)
- Dual XP tracking (pilot_xp separate from ground XP)
- Pilot class progression trees

**Added**:
- Piloting Stat section (under Movement & Awareness stats)
- Range: 0-100 (not 6-12 like other stats)
- Improved by: +1 per 100 XP, class bonuses, traits, equipment

#### `design/mechanics/Crafts.md`
**Removed**:
- Pilot class requirements
- Multi-crew pilot bonuses
- Pilot rank requirements per craft type

**Added**:
- Simple: Each craft needs 1 pilot
- Any unit can pilot any craft
- Higher Piloting stat = better performance

---

### API Files

#### `api/PILOTS.md`
**Status**: ⛔ DEPRECATED

**Updated Deprecation Notice**:
```
OLD: Separate Pilot class with branches
NEW: Piloting is a unit stat (0-100)

Formula:
Craft Dodge = Base + (Pilot Piloting / 5)%
Craft Accuracy = Base + (Pilot Piloting / 5)%
```

#### `api/UNITS.md`
**Removed Fields**:
```lua
pilot_role = string | nil      -- REMOVED
pilot_xp = number              -- REMOVED (use unified xp)
pilot_rank = number            -- REMOVED (use unit rank)
pilot_fatigue = number         -- REMOVED
total_interceptions = number   -- REMOVED
craft_kills = number           -- REMOVED
```

**Simplified To**:
```lua
piloting = number              -- 0-100 (craft operation skill)
assigned_craft_id = string | nil  -- Craft ID if currently piloting
```

#### `api/CRAFTS.md`
**Replaced Section**: "Pilot Skill Effects"

**OLD (Complex)**:
- Stat-based bonuses from multiple pilot stats
- Multi-pilot stacking with diminishing returns
- Pilot rank system (Rookie/Veteran/Ace)
- Crew bonuses (co-pilots, gunners)

**NEW (Simple)**:
```lua
-- Only pilot matters
local pilot = craft:getPilot()
if pilot then
  craft.dodge_bonus = pilot.piloting / 5
  craft.accuracy_bonus = pilot.piloting / 5
end

-- Crew ignored (no bonuses)
```

#### `api/GAME_API.toml`
**Updated Fields**:
```toml
# Unit fields
unit_type = ["soldier", "alien", "civilian"]  # "pilot" removed
piloting = { type = "integer", min = 0, max = 100 }  # Changed from 6-12 to 0-100
assigned_craft_id = { type = "string" }  # Simplified

# Removed obsolete fields:
# pilot_role
# pilot_xp
# pilot_rank
# pilot_fatigue

# Craft fields
required_pilots = { min = 1, max = 1, default = 1 }  # Always 1
max_crew = { min = 0, max = 20 }  # Passengers only

# Removed obsolete fields:
# required_pilot_class
# required_pilot_rank
```

---

## System Comparison

### OLD System (Complex) ❌

**Pilot Classes**:
- Rank 1: Pilot (Basic)
- Rank 2: Fighter Pilot, Bomber Pilot, Transport Pilot, Naval Pilot, Helicopter Pilot
- Rank 3: Ace Fighter, Strategic Bomber, Assault Transport, Fleet Commander, Tactical Assault

**Dual XP Tracking**:
- Pilot XP (from interceptions)
- Ground XP (from battlescape missions)
- Separate progression tracks

**Crew Bonuses**:
- Co-pilot: 75% of pilot bonuses
- Gunner: 50% of pilot bonuses
- Navigator: Radar bonus
- Multi-pilot stacking with diminishing returns

**Requirements**:
- Minimum pilot rank per craft type
- Specific pilot class required per craft
- Cross-training system to switch branches

### NEW System (Simple) ✅

**No Pilot Classes**:
- Any unit can pilot
- Piloting is just a stat (0-100)

**Unified XP**:
- One XP pool for everything
- XP from interception OR ground combat contributes equally
- +1 Piloting per 100 XP gained

**No Crew Bonuses**:
- Only pilot provides bonuses
- Crew = passengers = cargo (zero bonuses)

**No Requirements**:
- Any unit can pilot any craft
- Higher Piloting stat = better performance
- No minimums

---

## Implementation Guide

### For Modders

**Old TOML** (obsolete):
```toml
[[units]]
id = "fighter_pilot"
name = "Fighter Pilot"
class = "pilot"
pilot_branch = "fighter"
pilot_rank = 2
...
```

**New TOML** (correct):
```toml
[[units]]
id = "scout_soldier"
name = "Scout"
class = "scout"
piloting = 50  # 0-100, higher is better
# Any unit can pilot, no special pilot class needed
```

### For Engine Developers

**Old Code** (obsolete):
```lua
local pilot = unit:getPilotClass()
if pilot == "fighter_pilot" and pilot.rank >= 2 then
  craft:assignPilot(unit)
end
```

**New Code** (correct):
```lua
-- Any unit can pilot
craft:assignPilot(unit)

-- Calculate bonuses from piloting stat
local piloting = unit.piloting or 0
craft.dodge_bonus = piloting / 5
craft.accuracy_bonus = piloting / 5
```

### For Test Writers

**Update Tests**:
1. Remove pilot class tests
2. Remove dual XP tracking tests
3. Add piloting stat improvement tests
4. Add simple bonus calculation tests

**Example New Test**:
```lua
function test_piloting_bonuses()
  local unit = Unit.new({piloting = 60})
  local craft = Craft.new({})
  
  craft:assignPilot(unit)
  
  assert(craft.dodge_bonus == 12) -- 60 / 5
  assert(craft.accuracy_bonus == 12)
end
```

---

## Migration Checklist

### ✅ Design Documentation
- [x] Created Pilots.md (new simple system)
- [x] Updated Units.md (removed complex pilot class)
- [x] Updated Crafts.md (simplified requirements)
- [x] Deleted PilotSystem_Technical.md (old system)
- [x] Renamed files to shorter names

### ✅ API Documentation
- [x] Updated PILOTS.md (deprecated with new info)
- [x] Updated UNITS.md (simplified fields)
- [x] Updated CRAFTS.md (new bonus system)
- [x] Updated GAME_API.toml (removed obsolete fields)

### ⏳ TODO: Engine Implementation
- [ ] Update `engine/basescape/units/unit.lua` - Remove pilot_xp tracking
- [ ] Update `engine/geoscape/crafts/craft.lua` - Simplify pilot bonus calculation
- [ ] Remove `engine/basescape/logic/pilot_progression.lua` - Obsolete module
- [ ] Update craft assignment logic - Remove pilot class checks

### ⏳ TODO: Tests
- [ ] Remove pilot class progression tests
- [ ] Remove dual XP tracking tests
- [ ] Add piloting stat tests
- [ ] Add simple bonus calculation tests

### ⏳ TODO: Mods
- [ ] Update `mods/core/rules/units/*.toml` - Add piloting field
- [ ] Remove pilot-specific unit definitions
- [ ] Update craft requirements in `mods/core/rules/crafts/*.toml`

---

## Benefits of New System

### For Players
- ✅ **Easier to understand** - "This unit has high Piloting = good pilot"
- ✅ **More flexible** - Any veteran can pilot if needed
- ✅ **Less micromanagement** - No separate pilot XP tracking

### For Developers
- ✅ **Simpler to implement** - One stat, one formula
- ✅ **Easier to balance** - Tune one parameter (Piloting)
- ✅ **Less code** - No complex pilot class system

### For Modders
- ✅ **Easier content creation** - Just set piloting value
- ✅ **No special pilot classes** - Works with any unit
- ✅ **Clear mechanics** - Bonus formula is simple

---

## Summary

**What Changed**: Pilot system completely redesigned from complex (classes, dual XP, crew bonuses) to simple (one stat, one formula).

**Files Updated**: 8 files across design/ and api/

**Status**: ✅ DOCUMENTATION COMPLETE

**Next Steps**: Update engine code, tests, and mod content to match new system.

---

**End of Report**

*The pilot system is now simple, clear, and strategic.*

