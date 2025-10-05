#!/usr/bin/env python3
"""
Phase 10B Manual Validation Script
Validates that all Phase 10B deliverables are in place and correct.
"""

import os
import sys
import json
from pathlib import Path

def validate_file_exists(filepath, description):
    """Validate that a file exists."""
    if filepath.exists():
        print(f"✓ {description}: {filepath.name}")
        return True
    else:
        print(f"✗ {description}: {filepath.name} - MISSING")
        return False

def validate_file_content(filepath, expected_content_checks, description):
    """Validate file content contains expected strings."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        all_checks_pass = True
        for check in expected_content_checks:
            if check not in content:
                print(f"✗ {description}: Missing '{check}' in {filepath.name}")
                all_checks_pass = False

        if all_checks_pass:
            print(f"✓ {description}: Content validation passed for {filepath.name}")

        return all_checks_pass
    except Exception as e:
        print(f"✗ {description}: Error reading {filepath.name} - {e}")
        return False

def validate_json_file(filepath, expected_keys, description):
    """Validate JSON file structure."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        all_keys_present = True
        for key in expected_keys:
            if key not in data:
                print(f"✗ {description}: Missing key '{key}' in {filepath.name}")
                all_keys_present = False

        if all_keys_present:
            print(f"✓ {description}: JSON structure valid for {filepath.name}")

        return all_keys_present
    except Exception as e:
        print(f"✗ {description}: Error parsing JSON in {filepath.name} - {e}")
        return False

def main():
    """Main validation function."""
    print("=== Phase 10B Manual Validation ===\n")

    workspace_root = Path(__file__).parent
    godot_project = workspace_root

    validation_results = []

    # 1. Core script files
    print("1. Core Script Files:")
    files_to_check = [
        (godot_project / "battle_smoke_test.gd", "Battle smoke test script"),
        (godot_project / "scripts/tests/test_phase10b_simple.gd", "Phase 10B test script"),
        (godot_project / "scripts/tests/test_runner.gd", "Test runner script"),
    ]

    for filepath, description in files_to_check:
        validation_results.append(validate_file_exists(filepath, description))

    # 2. Batch files
    print("\n2. Batch Files:")
    batch_files = [
        (godot_project / "run_battle_smoke.bat", "Battle smoke test runner"),
        (godot_project / "run_phase10b_tests.bat", "Phase 10B test runner"),
        (godot_project / "run_tests.bat", "Main test runner"),
    ]

    for filepath, description in batch_files:
        validation_results.append(validate_file_exists(filepath, description))

    # 3. Documentation files
    print("\n3. Documentation Files:")
    doc_files = [
        (godot_project / "PHASE_10B_README.md", "Phase 10B README"),
        (godot_project / "PHASE_10B_GODOT_README.md", "Phase 10B Godot README"),
        (godot_project / "PHASE_10B_DELIVERY_SUMMARY.md", "Phase 10B delivery summary"),
    ]

    for filepath, description in doc_files:
        exists = validate_file_exists(filepath, description)
        validation_results.append(exists)

        if exists:
            # Check for key content in documentation
            content_checks = ["Phase 10B", "Headless", "Test Harness"]
            validation_results.append(validate_file_content(filepath, content_checks, f"{description} content"))

    # 4. Terrain data
    print("\n4. Terrain Data:")
    terrain_file = godot_project / "resources/data/terrain/templates.json"
    exists = validate_file_exists(terrain_file, "Terrain templates")
    validation_results.append(exists)

    if exists:
        # Validate JSON structure
        expected_keys = ["terrains"]
        validation_results.append(validate_json_file(terrain_file, expected_keys, "Terrain templates JSON"))

        # Check for specific terrains
        try:
            with open(terrain_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            terrains = data.get("terrains", {})
            expected_terrains = ["urban", "forest", "desert", "industrial"]

            for terrain in expected_terrains:
                if terrain in terrains:
                    print(f"✓ Terrain '{terrain}' found in templates")
                else:
                    print(f"✗ Terrain '{terrain}' missing from templates")
                    validation_results.append(False)
        except:
            validation_results.append(False)

    # 5. Scene files
    print("\n5. Scene Files:")
    scene_files = [
        (godot_project / "phase10b_test.tscn", "Phase 10B test scene"),
        (godot_project / "test_runner.tscn", "Main test runner scene"),
    ]

    for filepath, description in scene_files:
        validation_results.append(validate_file_exists(filepath, description))

    # 6. Test runner integration
    print("\n6. Test Runner Integration:")
    test_runner = godot_project / "scripts/tests/test_runner.gd"
    if test_runner.exists():
        content_checks = ["test_phase10b", "TestPhase10"]
        validation_results.append(validate_file_content(test_runner, content_checks, "Test runner integration"))

    # Summary
    print("\n=== Validation Summary ===")
    total_checks = len(validation_results)
    passed_checks = sum(validation_results)

    print(f"Checks passed: {passed_checks}/{total_checks}")

    if passed_checks == total_checks:
        print("🎉 All Phase 10B deliverables validated successfully!")
        print("\nPhase 10B Status: ✅ COMPLETE")
        return 0
    else:
        print("⚠️  Some validation checks failed.")
        print("\nPhase 10B Status: ⚠️ ISSUES FOUND")
        return 1

if __name__ == "__main__":
    sys.exit(main())
