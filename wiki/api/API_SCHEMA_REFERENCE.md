# API Schema Reference: Complete Entity Documentation

**Version**: 1.0.0  
**Date**: October 21, 2025  
**Coverage**: 118 entity types across 14 content categories  

---

## Overview

This document provides the complete schema reference for all moddable entity types in AlienFall. Each entity type includes:

- **Schema**: All fields, types, and constraints
- **Validation**: Required vs optional, defaults, constraints
- **TOML Format**: How to define in TOML files
- **Lua Access**: How to access from code
- **Examples**: Real working examples
- **Notes**: Tips for modders

---

## How to Use This Reference

### For Modders

1. Find your entity type in table of contents
2. Review the schema and examples
3. Copy the TOML structure to your mod
4. Modify values as needed
5. Test with Love2D console: `lovec "engine"`

### For Developers

1. Use schemas to validate TOML during parsing
2. Reference field types when reading data
3. Check constraints for game logic
4. Use examples as test data

---

## Content Organization

| # | Category | Entity Types | Files |
|---|---|---|---|
| **1** | Weapons & Armour | Weapon, Armour, Ammo | weapons.toml, armours.toml, ammo.toml |
| **2** | Units & Classes | UnitClass, Unit, Trait | classes.toml, soldiers.toml, aliens.toml |
| **3** | Facilities | Facility, Adjacency Bonus | base_facilities.toml, research_facilities.toml |
| **4** | Research & Manufacturing | ResearchProject, Recipe | research.toml, manufacturing.toml |
| **5** | Items & Resources | Resource, Equipment | items.toml, resources.toml |
| **6** | Missions | Mission, Objective | tactical_missions.toml, strategic_missions.toml |
| **7** | Economy | Marketplace Item, Supplier | economy.toml |
| **8** | Factions | Faction, Faction Unit Roster | faction_*.toml |
| **9** | Campaigns | Campaign, Campaign Phase | campaign_timeline.toml, phase_*.toml |
| **10** | Narrative | Narrative Event, Quest | narrative.toml |
| **11** | Geoscape | Country, Region, Biome | geoscape.toml |
| **12** | Crafts | Craft, Craft Weapon | crafts.toml |
| **13** | Interception | Interception Combat | interception.toml |
| **14** | General | Settings, Difficulty | config.toml |

---

## SCHEMA STANDARDS

### Field Type Conventions

```
string         - Text (e.g., "rifle", "human", "command_center")
integer        - Whole number (e.g., 50, 100, 1000)
number         - Decimal number (e.g., 1.5, 0.75, 2.25)
boolean        - true or false
array          - [item1, item2, item3]
table          - { field1 = value, field2 = value }
```

### TOML Array vs Section

```
# Array (multiple items)
[[weapon]]
id = "rifle"
name = "Rifle"

[[weapon]]
id = "plasma_rifle"
name = "Plasma Rifle"

# Section (single item)
[mod]
id = "core"
name = "Core Game Data"
```

### Required vs Optional

- **REQUIRED** - Must be present, no default
- **OPTIONAL** - Can be omitted, uses default if missing
- **DEFAULT** - Value used if field omitted

---

## 1. WEAPONS & ARMOUR

### 1.1 Weapon Entity

**TOML Array**: `[[weapon]]`  
**Lua Access**: `DataLoader.weapons.get("rifle")`  
**File**: `rules/items/weapons.toml`

#### Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric + underscore | Unique identifier |
| `name` | string | YES | - | any | Display name in UI |
| `description` | string | NO | "" | any | Flavor text/tooltip |
| `type` | string | YES | - | "primary", "secondary", "melee", "grenade", "craft" | Weapon slot |
| `damage` | integer | YES | - | 10-150 | Base damage output |
| `accuracy` | integer | YES | - | 0-100 | Base accuracy % |
| `range` | integer | YES | - | 5-100 | Attack range (tiles) |
| `ammo_type` | string | YES | - | ammo ID or "none" | Ammunition type |
| `fire_rate` | integer | NO | 1 | 1-5 | Shots per turn |
| `ap_cost` | integer | NO | 3 | 1-5 | Action points to fire |
| `ep_cost` | integer | NO | 5 | 0-25 | Energy points to fire |
| `cost` | integer | YES | - | 0-99999 | Manufacture cost |
| `tech_level` | string | YES | - | "conventional", "plasma", "laser", "alien" | Technology tier |
| `weight` | integer | NO | 5 | 1-20 | Encumbrance penalty |
| `rate_of_fire` | number | NO | 1.0 | 0.5-3.0 | Fire speed multiplier |

