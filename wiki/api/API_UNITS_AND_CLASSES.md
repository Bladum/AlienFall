# API Reference: Units & Classes System

**Version**: 1.0.0  
**Date**: October 21, 2025  
**Focus**: Unit classes, unit types, traits, and progression system

---

## Quick Start

### Loading Unit Classes

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get a unit class
local soldierClass = DataLoader.unitClasses.get("soldier")
if soldierClass then
    print(soldierClass.name)
end

-- Get all classes
local allClasses = DataLoader.unitClasses.getAllIds()

-- Get classes by side
local humanClasses = DataLoader.unitClasses.getBySide("human")
local alienClasses = DataLoader.unitClasses.getBySide("alien")
```

### Loading Unit Types

```lua
-- Get specific unit type
local rifleman = DataLoader.units.get("rifleman_recruit")

-- Get all units
local allUnits = DataLoader.units.getAllIds()

-- Get units by faction
local playerUnits = DataLoader.units.getByFaction("player")
local sectoidUnits = DataLoader.units.getByFaction("faction_sectoids")

-- Get units by side
local humanUnits = DataLoader.units.getBySide("human")
```

---

## Unit Class System

### Class Structure

**File**: `rules/units/classes.toml`  
**Array**: `[[unit_class]]`  
**Access**: `DataLoader.unitClasses.get(classId)`

A unit class is a template defining:
- Base statistics (health, aim, speed, etc.)
- Available abilities/skills
- Promotion pathway
- Equipment slots

### Unit Class Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric_underscore | Class identifier |
| `name` | string | YES | - | any | Display name |
| `side` | string | YES | - | "human", "alien", "civilian" | Faction side |
| `description` | string | NO | "" | any | Flavor text |
| `base_health` | integer | YES | - | 6-15 | Starting HP |
| `base_stats` | table | YES | - | see below | Base statistics table |
| `available_skills` | array | NO | [] | skill IDs | Learnable abilities |
| `promotion_tree` | array | NO | [] | class IDs | Next rank options |
| `starting_equipment` | table | NO | {} | equipment table | Default loadout |

### Base Stats Field

All classes require `base_stats` table with these fields:

```toml
base_stats = {
    aim = 8,              # Accuracy (6-12)
    melee = 6,            # Melee damage (6-12)
    react = 6,            # Reaction fire (6-12)
    speed = 8,            # Movement speed (6-12)
    sight = 10,           # Sight range bonus (0-10)
    armor = 1             # Base damage reduction (0-2)
}
```

**Stat Ranges & Meanings**:

| Stat | Min | Max | Effect |
|------|-----|-----|--------|
| **aim** | 6 | 12 | Affects weapon accuracy % |
| **melee** | 6 | 12 | Melee damage bonus |
| **react** | 6 | 12 | Reaction fire chance % |
| **speed** | 6 | 12 | Movement tiles per turn |
| **sight** | 0 | 10 | Bonus to sight range (base 16 hex) |
| **armor** | 0 | 2 | Base damage reduction |

### Human Unit Classes

```toml
# Soldier - Balanced infantry
[[unit_class]]
id = "soldier"
name = "Soldier"
side = "human"
description = "Standard infantry unit - balanced stats"
base_health = 10
base_stats = {aim=8, melee=6, react=6, speed=8, sight=10, armor=1}
available_skills = ["shoot", "throw", "suppress"]
promotion_tree = ["heavy_soldier", "squad_leader"]
starting_equipment = {weapon="rifle", armor="combat_armor_light"}

# Heavy Soldier - Tank class
[[unit_class]]
id = "heavy_soldier"
name = "Heavy Soldier"
side = "human"
description = "Heavily armored support - high HP, slow"
base_health = 12
base_stats = {aim=6, melee=6, react=5, speed=6, sight=9, armor=2}
available_skills = ["shoot", "throw", "suppress", "overwatch"]
promotion_tree = []
starting_equipment = {weapon="machine_gun", armor="combat_armor_heavy"}

# Sniper - Precision shooter
[[unit_class]]
id = "sniper"
name = "Sniper"
side = "human"
description = "Precision marksman - high accuracy, long range"
base_health = 9
base_stats = {aim=12, melee=4, react=6, speed=7, sight=12, armor=0}
available_skills = ["shoot", "headshot", "overwatch"]
promotion_tree = ["master_sniper"]
starting_equipment = {weapon="sniper_rifle", armor="combat_armor_light"}

