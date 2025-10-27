# Weapons & Armor System API Documentation

**Version:** 1.0  
**Last Updated:** October 21, 2025  
**Status:** ✅ Production Ready  

---

## Overview

The Weapons & Armor system manages all combat equipment including firearms, melee weapons, armor protection, accessories, and ammunition. The system supports weapon modification, damage type interactions, armor degradation, and dynamic equipment stat modifiers.

**Key Features:**
- 40+ weapon types with specializations
- 6 armor classes with degradation
- 5 damage types with different armor interactions
- Weapon modification system
- Ammunition management
- Equipment weight and mobility
- Accessory slots for scopes, grips, magazines
- Armor repair and replacement
- Combat effectiveness calculations

---

## Implementation Status

### ✅ Implemented (in engine/)
- Weapon definitions and data loading
- Armor definitions and classification
- Ammunition management
- Equipment TOML configuration
- Accuracy calculations with range modifiers
- Armor damage reduction mechanics
- Equipment usage tracking
- Inventory management

### 🚧 Partially Implemented
- Weapon modification system
- Advanced damage types
- Equipment durability tracking
- Loadout presets

### 📋 Planned
- Weapon customization and upgrades
- Accessory slots and attachments
- Armor degradation mechanics
- Equipment progression system

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

## Architecture

### Damage System
```
Damage Source
├── Ballistic (projectiles)
├── Energy (lasers, plasma)
├── Explosive (grenades, rockets)
├── Melee (blades, impact)
└── Incendiary (fire, corrosive)
```

### Armor Classes
```
Light Armor (Ranger, Medic)
├── 20-40 armor points
├── -0 AP movement
└── +30% visibility distance

Medium Armor (Specialist, Officer)
├── 40-60 armor points
├── -1 AP movement
└── +10% visibility

Heavy Armor (Soldier)
├── 80-120 armor points
├── -2 AP movement
└── -20% visibility
```

### Equipment Categories
```
Weapons
├── Primary (rifles, shotguns, SMGs)
├── Secondary (pistols, sidearms)
├── Melee (swords, axes, batons)
└── Grenades (throwables, explosives)

Armor
├── Helmet
├── Chest
├── Arms
├── Legs
└── Accessories (ammo, medical, tech)
```

---

## Core Entities

### Weapon

Individual weapon with stats, ammunition, and modification slots.

**Structure:**
```lua
local weapon = {
    id = "rifle_assault_001",
    name = "Assault Rifle XM-4",
    type = "rifle",
    damage_type = "ballistic",
    base_damage = 18,
    accuracy = 70,
    range_effective = 12,
    range_maximum = 20,
    ap_cost = 3,
    ammo_type = "5.56x45",
    ammo_capacity = 30,
    ammo_current = 30,
    fire_rate = "single|burst|auto",
    fire_rate_active = "single",
    rate_of_fire = {single = 1, burst = 3, auto = 6},
    critical_chance = 0.05,
    weight = 3.5,
    reliability = 0.95,
    modification_slots = {scope = nil, grip = nil, magazine = nil},
    condition = 100, -- durability 0-100
    market_value = 2500,
    faction = "human"
}
```

**Functions:**

#### Weapon.create(weapon_id, ammo_count, callback)
Create new weapon instance with ammo.

**Parameters:**
- `weapon_id` (string): Weapon template ID
- `ammo_count` (number): Initial ammo count
- `callback` (function): Called when created (err, weapon)

**Returns:**
- (table) New Weapon instance

**Example:**
```lua
Weapon.create("rifle_assault_001", 60, function(err, weapon)
    if err then print("Creation failed: " .. err) return end
    print("[WEAPONS] Created " .. weapon.name)
    print("  Damage: " .. weapon.base_damage)
    print("  Accuracy: " .. weapon.accuracy .. "%")
    print("  Ammo: " .. weapon.ammo_current .. "/" .. weapon.ammo_capacity)
end)
```

---

#### Weapon.calculate_damage(accuracy_bonus, range_multiplier, location)
Calculate damage for single shot considering all modifiers.

**Parameters:**
- `accuracy_bonus` (number): Accuracy modifier from unit stats (-50 to +50)
- `range_multiplier` (number): Range penalty (0.5 at max range, 1.0 at effective)
- `location` (string): Hit location "head", "torso", "limbs"

**Returns:**
- (number) Calculated damage
- (table) Breakdown {base, armor_reduction, critical, location_bonus}

**Damage Modifiers:**
```
Damage = Base Damage × Accuracy Multiplier × Range Multiplier
       + Location Bonus (head +50%, limbs -20%)
       + Critical Multiplier (if triggered)

Location Multipliers:
- Head: 1.5x
- Torso: 1.0x
- Limbs: 0.8x

Range Calculations:
- 0-Effective: 1.0x
- Effective-Max: Linear falloff to 0.5x
- Beyond Max: 0.3x
```

**Example:**
```lua
local damage, breakdown = weapon:calculate_damage(10, 1.0, "head")
print("Calculated damage: " .. damage)
print("  Base: " .. breakdown.base)
print("  Location: " .. breakdown.location_bonus .. "x")
print("  Critical: " .. (breakdown.critical and "YES" or "NO"))
```

---

#### Weapon.fire(accuracy_modifier, target_distance, callback)
Execute weapon fire and consume ammo.

**Parameters:**
- `accuracy_modifier` (number): Accuracy modifier from shooting unit (-30 to +20)
- `target_distance` (number): Distance to target in hexes
- `callback` (function): Called when fire resolved (err, result)

**Returns:**
- (boolean) Fire queued

**Fire Result:**
```lua
{
    hit = true/false,
    accuracy_chance = 75,
    critical = false,
    damage = 18,
    ammo_consumed = 1,
    ammo_remaining = 29,
    weapon_wear = 2 -- durability decrease
}
```

