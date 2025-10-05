extends Node

func _ready():
    print("Hello from test script!")
    print("Current working directory: ", OS.get_executable_path())
    print("Project path: ", ProjectSettings.globalize_path("res://"))
    get_tree().quit()