# Scout - Infiltrator
[[unit_class]]
id = "scout"
name = "Scout"
side = "human"
description = "Fast infiltrator - high mobility, low health"
base_health = 8
base_stats = {aim=7, melee=7, react=8, speed=12, sight=12, armor=0}
available_skills = ["shoot", "throw", "run", "scout"]
promotion_tree = ["ghost"]
starting_equipment = {weapon="rifle", armor="stealth_suit"}

# Support - Medic/Engineer
[[unit_class]]
id = "support"
name = "Support"
side = "human"
description = "Medic and engineer - versatile utility"
base_health = 9
base_stats = {aim=7, melee=5, react=7, speed=8, sight=10, armor=1}
available_skills = ["medic", "engineer", "repair", "throw"]
promotion_tree = ["field_medic"]
starting_equipment = {weapon="pistol", armor="combat_armor_standard"}
```

### Alien Unit Classes

```toml
# Sectoid - Basic alien
[[unit_class]]
id = "sectoid"
name = "Sectoid"
side = "alien"
description = "Basic alien infantry - average stats"
base_health = 9
base_stats = {aim=8, melee=6, react=7, speed=8, sight=10, armor=1}
available_skills = ["shoot", "psyonic_touch"]
promotion_tree = ["sectoid_leader"]
starting_equipment = {weapon="plasma_pistol", armor="muton_hide"}

# Sectoid Commander - Leader
[[unit_class]]
id = "sectoid_leader"
name = "Sectoid Commander"
side = "alien"
description = "Leader of the hive - psychic abilities"
base_health = 11
base_stats = {aim=9, melee=7, react=8, speed=8, sight=11, armor=2}
available_skills = ["shoot", "psyonic", "mind_control", "leader"]
promotion_tree = []
starting_equipment = {weapon="plasma_rifle", armor="muton_hide_heavy"}

# Muton - Heavy alien
[[unit_class]]
id = "muton"
name = "Muton"
side = "alien"
description = "Heavy alien warrior - strong and tough"
base_health = 14
base_stats = {aim=7, melee=10, react=5, speed=7, sight=9, armor=3}
available_skills = ["shoot", "melee_attack", "smash"]
promotion_tree = ["elite_muton"]
starting_equipment = {weapon="plasma_rifle", armor="muton_hide_heavy"}

# Floater - Aerial alien
[[unit_class]]
id = "floater"
name = "Floater"
side = "alien"
description = "Flying alien - mobile ranged attacker"
base_health = 8
base_stats = {aim=9, melee=4, react=8, speed=10, sight=11, armor=0}
available_skills = ["shoot", "fly", "strafe"]
promotion_tree = ["elite_floater"]
starting_equipment = {weapon="plasma_pistol", armor="floater_hide"}

# Chryssalid - Melee insectoid
[[unit_class]]
id = "chryssalid"
name = "Chryssalid"
side = "alien"
description = "Insectoid melee fighter - fast and deadly"
base_health = 10
base_stats = {aim=5, melee=12, react=9, speed=11, sight=10, armor=2}
available_skills = ["melee_attack", "charge", "cocoon"]
promotion_tree = []
starting_equipment = {weapon="none", armor="chryssalid_carapace"}
```

### Civilian Classes

```toml
# Civilian - Non-combatant
[[unit_class]]
id = "civilian"
name = "Civilian"
side = "civilian"
description = "Untrained civilian - minimal combat capability"
base_health = 6
base_stats = {aim=4, melee=3, react=3, speed=8, sight=8, armor=0}
available_skills = []
promotion_tree = []
starting_equipment = {}
```

---

## Unit Types System

### Unit Type Structure

**Files**:
- `rules/units/soldiers.toml` - Human units
- `rules/units/aliens.toml` - Alien units
- `rules/units/civilians.toml` - Civilians

**Array**: `[[unit]]`  
**Access**: `DataLoader.units.get(unitId)`

A unit type is a specific instance class:
- Inherits stats from a unit class
- Can have specialized traits
- Specifies recruitment/research costs
- Defines faction affiliation

### Unit Type Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric_underscore | Unique unit ID |
| `name` | string | YES | - | any | Unit type name |
| `class` | string | YES | - | class ID | References unit class |
| `faction` | string | NO | - | faction ID | Faction affiliation |
| `side` | string | YES | - | "human", "alien", "civilian" | Side affiliation |
| `xp_for_next_rank` | integer | YES | - | 100-3000 | XP to promote |
| `recruitment_cost` | integer | YES | - | 0-10000 | Cost to recruit (credits) |
| `recruitment_time` | integer | NO | 5 | 1-30 | Days to recruit |
| `traits` | array | NO | [] | trait IDs | Special characteristics |

### Human Unit Types

```toml
# Rifleman - Basic soldier
[[unit]]
id = "rifleman_recruit"
name = "Rifleman (Recruit)"
class = "soldier"
faction = "player"
side = "human"
xp_for_next_rank = 100
recruitment_cost = 0
recruitment_time = 1
traits = []

