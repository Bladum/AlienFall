# Phase 10B - Headless Battlescape Test Harness

This directory contains the headless battlescape test harness for Phase 10B of the AlienFall Godot implementation. The harness provides automated testing and debugging capabilities for battlescape generation.

## Overview

The battle smoke test harness allows you to:
- Generate deterministic battles from seeds
- Export battle data in multiple formats (JSON, ASCII, telemetry)
- Validate deterministic generation (same seed = same output)
- Run automated regression tests against golden snapshots
- Debug content and generator changes

## Files

- `battle_smoke_test.gd` - Main Godot script for headless battle generation
- `battle_smoke.py` - Python wrapper for CI/CD integration
- `golden_snapshot_test.py` - Regression testing against golden snapshots
- `run_battle_smoke.bat` - Windows batch file for easy execution

## Usage

### Basic Usage

#### Windows Batch File
```batch
run_battle_smoke.bat --seed 12345 --terrain urban --export out/
```

#### Python Script
```bash
python battle_smoke.py --seed 12345 --terrain urban --export out/
```

#### Direct Godot Execution
```bash
Godot_v4.4.1-stable_win64_console.exe --headless --script battle_smoke_test.gd --seed 12345 --terrain urban --export out/
```

### Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `--seed <int>` | RNG seed for deterministic generation | 12345 |
| `--terrain <id>` | Terrain template ID | urban |
| `--export <path>` | Export directory path | out/ |
| `--width <int>` | Map width | 20 |
| `--height <int>` | Map height | 20 |
| `--levels <int>` | Map levels | 1 |

### Available Terrains

- `urban` - City streets and buildings
- `forest` - Dense woodland
- `desert` - Open desert with dunes
- `industrial` - Factory complex

## Output Files

The harness generates three types of output files:

### 1. JSON Battle Data (`battle_<seed>_<terrain>.json`)
Complete battle data including:
- Map topology (3D array of tile data)
- Unit positions and stats
- Objectives and deployment info
- Generation metadata and hashes

### 2. ASCII Map (`battle_<seed>_<terrain>.txt`)
Human-readable map representation:
```
Battle Map - Seed: 12345, Terrain: urban
Legend: . = floor, # = wall, @ = feature
======================
|....................|
|....................|
|..###...............|
|..#.#...............|
|..###...............|
|....................|
======================

Unit Positions:
Player: soldier_1 at (5, 5)
Enemy: sectoid_1 at (15, 15)
```

### 3. Telemetry Data (`telemetry_<seed>_<terrain>.json`)
Analysis data including:
- Seed provenance tracking
- Tile distribution statistics
- Connectivity analysis
- Generation timestamps
- Performance metrics

## Deterministic Testing

The harness includes built-in deterministic validation:

```bash
# Generate battle twice with same seed
python battle_smoke.py --seed 12345 --terrain urban --export test1/
python battle_smoke.py --seed 12345 --terrain urban --export test2/

# Compare topology hashes - should be identical
diff test1/telemetry_12345_urban.json test2/telemetry_12345_urban.json
```

## Golden Snapshot Testing

For regression testing, use the golden snapshot system:

```bash
# Update golden snapshots (first time setup)
python golden_snapshot_test.py --update-goldens --test-seed 12345 --test-terrain urban

# Run regression tests
python golden_snapshot_test.py --test-seed 12345 --test-terrain urban
```

## CI/CD Integration

The Python wrapper is designed for CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Battle Smoke Tests
  run: |
    python battle_smoke.py --seed 12345 --terrain urban --export test_output/
    python golden_snapshot_test.py --test-seed 12345 --test-terrain urban
```

## Examples

### Generate Urban Battle
```bash
python battle_smoke.py --seed 12345 --terrain urban --export urban_battle/
```

### Generate Large Forest Map
```bash
python battle_smoke.py --seed 99999 --terrain forest --width 30 --height 30 --export large_forest/
```

### Test Determinism
```bash
# Run same generation multiple times
for i in {1..3}; do
  python battle_smoke.py --seed 77777 --terrain desert --export test_$i/
done

# All telemetry files should have identical topology_hash values
grep topology_hash test_*/telemetry_77777_desert.json
```

## Troubleshooting

### Common Issues

1. **Godot executable not found**
   - Ensure `Godot_v4.4.1-stable_win64_console.exe` is in the project directory
   - Or specify full path with `--godot-path`

2. **Export directory creation fails**
   - Ensure write permissions in the target directory
   - Use absolute paths if relative paths don't work

3. **Deterministic test fails**
   - Check that RNGService is properly initialized
   - Verify terrain templates exist in `resources/data/terrain/`
   - Ensure no external state affects generation

### Debug Mode

Enable verbose output for debugging:
```bash
python battle_smoke.py --seed 12345 --terrain urban --export debug/ --verbose
```

## Integration with Development Workflow

### During Development
- Run smoke tests after generator changes
- Use golden snapshots to catch regressions
- Test multiple seeds and terrains for coverage

### Pre-Commit
```bash
# Quick determinism check
python battle_smoke.py --seed 12345 --terrain urban --export precommit/
python golden_snapshot_test.py --test-seed 12345 --test-terrain urban
```

### Release Testing
```bash
# Test multiple scenarios
for terrain in urban forest desert industrial; do
  for seed in 11111 22222 33333; do
    python battle_smoke.py --seed $seed --terrain $terrain --export release_test/
  done
done
```

## Technical Details

### Architecture

The harness integrates with the existing Godot architecture:
- Uses `BattleService` for deterministic generation
- Leverages `RNGService` for seeded random number generation
- Connects to `DataRegistry` for terrain templates
- Exports data in multiple formats for different use cases

### Determinism Guarantees

- Same seed + terrain + deployment = identical topology
- Topology hash validation ensures consistency
- Seed provenance tracking for debugging
- Telemetry includes generation metadata

### Performance

- Headless execution (no GUI overhead)
- Fast JSON export for machine processing
- ASCII export for human debugging
- Telemetry for performance analysis

## Future Enhancements

- PNG image export for visual debugging
- Multiple battle format support
- Performance benchmarking
- Automated test case generation
- Integration with test coverage tools
