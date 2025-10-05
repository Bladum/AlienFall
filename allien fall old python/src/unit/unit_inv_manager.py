"""
XCOM Unit Module: unit_inv_manager.py

Unified inventory management for units.

Classes:
    InventoryTemplate: Container for saved equipment configurations.
    TUnitInventoryManager: Handles equipment slots, stat modifications, templates, and auto-equip logic for unit inventories.

Last updated: 2025-06-14
"""

from typing import Optional, Dict, List, Set, Tuple
from item.item import TItem
from enums import EUnitItemCategory
from item.item_type import TItemType
from unit.unit import TUnit


class InventoryTemplate:
    """
    Container for saved equipment configurations.
    Templates allow players to save and quickly restore equipment setups for different scenarios or unit types.
    """
    def __init__(self, name: str, equipment_data: Dict[str, Optional[Dict[str, TItem]]]) -> None:
        """
        Initialize an InventoryTemplate.
        Args:
            name (str): Template name.
            equipment_data (Dict[str, Optional[Dict[str, TItem]]]): Mapping of slot names to item data dicts.
        """
        self.name: str = name
        self.equipment_data: Dict[str, Optional[Dict[str, TItem]]] = equipment_data

    def to_dict(self) -> Dict[str, object]:
        return {
            'name': self.name,
            'equipment_data': self.equipment_data
        }

    @classmethod
    def from_dict(cls, data: Dict[str, object]) -> 'InventoryTemplate':
        return cls(
            name=data['name'],
            equipment_data=data['equipment_data']
        )