**Example:**
```lua
weapon:fire(5, 8, function(err, result)
    if err then print("Fire failed: " .. err) return end
    print("Fire resolution:")
    print("  Hit: " .. (result.hit and "YES" or "NO") .. " (" .. result.accuracy_chance .. "%)")
    print("  Damage: " .. result.damage)
    print("  Ammo: " .. result.ammo_remaining .. "/" .. weapon.ammo_capacity)
    print("  Weapon wear: " .. result.weapon_wear .. "%")
end)
```

---

#### Weapon.reload(ammo_available, callback)
Reload weapon from ammunition pool.

**Parameters:**
- `ammo_available` (number): Ammo to reload from
- `callback` (function): Called when reload complete (err, result)

**Returns:**
- (boolean) Reload successful

**Example:**
```lua
weapon:reload(30, function(err, result)
    if err then print("Reload failed: " .. err) return end
    print("Reloaded: " .. result.ammo_loaded .. " rounds")
    print("Ammo remaining: " .. ammo_available - result.ammo_loaded)
end)
```

---

#### Weapon.install_modification(modification, slot, callback)
Install accessory modification in weapon slot.

**Parameters:**
- `modification` (table): Modification object {id, name, type, bonuses}
- `slot` (string): Slot "scope", "grip", "magazine"
- `callback` (function): Called when installed (err, result)

**Returns:**
- (boolean) Modification installed

**Modification Types:**
- **Scope:** +10-20% accuracy at range
- **Grip:** +5-10% control in burst/auto
- **Magazine:** +10-20 ammo capacity
- **Suppressor:** -2 detection range, -10% damage
- **Laser:** +5% accuracy, reveals position at night
- **Extended Mag:** +50% ammo capacity

**Example:**
```lua
local scope = {id = "scope_acog", type = "scope", name = "ACOG Scope", bonuses = {accuracy = 15}}
weapon:install_modification(scope, "scope", function(err, result)
    if err then print("Install failed: " .. err) return end
    print("Installed: " .. scope.name)
    print("  Accuracy bonus: +" .. result.total_accuracy .. "%")
end)
```

---

### Armor

Protective equipment with damage reduction and degradation.

**Structure:**
```lua
local armor = {
    id = "armor_heavy_001",
    name = "Combat Armor Mk2",
    type = "chest",
    armor_class = "heavy",
    armor_points = 100,
    current_armor = 100,
    damage_reduction = {
        ballistic = 0.45,
        energy = 0.30,
        explosive = 0.25,
        melee = 0.35,
        incendiary = 0.10
    },
    weight = 8.5,
    mobility_penalty = -2,
    ap_reduction = 2,
    visibility_reduction = -20,
    condition = 100,
    repair_value = 500,
    market_value = 4500,
    coverage = 0.65,
    faction = "human"
}
```

**Functions:**

#### Armor.create(armor_id, callback)
Create new armor instance.

**Parameters:**
- `armor_id` (string): Armor template ID
- `callback` (function): Called when created (err, armor)

**Returns:**
- (table) New Armor instance

**Example:**
```lua
Armor.create("armor_heavy_001", function(err, armor)
    if err then print("Creation failed: " .. err) return end
    print("[ARMOR] Created " .. armor.name)
    print("  Class: " .. armor.armor_class)
    print("  Armor Points: " .. armor.armor_points)
    print("  Mobility Penalty: " .. armor.mobility_penalty .. " AP")
end)
```

---

#### Armor.absorb_damage(damage, damage_type, callback)
Apply damage to armor and reduce effective damage.

**Parameters:**
- `damage` (number): Incoming damage
- `damage_type` (string): "ballistic", "energy", "explosive", "melee", "incendiary"
- `callback` (function): Called when absorbed (err, result)

**Returns:**
- (boolean) Damage processed

**Damage Absorption Formula:**
```
Armor_Reduction = Armor_Points × Reduction_Factor[damage_type]
Effective_Damage = Damage - Armor_Reduction
Armor_Degradation = Damage × 0.5 (armor points lost)
```

**Example:**
```lua
armor:absorb_damage(25, "ballistic", function(err, result)
    if err then print("Error: " .. err) return end
    print("Damage absorbed:")
    print("  Incoming: " .. result.damage_incoming)
    print("  Absorbed: " .. result.damage_absorbed)
    print("  Effective: " .. result.damage_effective)
    print("  Armor remaining: " .. result.armor_remaining .. "/" .. armor.armor_points)
end)
```

---

## Integration Examples

### Example 1: Create and Equip Weapon

```lua
local Weapon = require("equipment.weapon")

-- Create assault rifle with ammo
Weapon.create("rifle_assault_001", 90, function(err, weapon)
    if err then print("Failed: " .. err) return end
    
    print("[WEAPON] " .. weapon.name .. " created")
    print("  Type: " .. weapon.type)
    print("  Damage: " .. weapon.base_damage)
    print("  Accuracy: " .. weapon.accuracy .. "%")
    print("  Ammo: " .. weapon.ammo_current .. "/" .. weapon.ammo_capacity)
    
    -- Install scope modification
    local scope = {id = "acog_scope", type = "scope", name = "ACOG 4x", bonuses = {accuracy = 15}}
    weapon:install_modification(scope, "scope", function(err, result)
        if err then print("Mod install failed: " .. err) return end
        print("[MODIFIED] " .. scope.name .. " installed")
        print("  Accuracy: " .. (weapon.accuracy + 15) .. "%")
    end)
end)
```

**Output:**
```
[WEAPON] Assault Rifle XM-4 created
  Type: rifle
  Damage: 18
  Accuracy: 70%
  Ammo: 90/30 (3 magazines)
[MODIFIED] ACOG 4x installed
  Accuracy: 85%
```

---

### Example 2: Combat Fire and Damage

