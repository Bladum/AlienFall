"""
TItemType: Base item type definition that stores static parameters for all types of items.

Acts as the central reference for all item characteristics and parameters. Defines the static/unchanging properties of items that individual instances refer to, acting as a template for creating actual game items.

Classes:
    TItemType: Main class for item type definitions.

Last standardized: 2025-06-14
"""

from typing import Dict, List, Optional
from enums import EUnitItemCategory
from item.item_mode import TWeaponMode
from unit.unit_stat import TUnitStats

class TItemType:
    """
    Base item type definition for all types of items.

    Stores static parameters and acts as a template for item instances.

    Attributes:
        pid (str): Unique identifier for the item type.
        name (str): Human-readable name.
        category (int): Item category.
        description (str): Description text.
        weight (int): Item weight for inventory.
        size (int): Item size for base capacity.
        pedia (str): Pedia entry or reference.
        sprite (str): Path to sprite/icon.
        sound (str): Path to sound effect.
        tech_needed (List[str]): Technologies required to use.
        unit_damage (int): Damage value for unit use.
        unit_damage_type (str): Damage type for unit use.
        unit_accuracy (int): Accuracy value for unit use.
        unit_range (int): Range value for unit use.
        unit_ammo (int): Ammo capacity for unit use.
        unit_shots (int): Shots per action for unit use.
        unit_action_point (int): Action point cost for unit use.
        unit_stats (TUnitStats): Stat modifiers for units.
        unit_modes (Dict[str, TWeaponMode]): Available weapon modes.
        unit_rearm_cost (int): Rearm cost after battle.
        armour_defense (int): Armor defense value.
        armour_resistance (Dict[str, float]): Resistance by damage type.
        armour_shield (int): Shield value.
        armour_shield_regen (int): Shield regeneration per turn.
        armour_cover (List[int]): Cover values.
        armour_sight (List[int]): Sight modifiers.
        armour_sense (List[int]): Sense modifiers.
        primary_slots (int): Number of primary slots (if weapon).
        secondary_slots (int): Number of secondary slots (if equipment).
        craft_damage (int): Craft damage value.
        craft_accuracy (float): Craft accuracy value.
        craft_range (int): Craft range value.
        craft_ammo (int): Craft ammo capacity.
        craft_size (int): Craft size.
        craft_action_point (int): Craft action point cost.
        craft_rearm_time (int): Time to rearm craft.
        craft_rearm_cost (int): Cost to rearm craft.
        craft_reload_time (int): Time to reload craft weapon.
        manufacture_tech (List[str]): Techs required for manufacturing.
        purchase_tech (List[str]): Techs required for purchase.
        sell_cost (int): Sell cost.
        effects (Dict[str, object]): Special effects.
        bonus (Dict[str, object]): Bonus properties.
        requirements (Dict[str, object]): Requirements for use.
        is_underwater (bool): Whether item is usable underwater.
        modes (Dict[str, TWeaponMode]): Weapon modes.
    """
    pid: str
    name: str
    category: int
    description: str
    weight: int
    size: int
    pedia: str
    sprite: str
    sound: str
    tech_needed: List[str]
    unit_damage: int
    unit_damage_type: str
    unit_accuracy: int
    unit_range: int
    unit_ammo: int
    unit_shots: int
    unit_action_point: int
    unit_stats: TUnitStats
    unit_modes: Dict[str, TWeaponMode]
    unit_rearm_cost: int
    armour_defense: int
    armour_resistance: Dict[str, float]
    armour_shield: int
    armour_shield_regen: int
    armour_cover: List[int]
    armour_sight: List[int]
    armour_sense: List[int]
    primary_slots: int
    secondary_slots: int
    craft_damage: int
    craft_accuracy: float
    craft_range: int
    craft_ammo: int
    craft_size: int
    craft_action_point: int
    craft_rearm_time: int
    craft_rearm_cost: int
    craft_reload_time: int
    manufacture_tech: List[str]
    purchase_tech: List[str]
    sell_cost: int
    effects: Dict[str, object]
    bonus: Dict[str, object]
    requirements: Dict[str, object]
    is_underwater: bool
    modes: Dict[str, TWeaponMode]
    game: 'TGame'  # type: ignore

    def __init__(self, pid: str, data: Dict[str, object]) -> None:
        """
        Initialize a new item type definition.

        Args:
            pid (str): Unique identifier for the item type.
            data (Dict[str, object]): Dictionary of item type properties.
        """
        from engine.game import TGame
        self.game: 'TGame' = TGame()

        self.pid = pid
        self.name = data.get('name', pid)  # type: ignore
        self.category = data.get('category', 0)  # type: ignore
        self.description = data.get('description', '')  # type: ignore
        self.weight = data.get('weight', 0)  # type: ignore
        self.size = data.get('size', 0)  # type: ignore
        self.pedia = data.get('pedia', '')  # type: ignore
        self.sprite = data.get('sprite', '')  # type: ignore
        self.sound = data.get('sound', '')  # type: ignore
        self.tech_needed = data.get('tech_needed', [])  # type: ignore
        self.unit_damage = data.get('unit_damage', 0)  # type: ignore
        self.unit_damage_type = data.get('unit_damage_type', '')  # type: ignore
        self.unit_accuracy = data.get('unit_accuracy', 0)  # type: ignore
        self.unit_range = data.get('unit_range', 0)  # type: ignore
        self.unit_ammo = data.get('unit_ammo', 0)  # type: ignore
        self.unit_shots = data.get('unit_shots', 1)  # type: ignore
        self.unit_action_point = data.get('unit_action_point', 2)  # type: ignore
        self.unit_stats = TUnitStats(data.get('unit_stats', {}))  # type: ignore
        unit_modes: List[str] = data.get('unit_modes', ['snap'])  # type: ignore
        self.unit_modes = {mode: self.game.mod.weapon_modes.get(mode) for mode in unit_modes}
        self.unit_rearm_cost = data.get('unit_rearm_cost', 0)  # type: ignore
        self.armour_defense = data.get('armour', 0)  # type: ignore
        resistance_raw = data.get('resistance', {})  # type: ignore
        self.armour_resistance = {k: float(v) for k, v in resistance_raw.items()}
        self.armour_shield = data.get('shield', 0)  # type: ignore
        self.armour_shield_regen = data.get('shield_regen', 0)  # type: ignore
        self.armour_cover = data.get('armour_cover', [0, 0])  # type: ignore
        self.armour_sight = data.get('armour_sight', [0, 0])  # type: ignore
        self.armour_sense = data.get('armour_sense', [0, 0])  # type: ignore
        self.primary_slots = data.get('primary_slots', 1) if self.category == EUnitItemCategory.WEAPON else 0
        self.secondary_slots = data.get('secondary_slots', 2) if self.category == EUnitItemCategory.EQUIPMENT else 0
        self.craft_damage = data.get('craft_damage', 0)  # type: ignore
        self.craft_accuracy = data.get('craft_accuracy', 0.0)  # type: ignore
        self.craft_range = data.get('craft_range', 0)  # type: ignore
        self.craft_ammo = data.get('craft_ammo', 0)  # type: ignore
        self.craft_size = data.get('craft_size', 1)  # type: ignore
        self.craft_action_point = data.get('craft_action_point', 1)  # type: ignore
        self.craft_rearm_time = data.get('craft_rearm_time', 1)  # type: ignore
        self.craft_rearm_cost = data.get('craft_rearm_cost', 0)  # type: ignore
        self.craft_reload_time = data.get('craft_reload_time', 0)  # type: ignore
        self.manufacture_tech = data.get('manufacture_tech', [])  # type: ignore
        self.purchase_tech = data.get('purchase_tech', [])  # type: ignore
        self.sell_cost = data.get('sell_cost', 0)  # type: ignore
        self.effects = data.get('effects', {})  # type: ignore
        self.bonus = data.get('bonus', {})  # type: ignore
        self.requirements = data.get('requirements', {})  # type: ignore
        self.is_underwater = data.get('is_underwater', False)  # type: ignore
        self.modes = {}
        mode_names: List[str] = data.get('modes', ['snap'])  # type: ignore
        mode_defs: Optional[Dict[str, Dict[str, object]]] = data.get('mode_defs', None)  # type: ignore
        if mode_defs is None:
            mode_defs = {}
        for mode_name in mode_names:
            mode_data: Dict[str, object] = mode_defs.get(mode_name, {})
            self.modes[mode_name] = TWeaponMode(mode_name, mode_data)

    def get_mode_parameters(self, mode_name: str) -> Dict[str, object]:
        """
        Returns the effective parameters for the given mode.

        Args:
            mode_name (str): Name of the mode to retrieve parameters for.

        Returns:
            Dict[str, object]: Effective parameters for the mode (ap_cost, range, accuracy, shots, damage).
        """
        base_params: Dict[str, object] = {
            'ap_cost': self.unit_action_point,
            'range': self.unit_range,
            'accuracy': self.unit_accuracy,
            'shots': 1,
            'damage': self.unit_damage
        }
        mode: TWeaponMode = self.modes.get(mode_name, self.modes.get('snap'))
        return mode.apply(base_params)

