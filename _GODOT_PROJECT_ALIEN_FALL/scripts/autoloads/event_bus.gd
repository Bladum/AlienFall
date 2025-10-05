extends Node

# EventBus - Global event system for loose coupling between game systems
# This replaces the original Python EventBus service

signal event_published(event_name: String, payload: Dictionary)

var _subscribers: Dictionary = {}  # event_name -> Array[Callable]

func _ready():
    # Make this a singleton that persists across scene changes
    pass

# Publish an event to all subscribers
func publish(event_name: String, payload: Dictionary = {}) -> void:
    print("EventBus: Publishing event '", event_name, "' with payload: ", payload)
    event_published.emit(event_name, payload)
    
    if _subscribers.has(event_name):
        for callback in _subscribers[event_name]:
            if callback.is_valid():
                callback.call(payload)
            else:
                # Remove invalid callbacks
                _subscribers[event_name].erase(callback)

# Subscribe to an event
func subscribe(event_name: String, callback: Callable) -> void:
    if not _subscribers.has(event_name):
        _subscribers[event_name] = []
    
    if not _subscribers[event_name].has(callback):
        _subscribers[event_name].append(callback)
        print("EventBus: Subscribed to event '", event_name, "'")

# Unsubscribe from an event
func unsubscribe(event_name: String, callback: Callable) -> void:
    if _subscribers.has(event_name):
        _subscribers[event_name].erase(callback)
        print("EventBus: Unsubscribed from event '", event_name, "'")

# Subscribe to an event only once (auto-unsubscribes after first call)
func subscribe_once(event_name: String, callback: Callable) -> void:
    var once_wrapper = _create_once_wrapper(event_name, callback)
    subscribe(event_name, once_wrapper)

func _create_once_wrapper(event_name: String, callback: Callable) -> Callable:
    var wrapper = func(payload):
        callback.call(payload)
        unsubscribe(event_name, wrapper)
    return wrapper

# Clear all subscribers for an event
func clear_subscribers(event_name: String) -> void:
    if _subscribers.has(event_name):
        _subscribers[event_name].clear()
        print("EventBus: Cleared all subscribers for event '", event_name, "'")

# Get list of all event names that have subscribers
func get_event_names() -> Array:
    return _subscribers.keys()

# Get subscriber count for an event
func get_subscriber_count(event_name: String) -> int:
    if _subscribers.has(event_name):
        return _subscribers[event_name].size()
    return 0
