#!/usr/bin/env -S godot --headless --script

# Battle Smoke Test Harness - Phase 10B
# Headless CLI tool for generating and evaluating battles from seeds
# Usage: godot --headless --script battle_smoke_test.gd --seed 12345 --terrain urban --export out/

extends SceneTree

# Command line arguments
var seed_value: int = 12345
var terrain_id: String = "urban"
var export_path: String = "out/"
var map_width: int = 20
var map_height: int = 20
var map_levels: int = 1

func _init():
    # Parse command line arguments
    _parse_command_line_args()

    print("\n=== AlienFall Battle Smoke Test Harness ===")
    print("Seed: ", seed_value)
    print("Terrain: ", terrain_id)
    print("Export path: ", export_path)
    print("Map size: ", map_width, "x", map_height, "x", map_levels)

    # Run the smoke test
    var success = run_smoke_test()

    if success:
        print("\n✓ Smoke test completed successfully")
        quit()
    else:
        print("\n✗ Smoke test failed")
        quit(1)

func _parse_command_line_args():
    """Parse command line arguments"""
    var args = OS.get_cmdline_args()

    for i in range(args.size()):
        var arg = args[i]
        match arg:
            "--seed":
                if i + 1 < args.size():
                    seed_value = args[i + 1].to_int()
            "--terrain":
                if i + 1 < args.size():
                    terrain_id = args[i + 1]
            "--export":
                if i + 1 < args.size():
                    export_path = args[i + 1]
            "--width":
                if i + 1 < args.size():
                    map_width = args[i + 1].to_int()
            "--height":
                if i + 1 < args.size():
                    map_height = args[i + 1].to_int()
            "--levels":
                if i + 1 < args.size():
                    map_levels = args[i + 1].to_int()

func run_smoke_test() -> bool:
    """Run the battle smoke test"""
    print("\n--- Running Battle Smoke Test ---")

    # Create deployment data
    var deployment = {
        "player_units": [
            {"id": "soldier_1", "type": "human_soldier", "position": [5, 5]},
            {"id": "soldier_2", "type": "human_soldier", "position": [6, 5]},
            {"id": "soldier_3", "type": "human_soldier", "position": [7, 5]}
        ],
        "enemy_units": [
            {"id": "sectoid_1", "type": "sectoid_warrior", "position": [15, 15]},
            {"id": "sectoid_2", "type": "sectoid_warrior", "position": [16, 15]},
            {"id": "sectoid_3", "type": "sectoid_warrior", "position": [17, 15]}
        ],
        "objectives": ["eliminate_all_enemies"]
    }

    # Generate battle
    print("Generating battle...")
    var battle_id = BattleService.create_battle(seed_value, terrain_id, deployment)

    if battle_id.is_empty():
        print("✗ Failed to create battle")
        return false

    print("✓ Battle created: ", battle_id)

    # Get battle data
    var battle_data = BattleService.get_battle_data(battle_id)
    if battle_data.is_empty():
        print("✗ Failed to get battle data")
        return false

    print("✓ Battle data retrieved")

    # Create export directory
    var dir = DirAccess.open("res://")
    if not dir.dir_exists(export_path):
        dir.make_dir_recursive(export_path)

    # Export JSON data
    var json_success = _export_json_data(battle_data, export_path)
    if not json_success:
        print("✗ Failed to export JSON data")
        return false

    # Export ASCII map
    var ascii_success = _export_ascii_map(battle_data, export_path)
    if not ascii_success:
        print("✗ Failed to export ASCII map")
        return false

    # Export telemetry
    var telemetry_success = _export_telemetry(battle_data, export_path)
    if not telemetry_success:
        print("✗ Failed to export telemetry")
        return false

    # Test deterministic regeneration
    print("\nTesting deterministic regeneration...")
    var battle2_id = BattleService.create_battle(seed_value, terrain_id, deployment)
    var battle2_data = BattleService.get_battle_data(battle2_id)

    var hash1 = battle_data.get("topology_hash", "")
    var hash2 = battle2_data.get("topology_hash", "")

    if hash1 == hash2 and not hash1.is_empty():
        print("✓ Deterministic generation confirmed")
        print("  Topology hash: ", hash1)
    else:
        print("✗ Deterministic generation failed")
        print("  Hash 1: ", hash1)
        print("  Hash 2: ", hash2)
        return false

    # Clean up
    BattleService.destroy_battle(battle_id)
    BattleService.destroy_battle(battle2_id)

    print("\n✓ All exports completed successfully")
    print("Files exported to: ", export_path)
    return true

