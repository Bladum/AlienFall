# API Reference: Weapons, Armour & Equipment

**Version**: 1.0.0  
**Date**: October 21, 2025  
**Focus**: Comprehensive weapon/armour/equipment documentation with 50+ examples

---

## Quick Start

### Loading Weapons

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get a specific weapon
local rifle = DataLoader.weapons.get("rifle")
if rifle then
    print(rifle.name .. " - Damage: " .. rifle.damage)
end

-- Get all weapon IDs
local allWeapons = DataLoader.weapons.getAllIds()

-- Get weapons by type
local primaryWeapons = DataLoader.weapons.getByType("primary")
```

### Loading Armour

```lua
-- Get specific armour
local armor = DataLoader.armours.get("combat_armor_heavy")
if armor then
    print(armor.name .. " - Protection: " .. armor.armor_value)
end

-- Get all armours
local allArmors = DataLoader.armours.getAllIds()

-- Get armours by type
local heavyArmors = DataLoader.armours.getByType("heavy")
```

---

## Weapon System

### Weapon Types

| Type | Purpose | Examples | Ammo |
|------|---------|----------|------|
| **primary** | Main weapon, 1 per unit | Rifle, Plasma Rifle, Laser Rifle | Yes |
| **secondary** | Sidearm backup | Pistol, Plasma Pistol, Laser Pistol | Yes |
| **melee** | Close combat | Sword, Plasma Blade | No |
| **grenade** | Throwable explosive | Grenade, Flashbang | No |
| **craft** | Aircraft mounted | Cannon, Missile | Yes |

### Weapon Technology Levels

| Level | Cost Range | Examples | Availability |
|-------|-----------|----------|---|
| **conventional** | 400-2000 | Rifle, Pistol, Machine Gun | Game start |
| **plasma** | 0* | Plasma Rifle, Plasma Cannon | Captured from aliens |
| **laser** | 1500-2500 | Laser Rifle, Laser Pistol | Late game research |
| **alien** | 0* | Alien Disruptor | Post-capture analysis |

*Cost 0 = Cannot manufacture, captured only

### Weapon Stat Ranges

| Stat | Min | Max | Notes |
|------|-----|-----|-------|
| **Damage** | 10 | 150 | Balanced: High damage = low accuracy |
| **Accuracy** | 0 | 100 | % chance to hit at range |
| **Range** | 5 | 100 | Distance in tiles |
| **AP Cost** | 1 | 5 | Action points to fire |
| **EP Cost** | 0 | 25 | Energy points to fire |
| **Fire Rate** | 1 | 5 | Shots per turn |
| **Weight** | 1 | 20 | Encumbrance |
| **Cost** | 0 | 99999 | Credits to manufacture |

---

## Complete Weapon Examples

### Conventional Weapons

```toml
# Rifle - Standard primary weapon
[[weapon]]
id = "rifle"
name = "Rifle"
description = "Standard issue rifle - reliable, accurate, versatile"
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

# Machine Gun - Rapid fire, lower accuracy
[[weapon]]
id = "machine_gun"
name = "Machine Gun"
description = "Rapid-fire heavy weapon - high damage but inaccurate"
type = "primary"
damage = 45
accuracy = 50
range = 20
ammo_type = "rifle_ammo"
fire_rate = 3
ap_cost = 4
ep_cost = 15
cost = 1500
tech_level = "conventional"
weight = 7
rate_of_fire = 1.5

# Sniper Rifle - High damage, high accuracy, limited ammo
[[weapon]]
id = "sniper_rifle"
name = "Sniper Rifle"
description = "Precision rifle - extremely accurate, high damage"
type = "primary"
damage = 70
accuracy = 90
range = 40
ammo_type = "rifle_ammo"
fire_rate = 1
ap_cost = 4
ep_cost = 12
cost = 1200
tech_level = "conventional"
weight = 6
rate_of_fire = 0.8

# Rocket Launcher - Area of effect
[[weapon]]
id = "rocket_launcher"
name = "Rocket Launcher"
description = "Heavy explosive weapon - devastating area damage"
type = "primary"
damage = 120
accuracy = 40
range = 30
ammo_type = "rocket"
fire_rate = 1
ap_cost = 5
ep_cost = 20
cost = 2000
tech_level = "conventional"
weight = 10
rate_of_fire = 0.5

