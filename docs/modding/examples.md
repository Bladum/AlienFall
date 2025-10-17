# Modding Examples & Templates

> **Source**: `../../../mods/core/examples/`
> **API Reference**: `../../../wiki/API.md`
> **Configuration Guide**: `toml_schemas/`

This guide shows how to use the example files in `mods/core/examples/` as templates for creating custom content.

---

## Overview

AlienFall supports extensive content customization through TOML configuration files. The example files provide:

1. **Complete Working Examples** - Actual content from the game
2. **Template Structure** - How to organize your own content
3. **Best Practices** - Recommended patterns for content creation
4. **Quick Start** - Copy & modify to create custom content

---

## Quick Start: Creating Custom Content

### Step 1: Choose Your Content Type

Select what you want to create:
- **Units** - Soldiers with custom stats and abilities
- **Weapons** - New armament with unique properties
- **Crafts** - Aircraft for various roles
- **Facilities** - Base buildings with different functions

### Step 2: Find the Example

Choose the closest example from `mods/core/examples/`:

| Content Type | Folder | Example Files |
|----------|--------|-----------|
| Units | `units/` | `assault_soldier.toml`, `sniper.toml` |
| Weapons | `weapons/` | `ballistic_rifle.toml`, `laser_rifle.toml` |
| Crafts | `crafts/` | `interceptor.toml`, `skyranger_transport.toml` |
| Facilities | `facilities/` | `laboratory.toml`, `hangar.toml` |

### Step 3: Copy & Customize

1. Copy the example file: `mods/core/examples/units/assault_soldier.toml`
2. Rename it: `mods/my_mod/units/my_custom_soldier.toml`
3. Modify the ID (must be unique):
   ```toml
   id = "my_custom_soldier"  # Change this
   ```
4. Adjust the values for your custom content
5. Test in-game

---

## Example: Creating a Custom Sniper Unit

### Starting Template

Copy from `mods/core/examples/units/sniper.toml`:

```toml
[[unit]]
id = "example_sniper"        # Step 1: Change this
name = "Sniper"              # Step 2: Change this
type = "soldier"
rank = "sergeant"
experience = 50
# ... rest of template
```

### Step-by-Step Customization

**Step 1: Change the ID (unique identifier)**
```toml
id = "elite_assassin"  # Changed from "example_sniper"
```

**Step 2: Update the display name**
```toml
name = "Elite Assassin"  # Changed from "Sniper"
```

**Step 3: Adjust the stats**
```toml
[unit.stats]
health = 80            # Increased from 70 for toughness
action_points = 9      # Increased from 8 for mobility
accuracy = 98          # Increased from 95 for better sniping
time_units = 50
strength = 25          # Decreased from 30 (not strength-based)
reactions = 75         # Increased from 70 for faster targeting
bravery = 60           # Increased from 50 (veteran)
```

**Step 4: Update equipment**
```toml
[unit.equipment]
primary_weapon = "plasma_rifle_sniper"  # Upgraded weapon
armor = "advanced_tactical_suit"        # Better armor
special_equipment = "targeting_computer" # Added technology
```

**Step 5: Update description**
```toml
description = "Elite assassin. Enhanced accuracy and health. Uses advanced plasma weapons and targeting systems."
```

### Final Result

```toml
[[unit]]
id = "elite_assassin"
name = "Elite Assassin"
type = "soldier"
rank = "captain"
experience = 100

[unit.stats]
health = 80
action_points = 9
accuracy = 98
time_units = 50
strength = 25
reactions = 75
bravery = 60

[unit.abilities]
precision_training = "master_sniper"
tactical_insertion = "infiltration"

[unit.equipment]
primary_weapon = "plasma_rifle_sniper"
armor = "advanced_tactical_suit"
special_equipment = "targeting_computer"

description = "Elite assassin. Enhanced accuracy and health. Uses advanced plasma weapons and targeting systems."
```

---

## Example: Creating a Custom Weapon

### Starting Template

Copy from `mods/core/examples/weapons/laser_rifle.toml`:

```toml
[[weapon]]
id = "example_laser_rifle"
name = "Military Laser Rifle"
# ... template data
```

### Customization Steps

**Step 1: Unique ID**
```toml
id = "experimental_laser_v2"  # Unique identifier
```

**Step 2: Updated stats (making it more powerful)**
```toml
damage = 40          # Increased from 35
accuracy = 78        # Increased from 75
range = 35           # Increased from 30
fire_rate = 3        # Increased from 2
cost_manufacturing = 3000  # Increased due to better stats
```

