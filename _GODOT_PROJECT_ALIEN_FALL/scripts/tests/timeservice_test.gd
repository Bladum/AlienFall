extends Node

func _ready():
    print("TimeService test starting...")
    print("TimeService available: ", TimeService != null)
    if TimeService:
        print("Current day: ", TimeService.get_current_day())
        print("TimeService test passed!")
    else:
        print("TimeService not available!")
    get_tree().quit()