[[unit]]
id = "rifleman_veteran"
name = "Rifleman (Veteran)"
class = "soldier"
faction = "player"
side = "human"
xp_for_next_rank = 300
recruitment_cost = 500
recruitment_time = 3
traits = ["veteran"]

# Heavy Gunner - Tank
[[unit]]
id = "heavy_gunner"
name = "Heavy Gunner"
class = "heavy_soldier"
faction = "player"
side = "human"
xp_for_next_rank = 150
recruitment_cost = 200
recruitment_time = 2
traits = ["tough"]

# Sharpshooter - Sniper
[[unit]]
id = "sharpshooter"
name = "Sharpshooter"
class = "sniper"
faction = "player"
side = "human"
xp_for_next_rank = 200
recruitment_cost = 300
recruitment_time = 2
traits = ["marksman"]
```

### Alien Unit Types

```toml
# Sectoid - Common alien
[[unit]]
id = "sectoid"
name = "Sectoid"
class = "sectoid"
faction = "faction_sectoids"
side = "alien"
xp_for_next_rank = 500
recruitment_cost = 0
traits = []

# Sectoid Commander - Leader
[[unit]]
id = "sectoid_commander"
name = "Sectoid Commander"
class = "sectoid_leader"
faction = "faction_sectoids"
side = "alien"
xp_for_next_rank = 1000
recruitment_cost = 0
traits = ["leader", "psyonic"]

# Muton - Heavy alien
[[unit]]
id = "muton_warrior"
name = "Muton Warrior"
class = "muton"
faction = "faction_mutons"
side = "alien"
xp_for_next_rank = 600
recruitment_cost = 0
traits = []
```

---

## Traits System

### Trait Purpose

Traits are special characteristics that modify unit behavior and stats:
- Personality traits (Brave, Coward, Aggressive)
- Physical traits (Strong, Weak, Fast)
- Learned traits (Veteran, Trained, Disciplined)

### Common Traits

```
brave          - +25% melee damage, -10% panic chance
coward         - -20% accuracy under fire, +20% panic chance
aggressive     - +15% damage, -5 armor
cautious       - +10% armor, -15% damage
leader         - Squad morale bonus
psyonic        - Psychic abilities
veteran        - +20% all stats
marksman       - +20% accuracy
tough          - +25% health
```

### Trait Assignment

```toml
# Traits array in unit definition
traits = ["veteran", "marksman"]

# Multiple traits can be combined
traits = ["brave", "marksman", "tough"]
```

---

## Promotion & Experience System

### Rank Progression

Units progress through ranks 0-6:

| Rank | XP Needed | Example Title | Role |
|------|-----------|--------------|------|
| **0** | 0 | Recruit | Starting |
| **1** | 100 | Veteran | Experienced |
| **2** | 250 | Expert | Seasoned |
| **3** | 500 | Specialist | Trained |
| **4** | 1000 | Expert | Highly trained |
| **5** | 1500 | Master | Top tier |
| **6** | 2500 | Legendary | Elite |

### XP Requirements

XP is cumulative (need 100 total for rank 1, 250 more for rank 2, etc.)

```lua
-- Example progression
xp_requirements = {
    0 -> Rank 1: 100 XP
    1 -> Rank 2: 250 XP (total 350)
    2 -> Rank 3: 500 XP (total 850)
    3 -> Rank 4: 1000 XP (total 1850)
    4 -> Rank 5: 1500 XP (total 3350)
    5 -> Rank 6: 2500 XP (total 5850)
}
```

### Setting Promotion XP

In unit definition:
```toml
[[unit]]
id = "rifleman_recruit"
name = "Rifleman (Recruit)"
class = "soldier"
xp_for_next_rank = 100  # XP needed to rank 1
```

---

## Lua Usage Patterns

### Accessing Unit Stats

```lua
-- Get unit class stats
local unitClass = DataLoader.unitClasses.get("soldier")
local baseHealth = unitClass.base_health
local baseStats = unitClass.base_stats
local aim = baseStats.aim