#### Example

```toml
[[weapon]]
id = "rifle"
name = "Rifle"
description = "Standard issue rifle"
type = "primary"
damage = 50
accuracy = 70
range = 25
ammo_type = "rifle_ammo"
fire_rate = 1
ap_cost = 3
ep_cost = 10
cost = 800
tech_level = "conventional"
weight = 5
rate_of_fire = 1.0

[[weapon]]
id = "plasma_rifle"
name = "Plasma Rifle"
description = "Alien plasma weapon"
type = "primary"
damage = 70
accuracy = 70
range = 25
ammo_type = "plasma_cartridge"
fire_rate = 1
ap_cost = 3
ep_cost = 15
cost = 0
tech_level = "plasma"
weight = 6
```

#### Lua Usage

```lua
local weapon = DataLoader.weapons.get("rifle")
if weapon then
    print("Weapon: " .. weapon.name)
    print("Damage: " .. weapon.damage)
    print("Accuracy: " .. weapon.accuracy .. "%")
end

-- Get all conventional weapons
local convWeapons = DataLoader.weapons.getByType("conventional")

-- Get all weapon IDs
local allWeaponIds = DataLoader.weapons.getAllIds()
```

#### Modding Notes

- Damage range: 10-150 (prevents broken balance)
- Accuracy should match damage (high damage = lower accuracy)
- Cost of 0 for alien/captured weapons (no manufacture)
- AP cost determines usefulness in turn-based combat
- Weight affects unit movement speed

---

### 1.2 Armour Entity

**TOML Array**: `[[armour]]`  
**Lua Access**: `DataLoader.armours.get("combat_armor_light")`  
**File**: `rules/items/armours.toml`

#### Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric + underscore | Unique identifier |
| `name` | string | YES | - | any | Display name |
| `description` | string | NO | "" | any | Flavor text |
| `type` | string | YES | - | "light", "standard", "heavy", "power", "alien", "hazmat", "stealth" | Armour category |
| `armor_value` | integer | YES | - | 0-30 | Damage reduction |
| `weight` | integer | YES | - | 0-20 | Movement penalty |
| `cost` | integer | YES | - | 0-99999 | Manufacture cost |
| `tech_level` | string | YES | - | "conventional", "advanced", "plasma", "laser", "alien" | Technology tier |
| `mobility_penalty` | integer | NO | weight | 0-30 | AP reduction % |
| `sight_penalty` | integer | NO | 0 | 0-20 | Sight range reduction % |
| `fire_resistance` | integer | NO | 0 | 0-100 | Fire damage reduction % |
| `acid_resistance` | integer | NO | 0 | 0-100 | Acid damage reduction % |

#### Example

```toml
[[armour]]
id = "combat_armor_light"
name = "Light Combat Armor"
description = "Basic protective gear"
type = "light"
armor_value = 5
weight = 3
cost = 400
tech_level = "conventional"
mobility_penalty = 0
sight_penalty = 0

[[armour]]
id = "combat_armor_heavy"
name = "Heavy Combat Armor"
description = "Heavy reinforced armor suit"
type = "heavy"
armor_value = 15
weight = 8
cost = 1500
tech_level = "conventional"
mobility_penalty = 15
sight_penalty = 5

[[armour]]
id = "power_suit"
name = "Power Suit"
description = "Powered exoskeleton armor"
type = "power"
armor_value = 20
weight = 12
cost = 3500
tech_level = "advanced"
mobility_penalty = 10
sight_penalty = 0
fire_resistance = 25
```

#### Lua Usage

```lua
local armor = DataLoader.armours.get("combat_armor_light")
if armor then
    print("Armor: " .. armor.name)
    print("Protection: " .. armor.armor_value)
    print("Weight: " .. armor.weight)
end

-- Get all light armor
local lightArmors = DataLoader.armours.getByType("light")

-- Get all armors
local allArmorIds = DataLoader.armours.getAllIds()
```

#### Modding Notes

- Weight = movement speed penalty (0 = no penalty, 8+ = significant slowdown)
- Armor value caps at 30 (prevents invulnerability)
- Heavy armor (weight 8+) should have mobility penalties
- Alien armor has 0 weight (no penalty for aliens)
- Special resists (fire, acid) are optional for special armors

---

### 1.3 Ammo Entity

