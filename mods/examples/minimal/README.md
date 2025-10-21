# Minimal Example Mod

**Purpose**: Simplest possible example mod for quick learning  
**Status**: Production-ready starter template  
**Version**: 1.0.0  

---

## Quick Start

This mod demonstrates the **absolute minimum** needed to create a working AlienFall mod.

### What This Mod Contains

- ✅ 1 custom weapon (Laser Rifle)
- ✅ 1 custom unit class (Scout)
- ✅ Basic validation

### File Structure

```
mods/examples/minimal/
├── mod.toml       -- Configuration (15 lines)
├── init.lua       -- Mod code (70 lines)
└── README.md      -- Documentation
```

---

## Structure Breakdown

### 1. mod.toml (Minimal Configuration)

```toml
[mod]
id = "example_minimal"
name = "Minimal Example Mod"
version = "1.0.0"
description = "Bare-bones example mod"

[settings]
enabled = true
load_order = 101

[hooks]
on_load = "init.lua"
```

**Key Points**:
- Every mod needs an `id`, `name`, `version`
- `enabled = true` activates the mod
- `on_load` points to initialization script

### 2. init.lua (Minimal Code)

```lua
local MinimalMod = {}

function MinimalMod:initialize()
    -- Define one weapon
    self.content.weapon = {
        id = "minimal_laser_rifle",
        damage = 65,
        accuracy = 85,
        -- ... other properties
    }
    
    -- Define one unit class
    self.content.unit_class = {
        id = "minimal_scout",
        base_health = 30,
        -- ... other properties
    }
end

MinimalMod:initialize()
return MinimalMod
```

**Key Points**:
- Simple table structure
- Direct property assignments
- Minimal validation
- Return the module

---

## Usage

### Load in Game

```lua
local mod = require("mods.examples.minimal.init")

-- Access weapon
print(mod.content.weapon.name)

-- Access unit class
print(mod.content.unit_class.name)
```

### Use in Combat

```lua
-- Create unit with minimal mod class
local unit = CombatUnit:new({
    class_id = "minimal_scout",
    faction = "xcom"
})
```

---

## Comparison: Minimal vs Complete

| Feature | Minimal | Complete |
|---------|---------|----------|
| **Config Lines** | 15 | 45 |
| **Code Lines** | 70 | 600+ |
| **Weapons** | 1 | 3 |
| **Units** | 1 | 4 |
| **Facilities** | 0 | 3 |
| **Technologies** | 0 | 2 |
| **Missions** | 0 | 1 |
| **Validation** | Basic | Comprehensive |

---

## Learning Path

1. **Read this README** (~5 minutes)
2. **Review mod.toml** (~2 minutes)
3. **Review init.lua** (~5 minutes)
4. **Modify weapon stats** (~5 minutes)
5. **Add new weapon** (~10 minutes)
6. **Test in game** (~5 minutes)

**Total**: ~30 minutes to understand modding basics

---

## Next Steps

### Add Another Weapon

In `init.lua`:

```lua
self.content.weapon2 = {
    id = "minimal_laser_pistol",
    name = "Minimal Laser Pistol",
    damage = 45,
    accuracy = 90,
    range = 15,
    -- ...
}
```

### Add Another Unit Class

In `init.lua`:

```lua
self.content.unit_class2 = {
    id = "minimal_heavy",
    name = "Heavy (Minimal)",
    base_health = 40,
    base_stats = {
        strength = 10,  -- High strength
        -- ...
    }
}
```

### Add Facility

In `init.lua`:

```lua
self.content.facility = {
    id = "minimal_workshop",
    name = "Workshop (Minimal)",
    grid_width = 2,
    grid_height = 2,
    build_cost = 2000,
    power_requirement = 40
}
```

### Add Technology

In `init.lua`:

```lua
self.content.technology = {
    id = "minimal_laser_tech",
    name = "Laser Technology (Minimal)",
    technology_tier = 2,
    research_cost = 800,
    prerequisites = {},
    unlocks = {
        weapons = {"minimal_laser_rifle"}
    }
}
```

---

## Common Properties

### Weapon

```lua
{
    id = "unique_id",
    name = "Display Name",
    damage = 50,           -- 10-150
    accuracy = 75,         -- 0-100
    range = 20,            -- tiles
    ap_cost = 3,           -- action points
    ep_cost = 10,          -- energy points
    fire_rate = 1,
    weight = 2.0,
    cost = 1500
}
```

### Unit Class

```lua
{
    id = "unique_id",
    name = "Display Name",
    base_health = 30,
    base_stats = {
        strength = 7,
        dexterity = 8,
        constitution = 7,
        intelligence = 7,
        wisdom = 7,
        charisma = 6
    }
}
```

### Facility

```lua
{
    id = "unique_id",
    name = "Display Name",
    grid_width = 2,
    grid_height = 2,
    build_cost = 2000,
    power_requirement = 40
}
```

### Technology

```lua
{
    id = "unique_id",
    name = "Display Name",
    technology_tier = 2,   -- 1-5
    research_cost = 800,
    prerequisites = {},
    unlocks = {weapons = {...}}
}
```

---

## Tips

### Use Prefix

```lua
-- ✅ Good
id = "minimal_laser_rifle"

-- ❌ Avoid (conflicts with other mods)
id = "laser_rifle"
```

### Keep It Simple

```lua
-- ✅ Good - clear and concise
self.content.weapon = { ... }

-- ❌ Avoid - unnecessary complexity
local weapons = {}
weapons["primary"] = { ... }
self.content.weapons = weapons
```

### Balance Stats

```lua
-- ✅ Good - balanced
{damage = 65, accuracy = 85}  -- Medium damage, high accuracy

-- ❌ Bad - unbalanced
{damage = 150, accuracy = 100} -- Too powerful
```

### Validate Data

```lua
-- ✅ Good
function MinimalMod:validate()
    assert(self.content.weapon.damage > 0, "Invalid damage")
    return true
end

-- ❌ Avoid - silent failures
if self.content.weapon.damage <= 0 then
    -- What happens here?
end
```

---

## Troubleshooting

### Mod Not Loading

Check `mod.toml`:
```toml
enabled = true              # Must be true
on_load = "init.lua"        # Must point to correct file
id = "example_minimal"      # Must be unique
```

### Can't Access Content

Make sure you `return MinimalMod` at end of `init.lua`:
```lua
MinimalMod:initialize()
return MinimalMod           -- Don't forget this!
```

### Validation Fails

Check required fields:
```lua
-- All weapons need:
weapon.id           -- Unique identifier
weapon.name         -- Display name
weapon.damage       -- Value > 0
weapon.accuracy     -- Value 0-100

-- All units need:
unit.id             -- Unique identifier
unit.base_health    -- Value > 0
unit.base_stats     -- All 6 stats (0-12)
```

---

## Summary

**The Minimal Mod shows you:**

✅ Smallest working mod structure  
✅ How to define weapons and units  
✅ Basic validation  
✅ How to return content to game  

**Start here to learn modding, then move to Complete Mod for advanced features.**

---

**Next**: Read `mods/examples/complete/README.md` for comprehensive mod development.