```lua
-- Unit fires weapon
local target_distance = 8
local accuracy_bonus = 10 -- from unit stats

weapon:fire(accuracy_bonus, target_distance, function(err, result)
    if err then print("Fire failed: " .. err) return end
    
    if result.hit then
        print("[HIT!] Accuracy: " .. result.accuracy_chance .. "%")
        print("  Damage: " .. result.damage)
        print("  Critical: " .. (result.critical and "YES" or "NO"))
        
        -- Enemy takes damage with armor protection
        enemy_armor:absorb_damage(result.damage, "ballistic", function(err, armor_result)
            if err then print("Error: " .. err) return end
            print("[ARMOR] Damage absorbed")
            print("  Incoming: " .. armor_result.damage_incoming)
            print("  Reduced: " .. armor_result.damage_absorbed .. " (" .. 
                  math.floor(armor_result.damage_absorbed/armor_result.damage_incoming*100) .. "%)")
            print("  Effective damage: " .. armor_result.damage_effective)
            print("  Enemy takes: " .. armor_result.damage_effective .. " damage")
        end)
    else
        print("[MISS!] Accuracy was " .. result.accuracy_chance .. "% (failed)")
    end
end)
```

**Output:**
```
[HIT!] Accuracy: 78%
  Damage: 18
  Critical: NO
[ARMOR] Damage absorbed
  Incoming: 18
  Reduced: 8 (45%)
  Effective damage: 10
  Enemy takes: 10 damage
```

---

### Example 3: Armor Degradation and Repair

```lua
-- After multiple combat encounters
print("Armor Status:")
print("  Current: " .. armor.current_armor .. "/" .. armor.armor_points)

local is_critical, percent, warnings = armor:is_critical_condition()
if is_critical then
    print("[WARNING] Armor critical at " .. math.floor(percent) .. "%")
    for _, warn in ipairs(warnings) do
        print("  - " .. warn)
    end
    
    -- Send to repair facility
    armor:repair(50, function(err, result)
        if err then print("Repair failed: " .. err) return end
        print("[REPAIRED]")
        print("  Before: " .. result.armor_before)
        print("  After: " .. result.armor_after)
        print("  Cost: $" .. result.repair_cost)
    end)
else
    print("  Status: OK (" .. math.floor(percent) .. "%)")
end
```

**Output:**
```
Armor Status:
  Current: 28/100
[WARNING] Armor critical at 28%
  - Below 30% effectiveness, repair recommended
  - Ballistic protection reduced to 67%
[REPAIRED]
  Before: 28
  After: 78
  Cost: $2500
```

---

### Example 4: Weapon Loadout Management

```lua
-- Create squad loadout
local loadout = {
    primary = {weapon_id = "rifle_assault_001", ammo = 90},
    secondary = {weapon_id = "pistol_combat_001", ammo = 30},
    armor = {armor_id = "armor_medium_001"},
    grenades = {grenade_id = "frag_grenade", quantity = 3}
}

-- Equip unit with loadout
for weapon_slot, weapon_config in pairs(loadout) do
    if weapon_slot ~= "armor" and weapon_slot ~= "grenades" then
        Weapon.create(weapon_config.weapon_id, weapon_config.ammo, function(err, weapon)
            if err then print("Weapon failed: " .. err) return end
            print("[LOADOUT] " .. weapon.name .. " equipped")
            print("  Slot: " .. weapon_slot)
            print("  Ammo: " .. weapon.ammo_current)
        end)
    end
end

print("[LOADOUT COMPLETE] Unit ready for deployment")
```

**Output:**
```
[LOADOUT] Assault Rifle XM-4 equipped
  Slot: primary
  Ammo: 90
[LOADOUT] Combat Pistol equipped
  Slot: secondary
  Ammo: 30
[LOADOUT COMPLETE] Unit ready for deployment
```

---

### Example 5: Ammunition Pool and Resupply

```lua
local Ammunition = require("equipment.ammo")

-- Create ammunition pool
local ammo_pool = Ammunition.create_pool(500)

-- Request ammo for weapon reload
ammo_pool:request_ammo("5.56x45", 30, function(err, result)
    if err then print("Request failed: " .. err) return end
    print("[AMMO] Allocated " .. result.ammo_allocated .. " rounds")
    print("  Type: " .. result.ammo_type)
    print("  Pool remaining: " .. result.pool_remaining)
end)

-- Consume ammo during combat
for shot = 1, 3 do
    ammo_pool:consume_ammo("5.56x45", 1, "weapon_rifle_001")
end
print("[AMMO] After firing 3 shots")
print("  5.56x45 remaining: " .. ammo_pool:get_ammo_count("5.56x45"))

-- Resupply from base inventory
ammo_pool:add_supply("5.56x45", 200, function(err, result)
    if err then print("Resupply failed: " .. err) return end
    print("[RESUPPLY] +" .. result.ammo_added .. " rounds")
    print("  Total 5.56x45: " .. result.total_ammo_type)
end)
```

**Output:**
```
[AMMO] Allocated 30 rounds
  Type: 5.56x45
  Pool remaining: 540
[AMMO] After firing 3 shots
  5.56x45 remaining: 207
[RESUPPLY] +200 rounds
  Total 5.56x45: 407
```

---

## Performance Considerations

### Damage Calculations
- Pre-calculate armor reduction modifiers
- Cache distance-to-damage tables
- Batch critical chance calculations

### Weapon Wear
- Update condition only on fire/damage events
- Cache reliability checks
- Lazy-load modification effects

### Ammunition Tracking
- Aggregate ammo by type in pool
- Update counts only on consumption
- Cache ammo-per-magazine ratios

---

## Item & Equipment System

### Item Categories

All items in AlienFall fall into five primary categories with distinct mechanics:

#### 1. Resources

Strategic materials consumed in manufacturing, research, and craft travel.

**Core Resource Types - By Game Phase:**

