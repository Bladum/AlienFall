extends Node

# Battlescape Test Runner
# Simple utility to run battlescape integration tests

func _ready():
	print("=== Battlescape Test Runner ===")
	print("Press 'T' to run battlescape integration tests")
	print("Press 'Q' to quit")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			run_battlescape_tests()
		elif event.keycode == KEY_Q:
			get_tree().quit()

func run_battlescape_tests():
	print("\n--- Running Battlescape Integration Tests ---")
	
	# Load and run the test scene
	var test_scene = load("res://scenes/test_battlescape_integration.tscn")
	if test_scene:
		var test_instance = test_scene.instantiate()
		add_child(test_instance)
		print("✓ Test scene loaded and running")
	else:
		print("✗ Failed to load test scene")
