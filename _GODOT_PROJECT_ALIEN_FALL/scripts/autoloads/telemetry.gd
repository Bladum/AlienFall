extends Node

# Telemetry - Records game events for debugging, replay, and analysis
# Part of Phase 12: Telemetry and provenance logging

class_name Telemetry

# Telemetry data storage
var _events: Array = []
var _session_start_time: int = 0
var _session_id: String = ""
var _enabled: bool = true

# Event types
enum EventType {
    GAME_START,
    GAME_END,
    SCENE_CHANGE,
    RNG_SEED_SET,
    RNG_CALL,
    BATTLE_START,
    BATTLE_END,
    UNIT_ACTION,
    SAVE_GAME,
    LOAD_GAME,
    MOD_LOADED,
    ERROR_OCCURRED,
    PERFORMANCE_METRIC,
    CUSTOM_EVENT
}

func _ready():
    """Initialize telemetry system"""
    _session_start_time = Time.get_unix_time_from_system()
    _session_id = _generate_session_id()
    _log_event(EventType.GAME_START, "Telemetry system initialized", {
        "session_id": _session_id,
        "godot_version": Engine.get_version_info().string,
        "platform": OS.get_name()
    })

func _generate_session_id() -> String:
    """Generate a unique session ID"""
    var timestamp = str(_session_start_time)
    var random_part = str(randi() % 1000000).pad_zeros(6)
    return "session_" + timestamp + "_" + random_part

func set_enabled(enabled: bool):
    """Enable or disable telemetry recording"""
    _enabled = enabled
    _log_event(EventType.CUSTOM_EVENT, "Telemetry " + ("enabled" if enabled else "disabled"))

func is_enabled() -> bool:
    """Check if telemetry is enabled"""
    return _enabled

func log_event(event_type: EventType, description: String, data: Dictionary = {}):
    """Log a telemetry event"""
    _log_event(event_type, description, data)

func _log_event(event_type: EventType, description: String, data: Dictionary = {}):
    """Internal method to log an event"""
    if not _enabled:
        return

    var event = {
        "timestamp": Time.get_unix_time_from_system(),
        "session_id": _session_id,
        "event_type": event_type,
        "description": description,
        "data": data.duplicate(true),  # Deep copy to prevent reference issues
        "frame": Engine.get_frames_drawn(),
        "memory_usage": OS.get_static_memory_usage()
    }

    _events.append(event)

    # Optional: Print to console for debugging
    if OS.is_debug_build():
        print("[TELEMETRY] ", _event_type_to_string(event_type), ": ", description)

func log_rng_call(context: String, seed: int, result: Variant = null):
    """Log an RNG call with provenance"""
    var data = {
        "context": context,
        "seed": seed,
        "result": str(result) if result != null else "null"
    }
    _log_event(EventType.RNG_CALL, "RNG call: " + context, data)

func log_scene_change(from_scene: String, to_scene: String):
    """Log scene transitions"""
    var data = {
        "from_scene": from_scene,
        "to_scene": to_scene
    }
    _log_event(EventType.SCENE_CHANGE, "Scene change: " + from_scene + " -> " + to_scene, data)

func log_battle_start(battle_id: String, seed: int, terrain: String):
    """Log battle start with provenance"""
    var data = {
        "battle_id": battle_id,
        "seed": seed,
        "terrain": terrain,
        "rng_provenance": _get_rng_provenance()
    }
    _log_event(EventType.BATTLE_START, "Battle started: " + battle_id, data)

func log_battle_end(battle_id: String, outcome: String, duration: float):
    """Log battle end with results"""
    var data = {
        "battle_id": battle_id,
        "outcome": outcome,
        "duration_seconds": duration,
        "total_turns": _get_current_turn_count()
    }
    _log_event(EventType.BATTLE_END, "Battle ended: " + battle_id + " (" + outcome + ")", data)

func log_unit_action(unit_id: String, action: String, target: Variant = null):
    """Log unit actions for replay analysis"""
    var data = {
        "unit_id": unit_id,
        "action": action,
        "target": str(target) if target != null else "null",
        "turn": _get_current_turn_count()
    }
    _log_event(EventType.UNIT_ACTION, "Unit action: " + unit_id + " " + action, data)

func log_error(error_message: String, context: String = ""):
    """Log errors for debugging"""
    var data = {
        "error_message": error_message,
        "context": context,
        "stack_trace": get_stack()
    }
    _log_event(EventType.ERROR_OCCURRED, "Error: " + error_message, data)

