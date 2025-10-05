#!/usr/bin/env python3
"""
Geoscape Harness Validation Tests
Tests the headless harness for consistency and correctness
"""

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

def run_harness_test(days=30, seed=12345, export_path=None):
    """Run a single harness test and return the results"""
    if export_path is None:
        export_path = tempfile.mkdtemp()

    cmd = [
        r"c:\Users\tombl\Documents\AlienFall\Godot\Godot_v4.4.1-stable_win64.exe",
        "--script", "res://scripts/harness/geoscape_headless_harness.gd",
        "--days", str(days),
        "--seed", str(seed),
        "--export", f"user://{export_path}/"
    ]

    result = subprocess.run(
        cmd,
        cwd=r"c:\Users\tombl\Documents\AlienFall\GodotProject",
        capture_output=True,
        text=True
    )

    return result, export_path

def test_deterministic_behavior():
    """Test that the same seed produces identical results"""
    print("Testing deterministic behavior...")

    # Run two simulations with the same seed
    result1, path1 = run_harness_test(seed=12345)
    result2, path2 = run_harness_test(seed=12345)

    if result1.returncode != 0 or result2.returncode != 0:
        print("ERROR: One or both simulations failed")
        return False

    # Compare outputs
    if result1.stdout == result2.stdout:
        print("✓ Deterministic behavior confirmed - identical outputs")
        return True
    else:
        print("✗ Non-deterministic behavior detected - outputs differ")
        print("Output 1 length:", len(result1.stdout))
        print("Output 2 length:", len(result2.stdout))
        return False

def test_different_seeds():
    """Test that different seeds produce different results"""
    print("Testing different seeds...")

    result1, path1 = run_harness_test(seed=12345)
    result2, path2 = run_harness_test(seed=54321)

    if result1.returncode != 0 or result2.returncode != 0:
        print("ERROR: One or both simulations failed")
        return False

    if result1.stdout != result2.stdout:
        print("✓ Different seeds produce different results")
        return True
    else:
        print("✗ Different seeds produced identical results (unexpected)")
        return False

def test_output_files():
    """Test that output files are created correctly"""
    print("Testing output file generation...")

    result, export_path = run_harness_test()

    if result.returncode != 0:
        print("ERROR: Simulation failed")
        return False

    # Check if output files exist
    json_file = Path(export_path) / "geoscape_simulation_12345_30days.json"
    csv_file = Path(export_path) / "summary_12345_30days.csv"

    json_exists = json_file.exists()
    csv_exists = csv_file.exists()

    if json_exists and csv_exists:
        print("✓ Output files created successfully")
        print(f"  JSON: {json_file}")
        print(f"  CSV: {csv_file}")

        # Validate JSON structure
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)

            required_keys = ["simulation_config", "final_state", "mission_timeline", "funding_history"]
            missing_keys = [key for key in required_keys if key not in data]

            if not missing_keys:
                print("✓ JSON structure is valid")
                return True
            else:
                print(f"✗ JSON missing required keys: {missing_keys}")
                return False

        except json.JSONDecodeError as e:
            print(f"✗ JSON file is not valid: {e}")
            return False

    else:
        print("✗ Output files not created")
        print(f"  JSON exists: {json_exists}")
        print(f"  CSV exists: {csv_exists}")
        return False

def test_performance():
    """Test performance metrics"""
    print("Testing performance...")

    import time
    start_time = time.time()

    result, export_path = run_harness_test(days=60)

    end_time = time.time()
    total_time = end_time - start_time

    if result.returncode != 0:
        print("ERROR: Simulation failed")
        return False

    print(".2f")
    print(".2f")

    # Performance should be reasonable (less than 30 seconds for 60 days)
    if total_time < 30.0:
        print("✓ Performance is acceptable")
        return True
    else:
        print("✗ Performance is too slow")
        return False

def main():
    """Run all validation tests"""
    print("=== Geoscape Harness Validation Tests ===\n")

    tests = [
        ("Deterministic Behavior", test_deterministic_behavior),
        ("Different Seeds", test_different_seeds),
        ("Output Files", test_output_files),
        ("Performance", test_performance)
    ]

    results = []
    for test_name, test_func in tests:
        print(f"\n--- {test_name} ---")
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"✗ Test failed with exception: {e}")
            results.append((test_name, False))

    # Summary
    print("\n=== Test Summary ===")
    passed = 0
    total = len(results)

    for test_name, result in results:
        status = "PASS" if result else "FAIL"
        print(f"{test_name}: {status}")
        if result:
            passed += 1

    print(f"\nPassed: {passed}/{total}")

    if passed == total:
        print("🎉 All tests passed!")
        return 0
    else:
        print("❌ Some tests failed")
        return 1

if __name__ == "__main__":
    sys.exit(main())
