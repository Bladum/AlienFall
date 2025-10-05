#!/usr/bin/env python3
"""
Golden Snapshot Test Runner
Compares battle smoke test outputs against golden snapshots for regression testing.
"""

import argparse
import json
import filecmp
import difflib
from pathlib import Path
from battle_smoke import main as run_smoke_test

def main():
    parser = argparse.ArgumentParser(
        description="Golden Snapshot Test Runner for Battle Smoke Tests"
    )

    parser.add_argument(
        "--update-goldens", action="store_true",
        help="Update golden snapshots with current outputs"
    )
    parser.add_argument(
        "--test-seed", type=int, default=12345,
        help="Seed to use for testing (default: 12345)"
    )
    parser.add_argument(
        "--test-terrain", type=str, default="urban",
        help="Terrain to use for testing (default: urban)"
    )
    parser.add_argument(
        "--goldens-dir", type=str, default="goldens/",
        help="Directory containing golden snapshots (default: goldens/)"
    )
    parser.add_argument(
        "--output-dir", type=str, default="test_output/",
        help="Directory for test outputs (default: test_output/)"
    )

    args = parser.parse_args()

    print("=== Golden Snapshot Test Runner ===")
    print(f"Test seed: {args.test_seed}")
    print(f"Test terrain: {args.test_terrain}")
    print(f"Goldens dir: {args.goldens_dir}")
    print(f"Output dir: {args.output_dir}")
    print()

    goldens_path = Path(args.goldens_dir)
    output_path = Path(args.output_dir)

    if args.update_goldens:
        print("Updating golden snapshots...")
        success = update_goldens(args.test_seed, args.test_terrain, goldens_path, output_path)
    else:
        print("Running golden snapshot tests...")
        success = run_golden_tests(args.test_seed, args.test_terrain, goldens_path, output_path)

    return 0 if success else 1

def update_goldens(seed, terrain, goldens_path, output_path):
    """Update golden snapshots with current test outputs"""
    # Run smoke test to generate outputs
    print("Generating test outputs...")

    # Create output directory
    output_path.mkdir(parents=True, exist_ok=True)

    # Run the smoke test (we'll need to modify this to accept output path)
    # For now, manually run the test and copy files
    print("Please run the battle smoke test manually:")
    print(f"python battle_smoke.py --seed {seed} --terrain {terrain} --export {output_path}")
    print()
    print("Then copy the generated files to the goldens directory:")
    print(f"cp {output_path}/* {goldens_path}/")

    return True

def run_golden_tests(seed, terrain, goldens_path, output_path):
    """Run tests comparing against golden snapshots"""
    # Create output directory
    output_path.mkdir(parents=True, exist_ok=True)

    # Run smoke test to generate current outputs
    print("Generating current test outputs...")

    # We need to modify battle_smoke.py to accept custom output directory
    # For now, assume files are generated in output_path

    # Check if golden files exist
    golden_files = {
        "json": goldens_path / f"battle_{seed}_{terrain}.json",
        "txt": goldens_path / f"battle_{seed}_{terrain}.txt",
        "telemetry": goldens_path / f"telemetry_{seed}_{terrain}.json"
    }

    current_files = {
        "json": output_path / f"battle_{seed}_{terrain}.json",
        "txt": output_path / f"battle_{seed}_{terrain}.txt",
        "telemetry": output_path / f"telemetry_{seed}_{terrain}.json"
    }

    all_passed = True

    for file_type, golden_file in golden_files.items():
        current_file = current_files[file_type]

        if not golden_file.exists():
            print(f"✗ Missing golden file: {golden_file}")
            all_passed = False
            continue

        if not current_file.exists():
            print(f"✗ Missing current file: {current_file}")
            all_passed = False
            continue

        # Compare files
        if filecmp.cmp(golden_file, current_file, shallow=False):
            print(f"✓ {file_type.upper()} file matches golden snapshot")
        else:
            print(f"✗ {file_type.upper()} file differs from golden snapshot")
            show_diff(golden_file, current_file, file_type)
            all_passed = False

    return all_passed

def show_diff(golden_file, current_file, file_type):
    """Show differences between golden and current files"""
    try:
        with open(golden_file, 'r') as f:
            golden_content = f.readlines()

        with open(current_file, 'r') as f:
            current_content = f.readlines()

        if file_type == "json":
            # For JSON files, parse and compare structure
            try:
                golden_json = json.loads(''.join(golden_content))
                current_json = json.loads(''.join(current_content))

                # Compare topology hashes (most important for determinism)
                golden_hash = golden_json.get("topology_hash", "")
                current_hash = current_json.get("topology_hash", "")

                if golden_hash != current_hash:
                    print(f"  Topology hash mismatch:")
                    print(f"    Golden:  {golden_hash}")
                    print(f"    Current: {current_hash}")
                else:
                    print("  ✓ Topology hashes match")

            except json.JSONDecodeError as e:
                print(f"  JSON parsing error: {e}")
        else:
            # For text files, show unified diff
            diff = list(difflib.unified_diff(
                golden_content, current_content,
                fromfile=str(golden_file),
                tofile=str(current_file),
                lineterm=''
            ))

            if len(diff) > 20:  # Limit diff output
                print("  Diff (first 20 lines):")
                for line in diff[:20]:
                    print(f"    {line}")
                print("    ... (truncated)")
            else:
                print("  Diff:")
                for line in diff:
                    print(f"    {line}")

    except Exception as e:
        print(f"  Error showing diff: {e}")

if __name__ == "__main__":
    import sys
    sys.exit(main())
