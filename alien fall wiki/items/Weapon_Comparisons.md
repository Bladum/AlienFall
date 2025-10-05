# Weapon Comparisons

## Table of Contents
- [Overview](#overview)
- [Comparison Tables](#comparison-tables)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Weapon Comparisons reference provides comprehensive statistical tables comparing all weapons in Alien Fall across damage, accuracy, range, action point cost, ammunition capacity, and special effects to support informed tactical loadout decisions and equipment research prioritization through side-by-side analysis of conventional, laser, plasma, and experimental weapon technologies.  
**Purpose:** Comprehensive comparison of all weapons including damage, range, accuracy, AP cost, and tactical analysis.

---

## Overview

This document provides detailed statistical comparisons for all weapons available in the game. Weapons are categorized by technology tier (Conventional, Laser, Plasma, Exotic) and type (Pistol, Rifle, Heavy, Special).

### Weapon Categories

1. **Conventional Weapons** - Starting human ballistic weapons
2. **Laser Weapons** - First tier alien tech adaptation
3. **Plasma Weapons** - Advanced alien energy weapons
4. **Exotic Weapons** - Specialized and unique weapons

---

## Weapon Statistics Summary

### Complete Weapon Table (XCOM/5 Scaling)

**CRITICAL NOTE**: All values use XCOM/5 scaling. Range is in tiles where 1 map block = 15 tiles. NO AMMO CLIPS - all weapons use Energy Pool system.

| Weapon | Tech | Damage | Range | Accuracy | AP Cost | EP Cost | EP Add | Weight | Regen |
|--------|------|--------|-------|----------|---------|---------|--------|--------|-------|
| **Pistols** |
| Pistol | Conv | 5 | 15 | 50% | 1 | 1 | +5 | 1 | +0 |
| Laser Pistol | Laser | 6 | 18 | 60% | 1 | 1 | +8 | 1 | +0 |
| Plasma Pistol | Plasma | 7 | 21 | 65% | 1 | 1 | +10 | 1 | +1 |
| **Rifles** |
| Rifle | Conv | 6 | 30 | 70% | 2 | 2 | +10 | 2 | +0 |
| Laser Rifle | Laser | 8 | 35 | 75% | 2 | 2 | +12 | 2 | +1 |
| Plasma Rifle | Plasma | 10 | 40 | 80% | 2 | 2 | +15 | 2 | +1 |
| **Heavy Weapons** |
| Heavy Cannon | Conv | 11 | 30 | 50% | 3 | 3 | +15 | 10 | +1 |
| Heavy Laser | Laser | 13 | 35 | 60% | 3 | 3 | +20 | 10 | +2 |
| Heavy Plasma | Plasma | 17 | 40 | 70% | 3 | 3 | +25 | 12 | +2 |
| **Automatic** |
| Auto-Rifle | Conv | 4 | 25 | 60% | 1 | 1 | +12 | 3 | +0 |
| Laser Auto | Laser | 5 | 30 | 65% | 1 | 1 | +15 | 3 | +1 |
| **Shotguns** |
| Shotgun | Conv | 8 | 10 | 70% | 2 | 2 | +8 | 3 | +0 |
| **Sniper** |
| Sniper Rifle | Conv | 7 | 45 | 90% | 3 | 3 | +12 | 3 | +0 |
| Laser Sniper | Laser | 9 | 50 | 95% | 3 | 3 | +15 | 3 | +1 |
| **Explosives** |
| Grenade | Conv | 10 | 15 | - | 2 | 4 | +0 | 1 | +0 |
| Plasma Grenade | Plasma | 15 | 18 | - | 2 | 4 | +0 | 1 | +0 |
| Rocket Launcher | Conv | 20 | 30 | 75% | 3 | 5 | +20 | 15 | +1 |
| **Special** |
| Stun Rod | Conv | 0/16* | 1 | 70% | 2 | 2 | +5 | 1 | +0 |

*Stun damage only
**EP Add** = Energy Pool contribution (added to unit's total EP)
**Regen** = Energy regeneration bonus per turn
**Range** = Maximum effective range in tiles (15 tiles = 1 map block)

---

## Detailed Weapon Analysis

## Conventional Weapons

### Pistol

**Basic Stats:**
- Damage: 18
- Range: 12 tiles
- Accuracy: 60%
- AP Cost: 2
- Ammo: 12 rounds
- Reload: 1 AP
- Weight: 2 kg

**Tactical Analysis:**
Starting sidearm with limited effectiveness. Best used as backup weapon or for scouts/rookies.

```lua
Weapon_Pistol = {
    name = "Pistol",
    type = "pistol",
    tech = "conventional",
    damage = {min = 15, max = 21, avg = 18},
    range = 12,
    accuracy = 0.6,
    apCost = 2,
    ammo = 12,
    reloadAP = 1,
    weight = 2,
    damageType = "kinetic",
    armorPiercing = 0,
    twoHanded = false
}

function Weapon_Pistol:calculateDamage(target)
    local baseDamage = math.random(self.damage.min, self.damage.max)
    local distance = self:getDistance(target)
    
    -- Range falloff: -5% per tile beyond optimal (6 tiles)
    local rangePenalty = math.max(0, distance - 6) * 0.05
    local damageMultiplier = 1 - rangePenalty
    
    return math.floor(baseDamage * damageMultiplier)
end
```

**Pros:**
- Low AP cost enables multiple shots
- Light weight doesn't impede mobility
- One-handed allows shield use
- Cheap and readily available

**Cons:**
- Low damage output
- Poor accuracy at range
- Ineffective against armor
- Limited ammo capacity

**Best Used For:**
- Backup weapon for specialists
- Close quarters combat
- Finishing wounded enemies
- Low-risk scouting

---

### Rifle

**Basic Stats:**
- Damage: 30
- Range: 20 tiles
- Accuracy: 65%
- AP Cost: 3
- Ammo: 20 rounds
- Reload: 1 AP
- Weight: 4 kg

**Tactical Analysis:**
Standard infantry weapon. Good all-around performance with decent damage and range.

```lua
Weapon_Rifle = {
    name = "Rifle",
    type = "rifle",
    tech = "conventional",
    damage = {min = 25, max = 35, avg = 30},
    range = 20,
    accuracy = 0.65,
    apCost = 3,
    ammo = 20,
    reloadAP = 1,
    weight = 4,
    damageType = "kinetic",
    armorPiercing = 5,
    snapShot = {apCost = 2, accuracyMod = -0.15},
    aimedShot = {apCost = 4, accuracyMod = 0.20},
    autoShot = {apCost = 4, shots = 3, accuracyMod = -0.25}
}

function Weapon_Rifle:getFireMode(ap)
    if ap >= 4 then
        return {"snap", "aimed", "auto"}
    elseif ap >= 3 then
        return {"snap", "aimed"}
    elseif ap >= 2 then
        return {"snap"}
    end
    return {}
end
```

**Fire Modes:**
- **Snap Shot:** 2 AP, -15% accuracy, single shot
- **Aimed Shot:** 4 AP, +20% accuracy, single shot
- **Auto Shot:** 4 AP, -25% accuracy, 3-round burst

**Pros:**
- Versatile fire modes
- Decent armor penetration
- Good ammo capacity
- Effective at medium range

**Cons:**
- Moderate AP cost limits mobility
- Mediocre accuracy
- Outclassed by laser/plasma quickly
- Heavy for scouts

**Best Used For:**
- Main infantry weapon early game
- Balanced combat approach
- Auto-fire for suppression
- General purpose combat

---

### Heavy Cannon

**Basic Stats:**
- Damage: 56
- Range: 25 tiles
- Accuracy: 50%
- AP Cost: 4
- Ammo: 6 rounds
- Reload: 2 AP
- Weight: 12 kg

**Tactical Analysis:**
High damage but cumbersome. Best for stationary heavy weapons specialists.

```lua
Weapon_HeavyCannon = {
    name = "Heavy Cannon",
    type = "heavy",
    tech = "conventional",
    damage = {min = 48, max = 64, avg = 56},
    range = 25,
    accuracy = 0.5,
    apCost = 4,
    ammo = 6,
    reloadAP = 2,
    weight = 12,
    damageType = "kinetic",
    armorPiercing = 15,
    explosiveRadius = 2,
    minStrength = 45, -- Requires high strength
    twoHanded = true
}

function Weapon_HeavyCannon:canEquip(unit)
    if unit.stats.strength < self.minStrength then
        return false, "Insufficient strength"
    end
    return true
end

function Weapon_HeavyCannon:calculateExplosion(impactTile)
    local affected = self:getTilesInRadius(impactTile, self.explosiveRadius)
    
    for _, tile in ipairs(affected) do
        local distance = self:getDistance(tile, impactTile)
        local damageMultiplier = 1 - (distance / self.explosiveRadius) * 0.5
        
        for _, unit in ipairs(tile:getUnits()) do
            local damage = self.damage.avg * damageMultiplier
            unit:takeDamage(damage, "explosive")
        end
    end
end
```

**Ammunition Types:**
- **HE (High Explosive):** Standard, 2-tile blast radius
- **AP (Armor Piercing):** +50% armor penetration, no explosion
- **Incendiary:** Creates fire, less direct damage

**Pros:**
- Highest conventional damage
- Area damage effective vs clusters
- Strong armor penetration
- Multiple ammo types

**Cons:**
- Very heavy, slows mobility
- Poor accuracy
- Low ammo capacity
- High AP cost
- Strength requirement

**Best Used For:**
- Destroying cover
- Area denial
- Heavy armor targets
- Base defense turrets

---

### Auto-Cannon

**Basic Stats:**
- Damage: 42 (per shot)
- Range: 17 tiles
- Accuracy: 55%
- AP Cost: 2 (burst)
- Ammo: 14 rounds
- Reload: 2 AP
- Weight: 10 kg

**Tactical Analysis:**
Suppression weapon with sustained fire capability.

```lua
Weapon_AutoCannon = {
    name = "Auto-Cannon",
    type = "automatic",
    tech = "conventional",
    damage = {min = 38, max = 46, avg = 42},
    range = 17,
    accuracy = 0.55,
    apCost = 2, -- Per burst
    shotsPerBurst = 3,
    ammo = 14,
    reloadAP = 2,
    weight = 10,
    damageType = "kinetic",
    armorPiercing = 8,
    twoHanded = true
}

function Weapon_AutoCannon:fireBurst(target)
    local hits = 0
    local totalDamage = 0
    
    for i = 1, self.shotsPerBurst do
        -- Each shot has independent hit chance
        local hitChance = self.accuracy * target:getCoverModifier()
        
        -- Recoil penalty: -10% per shot after first
        if i > 1 then
            hitChance = hitChance * (1 - (i - 1) * 0.1)
        end
        
        if math.random() < hitChance then
            local damage = math.random(self.damage.min, self.damage.max)
            target:takeDamage(damage, self.damageType)
            totalDamage = totalDamage + damage
            hits = hits + 1
        end
    end
    
    return {hits = hits, damage = totalDamage}
end
```

**Pros:**
- Multiple chances to hit per burst
- Good for suppression
- Decent armor penetration
- Lower AP cost per shot

**Cons:**
- Heavy and unwieldy
- Accuracy degrades in burst
- High ammo consumption
- Strength requirement

**Best Used For:**
- Suppressing enemy positions
- Overwhelming single targets
- Destroying light cover
- Reaction fire

---

### Shotgun

**Basic Stats:**
- Damage: 48
- Range: 8 tiles
- Accuracy: 70%
- AP Cost: 3
- Ammo: 6 shells
- Reload: 2 AP
- Weight: 5 kg

**Tactical Analysis:**
Close quarters devastation with pellet spread.

```lua
Weapon_Shotgun = {
    name = "Shotgun",
    type = "shotgun",
    tech = "conventional",
    damage = {min = 40, max = 56, avg = 48},
    range = 8,
    accuracy = 0.7,
    apCost = 3,
    pellets = 6,
    spread = 0.3, -- 30% spread angle
    ammo = 6,
    reloadAP = 2,
    weight = 5,
    damageType = "kinetic",
    armorPiercing = 3,
    twoHanded = true
}

function Weapon_Shotgun:fire(target)
    local totalDamage = 0
    local hits = 0
    
    for i = 1, self.pellets do
        -- Each pellet has independent trajectory
        local spreadAngle = (math.random() - 0.5) * self.spread
        local pelletTarget = self:applySpread(target, spreadAngle)
        
        -- Hit chance per pellet
        local baseAccuracy = self.accuracy
        local distance = self:getDistance(target)
        
        -- Severe range penalty beyond 5 tiles
        if distance > 5 then
            baseAccuracy = baseAccuracy * (1 - (distance - 5) * 0.15)
        end
        
        if math.random() < baseAccuracy then
            local damage = math.random(8, 12) -- Per pellet
            pelletTarget:takeDamage(damage, self.damageType)
            totalDamage = totalDamage + damage
            hits = hits + 1
        end
    end
    
    return {hits = hits, damage = totalDamage}
end
```

**Pros:**
- Devastating at close range
- Multiple pellets increase hit chance
- Good against unarmored targets
- Effective in buildings/corridors

**Cons:**
- Extremely limited range
- Poor armor penetration
- High AP cost
- Limited ammo capacity

**Best Used For:**
- Room clearing
- Point defense
- Ambush tactics
- Finishing wounded enemies

---

### Sniper Rifle

**Basic Stats:**
- Damage: 55
- Range: 40 tiles
- Accuracy: 80%
- AP Cost: 4
- Ammo: 8 rounds
- Reload: 2 AP
- Weight: 6 kg

**Tactical Analysis:**
Precision weapon for long-range elimination.

```lua
Weapon_SniperRifle = {
    name = "Sniper Rifle",
    type = "sniper",
    tech = "conventional",
    damage = {min = 50, max = 60, avg = 55},
    range = 40,
    accuracy = 0.8,
    apCost = 4,
    ammo = 8,
    reloadAP = 2,
    weight = 6,
    damageType = "kinetic",
    armorPiercing = 20,
    critChance = 0.25, -- 25% crit chance
    critMultiplier = 2.0,
    scopeBonus = 0.15, -- +15% accuracy when stationary
    twoHanded = true
}

function Weapon_SniperRifle:calculateHit(shooter, target)
    local baseAccuracy = self.accuracy
    
    -- Scope bonus if didn't move this turn
    if not shooter:hasMovedThisTurn() then
        baseAccuracy = baseAccuracy + self.scopeBonus
    end
    
    -- Range bonus: +5% accuracy per 5 tiles (optimal at long range)
    local distance = shooter:getDistance(target)
    if distance > 15 then
        local rangeBonus = math.floor((distance - 15) / 5) * 0.05
        baseAccuracy = baseAccuracy + rangeBonus
    end
    
    -- Apply shooter accuracy stat
    local finalAccuracy = baseAccuracy * (shooter.stats.accuracy / 100)
    
    return finalAccuracy
end

function Weapon_SniperRifle:calculateDamage(target)
    local baseDamage = math.random(self.damage.min, self.damage.max)
    
    -- Critical hit check
    if math.random() < self.critChance then
        baseDamage = baseDamage * self.critMultiplier
        target:showFloatingText("CRITICAL!", {255, 0, 0})
    end
    
    return baseDamage
end
```

**Pros:**
- Exceptional accuracy
- Very long range
- High damage
- Strong armor penetration
- Critical hit potential
- Scope bonus when stationary

**Cons:**
- High AP cost limits mobility
- Low ammo capacity
- Requires line of sight
- Ineffective at close range
- Heavy weapon

**Best Used For:**
- High-value target elimination
- Overwatch positions
- Flanking shots
- Supporting fire from rear

---

## Laser Weapons

### Laser Pistol

**Basic Stats:**
- Damage: 26
- Range: 15 tiles
- Accuracy: 70%
- AP Cost: 2
- Ammo: Infinite (battery powered)
- Weight: 2 kg

**Tactical Analysis:**
Reliable sidearm with unlimited ammunition.

```lua
Weapon_LaserPistol = {
    name = "Laser Pistol",
    type = "pistol",
    tech = "laser",
    damage = {min = 22, max = 30, avg = 26},
    range = 15,
    accuracy = 0.7,
    apCost = 2,
    ammo = math.huge, -- Infinite
    weight = 2,
    damageType = "laser",
    armorPiercing = 8,
    energyCost = 5, -- Per shot
    twoHanded = false
}

function Weapon_LaserPistol:canFire(unit)
    if unit.energy < self.energyCost then
        return false, "Insufficient energy"
    end
    return true
end

function Weapon_LaserPistol:fire(target)
    local shooter = self.owner
    shooter:useEnergy(self.energyCost)
    
    -- Laser accuracy not affected by smoke/darkness
    local baseAccuracy = self.accuracy
    local distance = shooter:getDistance(target)
    
    -- Minor range falloff
    if distance > 10 then
        baseAccuracy = baseAccuracy * (1 - (distance - 10) * 0.03)
    end
    
    local hitChance = baseAccuracy * (shooter.stats.accuracy / 100)
    
    if math.random() < hitChance then
        local damage = math.random(self.damage.min, self.damage.max)
        target:takeDamage(damage, self.damageType)
        return true
    end
    
    return false
end
```

**Pros:**
- Infinite ammo
- Better accuracy than conventional
- Light weight
- No smoke/darkness penalty
- One-handed

**Cons:**
- Requires unit energy
- Moderate damage
- Energy cost limits sustained fire

**Best Used For:**
- Reliable backup weapon
- Scouts and infiltrators
- Extended missions
- Energy-efficient combat

---

### Laser Rifle

**Basic Stats:**
- Damage: 40
- Range: 25 tiles
- Accuracy: 75%
- AP Cost: 3
- Ammo: Infinite
- Weight: 4 kg

**Tactical Analysis:**
Workhorse weapon with no ammunition concerns.

```lua
Weapon_LaserRifle = {
    name = "Laser Rifle",
    type = "rifle",
    tech = "laser",
    damage = {min = 35, max = 45, avg = 40},
    range = 25,
    accuracy = 0.75,
    apCost = 3,
    ammo = math.huge,
    weight = 4,
    damageType = "laser",
    armorPiercing = 12,
    energyCost = 8,
    snapShot = {apCost = 2, accuracyMod = -0.10, energyCost = 6},
    aimedShot = {apCost = 4, accuracyMod = 0.25, energyCost = 10},
    twoHanded = true
}
```

**Fire Modes:**
- **Snap Shot:** 2 AP, 6 energy, -10% accuracy
- **Aimed Shot:** 4 AP, 10 energy, +25% accuracy
- **Standard:** 3 AP, 8 energy, base accuracy

**Pros:**
- No reload required
- Excellent accuracy
- Good damage
- Decent armor penetration
- No ammo weight
- Multiple fire modes

**Cons:**
- Energy consumption limits shots
- Must rest to regenerate energy
- Moderate weight

**Best Used For:**
- Primary infantry weapon mid-game
- Long missions without resupply
- Accurate fire
- Versatile combat

---

### Heavy Laser

**Basic Stats:**
- Damage: 65
- Range: 30 tiles
- Accuracy: 60%
- AP Cost: 4
- Ammo: Infinite
- Weight: 10 kg

**Tactical Analysis:**
Heavy firepower without ammunition logistics.

```lua
Weapon_HeavyLaser = {
    name = "Heavy Laser",
    type = "heavy",
    tech = "laser",
    damage = {min = 58, max = 72, avg = 65},
    range = 30,
    accuracy = 0.6,
    apCost = 4,
    ammo = math.huge,
    weight = 10,
    damageType = "laser",
    armorPiercing = 18,
    energyCost = 15,
    minStrength = 40,
    twoHanded = true,
    overloadShot = {apCost = 5, energyCost = 30, damageBonus = 0.5}
}

function Weapon_HeavyLaser:overloadShot(target)
    local shooter = self.owner
    
    if shooter.energy < self.overloadShot.energyCost then
        return false, "Insufficient energy for overload"
    end
    
    shooter:useEnergy(self.overloadShot.energyCost)
    shooter:useAP(self.overloadShot.apCost)
    
    -- Increased damage and armor penetration
    local baseDamage = math.random(self.damage.min, self.damage.max)
    local overloadDamage = baseDamage * (1 + self.overloadShot.damageBonus)
    
    target:takeDamage(overloadDamage, self.damageType, {
        armorPiercing = self.armorPiercing * 1.5
    })
    
    return true
end
```

**Fire Modes:**
- **Standard:** 4 AP, 15 energy, base damage
- **Overload:** 5 AP, 30 energy, +50% damage, +50% AP

**Pros:**
- High damage output
- No reload downtime
- Strong armor penetration
- Overload mode for tough targets
- Better accuracy than Heavy Cannon

**Cons:**
- Very high energy cost
- Heavy weight
- Strength requirement
- High AP cost

**Best Used For:**
- Anti-armor role
- Heavy weapons specialist
- Long-range support
- Overload for tough enemies

---

### Laser Sniper

**Basic Stats:**
- Damage: 68
- Range: 45 tiles
- Accuracy: 85%
- AP Cost: 4
- Ammo: Infinite
- Weight: 5 kg

**Tactical Analysis:**
Ultimate precision weapon with infinite range capability.

```lua
Weapon_LaserSniper = {
    name = "Laser Sniper",
    type = "sniper",
    tech = "laser",
    damage = {min = 62, max = 74, avg = 68},
    range = 45,
    accuracy = 0.85,
    apCost = 4,
    ammo = math.huge,
    weight = 5,
    damageType = "laser",
    armorPiercing = 25,
    energyCost = 12,
    critChance = 0.30,
    critMultiplier = 2.0,
    scopeBonus = 0.20,
    twoHanded = true
}

function Weapon_LaserSniper:calculateHit(shooter, target)
    local baseAccuracy = self.accuracy
    
    -- Scope bonus if stationary
    if not shooter:hasMovedThisTurn() then
        baseAccuracy = baseAccuracy + self.scopeBonus
    end
    
    -- Laser precision: no range penalty
    -- +2% accuracy per 5 tiles beyond 15
    local distance = shooter:getDistance(target)
    if distance > 15 then
        local precisionBonus = math.floor((distance - 15) / 5) * 0.02
        baseAccuracy = math.min(0.99, baseAccuracy + precisionBonus)
    end
    
    return baseAccuracy * (shooter.stats.accuracy / 100)
end
```

**Pros:**
- Highest accuracy in game
- Excellent range
- No ammo concerns
- Strong armor penetration
- High critical chance
- Lighter than conventional sniper

**Cons:**
- High energy cost per shot
- High AP cost
- Limited shots per turn due to energy

**Best Used For:**
- Elite sniper role
- High-value elimination
- Long-range overwatch
- Precision strikes

---

## Plasma Weapons

### Plasma Pistol

**Basic Stats:**
- Damage: 34
- Range: 18 tiles
- Accuracy: 75%
- AP Cost: 2
- Ammo: 26 shots
- Reload: 1 AP
- Weight: 2 kg

**Tactical Analysis:**
Alien sidearm superior to human pistols.

```lua
Weapon_PlasmaPistol = {
    name = "Plasma Pistol",
    type = "pistol",
    tech = "plasma",
    damage = {min = 28, max = 40, avg = 34},
    range = 18,
    accuracy = 0.75,
    apCost = 2,
    ammo = 26,
    reloadAP = 1,
    weight = 2,
    damageType = "plasma",
    armorPiercing = 15,
    twoHanded = false,
    plasmaEffect = true
}

function Weapon_PlasmaPistol:fire(target)
    local damage = math.random(self.damage.min, self.damage.max)
    
    -- Plasma damage has chance to bypass armor
    if math.random() < 0.3 then -- 30% chance
        target:takeDamage(damage, "plasma", {ignoreArmor = 0.5}) -- Ignore 50% armor
    else
        target:takeDamage(damage, "plasma")
    end
    
    -- Small chance to set target on fire
    if math.random() < 0.15 then
        target:applyStatus("burning", 3)
    end
end
```

**Pros:**
- High damage for a pistol
- Good accuracy
- Excellent armor penetration
- Light weight
- One-handed
- Plasma effects (fire, armor bypass)

**Cons:**
- Limited ammo
- Requires alien power source

**Best Used For:**
- Backup weapon for all soldiers
- Officer sidearm
- Close quarters
- Emergency situations

---

### Plasma Rifle

**Basic Stats:**
- Damage: 52
- Range: 28 tiles
- Accuracy: 80%
- AP Cost: 3
- Ammo: 28 shots
- Reload: 1 AP
- Weight: 4 kg

**Tactical Analysis:**
Best all-around weapon in the game.

```lua
Weapon_PlasmaRifle = {
    name = "Plasma Rifle",
    type = "rifle",
    tech = "plasma",
    damage = {min = 45, max = 59, avg = 52},
    range = 28,
    accuracy = 0.8,
    apCost = 3,
    ammo = 28,
    reloadAP = 1,
    weight = 4,
    damageType = "plasma",
    armorPiercing = 22,
    snapShot = {apCost = 2, accuracyMod = -0.05},
    aimedShot = {apCost = 4, accuracyMod = 0.30},
    autoShot = {apCost = 5, shots = 3, accuracyMod = -0.15},
    twoHanded = true,
    plasmaEffect = true
}

function Weapon_PlasmaRifle:fire(target, mode)
    local fireMode = self[mode or "snapShot"]
    
    if mode == "autoShot" then
        return self:autoBurst(target)
    end
    
    local accuracy = self.accuracy + (fireMode.accuracyMod or 0)
    local hitChance = accuracy * (self.owner.stats.accuracy / 100)
    
    if math.random() < hitChance then
        local damage = math.random(self.damage.min, self.damage.max)
        
        -- Armor bypass chance
        if math.random() < 0.35 then
            target:takeDamage(damage, "plasma", {ignoreArmor = 0.5})
        else
            target:takeDamage(damage, "plasma")
        end
        
        -- Burning chance
        if math.random() < 0.20 then
            target:applyStatus("burning", 3)
        end
        
        return true
    end
    
    return false
end
```

**Fire Modes:**
- **Snap Shot:** 2 AP, -5% accuracy, single shot
- **Aimed Shot:** 4 AP, +30% accuracy, single shot
- **Auto Burst:** 5 AP, -15% accuracy, 3-round burst

**Pros:**
- Excellent damage
- High accuracy
- Superior armor penetration
- Versatile fire modes
- Good ammo capacity
- Plasma effects

**Cons:**
- Requires alien resources
- Slight weight

**Best Used For:**
- Primary weapon late game
- All combat situations
- Armor piercing
- Versatile engagements

---

### Heavy Plasma

**Basic Stats:**
- Damage: 85
- Range: 32 tiles
- Accuracy: 70%
- AP Cost: 4
- Ammo: 35 shots
- Reload: 2 AP
- Weight: 8 kg

**Tactical Analysis:**
Devastating firepower with excellent ammunition capacity.

```lua
Weapon_HeavyPlasma = {
    name = "Heavy Plasma",
    type = "heavy",
    tech = "plasma",
    damage = {min = 75, max = 95, avg = 85},
    range = 32,
    accuracy = 0.7,
    apCost = 4,
    ammo = 35,
    reloadAP = 2,
    weight = 8,
    damageType = "plasma",
    armorPiercing = 30,
    minStrength = 35,
    twoHanded = true,
    plasmaEffect = true
}

function Weapon_HeavyPlasma:fire(target)
    local damage = math.random(self.damage.min, self.damage.max)
    
    -- High armor bypass chance (50%)
    if math.random() < 0.5 then
        target:takeDamage(damage, "plasma", {ignoreArmor = 0.6}) -- Ignore 60% armor
    else
        target:takeDamage(damage, "plasma")
    end
    
    -- High burning chance
    if math.random() < 0.30 then
        target:applyStatus("burning", 4)
    end
    
    -- Splash damage to adjacent tiles
    for _, adjacent in ipairs(target:getAdjacentTiles()) do
        for _, unit in ipairs(adjacent:getUnits()) do
            if unit ~= target then
                unit:takeDamage(damage * 0.3, "plasma") -- 30% splash
            end
        end
    end
    
    return true
end
```

**Pros:**
- Highest direct damage weapon
- Excellent armor penetration
- Good accuracy for heavy weapon
- Large ammo capacity
- Splash damage
- Strong plasma effects

**Cons:**
- Heavy (but lighter than conventional)
- High AP cost
- Strength requirement

**Best Used For:**
- Heavy weapons specialist
- Anti-heavy armor
- Area damage
- Toughest enemies

---

## Special Weapons

### Grenade

**Basic Stats:**
- Damage: 60
- Range: 15 tiles (throw)
- Accuracy: N/A (area)
- AP Cost: 2 (throw)
- Ammo: Single use
- Weight: 1 kg
- Blast Radius: 3 tiles

**Tactical Analysis:**
Standard explosive for area denial and cover destruction.

```lua
Weapon_Grenade = {
    name = "Grenade",
    type = "explosive",
    tech = "conventional",
    damage = {min = 50, max = 70, avg = 60},
    range = 15,
    apCost = 2,
    weight = 1,
    damageType = "explosive",
    blastRadius = 3,
    throwRange = function(strength)
        return math.floor(strength / 5) + 5 -- 5 base + str/5
    end
}

function Weapon_Grenade:throw(thrower, target)
    local maxRange = self.throwRange(thrower.stats.strength)
    local distance = thrower:getDistance(target)
    
    if distance > maxRange then
        return false, "Out of range"
    end
    
    thrower:useAP(self.apCost)
    
    -- Grenade explodes at target location
    self:explode(target)
end

function Weapon_Grenade:explode(center)
    local affected = self:getTilesInRadius(center, self.blastRadius)
    
    for _, tile in ipairs(affected) do
        local distance = self:getDistance(tile, center)
        local damageMultiplier = 1 - (distance / self.blastRadius) * 0.5 -- 50-100%
        local damage = math.random(self.damage.min, self.damage.max) * damageMultiplier
        
        -- Damage units
        for _, unit in ipairs(tile:getUnits()) do
            unit:takeDamage(damage, self.damageType)
        end
        
        -- Destroy cover
        if tile:hasCover() then
            tile:reduceCover(damage)
        end
    end
end
```

**Pros:**
- Area damage
- Destroys cover
- Bypasses armor partially
- Light weight
- Low AP cost
- Can't miss

**Cons:**
- Single use
- Friendly fire risk
- Limited range
- Can't be retrieved

**Best Used For:**
- Clearing entrenched enemies
- Destroying cover
- Area denial
- Softening clusters

---

### Alien Grenade

**Basic Stats:**
- Damage: 90
- Range: 20 tiles
- Accuracy: N/A
- AP Cost: 2
- Ammo: Single use
- Weight: 1 kg
- Blast Radius: 4 tiles

**Tactical Analysis:**
Superior explosive with larger radius and damage.

```lua
Weapon_AlienGrenade = {
    name = "Alien Grenade",
    type = "explosive",
    tech = "plasma",
    damage = {min = 80, max = 100, avg = 90},
    range = 20,
    apCost = 2,
    weight = 1,
    damageType = "explosive",
    blastRadius = 4,
    plasmaFire = true, -- Creates lasting fire
    throwRange = function(strength)
        return math.floor(strength / 4) + 8 -- Better than conventional
    end
}

function Weapon_AlienGrenade:explode(center)
    -- Standard explosion
    Weapon_Grenade.explode(self, center)
    
    -- Additional plasma fire effect
    local fireTiles = self:getTilesInRadius(center, self.blastRadius - 1)
    
    for _, tile in ipairs(fireTiles) do
        if math.random() < 0.6 then -- 60% chance per tile
            tile:setOnFire(5) -- Burns for 5 turns
        end
    end
end
```

**Pros:**
- High damage
- Large blast radius
- Creates fire hazards
- Better throw range
- Light weight

**Cons:**
- Single use
- Rare and expensive
- Friendly fire risk

**Best Used For:**
- Clearing tough enemies
- Area denial with fire
- Last resort situations
- Destroying heavy cover

---

### Rocket Launcher

**Basic Stats:**
- Damage: 100
- Range: 30 tiles
- Accuracy: 75%
- AP Cost: 4
- Ammo: 1 rocket
- Reload: 3 AP
- Weight: 15 kg
- Blast Radius: 5 tiles

**Tactical Analysis:**
Maximum conventional firepower for vehicle/building destruction.

```lua
Weapon_RocketLauncher = {
    name = "Rocket Launcher",
    type = "launcher",
    tech = "conventional",
    damage = {min = 90, max = 110, avg = 100},
    range = 30,
    accuracy = 0.75,
    apCost = 4,
    ammo = 1,
    reloadAP = 3,
    weight = 15,
    damageType = "explosive",
    blastRadius = 5,
    minStrength = 50,
    guidedRocket = false,
    twoHanded = true
}

function Weapon_RocketLauncher:fire(target)
    local shooter = self.owner
    shooter:useAP(self.apCost)
    
    -- Accuracy check
    local hitChance = self.accuracy * (shooter.stats.accuracy / 100)
    
    -- Rockets can miss and hit nearby tiles
    local impactTile = target
    if math.random() > hitChance then
        local deviation = math.random(1, 3)
        impactTile = self:getRandomAdjacentTile(target, deviation)
    end
    
    -- Massive explosion
    self:explode(impactTile)
end

function Weapon_RocketLauncher:explode(center)
    local affected = self:getTilesInRadius(center, self.blastRadius)
    
    for _, tile in ipairs(affected) do
        local distance = self:getDistance(tile, center)
        local damageMultiplier = 1 - (distance / self.blastRadius) * 0.4 -- 60-100%
        local damage = math.random(self.damage.min, self.damage.max) * damageMultiplier
        
        -- Massive damage to units
        for _, unit in ipairs(tile:getUnits()) do
            unit:takeDamage(damage, self.damageType)
        end
        
        -- Destroy cover completely
        if tile:hasCover() then
            tile:destroyCover()
        end
        
        -- Damage walls and structures
        if tile:hasStructure() then
            tile:damageStructure(damage)
        end
    end
end
```

**Pros:**
- Extreme damage
- Huge blast radius
- Destroys anything
- Long range
- Guided trajectory

**Cons:**
- Extremely heavy
- Very long reload
- Single shot capacity
- High strength requirement
- Friendly fire catastrophic
- Expensive ammo

**Best Used For:**
- Building demolition
- Vehicle destruction
- Mass enemy clusters
- Base defense
- Desperate situations

---

### Blaster Launcher

**Basic Stats:**
- Damage: 120
- Range: 50 tiles
- Accuracy: 90%
- AP Cost: 4
- Ammo: 1 bomb
- Reload: 3 AP
- Weight: 10 kg
- Blast Radius: 6 tiles

**Tactical Analysis:**
Ultimate weapon with guided waypoint navigation.

```lua
Weapon_BlasterLauncher = {
    name = "Blaster Launcher",
    type = "launcher",
    tech = "plasma",
    damage = {min = 110, max = 130, avg = 120},
    range = 50,
    accuracy = 0.9,
    apCost = 4,
    ammo = 1,
    reloadAP = 3,
    weight = 10,
    damageType = "plasma_explosive",
    blastRadius = 6,
    minStrength = 40,
    guidedBomb = true,
    maxWaypoints = 8,
    twoHanded = true
}

function Weapon_BlasterLauncher:setWaypoints(waypoints)
    if #waypoints > self.maxWaypoints then
        return false, "Too many waypoints"
    end
    
    self.waypoints = waypoints
    return true
end

function Weapon_BlasterLauncher:fire(waypoints)
    local shooter = self.owner
    shooter:useAP(self.apCost)
    
    -- Blaster bomb follows waypoint path
    local currentPos = shooter.position
    
    for _, waypoint in ipairs(waypoints) do
        -- Animated flight path
        self:animateBomb(currentPos, waypoint)
        currentPos = waypoint
        
        -- Can hit units along the way
        if currentPos:hasUnits() then
            self:explode(currentPos)
            return
        end
    end
    
    -- Explode at final waypoint
    self:explode(currentPos)
end

function Weapon_BlasterLauncher:explode(center)
    local affected = self:getTilesInRadius(center, self.blastRadius)
    
    for _, tile in ipairs(affected) do
        local distance = self:getDistance(tile, center)
        local damageMultiplier = 1 - (distance / self.blastRadius) * 0.3 -- 70-100%
        local damage = math.random(self.damage.min, self.damage.max) * damageMultiplier
        
        -- Massive plasma damage
        for _, unit in ipairs(tile:getUnits()) do
            unit:takeDamage(damage, self.damageType, {ignoreArmor = 0.5})
        end
        
        -- Destroy everything
        tile:destroyCover()
        tile:destroyStructure()
        
        -- Create lasting plasma fire
        if math.random() < 0.8 then
            tile:setOnFire(8)
        end
    end
end
```

**Pros:**
- Highest damage in game
- Guided waypoint system
- Massive blast radius
- Can shoot around corners
- Plasma effects
- Lighter than rocket launcher

**Cons:**
- Rare alien weapon
- Expensive ammo
- Long reload
- Friendly fire risk
- Overkill for most situations

**Best Used For:**
- Impossible situations
- Alien base assaults
- Final mission
- Heavily fortified positions
- When all else fails

---

### Stun Rod

**Basic Stats:**
- Damage: 0 (80 stun)
- Range: 1 tile (melee)
- Accuracy: 70%
- AP Cost: 2
- Ammo: Infinite
- Weight: 2 kg

**Tactical Analysis:**
Non-lethal capture weapon for live specimens.

```lua
Weapon_StunRod = {
    name = "Stun Rod",
    type = "melee",
    tech = "conventional",
    stunDamage = {min = 70, max = 90, avg = 80},
    range = 1,
    accuracy = 0.7,
    apCost = 2,
    ammo = math.huge,
    weight = 2,
    damageType = "stun",
    twoHanded = false
}

function Weapon_StunRod:attack(target)
    local shooter = self.owner
    
    if not shooter:isAdjacent(target) then
        return false, "Target must be adjacent"
    end
    
    shooter:useAP(self.apCost)
    
    local hitChance = self.accuracy * (shooter.stats.melee / 100)
    
    if math.random() < hitChance then
        local stunDamage = math.random(self.stunDamage.min, self.stunDamage.max)
        
        -- Apply stun damage
        target:takeStunDamage(stunDamage)
        
        -- Check if knocked unconscious
        if target.stunDamage >= target.stats.hp then
            target:knockout()
        end
        
        return true
    end
    
    return false
end
```

**Pros:**
- Captures live aliens
- Infinite uses
- Light weight
- Low AP cost
- One-handed

**Cons:**
- Melee only
- High risk
- Ineffective vs heavy armor
- Target must be weakened first

**Best Used For:**
- Capturing aliens for interrogation
- Live specimen research
- Non-lethal takedowns
- Close combat specialists

---

### Small Launcher

**Basic Stats:**
- Damage: Varies (grenade type)
- Range: 25 tiles
- Accuracy: 70%
- AP Cost: 3
- Ammo: 1 round
- Reload: 2 AP
- Weight: 8 kg

**Tactical Analysis:**
Grenade launcher for precise explosive placement.

```lua
Weapon_SmallLauncher = {
    name = "Small Launcher",
    type = "launcher",
    tech = "conventional",
    range = 25,
    accuracy = 0.7,
    apCost = 3,
    ammo = 1,
    reloadAP = 2,
    weight = 8,
    damageType = "explosive",
    twoHanded = true,
    ammoTypes = {
        he = {damage = 60, radius = 3},
        incendiary = {damage = 40, radius = 2, fire = 5},
        smoke = {damage = 0, radius = 4, smoke = 10},
        stun = {stunDamage = 80, radius = 3}
    }
}

function Weapon_SmallLauncher:fire(target, ammoType)
    local shooter = self.owner
    local ammo = self.ammoTypes[ammoType]
    
    if not ammo then
        return false, "Invalid ammo type"
    end
    
    shooter:useAP(self.apCost)
    
    -- Accuracy check
    local hitChance = self.accuracy * (shooter.stats.accuracy / 100)
    local impactTile = target
    
    if math.random() > hitChance then
        local deviation = math.random(1, 2)
        impactTile = self:getRandomAdjacentTile(target, deviation)
    end
    
    -- Deploy effect based on ammo type
    if ammoType == "he" then
        self:explode(impactTile, ammo.damage, ammo.radius)
    elseif ammoType == "incendiary" then
        self:createFire(impactTile, ammo.radius, ammo.fire)
    elseif ammoType == "smoke" then
        self:createSmoke(impactTile, ammo.radius, ammo.smoke)
    elseif ammoType == "stun" then
        self:stunBlast(impactTile, ammo.stunDamage, ammo.radius)
    end
end
```

**Ammo Types:**
- **HE:** 60 damage, 3-tile radius
- **Incendiary:** 40 damage, creates fire
- **Smoke:** Creates smoke screen
- **Stun:** 80 stun damage for captures

**Pros:**
- Precise grenade delivery
- Multiple ammo types
- Good range
- Safer than hand grenades
- Versatile utility

**Cons:**
- Moderate weight
- Single shot capacity
- Reload required
- AP cost higher than throw

**Best Used For:**
- Long-range explosive delivery
- Smoke screens
- Fire support
- Area denial
- Stun captures

---

## Weapon Technology Progression

### Early Game (Months 1-3)
**Primary:** Rifle, Auto-Cannon  
**Secondary:** Pistol  
**Special:** Grenades, Rocket Launcher  
**Focus:** Conventional weapons, learning combat

### Mid Game (Months 4-6)
**Primary:** Laser Rifle, Heavy Laser  
**Secondary:** Laser Pistol  
**Special:** Alien Grenades (captured)  
**Focus:** Laser tech, no ammo concerns

### Late Game (Months 7-10)
**Primary:** Plasma Rifle, Heavy Plasma  
**Secondary:** Plasma Pistol  
**Special:** Blaster Launcher  
**Focus:** Maximum firepower, armor penetration

### End Game (Months 11+)
**Primary:** Plasma Rifle (upgraded)  
**Secondary:** Plasma Pistol  
**Special:** Blaster Launcher, Alien Grenades  
**Focus:** Optimal loadouts, perfect execution

---

## Weapon Selection Guide

### By Role

#### **Assault (Frontline)**
- Primary: Shotgun → Laser Rifle → Plasma Rifle
- Secondary: Pistol → Laser Pistol → Plasma Pistol
- Special: Grenades

#### **Heavy Weapons**
- Primary: Heavy Cannon → Heavy Laser → Heavy Plasma
- Secondary: Pistol → Laser Pistol
- Special: Rocket Launcher

#### **Sniper**
- Primary: Sniper Rifle → Laser Sniper → Plasma Rifle (aimed)
- Secondary: Pistol → Plasma Pistol
- Special: None (stay back)

#### **Scout/Infiltrator**
- Primary: Rifle → Laser Rifle → Plasma Rifle
- Secondary: Pistol → Laser Pistol → Plasma Pistol
- Special: Smoke Grenades

#### **Support/Grenadier**
- Primary: Rifle → Laser Rifle
- Secondary: Pistol
- Special: Small Launcher, Grenades

#### **Capture Specialist**
- Primary: Stun Rod
- Secondary: Pistol → Laser Pistol
- Special: Smoke Grenades, Stun Launcher

---

## Cross-References

**Related Documents:**
- [Alien Species](../lore/Alien_Species.md) - Enemy armor values
- [Armor System](../units/Armor.md) - Damage reduction mechanics
- [Combat System](../battlescape/Combat.md) - Hit chance calculations
- [Research Tree](../economy/Research.md) - Weapon unlock progression
- [Item Crafting](../economy/Item_Crafting.md) - Production costs

**See Also:**
- [Unit Stats](../units/Stats.md) - Accuracy and strength effects
- [Action Economy](../core/Action_Economy.md) - AP costs explained
- [Status Effects](../battlescape/Status_Effects.md) - Burning, stun mechanics

---

## Implementation Notes

### Love2D Weapon System
```lua
WeaponSystem = Class('WeaponSystem')

function WeaponSystem:loadWeapon(weaponId)
    local weaponData = require('data.weapons.' .. weaponId)
    local weapon = Weapon:new(weaponData)
    return weapon
end

function WeaponSystem:calculateDamage(weapon, target, distance)
    local baseDamage = math.random(weapon.damage.min, weapon.damage.max)
    local rangeMod = self:getRangeModifier(weapon, distance)
    local armorMod = target:getArmorReduction(weapon.damageType, weapon.armorPiercing)
    
    local finalDamage = baseDamage * rangeMod * (1 - armorMod)
    return math.max(1, math.floor(finalDamage))
end
```

### Data File Structure
```toml
# data/weapons/plasma_rifle.toml
[weapon]
id = "plasma_rifle"
name = "Plasma Rifle"
type = "rifle"
tech = "plasma"

[stats]
damage_min = 45
damage_max = 59
range = 28
accuracy = 0.8
ap_cost = 3
ammo = 28
reload_ap = 1
weight = 4
armor_piercing = 22

[fire_modes.snap]
ap_cost = 2
accuracy_mod = -0.05

[fire_modes.aimed]
ap_cost = 4
accuracy_mod = 0.30

[fire_modes.auto]
ap_cost = 5
shots = 3
accuracy_mod = -0.15
```

---

**Document Status:** Complete  
**Implementation Status:** Not started  
**Last Review:** September 30, 2025  
**Version:** 1.0
