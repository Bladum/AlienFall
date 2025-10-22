````markdown
# Mod Developer Guide: Complete Tutorial

**Version**: 1.0.0  
**Date**: October 21, 2025  
**Status**: Complete  
**Audience**: Modders of all skill levels  

---

## Welcome to AlienFall Modding!

This guide will teach you everything you need to know to create mods for AlienFall. Whether you're a beginner creating your first weapon or an advanced modder building a total conversion, this guide has you covered.

### Learning Paths

**👶 Complete Beginner?**
Start here: [Chapter 1: Getting Started](#chapter-1-getting-started)

**🎮 Familiar with Games?**
Jump to: [Chapter 2: Core Concepts](#chapter-2-core-concepts)

**⚙️ Advanced Developer?**
See: [Chapter 5: Advanced Topics](#chapter-5-advanced-topics)

---

## Table of Contents

1. [Getting Started](#chapter-1-getting-started)
2. [Core Concepts](#chapter-2-core-concepts)
3. [Creating Content](#chapter-3-creating-content)
4. [Working with Mods](#chapter-4-working-with-mods)
5. [Advanced Topics](#chapter-5-advanced-topics)
6. [Deployment & Sharing](#chapter-6-deployment--sharing)
7. [Troubleshooting](#chapter-7-troubleshooting)
8. [Reference](#chapter-8-reference)

---

## Chapter 1: Getting Started

### What is a Mod?

A **mod** (modification) is a package of custom content for AlienFall that extends or changes the game. Mods can add:

- ✅ New weapons, armor, equipment
- ✅ New unit classes, traits, abilities
- ✅ New facilities and base structures
- ✅ New technologies and research trees
- ✅ New missions and objectives
- ✅ Rebalanced stats and difficulty
- ✅ Complete gameplay overhauls

### Mod File Structure

Every mod has a standard structure:

```
my_mod/
├── mod.toml              ← Configuration file (required)
├── init.lua              ← Initialization script (required)
├── README.md             ← Documentation (recommended)
├── weapons/              ← Weapon data files (optional)
├── units/                ← Unit class files (optional)
├── facilities/           ← Facility files (optional)
├── technology/           ← Technology files (optional)
└── scripts/              ← Lua scripts (optional)
```

### Installation

1. **Create mod directory**: `mods/my_mod/`
2. **Create mod.toml**: Configuration file
3. **Create init.lua**: Main mod code
4. **Restart game**: Love2D loads mod automatically

### Your First Mod: 10 Minutes

Let's create a simple weapon mod!

**Step 1: Create directory**
```bash
mkdir mods/my_first_mod
```

**Step 2: Create mod.toml**
```toml
[mod]
id = "my_first_mod"
name = "My First Mod"
version = "1.0.0"
description = "My first AlienFall mod"

[settings]
enabled = true
load_order = 100
```

**Step 3: Create init.lua**
```lua
local MyMod = {}

function MyMod:initialize()
    print("[My First Mod] Loading...")
    
    self.content = {
        weapon = {
            id = "my_laser_rifle",
            name = "My Laser Rifle",
            damage = 60,
            accuracy = 80,
            range = 25,
            ap_cost = 3,
            cost = 1500,
            type = "rifle"
        }
    }
    
    print("[My First Mod] Loaded!")
end

function MyMod:validate()
    return self.content.weapon ~= nil
end

MyMod:initialize()
return MyMod
```

**Step 4: Test it**
```bash
lovec "engine"
```

**Result**: Your first mod is loaded!

---

## Chapter 2: Core Concepts

### TOML Format

Mods use **TOML** (Tom's Obvious, Minimal Language) for data files. It's simple and human-readable.

**Basic TOML Syntax**:

```toml
# Comments start with #

# Section (single item)
[mod]
id = "example"
name = "Example Mod"
version = "1.0.0"

# Array of sections (multiple items)
[[weapon]]
id = "rifle"
name = "Rifle"
damage = 50

[[weapon]]
id = "pistol"
name = "Pistol"
damage = 35
```

### Data Types

```toml
string = "text value"
integer = 42
number = 3.14
boolean = true
array = ["item1", "item2", "item3"]
table = {key1 = "value", key2 = 123}
```

### Entity Types

AlienFall has these main entity types (use these in your mods):

| Type | Purpose | File | Example |
|------|---------|------|---------|
| Weapon | Combat equipment | weapons.toml | Rifle, Plasma Gun |
| Armor | Protection gear | armors.toml | Combat Suit, Light Armor |
| Unit Class | Character template | classes.toml | Soldier, Sniper, Scout |
| Facility | Base building | facilities.toml | Lab, Workshop, Power Gen |
| Technology | Research project | technologies.toml | Laser Weapons, Plasma Tech |
| Mission | Game objective | missions.toml | UFO Crash, Terror Site |
| Item | Tradeable goods | items.toml | Medical Supplies, Components |

### Schema and Validation

Each entity type has a **schema** - required and optional fields:

**Weapon Schema** (example):
```
REQUIRED:
- id (unique identifier)
- name (display name)
- damage (10-150)
- accuracy (0-100)
- range (5-100 tiles)
- type (rifle, pistol, launcher, etc)
- cost (0-99999)

OPTIONAL:
- description (flavor text)
- ap_cost (action points, default: 3)
- fire_rate (shots per turn, default: 1)
- weight (encumbrance, default: 5)
- technology_required (tech ID to unlock)
```

**Why schemas matter**: They ensure your mod data is correct and the game can load it properly.

---

## Chapter 3: Creating Content

### Creating a Weapon

**Step 1: Define the weapon**

```lua
local myWeapon = {
    id = "my_rifle",
    name = "My Rifle",
    description = "A custom rifle",
    type = "rifle",
    damage = 55,
    accuracy = 75,
    range = 25,
    ap_cost = 3,
    ep_cost = 10,
    fire_rate = 1,
    weight = 5,
    cost = 1200,
    technology_required = nil,  -- No tech required
    ammo_type = "rifle_ammo"
}
```

**Step 2: Balance your weapon**

Use this formula as guide:
- **High damage** = Lower accuracy
- **Long range** = High AP cost
- **Expensive** = Better stats

Example balance:
```lua
-- Low tier weapon
{damage = 35, accuracy = 85, range = 15, cost = 400}

-- Medium tier weapon
{damage = 55, accuracy = 75, range = 25, cost = 1200}

-- High tier weapon
{damage = 85, accuracy = 60, range = 30, cost = 2500}
```

**Step 3: Add to your mod**

```lua
function MyMod:loadWeapons()
    self.content.weapons = {
        {
            id = "my_rifle",
            name = "My Rifle",
            damage = 55,
            -- ... all properties
        },
        {
            id = "my_pistol",
            name = "My Pistol",
            damage = 40,
            -- ... all properties
        }
    }
end
```

### Creating a Unit Class

**Step 1: Define the class**

```lua
local myUnitClass = {
    id = "my_scout",
    name = "My Scout",
    description = "Fast and sneaky",
    faction = "xcom",
    base_health = 28,
    base_stats = {
        strength = 6,
        dexterity = 11,  -- Fast!
        constitution = 6,
        intelligence = 7,
        wisdom = 7,
        charisma = 6
    },
    starting_equipment = {
        weapon = "my_rifle",
        armor = "light_armor"
    },
    abilities = {"scout_move", "stealth"},
    traits = {"fast", "sneaky"}
}
```

**Step 2: Balance your unit**

Stats should sum to 42-48 (6 stats × 7 average):

```lua
-- Balanced scout
{strength = 6, dexterity = 11, const = 6, int = 7, wisdom = 7, charisma = 5}  -- Total: 42

-- Balanced heavy
{strength = 11, dexterity = 5, const = 11, int = 6, wisdom = 7, charisma = 2}  -- Total: 42
```

**Step 3: Add to your mod**

```lua
function MyMod:loadUnits()
    self.content.unitClasses = {
        myUnitClass,
        -- ... more classes
    }
end
```

### Creating a Facility

**Step 1: Define the facility**

```lua
local myLab = {
    id = "my_research_lab",
    name = "My Research Lab",
    description = "Advanced research facility",
    category = "research",
    grid_width = 2,
    grid_height = 2,
    build_cost = 3000,
    build_time = 25,
    maintenance_cost = 400,
    maintenance_interval = 30,
    power_requirement = 50,
    staff_capacity = 8,
    properties = {
        research_bonus = 20,
        focus_technology = "my_tech"
    },
    adjacency_bonuses = {
        {
            adjacent_facility = "workshop",
            bonus_type = "research",
            bonus_value = 10
        }
    }
}
```

**Step 2: Balance your facility**

Cost guidelines:
- Small (1x1-2x2): 1000-2000 credits
- Medium (2x3-3x3): 2500-4000 credits
- Large (4x4+): 5000-10000 credits

Power guidelines:
- No power: 0
- Low power: 20-30
- Medium power: 40-60
- High power: 70-100

### Creating Technology

**Step 1: Define the technology**

```lua
local myTech = {
    id = "my_plasma_tech",
    name = "Plasma Technology",
    description = "Unlock plasma weapons",
    technology_tier = 3,
    research_cost = 1500,
    research_time = 40,
    prerequisites = {"laser_technology"},  -- Requires this first
    unlocks = {
        weapons = {"plasma_rifle", "plasma_pistol"},
        armor = {"plasma_suit"},
        facilities = {"plasma_lab"}
    }
}
```

**Step 2: Plan your tech tree**

Use this hierarchy:
```
Tier 1: Basic weapons (no prerequisites)
  ↓
Tier 2: Advanced weapons (requires Tier 1)
  ↓
Tier 3: Alien tech (requires Tier 2)
  ↓
Tier 4: Advanced alien (requires Tier 3)
  ↓
Tier 5: Exotic tech (requires Tier 4)
```

---

## Chapter 4: Working with Mods

### Mod Metadata (mod.toml)

```toml
[mod]
# Core info (required)
id = "my_mod"              # Unique ID (alphanumeric + underscore)
name = "My Mod"            # Display name
version = "1.0.0"          # Version (semantic versioning)
description = "My mod"     # One-line description
author = "Your Name"       # Creator

[metadata]
category = "weapons"       # Type of mod
tags = ["weapons", "balance", "scifi"]  # Search tags
documentation = "README.md"  # Doc file

[settings]
enabled = true             # Load this mod?
load_order = 100           # Priority (higher = load later)

[paths]
weapons = "weapons"        # Where weapon files are
units = "units"            # Where unit files are
facilities = "facilities"  # Where facility files are

[dependencies]
core = {version = ">=1.0.0", required = true}  # Required mods

[compatibility]
min_game_version = "1.0.0"
max_game_version = "2.0.0"
```

### Loading Content in init.lua

```lua
local MyMod = {}

function MyMod:initialize()
    print("[My Mod] Initializing...")
    
    self.content = {}
    
    -- Load each content type
    self:loadWeapons()
    self:loadUnits()
    self:loadFacilities()
    
    print("[My Mod] Successfully loaded!")
end

function MyMod:loadWeapons()
    self.content.weapons = {
        {id = "weapon1", name = "Weapon 1", damage = 50},
        {id = "weapon2", name = "Weapon 2", damage = 60}
    }
end

function MyMod:loadUnits()
    self.content.units = {
        {id = "unit1", name = "Unit 1", base_health = 35}
    }
end

function MyMod:loadFacilities()
    self.content.facilities = {
        {id = "facility1", name = "Facility 1", grid_width = 2}
    }
end

function MyMod:validate()
    -- Check all content is valid
    if not self.content.weapons or #self.content.weapons == 0 then
        print("[ERROR] No weapons loaded!")
        return false
    end
    return true
end

MyMod:initialize()
return MyMod
```

### Testing Your Mod

**Step 1: Syntax Check**
```bash
luac -p mods/my_mod/init.lua
```

**Step 2: Load Test**
```bash
lovec "engine"
```

Check console for:
- ✅ "[My Mod] Initializing..."
- ✅ "[My Mod] Successfully loaded!"
- ✅ No error messages

**Step 3: In-Game Test**
- Load game
- Check that your content appears
- Verify stats are correct
- Test in gameplay

### Debugging

**Enable debug output**:
```lua
print("[My Mod] Debug message: " .. tostring(value))
```

**Check console**: Run `lovec "engine"` to see all print statements

**Common errors**:
```
[ERROR] Missing field 'X'
  → Required field not provided

[ERROR] Could not load TOML
  → TOML syntax error, check formatting

[ERROR] Unknown mod dependency
  → Required mod not installed
```

---

## Chapter 5: Advanced Topics

### Mod Dependencies

**Require another mod**:

```toml
[dependencies]
core = {version = ">=1.0.0", required = true}
my_base_mod = {version = ">=1.0.0", required = true}
```

**Example**: Expansion mod that extends base mod:
```toml
[dependencies]
core = {version = ">=1.0.0", required = true}
base_weapons = {version = ">=1.0.0", required = true}

# This mod won't load if base_weapons isn't installed
```

### Content Overrides

**Replace core content** from your mod:

```lua
function MyMod:initialize()
    -- Override core rifle damage
    self.content.overrides = {
        weapons = {
            rifle = {damage = 60}  -- Changed from 50 to 60
        }
    }
end
```

### Custom Lua Functions

**Add custom game logic**:

```lua
function MyMod:onWeaponFired(weapon, attacker, target)
    -- Custom logic when weapon fires
    if weapon.id == "my_special_weapon" then
        print("Special weapon fired!")
    end
end

function MyMod:onUnitCreated(unit)
    -- Custom logic when unit spawned
    if unit.class_id == "my_scout" then
        print("Scout created!")
    end
end
```

### Balance Modding

**Change game difficulty**:

```lua
function MyMod:initialize()
    self.content.balanceChanges = {
        -- Increase all weapon damage by 20%
        weaponDamageMultiplier = 1.2,
        
        -- Reduce all building costs by 30%
        facilityBuildCostMultiplier = 0.7,
        
        -- Increase research speed by 50%
        researchSpeedMultiplier = 1.5
    }
end
```

---

## Chapter 6: Deployment & Sharing

### Package Your Mod

1. **Verify structure**:
```
my_mod/
├── mod.toml       ← Required
├── init.lua       ← Required
├── README.md      ← Recommended
└── [content files]
```

2. **Create ZIP archive**: `my_mod.zip`

3. **Include**: mod.toml, init.lua, README.md, and content files

### Share Your Mod

**Where to share**:
- GitHub (recommend)
- Mod community forums
- Game workshop
- Your personal website

**Recommended README sections**:
```markdown
# My Mod

Description of what this mod does.

## Installation

1. Download my_mod.zip
2. Extract to mods/my_mod/
3. Restart game

## Features

- Feature 1
- Feature 2
- Feature 3

## Balance Notes

How this mod affects game balance.

## Compatibility

Works with game version 1.0.0+

## License

License information
```

### Version Management

Use **semantic versioning**:
- **1.0.0** → Major.Minor.Patch
- **1.0.0** → First release
- **1.0.1** → Bug fixes
- **1.1.0** → New features
- **2.0.0** → Breaking changes

---

## Chapter 7: Troubleshooting

### Common Issues

**Issue**: Mod not loading
```
✓ Check: mod.toml exists in mod directory
✓ Check: init.lua exists in mod directory
✓ Check: enabled = true in mod.toml
✓ Check: load_order is reasonable (1-1000)
```

**Issue**: Syntax errors
```
✓ Run: luac -p mods/my_mod/init.lua
✓ Check: All brackets/braces matched
✓ Check: All strings have closing quotes
✓ Check: No special characters unescaped
```

**Issue**: Data not loading
```
✓ Check: Function names correct (loadWeapons, loadUnits)
✓ Check: Tables properly created (self.content.weapons = {})
✓ Check: All required fields present (id, name, etc)
✓ Check: Validation function returns true
```

**Issue**: Game crashes
```
✓ Check: Love2D console for error messages
✓ Check: No nil references (always verify before use)
✓ Check: Correct table/array syntax
✓ Check: No infinite loops or stack overflow
```

**Issue**: Content not appearing
```
✓ Check: Mod loads successfully (check console)
✓ Check: Content added to self.content table
✓ Check: Stats are reasonable (damage 10-150, etc)
✓ Check: IDs are unique (no duplicates)
✓ Check: Dependencies satisfied (required mods loaded)
```

### Debug Checklist

```
□ Enable Love2D console (lovec "engine")
□ Watch for "MyMod" print messages
□ Verify no [ERROR] messages
□ Check that content appears in game
□ Verify stats match what you defined
□ Test in actual gameplay
□ Check balance with similar items
□ Look for crashes or warnings
```

---

## Chapter 8: Reference

### Quick Links

**API Documentation**:
- [Weapons & Armor](WEAPONS_AND_ARMOR.md)
- [Units & Classes](UNITS.md)
- [Facilities](FACILITIES.md)
- [Research & Manufacturing](RESEARCH_AND_MANUFACTURING.md)
- [Missions](MISSIONS.md)
- [Economy & Items](ECONOMY.md)
- [TOML Schema Reference](TOML_SCHEMA_REFERENCE.md)

**Example Mods**:
- [Complete Example Mod](../../mods/examples/complete/)
- [Minimal Example Mod](../../mods/examples/minimal/)

**Tools**:
- [Map Editor](../../tools/map_editor/)
- [Asset Verification](../../tools/asset_verification/)

### Entity Type Stat Ranges

**Weapons**:
- Damage: 10-150
- Accuracy: 0-100%
- Range: 5-100 tiles
- AP Cost: 1-5
- Fire Rate: 1-5
- Cost: 0-99999

**Armor**:
- Armor Class: 0-20
- Health Bonus: 0-30
- Weight: 0.5-2.0 kg
- Cost: 500-5000

**Units**:
- Health: 20-50
- Stats: 0-12 each
- Progression: Rank 0-6
- XP per Rank: 100-2500

**Facilities**:
- Grid: 1x1 to 5x5
- Cost: 500-99999
- Power: 0-100
- Maintenance: 0-500/month

**Technologies**:
- Tier: 1-5
- Cost: 50-2500 man-days
- Prerequisites: Ordered by tier

### TOML Templates

**Weapon Template**:
```toml
[[weapon]]
id = "my_weapon"
name = "My Weapon"
description = "Description"
type = "rifle"
damage = 50
accuracy = 75
range = 25
ap_cost = 3
cost = 1200
technology_required = ""
```

**Unit Class Template**:
```toml
[[unit_class]]
id = "my_class"
name = "My Class"
faction = "xcom"
base_health = 35
strength = 7
dexterity = 8
constitution = 7
intelligence = 7
wisdom = 7
charisma = 6
```

**Facility Template**:
```toml
[[facility]]
id = "my_facility"
name = "My Facility"
category = "research"
grid_width = 2
grid_height = 2
build_cost = 3000
power_requirement = 50
```

---

## Learning Resources

### Progressive Learning Path

1. **Beginner** (Chapter 1-2)
   - Basic mod structure
   - TOML format
   - Getting started

2. **Intermediate** (Chapter 3-4)
   - Creating weapons, units, facilities
   - Mod initialization
   - Testing and debugging

3. **Advanced** (Chapter 5-6)
   - Dependencies and overrides
   - Custom Lua functions
   - Deployment and sharing

4. **Expert** (Chapter 7-8)
   - Troubleshooting complex issues
   - Performance optimization
   - Community contribution

### Hands-On Exercises

**Exercise 1: Create your first weapon** (30 min)
- Create new weapon with custom damage/accuracy
- Load in game
- Verify stats

**Exercise 2: Create a unit class** (45 min)
- Design unit with unique stats
- Balance against existing units
- Add starting equipment

**Exercise 3: Create a facility** (45 min)
- Design facility with grid placement
- Add adjacency bonuses
- Balance costs

**Exercise 4: Build a tech tree** (1 hour)
- Create 3 technologies
- Set up prerequisites
- Define unlocks

**Exercise 5: Create a complete mod** (2-3 hours)
- Combine weapons, units, facilities, tech
- Create README
- Test thoroughly
- Package for sharing

---

## Best Practices

### Code Organization

✅ **DO**:
- Use clear, descriptive names
- Add comments explaining complex logic
- Separate concerns (one function per task)
- Use consistent formatting

❌ **DON'T**:
- Use cryptic variable names (a, b, c)
- Nest functions too deeply
- Mix multiple concerns in one function
- Use inconsistent formatting

### Data Validation

✅ **DO**:
- Verify all required fields present
- Check stat ranges
- Validate cross-references
- Handle missing data gracefully

❌ **DON'T**:
- Assume data is correct
- Skip validation
- Use unverified values
- Silently fail

### Balance

✅ **DO**:
- Follow stat range guidelines
- Compare to similar items
- Test in actual gameplay
- Get feedback

❌ **DON'T**:
- Create overpowered items
- Ignore existing balance
- Only test in isolation
- Ignore user feedback

### Documentation

✅ **DO**:
- Write clear README
- Document non-obvious choices
- Include version history
- Provide usage examples

❌ **DON'T**:
- Leave mods undocumented
- Assume users understand intent
- Ignore compatibility info
- Hide limitations

---

## Conclusion

Congratulations! You now have a comprehensive understanding of AlienFall modding.

**Next steps**:
1. Create your first mod following this guide
2. Review example mods for reference
3. Join the modding community
4. Share your creations

**Remember**: The best mods come from:
- ✅ Understanding the game systems
- ✅ Careful balance and testing
- ✅ Clear documentation
- ✅ Listening to feedback
- ✅ Continuous improvement

**Happy modding!** 🚀

---

## Additional Resources

- **API Documentation**: See other files in `wiki/api2/`
- **Example Mods**: `mods/examples/`
- **Test Suite**: `tests/`
- **Tools**: `tools/`
- **Community Forums**: [Link to community]
- **Bug Reports**: [Link to issue tracker]


````