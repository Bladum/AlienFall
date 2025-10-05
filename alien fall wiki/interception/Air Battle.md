# Air Battle

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Air Battle system resolves aerial combat between player interceptors and alien UFOs on a 3×3 tactical grid through positioning, weapon range bands, evasion maneuvers, and damage calculation in Alien Fall, serving as the bridge between geoscape detection and ground mission deployment with outcomes determining craft damage, mission accessibility, and UFO crash site generation.

---

## Table of Contents
- [Overview](#overview)
- [Combat Flow](#combat-flow)
- [Hit Chance Formulas](#hit-chance-formulas)
- [Damage Calculation](#damage-calculation)
- [Evasion Mechanics](#evasion-mechanics)
- [Range Bands and Accuracy](#range-bands-and-accuracy)
- [Pursuit and Escape](#pursuit-and-escape)
- [Action Points Framework](#action-points-framework)
- [Energy Management](#energy-management)
- [Movement System](#movement-system)
- [UFO AI Behavior](#ufo-ai-behavior)
- [Lua Implementation](#lua-implementation)
- [Integration Points](#integration-points)
- [Cross-References](#cross-references)

---

## Overview

Air Battle handles air-to-air combat engagements between player craft and UFOs. The system combines deterministic mechanics (armor, damage) with probability-based outcomes (hit chance, evasion) to create tactical depth. Combat revolves around managing action points, energy reserves, distance control, and weapon selection.

---

## Combat Flow

### Turn Structure

```lua
-- Air combat turn sequence
function execute_air_combat_turn(combat_state)
    -- 1. Turn start: restore AP
    for _, craft in ipairs(combat_state.player_crafts) do
        craft.ap = craft.ap_max  -- Usually 4 AP
    end
    
    for _, ufo in ipairs(combat_state.ufos) do
        ufo.ap = ufo.ap_max  -- Varies by UFO type
    end
    
    -- 2. Determine initiative order (speed-based)
    local initiative_order = calculate_initiative(combat_state)
    
    -- 3. Execute actions in initiative order
    for _, actor in ipairs(initiative_order) do
        if actor.alive then
            execute_turn(actor, combat_state)
        end
    end
    
    -- 4. Turn end: regenerate energy
    for _, craft in ipairs(combat_state.player_crafts) do
        regenerate_energy(craft)
    end
    
    -- 5. Check victory conditions
    check_combat_end(combat_state)
end
```

### Initiative System

```lua
-- Calculate initiative order (speed determines turn order)
function calculate_initiative(combat_state)
    local actors = {}
    
    -- Collect all actors
    for _, craft in ipairs(combat_state.player_crafts) do
        table.insert(actors, craft)
    end
    for _, ufo in ipairs(combat_state.ufos) do
        table.insert(actors, ufo)
    end
    
    -- Sort by speed (descending)
    table.sort(actors, function(a, b)
        return a.speed > b.speed
    end)
    
    return actors
end
```

---

## Hit Chance Formulas

### Base Hit Chance

```lua
-- Core hit chance calculation
function calculate_hit_chance(attacker, target, weapon, distance)
    -- Base accuracy from weapon
    local base_accuracy = weapon.accuracy
    
    -- Range modifier (see Range Bands section)
    local range_modifier = calculate_range_accuracy(weapon, distance)
    
    -- Pilot skill bonus
    local pilot_skill = attacker.pilot_skill or 50
    local skill_modifier = (pilot_skill - 50) / 100  -- ±50% at skill 0/100
    
    -- Craft agility penalty for target
    local agility_penalty = (target.agility - 50) / 200  -- ±25% at agility 0/100
    
    -- Damage penalty (damaged craft less accurate)
    local damage_modifier = 1.0 - (attacker.damage_percent * 0.5)  -- Up to -50% at critical damage
    
    -- Calculate final hit chance
    local hit_chance = base_accuracy * range_modifier
    hit_chance = hit_chance * (1.0 + skill_modifier)
    hit_chance = hit_chance * (1.0 - agility_penalty)
    hit_chance = hit_chance * damage_modifier
    
    -- Clamp to 5-95% range
    hit_chance = math.max(0.05, math.min(0.95, hit_chance))
    
    return hit_chance
end
```

### Hit Chance Examples

**Interceptor (Skill 70) vs Scout UFO (Agility 60) at Medium Range:**
- Sidewinder missile: 75% base accuracy
- Range modifier: 0.9 (medium range)
- Skill modifier: +20% (70 vs 50 baseline)
- Agility penalty: -5% (60 agility)
- Damage modifier: 1.0 (no damage)
- Final: 0.75 × 0.9 × 1.2 × 0.95 × 1.0 = 76.95% → **77%**

**Damaged Interceptor (Skill 50, 40% damage) vs Fighter UFO (Agility 80) at Long Range:**
- Heavy Laser: 70% base accuracy
- Range modifier: 0.6 (long range)
- Skill modifier: 0% (50 baseline)
- Agility penalty: -15% (80 agility)
- Damage modifier: 0.8 (40% damage = 20% penalty)
- Final: 0.70 × 0.6 × 1.0 × 0.85 × 0.8 = 28.56% → **29%**

---

## Damage Calculation

### Damage Formula with Armor

```lua
-- Complete damage calculation including armor and penetration
function calculate_air_combat_damage(attacker, target, weapon)
    -- Base weapon damage with variance
    local base_damage = weapon.damage
    local variance = 0.15  -- ±15% damage variance
    local damage_roll = base_damage * (0.85 + math.random() * 0.3)
    
    -- Pilot skill damage bonus
    local pilot_skill = attacker.pilot_skill or 50
    local skill_bonus = (pilot_skill - 50) / 200  -- ±25% at skill 0/100
    damage_roll = damage_roll * (1.0 + skill_bonus)
    
    -- Critical hit multiplier (10% chance)
    local critical = false
    if math.random() < 0.10 then
        critical = true
        damage_roll = damage_roll * 1.5
    end
    
    -- Apply armor reduction
    local armor = target.armor or 0
    local penetration = weapon.armor_penetration or 0
    
    if critical then
        penetration = penetration * 1.5  -- Crits get bonus penetration
    end
    
    local effective_armor = math.max(0, armor - penetration)
    local damage_after_armor = math.max(0, damage_roll - effective_armor)
    
    -- Minimum damage rule: at least 10% gets through
    local minimum_damage = damage_roll * 0.1
    damage_after_armor = math.max(damage_after_armor, minimum_damage)
    
    return {
        damage = math.floor(damage_after_armor),
        critical = critical,
        armor_absorbed = math.floor(effective_armor),
    }
end
```

### UFO Armor Values

| UFO Type | Armor | Health | Threat Level |
|----------|-------|--------|--------------|
| **Small Scout** | 10 | 100 | Low |
| **Medium Scout** | 20 | 200 | Low |
| **Fighter** | 40 | 300 | Medium |
| **Heavy Fighter** | 60 | 400 | Medium |
| **Transport** | 80 | 600 | High |
| **Battleship** | 120 | 1000 | Very High |
| **Mothership** | 200 | 2000 | Extreme |

### Damage Examples

**Plasma Beam (180 damage, 50 penetration) vs Transport (80 armor, 600 HP):**
- Damage roll: 180 × (0.85 + 0.15) = 180 (average)
- Skill bonus: 1.0 (skill 50)
- Critical: No
- Effective armor: 80 - 50 = 30
- Final damage: 180 - 30 = **150 HP**

**Fusion Lance (400 damage, 100 penetration, CRITICAL) vs Battleship (120 armor, 1000 HP):**
- Damage roll: 400 × 1.00 = 400
- Critical multiplier: 400 × 1.5 = 600
- Penetration: 100 × 1.5 = 150 (critical bonus)
- Effective armor: 120 - 150 = 0
- Final damage: **600 HP**

---

## Evasion Mechanics

### Evasion Actions

```lua
-- Defensive maneuver system
DefensiveManeuvers = {
    evade = {
        ap_cost = 1,
        energy_cost = 5,
        evasion_bonus = 0.30,  -- +30% evasion
        duration = 1,  -- Lasts 1 turn
    },
    
    barrel_roll = {
        ap_cost = 2,
        energy_cost = 15,
        evasion_bonus = 0.50,  -- +50% evasion
        duration = 1,
    },
    
    defensive_pattern = {
        ap_cost = 3,
        energy_cost = 25,
        evasion_bonus = 0.70,  -- +70% evasion
        duration = 2,  -- Lasts 2 turns
    },
}

function execute_evasive_maneuver(craft, maneuver_type)
    local maneuver = DefensiveManeuvers[maneuver_type]
    
    -- Check resources
    if craft.ap < maneuver.ap_cost then
        return false, "Insufficient AP"
    end
    if craft.energy < maneuver.energy_cost then
        return false, "Insufficient energy"
    end
    
    -- Apply evasion buff
    craft.evasion_bonus = maneuver.evasion_bonus
    craft.evasion_duration = maneuver.duration
    
    -- Consume resources
    craft.ap = craft.ap - maneuver.ap_cost
    craft.energy = craft.energy - maneuver.energy_cost
    
    return true
end
```

### Evasion in Hit Calculation

```lua
-- Modified hit chance with evasion
function calculate_hit_chance_with_evasion(attacker, target, weapon, distance)
    -- Get base hit chance
    local hit_chance = calculate_hit_chance(attacker, target, weapon, distance)
    
    -- Apply target evasion
    if target.evasion_bonus and target.evasion_bonus > 0 then
        hit_chance = hit_chance * (1.0 - target.evasion_bonus)
    end
    
    -- Clamp result
    hit_chance = math.max(0.05, math.min(0.95, hit_chance))
    
    return hit_chance
end
```

### Evasion Examples

**Base Hit Chance: 70%**
- With Evade (+30%): 70% × (1.0 - 0.30) = **49%** hit chance
- With Barrel Roll (+50%): 70% × (1.0 - 0.50) = **35%** hit chance
- With Defensive Pattern (+70%): 70% × (1.0 - 0.70) = **21%** hit chance

---

## Range Bands and Accuracy

### Range System

```lua
-- Range bands for air combat
RangeBands = {
    CLOSE = {min = 0, max = 30, optimal = 1.0, name = "Close"},
    MEDIUM = {min = 30, max = 80, optimal = 0.9, name = "Medium"},
    LONG = {min = 80, max = 150, optimal = 0.6, name = "Long"},
    EXTREME = {min = 150, max = 300, optimal = 0.3, name = "Extreme"},
}

function calculate_range_accuracy(weapon, distance)
    -- Find range band
    local band = nil
    for _, b in pairs(RangeBands) do
        if distance >= b.min and distance < b.max then
            band = b
            break
        end
    end
    
    if not band then
        band = RangeBands.EXTREME
    end
    
    -- Weapon's optimal range
    local weapon_range = weapon.range
    
    -- If within weapon's optimal range, use band modifier
    if distance <= weapon_range * 0.5 then
        return 1.0  -- Perfect accuracy within half range
    elseif distance <= weapon_range then
        -- Linear falloff to max range
        local ratio = (distance - weapon_range * 0.5) / (weapon_range * 0.5)
        return 1.0 - (ratio * 0.3)  -- Up to -30% penalty
    else
        -- Beyond optimal: severe penalty
        local overshoot = (distance - weapon_range) / weapon_range
        return math.max(0.1, band.optimal * (1.0 - overshoot * 0.5))
    end
end
```

### Range Modifier Table

| Distance | Close (<30km) | Medium (30-80km) | Long (80-150km) | Extreme (>150km) |
|----------|---------------|------------------|-----------------|------------------|
| **Cannon (15km optimal)** | 100% → 70% | 30% | 10% | 5% |
| **Stinger (30km optimal)** | 100% → 70% | 70% → 40% | 20% | 10% |
| **Sidewinder (60km optimal)** | 100% | 100% → 70% | 50% → 30% | 15% |
| **Laser Cannon (50km optimal)** | 100% | 100% → 70% | 60% → 40% | 20% |
| **Plasma Beam (80km optimal)** | 100% | 100% | 100% → 70% | 50% → 30% |
| **Heavy Plasma (100km optimal)** | 100% | 100% | 100% → 70% | 70% → 40% |
| **Fusion Lance (120km optimal)** | 100% | 100% | 100% | 100% → 70% |

---

## Pursuit and Escape

### Distance Change Mechanics

```lua
-- Change distance between craft and UFO
function change_distance(actor, target, direction, ap_spent)
    -- Direction: "close" or "retreat"
    local speed = actor.speed
    
    -- AP scaling (spending more AP = more efficient movement)
    local ap_multipliers = {
        [1] = 1.0,
        [2] = 2.5,
        [3] = 4.0,
        [4] = 6.0,
    }
    
    local multiplier = ap_multipliers[ap_spent] or 1.0
    
    -- Base distance change per AP
    local base_distance_change = speed * 0.15  -- 15% of speed per AP
    
    -- Total distance change
    local distance_change = base_distance_change * multiplier
    
    -- Apply energy cost
    local energy_cost = 10 * ap_spent
    
    if actor.energy < energy_cost then
        return false, "Insufficient energy"
    end
    
    actor.energy = actor.energy - energy_cost
    actor.ap = actor.ap - ap_spent
    
    -- Modify distance
    if direction == "close" then
        target.distance = math.max(0, target.distance - distance_change)
    else  -- retreat
        target.distance = target.distance + distance_change
    end
    
    return true, distance_change
end
```

### Pursuit Examples

**Interceptor (Speed 200) closing on UFO:**
- 1 AP: 200 × 0.15 × 1.0 = **30km** closed
- 2 AP: 200 × 0.15 × 2.5 = **75km** closed
- 3 AP: 200 × 0.15 × 4.0 = **120km** closed
- 4 AP: 200 × 0.15 × 6.0 = **180km** closed

**Scout UFO (Speed 300) escaping:**
- 1 AP: 300 × 0.15 × 1.0 = **45km** retreat
- 2 AP: 300 × 0.15 × 2.5 = **112.5km** retreat

### Pursuit AI Logic

```lua
-- UFO escape decision
function ufo_escape_check(ufo, player_craft)
    -- Escape conditions
    local health_percent = ufo.health / ufo.health_max
    local distance = ufo.distance_to_target
    
    -- Flee if low health
    if health_percent < 0.3 then
        return true, "low_health"
    end
    
    -- Flee if outmatched (rough damage comparison)
    local player_dps = estimate_craft_dps(player_craft)
    local ufo_dps = estimate_craft_dps(ufo)
    
    if player_dps > ufo_dps * 2 then
        return true, "outmatched"
    end
    
    -- Flee if mission completed
    if ufo.mission_completed then
        return true, "mission_complete"
    end
    
    return false, "continue_combat"
end

function ufo_escape_attempt(ufo, combat_state)
    -- UFO tries to reach escape distance (300km)
    local escape_distance = 300
    local current_distance = ufo.distance_to_target
    
    if current_distance >= escape_distance then
        -- Successfully escaped
        combat_state.ufo_escaped = true
        return true
    end
    
    -- Spend all AP retreating
    change_distance(ufo, combat_state.player_craft, "retreat", ufo.ap)
    
    return false  -- Still in combat
end
```

---

## Action Points Framework

### AP System

```lua
-- Action point management
ActionCosts = {
    -- Movement
    close_distance = 1,       -- 1 AP per increment
    retreat = 1,              -- 1 AP per increment
    
    -- Defensive
    evade = 1,
    barrel_roll = 2,
    defensive_pattern = 3,
    
    -- Weapons (varies by weapon)
    fire_cannon = 1,
    fire_missile = 2,
    fire_laser = 1,
    fire_plasma = 2,
    fire_heavy_weapon = 3,
    
    -- Special
    rest_and_recover = 0,     -- Uses all remaining AP
    scan_ufo = 1,
    hail_ufo = 1,
}

function execute_action(craft, action_type, target)
    local ap_cost = ActionCosts[action_type]
    
    if craft.ap < ap_cost then
        return false, "Insufficient AP"
    end
    
    -- Execute action
    local success = perform_action(craft, action_type, target)
    
    if success then
        craft.ap = craft.ap - ap_cost
    end
    
    return success
end
```

---

## Energy Management

### Energy System

```lua
-- Energy regeneration system
function regenerate_energy(craft)
    local base_regen = craft.energy_regen or 20  -- Base 20 per round
    
    -- Resting bonus (if craft used "Rest" action)
    if craft.resting then
        base_regen = base_regen * 2
        craft.resting = false
    end
    
    -- Apply regen
    craft.energy = math.min(craft.energy_max, craft.energy + base_regen)
end

function rest_action(craft)
    -- Consume all remaining AP for bonus energy regen
    if craft.ap > 0 then
        local bonus_regen = craft.ap * 5  -- +5 energy per AP spent
        craft.energy = math.min(craft.energy_max, craft.energy + bonus_regen)
        craft.ap = 0
        craft.resting = true  -- Marks for double regen next turn
    end
end
```

---

## Movement System

### Movement Actions

```lua
-- Complete movement system
function execute_movement(craft, target, direction, ap_spent)
    -- Validate AP
    if craft.ap < ap_spent then
        return false, "Insufficient AP"
    end
    
    -- Calculate energy cost
    local energy_cost = 10 * ap_spent
    if craft.energy < energy_cost then
        return false, "Insufficient energy"
    end
    
    -- Calculate distance change
    local speed = craft.speed
    local damage_penalty = 1.0 - (craft.damage_percent * 0.3)  -- Up to -30% at critical
    speed = speed * damage_penalty
    
    local ap_efficiency = {1.0, 2.5, 4.0, 6.0}
    local efficiency = ap_efficiency[ap_spent] or 1.0
    
    local distance_per_ap = speed * 0.15
    local total_distance = distance_per_ap * efficiency
    
    -- Apply movement
    if direction == "close" then
        target.distance = math.max(0, target.distance - total_distance)
    else
        target.distance = target.distance + total_distance
    end
    
    -- Consume resources
    craft.ap = craft.ap - ap_spent
    craft.energy = craft.energy - energy_cost
    
    return true, total_distance
end
```

---

## UFO AI Behavior

### AI States

```lua
-- UFO behavioral states
UFOBehaviorStates = {
    AGGRESSIVE = "aggressive",      -- Closes and attacks
    EVASIVE = "evasive",           -- Maintains distance, attacks
    FLEEING = "fleeing",           -- Attempts escape
    BOMBARDING = "bombarding",     -- Attacks bases/cities
    SCOUTING = "scouting",         -- Avoids combat
}

function determine_ufo_behavior(ufo, combat_state)
    local health_percent = ufo.health / ufo.health_max
    local distance = ufo.distance_to_target
    
    -- Fleeing if critically damaged
    if health_percent < 0.25 then
        return UFOBehaviorStates.FLEEING
    end
    
    -- Mission-based behavior
    if ufo.mission_type == "terror" or ufo.mission_type == "bombardment" then
        if distance > 100 then
            return UFOBehaviorStates.AGGRESSIVE  -- Close to bombard
        else
            return UFOBehaviorStates.BOMBARDING
        end
    end
    
    if ufo.mission_type == "scout" then
        if health_percent < 0.5 then
            return UFOBehaviorStates.FLEEING
        else
            return UFOBehaviorStates.SCOUTING
        end
    end
    
    -- Default: aggressive if healthy, evasive if damaged
    if health_percent > 0.6 then
        return UFOBehaviorStates.AGGRESSIVE
    else
        return UFOBehaviorStates.EVASIVE
    end
end
```

### AI Action Selection

```lua
-- UFO AI decision making
function ufo_ai_turn(ufo, combat_state)
    local behavior = determine_ufo_behavior(ufo, combat_state)
    local target = combat_state.player_craft
    
    if behavior == UFOBehaviorStates.FLEEING then
        -- Spend all AP retreating
        execute_movement(ufo, target, "retreat", ufo.ap)
        
    elseif behavior == UFOBehaviorStates.AGGRESSIVE then
        -- Close distance and attack
        if ufo.distance_to_target > 50 then
            execute_movement(ufo, target, "close", 2)
        end
        
        -- Fire weapons
        for _, weapon in ipairs(ufo.weapons) do
            if ufo.ap >= weapon.ap_cost then
                fire_weapon(ufo, weapon, target)
            end
        end
        
    elseif behavior == UFOBehaviorStates.EVASIVE then
        -- Maintain distance and attack
        if ufo.distance_to_target < 80 then
            execute_movement(ufo, target, "retreat", 1)
        end
        
        -- Use evasion if available
        if ufo.ap >= 2 then
            execute_evasive_maneuver(ufo, "evade")
        end
        
        -- Fire weapons
        for _, weapon in ipairs(ufo.weapons) do
            if ufo.ap >= weapon.ap_cost then
                fire_weapon(ufo, weapon, target)
            end
        end
        
    elseif behavior == UFOBehaviorStates.SCOUTING then
        -- Avoid combat
        if ufo.distance_to_target < 150 then
            execute_movement(ufo, target, "retreat", 3)
        end
    end
end
```

---

## Lua Implementation

### Complete Combat System

```lua
-- Air combat manager
AirCombat = {
    player_craft = nil,
    ufo = nil,
    distance = 150,  -- Starting distance
    turn_number = 0,
    max_turns = 20,  -- Combat timeout
}

function AirCombat:initialize(craft, ufo)
    self.player_craft = craft
    self.ufo = ufo
    self.distance = 150
    self.turn_number = 0
    
    -- Reset resources
    craft.ap = craft.ap_max
    craft.energy = craft.energy_max
    ufo.ap = ufo.ap_max
    ufo.energy = ufo.energy_max
end

function AirCombat:execute_turn()
    self.turn_number = self.turn_number + 1
    
    -- Restore AP
    self.player_craft.ap = self.player_craft.ap_max
    self.ufo.ap = self.ufo.ap_max
    
    -- Determine initiative
    local first, second
    if self.player_craft.speed >= self.ufo.speed then
        first, second = self.player_craft, self.ufo
    else
        first, second = self.ufo, self.player_craft
    end
    
    -- Execute turns
    self:execute_actor_turn(first)
    if not self:check_combat_end() then
        self:execute_actor_turn(second)
    end
    
    -- Regenerate energy
    regenerate_energy(self.player_craft)
    regenerate_energy(self.ufo)
    
    -- Check combat end
    return self:check_combat_end()
end

function AirCombat:check_combat_end()
    -- UFO destroyed
    if self.ufo.health <= 0 then
        return true, "victory"
    end
    
    -- Player craft destroyed
    if self.player_craft.health <= 0 then
        return true, "defeat"
    end
    
    -- UFO escaped
    if self.distance >= 300 then
        return true, "escaped"
    end
    
    -- Turn limit
    if self.turn_number >= self.max_turns then
        return true, "timeout"
    end
    
    return false, "ongoing"
end
```

---

## Integration Points

### Geoscape Integration
```lua
-- Start air combat from geoscape
function initiate_air_combat(craft, mission)
    local combat = AirCombat:new()
    combat:initialize(craft, mission.ufo)
    
    -- Switch to combat screen
    UI.push_screen("air_combat", combat)
end
```

### Transition to Ground Combat
```lua
-- Successful interception leads to ground battle
function complete_air_combat(combat, result)
    if result == "victory" and combat.ufo.crashed then
        -- UFO crashed, start recovery mission
        generate_crash_site(combat.ufo.location)
    end
end
```

---

## Cross-References

### Related Systems
- **[Air_Weapons.md](Air_Weapons.md)** - Complete weapon stats and mechanics
- **[Detection.md](../geoscape/Detection.md)** - Mission detection and interception
- **[Crafts.md](../crafts/Crafts.md)** - Craft stats and capabilities
- **[Action_Economy.md](../core/Action_Economy.md)** - AP system details
- **[Energy_Systems.md](../core/Energy_Systems.md)** - Energy management

### Design Documents
- **Interception Core Mechanics** - Complete interception system
- **Mission Lifecycle** - Mission flow from detection to resolution
- **Tech Tree** - Weapon and craft progression

---

**Implementation Status:** Complete specification with formulas ready for coding  
**Testing Requirements:** 
- Hit chance calculations
- Damage with armor and penetration
- Evasion system
- Range accuracy modifiers
- Pursuit/escape mechanics
- UFO AI behavior states

**Version History:**
- v1.0 (2025-09-30): Enhanced with complete formulas, hit chance, damage calculations, evasion, and pursuit mechanics

---

## Related Wiki Pages

- [Interception Core Mechanics.md](Interception%20Core%20Mechanics.md) - Core interception systems
- [Mission Detection and Assignment.md](Mission%20Detection%20and%20Assignment.md) - Mission generation and assignment
- [Air_Weapons.md](Air_Weapons.md) - Complete weapon statistics
- [Overview.md](Overview.md) - Interception overview
- [Base Defense and Bombardment.md](Base%20Defense%20and%20Bombardment.md) - Base defense mechanics
- [Crafts.md](../crafts/Crafts.md) - Craft systems and stats
- [Action_Economy.md](../core/Action_Economy.md) - AP system details

## Master References

📖 **For comprehensive Action Economy documentation, see:**
- **[Action Economy Master Document](../core/Action_Economy.md)** - Complete AP system across all game layers
- **[Time Systems](../core/Time_Systems.md)** - Time scale conversions and round structure

This document covers Operational-level air combat using 4 AP per 30-second round. For broader context including:
- Tactical action points (Battlescape 6-second turns)
- Strategic time-based actions (Geoscape 5-minute ticks)
- AP equivalence formulas (1 operational AP = 5 tactical turns)
- Complete action economy design philosophy

Please refer to the master Action Economy document linked above.

## References to Existing Games and Mechanics

- **XCOM Series**: Air combat and interception mechanics
- **Ace Combat**: Aerial combat and dogfighting
- **IL-2 Sturmovik**: Historical air combat systems
- **Into the Breach**: AP-based tactical combat
- **Wing Commander**: Space combat and dogfighting
- **Star Control**: Tactical space combat
- **Freespace**: Naval space combat systems