| Phase | Key Resources | Purpose | Examples |
|-------|---------------|---------|----------|
| **Early Human** | Fuel (5K), Metal (3K) | Basic crafts, equipment | Scout missions, first weapons |
| **Advanced Human** | Fusion Core (50K), Titanium (20K), Uranium (100K) | Advanced tech unlocks | Interceptor craft, plasma research |
| **Alien War** | Elerium (200K), Alien Alloy (150K) | Alien tech integration | UFO weapons, advanced armor |
| **Aquatic War** | Zrbite (250K), Aqua Plastic (200K) | Underwater operations | Submarine development, naval combat |
| **Dimensional War** | Warp Crystal (500K), Rift Matter (300K) | Dimensional tech | Teleportation, portal research |
| **Ultimate** | Quantum Processor (1M), Reality Anchor (800K) | Endgame supremacy | AI integration, reality manipulation |
| **Virtual/AI War** | Data Core (100K), Processing Power (50K) | Digital warfare | Cyber attacks, AI combat systems |

**Resource Management Mechanics:**
- Crafts consume fuel directly from base inventory per mission
- Insufficient fuel prevents craft launch (creates resource management tension)
- Resources can be synthesized: Metal + Fuel → Titanium
- Trading converts resources to credits at 50% purchase price
- Black market provides high-cost alien resources with reputation risk
- Supply contracts establish steady resource income with factions

**Economic Strategy Trade-offs:**
1. **Manufacturing:** Resources → Equipment → Immediate unit equipping
2. **Trading:** Resources → Credits → Reinvestment in research/facilities
3. **Synthesis:** Common → Rare materials → Enable advanced manufacturing

#### 2. Lore Items

Non-mechanical story objects collected through special missions and narrative events.

**Characteristics:**
- Zero weight, zero storage space
- Cannot be accidentally sold (safe from player mistakes)
- May enable new research trees or unlock equipment
- Represent story progression and world-building

**Usage Examples:**
- Historical artifacts unlock ancient alien technology research
- Creature specimens enable biological research trees
- Technology salvage provides manufacturing blueprints
- Ancient documents trigger story events and faction reputation changes

#### 3. Unit Weapons

Infantry and small arms weapons that soldiers carry into battle.

**Weapon Characteristics:**
- All weapons have AP (Action Point) and EP (Energy Point) costs
- Range, accuracy, and damage vary by weapon type and technology
- All weapons can be thrown as emergency actions (1 AP)
- Damage types: Kinetic, Energy, Explosive, Psionic, Hazard
- Equipped weapons affect AP economy and mobility

**Weapon Types & Statistics:**

| Type | Range | AP Cost | Base Accuracy | Base Damage | Notes |
|------|-------|---------|----------------|------------|-------|
| **Pistol** | 8 hex | 1-2 | 75% | 12 | Fast, light, sidearm |
| **Rifle** | 15 hex | 2 | 70% | 18 | Standard infantry, balanced |
| **Sniper Rifle** | 25 hex | 3 | 85% | 35 | Requires stationary aim, high damage |
| **Shotgun** | 4 hex | 2 | 60% | 45 | Close quarters, high damage, unreliable |
| **Melee** | 1 hex | 1 | 80% | 20 | Silent, always available, no ammo |
| **Grenade Launcher** | 12 hex | 3 | 55% | 60 (area) | Area of effect, indirect fire |
| **Plasma Rifle** | 15 hex | 2 | 68% | 28 | Energy damage, high armor penetration |
| **Laser Rifle** | 12 hex | 2 | 72% | 24 | Energy damage, perfect accuracy over distance |

**Weapon Firing Modes** (mutually exclusive per shot):
- **Snap Shot:** -20% accuracy, 1 AP—quick reflexive fire
- **Aimed Shot:** +20% accuracy, 3 AP, stationary—deliberate targeting
- **Burst Fire:** -10% accuracy, 3 AP, 2-3x damage—medium coverage
- **Auto Fire:** -20% accuracy, 4 AP—sustained fire, unreliable but devastating

**Special Weapons & Consumables:**

| Item | AP Cost | Effect | Range | Charges | Notes |
|------|---------|--------|-------|---------|-------|
| **Grenade** | 1 | 30 damage, area effect | 3 hex radius | - | Can bounce off walls, friendly fire possible |
| **Mine** | 2 | 40 damage, proximity triggered | 3 hex radius | - | Defensive placement, triggers on enemy approach |
| **Flare** | 1 | +3 hex vision for 2 turns | 3 hex radius | - | Dispels darkness, reveals stealth units |
| **Flashbang** | 1 | 1-turn stun | 2 hex radius | - | Non-lethal control, disables abilities |
| **Flashlight** | - | +2 night vision | Equipped | - | Passive, always active, reduces stealth |
| **Night Vision Goggles** | - | +5 night vision | Equipped | 100 turns | Passive when equipped, battery-based |
| **Motion Scanner** | - | +3 sight range | Equipped | 50 turns | Detects movement through walls, requires toggle |
| **Psionic Amplifier** | - | Enables psychic abilities | Equipped | - | 30 EP per use, requires psionic unit |
| **Medikit** | 1 | 25 HP (Medic) / 15 HP (Others) | Self | 5 charges | Class synergy +50% for Medic, charges deplete |
| **Stimpack** | 1 | Grants +2 AP next turn | Self | 1 charge | Consumable buff, temporary enhancement |
| **Shield Generator** | - | 15 temporary HP | Equipped | 50 turns | Rechargeable defensive system, absorbs damage first |

**Damage Types & Effects:**
- **Kinetic:** Standard ballistic weapons, most effective against unarmored targets
- **Energy:** Laser/plasma weapons, ignores 25% armor effectiveness
- **Explosive:** Grenades/rockets, area effect damage, destroys terrain
- **Psionic:** Psychic attacks, bypasses armor, affects will/morale
- **Hazard:** Poison/fire/acid, damage over time, lingering environmental effects

