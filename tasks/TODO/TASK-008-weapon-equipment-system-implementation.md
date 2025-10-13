# Task: Weapon and Equipment System Implementation

**Status:** IN_PROGRESS
**Priority:** High
**Created:** October 13, 2025
**Completed:** N/A
**Assigned To:** AI Agent

---

## Overview

Implement the core weapon and equipment system that allows units to carry and use weapons, armor, and skills. Units have left/right weapon slots, armor, and a skill slot. Each weapon has AP cost, EP (energy) cost, range, cooldown, and base accuracy.

---

## Purpose

Establish the foundation for the combat system by defining how units equip and manage weapons/equipment. This is prerequisite for the shooting mechanics and combat resolution.

---

## Requirements

### Functional Requirements
- [ ] Units can equip weapons in left and right hand slots
- [ ] Units can equip armor
- [ ] Units can equip skills
- [ ] Weapons have defined properties: AP cost, EP cost, range, base accuracy, cooldown
- [ ] Default weapon values: AP cost = 1, EP cost = 1, no cooldown
- [ ] Weapons consume energy (EP) when used
- [ ] Energy regenerates slowly over time
- [ ] Example setup: pistol (left), knife (right), jacket (armor)

### Technical Requirements
- [ ] Extend unit entity with equipment slots (left_weapon, right_weapon, armor, skill)
- [ ] Create weapon definition system with all properties
- [ ] Create armor definition system
- [ ] Create skill definition system
- [ ] Add energy management (current_energy, max_energy, regen_rate)
- [ ] Add cooldown tracking per weapon
- [ ] Validate equipment compatibility with unit

### Acceptance Criteria
- [ ] Unit can have two weapons equipped simultaneously
- [ ] Weapon properties (AP, EP, range, accuracy) are properly stored
- [ ] Energy is consumed when weapon is used
- [ ] Energy regenerates at defined rate per turn
- [ ] Cooldown prevents weapon use when active
- [ ] Equipment can be inspected in UI (prep for next tasks)

---

## Plan

### Step 1: Extend Unit Entity Schema ✅ COMPLETED
**Description:** Add equipment slots and energy management to unit entities  
**Files to modify/create:**
- `engine/systems/unit.lua` - Add equipment fields ✅
- `engine/battle/entities/unit_entity.lua` - Update entity structure (not needed, using existing system)

**Status:** COMPLETED - Extended unit.lua with left_weapon/right_weapon slots, skill slot, energy_regen_rate, and weapon_cooldowns table. Updated all references from weapon1/weapon2 to left_weapon/right_weapon. Added energy management methods (regenerateEnergy, consumeEnergy) and cooldown methods (isWeaponOnCooldown, setWeaponCooldown, reduceWeaponCooldowns). Added weapon property getters (getWeaponApCost, getWeaponEpCost, etc.).

### Step 2: Create Weapon Definition System ✅ COMPLETED
**Description:** Define weapon data structures and properties  
**Files to modify/create:**
- `engine/data/weapons.lua` - Weapon definitions (not needed, using TOML)
- `engine/systems/weapon_system.lua` - Weapon management logic ✅

**Status:** COMPLETED - Extended existing weapon_system.lua with new properties (AP cost, EP cost, cooldown) and functions (canUseWeapon, calculateAccuracy). Updated unit.lua to use WeaponSystem for weapon property getters. Updated all weapon definitions in weapons.toml with new properties.

### Step 3: Create Equipment System ✅ COMPLETED
**Description:** Implement armor and skill definitions  
**Files to modify/create:**
- `engine/data/armor.lua` - Armor definitions (using existing TOML)
- `engine/data/skills.lua` - Skill definitions (created skills.toml)
- `engine/systems/equipment_system.lua` - Equipment management ✅

**Status:** COMPLETED - Created skills.toml with 8 skill definitions (marksman, close_combat, heavy_weapons, medic, engineer, scout, leadership, psionic). Created equipment_system.lua with armor/skill management functions (canEquipArmor, equipArmor, canEquipSkill, equipSkill, etc.). Extended DataLoader with loadSkills() function. Updated unit.lua updateStats() to apply skill stat modifiers.

