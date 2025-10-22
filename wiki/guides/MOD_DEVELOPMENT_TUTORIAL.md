# Mod Developer Tutorial

**Version:** 1.0  
**Date:** October 21, 2025  
**Goal:** Complete step-by-step guide to creating a mod

---

## What is a Mod?

A mod is a collection of TOML data files that define new game content:
- Items, weapons, armor
- Technologies and research
- Missions and scenarios
- Facilities and structures
- Units and classes
- Factions and nations

---

## Prerequisites

- Basic TOML file format knowledge (see `API_SCHEMA_REFERENCE.md`)
- Love2D installed and running
- AlienFall engine accessible
- Text editor (VS Code recommended)

---

## Step 1: Create Mod Directory

Create directory structure:
```
mods/
└── my_awesome_mod/
    ├── content/
    │   ├── items/
    │   │   └── items.toml
    │   ├── weapons/
    │   │   └── weapons.toml
    │   ├── technologies/
    │   │   └── tech.toml
    │   ├── missions/
    │   │   └── missions.toml
    │   └── facilities/
    │       └── facilities.toml
    ├── metadata.toml
    └── README.md
```

---

## Step 2: Create Metadata

Create `mods/my_awesome_mod/metadata.toml`:

```toml
[mod]
id = "mod_my_awesome_mod"
name = "My Awesome Mod"
version = "1.0.0"
author = "Your Name"
description = "A cool mod that adds new items and features"
min_game_version = "1.0.0"
dependencies = []  # Other mods this depends on

[mod.features]
items = true
weapons = true
missions = false
```

---

## Step 3: Create Your First Item

Create `mods/my_awesome_mod/content/items/items.toml`:

```toml
[[item]]
id = "item_awesome_medikit"
name = "Awesome Medikit"
category = "consumables"
subcategory = "medical"
description = "Super effective medical supply"
weight = 0.2
market_price = 500
stock_availability = "uncommon"
rarity = "uncommon"
tech_level = 2

[item.effects]
health_restore = 50
panic_reduction = 15

[item.usage]
reusable = false
charges = 1
```

---

## Step 4: Add a Weapon

Create weapon in `mods/my_awesome_mod/content/weapons/weapons.toml`:

```toml
[[weapon]]
id = "weapon_awesome_rifle"
name = "Awesome Rifle"
category = "weapons"
weapon_type = "rifle"
description = "An awesome rifle with great stats"
damage_min = 45
damage_max = 65
accuracy = 85
ammo_type = "rifle_ammo"
range = 20
rate_of_fire = 2
weight = 3.5
market_price = 1200
tech_level = 2
required_technology = "tech_awesome_rifle"

[weapon.damage_types]
kinetic = 85
armor_penetration = 10
```

---

## Step 5: Add Research Tech

Create `mods/my_awesome_mod/content/technologies/tech.toml`:

```toml
[[technology]]
id = "tech_awesome_rifle"
name = "Awesome Rifle Technology"
category = "weapons"
description = "Research into awesome rifle manufacturing"
research_cost = 300
prerequisite = "tech_advanced_weapons"
tier = 2
unlock_items = ["weapon_awesome_rifle"]
unlock_recipes = ["recipe_awesome_rifle"]

[technology.cost_by_base_size]
small = 300
medium = 250
large = 200
huge = 150
```

---

## Step 6: Create Manufacturing Recipe

Add to `mods/my_awesome_mod/content/weapons/weapons.toml`:

```toml
[[recipe]]
id = "recipe_awesome_rifle"
name = "Manufacture Awesome Rifle"
category = "weapons"
input_item = "component_awesome_rifle"
input_quantity = 2
output_item = "weapon_awesome_rifle"
output_quantity = 1
production_time = 15
resource_cost = 500
facility_type = "workshop"
required_technology = "tech_awesome_rifle"
facility_bonus_percent = 10
batch_size_optimal = 3
```

---

## Step 7: Test Your Mod

### Launch with mod enabled:
```bash
# From project root
lovec engine
```

### Check console output:
1. Open Love2D console
2. Look for mod loading messages
3. Search for your mod ID
4. Check for any errors

