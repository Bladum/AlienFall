extends Node
class_name SaveLoadSystem

# SaveLoadSystem - Complete game persistence with multiple save slots
# Handles saving/loading game state, metadata, and file management

const SAVE_DIR = "user://saves/"
const MAX_SAVE_SLOTS = 10
const AUTO_SAVE_SLOT = 0

var current_save_slot: int = -1
var save_metadata = {}  # slot_id -> metadata dict

signal save_completed(slot_id: int, success: bool)
signal load_completed(slot_id: int, success: bool)
signal save_deleted(slot_id: int)
signal auto_save_created()

func _ready():
    print("SaveLoadSystem initialized")
    _ensure_save_directory()
    _load_save_metadata()

func _ensure_save_directory():
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")
        print("Created saves directory")

func _load_save_metadata():
    var metadata_file = SAVE_DIR + "metadata.json"
    if FileAccess.file_exists(metadata_file):
        var file = FileAccess.open(metadata_file, FileAccess.READ)
        if file:
            var json_text = file.get_as_text()
            var json = JSON.new()
            var result = json.parse(json_text)
            if result == OK:
                save_metadata = json.get_data()
                print("Loaded save metadata for ", save_metadata.size(), " slots")
            file.close()

func _save_metadata():
    var metadata_file = SAVE_DIR + "metadata.json"
    var file = FileAccess.open(metadata_file, FileAccess.WRITE)
    if file:
        var json_text = JSON.stringify(save_metadata, "\t")
        file.store_string(json_text)
        file.close()
        print("Saved metadata for ", save_metadata.size(), " slots")

func create_save_slot(slot_id: int, description: String = "") -> bool:
    if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
        print("Invalid save slot: ", slot_id)
        return false

    var timestamp = Time.get_datetime_dict_from_system()
    var metadata = {
        "slot_id": slot_id,
        "description": description if description else "Save Slot " + str(slot_id + 1),
        "timestamp": timestamp,
        "timestamp_unix": Time.get_unix_time_from_datetime_dict(timestamp),
        "game_version": "1.0.0",
        "playtime": 0,  # Will be updated when saving
        "screenshot": null  # Could be added later
    }

    save_metadata[slot_id] = metadata
    _save_metadata()
    print("Created save slot ", slot_id, ": ", metadata.description)
    return true

func save_game(slot_id: int, game_state: Dictionary, description: String = "") -> bool:
    if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
        print("Invalid save slot: ", slot_id)
        return false

    # Create slot if it doesn't exist
    if not save_metadata.has(slot_id):
        create_save_slot(slot_id, description)

    # Update metadata
    var metadata = save_metadata[slot_id]
    var timestamp = Time.get_datetime_dict_from_system()
    metadata.timestamp = timestamp
    metadata.timestamp_unix = Time.get_unix_time_from_datetime_dict(timestamp)
    if description:
        metadata.description = description

    # Add system info to game state
    var full_save_data = {
        "metadata": metadata,
        "game_state": game_state,
        "system_info": {
            "godot_version": Engine.get_version_info(),
            "platform": OS.get_name(),
            "timestamp": timestamp
        }
    }

    # Save to file
    var save_file = SAVE_DIR + "save_" + str(slot_id) + ".json"
    var file = FileAccess.open(save_file, FileAccess.WRITE)
    if not file:
        print("Failed to open save file: ", save_file)
        emit_signal("save_completed", slot_id, false)
        return false

    var json_text = JSON.stringify(full_save_data, "\t")
    file.store_string(json_text)
    file.close()

    _save_metadata()
    current_save_slot = slot_id

    print("Game saved to slot ", slot_id, ": ", metadata.description)
    emit_signal("save_completed", slot_id, true)
    return true

func load_game(slot_id: int) -> Dictionary:
    if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
        print("Invalid save slot: ", slot_id)
        emit_signal("load_completed", slot_id, false)
        return {}

    if not save_metadata.has(slot_id):
        print("Save slot ", slot_id, " does not exist")
        emit_signal("load_completed", slot_id, false)
        return {}

    var save_file = SAVE_DIR + "save_" + str(slot_id) + ".json"
    if not FileAccess.file_exists(save_file):
        print("Save file does not exist: ", save_file)
        emit_signal("load_completed", slot_id, false)
        return {}

    var file = FileAccess.open(save_file, FileAccess.READ)
    if not file:
        print("Failed to open save file: ", save_file)
        emit_signal("load_completed", slot_id, false)
        return {}

    var json_text = file.get_as_text()
    file.close()

    var json = JSON.new()
    var result = json.parse(json_text)
    if result != OK:
        print("Failed to parse save file JSON")
        emit_signal("load_completed", slot_id, false)
        return {}

    var save_data = json.get_data()
    current_save_slot = slot_id

    print("Game loaded from slot ", slot_id, ": ", save_data.metadata.description)
    emit_signal("load_completed", slot_id, true)
    return save_data.game_state

