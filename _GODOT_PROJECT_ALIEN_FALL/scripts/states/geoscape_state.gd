extends Control

# GeoscapeState - Handles the strategic world map view
# This is the main strategic gameplay screen

@onready var time_label = $SidePanel/TimeLabel
@onready var funding_label = $SidePanel/FundingLabel
@onready var missions_label = $SidePanel/MissionsLabel
@onready var pause_button = $SidePanel/TimeControls/PauseButton
@onready var play_button = $SidePanel/TimeControls/PlayButton
@onready var fast_forward_button = $SidePanel/TimeControls/FastForwardButton
@onready var base_button = $SidePanel/ActionsContainer/BaseButton
@onready var research_button = $SidePanel/ActionsContainer/ResearchButton
@onready var manufacture_button = $SidePanel/ActionsContainer/ManufactureButton
@onready var missions_list = $MissionsPanel/MissionsList
@onready var no_missions_label = $MissionsPanel/MissionsList/NoMissionsLabel
@onready var back_button = $BackButton
@onready var advance_day_button = $TestButtons/AdvanceDayButton
@onready var advance_month_button = $TestButtons/AdvanceMonthButton
@onready var spawn_mission_button = $TestButtons/SpawnMissionButton

var current_day: int = 1
var time_paused: bool = true
var time_speed: int = 1  # 1 = normal, 2 = fast, 3 = fastest

var geoscape_manager: GeoscapeManager
var time_timer: Timer
var monthly_report_dialog: AcceptDialog

func _ready():
    print("GeoscapeState: Initializing...")

    # Create and add geoscape manager
    geoscape_manager = GeoscapeManager.new()
    add_child(geoscape_manager)

    # Create timer for time progression
    time_timer = Timer.new()
    time_timer.wait_time = 1.0  # 1 second per day in normal speed
    time_timer.connect("timeout", Callable(self, "_on_time_tick"))
    add_child(time_timer)

    # Create monthly report dialog
    _create_monthly_report_dialog()

    # Connect button signals
    pause_button.connect("pressed", Callable(self, "_on_pause_pressed"))
    play_button.connect("pressed", Callable(self, "_on_play_pressed"))
    fast_forward_button.connect("pressed", Callable(self, "_on_fast_forward_pressed"))
    base_button.connect("pressed", Callable(self, "_on_base_pressed"))
    research_button.connect("pressed", Callable(self, "_on_research_pressed"))
    manufacture_button.connect("pressed", Callable(self, "_on_manufacture_pressed"))
    back_button.connect("pressed", Callable(self, "_on_back_pressed"))
    advance_day_button.connect("pressed", Callable(self, "_on_advance_day_pressed"))
    advance_month_button.connect("pressed", Callable(self, "_on_advance_month_pressed"))
    spawn_mission_button.connect("pressed", Callable(self, "_on_spawn_mission_pressed"))

    # Subscribe to relevant events
    EventBus.subscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
    EventBus.subscribe("geoscape_updated", Callable(self, "_on_geoscape_updated"))
    EventBus.subscribe("mission_detected", Callable(self, "_on_mission_detected"))
    EventBus.subscribe("monthly_tick", Callable(self, "_on_monthly_tick"))

    # Set game mode
    GameState.set_game_mode(GameState.GameMode.GEOSCAPE)

    # Initialize display
    _update_display()
    _update_missions_display()

    print("GeoscapeState: Ready")

func _on_time_tick():
    if not time_paused:
        # Advance time based on current speed
        var days_to_advance = time_speed
        geoscape_manager.advance_time(days_to_advance)

func _on_pause_pressed():
    time_paused = true
    time_speed = 0
    time_timer.stop()
    _update_time_controls()

func _on_play_pressed():
    time_paused = false
    time_speed = 1
    time_timer.wait_time = 1.0  # Normal speed
    time_timer.start()
    _update_time_controls()

func _on_fast_forward_pressed():
    time_paused = false
    time_speed = 5  # 5x speed
    time_timer.wait_time = 0.2  # Faster ticks
    time_timer.start()
    _update_time_controls()

func _on_base_pressed():
    print("GeoscapeState: Base management requested")
    
    # Navigate to base management screen
    get_tree().change_scene_to_file("res://scenes/base_management.tscn")

func _on_research_pressed():
    print("GeoscapeState: Research requested")
    
    # Navigate to research screen
    get_tree().change_scene_to_file("res://scenes/research.tscn")

func _on_manufacture_pressed():
    print("GeoscapeState: Manufacturing requested")
    
    # Show manufacturing dialog
    var dialog = AcceptDialog.new()
    dialog.title = "Manufacturing"
    dialog.dialog_text = "Manufacturing system not implemented yet.\n\nThis will allow:\n- Producing new items\n- Managing production queues\n- Viewing manufacturing progress\n- Resource management"
    add_child(dialog)
    dialog.popup_centered()

func _on_advance_day_pressed():
    print("GeoscapeState: Advance day button pressed")
    geoscape_manager.advance_time(24)  # Advance 24 hours (1 day)

