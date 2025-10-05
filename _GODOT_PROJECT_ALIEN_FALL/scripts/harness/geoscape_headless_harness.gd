extends Node

# GeoscapeHeadlessHarness - Headless CLI tool for geoscape testing
# Run with: godot --scene scenes/harness_main.tscn -- --days 60 --seed 12345 --export results/

class_name GeoscapeHeadlessHarness

var days_to_simulate: int = 30
var random_seed: int = 0
var export_path: String = "user://geoscape_test_results/"
var telemetry_data = {}

var geoscape_manager: GeoscapeManager
var mission_factory: MissionFactory
var detection_system: DetectionSystem

var event_log = []
var mission_timeline = []
var funding_history = []
var detection_events = []

func _initialize_from_command_line():
    """Initialize configuration from command line arguments"""
    var args = OS.get_cmdline_args()

    for i in range(args.size()):
        match args[i]:
            "--days":
                if i + 1 < args.size():
                    days_to_simulate = int(args[i + 1])
            "--seed":
                if i + 1 < args.size():
                    random_seed = int(args[i + 1])
            "--export":
                if i + 1 < args.size():
                    export_path = args[i + 1]

    print("Configuration from command line:")
    print("  Days to simulate: ", days_to_simulate)
    print("  Random seed: ", random_seed)
    print("  Export path: ", export_path)

    # Start the simulation
    _setup_directories()
    _initialize_systems()
    _setup_event_listeners()
    _run_simulation()
    _export_results()
    print("=== Simulation Complete ===")
    # Note: Don't quit here - let the simulation complete naturally

func _setup_directories():
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("geoscape_test_results"):
        dir.make_dir("geoscape_test_results")

func _initialize_systems():
    print("Initializing systems...")

    # Set random seed for deterministic results
    if random_seed > 0:
        seed(random_seed)
        RNGService.set_seed(random_seed)

    # Use autoloaded instances instead of creating new ones
    geoscape_manager = GeoscapeManager
    mission_factory = MissionFactory
    detection_system = DetectionSystem

    print("Systems initialized successfully")

func _setup_event_listeners():
    print("Setting up event listeners...")

    # Listen to geoscape events
    geoscape_manager.connect("day_advanced", Callable(self, "_on_day_advanced"))
    geoscape_manager.connect("month_advanced", Callable(self, "_on_month_advanced"))
    geoscape_manager.connect("mission_completed", Callable(self, "_on_mission_completed"))
    geoscape_manager.connect("ufo_detected", Callable(self, "_on_ufo_detected"))
    geoscape_manager.connect("monthly_tick", Callable(self, "_on_monthly_tick"))

    # Listen to EventBus events
    EventBus.subscribe("mission_created", Callable(self, "_on_mission_created"))
    EventBus.subscribe("mission_detected", Callable(self, "_on_mission_detected_event"))

    print("Event listeners configured")

func _run_simulation():
    print("Starting simulation for ", days_to_simulate, " days...")

    var start_time = Time.get_ticks_msec()

    for day in range(1, days_to_simulate + 1):
        # Advance time by 24 hours (1 day)
        geoscape_manager.advance_time(24)

        # Log progress every 10 days
        if day % 10 == 0:
            print("  Completed day ", day, "/", days_to_simulate)

    var end_time = Time.get_ticks_msec()
    var duration = (end_time - start_time) / 1000.0

    print("Simulation completed in ", duration, " seconds")
    print("Average time per day: ", duration / days_to_simulate, " seconds")

    # Exit after simulation completes
    get_tree().quit()