func _export_json_data(battle_data: Dictionary, export_path: String) -> bool:
    """Export battle data as JSON"""
    print("Exporting JSON data...")

    var json = JSON.new()
    var json_string = json.stringify(battle_data, "\t")

    var file_path = export_path + "/battle_" + str(seed_value) + "_" + terrain_id + ".json"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        print("✗ Failed to open file for writing: ", file_path)
        return false

    file.store_string(json_string)
    file.close()

    print("✓ JSON data exported to: ", file_path)
    return true

func _export_ascii_map(battle_data: Dictionary, export_path: String) -> bool:
    """Export ASCII representation of the battle map"""
    print("Exporting ASCII map...")

    var topology = battle_data.get("topology", [])
    if topology.is_empty():
        print("✗ No topology data to export")
        return false

    var ascii_map = ""
    ascii_map += "Battle Map - Seed: " + str(seed_value) + ", Terrain: " + terrain_id + "\n"
    ascii_map += "Legend: . = floor, # = wall, @ = feature\n"
    ascii_map += "=" * (battle_data.map_width + 2) + "\n"

    # Only export first level for ASCII
    var level_data = topology[0] if topology.size() > 0 else []
    for y in range(battle_data.map_height):
        ascii_map += "|"
        for x in range(battle_data.map_width):
            if y < level_data.size() and x < level_data[y].size():
                var tile_data = level_data[y][x]
                var tile_type = tile_data.get("type", "floor")

                match tile_type:
                    "floor":
                        ascii_map += "."
                    "wall":
                        ascii_map += "#"
                    "feature":
                        ascii_map += "@"
                    _:
                        ascii_map += "?"
            else:
                ascii_map += "?"
        ascii_map += "|\n"

    ascii_map += "=" * (battle_data.map_width + 2) + "\n"

    # Add unit positions
    ascii_map += "\nUnit Positions:\n"
    for unit in battle_data.player_units:
        var pos = unit.get("position", [0, 0])
        ascii_map += "Player: " + unit.id + " at (" + str(pos[0]) + ", " + str(pos[1]) + ")\n"

    for unit in battle_data.enemy_units:
        var pos = unit.get("position", [0, 0])
        ascii_map += "Enemy: " + unit.id + " at (" + str(pos[0]) + ", " + str(pos[1]) + ")\n"

    var file_path = export_path + "/battle_" + str(seed_value) + "_" + terrain_id + ".txt"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        print("✗ Failed to open file for writing: ", file_path)
        return false

    file.store_string(ascii_map)
    file.close()

    print("✓ ASCII map exported to: ", file_path)
    return true

func _export_telemetry(battle_data: Dictionary, export_path: String) -> bool:
    """Export telemetry data for analysis"""
    print("Exporting telemetry...")

    var telemetry = {
        "seed_provenance": {
            "original_seed": seed_value,
            "terrain_id": terrain_id,
            "generation_time": Time.get_datetime_string_from_system(),
            "godot_version": Engine.get_version_info().string,
            "rng_service_version": "1.0"
        },
        "battle_stats": {
            "map_width": battle_data.get("map_width", 0),
            "map_height": battle_data.get("map_height", 0),
            "map_levels": battle_data.get("map_levels", 0),
            "player_unit_count": battle_data.get("player_units", []).size(),
            "enemy_unit_count": battle_data.get("enemy_units", []).size(),
            "topology_hash": battle_data.get("topology_hash", "")
        },
        "tile_distribution": _calculate_tile_distribution(battle_data),
        "connectivity_analysis": _analyze_connectivity(battle_data),
        "export_timestamp": Time.get_unix_time_from_system()
    }

    var json = JSON.new()
    var json_string = json.stringify(telemetry, "\t")

    var file_path = export_path + "/telemetry_" + str(seed_value) + "_" + terrain_id + ".json"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        print("✗ Failed to open file for writing: ", file_path)
        return false

    file.store_string(json_string)
    file.close()

    print("✓ Telemetry exported to: ", file_path)
    return true