func delete_save_slot(slot_id: int) -> bool:
    if slot_id < 0 or slot_id >= MAX_SAVE_SLOTS:
        print("Invalid save slot: ", slot_id)
        return false

    if not save_metadata.has(slot_id):
        print("Save slot ", slot_id, " does not exist")
        return false

    # Delete the save file
    var save_file = SAVE_DIR + "save_" + str(slot_id) + ".json"
    if FileAccess.file_exists(save_file):
        var dir = DirAccess.open(SAVE_DIR)
        dir.remove("save_" + str(slot_id) + ".json")

    # Remove metadata
    save_metadata.erase(slot_id)
    _save_metadata()

    print("Deleted save slot ", slot_id)
    emit_signal("save_deleted", slot_id)
    return true

func get_save_slot_info(slot_id: int) -> Dictionary:
    if save_metadata.has(slot_id):
        return save_metadata[slot_id].duplicate()
    return {}

func get_all_save_slots() -> Array:
    var slots = []
    for slot_id in range(MAX_SAVE_SLOTS):
        if save_metadata.has(slot_id):
            var info = save_metadata[slot_id].duplicate()
            info.slot_id = slot_id
            slots.append(info)
    return slots

func has_save_slot(slot_id: int) -> bool:
    return save_metadata.has(slot_id)

func get_save_slot_count() -> int:
    return save_metadata.size()

func auto_save(game_state: Dictionary) -> bool:
    var description = "Auto Save - " + _get_timestamp_string()
    var success = save_game(AUTO_SAVE_SLOT, game_state, description)
    if success:
        emit_signal("auto_save_created")
    return success

func quick_save(game_state: Dictionary) -> bool:
    if current_save_slot == -1:
        # No current save, use first available slot
        for slot_id in range(1, MAX_SAVE_SLOTS):
            if not has_save_slot(slot_id):
                current_save_slot = slot_id
                break

        if current_save_slot == -1:
            current_save_slot = 1  # Use slot 1 if all are full

    var description = "Quick Save - " + _get_timestamp_string()
    return save_game(current_save_slot, game_state, description)

func quick_load() -> Dictionary:
    if current_save_slot == -1:
        print("No current save slot to quick load from")
        return {}
    return load_game(current_save_slot)

func _get_timestamp_string() -> String:
    var datetime = Time.get_datetime_dict_from_system()
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year, datetime.month, datetime.day,
        datetime.hour, datetime.minute, datetime.second
    ]

func validate_save_data(save_data: Dictionary) -> bool:
    # Basic validation of save data structure
    if not save_data.has("metadata"):
        print("Save data missing metadata")
        return false

    if not save_data.has("game_state"):
        print("Save data missing game_state")
        return false

    if not save_data.has("system_info"):
        print("Save data missing system_info")
        return false

    var metadata = save_data.metadata
    if not metadata.has("game_version"):
        print("Save data metadata missing game_version")
        return false

    print("Save data validation passed")
    return true

func get_save_file_size(slot_id: int) -> int:
    if not has_save_slot(slot_id):
        return 0

    var save_file = SAVE_DIR + "save_" + str(slot_id) + ".json"
    if FileAccess.file_exists(save_file):
        var file = FileAccess.open(save_file, FileAccess.READ)
        if file:
            var size = file.get_length()
            file.close()
            return size
    return 0

func cleanup_old_saves(max_age_days: int = 30) -> int:
    var current_time = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
    var deleted_count = 0

    for slot_id in save_metadata.keys():
        var metadata = save_metadata[slot_id]
        var save_time = metadata.get("timestamp_unix", 0)
        var age_days = (current_time - save_time) / (60 * 60 * 24)

        if age_days > max_age_days:
            if delete_save_slot(slot_id):
                deleted_count += 1

    if deleted_count > 0:
        print("Cleaned up ", deleted_count, " old save files")
    return deleted_count