func _on_advance_month_pressed():
    print("GeoscapeState: Advance month button pressed")
    # Advance to next month (30 days)
    for i in range(30):
        geoscape_manager.advance_time(24)

func _on_spawn_mission_pressed():
    print("GeoscapeState: Spawn test mission button pressed")
    var mission = geoscape_manager.spawn_test_mission()
    if mission:
        print("GeoscapeState: Spawned test mission: ", mission.name)
        _update_missions_display()

func _on_back_pressed():
    print("GeoscapeState: Back to menu requested")
    
    # Return to main menu
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_geoscape_updated(data: Dictionary):
    print("GeoscapeState: Geoscape updated - Day: ", data.get("current_day", 1), ", Month: ", data.get("current_month", 1))
    _update_display()
    _update_missions_display()

func _on_monthly_tick(data: Dictionary):
    print("GeoscapeState: Monthly tick received - Month: ", data.month, ", Year: ", data.year)
    _show_monthly_report(data)

func _create_monthly_report_dialog():
    monthly_report_dialog = AcceptDialog.new()
    monthly_report_dialog.title = "Monthly Report"
    monthly_report_dialog.size = Vector2(500, 400)
    monthly_report_dialog.connect("confirmed", Callable(self, "_on_monthly_report_confirmed"))
    add_child(monthly_report_dialog)

func _show_monthly_report(data: Dictionary):
    var report_text = "MONTHLY REPORT - " + str(data.month) + "/" + str(data.year) + "\n\n"

    # Financial summary
    report_text += "FINANCIAL SUMMARY:\n"
    report_text += "Starting Balance: $" + _format_number(data.starting_balance) + "\n"
    report_text += "Income: $" + _format_number(data.income) + "\n"
    report_text += "Expenses: $" + _format_number(data.expenses) + "\n"
    report_text += "Ending Balance: $" + _format_number(data.ending_balance) + "\n\n"

    # Mission summary
    report_text += "MISSION SUMMARY:\n"
    report_text += "Missions Completed: " + str(data.missions_completed) + "\n"
    report_text += "Missions Failed: " + str(data.missions_failed) + "\n"
    report_text += "New Missions: " + str(data.new_missions) + "\n\n"

    # Research progress
    report_text += "RESEARCH PROGRESS:\n"
    report_text += "Projects Active: " + str(data.active_research) + "\n"
    report_text += "Projects Completed: " + str(data.completed_research) + "\n\n"

    # Base operations
    report_text += "BASE OPERATIONS:\n"
    report_text += "Personnel: " + str(data.total_personnel) + "\n"
    report_text += "Facilities: " + str(data.total_facilities) + "\n"
    report_text += "Craft: " + str(data.total_craft) + "\n"

    monthly_report_dialog.dialog_text = report_text
    monthly_report_dialog.popup_centered()

func _on_monthly_report_confirmed():
    print("GeoscapeState: Monthly report acknowledged")

func _update_display():
    if not is_node_ready():
        return
        
    var current_day = geoscape_manager.get_current_day()
    var current_month = geoscape_manager.get_current_month()
    var current_year = geoscape_manager.get_current_year()
    
    time_label.text = "Day " + str(current_day) + " - Month " + str(current_month) + " - " + str(current_year)
    funding_label.text = "Funding: $" + _format_number(GameState.get_funding())
    
    # Update missions count
    var active_missions = geoscape_manager.get_active_missions()
    missions_label.text = "Active Missions: " + str(active_missions.size())
    
    _update_time_controls()

func _update_missions_display():
    if not is_node_ready():
        return
        
    var missions_text = ""
    var active_missions = geoscape_manager.get_active_missions()
    
    if active_missions.size() == 0:
        missions_text = "No active missions"
    else:
        missions_text = "Active Missions:\n"
        for mission in active_missions:
            missions_text += "- " + mission.name + " (Day " + str(mission.spawn_day) + ")\n"
    
    var missions_label = get_node_or_null("MissionsLabel")
    if missions_label:
        missions_label.text = missions_text

func _update_time_controls():
    # Update button states based on time status
    pause_button.disabled = time_paused
    play_button.disabled = not time_paused
    fast_forward_button.disabled = time_paused

func _format_number(num: int) -> String:
    # Simple number formatting
    if num >= 1000000:
        return str(num / 1000000) + "M"
    elif num >= 1000:
        return str(num / 1000) + "K"
    else:
        return str(num)

func _on_game_mode_changed(data: Dictionary):
    print("GeoscapeState: Game mode changed to: ", data.new_mode)
    
    # Handle mode changes if needed
    pass

# Handle input
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ESCAPE:
                _on_back_pressed()
            KEY_SPACE:
                if time_paused:
                    _on_play_pressed()
                else:
                    _on_pause_pressed()
            KEY_B:
                _on_base_pressed()
            KEY_R:
                _on_research_pressed()
            KEY_M:
                _on_manufacture_pressed()

# Cleanup when leaving the scene
func _exit_tree():
    print("GeoscapeState: Exiting...")
    
    # Unsubscribe from events
    EventBus.unsubscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
