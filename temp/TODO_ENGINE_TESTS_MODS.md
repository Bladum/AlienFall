# TODO: Engine, Tests, and Mods Updates

**Status**: Documentation complete, implementation pending  
**Priority**: HIGH - Core system redesign  
**Date**: 2025-10-28

---

## ⏳ Engine Code Updates Required

### 1. Unit System (`engine/basescape/units/`)

**Files to Update**:
- `engine/basescape/units/unit.lua`
- `engine/basescape/units/unit_manager.lua`

**Changes**:
```lua
-- REMOVE these fields from Unit class:
self.pilot_role = nil
self.pilot_xp = 0
self.pilot_rank = 0
self.pilot_fatigue = 0
self.total_interceptions = 0
self.craft_kills = 0

-- KEEP/UPDATE:
self.piloting = math.random(20, 40) -- 0-100 range
self.assigned_craft_id = nil

-- UPDATE XP gain:
function Unit:gainXP(amount)
  self.xp = self.xp + amount
  -- Piloting improves with ANY XP
  self.piloting = math.min(100, self.piloting + math.floor(amount / 100))
  self:checkRankUp()
end
```

**Remove Functions**:
```lua
-- DELETE these (obsolete):
function Unit:gainPilotXP(amount) -- Use unified gainXP()
function Unit:getPilotRank() -- Use unit rank instead
function Unit:setPilotRole(role) -- Only 'pilot' matters now
function Unit:getPilotClass() -- No pilot classes
```

### 2. Craft System (`engine/geoscape/crafts/`)

**Files to Update**:
- `engine/geoscape/crafts/craft.lua`
- `engine/geoscape/crafts/craft_manager.lua`

**Changes**:
```lua
-- SIMPLIFY pilot bonus calculation:
function Craft:calculateBonuses()
  local pilot = self:getPilot() -- Returns unit in pilot slot
  if not pilot then
    self.dodge_bonus = 0
    self.accuracy_bonus = 0
    return
  end
  
  -- Simple formula: piloting / 5
  local piloting = pilot.piloting or 0
  self.dodge_bonus = piloting / 5
  self.accuracy_bonus = piloting / 5
  
  -- Crew provides ZERO bonuses (ignore them)
end

-- UPDATE pilot assignment:
function Craft:assignPilot(unit)
  -- No class check, no rank check
  if self.pilot_id then
    return false, "Already has pilot"
  end
  
  self.pilot_id = unit.id
  unit.assigned_craft_id = self.id
  self:calculateBonuses()
  return true
end

-- REMOVE crew bonus functions:
function Craft:addCrewMember(unit, role) -- DELETE (obsolete)
function Craft:getCrewBonus() -- DELETE (crew provides no bonuses)
```

### 3. Delete Obsolete Module

**File to DELETE**:
- `engine/basescape/logic/pilot_progression.lua` - Entire module obsolete

**Why**: Complex pilot rank system no longer exists. Use unified unit progression instead.

### 4. Interception System (`engine/interception/`)

**Files to Update**:
- `engine/interception/interception_combat.lua`

**Changes**:
```lua
-- UPDATE XP rewards:
function InterceptionCombat:awardXP(craft, victory)
  local pilot = craft:getPilot()
  if pilot then
    local xp = victory and 50 or 10
    pilot:gainXP(xp) -- Uses unified XP system
    -- Piloting improves automatically in gainXP()
  end
  
  -- Award XP to passengers too (they were there)
  for _, unit in ipairs(craft:getPassengers()) do
    unit:gainXP(victory and 25 or 5)
  end
end
```

---

## ⏳ Test Updates Required

### 1. Delete Obsolete Tests

**Files to DELETE**:
- `tests2/units/pilot_progression_test.lua` - Complex pilot system tests
- `tests2/units/pilot_class_test.lua` - Pilot class tests
- `tests2/crafts/crew_bonus_test.lua` - Crew bonus tests

### 2. Update Existing Tests

**File**: `tests2/units/unit_test.lua`

```lua
-- REMOVE dual XP tests:
-- DELETE: test_pilot_xp_gain()
-- DELETE: test_pilot_rank_progression()

-- ADD piloting stat tests:
function test_piloting_improvement_with_xp()
  local unit = Unit.new({piloting = 30})
  unit:gainXP(100) -- Should increase piloting by +1
  suite:assert(unit.piloting == 31, "Piloting should increase")
end

function test_piloting_cap_at_100()
  local unit = Unit.new({piloting = 99})
  unit:gainXP(500) -- Should cap at 100
  suite:assert(unit.piloting == 100, "Piloting capped at 100")
end
```

**File**: `tests2/crafts/craft_test.lua`

```lua
-- REMOVE complex bonus tests:
-- DELETE: test_multi_pilot_stacking()
-- DELETE: test_crew_member_bonuses()

-- ADD simple bonus tests:
function test_pilot_bonus_calculation()
  local unit = Unit.new({piloting = 60})
  local craft = Craft.new({})
  craft:assignPilot(unit)
  
  suite:assert(craft.dodge_bonus == 12, "Dodge should be piloting/5")
  suite:assert(craft.accuracy_bonus == 12, "Accuracy should be piloting/5")
end

function test_no_pilot_no_bonus()
  local craft = Craft.new({})
  craft:calculateBonuses()
  
  suite:assert(craft.dodge_bonus == 0, "No pilot = no bonus")
  suite:assert(craft.accuracy_bonus == 0, "No pilot = no bonus")
end

function test_crew_provides_no_bonuses()
  local pilot = Unit.new({piloting = 60})
  local crew = Unit.new({piloting = 80}) -- High piloting, but not pilot
  local craft = Craft.new({})
  
  craft:assignPilot(pilot)
  craft:addPassenger(crew)
  
  -- Bonuses should only be from pilot
  suite:assert(craft.dodge_bonus == 12, "Only pilot counts")
end
```