**Step 3: Add research requirement**
```toml
research_required = ["research_advanced_laser"]
```

**Complete Example:**
```toml
[[weapon]]
id = "experimental_laser_v2"
name = "Experimental Laser V2"
phase = "phase1"
category = "laser_rifle"
type = "energy"
research_required = ["research_advanced_laser"]
cost_manufacturing = 3000
damage = 40
damage_type = "laser"
armor_penetration = 25
accuracy = 78
range = 35
fire_rate = 3
capacity = 30
weight = 3.8
description = "Advanced laser rifle with experimental targeting system. Superior performance to standard military variant."
```

---

## Example: Creating a Custom Facility

### Starting Template

Copy from `mods/core/examples/facilities/laboratory.toml`:

```toml
[[facility]]
id = "example_laboratory"
name = "Advanced Laboratory"
# ... template
```

### Creating "Mega Laboratory"

**Increased Capacity:**
```toml
[facility.capacities]
research_projects = 4        # Increased from 2
units = 20                   # Increased from 10
```

**Higher Cost & Longer Build:**
```toml
build_time = 35              # Increased from 21 days
build_cost = 300000          # Increased from 150000
maintenance = 20000          # Increased from 10000
```

**Better Adjacency Bonuses:**
```toml
[facility.adjacency_bonuses]
storage_warehouse = 0.20     # Increased from 0.10
power_generator = 0.10       # Increased from 0.05
workshop = 0.10              # Added new bonus
```

**Full Example:**
```toml
[[facility]]
id = "mega_laboratory"
name = "Mega Research Laboratory"
phase = "phase2"
category = "research"
build_time = 35
build_cost = 300000
health = 120
armor = 8

[facility.capacities]
research_projects = 4
units = 20

[facility.services]
provides = ["research", "advanced_analysis"]
requires = ["power", "exotic_materials"]

maintenance = 20000
description = "Mega research facility. Supports 4 concurrent projects and 20 scientists. Enables advanced analysis technologies."

[facility.adjacency_bonuses]
storage_warehouse = 0.20
power_generator = 0.10
workshop = 0.10

[facility.benefits]
research_speed_bonus = 1.5
exotic_research_unlock = true
```

---

## Common Stat Ranges Reference

Use these as guidelines when customizing content:

### Unit Stats

| Stat | Range | Notes |
|------|-------|-------|
| **Health** | 60-150 | Soldiers 80-120, specialists vary |
| **Action Points** | 6-10 | Standard is 8 |
| **Accuracy** | 40-95 | Most soldiers 60-75 |
| **Strength** | 20-70 | Physical strength for damage |
| **Reactions** | 30-80 | Combat reflexes |
| **Bravery** | 30-80 | Morale and fear resistance |

### Weapon Stats

| Stat | Range | Notes |
|------|-------|-------|
| **Damage** | 10-100 | Pistol 10-20, Rifle 20-50, Heavy 50+ |
| **Accuracy** | 40-95 | Shotgun 40-50, Rifle 65-80, Sniper 90+ |
| **Range** | 8-50 | Melee 2, Pistol 12-18, Rifle 20-30 |
| **Fire Rate** | 1-6 | Semi-auto 1-2, Burst 3-4, Full auto 5-6 |
| **Capacity** | 5-40 | Pistol 15-20, Rifle 25-35 |

### Facility Stats

| Stat | Range | Notes |
|------|-------|-------|
| **Build Time** | 7-35 days | Storage 7-14, Research 21-35 |
| **Build Cost** | 50k-300k | Hangar 200k, Lab 150k |
| **Health** | 80-200 | Most 100-150 |
| **Maintenance** | 2k-20k monthly | Varies by capacity |

---

## Best Practices

### 1. Keep IDs Unique and Descriptive

❌ Bad:
```toml
id = "weapon1"  # Not descriptive
id = "rifle"    # Too generic, conflicts possible
```

✅ Good:
```toml
id = "plasma_rifle_mk2"    # Descriptive and unique
id = "exotic_laser_mk3"    # Clear progression
```

### 2. Balance Stats Within Ranges

❌ Unbalanced:
```toml
[[unit]]
health = 500      # Overpowered
accuracy = 99     # Too high
```

✅ Balanced:
```toml
[[unit]]
health = 110      # Slightly above average
accuracy = 75     # Good but not perfect
```

### 3. Document Your Content

