extends Resource
class_name Unit

# Unit - Represents soldiers, aliens, and other actors in the game
# This is a core domain class that handles unit data and behavior

@export var id: String = ""
@export var unit_id: String = ""  # Alias for id for compatibility
@export var name: String = ""
@export var race: String = ""
@export var unit_class: String = ""
@export var role: String = ""  # scientist, engineer, soldier, etc.
@export var assigned_facility: Resource = null  # Facility this unit is assigned to

# Stats
@export var stats: Dictionary = {
    "tu": 60,      # Time Units (action points)
    "energy": 100, # Energy for special abilities
    "health": 35,  # Hit points
    "morale": 70,  # Morale level
    "strength": 25 # Carrying capacity, melee damage
}

# Inventory slots
@export var inventory_slots: Array = [
    {"id": "armor", "type": "armor", "item": null},
    {"id": "primary_weapon", "type": "weapon", "item": null},
    {"id": "secondary_weapon_1", "type": "weapon", "item": null},
    {"id": "secondary_weapon_2", "type": "weapon", "item": null}
]

# Traits and abilities
@export var traits: Array = []
@export var abilities: Array = []

# Progression
@export var rank: String = "rookie"
@export var experience: int = 0
@export var promotion_threshold: int = 100

# Status
@export var is_alive: bool = true
@export var is_active: bool = true
@export var wounds: Array = []  # Active wounds/debuffs

# Position (for battlescape)
@export var position: Vector2 = Vector2.ZERO
@export var facing: int = 0  # 0-7, representing 8 directions

func _init(unit_id: String = "", unit_name: String = ""):
    id = unit_id
    self.unit_id = unit_id
    name = unit_name

# Create unit from data dictionary (for loading from JSON)
static func from_data(data: Dictionary) -> Unit:
    var unit = new(data.get("id", ""), data.get("name", ""))

    unit.race = data.get("race", "")
    unit.unit_class = data.get("class", "")

    if data.has("stats"):
        unit.stats = data.stats.duplicate()

    if data.has("inventory_slots"):
        unit.inventory_slots = data.inventory_slots.duplicate(true)
    
    if data.has("traits"):
        unit.traits = data.traits.duplicate()
    
    if data.has("abilities"):
        unit.abilities = data.abilities.duplicate()
    
    unit.rank = data.get("rank", "rookie")
    unit.experience = data.get("experience", 0)
    unit.promotion_threshold = data.get("promotion_threshold", 100)
    
    return unit

# Convert unit to dictionary (for saving)
func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": name,
        "race": race,
        "class": unit_class,
        "stats": stats.duplicate(),
        "inventory_slots": inventory_slots.duplicate(true),
        "traits": traits.duplicate(),
        "abilities": abilities.duplicate(),
        "rank": rank,
        "experience": experience,
        "promotion_threshold": promotion_threshold,
        "is_alive": is_alive,
        "is_active": is_active,
        "wounds": wounds.duplicate(),
        "position": {"x": position.x, "y": position.y},
        "facing": facing
    }

# Get current stat value
func get_stat(stat_name: String) -> int:
    return stats.get(stat_name, 0)

# Modify stat value
func modify_stat(stat_name: String, amount: int) -> void:
    if stats.has(stat_name):
        var old_value = stats[stat_name]
        stats[stat_name] = max(0, stats[stat_name] + amount)

        # Emit signal for stat changes (if EventBus is available)
        # TODO: Re-enable when EventBus is properly set up
        # EventBus.publish("unit_stat_changed", {
        #     "unit_id": id,
        #     "stat": stat_name,
        #     "old_value": old_value,
        #     "new_value": stats[stat_name]
        # })# Check if unit has a specific trait
func has_trait(trait_name: String) -> bool:
    return trait_name in traits

# Check if unit has a specific ability
func has_ability(ability_name: String) -> bool:
    return ability_name in abilities

# Add experience and check for promotion
func add_experience(amount: int) -> bool:
    experience += amount
    
    # Check for promotion
    if experience >= promotion_threshold:
        promote()
        return true
    
    return false

# Promote unit to next rank
func promote() -> void:
    var old_rank = rank
    
    # Simple promotion logic - in real game this would be more complex
    match rank:
        "rookie":
            rank = "squaddie"
        "squaddie":
            rank = "corporal"
        "corporal":
            rank = "sergeant"
        "sergeant":
            rank = "captain"
        "captain":
            rank = "major"
    
    experience = 0
    promotion_threshold = promotion_threshold * 1.5  # Increase threshold
    
    # Emit promotion event
    EventBus.publish("unit_promoted", {
        "unit_id": id,
        "old_rank": old_rank,
        "new_rank": rank
    })

# Take damage
func take_damage(amount: int, damage_type: String = "normal") -> void:
    if not is_alive:
        return
    
    var actual_damage = amount
    
    # Apply armor/damage reduction here
    # For now, just apply full damage
    
    stats.health -= actual_damage
    
    if stats.health <= 0:
        die()
    else:
        # Emit damage event
        EventBus.publish("unit_damaged", {
            "unit_id": id,
            "damage": actual_damage,
            "damage_type": damage_type,
            "remaining_health": stats.health
        })

# Kill the unit
func die() -> void:
    is_alive = false
    is_active = false
    
    EventBus.publish("unit_died", {
        "unit_id": id
    })

# Heal unit
func heal(amount: int) -> void:
    if not is_alive:
        return
    
    var old_health = stats.health
    stats.health = min(get_max_health(), stats.health + amount)
    
    EventBus.publish("unit_healed", {
        "unit_id": id,
        "healed": stats.health - old_health,
        "total_health": stats.health
    })

# Get maximum health (could be modified by traits/equipment)
func get_max_health() -> int:
    return 35  # Base value, could be calculated from stats/traits

# Equip item in specific slot
func equip_item(slot_id: String, item: Resource) -> bool:
    for slot in inventory_slots:
        if slot.id == slot_id:
            slot.item = item
            return true
    return false

# Unequip item from slot
func unequip_item(slot_id: String) -> Resource:
    for slot in inventory_slots:
        if slot.id == slot_id:
            var item = slot.item
            slot.item = null
            return item
    return null

# Get item in slot
func get_item_in_slot(slot_id: String) -> Resource:
    for slot in inventory_slots:
        if slot.id == slot_id:
            return slot.item
    return null

# Check if unit can perform action (has enough TU)
func can_perform_action(tu_cost: int) -> bool:
    return stats.tu >= tu_cost

# Spend time units for action
func spend_tu(amount: int) -> void:
    modify_stat("tu", -amount)

# Reset time units (start of turn)
func reset_tu() -> void:
    stats.tu = get_max_tu()

# Get maximum TU
func get_max_tu() -> int:
    return 60  # Base value, could be modified by traits/equipment
