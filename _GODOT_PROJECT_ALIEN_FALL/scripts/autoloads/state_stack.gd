extends Node

# StateStack - Manages game state transitions using a stack-based approach
# This provides clean state management for MainMenu, Geoscape, Basescape, Battlescape, etc.

class_name StateStack

# Signals
signal state_pushed(state_name: String)
signal state_popped(state_name: String)
signal state_replaced(old_state_name: String, new_state_name: String)
signal state_stack_changed()

# State stack
var _state_stack: Array = []
var _current_state: Control = null
var _state_container: Control = null

# State registry - maps state names to scene paths
var _state_scenes = {
	"main_menu": "res://scenes/main_menu.tscn",
	"geoscape": "res://scenes/geoscape.tscn",
	"basescape": "res://scenes/base_management.tscn",
	"battlescape": "res://scenes/battlescape.tscn",
	"research": "res://scenes/research.tscn"
}

func _ready():
	print("StateStack: Initializing...")
	
	# Create state container if it doesn't exist
	if not _state_container:
		_state_container = Control.new()
		_state_container.name = "StateContainer"
		_state_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		get_tree().root.add_child(_state_container)
	
	print("StateStack: Ready")

# Push a new state onto the stack
func push_state(state_name: String, state_data: Dictionary = {}) -> bool:
	print("StateStack: Pushing state: ", state_name)
	
	if not _state_scenes.has(state_name):
		push_error("StateStack: Unknown state: " + state_name)
		return false
	
	# Pause current state if it exists
	if _current_state:
		_current_state.process_mode = Node.PROCESS_MODE_DISABLED
		_current_state.hide()
	
	# Load and instantiate the new state
	var scene_path = _state_scenes[state_name]
	if not ResourceLoader.exists(scene_path):
		push_error("StateStack: Scene file not found: " + scene_path)
		return false
	
	var scene = load(scene_path)
	if not scene:
		push_error("StateStack: Failed to load scene: " + scene_path)
		return false
	
	var new_state = scene.instantiate()
	if not new_state:
		push_error("StateStack: Failed to instantiate scene: " + scene_path)
		return false
	
	# Add state data if provided
	if state_data.size() > 0 and new_state.has_method("set_state_data"):
		new_state.set_state_data(state_data)
	
	# Add to container and stack
	_state_container.add_child(new_state)
	_state_stack.push_back({
		"name": state_name,
		"instance": new_state,
		"data": state_data
	})
	
	_current_state = new_state
	
	# Show the new state
	new_state.show()
	
	emit_signal("state_pushed", state_name)
	emit_signal("state_stack_changed")
	
	print("StateStack: Successfully pushed state: ", state_name)
	return true

# Pop the current state from the stack
func pop_state() -> bool:
	print("StateStack: Popping current state")
	
	if _state_stack.size() == 0:
		push_error("StateStack: Cannot pop from empty stack")
		return false
	
	var popped_state = _state_stack.pop_back()
	var state_name = popped_state.name
	var state_instance = popped_state.instance
	
	# Remove from container
	if state_instance and is_instance_valid(state_instance):
		state_instance.queue_free()
	
	# Activate previous state
	if _state_stack.size() > 0:
		var previous_state_data = _state_stack.back()
		_current_state = previous_state_data.instance
		_current_state.process_mode = Node.PROCESS_MODE_INHERIT
		_current_state.show()
	else:
		_current_state = null
	
	emit_signal("state_popped", state_name)
	emit_signal("state_stack_changed")
	
	print("StateStack: Successfully popped state: ", state_name)
	return true

# Replace the current state with a new one
func replace_state(state_name: String, state_data: Dictionary = {}) -> bool:
	print("StateStack: Replacing current state with: ", state_name)
	
	if _state_stack.size() == 0:
		return push_state(state_name, state_data)
	
	var old_state_name = _state_stack.back().name
	
	# Pop current state
	pop_state()
	
	# Push new state
	if push_state(state_name, state_data):
		emit_signal("state_replaced", old_state_name, state_name)
		return true
	
	return false

# Clear the entire state stack
func clear_stack():
	print("StateStack: Clearing entire stack")
	
	while _state_stack.size() > 0:
		var state_data = _state_stack.back()
		if state_data.instance and is_instance_valid(state_data.instance):
			state_data.instance.queue_free()
		_state_stack.pop_back()
	
	_current_state = null
	emit_signal("state_stack_changed")
	
	print("StateStack: Stack cleared")

# Get current state name
func get_current_state_name() -> String:
	if _state_stack.size() > 0:
		return _state_stack.back().name
	return ""

# Get current state instance
func get_current_state() -> Control:
	return _current_state

# Get stack size
func get_stack_size() -> int:
	return _state_stack.size()

# Check if state exists in stack
func has_state(state_name: String) -> bool:
	for state_data in _state_stack:
		if state_data.name == state_name:
			return true
	return false

# Get state data for current state
func get_current_state_data() -> Dictionary:
	if _state_stack.size() > 0:
		return _state_stack.back().data
	return {}

# Register a new state scene
func register_state(state_name: String, scene_path: String):
	print("StateStack: Registering state: ", state_name, " -> ", scene_path)
	_state_scenes[state_name] = scene_path

# Get all registered states
func get_registered_states() -> Array:
	return _state_scenes.keys()

# Debug function to print stack contents
func print_stack():
	print("=== STATE STACK DEBUG ===")
	print("Stack size: ", _state_stack.size())
	print("Current state: ", get_current_state_name())
	
	for i in range(_state_stack.size()):
		var state_data = _state_stack[i]
		print("  ", i, ": ", state_data.name, " (", state_data.instance.name if state_data.instance else "null", ")")
	
	print("=========================")</content>
<parameter name="filePath">c:\Users\tombl\Documents\AlienFall\GodotProject\scripts\autoloads\state_stack.gd