❌ No description:
```toml
[[weapon]]
id = "x_rifle"
name = "X Rifle"
# No description!
```

✅ Clear description:
```toml
[[weapon]]
id = "x_rifle"
name = "X Rifle"
description = "Experimental rifle combining X technology. Moderate damage with exceptional accuracy."
```

### 4. Use Consistent Naming

✅ Good patterns:
- `elite_soldier_v2` (progression)
- `phase2_plasma_cannon` (phase indicator)
- `exotic_armor_mk3` (mark numbers)

### 5. Test Before Distribution

- Load in-game
- Check console for errors
- Verify stats are reasonable
- Test interactions with other systems
- Balance against core content

---

## Creating Content Chains

Link related items together for progressive content:

### Example: Research Chain

```toml
# 1. Define the research that unlocks items
[[research]]
id = "research_advanced_plasma"
name = "Advanced Plasma Technology"
prerequisites = ["research_plasma_weapons"]
unlock_items = ["advanced_plasma_rifle", "plasma_cannon_mk2"]
research_cost = 4000
research_time_days = 25

# 2. Create weapons that require this research
[[weapon]]
id = "advanced_plasma_rifle"
name = "Advanced Plasma Rifle"
research_required = ["research_advanced_plasma"]
damage = 50

[[weapon]]
id = "plasma_cannon_mk2"
name = "Plasma Cannon Mk2"
research_required = ["research_advanced_plasma"]
damage = 75
```

---

## File Organization

### Recommended Mod Structure

```
mods/my_mod/
├── units/
│   ├── soldiers.toml
│   ├── scientists.toml
│   └── specialists.toml
├── weapons/
│   ├── ballistic.toml
│   ├── energy.toml
│   └── exotic.toml
├── crafts/
│   ├── fighters.toml
│   └── transports.toml
├── facilities/
│   └── advanced_buildings.toml
└── mod.toml
```

### Naming Convention

- Files: `snake_case.toml` (lowercase, underscores)
- IDs: `snake_case_id` (lowercase, underscores)
- Names: `Title Case Name` (display names)
- Descriptions: Clear, descriptive, 1-2 sentences

---

## Validation & Debugging

### Check TOML Syntax

Use an online TOML validator:
1. Visit https://www.toml-lint.com/
2. Paste your TOML content
3. Check for syntax errors

### Common TOML Errors

```toml
# ❌ Missing quotes
name = Example Weapon

# ✅ Correct
name = "Example Weapon"

# ❌ Wrong bracket type
[[weapon}

# ✅ Correct
[[weapon]]

# ❌ Missing closing bracket
[facility
description = "test"

# ✅ Correct
[facility]
description = "test"
```

### Test in Game

1. Place your .toml file in proper mod directory
2. Launch AlienFall
3. Check console for errors: `[ERROR]` or `[WARNING]`
4. Verify content appears in-game
5. Check stats and functionality

---

## Advanced: Creating Multi-File Content Mods

### Organized Complex Mod

```
mods/my_complex_mod/
├── mod.toml                          # Mod metadata
├── weapon_systems/
│   ├── README.md
│   ├── ballistic_advanced.toml
│   ├── laser_experimental.toml
│   ├── plasma_variants.toml
│   └── exotic_weapons.toml
├── unit_types/
│   ├── elite_soldiers.toml
│   ├── specialists.toml
│   └── exotic_units.toml
├── base_buildings/
│   ├── advanced_facilities.toml
│   ├── exotic_structures.toml
│   └── defensive_systems.toml
└── documentation/
    ├── README.md
    ├── CHANGES.md
    └── COMPATIBILITY.md
```

### Mod Metadata (mod.toml)

```toml
[mod]
id = "my_complex_mod"
name = "My Complex Mod"
version = "1.0.0"
author = "Your Name"
description = "Adds advanced weapons and facilities"

[mod.dependencies]
core = "1.0.0"

[mod.content]
weapons = ["weapon_systems/*.toml"]
units = ["unit_types/*.toml"]
facilities = ["base_buildings/*.toml"]
```

---

## Contributing Your Examples

Have great example content? Share it!

1. Create well-documented .toml files
2. Include README explaining purpose
3. Ensure balanced stats
4. Test thoroughly
5. Submit PR to AlienFall repository

**Thank you for contributing to AlienFall!**

---

## See Also

- `mods/core/examples/` - All example files
- `docs/mods/toml_schemas/` - Complete schema reference
- `wiki/API.md` - Full API documentation
- `mods/core/` - Real content configurations