### Example console output:
```
[MOD LOADER] Loading mod: mod_my_awesome_mod
[MOD LOADER] ✓ Loaded 1 item
[MOD LOADER] ✓ Loaded 1 weapon
[MOD LOADER] ✓ Loaded 1 technology
[MOD LOADER] ✓ Loaded 1 recipe
[MOD LOADER] ✓ Mod 'My Awesome Mod' loaded successfully
```

### In-game testing:
1. Check marketplace for your item
2. Verify it's purchaseable
3. Check tech tree for your research
4. Verify research unlocks recipe
5. Verify manufacturing works

---

## Step 8: Add a Mission

Create `mods/my_awesome_mod/content/missions/missions.toml`:

```toml
[[mission]]
id = "mission_awesome_rescue"
name = "Rescue Awesome Scientists"
mission_type = "rescue"
description = "Rescue scientists working on awesome tech"
location = "Europe"
difficulty = "hard"
reward_credits = 3000
reward_technology_points = 200
reward_reputation = [25, -5]
min_squad_size = 4
max_squad_size = 6
recommended_squad_size = 5
enemy_types = ["alien_soldier", "alien_commander"]
enemy_count_min = 10
enemy_count_max = 15
map_type = "research_facility"

[[mission.objectives]]
type = "rescue"
target = "scientist_01"
description = "Rescue Lead Scientist"
optional = false
bonus_reward = 500

[[mission.objectives]]
type = "eliminate"
target = "commander"
description = "Eliminate Alien Commander"
optional = true
bonus_reward = 1000
```

---

## Step 9: Package Your Mod

Create `mods/my_awesome_mod/README.md`:

```markdown
# My Awesome Mod

## Features
- 1 new awesome item
- 1 new awesome weapon
- 1 new awesome technology
- 1 new awesome mission

## Installation
1. Copy mod folder to `mods/`
2. Restart game
3. Mod loads automatically

## Compatibility
- Game version: 1.0.0+
- Dependencies: None

## Credits
- Created by: Your Name
- Special thanks: People who helped

## License
Creative Commons Attribution
```

---

## Step 10: Distribute Your Mod

Share your mod:
1. Package into ZIP file
2. Upload to mod repository
3. Share with community
4. Collect feedback
5. Iterate and improve

---

## Advanced: Mod Hooks

For advanced mods, use the modding API:

```lua
-- In your mod initialization
local Mods = require("engine.mods.mods")

-- Register custom function
Mods.registerHook("on_mission_complete", function(mission, results)
    print("[MY MOD] Mission completed: " .. mission.name)
end)

-- Access other mods
local otherMod = Mods.getMod("other_mod_id")
if otherMod then
    print("[MY MOD] Found mod: " .. otherMod.name)
end
```

---

## Troubleshooting

### Mod not loading
- Check `metadata.toml` format
- Verify folder structure matches expected layout
- Check console for parse errors
- Validate TOML syntax (no typos)

### Items not appearing
- Verify item is in correct TOML file
- Check item ID is properly formatted
- Ensure category exists (weapons, items, etc.)
- Check prerequisites are met

### Research won't unlock
- Verify prerequisite is in base game
- Check tech_level is reasonable (1-5)
- Ensure unlock_items references correct IDs
- Verify unlock_recipes exist

### Performance issues
- Don't add excessive items in one mod
- Optimize recipe costs
- Avoid deep prerequisite chains
- Balance difficulty levels

---

## Template Checklist

- ✓ Created directory structure
- ✓ Created metadata.toml
- ✓ Created first item
- ✓ Created weapon
- ✓ Created technology
- ✓ Created recipe
- ✓ Created mission
- ✓ Tested in game
- ✓ Created README
- ✓ Ready to share!

---

## Next Steps

1. See `API_SCHEMA_REFERENCE.md` for full TOML schemas
2. Review individual API files for specific entities
3. Join mod community for feedback
4. Create more content
5. Share your mod!

---

**Happy modding!** 🎮

Questions? See FAQ or check console debug output.
