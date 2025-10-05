"""
Test suite for engine.unit.unit (TUnit)
Covers initialization and attribute defaults using pytest.
"""
import pytest
from src.unit.unit import TUnit
from unittest.mock import MagicMock
from src.unit.unit import TUnit
from src.unit.unit_type import TUnitType
from src.unit.unit_stat import TUnitStats
from src.unit.race import TRace
from src.unit.trait import TTrait

class DummyInventoryManager:
    def __init__(self, unit):
        self.equipment_slots = {'Armor': None, 'Primary': None}
        self.stat_modifiers = {}
    def get_all_items(self):
        return []

class DummyTrait:
    def __init__(self):
        self.stats = TUnitStats({'health': 1})

class TestTUnit:
    def test_init(self):
        unit_type = MagicMock(spec=TUnitType)
        side_id = 1
        unit = TUnit(unit_type, side_id)
        assert unit.unit_type == unit_type
        assert unit.side_id == side_id
        assert unit.name == ''
        assert unit.nationality == ''
        assert unit.face == ''
        assert unit.female is False
        assert unit.inventory == []
        assert unit.position is None or isinstance(unit.position, tuple)
        assert unit.direction is None or isinstance(unit.direction, int)
        assert unit.alive is True
        assert unit.dead is False
        assert unit.mind_controlled is False
        assert unit.panicked is False
        assert unit.crazy is False
        assert unit.stunned is False
        assert unit.kneeling is False
        assert unit.running is False
        assert unit.stats is not None
        assert unit.traits is not None
        assert unit.inventory_manager is not None