func log_performance_metric(metric_name: String, value: float, unit: String = ""):
    """Log performance metrics"""
    var data = {
        "metric_name": metric_name,
        "value": value,
        "unit": unit
    }
    _log_event(EventType.PERFORMANCE_METRIC, "Performance: " + metric_name + " = " + str(value) + unit, data)

func _get_rng_provenance() -> Dictionary:
    """Get current RNG provenance data"""
    if Engine.has_singleton("RNGService"):
        var rng_service = Engine.get_singleton("RNGService")
        if rng_service and rng_service.has_method("get_provenance_data"):
            return rng_service.get_provenance_data()
    return {}

func _get_current_turn_count() -> int:
    """Get current turn count (placeholder - would integrate with game state)"""
    # This would be replaced with actual game state integration
    return 0

func get_events(event_type_filter: EventType = -1, limit: int = -1) -> Array:
    """Get telemetry events, optionally filtered by type and limited"""
    var filtered_events = []

    for event in _events:
        if event_type_filter == -1 or event.event_type == event_type_filter:
            filtered_events.append(event)
            if limit > 0 and filtered_events.size() >= limit:
                break

    return filtered_events

func get_session_summary() -> Dictionary:
    """Get a summary of the current session"""
    var event_counts = {}
    var error_count = 0
    var performance_metrics = {}

    for event in _events:
        var type_str = _event_type_to_string(event.event_type)
        event_counts[type_str] = event_counts.get(type_str, 0) + 1

        if event.event_type == EventType.ERROR_OCCURRED:
            error_count += 1

        if event.event_type == EventType.PERFORMANCE_METRIC:
            var metric_name = event.data.get("metric_name", "unknown")
            performance_metrics[metric_name] = event.data.get("value", 0)

    return {
        "session_id": _session_id,
        "start_time": _session_start_time,
        "duration_seconds": Time.get_unix_time_from_system() - _session_start_time,
        "total_events": _events.size(),
        "event_counts": event_counts,
        "error_count": error_count,
        "performance_metrics": performance_metrics
    }

func export_to_file(file_path: String) -> bool:
    """Export telemetry data to a JSON file"""
    var export_data = {
        "session_summary": get_session_summary(),
        "events": _events
    }

    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        log_error("Failed to open telemetry export file: " + file_path)
        return false

    var json_string = JSON.stringify(export_data, "\t", true)
    file.store_string(json_string)
    file.close()

    _log_event(EventType.CUSTOM_EVENT, "Telemetry exported to: " + file_path)
    return true

func clear_events():
    """Clear all telemetry events (useful for memory management)"""
    var event_count = _events.size()
    _events.clear()
    _log_event(EventType.CUSTOM_EVENT, "Cleared " + str(event_count) + " telemetry events")

func _event_type_to_string(event_type: EventType) -> String:
    """Convert event type enum to string"""
    match event_type:
        EventType.GAME_START: return "GAME_START"
        EventType.GAME_END: return "GAME_END"
        EventType.SCENE_CHANGE: return "SCENE_CHANGE"
        EventType.RNG_SEED_SET: return "RNG_SEED_SET"
        EventType.RNG_CALL: return "RNG_CALL"
        EventType.BATTLE_START: return "BATTLE_START"
        EventType.BATTLE_END: return "BATTLE_END"
        EventType.UNIT_ACTION: return "UNIT_ACTION"
        EventType.SAVE_GAME: return "SAVE_GAME"
        EventType.LOAD_GAME: return "LOAD_GAME"
        EventType.MOD_LOADED: return "MOD_LOADED"
        EventType.ERROR_OCCURRED: return "ERROR_OCCURRED"
        EventType.PERFORMANCE_METRIC: return "PERFORMANCE_METRIC"
        EventType.CUSTOM_EVENT: return "CUSTOM_EVENT"
        _: return "UNKNOWN"

# Integration with Godot's notification system
func _notification(what):
    """Handle Godot notifications"""
    match what:
        NOTIFICATION_WM_CLOSE_REQUEST:
            _log_event(EventType.GAME_END, "Game closed by user")
        NOTIFICATION_CRASH:
            _log_event(EventType.ERROR_OCCURRED, "Game crashed", {
                "crash_time": Time.get_unix_time_from_system()
            })