**TOML Array**: `[[ammo]]`  
**Lua Access**: `DataLoader.ammo.get("rifle_ammo")`  
**File**: `rules/items/ammo.toml`

#### Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric + underscore | Unique identifier |
| `name` | string | YES | - | any | Display name |
| `ammo_type` | string | YES | - | "projectile", "energy", "explosive", "laser", "plasma" | Ammo category |
| `cost_per_round` | integer | YES | - | 1-100 | Cost per shot |
| `weight_per_round` | number | YES | - | 0.1-5.0 | Weight per shot |
| `magazine_size` | integer | YES | - | 10-100 | Rounds per magazine |
| `damage_modifier` | number | NO | 1.0 | 0.5-2.0 | Damage multiplier |

#### Example

```toml
[[ammo]]
id = "rifle_ammo"
name = "Rifle Ammunition"
ammo_type = "projectile"
cost_per_round = 5
weight_per_round = 0.5
magazine_size = 30
damage_modifier = 1.0

[[ammo]]
id = "plasma_cartridge"
name = "Plasma Cartridge"
ammo_type = "plasma"
cost_per_round = 25
weight_per_round = 1.0
magazine_size = 20
damage_modifier = 1.15
```

---

## 2. UNITS & CLASSES

### 2.1 Unit Class Entity

**TOML Section**: `[unit_class]` or array `[[unit_class]]`  
**Lua Access**: `DataLoader.unitClasses.get("soldier")`  
**File**: `rules/units/classes.toml`

#### Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric + underscore | Class identifier |
| `name` | string | YES | - | any | Display name |
| `side` | string | YES | - | "human", "alien", "civilian" | Unit faction |
| `description` | string | NO | "" | any | Flavor text |
| `base_health` | integer | YES | - | 6-15 | Starting HP |
| `base_stats` | table | YES | - | see below | Initial stat values |
| `available_skills` | array | NO | [] | skill IDs | Available abilities |
| `promotion_tree` | array | NO | [] | class IDs | Next rank options |
| `starting_equipment` | table | NO | {} | equipment IDs | Default loadout |

**base_stats fields**:
```
aim          - integer 6-12 - Accuracy
melee        - integer 6-12 - Melee damage
react        - integer 6-12 - Reaction fire chance
speed        - integer 6-12 - Movement speed
sight        - integer 6-12 - Sight range (16 hex base)
armor        - integer 0-2  - Damage reduction
```

#### Example

```toml
[[unit_class]]
id = "soldier"
name = "Soldier"
side = "human"
description = "Standard infantry unit"
base_health = 10
base_stats = {aim=8, melee=6, react=6, speed=8, sight=10, armor=1}
available_skills = ["shoot", "throw", "suppress"]
promotion_tree = ["heavy_soldier", "squad_leader"]
starting_equipment = {weapon="rifle", armor="combat_armor_light"}

[[unit_class]]
id = "heavy_soldier"
name = "Heavy Soldier"
side = "human"
description = "Heavily armored support unit"
base_health = 12
base_stats = {aim=6, melee=6, react=5, speed=6, sight=9, armor=2}
available_skills = ["shoot", "throw", "suppress", "overwatch"]
promotion_tree = []
starting_equipment = {weapon="machine_gun", armor="combat_armor_heavy"}
```

---

### 2.2 Unit Instance Entity

**TOML Array**: `[[unit]]`  
**Lua Access**: `DataLoader.units.get("rifleman_recruit")`  
**File**: `rules/units/soldiers.toml`, `rules/units/aliens.toml`, `rules/units/civilians.toml`

#### Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric + underscore | Unique unit ID |
| `name` | string | YES | - | any | Unit type name |
| `class` | string | YES | - | class ID | Unit class reference |
| `faction` | string | NO | - | faction ID | Faction affiliation |
| `side` | string | YES | - | "human", "alien", "civilian" | Faction side |
| `xp_for_next_rank` | integer | YES | - | 100-3000 | XP to promote |
| `recruitment_cost` | integer | YES | - | 0-10000 | Cost to recruit |
| `traits` | array | NO | [] | trait IDs | Special characteristics |

#### Example

```toml
[[unit]]
id = "rifleman_recruit"
name = "Rifleman (Recruit)"
class = "soldier"
faction = "player"
side = "human"
xp_for_next_rank = 100
recruitment_cost = 0
traits = []

[[unit]]
id = "sectoid_leader"
name = "Sectoid Leader"
class = "sectoid_commander"
faction = "faction_sectoids"
side = "alien"
xp_for_next_rank = 5000
recruitment_cost = 0
traits = ["leader", "psyonic"]
```