# Pistol - Secondary weapon
[[weapon]]
id = "pistol"
name = "Pistol"
description = "Standard issue sidearm - quick but weak"
type = "secondary"
damage = 35
accuracy = 60
range = 15
ammo_type = "pistol_ammo"
fire_rate = 1
ap_cost = 2
ep_cost = 5
cost = 400
tech_level = "conventional"
weight = 3
rate_of_fire = 1.2

# Tactical Knife - Melee weapon
[[weapon]]
id = "tactical_knife"
name = "Tactical Knife"
description = "Close combat blade - silent, reliable"
type = "melee"
damage = 30
accuracy = 85
range = 1
ammo_type = "none"
fire_rate = 2
ap_cost = 2
ep_cost = 0
cost = 100
tech_level = "conventional"
weight = 1
```

### Plasma Weapons (Alien Technology)

```toml
# Plasma Pistol - Alien secondary
[[weapon]]
id = "plasma_pistol"
name = "Plasma Pistol"
description = "Alien plasma weapon - powerful sidearm"
type = "secondary"
damage = 55
accuracy = 70
range = 15
ammo_type = "plasma_cartridge"
fire_rate = 1
ap_cost = 2
ep_cost = 10
cost = 0
tech_level = "plasma"
weight = 4
rate_of_fire = 1.1

# Plasma Rifle - Alien primary
[[weapon]]
id = "plasma_rifle"
name = "Plasma Rifle"
description = "Standard alien plasma rifle - effective and reliable"
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
rate_of_fire = 1.0

# Plasma Cannon - Heavy alien weapon
[[weapon]]
id = "plasma_cannon"
name = "Plasma Cannon"
description = "Heavy alien plasma cannon - devastating power"
type = "primary"
damage = 90
accuracy = 60
range = 30
ammo_type = "plasma_cartridge"
fire_rate = 1
ap_cost = 4
ep_cost = 25
cost = 0
tech_level = "plasma"
weight = 9
rate_of_fire = 0.7
```

### Laser Weapons (Research Technology)

```toml
# Laser Pistol - Secondary energy weapon
[[weapon]]
id = "laser_pistol"
name = "Laser Pistol"
description = "Compact laser sidearm - precise and efficient"
type = "secondary"
damage = 45
accuracy = 75
range = 15
ammo_type = "laser_power_pack"
fire_rate = 2
ap_cost = 2
ep_cost = 8
cost = 1500
tech_level = "laser"
weight = 3
rate_of_fire = 1.3

# Laser Rifle - Primary energy weapon
[[weapon]]
id = "laser_rifle"
name = "Laser Rifle"
description = "Precision laser weapon - excellent accuracy"
type = "primary"
damage = 65
accuracy = 85
range = 25
ammo_type = "laser_power_pack"
fire_rate = 1
ap_cost = 3
ep_cost = 12
cost = 2500
tech_level = "laser"
weight = 5
rate_of_fire = 1.0

# Laser Cannon - Heavy laser
[[weapon]]
id = "laser_cannon"
name = "Laser Cannon"
description = "Heavy laser weapon - extreme precision and damage"
type = "primary"
damage = 85
accuracy = 80
range = 35
ammo_type = "laser_power_pack"
fire_rate = 1
ap_cost = 4
ep_cost = 18
cost = 3500
tech_level = "laser"
weight = 8
rate_of_fire = 0.9
```

---

## Armour System

### Armour Types

| Type | Protection | Weight | Uses |
|------|-----------|--------|------|
| **light** | 0-10 | 2-5 | High mobility soldiers |
| **standard** | 5-15 | 4-8 | General purpose |
| **heavy** | 10-20 | 8-15 | Tank units |
| **power** | 15-25 | 10-20 | Advanced tech |
| **alien** | 5-20 | 0 | Aliens (no weight) |
| **hazmat** | 5-15 | 5-10 | Contamination areas |
| **stealth** | 5-10 | 3-8 | Stealth missions |

### Armour Stat Ranges

| Stat | Min | Max | Notes |
|------|-----|-----|-------|
| **Armor Value** | 0 | 30 | Damage reduction |
| **Weight** | 0 | 20 | Movement penalty |
| **Mobility Penalty** | 0 | 30 | AP reduction % |
| **Sight Penalty** | 0 | 20 | Vision range reduction % |
| **Fire Resistance** | 0 | 100 | Fire damage reduction % |
| **Acid Resistance** | 0 | 100 | Acid damage reduction % |

---

## Complete Armour Examples

### Conventional Armour

```toml
# Light Combat Armor - Balanced mobility/protection
[[armour]]
id = "combat_armor_light"
name = "Light Combat Armor"
description = "Basic protective gear - balances mobility and protection"
type = "light"
armor_value = 5
weight = 3
cost = 400
tech_level = "conventional"
mobility_penalty = 0
sight_penalty = 0

