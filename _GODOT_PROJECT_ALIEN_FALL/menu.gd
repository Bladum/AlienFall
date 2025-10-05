extends Control

func _ready():
    $SinglePlayerButton.connect("pressed", Callable(self, "_on_single_player_pressed"))
    $MultiplayerButton.connect("pressed", Callable(self, "_on_multiplayer_pressed"))
    $OptionsButton.connect("pressed", Callable(self, "_on_options_pressed"))
    $QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_single_player_pressed():
    get_tree().change_scene_to_file("res://battle.tscn")

func _on_multiplayer_pressed():
    print("Starting Multiplayer mode...")

func _on_options_pressed():
    print("Opening Options...")

func _on_quit_pressed():
    get_tree().quit()