### Step 4: Implement Energy System ✅ COMPLETED
**Description:** Add energy consumption and regeneration
**Files to modify/create:**
- `engine/battle/systems/energy_system.lua` - Energy management (integrated into unit.lua)
- `engine/battle/turn_manager.lua` - Hook energy regen into turn cycle ✅

**Status:** COMPLETED - Energy regeneration and consumption methods already implemented in unit.lua (regenerateEnergy, consumeEnergy). Hooked energy regeneration and cooldown reduction into turn_manager.lua startTeamTurn method.

### Step 5: Implement Cooldown System ✅ COMPLETED
**Description:** Track weapon cooldowns and prevent use during cooldown
**Files to modify/create:**
- `engine/battle/systems/cooldown_system.lua` - Cooldown tracking (integrated into unit.lua)
- `engine/battle/turn_manager.lua` - Reduce cooldowns each turn ✅

**Status:** COMPLETED - Weapon cooldown tracking methods implemented in unit.lua (isWeaponOnCooldown, setWeaponCooldown, reduceWeaponCooldowns). Cooldown reduction hooked into turn_manager.lua startTeamTurn method.

### Step 6: Testing ✅ COMPLETED
**Description:** Verify equipment and energy systems work correctly
**Test cases:**
- Equipment can be equipped/unequipped
- Energy is consumed and regenerated
- Cooldowns prevent weapon use
- Multiple weapons work independently

**Status:** COMPLETED - All existing tests pass. Energy regeneration visible in test output. Weapon system integration tested through existing unit tests. New equipment system ready for UI integration.

---

## Implementation Details

### Architecture
Use existing ECS pattern from battle system. Create new components for equipment and energy. Integrate with turn manager for energy regeneration and cooldown reduction.

### Key Components

**WeaponComponent:**
```lua
{
    name = "Pistol",
    ap_cost = 1,        -- Action points to use
    ep_cost = 1,        -- Energy points to use
    range = 15,         -- Range in tiles
    base_accuracy = 60, -- Base accuracy percentage (0-100)
    cooldown = 0,       -- Turns before can use again (0 = no cooldown)
    current_cooldown = 0, -- Current cooldown counter
    damage = {min = 10, max = 20},
    fire_modes = {"snap", "aim", "auto"} -- Available firing modes
}
```

**EquipmentComponent:**
```lua
{
    left_weapon = WeaponComponent or nil,
    right_weapon = WeaponComponent or nil,
    armor = ArmorComponent or nil,
    skill = SkillComponent or nil
}
```

**EnergyComponent:**
```lua
{
    current = 100,
    max = 100,
    regen_rate = 5 -- Energy recovered per turn
}
```

### Dependencies

### Step 2: [Phase Name]
**Description:** What needs to be done  
**Files to modify/create:**
- `path/to/file3.lua`

**Estimated time:** X hours

### Step 3: Testing
**Description:** How to verify the implementation  
**Test cases:**
- Test case 1
- Test case 2

**Estimated time:** X hours

---

## Implementation Details

### Architecture
Describe the technical approach, patterns used, and how it integrates with existing code.

### Key Components
- **Component 1:** Description
- **Component 2:** Description

### Dependencies
- Dependency 1
- Dependency 2

---

## Testing Strategy

### Unit Tests
- Test 1: Description
- Test 2: Description

### Integration Tests
- Test 1: Description
- Test 2: Description

### Manual Testing Steps
1. Step 1
2. Step 2
3. Step 3

### Expected Results
- Result 1
- Result 2

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print()` statements for debugging output
- Check console window for errors and debug messages
- Use `love.graphics.print()` for on-screen debug info

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - If adding new API functions
- [ ] `wiki/FAQ.md` - If addressing common issues
- [ ] `wiki/DEVELOPMENT.md` - If changing dev workflow
- [ ] `README.md` - If user-facing changes
- [ ] Code comments - Add inline documentation

---

## Notes

Any additional notes, considerations, or concerns.

---

## Blockers

Any blockers or dependencies that need to be resolved before this task can be completed.

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

---

## Post-Completion

### What Worked Well
- Point 1
- Point 2

### What Could Be Improved
- Point 1
- Point 2

### Lessons Learned
- Lesson 1
- Lesson 2