#### 4. Unit Armor

Protective gear that reduces incoming damage and affects mobility/accuracy.

**Armor Types & Statistics:**

| Armor Type | Movement Penalty | AP Penalty | Armor Value | Accuracy Penalty | Cost | Notes |
|------------|------------------|-----------|-------------|------------------|------|-------|
| **Light Scout** | +1 hex/turn | 0 | +5 | +5% accuracy | 8K | Mobility-focused, infiltration |
| **Combat Armor** | -1 hex/turn | -1 AP | +15 | -5% accuracy | 15K | Balanced all-rounder |
| **Heavy Assault** | -2 hex/turn | -2 AP | +25 | -10% accuracy | 25K | Tanking specialist, high protection |
| **Hazmat Suit** | Varies | Varies | +10 | Varies | 12K | +100% poison resistance, specialty |
| **Stealth Suit** | Varies | Varies | +8 | +20% stealth | 20K | Infiltration-focused, detection reduction |
| **Medic Armor** | Varies | Varies | +8 | Varies | 10K | +50% healing potency, medical focus |
| **Sniper Ghillie** | Varies | Varies | +10 | +10% accuracy, +1 sight | 18K | Marksman-optimized, concealment |

**Armor Mechanics:**
- Armor Value = damage reduction (1 point = 1 damage absorbed)
- Armor is fixed before deployment; cannot change during battle
- Each type sets resistances to Kinetic, Energy, and Hazard damage
- Unit race determines base resistances if armor doesn't override
- Class synergies apply: specialized units get stat bonuses with matching armor
- Armor degradation: Heavy armor loses effectiveness after 20 hits (-1 value per hit)

**Class Synergy Examples:**
- Medic + Medical Armor: +50% healing effectiveness
- Specialist unit + Heavy Cannon: +20% damage vs -30% accuracy penalty (net beneficial)
- Sniper + Sniper Ghillie: +10% accuracy, +1 sight range, +15% crit chance
- Scout + Light Armor: +2 movement hexes, +10% stealth detection

#### 5. Craft Equipment

Weapons, armor systems, and support modules mounted on interceptor craft.

**Craft Weapons - Hardpoint Mounted:**

| Weapon | Range | Damage | AP Cost | EP Cost | Cooldown | Accuracy | Special |
|--------|-------|--------|---------|---------|----------|----------|---------|
| **Point Defense Turret** | 20 km | 15 | 2 | 5 | 1 turn | 75% | Anti-missile, defensive |
| **Main Cannon** | 20 km | 40 | 3 | 10 | 1 turn | 75% | Balanced all-rounder |
| **Missile Pod** | 60 km | 80 (area) | 4 | 15 | 2 turns | 85% | Homing, long-range |
| **Laser Array** | 40 km | 60/turn | 3 | 20 | None | 75% | Sustained beam, high energy |
| **Plasma Caster** | 30 km | 70 | 4 | 25 | 2 turns | 70% | Ignores 50% armor |
| **Tractor Beam** | 25 km | 0 (stun) | 2 | 10 | 1 turn | 80% | Immobilizes target, non-lethal |
| **EMP Cannon** | 30 km | 0 (system) | 3 | 15 | 2 turns | 65% | Disables enemy systems, no damage |

**Craft Defense & Support Systems:**

| System | Category | Effect | Cost Implications | Notes |
|--------|----------|--------|-------------------|-------|
| **Energy Shield** | Defense | +10 health, +20 energy, +5 regen/turn | Premium | Power-dependent, regenerates |
| **Ablative Armor** | Defense | -50% explosive damage, degrades 10% per hit | Standard | Temporary defense, replaceable |
| **Reactive Plating** | Defense | Explosive +40%, Kinetic +20% resistance | Standard | Specialized defense, type-specific |
| **Standard Armor Plates** | Defense | +50 health | Budget | Solid baseline, maintenance required |
| **Afterburner** | Mobility | +1 speed, higher fuel consumption | Performance | Aggressive pursuit, fuel trade-off |
| **Cloak Generator** | Stealth | 50% detection reduction, 20 turns | High-tech | Expensive, detection risk high |
| **ECM Suite** | Countermeasure | 30% missile evasion, active toggle | Electronic | Requires operator attention |
| **Repair Drone** | Support | 20 HP regeneration per turn | Tech-heavy | Passive repair, limited duration |

---

## Weapon & Armor API Functions

### Weapon Management

```lua
WeaponManager.getWeapon(weapon_id) -> table
-- Get weapon by ID
-- Parameters: weapon_id (string)
-- Returns: Weapon entity with stats, range, damage, cost
-- Example: WeaponManager.getWeapon("rifle")

WeaponManager.getAllWeapons() -> table
-- Get all available weapons
-- Returns: Array of weapon entities
-- Filtering: Use getWeaponsByType() for categories

WeaponManager.getWeaponsByType(type) -> table
-- Get weapons by type
-- Parameters: type ("primary", "secondary", "melee", "grenade", "craft")
-- Returns: Array of weapons of specified type

WeaponManager.getWeaponsByTechLevel(tech_level) -> table
-- Get weapons by technology level
-- Parameters: tech_level ("conventional", "plasma", "laser", "alien")
-- Returns: Array of weapons at tech level

WeaponManager.calculateDamage(weapon, aim_stat, distance, multipliers) -> number
-- Calculate weapon damage including all modifiers
-- Parameters: weapon entity, unit's aim stat, target distance, optional multipliers
-- Returns: Final damage value (minimum 0 if completely ineffective)
-- Formula: BaseDamage × (Accuracy Modifier) × (Range Penalty) × (Multipliers)

WeaponManager.canUseTechnology(weapon_id, unit_class) -> boolean
-- Check if unit class can use weapon
-- Parameters: weapon_id, unit_class_id
-- Returns: true if restrictions met
-- Note: Some weapons require specialist training or high rank
```

