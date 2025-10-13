# Task: Weapon and Equipment System

**Status:** TODO  
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

### Step 1: Extend Unit Entity Schema
**Description:** Add equipment slots and energy management to unit entities  
**Files to modify/create:**
- `engine/systems/unit.lua` - Add equipment fields
- `engine/battle/entities/unit_entity.lua` - Update entity structure

**Estimated time:** 2 hours

### Step 2: Create Weapon Definition System
**Description:** Define weapon data structures and properties  
**Files to modify/create:**
- `engine/data/weapons.lua` - Weapon definitions
- `engine/systems/weapon_system.lua` - Weapon management logic

**Estimated time:** 3 hours

### Step 3: Create Equipment System
**Description:** Implement armor and skill definitions  
**Files to modify/create:**
- `engine/data/armor.lua` - Armor definitions
- `engine/data/skills.lua` - Skill definitions
- `engine/systems/equipment_system.lua` - Equipment management

**Estimated time:** 2 hours

### Step 4: Implement Energy System
**Description:** Add energy consumption and regeneration  
**Files to modify/create:**
- `engine/battle/systems/energy_system.lua` - Energy management
- `engine/battle/turn_manager.lua` - Hook energy regen into turn cycle

**Estimated time:** 2 hours

### Step 5: Implement Cooldown System
**Description:** Track weapon cooldowns and prevent use during cooldown  
**Files to modify/create:**
- `engine/battle/systems/cooldown_system.lua` - Cooldown tracking
- `engine/battle/turn_manager.lua` - Reduce cooldowns each turn

**Estimated time:** 2 hours

### Step 6: Testing
**Description:** Verify equipment and energy systems work correctly  
**Test cases:**
- Equipment can be equipped/unequipped
- Energy is consumed and regenerated
- Cooldowns prevent weapon use
- Multiple weapons work independently

**Estimated time:** 2 hours

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
- `engine/systems/unit.lua` - Existing unit system
- `engine/battle/entities/unit_entity.lua` - Unit entity structure
- `engine/battle/turn_manager.lua` - Turn management for regen/cooldown
- ECS system - Component-based architecture

### Data Files Structure

**engine/data/weapons.lua:**
```lua
return {
    pistol = {
        name = "Pistol",
        ap_cost = 1,
        ep_cost = 1,
        range = 15,
        base_accuracy = 60,
        cooldown = 0,
        damage = {min = 10, max = 20},
        fire_modes = {"snap", "aim"}
    },
    knife = {
        name = "Combat Knife",
        ap_cost = 1,
        ep_cost = 1,
        range = 1,
        base_accuracy = 90,
        cooldown = 0,
        damage = {min = 15, max = 25},
        fire_modes = {"stab"}
    }
}
```

---

## Testing Strategy

### Unit Tests
- Test 1: `test_weapon_equip.lua` - Verify weapons can be equipped/unequipped
- Test 2: `test_energy_consumption.lua` - Verify energy is consumed on weapon use
- Test 3: `test_energy_regen.lua` - Verify energy regenerates per turn
- Test 4: `test_cooldown.lua` - Verify cooldown prevents weapon use

### Integration Tests
- Test 1: `test_equipment_integration.lua` - Full equipment system with turn manager
- Test 2: `test_dual_weapons.lua` - Using both left and right weapons

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enter battlescape
3. Select a unit
4. Verify equipment slots display in UI
5. Use weapon and verify energy decreases
6. End turn and verify energy regenerates
7. Test weapon with cooldown

### Expected Results
- Weapons display correct properties
- Energy decreases when weapon used
- Energy regenerates each turn
- Cooldown prevents weapon use correctly
- No console errors

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Add debug prints:
```lua
print("[WeaponSystem] Equipped weapon: " .. weapon.name)
print("[EnergySystem] Current energy: " .. energy.current .. "/" .. energy.max)
print("[CooldownSystem] Cooldown remaining: " .. cooldown)
```
- Check console window for equipment changes
- Use Info panel to verify stats display

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - Add WeaponSystem, EquipmentSystem, EnergySystem APIs
- [ ] `wiki/FAQ.md` - Add section on equipment and weapons
- [ ] `wiki/ECS_BATTLE_SYSTEM_API.md` - Document new components
- [ ] Code comments - Add docstrings to all functions

---

## Notes

- Energy system replaces traditional ammo reloading
- Cooldown system allows for powerful weapons with usage limits
- Equipment is per-unit, not shared between units
- Consider future: equipment weight affecting movement
- Consider future: armor damage and degradation
- Example typical loadout: pistol + knife + jacket

---

## Blockers

None - this is a foundational task.

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
- [ ] Equipment data uses proper Lua table format
- [ ] Energy regeneration integrated with turn system
- [ ] Cooldown decrements integrated with turn system

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
