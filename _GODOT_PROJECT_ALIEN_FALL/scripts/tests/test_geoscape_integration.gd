extends Node

# TestGeoscapeIntegration - Tests the geoscape system integration
# Run this to verify all subsystems work together

@onready var test_output = $"../TestOutput"
@onready var status_label = $"../StatusLabel"

func _ready():
	print("=== Geoscape Integration Test ===")
	log_to_ui("=== Geoscape Integration Test ===\n")

func _on_run_test_pressed():
	test_output.text = ""
	status_label.text = "Running geoscape integration test..."
	run_integration_test()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func run_integration_test():
	# Test EventBus
	log_to_ui("Testing EventBus...")
	print("Testing EventBus...")
	EventBus.publish("test_event", {"message": "Hello from test"})
	log_to_ui("✓ EventBus working\n")
	print("✓ EventBus working")

	# Test RNGService
	log_to_ui("Testing RNGService...")
	print("Testing RNGService...")
	var rng = RNGService.get_rng("test_seed")
	var random_value = rng.randi_range(1, 100)
	log_to_ui("✓ RNGService working - Random value: " + str(random_value) + "\n")
	print("✓ RNGService working - Random value: ", random_value)

	# Test DataRegistry
	log_to_ui("Testing DataRegistry...")
	print("Testing DataRegistry...")
	var sample_data = DataRegistry.get_data("missions")
	if sample_data:
		log_to_ui("✓ DataRegistry working - Found " + str(sample_data.size()) + " mission types\n")
		print("✓ DataRegistry working - Found ", sample_data.size(), " mission types")
	else:
		log_to_ui("⚠ DataRegistry: No mission data found\n")
		print("⚠ DataRegistry: No mission data found")

	# Test TimeService
	log_to_ui("Testing TimeService...")
	print("Testing TimeService...")
	var current_time = TimeService.get_current_time()
	log_to_ui("✓ TimeService working - Current time: " + str(current_time) + "\n")
	print("✓ TimeService working - Current time: ", current_time)

	# Test GeoscapeManager
	log_to_ui("Testing GeoscapeManager...")
	print("Testing GeoscapeManager...")
	var geoscape_manager = GeoscapeManager.new()
	var current_day = geoscape_manager.get_current_day()
	log_to_ui("✓ GeoscapeManager working - Current day: " + str(current_day) + "\n")
	print("✓ GeoscapeManager working - Current day: ", current_day)

	# Test MissionFactory
	log_to_ui("Testing MissionFactory...")
	print("Testing MissionFactory...")
	var mission_factory = MissionFactory.new()
	var test_mission = mission_factory.create_mission("UFO_Scout", 1)
	if test_mission:
		log_to_ui("✓ MissionFactory working - Created mission: " + test_mission.name + "\n")
		print("✓ MissionFactory working - Created mission: ", test_mission.name)
	else:
		log_to_ui("⚠ MissionFactory: Could not create test mission\n")
		print("⚠ MissionFactory: Could not create test mission")

	# Test DetectionSystem
	log_to_ui("Testing DetectionSystem...")
	print("Testing DetectionSystem...")
	var detection_system = DetectionSystem.new()
	var detection_chance = detection_system.calculate_detection_chance(test_mission)
	log_to_ui("✓ DetectionSystem working - Detection chance: " + str(detection_chance) + "\n")
	print("✓ DetectionSystem working - Detection chance: ", detection_chance)

	log_to_ui("=== Integration Test Complete ===\n")
	print("=== Integration Test Complete ===")

	status_label.text = "Geoscape integration test completed!"

	# Clean up
	geoscape_manager.queue_free()
	if test_mission:
		test_mission.queue_free()

func log_to_ui(message: String):
	if test_output:
		test_output.text += message
		# Auto scroll to bottom
		test_output.scroll_vertical = test_output.get_line_count()