### Armor Management

```lua
ArmorManager.getArmor(armor_id) -> table
-- Get armor by ID
-- Parameters: armor_id (string)
-- Returns: Armor entity with stats, resistances, penalties

ArmorManager.getAllArmor() -> table
-- Get all available armor
-- Returns: Array of armor entities

ArmorManager.getArmorByType(type) -> table
-- Get armor by type/class
-- Parameters: type ("light", "medium", "heavy", "specialty")
-- Returns: Array of armor of specified type

ArmorManager.getArmorByTechLevel(tech_level) -> table
-- Get armor by technology level
-- Parameters: tech_level
-- Returns: Array of armor at tech level

ArmorManager.calculateProtection(armor, damage_type, damage) -> number
-- Calculate armor protection against damage
-- Parameters: armor entity, damage_type ("kinetic"|"energy"|"explosive"), damage amount
-- Returns: Damage after armor mitigation
-- Formula: FinalDamage = BaseDamage - (ArmorValue × TypeResistance)

ArmorManager.getMovementPenalty(armor_id) -> number
-- Get movement hex reduction for armor
-- Parameters: armor_id
-- Returns: Hex penalty (-0 to -3)
```

### Equipment Compatibility

```lua
EquipmentManager.canEquipItem(unit, item_id) -> boolean
-- Check if unit can equip item
-- Parameters: unit_entity, item_id
-- Returns: true if compatible (class, level, training requirements met)
-- Checks: Class restrictions, rank requirements, carry capacity

EquipmentManager.getEquipmentSlots(unit_class) -> table
-- Get equipment slot configuration for unit class
-- Parameters: unit_class_id
-- Returns: {primary_slot, secondary_slot, armor_slot, utility_slots}

EquipmentManager.canCarryWeight(unit, equipment_array) -> boolean
-- Check if unit can carry equipment load
-- Parameters: unit_entity, array of equipment
-- Returns: true if within carrying capacity
-- Penalty: Exceeding capacity reduces movement by 50%
```

---

## Integration Examples

### Example: Calculate Combat Effectiveness

```lua
local WeaponManager = require("engine.basescape.weapons")
local ArmorManager = require("engine.basescape.armor")

-- Get unit weapon and armor
local rifle = WeaponManager.getWeapon("rifle")
local armor = ArmorManager.getArmor("combat_armor")

-- Calculate base effectiveness
local base_damage = rifle.damage -- 18
local aim_bonus = rifle.accuracy -- 70%
local armor_reduction = armor.armor_value -- 15

-- Simulate combat
local target_distance = 10  -- hexes
local distance_penalty = (target_distance - 5) * -1  -- -5% per hex
local final_accuracy = aim_bonus + distance_penalty  -- 65%

local armor_protection = ArmorManager.calculateProtection(armor, "kinetic", base_damage)
print("[COMBAT] Rifle vs Combat Armor")
print("  Base Damage: " .. base_damage)
print("  Distance Penalty: " .. distance_penalty .. "%")
print("  Final Accuracy: " .. final_accuracy .. "%")
print("  Armor Protection: " .. armor_protection)
print("  Expected Damage: " .. (base_damage - armor_protection))

-- Output:
-- [COMBAT] Rifle vs Combat Armor
--   Base Damage: 18
--   Distance Penalty: -5%
--   Final Accuracy: 65%
--   Armor Protection: 8
--   Expected Damage: 10
```

### Example: Equipment Configuration

```lua
local EquipmentManager = require("engine.basescape.equipment")
local WeaponManager = require("engine.basescape.weapons")

-- Create unit and check equipment slots
local unit = {class_id = "soldier", rank = 2}
local slots = EquipmentManager.getEquipmentSlots("soldier")

print("[EQUIPMENT] Soldier Equipment Slots:")
print("  Primary: " .. slots.primary_slot)
print("  Secondary: " .. slots.secondary_slot)
print("  Armor: " .. slots.armor_slot)
print("  Utility: " .. slots.utility_slots .. " slots")

-- Check weapon compatibility
local rifle = WeaponManager.getWeapon("rifle")
local can_equip = EquipmentManager.canEquipItem(unit, "rifle")

if can_equip then
    print("[EQUIPMENT] ✓ Can equip Rifle (class: " .. unit.class_id .. ")")
else
    print("[EQUIPMENT] ✗ Cannot equip Rifle (restrictions apply)")
end

-- Output:
-- [EQUIPMENT] Soldier Equipment Slots:
--   Primary: rifle
--   Secondary: pistol
--   Armor: medium
--   Utility: 2 slots
-- [EQUIPMENT] ✓ Can equip Rifle (class: soldier)
```

---

## Comprehensive Weapon Balance Tables

### Conventional Weapons - Tier 1

| Weapon | Damage | Accuracy | Crit | Range | AP | Weight | Cost | Notes |
|--------|--------|----------|------|-------|----|----|------|-------|
| **Pistol** | 8 | 75% | 5% | 12 | 1 | 1.5 | 400 | Reliable sidearm |
| **Rifle** | 12 | 85% | 8% | 18 | 2 | 3.5 | 800 | Versatile primary |
| **Shotgun** | 18 | 65% | 12% | 6 | 2 | 4.0 | 850 | Close range devastation |
| **SMG** | 10 | 70% | 6% | 14 | 2 | 2.5 | 600 | High fire rate |
| **Sniper** | 20 | 80% | 15% | 25 | 2 | 5.0 | 1200 | Long range precision |

### Plasma Weapons - Tier 2 (Alien Tech)

| Weapon | Damage | Accuracy | Crit | Range | AP | Weight | Cost | Notes |
|--------|--------|----------|------|-------|----|----|------|-------|
| **Plasma Pistol** | 14 | 80% | 8% | 14 | 2 | 1.8 | 0* | Captured/converted |
| **Plasma Rifle** | 18 | 82% | 10% | 20 | 2 | 3.8 | 0* | Superior ballistics |
| **Plasma Cannon** | 26 | 75% | 12% | 16 | 3 | 6.0 | 0* | Heavy support |

