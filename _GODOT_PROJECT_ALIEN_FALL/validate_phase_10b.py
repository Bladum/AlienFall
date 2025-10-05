#!/usr/bin/env python3
"""
Phase 10B Test Validation Script

Validates that the battle smoke test harness is working correctly.
This script performs basic functionality tests and reports results.
"""

import os
import sys
import json
import subprocess
import hashlib
from pathlib import Path
from typing import Dict, List, Any

class TestValidator:
    def __init__(self, workspace_root: str):
        self.workspace_root = Path(workspace_root)
        self.godot_project = self.workspace_root / "GodotProject"
        self.test_output = self.godot_project / "test_validation_output"
        self.test_output.mkdir(exist_ok=True)

    def find_godot_executable(self) -> Path:
        """Find the Godot executable in the project directory."""
        godot_exe = self.godot_project / "Godot" / "Godot_v4.4.1-stable_win64_console.exe"
        if godot_exe.exists():
            return godot_exe

        # Try alternative locations
        alternatives = [
            self.workspace_root / "Godot" / "Godot_v4.4.1-stable_win64_console.exe",
            self.workspace_root / "Godot_v4.4.1-stable_win64_console.exe"
        ]

        for alt in alternatives:
            if alt.exists():
                return alt

        raise FileNotFoundError("Godot executable not found in expected locations")

    def run_battle_generation(self, seed: int, terrain: str) -> Dict[str, Any]:
        """Run a single battle generation and return results."""
        godot_exe = self.find_godot_executable()
        script_path = self.godot_project / "battle_smoke_test.gd"

        cmd = [
            str(godot_exe),
            "--headless",
            "--script", str(script_path),
            "--seed", str(seed),
            "--terrain", terrain,
            "--export", str(self.test_output)
        ]

        print(f"Running: {' '.join(cmd)}")

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=str(self.godot_project)
            )

            return {
                "success": result.returncode == 0,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "returncode": result.returncode
            }
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "error": "Command timed out",
                "stdout": "",
                "stderr": "",
                "returncode": -1
            }

    def validate_outputs(self, seed: int, terrain: str) -> Dict[str, Any]:
        """Validate that expected output files were created and are valid."""
        base_name = f"battle_{seed}_{terrain}"

        expected_files = [
            f"{base_name}.json",
            f"{base_name}.txt",
            f"telemetry_{seed}_{terrain}.json"
        ]

        results = {}

        for filename in expected_files:
            filepath = self.test_output / filename
            if filepath.exists():
                try:
                    if filename.endswith('.json'):
                        with open(filepath, 'r') as f:
                            data = json.load(f)
                        results[filename] = {
                            "exists": True,
                            "valid": True,
                            "size": filepath.stat().st_size,
                            "data_keys": list(data.keys()) if isinstance(data, dict) else None
                        }
                    else:
                        with open(filepath, 'r') as f:
                            content = f.read()
                        results[filename] = {
                            "exists": True,
                            "valid": True,
                            "size": filepath.stat().st_size,
                            "lines": len(content.split('\n'))
                        }
                except Exception as e:
                    results[filename] = {
                        "exists": True,
                        "valid": False,
                        "error": str(e)
                    }
            else:
                results[filename] = {
                    "exists": False,
                    "valid": False
                }

        return results

    def test_determinism(self, seed: int, terrain: str, runs: int = 3) -> Dict[str, Any]:
        """Test that multiple runs with same seed produce identical results."""
        results = []

        for i in range(runs):
            output_dir = self.test_output / f"determinism_test_{i}"
            output_dir.mkdir(exist_ok=True)

            # Run generation
            run_result = self.run_battle_generation(seed, terrain)
            if not run_result["success"]:
                return {"success": False, "error": f"Run {i} failed", "details": run_result}

            # Validate outputs
            validation = self.validate_outputs(seed, terrain)
            results.append(validation)

            # Move files to separate directory
            for filename in [f"battle_{seed}_{terrain}.json", f"telemetry_{seed}_{terrain}.json"]:
                src = self.test_output / filename
                dst = output_dir / filename
                if src.exists():
                    src.rename(dst)

        # Compare results
        if len(results) < 2:
            return {"success": False, "error": "Not enough successful runs"}

        # Check that all runs produced valid outputs
        for i, result in enumerate(results):
            json_file = f"battle_{seed}_{terrain}.json"
            if not result.get(json_file, {}).get("valid", False):
                return {"success": False, "error": f"Run {i} produced invalid JSON"}

        # Compare topology hashes from telemetry
        hashes = []
        for i in range(runs):
            telemetry_file = self.test_output / f"determinism_test_{i}" / f"telemetry_{seed}_{terrain}.json"
            if telemetry_file.exists():
                try:
                    with open(telemetry_file, 'r') as f:
                        data = json.load(f)
                    if "topology_hash" in data:
                        hashes.append(data["topology_hash"])
                except:
                    pass

        deterministic = len(set(hashes)) == 1 if hashes else False

        return {
            "success": deterministic,
            "hashes": hashes,
            "deterministic": deterministic,
            "runs": runs
        }

    def run_validation_tests(self) -> Dict[str, Any]:
        """Run all validation tests."""
        print("=== Phase 10B Test Validation ===\n")

        test_results = {
            "godot_found": False,
            "basic_generation": False,
            "output_validation": False,
            "determinism": False,
            "details": {}
        }

        try:
            # Test 1: Find Godot executable
            print("1. Finding Godot executable...")
            godot_exe = self.find_godot_executable()
            test_results["godot_found"] = True
            test_results["details"]["godot_path"] = str(godot_exe)
            print(f"   ✓ Found: {godot_exe}")

        except FileNotFoundError as e:
            print(f"   ✗ Failed: {e}")
            return test_results

        # Test 2: Basic battle generation
        print("\n2. Testing basic battle generation...")
        seed, terrain = 12345, "urban"
        generation_result = self.run_battle_generation(seed, terrain)

        if generation_result["success"]:
            test_results["basic_generation"] = True
            print("   ✓ Generation successful")
        else:
            print(f"   ✗ Generation failed: {generation_result.get('error', 'Unknown error')}")
            test_results["details"]["generation_error"] = generation_result
            return test_results

        # Test 3: Output validation
        print("\n3. Validating output files...")
        validation_result = self.validate_outputs(seed, terrain)
        all_valid = all(result.get("valid", False) for result in validation_result.values())

        if all_valid:
            test_results["output_validation"] = True
            print("   ✓ All output files valid")
            test_results["details"]["output_files"] = validation_result
        else:
            print("   ✗ Some output files invalid")
            test_results["details"]["output_validation"] = validation_result

        # Test 4: Determinism test
        print("\n4. Testing determinism...")
        determinism_result = self.test_determinism(seed, terrain, runs=3)

        if determinism_result["success"]:
            test_results["determinism"] = True
            print("   ✓ Deterministic generation confirmed")
        else:
            print("   ✗ Determinism test failed")
            test_results["details"]["determinism"] = determinism_result

        # Summary
        print("\n=== Test Results ===")
        passed = sum([test_results["godot_found"], test_results["basic_generation"],
                     test_results["output_validation"], test_results["determinism"]])
        total = 4

        print(f"Passed: {passed}/{total}")

        if passed == total:
            print("🎉 All tests passed! Phase 10B harness is ready.")
        else:
            print("⚠️  Some tests failed. Check details above.")

        return test_results

def main():
    """Main entry point."""
    workspace_root = os.getcwd()

    # Allow override via command line
    if len(sys.argv) > 1:
        workspace_root = sys.argv[1]

    validator = TestValidator(workspace_root)
    results = validator.run_validation_tests()

    # Exit with appropriate code
    if results.get("godot_found") and results.get("basic_generation"):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
