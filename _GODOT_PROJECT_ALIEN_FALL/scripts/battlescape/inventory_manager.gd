extends Node

# Inventory Manager - Handles unit equipment and inventory
# Manages weapons, armor, and equipment for battlescape units

class_name InventoryManager

# Inventory slots
enum SlotType { PRIMARY_WEAPON, SECONDARY_WEAPON, ARMOR, BELT, BACKPACK }

@export var max_inventory_slots: int = 20
@export var max_equipped_slots: int = 5

var inventory: Array = []  # Array of Item objects
var equipped_items: Dictionary = {}  # SlotType -> Item

func _ready():
    # Initialize equipped slots
    for slot in SlotType.values():
        equipped_items[slot] = null

# Add item to inventory
func add_item(item) -> bool:
    if inventory.size() >= max_inventory_slots:
        return false

    if item.stackable:
        # Try to stack with existing items
        for existing_item in inventory:
            if existing_item.item_id == item.item_id and existing_item.current_ammo < existing_item.max_stack:
                var space_available = existing_item.max_stack - existing_item.current_ammo
                var amount_to_add = min(item.current_ammo, space_available)
                existing_item.current_ammo += amount_to_add
                item.current_ammo -= amount_to_add

                if item.current_ammo <= 0:
                    return true  # Item fully stacked
                # Continue to add remaining as new stack
                break

    inventory.append(item)
    return true

# Remove item from inventory
func remove_item(item) -> bool:
    if item in inventory:
        inventory.erase(item)
        return true
    return false

# Equip item to specific slot
func equip_item(item, slot: SlotType) -> bool:
    if not can_equip_item(item, slot):
        return false

    # Unequip current item in slot if any
    if equipped_items[slot]:
        unequip_item(slot)

    # Remove from inventory and equip
    remove_item(item)
    equipped_items[slot] = item
    item.equipped = true

    # Apply stat bonuses
    if item.has_method("apply_stat_bonuses"):
        item.apply_stat_bonuses(get_parent())  # Parent should be the unit

    return true

# Unequip item from slot
func unequip_item(slot: SlotType) -> bool:
    var item = equipped_items[slot]
    if not item:
        return false

    # Remove stat bonuses
    if item.has_method("remove_stat_bonuses"):
        item.remove_stat_bonuses(get_parent())

    # Add back to inventory
    add_item(item)
    equipped_items[slot] = null
    item.equipped = false

    return true

# Check if item can be equipped in slot
func can_equip_item(item, slot: SlotType) -> bool:
    match slot:
        SlotType.PRIMARY_WEAPON, SlotType.SECONDARY_WEAPON:
            return item.type == item.ItemType.WEAPON
        SlotType.ARMOR:
            return item.type == item.ItemType.ARMOR
        SlotType.BELT, SlotType.BACKPACK:
            return item.type == item.ItemType.EQUIPMENT
        _:
            return false

# Get equipped weapon for specific slot
func get_equipped_weapon(slot: SlotType):
    if slot in [SlotType.PRIMARY_WEAPON, SlotType.SECONDARY_WEAPON]:
        return equipped_items[slot]
    return null

# Get all equipped weapons
func get_equipped_weapons() -> Array:
    var weapons = []
    for slot in [SlotType.PRIMARY_WEAPON, SlotType.SECONDARY_WEAPON]:
        var weapon = equipped_items[slot]
        if weapon:
            weapons.append(weapon)
    return weapons

# Get equipped armor
func get_equipped_armor():
    return equipped_items[SlotType.ARMOR]

# Calculate total armor rating from all equipped armor
func get_total_armor_rating() -> int:
    var total = 0
    var armor = get_equipped_armor()
    if armor:
        total += armor.armor_rating
    return total

# Calculate damage reduction for specific damage type
func get_damage_reduction(damage_type) -> int:
    var total_reduction = 0
    var armor = get_equipped_armor()
    if armor and armor.has_method("get_damage_reduction"):
        total_reduction += armor.get_damage_reduction(damage_type)
    return total_reduction

# Get all equipped items
func get_equipped_items() -> Array:
    var items = []
    for slot in equipped_items:
        if equipped_items[slot]:
            items.append(equipped_items[slot])
    return items

# Get inventory items (not equipped)
func get_inventory_items() -> Array:
    return inventory.duplicate()

# Find item by ID in inventory
func find_item_by_id(item_id: String):
    for item in inventory:
        if item.item_id == item_id:
            return item
    return null

# Get total weight of all items
func get_total_weight() -> int:
    var total = 0
    for item in inventory:
        total += item.weight
    for item in get_equipped_items():
        total += item.weight
    return total

# Check if unit can carry more weight
func can_carry_weight(additional_weight: int) -> bool:
    # Simple weight limit - could be based on unit strength
    var max_weight = 50  # Default max weight
    return get_total_weight() + additional_weight <= max_weight

# Get slot name for UI display
func get_slot_name(slot: SlotType) -> String:
    match slot:
        SlotType.PRIMARY_WEAPON:
            return "Primary Weapon"
        SlotType.SECONDARY_WEAPON:
            return "Secondary Weapon"
        SlotType.ARMOR:
            return "Armor"
        SlotType.BELT:
            return "Belt"
        SlotType.BACKPACK:
            return "Backpack"
        _:
            return "Unknown"

# Get inventory summary for UI
func get_inventory_summary() -> Dictionary:
    return {
        "total_items": inventory.size(),
        "equipped_items": get_equipped_items().size(),
        "total_weight": get_total_weight(),
        "weapons": get_equipped_weapons().size(),
        "has_armor": get_equipped_armor() != null
    }
