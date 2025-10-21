# Complete Example Mod

**Purpose**: Demonstrate all modding capabilities of AlienFall  
**Status**: Production-ready example  
**Version**: 1.0.0  

---

## Overview

The Complete Example Mod showcases every major modding feature available in AlienFall, serving as a comprehensive template for mod developers.

### What This Mod Includes

✅ **Custom Weapons** (3 items)
- Plasma Rifle (primary)
- Plasma Pistol (secondary)
- Plasma Launcher (heavy)

✅ **Custom Armor** (2 items)
- Plasma Combat Armor (powered)
- Light Plasma Suit

✅ **Custom Unit Classes** (2 templates)
- Advanced Soldier (enhanced training)
- Plasma Specialist (expert plasma weapons)

✅ **Custom Units** (2 instances)
- CPL. Example Unit (Advanced Soldier)
- SPC. Plasma Master (Plasma Specialist)

✅ **Custom Facilities** (3 buildings)
- Plasma Research Lab
- Plasma Manufacturing Workshop
- Plasma Storage Vault

✅ **Custom Technologies** (2 research paths)
- Plasma Weapons (Tier 3)
- Advanced Plasma Theory (Tier 4)

✅ **Custom Missions** (1 example)
- Alien Research Facility Raid

---

## Mod Structure

```
mods/examples/complete/
├── mod.toml                 -- Mod configuration and metadata
├── init.lua                 -- Main mod initialization script
├── README.md                -- This file (documentation)
├── weapons/                 -- Weapon data files (TOML)
├── units/                   -- Unit class definitions (TOML)
├── facilities/              -- Facility configurations (TOML)
└── technology/              -- Research tech tree (TOML)
```

---

## Key Features Demonstrated

### 1. Mod Metadata (mod.toml)

```toml
[mod]
id = "example_complete"
name = "Complete Example Mod"
version = "1.0.0"
description = "Comprehensive example demonstrating all capabilities"

[settings]
enabled = true
load_order = 100
```

**Demonstrates**:
- Mod identification and versioning
- Load order management (priority 100 = after core)
- Metadata for mod manager

### 2. Content Registration (init.lua)

```lua
function CompleteMod:loadWeapons()
    self.content.weapons[1] = {
        id = "example_plasma_rifle",
        name = "Plasma Rifle (Example)",
        -- ... complete weapon definition
    }
end
```

**Demonstrates**:
- Procedural content loading
- Dynamic content registration
- In-memory data structures

### 3. Weapon Definition

```lua
{
    id = "example_plasma_rifle",
    name = "Plasma Rifle (Example)",
    damage = 85,
    accuracy = 75,
    range = 30,
    ap_cost = 3,
    technology_required = "example_plasma_tech",
    properties = {
        armor_piercing = true,
        heat_damage = true,
        splash_radius = 2
    }
}
```

**Demonstrates**:
- Weapon stat system
- Technology dependencies
- Special properties

### 4. Unit Class Definition

```lua
{
    id = "example_advanced_soldier",
    name = "Advanced Soldier (Example)",
    base_health = 35,
    base_stats = {
        strength = 8,
        dexterity = 9,
        -- ... other stats
    },
    starting_equipment = {
        weapon = "example_plasma_rifle",
        armor = "example_plasma_armor"
    }
}
```

**Demonstrates**:
- Unit class templates
- Starting equipment
- Base stat configuration
- Progression systems

### 5. Facility Definition

```lua
{
    id = "example_plasma_lab",
    name = "Plasma Research Lab (Example)",
    grid_width = 2,
    grid_height = 2,
    build_cost = 3500,
    power_requirement = 50,
    properties = {
        research_bonus = 25,
        focus_technology = "plasma_weapons"
    }
}
```

**Demonstrates**:
- Facility grid placement
- Build and maintenance costs
- Power requirements
- Adjacency bonuses
- Resource focusing

### 6. Technology Definition

```lua
{
    id = "example_plasma_tech",
    name = "Plasma Weapons (Example)",
    technology_tier = 3,
    research_cost = 1500,
    prerequisites = {},
    unlocks = {
        weapons = {"example_plasma_rifle", ...},
        armor = {"example_plasma_armor", ...},
        facilities = {"example_plasma_lab", ...}
    }
}
```

