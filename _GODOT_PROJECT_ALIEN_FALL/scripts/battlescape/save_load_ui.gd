extends Control
class_name SaveLoadUI

# SaveLoadUI - User interface for managing save slots
# Provides save/load/delete functionality with slot management

var battlescape_manager: BattlescapeManager = null
var slot_containers = []

signal ui_closed()

func _ready():
    print("SaveLoadUI initialized")
    _setup_slot_containers()
    _connect_signals()
    _refresh_save_slots()

func _setup_slot_containers():
    slot_containers = [
        $Panel/SaveSlotsContainer/Slot1,
        $Panel/SaveSlotsContainer/Slot2,
        $Panel/SaveSlotsContainer/Slot3
    ]

func _connect_signals():
    # Connect slot buttons
    for i in range(slot_containers.size()):
        var container = slot_containers[i]
        var slot_id = i + 1  # Slots 1, 2, 3 (0 is auto-save)

        container.get_node("SaveButton").connect("pressed", Callable(self, "_on_save_pressed").bind(slot_id))
        container.get_node("LoadButton").connect("pressed", Callable(self, "_on_load_pressed").bind(slot_id))
        container.get_node("DeleteButton").connect("pressed", Callable(self, "_on_delete_pressed").bind(slot_id))

    # Connect other buttons
    $Panel/QuickSaveButton.connect("pressed", Callable(self, "_on_quick_save_pressed"))
    $Panel/QuickLoadButton.connect("pressed", Callable(self, "_on_quick_load_pressed"))
    $Panel/AutoSaveButton.connect("pressed", Callable(self, "_on_auto_save_pressed"))
    $Panel/CloseButton.connect("pressed", Callable(self, "_on_close_pressed"))

func _refresh_save_slots():
    if not battlescape_manager:
        return

    var save_slots = battlescape_manager.get_all_save_slots()

    for i in range(slot_containers.size()):
        var container = slot_containers[i]
        var slot_id = i + 1
        var description_label = container.get_node("DescriptionLabel")

        var slot_info = battlescape_manager.get_save_slot_info(slot_id)
        if slot_info.is_empty():
            description_label.text = "Empty"
            description_label.modulate = Color(0.7, 0.7, 0.7, 1)
            container.get_node("LoadButton").disabled = true
            container.get_node("DeleteButton").disabled = true
        else:
            var timestamp = slot_info.get("timestamp", {})
            var time_str = "%04d-%02d-%02d %02d:%02d" % [
                timestamp.get("year", 0),
                timestamp.get("month", 0),
                timestamp.get("day", 0),
                timestamp.get("hour", 0),
                timestamp.get("minute", 0)
            ]
            description_label.text = slot_info.get("description", "Unknown") + "\n" + time_str
            description_label.modulate = Color(1, 1, 1, 1)
            container.get_node("LoadButton").disabled = false
            container.get_node("DeleteButton").disabled = false

func _on_save_pressed(slot_id: int):
    if not battlescape_manager:
        return

    var description = "Manual Save - " + _get_timestamp_string()
    var success = battlescape_manager.save_battlescape_to_slot(slot_id, description)

    if success:
        print("Game saved to slot ", slot_id)
        _show_message("Game saved successfully!")
        _refresh_save_slots()
    else:
        print("Failed to save to slot ", slot_id)
        _show_message("Failed to save game!")

func _on_load_pressed(slot_id: int):
    if not battlescape_manager:
        return

    var confirm_dialog = ConfirmationDialog.new()
    confirm_dialog.title = "Load Game"
    confirm_dialog.dialog_text = "Are you sure you want to load from slot " + str(slot_id) + "?\nThis will overwrite your current game."
    confirm_dialog.connect("confirmed", Callable(self, "_confirm_load").bind(slot_id))
    add_child(confirm_dialog)
    confirm_dialog.popup_centered()

func _confirm_load(slot_id: int):
    var success = battlescape_manager.load_battlescape_from_slot(slot_id)

    if success:
        print("Game loaded from slot ", slot_id)
        _show_message("Game loaded successfully!")
        _refresh_save_slots()
        emit_signal("ui_closed")  # Close the UI after successful load
    else:
        print("Failed to load from slot ", slot_id)
        _show_message("Failed to load game!")

func _on_delete_pressed(slot_id: int):
    if not battlescape_manager:
        return

    var confirm_dialog = ConfirmationDialog.new()
    confirm_dialog.title = "Delete Save"
    confirm_dialog.dialog_text = "Are you sure you want to delete save slot " + str(slot_id) + "?\nThis action cannot be undone."
    confirm_dialog.connect("confirmed", Callable(self, "_confirm_delete").bind(slot_id))
    add_child(confirm_dialog)
    confirm_dialog.popup_centered()

func _confirm_delete(slot_id: int):
    var success = battlescape_manager.delete_save_slot(slot_id)

    if success:
        print("Save slot ", slot_id, " deleted")
        _show_message("Save slot deleted!")
        _refresh_save_slots()
    else:
        print("Failed to delete slot ", slot_id)
        _show_message("Failed to delete save slot!")

func _on_quick_save_pressed():
    if not battlescape_manager:
        return

    var success = battlescape_manager.quick_save_battlescape()

    if success:
        print("Quick save completed")
        _show_message("Quick save completed!")
        _refresh_save_slots()
    else:
        print("Quick save failed")
        _show_message("Quick save failed!")

func _on_quick_load_pressed():
    if not battlescape_manager:
        return

    var confirm_dialog = ConfirmationDialog.new()
    confirm_dialog.title = "Quick Load"
    confirm_dialog.dialog_text = "Are you sure you want to quick load?\nThis will overwrite your current game."
    confirm_dialog.connect("confirmed", Callable(self, "_confirm_quick_load"))
    add_child(confirm_dialog)
    confirm_dialog.popup_centered()

func _confirm_quick_load():
    var success = battlescape_manager.quick_load_battlescape()

    if success:
        print("Quick load completed")
        _show_message("Quick load completed!")
        _refresh_save_slots()
        emit_signal("ui_closed")  # Close the UI after successful load
    else:
        print("Quick load failed")
        _show_message("Quick load failed!")

func _on_auto_save_pressed():
    if not battlescape_manager:
        return

    var success = battlescape_manager.auto_save_battlescape()

    if success:
        print("Auto save completed")
        _show_message("Auto save completed!")
        _refresh_save_slots()
    else:
        print("Auto save failed")
        _show_message("Auto save failed!")

func _on_close_pressed():
    emit_signal("ui_closed")
    queue_free()

func _show_message(message: String):
    var dialog = AcceptDialog.new()
    dialog.title = "Save/Load System"
    dialog.dialog_text = message
    add_child(dialog)
    dialog.popup_centered()

func _get_timestamp_string() -> String:
    var datetime = Time.get_datetime_dict_from_system()
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        datetime.year, datetime.month, datetime.day,
        datetime.hour, datetime.minute, datetime.second
    ]

func set_battlescape_manager(manager: BattlescapeManager):
    battlescape_manager = manager
    _refresh_save_slots()

# Public methods for external control
func show_save_load():
    visible = true
    _refresh_save_slots()

func hide_save_load():
    visible = false
