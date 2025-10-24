# TASK-PILOT-001: Implement PILOT Class System

**Status:** TODO | **Priority:** CRITICAL | **Duration:** 4-5 hours  
**Depends On:** None  
**Blocks:** TASK-PILOT-002, TASK-PILOT-003, TASK-PILOT-007, TASK-PILOT-008

---

## Overview

Create the PILOT class as a new unit archetype focused on vehicle/craft operation. Pilots are humans who specialize in flying craft and gain experience during interception combat (not ground battle).

**Key Difference:** Unlike RIFLEMAN/MEDIC/SNIPER which are combat specialists, PILOT is an operator specialist. During ground missions, pilots deploy as combat units but retain their pilot skills.

---

## What Needs to be Done

### 1. Add PILOT to Unit Classes TOML

**File:** `mods/core/rules/unit/classes.toml`

Add new class definition:

```toml
[[classes]]
id = "pilot"
name = "Pilot"
description = "Professional aircraft and spacecraft pilot. Excels in vehicle operation with high speed and reaction time. Gains experience during interception combat."
type = "soldier"

# Base Stats (focus: SPEED, AIM, REACTION)
hp_base = 50
strength_base = 5
speed_base = 8          # High speed for flight operations
aim_base = 7            # Good accuracy for weapons
reaction_base = 8       # Quick reactions for piloting
energy_base = 6
wisdom_base = 5
psi_base = 4

# Combat Effectiveness
accuracy_base = 65      # Slightly below RIFLEMAN
armor_class = 5         # Light armor

# Equipment
starting_weapon = "pistol"
starting_armor = "light_armor"
weapon_types_preferred = ["pistol", "rifle", "submachine_gun"]
weapon_proficiencies = ["pistol", "rifle", "submachine_gun"]

# Abilities
abilities = []          # Pilots use standard abilities
class_abilities = []

# Perks
perks = [
    "can_move",
    "can_run",
    "can_shoot",
    "can_melee",
    "can_throw"
]

# Progression
xp_to_level_up = 100
promotion_requirement = 500
promotes_to = ["pilot_veteran", "pilot_ace"]

# Special
is_operator = true      # Flag indicating operator role
```

**Details:**
- **Stats:** SPEED 8 and REACTION 8 (piloting requires quick reactions and mobility)
- **AIM 7:** Decent accuracy, not sniper-level
- **Health 50:** Lower than RIFLEMAN (65) - pilots are not front-line
- **Accuracy 65%:** Below RIFLEMAN (70%) - combat is not their specialty
- **No special abilities:** Pilots use standard combat actions

### 2. Update PILOT Class Variants

Add specialist pilot classes:

```toml
# Fighter Pilot (high speed/aim)
[[classes]]
id = "fighter_pilot"
name = "Fighter Pilot"
description = "Elite aircraft combat pilot. Specialized for interceptor craft."
type = "soldier"
hp_base = 55
strength_base = 6
speed_base = 9
aim_base = 8
reaction_base = 9
energy_base = 6
wisdom_base = 5
psi_base = 4
xp_to_level_up = 80
promotion_requirement = 300

# Bomber Pilot (lower speed, good strength)
[[classes]]
id = "bomber_pilot"
name = "Bomber Pilot"
description = "Transport and heavy craft specialist. High endurance and control."
type = "soldier"
hp_base = 60
strength_base = 7
speed_base = 7
aim_base = 6
reaction_base = 7
energy_base = 7
wisdom_base = 6
psi_base = 3
xp_to_level_up = 100
promotion_requirement = 500

# Helicopter Pilot (VTOL specialist)
[[classes]]
id = "helicopter_pilot"
name = "Helicopter Pilot"
description = "Vertical takeoff/landing specialist. Precise hovering and low-altitude control."
type = "soldier"
hp_base = 55
strength_base = 5
speed_base = 7
aim_base = 7
reaction_base = 9
energy_base = 6
wisdom_base = 7
psi_base = 3
xp_to_level_up = 90
promotion_requirement = 400
```

### 3. Verify Pilot Units Load in Engine

**File:** `engine/basescape/logic/unit_system.lua` (or similar)

Check that:
- PILOT class can be created via `UnitSystem.createUnit("pilot", "John Doe")`
- Pilot units have correct stats from TOML
- Pilot perks are initialized
- No errors on unit creation

Add code if needed:

```lua
function UnitSystem.createUnit(classId, name)
    local classData = DataLoader.getUnitClass(classId)
    if not classData then
        error("Unit class not found: " .. classId)
    end
    
    local unit = {
        id = generateUnitId(),
        name = name,
        class_id = classId,
        stats = {
            strength = classData.strength_base,
            speed = classData.speed_base,
            aim = classData.aim_base,
            reaction = classData.reaction_base,
            -- ... other stats
        },
        perks = {},
        experience = 0,
        rank = 0
    }
    
    -- Initialize default perks from class
    if classData.perks then
        for _, perkId in ipairs(classData.perks) do
            unit.perks[perkId] = true
        end
    end
    
    return unit
end
```

### 4. Update Unit Recruitment UI (if exists)

**File:** `engine/basescape/ui/recruit_unit_ui.lua` (if exists)

Add PILOT to recruitment options:
- Show PILOT class in class selector
- Show PILOT description and stats
- Allow recruiting PILOT (or specialist pilots)

---

## Testing Checklist

- [ ] PILOT class defined in TOML with correct stats
- [ ] FIGHTER_PILOT, BOMBER_PILOT, HELICOPTER_PILOT defined
- [ ] Pilot unit can be created: `UnitSystem.createUnit("pilot", "Alice")`
- [ ] Pilot stats match TOML (SPEED=8, AIM=7, REACTION=8)
- [ ] Pilot perks initialized correctly
- [ ] Game runs without errors after changes
- [ ] Pilot units can be recruited from UI (if applicable)

---

## Files Modified

1. ✅ `mods/core/rules/unit/classes.toml` - Added 4 pilot class definitions
2. ✅ `engine/basescape/logic/unit_system.lua` - Verified unit creation works

---

## Related Tasks

- **TASK-PILOT-002:** Craft Pilot Requirements (needs pilots to exist)
- **TASK-PILOT-007:** Pilot Progression (ranks and XP)
- **TASK-PILOT-010:** Unit Classes TOML (adds perks to all classes)

---

## Notes

- Pilots are NOT promoted like other units (different progression system)
- Pilots gain XP only from interception (TASK-PILOT-008)
- Pilot stats get transmitted to craft as bonuses (TASK-PILOT-006)
- In ground combat, pilots deploy as regular soldiers with pilot stats

---

**Task Created:** October 23, 2025