**Demonstrates**:
- Technology tree structure
- Prerequisite chains
- Content unlocking
- Tiered progression

### 7. Mission Definition

```lua
{
    id = "example_mission_alien_facility",
    name = "Alien Research Facility (Example)",
    mission_type = "terror_site",
    difficulty = "challenging",
    objectives = {
        {type = "destroy", target = "research_computer", required = true},
        {type = "recover", target = "plasma_prototype", required = false}
    }
}
```

**Demonstrates**:
- Mission objectives
- Optional vs required tasks
- Reward systems
- Mission difficulty

### 8. Data Validation

```lua
function CompleteMod:validate()
    for _, weapon in ipairs(self.content.weapons) do
        if not weapon.id or not weapon.name or not weapon.damage then
            print("[ERROR] Invalid weapon: " .. tostring(weapon.id))
            return false
        end
    end
end
```

**Demonstrates**:
- Content validation
- Error handling
- Quality assurance

### 9. Statistics and Reporting

```lua
function CompleteMod:getStatistics()
    return {
        name = self.name,
        version = self.version,
        weapons = #self.content.weapons,
        armor = #self.content.armor,
        -- ... all categories
        total_content = ...
    }
end
```

**Demonstrates**:
- Metadata queries
- Statistics collection
- Content inventory

---

## Using This Mod in Your Game

### Enable the Mod

1. Ensure mod.toml has `enabled = true`
2. Place mod in `mods/examples/complete/` directory
3. Game loads mod on startup (respects load_order)

### Load Content in Code

```lua
-- In your mod manager
local mod = require("mods.examples.complete.init")

-- Access mod content
local weapons = mod.content.weapons
local units = mod.content.units
local facilities = mod.content.facilities

-- Get statistics
local stats = mod:getStatistics()
print("Mod loaded: " .. stats.weapons .. " weapons")
```

### In Battles

```lua
-- Create unit from mod class
local CombatUnit = require("battlescape.systems.combat_unit")
local unit = CombatUnit:new({
    class_id = "example_plasma_specialist",
    faction = "xcom",
    position = {x = 10, y = 10}
})

-- Equip mod weapons
unit:equip_weapon(weapons[1])  -- Plasma Rifle
unit:equip_armor(armor[1])      -- Plasma Combat Armor
```

### In Base Management

```lua
-- Build mod facility
local Facility = require("basescape.systems.facility")
local lab = Facility:new({
    facility_id = "example_plasma_lab",
    grid_position = {x = 0, y = 0}
})

base:add_facility(lab)
```

### In Research

```lua
-- Research mod technology
local Research = require("core.systems.research")
Research:queue_project({
    technology_id = "example_plasma_tech",
    base_id = current_base.id
})
```

---

## Testing This Mod

### 1. Syntax Validation

Run Lua syntax check:
```bash
luac -p mods/examples/complete/init.lua
```

### 2. Load Test

Load and initialize the mod:
```lua
local mod = require("mods.examples.complete.init")
assert(mod:validate(), "Mod validation failed")
```

### 3. Content Verification

```lua
local stats = mod:getStatistics()
assert(stats.weapons == 3, "Expected 3 weapons")
assert(stats.armor == 2, "Expected 2 armor items")
assert(stats.facilities == 3, "Expected 3 facilities")
assert(stats.total_content == 13, "Content count mismatch")
```

### 4. Integration Test

```lua
-- Test with game systems
local CombatUnit = require("battlescape.systems.combat_unit")
local unit = CombatUnit:new({class_id = "example_advanced_soldier"})
assert(unit ~= nil, "Failed to create unit from mod class")
assert(unit.base_health == 35, "Unit health incorrect")
```

---

## Extending This Mod

### Add Custom Weapons

In `init.lua`, add to `loadWeapons()`:

```lua
self.content.weapons[4] = {
    id = "example_new_weapon",
    name = "New Weapon (Example)",
    -- ... weapon properties
}
```

### Add Custom Facilities

In `init.lua`, add to `loadFacilities()`:

```lua
self.content.facilities[4] = {
    id = "example_new_facility",
    name = "New Facility (Example)",
    -- ... facility properties
}
```

### Add Custom Technologies

