extends Node

# TimeService - Manages game time progression and scheduling
# Handles daily/weekly/monthly events and time-based mechanics

signal day_changed(new_day: int)
signal week_changed(new_week: int)
signal month_changed(new_month: int)
signal daily_tick
signal monthly_tick

var current_day: int = 1
var current_week: int = 1
var current_month: int = 1
var time_paused: bool = true
var time_speed: int = 1  # 1 = normal, 2 = fast, 3 = fastest

var scheduled_events: Array = []  # Array of dictionaries with callback and timing
var daily_events: Array = []  # Events that run every day
var weekly_events: Array = []  # Events that run every week
var monthly_events: Array = []  # Events that run every month

func _ready():
    print("TimeService: Initializing...")
    
    # Subscribe to relevant events (only if EventBus is available)
    if EventBus and EventBus.has_method("subscribe"):
        EventBus.subscribe("game_mode_changed", Callable(self, "_on_game_mode_changed"))
    else:
        print("TimeService: EventBus not available, skipping subscription")

func _process(delta: float):
    # Only advance time if not paused and in geoscape mode
    if not time_paused and GameState.is_in_mode(GameState.GameMode.GEOSCAPE):
        # Simple time advancement - in a real game you'd use a timer
        pass

# Advance time by one day
func advance_day():
    current_day += 1
    
    # Check for week/month changes
    var new_week = ceil(current_day / 7.0)
    if new_week != current_week:
        current_week = new_week
        week_changed.emit(current_week)
        run_weekly_events()
    
    var new_month = ceil(current_day / 30.0)
    if new_month != current_month:
        current_month = new_month
        month_changed.emit(current_month)
        monthly_tick.emit()
        run_monthly_events()
    
    day_changed.emit(current_day)
    daily_tick.emit()
    run_daily_events()
    process_scheduled_events()
    
    print("TimeService: Advanced to day ", current_day)

# Advance time by multiple days
func advance_days(days: int):
    for i in range(days):
        advance_day()

# Set time paused state
func set_paused(paused: bool):
    time_paused = paused
    print("TimeService: Time ", "paused" if paused else "unpaused")

# Set time speed
func set_speed(speed: int):
    time_speed = clamp(speed, 1, 3)
    print("TimeService: Time speed set to ", time_speed)

# Get current time info
func get_current_time() -> Dictionary:
    return {
        "day": current_day,
        "week": current_week,
        "month": current_month,
        "paused": time_paused,
        "speed": time_speed
    }

# Get current day
func get_current_day() -> int:
    return current_day

# Get current month
func get_current_month() -> int:
    return current_month

# Get current month as string
func get_current_month_string() -> String:
    return "Month_" + str(current_month)

# Schedule an event to run at a specific day
func schedule_event(callback: Callable, target_day: int, event_id: String = ""):
    var event = {
        "callback": callback,
        "target_day": target_day,
        "event_id": event_id,
        "executed": false
    }
    scheduled_events.append(event)
    
    print("TimeService: Scheduled event for day ", target_day)

# Schedule a recurring daily event
func schedule_daily_event(callback: Callable, event_id: String = ""):
    var event = {
        "callback": callback,
        "event_id": event_id
    }
    daily_events.append(event)
    
    print("TimeService: Scheduled daily event: ", event_id)

# Schedule a recurring weekly event
func schedule_weekly_event(callback: Callable, event_id: String = ""):
    var event = {
        "callback": callback,
        "event_id": event_id
    }
    weekly_events.append(event)
    
    print("TimeService: Scheduled weekly event: ", event_id)

# Schedule a recurring monthly event
func schedule_monthly_event(callback: Callable, event_id: String = ""):
    var event = {
        "callback": callback,
        "event_id": event_id
    }
    monthly_events.append(event)
    
    print("TimeService: Scheduled monthly event: ", event_id)

# Remove scheduled event by ID
func remove_scheduled_event(event_id: String):
    scheduled_events = scheduled_events.filter(func(e): return e.event_id != event_id)
    daily_events = daily_events.filter(func(e): return e.event_id != event_id)
    weekly_events = weekly_events.filter(func(e): return e.event_id != event_id)
    monthly_events = monthly_events.filter(func(e): return e.event_id != event_id)
    
    print("TimeService: Removed events with ID: ", event_id)

# Process scheduled events for current day
func process_scheduled_events():
    var events_to_execute = []
    
    for event in scheduled_events:
        if not event.executed and current_day >= event.target_day:
            events_to_execute.append(event)
            event.executed = true
    
    for event in events_to_execute:
        if event.callback.is_valid():
            event.callback.call()
        scheduled_events.erase(event)

# Run all daily events
func run_daily_events():
    for event in daily_events:
        if event.callback.is_valid():
            event.callback.call()
    
    # Process base construction
    BaseManager.process_construction()
    
    # Process research
    ResearchManager.process_research()

# Run all weekly events
func run_weekly_events():
    for event in weekly_events:
        if event.callback.is_valid():
            event.callback.call()

# Run all monthly events
func run_monthly_events():
    for event in monthly_events:
        if event.callback.is_valid():
            event.callback.call()

# Get days until target day
func get_days_until(target_day: int) -> int:
    return max(0, target_day - current_day)

# Check if it's a specific day of the week (1-7)
func is_day_of_week(day_of_week: int) -> bool:
    return (current_day - 1) % 7 + 1 == day_of_week

# Check if it's a specific day of the month (1-30)
func is_day_of_month(day_of_month: int) -> bool:
    return (current_day - 1) % 30 + 1 == day_of_month

# Format current date as string
func get_date_string() -> String:
    return "Day " + str(current_day) + " (Month " + str(current_month) + ", Week " + str(current_week) + ")"

# Reset time to beginning
func reset():
    current_day = 1
    current_week = 1
    current_month = 1
    time_paused = true
    time_speed = 1
    
    scheduled_events.clear()
    daily_events.clear()
    weekly_events.clear()
    monthly_events.clear()
    
    print("TimeService: Time reset to beginning")

# Event handlers
func _on_game_mode_changed(data: Dictionary):
    if data.new_mode == GameState.GameMode.GEOSCAPE:
        print("TimeService: Entering geoscape mode")
        # Could auto-unpause here if desired
    elif data.old_mode == GameState.GameMode.GEOSCAPE:
        print("TimeService: Leaving geoscape mode")
        # Could auto-pause here

# Get time statistics
func get_time_stats() -> Dictionary:
    return {
        "current_day": current_day,
        "current_week": current_week,
        "current_month": current_month,
        "scheduled_events": scheduled_events.size(),
        "daily_events": daily_events.size(),
        "weekly_events": weekly_events.size(),
        "monthly_events": monthly_events.size(),
        "time_paused": time_paused,
        "time_speed": time_speed
    }
