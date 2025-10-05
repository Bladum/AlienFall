# Status Effects

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Status Effect Categories](#status-effect-categories)
  - [Effect Application System](#effect-application-system)
  - [Duration and Expiration](#duration-and-expiration)
  - [Stacking Rules](#stacking-rules)
  - [Immunity and Resistance](#immunity-and-resistance)
  - [Effect Interactions](#effect-interactions)
  - [Cleansing and Removal](#cleansing-and-removal)
  - [UI Representation](#ui-representation)
- [Examples](#examples)
  - [Overwatch Reaction Fire](#overwatch-reaction-fire)
  - [Burning Damage Over Time](#burning-damage-over-time)
  - [Mind Control Domination](#mind-control-domination)
  - [Stacking Poison Effects](#stacking-poison-effects)
  - [Breaking Free from Stun](#breaking-free-from-stun)
  - [Suppression Fire Impact](#suppression-fire-impact)
  - [Bleeding and Stabilization](#bleeding-and-stabilization)
  - [Robotic Immunity Systems](#robotic-immunity-systems)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Status Effects system provides turn-based, stackable conditions that modify unit capabilities and behavior during tactical battlescape combat in Alien Fall. Status effects encompass both beneficial buffs (Overwatch, Aiming, Inspired) and harmful debuffs (Stunned, Burning, Mind Controlled), creating dynamic combat scenarios where temporary conditions shape tactical decision-making. The system supports deterministic application through seeded randomization, comprehensive duration management, and sophisticated stacking rules for multiple simultaneous effects.

Status effects integrate with combat mechanics, unit stats, and equipment systems to deliver tactical depth through condition-based gameplay. Effects can modify accuracy, mobility, action points, damage resistance, and behavioral control, with clear visual feedback and explicit counter-play options through specialized equipment, abilities, and environmental interactions.

## Mechanics

### Status Effect Categories

### Status Effect Categories

The system categorizes effects into positive buffs and negative debuffs, each with distinct durations and mechanical impacts:

**Positive Effects (Buffs):**

| Effect | Duration | Description | Source |
|--------|----------|-------------|--------|
| **Overwatch** | Until triggered or turn end | Unit automatically shoots at first enemy that moves in range | Player command |
| **Hunker Down** | 1 turn | +50 defense, cannot shoot | Player command |
| **Aiming** | Until shot | +20% accuracy per turn aimed (max +60%) | Player command |
| **Inspired** | 3 turns | +10% accuracy, +1 morale | Officer ability |
| **Stimmed** | 5 turns | +2 AP, +20% speed, -10% accuracy | Stimpack item |
| **Shielded** | 5 turns | Absorbs 50 damage before breaking | Psi Shield ability |

**Negative Effects (Debuffs):**

| Effect | Duration | Description | Source |
|--------|----------|-------------|--------|
| **Stunned** | 1-3 turns | Unit cannot act, auto-fails morale checks | Stun weapons, explosions |
| **Panicked** | 1-2 turns | Unit acts randomly, may flee or shoot allies | Low morale, psi attacks |
| **Burning** | 3 turns | 10 damage per turn, -10% accuracy | Fire weapons, incendiary |
| **Poisoned** | 5 turns | 5 damage per turn, -20% health regen | Poison weapons, gas |
| **Bleeding** | Until stabilized | 3 damage per turn, can lead to death | Critical hits, sharp weapons |
| **Suppressed** | 1 turn | -40% accuracy, -2 AP if moving | Heavy weapons fire |
| **Disoriented** | 2 turns | Cannot use abilities, -20% accuracy | Flashbangs, concussions |
| **Acid Burn** | 4 turns | 8 damage per turn, -50% armor | Acid weapons, alien spit |
| **Mind Controlled** | Until broken | Unit controlled by enemy | Psi attacks |
| **Berserk** | 2 turns | Attacks nearest unit (friend or foe) | Alien rage ability |
| **Slowed** | 3 turns | -50% speed, movement costs double AP | Cryogenic weapons, webs |
| **Blinded** | 2 turns | -80% accuracy, -10 vision range | Smoke, flashbangs, darkness |

### Effect Application System

### Effect Application System

Status effects are applied through weapons, abilities, environmental hazards, and unit interactions with deterministic resolution:

**Overwatch Activation:**
```lua
function activate_overwatch(unit)
    unit.status_effects.overwatch = {
        active = true,
        ap_reserved = 2,  -- Costs 2 AP to set up
        shots_remaining = 1,
        trigger_range = unit.weapon.range,
        facing_arc = 180  -- 180° front arc
    }
    
    unit.ap = unit.ap - 2
end
```

**Overwatch Trigger:**
```lua
function check_overwatch_trigger(watching_unit, moving_unit)
    local overwatch = watching_unit.status_effects.overwatch
    
    if not overwatch or not overwatch.active then
        return false
    end
    
    -- Check range
    local distance = calculate_distance(watching_unit, moving_unit)
    if distance > overwatch.trigger_range then
        return false
    end
    
    -- Check facing
    if not is_in_field_of_view(watching_unit, moving_unit) then
        return false
    end
    
    -- Check LOS
    local has_los = check_line_of_sight(map, watching_unit, moving_unit)
    if not has_los then
        return false
    end
    
    return true
end

function trigger_overwatch_shot(watching_unit, moving_unit)
    local overwatch = watching_unit.status_effects.overwatch
    
    -- Take reaction shot
    execute_attack(watching_unit, moving_unit)
    
    -- Consume shot
    overwatch.shots_remaining = overwatch.shots_remaining - 1
    if overwatch.shots_remaining <= 0 then
        overwatch.active = false
    end
end
```

**Stunned Application:**
```lua
function apply_stun(unit, duration, source)
    unit.status_effects.stunned = {
        duration = duration,
        source = source,
        applied_turn = map.current_turn,
        recovery_chance = 0.3  -- 30% chance to recover each turn
    }
    
    log_event(unit.name .. " has been stunned!")
end
```

**Stunned Effect:**
```lua
function can_unit_act(unit)
    if unit.status_effects.stunned then
        -- Roll for recovery
        if roll_chance(unit.status_effects.stunned.recovery_chance) then
            remove_status_effect(unit, "stunned")
            log_event(unit.name .. " recovered from stun!")
            return true
        else
            log_event(unit.name .. " is stunned and cannot act")
            return false
        end
    end
    
    return true
end
```

**Burning Application:**
```lua
function apply_burning(unit, source)
    if unit.status_effects.burning then
        -- Already burning, refresh duration
        unit.status_effects.burning.duration = 3
    else
        unit.status_effects.burning = {
            duration = 3,
            damage_per_turn = 10,
            source = source,
            applied_turn = map.current_turn
        }
        
        log_event(unit.name .. " is on fire!")
    end
end
```

**Burning Tick Damage:**
```lua
function process_burning_damage(unit)
    local burning = unit.status_effects.burning
    
    if burning then
        -- Apply damage
        apply_damage(unit, burning.damage_per_turn, "fire")
        log_event(unit.name .. " takes " .. burning.damage_per_turn .. " fire damage")
        
        -- Decrement duration
        burning.duration = burning.duration - 1
        
        if burning.duration <= 0 then
            remove_status_effect(unit, "burning")
            log_event(unit.name .. " is no longer burning")
        end
    end
end
```

**Fire Extinguishing:**
```lua
function extinguish_fire(unit)
    if unit.status_effects.burning then
        remove_status_effect(unit, "burning")
        log_event(unit.name .. " extinguished the flames")
    end
end

function check_auto_extinguish(unit, map)
    if unit.status_effects.burning then
        local tile = map[unit.y][unit.x]
        
        -- Water extinguishes fire
        if tile.type == "water_shallow" or tile.type == "water_deep" then
            extinguish_fire(unit)
        end
    end
end
```

**Poisoned Application:**
```lua
function apply_poison(unit, potency, source)
    if unit.status_effects.poisoned then
        -- Stack poison
        unit.status_effects.poisoned.potency = unit.status_effects.poisoned.potency + potency
        unit.status_effects.poisoned.duration = 5  -- Refresh duration
    else
        unit.status_effects.poisoned = {
            duration = 5,
            potency = potency,
            damage_per_turn = 5 * potency,
            source = source,
            applied_turn = map.current_turn
        }
        
        log_event(unit.name .. " has been poisoned!")
    end
end
```

**Antidote Usage:**
```lua
function use_antidote(unit)
    if unit.status_effects.poisoned then
        remove_status_effect(unit, "poisoned")
        log_event(unit.name .. " cured the poison")
        return true
    end
    return false
end
```

**Bleeding Application:**
```lua
function apply_bleeding(unit, severity, source)
    unit.status_effects.bleeding = {
        severity = severity,  -- 1-3 (light, moderate, severe)
        damage_per_turn = severity * 3,
        stabilized = false,
        source = source,
        applied_turn = map.current_turn
    }
    
    log_event(unit.name .. " is bleeding!")
end
```

**Bleeding Stabilization:**
```lua
function stabilize_bleeding(medic, patient)
    if not patient.status_effects.bleeding then
        return false
    end
    
    local medical_skill = medic.stats.medical or 0
    local success_chance = 0.5 + (medical_skill / 100)  -- 50-100% based on skill
    
    if roll_chance(success_chance) then
        patient.status_effects.bleeding.stabilized = true
        patient.status_effects.bleeding.damage_per_turn = 0
        log_event(medic.name .. " stabilized " .. patient.name)
        return true
    else
        log_event(medic.name .. " failed to stabilize " .. patient.name)
        return false
    end
end
```

**Suppression Application:**
```lua
function apply_suppression(unit, suppressor)
    unit.status_effects.suppressed = {
        duration = 1,  -- Lasts until end of target's next turn
        suppressor = suppressor,
        accuracy_penalty = 40,
        ap_penalty = 2,
        applied_turn = map.current_turn
    }
    
    log_event(unit.name .. " is suppressed by " .. suppressor.name)
end
```

**Suppression Effect on Actions:**
```lua
function calculate_accuracy_with_effects(unit, target, base_accuracy)
    local accuracy = base_accuracy
    
    if unit.status_effects.suppressed then
        accuracy = accuracy - unit.status_effects.suppressed.accuracy_penalty
    end
    
    -- Other effects...
    
    return math.max(5, math.min(95, accuracy))
end

function calculate_ap_cost_with_effects(unit, action, base_cost)
    local ap_cost = base_cost
    
    if unit.status_effects.suppressed and action.type == "move" then
        ap_cost = ap_cost + unit.status_effects.suppressed.ap_penalty
    end
    
    return ap_cost
end
```

**Mind Control Application:**
```lua
function apply_mind_control(unit, controller, duration)
    unit.status_effects.mind_controlled = {
        controller = controller,
        duration = duration,
        original_faction = unit.faction,
        break_chance = 0.2,  -- 20% chance to break each turn
        applied_turn = map.current_turn
    }
    
    -- Change unit faction temporarily
    unit.faction = controller.faction
    unit.controlled_by_ai = true
    
    log_event(unit.name .. " has been mind controlled!")
end
```

**Breaking Mind Control:**
```lua
function check_mind_control_break(unit)
    local mc = unit.status_effects.mind_controlled
    
    if mc then
        -- Higher willpower = higher break chance
        local break_chance = mc.break_chance + (unit.stats.willpower / 200)
        
        if roll_chance(break_chance) then
            break_mind_control(unit)
            return true
        end
    end
    
    return false
end

function break_mind_control(unit)
    local mc = unit.status_effects.mind_controlled
    
    -- Restore original faction
    unit.faction = mc.original_faction
    unit.controlled_by_ai = false
    
    remove_status_effect(unit, "mind_controlled")
    log_event(unit.name .. " broke free from mind control!")
end
```

### Duration and Expiration

**Non-Stacking Effects:**
```lua
non_stacking_effects = {
    "stunned",          -- Only one stun at a time
    "mind_controlled",  -- Only one controller
    "panicked",         -- Can't be multiple panic states
    "berserk"
}

function apply_status_effect(unit, effect_name, effect_data)
    if contains(non_stacking_effects, effect_name) then
        -- Replace existing effect
        unit.status_effects[effect_name] = effect_data
    else
        -- Stack with existing effect
        if unit.status_effects[effect_name] then
            stack_effect(unit, effect_name, effect_data)
        else
            unit.status_effects[effect_name] = effect_data
        end
    end
end
```

**Stackable Effects:**
```lua
stackable_effects = {
    "burning",    -- Multiple fire sources
    "poisoned",   -- Toxins accumulate
    "bleeding",   -- Multiple wounds
    "aiming"      -- Aim bonus increases
}

function stack_effect(unit, effect_name, new_effect_data)
    local existing = unit.status_effects[effect_name]
    
    if effect_name == "burning" then
        -- Burning: refresh duration, increase damage
        existing.duration = math.max(existing.duration, new_effect_data.duration)
        existing.damage_per_turn = existing.damage_per_turn + new_effect_data.damage_per_turn
    elseif effect_name == "poisoned" then
        -- Poison: stack potency
        existing.potency = existing.potency + new_effect_data.potency
        existing.damage_per_turn = 5 * existing.potency
        existing.duration = 5
    elseif effect_name == "aiming" then
        -- Aiming: increment bonus (max cap)
        existing.accuracy_bonus = math.min(60, existing.accuracy_bonus + 20)
    end
end
```

### Immunity and Resistance

Certain unit types and equipment grant immunity or resistance to specific status effects:

**Immunity System:**
```lua
function is_immune_to_effect(unit, effect_name)
    -- Check unit type immunity
    if unit.type == "robot" then
        local robot_immunities = {"poisoned", "bleeding", "burning", "mind_controlled", "panicked"}
        if contains(robot_immunities, effect_name) then
            return true
        end
    end
    
    -- Check equipment immunity
    if unit.equipment.hazmat_suit and effect_name == "poisoned" then
        return true
    end
    
    if unit.equipment.fireproof_armor and effect_name == "burning" then
        return true
    end
    
    -- Check psi resistance
    if (effect_name == "mind_controlled" or effect_name == "panicked") then
        if unit.stats.willpower > 80 then
            if roll_chance(0.5) then  -- 50% resist chance with high willpower
                return true
            end
        end
    end
    
    return false
end
```

### Effect Interactions

Status effects can interact with each other, creating synergies or conflicts based on their nature.

### Cleansing and Removal

**Remove All Effects:**
```lua
function cleanse_all_effects(unit, effect_type)
    local cleansed = {}
    
    for effect_name, effect_data in pairs(unit.status_effects) do
        if effect_type == "all" or 
           (effect_type == "debuffs" and is_debuff(effect_name)) or
           (effect_type == "buffs" and is_buff(effect_name)) then
            unit.status_effects[effect_name] = nil
            table.insert(cleansed, effect_name)
        end
    end
    
    if #cleansed > 0 then
        log_event(unit.name .. " cleansed: " .. table.concat(cleansed, ", "))
    end
    
    return cleansed
end

function is_debuff(effect_name)
    local debuffs = {
        "stunned", "panicked", "burning", "poisoned", "bleeding",
        "suppressed", "disoriented", "acid_burn", "mind_controlled",
        "berserk", "slowed", "blinded"
    }
    return contains(debuffs, effect_name)
end

function is_buff(effect_name)
    local buffs = {
        "overwatch", "hunker_down", "aiming", "inspired",
        "stimmed", "shielded"
    }
    return contains(buffs, effect_name)
end
```

### Duration and Expiration

Status effects track turn-based durations with automatic expiration and per-turn processing:

**Turn Processing:**
```lua
function update_status_effects(unit)
    for effect_name, effect_data in pairs(unit.status_effects) do
        -- Process per-turn effects
        if effect_name == "burning" then
            process_burning_damage(unit)
        elseif effect_name == "poisoned" then
            process_poison_damage(unit)
        elseif effect_name == "bleeding" then
            process_bleeding_damage(unit)
        end
        
        -- Decrement duration
        if effect_data.duration then
            effect_data.duration = effect_data.duration - 1
            
            if effect_data.duration <= 0 then
                remove_status_effect(unit, effect_name)
                log_event(unit.name .. " recovered from " .. effect_name)
            end
        end
    end
end
```

**Effect Removal:**
```lua
function remove_status_effect(unit, effect_name)
    local effect_data = unit.status_effects[effect_name]
    
    if not effect_data then
        return
    end
    
    -- Special cleanup for certain effects
    if effect_name == "mind_controlled" then
        break_mind_control(unit)
    elseif effect_name == "overwatch" then
        -- Return reserved AP
        unit.ap = unit.ap + (effect_data.ap_reserved or 0)
    end
    
    unit.status_effects[effect_name] = nil
end
```

### Stacking Rules

**Icon Definitions:**
```lua
status_effect_icons = {
    overwatch = {icon = "icon_overwatch.png", color = {0, 1, 0}},
    stunned = {icon = "icon_stunned.png", color = {1, 1, 0}},
    burning = {icon = "icon_fire.png", color = {1, 0.5, 0}},
    poisoned = {icon = "icon_poison.png", color = {0.5, 1, 0}},
    bleeding = {icon = "icon_blood.png", color = {1, 0, 0}},
    suppressed = {icon = "icon_suppressed.png", color = {0.5, 0.5, 0.5}},
    mind_controlled = {icon = "icon_mind.png", color = {1, 0, 1}}
}
```

**Display:**
```lua
function draw_status_effects(unit)
    local x = unit.screen_x
    local y = unit.screen_y - 30
    local icon_size = 16
    local spacing = 2
    local i = 0
    
    for effect_name, effect_data in pairs(unit.status_effects) do
        local icon_data = status_effect_icons[effect_name]
        if icon_data then
            local icon_x = x + (icon_size + spacing) * i
            local icon_y = y
            
            -- Draw icon
            love.graphics.setColor(icon_data.color)
            love.graphics.draw(icon_data.icon, icon_x, icon_y)
            
            -- Draw duration
            if effect_data.duration then
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(effect_data.duration, icon_x + 2, icon_y + 10)
            end
            
            i = i + 1
        end
    end
    
    love.graphics.setColor(1, 1, 1)
end
```

---

## Cross-References

**Related Systems:**
- [Battlescape Combat](../battlescape/Combat.md) - Combat damage and effects
- [Units](../units/README.md) - Unit stats and capabilities
- [Items](../items/README.md) - Items that cause/cure effects
- [Morale System](../battlescape/Morale.md) - Panic and morale-related effects
- [Psi Abilities](../units/Psi_Abilities.md) - Mind control and psi effects

**Implementation Files:**
- `src/battlescape/status_effects.lua` - Status effect system
- `src/battlescape/combat.lua` - Effect application
- `src/ui/status_display.lua` - UI rendering
- `data/status_effects.toml` - Effect definitions

---

## Version History

- **v1.0 (2025-09-30):** Initial content specification for status effects