In `init.lua`, add to `loadTechnologies()`:

```lua
self.content.technologies[3] = {
    id = "example_new_tech",
    name = "New Technology (Example)",
    -- ... tech properties
}
```

### Add Custom Missions

In `init.lua`, add to `loadMissions()`:

```lua
self.content.missions[2] = {
    id = "example_new_mission",
    name = "New Mission (Example)",
    -- ... mission properties
}
```

---

## API Reference

### Weapon Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | string | Yes | Unique weapon identifier |
| name | string | Yes | Display name |
| damage | number | Yes | Damage value (10-150) |
| accuracy | number | Yes | Hit chance (0-100) |
| range | number | Yes | Effective range in tiles |
| ap_cost | number | Yes | Action points required |
| technology_required | string | No | Tech ID that unlocks |
| properties | table | No | Special weapon properties |

### Unit Class Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | string | Yes | Unique class identifier |
| name | string | Yes | Display name |
| base_health | number | Yes | Starting health |
| base_stats | table | Yes | 6 core stats (0-12) |
| starting_equipment | table | No | Default gear |
| abilities | table | No | Available abilities |
| traits | table | No | Personality/physical traits |

### Facility Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | string | Yes | Unique facility ID |
| name | string | Yes | Display name |
| grid_width | number | Yes | Grid cells wide |
| grid_height | number | Yes | Grid cells high |
| build_cost | number | Yes | Cost to construct |
| power_requirement | number | Yes | Energy consumption |
| properties | table | No | Special facility properties |

### Technology Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| id | string | Yes | Unique tech ID |
| name | string | Yes | Display name |
| technology_tier | number | Yes | Tech tier (1-5) |
| research_cost | number | Yes | Research man-days |
| prerequisites | table | Yes | Required techs |
| unlocks | table | No | Content unlocked |

---

## Best Practices

### 1. Unique IDs

Always prefix IDs with mod identifier:
```lua
-- ✅ Good
id = "example_plasma_rifle"

-- ❌ Bad
id = "plasma_rifle"  -- Might conflict with other mods
```

### 2. Data Validation

Always validate content on load:
```lua
function MyMod:validate()
    for _, item in ipairs(self.content.weapons) do
        assert(item.id, "Weapon missing ID")
        assert(item.damage >= 10, "Damage too low")
    end
end
```

### 3. Error Handling

Use safe loading with error reporting:
```lua
local success, result = pcall(function()
    return loadContent()
end)

if not success then
    print("[ERROR] Failed to load: " .. result)
end
```

### 4. Clear Descriptions

Include detailed descriptions for all content:
```lua
description = "Advanced armor with plasma-resistant properties",
```

### 5. Consistent Naming

Use consistent naming conventions:
```lua
-- Mod prefix + descriptive name
"example_plasma_rifle"
"example_advanced_soldier"
"example_plasma_lab"
```

---

## Troubleshooting

### Mod Not Loading

- Check `mod.toml` syntax
- Verify `enabled = true` in settings
- Check `load_order` priority
- Verify directory structure matches mod.toml `paths`

### Content Not Available

- Verify content was added to `self.content` tables
- Check `validate()` function passes
- Ensure IDs match technology `unlocks` references
- Verify prerequisites are satisfied

### Performance Issues

- Validate weapon stat ranges (10-150 damage)
- Check facility power requirements (realistic values)
- Verify technology research costs (50-2500)
- Profile loading time with `print()` statements

---

## Learning Path

1. **Start Here**: Read this entire README
2. **Explore**: Review `init.lua` and understand content structure
3. **Experiment**: Create your own weapons/units in `init.lua`
4. **Test**: Use validation and statistics functions
5. **Extend**: Add more facilities, technologies, missions
6. **Optimize**: Profile and balance your content
7. **Deploy**: Share with other players

---

## Summary

The Complete Example Mod demonstrates:

✅ Modding project structure and configuration  
✅ Content registration and initialization  
✅ All entity types (weapons, armor, units, facilities, tech, missions)  
✅ Stat systems and balance mechanics  
✅ Technology prerequisites and unlocks  
✅ Data validation and error handling  
✅ Statistics collection and reporting  

Use this as a template for your own mods!

---

**Questions?** See API documentation in `wiki/api/`

