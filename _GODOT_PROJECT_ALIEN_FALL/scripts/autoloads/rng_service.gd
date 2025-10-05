extends Node

# RNGService - Deterministic random number generation with seed tracking
# This ensures reproducible gameplay and debugging

class RNGHandle:
    var generator: RandomNumberGenerator
    var seed_value: int
    var context: String
    var draw_count: int = 0
    
    func _init(seed_val: int, ctx: String):
        seed_value = seed_val
        context = ctx
        generator = RandomNumberGenerator.new()
        generator.seed = seed_val
    
    func randi() -> int:
        draw_count += 1
        return generator.randi()
    
    func randf() -> float:
        draw_count += 1
        return generator.randf()
    
    func randi_range(from: int, to: int) -> int:
        draw_count += 1
        return generator.randi_range(from, to)
    
    func randf_range(from: float, to: float) -> float:
        draw_count += 1
        return generator.randf_range(from, to)
    
    func rand_weighted(weights: Array) -> int:
        draw_count += 1
        var total_weight = 0.0
        for weight in weights:
            total_weight += weight
        
        var random_value = generator.randf() * total_weight
        
        var cumulative_weight = 0.0
        for i in range(weights.size()):
            cumulative_weight += weights[i]
            if random_value <= cumulative_weight:
                return i
        
        return weights.size() - 1  # fallback
    
    func get_provenance() -> Dictionary:
        return {
            "seed": seed_value,
            "context": context,
            "draws": draw_count
        }

var _campaign_seed: int = 0
var _current_handles: Dictionary = {}  # context -> RNGHandle

func _ready():
    # Initialize with a random campaign seed if not set
    if _campaign_seed == 0:
        randomize()
        _campaign_seed = randi()
        print("RNGService: Initialized with campaign seed: ", _campaign_seed)

# Set the campaign seed (should be called at game start)
func set_campaign_seed(seed: int) -> void:
    _campaign_seed = seed
    _current_handles.clear()
    print("RNGService: Campaign seed set to: ", seed)

# Get the current campaign seed
func get_campaign_seed() -> int:
    return _campaign_seed

# Create a deterministic RNG handle for a specific context
func get_rng_handle(context: String, additional_seed: int = 0) -> RNGHandle:
    var combined_seed = _campaign_seed
    if additional_seed != 0:
        combined_seed = hash(str(combined_seed) + str(additional_seed))
    
    # Create a context-specific seed
    var context_seed = hash(str(combined_seed) + context)
    
    var handle = RNGHandle.new(context_seed, context)
    _current_handles[context] = handle
    
    print("RNGService: Created RNG handle for context '", context, "' with seed: ", context_seed)
    return handle

# Get provenance data for all current RNG handles
func get_provenance_data() -> Dictionary:
    var data = {
        "campaign_seed": _campaign_seed,
        "handles": {}
    }
    
    for context in _current_handles:
        data.handles[context] = _current_handles[context].get_provenance()
    
    return data

# Reset all RNG handles (useful for replay/testing)
func reset() -> void:
    _current_handles.clear()
    print("RNGService: All RNG handles reset")

# Generate a stable hash for deterministic seeding
func hash(input: String) -> int:
    var hash_value = 0
    for c in input:
        hash_value = (hash_value * 31 + c.unicode_at(0)) & 0xFFFFFFFF
    return hash_value