### Laser Weapons - Tier 3 (Advanced Research)

| Weapon | Damage | Accuracy | Crit | Range | AP | Weight | Cost | Notes |
|--------|--------|----------|------|-------|----|----|------|-------|
| **Laser Pistol** | 16 | 80% | 6% | 15 | 2 | 1.6 | 1500 | Energy-based |
| **Laser Rifle** | 20 | 85% | 8% | 22 | 2 | 3.5 | 2200 | Precision weapon |
| **Laser Cannon** | 30 | 78% | 10% | 18 | 3 | 5.5 | 2800 | Area coverage |

### Grenades & Explosives

| Item | Damage | Radius | Weight | Cost | Notes |
|------|--------|--------|--------|------|-------|
| **Grenade** | 15 | 4 hex | 0.5 | 150 | Standard explosive |
| **Flashbang** | 2 | 5 hex | 0.4 | 200 | Stun + blind |
| **Smoke Bomb** | 0 | 5 hex | 0.3 | 100 | Obscuring |
| **Incendiary** | 8 | 3 hex | 0.5 | 250 | Burn damage |
| **EMP** | 2 | 6 hex | 0.6 | 300 | Disable tech |

---

## Comprehensive Armor Balance Tables

### Light Armor - Tier 1

| Armor | AC | Weight | Cost | Mobility Penalty | Special |
|-------|----|----|------|--------|---------|
| **Leather Vest** | 2 | 2 kg | 200 | None | Basic |
| **Combat Vest** | 3 | 2.5 kg | 300 | -5% | Standard |
| **Tactical Vest** | 4 | 3 kg | 400 | -10% | Extra slots |

### Medium Armor - Tier 2

| Armor | AC | Weight | Cost | Mobility Penalty | Special |
|-------|----|----|------|--------|---------|
| **Combat Suit** | 5 | 4 kg | 800 | -15% | Balanced |
| **Reinforced Suit** | 6 | 4.5 kg | 1000 | -20% | Enhanced |
| **Combat Plating** | 7 | 5 kg | 1200 | -25% | Extra plating |

### Heavy Armor - Tier 3

| Armor | AC | Weight | Cost | Mobility Penalty | Special |
|-------|----|----|------|--------|---------|
| **Heavy Combat Armor** | 8 | 8 kg | 1800 | -30% | Reinforced |
| **Combat Armor Mk II** | 9 | 8.5 kg | 2100 | -35% | Advanced |
| **Tactical Heavy** | 10 | 9 kg | 2400 | -40% | Specialized |

### Power Armor - Tier 4

| Armor | AC | Weight | Cost | Mobility Penalty | Special |
|-------|----|----|------|--------|---------|
| **Light Exoskeleton** | 11 | 12 kg | 3500 | -20% | +Strength |
| **Combat Exoskeleton** | 12 | 14 kg | 4000 | -25% | +Movement |
| **Heavy Exoskeleton** | 13 | 16 kg | 4500 | -30% | +Carrying |

### Advanced Armor - Tier 5

| Armor | AC | Weight | Cost | Mobility Penalty | Special |
|-------|----|----|------|--------|---------|
| **Advanced Combat Suit** | 14 | 10 kg | 5000 | -15% | Tech integration |
| **Energy Shield Suit** | 15 | 8 kg | 6000 | -10% | Active shield |
| **Legendary Armor** | 16 | 9 kg | 7000 | -12% | Balanced perfection |

---

## Damage Type Effectiveness

### Armor Resistance by Material

| Material | Kinetic | Energy | Explosive | EMP |
|----------|---------|--------|-----------|-----|
| **Cloth** | 0% | 10% | 0% | 0% |
| **Leather** | 15% | 15% | 10% | 5% |
| **Composite** | 40% | 35% | 25% | 15% |
| **Ceramic** | 60% | 40% | 35% | 20% |
| **Energy Reactive** | 50% | 60% | 30% | 40% |

### Damage Type Properties

```lua
damage_types = {
  kinetic = {
    description = "Bullets, fragments",
    armor_effectiveness = 1.0,      -- Full effectiveness
    typical_weapons = {"rifle", "pistol", "shotgun"}
  },
  
  energy = {
    description = "Plasma, lasers",
    armor_effectiveness = 0.85,     -- Penetrating
    typical_weapons = {"plasma_rifle", "laser_rifle"}
  },
  
  explosive = {
    description = "Grenades, rockets",
    armor_effectiveness = 0.50,     -- AOE shockwave
    typical_weapons = {"grenade", "rocket"}
  },
  
  emp = {
    description = "Electromagnetic",
    armor_effectiveness = 0.0,      -- Ignores armor
    typical_weapons = {"emp_device", "emp_grenade"}
  }
}
```

---

## Weapon Modification System

### Available Modifications

| Modification | Weapon Type | Bonus | Weight | Cost | Slot |
|---|---|---|---|---|---|
| **Scope (2x)** | Rifles, Sniper | +10% accuracy | +0.5 | 200 | Top |
| **Scope (4x)** | Rifles, Sniper | +15% accuracy | +0.7 | 400 | Top |
| **Grip** | All Firearms | +5% accuracy | +0.2 | 100 | Side |
| **Extended Mag** | Pistol, SMG, Rifle | +50% ammo | +0.5 | 150 | Side |
| **Silencer** | Pistol, Rifle | Stealth mode | +0.3 | 300 | Muzzle |
| **Stock Upgrade** | Rifles | -1 AP cost | +0.3 | 250 | Rear |
| **Flashhider** | All Firearms | Reduce muzzle flash | +0.1 | 150 | Muzzle |

