extends Resource
class_name Item

# Enhanced Item - Weapons, armor, and equipment for battlescape
# Supports multiple weapon modes, armor ratings, and special abilities

enum ItemType { WEAPON, ARMOR, EQUIPMENT, CONSUMABLE }
enum WeaponMode { SNAPSHOT, AIMED, AUTO, BURST }
enum DamageType { KINETIC, PLASMA, LASER, EXPLOSIVE, ACID }

@export var item_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var type: ItemType = ItemType.EQUIPMENT
@export var weight: int = 1
@export var value: int = 0

# Weapon-specific properties
@export var weapon_modes: Array[WeaponMode] = []
@export var base_damage: int = 0
@export var damage_type: DamageType = DamageType.KINETIC
@export var base_accuracy: int = 0
@export var ammo_capacity: int = 0
@export var current_ammo: int = 0
@export var range: int = 0
@export var shots_per_turn: int = 1

# Armor-specific properties
@export var armor_rating: int = 0
@export var damage_reduction: Dictionary = {}  # DamageType -> reduction percentage

# Equipment-specific properties
@export var abilities: Array[String] = []  # ability names
@export var stat_bonuses: Dictionary = {}  # stat_name -> bonus value
@export var passive_effects: Array[String] = []  # passive effect names

# Inventory properties
@export var stackable: bool = false
@export var max_stack: int = 1
@export var equipped: bool = false

func _init():
    # Initialize default damage reduction for armor
    if type == ItemType.ARMOR:
        for damage_type_enum in DamageType.values():
            damage_reduction[damage_type_enum] = 0

# Get weapon mode names for UI display
func get_weapon_mode_names() -> Array[String]:
    var names = []
    for mode in weapon_modes:
        match mode:
            WeaponMode.SNAPSHOT:
                names.append("Snapshot")
            WeaponMode.AIMED:
                names.append("Aimed")
            WeaponMode.AUTO:
                names.append("Auto")
            WeaponMode.BURST:
                names.append("Burst")
    return names

# Calculate damage for specific weapon mode
func get_damage_for_mode(mode: WeaponMode) -> int:
    match mode:
        WeaponMode.SNAPSHOT:
            return base_damage
        WeaponMode.AIMED:
            return base_damage + 10  # Aimed shots do more damage
        WeaponMode.AUTO:
            return base_damage - 5   # Auto fire less accurate but still good damage
        WeaponMode.BURST:
            return base_damage + 5   # Burst fire bonus
        _:
            return base_damage

# Calculate accuracy for specific weapon mode
func get_accuracy_for_mode(mode: WeaponMode) -> int:
    match mode:
        WeaponMode.SNAPSHOT:
            return base_accuracy + 20  # Snapshot is fast but less accurate
        WeaponMode.AIMED:
            return base_accuracy + 40  # Aimed is slow but very accurate
        WeaponMode.AUTO:
            return base_accuracy - 10  # Auto fire less accurate
        WeaponMode.BURST:
            return base_accuracy       # Burst is balanced
        _:
            return base_accuracy

# Calculate TU cost for specific weapon mode
func get_tu_cost_for_mode(mode: WeaponMode) -> int:
    match mode:
        WeaponMode.SNAPSHOT:
            return 30  # Fast shot
        WeaponMode.AIMED:
            return 60  # Takes time to aim
        WeaponMode.AUTO:
            return 50  # Moderate TU cost
        WeaponMode.BURST:
            return 40  # Balanced cost
        _:
            return 40

# Check if item can be used in current weapon mode
func can_use_mode(mode: WeaponMode) -> bool:
    return mode in weapon_modes

# Reload weapon
func reload() -> void:
    current_ammo = ammo_capacity

# Check if weapon needs reloading
func needs_reload() -> bool:
    return current_ammo <= 0 and ammo_capacity > 0

# Get damage reduction for specific damage type
func get_damage_reduction(damage_type: DamageType) -> int:
    if damage_reduction.has(damage_type):
        return damage_reduction[damage_type]
    return 0

# Apply stat bonuses to unit
func apply_stat_bonuses(unit) -> void:
    for stat_name in stat_bonuses:
        if unit.stats.has(stat_name):
            unit.stats[stat_name] += stat_bonuses[stat_name]

# Remove stat bonuses from unit
func remove_stat_bonuses(unit) -> void:
    for stat_name in stat_bonuses:
        if unit.stats.has(stat_name):
            unit.stats[stat_name] -= stat_bonuses[stat_name]

# Check if item has specific ability
func has_ability(ability_name: String) -> bool:
    return ability_name in abilities

# Get item info for UI display
func get_display_info() -> Dictionary:
    var info = {
        "name": name,
        "description": description,
        "type": ItemType.keys()[type],
        "weight": weight,
        "value": value
    }

    if type == ItemType.WEAPON:
        info["damage"] = base_damage
        info["accuracy"] = base_accuracy
        info["range"] = range
        info["ammo"] = str(current_ammo) + "/" + str(ammo_capacity)
        info["modes"] = get_weapon_mode_names()

    elif type == ItemType.ARMOR:
        info["armor_rating"] = armor_rating
        info["damage_reduction"] = damage_reduction

    elif type == ItemType.EQUIPMENT:
        info["abilities"] = abilities
        info["stat_bonuses"] = stat_bonuses

    return info
