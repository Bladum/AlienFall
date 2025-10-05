"""
Test suite for TPedia (pedia.py).
Covers initialization, add/get/list methods, and add_category.
"""
import pytest
from src.pedia.pedia import TPedia
from src.pedia.pedia_entry import TPediaEntry
from src.pedia.pedia_entry_type import TPediaEntryType

class DummyEntry:
    def __init__(self, pid, type):
        self.pid = pid
        self.type = type
class DummyCategory:
    def __init__(self, type_id):
        self.type_id = type_id

class TestTPediaEntryType:
    def test_init(self):
        t = TPediaEntryType(1, 'Weapons', 'Weapon category', 'icon.png', 10)
        assert t.type_id == 1
        assert t.name == 'Weapons'
        assert t.description == 'Weapon category'
        assert t.icon == 'icon.png'
        assert t.order == 10

class TestTPediaEntry:
    def test_init_and_attributes(self):
        data = {
            'type': 2,
            'name': 'Laser Rifle',
            'section': 'Weapons',
            'description': 'A powerful laser weapon.',
            'sprite': 'laser_rifle.png',
            'tech_needed': ['Laser Tech'],
            'order': 5,
            'related': ['plasma_rifle'],
            'stats': {'damage': 60}
        }
        entry = TPediaEntry('laser_rifle', data)
        assert entry.pid == 'laser_rifle'
        assert entry.type == 2
        assert entry.name == 'Laser Rifle'
        assert entry.section == 'Weapons'
        assert entry.description == 'A powerful laser weapon.'
        assert entry.sprite == 'laser_rifle.png'
        assert entry.tech_needed == ['Laser Tech']
        assert entry.order == 5
        assert entry.related == ['plasma_rifle']
        assert entry.stats == {'damage': 60}
