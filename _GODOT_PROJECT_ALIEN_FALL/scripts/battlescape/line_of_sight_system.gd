class_name LineOfSightSystem
extends Node

# LineOfSightSystem - Handles line of sight calculations and visibility
# Determines what units can see each other and what areas are visible

var battlescape_map: BattlescapeMap = null

func _init(map: BattlescapeMap):
    battlescape_map = map

func calculate_visibility_from_position(position: Vector2, max_distance: int = 10) -> Array[Vector2]:
    var visible_tiles = []
    
    for x in range(-max_distance, max_distance + 1):
        for y in range(-max_distance, max_distance + 1):
            var check_pos = position + Vector2(x, y)
            
            if check_pos.distance_to(position) > max_distance:
                continue
            
            if battlescape_map.has_line_of_sight(position, check_pos):
                visible_tiles.append(check_pos)
    
    return visible_tiles

func can_see_unit(observer: Unit, target: Unit) -> bool:
    if not observer or not target:
        return false
    
    # Check distance (simplified - in real game would use actual vision range)
    var distance = observer.position.distance_to(target.position)
    if distance > 15:  # Max vision distance
        return false
    
    # Check line of sight
    return battlescape_map.has_line_of_sight(observer.position, target.position)

func get_visible_units_from_position(position: Vector2, max_distance: int = 15) -> Array[Unit]:
    var visible_units = []
    var visible_tiles = calculate_visibility_from_position(position, max_distance)
    
    for unit in battlescape_map.units:
        if visible_tiles.has(unit.position):
            visible_units.append(unit)
    
    return visible_units

func get_visible_enemies(unit: Unit) -> Array[Unit]:
    var visible_units = get_visible_units_from_position(unit.position)
    var enemies = []
    
    for visible_unit in visible_units:
        if visible_unit.race != unit.race:  # Simple faction check
            enemies.append(visible_unit)
    
    return enemies

func get_visible_allies(unit: Unit) -> Array[Unit]:
    var visible_units = get_visible_units_from_position(unit.position)
    var allies = []
    
    for visible_unit in visible_units:
        if visible_unit.race == unit.race and visible_unit != unit:
            allies.append(visible_unit)
    
    return allies

func is_position_visible_from(position: Vector2, target: Vector2) -> bool:
    return battlescape_map.has_line_of_sight(position, target)

func get_concealment_bonus(unit: Unit) -> int:
    # Calculate concealment based on nearby cover
    var cover_bonus = 0
    var position = unit.position
    
    # Check adjacent tiles for cover
    var neighbors = battlescape_map.get_neighbors(int(position.x), int(position.y))
    for neighbor in neighbors:
        cover_bonus = max(cover_bonus, battlescape_map.get_cover_bonus(int(neighbor.x), int(neighbor.y)))
    
    # Check current tile
    cover_bonus = max(cover_bonus, battlescape_map.get_cover_bonus(int(position.x), int(position.y)))
    
    return cover_bonus

func get_elevation_bonus(unit: Unit) -> int:
    # Higher elevation provides better visibility and defense
    var elevation = battlescape_map.get_elevation(int(unit.position.x), int(unit.position.y))
    return elevation * 10  # 10% bonus per elevation level

func get_visibility_modifier(attacker: Unit, target: Unit) -> float:
    # Calculate visibility modifier for combat (0.0 = completely hidden, 1.0 = fully visible)
    if not can_see_unit(attacker, target):
        return 0.0
    
    var distance = attacker.position.distance_to(target.position)
    var max_distance = 15.0
    
    # Distance modifier (closer = more visible)
    var distance_modifier = 1.0 - (distance / max_distance) * 0.3
    
    # Elevation modifier
    var elevation_diff = battlescape_map.get_elevation(int(target.position.x), int(target.position.y)) - battlescape_map.get_elevation(int(attacker.position.x), int(attacker.position.y))
    var elevation_modifier = 1.0 + elevation_diff * 0.1
    
    # Cover modifier
    var cover_modifier = 1.0 - (get_concealment_bonus(target) / 100.0) * 0.5
    
    return clamp(distance_modifier * elevation_modifier * cover_modifier, 0.0, 1.0)

func get_spotting_chance(observer: Unit, target: Unit) -> float:
    # Calculate chance to spot a hidden unit
    var visibility = get_visibility_modifier(observer, target)
    
    # Base spotting chance
    var base_chance = 0.5
    
    # Modify by visibility
    var spotting_chance = base_chance * visibility
    
    # Modify by unit skills (simplified)
    if observer.unit_class == "sniper":
        spotting_chance *= 1.5
    elif observer.unit_class == "scout":
        spotting_chance *= 1.3
    
    return clamp(spotting_chance, 0.0, 1.0)

func update_unit_visibility(unit: Unit):
    # Update what this unit can see
    unit.visible_units = get_visible_units_from_position(unit.position)
    unit.visible_enemies = get_visible_enemies(unit)
    unit.visible_allies = get_visible_allies(unit)

func update_all_visibility():
    # Update visibility for all units
    for unit in battlescape_map.units:
        update_unit_visibility(unit)