-- Calculate modified health (with armor bonus)
function getModifiedHealth(unitClass, armor)
    local baseHealth = unitClass.base_health or 10
    local armorHealth = armor.armor_value or 0
    return baseHealth + math.floor(armorHealth / 2)
end

-- Get promotion tree (next rank options)
function getPromotions(unitClass)
    return unitClass.promotion_tree or {}
end
```

### Accessing Unit Traits

```lua
-- Get unit traits
local unit = DataLoader.units.get("rifleman_veteran")
local traits = unit.traits or {}

-- Check for specific trait
function hasTrait(unit, traitId)
    if not unit.traits then return false end
    for _, trait in ipairs(unit.traits) do
        if trait == traitId then return true end
    end
    return false
end

-- Get trait effects
function applyTraitModifiers(unit, baseStats)
    local modified = baseStats
    if hasTrait(unit, "veteran") then
        modified.aim = modified.aim + 2
        modified.speed = modified.speed + 1
    end
    if hasTrait(unit, "brave") then
        modified.melee = modified.melee + 3
    end
    return modified
end
```

### Squad Formation

```lua
-- Create squad from composition
function createSquadFromComposition(compositionId)
    local composition = getSquadComposition(compositionId)
    if not composition then return {} end
    
    local squad = {}
    for i, classId in ipairs(composition.unit_class_list) do
        local unit = createUnitFromClass(classId)
        table.insert(squad, unit)
    end
    return squad
end

-- Get all soldiers available for deployment
function getAvailableSoldiers(baseId)
    local availableSoldiers = {}
    local allSoldiers = DataLoader.units.getByFaction("player")
    
    for _, soldierId in ipairs(allSoldiers) do
        -- Check if soldier is at base and not injured
        if isSoldierAvailable(baseId, soldierId) then
            table.insert(availableSoldiers, soldierId)
        end
    end
    
    return availableSoldiers
end
```

---

## Modding: Creating Custom Units

### Step 1: Create Unit Class

```toml
# In mods/mymod/content/rules/units/classes.toml

[[unit_class]]
id = "my_soldier_class"
name = "My Soldier"
side = "human"
description = "Custom soldier class"
base_health = 11
base_stats = {aim=9, melee=7, react=7, speed=8, sight=10, armor=1}
available_skills = ["shoot", "throw", "suppress"]
promotion_tree = []
starting_equipment = {weapon="rifle", armor="combat_armor_light"}
```

### Step 2: Create Unit Type

```toml
# In mods/mymod/content/rules/units/soldiers.toml

[[unit]]
id = "my_custom_recruit"
name = "Custom Recruit"
class = "my_soldier_class"
faction = "player"
side = "human"
xp_for_next_rank = 100
recruitment_cost = 0
traits = []
```

### Step 3: Test

```bash
lovec "engine"
```

Check console for:
```
[DataLoader] ✓ Loaded X unit classes
[DataLoader] ✓ Loaded X unit types
```

### Step 4: Use in Code

```lua
local myUnit = DataLoader.units.get("my_custom_recruit")
```

---

## Balance Guidelines

### Health Balance

```
Base Health = 6 + (armor * 2) + (toughness bonus)
  Light class:    6-9 HP
  Standard class: 9-12 HP
  Heavy class:    12-15 HP
  Tank class:     15+ HP
```

### Stat Balance

```
Lower health = Higher offense (damage, accuracy)
Higher health = Lower offense
Total effectiveness should be balanced
```

### XP Requirements

```
Rank 1: 100 XP (early promotion, easy)
Rank 2: 250 XP (mid, achievable)
Rank 3: 500 XP (challenging)
Rank 4: 1000 XP (difficult)
Rank 5+: 1500+ XP (endgame)
```

---

## See Also

- **API_SCHEMA_REFERENCE.md** - Complete schema reference
- **API_WEAPONS_AND_ARMOR.md** - Weapons and armor documentation
- **API_FACILITIES.md** - Facility documentation
- **MOD_DEVELOPER_GUIDE.md** - Complete modding guide