---

## 3. FACILITIES

### 3.1 Facility Entity

**TOML Array**: `[[facility]]`  
**Lua Access**: `DataLoader.facilities.get("command_center")`  
**File**: `rules/facilities/base_facilities.toml`, `rules/facilities/research_facilities.toml`, `rules/facilities/manufacturing.toml`, `rules/facilities/defense.toml`

#### Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric + underscore | Unique facility ID |
| `name` | string | YES | - | any | Display name |
| `description` | string | NO | "" | any | Flavor text |
| `type` | string | YES | - | "command", "residential", "manufacturing", "storage", "power", "detection", "medical", "research", "defense" | Facility category |
| `width` | integer | YES | - | 1-5 | Grid width (hexes) |
| `height` | integer | YES | - | 1-5 | Grid height (hexes) |
| `cost` | integer | YES | - | 500-99999 | Build cost |
| `time_to_build` | integer | YES | - | 1-100 | Build time (days) |
| `maintenance_cost` | integer | YES | - | 0-500 | Monthly upkeep |
| `capacity` | integer | NO | 0 | 0-100 | Storage/personnel limit |
| `production_rate` | number | NO | 1.0 | 0.5-3.0 | Manufacturing multiplier |
| `power_generation` | integer | NO | 0 | 0-50 | Power produced |
| `power_consumption` | integer | NO | 0 | 0-50 | Power consumed |
| `detection_radius` | integer | NO | 0 | 0-500 | Radar range (km) |
| `specialization` | string | NO | "" | "armor", "ammunition", "research", "medical" | Workshop specialization |
| `effect` | string | NO | "" | effect ID | Special ability |
| `adjacency_bonus_type` | string | NO | "" | "research", "manufacturing" | Adjacency synergy |

#### Example

```toml
[[facility]]
id = "command_center"
name = "Command Center"
description = "Strategic command and control center"
type = "command"
width = 2
height = 2
cost = 2000
time_to_build = 10
maintenance_cost = 50
effect = "base_command"
power_consumption = 5

[[facility]]
id = "workshop"
name = "Workshop"
description = "Equipment manufacturing"
type = "manufacturing"
width = 2
height = 2
cost = 1500
time_to_build = 8
maintenance_cost = 30
production_rate = 1.2
power_consumption = 10
specialization = "general"
adjacency_bonus_type = "manufacturing"

[[facility]]
id = "power_generator"
name = "Power Generator"
description = "Nuclear power generation"
type = "power"
width = 1
height = 1
cost = 1200
time_to_build = 8
maintenance_cost = 25
power_generation = 10
```

---

## CONTINUED IN NEXT FILE...

*This document continues with sections on*:
- **4. Research & Manufacturing** (Research Projects, Recipes)
- **5. Items & Resources** (Resources, Equipment)
- **6. Missions** (Mission Types, Objectives)
- **7. Economy** (Marketplace Items, Suppliers)
- **8. Factions** (Faction Definitions)
- **9. Campaigns** (Campaign Phases)
- **10. Narrative** (Story Events, Quests)

*See linked API files for complete schema reference.*

---

## General Usage Guidelines

### Field Naming Conventions

- Use `snake_case` for all field names
- Use `_id` suffix for references to other entities
- Use `_cost`, `_time`, `_rate` suffixes for numeric values

### ID Naming Conventions

- Use lowercase with underscores: `combat_armor_heavy`
- Include category prefix if needed: `weapon_rifle`, `facility_command_center`
- Keep IDs under 40 characters for readability

### TOML Best Practices

1. **Group related fields** together
2. **Use comments** to explain non-obvious values
3. **Organize arrays** by category (weapons, aliens, etc.)
4. **Use descriptive names** that match gameplay meaning
5. **Validate numbers** are in reasonable ranges

### Modding Workflow

1. Copy entity TOML template to your mod file
2. Modify ID, name, and properties
3. Add to appropriate array in TOML file
4. Test with Love2D console
5. Check console for load errors
6. Verify entity appears in game

---

## Next Steps

- See **API_WEAPONS_AND_ARMOR.md** for weapons/armor API
- See **API_UNITS_AND_CLASSES.md** for units/classes API
- See **API_FACILITIES.md** for facilities API
- See **MOD_DEVELOPER_GUIDE.md** for complete modding guide