func _export_results():
    print("Exporting results...")

    telemetry_data = {
        "simulation_config": {
            "days_simulated": days_to_simulate,
            "random_seed": random_seed,
            "timestamp": Time.get_datetime_string_from_system(),
            "godot_version": Engine.get_version_info().string
        },
        "final_state": {
            "current_day": geoscape_manager.get_current_day(),
            "current_month": geoscape_manager.get_current_month(),
            "current_year": geoscape_manager.get_current_year(),
            "total_funding": GameState.get_funding(),
            "active_missions": geoscape_manager.get_active_missions().size(),
            "discovered_ufos": geoscape_manager.get_discovered_ufo_sites().size(),
            "xcom_bases": geoscape_manager.get_xcom_bases().size()
        },
        "mission_timeline": mission_timeline,
        "funding_history": funding_history,
        "detection_events": detection_events,
        "event_log": event_log
    }

    # Export JSON
    var json_path = export_path + "geoscape_simulation_" + str(random_seed) + "_" + str(days_to_simulate) + "days.json"
    _export_json(json_path, telemetry_data)

    # Export CSV summary
    var csv_path = export_path + "summary_" + str(random_seed) + "_" + str(days_to_simulate) + "days.csv"
    _export_csv(csv_path)

    print("Results exported to:")
    print("  JSON: ", json_path)
    print("  CSV: ", csv_path)

func _export_json(path: String, data: Dictionary):
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data, "\t"))
        file.close()
        print("JSON export successful")
    else:
        print("ERROR: Failed to export JSON to ", path)

func _export_csv(path: String):
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file:
        # CSV Header
        file.store_line("Day,Month,Year,Funding,ActiveMissions,NewMissions,DetectionEvents")

        # CSV Data
        for entry in funding_history:
            var day = entry.get("day", 0)
            var month = entry.get("month", 0)
            var year = entry.get("year", 0)
            var funding = entry.get("funding", 0)
            var active_missions = entry.get("active_missions", 0)
            var new_missions = entry.get("new_missions", 0)
            var detection_events = entry.get("detection_events", 0)

            file.store_line(str(day) + "," + str(month) + "," + str(year) + "," +
                          str(funding) + "," + str(active_missions) + "," +
                          str(new_missions) + "," + str(detection_events))

        file.close()
        print("CSV export successful")
    else:
        print("ERROR: Failed to export CSV to ", path)

# Event Handlers
func _on_day_advanced(day: int):
    var current_funding = GameState.get_funding()
    var active_missions = geoscape_manager.get_active_missions().size()

    funding_history.append({
        "day": day,
        "month": geoscape_manager.get_current_month(),
        "year": geoscape_manager.get_current_year(),
        "funding": current_funding,
        "active_missions": active_missions,
        "new_missions": 0,
        "detection_events": 0
    })

    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "day_advanced",
        "day": day,
        "funding": current_funding
    })

func _on_month_advanced(month: int, year: int):
    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "month_advanced",
        "month": month,
        "year": year
    })

func _on_mission_completed(mission_data: Dictionary):
    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "mission_completed",
        "mission_data": mission_data
    })

func _on_ufo_detected(ufo_data: Dictionary):
    detection_events.append({
        "day": geoscape_manager.get_current_day(),
        "month": geoscape_manager.get_current_month(),
        "year": geoscape_manager.get_current_year(),
        "ufo_data": ufo_data
    })

    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "ufo_detected",
        "ufo_data": ufo_data
    })

func _on_mission_created(data: Dictionary):
    mission_timeline.append({
        "day": geoscape_manager.get_current_day(),
        "month": geoscape_manager.get_current_month(),
        "year": geoscape_manager.get_current_year(),
        "mission_type": data.get("type", "unknown"),
        "mission_name": data.get("name", "unknown")
    })

    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "mission_created",
        "mission_data": data
    })

func _on_mission_detected_event(data: Dictionary):
    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "mission_detected",
        "mission_data": data
    })

func _on_monthly_tick(data: Dictionary):
    event_log.append({
        "timestamp": Time.get_ticks_msec(),
        "event_type": "monthly_tick",
        "report_data": data
    })

# Main entry point
func _ready():
    print("=== Geoscape Headless Harness ===")
    # Configuration will be set by _initialize_from_command_line when the scene is ready
