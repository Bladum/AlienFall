extends Control

@onready var status_label = $StatusLabel

func _ready():
	print("=== TEST MENU LOADED ===")
	print("If you can see this message, the script is working!")
	status_label.text = "Status: Script loaded successfully"

func _on_test_button_1_pressed():
	print("=== TEST BUTTON 1 PRESSED ===")
	status_label.text = "Status: Button 1 pressed at " + Time.get_time_string_from_system()
	print("Button 1 signal received!")

func _on_test_button_2_pressed():
	print("=== TEST BUTTON 2 PRESSED ===")
	status_label.text = "Status: Button 2 pressed at " + Time.get_time_string_from_system()
	print("Button 2 signal received!")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("Escape pressed - going back to main menu")
			get_tree().change_scene_to_file("res://main.tscn")
