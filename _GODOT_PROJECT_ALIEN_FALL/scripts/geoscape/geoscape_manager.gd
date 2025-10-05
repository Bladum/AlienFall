extends Node

# GeoscapeManager - Manages the global geoscape state and operations
# Handles world map, missions, bases, and global game progression

var current_day: int = 1
var current_month: int = 1
var current_year: int = 1999
var current_hour: int = 0
var game_speed: float = 1.0

var active_missions = []
var discovered_ufo_sites = []
var xcom_bases = []

# Monthly tracking
var monthly_income: int = 0
var monthly_expenses: int = 0
var missions_completed_this_month: int = 0
var missions_failed_this_month: int = 0
var new_missions_this_month: int = 0

signal day_advanced(new_day: int)
signal month_advanced(new_month: int, new_year: int)
signal mission_completed(mission_data: Dictionary)
signal ufo_detected(ufo_data: Dictionary)
signal monthly_tick(data: Dictionary)

func _ready():
	print("GeoscapeManager initialized")
	# Initialize with default values
	current_day = 1
	current_month = 1
	current_year = 1999
	current_hour = 8  # Start at 8 AM

func get_current_day() -> int:
	return current_day

func get_current_time_string() -> String:
	return "Day " + str(current_day) + ", " + str(current_hour) + ":00"

func advance_time(hours: int = 1):
	current_hour += hours
	if current_hour >= 24:
		var days_advanced = current_hour / 24
		current_hour = current_hour % 24
		
		for i in range(days_advanced):
			current_day += 1
			day_advanced.emit(current_day)
			_process_new_day()
			
			# Check for month advancement (30 days per month)
			if current_day % 30 == 0:
				current_month += 1
				if current_month > 12:
					current_month = 1
					current_year += 1
				
				month_advanced.emit(current_month, current_year)
				_process_new_month()

func _process_new_day():
	# Process daily events
	print("Processing day " + str(current_day))
	
	# Generate new missions
	_generate_random_missions()
	
	# Update mission timers
	_update_mission_timers()
	
	# Check for UFO activity
	_check_ufo_activity()
	
	# Update daily expenses
	monthly_expenses += _calculate_daily_expenses()

func _process_new_month():
	# Process monthly events
	print("Processing month " + str(current_month) + "/" + str(current_year))
	
	# Calculate monthly income (funding from nations)
	monthly_income += _calculate_monthly_income()
	
	# Generate monthly report data
	var report_data = {
		"month": current_month,
		"year": current_year,
		"starting_balance": GameState.get_funding(),
		"income": monthly_income,
		"expenses": monthly_expenses,
		"ending_balance": GameState.get_funding() + monthly_income - monthly_expenses,
		"missions_completed": missions_completed_this_month,
		"missions_failed": missions_failed_this_month,
		"new_missions": new_missions_this_month,
		"active_research": 0,  # TODO: Integrate with research system
		"completed_research": 0,  # TODO: Integrate with research system
		"total_personnel": _get_total_personnel(),
		"total_facilities": xcom_bases.size(),
		"total_craft": _get_total_craft()
	}
	
	# Update game funding
	GameState.add_funding(monthly_income - monthly_expenses)
	
	# Emit monthly tick event
	monthly_tick.emit(report_data)
	
	# Reset monthly counters
	monthly_income = 0
	monthly_expenses = 0
	missions_completed_this_month = 0
	missions_failed_this_month = 0
	new_missions_this_month = 0

func _generate_random_missions():
	# Generate random missions for the day
	var mission_types = ["UFO_Scout", "UFO_Fighter", "Terror_Site", "Alien_Base"]
	
	for i in range(randi() % 3 + 1):  # 1-3 missions per day
		var mission_type = mission_types[randi() % mission_types.size()]
		var mission_factory = MissionFactory.new()
		var mission = mission_factory.create_mission(mission_type, current_day)
		
		if mission:
			active_missions.append(mission)
			print("Generated mission: " + mission.name)

func _update_mission_timers():
	# Update mission timers and check for expirations
	var expired_missions = []
	
	for mission in active_missions:
		if mission.has_method("update_timer"):
			mission.update_timer(24)  # 24 hours passed
			
			if mission.is_expired():
				expired_missions.append(mission)
	
	# Remove expired missions
	for mission in expired_missions:
		active_missions.erase(mission)
		print("Mission expired: " + mission.name)

func _check_ufo_activity():
	# Random chance of UFO detection
	if randf() < 0.3:  # 30% chance per day
		var ufo_data = {
			"type": "UFO_Scout",
			"position": Vector2(randi() % 100, randi() % 100),
			"threat_level": randi() % 5 + 1
		}
		discovered_ufo_sites.append(ufo_data)
		ufo_detected.emit(ufo_data)
		print("UFO detected at position: " + str(ufo_data.position))

func add_xcom_base(base_data: Dictionary):
	xcom_bases.append(base_data)
	print("XCOM base added: " + base_data.name)

func get_active_missions() -> Array:
	return active_missions

func get_discovered_ufo_sites() -> Array:
	return discovered_ufo_sites

func get_xcom_bases() -> Array:
	return xcom_bases

func complete_mission(mission, success: bool = true):
	if mission in active_missions:
		active_missions.erase(mission)
		
		if success:
			missions_completed_this_month += 1
		else:
			missions_failed_this_month += 1
		
		mission_completed.emit({
			"name": mission.name,
			"type": mission.type,
			"success": success
		})
		print("Mission completed: " + mission.name + " (Success: " + str(success) + ")")

func get_current_date_string() -> String:
	return "Day " + str(current_day) + ", Month " + str(current_month) + ", " + str(current_year)

func get_current_month() -> int:
	return current_month

func get_current_year() -> int:
	return current_year

func set_game_speed(speed: float):
	game_speed = clamp(speed, 0.1, 5.0)
	print("Game speed set to: " + str(game_speed))

func _calculate_daily_expenses() -> int:
	# Calculate daily operational expenses
	var base_expenses = 1000  # Base daily cost
	var personnel_expenses = _get_total_personnel() * 50  # $50 per person per day
	var facility_expenses = xcom_bases.size() * 200  # $200 per facility per day
	
	return base_expenses + personnel_expenses + facility_expenses

func _calculate_monthly_income() -> int:
	# Calculate monthly funding from nations
	var base_funding = 100000  # Base monthly funding
	var performance_bonus = missions_completed_this_month * 5000  # Bonus per completed mission
	
	return base_funding + performance_bonus

func _get_total_personnel() -> int:
	# Count total personnel across all bases
	var total = 0
	for base in xcom_bases:
		total += base.get("personnel_count", 0)
	return total

func _get_total_craft() -> int:
	# Count total craft across all bases
	var total = 0
	for base in xcom_bases:
		total += base.get("craft_count", 0)
	return total
