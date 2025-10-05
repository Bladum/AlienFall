extends Control

# MainMenuState - Handles the main menu screen
# This is the entry point of the game

@onready var new_game_button = $MenuContainer/NewGameButton
@onready var load_game_button = $MenuContainer/LoadGameButton
@onready var options_button = $MenuContainer/OptionsButton
@onready var test_button = $MenuContainer/TestButton

func _ready():
    print("MainMenuState: Initializing...")
    
    # Connect button signals
    new_game_button.connect("pressed", Callable(self, "_on_new_game_pressed"))
    load_game_button.connect("pressed", Callable(self, "_on_load_game_pressed"))
    options_button.connect("pressed", Callable(self, "_on_options_pressed"))
    test_button.connect("pressed", Callable(self, "_on_test_pressed"))
    
    # Subscribe to relevant events
    EventBus.subscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
    
    # Set initial game mode
    GameState.set_game_mode(GameState.GameMode.MAIN_MENU)
    
    print("MainMenuState: Ready")

func _on_new_game_pressed():
    print("MainMenuState: New Game button pressed")
    
    # Create a new campaign
    GameState.new_campaign("Test Campaign")
    
    # Transition to geoscape
    _transition_to_geoscape()

func _on_load_game_pressed():
    print("MainMenuState: Load Game button pressed")
    
    # For now, just create a new game
    # In a real implementation, this would show a load dialog
    _on_new_game_pressed()

func _on_options_pressed():
    print("MainMenuState: Options button pressed")
    
    # For now, just show a simple message
    # In a real implementation, this would open an options menu
    var dialog = AcceptDialog.new()
    dialog.title = "Options"
    dialog.dialog_text = "Options menu not implemented yet.\n\nAvailable options will include:\n- Audio settings\n- Video settings\n- Controls\n- Game settings"
    add_child(dialog)
    dialog.popup_centered()

func _on_test_pressed():
    print("MainMenuState: Test button pressed")
    
    # Run the test scene
    get_tree().change_scene_to_file("res://scenes/test_scene.tscn")

func _transition_to_geoscape():
    print("MainMenuState: Transitioning to Geoscape...")
    
    # Change to geoscape scene
    # For now, we'll create a simple placeholder scene
    # In the next phase, we'll create the actual geoscape scene
    var geoscape_scene = load("res://scenes/geoscape.tscn")
    if geoscape_scene:
        get_tree().change_scene_to_packed(geoscape_scene)
    else:
        print("MainMenuState: Geoscape scene not found, staying in menu")
        # For now, just show a message
        var dialog = AcceptDialog.new()
        dialog.title = "Geoscape"
        dialog.dialog_text = "Geoscape scene not implemented yet.\n\nThis will show:\n- World map\n- Mission tracking\n- Base management\n- Time controls"
        add_child(dialog)
        dialog.popup_centered()

func _on_game_mode_changed(data: Dictionary):
    print("MainMenuState: Game mode changed to: ", data.new_mode)
    
    # Handle mode changes if needed
    pass

# Handle input (for keyboard shortcuts, etc.)
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ESCAPE:
                _on_quit_pressed()
            KEY_N:
                if event.ctrl_pressed:
                    _on_new_game_pressed()
            KEY_L:
                if event.ctrl_pressed:
                    _on_load_game_pressed()
            KEY_O:
                if event.ctrl_pressed:
                    _on_options_pressed()

# Cleanup when leaving the scene
func _exit_tree():
    print("MainMenuState: Exiting...")
    
    # Unsubscribe from events
    EventBus.unsubscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
