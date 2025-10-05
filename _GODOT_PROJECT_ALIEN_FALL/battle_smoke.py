#!/usr/bin/env python3
"""
Battle Smoke Test Harness - Phase 10B
Backend-only CLI to generate and evaluate battles from seeds for automated debugging.

Usage: python battle_smoke.py --seed 12345 --terrain urban --export out/
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(
        description="AlienFall Battle Smoke Test Harness",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python battle_smoke.py --seed 12345 --terrain urban --export out/
  python battle_smoke.py --seed 99999 --terrain forest --width 25 --height 25 --export results/

Available terrains: urban, forest, desert, industrial
        """
    )

    parser.add_argument(
        "--seed", type=int, default=12345,
        help="RNG seed for deterministic generation (default: 12345)"
    )
    parser.add_argument(
        "--terrain", type=str, default="urban",
        help="Terrain template ID (default: urban)"
    )
    parser.add_argument(
        "--export", type=str, default="out/",
        help="Export directory path (default: out/)"
    )
    parser.add_argument(
        "--width", type=int, default=20,
        help="Map width (default: 20)"
    )
    parser.add_argument(
        "--height", type=int, default=20,
        help="Map height (default: 20)"
    )
    parser.add_argument(
        "--levels", type=int, default=1,
        help="Map levels (default: 1)"
    )
    parser.add_argument(
        "--godot-path", type=str, default=None,
        help="Path to Godot executable (auto-detect if not specified)"
    )
    parser.add_argument(
        "--quiet", action="store_true",
        help="Suppress verbose output"
    )

    args = parser.parse_args()

    print("=== AlienFall Battle Smoke Test Harness ===")
    print(f"Seed: {args.seed}")
    print(f"Terrain: {args.terrain}")
    print(f"Export path: {args.export}")
    print(f"Map size: {args.width}x{args.height}x{args.levels}")
    print()

    # Find Godot executable
    godot_path = find_godot_executable(args.godot_path)
    if not godot_path:
        print("ERROR: Could not find Godot executable")
        print("Please specify --godot-path or ensure Godot is in PATH")
        return 1

    print(f"Using Godot: {godot_path}")

    # Create export directory
    export_path = Path(args.export)
    export_path.mkdir(parents=True, exist_ok=True)

    # Build Godot command
    cmd = [
        str(godot_path),
        "--headless",
        "--script", "battle_smoke_test.gd",
        "--seed", str(args.seed),
        "--terrain", args.terrain,
        "--export", str(export_path),
        "--width", str(args.width),
        "--height", str(args.height),
        "--levels", str(args.levels)
    ]

    if not args.quiet:
        print(f"Running command: {' '.join(cmd)}")
    print()

    # Run the test
    try:
        result = subprocess.run(cmd, cwd=Path(__file__).parent, capture_output=True, text=True)

        if not args.quiet:
            if result.stdout:
                print("STDOUT:")
                print(result.stdout)
            if result.stderr:
                print("STDERR:")
                print(result.stderr)

        if result.returncode == 0:
            print("✓ Battle smoke test completed successfully")

            # List generated files
            print("\nGenerated files:")
            for file_path in export_path.glob("*"):
                if file_path.is_file():
                    size = file_path.stat().st_size
                    print(f"  {file_path.name} ({size} bytes)")

            # Validate outputs
            validation_result = validate_outputs(export_path, args.seed, args.terrain)
            if validation_result:
                print("✓ Output validation passed")
            else:
                print("✗ Output validation failed")
                return 1

            return 0
        else:
            print(f"✗ Battle smoke test failed with return code {result.returncode}")
            return result.returncode

    except Exception as e:
        print(f"ERROR: Failed to run battle smoke test: {e}")
        return 1

def find_godot_executable(specified_path=None):
    """Find Godot executable"""
    if specified_path:
        path = Path(specified_path)
        if path.exists():
            return path

    # Try common locations
    candidates = [
        Path("Godot_v4.4.1-stable_win64_console.exe"),
        Path("Godot_v4.4.1-stable_win64.exe"),
        Path("../Godot/Godot_v4.4.1-stable_win64_console.exe"),
        Path("../Godot/Godot_v4.4.1-stable_win64.exe"),
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    # Try PATH
    try:
        result = subprocess.run(["where", "godot"], capture_output=True, text=True)
        if result.returncode == 0:
            return Path(result.stdout.strip().split('\n')[0])
    except:
        pass

    return None

def validate_outputs(export_path, seed, terrain):
    """Validate generated outputs"""
    try:
        # Check for required files
        json_file = export_path / f"battle_{seed}_{terrain}.json"
        txt_file = export_path / f"battle_{seed}_{terrain}.txt"
        telemetry_file = export_path / f"telemetry_{seed}_{terrain}.json"

        if not json_file.exists():
            print(f"✗ Missing JSON file: {json_file}")
            return False

        if not txt_file.exists():
            print(f"✗ Missing ASCII file: {txt_file}")
            return False

        if not telemetry_file.exists():
            print(f"✗ Missing telemetry file: {telemetry_file}")
            return False

        # Validate JSON structure
        with open(json_file, 'r') as f:
            battle_data = json.load(f)

        required_fields = [
            "battle_id", "terrain_id", "map_width", "map_height",
            "topology", "topology_hash", "player_units", "enemy_units"
        ]

        for field in required_fields:
            if field not in battle_data:
                print(f"✗ Missing required field in JSON: {field}")
                return False

        # Validate telemetry
        with open(telemetry_file, 'r') as f:
            telemetry = json.load(f)

        if "seed_provenance" not in telemetry:
            print("✗ Missing seed_provenance in telemetry")
            return False

        if telemetry["seed_provenance"]["original_seed"] != seed:
            print("✗ Seed mismatch in telemetry")
            return False

        # Check ASCII file has content
        with open(txt_file, 'r') as f:
            content = f.read()
            if len(content) < 100:
                print("✗ ASCII file seems too small")
                return False

        return True

    except Exception as e:
        print(f"✗ Validation error: {e}")
        return False

if __name__ == "__main__":
    sys.exit(main())
