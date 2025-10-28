# minimal_mod - Bare Minimum Game Content# Minimal Example Mod



**Status:** ✅ Complete**Purpose**: Simplest possible example mod for quick learning  

**Version:** 1.0.0**Status**: Production-ready starter template  

**Purpose:** Absolute minimum content required to run the game**Version**: 1.0.0  



------



## Overview## Quick Start



This mod contains the bare minimum game content to launch and test the engine. Use it for:This mod demonstrates the **absolute minimum** needed to create a working AlienFall mod.



- **Quick Testing:** Fast load time (< 1 second)### What This Mod Contains

- **Debugging:** Minimal complexity for debugging

- **Engine Development:** Focus on engine code, not content- ✅ 1 custom weapon (Laser Rifle)

- **Validation Testing:** Test validators on small dataset- ✅ 1 custom unit class (Scout)

- ✅ Basic validation

**NOT recommended for:** Normal gameplay (extremely limited content)

### File Structure

---

```

## Contentsmods/examples/minimal/

├── mod.toml       -- Configuration (15 lines)

### Units (2 entities)├── init.lua       -- Mod code (70 lines)

└── README.md      -- Documentation

| ID | Name | Type | Purpose |```

|----|------|------|---------|

| soldier_basic | Basic Soldier | Player | Playable character |---

| alien_basic | Basic Alien | Enemy | Enemy unit |

## Structure Breakdown

### Items/Equipment (3 entities)

### 1. mod.toml (Minimal Configuration)

| ID | Name | Type |

|----|------|------|```toml

| rifle_basic | Basic Rifle | Weapon |[mod]

| armor_basic | Basic Armor | Armor |id = "example_minimal"

| ammo_basic | Basic Ammo | Ammunition |name = "Minimal Example Mod"

version = "1.0.0"

### Research (1 entity)description = "Bare-bones example mod"



| ID | Name |[settings]

|----|------|enabled = true

| tech_basic | Basic Technology |load_order = 101



### Facilities (1 entity)[hooks]

on_load = "init.lua"

| ID | Name | Purpose |```

|----|------|---------|

| hangar_basic | Basic Hangar | Aircraft storage |**Key Points**:

- Every mod needs an `id`, `name`, `version`

### Crafts (1 entity)- `enabled = true` activates the mod

- `on_load` points to initialization script

| ID | Name | Type |

|----|------|------|### 2. init.lua (Minimal Code)

| interceptor_basic | Basic Interceptor | Fighter |

```lua

### Missions (1 entity)local MinimalMod = {}



| ID | Name | Type |function MinimalMod:initialize()

|----|------|------|    -- Define one weapon

| mission_crash | UFO Crash | Crash retrieval |    self.content.weapon = {

        id = "minimal_laser_rifle",

### Regions (1 entity)        damage = 65,

        accuracy = 85,

| ID | Name |        -- ... other properties

|----|------|    }

| north_america | North America |    

    -- Define one unit class

---    self.content.unit_class = {

        id = "minimal_scout",

## Performance        base_health = 30,

        -- ... other properties

Load time comparison:    }

end

| Mod | Load Time | Entities | Notes |

|-----|-----------|----------|-------|MinimalMod:initialize()

| **minimal_mod** | ~0.5s | 11 | Bare minimum |return MinimalMod

| **core** | ~3-5s | 500+ | Production content |```



Use `minimal_mod` when fast iteration is critical.**Key Points**:

- Simple table structure

---- Direct property assignments

- Minimal validation

## Usage- Return the module



### Test Validators on Minimal Mod---



```bash## Usage

# API validation (should PASS)

lovec tools/validators/validate_mod.lua mods/minimal_mod### Load in Game



# Content validation (should PASS)```lua

lovec tools/validators/validate_content.lua mods/minimal_modlocal mod = require("mods.examples.minimal.init")

```

-- Access weapon

### Validation Resultsprint(mod.content.weapon.name)



Both validators should pass:-- Access unit class

print(mod.content.unit_class.name)

``````

======================================================================

VALIDATION SUMMARY### Use in Combat

======================================================================

```lua

Total entities checked: 11-- Create unit with minimal mod class

Total errors found: 0local unit = CombatUnit:new({

Total warnings found: 0    class_id = "minimal_scout",

    faction = "xcom"

✅ VALIDATION PASSED})

``````



------



## Limitations## Comparison: Minimal vs Complete



- ❌ Only 1 player unit type| Feature | Minimal | Complete |

- ❌ Only 1 enemy unit type|---------|---------|----------|

- ❌ Only basic weapons/armor| **Config Lines** | 15 | 45 |

- ❌ No tech tree progression| **Code Lines** | 70 | 600+ |

- ❌ No balance considerations| **Weapons** | 1 | 3 |

| **Units** | 1 | 4 |

**Do NOT use for normal gameplay.**| **Facilities** | 0 | 3 |

| **Technologies** | 0 | 2 |

---| **Missions** | 0 | 1 |

| **Validation** | Basic | Comprehensive |

## File Locations

---

```

minimal_mod/## Learning Path

├── mod.toml                    ← Mod metadata

├── README.md                   ← This file1. **Read this README** (~5 minutes)

├── rules/2. **Review mod.toml** (~2 minutes)

│   ├── units/3. **Review init.lua** (~5 minutes)

│   │   ├── soldier_basic.toml4. **Modify weapon stats** (~5 minutes)

│   │   └── alien_basic.toml5. **Add new weapon** (~10 minutes)

│   ├── items/6. **Test in game** (~5 minutes)

│   │   ├── rifle_basic.toml

│   │   ├── armor_basic.toml**Total**: ~30 minutes to understand modding basics

│   │   └── ammo_basic.toml

│   ├── research/---

│   │   └── tech_basic.toml

│   ├── facilities/## Next Steps

│   │   └── hangar_basic.toml

│   ├── crafts/### Add Another Weapon

│   │   └── interceptor_basic.toml

│   ├── missions/In `init.lua`:

│   │   └── mission_crash.toml

│   └── regions/```lua

│       └── north_america.tomlself.content.weapon2 = {

└── assets/    id = "minimal_laser_pistol",

    └── sprites/ (minimal images)    name = "Minimal Laser Pistol",

```    damage = 45,

    accuracy = 90,

---    range = 15,

    -- ...

## Related Documentation}

```

- **Core Mod:** `mods/core/README.md`

- **Modding Guide:** `api/MODDING_GUIDE.md`### Add Another Unit Class

- **Validators:** `tools/validators/README.md`

In `init.lua`:

---

```lua

**Load Time:** < 1 second  self.content.unit_class2 = {

**Complexity:** Minimal      id = "minimal_heavy",

**Use Case:** Testing & Debugging      name = "Heavy (Minimal)",

**Gameplay Ready:** ❌ No      base_health = 40,

**Validator Compliant:** ✅ Yes    base_stats = {

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