func _calculate_tile_distribution(battle_data: Dictionary) -> Dictionary:
    """Calculate distribution of tile types"""
    var distribution = {"floor": 0, "wall": 0, "feature": 0, "other": 0}
    var total_tiles = 0

    var topology = battle_data.get("topology", [])
    for level in topology:
        for row in level:
            for tile in row:
                var tile_type = tile.get("type", "other")
                if distribution.has(tile_type):
                    distribution[tile_type] += 1
                else:
                    distribution.other += 1
                total_tiles += 1

    # Calculate percentages
    var percentages = {}
    for tile_type in distribution:
        var count = distribution[tile_type]
        percentages[tile_type] = float(count) / total_tiles * 100.0 if total_tiles > 0 else 0.0

    return {
        "counts": distribution,
        "percentages": percentages,
        "total_tiles": total_tiles
    }

func _analyze_connectivity(battle_data: Dictionary) -> Dictionary:
    """Analyze map connectivity (simplified)"""
    var topology = battle_data.get("topology", [])
    if topology.is_empty() or topology[0].is_empty():
        return {"error": "No topology data"}

    var level_data = topology[0]
    var width = battle_data.get("map_width", 0)
    var height = battle_data.get("map_height", 0)

    # Simple connectivity check - count accessible floor tiles
    var visited = []
    for y in range(height):
        visited.append([])
        for x in range(width):
            visited[y].append(false)

    var accessible_count = 0
    var total_floor_count = 0

    # Start from center and flood fill
    var start_x = width / 2
    var start_y = height / 2

    if _is_walkable(level_data, start_x, start_y, width, height):
        accessible_count = _flood_fill_count(level_data, visited, start_x, start_y, width, height)

    # Count total floor tiles
    for y in range(height):
        for x in range(width):
            if y < level_data.size() and x < level_data[y].size():
                var tile_data = level_data[y][x]
                if tile_data.get("type", "") == "floor":
                    total_floor_count += 1

    return {
        "accessible_floor_tiles": accessible_count,
        "total_floor_tiles": total_floor_count,
        "connectivity_ratio": float(accessible_count) / total_floor_count if total_floor_count > 0 else 0.0,
        "start_position": [start_x, start_y]
    }

func _is_walkable(level_data: Array, x: int, y: int, width: int, height: int) -> bool:
    """Check if a tile is walkable"""
    if x < 0 or x >= width or y < 0 or y >= height:
        return false

    if y >= level_data.size() or x >= level_data[y].size():
        return false

    var tile_data = level_data[y][x]
    return tile_data.get("type", "") == "floor"

func _flood_fill_count(level_data: Array, visited: Array, x: int, y: int, width: int, height: int) -> int:
    """Count accessible tiles using flood fill"""
    if not _is_walkable(level_data, x, y, width, height) or visited[y][x]:
        return 0

    visited[y][x] = true
    var count = 1

    # Check adjacent tiles
    count += _flood_fill_count(level_data, visited, x + 1, y, width, height)
    count += _flood_fill_count(level_data, visited, x - 1, y, width, height)
    count += _flood_fill_count(level_data, visited, x, y + 1, width, height)
    count += _flood_fill_count(level_data, visited, x, y - 1, width, height)

    return count
