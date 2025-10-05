# Air Weapons

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Air Weapons system defines missile systems, cannons, and beam weapons mountable on interceptor craft for aerial combat in Alien Fall, with distinct characteristics for range, damage, accuracy, ammunition capacity, and reload time that create loadout optimization decisions and tactical tradeoffs between burst damage, sustained fire, and engagement range across technology tiers.

---

## Table of Contents
- [Overview](#overview)
- [Weapon Categories](#weapon-categories)
- [Weapon Stats Tables](#weapon-stats-tables)
- [Range and Accuracy](#range-and-accuracy)
- [Ammo and Energy Systems](#ammo-and-energy-systems)
- [Reload and Cooldown](#reload-and-cooldown)
- [Weapon Comparison](#weapon-comparison)
- [Tactical Analysis](#tactical-analysis)
- [Lua Implementation](#lua-implementation)
- [Integration Points](#integration-points)
- [Cross-References](#cross-references)

---

## Overview

Air Weapons are offensive systems mounted on interceptor craft for air-to-air combat against UFOs. Weapons are classified by technology level (Conventional, Laser, Plasma, Fusion), damage type, range effectiveness, and resource management (ammunition or energy).

**Core Principles:**
- **Technology Progression:** Conventional → Laser → Plasma → Fusion
- **Range Bands:** Near/Medium/Long/Extreme with accuracy falloff
- **Resource Management:** Ammunition-based or energy-based weapons
- **Hardpoint Limitations:** Craft can mount multiple weapons but fire limits apply
- **Tactical Roles:** Different weapons excel at different ranges and situations

---

## Weapon Categories

### Conventional Weapons (Starting Tech)
- **Stinger Missiles:** Short-range high-damage missiles
- **Sidewinder Missiles:** Medium-range balanced missiles
- **Phoenix Missiles:** Long-range heavy missiles
- **Cannon:** Close-range rapid-fire ballistic

### Laser Weapons (Early Research)
- **Laser Cannon:** Energy-based precision weapon
- **Dual Laser:** Enhanced laser system with higher damage
- **Heavy Laser:** Long-range high-power laser

### Plasma Weapons (Mid-Game Research)
- **Plasma Beam:** High-damage energy weapon
- **Fusion Ball:** Area-effect plasma projectile
- **Heavy Plasma Cannon:** Maximum damage plasma system

### Exotic Weapons (Late-Game Research)
- **EMP Cannon:** Disables UFO systems temporarily
- **Fusion Lance:** Armor-piercing beam weapon
- **Blaster Launcher:** Guided missile system

---

## Weapon Stats Tables

### Conventional Weapons

| Weapon | Damage | Range (km) | Accuracy | Ammo Capacity | Reload Time | AP Cost | Hardpoint Size |
|--------|--------|------------|----------|---------------|-------------|---------|----------------|
| **Stinger** | 80 | 30 | 85% | 4 | 2 rounds | 1 | 1 |
| **Sidewinder** | 120 | 60 | 75% | 6 | 2 rounds | 2 | 1 |
| **Phoenix** | 200 | 120 | 60% | 3 | 3 rounds | 2 | 2 |
| **Cannon** | 40 | 15 | 90% | 200 | - | 1 | 1 |

### Laser Weapons

| Weapon | Damage | Range (km) | Accuracy | Energy Cost | Regen Rate | AP Cost | Hardpoint Size |
|--------|--------|------------|----------|-------------|------------|---------|----------------|
| **Laser Cannon** | 100 | 50 | 80% | 20 | 10/round | 1 | 1 |
| **Dual Laser** | 150 | 70 | 75% | 30 | 10/round | 2 | 2 |
| **Heavy Laser** | 220 | 100 | 70% | 50 | 15/round | 2 | 2 |

### Plasma Weapons

| Weapon | Damage | Range (km) | Accuracy | Energy Cost | Regen Rate | AP Cost | Hardpoint Size |
|--------|--------|------------|----------|-------------|------------|---------|----------------|
| **Plasma Beam** | 180 | 80 | 85% | 35 | 15/round | 2 | 2 |
| **Fusion Ball** | 250 | 60 | 70% | 50 | 20/round | 2 | 2 |
| **Heavy Plasma** | 320 | 100 | 80% | 60 | 20/round | 3 | 3 |

### Exotic Weapons

| Weapon | Damage | Range (km) | Accuracy | Energy/Ammo | Special | AP Cost | Hardpoint Size |
|--------|--------|------------|----------|-------------|---------|---------|----------------|
| **EMP Cannon** | 50 | 40 | 85% | 40 energy | Disables systems | 2 | 2 |
| **Fusion Lance** | 400 | 120 | 90% | 80 energy | +100 penetration | 3 | 3 |
| **Blaster** | 300 | 150 | 95% | 2 ammo | Guided missile | 3 | 3 |

---

## Range and Accuracy

### Range Band System

```lua
-- Range bands for accuracy calculation
RangeBands = {
    POINT_BLANK = {min = 0, max = 10, name = "Point Blank"},
    NEAR = {min = 10, max = 40, name = "Near"},
    MEDIUM = {min = 40, max = 80, name = "Medium"},
    LONG = {min = 80, max = 150, name = "Long"},
    EXTREME = {min = 150, max = 300, name = "Extreme"},
}

function get_range_band(distance_km)
    for _, band in pairs(RangeBands) do
        if distance_km >= band.min and distance_km < band.max then
            return band
        end
    end
    return RangeBands.EXTREME
end
```

### Accuracy by Range

```lua
-- Calculate accuracy modifier based on range
function calculate_range_accuracy(weapon, distance_km)
    local optimal_range = weapon.range
    local base_accuracy = weapon.accuracy
    
    -- Accuracy falloff calculation
    if distance_km <= optimal_range * 0.5 then
        -- Within optimal range: full accuracy
        return base_accuracy
    elseif distance_km <= optimal_range then
        -- Within max range: linear falloff
        local range_ratio = (distance_km - optimal_range * 0.5) / (optimal_range * 0.5)
        return base_accuracy * (1.0 - range_ratio * 0.3)  -- Up to -30% at max range
    else
        -- Beyond max range: severe penalty
        local overshoot = (distance_km - optimal_range) / optimal_range
        local penalty = 0.3 + overshoot * 0.5
        return math.max(0.1, base_accuracy * (1.0 - penalty))
    end
end
```

### Range Band Accuracy Tables

**Stinger Missile (30km optimal, 85% base accuracy):**
- 0-15km (Point Blank/Near): 85% accuracy
- 15-30km (Medium): 85% → 60% accuracy
- 30-60km (Long): 60% → 20% accuracy
- 60km+ (Extreme): 10% accuracy

**Heavy Plasma (100km optimal, 80% base accuracy):**
- 0-50km (Near/Medium): 80% accuracy
- 50-100km (Long): 80% → 56% accuracy
- 100-200km (Extreme): 56% → 20% accuracy
- 200km+ (Beyond): 10% accuracy

---

## Ammo and Energy Systems

### Ammunition-Based Weapons

```lua
-- Ammunition system for conventional weapons
AmmunitionWeapon = {
    name = "Sidewinder Missile",
    ammo_current = 6,
    ammo_max = 6,
    ammo_per_shot = 1,
    reload_time = 2,  -- Rounds to reload
    reloading = false,
    reload_counter = 0,
}

function AmmunitionWeapon:can_fire()
    return self.ammo_current >= self.ammo_per_shot and not self.reloading
end

function AmmunitionWeapon:fire()
    if not self:can_fire() then
        return false
    end
    
    self.ammo_current = self.ammo_current - self.ammo_per_shot
    
    -- Auto-reload when empty
    if self.ammo_current == 0 then
        self:start_reload()
    end
    
    return true
end

function AmmunitionWeapon:start_reload()
    self.reloading = true
    self.reload_counter = self.reload_time
end

function AmmunitionWeapon:update_reload()
    if not self.reloading then
        return
    end
    
    self.reload_counter = self.reload_counter - 1
    
    if self.reload_counter <= 0 then
        self.ammo_current = self.ammo_max
        self.reloading = false
    end
end
```

### Energy-Based Weapons

```lua
-- Energy system for laser/plasma weapons
EnergyWeapon = {
    name = "Plasma Beam",
    energy_cost = 35,
    energy_regen = 15,  -- Per round
    cooldown_current = 0,
    cooldown_max = 0,   -- Some weapons have cooldown after firing
}

function EnergyWeapon:can_fire(craft_energy)
    return craft_energy >= self.energy_cost and self.cooldown_current == 0
end

function EnergyWeapon:fire(craft)
    if not self:can_fire(craft.energy) then
        return false
    end
    
    -- Deduct energy from craft
    craft.energy = craft.energy - self.energy_cost
    
    -- Start cooldown if weapon has one
    if self.cooldown_max > 0 then
        self.cooldown_current = self.cooldown_max
    end
    
    return true
end

function EnergyWeapon:update_turn()
    -- Reduce cooldown
    if self.cooldown_current > 0 then
        self.cooldown_current = self.cooldown_current - 1
    end
end

function EnergyWeapon:regenerate_energy(craft)
    -- Regenerate craft energy
    craft.energy = math.min(craft.energy_max, craft.energy + self.energy_regen)
end
```

### Hybrid Systems

```lua
-- Some weapons use both energy and ammo (e.g., Blaster Launcher)
HybridWeapon = {
    name = "Blaster Launcher",
    ammo_current = 2,
    ammo_max = 2,
    energy_cost = 40,
    reload_time = 4,
}

function HybridWeapon:can_fire(craft_energy)
    return self.ammo_current > 0 and 
           craft_energy >= self.energy_cost and 
           not self.reloading
end

function HybridWeapon:fire(craft)
    if not self:can_fire(craft.energy) then
        return false
    end
    
    -- Consume both ammo and energy
    self.ammo_current = self.ammo_current - 1
    craft.energy = craft.energy - self.energy_cost
    
    if self.ammo_current == 0 then
        self:start_reload()
    end
    
    return true
end
```

---

## Reload and Cooldown

### Reload Mechanics

```lua
-- Reload system timing
ReloadSystem = {
    -- Reload times in combat rounds (30 seconds each)
    reload_times = {
        stinger = 2,      -- 1 minute reload
        sidewinder = 2,   -- 1 minute reload
        phoenix = 3,      -- 1.5 minutes reload
        cannon = 0,       -- No reload (belt-fed)
        blaster = 4,      -- 2 minutes reload
    }
}

function calculate_reload_time(weapon, crew_skill)
    local base_time = weapon.reload_time
    
    -- Crew skill reduces reload time
    local skill_bonus = (crew_skill - 50) / 100  -- ±50% at skill 0/100
    local modified_time = base_time * (1.0 - skill_bonus * 0.3)  -- Up to 30% reduction
    
    return math.max(1, math.floor(modified_time))
end

function start_weapon_reload(weapon, craft)
    weapon.reloading = true
    weapon.reload_counter = calculate_reload_time(weapon, craft.crew_skill)
    
    -- Visual feedback
    show_reload_indicator(weapon)
end
```

### Cooldown System

```lua
-- Some high-power weapons have cooldown after firing
WeaponCooldowns = {
    heavy_plasma = 1,     -- 1 round cooldown
    fusion_lance = 2,     -- 2 rounds cooldown
    blaster = 2,          -- 2 rounds cooldown
    emp_cannon = 3,       -- 3 rounds cooldown (powerful effect)
}

function apply_weapon_cooldown(weapon)
    if weapon.cooldown_max and weapon.cooldown_max > 0 then
        weapon.cooldown_current = weapon.cooldown_max
        weapon.can_fire = false
    end
end

function update_weapon_cooldown(weapon)
    if weapon.cooldown_current > 0 then
        weapon.cooldown_current = weapon.cooldown_current - 1
        
        if weapon.cooldown_current == 0 then
            weapon.can_fire = true
        end
    end
end
```

### Emergency Reload

```lua
-- Crew can perform emergency reload (faster but risky)
function emergency_reload(weapon, craft)
    if not weapon.reloading then
        return false
    end
    
    -- Reduce reload time by 1 round
    weapon.reload_counter = math.max(0, weapon.reload_counter - 1)
    
    -- Risk of jam (10% chance)
    local jam_chance = 0.1
    if math.random() < jam_chance then
        weapon.jammed = true
        weapon.reload_counter = weapon.reload_counter + 2  -- Penalty
        return false
    end
    
    return true
end
```

---

## Weapon Comparison

### Damage per AP Cost

| Weapon | Damage | AP Cost | Damage/AP | Energy/Ammo Efficiency |
|--------|--------|---------|-----------|------------------------|
| **Cannon** | 40 | 1 | 40.0 | Excellent (200 shots) |
| **Stinger** | 80 | 1 | 80.0 | Good (4 shots) |
| **Laser Cannon** | 100 | 1 | 100.0 | Good (5 shots/energy) |
| **Sidewinder** | 120 | 2 | 60.0 | Medium (6 shots) |
| **Dual Laser** | 150 | 2 | 75.0 | Medium (3 shots/energy) |
| **Plasma Beam** | 180 | 2 | 90.0 | Good (3 shots/energy) |
| **Phoenix** | 200 | 2 | 100.0 | Low (3 shots) |
| **Heavy Laser** | 220 | 2 | 110.0 | Medium (2 shots/energy) |
| **Fusion Ball** | 250 | 2 | 125.0 | Low (2 shots/energy) |
| **Heavy Plasma** | 320 | 3 | 106.7 | Medium (2 shots/energy) |
| **Fusion Lance** | 400 | 3 | 133.3 | Low (1 shot/energy) |

### Range Effectiveness

| Weapon | Optimal Range | Max Effective | Beyond Range | Best Use |
|--------|---------------|---------------|--------------|----------|
| **Cannon** | 15km | 20km | Poor | Dogfighting |
| **Stinger** | 30km | 40km | Poor | Close combat |
| **Sidewinder** | 60km | 80km | Medium | Versatile |
| **Laser Cannon** | 50km | 70km | Medium | Mid-range |
| **Plasma Beam** | 80km | 100km | Good | Long-range |
| **Phoenix** | 120km | 150km | Good | Long-range |
| **Heavy Laser** | 100km | 130km | Excellent | Standoff |
| **Heavy Plasma** | 100km | 130km | Excellent | Standoff |
| **Fusion Lance** | 120km | 160km | Excellent | Ultra-long |
| **Blaster** | 150km | 200km | Excellent | Maximum range |

### Cost-Effectiveness

| Weapon | Purchase Cost | Ammo Cost (if applicable) | Damage/$ | Maintenance |
|--------|---------------|---------------------------|----------|-------------|
| **Cannon** | $50,000 | $5,000/200 rounds | 160.0 | Low |
| **Stinger** | $100,000 | $10,000/4 missiles | 3.2 | Low |
| **Sidewinder** | $150,000 | $20,000/6 missiles | 4.2 | Medium |
| **Phoenix** | $250,000 | $50,000/3 missiles | 2.0 | Medium |
| **Laser Cannon** | $200,000 | - | - | High (power) |
| **Dual Laser** | $400,000 | - | - | High (power) |
| **Heavy Laser** | $600,000 | - | - | Very High |
| **Plasma Beam** | $800,000 | - | - | Very High |
| **Fusion Ball** | $1,200,000 | - | - | Extreme |
| **Heavy Plasma** | $1,500,000 | - | - | Extreme |
| **Fusion Lance** | $2,500,000 | - | - | Extreme |
| **Blaster** | $3,000,000 | $100,000/2 missiles | 2.0 | Extreme |

---

## Tactical Analysis

### Weapon Roles

```lua
-- Weapon tactical roles and recommendations
WeaponRoles = {
    cannon = {
        role = "Close-Range Brawler",
        strengths = {"High DPS", "No ammo concerns", "Low AP cost"},
        weaknesses = {"Very short range", "Requires dogfighting"},
        best_against = {"Small UFOs", "Close encounters"},
        loadout = "Primary weapon for interceptors",
    },
    
    stinger = {
        role = "Fast Response",
        strengths = {"Quick firing", "Good accuracy", "1 AP cost"},
        weaknesses = {"Low ammo", "Short range"},
        best_against = {"Scouts", "Light fighters"},
        loadout = "Backup weapon",
    },
    
    sidewinder = {
        role = "Versatile Missile",
        strengths = {"Balanced stats", "Good range", "Reliable"},
        weaknesses = {"Moderate ammo", "2 AP cost"},
        best_against = {"Medium UFOs", "General purpose"},
        loadout = "Main armament early game",
    },
    
    phoenix = {
        role = "Long-Range Strike",
        strengths = {"High damage", "Long range", "Alpha strike"},
        weaknesses = {"Low ammo", "Slow reload", "2 hardpoints"},
        best_against = {"Battleships", "Terror ships"},
        loadout = "Heavy interceptor weapon",
    },
    
    laser_cannon = {
        role = "Energy Workhorse",
        strengths = {"No ammo", "Good accuracy", "Efficient"},
        weaknesses = {"Moderate damage", "Energy dependent"},
        best_against = {"All targets", "Extended missions"},
        loadout = "Standard mid-game weapon",
    },
    
    plasma_beam = {
        role = "High-Damage Energy",
        strengths = {"Excellent damage", "Good range", "No ammo"},
        weaknesses = {"High energy cost", "2 hardpoints"},
        best_against = {"Heavy UFOs", "Armored targets"},
        loadout = "Primary late-game weapon",
    },
    
    fusion_lance = {
        role = "Armor Penetration",
        strengths = {"Extreme damage", "Ignores armor", "Long range"},
        weaknesses = {"Very high cost", "3 hardpoints", "Slow firing"},
        best_against = {"Battleships", "Motherships"},
        loadout = "Capital ship killer",
    },
}
```

### Recommended Loadouts

```lua
-- Craft loadout recommendations by mission type
LoadoutRecommendations = {
    early_game_interceptor = {
        primary = "sidewinder",
        secondary = "stinger",
        strategy = "Close for missile shots, use stinger for cleanup",
    },
    
    mid_game_interceptor = {
        primary = "laser_cannon",
        secondary = "sidewinder",
        strategy = "Laser for sustained fire, missiles for burst damage",
    },
    
    late_game_interceptor = {
        primary = "plasma_beam",
        secondary = "heavy_laser",
        strategy = "Plasma for main damage, laser for backup",
    },
    
    heavy_interceptor = {
        primary = "fusion_lance",
        secondary = "heavy_plasma",
        strategy = "Lance for alpha strike, plasma for sustained combat",
    },
    
    scout_craft = {
        primary = "laser_cannon",
        secondary = nil,
        strategy = "Efficiency over damage, avoid combat when possible",
    },
}
```

---

## Lua Implementation

### Complete Weapon System

```lua
-- Air weapon implementation
AirWeapon = {}
AirWeapon.__index = AirWeapon

function AirWeapon:new(weapon_type)
    local weapon = setmetatable({}, AirWeapon)
    
    -- Load weapon stats
    local stats = WeaponStats[weapon_type]
    
    weapon.type = weapon_type
    weapon.name = stats.name
    weapon.damage = stats.damage
    weapon.range = stats.range
    weapon.accuracy = stats.accuracy
    weapon.ap_cost = stats.ap_cost
    weapon.hardpoint_size = stats.hardpoint_size
    
    -- Resource system
    if stats.ammo_capacity then
        weapon.resource_type = "ammo"
        weapon.ammo_current = stats.ammo_capacity
        weapon.ammo_max = stats.ammo_capacity
        weapon.reload_time = stats.reload_time
        weapon.reloading = false
        weapon.reload_counter = 0
    else
        weapon.resource_type = "energy"
        weapon.energy_cost = stats.energy_cost
        weapon.energy_regen = stats.energy_regen
    end
    
    -- Cooldown
    weapon.cooldown_max = stats.cooldown or 0
    weapon.cooldown_current = 0
    
    -- Special properties
    weapon.special = stats.special or {}
    
    return weapon
end

function AirWeapon:can_fire(craft)
    -- Check cooldown
    if self.cooldown_current > 0 then
        return false, "Weapon on cooldown"
    end
    
    -- Check reload
    if self.reloading then
        return false, "Weapon reloading"
    end
    
    -- Check resources
    if self.resource_type == "ammo" then
        if self.ammo_current <= 0 then
            return false, "Out of ammo"
        end
    elseif self.resource_type == "energy" then
        if craft.energy < self.energy_cost then
            return false, "Insufficient energy"
        end
    end
    
    return true, "Ready"
end

function AirWeapon:fire(craft, target, distance)
    local can_fire, reason = self:can_fire(craft)
    
    if not can_fire then
        return false, reason
    end
    
    -- Consume resources
    if self.resource_type == "ammo" then
        self.ammo_current = self.ammo_current - 1
        if self.ammo_current == 0 then
            self:start_reload()
        end
    elseif self.resource_type == "energy" then
        craft.energy = craft.energy - self.energy_cost
    end
    
    -- Apply cooldown
    if self.cooldown_max > 0 then
        self.cooldown_current = self.cooldown_max
    end
    
    -- Calculate hit chance
    local hit_chance = calculate_range_accuracy(self, distance)
    local hit_roll = math.random()
    
    if hit_roll <= hit_chance then
        -- Hit: apply damage
        return true, self.damage
    else
        -- Miss
        return true, 0
    end
end

function AirWeapon:update_turn()
    -- Update cooldown
    if self.cooldown_current > 0 then
        self.cooldown_current = self.cooldown_current - 1
    end
    
    -- Update reload
    if self.reloading then
        self.reload_counter = self.reload_counter - 1
        if self.reload_counter <= 0 then
            self.ammo_current = self.ammo_max
            self.reloading = false
        end
    end
    
    -- Regenerate energy (for craft)
    if self.resource_type == "energy" and self.energy_regen then
        -- Note: energy regen applied to craft, not weapon
    end
end

function AirWeapon:start_reload()
    self.reloading = true
    self.reload_counter = self.reload_time
end
```

---

## Integration Points

### Craft System Integration
```lua
-- Craft weapon hardpoints
function install_weapon(craft, weapon, hardpoint_slot)
    -- Check hardpoint availability
    if not craft.hardpoints[hardpoint_slot] then
        return false, "Invalid hardpoint slot"
    end
    
    if craft.hardpoints[hardpoint_slot].size < weapon.hardpoint_size then
        return false, "Weapon too large for hardpoint"
    end
    
    -- Install weapon
    craft.weapons[hardpoint_slot] = weapon
    craft.hardpoints[hardpoint_slot].equipped = weapon
    
    return true
end

function uninstall_weapon(craft, hardpoint_slot)
    craft.weapons[hardpoint_slot] = nil
    craft.hardpoints[hardpoint_slot].equipped = nil
end
```

### Combat System Integration
```lua
-- Weapon firing in combat
function fire_craft_weapon(craft, weapon_slot, target, distance)
    local weapon = craft.weapons[weapon_slot]
    
    if not weapon then
        return false, "No weapon in slot"
    end
    
    -- Check AP
    if craft.ap < weapon.ap_cost then
        return false, "Insufficient AP"
    end
    
    -- Fire weapon
    local success, damage = weapon:fire(craft, target, distance)
    
    if success then
        craft.ap = craft.ap - weapon.ap_cost
        
        if damage > 0 then
            apply_damage_to_ufo(target, damage)
        end
    end
    
    return success, damage
end
```

---

## Cross-References

### Related Systems
- **[Air_Battle.md](Air_Battle.md)** - Air combat mechanics
- **[Crafts.md](../crafts/Crafts.md)** - Craft systems and hardpoints
- **[Tech_Tree_Overview.md](../economy/Tech_Tree_Overview.md)** - Weapon research progression
- **[Action_Economy.md](../core/Action_Economy.md)** - AP costs for weapons
- **[Energy_Systems.md](../core/Energy_Systems.md)** - Energy weapon mechanics

### Design Documents
- **Interception Core Mechanics** - Complete air combat system
- **Mission Detection** - Interception targeting
- **Tech Tree** - Weapon unlock progression

---

**Implementation Status:** Complete specification ready for coding  
**Testing Requirements:** 
- Range accuracy calculations
- Ammo/energy management
- Reload timing
- Cooldown system
- Damage application

**Version History:**
- v1.0 (2025-09-30): Initial complete specification with stats tables and Lua code
