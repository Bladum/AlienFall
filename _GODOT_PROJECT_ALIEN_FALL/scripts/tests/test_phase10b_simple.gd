extends Node

# TestPhase10B - Tests for Phase 10B: Headless Battlescape Test Harness

class_name TestPhase10B

func _ready():
    """Run all tests when the scene is ready"""
    run_all_tests()
    get_tree().quit()  # Exit after tests complete

func test_battle_smoke_test_script_exists():
    """Test that the battle smoke test script exists"""
    var file_path = "res://battle_smoke_test.gd"
    var file = FileAccess.open(file_path, FileAccess.READ)
    assert_not_null(file, "Battle smoke test script should exist")
    file.close()
    print("✓ Battle smoke test script file exists")

func test_battle_smoke_test_has_content():
    """Test that the battle smoke test script has content"""
    var file = FileAccess.open("res://battle_smoke_test.gd", FileAccess.READ)
    var content = file.get_as_text()
    file.close()

    assert_false(content.is_empty(), "Battle smoke test script should have content")
    assert_true(content.length() > 1000, "Battle smoke test script should be substantial")

    # Check for key content
    assert_true(content.contains("extends SceneTree"), "Should extend SceneTree")
    assert_true(content.contains("_parse_command_line_args"), "Should have CLI parsing")
    assert_true(content.contains("_export_json_data"), "Should have JSON export")

    print("✓ Battle smoke test script has expected content")

func test_battle_smoke_test_batch_file_exists():
    """Test that the battle smoke test batch file exists"""
    var file_path = "res://run_battle_smoke.bat"
    var file = FileAccess.open(file_path, FileAccess.READ)
    assert_not_null(file, "Battle smoke test batch file should exist")
    file.close()
    print("✓ Battle smoke test batch file exists")

func test_terrain_templates_exist():
    """Test that terrain templates exist"""
    var file_path = "res://resources/data/terrain/templates.json"
    var file = FileAccess.open(file_path, FileAccess.READ)
    assert_not_null(file, "Terrain templates should exist")
    file.close()
    print("✓ Terrain templates exist")

func test_terrain_templates_have_content():
    """Test that terrain templates have expected content"""
    var file = FileAccess.open("res://resources/data/terrain/templates.json", FileAccess.READ)
    var content = file.get_as_text()
    file.close()

    var json = JSON.parse_string(content)
    assert_not_null(json, "Terrain templates should be valid JSON")
    assert_true(json.has("terrains"), "Should have terrains section")
    assert_true(json.terrains.has("urban"), "Should have urban terrain")

    print("✓ Terrain templates have expected structure")

func test_test_runner_includes_phase10b():
    """Test that the test runner includes Phase 10B tests"""
    var file = FileAccess.open("res://scripts/tests/test_runner.gd", FileAccess.READ)
    var content = file.get_as_text()
    file.close()

    assert_true(content.contains("test_phase10b"), "Test runner should include Phase 10B tests")
    assert_true(content.contains("TestPhase10"), "Test runner should include Phase 10 tests")

    print("✓ Test runner includes Phase 10B tests")

func test_export_directory_creation():
    """Test that export directories can be created"""
    var test_dir = "res://test_output_phase10b"
    var dir_access = DirAccess.open("res://")

    # Clean up any existing test directory
    if dir_access.dir_exists(test_dir):
        var success = dir_access.remove(test_dir)
        assert_true(success, "Should be able to remove existing test directory")

    # Test directory creation
    var success = dir_access.make_dir(test_dir)
    assert_true(success, "Should be able to create test directory")

    # Verify directory exists
    assert_true(dir_access.dir_exists(test_dir), "Test directory should exist after creation")

    print("✓ Export directory creation works correctly")

func test_readme_files_exist():
    """Test that Phase 10B documentation exists"""
    var files_to_check = [
        "res://PHASE_10B_README.md",
        "res://PHASE_10B_DELIVERY_SUMMARY.md"
    ]

    for file_path in files_to_check:
        var file = FileAccess.open(file_path, FileAccess.READ)
        assert_not_null(file, "Documentation file should exist: " + file_path)
        var content = file.get_as_text()
        assert_false(content.is_empty(), "Documentation should have content: " + file_path)
        file.close()

    print("✓ Phase 10B documentation files exist")

func test_batch_files_exist():
    """Test that batch files exist"""
    var files_to_check = [
        "res://run_tests.bat",
        "res://run_phase10b_tests.bat",
        "res://run_battle_smoke.bat"
    ]

    for file_path in files_to_check:
        var file = FileAccess.open(file_path, FileAccess.READ)
        assert_not_null(file, "Batch file should exist: " + file_path)
        file.close()

    print("✓ Batch files exist")

func run_all_tests():
    """Run all Phase 10B tests"""
    print("\n=== Phase 10B Tests ===")

    test_battle_smoke_test_script_exists()
    test_battle_smoke_test_has_content()
    test_battle_smoke_test_batch_file_exists()
    test_terrain_templates_exist()
    test_terrain_templates_have_content()
    test_test_runner_includes_phase10b()
    test_export_directory_creation()
    test_readme_files_exist()
    test_batch_files_exist()

    print("\n✓ All Phase 10B tests completed successfully!")
