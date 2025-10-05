# Unit Behavior Types System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Behavior Priority Hierarchy](#behavior-priority-hierarchy)
  - [Energy Pool and Action Point System](#energy-pool-and-action-point-system)
  - [Weapon and EquipmStrategic Goals → Formation Position → Energy Allocation → Weapon Choice → Execution
```

## Modding Supporteapon-and-equipment-management)
  - [Enemy Unit Behavior Types](#enemy-unit-behavior-types)
  - [Allied Unit Behavior Types](#allied-unit-behavior-types)
  - [Neutral Unit Behavior Types](#neutral-unit-behavior-types)
  - [Armor and Damage Management](#armor-and-damage-management)
  - [Integration with AI Hierarchy](#integration-with-ai-hierarchy)
- [Examples](#examples)
  - [Energy Pool Allocation Matrix](#energy-pool-allocation-matrix)
  - [Behavior Flow Diagrams](#behavior-flow-diagrams)
  - [Code Examples](#code-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Unit Behavior Types system implements a comprehensive framework for diverse AI unit behaviors in Alien Fall, inspired by tactical strategy games like XCOM. Each unit type follows distinct behavioral patterns that prioritize squad effectiveness while contributing to broader battle-side objectives. The system integrates with the hierarchical AI architecture, incorporating energy pool management, action points, and intelligent weapon selection to create challenging, predictable AI that rewards tactical player decisions.

The behavior system emphasizes deterministic decision-making with configurable parameters for difficulty scaling and modding support. Units dynamically allocate resources across movement, combat, special abilities, and reserve pools while adapting to mission context, squad coordination, and individual survival needs.

## Mechanics

### Behavior Priority Hierarchy
All unit behaviors follow this structured priority system ensuring coordinated tactical decision-making:

- **Squad Survival**: Immediate protection of squad cohesion and member safety
- **Squad Objectives**: Contribution to assigned squad mission and formation requirements
- **Personal Survival**: Self-preservation when squad integrity is maintained
- **Battle-Side Goals**: Support for broader faction objectives and mission completion
- **Exploration/Positioning**: Strategic positioning to improve future tactical options

### Energy Pool and Action Point System

Units manage tactical resources through dynamic allocation across four interconnected energy pools:

- **Movement Pool**: Controls positioning, repositioning, and pathfinding actions
- **Combat Pool**: Powers offensive attacks, defensive maneuvers, and weapon usage
- **Special Pool**: Enables unique abilities, special tactics, and advanced capabilities
- **Reserve Pool**: Emergency resources for critical situations and survival actions

### Weapon and Equipment Management

Intelligent weapon selection based on tactical context and situational requirements:

- **Range Optimization**: Weapon choice based on engagement distance and target positioning
- **Damage Potential**: Selection considering target armor, health, and vulnerability
- **Cover Penetration**: Weapons chosen for ability to bypass environmental protection
- **Ammunition Efficiency**: Conservation of limited resources and tactical sustainability

### Enemy Unit Behavior Types

Specialized tactical patterns for hostile AI units:

- **Hunter**: Aggressive pursuit specialist focusing on flanking and target isolation
- **Sniper**: Long-range precision expert providing overwatch and area control
- **Healer**: Squad sustainment unit maintaining combat effectiveness through regeneration
- **Commander**: Leadership unit coordinating squad actions and strategic adaptation
- **Scout**: Reconnaissance specialist revealing map areas and identifying threats
- **Suicide**: Kamikaze unit creating opportunities through self-sacrificial tactics
- **Long Range**: Artillery-like unit providing suppression and area denial
- **Assault**: Close-quarters specialist breaking through defenses and capturing objectives
- **Heavy**: Durable anchor unit providing formation stability and sustained firepower

### Allied Unit Behavior Types

Cooperative behaviors prioritizing player support and coordination:

- **Allied Sniper**: Conservative overwatch specialist protecting player positions
- **Allied Healer**: Player-focused regeneration unit prioritizing ally health
- **Allied Commander**: Coordination expert providing tactical support and threat warnings

### Neutral Unit Behavior Types

Self-preservation focused behaviors avoiding active combat participation:

- **Civilian/Refugee**: Evasion specialist seeking safe zones and avoiding all conflict
- **Wild Animal**: Territory defender responding only to direct threats
- **Robotic Drone**: Patrol unit maintaining area security through surveillance

### Armor and Damage Management

Strategic positioning and orientation to maximize defensive capabilities:

- **Facing Optimization**: Orientation of strongest armor toward primary threats
- **Cover Integration**: Environmental positioning supplementing armor weaknesses
- **Damage Type Adaptation**: Positioning adjustments based on incoming attack characteristics

### Integration with AI Hierarchy

Seamless coordination across strategic, squad, and individual AI levels:

- **Strategic Level**: Mission objective adaptation and resource allocation
- **Squad Level**: Formation maintenance and role specialization
- **Individual Level**: Personal decision-making within behavioral constraints

## Examples

### Energy Pool Allocation Matrix

| Unit Type | Movement | Combat | Special | Reserve | Primary Focus |
|-----------|----------|--------|---------|---------|---------------|
| Hunter    | 40%      | 40%    | 20%     | 0%      | Pursuit       |
| Sniper    | 20%      | 30%    | 40%     | 10%     | Overwatch     |
| Healer    | 30%      | 20%    | 40%     | 10%     | Sustainment   |
| Commander | 25%      | 25%    | 40%     | 10%     | Coordination  |
| Scout     | 50%      | 20%    | 20%     | 10%     | Exploration   |
| Suicide   | 60%      | 30%     | 10%     | 0%      | Sacrifice     |
| Long Range| 15%      | 35%    | 40%     | 10%     | Suppression   |
| Assault   | 35%      | 50%    | 15%     | 0%      | Breakthrough  |
| Heavy     | 20%      | 40%    | 30%     | 10%     | Defense       |

### Behavior Flow Diagrams

#### Unit Behavior Flow
```
Mission Context → Squad Assignment → Unit Role → Behavior Priority → Action Selection
       ↓              ↓              ↓              ↓              ↓
Strategic Goals → Formation Position → Energy Allocation → Weapon Choice → Execution
```

### Code Examples

#### Energy Pool Management

```lua
-- Energy Pool Management
local ENERGY_POOL = {
    MOVEMENT = "movement",
    COMBAT = "combat",
    SPECIAL = "special",
    RESERVE = "reserve"
}

function allocate_energy_pool(unit, situation)
    local allocation = {
        [ENERGY_POOL.MOVEMENT] = 0.3,  -- Base movement allocation
        [ENERGY_POOL.COMBAT] = 0.4,    -- Combat actions
        [ENERGY_POOL.SPECIAL] = 0.2,   -- Special abilities
        [ENERGY_POOL.RESERVE] = 0.1    -- Emergency reserve
    }

    -- Adjust based on unit type and situation
    if unit.type == "assault" and situation.close_combat then
        allocation[ENERGY_POOL.COMBAT] = 0.6
        allocation[ENERGY_POOL.MOVEMENT] = 0.2
    elseif unit.type == "sniper" and situation.overwatch_opportunity then
        allocation[ENERGY_POOL.SPECIAL] = 0.4
        allocation[ENERGY_POOL.MOVEMENT] = 0.1
    end

    return allocation
end
```

#### Weapon Selection Logic

```lua
function select_optimal_weapon(unit, target, distance, cover_situation)
    local weapons = {unit.primary_weapon, unit.secondary_weapon}

    for _, weapon in ipairs(weapons) do
        if evaluate_weapon_suitability(weapon, target, distance, cover_situation) then
            return weapon
        end
    end

    return unit.primary_weapon -- Default fallback
end

function evaluate_weapon_suitability(weapon, target, distance, cover_situation)
    local score = 0

    -- Range suitability
    if distance >= weapon.min_range and distance <= weapon.max_range then
        score = score + 30
    end

    -- Damage vs target armor
    local damage_potential = calculate_damage_potential(weapon, target.armor)
    score = score + damage_potential

    -- Cover penetration
    if cover_situation.target_has_cover and weapon.can_penetrate_cover then
        score = score + 20
    end

    -- Ammo efficiency
    local ammo_efficiency = weapon.current_ammo / weapon.max_ammo
    score = score + (ammo_efficiency * 10)

    return score > 50 -- Threshold for suitability
end
```

#### Hunter Behavior Implementation

```lua
function hunter_behavior_update(unit, squad, situation)
    -- Primary: Find and isolate targets
    if situation.has_priority_targets then
        local isolated_target = find_isolated_target(squad, situation)
        if isolated_target then
            return pursue_and_flank(unit, isolated_target, squad)
        end
    end

    -- Secondary: Support squad by creating opportunities
    if squad.formation == "tight" then
        return create_flanking_opportunity(unit, squad)
    end

    -- Tertiary: Aggressive positioning
    return aggressive_positioning(unit, situation.threats)
end
```
**Behavior**: Flee from all combat, seek safe zones
**Squad Priority**: None (individuals or small groups)
**Battle-Side Priority**: Survival and minimal interference

### Wild Animal
**Behavior**: Avoid combat unless cornered, then defend territory
**Squad Priority**: Pack coordination for hunting/defense
**Battle-Side Priority**: None, follows survival instincts

### Robotic Drone
**Behavior**: Patrol patterns, defend assigned areas
**Squad Priority**: Networked coordination
**Battle-Side Priority**: Area security and surveillance

## Armor and Damage Management

### Armor Usage Strategy

Units position to maximize armor effectiveness:

- **Facing**: Orient strongest armor toward primary threats
- **Positioning**: Use cover to supplement armor weaknesses
- **Movement**: Adjust positioning based on incoming damage types

## Integration with AI Hierarchy

### Strategic Level Integration
Unit behaviors adapt to mission objectives:

- **Elimination Missions**: Aggressive behaviors, prioritize combat AP allocation
- **Survival Missions**: Defensive behaviors, prioritize movement and positioning
- **Extraction Missions**: Escort behaviors, coordinate with protected units

### Squad Level Integration
Units contribute to squad tactics:

- **Formation Maintenance**: Position according to squad formation requirements
- **Role Specialization**: Focus on squad-assigned roles (flank, support, etc.)
- **Communication**: Signal status and needs to squad coordinator

### Individual Level Integration
Personal decision making within behavior constraints:

- **Threat Assessment**: Evaluate local dangers within behavior framework
- **Opportunity Recognition**: Identify behavior-specific opportunities
- **Resource Management**: Balance personal needs with squad/battle-side goals

## Behavior Diagrams

### Unit Behavior Flow
```
Mission Context → Squad Assignment → Unit Role → Behavior Priority → Action Selection
       ↓              ↓              ↓              ↓              ↓
Strategic Goals → Formation Position → Energy Allocation → Weapon Choice → Execution
```

### Energy Pool Allocation Matrix

| Unit Type | Movement | Combat | Special | Reserve | Primary Focus |
|-----------|----------|--------|---------|---------|---------------|
| Hunter    | 40%      | 40%    | 20%     | 0%      | Pursuit       |
| Sniper    | 20%      | 30%    | 40%     | 10%     | Overwatch     |
| Healer    | 30%      | 20%    | 40%     | 10%     | Sustainment   |
| Commander | 25%      | 25%    | 40%     | 10%     | Coordination  |
| Scout     | 50%      | 20%    | 20%     | 10%     | Exploration   |
| Suicide   | 60%      | 30%    | 10%     | 0%      | Sacrifice     |
| Long Range| 15%      | 35%    | 40%     | 10%     | Suppression   |
| Assault   | 35%      | 50%    | 15%     | 0%      | Breakthrough  |
| Heavy     | 20%      | 40%    | 30%     | 10%     | Defense       |

## Modding Support

### Custom Behavior Templates

Allow mods to create new unit behaviors through TOML configuration:

```toml
[custom_behavior.stealth_infiltrator]
base_type = "scout"
special_abilities = ["cloaking", "silent_movement"]
energy_allocation = { movement = 0.6, combat = 0.2, special = 0.2 }
weapon_priorities = ["silent_weapons", "non-lethal"]
squad_contribution = "infiltration_support"
battle_side_priority = "disruption"
```

### Behavior Override System

Mods can modify existing behaviors through Lua scripting hooks.

## Code Examples

### Energy Pool Management

```lua
-- Energy Pool Management
local ENERGY_POOL = {
    MOVEMENT = "movement",
    COMBAT = "combat",
    SPECIAL = "special",
    RESERVE = "reserve"
}

function allocate_energy_pool(unit, situation)
    local allocation = {
        [ENERGY_POOL.MOVEMENT] = 0.3,  -- Base movement allocation
        [ENERGY_POOL.COMBAT] = 0.4,    -- Combat actions
        [ENERGY_POOL.SPECIAL] = 0.2,   -- Special abilities
        [ENERGY_POOL.RESERVE] = 0.1    -- Emergency reserve
    }

    -- Adjust based on unit type and situation
    if unit.type == "assault" and situation.close_combat then
        allocation[ENERGY_POOL.COMBAT] = 0.6
        allocation[ENERGY_POOL.MOVEMENT] = 0.2
    elseif unit.type == "sniper" and situation.overwatch_opportunity then
        allocation[ENERGY_POOL.SPECIAL] = 0.4
        allocation[ENERGY_POOL.MOVEMENT] = 0.1
    end

    return allocation
end
```

### Weapon Selection Logic

```lua
function select_optimal_weapon(unit, target, distance, cover_situation)
    local weapons = {unit.primary_weapon, unit.secondary_weapon}

    for _, weapon in ipairs(weapons) do
        if evaluate_weapon_suitability(weapon, target, distance, cover_situation) then
            return weapon
        end
    end

    return unit.primary_weapon -- Default fallback
end

function evaluate_weapon_suitability(weapon, target, distance, cover_situation)
    local score = 0

    -- Range suitability
    if distance >= weapon.min_range and distance <= weapon.max_range then
        score = score + 30
    end

    -- Damage vs target armor
    local damage_potential = calculate_damage_potential(weapon, target.armor)
    score = score + damage_potential

    -- Cover penetration
    if cover_situation.target_has_cover and weapon.can_penetrate_cover then
        score = score + 20
    end

    -- Ammo efficiency
    local ammo_efficiency = weapon.current_ammo / weapon.max_ammo
    score = score + (ammo_efficiency * 10)

    return score > 50 -- Threshold for suitability
end
```

### Unit Behavior Functions

#### Hunter Behavior

```lua
function hunter_behavior_update(unit, squad, situation)
    -- Primary: Find and isolate targets
    if situation.has_priority_targets then
        local isolated_target = find_isolated_target(squad, situation)
        if isolated_target then
            return pursue_and_flank(unit, isolated_target, squad)
        end
    end

    -- Secondary: Support squad by creating opportunities
    if squad.formation == "tight" then
        return create_flanking_opportunity(unit, squad)
    end

    -- Tertiary: Aggressive positioning
    return aggressive_positioning(unit, situation.threats)
end
```

#### Sniper Behavior

```lua
function sniper_behavior_update(unit, squad, situation)
    -- Primary: Establish overwatch on squad flanks
    if not squad.has_overwatch and situation.flank_exposed then
        return establish_overwatch_position(unit, squad.flanks)
    end

    -- Secondary: Target priority enemies
    local priority_target = find_priority_target(situation.visible_enemies, "high_value")
    if priority_target and can_hit_from_position(unit.position, priority_target.position) then
        return snipe_target(unit, priority_target)
    end

    -- Tertiary: Find optimal firing position
    return find_sniper_position(unit, situation.terrain, squad.position)
end
```

#### Healer Behavior

```lua
function healer_behavior_update(unit, squad, situation)
    -- Primary: Heal critically wounded squad members
    local critical_ally = find_most_wounded_ally(squad.units, unit)
    if critical_ally and distance(unit.position, critical_ally.position) <= 3 then
        return heal_ally(unit, critical_ally)
    end

    -- Secondary: Position for squad support
    if not in_support_position(unit, squad) then
        return move_to_support_position(unit, squad)
    end

    -- Tertiary: Provide covering fire if safe
    if situation.low_threat and unit.secondary_weapon then
        return provide_covering_fire(unit, situation.nearby_threats)
    end
end
```

#### Commander Behavior

```lua
function commander_behavior_update(unit, squad, situation)
    -- Primary: Assess and direct squad actions
    local squad_status = assess_squad_effectiveness(squad)
    if squad_status.needs_reformation then
        return direct_formation_change(unit, squad, situation)
    end

    -- Secondary: Coordinate with nearby squads
    local nearby_squads = find_nearby_squads(unit.faction, unit.position)
    if #nearby_squads > 0 then
        return coordinate_multi_squad_action(unit, squad, nearby_squads, situation)
    end

    -- Tertiary: Position for optimal command
    return maintain_command_position(unit, squad, situation.terrain)
end
```

#### Scout Behavior

```lua
function scout_behavior_update(unit, squad, situation)
    -- Primary: Explore unknown areas for squad
    local unknown_area = find_nearest_unknown_area(unit.known_map, unit.position)
    if unknown_area and not situation.high_threat then
        return explore_area(unit, unknown_area, squad)
    end

    -- Secondary: Report enemy positions
    if situation.visible_enemies and not squad.has_intelligence then
        return report_intelligence(unit, situation.visible_enemies, squad)
    end

    -- Tertiary: Find concealed observation position
    return find_observation_position(unit, situation.terrain, squad)
end
```

#### Suicide Behavior

```lua
function suicide_behavior_update(unit, squad, situation)
    -- Primary: Identify high-value targets
    local high_value_target = find_high_value_target(situation, unit.explosion_radius)
    if high_value_target then
        return approach_and_detonate(unit, high_value_target.position)
    end

    -- Secondary: Position for maximum disruption
    if squad.objective == "delay" or squad.objective == "disrupt" then
        return position_for_maximum_disruption(unit, situation.player_positions)
    end

    -- Tertiary: Stay with squad until opportunity arises
    return maintain_squad_proximity(unit, squad)
end
```

#### Long Range Behavior

```lua
function long_range_behavior_update(unit, squad, situation)
    -- Primary: Suppress concentrated enemy groups
    local enemy_cluster = find_enemy_cluster(situation.visible_enemies, 3)
    if enemy_cluster then
        return suppress_area(unit, enemy_cluster.position)
    end

    -- Secondary: Cover squad movement
    if squad.is_moving and situation.exposed_approach then
        return provide_covering_fire(unit, squad.movement_path)
    end

    -- Tertiary: Find optimal firing position
    return establish_firing_position(unit, situation.terrain, squad.position)
end
```

#### Assault Behavior

```lua
function assault_behavior_update(unit, squad, situation)
    -- Primary: Close with and destroy immediate threats
    local close_threat = find_closest_threat(situation.visible_enemies, unit.position)
    if close_threat and distance(unit.position, close_threat.position) <= 3 then
        return assault_target(unit, close_threat)
    end

    -- Secondary: Breach defensive positions
    if situation.defensive_position_ahead then
        return breach_position(unit, situation.defensive_position, squad)
    end

    -- Tertiary: Aggressive advance
    return aggressive_advance(unit, situation.objectives, squad)
end
```

#### Heavy Behavior

```lua
function heavy_behavior_update(unit, squad, situation)
    -- Primary: Provide covering fire for squad movement
    if squad.is_advancing and situation.exposed then
        return provide_suppressive_fire(unit, squad.advancement_axis)
    end

    -- Secondary: Hold defensive positions
    if squad.objective == "hold" then
        return maintain_defensive_position(unit, squad.position, situation.threats)
    end

    -- Tertiary: Position as formation anchor
    return anchor_formation(unit, squad, situation.terrain)
end
```

### Action Point Management

```lua
function allocate_action_points(unit, available_ap, situation)
    local allocation = {}

    -- Reserve AP for critical squad needs
    if squad_in_crisis(unit.squad) then
        allocation.squad_support = math.min(available_ap * 0.4, available_ap)
        available_ap = available_ap - allocation.squad_support
    end

    -- Allocate based on unit role
    if unit.type == "assault" then
        allocation.movement = math.min(available_ap * 0.5, available_ap)
        available_ap = available_ap - allocation.movement
        allocation.combat = available_ap
    elseif unit.type == "sniper" then
        allocation.positioning = math.min(available_ap * 0.3, available_ap)
        available_ap = available_ap - allocation.positioning
        allocation.overwatch = available_ap
    end

    return allocation
end
```

### Movement Optimization

```lua
function optimize_movement_path(unit, destination, available_ap)
    local direct_path = calculate_direct_path(unit.position, destination)
    local direct_cost = calculate_path_cost(direct_path, unit.movement_cost)

    if direct_cost <= available_ap then
        return direct_path
    end

    -- Find optimal partial path
    return find_optimal_partial_path(unit.position, destination, available_ap, unit.movement_cost)
end
```

### Weapon Switching Logic

```lua
function should_switch_weapons(unit, current_weapon, target_weapon, available_ap)
    local switch_cost = unit.weapon_switch_ap_cost

    if available_ap < switch_cost then
        return false
    end

    local current_effectiveness = evaluate_weapon_effectiveness(current_weapon, unit.situation)
    local target_effectiveness = evaluate_weapon_effectiveness(target_weapon, unit.situation)

    return target_effectiveness > current_effectiveness * 1.5 -- Significant improvement threshold
end
```

### Armor Management

```lua
function optimize_armor_usage(unit, incoming_threats)
    local armor_strategy = {
        positioning = "standard",
        facing = unit.facing,
        movement = "normal"
    }

    -- Face strongest armor toward primary threat
    if #incoming_threats > 0 then
        local primary_threat = find_primary_threat(incoming_threats)
        armor_strategy.facing = face_toward_threat(unit, primary_threat)
    end

    -- Use cover to supplement armor
    if unit.armor.weaknesses.exposed and nearby_cover_available(unit) then
        armor_strategy.positioning = "seek_cover"
    end

    return armor_strategy
end
```

## Related Wiki Pages

- [Unit AI.md](../ai/Unit%20AI.md) - Individual unit decision-making framework that utilizes behavior types
- [Squad AI.md](../ai/Squad%20AI.md) - Squad-level coordination that incorporates unit behaviors
- [Strategic AI.md](../ai/Strategic%20AI.md) - Mission-level planning that assigns behavioral roles
- [Map Nodes.md](../ai/Map%20Nodes.md) - Navigation system used by behavior positioning
- [Movement.md](../ai/Movement.md) - Pathfinding and positioning used by behavior execution
- [Exploration.md](../ai/Exploration.md) - Intelligence gathering behaviors for scout units
- [Stats.md](../../units/Stats.md) - Unit attributes that influence behavior effectiveness
- [Items.md](../../items/Items.md) - Weapon and equipment systems integrated with behavior management
- [Unit actions.md](../Unit%20actions.md) - Combat actions executed by behavior systems
- [Wounds.md](../Wounds.md) - Injury mechanics that modify behavior patterns

## References to Existing Games and Mechanics

The Unit Behavior Types system draws from established AI patterns in tactical and strategy games:

- **XCOM series (1994-2016)**: Specialized unit classes with distinct tactical roles and AI behaviors
- **Fire Emblem series (1990-2023)**: Class-based behavior systems with weapon triangle interactions
- **Advance Wars series (2001-2018)**: Unit-specific movement ranges and combat behaviors
- **Jagged Alliance series (1994-2014)**: Detailed mercenary behaviors based on personality and training
- **BattleTech (1984-2024)**: Mech-specific combat behaviors and formation tactics
- **Fallout series (1997-2023)**: Companion AI behaviors with varying levels of autonomy and specialization
- **Deus Ex series (2000-2017)**: Stealth and combat behavior specialization for AI companions
- **Mass Effect series (2007-2021)**: Squad-based AI behaviors with positioning and ability usage
- **Divinity: Original Sin series (2014-2018)**: Complex AI behaviors with environmental interactions
- **Pillars of Eternity (2015)**: Class-based tactical behaviors with positioning and ability coordination