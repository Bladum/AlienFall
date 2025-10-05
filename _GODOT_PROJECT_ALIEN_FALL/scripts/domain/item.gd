extends Resource
class_name Item

# Item - Represents weapons, armor, equipment, and other items
# Core domain class for all game items

@export var id: String = ""
@export var name: String = ""
@export var type: String = ""  # weapon, armor, utility, etc.
@export var subtype: String = ""  # pistol, rifle, heavy, light, etc.

# Physical properties
@export var weight: int = 0
@export var size: String = "small"  # small, medium, large

# Weapon-specific properties
@export var damage: Dictionary = {
    "base": 0,
    "type": "normal",
    "armor_pierce": 0
}

@export var weapon_modes: Array = []  # Array of firing modes

# Armor-specific properties
@export var armor_rating: Dictionary = {
    "front": 0,
    "side": 0,
    "rear": 0,
    "under": 0
}

# Utility item properties
@export var capacity: int = 0  # For containers/backpacks
@export var charges: int = 0   # For consumables

# Research/manufacturing requirements
@export var research_required: Array = []
@export var manufacturing_cost: Dictionary = {}

# Visual/audio
@export var sprite_path: String = ""
@export var icon_path: String = ""

# Special properties
@export var special_properties: Array = []
@export var description: String = ""

func _init(item_id: String = "", item_name: String = ""):
    id = item_id
    name = item_name

# Create item from data dictionary
static func from_data(data: Dictionary) -> Item:
    var item = Item.new(data.get("id", ""), data.get("name", ""))
    
    item.type = data.get("type", "")
    item.subtype = data.get("subtype", "")
    item.weight = data.get("weight", 0)
    item.size = data.get("size", "small")
    
    if data.has("damage"):
        item.damage = data.damage.duplicate()
    
    if data.has("weapon_modes"):
        item.weapon_modes = data.weapon_modes.duplicate(true)
    
    if data.has("armor_rating"):
        item.armor_rating = data.armor_rating.duplicate()
    
    item.capacity = data.get("capacity", 0)
    item.charges = data.get("charges", 0)
    
    if data.has("research_required"):
        item.research_required = data.research_required.duplicate()
    
    if data.has("manufacturing_cost"):
        item.manufacturing_cost = data.manufacturing_cost.duplicate()
    
    item.sprite_path = data.get("sprite_path", "")
    item.icon_path = data.get("icon_path", "")
    
    if data.has("special_properties"):
        item.special_properties = data.special_properties.duplicate()
    
    item.description = data.get("description", "")
    
    return item

# Convert item to dictionary
func to_dict() -> Dictionary:
    return {
        "id": id,
        "name": name,
        "type": type,
        "subtype": subtype,
        "weight": weight,
        "size": size,
        "damage": damage.duplicate(),
        "weapon_modes": weapon_modes.duplicate(true),
        "armor_rating": armor_rating.duplicate(),
        "capacity": capacity,
        "charges": charges,
        "research_required": research_required.duplicate(),
        "manufacturing_cost": manufacturing_cost.duplicate(),
        "sprite_path": sprite_path,
        "icon_path": icon_path,
        "special_properties": special_properties.duplicate(),
        "description": description
    }

# Check if item is a weapon
func is_weapon() -> bool:
    return type == "weapon"

# Check if item is armor
func is_armor() -> bool:
    return type == "armor"

# Check if item is utility
func is_utility() -> bool:
    return type == "utility"

# Get weapon mode by ID
func get_weapon_mode(mode_id: String) -> Dictionary:
    for mode in weapon_modes:
        if mode.get("id", "") == mode_id:
            return mode
    return {}

# Check if item has a specific property
func has_property(property_name: String) -> bool:
    return property_name in special_properties

# Use charge (for consumable items)
func use_charge() -> bool:
    if charges > 0:
        charges -= 1
        return true
    return false

# Check if item has charges remaining
func has_charges() -> bool:
    return charges > 0

# Get armor rating for specific direction
func get_armor_rating(direction: String) -> int:
    return armor_rating.get(direction, 0)

# Calculate total armor rating (average)
func get_total_armor_rating() -> float:
    var total = 0
    for rating in armor_rating.values():
        total += rating
    return float(total) / armor_rating.size()

# Check if item can be equipped by unit
func can_equip(unit: Unit) -> bool:
    # Basic compatibility check - in real game this would be more complex
    match type:
        "weapon":
            return true  # All units can use weapons
        "armor":
            return true  # All units can wear armor
        "utility":
            return true  # All units can use utility items
        _:
            return false

# Get item value (for trading/selling)
func get_value() -> int:
    # Simple calculation based on weight and properties
    var base_value = weight * 10
    
    if is_weapon():
        base_value += damage.base * 5
    
    if is_armor():
        base_value += int(get_total_armor_rating()) * 20
    
    return base_value

# Get display name with charges if applicable
func get_display_name() -> String:
    if charges > 0:
        return name + " (" + str(charges) + ")"
    return name

# Check if item is two-handed
func is_two_handed() -> bool:
    return has_property("two_handed")

# Check if item requires both hands
func requires_both_hands() -> bool:
    return is_two_handed()

# Get weapon accuracy for specific mode
func get_weapon_accuracy(mode_id: String) -> int:
    var mode = get_weapon_mode(mode_id)
    return mode.get("accuracy", 0)

# Get weapon TU cost for specific mode
func get_weapon_tu_cost(mode_id: String) -> int:
    var mode = get_weapon_mode(mode_id)
    return mode.get("tu_cost", 0)

# Get weapon damage for specific mode
func get_weapon_damage(mode_id: String) -> Dictionary:
    var mode = get_weapon_mode(mode_id)
    var mode_damage = mode.get("damage", {})
    
    # Merge with base damage
    var result = damage.duplicate()
    for key in mode_damage:
        result[key] = mode_damage[key]
    
    return result
