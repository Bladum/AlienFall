extends Control

# Main menu controller for AlienFall Phase 5 demonstrations

func _ready():
	print("AlienFall Phase 5 - Main Menu Ready")
	print("Available scenes in project:")
	var dir = DirAccess.open("res://scenes")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				print("  - " + file_name)
			file_name = dir.get_next()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			print("=== SPACE KEY PRESSED ===")
			print("Input system is working!")
		elif event.keycode == KEY_T:
			print("=== T KEY PRESSED - Loading Test Menu ===")
			_on_test_menu_pressed()

func _on_enhanced_inventory_pressed():
	print("=== BUTTON PRESSED: Enhanced Inventory Demo ===")
	print("Attempting to load: res://scenes/enhanced_inventory_demo.tscn")
	if ResourceLoader.exists("res://scenes/enhanced_inventory_demo.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://scenes/enhanced_inventory_demo.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/EnhancedInventoryButton.text = "ERROR: Scene not found"

func _on_alien_ai_demo_pressed():
	print("=== BUTTON PRESSED: Alien AI Demo ===")
	print("Attempting to load: res://scenes/alien_ai_demo.tscn")
	if ResourceLoader.exists("res://scenes/alien_ai_demo.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://scenes/alien_ai_demo.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/AlienAIDemoButton.text = "ERROR: Scene not found"

func _on_alien_ai_test_pressed():
	print("=== BUTTON PRESSED: Alien AI Tests ===")
	print("Attempting to load: res://scenes/alien_ai_test_runner.tscn")
	if ResourceLoader.exists("res://scenes/alien_ai_test_runner.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://scenes/alien_ai_test_runner.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/AlienAITestButton.text = "ERROR: Scene not found"

func _on_geoscape_test_pressed():
	print("=== BUTTON PRESSED: Geoscape Integration Test ===")
	print("Attempting to load: res://scenes/geoscape_test_runner.tscn")
	if ResourceLoader.exists("res://scenes/geoscape_test_runner.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://scenes/geoscape_test_runner.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/GeoscapeTestButton.text = "ERROR: Scene not found"

func _on_simple_test_pressed():
	print("=== BUTTON PRESSED: Simple Test ===")
	print("Attempting to load: res://scenes/simple_test.tscn")
	if ResourceLoader.exists("res://scenes/simple_test.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://scenes/simple_test.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/SimpleTestButton.text = "ERROR: Scene not found"

func _on_test_menu_pressed():
	print("=== BUTTON PRESSED: TEST MENU (Debug) ===")
	print("Attempting to load: res://scenes/test_main_menu.tscn")
	if ResourceLoader.exists("res://scenes/test_main_menu.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://scenes/test_main_menu.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/TestMenuButton.text = "ERROR: Scene not found"

func _on_battle_demo_pressed():
	print("=== BUTTON PRESSED: Battle Demo ===")
	print("Attempting to load: res://battle.tscn")
	if ResourceLoader.exists("res://battle.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://battle.tscn")
	else:
		print("ERROR: Scene file does not exist!")
		$MenuContainer/BattleDemoButton.text = "ERROR: Scene not found"

func _on_exit_pressed():
	print("=== BUTTON PRESSED: Exit ===")
	print("Exiting AlienFall...")
	get_tree().quit()

# Legacy button handler (keeping for compatibility)
func _on_button_pressed():
	print("Legacy button clicked!")
	$Label.text = "Legacy button was clicked!"