# Standard Combat Armor - Baseline protection
[[armour]]
id = "combat_armor_standard"
name = "Combat Armor"
description = "Standard military-grade armor - reliable protection"
type = "standard"
armor_value = 10
weight = 5
cost = 800
tech_level = "conventional"
mobility_penalty = 5
sight_penalty = 0

# Heavy Combat Armor - Maximum conventional protection
[[armour]]
id = "combat_armor_heavy"
name = "Heavy Combat Armor"
description = "Heavy reinforced armor suit - maximum protection"
type = "heavy"
armor_value = 15
weight = 8
cost = 1500
tech_level = "conventional"
mobility_penalty = 15
sight_penalty = 5

# Hazmat Suit - Contamination protection
[[armour]]
id = "hazmat_suit"
name = "Hazmat Suit"
description = "Protective suit for contaminated areas"
type = "hazmat"
armor_value = 8
weight = 6
cost = 600
tech_level = "conventional"
mobility_penalty = 10
sight_penalty = 10
acid_resistance = 100
fire_resistance = 50
```

### Advanced Armour

```toml
# Power Suit - Powered exoskeleton
[[armour]]
id = "power_suit"
name = "Power Suit"
description = "Powered exoskeleton armor - advanced protection"
type = "power"
armor_value = 20
weight = 12
cost = 3500
tech_level = "advanced"
mobility_penalty = 10
sight_penalty = 0
fire_resistance = 30

# Flying Suit - Flight-capable armor
[[armour]]
id = "flying_suit"
name = "Flying Suit"
description = "Armor with flight capability - unique mobility"
type = "special"
armor_value = 12
weight = 6
cost = 2500
tech_level = "advanced"
mobility_penalty = 0
sight_penalty = 0

# Stealth Suit - Invisibility-enhanced
[[armour]]
id = "stealth_suit"
name = "Stealth Suit"
description = "Stealth-enhanced armor - light and quiet"
type = "stealth"
armor_value = 8
weight = 4
cost = 2000
tech_level = "advanced"
mobility_penalty = -5  # Bonus to movement
sight_penalty = 0
```

### Alien Armour

```toml
# Muton Hide - Natural alien armor (light)
[[armour]]
id = "muton_hide"
name = "Muton Hide"
description = "Alien muton natural armor - organic protection"
type = "alien"
armor_value = 10
weight = 0
cost = 0
tech_level = "alien"
mobility_penalty = 0
sight_penalty = 0

# Muton Heavy Hide - Reinforced alien armor
[[armour]]
id = "muton_hide_heavy"
name = "Muton Heavy Hide"
description = "Reinforced muton alien armor - maximum natural protection"
type = "alien"
armor_value = 15
weight = 0
cost = 0
tech_level = "alien"
mobility_penalty = 0
sight_penalty = 0

# Floater Hide - Lightweight alien armor
[[armour]]
id = "floater_hide"
name = "Floater Hide"
description = "Alien floater lightweight armor - minimal protection"
type = "alien"
armor_value = 5
weight = 0
cost = 0
tech_level = "alien"
mobility_penalty = 0
sight_penalty = 0

# Chryssalid Carapace - Insectoid armor
[[armour]]
id = "chryssalid_carapace"
name = "Chryssalid Carapace"
description = "Natural alien insectoid armor - moderate protection"
type = "alien"
armor_value = 12
weight = 0
cost = 0
tech_level = "alien"
mobility_penalty = 0
sight_penalty = 0
acid_resistance = 50  # Resistant to their own acid
```

---

## Equipment Item Types

### Equipment Categories

```toml
# Equipment (non-weapon items)
[[equipment]]
id = "field_kit"
name = "Field Kit"
description = "Basic field medicine and supply kit"
type = "support"
weight = 2
effect = "healing_boost"
target_stat = "health_recovery"
effect_value = 1.5

[[equipment]]
id = "sensor_pack"
name = "Sensor Pack"
description = "Advanced detection system"
type = "utility"
weight = 3
effect = "sight_boost"
effect_value = 1.25

