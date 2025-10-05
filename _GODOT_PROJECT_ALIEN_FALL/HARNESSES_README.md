# Geoscape Headless Harness

A headless testing tool for the AlienFall geoscape system that allows running simulations without the UI for automated testing, validation, and performance analysis.

## Features

- **Deterministic Simulations**: Same seed produces identical results
- **Comprehensive Telemetry**: Mission timeline, funding history, detection events
- **Multiple Output Formats**: JSON and CSV exports
- **Performance Monitoring**: Execution time tracking and benchmarking
- **CI/CD Ready**: Command-line interface suitable for automated testing

## Quick Start

### Direct Godot Execution

```bash
# Run using Godot directly (recommended)
godot --path . --scene scenes/harness_main.tscn -- --days 30 --seed 12345 --export test_output.json

# Or using the full path
"c:\path\to\Godot_v4.4.1-stable_win64_console.exe" --path . --scene scenes/harness_main.tscn -- --days 30 --seed 12345 --export test_output.json
```

### Python Wrapper

```bash
# Run a 30-day simulation with default seed
python geoscape_harness.py

# Run a 60-day simulation with specific seed
python geoscape_harness.py --days 60 --seed 12345

# Run with custom export path
python geoscape_harness.py --days 30 --seed 12345 --export results/
```

### Windows Batch File

```cmd
# Using the batch file
run_harness.bat 60 12345 results/
```

### Advanced Usage

```bash
# Run benchmark tests (5 iterations)
python geoscape_harness.py --benchmark --iterations 5 --days 30

# Compare two simulation results
python geoscape_harness.py --compare results1/ results2/
```

## Implementation Status

✅ **Completed Features:**
- Headless geoscape simulation engine
- Command-line argument parsing
- Deterministic seeding with RNGService
- Event telemetry collection (missions, funding, detections)
- JSON and CSV output formats
- Python wrapper with advanced features
- Windows batch file runner
- Comprehensive documentation

🔄 **Current Status:**
- Core harness implementation complete
- All dependencies verified (EventBus, GameState, RNGService, etc.)
- Command-line integration tested
- Ready for execution and validation

## Troubleshooting

### No Console Output
If running Godot doesn't produce console output:
1. Use the console version: `Godot_v4.4.1-stable_win64_console.exe`
2. Check that all autoloads are properly configured in `project.godot`
3. Verify the scene file `scenes/harness_main.tscn` exists and is properly configured

### Missing Dependencies
Ensure these autoloads are configured in `project.godot`:
- EventBus
- RNGService
- GameState
- GeoscapeManager
- MissionFactory
- DetectionSystem

### Output Files Location
- JSON/CSV files are saved to `user://geoscape_test_results/` by default
- This maps to `%APPDATA%/Godot/app_userdata/AlienFall/geoscape_test_results/`
- Use absolute paths for custom export locations

```json
{
  "simulation_config": {
    "days_simulated": 30,
    "random_seed": 12345,
    "timestamp": "2025-08-31T...",
    "godot_version": "4.4.1"
  },
  "final_state": {
    "current_day": 30,
    "current_month": 1,
    "current_year": 1999,
    "total_funding": 1250000,
    "active_missions": 3,
    "discovered_ufos": 2,
    "xcom_bases": 1
  },
  "mission_timeline": [
    {
      "day": 5,
      "month": 1,
      "year": 1999,
      "mission_type": "UFO_Scout",
      "mission_name": "UFO Scout Alpha"
    }
  ],
  "funding_history": [
    {
      "day": 1,
      "month": 1,
      "year": 1999,
      "funding": 1000000,
      "active_missions": 0,
      "new_missions": 1,
      "detection_events": 0
    }
  ],
  "detection_events": [
    {
      "day": 10,
      "month": 1,
      "year": 1999,
      "ufo_data": {
        "type": "UFO_Scout",
        "position": [150, 200],
        "threat_level": 2
      }
    }
  ],
  "event_log": [
    {
      "timestamp": 1693523456789,
      "event_type": "mission_created",
      "mission_data": {...}
    }
  ]
}
```

### CSV Output (`summary_[seed]_[days]days.csv`)

```csv
Day,Month,Year,Funding,ActiveMissions,NewMissions,DetectionEvents
1,1,1999,1000000,0,1,0
2,1,1999,995000,1,0,0
3,1,1999,990000,1,0,0
...
```

## Validation Tests

Run the validation tests to ensure the harness is working correctly:

```bash
python test_harness_validation.py
```

The validation tests check:
- **Deterministic Behavior**: Same seed produces identical results
- **Seed Variation**: Different seeds produce different results
- **Output Generation**: JSON and CSV files are created correctly
- **Performance**: Simulations complete within reasonable time limits

## Architecture

### Core Components

1. **GeoscapeHeadlessHarness**: Main simulation runner (GDScript)
2. **GeoscapeHarnessRunner**: Python wrapper for advanced features
3. **Event Collection**: Comprehensive telemetry gathering
4. **Output Generation**: Multiple format support

### Event Tracking

The harness tracks these key events:
- Mission creation and completion
- UFO detection and interception
- Monthly economic reports
- Funding changes over time
- System performance metrics

### Determinism

- Uses Godot's `seed()` function for reproducible randomness
- RNGService integration for seeded random number generation
- Timestamp-independent execution
- Consistent event ordering

## Use Cases

### Automated Testing
```bash
# Run daily regression tests
python geoscape_harness.py --days 30 --seed 12345
```

### Performance Benchmarking
```bash
# Benchmark simulation performance
python geoscape_harness.py --benchmark --iterations 10 --days 60
```

### Balance Testing
```bash
# Test different scenarios
python geoscape_harness.py --days 90 --seed 11111  # Scenario A
python geoscape_harness.py --days 90 --seed 22222  # Scenario B
python geoscape_harness.py --compare results_A/ results_B/
```

### CI/CD Integration
```yaml
# Example GitHub Actions workflow
- name: Run Geoscape Tests
  run: |
    python geoscape_harness.py --days 30 --seed 12345
    python test_harness_validation.py
```

## Configuration

### Command Line Options

- `--days`: Number of days to simulate (default: 30)
- `--seed`: Random seed for deterministic results (default: 12345)
- `--export`: Export path for results (default: user://geoscape_test_results/)
- `--benchmark`: Run benchmark tests
- `--iterations`: Number of benchmark iterations (default: 5)
- `--compare`: Compare two result directories

### Environment Variables

- `GODOT_PATH`: Path to Godot executable (auto-detected on Windows)
- `PROJECT_PATH`: Path to Godot project (auto-detected)

## Troubleshooting

### Common Issues

1. **Godot executable not found**
   - Update the path in `GeoscapeHarnessRunner.__init__()`
   - Or set the `GODOT_PATH` environment variable

2. **Project path incorrect**
   - Update the path in `GeoscapeHarnessRunner.__init__()`
   - Or set the `PROJECT_PATH` environment variable

3. **Output files not generated**
   - Check write permissions in the export directory
   - Ensure the Godot project has proper autoloads configured

4. **Non-deterministic results**
   - Verify the same seed is used for comparison
   - Check that all random number generation uses RNGService

### Debug Mode

Enable verbose output by modifying the harness script:
```gdscript
# In geoscape_headless_harness.gd
const DEBUG_MODE = true
```

## Contributing

When adding new features to the harness:

1. Maintain deterministic behavior
2. Add appropriate telemetry collection
3. Update validation tests
4. Document new command-line options
5. Ensure backward compatibility

## License

This tool is part of the AlienFall project and follows the same license terms.
