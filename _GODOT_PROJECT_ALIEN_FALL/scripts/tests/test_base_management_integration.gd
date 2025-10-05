extends Node
class_name TestBaseManagementIntegration

# TestBaseManagementIntegration - Tests the base management system integration

func _ready():
    print("=== TestBaseManagementIntegration Starting ===")
    
    # Test base creation
    test_base_creation()
    
    # Test facility management
    test_facility_management()
    
    # Test personnel management
    test_personnel_management()
    
    # Test research integration
    test_research_integration()
    
    print("=== TestBaseManagementIntegration Complete ===")

func test_base_creation():
    print("\n--- Testing Base Creation ---")
    
    var base = Base.new("Test Base", Vector2(100, 200))
    print("Created base: ", base.name, " at ", base.location)
    
    # Check initial state
    var power_status = base.get_power_status()
    print("Initial power status: ", power_status)
    
    var personnel_count = base.personnel.size()
    print("Initial personnel count: ", personnel_count)
    
    assert(base.name == "Test Base")
    assert(base.location == Vector2(100, 200))
    assert(personnel_count == 0)

func test_facility_management():
    print("\n--- Testing Facility Management ---")
    
    var base = Base.new("Facility Test Base", Vector2(0, 0))
    
    # Test adding facilities
    var living_quarters = Facility.new("living_quarters", "Living Quarters")
    living_quarters.living_quarters = 10
    living_quarters.power_required = 5
    
    var power_plant = Facility.new("power_plant", "Power Plant")
    power_plant.power_generation = 50
    power_plant.power_required = 0
    
    assert(base.add_facility(living_quarters))
    assert(base.add_facility(power_plant))
    
    print("Added facilities: ", base.facilities.size())
    
    # Test power calculations
    var power_status = base.get_power_status()
    print("Power generation: ", power_status.generation)
    print("Power consumption: ", power_status.consumption)
    print("Power surplus: ", power_status.surplus)
    
    assert(power_status.generation == 50)
    assert(power_status.consumption == 5)
    assert(power_status.surplus == 45)

func test_personnel_management():
    print("\n--- Testing Personnel Management ---")
    
    var base = Base.new("Personnel Test Base", Vector2(0, 0))
    
    # Add living quarters first
    var living_quarters = Facility.new("living_quarters", "Living Quarters")
    living_quarters.living_quarters = 5
    base.add_facility(living_quarters)
    
    # Test adding personnel
    var scientist = Unit.new("scientist_001", "Dr. Test")
    scientist.role = "scientist"
    scientist.race = "human"
    
    var engineer = Unit.new("engineer_001", "Tech Test")
    engineer.role = "engineer"
    engineer.race = "human"
    
    assert(base.add_personnel(scientist))
    assert(base.add_personnel(engineer))
    
    print("Added personnel: ", base.personnel.size())
    
    # Test personnel queries
    var scientists = base.get_scientists()
    var engineers = base.get_engineers()
    
    print("Scientists: ", scientists.size())
    print("Engineers: ", engineers.size())
    
    assert(scientists.size() == 1)
    assert(engineers.size() == 1)

func test_research_integration():
    print("\n--- Testing Research Integration ---")
    
    # Test research manager initialization
    var research_projects = ResearchManager.get_all_research_projects()
    print("Available research projects: ", research_projects.size())
    
    # Test basic research availability
    var basic_research_available = ResearchManager.can_start_research("basic_research")
    print("Basic research available: ", basic_research_available)
    
    # This should be true since basic research has no prerequisites
    assert(basic_research_available)

func _process(delta):
    # Exit after a short time
    if Time.get_ticks_msec() > 2000:  # 2 seconds
        get_tree().quit()