[[equipment]]
id = "smoke_grenade"
name = "Smoke Grenade"
description = "Throwable smoke for concealment"
type = "consumable"
weight = 1
effect = "create_smoke"
duration_turns = 3
```

---

## Lua Access Patterns

### Getting Weapon Stats

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Safe access with defaults
function getWeaponDamage(weaponId)
    local weapon = DataLoader.weapons.get(weaponId)
    if not weapon then
        return 0  -- Default damage if weapon not found
    end
    return weapon.damage or 0
end

-- Get all weapons for a unit class
function getWeaponsForClass(classId)
    -- Implementation depends on game design
    -- Could filter by type or tech level
    return DataLoader.weapons.getAllIds()
end

-- Calculate modified damage
function calculateModifiedDamage(weaponId, modifiers)
    local weapon = DataLoader.weapons.get(weaponId)
    if not weapon then return 0 end
    
    local baseDamage = weapon.damage or 0
    local modifiedDamage = baseDamage
    
    for _, modifier in ipairs(modifiers) do
        modifiedDamage = modifiedDamage * modifier
    end
    
    return math.floor(modifiedDamage)
end
```

### Getting Armour Stats

```lua
-- Safe access with defaults
function getArmourValue(armourId)
    local armour = DataLoader.armours.get(armourId)
    if not armour then
        return 0  -- Default protection if armour not found
    end
    return armour.armor_value or 0
end

-- Get mobility penalty
function getMobilityPenalty(armourId)
    local armour = DataLoader.armours.get(armourId)
    if not armour then
        return 0
    end
    return armour.mobility_penalty or armour.weight
end

-- Calculate total protection with all equipment
function calculateTotalProtection(unit)
    local baseProtection = unit.stats.armor or 0
    local armourProtection = getArmourValue(unit.equipment.armor)
    local totalProtection = baseProtection + armourProtection
    
    return totalProtection
end
```

---

## Modding: Creating Custom Weapons

### Step-by-Step Guide

1. **Create TOML file** in your mod:
```
mods/mymod/content/rules/items/weapons.toml
```

2. **Define weapon array**:
```toml
[[weapon]]
id = "my_custom_rifle"
name = "Custom Rifle"
description = "My awesome rifle"
type = "primary"
damage = 55
accuracy = 75
range = 25
ammo_type = "rifle_ammo"
fire_rate = 1
ap_cost = 3
ep_cost = 10
cost = 900
tech_level = "conventional"
weight = 5
```

3. **Test in Love2D console**:
```
lovec "engine"
```

4. **Check console** for load errors:
```
[DataLoader] ✓ Loaded 11 weapons
```

5. **Access in code**:
```lua
local myWeapon = DataLoader.weapons.get("my_custom_rifle")
```

### Custom Weapon Template

```toml
[[weapon]]
id = "template_weapon"
name = "Template Weapon"
description = "Copy this to create custom weapons"
type = "primary"              # primary, secondary, melee, grenade
damage = 50                   # 10-150 (balance with accuracy)
accuracy = 70                 # 0-100 (%)
range = 25                    # 5-100 (tiles)
ammo_type = "ammo_id"        # must exist in ammo.toml
fire_rate = 1                 # 1-5 (shots per turn)
ap_cost = 3                   # 1-5 (action points)
ep_cost = 10                  # 0-25 (energy points)
cost = 800                    # 0-99999 (credits)
tech_level = "conventional"   # conventional, plasma, laser, alien
weight = 5                    # 1-20 (encumbrance)
rate_of_fire = 1.0           # 0.5-3.0 (speed multiplier)
```

---

## Balance Guidelines

### Weapon Balance Formula

```
Damage + Accuracy + Range = Weapon Effectiveness
```

**Example**: 
- High damage (90) + Low accuracy (40) + Low range (15) = Medium effectiveness
- Medium damage (50) + High accuracy (85) + Long range (35) = High effectiveness

### Armor Balance

```
Protection + Cost + Weight = Armor Effectiveness
```

**Example**:
- Heavy protection (20) + High cost (3500) + High weight (12) = Endgame armor
- Light protection (5) + Low cost (400) + Low weight (3) = Early game armor

### Tech Level Progression

```
conventional → laser → plasma → advanced
(Start)        (Mid)    (Alien)  (Endgame)
```

---

## See Also

- **API_SCHEMA_REFERENCE.md** - Complete schema reference
- **API_UNITS_AND_CLASSES.md** - Unit and class documentation
- **API_FACILITIES.md** - Facility documentation
- **MOD_DEVELOPER_GUIDE.md** - Complete modding guide
- **TOML_FORMATTING_GUIDE.md** - TOML syntax and best practices

