class_name CombatSystem
extends Node

# CombatSystem - Handles combat calculations and resolution
# Manages attacks, damage, hit chances, and combat outcomes

var rng_service = RNGService
var line_of_sight_system: LineOfSightSystem = null
var destructible_terrain_system: DestructibleTerrain = null

signal attack_resolved(attacker: Unit, target: Unit, hit: bool, damage: int, critical: bool)
signal unit_damaged(unit: Unit, damage: int, new_health: int)
signal unit_killed(unit: Unit, killer: Unit)

func _init(los_system: LineOfSightSystem, terrain_system: DestructibleTerrain = null):
    line_of_sight_system = los_system
    destructible_terrain_system = terrain_system

func calculate_hit_chance(attacker: Unit, target: Unit, weapon_accuracy: int = 60) -> float:
    if not attacker or not target:
        return 0.0

    # Base accuracy
    var hit_chance = weapon_accuracy / 100.0

    # Distance modifier
    var distance = attacker.position.distance_to(target.position)
    if distance > 10:
        hit_chance *= 0.5  # Long range penalty
    elif distance <= 2:
        hit_chance *= 1.2  # Close range bonus

    # Visibility modifier
    var visibility = line_of_sight_system.get_visibility_modifier(attacker, target)
    hit_chance *= visibility

    # Cover modifier
    var cover_bonus = line_of_sight_system.get_concealment_bonus(target)
    hit_chance *= (1.0 - cover_bonus / 100.0)

    # Elevation modifier
    var elevation_diff = line_of_sight_system.get_elevation_bonus(target) - line_of_sight_system.get_elevation_bonus(attacker)
    hit_chance *= (1.0 + elevation_diff / 100.0)

    # Unit skill modifiers
    if attacker.unit_class == "sniper":
        hit_chance *= 1.3
    elif attacker.unit_class == "assault":
        hit_chance *= 0.9

    if target.unit_class == "sniper":
        hit_chance *= 0.8  # Harder to hit snipers

    return clamp(hit_chance, 0.0, 1.0)

# Enhanced hit chance calculation with weapon and mode
func calculate_hit_chance_enhanced(attacker: Unit, target: Unit, weapon, weapon_mode) -> float:
    if not weapon or not weapon.has_method("get_accuracy_for_mode"):
        return calculate_hit_chance(attacker, target, 60)

    var base_accuracy = weapon.get_accuracy_for_mode(weapon_mode)
    var hit_chance = calculate_hit_chance(attacker, target, base_accuracy)

    # Weapon-specific modifiers
    if weapon.damage_type == weapon.DamageType.PLASMA:
        hit_chance *= 0.9  # Plasma weapons slightly less accurate
    elif weapon.damage_type == weapon.DamageType.LASER:
        hit_chance *= 1.1  # Laser weapons more accurate

    return clamp(hit_chance, 0.0, 1.0)
    
    return clamp(hit_chance, 0.0, 1.0)

func calculate_damage(attacker: Unit, target: Unit, weapon_damage: int = 25) -> int:
    var base_damage = weapon_damage

    # Armor reduction (simplified)
    var armor_reduction = 0
    if target.inventory_slots[0].item:  # Armor slot
        armor_reduction = target.inventory_slots[0].item.armor_rating

    var damage = max(1, base_damage - armor_reduction)

    # Critical hit chance
    var crit_chance = 0.05  # 5% base crit chance
    if attacker.unit_class == "sniper":
        crit_chance *= 2.0

    if rng_service.randf() < crit_chance:
        damage *= 2  # Critical hit doubles damage

    return damage

# Enhanced damage calculation with weapon and damage types
func calculate_damage_enhanced(attacker: Unit, target: Unit, weapon, weapon_mode) -> int:
    if not weapon or not weapon.has_method("get_damage_for_mode"):
        return calculate_damage(attacker, target, 25)

    var base_damage = weapon.get_damage_for_mode(weapon_mode)

    # Get target's armor and damage reduction
    var armor_reduction = 0
    var damage_reduction = 0

    # Check if target has inventory manager
    if target.has_node("InventoryManager"):
        var inventory = target.get_node("InventoryManager")
        armor_reduction = inventory.get_total_armor_rating()
        damage_reduction = inventory.get_damage_reduction(weapon.damage_type)

    # Apply damage reduction
    var final_damage = base_damage - armor_reduction
    final_damage = final_damage * (1.0 - damage_reduction / 100.0)
    final_damage = max(1, int(final_damage))

    # Critical hit chance (enhanced)
    var crit_chance = 0.05  # 5% base crit chance

    # Weapon-specific crit modifiers
    if weapon_mode == weapon.WeaponMode.AIMED:
        crit_chance *= 1.5  # Aimed shots have higher crit chance
    elif weapon_mode == weapon.WeaponMode.BURST:
        crit_chance *= 0.8   # Burst fire lower crit chance

    # Unit class modifiers
    if attacker.unit_class == "sniper":
        crit_chance *= 2.0
    elif attacker.unit_class == "heavy":
        crit_chance *= 0.5  # Heavy weapons less likely to crit

    if rng_service.randf() < crit_chance:
        final_damage *= 2  # Critical hit doubles damage

    return final_damage