### 3. Add New Tests

**File**: `tests2/units/piloting_stat_test.lua` (NEW)

```lua
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Unit = require("engine.basescape.units.unit")

local suite = HierarchicalSuite.new("PilotingStat", "tests2/units/piloting_stat_test.lua")

suite:testMethod("piloting_improves_with_xp", "Piloting increases per 100 XP", function()
  local unit = Unit.new({piloting = 30})
  
  unit:gainXP(100)
  suite:assert(unit.piloting == 31, "Should increase by 1")
  
  unit:gainXP(200)
  suite:assert(unit.piloting == 33, "Should increase by 2 more")
end)

suite:testMethod("piloting_class_bonus", "Scout class gets +10 piloting", function()
  local unit = Unit.new({class = "scout", piloting = 30})
  local total = unit:getTotalPiloting() -- Base + class bonus
  suite:assert(total == 40, "Should have +10 from scout class")
end)

suite:testMethod("piloting_trait_bonus", "Natural Pilot trait adds +15", function()
  local unit = Unit.new({piloting = 30, traits = {"natural_pilot"}})
  local total = unit:getTotalPiloting()
  suite:assert(total == 45, "Should have +15 from trait")
end)

return suite
```

---

## ⏳ Mod Content Updates Required

### 1. Core Mod Units (`mods/core/rules/units/`)

**Files to Update**:
- `soldiers.toml`
- `aliens.toml`
- `robots.toml`

**Changes**:
```toml
# REMOVE pilot-specific units:
# DELETE these entire entries:
# [[units]]
# id = "fighter_pilot"
# ...
# 
# [[units]]
# id = "bomber_pilot"
# ...

# UPDATE all units to have piloting field:
[[units]]
id = "rookie_soldier"
name = "Rookie Soldier"
class = "soldier"
piloting = 25  # 0-100, base value
# ... rest of stats

[[units]]
id = "scout_veteran"
name = "Scout Veteran"
class = "scout"
piloting = 45  # Scouts naturally better pilots
# ... rest of stats

[[units]]
id = "heavy_assault"
name = "Heavy"
class = "heavy"
piloting = 20  # Heavy units worse pilots (bulky)
# ... rest of stats
```

### 2. Core Mod Crafts (`mods/core/rules/crafts/`)

**Files to Update**:
- `craft_types.toml`

**Changes**:
```toml
# UPDATE all craft definitions:
[[craft_types]]
id = "skyranger"
name = "Skyranger"
required_pilots = 1  # Always 1
max_crew = 8  # Passengers

# REMOVE these fields (obsolete):
# required_pilot_class = "transport_pilot"
# required_pilot_rank = 2

[[craft_types]]
id = "interceptor"
name = "Interceptor"
required_pilots = 1
max_crew = 0  # No passengers (fighter)

# REMOVE pilot class requirements from ALL crafts
```

### 3. Add Piloting to Class Definitions

**New File**: `mods/core/rules/units/class_bonuses.toml`

```toml
# Define piloting bonuses per class
[[class_bonuses]]
class = "scout"
piloting_bonus = 10  # Scouts are naturally good pilots

[[class_bonuses]]
class = "sniper"
piloting_bonus = 5  # Good reflexes help

[[class_bonuses]]
class = "assault"
piloting_bonus = 0  # Neutral

[[class_bonuses]]
class = "heavy"
piloting_bonus = -5  # Too bulky for finesse flying

[[class_bonuses]]
class = "medic"
piloting_bonus = 0  # Neutral

[[class_bonuses]]
class = "engineer"
piloting_bonus = 3  # Technical knowledge helps
```

---

## Priority Order

### 1. HIGH PRIORITY (Core Functionality)
- [ ] Update `engine/basescape/units/unit.lua` - Remove obsolete fields
- [ ] Update `engine/geoscape/crafts/craft.lua` - Simplify bonus calculation
- [ ] Delete `engine/basescape/logic/pilot_progression.lua`
- [ ] Update `mods/core/rules/units/*.toml` - Add piloting field

### 2. MEDIUM PRIORITY (Testing)
- [ ] Delete obsolete test files
- [ ] Update existing craft/unit tests
- [ ] Create new piloting stat tests

### 3. LOW PRIORITY (Polish)
- [ ] Update UI to show piloting stat
- [ ] Add piloting improvement notifications
- [ ] Create piloting equipment items

---

## Verification Checklist

After implementing updates:

- [ ] Game starts without errors
- [ ] Units have piloting stat (0-100 range)
- [ ] XP gain improves piloting (+1 per 100 XP)
- [ ] Crafts accept any unit as pilot
- [ ] Pilot bonuses calculate correctly (piloting / 5)
- [ ] Crew provides zero bonuses
- [ ] No references to pilot_xp, pilot_rank, pilot_class
- [ ] All tests pass
- [ ] Mod content loads correctly

---

## Estimated Effort

- **Engine Updates**: 4-6 hours
- **Test Updates**: 2-3 hours
- **Mod Updates**: 1-2 hours
- **Total**: ~8-11 hours

---

**Status**: Ready for implementation  
**Documentation**: ✅ Complete  
**Next Step**: Update engine code

---

**End of TODO List**

