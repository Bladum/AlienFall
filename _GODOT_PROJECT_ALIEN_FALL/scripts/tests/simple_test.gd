extends Control

func _ready():
	print("Simple test scene loaded successfully!")
	$MessageLabel.text = "Scene loaded at: " + Time.get_datetime_string_from_system()

func _on_back_pressed():
	print("Going back to main menu...")
	get_tree().change_scene_to_file("res://main.tscn")