# Enhanced attack resolution with weapon and mode
func perform_attack_enhanced(attacker: Unit, target: Unit, weapon, weapon_mode) -> Dictionary:
    var result = {
        "hit": false,
        "damage": 0,
        "critical": false,
        "message": "",
        "weapon_mode": weapon_mode,
        "damage_type": weapon.damage_type if weapon else 0
    }

    # Check ammo
    if weapon and weapon.current_ammo <= 0:
        result.message = "Out of ammo!"
        emit_signal("attack_resolved", attacker, target, false, 0, false)
        return result

    # Check if attack is possible
    if not line_of_sight_system.can_see_unit(attacker, target):
        result.message = "No line of sight to target"
        emit_signal("attack_resolved", attacker, target, false, 0, false)
        return result

    # Calculate hit chance
    var hit_chance = calculate_hit_chance_enhanced(attacker, target, weapon, weapon_mode)
    var hit_roll = rng_service.randf()

    if hit_roll <= hit_chance:
        # Hit!
        result.hit = true
        result.damage = calculate_damage_enhanced(attacker, target, weapon, weapon_mode)

        # Apply damage
        target.stats.health -= result.damage
        emit_signal("unit_damaged", target, result.damage, target.stats.health)

        # Apply terrain damage if system is available
        if destructible_terrain_system:
            var target_pos = target.position
            var damage_type = DestructibleTerrain.DamageType.BULLET

            # Check if weapon causes explosions
            if weapon and weapon.weapon_type == "explosive":
                damage_type = DestructibleTerrain.DamageType.EXPLOSION
                # Apply explosion damage to surrounding tiles
                destructible_terrain_system.apply_explosion_damage(target_pos, weapon.explosion_radius if weapon.has("explosion_radius") else 2, result.damage)
            else:
                # Apply bullet damage to target tile
                destructible_terrain_system.apply_damage(target_pos, result.damage, damage_type)

        # Consume ammo
        if weapon:
            weapon.current_ammo -= 1

        # Check if unit died
        if target.stats.health <= 0:
            target.is_alive = false
            emit_signal("unit_killed", target, attacker)
            result.message = "Target killed!"
        else:
            result.message = "Hit for " + str(result.damage) + " damage"

        if result.critical:
            result.message += " (Critical!)"
    else:
        # Miss
        result.message = "Attack missed"

    emit_signal("attack_resolved", attacker, target, result.hit, result.damage, result.critical)
    return result

func perform_attack(attacker: Unit, target: Unit, weapon_accuracy: int = 60, weapon_damage: int = 25) -> Dictionary:
    var result = {
        "hit": false,
        "damage": 0,
        "critical": false,
        "message": ""
    }
    
    # Check if attack is possible
    if not line_of_sight_system.can_see_unit(attacker, target):
        result.message = "No line of sight to target"
        emit_signal("attack_resolved", attacker, target, false, 0, false)
        return result
    
    # Calculate hit chance
    var hit_chance = calculate_hit_chance(attacker, target, weapon_accuracy)
    var hit_roll = rng_service.randf()
    
    if hit_roll <= hit_chance:
        # Hit!
        result.hit = true
        result.damage = calculate_damage(attacker, target, weapon_damage)
        
        # Check for critical
        var crit_chance = 0.05
        if attacker.unit_class == "sniper":
            crit_chance *= 2.0
        
        if rng_service.randf() < crit_chance:
            result.critical = true
            result.damage *= 2
        
        # Apply damage
        target.stats.health -= result.damage
        emit_signal("unit_damaged", target, result.damage, target.stats.health)

        # Apply terrain damage if system is available
        if destructible_terrain_system:
            var target_pos = target.position
            var damage_type = DestructibleTerrain.DamageType.BULLET

            # Apply bullet damage to target tile
            destructible_terrain_system.apply_damage(target_pos, result.damage, damage_type)
        
        # Check if unit died
        if target.stats.health <= 0:
            target.is_alive = false
            emit_signal("unit_killed", target, attacker)
            result.message = "Target killed!"
        else:
            result.message = "Hit for " + str(result.damage) + " damage"
            
        if result.critical:
            result.message += " (Critical!)"
    else:
        # Miss
        result.message = "Attack missed"
    
    emit_signal("attack_resolved", attacker, target, result.hit, result.damage, result.critical)
    return result

