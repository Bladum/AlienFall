class_name TurnManager
extends Node

# TurnManager - Manages turn-based combat flow
# Handles turn order, time units, and combat phases

enum CombatPhase {
    NOT_STARTED,
    PLAYER_TURN,
    ENEMY_TURN,
    RESOLUTION,
    ENDED
}

var current_phase: CombatPhase = CombatPhase.NOT_STARTED
var current_turn: int = 0
var active_unit: Unit = null
var turn_order: Array[Unit] = []
var time_units_remaining: int = 0

signal turn_started(unit: Unit)
signal turn_ended(unit: Unit)
signal phase_changed(new_phase: CombatPhase)
signal combat_ended(winner: String)

func _init():
    print("TurnManager: Initializing turn-based combat system")

func start_combat(units: Array[Unit]):
    print("TurnManager: Starting combat with ", units.size(), " units")
    
    turn_order = units.duplicate()
    _sort_turn_order()
    
    current_turn = 0
    current_phase = CombatPhase.PLAYER_TURN
    active_unit = turn_order[0]
    time_units_remaining = active_unit.stats.tu
    
    emit_signal("phase_changed", current_phase)
    emit_signal("turn_started", active_unit)

func end_turn():
    if active_unit:
        emit_signal("turn_ended", active_unit)
    
    # Move to next unit
    current_turn += 1
    if current_turn >= turn_order.size():
        current_turn = 0
        _next_phase()
    
    active_unit = turn_order[current_turn]
    time_units_remaining = active_unit.stats.tu
    
    emit_signal("turn_started", active_unit)

func _next_phase():
    if current_phase == CombatPhase.PLAYER_TURN:
        current_phase = CombatPhase.ENEMY_TURN
    elif current_phase == CombatPhase.ENEMY_TURN:
        current_phase = CombatPhase.PLAYER_TURN
        _check_victory_conditions()
    
    emit_signal("phase_changed", current_phase)

func _sort_turn_order():
    # Sort by initiative (simplified - could be based on stats)
    turn_order.sort_custom(func(a, b): return a.stats.tu > b.stats.tu)

func spend_time_units(amount: int) -> bool:
    if time_units_remaining >= amount:
        time_units_remaining -= amount
        return true
    return false

func get_remaining_time_units() -> int:
    return time_units_remaining

func is_player_turn() -> bool:
    return current_phase == CombatPhase.PLAYER_TURN and active_unit and active_unit.race == "human"

func is_enemy_turn() -> bool:
    return current_phase == CombatPhase.ENEMY_TURN and active_unit and active_unit.race != "human"

func get_active_unit() -> Unit:
    return active_unit

func get_turn_order() -> Array[Unit]:
    return turn_order.duplicate()

func _check_victory_conditions():
    var human_units = 0
    var alien_units = 0
    
    for unit in turn_order:
        if unit.is_alive:
            if unit.race == "human":
                human_units += 1
            else:
                alien_units += 1
    
    if human_units == 0:
        _end_combat("aliens")
    elif alien_units == 0:
        _end_combat("humans")

func _end_combat(winner: String):
    current_phase = CombatPhase.ENDED
    emit_signal("combat_ended", winner)
    emit_signal("phase_changed", current_phase)
    print("TurnManager: Combat ended, winner: ", winner)

func add_unit_to_combat(unit: Unit):
    if not turn_order.has(unit):
        turn_order.append(unit)
        _sort_turn_order()

func remove_unit_from_combat(unit: Unit):
    if turn_order.has(unit):
        turn_order.erase(unit)
        if active_unit == unit:
            end_turn()

func get_units_by_faction(faction: String) -> Array[Unit]:
    var units = []
    for unit in turn_order:
        if unit.race == faction:
            units.append(unit)
    return units

func get_living_units() -> Array[Unit]:
    var living = []
    for unit in turn_order:
        if unit.is_alive:
            living.append(unit)
    return living

func reset():
    current_phase = CombatPhase.NOT_STARTED
    current_turn = 0
    active_unit = null
    turn_order.clear()
    time_units_remaining = 0
