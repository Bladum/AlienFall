"""
Test suite for engine.unit.unit_inv_manager (InventoryTemplate, TUnitInventoryManager)
Covers initialization, to_dict, and from_dict methods using pytest.
"""
import pytest
from src.unit.unit_inv_manager import InventoryTemplate
from unittest.mock import MagicMock
from src.unit.unit_inv_manager import TUnitInventoryManager

@pytest.fixture
def template() -> InventoryTemplate:
    equipment_data = {'slot1': {'id': 'rifle', 'ammo': 5}}
    return InventoryTemplate('Alpha', equipment_data)

def test_init_defaults(template: InventoryTemplate) -> None:
    """Test initialization and attribute values."""
    assert template.name == 'Alpha'
    assert template.equipment_data == {'slot1': {'id': 'rifle', 'ammo': 5}}

def test_to_dict(template: InventoryTemplate) -> None:
    """Test to_dict returns correct dictionary."""
    d = template.to_dict()
    assert d['name'] == 'Alpha'
    assert d['equipment_data'] == {'slot1': {'id': 'rifle', 'ammo': 5}}

def test_from_dict() -> None:
    """Test from_dict creates a template with correct attributes."""
    data = {
        'name': 'Bravo',
        'equipment_data': {'slot2': {'id': 'pistol', 'ammo': 2}}
    }
    t = InventoryTemplate.from_dict(data)
    assert t.name == 'Bravo'
    assert t.equipment_data == {'slot2': {'id': 'pistol', 'ammo': 2}}

class DummyItem:
    def __init__(self, item_type='equipment', weight=1, stat_modifiers=None):
        self.item_type = item_type
        self.weight = weight
        self.stat_modifiers = stat_modifiers or {}
        self.to_dict = lambda: {'item_type': self.item_type, 'weight': self.weight}

class TestTUnitInventoryManager:
    def test_init_and_slots(self) -> None:
        mgr = TUnitInventoryManager()
        assert 'Armor' in mgr.equipment_slots
        assert 'Weapon' in mgr.equipment_slots
        assert isinstance(mgr.available_slots, set)