class TUnitInventoryManager:
    """
    Unified inventory manager for a single unit.
    Handles slot logic, stat modification, template save/load, dynamic slot availability, and auto-equip.
    All attribute access is direct and all types are explicit.
    """
    def __init__(self, unit: Optional[TUnit] = None):
        self.unit: Optional[TUnit] = unit
        self.equipment_slots: Dict[str, Optional[TItem]] = {
            'Armor': None,
            'Weapon': None,
            'Equipment 1': None,
            'Equipment 2': None,
            'Equipment 3': None,
            'Equipment 4': None
        }
        self.slot_types: Dict[str, EUnitItemCategory] = {
            'Armor': EUnitItemCategory.ARMOR,
            'Weapon': EUnitItemCategory.WEAPON,
            'Equipment 1': EUnitItemCategory.EQUIPMENT,
            'Equipment 2': EUnitItemCategory.EQUIPMENT,
            'Equipment 3': EUnitItemCategory.EQUIPMENT,
            'Equipment 4': EUnitItemCategory.EQUIPMENT
        }
        self.available_slots: Set[str] = set(self.equipment_slots.keys())
        self.stat_modifiers: Dict[str, Dict[str, int]] = {k: {} for k in self.equipment_slots}
        self._template: Optional[Dict[str, object]] = None
        self._named_templates: Dict[str, InventoryTemplate] = {}
        self._update_available_slots()

    def _update_available_slots(self) -> None:
        armor_item: Optional[TItem] = self.equipment_slots.get('Armor')
        slots: int = 2
        if armor_item is not None:
            slots = armor_item.properties['equipment_slots'] if 'equipment_slots' in armor_item.properties else 2
            slots = max(1, min(4, slots))
        self.available_slots = {'Armor', 'Weapon'}
        for i in range(1, slots+1):
            self.available_slots.add(f'Equipment {i}')
        for i in range(slots+1, 5):
            slot = f'Equipment {i}'
            if self.equipment_slots[slot] is not None:
                self.equipment_slots[slot] = None

    def can_accept_item(self, item: TItem, slot_name: str) -> bool:
        if slot_name not in self.slot_types:
            return False
        slot_type: EUnitItemCategory = self.slot_types[slot_name]
        item_type: TItemType = item.item_type
        item_type_str: str = str(item_type).lower()
        if slot_type == EUnitItemCategory.ARMOR:
            return 'armor' in item_type_str or 'armour' in item_type_str
        elif slot_type == EUnitItemCategory.WEAPON:
            return 'weapon' in item_type_str
        elif slot_type == EUnitItemCategory.EQUIPMENT:
            return 'equipment' in item_type_str
        return False

    def equip_item(self, slot_name: str, item: TItem) -> bool:
        if slot_name not in self.equipment_slots or slot_name not in self.available_slots:
            return False
        if not self.can_accept_item(item, slot_name):
            return False
        self.unequip_item(slot_name)
        self.equipment_slots[slot_name] = item
        self.stat_modifiers[slot_name] = item.stat_modifiers
        self._apply_stat_modifiers(slot_name, item.stat_modifiers)
        if slot_name == 'Armor':
            self._update_available_slots()
        self._sync_to_unit_inventory()
        return True

    def unequip_item(self, slot_name: str) -> Optional[TItem]:
        if slot_name not in self.equipment_slots:
            return None
        item: Optional[TItem] = self.equipment_slots[slot_name]
        if item is None:
            return None
        if self.stat_modifiers.get(slot_name):
            self._remove_stat_modifiers(slot_name, self.stat_modifiers[slot_name])
            self.stat_modifiers[slot_name] = {}
        self.equipment_slots[slot_name] = None
        if slot_name == 'Armor':
            self._update_available_slots()
        self._sync_to_unit_inventory()
        return item

    def get_total_weight(self) -> int:
        total: int = 0
        for slot in self.available_slots:
            item: Optional[TItem] = self.equipment_slots.get(slot)
            if item is not None:
                total += item.weight
        return total

    def get_available_slots(self) -> List[str]:
        return list(self.available_slots)

    def save_template(self) -> Dict[str, object]:
        template: Dict[str, object] = {}
        for slot_name, item in self.equipment_slots.items():
            template[slot_name] = item.to_dict() if item is not None else None
        self._template = template
        return template

    def load_template(self, template: Dict[str, object]) -> None:
        for slot_name in self.equipment_slots:
            self.unequip_item(slot_name)
        for slot_name, item_data in template.items():
            if item_data is not None and slot_name in self.equipment_slots:
                item = TItem.from_dict(item_data)  # type: ignore
                self.equip_item(slot_name, item)
        self._template = template

    def save_named_template(self, name: str) -> None:
        data: Dict[str, object] = {slot: item.to_dict() if item is not None else None for slot, item in self.equipment_slots.items()}
        self._named_templates[name] = InventoryTemplate(name, data)

    def load_named_template(self, name: str) -> None:
        if name in self._named_templates:
            self.load_template(self._named_templates[name].equipment_data)

    def list_templates(self) -> List[str]:
        return list(self._named_templates.keys())

    def clear_all(self) -> None:
        for slot_name in self.equipment_slots:
            self.unequip_item(slot_name)
        self._update_available_slots()

    def get_all_items(self) -> List[TItem]:
        items: List[TItem] = []
        for slot in self.available_slots:
            item: Optional[TItem] = self.equipment_slots.get(slot)
            if item is not None:
                items.append(item)
        return items

    def to_dict(self) -> Dict[str, object]:
        result: Dict[str, object] = {
            'slots': {},
            'available_slots': list(self.available_slots)
        }
        for slot, item in self.equipment_slots.items():
            result['slots'][slot] = item.to_dict() if item is not None else None
        return result

    @classmethod
    def from_dict(cls, data: Dict[str, object], item_factory) -> 'TUnitInventoryManager':
        inv = cls()
        inv.available_slots = set(data.get('available_slots', []))
        for slot, item_data in data.get('slots', {}).items():
            if item_data is not None:
                inv.equipment_slots[slot] = item_factory(item_data)
        return inv

    def _apply_stat_modifiers(self, slot_name: str, modifiers: Dict[str, int]) -> None:
        if self.unit is None:
            return
        for stat_name, modifier in modifiers.items():
            if stat_name == "health":
                self.unit.health += modifier
            elif stat_name == "strength":
                self.unit.strength += modifier
            elif stat_name == "stamina":
                self.unit.stamina += modifier
            elif stat_name == "reactions":
                self.unit.reactions += modifier
            elif stat_name == "accuracy":
                self.unit.accuracy += modifier
            elif stat_name == "psi":
                self.unit.psi += modifier
            elif stat_name == "bravery":
                self.unit.bravery += modifier
            # Add more stat names as needed

    def _remove_stat_modifiers(self, slot_name: str, modifiers: Dict[str, int]) -> None:
        if self.unit is None:
            return
        for stat_name, modifier in modifiers.items():
            if stat_name == "health":
                self.unit.health -= modifier
            elif stat_name == "strength":
                self.unit.strength -= modifier
            elif stat_name == "stamina":
                self.unit.stamina -= modifier
            elif stat_name == "reactions":
                self.unit.reactions -= modifier
            elif stat_name == "accuracy":
                self.unit.accuracy -= modifier
            elif stat_name == "psi":
                self.unit.psi -= modifier
            elif stat_name == "bravery":
                self.unit.bravery -= modifier
            # Add more stat names as needed

    def _sync_to_unit_inventory(self) -> None:
        if self.unit is None:
            return
        self.unit.inventory = []
        for slot_name, item in self.equipment_slots.items():
            if item is not None:
                item.equipment_slot = slot_name
                self.unit.inventory.append(item)

    def auto_equip(self, item: TItem) -> Tuple[bool, str]:
        """
        Automatically equip an item in the first available slot of appropriate type.
        Returns (success, slot_name)
        """
        item_type: TItemType = item.item_type
        item_type_str: str = str(item_type).lower()
        if 'armor' in item_type_str or 'armour' in item_type_str:
            if self.can_accept_item(item, 'Armor') and self.equipment_slots['Armor'] is None:
                return self.equip_item('Armor', item), 'Armor'
        elif 'weapon' in item_type_str:
            if self.can_accept_item(item, 'Weapon') and self.equipment_slots['Weapon'] is None:
                return self.equip_item('Weapon', item), 'Weapon'
        elif 'equipment' in item_type_str:
            for i in range(1, 5):
                slot = f'Equipment {i}'
                if slot in self.available_slots and self.equipment_slots[slot] is None:
                    return self.equip_item(slot, item), slot
        return False, ''