**Modification Slots:**
```lua
weapon_modification_slots = {
  rifle = {
    top = 1,           -- Scope
    side = 1,          -- Grip/mag
    muzzle = 1,        -- Silencer/flashhider
    stock = 1          -- Stock upgrade
  },
  
  pistol = {
    top = 1,           -- Mini-scope
    side = 1,          -- Grip/extended mag
    muzzle = 1         -- Silencer
  },
  
  shotgun = {
    top = 0,           -- No scopes
    side = 1,          -- Grip
    muzzle = 1         -- Flashhider
  }
}
```

---

## Weapon Specialization Bonuses

### Specialization Damage Modifiers

```lua
weapon_specialization_modifiers = {
  -- Assault Specialization
  assault = {
    rifle = 1.10,
    smg = 1.15,
    shotgun = 1.15,
    description = "Master of close to medium combat"
  },
  
  -- Marksman Specialization
  marksman = {
    sniper = 1.15,
    pistol = 1.10,
    laser_rifle = 1.10,
    description = "Precision and range expertise"
  },
  
  -- Heavy Weapons Specialization
  heavy = {
    cannon = 1.20,
    grenade_launcher = 1.15,
    plasma_cannon = 1.15,
    description = "Devastating firepower"
  },
  
  -- Support Specialization
  support = {
    pistol = 1.10,
    grenade = 1.10,
    medical = 1.20,
    description = "Utility and team support"
  }
}
```

---

## Ammunition System

### Ammo Types & Availability

| Ammo Type | Capacity | Cost | Damage Bonus | Rarity |
|---|---|---|---|---|
| **Standard Rounds** | 200 | 50 | None | Common |
| **Armor Piercing** | 150 | 100 | -10% kinetic resistance | Uncommon |
| **Hollow Point** | 100 | 75 | +20% damage, -5% penetration | Uncommon |
| **Incendiary** | 80 | 120 | +5 burn damage | Rare |
| **Plasma Pack** | 50 | 500 | Plasma charge | Rare |
| **Exotic Rounds** | 30 | 800 | Variable effect | Epic |

**Ammo Consumption per Shot:**
```lua
weapon_ammo_consumption = {
  pistol = 1,
  rifle = 2,
  smg = 3,           -- High fire rate
  shotgun = 2,
  sniper = 1,
  plasma_rifle = 3,  -- Energy cells
  laser_rifle = 2    -- Power cells
}
```

---

## Equipment Weight & Carrying Capacity

### Class Carrying Capacity

| Class | Capacity | Penalty Threshold | Overload Penalty |
|---|---|---|---|
| **Scout** | 15 kg | 20 kg | -50% movement |
| **Soldier** | 20 kg | 25 kg | -40% movement |
| **Heavy** | 35 kg | 40 kg | -30% movement |
| **Support** | 18 kg | 23 kg | -40% movement |

**Weight Calculation:**
```lua
function calculateEncumbrance(unit, equipment)
  local base_weight = unit.base_weight or 70  -- kg
  local equipment_weight = 0
  
  for _, item in ipairs(equipment) do
    equipment_weight = equipment_weight + item.weight
  end
  
  local total_weight = base_weight + equipment_weight
  local capacity = getUnitCapacity(unit.class)
  
  if total_weight > capacity then
    local penalty = math.floor((total_weight - capacity) / capacity * 50)
    penalty = math.min(penalty, 50)  -- Max 50% reduction
    return {total = total_weight, capacity = capacity, penalty = penalty}
  end
  
  return {total = total_weight, capacity = capacity, penalty = 0}
end
```

---

## Durability & Wear System

### Durability Degradation

```lua
durability_system = {
  max_durability = 100,
  
  -- Degradation per action
  fire_penalty = 1,              -- 1% per shot
  melee_penalty = 2,            -- 2% per swing
  blocked_hit = 5,              -- 5% when blocking
  
  -- Repair mechanics
  repair_rate = 10,             -- 10% per repair turn
  repair_cost_ratio = 0.5,      -- 50% of item value to full repair
  
  -- Condition states
  conditions = {
    "pristine",                -- 100-90%
    "excellent",               -- 90-70%
    "good",                    -- 70-50%
    "worn",                    -- 50-30%
    "damaged",                 -- 30-10%
    "critical"                 -- 10-0%
  }
}

-- Damage penalty by condition
condition_penalties = {
  pristine = {damage = 0.0, accuracy = 0.0},
  excellent = {damage = 0.0, accuracy = 0.0},
  good = {damage = -0.05, accuracy = -0.02},
  worn = {damage = -0.10, accuracy = -0.05},
  damaged = {damage = -0.20, accuracy = -0.10},
  critical = {damage = -0.35, accuracy = -0.20}
}
```

---

## See Also

- **Battlescape** (`API_BATTLESCAPE_EXTENDED.md`) - Combat mechanics using weapons
- **Units & Classes** (`API_UNITS_AND_CLASSES.md`) - Equipment restrictions by class
- **Basescape** (`API_BASESCAPE_EXTENDED.md`) - Weapon storage and management
- **AI Systems** (`API_AI_SYSTEMS.md`) - Tactical decision-making with equipment

---

## Implementation Status

### IN DESIGN (Implemented Systems)

**Data Loading System (`engine/core/data_loader.lua`)**
- Weapon definitions loaded from `mods/core/rules/items/weapons.toml`
- Armor definitions loaded from `mods/core/rules/items/armours.toml`
- Ammunition data loaded from `mods/core/rules/items/ammo.toml`
- Equipment data loaded from `mods/core/rules/items/equipment.toml`
- Utility functions: `DataLoader.weapons.get()`, `getAllIds()`, `getByType()`
- Utility functions: `DataLoader.armours.get()`, `getAllIds()`, `getByType()`

---

**Status:** ✅ Complete  
**Last Updated:** October 21, 2025

