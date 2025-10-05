# Armor

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Armor system provides defensive equipment for units in Alien Fall through protective suits that reduce incoming damage, provide special resistances, and modify unit statistics including movement speed, inventory capacity, and environmental protection, creating strategic tradeoffs between protection, mobility, and tactical flexibility across technology tiers from basic vests through powered exoskeletons.

---

## Table of Contents
- [Overview](#overview)
- [Armor Types](#armor-types)
- [Damage Reduction Formula](#damage-reduction-formula)
- [Armor Penetration](#armor-penetration)
- [Armor Degradation](#armor-degradation)
- [Damage Type Effectiveness](#damage-type-effectiveness)
- [Special Armor Properties](#special-armor-properties)
- [Armor Comparison Tables](#armor-comparison-tables)
- [Lua Implementation](#lua-implementation)
- [Integration Points](#integration-points)
- [Cross-References](#cross-references)

---

## Overview

The Armor System provides defensive protection for units through damage reduction mechanics. Armor reduces incoming damage based on armor rating and damage type, with armor penetration mechanics allowing high-powered weapons to bypass protection. Armor can degrade during combat, reducing effectiveness over time.

**Core Principles:**
- **Damage Reduction:** Armor subtracts from incoming damage before health loss
- **Type Effectiveness:** Different damage types have varying effectiveness against armor
- **Armor Penetration:** Weapons can pierce armor partially or completely
- **Degradation:** Armor loses effectiveness when taking hits
- **Technology Progression:** Better armor materials provide superior protection

---

## Armor Types

### Human Armor Progression

| Armor Type | Armor Rating | Movement Penalty | Tech Required | Production Cost |
|------------|--------------|------------------|---------------|-----------------|
| **Civilian Clothes** | 0 | 0% | Starting | - |
| **Body Armor** | 20 | -5% | Starting | $5,000 |
| **Tactical Vest** | 30 | -5% | Advanced Materials | $10,000 |
| **Powered Armor** | 50 | -10% | Power Systems | $50,000 |
| **Laser-Resistant Armor** | 60 | -10% | Laser Tech | $75,000 |
| **Plasma Armor** | 80 | -5% | Plasma Tech | $150,000 |
| **Fusion Armor** | 100 | 0% | Fusion Tech | $250,000 |
| **Alien Alloy Armor** | 120 | +5% | Alien Materials | $500,000 |

### Alien Armor Types

| Armor Type | Armor Rating | Special Properties | Species |
|------------|--------------|-------------------|---------|
| **Sectoid Skin** | 10 | Psionic resistance +10 | Sectoid |
| **Floater Carapace** | 30 | Flying, fire resistance | Floater |
| **Muton Battle Armor** | 70 | High durability | Muton |
| **Snakeman Scales** | 50 | Poison immunity | Snakeman |
| **Ethereal Robes** | 40 | Psionic resistance +50 | Ethereal |

### Armor Coverage

```lua
-- Armor coverage system for hit locations
ArmorCoverage = {
    head = 0.7,      -- 70% armor effectiveness for head shots
    torso = 1.0,     -- 100% armor effectiveness for torso
    arms = 0.8,      -- 80% armor effectiveness for arms
    legs = 0.8,      -- 80% armor effectiveness for legs
}

function apply_coverage_modifier(armor_rating, hit_location)
    local coverage = ArmorCoverage[hit_location] or 1.0
    return armor_rating * coverage
end
```

---

## Damage Reduction Formula

### Basic Damage Reduction

```lua
-- Core damage calculation with armor
function calculate_damage_with_armor(base_damage, armor_rating, damage_type)
    -- Apply armor effectiveness for damage type
    local effective_armor = armor_rating * get_armor_effectiveness(damage_type)
    
    -- Damage reduction: subtract armor from damage
    local reduced_damage = math.max(0, base_damage - effective_armor)
    
    -- Minimum damage rule: at least 10% damage always gets through
    local minimum_damage = base_damage * 0.1
    reduced_damage = math.max(reduced_damage, minimum_damage)
    
    return math.floor(reduced_damage)
end
```

**Example Calculations:**

Body Armor (20 rating) vs Ballistic damage:
- 50 damage weapon: 50 - 20 = 30 damage (40% reduction)
- 25 damage weapon: 25 - 20 = 5 damage (80% reduction)
- 15 damage weapon: 15 - 20 = 0, but minimum 1.5 damage = 2 damage

Plasma Armor (80 rating) vs Ballistic damage:
- 100 damage weapon: 100 - 80 = 20 damage (80% reduction)
- 80 damage weapon: 80 - 80 = 0, but minimum 8 damage = 8 damage

### Advanced Damage Formula

```lua
-- Complete damage calculation with all modifiers
function calculate_final_damage(attacker, target, weapon, hit_location)
    -- Base damage with randomization
    local base_damage = weapon.damage
    local damage_variance = 0.15  -- ±15% variance
    local rng_modifier = 1.0 + (math.random() * 2 - 1) * damage_variance
    base_damage = base_damage * rng_modifier
    
    -- Get effective armor for hit location
    local armor_rating = target.armor.rating
    local effective_armor = apply_coverage_modifier(armor_rating, hit_location)
    
    -- Apply damage type effectiveness
    effective_armor = effective_armor * get_armor_effectiveness(weapon.damage_type)
    
    -- Apply armor penetration
    local penetration = weapon.armor_penetration or 0
    effective_armor = math.max(0, effective_armor - penetration)
    
    -- Calculate damage reduction
    local reduced_damage = math.max(0, base_damage - effective_armor)
    
    -- Minimum damage rule
    local minimum_damage = base_damage * 0.1
    reduced_damage = math.max(reduced_damage, minimum_damage)
    
    -- Critical hit multiplier
    if is_critical_hit(attacker, target) then
        reduced_damage = reduced_damage * 1.5
    end
    
    return math.floor(reduced_damage)
end
```

---

## Armor Penetration

### Penetration Mechanics

```lua
-- Weapon armor penetration values
WeaponPenetration = {
    -- Ballistic weapons
    pistol = 5,
    rifle = 15,
    sniper_rifle = 25,
    shotgun = 10,
    machine_gun = 20,
    
    -- Energy weapons
    laser_pistol = 20,
    laser_rifle = 30,
    heavy_laser = 40,
    
    plasma_pistol = 35,
    plasma_rifle = 50,
    heavy_plasma = 70,
    
    -- Explosives
    grenade = 0,          -- Area damage, ignores armor differently
    rocket = 10,
    blaster_bomb = 30,
    
    -- Melee
    knife = 2,
    stun_rod = 0,         -- Stun damage type
    alien_blade = 40,
}

function apply_armor_penetration(armor_rating, penetration_value)
    -- Penetration directly reduces effective armor
    local effective_armor = math.max(0, armor_rating - penetration_value)
    return effective_armor
end
```

### Penetration Examples

**Sniper Rifle (25 penetration) vs Powered Armor (50 rating):**
- Effective armor: 50 - 25 = 25
- 100 damage shot: 100 - 25 = 75 damage (25% reduction)

**Heavy Plasma (70 penetration) vs Fusion Armor (100 rating):**
- Effective armor: 100 - 70 = 30
- 150 damage shot: 150 - 30 = 120 damage (20% reduction)

**Pistol (5 penetration) vs Plasma Armor (80 rating):**
- Effective armor: 80 - 5 = 75
- 40 damage shot: 40 - 75 = 0, but minimum 4 damage

### Critical Hits and Penetration

```lua
-- Critical hits gain bonus penetration
function calculate_critical_penetration(weapon, is_critical)
    local base_penetration = weapon.armor_penetration or 0
    
    if is_critical then
        -- Critical hits gain +50% penetration
        return base_penetration * 1.5
    end
    
    return base_penetration
end
```

---

## Armor Degradation

### Degradation System

```lua
-- Armor degrades when taking damage
ArmorDegradation = {
    degradation_per_hit = 2,      -- Armor rating lost per hit
    max_degradation = 0.5,        -- Maximum 50% degradation
    repair_per_turn = 5,          -- Armor repair between missions
}

function apply_armor_degradation(unit, damage_taken)
    local armor = unit.armor
    
    if not armor or armor.rating <= 0 then
        return
    end
    
    -- Calculate degradation based on damage severity
    local degradation_amount = ArmorDegradation.degradation_per_hit
    
    -- Heavy hits cause more degradation
    if damage_taken >= 50 then
        degradation_amount = degradation_amount * 2
    elseif damage_taken >= 100 then
        degradation_amount = degradation_amount * 3
    end
    
    -- Apply degradation
    armor.current_rating = math.max(0, armor.current_rating - degradation_amount)
    
    -- Track total degradation
    armor.total_degradation = (armor.base_rating - armor.current_rating)
    
    -- Cap degradation at max percentage
    local max_degraded = armor.base_rating * ArmorDegradation.max_degradation
    if armor.total_degradation > max_degraded then
        armor.current_rating = armor.base_rating - max_degraded
    end
end
```

### Degradation Examples

**Powered Armor (50 rating) taking multiple hits:**
1. Start: 50 armor rating
2. Hit 1 (30 damage): 50 - 2 = 48 armor rating
3. Hit 2 (60 damage, heavy): 48 - 4 = 44 armor rating
4. Hit 3 (120 damage, massive): 44 - 6 = 38 armor rating
5. Maximum degradation: 50 × 0.5 = 25, minimum rating = 25

### Armor Repair

```lua
-- Armor repairs between missions
function repair_armor_post_mission(unit)
    local armor = unit.armor
    
    if not armor then
        return
    end
    
    -- Repair degradation
    local repair_amount = ArmorDegradation.repair_per_turn
    armor.current_rating = math.min(
        armor.base_rating,
        armor.current_rating + repair_amount
    )
    
    -- Full repair if at base
    if unit.location == "base" then
        armor.current_rating = armor.base_rating
        armor.total_degradation = 0
    end
end

-- Emergency field repairs (medic ability)
function field_repair_armor(medic, target, ap_cost)
    if medic.ap < ap_cost then
        return false
    end
    
    local armor = target.armor
    if not armor then
        return false
    end
    
    -- Repair small amount of armor
    local repair_amount = 10
    armor.current_rating = math.min(
        armor.base_rating,
        armor.current_rating + repair_amount
    )
    
    medic.ap = medic.ap - ap_cost
    return true
end
```

---

## Damage Type Effectiveness

### Damage Type Modifiers

```lua
-- Armor effectiveness vs different damage types
DamageTypeEffectiveness = {
    -- Armor Type -> Damage Type -> Effectiveness multiplier
    body_armor = {
        ballistic = 1.0,      -- Full effectiveness
        laser = 0.6,          -- 60% effective (lasers bypass some armor)
        plasma = 0.4,         -- 40% effective (plasma melts armor)
        explosive = 0.8,      -- 80% effective (good vs shrapnel)
        fire = 0.5,           -- 50% effective (burns through)
        poison = 0.0,         -- 0% effective (poison ignores armor)
        stun = 0.5,           -- 50% effective (some absorption)
        psionic = 0.0,        -- 0% effective (mental attacks)
    },
    
    laser_resistant_armor = {
        ballistic = 1.0,
        laser = 1.2,          -- 120% effective (enhanced vs lasers)
        plasma = 0.6,
        explosive = 0.9,
        fire = 0.8,
        poison = 0.0,
        stun = 0.6,
        psionic = 0.0,
    },
    
    plasma_armor = {
        ballistic = 1.1,      -- Slightly better vs ballistic
        laser = 1.3,          -- Excellent vs lasers
        plasma = 1.0,         -- Standard vs plasma
        explosive = 1.0,
        fire = 1.2,           -- Good vs fire
        poison = 0.2,         -- Some resistance
        stun = 0.7,
        psionic = 0.0,
    },
    
    fusion_armor = {
        ballistic = 1.2,
        laser = 1.4,
        plasma = 1.3,
        explosive = 1.2,
        fire = 1.5,           -- Excellent fire protection
        poison = 0.5,         -- Sealed suit
        stun = 1.0,
        psionic = 0.1,        -- Minimal psionic protection
    },
    
    alien_alloy_armor = {
        ballistic = 1.3,      -- Superior vs all types
        laser = 1.5,
        plasma = 1.4,
        explosive = 1.3,
        fire = 1.4,
        poison = 1.0,         -- Full immunity
        stun = 1.2,
        psionic = 0.3,        -- Some psionic shielding
    },
}

function get_armor_effectiveness(armor_type, damage_type)
    local armor_table = DamageTypeEffectiveness[armor_type]
    
    if not armor_table then
        return 1.0  -- Default effectiveness
    end
    
    return armor_table[damage_type] or 1.0
end
```

### Effectiveness Examples

**Plasma Rifle (150 damage) vs Body Armor (20 rating):**
- Armor effectiveness: 20 × 0.4 = 8 effective armor
- Damage: 150 - 8 = 142 damage (only 5% reduction)

**Plasma Rifle (150 damage) vs Plasma Armor (80 rating):**
- Armor effectiveness: 80 × 1.0 = 80 effective armor
- Damage: 150 - 80 = 70 damage (53% reduction)

**Ballistic Rifle (100 damage) vs Fusion Armor (100 rating):**
- Armor effectiveness: 100 × 1.2 = 120 effective armor
- Damage: 100 - 120 = 0, but minimum 10 damage

### Damage Type System

```lua
-- Damage type enumeration
DamageType = {
    BALLISTIC = "ballistic",
    LASER = "laser",
    PLASMA = "plasma",
    EXPLOSIVE = "explosive",
    FIRE = "fire",
    POISON = "poison",
    STUN = "stun",
    PSIONIC = "psionic",
    MELEE = "melee",
}

-- Complete damage calculation with type effectiveness
function apply_damage_to_unit(attacker, target, weapon, hit_location)
    -- Get base damage
    local base_damage = weapon.damage
    
    -- Get effective armor
    local armor_rating = target.armor.current_rating or target.armor.rating
    armor_rating = apply_coverage_modifier(armor_rating, hit_location)
    
    -- Apply damage type effectiveness
    local armor_type = target.armor.type
    local damage_type = weapon.damage_type
    local effectiveness = get_armor_effectiveness(armor_type, damage_type)
    local effective_armor = armor_rating * effectiveness
    
    -- Apply penetration
    local penetration = weapon.armor_penetration or 0
    if is_critical_hit(attacker, target) then
        penetration = penetration * 1.5
    end
    effective_armor = math.max(0, effective_armor - penetration)
    
    -- Calculate final damage
    local damage = math.max(0, base_damage - effective_armor)
    damage = math.max(damage, base_damage * 0.1)  -- Minimum 10%
    
    -- Apply damage to target
    target.health = target.health - damage
    
    -- Apply armor degradation
    if damage > 0 then
        apply_armor_degradation(target, damage)
    end
    
    return damage
end
```

---

## Special Armor Properties

### Environmental Protection

```lua
-- Armor provides environmental protection
ArmorEnvironmentalProtection = {
    body_armor = {
        fire_resistance = 0.2,
        cold_resistance = 0.1,
        radiation_resistance = 0.0,
        underwater = false,
    },
    
    powered_armor = {
        fire_resistance = 0.5,
        cold_resistance = 0.5,
        radiation_resistance = 0.3,
        underwater = false,
    },
    
    fusion_armor = {
        fire_resistance = 0.9,
        cold_resistance = 0.9,
        radiation_resistance = 0.8,
        underwater = true,
    },
    
    alien_alloy_armor = {
        fire_resistance = 1.0,      -- Immune
        cold_resistance = 1.0,      -- Immune
        radiation_resistance = 1.0, -- Immune
        underwater = true,
        vacuum = true,
    },
}

function apply_environmental_damage(unit, environment_type, damage)
    local armor = unit.armor
    
    if not armor then
        return damage
    end
    
    local protection = ArmorEnvironmentalProtection[armor.type]
    
    if not protection then
        return damage
    end
    
    -- Get resistance for environment type
    local resistance = protection[environment_type .. "_resistance"] or 0
    
    -- Reduce damage by resistance
    local reduced_damage = damage * (1.0 - resistance)
    
    return math.floor(reduced_damage)
end
```

### Powered Armor Special Abilities

```lua
-- Powered armor grants special abilities
PoweredArmorAbilities = {
    strength_bonus = 20,      -- +20 strength for carrying capacity
    speed_bonus = 10,         -- +10 speed despite weight
    jump_height = 2,          -- Can jump 2 tiles high
    energy_shield = 20,       -- 20 HP regenerating shield
    night_vision = true,      -- See in darkness
    radar = true,             -- Detect enemies in 10 tile radius
}

function apply_powered_armor_bonuses(unit)
    if unit.armor.type ~= "powered_armor" then
        return
    end
    
    -- Apply stat bonuses
    unit.strength = unit.strength + PoweredArmorAbilities.strength_bonus
    unit.speed = unit.speed + PoweredArmorAbilities.speed_bonus
    
    -- Grant abilities
    unit.abilities.jump = PoweredArmorAbilities.jump_height
    unit.abilities.night_vision = PoweredArmorAbilities.night_vision
    unit.abilities.radar = PoweredArmorAbilities.radar
    
    -- Energy shield
    unit.shield = {
        current = PoweredArmorAbilities.energy_shield,
        max = PoweredArmorAbilities.energy_shield,
        regen_per_turn = 5,
    }
end
```

---

## Armor Comparison Tables

### Protection vs Damage Types

| Armor Type | Ballistic | Laser | Plasma | Explosive | Fire | Poison |
|------------|-----------|-------|--------|-----------|------|--------|
| **Body Armor** | 20 (100%) | 12 (60%) | 8 (40%) | 16 (80%) | 10 (50%) | 0 (0%) |
| **Tactical Vest** | 30 (100%) | 18 (60%) | 12 (40%) | 24 (80%) | 15 (50%) | 0 (0%) |
| **Powered Armor** | 50 (100%) | 30 (60%) | 20 (40%) | 40 (80%) | 25 (50%) | 0 (0%) |
| **Laser-Resistant** | 60 (100%) | 72 (120%) | 36 (60%) | 54 (90%) | 48 (80%) | 0 (0%) |
| **Plasma Armor** | 88 (110%) | 104 (130%) | 80 (100%) | 80 (100%) | 96 (120%) | 16 (20%) |
| **Fusion Armor** | 120 (120%) | 140 (140%) | 130 (130%) | 120 (120%) | 150 (150%) | 50 (50%) |
| **Alien Alloy** | 156 (130%) | 180 (150%) | 168 (140%) | 156 (130%) | 168 (140%) | 120 (100%) |

*Values show: Effective Rating (Effectiveness %)*

### Weight and Movement Impact

| Armor Type | Weight (kg) | Movement Penalty | Encumbrance |
|------------|-------------|------------------|-------------|
| Civilian Clothes | 2 | 0% | 2 |
| Body Armor | 10 | -5% | 10 |
| Tactical Vest | 12 | -5% | 12 |
| Powered Armor | 40 | -10% | 20 (powered assist) |
| Laser-Resistant | 15 | -10% | 15 |
| Plasma Armor | 18 | -5% | 18 |
| Fusion Armor | 20 | 0% | 10 (lightweight materials) |
| Alien Alloy | 15 | +5% | 5 (enhanced mobility) |

### Cost-Effectiveness Analysis

| Armor Type | Cost | Armor Rating | Cost per Point | Production Time |
|------------|------|--------------|----------------|-----------------|
| Body Armor | $5,000 | 20 | $250 | 5 days |
| Tactical Vest | $10,000 | 30 | $333 | 7 days |
| Powered Armor | $50,000 | 50 | $1,000 | 15 days |
| Laser-Resistant | $75,000 | 60 | $1,250 | 20 days |
| Plasma Armor | $150,000 | 80 | $1,875 | 30 days |
| Fusion Armor | $250,000 | 100 | $2,500 | 45 days |
| Alien Alloy | $500,000 | 120 | $4,167 | 60 days |

---

## Lua Implementation

### Complete Armor System

```lua
-- Armor system implementation
Armor = {}
Armor.__index = Armor

function Armor:new(armor_type)
    local armor = setmetatable({}, Armor)
    
    -- Load armor stats from data
    local stats = ArmorStats[armor_type]
    
    armor.type = armor_type
    armor.base_rating = stats.rating
    armor.current_rating = stats.rating
    armor.weight = stats.weight
    armor.movement_penalty = stats.movement_penalty
    armor.special_properties = stats.special_properties or {}
    armor.total_degradation = 0
    
    return armor
end

function Armor:get_effective_rating(damage_type, hit_location)
    -- Start with current rating (accounting for degradation)
    local rating = self.current_rating
    
    -- Apply hit location coverage
    rating = apply_coverage_modifier(rating, hit_location)
    
    -- Apply damage type effectiveness
    local effectiveness = get_armor_effectiveness(self.type, damage_type)
    rating = rating * effectiveness
    
    return rating
end

function Armor:apply_damage(damage_amount)
    -- Calculate degradation
    local degradation = ArmorDegradation.degradation_per_hit
    
    if damage_amount >= 100 then
        degradation = degradation * 3
    elseif damage_amount >= 50 then
        degradation = degradation * 2
    end
    
    -- Apply degradation
    self.current_rating = math.max(0, self.current_rating - degradation)
    self.total_degradation = self.base_rating - self.current_rating
    
    -- Cap at maximum degradation
    local max_degraded = self.base_rating * ArmorDegradation.max_degradation
    if self.total_degradation > max_degraded then
        self.current_rating = self.base_rating - max_degraded
    end
end

function Armor:repair(amount)
    self.current_rating = math.min(self.base_rating, self.current_rating + amount)
    self.total_degradation = self.base_rating - self.current_rating
end

function Armor:full_repair()
    self.current_rating = self.base_rating
    self.total_degradation = 0
end

function Armor:get_condition_percent()
    return (self.current_rating / self.base_rating) * 100
end
```

### Damage Application System

```lua
-- Complete damage system with armor
DamageSystem = {}

function DamageSystem.apply_damage(attacker, target, weapon, hit_location)
    -- Base damage with variance
    local base_damage = weapon.damage * (0.85 + math.random() * 0.3)
    
    -- Get target armor
    local armor = target.armor
    local effective_armor = 0
    
    if armor then
        -- Get effective armor rating
        effective_armor = armor:get_effective_rating(weapon.damage_type, hit_location)
        
        -- Apply penetration
        local penetration = weapon.armor_penetration or 0
        if attacker.critical_hit then
            penetration = penetration * 1.5
        end
        effective_armor = math.max(0, effective_armor - penetration)
    end
    
    -- Calculate damage
    local damage = math.max(0, base_damage - effective_armor)
    damage = math.max(damage, base_damage * 0.1)  -- Minimum 10%
    
    -- Apply to target
    target.health = target.health - damage
    
    -- Degrade armor
    if armor and damage > 0 then
        armor:apply_damage(damage)
    end
    
    -- Return damage result
    return {
        damage = math.floor(damage),
        armor_absorbed = math.floor(effective_armor),
        armor_degraded = armor and armor.total_degradation or 0,
        critical = attacker.critical_hit,
    }
end
```

---

## Integration Points

### Unit System Integration
```lua
-- Units equipped with armor
function equip_armor(unit, armor_type)
    unit.armor = Armor:new(armor_type)
    
    -- Apply movement penalty
    unit.speed_modifier = unit.speed_modifier + unit.armor.movement_penalty
    
    -- Apply special abilities (powered armor)
    if unit.armor.type == "powered_armor" then
        apply_powered_armor_bonuses(unit)
    end
end

function unequip_armor(unit)
    if not unit.armor then
        return
    end
    
    -- Remove movement penalty
    unit.speed_modifier = unit.speed_modifier - unit.armor.movement_penalty
    
    -- Remove special abilities
    if unit.armor.type == "powered_armor" then
        remove_powered_armor_bonuses(unit)
    end
    
    unit.armor = nil
end
```

### Combat System Integration
```lua
-- Combat damage resolution
function resolve_attack(attacker, target, weapon)
    -- Hit chance calculation
    local hit_roll = math.random()
    local hit_chance = calculate_hit_chance(attacker, target, weapon)
    
    if hit_roll > hit_chance then
        return {hit = false, damage = 0}
    end
    
    -- Determine hit location
    local hit_location = determine_hit_location()
    
    -- Check for critical hit
    attacker.critical_hit = check_critical_hit(attacker, target)
    
    -- Apply damage with armor
    local result = DamageSystem.apply_damage(attacker, target, weapon, hit_location)
    result.hit = true
    result.location = hit_location
    
    return result
end
```

---

## Cross-References

### Related Systems
- **[Stats.md](Stats.md)** - Unit statistics and derived values
- **[Weapon_Comparisons.md](../items/Weapon_Comparisons.md)** - Weapon damage and penetration
- **[Cover.md](../battlescape/Cover.md)** - Cover and armor interaction
- **[Status_Effects.md](../battlescape/Status_Effects.md)** - Status effects on armor
- **[Progression.md](Progression.md)** - Armor unlocks through tech tree

### Design Documents
- **Damage Calculations** - Complete damage system
- **Tech Tree** - Armor research progression
- **Item Crafting** - Armor production requirements

---

**Implementation Status:** Complete specification ready for coding  
**Testing Requirements:** 
- Damage reduction calculations
- Armor penetration mechanics
- Degradation system
- Type effectiveness tables
- Environmental protection

**Version History:**
- v1.0 (2025-09-30): Initial complete specification with formulas and Lua code