func calculate_movement_cost(from_pos: Vector2, to_pos: Vector2, unit: Unit) -> int:
    var distance = from_pos.distance_to(to_pos)
    
    # Base cost is distance (simplified)
    var cost = int(distance)
    
    # Terrain modifiers
    var to_tile = line_of_sight_system.battlescape_map.get_tile(int(to_pos.x), int(to_pos.y))
    if to_tile.terrain == "wall":
        cost *= 2  # Rough terrain
    elif to_tile.terrain == "crate":
        cost += 1  # Slight penalty
    
    # Elevation change
    var from_elevation = line_of_sight_system.battlescape_map.get_elevation(int(from_pos.x), int(from_pos.y))
    var to_elevation = line_of_sight_system.battlescape_map.get_elevation(int(to_pos.x), int(to_pos.y))
    var elevation_diff = abs(to_elevation - from_elevation)
    cost += elevation_diff * 2  # Elevation changes cost extra TU
    
    return cost

func can_unit_move(unit: Unit, from_pos: Vector2, to_pos: Vector2) -> bool:
    # Check if unit has enough TU
    var cost = calculate_movement_cost(from_pos, to_pos, unit)
    return unit.stats.tu >= cost

func perform_movement(unit: Unit, path: Array[Vector2]) -> bool:
    if path.size() < 2:
        return false
    
    var total_cost = 0
    var current_pos = unit.position
    
    # Calculate total movement cost
    for i in range(1, path.size()):
        total_cost += calculate_movement_cost(path[i-1], path[i], unit)
    
    if total_cost > unit.stats.tu:
        return false
    
    # Move unit along path
    unit.position = path[-1]
    unit.stats.tu -= total_cost
    
    return true

func get_attack_options(unit: Unit) -> Array[Unit]:
    # Return list of valid targets
    return line_of_sight_system.get_visible_enemies(unit)

func get_movement_options(unit: Unit, max_distance: int = 5) -> Array[Vector2]:
    # Return list of reachable positions
    var options = []
    var start_pos = unit.position
    
    for x in range(-max_distance, max_distance + 1):
        for y in range(-max_distance, max_distance + 1):
            var check_pos = start_pos + Vector2(x, y)
            
            if check_pos.distance_to(start_pos) > max_distance:
                continue
            
            if line_of_sight_system.battlescape_map.is_walkable(int(check_pos.x), int(check_pos.y)):
                if not line_of_sight_system.battlescape_map.get_unit_at_position(check_pos):
                    options.append(check_pos)
    
    return options

func get_optimal_firing_position(unit: Unit, target: Unit) -> Vector2:
    # Find best position to attack from
    var current_pos = unit.position
    var best_pos = current_pos
    var best_score = 0
    
    var options = get_movement_options(unit, 3)  # Check within 3 tiles
    
    for pos in options:
        var distance = pos.distance_to(target.position)
        var has_los = line_of_sight_system.is_position_visible_from(pos, target.position)
        var cover = line_of_sight_system.battlescape_map.get_cover_bonus(int(pos.x), int(pos.y))
        
        if has_los:
            var score = (10 - distance) + cover  # Closer and more cover is better
            if score > best_score:
                best_score = score
                best_pos = pos
    
    return best_pos

func simulate_combat(attacker: Unit, target: Unit, simulations: int = 100) -> Dictionary:
    # Run multiple combat simulations to predict outcomes
    var results = {
        "average_damage": 0.0,
        "hit_chance": 0.0,
        "kill_chance": 0.0,
        "simulations": simulations
    }
    
    var total_damage = 0
    var hits = 0
    var kills = 0
    
    for i in range(simulations):
        var combat_result = perform_attack(attacker, target, 60, 25)
        total_damage += combat_result.damage
        
        if combat_result.hit:
            hits += 1
            
            # Check if this would kill the target
            var simulated_health = target.stats.health - combat_result.damage
            if simulated_health <= 0:
                kills += 1
    
    results.average_damage = total_damage / float(simulations)
    results.hit_chance = hits / float(simulations)
    results.kill_chance = kills / float(simulations)
    
    return results
