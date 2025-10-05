#!/usr/bin/env python3
"""
Geoscape Headless Harness Runner
Python wrapper for running geoscape simulations and analyzing results

Usage:
    python geoscape_harness.py --days 60 --seed 12345 --export results/
    python geoscape_harness.py --compare results1/ results2/
    python geoscape_harness.py --benchmark --iterations 5
"""

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Any

class GeoscapeHarnessRunner:
    def __init__(self):
        self.godot_path = r"c:\Users\tombl\Documents\AlienFall\Godot\Godot_v4.4.1-stable_win64.exe"
        self.project_path = r"c:\Users\tombl\Documents\AlienFall\GodotProject"
        self.harness_script = "res://scripts/harness/geoscape_headless_harness.gd"

    def run_simulation(self, days: int = 30, seed: int = 12345, export_path: str = "user://geoscape_test_results/") -> Dict[str, Any]:
        """Run a single geoscape simulation"""
        print(f"Running simulation: {days} days, seed {seed}")

        # Create a temporary main scene that runs our harness
        harness_scene = f"""
extends Node

func _ready():
    var harness = load("res://scripts/harness/geoscape_headless_harness.gd").new()
    harness.days_to_simulate = {days}
    harness.random_seed = {seed}
    harness.export_path = "{export_path}"
    add_child(harness)
"""

        # Write temporary scene file
        temp_scene_path = os.path.join(self.project_path, "temp_harness_scene.tscn")
        with open(temp_scene_path, 'w') as f:
            f.write(harness_scene)

        cmd = [
            self.godot_path,
            "--path", ".",
            temp_scene_path
        ]

        start_time = time.time()
        result = subprocess.run(cmd, cwd=self.project_path, capture_output=True, text=True)
        end_time = time.time()

        # Clean up temp file
        try:
            os.remove(temp_scene_path)
        except:
            pass

        if result.returncode != 0:
            print(f"ERROR: Simulation failed with return code {result.returncode}")
            print("STDOUT:", result.stdout)
            print("STDERR:", result.stderr)
            return None

        execution_time = end_time - start_time
        print(".2f")

        # Parse the output to extract results
        return self._parse_simulation_output(result.stdout, execution_time)

    def run_multiple_simulations(self, configs: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Run multiple simulations with different configurations"""
        results = []

        for i, config in enumerate(configs):
            print(f"\nRunning simulation {i+1}/{len(configs)}")
            result = self.run_simulation(**config)
            if result:
                results.append(result)

        return results

    def compare_simulations(self, path1: str, path2: str) -> Dict[str, Any]:
        """Compare two simulation result sets"""
        print(f"Comparing simulations: {path1} vs {path2}")

        results1 = self._load_results(path1)
        results2 = self._load_results(path2)

        if not results1 or not results2:
            return {"error": "Failed to load one or both result sets"}

        return self._compare_results(results1, results2)

    def run_benchmark(self, iterations: int = 5, days: int = 30) -> Dict[str, Any]:
        """Run benchmark tests with multiple iterations"""
        print(f"Running benchmark: {iterations} iterations of {days} days each")

        execution_times = []
        results = []

        for i in range(iterations):
            seed = 1000 + i  # Different seed for each iteration
            result = self.run_simulation(days=days, seed=seed)
            if result:
                execution_times.append(result["execution_time"])
                results.append(result)

        if not execution_times:
            return {"error": "No successful benchmark runs"}

        avg_time = sum(execution_times) / len(execution_times)
        min_time = min(execution_times)
        max_time = max(execution_times)

        return {
            "benchmark_results": {
                "iterations": iterations,
                "days_per_simulation": days,
                "average_time": avg_time,
                "min_time": min_time,
                "max_time": max_time,
                "total_time": sum(execution_times)
            },
            "individual_results": results
        }

    def _parse_simulation_output(self, output: str, execution_time: float) -> Dict[str, Any]:
        """Parse the simulation output to extract key metrics"""
        lines = output.split('\n')
        result = {
            "execution_time": execution_time,
            "days_simulated": 0,
            "final_day": 0,
            "final_month": 0,
            "final_year": 0,
            "final_funding": 0,
            "missions_created": 0,
            "ufos_detected": 0,
            "events_logged": 0
        }

        for line in lines:
            line = line.strip()
            if "Days to simulate:" in line:
                result["days_simulated"] = int(line.split(":")[1].strip())
            elif "Final state" in line:
                # Parse final state if available in output
                pass
            elif "Mission created" in line:
                result["missions_created"] += 1
            elif "UFO detected" in line:
                result["ufos_detected"] += 1

        return result

    def _load_results(self, path: str) -> Dict[str, Any]:
        """Load simulation results from JSON file"""
        try:
            with open(path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading results from {path}: {e}")
            return None

    def _compare_results(self, results1: Dict[str, Any], results2: Dict[str, Any]) -> Dict[str, Any]:
        """Compare two sets of simulation results"""
        comparison = {
            "identical": True,
            "differences": [],
            "summary": {}
        }

        # Compare key metrics
        key_metrics = [
            "final_state.current_day",
            "final_state.total_funding",
            "final_state.active_missions",
            "final_state.discovered_ufos"
        ]

        for metric in key_metrics:
            val1 = self._get_nested_value(results1, metric)
            val2 = self._get_nested_value(results2, metric)

            if val1 != val2:
                comparison["identical"] = False
                comparison["differences"].append({
                    "metric": metric,
                    "value1": val1,
                    "value2": val2,
                    "difference": val2 - val1 if isinstance(val1, (int, float)) and isinstance(val2, (int, float)) else "N/A"
                })

        return comparison

    def _get_nested_value(self, data: Dict[str, Any], path: str):
        """Get a nested value from a dictionary using dot notation"""
        keys = path.split('.')
        current = data

        try:
            for key in keys:
                current = current[key]
            return current
        except (KeyError, TypeError):
            return None

def main():
    parser = argparse.ArgumentParser(description="Geoscape Headless Harness Runner")
    parser.add_argument("--days", type=int, default=30, help="Number of days to simulate")
    parser.add_argument("--seed", type=int, default=12345, help="Random seed for simulation")
    parser.add_argument("--export", default="user://geoscape_test_results/", help="Export path for results")
    parser.add_argument("--compare", nargs=2, help="Compare two result directories")
    parser.add_argument("--benchmark", action="store_true", help="Run benchmark tests")
    parser.add_argument("--iterations", type=int, default=5, help="Number of benchmark iterations")

    args = parser.parse_args()

    runner = GeoscapeHarnessRunner()

    if args.compare:
        result = runner.compare_simulations(args.compare[0], args.compare[1])
        print(json.dumps(result, indent=2))
    elif args.benchmark:
        result = runner.run_benchmark(iterations=args.iterations, days=args.days)
        print(json.dumps(result, indent=2))
    else:
        result = runner.run_simulation(days=args.days, seed=args.seed, export_path=args.export)
        if result:
            print(json.dumps(result, indent=2))
        else:
            print("Simulation failed")
            sys.exit(1)

if __name__ == "__main__":
    main()
