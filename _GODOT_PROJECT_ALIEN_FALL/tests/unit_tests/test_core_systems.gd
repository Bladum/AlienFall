extends Node

# TestCoreSystems - Simple test script to verify core systems are working
# Run this to test the basic functionality

func _ready():
    print("=== AlienFall Core Systems Test ===")
    
    # Test EventBus
    print("\n--- Testing EventBus ---")
    test_event_bus()
    
    # Test RNGService
    print("\n--- Testing RNGService ---")
    test_rng_service()
    
    # Test DataRegistry
    print("\n--- Testing DataRegistry ---")
    test_data_registry()
    
    # Test GameState
    print("\n--- Testing GameState ---")
    test_game_state()
    
    # Test Domain Classes
    print("\n--- Testing Domain Classes ---")
    test_domain_classes()
    
    print("\n=== Test Complete ===")

func test_event_bus():
    print("EventBus subscribers: ", EventBus.get_event_names().size())
    
    # Test publishing an event
    var test_payload = {"test": "value", "number": 42}
    EventBus.publish("test_event", test_payload)
    print("Published test event")

func test_rng_service():
    print("Campaign seed: ", RNGService.get_campaign_seed())
    
    # Test RNG handle
    var rng_handle = RNGService.get_rng_handle("test")
    var random_int = rng_handle.randi_range(1, 100)
    var random_float = rng_handle.randf_range(0.0, 1.0)
    
    print("Random int (1-100): ", random_int)
    print("Random float (0-1): ", random_float)
    
    # Test provenance
    var provenance = rng_handle.get_provenance()
    print("RNG provenance: ", provenance)

func test_data_registry():
    var stats = DataRegistry.get_stats()
    print("Data registry stats: ", stats)
    
    # Test loading specific data
    var unit_data = DataRegistry.get_data("units", "sectoid_warrior")
    if unit_data:
        print("Loaded unit: ", unit_data.name)
    else:
        print("Unit data not found (this is expected if data files aren't loaded)")
    
    var item_data = DataRegistry.get_data("items", "plasma_pistol")
    if item_data:
        print("Loaded item: ", item_data.name)
    else:
        print("Item data not found (this is expected if data files aren't loaded)")

func test_game_state():
    print("Current game mode: ", GameState.get_current_mode_string())
    print("Is game active: ", GameState.is_game_active)
    print("Current funding: ", GameState.get_funding())
    
    # Test stat updates
    var old_funding = GameState.get_funding()
    GameState.add_funding(50000)
    print("Funding changed from ", old_funding, " to ", GameState.get_funding())

func test_domain_classes():
    # Test creating a unit
    var test_unit = Unit.new("test_unit", "Test Soldier")
    test_unit.stats.health = 50
    print("Created unit: ", test_unit.name, " with ", test_unit.get_stat("health"), " health")
    
    # Test creating an item
    var test_item = Item.new("test_weapon", "Test Weapon")
    test_item.type = "weapon"
    test_item.weight = 10
    print("Created item: ", test_item.name, " (", test_item.type, ") weighing ", test_item.weight)
    
    # Test creating a facility
    var test_facility = Facility.new("test_lab", "Test Laboratory")
    test_facility.capacities["research"] = 25
    print("Created facility: ", test_facility.name, " with ", test_facility.get_capacity("research"), " research capacity")
