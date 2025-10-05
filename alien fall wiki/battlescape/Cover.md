# Cover

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Cover Types](#cover-types)
  - [Cover Detection System](#cover-detection-system)
  - [Cover Effectiveness Formula](#cover-effectiveness-formula)
  - [Height-Based Cover](#height-based-cover)
  - [Flanking System](#flanking-system)
  - [Cover Degradation](#cover-degradation)
  - [Line of Sight Interaction](#line-of-sight-interaction)
  - [UI Representation](#ui-representation)
- [Examples](#examples)
  - [Half Cover Defense Bonus](#half-cover-defense-bonus)
  - [Flanking Attack](#flanking-attack)
  - [Height Advantage Shooting](#height-advantage-shooting)
  - [Cover Destruction](#cover-destruction)
  - [Directional Cover Protection](#directional-cover-protection)
  - [Car Explosion Chain Reaction](#car-explosion-chain-reaction)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Cover System provides tactical defensive positioning through environmental obstacles that reduce incoming accuracy and damage in Alien Fall's battlescape combat. Cover creates asymmetric combat dynamics where positioning and flanking become critical tactical decisions, with three distinct cover levels (None 0%, Half 45%, Full 90%), directional protection arcs, height-based modifiers, and destructible cover objects. The system integrates with line of sight, accuracy calculations, and damage resolution to reward tactical positioning while punishing static defense through flanking mechanics and cover degradation from sustained fire.

Cover protection operates directionally within 180-degree arcs from cover sources, with effectiveness determined by shooter-target angles, elevation differences, and unit stance. Height advantages allow elevated shooters to ignore partial cover bonuses, while flanking attacks from 135-225 degree rear arcs completely negate cover benefits. Environmental cover objects maintain health pools subject to damage from weapons fire and explosives, creating dynamic tactical scenarios where cover degrades over combat duration.

## Mechanics

### Cover Types

```lua
COVER_TYPES = {
    none = {
        defense_bonus = 0,
        damage_reduction = 0,
        icon = "none"
    },
    
    half = {
        defense_bonus = 45,        -- +45% miss chance
        damage_reduction = 0.15,   -- 15% damage reduction
        icon = "shield_half",
        examples = {"low walls", "crates", "car doors", "sandbags"}
    },
    
    full = {
        defense_bonus = 90,        -- +90% miss chance
        damage_reduction = 0.30,   -- 30% damage reduction
        icon = "shield_full",
        examples = {"high walls", "thick pillars", "vehicles", "buildings"}
    }
}
```

### Environmental Cover Sources

| Object Type | Cover Level | HP | Special Properties |
|------------|-------------|-----|-------------------|
| Low Wall | Half | 100 | Destructible |
| High Wall | Full | 250 | Destructible, blocks LOS |
| Sandbag | Half | 80 | Explosive-resistant (×0.5 damage) |
| Concrete Barrier | Full | 300 | Explosive-resistant (×0.5 damage) |
| Wooden Crate | Half | 50 | Flammable |
| Metal Crate | Full | 150 | Blocks LOS |
| Car | Half/Full | 200 | Can explode (HP < 50) |
| Tree | Half | 120 | Flammable |
| Rock | Full | 500 | Indestructible |
| Building Corner | Full | 400 | Permanent structure |
| Window Frame | Half | 60 | Can peek through |

---

### Cover Detection System

```lua
-- Determine cover for a unit at a position
function get_cover_from_direction(unit_pos, shooter_pos, map)
    -- Calculate angle from shooter to unit
    local angle = calculate_angle(shooter_pos, unit_pos)
    
    -- Check adjacent tiles for cover objects
    local cover_sources = get_adjacent_cover_objects(unit_pos, map)
    
    for _, cover_obj in ipairs(cover_sources) do
        -- Check if cover is between shooter and unit
        local cover_angle = calculate_angle(unit_pos, cover_obj.position)
        local angle_diff = math.abs(normalize_angle(cover_angle - angle))
        
        -- Cover protects in 180° arc from source
        if angle_diff <= 90 then
            return cover_obj.cover_type
        end
    end
    
    return COVER_TYPES.none
end
```

### Cover Effectiveness Formula

```lua
-- Calculate total defensive bonus from cover
function calculate_cover_defense(attacker_pos, target_pos, target_unit, map)
    local base_cover = get_cover_from_direction(target_pos, attacker_pos, map)
    
    -- Base defense bonus
    local defense = base_cover.defense_bonus
    
    -- Height modifier (see height-based cover section)
    local height_mod = calculate_height_modifier(attacker_pos, target_pos, map)
    defense = defense + height_mod
    
    -- Stance modifier
    if target_unit.stance == "crouch" then
        defense = defense + 15  -- +15% when crouching
    elseif target_unit.stance == "prone" then
        defense = defense + 30  -- +30% when prone
    end
    
    -- Cover skill bonus (from unit stats)
    local cover_skill = target_unit.stats.cover or 0
    defense = defense + cover_skill
    
    -- Cap at 95% (always 5% hit chance minimum)
    return math.min(95, defense)
end
```

### Damage Reduction from Cover

```lua
-- Apply cover damage reduction
function apply_cover_damage_reduction(raw_damage, cover_type)
    if cover_type == COVER_TYPES.none then
        return raw_damage
    end
    
    local reduction = cover_type.damage_reduction
    local final_damage = raw_damage * (1.0 - reduction)
    
    return math.max(1, math.floor(final_damage))  -- Minimum 1 damage
end

-- Example: 20 damage vs full cover
-- 20 × (1.0 - 0.30) = 14 damage (30% reduction)
```

---

### Height-Based Cover

### Elevation System

```lua
-- Height levels (in tiles)
HEIGHT_LEVELS = {
    ground = 0,
    elevated_1 = 1,  -- Roof, platform (+1 tile)
    elevated_2 = 2,  -- Second floor (+2 tiles)
    elevated_3 = 3   -- Third floor (+3 tiles)
}
```

### Height Advantage Mechanics

#### Shooting Down (High Ground)

```lua
function calculate_height_advantage(shooter_height, target_height)
    local height_diff = shooter_height - target_height
    
    if height_diff > 0 then
        -- Shooter is higher: accuracy bonus, ignores some cover
        local accuracy_bonus = height_diff × 10  -- +10% per level
        local cover_reduction = height_diff × 15 -- Reduces target cover by 15% per level
        
        return {
            accuracy = accuracy_bonus,
            cover_pierce = cover_reduction
        }
    elseif height_diff < 0 then
        -- Shooter is lower: accuracy penalty
        local accuracy_penalty = math.abs(height_diff) × 5  -- -5% per level
        
        return {
            accuracy = -accuracy_penalty,
            cover_pierce = 0
        }
    else
        -- Same height: no modifier
        return {accuracy = 0, cover_pierce = 0}
    end
end
```

#### Height and Cover Interaction

```lua
function calculate_effective_cover(base_cover, height_advantage)
    -- Height advantage reduces effective cover
    local effective_cover = base_cover.defense_bonus - height_advantage.cover_pierce
    
    -- Example: Target in full cover (90%), shooter 2 levels higher
    -- cover_pierce = 2 × 15 = 30
    -- effective_cover = 90 - 30 = 60% (reduced to half cover equivalent)
    
    return math.max(0, effective_cover)
end
```

### Low Cover vs Height

When shooting at a target behind low cover from an elevated position:

| Height Difference | Half Cover (45%) | Full Cover (90%) |
|------------------|------------------|------------------|
| Same Level (0) | 45% defense | 90% defense |
| +1 Level | 30% defense (-15) | 75% defense (-15) |
| +2 Levels | 15% defense (-30) | 60% defense (-30) |
| +3 Levels | 0% defense (exposed) | 45% defense (-45) |

**Tactical Implication**: High ground drastically reduces cover effectiveness, making elevation control critical.

---

### Flanking System

### Flanking Zones

```lua
-- Flanking angle definition: 135-225° behind target
FLANK_ANGLE_MIN = 135  -- degrees
FLANK_ANGLE_MAX = 225  -- degrees

function is_flanking(attacker_pos, target_pos, target_facing)
    -- Calculate angle from target to attacker
    local angle_to_attacker = calculate_angle(target_pos, attacker_pos)
    
    -- Calculate relative angle to target's facing
    local relative_angle = normalize_angle(angle_to_attacker - target_facing)
    
    -- Check if in flanking zone (135-225° = 90° arc behind)
    return relative_angle >= FLANK_ANGLE_MIN and relative_angle <= FLANK_ANGLE_MAX
end
```

### Flanking Effects

#### Complete Flank (Behind Target)

```lua
function apply_flanking_bonus(attacker, target, is_flanked)
    if not is_flanked then
        return {accuracy = 0, crit = 0, cover_ignore = false}
    end
    
    return {
        accuracy = 30,        -- +30% accuracy
        crit_chance = 15,     -- +15% critical hit chance
        cover_ignore = true   -- Ignore all cover bonuses
    }
end
```

#### Partial Flank (Side Angle)

Units 45-135° or 225-315° to target facing get partial flank:

```lua
function is_partial_flank(relative_angle)
    -- Side angles: 45-135° (right) or 225-315° (left)
    return (relative_angle >= 45 and relative_angle < 135) or
           (relative_angle >= 225 and relative_angle < 315)
end

function apply_partial_flank_bonus()
    return {
        accuracy = 15,        -- +15% accuracy
        crit_chance = 5,      -- +5% critical chance
        cover_ignore = false  -- Cover still applies
    }
end
```

### Facing System

```lua
-- Unit facing (8 directions)
FACING_DIRECTIONS = {
    north = 0,
    northeast = 45,
    east = 90,
    southeast = 135,
    south = 180,
    southwest = 225,
    west = 270,
    northwest = 315
}

-- Update facing when unit acts
function update_unit_facing(unit, target_pos)
    local angle = calculate_angle(unit.position, target_pos)
    unit.facing = snap_to_cardinal(angle)  -- Snap to nearest 45° direction
end
```

### Flanking Visualization

```
        0° (North)
         ↑
    315° | 45°
  270° ←-+-→ 90°
    225° | 135°
         ↓
       180° (South)

FULL FLANK ZONE: 135-225° (shaded)
- Ignores all cover
- +30% accuracy
- +15% crit chance

PARTIAL FLANK ZONES: 45-135° and 225-315°
- Cover applies
- +15% accuracy
- +5% crit chance

FRONTAL ARC: 315-45°
- Full cover applies
- No bonuses
```

---

### Cover Degradation

### Cover Hit Points

Each cover object has HP that degrades from damage:

```lua
cover_object = {
    type = "sandbag",
    cover_level = COVER_TYPES.half,
    max_hp = 80,
    current_hp = 80,
    position = {x = 10, y = 15},
    explosive_resistance = 0.5  -- Takes 50% explosive damage
}
```

### Damage to Cover

```lua
-- Apply damage to cover
function damage_cover(cover_obj, damage, damage_type)
    local final_damage = damage
    
    -- Apply resistances
    if damage_type == "explosive" and cover_obj.explosive_resistance then
        final_damage = damage * (1.0 - cover_obj.explosive_resistance)
    end
    
    -- Apply damage
    cover_obj.current_hp = cover_obj.current_hp - final_damage
    
    -- Check destruction
    if cover_obj.current_hp <= 0 then
        destroy_cover(cover_obj)
    elseif cover_obj.current_hp < cover_obj.max_hp * 0.5 then
        -- Damaged cover: reduce effectiveness
        degrade_cover_level(cover_obj)
    end
end
```

### Cover Degradation Stages

| HP Remaining | Cover Status | Defense Bonus | Visual |
|--------------|--------------|---------------|--------|
| 100-75% | Intact | Full effect | Pristine |
| 74-50% | Damaged | -10% defense | Chipped/cracked |
| 49-25% | Heavily Damaged | -25% defense | Broken sections |
| 24-1% | Nearly Destroyed | -40% defense | Barely standing |
| 0% | Destroyed | No cover | Debris/rubble |

### Explosive Cover Destruction

```lua
-- Explosives are highly effective against cover
function apply_explosive_to_cover(cover_objects, explosion_center, explosion_radius, damage)
    for _, cover_obj in ipairs(cover_objects) do
        local distance = calculate_distance(cover_obj.position, explosion_center)
        
        if distance <= explosion_radius then
            -- Damage falloff with distance
            local distance_ratio = 1.0 - (distance / explosion_radius)
            local cover_damage = damage * distance_ratio
            
            damage_cover(cover_obj, cover_damage, "explosive")
        end
    end
end

-- Example: Grenade (damage 50, radius 3) vs sandbag (HP 80, resistance 0.5)
-- Distance 1 tile: damage_ratio = 0.67, final = 50 × 0.67 × 0.5 = 16.75 damage
-- Sandbag survives: 80 - 16.75 = 63.25 HP (damaged state)
```

### Sustained Fire Degradation

```lua
-- Cover degrades from repeated hits
function on_shot_hit_cover(cover_obj, weapon_damage)
    -- Cover takes reduced damage from bullets
    local cover_damage = weapon_damage * 0.2  -- 20% of weapon damage
    
    damage_cover(cover_obj, cover_damage, "kinetic")
end

-- Example: Rifle (20 damage) hits cover 5 times
-- 20 × 0.2 = 4 damage per hit
-- 5 hits = 20 total damage
-- Sandbag HP: 80 - 20 = 60 HP (still functional)
```

---

### Line of Sight Interaction

### Full Cover and LOS Blocking

```lua
-- Full cover blocks line of sight
function blocks_line_of_sight(cover_type, shooter_height, target_height)
    if cover_type ~= COVER_TYPES.full then
        return false
    end
    
    -- Full cover blocks LOS if shooter and target at same height
    if shooter_height == target_height then
        return true
    end
    
    -- Height advantage allows shooting over full cover
    local height_diff = math.abs(shooter_height - target_height)
    if height_diff >= 1 then
        return false  -- Can see over cover
    end
    
    return true
end
```

### Peek Mechanics

```lua
-- Peek over/around cover to shoot
function peek_shot(unit, cover_obj, target_pos)
    -- Peek costs 1 AP
    if unit.action_points < 1 then
        return false, "Insufficient AP"
    end
    
    unit.action_points = unit.action_points - 1
    unit.is_peeking = true
    
    -- Peeking grants shot opportunity but exposes unit
    -- Next enemy shot against peeking unit: cover reduced by 50%
    
    return true
end

function calculate_peek_penalty(unit)
    if unit.is_peeking then
        return 0.5  -- Cover effectiveness reduced by 50%
    end
    return 1.0
end
```

### Window/Doorway Cover

```lua
-- Special cover: can shoot through but blocks movement
window_cover = {
    type = "window",
    cover_level = COVER_TYPES.half,
    blocks_movement = false,
    blocks_los = false,  -- Can see/shoot through
    fragile = true,      -- Easily destroyed
    max_hp = 30
}
```

---

### UI Representation

#### Cover System Module

```lua
-- Cover system manager
CoverSystem = {}

function CoverSystem:init(map)
    self.map = map
    self.cover_objects = {}
    
    -- Initialize cover from map objects
    self:scan_map_for_cover()
end

-- Scan map for cover-providing objects
function CoverSystem:scan_map_for_cover()
    for y = 1, self.map.height do
        for x = 1, self.map.width do
            local tile = self.map:get_tile(x, y)
            
            if tile.object and tile.object.provides_cover then
                table.insert(self.cover_objects, {
                    position = {x = x, y = y},
                    object = tile.object,
                    cover_level = tile.object.cover_type,
                    hp = tile.object.max_hp
                })
            end
        end
    end
end

-- Get cover for a unit against an attacker
function CoverSystem:get_cover(unit_pos, attacker_pos)
    local cover = get_cover_from_direction(unit_pos, attacker_pos, self.map)
    
    -- Check for height advantages
    local unit_height = self.map:get_height(unit_pos.x, unit_pos.y)
    local attacker_height = self.map:get_height(attacker_pos.x, attacker_pos.y)
    local height_advantage = calculate_height_advantage(attacker_height, unit_height)
    
    -- Adjust cover for height
    local effective_defense = calculate_effective_cover(cover, height_advantage)
    
    return {
        type = cover,
        defense = effective_defense,
        height_modifier = height_advantage
    }
end

-- Check if shot is flanking
function CoverSystem:is_flanking_shot(attacker_pos, target)
    return is_flanking(attacker_pos, target.position, target.facing)
end

-- Apply damage to cover
function CoverSystem:damage_cover_at(position, damage, damage_type)
    local cover_obj = self:get_cover_at(position)
    if cover_obj then
        damage_cover(cover_obj, damage, damage_type)
    end
end

return CoverSystem
```

### UI Visualization

```lua
-- Draw cover indicators
function draw_cover_indicators(unit, map)
    -- Get unit's current cover from all directions
    local cover_by_direction = {}
    
    for angle = 0, 315, 45 do
        local test_pos = calculate_position_at_angle(unit.position, angle, 10)
        local cover = CoverSystem:get_cover(unit.position, test_pos)
        cover_by_direction[angle] = cover
    end
    
    -- Draw shield icons around unit
    for angle, cover in pairs(cover_by_direction) do
        if cover.type ~= COVER_TYPES.none then
            local icon_pos = calculate_position_at_angle(unit.position, angle, 1)
            draw_cover_icon(icon_pos, cover.type.icon, cover.defense)
        end
    end
end

-- Draw cover icon
function draw_cover_icon(position, icon_type, defense_value)
    local screen_x, screen_y = world_to_screen(position.x, position.y)
    
    -- Draw shield sprite
    love.graphics.draw(cover_icons[icon_type], screen_x, screen_y)
    
    -- Draw defense percentage
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(defense_value .. "%", screen_x + 5, screen_y - 10)
end
```

---

## Examples

### Half Cover Defense Bonus

A soldier crouches behind a low wall (+45% defense, +15% crouch bonus) facing an alien shooter. The alien's base 75% accuracy reduces to 15% chance to hit (75% - 45% - 15% = 15%). The soldier returns fire from cover with no penalty. If hit, the shot deals 20 damage reduced by 15% cover damage reduction to 17 damage.

### Flanking Attack

An alien takes cover behind a crate facing north (180° protection arc). A player soldier maneuvers to attack from the southeast (135° angle). The flanking position completely negates the alien's cover bonus, converting defensive advantage to vulnerability. The attack proceeds with full accuracy and damage.

### Height Advantage Shooting

A sniper on a second-floor rooftop (+2 elevation) targets an alien behind half cover at ground level. The height advantage provides +20% accuracy bonus and reduces the alien's cover defense by 30% (2 levels × 15%), converting effective half cover (45%) to minimal cover (15%). The elevated position creates tactical superiority.

### Cover Destruction

A concrete barrier (300 HP, full cover) provides defensive position for two soldiers. Enemy explosives deal 150 damage, reducing barrier HP to 150. Subsequent machinegun fire (80 damage) destroys the barrier completely, eliminating cover protection and forcing tactical repositioning.

### Directional Cover Protection

A soldier takes cover behind a wall facing east (protection arc 90° to 270°). An attacker approaching from the north (90° angle) gains full cover protection. An attacker approaching from the west (270° angle) also receives protection. An attacker from the south (180° angle, directly behind) achieves flanking status, negating all cover benefits.

### Car Explosion Chain Reaction

A soldier uses a damaged car (100 HP remaining) as half cover. Enemy incendiary grenade deals 60 damage to the car, reducing HP below 50 and triggering explosion. The car explodes for 80 damage in 3-tile radius, damaging both the soldier using it as cover and nearby units, demonstrating cover object hazards.

## Related Wiki Pages

- [Combat.md](battlescape/README.md) - Combat mechanics and accuracy calculations
- [Stats.md](units/Stats.md) - Unit statistics affecting cover effectiveness
- [Damage Types.md](items/Damage_types.md) - Damage types and cover interactions
- [Battlescape.md](battlescape/README.md) - Tactical combat overview
- [Map Generation.md](procedure/README.md) - Cover object placement in maps
- [Line of Sight.md](battlescape/README.md) - LOS mechanics and cover blocking

## References to Existing Games and Mechanics

- **XCOM Series**: Half/full cover system with directional protection
- **XCOM 2**: Flanking mechanics and cover destruction
- **Phoenix Point**: Height advantage and cover penetration
- **Jagged Alliance 2**: Stance-based cover bonuses
- **Wasteland 3**: Cover degradation from sustained fire
- **Gears of War**: Cover-based combat positioning
- **Rainbow Six Siege**: Destructible cover environments
- **Valkyria Chronicles**: Height-based tactical advantages
- **Into the Breach**: Clear cover indicators and tactical visualization
- **Invisible Inc**: Directional cover arcs and flanking
